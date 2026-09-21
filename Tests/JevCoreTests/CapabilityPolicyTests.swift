import XCTest
@testable import JevCore

final class CapabilityPolicyTests: XCTestCase {
    func testRegistryContainsOnlyReviewedFirstSliceCapabilities() {
        XCTAssertEqual(
            CapabilityID.allCases,
            [
                .activatePreflightedSafariFixture,
                .selectReviewedFixtureView,
                .returnToLandingFixtureView,
                .waitForReviewedFixtureState,
                .stop,
                .askUser
            ]
        )
    }

    func testSafariOperationRequiresFinalTranscript() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(
                target: .init(processID: 42, windowID: "fixture-window", fixtureVersion: "fixture-v1")
            ).first(where: { $0.id == .selectReviewedFixtureView })
        )

        XCTAssertEqual(candidate.transcriptRequirement, .final)
        XCTAssertFalse(
            PolicyGate.canDispatch(
                candidate: candidate,
                transcriptPhase: .partial,
                target: candidate.target,
                now: candidate.expiresAt.addingTimeInterval(-1)
            )
        )
        XCTAssertTrue(
            PolicyGate.canDispatch(
                candidate: candidate,
                transcriptPhase: .final,
                target: candidate.target,
                now: candidate.expiresAt.addingTimeInterval(-1)
            )
        )
    }

    func testStaleTargetInvalidatesCandidate() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(
                target: .init(processID: 42, windowID: "fixture-window", fixtureVersion: "fixture-v1")
            ).first(where: { $0.id == .selectReviewedFixtureView })
        )
        let changedTarget = TargetBinding(
            processID: 42,
            windowID: "replacement-window",
            fixtureVersion: "fixture-v1"
        )

        XCTAssertFalse(
            PolicyGate.canDispatch(
                candidate: candidate,
                transcriptPhase: .final,
                target: changedTarget,
                now: candidate.expiresAt.addingTimeInterval(-1)
            )
        )
    }

    func testExpiredCandidateCannotDispatch() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(
                target: .init(processID: 42, windowID: "fixture-window", fixtureVersion: "fixture-v1")
            ).first(where: { $0.id == .selectReviewedFixtureView })
        )

        XCTAssertFalse(
            PolicyGate.canDispatch(
                candidate: candidate,
                transcriptPhase: .final,
                target: candidate.target,
                now: candidate.expiresAt.addingTimeInterval(1)
            )
        )
    }

    func testStopInvalidatesFutureDispatchAuthority() {
        var authority = SessionAuthority(sessionID: "session-1")
        XCTAssertTrue(authority.isValid)

        authority.stop()

        XCTAssertFalse(authority.isValid)
        XCTAssertEqual(authority.generation, 1)
    }

    func testOutcomeUnknownIsDistinctFromFailure() {
        XCTAssertNotEqual(ActionState.outcomeUnknown, .failed)
        XCTAssertTrue(ActionState.outcomeUnknown.requiresFreshObservation)
        XCTAssertFalse(ActionState.failed.requiresFreshObservation)
    }
}
