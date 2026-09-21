import Foundation

public enum FastSubtaskCapabilityRouteError: Error, Equatable, Sendable {
    case unsupportedCapability
    case invalidCapabilityPayload
}

public enum FastSubtaskCapabilityRoute {
    public static func subtask(
        for candidate: CapabilityCandidate
    ) throws -> FastDesktopSubtask {
        guard candidate.id == .selectReviewedFixtureView else {
            throw FastSubtaskCapabilityRouteError.unsupportedCapability
        }
        guard candidate.transcriptRequirement == .final,
              candidate.payloadProvenance == .declaredFixture,
              candidate.confirmationRequirement == .none,
              candidate.policyVersion == "safari-fixture-v1" else {
            throw FastSubtaskCapabilityRouteError.invalidCapabilityPayload
        }

        return try FastDesktopSubtask(
            goal: candidate.description,
            verification: .reviewedFixture,
            inputs: [:],
            constraints: [
                "Use only the capability-bound local Safari fixture",
                "Dispatch at most one reviewed-fixture click"
            ],
            maxActions: 2
        )
    }
}

public struct FastSubtaskCapabilityPolicy: FastDesktopDecisionPolicy, Sendable {
    private let capability: CapabilityID

    public init(capability: CapabilityID) {
        self.capability = capability
    }

    public func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision {
        guard capability == .selectReviewedFixtureView else {
            return FastDesktopDecision(operation: .needsAgent)
        }

        if snapshot.context["fixture_view"] == "reviewed" {
            return FastDesktopDecision(operation: .subtaskComplete)
        }
        guard snapshot.context["fixture_view"] == "landing" else {
            return FastDesktopDecision(operation: .needsAgent)
        }

        let actionSpace = FastDesktopActionSpaceBuilder.build(
            snapshot: snapshot,
            subtask: subtask
        )
        guard actionSpace.operations.contains(.click),
              let targetID = actionSpace.targetIDsByOperation[.click]?
                .first(where: { $0 == "reviewed-fixture-view" }) else {
            return FastDesktopDecision(operation: .needsAgent)
        }
        return FastDesktopDecision(operation: .click, targetID: targetID)
    }
}
