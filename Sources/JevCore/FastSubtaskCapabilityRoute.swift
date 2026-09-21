import Foundation

public enum FastSubtaskCapabilityRouteError: Error, Equatable, Sendable {
    case unsupportedCapability
    case invalidCapabilityPayload
}

public enum FastSubtaskCapabilityRoute {
    public static func subtask(
        for candidate: CapabilityCandidate
    ) throws -> FastDesktopSubtask {
        let verification: FastDesktopVerificationID
        let constraint: String
        switch candidate.id {
        case .selectReviewedFixtureView:
            verification = .reviewedFixture
            constraint = "Dispatch at most one reviewed-fixture click"
        case .returnToLandingFixtureView:
            verification = .landingFixture
            constraint = "Dispatch at most one landing-fixture click"
        default:
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
            verification: verification,
            inputs: [:],
            constraints: [
                "Use only the capability-bound local Safari fixture",
                constraint
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
        let expectedView: String
        let expectedTargetID: String
        switch capability {
        case .selectReviewedFixtureView:
            expectedView = "reviewed"
            expectedTargetID = "reviewed-fixture-view"
        case .returnToLandingFixtureView:
            expectedView = "landing"
            expectedTargetID = "landing-fixture-view"
        default:
            return FastDesktopDecision(operation: .needsAgent)
        }

        if snapshot.context["fixture_view"] == expectedView {
            return FastDesktopDecision(operation: .subtaskComplete)
        }
        guard snapshot.context["fixture_view"] != nil else {
            return FastDesktopDecision(operation: .needsAgent)
        }

        let actionSpace = FastDesktopActionSpaceBuilder.build(
            snapshot: snapshot,
            subtask: subtask
        )
        guard actionSpace.operations.contains(.click),
              let selectedTargetID = actionSpace.targetIDsByOperation[.click]?
                .first(where: { $0 == expectedTargetID }) else {
            return FastDesktopDecision(operation: .needsAgent)
        }
        return FastDesktopDecision(operation: .click, targetID: selectedTargetID)
    }
}
