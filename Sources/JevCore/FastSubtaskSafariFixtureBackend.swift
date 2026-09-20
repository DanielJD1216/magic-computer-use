import Foundation

public enum FastSubtaskSafariFixtureBackendError: Error, Equatable, Sendable {
    case targetBindingMismatch
    case staleTarget
    case unsupportedAction
    case capabilityUnavailable
}

public actor FastSubtaskSafariFixtureState {
    public let target: TargetBinding
    private var fixture: FakeSafariFixture

    public init(target: TargetBinding) {
        self.target = target
        self.fixture = FakeSafariFixture(target: target)
    }

    public func observe() -> FixtureObservation {
        fixture.observe()
    }

    public func execute(_ candidate: CapabilityCandidate) throws -> FixtureObservation {
        try fixture.execute(candidate)
    }

    public func dispatchCount() -> Int {
        fixture.dispatchCount
    }
}

public actor FastSubtaskSafariFixtureBackend: FastDesktopBackend {
    public let state: FastSubtaskSafariFixtureState
    public let target: TargetBinding

    public init(target: TargetBinding) {
        self.state = FastSubtaskSafariFixtureState(target: target)
        self.target = target
    }

    public init(state: FastSubtaskSafariFixtureState, target: TargetBinding) {
        self.state = state
        self.target = target
    }

    public func observe() async throws -> FastDesktopSnapshot {
        let observation = await state.observe()
        return Self.snapshot(observation: observation, target: target)
    }

    public func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool {
        guard state.target == target else {
            return false
        }
        guard Self.matchesBinding(snapshot: snapshot, target: target) else {
            return false
        }

        let currentObservation = await state.observe()
        let currentSnapshot = Self.snapshot(observation: currentObservation, target: target)
        guard snapshot.revision == currentSnapshot.revision else {
            return false
        }

        switch action.kind {
        case .wait:
            return action.targetID == nil
                && action.targetGuard == nil
                && action.inputKey == nil
                && action.value == nil
        case .click:
            guard action.inputKey == nil, action.value == nil,
                  action.targetID == "reviewed-fixture-view",
                  let element = currentSnapshot.element("reviewed-fixture-view") else {
                return false
            }
            return element.actions.contains(.click)
                && element.visible
                && element.enabled
                && action.targetGuard == element.semanticGuard
        case .typeText:
            return false
        }
    }

    public func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws {
        guard state.target == target,
              Self.matchesBinding(snapshot: snapshot, target: target) else {
            throw FastSubtaskSafariFixtureBackendError.targetBindingMismatch
        }
        guard try await isFresh(snapshot: snapshot, action: action) else {
            throw FastSubtaskSafariFixtureBackendError.staleTarget
        }
        guard action.kind == .click,
              action.targetID == "reviewed-fixture-view",
              action.inputKey == nil,
              action.value == nil else {
            throw FastSubtaskSafariFixtureBackendError.unsupportedAction
        }

        guard let candidate = CapabilityRegistry
            .firstSliceCandidates(target: target)
            .first(where: { $0.id == .selectReviewedFixtureView }) else {
            throw FastSubtaskSafariFixtureBackendError.capabilityUnavailable
        }
        do {
            _ = try ComputerUsePolicy.action(for: candidate)
            _ = try await state.execute(candidate)
        } catch let error as FixtureExecutionError {
            switch error {
            case .targetMismatch:
                throw FastSubtaskSafariFixtureBackendError.targetBindingMismatch
            case .unsupportedCapability:
                throw FastSubtaskSafariFixtureBackendError.capabilityUnavailable
            }
        } catch {
            throw FastSubtaskSafariFixtureBackendError.capabilityUnavailable
        }
    }

    fileprivate static func matchesBinding(
        snapshot: FastDesktopSnapshot,
        target: TargetBinding
    ) -> Bool {
        snapshot.application == "Safari"
            && snapshot.window == target.windowID
            && snapshot.context["fixture_version"] == target.fixtureVersion
            && snapshot.context["target_identity_class"] == "preflighted-safari-fixture"
    }

    fileprivate static func snapshot(
        observation: FixtureObservation,
        target: TargetBinding
    ) -> FastDesktopSnapshot {
        let viewName: String
        let elements: [FastDesktopElement]
        switch observation.view {
        case .landing:
            viewName = "landing"
            elements = [FastDesktopElement(
                id: "reviewed-fixture-view",
                role: "button",
                name: "Select reviewed fixture view",
                value: nil,
                actions: [.click],
                enabled: true,
                visible: true,
                semanticGuard: semanticGuard(
                    observation: observation,
                    target: target
                )
            )]
        case .reviewed:
            viewName = "reviewed"
            elements = []
        }

        return FastDesktopSnapshot(
            application: "Safari",
            window: target.windowID,
            revision: "fixture-\(observation.revision)",
            elements: elements,
            context: [
                "fixture_view": viewName,
                "fixture_version": target.fixtureVersion,
                "target_identity_class": "preflighted-safari-fixture"
            ]
        )
    }

    private static func semanticGuard(
        observation: FixtureObservation,
        target: TargetBinding
    ) -> String {
        let viewName = observation.view == .landing ? "landing" : "reviewed"
        return [
            target.processID.description,
            target.windowID,
            target.fixtureVersion,
            viewName,
            observation.revision.description
        ].joined(separator: ":")
    }
}

public struct FastSubtaskSafariFixtureVerifier: FastDesktopVerifier, Sendable {
    private let state: FastSubtaskSafariFixtureState
    private let target: TargetBinding

    public init(state: FastSubtaskSafariFixtureState, target: TargetBinding) {
        self.state = state
        self.target = target
    }

    public func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult {
        guard verification == .reviewedFixture else {
            return .unavailable
        }
        guard FastSubtaskSafariFixtureBackend.matchesBinding(
            snapshot: snapshot,
            target: target
        ) else {
            return .notSatisfied
        }

        let observation = await state.observe()
        guard observation.target == target,
              observation.view == .reviewed,
              snapshot.context["fixture_view"] == "reviewed",
              snapshot.revision == "fixture-\(observation.revision)",
              snapshot.visibleElements.isEmpty else {
            return .notSatisfied
        }
        return .satisfied
    }
}
