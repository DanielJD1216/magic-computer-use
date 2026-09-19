import Foundation

public enum FixtureCommandRouter {
    public static func selectCapability(
        for transcript: String,
        candidates: [CapabilityCandidate]
    ) -> CapabilityID? {
        let words = Set(
            transcript
                .lowercased()
                .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
                .map(String.init)
        )
        let candidateIDs = Set(candidates.map(\.id))

        if words.contains("wait"),
           words.contains("reviewed"),
           candidateIDs.contains(.waitForReviewedFixtureState) {
            return .waitForReviewedFixtureState
        }

        if (words.contains("reviewed") || words.contains("review")),
           candidateIDs.contains(.selectReviewedFixtureView) {
            return .selectReviewedFixtureView
        }

        let activationWords: Set<String> = ["activate", "open", "launch", "start"]
        if !activationWords.isDisjoint(with: words),
           (words.contains("safari") || words.contains("fixture")),
           candidateIDs.contains(.activatePreflightedSafariFixture) {
            return .activatePreflightedSafariFixture
        }

        return nil
    }
}
