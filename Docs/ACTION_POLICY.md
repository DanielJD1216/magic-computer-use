# Action Policy

## Policy Position

Native code is the authority for capability, target, risk, confirmation, dispatch, and verification. Jev is a bounded selector, not an executor and not a policy engine.

## Fast-subtask normalized actions

`click`, `typeText`, and `wait` are normalized runtime actions, not capabilities by themselves. A trusted capability or backend adapter must still authorize the target, operation compatibility, input-key provenance, freshness binding, dispatch, settling, and independent verifier. A normalized action must never expand the closed registry or authorize an arbitrary current-Mac target.

## First-Slice Allowlist

Only these operations may be selected or dispatched:

- `activate_preflighted_safari_fixture`
- `select_reviewed_fixture_view`
- `wait_for_reviewed_fixture_state`
- `stop`
- `ask_user`

The registry is closed. No unknown action is represented as a fallback.

## Eligibility

An eligible candidate requires all of the following:

- Correct session and goal identity.
- Transcript phase satisfies the candidate requirement.
- Candidate ID exists in the locally generated candidate set.
- Candidate-set, observation, target, payload, policy, and deadline bindings are current.
- Target is the exact preflighted Safari fixture.
- Payload provenance is allowed and immutable.
- Required permission is granted and still valid.
- No stop, cancellation, timeout, ambiguity, or unresolved prior effect exists.

If any check fails, block and request a fresh observation or user decision.

## Risk and Confirmation

The first Safari fixture is a controlled synthetic target, but local policy still classifies effects:

- **Preparatory:** may run only when explicitly registered, harmless, and independently verifiable.
- **Visible but reversible:** requires the final transcript and a fresh target check. Add confirmation if the real target boundary makes the effect externally visible.
- **Destructive, external, financial, privacy-sensitive, account-changing, or publishing:** not in the registry and therefore impossible to dispatch.

Confirmation is an exact local policy decision. Model confidence, probability, or a user-looking string from fixture content is never confirmation.

## Partial and Final Speech

- Partial revisions can update display and eligibility only.
- A partial revision may authorize a harmless predeclared preparation effect only if the gate is explicit and the effect cannot expand scope.
- Final speech is required for the first Safari operation.
- Key release finalizes capture and waits for finalization. It does not cancel.
- `abortSession` invalidates the session and prevents dispatch.
- Late revisions cannot authorize a new action after finalization, dispatch, stop, or outcome uncertainty.

## Dispatch

Immediately before dispatch, revalidate session generation, action attempt, target, candidate set, transcript revision, payload version, policy version, permission, confirmation, and deadline. Dispatch the one mapped native operation once. Never pass through free-form model output.

## Verification

The verifier must independently observe the exact expected fixture state. Executor success is not verification. If verification fails, times out, or the target changes, show failed or `outcome_unknown` as appropriate and do not retry automatically.

## Stop and Unknown Effect

Stop is local, idempotent, available in every active state, and cancels future authority before attempting cooperative cancellation. If an adapter may have acted and the result cannot be proved, show `outcome_unknown`, preserve a redacted diagnostic, require fresh observation, and prohibit replay.

## Failure Reasons

Use stable reason codes such as:

- `missing_final_transcript`
- `unknown_capability`
- `stale_candidate_set`
- `target_mismatch`
- `permission_missing`
- `confirmation_required`
- `confirmation_expired`
- `deadline_exceeded`
- `selection_invalid`
- `selection_unavailable`
- `dispatch_rejected`
- `verification_failed`
- `outcome_unknown`
- `session_stopped`

The UI explains the next safe action in plain language without exposing raw private state.
