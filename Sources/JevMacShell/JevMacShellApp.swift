import AppKit
import ApplicationServices
import Darwin
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

    private let speechCapture = SpeechCapture()

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

    func beginListening() {
        transcript = "Requesting microphone and speech access…"
        speechCapture.begin()
    }

    func releaseCapture() {
        guard status == .listening else { return }
        transcript = "Finalizing transcript…"
        speechCapture.release()
    }

    func stop() {
        speechCapture.cancel()
        status = .stopped
        transcript = "Stopped. No action dispatched."
    }

    func reset() {
        speechCapture.reset()
        status = .armed
        transcript = "Hold to speak"
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
            status = .completed
        case .cancelled:
            status = .stopped
        case .blocked:
            status = .blocked
        case .failed:
            status = .failed
        }
    }
}

enum ShellStatus: String {
    case armed
    case requestingPermission
    case listening
    case finalizing
    case completed
    case stopped
    case blocked
    case failed

    var title: String {
        switch self {
        case .armed: return "Jev Armed"
        case .requestingPermission: return "Jev Waiting for Permission"
        case .listening: return "Jev Listening"
        case .finalizing: return "Jev Finalizing"
        case .completed: return "Jev Transcript Ready"
        case .stopped: return "Jev Stopped"
        case .blocked: return "Jev Permission Needed"
        case .failed: return "Jev Speech Failed"
        }
    }

    var symbol: String {
        switch self {
        case .armed: return "waveform"
        case .requestingPermission: return "lock.open"
        case .listening: return "mic.fill"
        case .finalizing: return "hourglass"
        case .completed: return "checkmark.circle"
        case .stopped: return "stop.circle"
        case .blocked: return "exclamationmark.triangle"
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

            HStack {
                Button("Hold to Speak") {
                    model.beginListening()
                }
                .keyboardShortcut("l", modifiers: [.command, .option])
                .disabled(model.status == .requestingPermission || model.status == .listening || model.status == .finalizing)

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
                .disabled(model.status == .requestingPermission || model.status == .listening || model.status == .finalizing)
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
