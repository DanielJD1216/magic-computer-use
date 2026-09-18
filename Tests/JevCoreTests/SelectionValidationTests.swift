import XCTest
@testable import JevCore

final class SelectionValidationTests: XCTestCase {
    private func request() -> CandidateRequest {
        let target = TargetBinding(
            processID: 42,
            windowID: "fixture-window",
            fixtureVersion: "fixture-v1"
        )
        let candidates = CapabilityRegistry.firstSliceCandidates(target: target)
            .filter { $0.id != .askUser }
        return CandidateRequest(
            requestID: "request-1",
            candidateSetID: "candidate-set-1",
            sessionGeneration: 3,
            actionAttemptID: "attempt-1",
            candidates: candidates
        )
    }

    func testValidSelectionResolvesToLocalCandidate() throws {
        let request = request()
        let response = SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: request.actionAttemptID,
            selectedCapabilityID: .selectReviewedFixtureView
        )

        let selected = try SelectionValidator.validate(response, against: request)

        XCTAssertEqual(selected.id, .selectReviewedFixtureView)
    }

    func testCapabilityOutsideExactCandidateSetIsRejected() {
        let request = request()
        let response = SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: request.actionAttemptID,
            selectedCapabilityID: .askUser
        )

        XCTAssertThrowsError(try SelectionValidator.validate(response, against: request)) { error in
            XCTAssertEqual(error as? SelectionValidationError, .capabilityNotInCandidateSet)
        }
    }

    func testStaleActionAttemptIsRejected() {
        let request = request()
        let response = SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: "old-attempt",
            selectedCapabilityID: .selectReviewedFixtureView
        )

        XCTAssertThrowsError(try SelectionValidator.validate(response, against: request)) { error in
            XCTAssertEqual(error as? SelectionValidationError, .actionAttemptMismatch)
        }
    }

    func testMissingSelectionIsRejected() {
        let request = request()
        let response = SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: request.actionAttemptID,
            selectedCapabilityID: nil
        )

        XCTAssertThrowsError(try SelectionValidator.validate(response, against: request)) { error in
            XCTAssertEqual(error as? SelectionValidationError, .selectionMissing)
        }
    }
}
