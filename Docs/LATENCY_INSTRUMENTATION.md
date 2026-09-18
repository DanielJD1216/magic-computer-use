# Latency Instrumentation

Measure the action loop before making any performance claim. Timing records are local and redacted.

## Checkpoints

- `session_started`
- `push_to_talk_pressed`
- `speech_first_partial`
- `speech_stable_partial`
- `speech_final`
- `observation_captured`
- `jev_request_started`
- `jev_response_received`
- `policy_decided`
- `confirmation_shown`
- `confirmation_received`
- `executor_started`
- `executor_observed_result`
- `verification_started`
- `verification_completed`
- `session_stopped`
- `session_failed`

## Store

Each event may include:

- Session ID.
- Observation ID.
- Candidate ID and risk class.
- Transcript phase, not full transcript by default.
- Monotonic timestamp/duration.
- Policy decision and reason code.
- Redacted result summary.
- Stop/error category.

Never store API keys, bearer headers, passwords, full clipboard contents, private document values, raw screenshots, audio, or unrestricted accessibility trees.

## Derived Measures

- Speech start to first visible action.
- Stable partial to Jev response.
- Jev response to policy decision.
- Policy decision to executor start.
- Executor start to verification completion.
- End-to-end success and stop latency.
- Verification success rate, unnecessary action rate, and failed-closed rate.

## Evidence Rules

- Use a fixed synthetic task set and record OS, app, network, model alias, and build identifiers.
- Keep provider request count and cost internal unless current terms permit publication.
- Do not compare Jev or this prototype publicly without terms review, a defined baseline, and reproducible runs.
- If instrumentation changes behavior materially, label the measurement accordingly.
