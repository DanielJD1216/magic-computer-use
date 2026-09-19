import XCTest
@testable import JevCore

final class SpeechCaptureStateTests: XCTestCase {
    func testAuthorizedReleaseFinalizesAndAcceptsFinalTranscript() {
        var capture = SpeechCaptureLedger()

        XCTAssertTrue(capture.beginPermissionRequest())
        XCTAssertEqual(capture.phase, .requestingPermission)
        XCTAssertTrue(capture.authorize())
        XCTAssertEqual(capture.phase, .listening)
        XCTAssertTrue(capture.releaseCapture())
        XCTAssertEqual(capture.phase, .finalizing)
        XCTAssertTrue(capture.acceptFinalTranscript())
        XCTAssertEqual(capture.phase, .completed)
    }

    func testTerminalCaptureCanPrepareForNextCapture() {
        var capture = SpeechCaptureLedger()

        XCTAssertTrue(capture.beginPermissionRequest())
        XCTAssertTrue(capture.authorize())
        XCTAssertTrue(capture.releaseCapture())
        XCTAssertTrue(capture.acceptFinalTranscript())

        XCTAssertTrue(capture.prepareForNextCapture())
        XCTAssertEqual(capture.phase, .idle)
        XCTAssertTrue(capture.beginPermissionRequest())
    }

    func testActiveCaptureCannotBeReplacedByNextCapture() {
        var capture = SpeechCaptureLedger()

        XCTAssertTrue(capture.beginPermissionRequest())
        XCTAssertTrue(capture.authorize())
        XCTAssertFalse(capture.prepareForNextCapture())
        XCTAssertEqual(capture.phase, .listening)
    }

    func testCancellationRejectsLateFinalTranscript() {
        var capture = SpeechCaptureLedger()

        XCTAssertTrue(capture.beginPermissionRequest())
        XCTAssertTrue(capture.authorize())
        XCTAssertTrue(capture.cancel())
        XCTAssertEqual(capture.phase, .cancelled)
        XCTAssertFalse(capture.acceptFinalTranscript())
    }

    func testPermissionDenialCannotStartListening() {
        var capture = SpeechCaptureLedger()

        XCTAssertTrue(capture.beginPermissionRequest())
        XCTAssertTrue(capture.denyPermission())
        XCTAssertEqual(capture.phase, .blocked)
        XCTAssertFalse(capture.releaseCapture())
    }
}