import Foundation

public enum FastDesktopActionKind: String, Codable, CaseIterable, Sendable {
    case click
    case typeText
    case wait
}

public enum FastDesktopDecisionOperation: String, Codable, CaseIterable, Sendable {
    case click
    case typeText
    case wait
    case subtaskComplete
    case blocked
    case needsAgent
    case stopped
    case outcomeUnknown

    public var isTerminal: Bool {
        switch self {
        case .subtaskComplete, .blocked, .needsAgent, .stopped, .outcomeUnknown:
            true
        case .click, .typeText, .wait:
            false
        }
    }
}

public enum FastDesktopTerminal: String, Codable, Sendable {
    case subtaskComplete
    case blocked
    case needsAgent
    case stopped
    case outcomeUnknown
}

public enum FastDesktopVerificationID: String, Codable, CaseIterable, Sendable {
    case reviewedFixture
}

public enum FastDesktopRuntimeCheckpoint: String, Codable, CaseIterable, Hashable, Sendable {
    case subtaskStarted
    case observationCaptured
    case actionSpaceBuilt
    case policyDecisionStarted
    case policyDecisionReceived
    case freshnessChecked
    case actionDispatched
    case settleCompleted
    case verificationStarted
    case verificationCompleted
    case subtaskTerminal
}

public enum FastDesktopSubtaskError: Error, Equatable, Sendable {
    case emptyGoal
    case invalidActionBudget
}

public typealias FastSubtaskModelError = FastDesktopSubtaskError

public struct FastDesktopSubtask: Equatable, Sendable {
    public let goal: String
    public let verification: FastDesktopVerificationID
    public let inputs: [String: String]
    public let constraints: [String]
    public let maxActions: Int

    public init(
        goal: String,
        verification: FastDesktopVerificationID,
        inputs: [String: String],
        constraints: [String],
        maxActions: Int
    ) throws {
        let normalizedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedGoal.isEmpty else {
            throw FastDesktopSubtaskError.emptyGoal
        }
        guard maxActions > 0 else {
            throw FastDesktopSubtaskError.invalidActionBudget
        }
        self.goal = normalizedGoal
        self.verification = verification
        self.inputs = inputs
        self.constraints = constraints
        self.maxActions = maxActions
    }
}

public struct FastDesktopElement: Equatable, Sendable {
    public let id: String
    public let role: String
    public let name: String
    public let value: String?
    public let actions: [FastDesktopActionKind]
    public let enabled: Bool
    public let visible: Bool
    public let semanticGuard: String

    public init(
        id: String,
        role: String,
        name: String,
        value: String?,
        actions: [FastDesktopActionKind],
        enabled: Bool,
        visible: Bool,
        semanticGuard: String
    ) {
        self.id = id
        self.role = role
        self.name = name
        self.value = value
        self.actions = actions
        self.enabled = enabled
        self.visible = visible
        self.semanticGuard = semanticGuard
    }
}

public struct FastDesktopSnapshot: Equatable, Sendable {
    public let application: String
    public let window: String
    public let revision: String
    public let elements: [FastDesktopElement]
    public let context: [String: String]

    public init(
        application: String,
        window: String,
        revision: String,
        elements: [FastDesktopElement],
        context: [String: String]
    ) {
        self.application = application
        self.window = window
        self.revision = revision
        self.elements = elements
        self.context = context
    }

    public func element(_ id: String) -> FastDesktopElement? {
        elements.first { $0.id == id }
    }

    public var visibleElements: [FastDesktopElement] {
        elements.filter(\.visible)
    }

    public var structuralSignature: String {
        visibleElements
            .map {
                [
                    $0.id,
                    $0.role,
                    $0.enabled ? "enabled" : "disabled",
                    $0.actions.map(\.rawValue).sorted().joined(separator: ","),
                    $0.semanticGuard
                ].joined(separator: "|")
            }
            .sorted()
            .joined(separator: "\n")
    }
}

public struct FastDesktopDecision: Equatable, Sendable {
    public let operation: FastDesktopDecisionOperation
    public let targetID: String?
    public let inputKey: String?

    public init(
        operation: FastDesktopDecisionOperation,
        targetID: String? = nil,
        inputKey: String? = nil
    ) {
        self.operation = operation
        self.targetID = targetID
        self.inputKey = inputKey
    }
}

public struct FastDesktopAction: Equatable, Sendable {
    public let kind: FastDesktopActionKind
    public let targetID: String?
    public let targetGuard: String?
    public let inputKey: String?
    public let value: String?

    public init(
        kind: FastDesktopActionKind,
        targetID: String?,
        targetGuard: String?,
        inputKey: String?,
        value: String?
    ) {
        self.kind = kind
        self.targetID = targetID
        self.targetGuard = targetGuard
        self.inputKey = inputKey
        self.value = value
    }
}

public struct FastDesktopActionRecord: Codable, Equatable, Sendable {
    public let step: Int
    public let kind: FastDesktopActionKind
    public let targetID: String?
    public let inputKey: String?
    public let beforeRevision: String
    public let afterRevision: String
    public let stateChanged: Bool

    public init(
        step: Int,
        kind: FastDesktopActionKind,
        targetID: String?,
        inputKey: String?,
        beforeRevision: String,
        afterRevision: String,
        stateChanged: Bool
    ) {
        self.step = step
        self.kind = kind
        self.targetID = targetID
        self.inputKey = inputKey
        self.beforeRevision = beforeRevision
        self.afterRevision = afterRevision
        self.stateChanged = stateChanged
    }
}

public struct FastDesktopExecutionResult: Equatable, Sendable {
    public let status: FastDesktopTerminal
    public let finalSnapshot: FastDesktopSnapshot
    public let history: [FastDesktopActionRecord]
    public let reasonCode: String?

    public init(
        status: FastDesktopTerminal,
        finalSnapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord],
        reasonCode: String?
    ) {
        self.status = status
        self.finalSnapshot = finalSnapshot
        self.history = history
        self.reasonCode = reasonCode
    }

    public var redactedEvidence: FastDesktopExecutionEvidence {
        FastDesktopExecutionEvidence(
            status: status,
            history: history,
            reasonCode: reasonCode
        )
    }
}

public struct FastDesktopExecutionEvidence: Codable, Equatable, Sendable {
    public let status: FastDesktopTerminal
    public let history: [FastDesktopActionRecord]
    public let reasonCode: String?

    public init(
        status: FastDesktopTerminal,
        history: [FastDesktopActionRecord],
        reasonCode: String?
    ) {
        self.status = status
        self.history = history
        self.reasonCode = reasonCode
    }
}
