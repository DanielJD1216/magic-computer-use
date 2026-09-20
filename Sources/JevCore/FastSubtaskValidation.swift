import Foundation

public enum FastDesktopActionValidationError: Error, Equatable, Sendable {
    case terminalOperation(FastDesktopDecisionOperation)
    case missingTarget
    case unknownTarget(String)
    case targetNotVisible(String)
    case targetDisabled(String)
    case unsupportedOperation(FastDesktopDecisionOperation, targetID: String)
    case missingInputKey
    case unknownInputKey(String)
}

public enum FastDesktopActionValidator {
    public static func materialize(
        _ decision: FastDesktopDecision,
        snapshot: FastDesktopSnapshot,
        subtask: FastDesktopSubtask
    ) throws -> FastDesktopAction {
        guard !decision.operation.isTerminal else {
            throw FastDesktopActionValidationError.terminalOperation(decision.operation)
        }

        switch decision.operation {
        case .wait:
            return FastDesktopAction(
                kind: .wait,
                targetID: nil,
                targetGuard: nil,
                inputKey: nil,
                value: nil
            )
        case .click, .typeText:
            guard let targetID = decision.targetID, !targetID.isEmpty else {
                throw FastDesktopActionValidationError.missingTarget
            }
            guard let target = snapshot.element(targetID) else {
                throw FastDesktopActionValidationError.unknownTarget(targetID)
            }
            guard target.visible else {
                throw FastDesktopActionValidationError.targetNotVisible(targetID)
            }
            guard target.enabled else {
                throw FastDesktopActionValidationError.targetDisabled(targetID)
            }

            let actionKind: FastDesktopActionKind
            switch decision.operation {
            case .click:
                actionKind = .click
            case .typeText:
                actionKind = .typeText
            case .wait, .subtaskComplete, .blocked, .needsAgent, .stopped, .outcomeUnknown:
                throw FastDesktopActionValidationError.terminalOperation(decision.operation)
            }

            guard target.actions.contains(actionKind) else {
                throw FastDesktopActionValidationError.unsupportedOperation(
                    decision.operation,
                    targetID: targetID
                )
            }

            var inputKey: String?
            var value: String?
            if decision.operation == .typeText {
                guard let requestedInputKey = decision.inputKey,
                      !requestedInputKey.isEmpty else {
                    throw FastDesktopActionValidationError.missingInputKey
                }
                guard let trustedValue = subtask.inputs[requestedInputKey] else {
                    throw FastDesktopActionValidationError.unknownInputKey(requestedInputKey)
                }
                inputKey = requestedInputKey
                value = trustedValue
            }

            return FastDesktopAction(
                kind: actionKind,
                targetID: targetID,
                targetGuard: target.semanticGuard,
                inputKey: inputKey,
                value: value
            )
        case .subtaskComplete, .blocked, .needsAgent, .stopped, .outcomeUnknown:
            throw FastDesktopActionValidationError.terminalOperation(decision.operation)
        }
    }
}
