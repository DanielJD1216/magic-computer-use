import XCTest
@testable import JevCore

final class FastSubtaskSafariFixtureBackendTests: XCTestCase {
    private let target = TargetBinding(
        processID: 42,
        windowID: "fixture-window",
        fixtureVersion: "safari-fixture-v1"
    )

    func testInitialObservationExposesOnlyTheReviewedFixtureClickTarget() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)

        let snapshot = try await backend.observe()

        XCTAssertEqual(snapshot.application, "Safari")
        XCTAssertEqual(snapshot.window, "fixture-window")
        XCTAssertEqual(snapshot.context["fixture_view"], "landing")
        XCTAssertEqual(snapshot.context["fixture_version"], "safari-fixture-v1")
        XCTAssertEqual(snapshot.context["target_identity_class"], "preflighted-safari-fixture")
        XCTAssertEqual(snapshot.visibleElements.map(\.id), ["reviewed-fixture-view"])
        XCTAssertEqual(snapshot.visibleElements.first?.actions, [FastDesktopActionKind.click])
    }

    func testClickMapsToTheExistingReviewedCapabilityAndChangesFixtureState() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let before = try await backend.observe()
        let element = try XCTUnwrap(before.element("reviewed-fixture-view"))
        let action = FastDesktopAction(
            kind: .click,
            targetID: element.id,
            targetGuard: element.semanticGuard,
            inputKey: nil,
            value: nil
        )

        try await backend.execute(action: action, against: before)
        let after = try await backend.observe()
        let dispatchCount = await state.dispatchCount()

        XCTAssertEqual(after.context["fixture_view"], "reviewed")
        XCTAssertEqual(dispatchCount, 1)
        XCTAssertEqual(Set(CapabilityID.allCases), Set([
            .activatePreflightedSafariFixture,
            .selectReviewedFixtureView,
            .waitForReviewedFixtureState,
            .stop,
            .askUser
        ]))
    }

    func testTargetGuardAndBindingMismatchAreRejectedBeforeDispatch() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let snapshot = try await backend.observe()
        let element = try XCTUnwrap(snapshot.element("reviewed-fixture-view"))
        let staleAction = FastDesktopAction(
            kind: .click,
            targetID: element.id,
            targetGuard: "stale-guard",
            inputKey: nil,
            value: nil
        )

        await XCTAssertThrowsErrorAsync {
            try await backend.execute(action: staleAction, against: snapshot)
        } verify: { error in
            XCTAssertEqual(error as? FastSubtaskSafariFixtureBackendError, .staleTarget)
        }

        let mismatchedSnapshot = FastDesktopSnapshot(
            application: "Safari",
            window: "other-window",
            revision: snapshot.revision,
            elements: snapshot.elements,
            context: snapshot.context
        )
        let validAction = FastDesktopAction(
            kind: .click,
            targetID: element.id,
            targetGuard: element.semanticGuard,
            inputKey: nil,
            value: nil
        )
        await XCTAssertThrowsErrorAsync {
            try await backend.execute(action: validAction, against: mismatchedSnapshot)
        } verify: { error in
            XCTAssertEqual(error as? FastSubtaskSafariFixtureBackendError, .targetBindingMismatch)
        }

        let dispatchCount = await state.dispatchCount()
        XCTAssertEqual(dispatchCount, 0)
    }

    func testVerifierRequiresReviewedTypedFixtureStateAndCurrentTarget() async throws {
        let state = FastSubtaskSafariFixtureState(target: target)
        let backend = FastSubtaskSafariFixtureBackend(state: state, target: target)
        let verifier = FastSubtaskSafariFixtureVerifier(state: state, target: target)
        let initial = try await backend.observe()

        let initialVerification = await verifier.verify(
            verification: .reviewedFixture,
            snapshot: initial
        )
        XCTAssertEqual(initialVerification, .notSatisfied)

        let element = try XCTUnwrap(initial.element("reviewed-fixture-view"))
        try await backend.execute(
            action: FastDesktopAction(
                kind: .click,
                targetID: element.id,
                targetGuard: element.semanticGuard,
                inputKey: nil,
                value: nil
            ),
            against: initial
        )
        let reviewed = try await backend.observe()

        let reviewedVerification = await verifier.verify(
            verification: .reviewedFixture,
            snapshot: reviewed
        )
        XCTAssertEqual(reviewedVerification, .satisfied)
        let staleTargetSnapshot = FastDesktopSnapshot(
            application: reviewed.application,
            window: "other-window",
            revision: reviewed.revision,
            elements: reviewed.elements,
            context: reviewed.context
        )
        let staleVerification = await verifier.verify(
            verification: .reviewedFixture,
            snapshot: staleTargetSnapshot
        )
        XCTAssertEqual(staleVerification, .notSatisfied)
    }
}

private func XCTAssertThrowsErrorAsync(
    _ expression: @escaping () async throws -> Void,
    verify: (Error) -> Void
) async {
    do {
        try await expression()
        XCTFail("Expected the async expression to throw")
    } catch {
        verify(error)
    }
}
