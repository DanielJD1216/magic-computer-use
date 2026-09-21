import Foundation
import JevCore

private let liveJevEndpoint = URL(string: "https://api.typesafe.ai/v1/systemone")!
private let liveJevModel = "jev-latest"

private struct LiveJevSelectionState: Encodable {
    let workflow: String
    let requestID: String
    let candidateSetID: String
    let sessionGeneration: Int
    let actionAttemptID: String
    let transcriptPhase: String
    let commandFragment: String
    let fixtureVersion: String
    let fixtureView: String
    let candidates: [CandidateState]

    struct CandidateState: Encodable {
        let id: String
        let description: String
    }
}

private struct LiveJevChoiceQuestion: Encodable {
    let type = "choice"
    let instructions: String
    let criteria: [String: String]
}

private struct LiveJevRequestBody: Encodable {
    let state: LiveJevSelectionState
    let model: String
    let questions: [String: LiveJevChoiceQuestion]
}

private struct LiveJevResponseBody: Decodable {
    let model: String
    let answers: [String: LiveJevChoiceAnswer]
}

private struct LiveJevChoiceAnswer: Decodable {
    let type: String
    let choice: String
    let probabilities: [String: Double]
    let confidence: Double
}

enum LiveJevSelectionError: Error, LocalizedError, Sendable {
    case credentialMissing
    case transcriptRejected
    case transcriptTooLong
    case requestTooLarge
    case transportFailure
    case unexpectedHTTPStatus(Int)
    case malformedResponse
    case wrongAnswerType
    case probabilitySetMismatch
    case invalidProbability
    case unknownCapability

    var errorDescription: String? {
        switch self {
        case .credentialMissing:
            return "Live Jev is enabled, but no TypeSafe key is configured in this Mac's Keychain."
        case .transcriptRejected:
            return "The command contained data that is not allowed to leave the Mac."
        case .transcriptTooLong:
            return "The final command was longer than the live Jev input budget."
        case .requestTooLarge:
            return "The live Jev request exceeded the bounded payload limit."
        case .transportFailure:
            return "Live Jev could not be reached. No local fallback or action retry was made."
        case let .unexpectedHTTPStatus(status):
            return "Live Jev returned HTTP \(status). No local fallback or action retry was made."
        case .malformedResponse:
            return "Live Jev returned a response that did not match the required Choice shape."
        case .wrongAnswerType:
            return "Live Jev returned a non-Choice answer for the capability question."
        case .probabilitySetMismatch:
            return "Live Jev returned probabilities for a different capability set."
        case .invalidProbability:
            return "Live Jev returned an invalid probability or confidence value."
        case .unknownCapability:
            return "Live Jev selected a capability outside the locally generated registry."
        }
    }
}

@MainActor
final class LiveJevSelectionAdapter {
    private let credentialStore: JevCredentialStore
    private let session: URLSession

    init(
        credentialStore: JevCredentialStore = .shared,
        session: URLSession = .shared
    ) {
        self.credentialStore = credentialStore
        self.session = session
    }

    func select(
        transcript: String,
        request: CandidateRequest,
        fixtureView: FixtureView
    ) async throws -> SelectionResponse {
        try Task.checkCancellation()

        let commandFragment = try sanitizedCommandFragment(transcript)
        guard let apiKey = try credentialStore.load() else {
            throw LiveJevSelectionError.credentialMissing
        }
        guard !request.candidates.isEmpty,
              Set(request.candidates.map(\.id)).count == request.candidates.count else {
            throw LiveJevSelectionError.malformedResponse
        }

        let candidateStates = request.candidates.map {
            LiveJevSelectionState.CandidateState(
                id: $0.id.rawValue,
                description: $0.description
            )
        }
        let fixtureVersion = request.candidates[0].target.fixtureVersion
        let body = LiveJevRequestBody(
            state: LiveJevSelectionState(
                workflow: "jev-mac-safari-fixture-v1",
                requestID: request.requestID,
                candidateSetID: request.candidateSetID,
                sessionGeneration: request.sessionGeneration,
                actionAttemptID: request.actionAttemptID,
                transcriptPhase: "final",
                commandFragment: commandFragment,
                fixtureVersion: fixtureVersion,
                fixtureView: fixtureView == .reviewed ? "reviewed" : "landing",
                candidates: candidateStates
            ),
            model: liveJevModel,
            questions: [
                "capability": LiveJevChoiceQuestion(
                    instructions: "Select exactly one capability ID from the supplied closed set for this final user command. Never invent an ID or an executable parameter. Choose ask_user when no capability is clearly supported.",
                    criteria: Dictionary(uniqueKeysWithValues: request.candidates.map {
                        ($0.id.rawValue, $0.description)
                    })
                )
            ]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encodedBody: Data
        do {
            encodedBody = try encoder.encode(body)
        } catch {
            throw LiveJevSelectionError.malformedResponse
        }
        guard encodedBody.count <= 64 * 1024 else {
            throw LiveJevSelectionError.requestTooLarge
        }

        var urlRequest = URLRequest(url: liveJevEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 8
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = encodedBody

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw LiveJevSelectionError.transportFailure
        }
        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LiveJevSelectionError.transportFailure
        }
        guard httpResponse.statusCode == 200 else {
            throw LiveJevSelectionError.unexpectedHTTPStatus(httpResponse.statusCode)
        }
        guard data.count <= 64 * 1024 else {
            throw LiveJevSelectionError.requestTooLarge
        }

        let decoded: LiveJevResponseBody
        do {
            decoded = try JSONDecoder().decode(LiveJevResponseBody.self, from: data)
        } catch {
            throw LiveJevSelectionError.malformedResponse
        }
        guard !decoded.model.isEmpty,
              decoded.answers.count == 1,
              let answer = decoded.answers["capability"] else {
            throw LiveJevSelectionError.malformedResponse
        }
        guard answer.type == "choice" else {
            throw LiveJevSelectionError.wrongAnswerType
        }

        let candidateIDs = Set(request.candidates.map { $0.id.rawValue })
        guard Set(answer.probabilities.keys) == candidateIDs else {
            throw LiveJevSelectionError.probabilitySetMismatch
        }
        let probabilityTotal = answer.probabilities.values.reduce(0, +)
        guard answer.confidence.isFinite,
              (0...1).contains(answer.confidence),
              probabilityTotal.isFinite,
              abs(probabilityTotal - 1) <= 0.02,
              answer.probabilities.values.allSatisfy({ $0.isFinite && (0...1).contains($0) }) else {
            throw LiveJevSelectionError.invalidProbability
        }
        guard let capabilityID = CapabilityID(rawValue: answer.choice),
              candidateIDs.contains(answer.choice) else {
            throw LiveJevSelectionError.unknownCapability
        }

        return SelectionResponse(
            requestID: request.requestID,
            candidateSetID: request.candidateSetID,
            sessionGeneration: request.sessionGeneration,
            actionAttemptID: request.actionAttemptID,
            selectedCapabilityID: capabilityID
        )
    }

    private func sanitizedCommandFragment(_ transcript: String) throws -> String {
        let value = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            throw LiveJevSelectionError.transcriptRejected
        }
        guard value.count <= 240 else {
            throw LiveJevSelectionError.transcriptTooLong
        }

        let lowercased = value.lowercased()
        let prohibitedFragments = [
            "password",
            "api key",
            "apikey",
            "access token",
            "authorization:",
            "bearer ",
            "secret",
            "http://",
            "https://"
        ]
        guard !prohibitedFragments.contains(where: { lowercased.contains($0) }) else {
            throw LiveJevSelectionError.transcriptRejected
        }
        return value
    }
}
