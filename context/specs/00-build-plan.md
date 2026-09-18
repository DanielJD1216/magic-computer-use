# Build Plan

This plan turns the handoff into gated vertical slices. The live Jev adapter is intentionally not on the critical path until terms and Jev-side authorization are resolved.

## Gate 0: Target and runtime

- Inspect target Mac repository/project format, macOS minimum, architecture, Swift/Xcode, bundle ID, signing, sandbox, existing UI conventions, and real-Mac test method.
- Record exact build/test commands.
- Do not claim Mac implementation verification from WSL.

## Gate 1: Product and UX contract

- `Design/APPLICATION_UI_UX_BRIEF.md`
- `Design/UX_ACCEPTANCE_CHECKLIST.md`
- Required states: off, armed, listening, transcribing, choosing, executing, confirmation, blocked, stopped, error, permission required, verified.
- External pattern evidence remains open because Mobbin was unavailable.

## Slice 1: Pure domain contracts

- Action kind, risk, candidate, result, transcript, accessibility snapshot, observation, session state, and session event.
- Define strict decoding and local construction rules: exact candidate fields, stable candidate ID, source observation ID, risk, reversibility, opaque payload reference, and no executable free-form fields.
- Define the allowlisted candidate-to-operation mapping and `ValidatedAction` boundary. The native executor accepts only `ValidatedAction`.
- Tests: Codable round trips, unique IDs, mandatory stop/ask-user candidates, stale identity, unknown-field rejection, candidate-kind/payload mismatch, and payload non-executability.
- No SwiftUI, network, Keychain, or Mac permissions.

## Slice 2: Local policy and freshness

- Action risk policy configuration, reason codes, candidate validation, confirmation rules, stale observation guard.
- Tests: risk precedence, confidence as routing only, destructive confirmation, incomplete observation, changed app/window/focus.

## Slice 3: Fake action loop

- Orchestrator, cancellation controller, session-generation guard, action-attempt identity, fake Jev selector, fake observation, fake executor, fake verifier.
- Every callback checks generation and attempt identity before state mutation or execution.
- Tests: state transitions, cancellation precedence, single-flight execution, stale callback rejection, verifier failure without replay, ask-user fallback, and `unknownEffect` when a native outcome cannot be proven.

## Slice 4: SwiftUI shell

- MenuBarExtra, command bar, menu-bar state, local fake session rendering.
- Tests/UI tests: state visibility, stop action, permission/error/recovery copy, no permission request at launch.

## Slice 5: Permission discovery

- Permission checker, first-run guidance, PrivacyInfo.xcprivacy, recovery paths.
- Real-Mac checks for allowed, denied, restricted, and revoked states.

## Slice 6: Speech boundary

- SpeechTranscriber protocol, fake adapter, Apple Speech adapter, audio session, voice-activity boundary.
- Tests: partial/final/ended events, cancellation, microphone denial, stale partials.

## Slice 7: Native read-only adapters

- Open application, open URL/search, active app/window observation, Accessibility candidate enumeration, scroll/back/wait/stop.
- Tests with fakes first; real Mac synthetic pages/apps second.

## Slice 8: Notes and verified typing

- Narrow Notes integration and verified focused-element typing.
- No arbitrary coordinate click, send, delete, purchase, publish, or shell execution.
- Real-Mac synthetic test only.

## Gate 2: Jev authorization and access

Close all of the following before enabling live transport:

- Written or otherwise authoritative decision that the intended private prototype use is permitted under current TypeSafe preview terms.
- Confirmed Jev-side account/API access and usage scope.
- Confirmed whether direct client calls are allowed or a relay is required.
- Confirmed retention/privacy handling for the minimized state sent to the provider, including any deletion or retention uncertainty.
- Confirmed field-level transport allowlist and redaction behavior.
- Approved credential-storage path in the target Mac Keychain.

Only at this gate should the app request Jev-side credentials. Do not paste a credential into chat or source.

## Slice 9: Fixture-backed TypeSafe adapter

- Build request/response models from the current official API docs.
- Parse `Choice` selection, probabilities, confidence, usage, and explicit HTTP errors.
- Validate selected choice against the exact request candidate map.
- Test `401`, `422`, `429`, `529`, timeout, cancellation, malformed answer, and unknown candidate with fixtures.
- Keep live calls disabled by default.

## Slice 10: Live bounded selection

- Enable only in an explicit private-prototype setting after Gate 2.
- Coalesce stable partials, cancel superseded requests, and never allow a Jev result to bypass local policy/freshness.
- Run one read-only/safe synthetic workflow as a manually approved smoke test.

## Slice 11: Redacted telemetry and recovery

- Local event store, redacting logger, activity history, timing checkpoints, delete-history control.
- Test redaction and crash/restart recovery.

## Gate 3: Controlled real-Mac acceptance

- Require Gate 0 runtime/signing/sandbox evidence, Gate 2 Jev authorization/direct-call-or-relay decision, field-level privacy/retention review, and target-isolation evidence before controlled dogfooding.
- Build, unit tests, UI tests, permission states, Notes/browser/cross-app synthetic workflows, stop, ambiguity, provider failure, unknown-effect recovery, and network failure.
- Record exact evidence and unsupported actions.
- Do not publish claims or package for third parties.
