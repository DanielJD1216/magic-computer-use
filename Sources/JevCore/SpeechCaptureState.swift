import Foundation

public enum SpeechCapturePhase: Equatable, Sendable {
    case idle
    case requestingPermission
    case listening
    case finalizing
    case completed
    case cancelled
    case blocked
    case failed
}

public struct SpeechCaptureLedger: Equatable, Sendable {
    public private(set) var phase: SpeechCapturePhase = .idle

    public init() {}

    public mutating func beginPermissionRequest() -> Bool {
        guard phase == .idle else { return false }
        phase = .requestingPermission
        return true
    }

    public mutating func prepareForNextCapture() -> Bool {
        switch phase {
        case .idle:
            return true
        case .requestingPermission, .listening, .finalizing:
            return false
        case .completed, .cancelled, .blocked, .failed:
            phase = .idle
            return true
        }
    }

    public mutating func authorize() -> Bool {
        guard phase == .requestingPermission else { return false }
        phase = .listening
        return true
    }

    public mutating func denyPermission() -> Bool {
        guard phase == .requestingPermission else { return false }
        phase = .blocked
        return true
    }

    public mutating func releaseCapture() -> Bool {
        guard phase == .listening else { return false }
        phase = .finalizing
        return true
    }

    public mutating func acceptFinalTranscript() -> Bool {
        guard phase == .finalizing else { return false }
        phase = .completed
        return true
    }

    public mutating func cancel() -> Bool {
        guard phase == .requestingPermission || phase == .listening || phase == .finalizing else {
            return false
        }
        phase = .cancelled
        return true
    }

    public mutating func fail() -> Bool {
        guard phase == .requestingPermission || phase == .listening || phase == .finalizing else {
            return false
        }
        phase = .failed
        return true
    }

    public mutating func reset() {
        phase = .idle
    }
}
