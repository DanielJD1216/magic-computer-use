import XCTest
@testable import JevCore

final class FastSubtaskCapabilityRouteTests: XCTestCase {
    private let target = TargetBinding(
        processID: 42,
        windowID: "fixture-window",
        fixtureVersion: "safari-fixture-v1"
    )

    func testReviewedCapabilityRunsThroughTheBoundedExecutor() async throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: target)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )
        let subtask = try FastSubtaskCapabilityRoute.subtask(for: candidate)
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let verifier = FastSubtaskSafariFixtureVerifier(state: state, target: target)
        let executor = FastSubtaskExecutor(
            backend: backend,
            policy: FastSubtaskCapabilityPolicy(capability: candidate.id),
            verifier: verifier,
            configuration: FastDesktopRuntimeConfiguration(
                stableObservationCount: 1,
                maxSettleObservations: 1
            )
        )

        let result = await executor.execute(subtask: subtask)

        XCTAssertEqual(result.status, .subtaskComplete)
        XCTAssertEqual(result.history.count, 1)
        XCTAssertEqual(result.history.first?.targetID, "reviewed-fixture-view")
        let dispatchCount = await state.dispatchCount()
        XCTAssertEqual(dispatchCount, 1)
    }

    func testOtherCapabilitiesCannotCreateTheReviewedSubtask() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: target)
                .first(where: { $0.id == .waitForReviewedFixtureState })
        )

        XCTAssertThrowsError(try FastSubtaskCapabilityRoute.subtask(for: candidate)) { error in
            XCTAssertEqual(
                error as? FastSubtaskCapabilityRouteError,
                .unsupportedCapability
            )
        }
    }
}
