# Security and Privacy

This is a private prototype for controlled, synthetic, reversible workflows. It is not a production security posture or a guarantee of safe autonomous computer use.

## Trust Boundaries

1. **Microphone and speech adapter**: produces transcript events; does not execute actions.
2. **Observation layer**: minimizes active-app/accessibility state; does not decide consequences.
3. **Jev/TypeSafe transport**: receives only the state needed for the next bounded choice, and only after its access/terms gate is closed.
4. **Local policy**: owns risk, permission, freshness, confirmation, privacy switch, and cancellation decisions.
5. **Native executor**: resolves stable candidate IDs to allowlisted operations; never accepts arbitrary commands.
6. **Verifier and event store**: records safe summaries and evidence without copying private screen contents.

## Credential Handling

- The TypeSafe API key, if the live path is authorized, is stored only in macOS Keychain.
- The key must never appear in source, `Info.plist`, README, fixtures, screenshots, crash reports, ordinary logs, or chat.
- Authorization headers are redacted before errors or diagnostics are persisted.
- Do not request or accept a key in chat. Use the approved credential-entry path on the Jev/Mac side when the access gate is closed.

## Data Minimization

The transport allowlist is field-level and deny-by-default. A live request may contain only:

- Session goal, transcript phase, and the minimum stable transcript text needed for the current choice.
- Active bundle identifier and application name.
- A window title only after local sensitivity filtering; otherwise send `window_present: true` without the title.
- Focused-element role and a non-sensitive label class; never the raw value by default.
- Locally generated candidate IDs, action kinds, risk, reversibility, and plain-language descriptions.
- Observation ID, capture timestamp, and a redacted prior action result.

Do not send audio, screenshots, video, full clipboard contents, passwords, tokens, private document bodies, raw accessibility values, file paths, URLs containing secrets, or unrestricted element trees to Jev in version 0.1. Full transcript logging is opt-in and deletable if implemented.

Provider retention, deletion, and operational-log handling for this minimized state are currently unknown. Record the authoritative provider answer before enabling live transport; do not infer deletion from the API docs or terms summary.

## Action Safety

- No shell execution, arbitrary coordinate clicking, automatic sending, deletion, purchasing, publishing, or account changes.
- Use application and domain allowlists in the prototype.
- Require fresh observation and explicit local policy approval before every action.
- Resolve the provider's selected ID through a strict local allowlist and reject unknown fields, mismatched observation IDs, malformed payload references, and candidate-kind/payload mismatches.
- Check the active `sessionGeneration` and `actionAttemptID` in every asynchronous callback.
- Treat Accessibility as a high-trust permission and explain its scope plainly.
- Stop and fail closed on ambiguity, stale state, permission failure, permission revocation, network failure, unknown candidate, or failed verification.
- Enter `unknownEffect` after cancellation, timeout, crash, or native boundary uncertainty when the app cannot prove whether an action took effect. Do not replay automatically.

## Provider Terms Gate

The current TypeSafe preview terms retrieved for this build state that preview access is for evaluating the Interfaces, forbids using them to provide a product/service to third parties, forbids public benchmarks, and warns they may not be production-suitable. The planned client may fall within a similar-product boundary. Live integration therefore remains disabled pending an authoritative Jev-side/TypeSafe authorization decision.

## Incident Response

- Revoke or remove the Keychain credential through the app's settings path if compromise is suspected.
- Delete local activity history.
- Disable the privacy switch before further debugging.
- Preserve only redacted event IDs and timestamps needed for diagnosis.
- Do not replay an uncertain native side effect after a crash, timeout, cancellation, permission revocation, or verification failure. Surface `unknownEffect` and require fresh user-visible observation.
