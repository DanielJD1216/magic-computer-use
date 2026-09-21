import Foundation
import JevCore

private enum MacSafariFastSubtaskBackendError: Error, Equatable, Sendable {
    case targetUnavailable
    case targetBindingMismatch
    case staleTarget
    case unsupportedAction
}

private actor MacSafariFastSubtaskBackend: FastDesktopBackend {
    private let adapter: SafariFixtureAdapter
    private let target: TargetBinding

    init(adapter: SafariFixtureAdapter, target: TargetBinding) {
        self.adapter = adapter
        self.target = target
    }

    func observe() async throws -> FastDesktopSnapshot {
        guard let observation = await MainActor.run(body: { adapter.observe() }) else {
            throw MacSafariFastSubtaskBackendError.targetUnavailable
        }
        guard observation.binding == target else {
            throw MacSafariFastSubtaskBackendError.targetBindingMismatch
        }
        return Self.snapshot(observation: observation, target: target)
    }

    func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool {
        guard Self.matchesBinding(snapshot: snapshot, target: target) else {
            return false
        }
        let current = try await observe()
        guard current.revision == snapshot.revision else {
            return false
        }

        switch action.kind {
        case .wait:
            return action.targetID == nil
                && action.targetGuard == nil
                && action.inputKey == nil
                && action.value == nil
        case .click:
            guard action.targetID == "reviewed-fixture-view",
                  action.inputKey == nil,
                  action.value == nil,
                  let element = current.element("reviewed-fixture-view") else {
                return false
            }
            return element.visible
                && element.enabled
                && element.actions.contains(.click)
                && action.targetGuard == element.semanticGuard
        case .typeText:
            return false
        }
    }

    func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws {
        guard try await isFresh(snapshot: snapshot, action: action) else {
            throw MacSafariFastSubtaskBackendError.staleTarget
        }
        switch action.kind {
        case .wait:
            return
        case .typeText:
            throw MacSafariFastSubtaskBackendError.unsupportedAction
        case .click:
            guard action.targetID == "reviewed-fixture-view" else {
                throw MacSafariFastSubtaskBackendError.unsupportedAction
            }
            try Task.checkCancellation()
            _ = try await adapter.selectReviewed(expectedTarget: target)
        }
    }

    private static func matchesBinding(
        snapshot: FastDesktopSnapshot,
        target: TargetBinding
    ) -> Bool {
        snapshot.application == "Safari"
            && snapshot.window == target.windowID
            && snapshot.context["fixture_version"] == target.fixtureVersion
            && snapshot.context["target_identity_class"] == "preflighted-safari-fixture"
    }

    private static func snapshot(
        observation: SafariFixtureRuntimeObservation,
        target: TargetBinding
    ) -> FastDesktopSnapshot {
        let viewName = observation.view == .landing ? "landing" : "reviewed"
        let elements: [FastDesktopElement]
        if observation.view == .landing {
            elements = [FastDesktopElement(
                id: "reviewed-fixture-view",
                role: "button",
                name: "Select reviewed fixture view",
                value: nil,
                actions: [.click],
                enabled: true,
                visible: true,
                semanticGuard: [
                    target.processID.description,
                    target.windowID,
                    target.fixtureVersion,
                    viewName
                ].joined(separator: ":")
            )]
        } else {
            elements = []
        }
        return FastDesktopSnapshot(
            application: "Safari",
            window: target.windowID,
            revision: "fixture-\(viewName)-\(target.windowID)",
            elements: elements,
            context: [
                "fixture_view": viewName,
                "fixture_version": target.fixtureVersion,
                "target_identity_class": "preflighted-safari-fixture"
            ]
        )
    }
}

private struct MacSafariFastSubtaskVerifier: FastDesktopVerifier {
    let backend: MacSafariFastSubtaskBackend
    let target: TargetBinding

    func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult {
        guard verification == .reviewedFixture,
              snapshot.application == "Safari",
              snapshot.window == target.windowID,
              snapshot.context["fixture_version"] == target.fixtureVersion,
              snapshot.context["target_identity_class"] == "preflighted-safari-fixture",
              snapshot.context["fixture_view"] == "reviewed" else {
            return .notSatisfied
        }
        guard let current = try? await backend.observe() else {
            return .unavailable
        }
        return current.context["fixture_view"] == "reviewed"
            && current.visibleElements.isEmpty
            ? .satisfied
            : .notSatisfied
    }
}

@MainActor
final class SafariFixtureFastSubtaskRunner {
    private let adapter: SafariFixtureAdapter

    init(adapter: SafariFixtureAdapter) {
        self.adapter = adapter
    }

    func execute(
        candidate: CapabilityCandidate
    ) async throws -> FastDesktopExecutionResult {
        let subtask = try FastSubtaskCapabilityRoute.subtask(for: candidate)
        let backend = MacSafariFastSubtaskBackend(
            adapter: adapter,
            target: candidate.target
        )
        let executor = FastSubtaskExecutor(
            backend: backend,
            policy: FastSubtaskCapabilityPolicy(capability: candidate.id),
            verifier: MacSafariFastSubtaskVerifier(
                backend: backend,
                target: candidate.target
            ),
            configuration: FastDesktopRuntimeConfiguration(
                stableObservationCount: 1,
                maxSettleObservations: 1
            )
        )
        return await executor.execute(subtask: subtask)
    }
}
