import Foundation
import XCTest
@testable import JevCore

final class TypeSafeChoiceClientTests: XCTestCase {
    private struct FixtureState: Codable, Equatable, Sendable {
        let workflow: String
        let payload: String
    }

    private enum StubTransportError: Error, Sendable {
        case failed
    }

    private enum StubBehavior: Sendable {
        case response(TypeSafeHTTPResponse)
        case timeout
        case failure
        case delayed
    }

    private actor StubTransport: TypeSafeChoiceTransport {
        private let behavior: StubBehavior
        private var lastBody: Data?

        init(behavior: StubBehavior) {
            self.behavior = behavior
        }

        func send(body: Data) async throws -> TypeSafeHTTPResponse {
            lastBody = body
            switch behavior {
            case let .response(response):
                return response
            case .timeout:
                throw URLError(.timedOut)
            case .failure:
                throw StubTransportError.failed
            case .delayed:
                try await Task.sleep(nanoseconds: 5_000_000_000)
                try Task.checkCancellation()
                throw StubTransportError.failed
            }
        }

        func requestBody() -> Data? {
            lastBody
        }
    }

    private let state = FixtureState(workflow: "fixture-v1", payload: "bounded-state")
    private let question = TypeSafeChoiceQuestion(
        instructions: "Choose exactly one supplied option.",
        criteria: [
            "option-a": "Use option A",
            "option-b": "Use option B"
        ]
    )

    func testParsesChoiceResponseAndEncodesOfficialRequestShape() async throws {
        let transport = StubTransport(behavior: .response(.init(
            statusCode: 200,
            body: Data(#"""
            {
                "model": "jev-latest",
                "answers": {
                    "action": {
                        "type": "choice",
                        "choice": "option-a",
                        "probabilities": {"option-a": 0.8, "option-b": 0.2},
                        "confidence": 0.74
                    }
                },
                "usage": {"input_tokens": 12, "output_tokens": 3}
            }
            """#.utf8)
        )))
        let client = TypeSafeChoiceClient(transport: transport)

        let selection = try await client.choose(
            state: state,
            model: "jev-latest",
            questionID: "action",
            question: question,
            allowedChoiceIDs: ["option-a", "option-b"]
        )

        XCTAssertEqual(selection.model, "jev-latest")
        XCTAssertEqual(selection.choice, "option-a")
        XCTAssertEqual(selection.probabilities["option-a"], 0.8)
        XCTAssertEqual(selection.confidence, 0.74)
        XCTAssertEqual(selection.usage?.inputTokens, 12)
        XCTAssertEqual(selection.usage?.outputTokens, 3)

        let bodyData = await transport.requestBody()
        let body = try XCTUnwrap(bodyData)
        let decoded = try JSONDecoder().decode(
            TypeSafeSystemOneRequest<FixtureState>.self,
            from: body
        )
        XCTAssertEqual(decoded.state, state)
        XCTAssertEqual(decoded.model, "jev-latest")
        XCTAssertEqual(decoded.questions["action"], question)
    }

    func testMapsExplicitProviderHTTPStatuses() async throws {
        let cases: [(Int, TypeSafeChoiceClientError)] = [
            (401, .unauthorized),
            (422, .invalidRequest),
            (429, .rateLimited),
            (529, .overloaded),
            (503, .unexpectedHTTPStatus(503))
        ]

        for (status, expectedError) in cases {
            let transport = StubTransport(behavior: .response(.init(
                statusCode: status,
                body: Data(#"{"provider_error":"redacted"}"#.utf8)
            )))
            let client = TypeSafeChoiceClient(transport: transport)

            do {
                _ = try await client.choose(
                    state: state,
                    model: "jev-latest",
                    questionID: "action",
                    question: question,
                    allowedChoiceIDs: ["option-a", "option-b"]
                )
                XCTFail("Expected HTTP \(status) to fail")
            } catch let error as TypeSafeChoiceClientError {
                XCTAssertEqual(error, expectedError)
            }
        }
    }

    func testMapsTimeoutAndOtherTransportFailure() async throws {
        let timeoutClient = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .timeout)
        )
        do {
            _ = try await timeoutClient.choose(
                state: state,
                model: "jev-latest",
                questionID: "action",
                question: question,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
            XCTFail("Expected timeout")
        } catch let error as TypeSafeChoiceClientError {
            XCTAssertEqual(error, .timeout)
        }

        let failureClient = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .failure)
        )
        do {
            _ = try await failureClient.choose(
                state: state,
                model: "jev-latest",
                questionID: "action",
                question: question,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
            XCTFail("Expected transport failure")
        } catch let error as TypeSafeChoiceClientError {
            XCTAssertEqual(error, .transportFailure)
        }
    }

    func testCancellationIsNotConvertedToAProviderFailure() async throws {
        let client = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .delayed)
        )
        let cancellationState = state
        let cancellationQuestion = question
        let task = Task {
            try await client.choose(
                state: cancellationState,
                model: "jev-latest",
                questionID: "action",
                question: cancellationQuestion,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
        }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    func testRejectsMalformedChoiceAnswers() async throws {
        let cases: [(String, TypeSafeChoiceClientError)] = [
            (
                #"{"model":"jev-latest","answers":{"action":{"type":"noul","choice":"option-a","probabilities":{"option-a":0.8,"option-b":0.2},"confidence":0.7}}}"#,
                .wrongAnswerType
            ),
            (
                #"{"model":"jev-latest","answers":{"action":{"type":"choice","choice":"option-a","probabilities":{"option-a":1.0},"confidence":1.0}}}"#,
                .probabilitySetMismatch
            ),
            (
                #"{"model":"jev-latest","answers":{"action":{"type":"choice","choice":"option-a","probabilities":{"option-a":1.4,"option-b":-0.4},"confidence":0.7}}}"#,
                .invalidProbability
            ),
            (
                #"{"model":"jev-latest","answers":{"action":{"type":"choice","choice":"invented","probabilities":{"option-a":0.8,"option-b":0.2},"confidence":0.7}}}"#,
                .unknownChoice
            ),
            (
                "not-json",
                .malformedResponse
            )
        ]

        for (body, expectedError) in cases {
            let client = TypeSafeChoiceClient(
                transport: StubTransport(behavior: .response(.init(
                    statusCode: 200,
                    body: Data(body.utf8)
                )))
            )

            do {
                _ = try await client.choose(
                    state: state,
                    model: "jev-latest",
                    questionID: "action",
                    question: question,
                    allowedChoiceIDs: ["option-a", "option-b"]
                )
                XCTFail("Expected malformed choice response to fail")
            } catch let error as TypeSafeChoiceClientError {
                XCTAssertEqual(error, expectedError)
            }
        }
    }

    func testRejectsMissingAnswerAndOversizedPayloads() async throws {
        let missingAnswerClient = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .response(.init(
                statusCode: 200,
                body: Data(#"{"model":"jev-latest","answers":{}}"#.utf8)
            )))
        )
        do {
            _ = try await missingAnswerClient.choose(
                state: state,
                model: "jev-latest",
                questionID: "action",
                question: question,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
            XCTFail("Expected missing answer")
        } catch let error as TypeSafeChoiceClientError {
            XCTAssertEqual(error, .missingAnswer)
        }

        let oversizedRequestState = FixtureState(
            workflow: "fixture-v1",
            payload: String(repeating: "x", count: 128)
        )
        let requestLimitedClient = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .failure),
            maxRequestBytes: 64
        )
        do {
            _ = try await requestLimitedClient.choose(
                state: oversizedRequestState,
                model: "jev-latest",
                questionID: "action",
                question: question,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
            XCTFail("Expected oversized request")
        } catch let error as TypeSafeChoiceClientError {
            XCTAssertEqual(error, .requestTooLarge)
        }

        let responseLimitedClient = TypeSafeChoiceClient(
            transport: StubTransport(behavior: .response(.init(
                statusCode: 200,
                body: Data(String(repeating: "x", count: 128).utf8)
            ))),
            maxResponseBytes: 64
        )
        do {
            _ = try await responseLimitedClient.choose(
                state: state,
                model: "jev-latest",
                questionID: "action",
                question: question,
                allowedChoiceIDs: ["option-a", "option-b"]
            )
            XCTFail("Expected oversized response")
        } catch let error as TypeSafeChoiceClientError {
            XCTAssertEqual(error, .responseTooLarge)
        }
    }
}
