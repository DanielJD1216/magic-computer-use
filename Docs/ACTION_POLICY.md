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

## Calibration

Thresholds are configuration, not facts copied from TypeSafe examples. Calibrate against representative local synthetic cases after the fake loop is working. Do not publish thresholds, accuracy, latency, or safety claims without terms review and reproducible evidence.
