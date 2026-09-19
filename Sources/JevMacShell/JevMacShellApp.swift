import AppKit
import ApplicationServices
import Darwin
import SwiftUI

@main
@MainActor
struct JevMacShellApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

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
            CommandPanel(model: appDelegate.model)
        } label: {
            Label(appDelegate.model.status.title, systemImage: appDelegate.model.status.symbol)
        }

        Settings {
            SettingsView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = ShellModel()
    private var panel: NSPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("JEV_PANEL_DID_FINISH_LAUNCH")
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
        NSLog("JEV_PANEL_ORDERED_FRONT visible=\(panel.isVisible) key=\(panel.isKeyWindow)")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
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
