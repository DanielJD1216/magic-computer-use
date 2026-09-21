import Foundation

public enum CapabilityID: String, CaseIterable, Codable, Sendable {
    case activatePreflightedSafariFixture = "activate_preflighted_safari_fixture"
    case selectReviewedFixtureView = "select_reviewed_fixture_view"
    case returnToLandingFixtureView = "return_to_landing_fixture_view"
    case waitForReviewedFixtureState = "wait_for_reviewed_fixture_state"
    case stop
    case askUser = "ask_user"
}

public enum TranscriptPhase: Equatable, Codable, Sendable {
    case partial
    case final
}

public enum TranscriptRequirement: Equatable, Codable, Sendable {
    case final
}

public enum PayloadProvenance: Equatable, Codable, Sendable {
    case none
    case explicitUserInput
    case declaredFixture
}

public enum ConfirmationRequirement: Equatable, Codable, Sendable {
    case none
    case explicit
}

public struct TargetBinding: Equatable, Codable, Sendable {
    public let processID: Int
    public let windowID: String
    public let fixtureVersion: String

    public init(processID: Int, windowID: String, fixtureVersion: String) {
        self.processID = processID
        self.windowID = windowID
        self.fixtureVersion = fixtureVersion
    }
}

public struct CapabilityCandidate: Identifiable, Equatable, Codable, Sendable {
    public let id: CapabilityID
    public let description: String
    public let target: TargetBinding
    public let transcriptRequirement: TranscriptRequirement
    public let payloadProvenance: PayloadProvenance
    public let confirmationRequirement: ConfirmationRequirement
    public let expiresAt: Date
    public let policyVersion: String

    public init(
        id: CapabilityID,
        description: String,
        target: TargetBinding,
        transcriptRequirement: TranscriptRequirement,
        payloadProvenance: PayloadProvenance,
        confirmationRequirement: ConfirmationRequirement,
        expiresAt: Date,
        policyVersion: String
    ) {
        self.id = id
        self.description = description
        self.target = target
        self.transcriptRequirement = transcriptRequirement
        self.payloadProvenance = payloadProvenance
        self.confirmationRequirement = confirmationRequirement
        self.expiresAt = expiresAt
        self.policyVersion = policyVersion
    }
}

public enum CapabilityRegistry {
    public static func firstSliceCandidates(
        target: TargetBinding,
        now: Date = Date()
    ) -> [CapabilityCandidate] {
        let expiry = now.addingTimeInterval(30)
        return [
            CapabilityCandidate(
                id: .activatePreflightedSafariFixture,
                description: "Activate the preflighted local Safari fixture",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .declaredFixture,
                confirmationRequirement: .none,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            ),
            CapabilityCandidate(
                id: .selectReviewedFixtureView,
                description: "Select a reviewed view in the local Safari fixture",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .declaredFixture,
                confirmationRequirement: .none,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            ),
            CapabilityCandidate(
                id: .returnToLandingFixtureView,
                description: "Return the local Safari fixture to its landing view",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .declaredFixture,
                confirmationRequirement: .none,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            ),
            CapabilityCandidate(
                id: .waitForReviewedFixtureState,
                description: "Wait for a reviewed state in the local Safari fixture",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .none,
                confirmationRequirement: .none,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            ),
            CapabilityCandidate(
                id: .stop,
                description: "Stop the current goal",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .none,
                confirmationRequirement: .none,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            ),
            CapabilityCandidate(
                id: .askUser,
                description: "Ask the user for clarification or approval",
                target: target,
                transcriptRequirement: .final,
                payloadProvenance: .none,
                confirmationRequirement: .explicit,
                expiresAt: expiry,
                policyVersion: "safari-fixture-v1"
            )
        ]
    }
}

public enum PolicyGate {
    public static func canDispatch(
        candidate: CapabilityCandidate,
        transcriptPhase: TranscriptPhase,
        target: TargetBinding,
        now: Date
    ) -> Bool {
        guard transcriptPhase == .final else { return false }
        guard candidate.target == target else { return false }
        guard now < candidate.expiresAt else { return false }
        return true
    }
}

public struct SessionAuthority: Equatable, Sendable {
    public let sessionID: String
    public private(set) var generation: Int
    public private(set) var isValid: Bool

    public init(sessionID: String, generation: Int = 0, isValid: Bool = true) {
        self.sessionID = sessionID
        self.generation = generation
        self.isValid = isValid
    }

    public mutating func stop() {
        generation += 1
        isValid = false
    }
}

public enum CaptureState: Equatable, Sendable {
    case off
    case listening
    case finalizing
    case final
    case cancelled
    case failed
}

public enum ActionState: Equatable, Sendable {
    case idle
    case selecting
    case confirming
    case executing
    case verifying
    case completed
    case blocked
    case stopped
    case outcomeUnknown
    case failed

    public var requiresFreshObservation: Bool {
        self == .outcomeUnknown
    }
}

public struct CallbackIdentity: Equatable, Sendable {
    public let sessionGeneration: Int
    public let actionAttemptID: String

    public init(sessionGeneration: Int, actionAttemptID: String) {
        self.sessionGeneration = sessionGeneration
        self.actionAttemptID = actionAttemptID
    }
}

public struct SessionLedger: Sendable {
    public let sessionID: String
    public private(set) var sessionGeneration: Int
    public private(set) var captureState: CaptureState
    public private(set) var actionState: ActionState
    private var authority: SessionAuthority
    private var activeActionAttemptID: String?

    public init(sessionID: String) {
        self.sessionID = sessionID
        self.sessionGeneration = 0
        self.captureState = .off
        self.actionState = .idle
        self.authority = SessionAuthority(sessionID: sessionID)
        self.activeActionAttemptID = nil
    }

    public mutating func beginListening() {
        guard authority.isValid else { return }
        captureState = .listening
    }

    public mutating func releaseCapture() -> Bool {
        guard captureState == .listening else { return false }
        captureState = .finalizing
        return true
    }

    public mutating func acceptFinalTranscript() -> Bool {
        guard captureState == .finalizing else { return false }
        captureState = .final
        return true
    }

    public mutating func startSelection(actionAttemptID: String) -> CallbackIdentity? {
        guard authority.isValid, captureState == .final else { return nil }
        actionState = .selecting
        activeActionAttemptID = actionAttemptID
        return CallbackIdentity(
            sessionGeneration: sessionGeneration,
            actionAttemptID: actionAttemptID
        )
    }

    public func accepts(_ callback: CallbackIdentity) -> Bool {
        authority.isValid
            && callback.sessionGeneration == sessionGeneration
            && callback.actionAttemptID == activeActionAttemptID
    }

    public mutating func stop() {
        authority.stop()
        sessionGeneration = authority.generation
        captureState = .cancelled
        actionState = .stopped
        activeActionAttemptID = nil
    }

    public mutating func startNewGoal() {
        sessionGeneration += 1
        authority = SessionAuthority(sessionID: sessionID, generation: sessionGeneration)
        captureState = .off
        actionState = .idle
        activeActionAttemptID = nil
    }
}
