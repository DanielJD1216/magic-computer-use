# UX Acceptance Checklist

This checklist is the gate for the private prototype. It is not representative-user usability evidence and does not authorize live Jev use, public distribution, or external claims.

## Orientation and Trust

- [ ] The menu-bar item has a text-accessible state label, not color alone.
- [ ] The command bar identifies the current target application/window when known.
- [ ] The user can tell whether audio is off, armed, listening, or ended.
- [ ] The current transcript is visible and distinguishable as partial or final.
- [ ] The selected action is stated in plain language and maps to a closed candidate ID.
- [ ] The UI distinguishes automatic, confirmation-required, blocked, stopped, error, and verified outcomes.
- [ ] A visible stop control remains available during listening, selection, and execution.
- [ ] Stopping does not wait for the network or Jev.

## Permissions

- [ ] Launching the app does not request microphone or Accessibility permission by itself.
- [ ] The first-run view explains why each permission exists before requesting it.
- [ ] Microphone denial has a specific recovery path.
- [ ] Speech recognition denial/unavailability has a specific recovery path.
- [ ] Accessibility is requested only when computer actions are enabled.
- [ ] Automation is requested only for a workflow that needs it.
- [ ] A missing permission never produces a false action success.

## Action Safety

- [ ] `stop` and `askUser` are always available in the candidate set.
- [ ] No arbitrary shell command or free-form executable instruction is accepted.
- [ ] Candidate descriptions explain meaning and consequence, not just enum names.
- [ ] Medium-risk actions show the intended target and require configured confirmation.
- [ ] Externally visible, destructive, financial, privacy-sensitive, and account-changing actions remain confirmation-gated or blocked.
- [ ] High confidence never bypasses a hard confirmation rule.
- [ ] A changed app/window/focus invalidates the candidate before execution.
- [ ] The candidate schema is strict, rejects unknown/extra executable fields, binds to one observation ID, and resolves through an exact local allowlist.
- [ ] The native executor accepts only a locally constructed validated action, never provider free text.
- [ ] A failed verifier does not replay the side effect automatically.

## Recovery and Failure

- [ ] Stop during speech ends capture cleanly.
- [ ] Stop during Jev selection cancels or invalidates the response.
- [ ] Every speech, Jev, retry, permission, executor, and verifier callback rejects a stale session generation.
- [ ] Stop during execution prevents the next action from starting.
- [ ] If cancellation or a native boundary leaves the outcome unknowable, the app shows `Unknown effect`, does not replay, and requires a fresh user-visible observation.
- [ ] Unknown candidate, malformed response, timeout, `401`, `422`, `429`, and `529` have distinct redacted error paths.
- [ ] Low confidence routes to stop or ask-user according to policy.
- [ ] Jev unavailable fails closed for consequential actions.
- [ ] Verification failure says the result was not verified.
- [ ] The app reports what did not happen and a safe next step.

## Privacy and Diagnostics

- [ ] Ordinary logs contain no API keys, bearer headers, passwords, full clipboard content, or private document contents.
- [ ] The transport has a field-level allowlist for transcript, app/window, focus, candidates, observation ID, and redacted prior result.
- [ ] Provider retention/deletion behavior is documented from an authoritative source, or live transport remains disabled.
- [ ] Full transcript logging is opt-in, visibly labeled, and deletable if implemented.
- [ ] Activity history uses session ID, candidate ID, risk, observation ID, policy result, timings, and redacted result summaries.
- [ ] The app has a local privacy switch that disables execution while allowing transcription tests.
- [ ] Test fixtures contain synthetic names and content only.
- [ ] No live Jev credential is present in source, fixtures, screenshots, crash reports, or README.

## Mac Acceptance Scenarios

- [ ] Menu-bar app launches with no automation side effects.
- [ ] Push-to-talk shows partial and final transcript on a real Mac.
- [ ] Open Notes completes and verifies the active app.
- [ ] Create a synthetic note completes only in the test fixture/account.
- [ ] Browser search opens the expected synthetic/local query.
- [ ] Cross-app copy transfers only the approved synthetic title.
- [ ] Ambiguous command asks the user or stops.
- [ ] Missing Accessibility permission blocks without acting.
- [ ] Saying or pressing stop ends the current session without a new action.
- [ ] Delete/send/publish requests do not mutate anything before explicit approval and are out of default scope.
- [ ] Network unavailable stops without replaying a side effect.
- [ ] Unknown-effect recovery requires a fresh observation and does not claim reversal or success.

## Evidence Labels

- **Contract defined:** this checklist and the product brief state the intended behavior.
- **Fixture verified:** deterministic tests prove behavior without Mac or network permissions.
- **Mac verified:** a real Mac run records the exact scenario, OS/app versions, permissions, and observed result.
- **Interaction verified:** requires the approved runtime interaction evidence path; not earned by static code or this document.
- **Ready for controlled dogfooding:** only after Gate 0 target runtime/signing/sandbox evidence, Gate 2 Jev authorization and direct-call/relay decision, field-level privacy/retention review, synthetic-target isolation, and all required fixture and real-Mac gates pass. This does not mean safe, fast, accurate, or production-ready.
