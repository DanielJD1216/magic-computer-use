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
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 640),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        panel.title = "Jev Command Panel"
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let hostingView = NSHostingView(rootView: CommandPanel(model: model))
        hostingView.sizingOptions = []
        panel.contentView = hostingView
        panel.center()
        self.panel = panel

        NSApp.setActivationPolicy(.regular)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)

        // MenuBarExtra may restore the accessory policy after the first panel
        // presentation. Reassert regular policy once SwiftUI has finished
        // scene setup so the visible panel remains addressable through the
        // native Accessibility tree as well as the window server.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak panel] in
            guard let self, let panel, self.panel === panel else { return }
            NSApp.setActivationPolicy(.regular)
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

@MainActor
final class ShellModel: ObservableObject {
    @Published private(set) var status: ShellStatus = .armed
    @Published private(set) var transcript = "Hold to speak"
    @Published private(set) var target = "Safari fixture • not connected"
    @Published private(set) var actionDetail = "No fixture action dispatched."
    @Published private(set) var activityLog: [ShellActivity] = []
    @Published private(set) var desktopControllerReady = false
    @Published private(set) var desktopControllerStatus = "Checking Hermes controller readiness…"

    private let speechCapture = SpeechCapture()
    private let fixtureAdapter: SafariFixtureAdapter
    private let computerUseAdapter: CuaDriverFixtureAdapter
    private let fastSubtaskRunner: SafariFixtureFastSubtaskRunner
    private let liveJevAdapter = LiveJevSelectionAdapter()
    private var fixtureObservation: SafariFixtureRuntimeObservation?
    private var lastRecognizedTranscript = ""
    private var sessionLedger = SessionLedger(sessionID: UUID().uuidString)
    private var activeCallback: CallbackIdentity?
    private var activeDispatchTask: Task<Void, Never>?


    var isFixtureConnected: Bool {
        fixtureObservation != nil
    }

    var computerUseMode: ComputerUseMode {
        ComputerUseConfiguration.mode
    }


    var displayTarget: String {
        computerUseMode == .experimentalDesktop
            ? "Current Mac desktop • \(desktopControllerReady ? "controller ready" : "controller bridge unavailable")"
            : target
    }

    var selectionSource: String {
        if computerUseMode == .experimentalDesktop {
            return desktopControllerReady
                ? "Hermes controller • current Mac session"
                : "Hermes controller bridge unavailable"
        }
        if LiveJevConfiguration.isEnabled {
            return JevCredentialStore.shared.hasCredential()
                ? "Live Jev selector enabled"
                : "Live Jev enabled • Keychain key required"
        }
        return "Local deterministic selector"
    }

    var executionSource: String {
        switch computerUseMode {
        case .native:
            return "Native Swift executor"
        case .bounded:
            return "Bounded CuaDriver executor • Safari fixture only"
        case .experimentalDesktop:
            return desktopControllerReady
                ? "Experimental desktop surface • Hermes + Mac CuaDriver"
                : "Experimental desktop surface • bridge unavailable"
        }
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
        let fixtureAdapter = SafariFixtureAdapter()
        self.fixtureAdapter = fixtureAdapter
        self.computerUseAdapter = CuaDriverFixtureAdapter()
        self.fastSubtaskRunner = SafariFixtureFastSubtaskRunner(adapter: fixtureAdapter)

        speechCapture.onPhaseChange = { [weak self] phase in
            self?.apply(phase: phase)
        }
        speechCapture.onTranscript = { [weak self] transcript in
            guard let self else { return }
            self.lastRecognizedTranscript = transcript
            self.transcript = transcript
        }
        speechCapture.onError = { [weak self] message in
            self?.transcript = message
        }

        Task { @MainActor [weak self] in
            self?.refreshDesktopController()
        }
    }

    func connectFixture() {
        guard !isBusy else { return }
        guard computerUseMode != .experimentalDesktop else {
            status = .blocked
            actionDetail = "Experimental desktop mode does not use the Safari fixture voice route."
            recordActivity(
                title: "Fixture connection blocked",
                detail: "Switch back to native or bounded mode before using the fixture."
            )
            return
        }
        status = .connecting
        target = "Safari fixture • connecting…"
        actionDetail = "Opening the declared Safari fixture and observing its exact target."
        recordActivity(
            title: "Connecting Safari fixture",
            detail: "Observing the declared local fixture target."
        )

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let observation = try await fixtureAdapter.connect()
                apply(observation: observation)
                status = .armed
                transcript = "Ready. Say “show me the reviewed fixture”."
                actionDetail = "Connected. No action dispatched."
                recordActivity(
                    title: "Safari fixture connected",
                    detail: "No action dispatched."
                )
            } catch {
                fixtureObservation = nil
                target = "Safari fixture • not connected"
                status = .blocked
                actionDetail = "Fixture connection blocked: \(error.localizedDescription)"
                transcript = "Connect the exact local Safari fixture before speaking."
                recordActivity(
                    title: "Fixture connection blocked",
                    detail: "The exact target could not be observed."
                )
            }
        }
    }

    func beginListening() {
        if computerUseMode == .experimentalDesktop {
            guard desktopControllerReady else {
                status = .blocked
                transcript = "Hermes desktop voice route is not ready."
                actionDetail = "Grant CuaDriver Accessibility and Screen Recording access, then Reset."
                recordActivity(
                    title: "Desktop voice route blocked",
                    detail: "Hermes/CuaDriver preflight is not ready."
                )
                return
            }
        } else {
            guard fixtureObservation != nil else {
                status = .blocked
                transcript = "Connect the exact local Safari fixture first."
                actionDetail = "No target observation exists, so no speech request was started."
                return
            }
        }
        guard !isBusy else { return }
        lastRecognizedTranscript = ""
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
        activeDispatchTask?.cancel()
        activeDispatchTask = nil
        status = .stopped
        transcript = "Stopped. No action dispatched or retried."
        actionDetail = "Any late callback is stale and cannot update this session."
        recordActivity(
            title: "Session stopped",
            detail: "No queued callback can resume this session."
        )
    }

    func reset() {
        speechCapture.reset()
        lastRecognizedTranscript = ""
        sessionLedger.startNewGoal()
        activeCallback = nil
        activeDispatchTask?.cancel()
        activeDispatchTask = nil
        status = .armed
        transcript = fixtureObservation == nil
            ? "Connect the exact local Safari fixture first."
            : "Ready. Hold to speak."
        actionDetail = "No fixture action dispatched."
        recordActivity(
            title: "Session reset",
            detail: "No action dispatched."
        )
        refreshDesktopController()
    }

    func refreshDesktopController() {
        desktopControllerReady = false
        desktopControllerStatus = "Deferred • no experimental desktop controller is enabled"
    }

    func runWorkspaceTypingProbe() {
        status = .blocked
        transcript = "Workspace test deferred."
        actionDetail = "No workspace action was dispatched. Descriptor-bound file handoff verification is still required."
        recordActivity(
            title: "Workspace test deferred",
            detail: "No TextEdit document or CuaDriver input was opened."
        )
    }

    func submitDesktopTask(_ task: String) {
        status = .blocked
        transcript = "Experimental desktop tasks are deferred."
        actionDetail = "No Hermes desktop task was submitted. The accepted surface is limited to the Safari fixture."
        recordActivity(
            title: "Desktop task deferred",
            detail: "No arbitrary desktop action was dispatched."
        )
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
        let commandTranscript = lastRecognizedTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !commandTranscript.isEmpty else {
            status = .blocked
            transcript = "No speech transcript was captured. Press Reset and try again."
            actionDetail = "No provider request or action was made because the final speech text was empty."
            return
        }
        transcript = commandTranscript

        if computerUseMode == .experimentalDesktop {
            status = .blocked
            actionDetail = "Experimental desktop tasks are deferred. No task was submitted."
            return
        }

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
        guard let callback = sessionLedger.startSelection(actionAttemptID: actionAttemptID) else {
            status = .blocked
            actionDetail = "The action attempt was stale before selection."
            return
        }
        activeCallback = callback

        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response: SelectionResponse
                if LiveJevConfiguration.isEnabled {
                    actionDetail = "Sending the minimized candidate request to live Jev."
                    response = try await liveJevAdapter.select(
                        transcript: commandTranscript,
                        request: request,
                        fixtureView: observation.view
                    )
                } else {
                    let selectedCapabilityID = FixtureCommandRouter.selectCapability(
                        for: commandTranscript,
                        candidates: candidates
                    )
                    response = SelectionResponse(
                        requestID: request.requestID,
                        candidateSetID: request.candidateSetID,
                        sessionGeneration: request.sessionGeneration,
                        actionAttemptID: request.actionAttemptID,
                        selectedCapabilityID: selectedCapabilityID
                    )
                }

                guard sessionLedger.accepts(callback), activeCallback == callback else {
                    return
                }
                guard let selectedCapabilityID = response.selectedCapabilityID else {
                    status = .blocked
                    actionDetail = "No approved fixture capability matched this final transcript."
                    return
                }

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

                status = .executing
                actionDetail = "Dispatching the bounded \(candidate.id.rawValue) capability."
                dispatch(candidate, callback: callback)
            } catch is CancellationError {
                guard sessionLedger.accepts(callback), activeCallback == callback else {
                    return
                }
                status = .stopped
                actionDetail = "Live Jev selection was cancelled. No action was dispatched."
            } catch {
                guard sessionLedger.accepts(callback), activeCallback == callback else {
                    return
                }
                status = .blocked
                actionDetail = "Selection blocked: \(error.localizedDescription)"
            }
        }
    }

    private func startDesktopTask(_ task: String) {
        status = .blocked
        actionDetail = "Experimental desktop tasks are deferred. No task was submitted."
    }

    private func refreshDesktopControllerReadiness() async {
        desktopControllerReady = false
        desktopControllerStatus = "Deferred • no experimental desktop controller is enabled"
    }

    private func dispatch(_ candidate: CapabilityCandidate, callback: CallbackIdentity) {
        activeDispatchTask?.cancel()
        let dispatchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let observation: SafariFixtureRuntimeObservation
                switch candidate.id {
                case .activatePreflightedSafariFixture:
                    observation = try await fixtureAdapter.connect()
                case .selectReviewedFixtureView:
                    if ComputerUseConfiguration.isEnabled {
                        guard try ComputerUsePolicy.action(for: candidate) == .pressReviewedFixture else {
                            status = .blocked
                            actionDetail = "The computer-use policy rejected this capability."
                            return
                        }
                        status = .executing
                        actionDetail = "Dispatching the exact fixture control through CuaDriver."
                        try await computerUseAdapter.pressReviewedFixture(
                            expectedTarget: candidate.target
                        )
                        status = .verifying
                        observation = try await fixtureAdapter.waitForReviewed(
                            expectedTarget: candidate.target
                        )
                    } else {
                        status = .executing
                        actionDetail = "Dispatching the capability through the bounded FastSubtaskExecutor."
                        let result = try await fastSubtaskRunner.execute(candidate: candidate)
                        guard sessionLedger.accepts(callback), activeCallback == callback else {
                            return
                        }
                        guard result.status == .subtaskComplete else {
                            switch result.status {
                            case .stopped:
                                status = .stopped
                                actionDetail = "Fast subtask stopped. No retry was made."
                            case .outcomeUnknown:
                                status = .outcomeUnknown
                                actionDetail = "Fast subtask outcome unknown. No automatic retry was made."
                            case .blocked, .needsAgent:
                                status = .blocked
                                actionDetail = "Fast subtask blocked: \(result.reasonCode ?? "verification_required")"
                            case .subtaskComplete:
                                break
                            }
                            return
                        }
                        guard let verifiedObservation = fixtureAdapter.observe(),
                              verifiedObservation.binding == candidate.target,
                              verifiedObservation.view == .reviewed else {
                            status = .outcomeUnknown
                            actionDetail = "Fast subtask completed without an exact fixture readback. No automatic retry was made."
                            return
                        }
                        observation = verifiedObservation
                    }
                case .returnToLandingFixtureView:
                    if ComputerUseConfiguration.isEnabled {
                        guard try ComputerUsePolicy.action(for: candidate) == .pressLandingFixture else {
                            status = .blocked
                            actionDetail = "The computer-use policy rejected this capability."
                            return
                        }
                        status = .executing
                        actionDetail = "Dispatching the exact landing control through CuaDriver."
                        try await computerUseAdapter.pressLandingFixture(
                            expectedTarget: candidate.target
                        )
                        status = .verifying
                        observation = try await fixtureAdapter.waitForLanding(
                            expectedTarget: candidate.target
                        )
                    } else {
                        status = .executing
                        actionDetail = "Dispatching the capability through the bounded FastSubtaskExecutor."
                        let result = try await fastSubtaskRunner.execute(candidate: candidate)
                        guard sessionLedger.accepts(callback), activeCallback == callback else {
                            return
                        }
                        guard result.status == .subtaskComplete else {
                            switch result.status {
                            case .stopped:
                                status = .stopped
                                actionDetail = "Fast subtask stopped. No retry was made."
                            case .outcomeUnknown:
                                status = .outcomeUnknown
                                actionDetail = "Fast subtask outcome unknown. No automatic retry was made."
                            case .blocked, .needsAgent:
                                status = .blocked
                                actionDetail = "Fast subtask blocked: \(result.reasonCode ?? "verification_required")"
                            case .subtaskComplete:
                                break
                            }
                            return
                        }
                        guard let verifiedObservation = fixtureAdapter.observe(),
                              verifiedObservation.binding == candidate.target,
                              verifiedObservation.view == .landing else {
                            status = .outcomeUnknown
                            actionDetail = "Fast subtask completed without an exact fixture readback. No automatic retry was made."
                            return
                        }
                        observation = verifiedObservation
                    }
                case .waitForReviewedFixtureState:
                    status = .verifying
                    observation = try await fixtureAdapter.waitForReviewed(
                        expectedTarget: candidate.target
                    )
                case .stop:
                    status = .stopped
                    actionDetail = "The selector requested stop. No action was dispatched."
                    return
                case .askUser:
                    status = .blocked
                    actionDetail = "The selector requested clarification or approval. No action was dispatched."
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
        activeDispatchTask = dispatchTask
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

    private func recordActivity(title: String, detail: String) {
        let event = ShellActivity(
            timestamp: Date(),
            title: title,
            detail: detail
        )
        activityLog = Array(([event] + activityLog).prefix(5))
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

    var tint: Color {
        switch self {
        case .completed:
            return .green
        case .blocked, .failed:
            return .red
        case .outcomeUnknown:
            return .orange
        case .stopped:
            return .secondary
        case .listening, .executing, .verifying, .selecting, .finalizing, .requestingPermission, .connecting:
            return .blue
        case .armed:
            return .accentColor
        }
    }
}

struct ShellActivity: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let title: String
    let detail: String
}

struct CommandPanel: View {
    @ObservedObject var model: ShellModel
    @State private var isShowingLiveConfiguration = false
    @State private var desktopTask = ""

    private var activeMode: ComputerUseMode {
        ComputerUseConfiguration.mode
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Label(model.status.title, systemImage: model.status.symbol)
                        .font(.headline)
                        .foregroundStyle(model.status.tint)
                    Spacer()
                    Text(activeMode.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(model.executionSource)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Stop", role: .destructive) {
                        model.stop()
                    }
                    .keyboardShortcut(.cancelAction)
                }

                ModeBanner(mode: activeMode)

                if activeMode == .experimentalDesktop {
                    DesktopTaskSurface(model: model, task: $desktopTask)
                } else {
                    BoundedControlsSurface(model: model, mode: activeMode)
                }

                PanelSection("Current state", systemImage: "waveform.path.ecg") {
                    StateLine(label: "Transcript", value: model.transcript)
                    StateLine(label: "Target", value: model.displayTarget)
                    StateLine(label: "Action", value: model.actionDetail)
                }

                PanelSection("Recent activity", systemImage: "clock.arrow.circlepath") {
                    if model.activityLog.isEmpty {
                        Text("No actions yet. Completed, stopped, blocked, and uncertain outcomes appear here.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(model.activityLog) { event in
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(event.title)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(event.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Text(event.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                HStack {
                    Button("Reset") {
                        model.reset()
                    }
                    .disabled(model.isBusy)

                    Spacer()

                    Button("Settings…") {
                        isShowingLiveConfiguration = true
                    }
                }
            }
            .padding(16)
        }
        .frame(minWidth: 420, idealWidth: 440, maxWidth: 560, minHeight: 520, idealHeight: 620)
        .sheet(isPresented: $isShowingLiveConfiguration) {
            SettingsView()
        }
    }
}

private struct ModeBanner: View {
    let mode: ComputerUseMode

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: mode == .experimentalDesktop ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                .foregroundStyle(mode == .experimentalDesktop ? .orange : .green)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            (mode == .experimentalDesktop ? Color.orange : Color.green).opacity(0.12),
            in: RoundedRectangle(cornerRadius: 9)
        )
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        switch mode {
        case .native:
            return "Native mode · registered capability only"
        case .bounded:
            return "Bounded mode · exact targets only"
        case .experimentalDesktop:
            return "Experimental desktop control active"
        }
    }

    private var message: String {
        switch mode {
        case .native:
            return "Jev can use the deterministic native Safari fixture route."
        case .bounded:
            return "CuaDriver can act only on the exact local Safari fixture controls."
        case .experimentalDesktop:
            return "This targets the current Mac session. It is not isolated."
        }
    }
}

private struct DesktopTaskSurface: View {
    @ObservedObject var model: ShellModel
    @Binding var task: String

    var body: some View {
        PanelSection("Desktop task", systemImage: "macwindow") {
            Text("Describe one concrete task for Hermes.")
                .font(.subheadline)

            TextEditor(text: $task)
                .frame(minHeight: 74, maxHeight: 120)
                .padding(4)
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(.quaternary)
                }
                .accessibilityLabel("Desktop task")
                .accessibilityHint("Describe one concrete task for the Hermes controller.")

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: model.desktopControllerReady ? "checkmark.circle.fill" : "network.slash")
                    .foregroundStyle(model.desktopControllerReady ? .green : .orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Controller status")
                        .font(.caption.weight(.semibold))
                    Text(model.desktopControllerStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Voice and typed tasks use this bridge only when readiness is verified.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !model.desktopControllerReady {
                Button("Refresh controller readiness") {
                    model.refreshDesktopController()
                }
                .disabled(model.isBusy)
            }

            if model.computerUseMode == .experimentalDesktop {
                HStack {
                    Button("Hold to Speak") {
                        model.beginListening()
                    }
                    .keyboardShortcut("l", modifiers: [.command, .option])
                    .disabled(model.isBusy || !model.desktopControllerReady)

                    Button("Release") {
                        model.releaseCapture()
                    }
                    .disabled(model.status != .listening)
                }

                Text("Hold to Speak, say the task, then Release. Common actions use Jev's fast native path; other tasks use Hermes and report completion or an uncertain outcome without retrying.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Send task to Hermes") {
                model.submitDesktopTask(task)
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.isBusy || task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !model.desktopControllerReady)

            Text("The button stays disabled until the SSH identity, Hermes command, and Mac CuaDriver preflight are ready. Enabling this mode does not silently change bounded mode.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private struct BoundedControlsSurface: View {
    @ObservedObject var model: ShellModel
    let mode: ComputerUseMode

    var body: some View {
        PanelSection("Bounded controls", systemImage: "checkmark.shield") {
            Button(model.isFixtureConnected ? "Refresh Safari Fixture" : "Connect Safari Fixture") {
                model.connectFixture()
            }
            .disabled(model.isBusy)

            Button("Mac Workspace Typing Test (deferred)") {
                model.runWorkspaceTypingProbe()
            }
            .disabled(true)

            if mode != .bounded {
                Text("The workspace probe is deferred and unavailable.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if mode != .experimentalDesktop {
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
            }
        }
    }
}

private struct PanelSection<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(_ title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 9) {
                content
            }
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}

private struct StateLine: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

struct SettingsView: View {
    @State private var apiKey = ""
    @State private var liveEnabled = LiveJevConfiguration.isEnabled
    @State private var computerUseEnabled = ComputerUseConfiguration.isEnabled
    @State private var experimentalDesktopEnabled = ComputerUseConfiguration.isExperimentalDesktopEnabled
    @State private var isShowingDesktopConfirmation = false
    @State private var message = ""

    private let credentialStore = JevCredentialStore.shared

    var body: some View {
        Form {
            Section("Selection source") {
                Toggle("Enable live Jev selection", isOn: $liveEnabled)
                    .disabled(!credentialStore.hasCredential())
                    .onChange(of: liveEnabled) { _, enabled in
                        LiveJevConfiguration.setEnabled(enabled)
                    }

                Text(credentialStore.hasCredential()
                    ? "TypeSafe key: stored in this Mac's Keychain."
                    : "TypeSafe key: not configured.")
                    .foregroundStyle(.secondary)
            }

            Section("Execution mode") {
                LabeledContent("Current mode", value: ComputerUseConfiguration.mode.title)

                Text(ComputerUseConfiguration.mode.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle("Enable bounded computer-use executor", isOn: $computerUseEnabled)
                    .disabled(experimentalDesktopEnabled)
                    .onChange(of: computerUseEnabled) { _, enabled in
                        ComputerUseConfiguration.setEnabled(enabled)
                        if enabled {
                            experimentalDesktopEnabled = false
                        }
                    }

                Text("When enabled, CuaDriver may use only the registered Safari fixture capability. The workspace expansion is deferred. The app binds an exact target and verifies a fresh postcondition. Arbitrary coordinates, navigation, passwords, system settings, and personal documents remain unavailable.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("The next workspace expansion requires descriptor-bound file handoff and exact document identity before it can be enabled. No TextEdit document is created by this checkpoint.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                if experimentalDesktopEnabled {
                    Label("Experimental desktop control is active", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    Text("This targets the current Mac user session. It is not an isolated user, VM, or disposable workspace. Voice and typed tasks stay disabled until Hermes SSH and CuaDriver preflight both pass.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Disable experimental desktop mode") {
                        ComputerUseConfiguration.setExperimentalDesktopEnabled(false)
                        experimentalDesktopEnabled = false
                    }
                } else {
                    Button("Experimental desktop mode (deferred)") {}
                        .disabled(true)

                    Text("Deferred. The current checkpoint does not expose an unrestricted controller or arbitrary desktop target.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("TypeSafe credential") {
                SecureField("Paste or type the API key here", text: $apiKey)

                HStack {
                    Button("Save to Keychain") {
                        do {
                            let pendingKey = apiKey
                            try credentialStore.save(apiKey: pendingKey)
                            apiKey = ""
                            message = "Saved to the Mac Keychain."
                        } catch {
                            message = error.localizedDescription
                        }
                    }
                    .disabled(apiKey.isEmpty)

                    Button("Forget key", role: .destructive) {
                        do {
                            try credentialStore.delete()
                            LiveJevConfiguration.setEnabled(false)
                            liveEnabled = false
                            message = "Removed from the Mac Keychain."
                        } catch {
                            message = error.localizedDescription
                        }
                    }
                    .disabled(!credentialStore.hasCredential())
                }

                if !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Live Jev receives only the final command fragment, fixture version/view, request identities, and descriptions from the closed local capability registry. Audio, screenshots, Accessibility trees, credentials, URLs, shell text, and full session history stay on the Mac.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Microphone and Speech Recognition permissions are requested only after Hold to Speak. Accessibility is used only for the exact local Safari fixture route. Workspace and experimental desktop routing remain deferred.")
                .foregroundStyle(.secondary)
        }
        .confirmationDialog(
            "Enable experimental desktop control?",
            isPresented: $isShowingDesktopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Enable current-Mac desktop mode", role: .destructive) {
                ComputerUseConfiguration.setExperimentalDesktopEnabled(true)
                computerUseEnabled = false
                experimentalDesktopEnabled = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This is not an isolated user or VM. The future Hermes controller could act in visible applications on this Mac. The current build has no controller bridge, so no task will run yet.")
        }
        .padding(20)
        .frame(width: 480)
    }
}
