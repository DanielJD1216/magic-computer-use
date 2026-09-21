import Foundation

public enum FixtureView: Equatable, Sendable {
    case landing
    case reviewed
}

public struct FixtureObservation: Equatable, Sendable {
    public let target: TargetBinding
    public let view: FixtureView
    public let revision: Int

    public init(target: TargetBinding, view: FixtureView, revision: Int) {
        self.target = target
        self.view = view
        self.revision = revision
    }
}

public enum FixtureExecutionError: Error, Equatable, Sendable {
    case targetMismatch
    case unsupportedCapability
}

public struct FakeSafariFixture: Sendable {
    public let target: TargetBinding
    public private(set) var currentView: FixtureView
    public private(set) var revision: Int
    public private(set) var dispatchCount: Int

    public init(target: TargetBinding) {
        self.target = target
        self.currentView = .landing
        self.revision = 0
        self.dispatchCount = 0
    }

    public mutating func execute(_ candidate: CapabilityCandidate) throws -> FixtureObservation {
        guard candidate.target == target else {
            throw FixtureExecutionError.targetMismatch
        }

        switch candidate.id {
        case .activatePreflightedSafariFixture:
            dispatchCount += 1
        case .selectReviewedFixtureView:
            dispatchCount += 1
            currentView = .reviewed
        case .returnToLandingFixtureView:
            dispatchCount += 1
            currentView = .landing
        case .waitForReviewedFixtureState:
            break
        case .stop, .askUser:
            throw FixtureExecutionError.unsupportedCapability
        }

        revision += 1
        return observe()
    }

    public func observe() -> FixtureObservation {
        FixtureObservation(
            target: target,
            view: currentView,
            revision: revision
        )
    }

    public func verify(expected: FixtureView, observed: FixtureObservation) -> Bool {
        observed.target == target
            && observed.view == expected
            && observed.revision == revision
    }
}
