import XCTest
@testable import JevCore

final class ComputerUsePolicyTests: XCTestCase {
    private let validTarget = TargetBinding(
        processID: 42,
        windowID: "fixture-window",
        fixtureVersion: "safari-fixture-v1"
    )

    func testReviewedFixtureCapabilityMapsToComputerUsePress() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: validTarget)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )

        XCTAssertEqual(
            try ComputerUsePolicy.action(for: candidate),
            .pressReviewedFixture
        )
    }

    func testLandingFixtureCapabilityMapsToComputerUsePress() throws {
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: validTarget)
                .first(where: { $0.id == .returnToLandingFixtureView })
        )

        XCTAssertEqual(
            try ComputerUsePolicy.action(for: candidate),
            .pressLandingFixture
        )
    }

    func testNonReviewedCapabilityIsRejected() throws {
        let candidates = CapabilityRegistry.firstSliceCandidates(target: validTarget)
        for id in [
            CapabilityID.activatePreflightedSafariFixture,
            .waitForReviewedFixtureState,
            .stop,
            .askUser
        ] {
            let candidate = try XCTUnwrap(candidates.first(where: { $0.id == id }))
            XCTAssertThrowsError(try ComputerUsePolicy.action(for: candidate)) { error in
                XCTAssertEqual(error as? ComputerUsePolicyError, .unsupportedCapability)
            }
        }
    }

    func testNonFixtureTargetIsRejected() throws {
        let target = TargetBinding(
            processID: validTarget.processID,
            windowID: validTarget.windowID,
            fixtureVersion: "other-fixture-v1"
        )
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: target)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )

        XCTAssertThrowsError(try ComputerUsePolicy.action(for: candidate)) { error in
            XCTAssertEqual(error as? ComputerUsePolicyError, .unsupportedTarget)
        }
    }
}
