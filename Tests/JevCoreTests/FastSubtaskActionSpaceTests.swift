import XCTest
@testable import JevCore

final class FastSubtaskActionSpaceTests: XCTestCase {
    func testActionSpaceFiltersToVisibleEnabledOperationCompatibleTargets() throws {
        let subtask = try makeSubtask(inputs: ["query": "Gaussian Blur"])
        let snapshot = makeSnapshot(elements: [
            element(id: "z-click", actions: [.click], enabled: true, visible: true),
            element(id: "a-click", actions: [.click], enabled: true, visible: true),
            element(id: "hidden", actions: [.click], enabled: true, visible: false),
            element(id: "disabled", actions: [.click], enabled: false, visible: true),
            element(id: "search", actions: [.typeText], enabled: true, visible: true)
        ])

        let actionSpace = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: subtask)

        XCTAssertEqual(actionSpace.targetIDsByOperation[.click], ["a-click", "z-click"])
        XCTAssertEqual(actionSpace.targetIDsByOperation[.typeText], ["search"])
        XCTAssertFalse(actionSpace.targetIDsByOperation.values.flatMap { $0 }.contains("hidden"))
        XCTAssertFalse(actionSpace.targetIDsByOperation.values.flatMap { $0 }.contains("disabled"))
    }

    func testTypeTextRequiresTrustedInputsAndNeverIncludesTheirValues() throws {
        let emptySubtask = try makeSubtask(inputs: [:])
        let snapshot = makeSnapshot(elements: [
            element(id: "search", actions: [.typeText], enabled: true, visible: true)
        ])
        let emptySpace = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: emptySubtask)
        XCTAssertFalse(emptySpace.operations.contains(.typeText))

        let subtask = try makeSubtask(inputs: ["query": "Gaussian Blur"])
        let actionSpace = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: subtask)
        XCTAssertTrue(actionSpace.operations.contains(.typeText))
        XCTAssertEqual(actionSpace.inputKeys, ["query"])
        XCTAssertFalse(actionSpace.policyText.contains("Gaussian Blur"))
    }

    func testTerminalDecisionsAreAlwaysAvailableAndOutputIsDeterministic() throws {
        let subtask = try makeSubtask(inputs: [:])
        let snapshot = makeSnapshot(elements: [
            element(id: "button", actions: [.click], enabled: true, visible: true)
        ])

        let first = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: subtask)
        let second = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: subtask)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.operations, [.wait, .click, .subtaskComplete, .blocked, .needsAgent])
        XCTAssertTrue(first.operations.contains(.subtaskComplete))
        XCTAssertTrue(first.operations.contains(.blocked))
        XCTAssertTrue(first.operations.contains(.needsAgent))
        XCTAssertFalse(first.operations.contains(.outcomeUnknown))
    }

    private func makeSubtask(inputs: [String: String]) throws -> FastDesktopSubtask {
        try FastDesktopSubtask(
            goal: "Use the current fixture",
            verification: .reviewedFixture,
            inputs: inputs,
            constraints: [],
            maxActions: 5
        )
    }

    private func makeSnapshot(elements: [FastDesktopElement]) -> FastDesktopSnapshot {
        FastDesktopSnapshot(
            application: "TestApp",
            window: "TestWindow",
            revision: "revision-1",
            elements: elements,
            context: [:]
        )
    }

    private func element(
        id: String,
        actions: [FastDesktopActionKind],
        enabled: Bool,
        visible: Bool
    ) -> FastDesktopElement {
        FastDesktopElement(
            id: id,
            role: "control",
            name: id,
            value: nil,
            actions: actions,
            enabled: enabled,
            visible: visible,
            semanticGuard: "guard-\(id)"
        )
    }
}
