# Diagnostic Runbook

Use this file to identify the first failed layer before changing code, retrying an action, or rotating a credential. The Safari fixture must fail closed and must not replay an uncertain effect.

## Environments

| Environment | Entrypoint | Live provider | Storage | Status |
| --- | --- | --- | --- | --- |
| WSL development | Repository docs, pure tests, static checks | Disabled | Git working tree | No Swift/Xcode toolchain |
| Target Mac | Xcode app target after orientation | Disabled until authority and egress gates | Keychain plus redacted local evidence | SSH authentication pending |
| Public distribution | Not in v0.1 | Not approved | Not approved | Agreement and security review unresolved |

## Health Checks

| Layer | Check | Healthy result |
| --- | --- | --- |
| Repository | `git status --short --branch` | Expected branch and no unrelated changes |
| Target | `sw_vers`, `uname -m`, `xcodebuild -version`, `swift --version` | Versions recorded in `Docs/PLATFORM_PROBES.md` |
| Build | Exact target-specific Xcode command | Clean build for supported destination |
| Unit tests | Exact XCTest command | Registry, policy, binding, cancellation, redaction, and orchestrator tests pass |
| Permissions | In-app state plus System Settings | Current status is accurate and denied state is safe |
| Speech | Fake adapter then target-Mac probe | Partial/final/release/abort behavior is distinct |
| Fixture | Local Safari fixture probe | Process/window/fixture identity and exact verifier work |
| Selection | Fixture adapter first | Only exact candidate IDs are accepted |
| Native execution | One registered fixture operation | Trusted dispatch and exact postcondition verification |
| Cancellation | Stop at every boundary | No later callback dispatches; uncertain effect is explicit |

## First-Failure Ladder

1. Identify WSL, target Mac, permission, fixture, transport, or provider layer.
2. Reproduce with synthetic state and fake adapters before native or live actions.
3. Inspect session, goal, transcript revision, observation, candidate-set, target, action attempt, policy reason, and stop/error code.
4. Check only the permission required by the current capability.
5. Check Safari process/window/fixture identity and observation freshness.
6. Validate exact candidate membership and all request bindings.
7. Check response status and shape. Do not retry invalid answers or side effects.
8. Check bounded transient selection retry only if live transport is authorized.
9. Check redaction and egress canaries.
10. Check build/signing/runtime evidence after behavior and boundary evidence are known.

## Safe Commands

```bash
git status --short --branch
git diff --check
```

On the Mac, use the exact commands recorded after target orientation. Do not invent a build/test command before the project format is known.

## Dangerous Actions

- Never paste API keys, Keychain values, passwords, raw transcripts, clipboard contents, private Accessibility values, or customer data into logs or chat.
- Do not enable live Jev before authorization, provider handling, and egress gates close.
- Do not repeat a native effect after timeout, crash, stale target, cancellation ambiguity, or failed verification without a fresh visible observation and new decision.
- Do not grant broad Accessibility or Automation permissions to an unreviewed build.
- Use only synthetic local fixture data. No real accounts, sending, purchasing, deletion, publishing, sharing, or account changes.
- Do not claim build, safety, speed, accuracy, or readiness from WSL documentation evidence.

## Data and Queue Model

There is no remote database or queue in v0.1. The local loop is single-flight.

| Workflow | Progression |
| --- | --- |
| Capture | `off` -> `listening` -> `finalizing` -> `final` or `cancelled`/`failed` |
| Action | `idle` -> `selecting` -> `confirming` -> `executing` -> `verifying` -> `completed`/`blocked`/`stopped`/`outcome_unknown`/`failed` |
| Selection | created -> in-flight -> validated selection, stop, or error |
| Native action | proposed -> policy approved -> executing -> observed -> verified or uncertain |

## Known Failure Modes

| Symptom | First layer | Evidence | Safe next action |
| --- | --- | --- | --- |
| No transcript | Mic/speech permission or adapter | Permission and typed adapter error | Explain or stop; do not execute |
| Final transcript missing | Speech finalization | Revision and timeout state | Block first Safari operation; do not treat release as cancel |
| Unknown selection | Response validation | ID absent from exact candidate set | Stop and fresh observation |
| Target changed | Binding/freshness | Process/window/fixture mismatch | Invalidate and rebuild |
| Permission denied | Permission checker | macOS status and native error | Show specific recovery; no false success |
| Timeout or disconnect | Adapter/native boundary | Timeout plus action attempt state | Fail or `outcome_unknown`; never replay automatically |
| `401` | Authorization gate | Redacted status | Disable live mode; do not ask for key in chat |
| `422` or malformed answer | Request/response contract | Redacted validation reason | Stop and repair contract |
| `429` or `529` | Bounded selection retry | Status and retry count | Retry only authorized selection, then stop |
| Verification failed | Fixture verifier | Expected versus safe observed summary | Report not verified; fresh goal required |
| Slow result | Timing checkpoints | Monotonic phase durations | Measure internally; no public claim |

## Incident Packet

- Environment:
- User-visible symptom:
- First failed layer:
- Evidence:
- Unknowns:
- Two-minute check:
- Do not do yet:
- Next action:

## Open Questions

- Target Mac OS, architecture, Xcode/Swift, project format, signing, and sandbox.
- On-device speech support and selected locale behavior.
- Safari fixture identity, native action path, and exact verifier.
- Applicable Jev/TypeSafe authorization, direct client versus relay, and provider retention/deletion.
