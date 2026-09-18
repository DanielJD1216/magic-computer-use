import XCTest
@testable import JevCore

final class TranscriptLedgerTests: XCTestCase {
    func testOlderPartialCannotReplaceNewerRevision() {
        var ledger = TranscriptLedger()
        ledger.begin()

        XCTAssertTrue(
            ledger.accept(
                TranscriptRevision(revision: 1, text: "open", phase: .partial)
            )
        )
        XCTAssertTrue(
            ledger.accept(
                TranscriptRevision(revision: 2, text: "open the", phase: .partial)
            )
        )
        XCTAssertFalse(
            ledger.accept(
                TranscriptRevision(revision: 1, text: "open", phase: .partial)
            )
        )
        XCTAssertEqual(ledger.latest?.text, "open the")
    }

    func testReleaseAndFinalizationAreDistinct() {
        var ledger = TranscriptLedger()
        ledger.begin()
        XCTAssertTrue(
            ledger.accept(
                TranscriptRevision(revision: 1, text: "open the fixture", phase: .partial)
            )
        )

        XCTAssertTrue(ledger.finishCapture())
        XCTAssertEqual(ledger.captureState, .finalizing)
        XCTAssertNotEqual(ledger.captureState, .cancelled)

        XCTAssertTrue(
            ledger.accept(
                TranscriptRevision(revision: 2, text: "open the fixture", phase: .final)
            )
        )
        XCTAssertEqual(ledger.captureState, .final)
    }

    func testAbortDoesNotBecomeFinalTranscript() {
        var ledger = TranscriptLedger()
        ledger.begin()
        XCTAssertTrue(ledger.finishCapture())

        ledger.abort()

        XCTAssertEqual(ledger.captureState, .cancelled)
        XCTAssertFalse(
            ledger.accept(
                TranscriptRevision(revision: 1, text: "discard me", phase: .final)
            )
        )
        XCTAssertNil(ledger.latest)
    }
}
