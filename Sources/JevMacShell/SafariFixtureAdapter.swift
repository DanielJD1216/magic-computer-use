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
    case landingButtonNotFound
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
        case .landingButtonNotFound:
            return "The landing fixture control was not found."
        case let .pressFailed(status):
            return "The native fixture press failed with status \(status)."
        case .verificationTimedOut:
            return "The requested fixture postcondition was not observed before the deadline."
        }
    }
}

@MainActor
final class SafariFixtureAdapter {
    private static let fixtureTitle = "Jev Fixture v1"
    private static let reviewedButtonLabel = "Select reviewed fixture view"
    private static let landingButtonLabel = "Return to landing fixture view"
    private static let reviewedState = "State: reviewed"
    private static let landingState = "State: landing"
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

        // Reuse an already uniquely identified fixture. Opening the declared
        // file first can create a second Safari window and make the target
        // ambiguous, which must remain fail-closed.
        if let existingObservation = observe() {
            return existingObservation
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
        guard let window = Self.findFixtureWindow(in: application, expectedURL: fixtureURL) else {
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
        try await waitFor(expectedView: .reviewed, expectedTarget: expectedTarget)
    }

    func waitForLanding(
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        try await waitFor(expectedView: .landing, expectedTarget: expectedTarget)
    }

    private func waitFor(
        expectedView: FixtureView,
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        guard AXIsProcessTrusted() else {
            throw SafariFixtureAdapterError.accessibilityDenied
        }

        for _ in 0..<15 {
            if let observation = observe(),
               observation.binding == expectedTarget,
               observation.view == expectedView {
                return observation
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw SafariFixtureAdapterError.verificationTimedOut
    }

    func selectReviewed(
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        try await select(
            expectedView: .reviewed,
            buttonLabel: Self.reviewedButtonLabel,
            expectedTarget: expectedTarget
        )
    }

    func selectLanding(
        expectedTarget: TargetBinding
    ) async throws -> SafariFixtureRuntimeObservation {
        try await select(
            expectedView: .landing,
            buttonLabel: Self.landingButtonLabel,
            expectedTarget: expectedTarget
        )
    }

    private func select(
        expectedView: FixtureView,
        buttonLabel: String,
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
        guard let window = Self.findFixtureWindow(in: application, expectedURL: fixtureURL) else {
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

        if expectedView == .reviewed,
           Self.hasReviewedPostcondition(title: title, in: window) {
            return SafariFixtureRuntimeObservation(
                binding: actualTarget,
                view: .reviewed,
                title: title
            )
        }
        if expectedView == .landing,
           Self.hasLandingPostcondition(title: title, in: window) {
            return SafariFixtureRuntimeObservation(
                binding: actualTarget,
                view: .landing,
                title: title
            )
        }

        guard let button = Self.findButton(in: window, label: buttonLabel) else {
            throw expectedView == .reviewed
                ? SafariFixtureAdapterError.reviewedButtonNotFound
                : SafariFixtureAdapterError.landingButtonNotFound
        }
        let pressStatus = AXUIElementPerformAction(button, kAXPressAction as CFString)
        guard pressStatus == .success else {
            throw SafariFixtureAdapterError.pressFailed(pressStatus.rawValue)
        }

        for _ in 0..<15 {
            if let observation = observe(),
               observation.binding == expectedTarget,
               observation.view == expectedView {
                return observation
            }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        throw SafariFixtureAdapterError.verificationTimedOut
    }

    private static func findFixtureWindow(
        in application: AXUIElement,
        expectedURL: URL
    ) -> AXUIElement? {
        for window in children(of: application, attribute: kAXWindowsAttribute) {
            let title = stringAttribute(window, kAXTitleAttribute) ?? ""
            guard title.contains(fixtureTitle) || containsFixtureTitle(in: window, depth: 0) else {
                continue
            }
            if hasExactFixtureDocument(in: window, expectedURL: expectedURL, depth: 0) {
                return window
            }
        }
        return nil
    }

    private static func hasExactFixtureDocument(
        in element: AXUIElement,
        expectedURL: URL,
        depth: Int
    ) -> Bool {
        guard depth < 12 else { return false }
        let expectedPath = expectedURL.standardizedFileURL.path
        for attribute in [kAXDocumentAttribute, "AXURL"] {
            guard let value = attributeValue(element, attribute) else { continue }
            let stringValue: String?
            if let value = value as? String {
                stringValue = value
            } else if let value = value as? URL {
                stringValue = value.absoluteString
            } else if let value = value as? NSURL {
                stringValue = value.absoluteString
            } else {
                stringValue = nil
            }
            guard let stringValue else { continue }
            if let documentURL = URL(string: stringValue), documentURL.isFileURL {
                if documentURL.standardizedFileURL.path == expectedPath {
                    return true
                }
            } else if stringValue == expectedPath {
                return true
            }
        }
        return children(of: element, attribute: kAXChildrenAttribute).contains {
            hasExactFixtureDocument(in: $0, expectedURL: expectedURL, depth: depth + 1)
        }
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

    private static func findButton(in window: AXUIElement, label: String) -> AXUIElement? {
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
                normalize($0) == normalize(label)
            }
        }
    }

    private static func hasReviewedPostcondition(title: String, in window: AXUIElement) -> Bool {
        title.hasSuffix("| Reviewed")
            && currentFixtureState(in: window) == reviewedState
    }

    private static func hasLandingPostcondition(title: String, in window: AXUIElement) -> Bool {
        title.hasSuffix("| Landing")
            && currentFixtureState(in: window) == landingState
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
            ].compactMap { $0 }.first {
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
