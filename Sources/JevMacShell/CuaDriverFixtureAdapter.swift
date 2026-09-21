import Foundation
import JevCore

struct CuaDriverProcessRunner: Sendable {
    let executablePath: String?

    init(fileManager: FileManager = .default) {
        let candidates = [
            fileManager.homeDirectoryForCurrentUser
                .appendingPathComponent(".local/bin/cua-driver").path,
            "/Applications/CuaDriver.app/Contents/MacOS/cua-driver",
            "/usr/local/bin/cua-driver"
        ]
        executablePath = candidates.first(where: fileManager.isExecutableFile(atPath:))
    }

    func run(arguments: [String]) throws -> Data {
        guard let executablePath else {
            throw CuaDriverProcessError.executableNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
        } catch {
            throw CuaDriverProcessError.launchFailed
        }

        let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
        _ = errorPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw CuaDriverProcessError.failed(process.terminationStatus)
        }
        guard !output.isEmpty else {
            throw CuaDriverProcessError.emptyOutput
        }
        return output
    }
}

enum CuaDriverProcessError: Error, Equatable, LocalizedError, Sendable {
    case executableNotFound
    case launchFailed
    case failed(Int32)
    case emptyOutput

    var errorDescription: String? {
        switch self {
        case .executableNotFound:
            return "The CuaDriver executable was not found on this Mac."
        case .launchFailed:
            return "The CuaDriver process could not be started."
        case let .failed(status):
            return "The CuaDriver process failed with status \(status)."
        case .emptyOutput:
            return "The CuaDriver process returned no response."
        }
    }
}

enum CuaDriverFixtureAdapterError: Error, Equatable, LocalizedError, Sendable {
    case unsupportedTarget
    case invalidWindowBinding
    case invalidSnapshot
    case fixtureWindowMismatch
    case reviewedButtonNotFound
    case landingButtonNotFound
    case invalidActionResponse
    case actionRejected
    case process(CuaDriverProcessError)

    var errorDescription: String? {
        switch self {
        case .unsupportedTarget:
            return "Computer-use execution is limited to safari-fixture-v1."
        case .invalidWindowBinding:
            return "The Safari fixture window binding is not a valid native window ID."
        case .invalidSnapshot:
            return "The computer-use accessibility snapshot could not be trusted."
        case .fixtureWindowMismatch:
            return "The computer-use snapshot was not the declared Safari fixture."
        case .reviewedButtonNotFound:
            return "The exact reviewed-fixture control was not found."
        case .landingButtonNotFound:
            return "The exact landing-fixture control was not found."
        case .invalidActionResponse:
            return "The computer-use action returned an invalid response."
        case .actionRejected:
            return "The computer-use action was not delivered through Accessibility."
        case let .process(error):
            return error.localizedDescription
        }
    }
}

@MainActor
final class CuaDriverFixtureAdapter {
    private static let fixtureVersion = "safari-fixture-v1"
    private static let fixtureTitle = "Jev Fixture v1"
    private static let reviewedButtonLabel = "Select reviewed fixture view"
    private static let landingButtonLabel = "Return to landing fixture view"
    private static let fixtureURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Dev Life/active/Meet Jev, Fastest Computer Use/Fixtures/SafariFixture-v1/index.html")

    private let processRunner: CuaDriverProcessRunner
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(processRunner: CuaDriverProcessRunner = CuaDriverProcessRunner()) {
        self.processRunner = processRunner
    }

    func pressReviewedFixture(expectedTarget: TargetBinding) async throws {
        try await pressFixtureButton(
            label: Self.reviewedButtonLabel,
            expectedTarget: expectedTarget
        )
    }

    func pressLandingFixture(expectedTarget: TargetBinding) async throws {
        try await pressFixtureButton(
            label: Self.landingButtonLabel,
            expectedTarget: expectedTarget
        )
    }

    private func pressFixtureButton(
        label: String,
        expectedTarget: TargetBinding
    ) async throws {
        guard expectedTarget.fixtureVersion == Self.fixtureVersion else {
            throw CuaDriverFixtureAdapterError.unsupportedTarget
        }
        guard expectedTarget.processID > 0 else {
            throw CuaDriverFixtureAdapterError.invalidWindowBinding
        }
        guard let windowID = Int(expectedTarget.windowID), windowID > 0 else {
            throw CuaDriverFixtureAdapterError.invalidWindowBinding
        }

        let session = "jev-fixture-\(UUID().uuidString)"
        let snapshot = try await getWindowState(
            processID: expectedTarget.processID,
            windowID: windowID,
            session: session
        )
        guard snapshot.processID == expectedTarget.processID,
              snapshot.windowID == windowID,
              snapshot.windowTitle == Self.fixtureTitle,
              Self.normalizedDocumentPath(snapshot.documentURL) == Self.fixtureURL.standardizedFileURL.path else {
            throw CuaDriverFixtureAdapterError.fixtureWindowMismatch
        }
        guard let button = snapshot.elements.first(where: {
            $0.role == "AXButton"
                && $0.label == label
                && $0.enabled != false
                && $0.elementToken != nil
        }), let elementToken = button.elementToken else {
            throw label == Self.reviewedButtonLabel
                ? CuaDriverFixtureAdapterError.reviewedButtonNotFound
                : CuaDriverFixtureAdapterError.landingButtonNotFound
        }

        let response: ClickResponse = try await call(
            tool: "click",
            request: ClickRequest(
                session: session,
                processID: expectedTarget.processID,
                windowID: windowID,
                elementToken: elementToken,
                action: "press",
                deliveryMode: "background"
            )
        )
        guard response.route == "accessibility",
              response.effect == "pressed",
              response.processID == expectedTarget.processID,
              response.windowID == windowID else {
            throw CuaDriverFixtureAdapterError.actionRejected
        }
    }

    private static func normalizedDocumentPath(_ value: String?) -> String? {
        guard let value else { return nil }
        if let url = URL(string: value), url.isFileURL {
            return url.standardizedFileURL.path
        }
        return URL(fileURLWithPath: value).standardizedFileURL.path
    }

    private func getWindowState(
        processID: Int,
        windowID: Int,
        session: String
    ) async throws -> WindowStateResponse {
        try await call(
            tool: "get_window_state",
            request: WindowStateRequest(
                processID: processID,
                windowID: windowID,
                session: session,
                includeScreenshot: false,
                maxElements: 500
            )
        )
    }

    private func call<Response: Decodable, Request: Encodable>(
        tool: String,
        request: Request
    ) async throws -> Response {
        let encoder = self.encoder
        let requestData: Data
        do {
            requestData = try encoder.encode(request)
        } catch {
            throw CuaDriverFixtureAdapterError.invalidActionResponse
        }
        let requestJSON = String(decoding: requestData, as: UTF8.self)
        let runner = processRunner

        let responseData: Data
        do {
            responseData = try await Task.detached(priority: .userInitiated) {
                try runner.run(arguments: ["call", tool, "--json", requestJSON])
            }.value
        } catch let error as CuaDriverProcessError {
            throw CuaDriverFixtureAdapterError.process(error)
        } catch {
            throw CuaDriverFixtureAdapterError.invalidActionResponse
        }

        do {
            return try decoder.decode(Response.self, from: responseData)
        } catch {
            throw CuaDriverFixtureAdapterError.invalidActionResponse
        }
    }
}

private struct WindowStateRequest: Encodable {
    let processID: Int
    let windowID: Int
    let session: String
    let includeScreenshot: Bool
    let maxElements: Int

    enum CodingKeys: String, CodingKey {
        case processID = "pid"
        case windowID = "window_id"
        case session
        case includeScreenshot = "include_screenshot"
        case maxElements = "max_elements"
    }
}

private struct ClickRequest: Encodable {
    let session: String
    let processID: Int
    let windowID: Int
    let elementToken: String
    let action: String
    let deliveryMode: String

    enum CodingKeys: String, CodingKey {
        case session
        case processID = "pid"
        case windowID = "window_id"
        case elementToken = "element_token"
        case action
        case deliveryMode = "delivery_mode"
    }
}

private struct WindowStateResponse: Decodable {
    let snapshotID: String?
    let processID: Int
    let windowID: Int
    let windowTitle: String?
    let documentURL: String?
    let elements: [AccessibilityElement]

    enum CodingKeys: String, CodingKey {
        case snapshotID = "snapshot_id"
        case processID = "pid"
        case windowID = "window_id"
        case windowTitle = "window_title"
        case documentURL = "document_url"
        case elements
    }
}

private struct AccessibilityElement: Decodable {
    let role: String?
    let label: String?
    let enabled: Bool?
    let elementToken: String?

    enum CodingKeys: String, CodingKey {
        case role
        case label
        case enabled
        case elementToken = "element_token"
    }
}

private struct ClickResponse: Decodable {
    let effect: String?
    let route: String?
    let processID: Int?
    let windowID: Int?

    enum CodingKeys: String, CodingKey {
        case effect
        case route
        case processID = "pid"
        case windowID = "window_id"
    }
}
