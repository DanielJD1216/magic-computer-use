# Data Egress and Privacy Boundary

## Current Decision

Speech data mode is unresolved pending target-Mac probes. The default preference is on-device recognition if the selected locale and Mac support it. The app must not silently switch to remote recognition. Any remote recognition path requires explicit user consent and documented provider handling.

Live Jev transport is implemented but remains default-off pending explicit Mac-side enablement, a Keychain credential, and account-specific confirmation of the applicable TypeSafe conditions.

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

## Bounded Fast Subtask Policy Boundary

A future dynamic policy may receive only operation-compatible target IDs, roles, names, bounded state, input-key names, and redacted recent action metadata. Literal input values remain local to trusted `Subtask.inputs` and must not be sent to the policy by default. Normalized runtime actions are not capabilities and cannot authorize a target, dispatch, or verifier on their own.

The local `FastDesktopExecutionEvidence` projection contains only terminal status, action metadata, and stable reason codes. It deliberately excludes the full subtask, resolved action values, snapshot context, raw Accessibility values, and provider responses.

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

Provider retention, deletion, operational logging, and training/use handling for the minimized state must be confirmed from the applicable account agreement or authoritative provider source. Public TypeSafe legal pages are recorded in `Docs/LIVE_JEV.md`, but they do not prove which agreement governs Daniel's account. The app therefore requires an explicit local enablement before transport can run.

## Test Canaries

Use synthetic secret canaries in transcript, title, and Accessibility fields during probes. Verify that prohibited values do not leave the approved payload or ordinary log boundary.
