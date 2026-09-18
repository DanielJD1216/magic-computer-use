# Action Policy

Policy is local application logic. Jev confidence is a routing signal, never permission to act.

## Risk Classes

| Risk | Examples | Default version 0.1 behavior |
| --- | --- | --- |
| Read-only | Observe active app, open a local app, open a URL, search, scroll, back, wait | May auto-run only when candidate is current, permissioned, bounded, and confidence passes a locally calibrated threshold |
| Reversible | Type synthetic text into a verified test target, create a synthetic note | Show intended action; confirmation mode is configurable but conservative by default |
| Confirmation required | Type into a non-test target, copy data across apps, use an integration with external visibility | Explicit confirmation before execution |
| Destructive/external | Send, publish, delete, purchase, share private data, change account/system settings | Always require explicit confirmation; default implementation blocks these actions entirely |

## Hard Rules

- `stop` and `askUser` are always available.
- No candidate, stale observation, incomplete Accessibility state, low confidence, permission failure, or conflicting signal routes to stop or ask-user.
- The selected candidate must belong to the exact observation sent to Jev.
- A high-confidence destructive candidate never bypasses confirmation.
- A failed verification never triggers automatic replay.
- The privacy switch can disable execution while leaving transcription tests enabled.
- Every asynchronous callback checks the active `sessionGeneration` and, after selection, the `actionAttemptID` before mutating state or starting execution.
- A cancelled or superseded generation may finish transport cleanup, but its response, retry, permission callback, verifier result, or executor completion cannot authorize a new action.

## Enforceable Candidate Contract

The candidate is data, not an executable instruction. The only executable candidates are created locally from this exact allowlist:

| Candidate kind | Required local mapping | Free-form fields allowed |
| --- | --- | --- |
| `openApplication` | `NSWorkspace` launch of an allowlisted bundle identifier | None beyond the local bundle ID reference |
| `openURL` | URL opening after local scheme/domain allowlist validation | None beyond the local URL reference |
| `searchWeb` | Locally encoded query into an allowlisted search endpoint | Query payload held outside the model choice |
| `createNote` | Narrow Notes adapter using synthetic/test target only | Note content held outside the model choice |
| `typeText` | Verified focused accessibility element plus separately held text payload | No selector or text command from Jev |
| `scroll`, `goBack`, `wait`, `stop`, `askUser` | Fixed native operation | None |

The internal candidate record must carry a stable candidate ID, action kind, risk, reversibility, source observation ID, and an optional opaque payload reference. The provider response may select only the candidate ID. Unknown candidate IDs, missing required fields, extra executable fields, mismatched observation IDs, malformed payload references, and candidate-kind/payload mismatches are rejected before policy review. The native executor accepts only a locally resolved `ValidatedAction`, never a decoded provider object or free-form string.

## Decision Inputs

Policy receives:

- Candidate ID and risk.
- Jev choice, probabilities, and confidence if live selection is authorized.
- Observation ID and captured timestamp.
- Current active app/window/focus snapshot.
- Permission state.
- Confirmation mode.
- Privacy switch.
- Session cancellation state.

## Reason Codes

- `allowed_read_only`
- `allowed_reversible`
- `confirmation_required`
- `blocked_destructive`
- `blocked_stale_observation`
- `blocked_incomplete_observation`
- `blocked_permission`
- `blocked_low_confidence`
- `blocked_unknown_candidate`
- `blocked_privacy_switch`
- `stopped_by_user`
- `stopped_network_or_provider`
- `verification_failed`
- `blocked_invalid_candidate_schema`
- `blocked_permission_revoked`
- `stopped_superseded_generation`
- `unknown_effect_after_cancellation`

## Calibration

Thresholds are configuration, not facts copied from TypeSafe examples. Calibrate against representative local synthetic cases after the fake loop is working. Do not publish thresholds, accuracy, latency, or safety claims without terms review and reproducible evidence.
