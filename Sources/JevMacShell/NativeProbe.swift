import ApplicationServices
import AppKit
import AVFoundation
import Carbon.HIToolbox
import CoreGraphics
import Foundation
import Speech

struct NativeProbe {
    static func runIfRequested(arguments: [String] = CommandLine.arguments) -> Bool {
        guard let command = arguments.first(where: { $0.hasPrefix("--probe-") }) else {
            return false
        }

        switch command {
        case "--probe-speech":
            probeSpeech()
        case "--probe-hotkey":
            HotKeyProbe.run()
        case "--probe-safari":
            SafariFixtureProbe.run()
        default:
            print("PROBE_ERROR=unsupported_command")
        }
        return true
    }

    private static func probeSpeech() {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-CA"))
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = recognizer?.supportsOnDeviceRecognition ?? false
        request.endAudio()

        print("SPEECH_AUTHORIZATION=\(SFSpeechRecognizer.authorizationStatus().rawValue)")
        print("MICROPHONE_AUTHORIZATION=\(AVCaptureDevice.authorizationStatus(for: .audio).rawValue)")
        print("SPEECH_AVAILABLE=\(recognizer?.isAvailable ?? false)")
        print("SPEECH_ON_DEVICE=\(recognizer?.supportsOnDeviceRecognition ?? false)")
        print("REQUEST_ON_DEVICE=\(request.requiresOnDeviceRecognition)")
        print("REQUEST_FINALIZE=completed")
        request.endAudio()
        print("REQUEST_CANCEL_PATH=available")
    }
}

private final class HotKeyProbe {
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?

    static func run() {
        let probe = HotKeyProbe()
        probe.register()
        probe.cleanup()
    }

    private func register() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, _ in noErr },
            1,
            &eventSpec,
            nil,
            &handler
        )
        print("HOTKEY_EVENT_HANDLER_STATUS=\(handlerStatus)")

        let hotKeyID = EventHotKeyID(signature: OSType(0x4A455648), id: 1)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_L),
            UInt32(cmdKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKey
        )
        print("HOTKEY_REGISTER_STATUS=\(registerStatus)")
        print("HOTKEY_REGISTERED=\(registerStatus == noErr && hotKey != nil)")
        print("HOTKEY_SUPPRESSION_CLAIM=false")
        print("HOTKEY_KEYUP_TEST=not_run")
    }

    private func cleanup() {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
            self.hotKey = nil
        }
        if let handler {
            RemoveEventHandler(handler)
            self.handler = nil
        }
    }
}

private enum SafariFixtureProbe {
    private static let fixtureTitle = "Jev Fixture v1"
    private static let buttonLabel = "Select reviewed fixture view"
    private static let expectedState = "State: reviewed"

    static func run() {
        guard AXIsProcessTrusted() else {
            print("SAFARI_PROBE=blocked_accessibility")
            return
        }

        guard let safari = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.apple.Safari"
        ).first(where: { $0.processIdentifier > 0 }) else {
            print("SAFARI_PROBE=safari_not_running")
            return
        }

        let processID = safari.processIdentifier
        let application = AXUIElementCreateApplication(processID)
        guard let window = findFixtureWindow(in: application) else {
            print("SAFARI_PROBE=fixture_window_not_found")
            print("SAFARI_PID=\(processID)")
            return
        }

        let titleBefore = stringAttribute(window, kAXTitleAttribute) ?? ""
        let windowID = visibleWindowID(processID: processID, title: titleBefore)
        print("SAFARI_PID=\(processID)")
        print("SAFARI_WINDOW_TITLE_BEFORE=\(titleBefore)")
        print("SAFARI_WINDOW_ID=\(windowID.map(String.init) ?? "unknown")")
        print("SAFARI_FIXTURE_IDENTITY=\(titleBefore.contains(fixtureTitle))")

        guard let button = findButton(in: window) else {
            print("SAFARI_BUTTON_FOUND=false")
            return
        }
        print("SAFARI_BUTTON_FOUND=true")

        let pressStatus = AXUIElementPerformAction(button, kAXPressAction as CFString)
        print("SAFARI_PRESS_STATUS=\(pressStatus.rawValue)")
        RunLoop.main.run(until: Date().addingTimeInterval(0.8))

        let titleAfter = stringAttribute(window, kAXTitleAttribute) ?? ""
        let stateFound = containsExpectedState(in: window)
        let exactPostcondition = titleAfter.contains("Reviewed") && stateFound
        print("SAFARI_WINDOW_TITLE_AFTER=\(titleAfter)")
        print("SAFARI_STATE_FOUND=\(stateFound)")
        print("SAFARI_EXACT_POSTCONDITION=\(exactPostcondition)")
    }

    private static func findFixtureWindow(in application: AXUIElement) -> AXUIElement? {
        for window in children(of: application, attribute: kAXWindowsAttribute) {
            let title = stringAttribute(window, kAXTitleAttribute) ?? ""
            if title.contains(fixtureTitle) {
                return window
            }
            if containsFixtureTitle(in: window, depth: 0) {
                return window
            }
        }
        return nil
    }

    private static func containsFixtureTitle(in element: AXUIElement, depth: Int) -> Bool {
        guard depth < 8 else { return false }
        let text = [
            stringAttribute(element, kAXTitleAttribute),
            stringAttribute(element, kAXValueAttribute),
            stringAttribute(element, kAXDescriptionAttribute)
        ]
        if text.contains(where: { $0?.contains(fixtureTitle) == true }) {
            return true
        }
        return children(of: element, attribute: kAXChildrenAttribute).contains {
            containsFixtureTitle(in: $0, depth: depth + 1)
        }
    }

    private static func findButton(in window: AXUIElement) -> AXUIElement? {
        find(in: window, depth: 0) { element in
            let role = stringAttribute(element, kAXRoleAttribute)
            guard role == kAXButtonRole else { return false }
            let values = [
                stringAttribute(element, kAXTitleAttribute),
                stringAttribute(element, kAXDescriptionAttribute),
                stringAttribute(element, kAXValueAttribute),
                stringAttribute(element, "AXIdentifier")
            ]
            return values.contains { normalize($0) == normalize(buttonLabel) }
        }
    }

    private static func containsExpectedState(in window: AXUIElement) -> Bool {
        find(in: window, depth: 0) { element in
            let values = [
                stringAttribute(element, kAXTitleAttribute),
                stringAttribute(element, kAXValueAttribute),
                stringAttribute(element, kAXDescriptionAttribute)
            ]
            return values.contains { normalize($0) == normalize(expectedState) }
        } != nil
    }

    private static func find(
        in element: AXUIElement,
        depth: Int,
        matches: (AXUIElement) -> Bool
    ) -> AXUIElement? {
        guard depth < 12 else { return nil }
        if matches(element) { return element }
        for child in children(of: element, attribute: kAXChildrenAttribute) {
            if let match = find(in: child, depth: depth + 1, matches: matches) {
                return match
            }
        }
        return nil
    }

    private static func children(of element: AXUIElement, attribute: String) -> [AXUIElement] {
        guard let value = attributeValue(element, attribute) as? [AXUIElement] else { return [] }
        return value
    }

    private static func attributeValue(_ element: AXUIElement, _ attribute: String) -> Any? {
        var raw: CFTypeRef?
        let status = AXUIElementCopyAttributeValue(element, attribute as CFString, &raw)
        guard status == .success else { return nil }
        return raw
    }

    private static func stringAttribute(_ element: AXUIElement, _ attribute: String) -> String? {
        attributeValue(element, attribute) as? String
    }

    private static func normalize(_ value: String?) -> String {
        value?.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").lowercased() ?? ""
    }

    private static func visibleWindowID(processID: pid_t, title: String) -> CGWindowID? {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let raw = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        return raw.first { info in
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                  ownerPID == processID else { return false }
            let windowName = info[kCGWindowName as String] as? String ?? ""
            return windowName.isEmpty || title.contains(windowName) || windowName.contains(fixtureTitle)
        }?[kCGWindowNumber as String] as? CGWindowID
    }
}
