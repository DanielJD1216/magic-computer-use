# Data Egress and Privacy Boundary

## Current Decision

Speech data mode is unresolved pending target-Mac probes. The default preference is on-device recognition if the selected locale and Mac support it. The app must not silently switch to remote recognition. Any remote recognition path requires explicit user consent and documented provider handling.

Live Jev transport is disabled pending authoritative agreement and data-handling clearance.

## Allowed Jev State

A future live request may contain only the minimum state needed for the next choice:

- Bounded goal or command fragment.
- Transcript phase and relevant revision context.
- Approved Safari fixture metadata.
- Trusted capability descriptions and IDs.
- Explicitly labeled, minimized untrusted fixture content where needed.
- Compact previous-result status.
- `wait`, `stop`, and `ask_user` control options where applicable.
- Session, goal, request, observation, candidate-set, payload, policy, and deadline identities needed for validation.

## Prohibited Egress

Do not send audio, screenshots, full Accessibility trees, clipboard contents, credentials, password fields, session tokens, authenticated URLs, arbitrary AppleScript, shell text, selectors, page instructions, full documents, or full session history.

Treat the current command as potentially sensitive. Use field-level allowlisting and deny-by-default serialization, not only log redaction.

## Local Logs

Allowlist only IDs, capability, policy codes, model identity if returned, timestamps, durations, response status class, verification, stop/failure/uncertainty codes, fixture version, build, OS, toolchain, permission configuration, and policy version.

Do not store raw transcripts, query strings, document bodies, Accessibility values, credentials, clipboard contents, screenshots, or raw HTTP bodies by default. Synthetic diagnostic capture must be explicit, bounded, and deletable.

## Credential Boundary

If direct client use is authorized, a personal development credential may be stored in macOS Keychain only. Before using it, document accessibility, access control, synchronization, deletion, rotation, and crash/log redaction behavior. A client-held key remains extractable risk and does not prove product authorization.

Do not request, paste, or store credentials in chat, source, fixtures, screenshots, README files, or logs.

## Provider Retention Gate

Provider retention, deletion, operational logging, and training/use handling for the minimized state must be confirmed from the applicable account agreement or authoritative provider source. Do not infer it from the existence of API documentation. Until confirmed, live transport remains disabled.

## Test Canaries

Use synthetic secret canaries in transcript, title, and Accessibility fields during probes. Verify that prohibited values do not leave the approved payload or ordinary log boundary.
