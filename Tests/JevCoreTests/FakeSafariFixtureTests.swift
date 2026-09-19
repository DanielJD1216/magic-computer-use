import XCTest
@testable import JevCore

final class FakeSafariFixtureTests: XCTestCase {
    private let target = TargetBinding(
        processID: 42,
        windowID: "fixture-window",
        fixtureVersion: "fixture-v1"
    )

    func testReviewedViewOperationProducesExactVerifiedPostcondition() throws {
        var fixture = FakeSafariFixture(target: target)
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: target)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )

        let observation = try fixture.execute(candidate)

        XCTAssertEqual(observation.view, .reviewed)
        XCTAssertTrue(fixture.verify(expected: .reviewed, observed: observation))
        XCTAssertEqual(fixture.dispatchCount, 1)
    }

    func testTargetMismatchCannotExecuteFixtureOperation() throws {
        var fixture = FakeSafariFixture(target: target)
        let wrongTarget = TargetBinding(
            processID: 99,
            windowID: "other-window",
            fixtureVersion: "fixture-v1"
        )
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: wrongTarget)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )

        XCTAssertThrowsError(try fixture.execute(candidate)) { error in
            XCTAssertEqual(error as? FixtureExecutionError, .targetMismatch)
        }
        XCTAssertEqual(fixture.dispatchCount, 0)
    }

    func testVerifierRejectsStaleObservation() throws {
        var fixture = FakeSafariFixture(target: target)
        let candidate = try XCTUnwrap(
            CapabilityRegistry.firstSliceCandidates(target: target)
                .first(where: { $0.id == .selectReviewedFixtureView })
        )

        let firstObservation = try fixture.execute(candidate)
        _ = try fixture.execute(candidate)

        XCTAssertFalse(fixture.verify(expected: .reviewed, observed: firstObservation))
    }
}
