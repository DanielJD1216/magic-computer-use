import XCTest
@testable import JevCore

final class FastSubtaskValidationTests: XCTestCase {
    func testTypeTextUsesTheTrustedInputKeyValue() throws {
        let subtask = try makeSubtask(inputs: ["query": "Gaussian Blur"])
        let snapshot = makeSnapshot(
            element: FastDesktopElement(
                id: "search",
                role: "textField",
                name: "Search",
                value: "",
                actions: [.typeText],
                enabled: true,
                visible: true,
                semanticGuard: "guard-1"
            )
        )

        let action = try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .typeText, targetID: "search", inputKey: "query"),
            snapshot: snapshot,
            subtask: subtask
        )

        XCTAssertEqual(action.kind, .typeText)
        XCTAssertEqual(action.targetID, "search")
        XCTAssertEqual(action.targetGuard, "guard-1")
        XCTAssertEqual(action.inputKey, "query")
        XCTAssertEqual(action.value, "Gaussian Blur")
    }

    func testWaitMaterializesWithoutATarget() throws {
        let subtask = try makeSubtask(inputs: [:])
        let action = try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .wait),
            snapshot: makeSnapshot(element: nil),
            subtask: subtask
        )

        XCTAssertEqual(action, FastDesktopAction(
            kind: .wait,
            targetID: nil,
            targetGuard: nil,
            inputKey: nil,
            value: nil
        ))
    }

    func testValidatorRejectsUnknownOrUnavailableTargets() throws {
        let subtask = try makeSubtask(inputs: [:])
        let unknown = FastDesktopDecision(operation: .click, targetID: "missing")
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            unknown,
            snapshot: makeSnapshot(element: nil),
            subtask: subtask
        )) { error in
            XCTAssertEqual(error as? FastDesktopActionValidationError, .unknownTarget("missing"))
        }

        let hidden = element(id: "hidden", actions: [.click], enabled: true, visible: false)
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .click, targetID: "hidden"),
            snapshot: makeSnapshot(element: hidden),
            subtask: subtask
        )) { error in
            XCTAssertEqual(error as? FastDesktopActionValidationError, .targetNotVisible("hidden"))
        }

        let disabled = element(id: "disabled", actions: [.click], enabled: false, visible: true)
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .click, targetID: "disabled"),
            snapshot: makeSnapshot(element: disabled),
            subtask: subtask
        )) { error in
            XCTAssertEqual(error as? FastDesktopActionValidationError, .targetDisabled("disabled"))
        }
    }

    func testValidatorRejectsUnsupportedOperationsAndUntrustedInputs() throws {
        let subtask = try makeSubtask(inputs: ["query": "Gaussian Blur"])
        let clickOnly = element(id: "button", actions: [.click], enabled: true, visible: true)
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .typeText, targetID: "button", inputKey: "query"),
            snapshot: makeSnapshot(element: clickOnly),
            subtask: subtask
        )) { error in
            XCTAssertEqual(
                error as? FastDesktopActionValidationError,
                .unsupportedOperation(.typeText, targetID: "button")
            )
        }

        let textField = element(id: "search", actions: [.typeText], enabled: true, visible: true)
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .typeText, targetID: "search"),
            snapshot: makeSnapshot(element: textField),
            subtask: subtask
        )) { error in
            XCTAssertEqual(error as? FastDesktopActionValidationError, .missingInputKey)
        }
        XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
            FastDesktopDecision(operation: .typeText, targetID: "search", inputKey: "invented"),
            snapshot: makeSnapshot(element: textField),
            subtask: subtask
        )) { error in
            XCTAssertEqual(error as? FastDesktopActionValidationError, .unknownInputKey("invented"))
        }
    }

    func testValidatorRejectsTerminalDecisions() throws {
        let subtask = try makeSubtask(inputs: [:])
        for operation in FastDesktopDecisionOperation.allCases where operation.isTerminal {
            XCTAssertThrowsError(try FastDesktopActionValidator.materialize(
                FastDesktopDecision(operation: operation),
                snapshot: makeSnapshot(element: nil),
                subtask: subtask
            )) { error in
                XCTAssertEqual(
                    error as? FastDesktopActionValidationError,
                    .terminalOperation(operation)
                )
            }
        }
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

    private func makeSnapshot(element: FastDesktopElement?) -> FastDesktopSnapshot {
        FastDesktopSnapshot(
            application: "TestApp",
            window: "TestWindow",
            revision: "revision-1",
            elements: element.map { [$0] } ?? [],
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
