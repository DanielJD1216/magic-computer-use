import Foundation

public struct TypeSafeChoiceQuestion: Codable, Equatable, Sendable {
    public let type: String
    public let instructions: String
    public let criteria: [String: String]

    public init(instructions: String, criteria: [String: String]) {
        self.type = "choice"
        self.instructions = instructions
        self.criteria = criteria
    }
}

public struct TypeSafeSystemOneRequest<State: Codable & Sendable>: Codable, Sendable {
    public let state: State
    public let model: String
    public let questions: [String: TypeSafeChoiceQuestion]

    public init(
        state: State,
        model: String,
        questions: [String: TypeSafeChoiceQuestion]
    ) {
        self.state = state
        self.model = model
        self.questions = questions
    }
}

public struct TypeSafeHTTPResponse: Sendable {
    public let statusCode: Int
    public let body: Data

    public init(statusCode: Int, body: Data) {
        self.statusCode = statusCode
        self.body = body
    }
}

public protocol TypeSafeChoiceTransport: Sendable {
    func send(body: Data) async throws -> TypeSafeHTTPResponse
}

public struct TypeSafeTokenUsage: Codable, Equatable, Sendable {
    public let inputTokens: Int
    public let outputTokens: Int

    public init(inputTokens: Int, outputTokens: Int) {
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
    }

    private enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

public struct TypeSafeChoiceAnswer: Decodable, Equatable, Sendable {
    public let type: String
    public let choice: String
    public let probabilities: [String: Double]
    public let confidence: Double

    public init(
        type: String,
        choice: String,
        probabilities: [String: Double],
        confidence: Double
    ) {
        self.type = type
        self.choice = choice
        self.probabilities = probabilities
        self.confidence = confidence
    }
}

public struct TypeSafeSystemOneResponse: Decodable, Equatable, Sendable {
    public let model: String
    public let answers: [String: TypeSafeChoiceAnswer]
    public let usage: TypeSafeTokenUsage?

    public init(
        model: String,
        answers: [String: TypeSafeChoiceAnswer],
        usage: TypeSafeTokenUsage?
    ) {
        self.model = model
        self.answers = answers
        self.usage = usage
    }
}

public struct TypeSafeChoiceSelection: Equatable, Sendable {
    public let model: String
    public let choice: String
    public let probabilities: [String: Double]
    public let confidence: Double
    public let usage: TypeSafeTokenUsage?

    public init(
        model: String,
        choice: String,
        probabilities: [String: Double],
        confidence: Double,
        usage: TypeSafeTokenUsage?
    ) {
        self.model = model
        self.choice = choice
        self.probabilities = probabilities
        self.confidence = confidence
        self.usage = usage
    }
}

public enum TypeSafeChoiceClientError: Error, LocalizedError, Equatable, Sendable {
    case invalidQuestion
    case requestEncodingFailed
    case requestTooLarge
    case responseTooLarge
    case transportFailure
    case timeout
    case unauthorized
    case invalidRequest
    case rateLimited
    case overloaded
    case unexpectedHTTPStatus(Int)
    case malformedResponse
    case missingAnswer
    case wrongAnswerType
    case probabilitySetMismatch
    case invalidProbability
    case unknownChoice

    public var errorDescription: String? {
        switch self {
        case .invalidQuestion:
            return "The TypeSafe Choice question was not a non-empty closed set."
        case .requestEncodingFailed:
            return "The TypeSafe request could not be encoded."
        case .requestTooLarge:
            return "The TypeSafe request exceeded the bounded payload limit."
        case .responseTooLarge:
            return "The TypeSafe response exceeded the bounded payload limit."
        case .transportFailure:
            return "The TypeSafe provider could not be reached."
        case .timeout:
            return "The TypeSafe provider request timed out."
        case .unauthorized:
            return "The TypeSafe provider rejected the credential."
        case .invalidRequest:
            return "The TypeSafe provider rejected the request shape."
        case .rateLimited:
            return "The TypeSafe provider rate-limited the request."
        case .overloaded:
            return "The TypeSafe provider was overloaded."
        case let .unexpectedHTTPStatus(status):
            return "The TypeSafe provider returned HTTP \(status)."
        case .malformedResponse:
            return "The TypeSafe provider returned malformed JSON."
        case .missingAnswer:
            return "The TypeSafe response did not contain the requested answer."
        case .wrongAnswerType:
            return "The TypeSafe response was not a Choice answer."
        case .probabilitySetMismatch:
            return "The TypeSafe response did not preserve the exact closed choice set."
        case .invalidProbability:
            return "The TypeSafe response contained an invalid probability or confidence."
        case .unknownChoice:
            return "The TypeSafe response selected an option outside the closed choice set."
        }
    }
}

public struct TypeSafeChoiceClient: Sendable {
    private let transport: any TypeSafeChoiceTransport
    private let maxRequestBytes: Int
    private let maxResponseBytes: Int

    public init(
        transport: any TypeSafeChoiceTransport,
        maxRequestBytes: Int = 64 * 1024,
        maxResponseBytes: Int = 64 * 1024
    ) {
        self.transport = transport
        self.maxRequestBytes = max(1, maxRequestBytes)
        self.maxResponseBytes = max(1, maxResponseBytes)
    }

    public func choose<State: Codable & Sendable>(
        state: State,
        model: String,
        questionID: String,
        question: TypeSafeChoiceQuestion,
        allowedChoiceIDs: Set<String>
    ) async throws -> TypeSafeChoiceSelection {
        try Task.checkCancellation()
        guard !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !questionID.isEmpty,
              !question.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !allowedChoiceIDs.isEmpty,
              question.criteria.keys.count == allowedChoiceIDs.count,
              Set(question.criteria.keys) == allowedChoiceIDs,
              question.criteria.keys.allSatisfy({ !$0.isEmpty }),
              question.criteria.values.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw TypeSafeChoiceClientError.invalidQuestion
        }

        let request = TypeSafeSystemOneRequest(
            state: state,
            model: model,
            questions: [questionID: question]
        )
        let encodedRequest: Data
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            encodedRequest = try encoder.encode(request)
        } catch {
            throw TypeSafeChoiceClientError.requestEncodingFailed
        }
        guard encodedRequest.count <= maxRequestBytes else {
            throw TypeSafeChoiceClientError.requestTooLarge
        }

        let response: TypeSafeHTTPResponse
        do {
            response = try await transport.send(body: encodedRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .timedOut {
            throw TypeSafeChoiceClientError.timeout
        } catch {
            throw TypeSafeChoiceClientError.transportFailure
        }
        try Task.checkCancellation()

        switch response.statusCode {
        case 200:
            break
        case 401:
            throw TypeSafeChoiceClientError.unauthorized
        case 422:
            throw TypeSafeChoiceClientError.invalidRequest
        case 429:
            throw TypeSafeChoiceClientError.rateLimited
        case 529:
            throw TypeSafeChoiceClientError.overloaded
        default:
            throw TypeSafeChoiceClientError.unexpectedHTTPStatus(response.statusCode)
        }
        guard response.body.count <= maxResponseBytes else {
            throw TypeSafeChoiceClientError.responseTooLarge
        }

        let decoded: TypeSafeSystemOneResponse
        do {
            decoded = try JSONDecoder().decode(TypeSafeSystemOneResponse.self, from: response.body)
        } catch {
            throw TypeSafeChoiceClientError.malformedResponse
        }
        guard !decoded.model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let answer = decoded.answers[questionID] else {
            throw TypeSafeChoiceClientError.missingAnswer
        }
        guard decoded.answers.count == 1 else {
            throw TypeSafeChoiceClientError.malformedResponse
        }
        guard answer.type == "choice" else {
            throw TypeSafeChoiceClientError.wrongAnswerType
        }
        guard Set(answer.probabilities.keys) == allowedChoiceIDs else {
            throw TypeSafeChoiceClientError.probabilitySetMismatch
        }
        let probabilityTotal = answer.probabilities.values.reduce(0, +)
        guard answer.confidence.isFinite,
              (0...1).contains(answer.confidence),
              probabilityTotal.isFinite,
              abs(probabilityTotal - 1) <= 0.02,
              answer.probabilities.values.allSatisfy({ $0.isFinite && (0...1).contains($0) }) else {
            throw TypeSafeChoiceClientError.invalidProbability
        }
        guard allowedChoiceIDs.contains(answer.choice) else {
            throw TypeSafeChoiceClientError.unknownChoice
        }

        return TypeSafeChoiceSelection(
            model: decoded.model,
            choice: answer.choice,
            probabilities: answer.probabilities,
            confidence: answer.confidence,
            usage: decoded.usage
        )
    }
}
