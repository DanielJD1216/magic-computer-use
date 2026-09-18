# Diagnostic Runbook

Use this file as the first stop when something breaks. Keep it factual, current, and safe to share with an agent.

## Purpose

Identify the first failed layer in the local macOS prototype before changing code, retrying an action, or rotating a credential. The app must fail closed and must not replay an uncertain side effect.

## Environments

| Environment | Entrypoint | API base | Storage | Deploy target | Notes |
| --- | --- | --- | --- | --- | --- |
| WSL development | Repository tests and static inspection | No live Jev calls by default | Git working tree | N/A | Linux host has no Swift/Xcode toolchain |
| Local Mac prototype | Xcode app target, command pending target inspection | `https://api.typesafe.ai/v1/systemone` only when authorized | Keychain plus local redacted event store | Developer Mac | Requires explicit permissions and synthetic data |
| Public distribution | Not in version 0.1 | Not approved | Not approved | Not approved | Preview terms and product security review are unresolved |

## Health Checks

| Layer | Check | Expected healthy result |
| --- | --- | --- |
| Repository | `git status --short --branch` | Expected branch and no unrelated changes |
| Mac toolchain | `xcodebuild -version`, `swift --version` | Supported versions recorded in project context |
| Build | Project-specific Xcode build command | Clean build for the supported macOS destination |
| Unit tests | Project-specific XCTest command | Domain, policy, transport fixture, and orchestrator tests pass |
| Permissions | In-app permission screen and System Settings | Current status is accurately shown; denied state has recovery guidance |
| Speech | Synthetic/fake adapter, then real Mac speech check | Partial/final events and cancellation are deterministic |
| Jev transport | Fixture tests first; live call only after authorization | Correct request shape, typed response, bounded errors, no secret leakage |
| Native execution | Synthetic Notes/browser workflow | Action-specific verification succeeds or fails closed |
| Cancellation | Stop during speech, network, and execution boundaries | No subsequent action starts; state reports stopped |

## First-Failure Ladder

1. Confirm whether the failure is in WSL fixture work, the Mac app, a permission, the network, or the Jev provider.
2. Reproduce with synthetic state and fake adapters before touching live Mac actions.
3. Inspect the session state, observation ID, candidate ID, policy reason, and stop/error reason.
4. Check microphone, speech, Accessibility, and Automation status only for the capability being tested.
5. Check the active application and focused element before assuming an executor bug.
6. Check observation freshness immediately before execution. Never replay an action after a stale observation or failed verification.
7. Check transport status and response parsing for Jev failures. Do not retry `401`, `422`, malformed answers, cancellations, or side effects.
8. Check `429`/`529` retry bounds and timeout cancellation without printing authorization headers or raw private state.
9. Check local event-store redaction and retention if diagnostics include private text.
10. Check the Mac build/signing/runtime only after the app behavior and boundary evidence are known.

## Logs And Diagnostics

| Source | Where to check | What to look for |
| --- | --- | --- |
| Activity history | In-app redacted activity view | Session, observation, candidate, policy, executor, verification, stop/error reason |
| Development logs | Local development console, exact path pending | Redacted status and timing only |
| Keychain | macOS Keychain through the app's store | Credential presence/absence, never the value |
| TypeSafe response | Fixture capture in tests, not ordinary logs | Shape/status mapping, candidate membership, probabilities kept only in controlled diagnostics |
| Permission state | In-app permissions view plus System Settings | Missing capability and recovery action |
| Git evidence | `git diff --check`, `git status`, project-specific tests | Unintended changes, whitespace errors, test results |

## Safe Commands

These are read-only by default.

```bash
git status --short --branch
git diff --check
```

```bash
# Run the project-specific test command after a Mac/Xcode target exists.
# Do not invent a command before that target is recorded.
```

## Dangerous Actions

- Never paste API keys, Keychain values, passwords, full clipboard contents, private accessibility values, or raw customer data into logs or agent context.
- Do not enable the live Jev adapter or run a live request until terms and Jev-side authorization are closed.
- Do not re-run a native side effect after timeout, crash, stale observation, or failed verification without a fresh user-visible decision.
- Do not grant Accessibility or Automation permissions to an unreviewed build for convenience.
- Do not use real customer data, real accounts, publishing, sending, purchasing, deletion, or account changes in acceptance testing.
- Do not claim a build, release, safety result, or performance result from WSL documentation evidence.

## External Providers

| Provider | Purpose | Required secrets | Health/status check | Common failures |
| --- | --- | --- | --- | --- |
| TypeSafe/​Jev | Typed action selection | A Jev/TypeSafe API key, only after authorization | Official API docs, fixture tests, then explicit live smoke check | `401`, `422`, `429`, `529`, timeout, malformed answer, unknown candidate |
| Apple Speech | Local transcription | None beyond Mac permission | Real-Mac synthetic speech check | Permission denied, unavailable locale, cancellation race |

## Data And Queue Checks

There is no remote database or queue in version 0.1. The session loop is local and single-flight.

| Workflow | State | Healthy progression |
| --- | --- | --- |
| Push-to-talk | Session state | idle → listening → transcribing → selecting → policy review → executing/confirming → verifying → completed/stopped/failed |
| Jev selection | Request lifecycle | created → in-flight → response/cancel/error; one current request only |
| Native action | Action result | proposed → policy approved → executing → observed result → verified or failed |

## Known Failure Modes

| Symptom | First layer to check | Evidence that proves it | Safe next action |
| --- | --- | --- | --- |
| No transcript | Microphone/speech permission | Permission state and adapter error | Explain recovery or stop; do not execute |
| Jev answer unknown | Response validation | Choice absent from exact candidate map | Stop and request a fresh observation |
| Action target changed | Freshness guard | Observation ID/window/focus mismatch | Stop the action and rebuild observation |
| Permission denied | Permission checker | macOS status and native error | Show the specific permission path; no false success |
| Network timeout | Request cancellation/status | Timeout/error with session state | Stop or offer local read-only flow; never replay side effect |
| `401` | Keychain/access gate | Redacted status code | Stop live mode and resolve authorization; never print/ask for key in chat |
| `429` or `529` | Bounded retry policy | Status and retry count | Retry only the selection request within bound, then stop |
| Verification failed | Action verifier | Expected vs observed safe summary | Report not verified; do not repeat automatically |
| App feels slow | Timing checkpoints | Speech, Jev, policy, executor, verification durations | Measure first; no public performance claim |

## Incident Packet Template

- Environment:
- User-visible symptom:
- First failed layer:
- Evidence:
- Unknowns:
- Two-minute check:
- Do not do yet:
- Next action:

## Open Questions

- Supported macOS/Xcode/Swift versions and project format.
- Exact event-store location and retention implementation.
- Whether direct Jev calls from a personal client are authorized under the current preview terms.
- Whether a relay is required for any future distribution.
