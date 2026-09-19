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

    var phase: SpeechCapturePhase {
        ledger.phase
    }

    init(locale: Locale = Locale(identifier: "en-CA")) {
        recognizer = SFSpeechRecognizer(locale: locale)
        recognizer?.defaultTaskHint = .dictation
    }

    func begin() {
        guard ledger.beginPermissionRequest() else { return }
        publishPhase()

        SFSpeechRecognizer.requestAuthorization { [weak self] authorization in
            DispatchQueue.main.async {
                guard let self else { return }
                guard authorization == .authorized else {
                    self.transitionToBlocked(message: "Speech recognition permission is required.")
                    return
                }

                AVAudioApplication.requestRecordPermission { [weak self] granted in
                    DispatchQueue.main.async {
                        guard let self else { return }
                        guard granted else {
                            self.transitionToBlocked(message: "Microphone permission is required.")
                            return
                        }
                        self.startRecognition()
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

        let timeout = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.ledger.phase == .finalizing else { return }
            _ = self.ledger.fail()
            self.stopRecognition(cancelTask: true)
            self.onError?("Speech finalization timed out.")
            self.publishPhase()
        }
        finalizationTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: timeout)
    }

    func cancel() {
        guard ledger.cancel() else { return }
        stopRecognition(cancelTask: true)
        publishPhase()
    }

    func reset() {
        finalizationTimeout?.cancel()
        finalizationTimeout = nil
        stopRecognition(cancelTask: true)
        ledger.reset()
        publishPhase()
    }

    private func startRecognition() {
        guard ledger.authorize() else { return }
        guard let recognizer, recognizer.isAvailable else {
            _ = ledger.fail()
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

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let result {
                    let transcript = result.bestTranscription.formattedString
                    if !transcript.isEmpty {
                        self.onTranscript?(transcript)
                    }
                    if result.isFinal && self.ledger.phase == .finalizing {
                        self.finalizationTimeout?.cancel()
                        self.finalizationTimeout = nil
                        _ = self.ledger.acceptFinalTranscript()
                        self.stopRecognition(cancelTask: false)
                        self.publishPhase()
                    }
                }

                if let error, self.ledger.phase == .listening || self.ledger.phase == .finalizing {
                    _ = self.ledger.fail()
                    self.stopRecognition(cancelTask: true)
                    self.onError?(error.localizedDescription)
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

    private func transitionToBlocked(message: String) {
        _ = ledger.denyPermission()
        onError?(message)
        publishPhase()
    }

    private func publishPhase() {
        onPhaseChange?(ledger.phase)
    }
}
