import ApplicationServices
import AppKit
import CoreGraphics
import Foundation
import JevCore

struct SafariFixtureRuntimeObservation: Equatable, Sendable {
    let binding: TargetBinding
    let view: FixtureView
    let title: String
}

enum SafariFixtureAdapterError: Error, Equatable, LocalizedError, Sendable {
    case accessibilityDenied
    case fixtureFileMissing
    case safariNotRunning
    case fixtureWindowNotFound
    case windowIdentityUnavailable
    case reviewedButtonNotFound
    case pressFailed(Int32)
    case verificationTimedOut

    var errorDescription: String? {
        switch self {
        case .accessibilityDenied:
            return "Accessibility permission is required for the Safari fixture."
        case .fixtureFileMissing:
            return "The versioned Safari fixture file is missing."
        case .safariNotRunning:
            return "Safari is not running."
        case .fixtureWindowNotFound:
            return "The versioned Safari fixture window was not found."
        case .windowIdentityUnavailable:
            return "The Safari fixture window identity could not be verified."
        case .reviewedButtonNotFound:
            return "The reviewed fixture control was not found."
        case let .pressFailed(status):
            return "The native fixture press failed with status \(status)."
        case .verificationTimedOut:
            return "The reviewed fixture postcondition was not observed before the deadline."
        }
    }
}

@MainActor
final class SafariFixtureAdapter {
    private static let fixtureTitle = "Jev Fixture v1"
    private static let reviewedButtonLabel = "Select reviewed fixture view"
    private static let reviewedState = "State: reviewed"
    private static let fixtureVersion = "safari-fixture-v1"

    let fixtureURL: URL

    init() {
        fixtureURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Dev Life/active/Meet Jev, Fastest Computer Use/Fixtures/SafariFixture-v1/index.html")
    }

    func connect() async throws -> SafariFixtureRuntimeObservation {
        guard AXIsProcessTrusted() else {
            throw SafariFixtureAdapterError.accessibilityDenied
        }
        guard FileManager.default.fileExists(atPath: fixtureURL.path) else {
            throw SafariFixtureAdapterError.fixtureFileMissing
        }
        guard NSWorkspace.shared.open(fixtureURL) else {
            throw SafariFixtureAdapterError.fixtureWindowNotFound
        }

        for _ in 0..<25 {
            if let observation = observe() {
                return observation
            }
            try await Task.sleep(nanoseconds: 200_000_000)
        }
        throw SafariFixtureAdapterError.fixtureWindowNotFound
    }

    func observe() -> SafariFixtureRuntimeObservation? {
        guard AXIsProcessTrusted() else { return nil }
        guard let safari = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.apple.Safari"
        ).first(where: { $0.processIdentifier > 0 }) else {
            return nil
        }

        let application = AXUIElementCreateApplication(safari.processIdentifier)
        guard let window = Self.findFixtureWindow(in: application) else {
            return nil
        }
        guard let title = Self.stringAttribute(window, kAXTitleAttribute),
              let windowID = Self.visibleWindowID(
                processID: safari.processIdentifier,
                title: title
              ) else {
            return nil
        }

        let view: FixtureView
        if Self.hasReviewedPostcondition(title: title, in: window) {
            view = .reviewed
        } else if Self.hasLandingPostcondition(title: title, in: window) {
            view = .landing
        } else {
            return nil
        }

        return SafariFixtureRuntimeObservation(
            binding: TargetBinding(
                processID: Int(safari.processIdentifier),
                windowID: String(windowID),
                fixtureVersion: Self.fixtureVersion
            ),
            view: view,
            title: title
        )
    }

    func waitForReviewed(
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        guard AXIsProcessTrusted() else {
            throw SafariFixtureAdapterError.accessibilityDenied
        }

        for _ in 0..<15 {
            if let observation = observe(),
               observation.binding == expectedTarget,
               observation.view == .reviewed {
                return observation
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw SafariFixtureAdapterError.verificationTimedOut
    }

    func selectReviewed(
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        guard AXIsProcessTrusted() else {
            throw SafariFixtureAdapterError.accessibilityDenied
        }
        guard let safari = NSRunningApplication.runningApplications(
            withBundleIdentifier: "com.apple.Safari"
        ).first(where: { $0.processIdentifier > 0 }) else {
            throw SafariFixtureAdapterError.safariNotRunning
        }

        let application = AXUIElementCreateApplication(safari.processIdentifier)
        guard let window = Self.findFixtureWindow(in: application) else {
            throw SafariFixtureAdapterError.fixtureWindowNotFound
        }
        guard let title = Self.stringAttribute(window, kAXTitleAttribute),
              let windowID = Self.visibleWindowID(
                processID: safari.processIdentifier,
                title: title
              ) else {
            throw SafariFixtureAdapterError.windowIdentityUnavailable
        }
        let actualTarget = TargetBinding(
            processID: Int(safari.processIdentifier),
            windowID: String(windowID),
            fixtureVersion: Self.fixtureVersion
        )
        guard actualTarget == expectedTarget else {
            throw SafariFixtureAdapterError.windowIdentityUnavailable
        }

        if Self.hasReviewedPostcondition(title: title, in: window) {
            return SafariFixtureRuntimeObservation(
                binding: actualTarget,
                view: .reviewed,
                title: title
            )
        }

        guard let button = Self.findReviewedButton(in: window) else {
            throw SafariFixtureAdapterError.reviewedButtonNotFound
        }
        let pressStatus = AXUIElementPerformAction(button, kAXPressAction as CFString)
        guard pressStatus == .success else {
            throw SafariFixtureAdapterError.pressFailed(pressStatus.rawValue)
        }

        for _ in 0..<15 {
            if let observation = observe(),
               observation.binding == expectedTarget,
               observation.view == .reviewed {
                return observation
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw SafariFixtureAdapterError.verificationTimedOut
    }

    private static func findFixtureWindow(in application: AXUIElement) -> AXUIElement? {
        for window in children(of: application, attribute: kAXWindowsAttribute) {
            let title = stringAttribute(window, kAXTitleAttribute) ?? ""
            if title.contains(fixtureTitle) || containsFixtureTitle(in: window, depth: 0) {
                return window
            }
        }
        return nil
    }

    private static func containsFixtureTitle(in element: AXUIElement, depth: Int) -> Bool {
        guard depth < 8 else { return false }
        let values = [
            stringAttribute(element, kAXTitleAttribute),
            stringAttribute(element, kAXValueAttribute),
            stringAttribute(element, kAXDescriptionAttribute)
        ]
        if values.contains(where: { $0?.contains(fixtureTitle) == true }) {
            return true
        }
        return children(of: element, attribute: kAXChildrenAttribute).contains {
            containsFixtureTitle(in: $0, depth: depth + 1)
        }
    }

    private static func findReviewedButton(in window: AXUIElement) -> AXUIElement? {
        find(in: window, depth: 0) { element in
            guard stringAttribute(element, kAXRoleAttribute) == kAXButtonRole else {
                return false
            }
            let values = [
                stringAttribute(element, kAXTitleAttribute),
                stringAttribute(element, kAXDescriptionAttribute),
                stringAttribute(element, kAXValueAttribute),
                stringAttribute(element, "AXIdentifier")
            ]
            return values.contains {
                normalize($0) == normalize(reviewedButtonLabel)
            }
        }
    }

    private static func hasReviewedPostcondition(title: String, in window: AXUIElement) -> Bool {
        title.hasSuffix("| Reviewed")
            && currentFixtureState(in: window) == reviewedState
    }

    private static func hasLandingPostcondition(title: String, in window: AXUIElement) -> Bool {
        title.hasSuffix("| Landing")
            && currentFixtureState(in: window) == "State: landing"
    }

    private static func currentFixtureState(in window: AXUIElement) -> String? {
        find(in: window, depth: 0) { element in
            guard isVisible(element) else { return false }
            let role = stringAttribute(element, kAXRoleAttribute)
            guard role == kAXStaticTextRole || role == "AXText" || role == "AXStatus" else {
                return false
            }
            let values = [
                stringAttribute(element, kAXTitleAttribute),
                stringAttribute(element, kAXValueAttribute),
                stringAttribute(element, kAXDescriptionAttribute)
            ]
            return values.contains {
                normalize($0) == normalize(reviewedState)
                    || normalize($0) == normalize("State: landing")
            }
        }.flatMap { element in
            [
                stringAttribute(element, kAXTitleAttribute),
                stringAttribute(element, kAXValueAttribute),
                stringAttribute(element, kAXDescriptionAttribute)
            ].first {
                let normalized = normalize($0)
                return normalized == normalize(reviewedState)
                    || normalized == normalize("State: landing")
            }
        }
    }

    private static func isVisible(_ element: AXUIElement) -> Bool {
        (attributeValue(element, kAXHiddenAttribute) as? Bool) != true
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
        attributeValue(element, attribute) as? [AXUIElement] ?? []
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
        let ownedWindows = raw.filter { info in
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? Int,
                  ownerPID == Int(processID) else { return false }
            return true
        }
        if let exact = ownedWindows.first(where: { info in
            let windowName = info[kCGWindowName as String] as? String ?? ""
            return !windowName.isEmpty
                && (title.contains(windowName) || windowName.contains(fixtureTitle))
        }) {
            return exact[kCGWindowNumber as String] as? CGWindowID
        }
        guard ownedWindows.count == 1 else { return nil }
        return ownedWindows[0][kCGWindowNumber as String] as? CGWindowID
    }
}
