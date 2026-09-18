# Experiment Protocol

## Purpose

Measure the two hypotheses separately without turning a prototype into a public benchmark.

## Hypothesis A: Responsiveness

In a controlled Safari fixture, a pre-authorized harmless preparation operation may produce a visible effect before speech ends without authorizing a mutation or expanding the capability set.

If later speech contradicts the prefix, stop continuation and record the effect as unnecessary or mistaken. If zero unwanted actions is required, use final speech only.

## Hypothesis B: Semantic Selection

Given varied commands and starting states, Jev selects the appropriate exact fixture capability, waits, stops, or asks the user from the supplied candidate set.

The test set must include:

- Multiple natural-language requests with the same candidate set.
- The same request against different starting states.
- Multiple plausible candidates.
- An already-satisfied goal.
- No matching candidate.
- Correct wait and ask-user cases.
- Held-out paraphrases.
- Hostile or misleading fixture text that cannot expand capability or alter policy.

## Modes

Compare:

1. Jev selection from an eligible partial transcript.
2. Jev selection from the final transcript only.
3. A deterministic router as an experimental baseline only, never as a runtime fallback.

If the deterministic baseline performs as well as Jev, report that honestly.

## Timing Checkpoints

Use monotonic timestamps for push-to-talk, speech onset, every partial, the predetermined stable-partial event, observation, Jev request/response, policy, executor dispatch, first fixture effect, verification, speech end, key release, final transcript, stop delivery, and session invalidation.

Report separately:

- Stable-partial to first visible effect.
- Speech end to first visible effect.
- Stable-partial to verified completion.
- Speech end to verified completion.
- Failed and abandoned attempts.
- Unnecessary early effects.
- Stop dispatch inhibition and uncertain outcomes.

The one-second target is an internal hypothesis only. Define percentile, warm/cold conditions, sample set, exclusions, and failure handling before measuring.

## Sample Plan

- Five runs are a smoke test only.
- A later internal pilot may use at least 30 predeclared paired partial-mode and final-only trials if the applicable agreement permits internal measurement.
- Record held-out commands and varied fixture states.
- Preserve evidence for every attempt, not only successes.

## Failure Rules

Timeout, disconnect, invalid response, unknown candidate, wrong answer type/key, `401`, `422`, `429`, `529`, permission failure, stale target, expired confirmation, ambiguity, failed verification, or outcome uncertainty ends the goal. A user retry starts a fresh goal, observation, authorization, and request identity.

## Publication Boundary

No timing, accuracy, cost, safety, reliability, or benchmark claim may be published until the applicable TypeSafe agreement, evidence, baseline, sample, and instrumentation have been reviewed. See `Docs/PUBLICATION_CLEARANCE.md`.
