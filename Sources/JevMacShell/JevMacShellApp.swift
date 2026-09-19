import AppKit
import ApplicationServices
import Darwin
import Foundation
import JevCore
import SwiftUI

@main
@MainActor
struct JevMacShellApp: App {
    @StateObject private var model: ShellModel

    init() {
        let model = ShellModel()
        _model = StateObject(wrappedValue: model)

        if CommandLine.arguments.contains("--probe-accessibility") {
            print("AX_TRUSTED=\(AXIsProcessTrusted())")
            Darwin.exit(0)
        }
        if NativeProbe.runIfRequested() {
            Darwin.exit(0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            CommandPanelController.shared.show(model: model)
        }
    }

    var body: some Scene {
        MenuBarExtra {
            CommandPanel(model: model)
        } label: {
            Label(model.status.title, systemImage: model.status.symbol)
        }

        Settings {
            SettingsView()
        }
    }
}

@MainActor
final class CommandPanelController {
    static let shared = CommandPanelController()

    private var panel: NSPanel?

    func show(model: ShellModel) {
        if let panel, panel.isVisible {
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Jev Command Panel"
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: CommandPanel(model: model))
        panel.center()
        self.panel = panel

        NSApp.setActivationPolicy(.regular)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}

@MainActor
final class ShellModel: ObservableObject {
    @Published private(set) var status: ShellStatus = .armed
    @Published private(set) var transcript = "Hold to speak"
    @Published private(set) var target = "Safari fixture • not connected"
    @Published private(set) var actionDetail = "No fixture action dispatched."

    private let speechCapture = SpeechCapture()
    private let fixtureAdapter = SafariFixtureAdapter()
    private var fixtureObservation: SafariFixtureRuntimeObservation?
    private var sessionLedger = SessionLedger(sessionID: UUID().uuidString)
    private var activeCallback: CallbackIdentity?

    var isFixtureConnected: Bool {
        fixtureObservation != nil
    }

    var isBusy: Bool {
        switch status {
        case .connecting, .requestingPermission, .listening, .finalizing, .selecting, .executing, .verifying:
            return true
        case .armed, .completed, .stopped, .blocked, .outcomeUnknown, .failed:
            return false
        }
    }

    init() {
        speechCapture.onPhaseChange = { [weak self] phase in
            self?.apply(phase: phase)
        }
        speechCapture.onTranscript = { [weak self] transcript in
            self?.transcript = transcript
        }
        speechCapture.onError = { [weak self] message in
            self?.transcript = message
        }
    }

    func connectFixture() {
        guard !isBusy else { return }
        status = .connecting
        target = "Safari fixture • connecting…"
        actionDetail = "Opening the declared Safari fixture and observing its exact target."

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let observation = try await fixtureAdapter.connect()
                apply(observation: observation)
                status = .armed
                transcript = "Ready. Say “show me the reviewed fixture”."
                actionDetail = "Connected. No action dispatched."
            } catch {
                fixtureObservation = nil
                target = "Safari fixture • not connected"
                status = .blocked
                actionDetail = "Fixture connection blocked: \(error.localizedDescription)"
                transcript = "Connect the exact local Safari fixture before speaking."
            }
        }
    }

    func beginListening() {
        guard fixtureObservation != nil else {
            status = .blocked
            transcript = "Connect the exact local Safari fixture first."
            actionDetail = "No target observation exists, so no speech request was started."
            return
        }
        guard !isBusy else { return }
        sessionLedger.startNewGoal()
        sessionLedger.beginListening()
        activeCallback = nil
        status = .requestingPermission
        transcript = "Requesting microphone and speech access…"
        guard speechCapture.begin() else {
            status = .blocked
            transcript = "Speech capture could not start from the current lifecycle state."
            actionDetail = "No action dispatched. Press Reset before trying again."
            return
        }
    }

    func releaseCapture() {
        guard status == .listening else { return }
        guard sessionLedger.releaseCapture() else { return }
        transcript = "Finalizing transcript…"
        speechCapture.release()
    }

    func stop() {
        speechCapture.cancel()
        sessionLedger.stop()
        activeCallback = nil
        status = .stopped
        transcript = "Stopped. No action dispatched or retried."
        actionDetail = "Any late callback is stale and cannot update this session."
    }

    func reset() {
        speechCapture.reset()
        sessionLedger.startNewGoal()
        activeCallback = nil
        status = .armed
        transcript = fixtureObservation == nil
            ? "Connect the exact local Safari fixture first."
            : "Ready. Hold to speak."
        actionDetail = "No fixture action dispatched."
    }

    private func apply(phase: SpeechCapturePhase) {
        switch phase {
        case .idle:
            status = .armed
        case .requestingPermission:
            status = .requestingPermission
        case .listening:
            status = .listening
            if transcript == "Requesting microphone and speech access…" {
                transcript = "Listening…"
            }
        case .finalizing:
            status = .finalizing
        case .completed:
            guard sessionLedger.acceptFinalTranscript() else {
                status = .blocked
                actionDetail = "Final transcript rejected because the capture session was stale."
                return
            }
            executeFinalTranscript()
        case .cancelled:
            sessionLedger.stop()
            activeCallback = nil
            status = .stopped
        case .blocked:
            sessionLedger.startNewGoal()
            activeCallback = nil
            status = .blocked
        case .failed:
            sessionLedger.startNewGoal()
            activeCallback = nil
            status = .failed
        }
    }

    private func executeFinalTranscript() {
        guard let observation = fixtureObservation else {
            status = .blocked
            actionDetail = "No target observation exists, so no capability was dispatched."
            return
        }

        status = .selecting
        let actionAttemptID = UUID().uuidString
        let candidates = CapabilityRegistry.firstSliceCandidates(target: observation.binding)
        let request = CandidateRequest(
            requestID: UUID().uuidString,
            candidateSetID: UUID().uuidString,
            sessionGeneration: sessionLedger.sessionGeneration,
            actionAttemptID: actionAttemptID,
            candidates: candidates
        )
        let selectedCapabilityID = FixtureCommandRouter.selectCapability(
            for: transcript,
            candidates: candidates
        )
        let response = SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: request.actionAttemptID,
            selectedCapabilityID: selectedCapabilityID
        )

        guard let selectedCapabilityID else {
            status = .blocked
            actionDetail = "No approved fixture capability matched this final transcript."
            return
        }

        do {
            let candidate = try SelectionValidator.validate(response, against: request)
            guard PolicyGate.canDispatch(
                candidate: candidate,
                transcriptPhase: .final,
                target: observation.binding,
                now: Date()
            ) else {
                status = .blocked
                actionDetail = "The local policy gate rejected \(selectedCapabilityID.rawValue)."
                return
            }
            guard let callback = sessionLedger.startSelection(actionAttemptID: actionAttemptID) else {
                status = .blocked
                actionDetail = "The action attempt was stale before dispatch."
                return
            }
            activeCallback = callback
            status = .executing
            actionDetail = "Dispatching the bounded \(candidate.id.rawValue) capability."
            dispatch(candidate, callback: callback)
        } catch {
            status = .blocked
            actionDetail = "Selection validation rejected the capability: \(error.localizedDescription)"
        }
    }

    private func dispatch(_ candidate: CapabilityCandidate, callback: CallbackIdentity) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let observation: SafariFixtureRuntimeObservation
                switch candidate.id {
                case .activatePreflightedSafariFixture:
                    observation = try await fixtureAdapter.connect()
                case .selectReviewedFixtureView:
                    status = .verifying
                    observation = try await fixtureAdapter.selectReviewed(
                        expectedTarget: candidate.target
                    )
                case .waitForReviewedFixtureState:
                    status = .verifying
                    observation = try await fixtureAdapter.waitForReviewed(
                        expectedTarget: candidate.target
                    )
                case .stop, .askUser:
                    status = .blocked
                    actionDetail = "This capability is not executable in the fixture slice."
                    return
                }

                guard sessionLedger.accepts(callback), activeCallback == callback else {
                    return
                }
                guard observation.binding == candidate.target else {
                    status = .outcomeUnknown
                    actionDetail = "The target changed during execution. Outcome is unknown; no retry was made."
                    return
                }
                apply(observation: observation)
                status = .completed
                actionDetail = exactPostcondition(for: observation)
            } catch {
                guard sessionLedger.accepts(callback), activeCallback == callback else {
                    return
                }
                switch error {
                case SafariFixtureAdapterError.pressFailed, SafariFixtureAdapterError.verificationTimedOut:
                    status = .outcomeUnknown
                    actionDetail = "Outcome unknown: \(error.localizedDescription) No automatic retry was made."
                default:
                    status = .blocked
                    actionDetail = "Fixture action blocked: \(error.localizedDescription)"
                }
            }
        }
    }

    private func apply(observation: SafariFixtureRuntimeObservation) {
        fixtureObservation = observation
        let view = observation.view == .reviewed ? "Reviewed" : "Landing"
        target = "Safari fixture • connected • \(view)"
    }

    private func exactPostcondition(for observation: SafariFixtureRuntimeObservation) -> String {
        let state = observation.view == .reviewed ? "reviewed" : "landing"
        return "Verified: \(observation.title) / State: \(state)"
    }
}

enum ShellStatus: String {
    case armed
    case connecting
    case requestingPermission
    case listening
    case finalizing
    case selecting
    case executing
    case verifying
    case completed
    case stopped
    case blocked
    case outcomeUnknown
    case failed

    var title: String {
        switch self {
        case .armed: return "Jev Armed"
        case .connecting: return "Jev Connecting"
        case .requestingPermission: return "Jev Waiting for Permission"
        case .listening: return "Jev Listening"
        case .finalizing: return "Jev Finalizing"
        case .selecting: return "Jev Selecting"
        case .executing: return "Jev Executing"
        case .verifying: return "Jev Verifying"
        case .completed: return "Jev Completed"
        case .stopped: return "Jev Stopped"
        case .blocked: return "Jev Action Blocked"
        case .outcomeUnknown: return "Jev Outcome Unknown"
        case .failed: return "Jev Speech Failed"
        }
    }

    var symbol: String {
        switch self {
        case .armed: return "waveform"
        case .connecting: return "safari"
        case .requestingPermission: return "lock.open"
        case .listening: return "mic.fill"
        case .finalizing: return "hourglass"
        case .selecting: return "list.bullet.rectangle"
        case .executing: return "play.fill"
        case .verifying: return "checkmark.shield"
        case .completed: return "checkmark.circle"
        case .stopped: return "stop.circle"
        case .blocked: return "exclamationmark.triangle"
        case .outcomeUnknown: return "questionmark.diamond"
        case .failed: return "xmark.octagon"
        }
    }
}

struct CommandPanel: View {
    @ObservedObject var model: ShellModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(model.status.title, systemImage: model.status.symbol)
                    .font(.headline)
                Spacer()
                Text("Fixture only")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Transcript")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(model.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Target")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(model.target)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Action")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(model.actionDetail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
            }

            Button(model.isFixtureConnected ? "Refresh Safari Fixture" : "Connect Safari Fixture") {
                model.connectFixture()
            }
            .disabled(model.isBusy)

            HStack {
                Button("Hold to Speak") {
                    model.beginListening()
                }
                .keyboardShortcut("l", modifiers: [.command, .option])
                .disabled(model.isBusy || !model.isFixtureConnected)

                Button("Release") {
                    model.releaseCapture()
                }
                .disabled(model.status != .listening)
            }

            HStack {
                Button("Stop", role: .destructive) {
                    model.stop()
                }
                .keyboardShortcut(.cancelAction)

                Button("Reset") {
                    model.reset()
                }
                .disabled(model.isBusy)
            }
        }
        .padding(16)
        .frame(width: 340)
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Text("Jev is currently running in local fixture mode.")
            Text("Microphone and Speech Recognition permissions are requested only after Hold to Speak. Accessibility is used only for the reviewed Safari fixture action.")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 420)
    }
}
