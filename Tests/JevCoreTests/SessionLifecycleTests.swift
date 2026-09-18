import XCTest
@testable import JevCore

final class SessionLifecycleTests: XCTestCase {
    func testReleasingPushToTalkFinalizesInsteadOfCancelling() {
        var session = SessionLedger(sessionID: "session-1")

        session.beginListening()
        XCTAssertEqual(session.captureState, .listening)

        XCTAssertTrue(session.releaseCapture())
        XCTAssertEqual(session.captureState, .finalizing)
        XCTAssertNotEqual(session.captureState, .cancelled)

        XCTAssertTrue(session.acceptFinalTranscript())
        XCTAssertEqual(session.captureState, .final)
    }

    func testStopInvalidatesLateCallbackAndMarksStopped() throws {
        var session = SessionLedger(sessionID: "session-1")
        session.beginListening()
        XCTAssertTrue(session.releaseCapture())
        XCTAssertTrue(session.acceptFinalTranscript())
        let callback = try XCTUnwrap(session.startSelection(actionAttemptID: "attempt-1"))

        session.stop()

        XCTAssertEqual(session.actionState, .stopped)
        XCTAssertFalse(session.accepts(callback))
    }

    func testOnlyCurrentActionAttemptCanApplyCallback() throws {
        var session = SessionLedger(sessionID: "session-1")
        session.beginListening()
        XCTAssertTrue(session.releaseCapture())
        XCTAssertTrue(session.acceptFinalTranscript())

        let first = try XCTUnwrap(session.startSelection(actionAttemptID: "attempt-1"))
        let second = try XCTUnwrap(session.startSelection(actionAttemptID: "attempt-2"))

        XCTAssertFalse(session.accepts(first))
        XCTAssertTrue(session.accepts(second))
    }

    func testNewSessionGenerationInvalidatesOldCallback() throws {
        var session = SessionLedger(sessionID: "session-1")
        session.beginListening()
        XCTAssertTrue(session.releaseCapture())
        XCTAssertTrue(session.acceptFinalTranscript())
        let callback = try XCTUnwrap(session.startSelection(actionAttemptID: "attempt-1"))
        let oldGeneration = session.sessionGeneration

        session.startNewGoal()

        XCTAssertEqual(session.sessionGeneration, oldGeneration + 1)
        XCTAssertFalse(session.accepts(callback))
        XCTAssertEqual(session.captureState, .off)
        XCTAssertEqual(session.actionState, .idle)
    }
}
