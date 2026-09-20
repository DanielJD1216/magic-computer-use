import Foundation

public struct FastDesktopActionSpace: Equatable, Sendable {
    public let operations: [FastDesktopDecisionOperation]
    public let targetIDsByOperation: [FastDesktopDecisionOperation: [String]]
    public let inputKeys: [String]
    public let policyText: String

    public init(
        operations: [FastDesktopDecisionOperation],
        targetIDsByOperation: [FastDesktopDecisionOperation: [String]],
        inputKeys: [String],
        policyText: String
    ) {
        self.operations = operations
        self.targetIDsByOperation = targetIDsByOperation
        self.inputKeys = inputKeys
        self.policyText = policyText
    }
}

public enum FastDesktopActionSpaceBuilder {
    public static func build(
        snapshot: FastDesktopSnapshot,
        subtask: FastDesktopSubtask
    ) -> FastDesktopActionSpace {
        let usable = snapshot.visibleElements.filter { $0.enabled }
        let clickTargets = usable
            .filter { $0.actions.contains(.click) }
            .map(\.id)
            .sorted()
        let typeTargets = usable
            .filter { $0.actions.contains(.typeText) }
            .map(\.id)
            .sorted()

        var operations: [FastDesktopDecisionOperation] = [.wait]
        var targets: [FastDesktopDecisionOperation: [String]] = [:]

        if !clickTargets.isEmpty {
            operations.append(.click)
            targets[.click] = clickTargets
        }
        if !typeTargets.isEmpty && !subtask.inputs.isEmpty {
            operations.append(.typeText)
            targets[.typeText] = typeTargets
        }

        operations.append(contentsOf: [.subtaskComplete, .blocked, .needsAgent])

        let inputKeys = subtask.inputs.keys.sorted()
        let policyText = operations.map(\.rawValue).joined(separator: ",")
        return FastDesktopActionSpace(
            operations: operations,
            targetIDsByOperation: targets,
            inputKeys: inputKeys,
            policyText: policyText
        )
    }
}
