import XCTest
@testable import JevCore

final class FastSubtaskModelsTests: XCTestCase {
    func testSubtaskRejectsEmptyGoal() {
        XCTAssertThrowsError(
            try FastDesktopSubtask(
                goal: "   ",
                verification: .reviewedFixture,
                inputs: [:],
                constraints: [],
                maxActions: 3
            )
        ) { error in
            XCTAssertEqual(error as? FastDesktopSubtaskError, .emptyGoal)
        }
    }

    func testSubtaskRejectsNonPositiveActionBudget() {
        XCTAssertThrowsError(
            try FastDesktopSubtask(
                goal: "Select reviewed view",
                verification: .reviewedFixture,
                inputs: [:],
                constraints: [],
                maxActions: 0
            )
        ) { error in
            XCTAssertEqual(error as? FastDesktopSubtaskError, .invalidActionBudget)
        }
    }

    func testSnapshotFindsElementByCurrentID() throws {
        let element = FastDesktopElement(
            id: "reviewed-button",
            role: "button",
            name: "Select reviewed fixture view",
            value: nil,
            actions: [.click],
            enabled: true,
            visible: true,
            semanticGuard: "guard-1"
        )
        let snapshot = FastDesktopSnapshot(
            application: "Safari",
            window: "Jev Fixture v1",
            revision: "revision-1",
            elements: [element],
            context: ["fixture_view": "landing"]
        )

        XCTAssertEqual(snapshot.element("reviewed-button"), element)
        XCTAssertEqual(snapshot.visibleElements.count, 1)
    }
}
