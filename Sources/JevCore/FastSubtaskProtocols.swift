import Foundation

public enum FastDesktopVerificationResult: Equatable, Sendable {
    case satisfied
    case notSatisfied
    case unavailable
}

public protocol FastDesktopDecisionPolicy: Sendable {
    func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision
}

public protocol FastDesktopBackend: Sendable {
    func observe() async throws -> FastDesktopSnapshot
    func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool
    func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws
}

public protocol FastDesktopVerifier: Sendable {
    func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult
}
