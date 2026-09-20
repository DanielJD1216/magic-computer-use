import XCTest
@testable import JevCore

final class FastSubtaskProtocolTests: XCTestCase {
    func testPolicyBackendAndVerifierSeamsCompile() async throws {
        let subtask = try FastDesktopSubtask(
            goal: "Use the fixture",
            verification: .reviewedFixture,
            inputs: [:],
            constraints: [],
            maxActions: 1
        )
        let snapshot = FastDesktopSnapshot(
            application: "TestApp",
            window: "TestWindow",
            revision: "revision-1",
            elements: [],
            context: [:]
        )
        let policy: any FastDesktopDecisionPolicy = TestPolicy()
        let backend: any FastDesktopBackend = TestBackend(snapshot: snapshot)
        let verifier: any FastDesktopVerifier = TestVerifier()

        let decision = try await policy.decide(subtask: subtask, snapshot: snapshot, history: [])
        let observedSnapshot = try await backend.observe()
        let isFresh = try await backend.isFresh(
            snapshot: snapshot,
            action: FastDesktopAction(
                kind: .wait,
                targetID: nil,
                targetGuard: nil,
                inputKey: nil,
                value: nil
            )
        )
        let verification = await verifier.verify(
            verification: .reviewedFixture,
            snapshot: snapshot
        )

        XCTAssertEqual(decision.operation, .needsAgent)
        XCTAssertEqual(observedSnapshot, snapshot)
        XCTAssertTrue(isFresh)
        XCTAssertEqual(verification, .satisfied)
    }
}

private struct TestPolicy: FastDesktopDecisionPolicy {
    func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision {
        FastDesktopDecision(operation: .needsAgent)
    }
}

private struct TestBackend: FastDesktopBackend {
    let snapshot: FastDesktopSnapshot

    func observe() async throws -> FastDesktopSnapshot {
        snapshot
    }

    func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool {
        true
    }

    func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws {}
}

private struct TestVerifier: FastDesktopVerifier {
    func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult {
        .satisfied
    }
}
