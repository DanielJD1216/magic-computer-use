import ApplicationServices
import Darwin
import SwiftUI

@main
@MainActor
struct JevMacShellApp: App {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var model = ShellModel()
    @State private var didOpenCommandPanel = false

    init() {
        if CommandLine.arguments.contains("--probe-accessibility") {
            print("AX_TRUSTED=\(AXIsProcessTrusted())")
            Darwin.exit(0)
        }
        if NativeProbe.runIfRequested() {
            Darwin.exit(0)
        }
    }

    var body: some Scene {
        MenuBarExtra {
            CommandPanel(model: model)
                .onAppear {
                    guard !didOpenCommandPanel else { return }
                    didOpenCommandPanel = true
                    openWindow(id: "command-panel")
                }
        } label: {
            Label(model.status.title, systemImage: model.status.symbol)
        }

        Window("Jev Command Panel", id: "command-panel") {
            CommandPanel(model: model)
        }
        .defaultSize(width: 380, height: 300)

        Settings {
            SettingsView()
        }
    }
}

@MainActor
final class ShellModel: ObservableObject {
    @Published private(set) var status: ShellStatus = .armed
    @Published private(set) var transcript = "Hold to speak"
    @Published private(set) var target = "Safari fixture • not connected"

    func beginListening() {
        status = .listening
        transcript = "Listening…"
    }

    func releaseCapture() {
        guard status == .listening else { return }
        status = .finalizing
        transcript = "Finalizing transcript…"
    }

    func stop() {
        status = .stopped
        transcript = "Stopped. No action dispatched."
    }

    func reset() {
        status = .armed
        transcript = "Hold to speak"
    }
}

enum ShellStatus: String {
    case armed
    case listening
    case finalizing
    case stopped

    var title: String {
        switch self {
        case .armed: return "Jev Armed"
        case .listening: return "Jev Listening"
        case .finalizing: return "Jev Finalizing"
        case .stopped: return "Jev Stopped"
        }
    }

    var symbol: String {
        switch self {
        case .armed: return "waveform"
        case .listening: return "mic.fill"
        case .finalizing: return "hourglass"
        case .stopped: return "stop.circle"
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
                .disabled(model.status == .listening || model.status == .finalizing)

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
                .disabled(model.status == .listening)
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
            Text("No microphone, Accessibility, Automation, or Jev permissions are requested by this shell.")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 420)
    }
}
