import XCTest
@testable import JevCore

final class FastSubtaskIntegrationTests: XCTestCase {
    private let target = TargetBinding(
        processID: 42,
        windowID: "fixture-window",
        fixtureVersion: "safari-fixture-v1"
    )

    func testPlannerSubtaskPolicyExecutorBackendAndVerifierCompleteTogether() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let verifier = FastSubtaskSafariFixtureVerifier(state: state, target: target)
        let policy = ScriptedIntegrationPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-fixture-view"),
            FastDesktopDecision(operation: .subtaskComplete)
        ])
        let executor = FastSubtaskExecutor(
            backend: backend,
            policy: policy,
            verifier: verifier
        )
        let subtask = try FastDesktopSubtask(
            goal: "Select the reviewed fixture view",
            verification: .reviewedFixture,
            inputs: [:],
            constraints: ["Use only the local Safari fixture"],
            maxActions: 3
        )

        let result = await executor.execute(subtask: subtask)
        let dispatchCount = await state.dispatchCount()

        XCTAssertEqual(result.status, .subtaskComplete)
        XCTAssertEqual(result.history.count, 1)
        XCTAssertEqual(result.history.first?.targetID, "reviewed-fixture-view")
        XCTAssertEqual(result.finalSnapshot.context["fixture_view"], "reviewed")
        XCTAssertEqual(dispatchCount, 1)
    }

    func testUnknownTargetStopsBeforeFixtureDispatch() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let verifier = FastSubtaskSafariFixtureVerifier(state: state, target: target)
        let policy = ScriptedIntegrationPolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "unknown-target")
        ])
        let executor = FastSubtaskExecutor(
            backend: backend,
            policy: policy,
            verifier: verifier
        )
        let subtask = try FastDesktopSubtask(
            goal: "Select the reviewed fixture view",
            verification: .reviewedFixture,
            inputs: [:],
            constraints: [],
            maxActions: 2
        )

        let result = await executor.execute(subtask: subtask)
        let dispatchCount = await state.dispatchCount()

        XCTAssertEqual(result.status, .needsAgent)
        XCTAssertEqual(result.reasonCode, "invalid_action")
        XCTAssertEqual(dispatchCount, 0)
    }
}

private actor ScriptedIntegrationPolicy: FastDesktopDecisionPolicy {
    private var decisions: [FastDesktopDecision]

    init(decisions: [FastDesktopDecision]) {
        self.decisions = decisions
    }

    func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision {
        guard !decisions.isEmpty else {
            return FastDesktopDecision(operation: .needsAgent)
        }
        return decisions.removeFirst()
    }
}
