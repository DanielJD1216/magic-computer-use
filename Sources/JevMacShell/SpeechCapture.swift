import AVFoundation
import Foundation
import JevCore
import Speech

@MainActor
final class SpeechCapture {
    var onPhaseChange: ((SpeechCapturePhase) -> Void)?
    var onTranscript: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var finalizationTimeout: DispatchWorkItem?
    private var ledger = SpeechCaptureLedger()
    private var captureGeneration = 0

    var phase: SpeechCapturePhase {
        ledger.phase
    }

    init(locale: Locale = Locale(identifier: "en-CA")) {
        recognizer = SFSpeechRecognizer(locale: locale)
        recognizer?.defaultTaskHint = .dictation
    }

    func begin() {
        guard ledger.beginPermissionRequest() else { return }
        captureGeneration += 1
        let generation = captureGeneration
        publishPhase()

        SFSpeechRecognizer.requestAuthorization { @Sendable authorization in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.isCurrent(generation) else { return }
                guard authorization == .authorized else {
                    self.transitionToBlocked(
                        message: "Speech recognition permission is required.",
                        generation: generation
                    )
                    return
                }

                AVAudioApplication.requestRecordPermission { @Sendable granted in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        guard self.isCurrent(generation) else { return }
                        guard granted else {
                            self.transitionToBlocked(
                                message: "Microphone permission is required.",
                                generation: generation
                            )
                            return
                        }
                        self.startRecognition(generation: generation)
                    }
                }
            }
        }
    }

    func release() {
        guard ledger.releaseCapture() else { return }
        publishPhase()

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()

        let generation = captureGeneration
        let timeout = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.isCurrent(generation) else { return }
            guard self.ledger.phase == .finalizing else { return }
            _ = self.ledger.fail()
            self.captureGeneration += 1
            self.stopRecognition(cancelTask: true)
            self.onError?("Speech finalization timed out.")
            self.publishPhase()
        }
        finalizationTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: timeout)
    }

    func cancel() {
        guard ledger.cancel() else { return }
        captureGeneration += 1
        stopRecognition(cancelTask: true)
        publishPhase()
    }

    func reset() {
        finalizationTimeout?.cancel()
        finalizationTimeout = nil
        captureGeneration += 1
        stopRecognition(cancelTask: true)
        ledger.reset()
        publishPhase()
    }

    private func startRecognition(generation: Int) {
        guard isCurrent(generation) else { return }
        guard ledger.authorize() else { return }
        guard let recognizer, recognizer.isAvailable else {
            _ = ledger.fail()
            captureGeneration += 1
            onError?("On-device speech recognition is unavailable.")
            publishPhase()
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        recognitionRequest = request

        recognitionTask = recognizer.recognitionTask(with: request) { @Sendable [weak self] result, error in
            let transcript = result?.bestTranscription.formattedString
            let isFinal = result?.isFinal ?? false
            let errorMessage = error?.localizedDescription

            Task { @MainActor [weak self] in
                guard let self else { return }
                guard self.isCurrent(generation) else { return }
                if let transcript, !transcript.isEmpty {
                    self.onTranscript?(transcript)
                }
                if isFinal && self.ledger.phase == .finalizing {
                    self.finalizationTimeout?.cancel()
                    self.finalizationTimeout = nil
                    _ = self.ledger.acceptFinalTranscript()
                    self.stopRecognition(cancelTask: false)
                    self.publishPhase()
                }

                if let errorMessage, self.ledger.phase == .listening || self.ledger.phase == .finalizing {
                    _ = self.ledger.fail()
                    self.captureGeneration += 1
                    self.stopRecognition(cancelTask: true)
                    self.onError?(errorMessage)
                    self.publishPhase()
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            publishPhase()
        } catch {
            _ = ledger.fail()
            captureGeneration += 1
            stopRecognition(cancelTask: true)
            onError?(error.localizedDescription)
            publishPhase()
        }
    }

    private func stopRecognition(cancelTask: Bool) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        if cancelTask {
            recognitionTask?.cancel()
        }
        recognitionTask = nil
        recognitionRequest = nil
    }

    private func transitionToBlocked(message: String, generation: Int) {
        guard isCurrent(generation) else { return }
        _ = ledger.denyPermission()
        captureGeneration += 1
        onError?(message)
        publishPhase()
    }

    private func isCurrent(_ generation: Int) -> Bool {
        captureGeneration == generation
    }

    private func publishPhase() {
        onPhaseChange?(ledger.phase)
    }
}
