import Foundation

public struct TranscriptRevision: Equatable, Sendable {
    public let revision: Int
    public let text: String
    public let phase: TranscriptPhase

    public init(revision: Int, text: String, phase: TranscriptPhase) {
        self.revision = revision
        self.text = text
        self.phase = phase
    }
}

public struct TranscriptLedger: Sendable {
    public private(set) var captureState: CaptureState = .off
    public private(set) var latest: TranscriptRevision?

    public init() {}

    public mutating func begin() {
        guard captureState == .off else { return }
        captureState = .listening
        latest = nil
    }

    public mutating func accept(_ revision: TranscriptRevision) -> Bool {
        guard captureState == .listening || captureState == .finalizing else {
            return false
        }
        if let latest, revision.revision <= latest.revision {
            return false
        }
        if revision.phase == .final {
            guard captureState == .finalizing else { return false }
            captureState = .final
        }
        latest = revision
        return true
    }

    public mutating func finishCapture() -> Bool {
        guard captureState == .listening else { return false }
        captureState = .finalizing
        return true
    }

    public mutating func abort() {
        guard captureState == .listening || captureState == .finalizing else {
            return
        }
        captureState = .cancelled
        latest = nil
    }
}
