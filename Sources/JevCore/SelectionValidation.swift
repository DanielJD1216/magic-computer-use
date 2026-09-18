import Foundation

public struct CandidateRequest: Equatable, Sendable {
    public let requestID: String
    public let candidateSetID: String
    public let sessionGeneration: Int
    public let actionAttemptID: String
    public let candidates: [CapabilityCandidate]

    public init(
        requestID: String,
        candidateSetID: String,
        sessionGeneration: Int,
        actionAttemptID: String,
        candidates: [CapabilityCandidate]
    ) {
        self.requestID = requestID
        self.candidateSetID = candidateSetID
        self.sessionGeneration = sessionGeneration
        self.actionAttemptID = actionAttemptID
        self.candidates = candidates
    }
}

public struct SelectionResponse: Equatable, Sendable {
    public let requestID: String
    public let candidateSetID: String
    public let sessionGeneration: Int
    public let actionAttemptID: String
    public let selectedCapabilityID: CapabilityID?

    public init(
        requestID: String,
        candidateSetID: String,
        sessionGeneration: Int,
        actionAttemptID: String,
        selectedCapabilityID: CapabilityID?
    ) {
        self.requestID = requestID
        self.candidateSetID = candidateSetID
        self.sessionGeneration = sessionGeneration
        self.actionAttemptID = actionAttemptID
        self.selectedCapabilityID = selectedCapabilityID
    }
}

public enum SelectionValidationError: Error, Equatable, Sendable {
    case requestMismatch
    case candidateSetMismatch
    case sessionGenerationMismatch
    case actionAttemptMismatch
    case selectionMissing
    case capabilityNotInCandidateSet
}

public enum SelectionValidator {
    public static func validate(
        _ response: SelectionResponse,
        against request: CandidateRequest
    ) throws -> CapabilityCandidate {
        guard response.requestID == request.requestID else {
            throw SelectionValidationError.requestMismatch
        }
        guard response.candidateSetID == request.candidateSetID else {
            throw SelectionValidationError.candidateSetMismatch
        }
        guard response.sessionGeneration == request.sessionGeneration else {
            throw SelectionValidationError.sessionGenerationMismatch
        }
        guard response.actionAttemptID == request.actionAttemptID else {
            throw SelectionValidationError.actionAttemptMismatch
        }
        guard let selectedCapabilityID = response.selectedCapabilityID else {
            throw SelectionValidationError.selectionMissing
        }
        guard let candidate = request.candidates.first(where: { $0.id == selectedCapabilityID }) else {
            throw SelectionValidationError.capabilityNotInCandidateSet
        }
        return candidate
    }
}
