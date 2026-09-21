import Foundation

public enum ComputerUseAction: Equatable, Sendable {
    case pressReviewedFixture
    case pressLandingFixture
}

public enum ComputerUsePolicyError: Error, Equatable, Sendable {
    case unsupportedCapability
    case unsupportedTarget
}

public enum ComputerUsePolicy {
    private static let fixtureVersion = "safari-fixture-v1"

    public static func action(
        for candidate: CapabilityCandidate
    ) throws -> ComputerUseAction {
        let action: ComputerUseAction
        switch candidate.id {
        case .selectReviewedFixtureView:
            action = .pressReviewedFixture
        case .returnToLandingFixtureView:
            action = .pressLandingFixture
        default:
            throw ComputerUsePolicyError.unsupportedCapability
        }
        guard candidate.target.fixtureVersion == fixtureVersion else {
            throw ComputerUsePolicyError.unsupportedTarget
        }
        return action
    }
}
