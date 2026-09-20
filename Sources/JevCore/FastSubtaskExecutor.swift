import Foundation

public struct FastDesktopRuntimeConfiguration: Equatable, Sendable {
    public var staleRetryLimit: Int
    public var noChangeLimit: Int
    public var stableObservationCount: Int
    public var maxSettleObservations: Int
    public var pollNanoseconds: UInt64

    public init(
        staleRetryLimit: Int = 3,
        noChangeLimit: Int = 3,
        stableObservationCount: Int = 2,
        maxSettleObservations: Int = 5,
        pollNanoseconds: UInt64 = 0
    ) {
        self.staleRetryLimit = max(0, staleRetryLimit)
        self.noChangeLimit = max(1, noChangeLimit)
        self.stableObservationCount = max(1, stableObservationCount)
        self.maxSettleObservations = max(1, maxSettleObservations)
        self.pollNanoseconds = pollNanoseconds
    }
}

public struct FastSubtaskExecutor: Sendable {
    private let backend: any FastDesktopBackend
    private let policy: any FastDesktopDecisionPolicy
    private let verifier: any FastDesktopVerifier
    private let configuration: FastDesktopRuntimeConfiguration
    private let cancellation: @Sendable () -> Bool

    public init(
        backend: any FastDesktopBackend,
        policy: any FastDesktopDecisionPolicy,
        verifier: any FastDesktopVerifier,
        configuration: FastDesktopRuntimeConfiguration = FastDesktopRuntimeConfiguration(),
        cancellation: @escaping @Sendable () -> Bool = { Task.isCancelled }
    ) {
        self.backend = backend
        self.policy = policy
        self.verifier = verifier
        self.configuration = configuration
        self.cancellation = cancellation
    }

    public func execute(subtask: FastDesktopSubtask) async -> FastDesktopExecutionResult {
        var snapshot = FastDesktopSnapshot.empty
        var history: [FastDesktopActionRecord] = []
        var staleRetries = 0
        var noChangeCount = 0

        if cancellation() {
            return result(
                status: .stopped,
                snapshot: snapshot,
                history: history,
                reasonCode: "session_stopped"
            )
        }

        do {
            snapshot = try await backend.observe()
        } catch {
            return result(
                status: .needsAgent,
                snapshot: snapshot,
                history: history,
                reasonCode: "initial_observation_failed"
            )
        }

        while history.count < subtask.maxActions {
            if cancellation() {
                return result(
                    status: .stopped,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "session_stopped"
                )
            }

            _ = FastDesktopActionSpaceBuilder.build(snapshot: snapshot, subtask: subtask)

            let decision: FastDesktopDecision
            do {
                decision = try await policy.decide(
                    subtask: subtask,
                    snapshot: snapshot,
                    history: history
                )
            } catch {
                return result(
                    status: .needsAgent,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "policy_failed"
                )
            }

            switch decision.operation {
            case .subtaskComplete:
                let verification = await verifier.verify(
                    verification: subtask.verification,
                    snapshot: snapshot
                )
                switch verification {
                case .satisfied:
                    return result(
                        status: .subtaskComplete,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: nil
                    )
                case .notSatisfied:
                    return result(
                        status: .needsAgent,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: "verification_failed"
                    )
                case .unavailable:
                    return result(
                        status: .needsAgent,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: "verification_unavailable"
                    )
                }
            case .blocked:
                return result(
                    status: .blocked,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "policy_blocked"
                )
            case .needsAgent:
                return result(
                    status: .needsAgent,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "policy_requested_agent"
                )
            case .stopped:
                return result(
                    status: .stopped,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "session_stopped"
                )
            case .outcomeUnknown:
                return result(
                    status: .outcomeUnknown,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "outcome_unknown"
                )
            case .click, .typeText, .wait:
                break
            }

            let action: FastDesktopAction
            do {
                action = try FastDesktopActionValidator.materialize(
                    decision,
                    snapshot: snapshot,
                    subtask: subtask
                )
            } catch {
                return result(
                    status: .needsAgent,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "invalid_action"
                )
            }

            let isFresh: Bool
            do {
                isFresh = try await backend.isFresh(snapshot: snapshot, action: action)
            } catch {
                return result(
                    status: .needsAgent,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "freshness_check_failed"
                )
            }

            guard isFresh else {
                staleRetries += 1
                if staleRetries > configuration.staleRetryLimit {
                    return result(
                        status: .needsAgent,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: "stale_target"
                    )
                }
                do {
                    snapshot = try await backend.observe()
                } catch {
                    return result(
                        status: .needsAgent,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: "stale_refresh_failed"
                    )
                }
                continue
            }

            if cancellation() {
                return result(
                    status: .stopped,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "session_stopped"
                )
            }

            do {
                try await backend.execute(action: action, against: snapshot)
            } catch {
                return result(
                    status: .outcomeUnknown,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "outcome_unknown"
                )
            }
            staleRetries = 0

            if cancellation() {
                return result(
                    status: .outcomeUnknown,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "outcome_unknown"
                )
            }

            let settledSnapshot: FastDesktopSnapshot
            do {
                settledSnapshot = try await settle()
            } catch {
                return result(
                    status: .outcomeUnknown,
                    snapshot: snapshot,
                    history: history,
                    reasonCode: "outcome_unknown"
                )
            }

            let stateChanged = snapshot.structuralSignature != settledSnapshot.structuralSignature
            history.append(FastDesktopActionRecord(
                step: history.count + 1,
                kind: action.kind,
                targetID: action.targetID,
                inputKey: action.inputKey,
                beforeRevision: snapshot.revision,
                afterRevision: settledSnapshot.revision,
                stateChanged: stateChanged
            ))
            snapshot = settledSnapshot

            if stateChanged {
                noChangeCount = 0
            } else {
                noChangeCount += 1
                if noChangeCount >= configuration.noChangeLimit {
                    return result(
                        status: .blocked,
                        snapshot: snapshot,
                        history: history,
                        reasonCode: "no_observable_change"
                    )
                }
            }
        }

        return result(
            status: .needsAgent,
            snapshot: snapshot,
            history: history,
            reasonCode: "action_budget_exhausted"
        )
    }

    private func settle() async throws -> FastDesktopSnapshot {
        var snapshot = try await backend.observe()
        guard configuration.stableObservationCount > 1 else {
            return snapshot
        }

        var stableCount = 1
        var previousSignature = snapshot.structuralSignature
        let observationLimit = max(
            configuration.stableObservationCount,
            configuration.maxSettleObservations
        )

        guard observationLimit > 1 else {
            return snapshot
        }

        for _ in 1..<observationLimit {
            if configuration.pollNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: configuration.pollNanoseconds)
            }
            let nextSnapshot = try await backend.observe()
            if nextSnapshot.structuralSignature == previousSignature {
                stableCount += 1
            } else {
                stableCount = 1
            }
            snapshot = nextSnapshot
            previousSignature = nextSnapshot.structuralSignature
            if stableCount >= configuration.stableObservationCount {
                break
            }
        }
        return snapshot
    }

    private func result(
        status: FastDesktopTerminal,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord],
        reasonCode: String?
    ) -> FastDesktopExecutionResult {
        FastDesktopExecutionResult(
            status: status,
            finalSnapshot: snapshot,
            history: history,
            reasonCode: reasonCode
        )
    }
}

private extension FastDesktopSnapshot {
    static let empty = FastDesktopSnapshot(
        application: "unknown",
        window: "unknown",
        revision: "unknown",
        elements: [],
        context: [:]
    )
}
