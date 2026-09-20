import XCTest
@testable import JevCore

final class FastSubtaskExecutorTests: XCTestCase {
    func testClickFollowedByVerifiedTerminalDecisionCompletes() async throws {
        let initial = snapshot(revision: "landing", semanticGuard: "landing-guard")
        let reviewed = snapshot(
            revision: "reviewed",
            semanticGuard: "reviewed-guard",
            context: ["fixture_view": "reviewed"]
        )
        let backend = ScriptedBackend(observations: [initial, reviewed])
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-button"),
            FastDesktopDecision(operation: .subtaskComplete)
        ])
        let verifier = ScriptedVerifier(result: .satisfied)
        let executor = makeExecutor(backend: backend, policy: policy, verifier: verifier)

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 3))
        let dispatchCount = await backend.dispatchCount()

        XCTAssertEqual(result.status, .subtaskComplete)
        XCTAssertEqual(result.history.count, 1)
        XCTAssertEqual(result.history.first?.kind, .click)
        XCTAssertEqual(dispatchCount, 1)
        XCTAssertEqual(result.finalSnapshot.context["fixture_view"], "reviewed")
    }

    func testStaleTargetCausesFreshObservationAndNewDecisionWithoutReplay() async throws {
        let stale = snapshot(revision: "stale", semanticGuard: "old-guard")
        let fresh = snapshot(revision: "fresh", semanticGuard: "new-guard", buttonID: "new-button")
        let reviewed = snapshot(
            revision: "reviewed",
            semanticGuard: "reviewed-guard",
            context: ["fixture_view": "reviewed"]
        )
        let backend = ScriptedBackend(
            observations: [stale, fresh, reviewed],
            freshness: [false, true]
        )
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-button"),
            FastDesktopDecision(operation: .click, targetID: "new-button"),
            FastDesktopDecision(operation: .subtaskComplete)
        ])
        let verifier = ScriptedVerifier(result: .satisfied)
        let executor = makeExecutor(backend: backend, policy: policy, verifier: verifier)

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 4))
        let dispatchCount = await backend.dispatchCount()
        let decisionCount = await policy.decisionCount()

        XCTAssertEqual(result.status, .subtaskComplete)
        XCTAssertEqual(result.history.count, 1)
        XCTAssertEqual(result.history.first?.targetID, "new-button")
        XCTAssertEqual(dispatchCount, 1)
        XCTAssertEqual(decisionCount, 3)
    }

    func testNoObservableChangeBlocksAfterConfiguredLimit() async throws {
        let unchanged = snapshot(revision: "same", semanticGuard: "same-guard")
        let backend = ScriptedBackend(observations: [unchanged])
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .wait),
            FastDesktopDecision(operation: .wait),
            FastDesktopDecision(operation: .wait)
        ])
        let executor = makeExecutor(
            backend: backend,
            policy: policy,
            verifier: ScriptedVerifier(result: .satisfied),
            configuration: configuration(noChangeLimit: 3)
        )

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 5))
        let dispatchCount = await backend.dispatchCount()

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.reasonCode, "no_observable_change")
        XCTAssertEqual(result.history.count, 3)
        XCTAssertEqual(dispatchCount, 3)
    }

    func testActionBudgetTerminatesWithoutAnotherPolicyDecision() async throws {
        let unchanged = snapshot(revision: "same", semanticGuard: "same-guard")
        let backend = ScriptedBackend(observations: [unchanged])
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .wait),
            FastDesktopDecision(operation: .wait),
            FastDesktopDecision(operation: .wait)
        ])
        let executor = makeExecutor(
            backend: backend,
            policy: policy,
            verifier: ScriptedVerifier(result: .satisfied),
            configuration: configuration(noChangeLimit: 10)
        )

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 2))
        let decisionCount = await policy.decisionCount()

        XCTAssertEqual(result.status, .needsAgent)
        XCTAssertEqual(result.reasonCode, "action_budget_exhausted")
        XCTAssertEqual(result.history.count, 2)
        XCTAssertEqual(decisionCount, 2)
    }

    func testCancellationBeforeDispatchStopsWithoutBackendMutation() async throws {
        let initial = snapshot(revision: "landing", semanticGuard: "landing-guard")
        let backend = ScriptedBackend(observations: [initial])
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-button")
        ])
        let executor = makeExecutor(
            backend: backend,
            policy: policy,
            verifier: ScriptedVerifier(result: .satisfied),
            cancellation: { true }
        )

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 3))
        let dispatchCount = await backend.dispatchCount()

        XCTAssertEqual(result.status, .stopped)
        XCTAssertEqual(result.reasonCode, "session_stopped")
        XCTAssertEqual(dispatchCount, 0)
    }

    func testFailedPostActionObservationReturnsOutcomeUnknownWithoutReplay() async throws {
        let initial = snapshot(revision: "landing", semanticGuard: "landing-guard")
        let backend = ScriptedBackend(
            observations: [initial],
            failObservationAfterDispatch: true
        )
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-button"),
            FastDesktopDecision(operation: .click, targetID: "reviewed-button")
        ])
        let executor = makeExecutor(
            backend: backend,
            policy: policy,
            verifier: ScriptedVerifier(result: .satisfied)
        )

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 3))
        let dispatchCount = await backend.dispatchCount()
        let decisionCount = await policy.decisionCount()

        XCTAssertEqual(result.status, .outcomeUnknown)
        XCTAssertEqual(result.reasonCode, "outcome_unknown")
        XCTAssertEqual(dispatchCount, 1)
        XCTAssertEqual(decisionCount, 1)
    }

    func testUnsatisfiedVerifierDoesNotReportCompletion() async throws {
        let initial = snapshot(revision: "landing", semanticGuard: "landing-guard")
        let backend = ScriptedBackend(observations: [initial])
        let policy = ScriptedPolicy(decisions: [
            FastDesktopDecision(operation: .subtaskComplete)
        ])
        let executor = makeExecutor(
            backend: backend,
            policy: policy,
            verifier: ScriptedVerifier(result: .notSatisfied)
        )

        let result = await executor.execute(subtask: try makeSubtask(maxActions: 3))
        let dispatchCount = await backend.dispatchCount()

        XCTAssertEqual(result.status, .needsAgent)
        XCTAssertEqual(result.reasonCode, "verification_failed")
        XCTAssertEqual(dispatchCount, 0)
    }

    private func makeExecutor(
        backend: ScriptedBackend,
        policy: ScriptedPolicy,
        verifier: ScriptedVerifier,
        configuration: FastDesktopRuntimeConfiguration? = nil,
        cancellation: @escaping @Sendable () -> Bool = { false }
    ) -> FastSubtaskExecutor {
        FastSubtaskExecutor(
            backend: backend,
            policy: policy,
            verifier: verifier,
            configuration: configuration ?? self.configuration(),
            cancellation: cancellation
        )
    }

    private func configuration(noChangeLimit: Int = 3) -> FastDesktopRuntimeConfiguration {
        FastDesktopRuntimeConfiguration(
            staleRetryLimit: 2,
            noChangeLimit: noChangeLimit,
            stableObservationCount: 1,
            maxSettleObservations: 1,
            pollNanoseconds: 0
        )
    }

    private func makeSubtask(maxActions: Int) throws -> FastDesktopSubtask {
        try FastDesktopSubtask(
            goal: "Select the reviewed fixture view",
            verification: .reviewedFixture,
            inputs: [:],
            constraints: ["Use only the local Safari fixture"],
            maxActions: maxActions
        )
    }

    private func snapshot(
        revision: String,
        semanticGuard: String,
        buttonID: String = "reviewed-button",
        context: [String: String] = ["fixture_view": "landing"]
    ) -> FastDesktopSnapshot {
        FastDesktopSnapshot(
            application: "Safari",
            window: "Jev Fixture v1",
            revision: revision,
            elements: [FastDesktopElement(
                id: buttonID,
                role: "button",
                name: "Select reviewed fixture view",
                value: nil,
                actions: [.click],
                enabled: true,
                visible: true,
                semanticGuard: semanticGuard
            )],
            context: context
        )
    }
}

private actor ScriptedPolicy: FastDesktopDecisionPolicy {
    private var decisions: [FastDesktopDecision]
    private var calls = 0

    init(decisions: [FastDesktopDecision]) {
        self.decisions = decisions
    }

    func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision {
        calls += 1
        guard !decisions.isEmpty else {
            return FastDesktopDecision(operation: .needsAgent)
        }
        return decisions.removeFirst()
    }

    func decisionCount() -> Int {
        calls
    }
}

private actor ScriptedVerifier: FastDesktopVerifier {
    let result: FastDesktopVerificationResult

    init(result: FastDesktopVerificationResult) {
        self.result = result
    }

    func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult {
        result
    }
}

private actor ScriptedBackend: FastDesktopBackend {
    private var observations: [FastDesktopSnapshot]
    private var freshness: [Bool]
    private let failObservationAfterDispatch: Bool
    private var dispatches = 0

    init(
        observations: [FastDesktopSnapshot],
        freshness: [Bool] = [],
        failObservationAfterDispatch: Bool = false
    ) {
        self.observations = observations
        self.freshness = freshness
        self.failObservationAfterDispatch = failObservationAfterDispatch
    }

    func observe() async throws -> FastDesktopSnapshot {
        if failObservationAfterDispatch && dispatches > 0 {
            throw TestBackendError.observationFailed
        }
        if observations.count > 1 {
            return observations.removeFirst()
        }
        guard let snapshot = observations.first else {
            throw TestBackendError.observationFailed
        }
        return snapshot
    }

    func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool {
        if !freshness.isEmpty {
            return freshness.removeFirst()
        }
        return true
    }

    func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws {
        dispatches += 1
    }

    func dispatchCount() -> Int {
        dispatches
    }
}

private enum TestBackendError: Error {
    case observationFailed
}
