# Security and Privacy

This is a private prototype for controlled, synthetic, reversible workflows. It is not a production security posture or a guarantee of safe autonomous computer use.

## Trust Boundaries

1. **Microphone and speech adapter:** produces transcript revisions; never executes actions.
2. **Eligibility and observation:** creates minimized, versioned local state; never expands capability.
3. **Selection adapter:** fixture first; future Jev receives only an allowlisted request and returns a bounded selection.
4. **Local policy:** owns target, provenance, freshness, risk, confirmation, deadlines, permissions, and cancellation.
5. **Native executor:** maps exact capability IDs to trusted code; never accepts free-form commands.
6. **Verifier:** independently checks the expected fixture postcondition.
7. **Evidence logger:** records only allowlisted summaries.

## Credential Handling

A future authorized live credential may be stored only in macOS Keychain. It must not appear in source, Info.plist, fixtures, screenshots, crash reports, logs, or chat. Authorization headers are redacted before diagnostics. Do not request or accept a key in chat.

## Data Minimization

Deny by default. A future live request may contain only the minimum bounded goal, transcript phase/revision, reviewed Safari fixture metadata, exact candidate IDs/descriptions, minimized untrusted fixture text where necessary, compact prior-result status, and identity/deadline fields needed for validation.

Never send audio, screenshots, video, full Accessibility trees, clipboard contents, passwords, tokens, private document bodies, raw Accessibility values, arbitrary URLs, page instructions, shell text, or full session history.

## Local Logs

Allowlist IDs, capability, policy/version codes, timestamps, durations, status classes, fixture version, build/OS/toolchain, permission configuration, verification, and stop/failure/uncertainty codes. Do not store raw transcripts, query strings, document bodies, credentials, clipboard values, screenshots, or raw HTTP bodies by default.

## Action Safety

No shell, arbitrary coordinates, generic typing, external sites, sending, deletion, purchase, publication, sharing, account changes, or uncontrolled navigation. Recheck all bindings immediately before one trusted dispatch. Stop invalidates authority first. Any uncertain effect becomes `outcome_unknown` and cannot be replayed automatically.

## Provider Gate

TypeSafe/Jev terms, private-use authorization, direct-client versus relay, provider retention, deletion, operational logging, and training/use handling remain unresolved. Live transport is disabled until authoritative answers and the minimized egress review are recorded.

## Incident Response

If compromise is suspected, revoke the Keychain credential, delete local activity history, disable execution, and preserve only redacted IDs/timestamps needed for diagnosis. Never replay an uncertain native effect.
