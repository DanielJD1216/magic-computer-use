# Application UI/UX Brief

## Orientation Record

- **Authorized target:** `/home/jinni_doo/Dev Life/active/Meet Jev, Fastest Computer Use`, authorized by Daniel's request to read and execute the attached Jev Mac handoff.
- **Application surface:** Native macOS menu-bar utility with a floating command bar.
- **Platform:** macOS, SwiftUI with AppKit integration. Real Mac/Xcode target not available in the current WSL session.
- **Primary user:** One developer/operator running controlled, synthetic, reversible workflows.
- **Primary job:** Speak a bounded computer-use goal, see what the app heard and intends to do, allow safe progress or stop immediately, and know whether the result was verified.
- **Workflow start:** App off or menu-bar control visible.
- **Workflow finish:** Verified result, explicit confirmation pending, stopped, blocked, or failed with recovery guidance.
- **Permissions:** Microphone and speech recognition for dictation; Accessibility only when computer actions are enabled; Automation only for a workflow that proves it needs it.
- **Consequences:** Accessibility and automation can affect the user's Mac. Externally visible, destructive, financial, privacy-sensitive, or account-changing actions are blocked or confirmation-gated in version 0.1.
- **Authorization posture:** Implementation authorized for the private repository, but live Jev use is not authorized until the TypeSafe preview terms and Jev-side access decision are closed.
- **Risk tier:** Tier 3 working classification because local computer control and private accessibility state create meaningful privacy and side-effect risk. Re-tier after the real Mac permission and signing boundary are known.
- **Current decision:** Build the low-fidelity contract, state model, fake adapters, and tests first. Keep high-fidelity and real-Mac proof open until the target Mac is inspected.
- **Next gate:** Daniel or the Mac operator supplies the target toolchain/runtime evidence and resolves whether the intended Jev use is permitted. The live credential is not needed for the fake foundation.

## Evidence Ledger

### Intended

- The attached handoff requires push-to-talk, live transcription, bounded closed-set action choice, local policy, native execution, verification, cancellation, and redacted instrumentation.
- Required visible states include off, armed, listening, transcribing, choosing, executing, confirmation, blocked, stopped, error, and permission required.
- First demonstrable workflow: open Notes, create a synthetic note, and type three ideas without sending or publishing.

### Implemented

- Repository was empty except for a README before this work.
- Context files and the design/build planning artifacts are now present.
- No SwiftUI app, Xcode project, native executor, or live network adapter has been implemented yet.

### Observed

- Current host is Ubuntu 24.04 under WSL2, with no `swift` or `xcodebuild` executable.
- The Mobbin connector required by the UI skill was searched for but is unavailable in this session. No external high-fidelity pattern is adopted.
- MagicPath is skipped because the workflow contract is already defined and the target is native SwiftUI/AppKit.

### Required

- Current TypeSafe terms state preview access, prohibit sharing credentials, prohibit using the Interfaces to provide a product or service to a third party, prohibit public benchmarks, and warn the Interfaces may not be production-suitable.
- Apple APIs and macOS permissions must be verified on the actual target Mac before implementation or readiness claims.

## Product Contract

The product is an action controller, not a conversational assistant. The compact status sequence is the primary UI:

```text
Listening
“open Notes and create a note...”
Choosing: open Notes
Running
Verified: Notes is active
```

The command bar must answer, visibly and in order:

1. Is the microphone off, armed, or listening?
2. What exact words has the app heard so far?
3. Which application/window is in scope?
4. What action is being considered?
5. Will it run, wait for confirmation, or stop?
6. What happened after execution?
7. How does the user stop now?
8. What permission or recovery step is required?

## State and Surface Specification

| State | User-visible meaning | Primary controls | Safe behavior |
| --- | --- | --- | --- |
| Off | No capture or action is active | Activate, settings | No microphone or Accessibility request on launch |
| Armed | Push-to-talk is ready | Hold to speak, cancel | No audio sent or action selected |
| Listening | Microphone is actively capturing | Release, stop | Show a clear live indicator and transcript placeholder |
| Transcribing | Partial or final speech is being resolved | Stop, retry speech | Stale speech events cannot replace a newer session |
| Choosing | Current observation and transcript are being evaluated | Stop | Show target app, observation freshness, and candidate status |
| Executing | Local policy approved one bounded action | Stop | No second action starts concurrently |
| Waiting for confirmation | Action needs explicit approval | Confirm, cancel/stop | Explain action, target, and consequence in plain language |
| Blocked | Policy, permission, terms, stale state, or unsupported action prevents progress | Explain, open settings, stop | Nothing consequential runs |
| Stopped | User or local guard ended the session | Dismiss, start again | No queued request or side effect resumes automatically |
| Error | An operation failed or could not be verified | Retry safe observation, dismiss | Report what did not happen and do not silently replay |
| Unknown effect | Cancellation, timeout, crash, or native boundary leaves the result unknowable | Fresh observation, dismiss | Do not claim reversal or retry automatically |
| Permission required | A named macOS capability is missing | Explain, open System Settings, cancel | Request only the permission needed by the current capability |
| Verified | Expected visible result was observed | Dismiss, next command | Show action and verification summary, not raw private content |

## Primary Flow

1. Menu-bar item exposes current state with an accessible label and status color plus text.
2. Press-and-hold the push-to-talk control. Transition to `Listening` and show elapsed capture time.
3. Render partial transcript in a bounded region. Do not create a chat history by default.
4. On a stable final or partial transcript, capture a minimized observation: active bundle/name, a filtered window summary, focused element class, locally generated bounded candidates, transcript phase, session goal, timestamp, and observation ID. The candidate set is strict local data, not provider-generated executable instructions.
5. Show `Choosing` with the target application and candidate count. Do not show a model probability as permission.
6. Resolve the selected candidate ID against the exact observation and local allowlist. Show the selected action in plain language, risk category, and target. For medium-risk actions, show `Waiting for confirmation`; for safe reversible actions, proceed only after local freshness and policy checks.
7. Show `Executing` with a persistent stop control. The stop path is local and does not wait on Jev/network.
8. Verify the action-specific visible result. Show `Verified` only when the expected state is observed.
9. On ambiguity, stale state, permission failure, network failure, unknown choice, or verification failure, show `Blocked` or `Error`, state that the action did not run or was not verified, and offer the next safe step.

## Required Recovery Paths

- Stop during speech: end capture and discard unsent partial state for the cancelled session.
- Stop during Jev selection: advance the session generation, cancel the request, and prevent later response handling from mutating state or executing an action.
- Stop during native execution: invoke the adapter's cooperative cancellation if available. If the effect cannot be proven absent or complete, show `Unknown effect`, do not claim reversal, and require a fresh user-visible observation before any new action.
- Every speech event, Jev response, retry, permission callback, executor completion, and verifier result must match the active `sessionGeneration` and `actionAttemptID`.
- Active app/window changes: invalidate the candidate and rebuild observation.
- Accessibility permission withdrawal: block action execution and show the System Settings path.
- Unknown or malformed choice: stop, preserve only redacted diagnostics, and request a fresh observation.
- Verification failure: show `Not verified`, never repeat automatically.
- Jev unavailable: local safe/read-only flows may be offered only if an independent local path is implemented; risky actions stop. Never replay an action whose outcome is unknown.

## Native Adapter Decision

- Use SwiftUI for presentation and state binding.
- Use `MenuBarExtra` for persistent menu-bar access.
- Use an AppKit utility window/panel for the floating command bar if the native SwiftUI scene cannot provide the desired focus/always-on-top behavior.
- Use Apple Speech live audio-buffer recognition behind a protocol.
- Use Accessibility APIs for semantic element discovery and execution. Do not add coordinate clicking as a shortcut.
- Use `NSWorkspace` for application launching and safe URL opening.
- Use narrowly scoped AppleScript/Shortcuts only where a target application lacks a safer Accessibility path, with explicit permission and verification.

## External Pattern Research Gate

- **Mobbin:** searched for the required application screens/flows capability; connector unavailable in this session. No Mobbin mechanic is adopted, and freshness is unverified.
- **MagicPath:** `skip`. The layout direction is constrained by a native menu-bar utility and the handoff already defines the required states; concept-generation output would not be implementation truth.
- **Evidence limit:** this is a tool-neutral low-fidelity specification, not high-fidelity design proof or interaction verification.

## Open Decisions

- Minimum macOS version, architecture, Xcode/Swift version, bundle identifier, signing team, sandbox posture.
- Exact utility-window interaction and global hotkey implementation on the real Mac.
- Whether the direct client architecture is allowed under the current TypeSafe preview terms.
- Whether the future product path requires a relay.
- Which browser is the controlled acceptance target and how synthetic pages are isolated.
