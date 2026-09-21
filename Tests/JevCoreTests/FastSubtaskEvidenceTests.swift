import Foundation
import XCTest
@testable import JevCore

final class FastSubtaskEvidenceTests: XCTestCase {
    func testRedactedEvidenceExcludesSnapshotValuesAndKeepsSafeMetadata() throws {
        let canary = "SECRET_CANARY_DO_NOT_EXPORT"
        let snapshot = FastDesktopSnapshot(
            application: "Safari",
            window: "fixture-window",
            revision: "fixture-1",
            elements: [FastDesktopElement(
                id: "reviewed-button",
                role: "button",
                name: "Reviewed fixture",
                value: canary,
                actions: [.click],
                enabled: true,
                visible: true,
                semanticGuard: "guard-1"
            )],
            context: ["fixture_view": "landing", "private_value": canary]
        )
        let record = FastDesktopActionRecord(
            step: 1,
            kind: .typeText,
            targetID: "search-field",
            inputKey: "query",
            beforeRevision: "fixture-1",
            afterRevision: "fixture-2",
            stateChanged: true
        )
        let result = FastDesktopExecutionResult(
            status: .needsAgent,
            finalSnapshot: snapshot,
            history: [record],
            reasonCode: "verification_failed"
        )

        let encoded = try JSONEncoder().encode(result.redactedEvidence)
        let json = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        XCTAssertFalse(json.contains(canary))
        XCTAssertTrue(json.contains("search-field"))
        XCTAssertTrue(json.contains("query"))
        XCTAssertTrue(json.contains("verification_failed"))
        XCTAssertEqual(result.redactedEvidence.history, [record])
    }

    func testExecutorEmitsRedactedLifecycleCheckpoints() async throws {
        let initial = evidenceSnapshot(revision: "landing", semanticGuard: "landing-guard")
        let reviewed = evidenceSnapshot(
            revision: "reviewed",
            semanticGuard: "reviewed-guard",
            context: ["fixture_view": "reviewed"]
        )
        let backend = EvidenceBackend(observations: [initial, reviewed])
        let policy = EvidencePolicy(decisions: [
            FastDesktopDecision(operation: .click, targetID: "reviewed-button"),
            FastDesktopDecision(operation: .subtaskComplete)
        ])
        let recorder = EvidenceCheckpointRecorder()
        let executor = FastSubtaskExecutor(
            backend: backend,
            policy: policy,
            verifier: EvidenceVerifier(),
            configuration: FastDesktopRuntimeConfiguration(
                stableObservationCount: 1,
                maxSettleObservations: 1
            ),
            checkpoint: { checkpoint in
                recorder.append(checkpoint)
            }
        )
        let subtask = try FastDesktopSubtask(
            goal: "Select the reviewed fixture view",
            verification: .reviewedFixture,
            inputs: [:],
            constraints: [],
            maxActions: 3
        )

        let result = await executor.execute(subtask: subtask)
        let checkpoints = recorder.values()

        XCTAssertEqual(result.status, .subtaskComplete)
        for checkpoint in [
            FastDesktopRuntimeCheckpoint.subtaskStarted,
            .observationCaptured,
            .actionSpaceBuilt,
            .policyDecisionStarted,
            .policyDecisionReceived,
            .freshnessChecked,
            .actionDispatched,
            .settleCompleted,
            .verificationStarted,
            .verificationCompleted,
            .subtaskTerminal
        ] {
            XCTAssertTrue(checkpoints.contains(checkpoint), "Missing checkpoint \(checkpoint.rawValue)")
        }
    }

    private func evidenceSnapshot(
        revision: String,
        semanticGuard: String,
        context: [String: String] = ["fixture_view": "landing"]
    ) -> FastDesktopSnapshot {
        FastDesktopSnapshot(
            application: "Safari",
            window: "fixture-window",
            revision: revision,
            elements: [FastDesktopElement(
                id: "reviewed-button",
                role: "button",
                name: "Reviewed fixture",
                value: nil,
                actions: [.click],
                enabled: true,
                visible: true,
                semanticGuard: semanticGuard
            )],
            context: context
        )
    }
}

private final class EvidenceCheckpointRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [FastDesktopRuntimeCheckpoint] = []

    func append(_ checkpoint: FastDesktopRuntimeCheckpoint) {
        lock.lock()
        recorded.append(checkpoint)
        lock.unlock()
    }

    func values() -> [FastDesktopRuntimeCheckpoint] {
        lock.lock()
        defer { lock.unlock() }
        return recorded
    }
}

private actor EvidencePolicy: FastDesktopDecisionPolicy {
    private var decisions: [FastDesktopDecision]

    init(decisions: [FastDesktopDecision]) {
        self.decisions = decisions
    }

    func decide(
        subtask: FastDesktopSubtask,
        snapshot: FastDesktopSnapshot,
        history: [FastDesktopActionRecord]
    ) async throws -> FastDesktopDecision {
        decisions.isEmpty
            ? FastDesktopDecision(operation: .needsAgent)
            : decisions.removeFirst()
    }
}

private actor EvidenceBackend: FastDesktopBackend {
    private var observations: [FastDesktopSnapshot]

    init(observations: [FastDesktopSnapshot]) {
        self.observations = observations
    }

    func observe() async throws -> FastDesktopSnapshot {
        if observations.count > 1 {
            return observations.removeFirst()
        }
        guard let snapshot = observations.first else {
            throw EvidenceBackendError.empty
        }
        return snapshot
    }

    func isFresh(
        snapshot: FastDesktopSnapshot,
        action: FastDesktopAction
    ) async throws -> Bool {
        true
    }

    func execute(
        action: FastDesktopAction,
        against snapshot: FastDesktopSnapshot
    ) async throws {}
}

private struct EvidenceVerifier: FastDesktopVerifier {
    func verify(
        verification: FastDesktopVerificationID,
        snapshot: FastDesktopSnapshot
    ) async -> FastDesktopVerificationResult {
        .satisfied
    }
}

private enum EvidenceBackendError: Error {
    case empty
}
