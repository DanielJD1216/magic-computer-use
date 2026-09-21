import XCTest
@testable import JevCore

final class FixtureCommandRouterTests: XCTestCase {
    private let target = TargetBinding(
        processID: 42,
        windowID: "window-1",
        fixtureVersion: "safari-fixture-v1"
    )

    func testReviewedRequestSelectsReviewedCapability() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)

        let selection = FixtureCommandRouter.selectCapability(
            for: "show me the reviewed fixture",
            candidates: candidates
        )

        XCTAssertEqual(selection, .selectReviewedFixtureView)
    }

    func testLandingRequestSelectsLandingCapability() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)

        let selection = FixtureCommandRouter.selectCapability(
            for: "return the fixture to the landing view",
            candidates: candidates
        )

        XCTAssertEqual(selection, .returnToLandingFixtureView)
    }

    func testOpenRequestSelectsActivationCapability() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)

        let selection = FixtureCommandRouter.selectCapability(
            for: "open the local Safari fixture",
            candidates: candidates
        )

        XCTAssertEqual(selection, .activatePreflightedSafariFixture)
    }

    func testWaitRequestSelectsWaitCapability() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)

        let selection = FixtureCommandRouter.selectCapability(
            for: "wait for the reviewed state",
            candidates: candidates
        )

        XCTAssertEqual(selection, .waitForReviewedFixtureState)
    }

    func testUnrelatedTranscriptDoesNotCreateAnAction() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)

        let selection = FixtureCommandRouter.selectCapability(
            for: "I don't know man can you hear me",
            candidates: candidates
        )

        XCTAssertNil(selection)
    }

    func testRouterCannotSelectCapabilityOutsideCandidateSet() {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)
            .filter { $0.id != .selectReviewedFixtureView }

        let selection = FixtureCommandRouter.selectCapability(
            for: "show me the reviewed fixture",
            candidates: candidates
        )

        XCTAssertNil(selection)
    }
}
