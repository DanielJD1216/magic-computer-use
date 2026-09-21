# Fixture-Backed TypeSafe Choice Client

## Scope

`TypeSafeChoiceClient` is a provider-shaped, network-free boundary for the next Jev gate. It accepts an injected `TypeSafeChoiceTransport`, encodes the documented System One request shape, and validates one closed `Choice` answer. It does not create capabilities, choose targets, dispatch actions, store credentials, or enable live network access.

The current implementation is intentionally in `JevCore`. A future Mac transport may be added only after the Jev authorization and data-egress gates in `context/specs/00-build-plan-v1-summary.md` are closed.

## Revalidated provider contract

The request shape follows the current official TypeSafe API reference:

- Endpoint vocabulary: `POST https://api.typesafe.ai/v1/systemone`.
- Top-level fields: `state`, `model`, and a named `questions` map.
- Question type: `choice`, with `instructions` and a criteria map of option ID to rubric description.
- Current model alias: `jev-latest`.
- Choice answer fields: `type`, `choice`, `probabilities`, and `confidence`.
- Optional usage fields: `input_tokens` and `output_tokens`.

Source: <https://docs.typesafe.ai/api>

This source confirms the public request and response shape only. It does not establish Daniel's account authorization, retention terms, deletion guarantees, or permission for direct client calls.

## Local validation boundary

Before the transport is called, the client requires:

- A non-empty model and question ID.
- A non-empty closed set of choice IDs.
- Criteria keys exactly equal to the allowed choice IDs.
- Non-empty instructions and criteria descriptions.
- A serialized request below the configured payload limit.

After a successful HTTP response, the client requires:

- HTTP 200.
- A non-empty model identity.
- Exactly one answer containing the requested question ID.
- Answer type `choice`.
- Probability keys exactly equal to the local closed choice set.
- Finite probabilities in `[0, 1]` whose total is within the bounded tolerance of `1`.
- Finite confidence in `[0, 1]`.
- A selected choice contained in the local closed set.
- A response below the configured payload limit.

The client maps `401`, `422`, `429`, and `529` to explicit typed failures. Other statuses remain typed failures. Timeout, cancellation, malformed JSON, unknown choices, probability mismatches, and payload limits fail closed.

Provider error bodies are not decoded, retained, logged, or surfaced as user text.

## Fixture test coverage

The injected fixture transport covers:

- Valid request and Choice response decoding.
- Usage decoding.
- `401`, `422`, `429`, `529`, and other HTTP statuses.
- Timeout and generic transport failure.
- Cancellation propagation.
- Malformed JSON and wrong answer type.
- Probability-set mismatch, invalid probabilities, and unknown choices.
- Missing answers and request/response size limits.

No live provider call or credential was used for this slice. A live transport remains disabled until Gate 2 is closed and a separate target-Mac smoke test is explicitly authorized.
