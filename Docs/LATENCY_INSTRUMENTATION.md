# Latency Instrumentation

Measure the local Safari-fixture loop before making any performance statement. Timing records are local, monotonic, bounded, and redacted.

## Checkpoints

- `session_started`
- `push_to_talk_pressed`
- `speech_first_partial`
- `speech_stable_partial`
- `speech_release`
- `speech_final`
- `eligibility_decided`
- `observation_captured`
- `candidate_set_created`
- `selection_request_started`
- `selection_response_received`
- `policy_decided`
- `confirmation_shown`
- `confirmation_received`
- `dispatch_started`
- `fixture_effect_observed`
- `verification_started`
- `verification_completed`
- `stop_requested`
- `authority_invalidated`
- `outcome_unknown`
- `session_failed`

### Bounded fast subtask runtime

The fixture-backed `FastSubtaskExecutor` emits these local, monotonic lifecycle checkpoints:

- `subtask_started`
- `observation_captured`
- `action_space_built`
- `policy_decision_started`
- `policy_decision_received`
- `freshness_checked`
- `action_dispatched`
- `settle_completed`
- `verification_started`
- `verification_completed`
- `subtask_terminal`

These markers carry no task text, literal input values, raw Accessibility values, screenshots, or provider responses. They are instrumentation for the bounded local runtime and do not imply live-provider or generic-desktop readiness.

## Stored Fields

- Session, goal, request, observation, candidate-set, and action-attempt IDs.
- Capability ID and risk class.
- Transcript phase and revision, not raw transcript by default.
- Monotonic timestamp and duration.
- Policy decision and reason code.
- Fixture version and target binding class.
- Redacted result, stop, failure, or uncertainty code.

Never store API keys, bearer headers, passwords, raw transcripts, full clipboard values, private document values, screenshots, audio, or unrestricted Accessibility trees.

## Derived Measures

Report separately:

- Stable partial to first visible fixture effect.
- Speech release to first visible fixture effect.
- Stable partial to verified completion.
- Speech release to verified completion.
- Stop request to authority invalidation.
- Unnecessary early effects.
- Failed, abandoned, and uncertain attempts.
- Selection and verification failure rates.

The one-second target is an internal hypothesis, not a promise. Define percentile, warm/cold conditions, sample set, exclusions, baseline, and failure handling in `Docs/EXPERIMENT_PROTOCOL.md` before measuring.

## Evidence Rules

Use fixed synthetic commands, varied fixture states, held-out paraphrases, and recorded OS/app/build/toolchain/permission conditions. Keep provider request count and cost internal unless agreement and publication clearance permit otherwise. Do not compare Jev or this prototype publicly without agreement review, baseline, and reproducible runs. If instrumentation changes behavior materially, label the measurement.
