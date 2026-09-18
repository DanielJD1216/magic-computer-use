# Jev Mac Voice Computer-Use v0.1 Revised Implementation Plan

> **For Dev Life:** This revision supersedes the earlier broad implementation proposal for execution. Use `/application-ui-ux` for the native application UX process and build the client in SwiftUI/AppKit for macOS. The original plan remains the audit trail at `.hermes/plans/2026-09-18_141351-jev-mac-voice-control.md`.
>
> **Review status:** The original plan was grilled with Daniel, then independently assessed by GPT-6 Astra Thinking High. Astra returned **GO WITH REQUIRED CHANGES**. This revision incorporates the required changes. It is approved for repository orientation and feasibility probes, not blind implementation.

**Goal:** Prove a narrow, safe, native Mac voice-to-action loop in a controlled Safari fixture before adding cross-application Notes workflows or broader computer-use actions.

**Architecture:** SwiftUI/AppKit owns the command surface. Apple Speech or the selected approved speech adapter produces session-scoped transcript revisions. A trusted capability registry creates exact operations against approved targets. Jev selects one eligible operation from a closed candidate set. Deterministic policy checks transcript phase, target freshness, payload provenance, permissions, and risk. Native code dispatches the operation once, independently verifies the postcondition, and records an allowlisted event. The stop path invalidates future dispatch locally and does not pretend to undo an already-issued operating-system call.

**Tech stack:** SwiftUI, AppKit, Swift concurrency, `MenuBarExtra`, a verified floating panel, the selected speech adapter, macOS Accessibility APIs only for approved fixture operations, `NSWorkspace` only for approved application activation, `URLSession` for the TypeSafe adapter, Keychain for a personal development credential if permitted, XCTest, SwiftUI UI tests, and real-Mac probes.

---

## 1. Current decision and scope

### 1.1 Current decision

Proceed to:

1. Dev Life repository orientation.
2. Target-Mac feasibility probes.
3. Corrected product and safety contract.
4. Low-fidelity UX discovery and design.
5. A controlled Safari fixture slice.

Do not proceed directly to:

- Generic Mac automation.
- Notes creation or cross-app transfer.
- Public web search.
- Arbitrary Accessibility clicking or typing.
- Public distribution.
- Video claims about general computer control, guaranteed safety, or one-second end-to-end performance.

### 1.2 First user and target

- First user: Daniel.
- First runtime: one verified Apple Silicon Mac.
- Proposed target: macOS 14 or newer, pending Dev Life repository and target-Mac verification.
- Distribution: local Xcode-run private prototype.
- Target repository: a separate Dev Life project. The target repository is not present in the current YouTube workspace.
- Do not infer target conventions from the current working directory.

### 1.3 Actual first product slice

The first slice controls a preflighted, synthetic, local Safari fixture:

```text
push to talk
  → partial and final transcript revisions
  → deterministic eligibility gate
  → exact fixture capability candidates
  → Jev selects one eligible operation, wait, stop, or ask_user
  → policy revalidates target and authorization
  → native Safari fixture operation executes once
  → exact fixture state is verified
  → session continues, completes, stops, or reports uncertainty
```

The first slice must demonstrate real Jev selection across varied commands and starting states. It must not be a fixed sequence with Jev inserted only for appearance.

### 1.4 Second slice, only after the first gate passes

Add one exact-payload local Notes operation only after the Safari fixture gate passes:

```text
final transcript
  → exact user-dictated or fixture-provided payload
  → specific local Notes account and folder
  → visible confirmation bound to the exact payload and destination
  → trusted Notes adapter
  → exact note identity and content verification
```

The phrase “create a note called Video ideas, and type three ideas” is not an acceptance command unless the three ideas come from explicit dictation or a declared fixture. Jev Choice output does not generate missing content.

### 1.5 Explicit non-goals for v0.1

Do not include:

- Always-on listening.
- Arbitrary shell commands or AppleScript supplied by the user or page content.
- Generic coordinate clicking.
- Generic Accessibility clicking as a runtime capability.
- Generic typing into an arbitrary focused element.
- Arbitrary URLs, redirects, custom schemes, downloads, or pop-ups.
- Public search or uncontrolled websites in the acceptance fixture.
- Send, delete, purchase, publish, share private data, account changes, or system settings.
- Camera access.
- Clipboard transfer.
- Screenshot or vision fallback.
- Browser extensions.
- Multi-user accounts, billing, cloud sync, telemetry, relay infrastructure, installer, notarization, or public download.
- Automatic recovery or replay after an uncertain operation.
- Performance or benchmark claims before evidence and agreement clearance.

---

## 2. Proof strategy

The product idea contains two separate hypotheses. Test them separately.

### 2.1 Responsiveness hypothesis

> In a controlled Safari fixture, a pre-authorized preparatory operation can produce a visible effect before actual speech ends, without authorizing a mutation or expanding the allowed capability.

This does not mean that a stable partial transcript is committed intent. It means the user has pre-authorized a narrowly defined preparatory effect for this experiment.

Allowed early effects must be:

- Target-specific.
- Reversible or harmless within the synthetic fixture.
- Fixed to a reviewed local fixture route or view.
- Not externally visible.
- Not a mutation.
- Not a generic click, typing, URL, or navigation primitive.

If later speech contradicts the prefix, stop continuation and record the early action as unnecessary or mistaken. Do not relabel it as correct after the fact. If the requirement is zero unwanted actions, require final speech instead of speculative execution.

### 2.2 Semantic-selection hypothesis

> Given varied commands and starting states, Jev selects the appropriate exact fixture capability, waits, stops, or asks the user from the candidate set.

The test set must include:

- Multiple natural-language requests with the same candidate set.
- The same request against different starting states.
- Multiple plausible candidates.
- An already-satisfied goal.
- No matching candidate.
- A case where waiting is correct.
- A case where asking is correct.
- Held-out paraphrases not used to tune the request.
- Hostile or misleading fixture text that must not expand capability or alter policy.

Compare three modes:

1. Jev selection from an eligible partial transcript.
2. Jev selection from the final transcript only.
3. A deterministic router used only as an experimental baseline, never as a runtime fallback.

If the deterministic baseline performs as well as Jev, report that honestly. Do not manufacture ambiguity to justify the model.

### 2.3 Timing protocol

Use monotonic timestamps for:

- Push-to-talk activation.
- Detected speech onset, if available.
- Every partial transcript arrival.
- The predetermined partial-stability event.
- Observation acquisition.
- Jev request start and response.
- Policy decision.
- Executor dispatch.
- First observed fixture effect.
- Verification completion.
- Actual speech end, key release, and final transcript.
- Stop input delivery.
- Session invalidation.

Report separately:

- Stable-partial event to first visible effect.
- Actual speech end to first visible effect.
- Stable-partial event to verified completion.
- Actual speech end to verified completion.
- Failure and abandoned attempts.
- Unnecessary early effects.
- Stop dispatch inhibition and uncertain outcomes.

The one-second target is an internal engineering hypothesis only. Before measuring it, define the percentile, warm and cold conditions, sample set, exclusion rules, and treatment of failures. Five runs are a smoke test, not a reliability study. A later responsiveness pilot should use at least 30 predeclared paired partial-mode and final-only trials if the cost and terms permit internal measurement.

Never publish a timing claim until the applicable TypeSafe agreement, evidence, baseline, sample, and displayed instrumentation have been reviewed.

---

## 3. Capability and action contract

### 3.1 Capability principle

A candidate is an exact trusted operation, not a generic instruction primitive.

Every capability must declare:

- Stable capability ID.
- Human-readable description.
- Exact target identity.
- Allowed effect.
- Preconditions.
- Payload provenance.
- Transcript phase requirement.
- Confirmation requirement.
- Expiry and invalidation conditions.
- Native implementation.
- Operation-specific verifier.
- Risk and reason code.

Page text, Accessibility labels, titles, URLs, or Jev output may not create a new capability or alter its risk class.

### 3.2 First-slice capability registry

The exact names may be mapped into the Dev Life repository's conventions after orientation. The first registry should contain only operations equivalent to:

```text
activate_preflighted_safari_fixture
select_reviewed_fixture_view
wait_for_reviewed_fixture_state
stop
ask_user
```

`observe_fixture_state` is an internal observation service, not a Jev-selected execution capability.

`select_reviewed_fixture_view` must resolve to a known fixture view and reviewed native interaction. It must not accept a page-provided selector, arbitrary URL, coordinate, or free-form keyboard command.

`activate_preflighted_safari_fixture` may activate a known Safari process and known fixture window only after the target binding is verified. It must not open an arbitrary external URL or restore an uncontrolled personal window.

### 3.3 Deferred Notes capability

The later Notes registry may contain one exact operation equivalent to:

```text
create_exact_local_note
```

It must bind to:

- A named local Notes account or explicitly approved local storage location.
- A named folder when the platform exposes one.
- An exact title.
- An exact content payload with trusted provenance.
- A single authorized operation sequence.
- A visible confirmation that expires and is invalidated by target or payload changes.
- A verifier that identifies the created note, destination, and content.

Do not implement generic `click_accessible_element`, `type_text`, `copy_data`, or `open_url` as first-slice capabilities.

### 3.4 Candidate object

Use the target repository's existing model conventions. The logical shape should include:

```swift
struct CapabilityCandidate: Identifiable, Codable, Equatable {
    let id: String
    let description: String
    let targetBinding: TargetBinding
    let effect: AllowedEffect
    let payloadProvenance: PayloadProvenance
    let transcriptRequirement: TranscriptRequirement
    let confirmationRequirement: ConfirmationRequirement
    let expiresAt: Date
    let verifierID: String
    let policyVersion: String
}
```

Do not expose executable selectors, arbitrary URLs, AppleScript source, shell text, credentials, or page-supplied command strings in the candidate.

---

## 4. Trust boundaries and responsibilities

Keep these boundaries fixed:

| Component | Responsibility | Must not do |
|---|---|---|
| Speech adapter | Produce session-scoped partial and final revisions; report recognition mode and errors | Authorize a mutation or treat key release as final intent |
| Observer | Read bounded facts from an approved fixture target | Establish permission or invent capabilities |
| Capability builder | Create exact candidates from trusted local definitions and current facts | Convert arbitrary page labels into actions |
| Jev adapter | Select one supplied candidate or `wait`, `stop`, or `ask_user` | Create targets, change policy, or authorize effects |
| Policy engine | Check transcript phase, target, payload, permission, freshness, risk, and confirmation | Schedule retries or execute native operations |
| Orchestrator | Own goal lifecycle, revisions, request supersession, budgets, cancellation, and sequencing | Treat a late response as current |
| Executor | Recheck target and preconditions, dispatch one trusted operation, report native status | Parse arbitrary instructions or promise verification |
| Verifier | Independently inspect the operation-specific postcondition | Echo executor optimism |
| Event store | Store an allowlisted redacted event schema | Store raw transcripts, URLs, AX values, secrets, or HTTP bodies |

Policy may return eligibility and denial reasons. Scheduling belongs to the orchestrator. Do not let policy and orchestrator both own retry behavior.

---

## 5. Session and concurrency model

### 5.1 Two coordinated state dimensions

A single linear state machine cannot represent speech capture overlapping with action work. Model at least:

```text
CaptureState:
  off
  listening
  finalizing
  final
  cancelled
  failed

ActionState:
  idle
  selecting
  confirming
  executing
  verifying
  completed
  blocked
  stopped
  outcome_unknown
  failed
```

The UI may derive a compact display state from these two authoritative dimensions. Include explicit `finalizing`, `verifying`, `completed`, and `outcome_unknown` states in the UX contract.

### 5.2 Revision and authority binding

Bind every Jev decision and every confirmation to:

- Session ID.
- Goal ID.
- Transcript revision.
- Observation revision.
- Request ID.
- Candidate-set identity.
- Immutable payload version.
- Policy version.
- Target binding.
- Confirmation identity, when applicable.
- Deadline.

Immediately before dispatch, revalidate all bindings. A cancelled request may still return from the server. Its response must be unusable after local invalidation.

Observation IDs and timestamps alone do not establish target freshness. Where the platform permits, recheck:

- Process identity and launch instance.
- Window identity.
- Fixture identity.
- Element identity and supported actions.
- Relevant attributes and preconditions.
- Current authorization and policy version.

There remains a check-to-use interval. Reduce its risk by using exact fixture operations and avoiding global keyboard actions.

### 5.3 Capture lifecycle

Releasing push-to-talk means capture ended. It does not mean the session was cancelled, and it does not authorize a mutation.

Use separate operations equivalent to:

```text
finishCaptureAndFinalize
abortSession
```

The speech adapter must distinguish accepted-audio finalization from cancellation. A final transcript may arrive after key release. Late transcript callbacks must be revision-checked.

### 5.4 Stop behavior

The local stop control must:

1. Invalidate dispatch authority.
2. Cancel speech and pending Jev work where possible.
3. Prevent any later candidate from dispatching.
4. Remain usable while the overlay is confirming, executing, verifying, or blocked.
5. Report when an already-issued native operation later completes.
6. Never claim that Stop undid an operation.

Stop is a dispatch-inhibition and session-invalidation control, not an unconditional interruption guarantee for every operating-system call.

### 5.5 Goal boundaries and budgets

- One goal at a time.
- One dispatched operation at a time.
- New speech while a goal is busy must be rejected or explicitly cancel-and-restart. It must not silently replace an existing goal or confirmation.
- First-slice limits: 10 candidate dispatch opportunities, 20 Jev evaluations, a wall-clock deadline, and a payload-size limit.
- Repeated `wait` or observation cycles must consume budget.
- Exceeding a budget ends the goal with a specific reason.
- A crash or restart discards the goal and requires a new observation and command.

---

## 6. Risk and policy contract

### 6.1 Hard capability boundary

These capabilities do not exist in v0.1, even behind confirmation:

- Send.
- Delete.
- Purchase.
- Publish.
- Share private information.
- Change system settings.
- Open arbitrary external URLs.
- Navigate uncontrolled websites.
- Press arbitrary buttons through generic AX or keyboard control.
- Type into arbitrary fields.
- Run shell or AppleScript text supplied by the user, page, or model.

Confirmation cannot enable an unsupported capability.

### 6.2 Partial speech policy

Partial speech may authorize only the pre-declared fixture preparation operation. It may not authorize:

- A mutation.
- A destination chosen from incomplete speech.
- A generic navigation primitive.
- A page-provided action.
- A payload transfer.
- A Notes operation.

If later transcript revisions contradict the early prefix, stop continuation and record the unnecessary effect. If the fixture cannot provide a safe pre-authorized operation, wait for final speech.

### 6.3 Final speech and confirmation

For the first Safari fixture, final speech is required unless the action matches the explicit preparatory exception.

For the later Notes operation:

- Final transcript is mandatory.
- The final payload must be explicit or fixture-provided.
- Confirmation must name the exact operation, payload, destination, current goal, and target.
- Confirmation expires after a short defined interval and on any payload, target, goal, observation, or policy change.
- There is no confirmation-off setting in v0.1.
- A changed payload or destination requires new confirmation.

Jev confidence is never permission.

### 6.4 Prompt injection and untrusted content

Treat fixture text, web page text, Accessibility labels, copied content, and document text as untrusted data. They may be included in a judgment only with explicit labels and minimization.

They must not:

- Create a candidate.
- Change an effect or risk class.
- Supply a confirmation.
- Provide executable code.
- Expand an allowlist.
- Change the target binding.
- Override Stop or policy.

The security boundary is the capability registry and deterministic policy, not prompt wording.

### 6.5 Failure behavior

For the first slice, the following end the goal without fallback:

- Jev timeout.
- Network failure.
- Invalid response.
- Unknown candidate.
- Wrong answer type or key.
- `401`, `422`, `429`, `529`, or unexpected HTTP status.
- Missing or revoked permission.
- Stale target.
- Expired confirmation.
- Ambiguous or unsupported intent.
- Failed verification after a possible dispatch.

A user retry starts a fresh goal, observation, authorization, and request identity. No automatic inference or action retry is allowed in the first slice. Bounded observation polling is not action replay and must have a deadline.

If a native write may have occurred but verification fails, report `outcome_unknown`. Never offer a retry that silently repeats it.

---

## 7. Data, privacy, and credentials

### 7.1 TypeSafe input boundary

Send only the minimum state needed for the next choice:

- Bounded goal or command fragment.
- Transcript phase and relevant revision context.
- Approved fixture metadata.
- Trusted operation descriptions.
- Minimal, explicitly untrusted content labels where needed.
- Compact previous-result status.
- `wait`, `stop`, and `ask_user` where applicable.

Do not send:

- Audio.
- Screenshots.
- Full Accessibility trees.
- Clipboard contents.
- Credentials, password fields, session tokens, or authenticated URLs.
- Arbitrary AppleScript, shell text, selectors, or page instructions.
- Full documents or full session history.

“Current command” can be sensitive. Define an egress and minimization policy rather than relying on log redaction.

### 7.2 Speech data mode

Before implementation, explicitly choose one:

1. On-device-only speech recognition, if the selected locale and target Mac support it.
2. Remote recognition with explicit user consent and documented data handling.

Do not silently switch from on-device to remote recognition when local recognition is unsupported. Record the selected mode in the orientation and privacy documents.

### 7.3 Local logs

Use an allowlisted schema containing only:

- Session, goal, request, observation, and candidate IDs.
- Action kind or capability ID.
- Risk and policy result codes.
- Timestamps and durations.
- Model identity, if returned.
- Response status class, not raw HTTP bodies.
- Verification result.
- Stop, failure, and uncertainty reason.

Do not store raw transcripts, query strings, document bodies, AX values, credentials, clipboard contents, or screenshots by default. Keep transient content in memory and make any synthetic diagnostic capture explicit, bounded, and deletable.

### 7.4 Keychain

Keychain is appropriate for a personal development credential if direct client use is allowed, but it does not make a client-held key impossible to extract. Before use, define:

- Keychain accessibility and access-control settings.
- Synchronization behavior.
- Deletion and rotation behavior.
- Redaction rules.
- No inclusion in crash reports, diagnostics, screenshots, or UI state.

Product mode with a relay is deferred. A relay does not cure a contractual restriction on the underlying TypeSafe use.

### 7.5 Test environment

Use:

- A dedicated macOS test account where practical.
- Synthetic fixture text and secret canaries.
- A preflighted Safari fixture with no personal authenticated sessions.
- No real customer data, secrets, private medical data, or financial data.
- No clipboard dependency.

A dedicated browser window does not isolate the broad permission granted to the application.

---

## 8. Platform feasibility gates

Resolve these before building live automation.

### 8.1 Repository and signing

Confirm in Dev Life:

- Repository path and instructions.
- Xcode and Swift versions.
- Minimum macOS version.
- Apple Silicon and Intel requirements.
- Bundle identifier and signing team.
- Sandboxed or non-sandboxed configuration.
- Entitlements, usage descriptions, and privacy manifest.
- Real-Mac test capability.

Direct assistive Accessibility control and App Sandbox configuration must be treated as an architecture decision. Do not assume sandboxed and non-sandboxed builds are interchangeable. Verify the current Apple documentation and actual built-app entitlements.

### 8.2 Speech probe

On the target Mac, verify:

- Selected locale.
- Microphone permission.
- Speech permission.
- On-device recognition support.
- Behavior when local recognition is unavailable.
- Partial revision quality.
- Finalization after key release.
- Cancellation during recognition.
- Delayed or missing final callbacks.
- Sleep, interruption, and permission withdrawal.

### 8.3 Hotkey probe

Select and verify a global push-to-talk mechanism. Test:

- Press and release.
- Lost key-up.
- Repeated keydown.
- Key conflicts.
- App switching.
- Secure input.
- Sleep and lock.
- Permission denial.
- The app's own event handling.

Do not claim that a generic global event monitor can suppress arbitrary events. Choose a mechanism whose behavior is proven for the target product.

### 8.4 Floating panel probe

Verify the native SwiftUI/AppKit panel for:

- Passive transcript display.
- Confirmation interaction.
- Keyboard focus.
- Focus restoration to the controlled fixture.
- Spaces and full-screen behavior.
- Stop availability.
- Panel dismissal without losing the session state.

A nonactivating panel can still affect keyboard focus. Test this directly.

### 8.5 Safari fixture probe

Use a local, versioned fixture with:

- Fixed route and known identity.
- Reviewed accessible elements.
- No redirects, external links, custom schemes, downloads, pop-ups, or login state.
- Deterministic expected states.
- A fixture version included in every acceptance record.

Verify actual Safari Accessibility attributes, supported actions, invalid-element behavior, timeout behavior, focus behavior, and process/window identity. Do not infer behavior from a browser mock.

### 8.6 Notes probe for the second slice

Before Notes work, verify:

- Exact available scripting dictionary or Accessibility path.
- Explicit local account or folder.
- No unintended synchronization.
- Creation identity.
- Exact content verification.
- Duplicate title behavior.
- Unavailable account behavior.

Defer Notes if any of these are not reliable.

---

## 9. UX and `/application-ui-ux` process

### 9.1 Authorized design target

The Dev Life repository or an explicitly authorized isolated design artifact is the target. The current YouTube workspace is not the product target.

Before high fidelity, record:

- Target path.
- Platform and runtime.
- Primary user and job.
- Workflow start and finish.
- Permissions and consequences.
- Recovery paths.
- Evidence gaps.
- Risk tier and authorization posture.
- Current decision.
- Next gate and decision owner.
- `MagicPath: use` or `MagicPath: skip` with a reason.

### 9.2 Required low-fidelity states

The design must distinguish:

- Microphone off.
- Armed.
- Listening.
- Transcribing partial speech.
- Finalizing speech.
- Selecting.
- Considering an action.
- Confirming.
- Executing.
- Verifying.
- Completed.
- Blocked.
- Stopped.
- Error.
- Outcome unknown.
- Permission required.
- Jev unavailable.

The interface must show:

- Exact transcript phase.
- Current goal.
- Exact capability under consideration.
- Target application and fixture.
- Whether the operation is pre-authorized, awaiting approval, blocked, or uncertain.
- Local Stop at every active phase.
- The reason for failure or refusal.

Do not use a large chat surface as the primary UI. This is an action controller.

### 9.3 Pattern and native validation gates

Before high-fidelity flows:

1. Run focused Mobbin flow and screen searches for command bars, push-to-talk, live transcription, confirmation, blocked, error, and recovery states when the connector is available.
2. Inspect returned references, record adopted and rejected mechanics, and verify freshness.
3. If Mobbin is unavailable, continue tool-neutral workflow discovery but leave dependent high-fidelity decisions open.
4. Define the native SwiftUI/AppKit adapter, focus strategy, Accessibility tools, permission model, and real-Mac validation method.
5. Use MagicPath only for exploratory layout work if it accelerates a real decision. Do not treat its output as the implementation source of truth.
6. Validate comprehension with Daniel: listening, acting, awaiting approval, stopped, blocked, and outcome unknown.
7. Run scoped accessibility checks: keyboard operation, VoiceOver labels and announcements, focus order, contrast, non-color status communication, and reduced motion.

A browser prototype cannot establish SwiftUI behavior. Mobbin evidence cannot establish native focus behavior.

---

## 10. Revised implementation sequence

Do not create the entire proposed directory tree before the target repository is inspected. Map these logical boundaries into existing Dev Life conventions.

### Task 0: Orient the authorized Dev Life target

**Objective:** Establish the real repository, toolchain, signing boundary, test capability, and UI target.

**Inspect:**

- Repository root.
- `AGENTS.md`, `README.md`, and project instructions.
- `.xcodeproj`, `Package.swift`, or existing build system.
- Existing SwiftUI/AppKit patterns.
- CI and test commands.
- Signing and entitlements.

**Gate:** Record the target path, runtime, architecture, sandbox posture, permissions, and exact validation commands. If the target is unavailable, stop product implementation and keep work tool-neutral.

### Task 1: Freeze the corrected product and safety contract

**Objective:** Make capabilities, effects, payload provenance, confirmation, failure, and experiment rules explicit before live Mac control.

**Expected artifacts after orientation:**

- `Design/PRODUCT_AND_SAFETY_CONTRACT.md`
- `Docs/CAPABILITY_REGISTRY.md`
- `Docs/EXPERIMENT_PROTOCOL.md`
- `Docs/DATA_EGRESS.md`

**Verification:** A reviewer can determine exactly which operation is allowed, against which target, with which payload, at which transcript phase, under which confirmation, and how it will be verified.

### Task 2: Run target-Mac feasibility probes

**Objective:** Replace platform assumptions with observed evidence before high-fidelity UI or live automation.

**Probe artifacts:**

- `Docs/PLATFORM_PROBES.md`
- Small isolated probe target or existing project test target, according to Dev Life conventions.

**Required probes:** speech finalization and cancellation, on-device mode, hotkey lifecycle, panel focus, Safari Accessibility target identity, native fixture action, and exact verification.

**Gate:** Every required platform dependency is `Observed` or explicitly deferred. A mock result does not close a native feasibility gate.

### Task 3: Run `/application-ui-ux` discovery and low-fidelity design

**Objective:** Design the trustworthy state and recovery workflow before high-fidelity SwiftUI implementation.

**Expected artifacts:**

- `Design/APPLICATION_UI_UX_BRIEF.md`
- `Design/UX_ACCEPTANCE_CHECKLIST.md`
- A low-fidelity state walkthrough or equivalent tool-neutral artifact.

**Gate:** The design answers how the user knows what was heard, what exact capability is authorized, whether the result was verified, how to stop, and what may have happened after uncertainty.

### Task 4: Build domain, capability, and state tests first

**Objective:** Make the corrected safety contract executable without a real Mac or live Jev request.

**Logical boundaries:**

- Domain capability models.
- Target bindings.
- Transcript revisions.
- Capture and action states.
- Confirmation identity.
- Event schema.
- Policy reason codes.

**Tests first:**

- Capability IDs are unique and exact.
- No generic selectors or executable strings enter candidates.
- Unsupported effects cannot be represented.
- `stop` and `ask_user` remain available when applicable.
- Target bindings expire and invalidate correctly.
- Payload provenance is preserved.
- Outcome unknown is distinct from failed.
- One goal and one dispatch are enforced.

### Task 5: Build the fake orchestrator and concurrency tests

**Objective:** Prove cancellation, supersession, stale-result rejection, budgets, and confirmation invalidation with fake adapters.

**Required cases:**

- A cancelled Jev request returns late.
- An old transcript revision returns after a new revision.
- An observation changes before dispatch.
- A target process or window changes.
- Stop arrives during capture, selection, confirmation, execution, and verification.
- A new utterance arrives while a goal is busy.
- A verification timeout creates outcome unknown.
- A crash or restart discards the goal.
- A budget is exhausted.

**Gate:** No live native action or TypeSafe request is needed to pass this task.

### Task 6: Build the minimal native shell

**Objective:** Provide a menu-bar item and floating command bar driven only by fake session state.

**Required behavior:**

- Off, armed, listening, finalizing, selecting, confirming, executing, verifying, stopped, blocked, error, and outcome unknown states render distinctly.
- Stop is visible during all active phases.
- Launching the app does not request every permission.
- The shell does not dispatch computer actions.

**Verification:** Build, launch, show and hide the panel, keyboard navigate it, test focus restoration, and run scoped accessibility checks.

### Task 7: Add the speech adapter boundary

**Objective:** Produce partial and final transcript revisions with separate finalize and cancel paths.

**Logical protocol:**

```swift
protocol SpeechTranscriber {
    func start() async throws -> AsyncThrowingStream<TranscriptEvent, Error>
    func finishCapture() async throws -> FinalTranscript
    func cancel()
}
```

Use the selected Apple or approved provider adapter only after the speech probe closes the data-egress and locale decision. Keep a fake adapter for deterministic tests.

**Verification:** Test partial revisions, finalization after release, cancellation, delayed callbacks, permission denial, interruption, and stale callback rejection.

### Task 8: Implement the trusted fixture observer and capability adapter

**Objective:** Observe only the approved Safari fixture and create exact candidate operations from trusted local definitions.

**Required behavior:**

- Confirm process, window, fixture, and element identity.
- Omit sensitive values by default.
- Mark incomplete observations explicitly.
- Never derive a capability from arbitrary page labels.
- Recheck target and preconditions immediately before dispatch.
- Return operation-specific native status.

**Verification:** Real-Mac tests cover changed window, duplicate labels, invalid elements, app closure, relaunch, focus changes, and missing Accessibility permission.

### Task 9: Implement the TypeSafe adapter after contract clearance

**Objective:** Convert one current Choice response into a validated internal capability selection.

**Before coding:** Re-read the current TypeSafe API, state, Choice, models, confidence, limitations, legal, and data-handling documentation. Identify the applicable account agreement and whether direct client calls are allowed for this private prototype.

**Implementation rules:**

- Use the current documented endpoint and request shape, not an old copied schema.
- Use a documented pinned model version for evaluated runs when available. Record returned model identity.
- Keep the Jev question narrow: which currently eligible capability best advances this goal?
- Include a no-match or control outcome where appropriate.
- Validate answer type and key.
- Validate choice membership against the exact request candidate set.
- Validate probability keys, finite values, ranges, and documented consistency.
- Validate confidence type and range without inventing a confidence formula.
- Validate response size, deadline, request identity, transcript revision, observation revision, and policy version.
- Redact secrets and raw bodies.
- Do not use Jev response to decide whether a capability is permitted.

**Failure behavior:** Invalid, stale, cancelled, unauthorized, rate-limited, overloaded, or timed-out requests end the goal. A later user retry starts fresh.

### Task 10: Connect real Jev selection to the fixture loop

**Objective:** Prove that a real Jev choice causes a verified native fixture action while policy and capability boundaries remain local.

**Flow:**

1. Start a new goal.
2. Press and hold push-to-talk.
3. Receive partial revisions.
4. Build only eligible fixture candidates.
5. Allow the preparatory exception only if the deterministic gate passes.
6. Request Jev selection with current candidate identity.
7. Revalidate all bindings.
8. Dispatch exactly one trusted fixture operation.
9. Observe the exact fixture postcondition.
10. Continue, stop, complete, or report uncertainty.
11. Finalize or cancel capture through the distinct speech path.

**Verification:** Run partial-mode, final-only, and deterministic-baseline trials with held-out commands and varied states.

### Task 11: Add allowlisted instrumentation and evidence capture

**Objective:** Record enough evidence to audit the experiment without capturing private application state.

**Record:**

- IDs, capability, policy code, model identity, timestamps, durations, result codes, verification, stop, and uncertainty.
- Fixture version, app build, OS, toolchain, permission configuration, and policy version.
- Failed, abandoned, and successful attempts.

**Do not record:** raw audio, raw transcripts by default, screenshots, URLs with query data, AX values, documents, clipboard, credentials, or raw HTTP bodies.

### Task 12: Run the first-slice acceptance gate

**Objective:** Decide whether the first slice proves enough to earn a Notes extension.

The gate is defined in Section 12. Do not add Notes because the happy path works once.

### Task 13: Add the confirmed local Notes slice only if earned

**Objective:** Add one exact-payload, local Notes operation without introducing generic typing or clipboard transfer.

**Prerequisites:**

- Safari slice passes.
- Notes adapter and storage location are observed and documented.
- Exact payload provenance is defined.
- Confirmation binding and verifier are implemented.
- Local account/folder is explicitly approved.

**Verification:** Exact note identity, destination, title, content, duplicate handling, unavailable account, partial creation, timeout, and outcome unknown.

### Task 14: Document private dogfooding and publication boundaries

**Objective:** Produce a reproducible local prototype record without claiming production readiness.

**Documents:**

- `README.md`
- `Docs/SECURITY.md`
- `Docs/PERMISSIONS.md`
- `Docs/ACTION_POLICY.md`
- `Docs/TEST_MATRIX.md`
- `Docs/LATENCY_INSTRUMENTATION.md`
- `Docs/PUBLICATION_CLEARANCE.md`

Record exact build and test commands from the target repository. Do not include credentials or unsupported claims.

---

## 11. TypeSafe contract and live-source gates

Recheck these pages at implementation time because API, model, legal, and preview details can change:

- API: https://docs.typesafe.ai/api.md
- State: https://docs.typesafe.ai/concepts/state.md
- Choice: https://docs.typesafe.ai/primitives/choice.md
- Confidence: https://docs.typesafe.ai/confidence.md
- Models: https://docs.typesafe.ai/models.md
- Jev limitations: https://docs.typesafe.ai/model-jaggedness/jev-1.13.md
- Function calling: https://docs.typesafe.ai/cookbooks/function_calling.md
- Guardrails: https://docs.typesafe.ai/cookbooks/llm_guardrails.md
- Legal index: https://docs.typesafe.ai/legal.md
- Applicable agreement: https://typesafe.ai/legal/mca or the agreement governing the account
- Privacy policy: https://typesafe.ai/legal/privacy-policy
- Data processing: https://typesafe.ai/legal/data-processing

Do not treat a current page's existence as proof that it governs Daniel's account. Record the applicable agreement, direct-client conditions, data handling, publication restrictions, and written exceptions before live calls or public claims.

---

## 12. Acceptance gates and test matrix

### Gate 0: orientation complete

Pass only when the target repository, toolchain, signing, sandbox, permissions, speech mode, hotkey path, test capability, and applicable TypeSafe agreement are recorded.

### Gate 1: native feasibility complete

Pass only when speech finalization, hotkey lifecycle, panel focus, Safari Accessibility, native fixture action, and exact verification have been observed on the target Mac.

### Gate 2: fake safety loop complete

Pass only when domain, policy, concurrency, stale-target, cancellation, confirmation, budget, and redaction tests pass without network or Accessibility permission.

### Gate 3: live Safari fixture complete

Pass only when all are true:

- A real Jev response selects among actual eligible fixture capabilities.
- Held-out commands and varied starting states are included.
- Partial, final-only, and deterministic-baseline modes are compared.
- No unsupported capability can be represented or dispatched.
- No forbidden dispatch occurs in the defined test set.
- Stop prevents later dispatch in every supported phase.
- Late, stale, malformed, or failed responses cannot act.
- Uncertain outcomes are reported and never replayed.
- Privacy canaries do not leave the approved payload or log boundary.
- Actual visible effect is compared with actual speech end.
- The one-second metric, if measured, includes predefined sample and failure rules.
- Evidence is retained for every attempt, not only successes.

Five clean runs are a smoke test only. A later pilot may use at least 30 paired controlled trials if internal measurement is permitted. Neither is a general reliability benchmark.

### Gate 4: Notes extension complete

Pass only when the exact local account/folder, payload provenance, confirmation binding, native adapter, and note verifier are observed and tested. If any prerequisite is uncertain, keep Notes out of the prototype.

### Required test families

| Test family | Required cases | Passing evidence |
|---|---|---|
| Partial intent | Late negation, correction, quoted instruction, conditional instruction, ASR revision | Only the pre-authorized fixture preparation can occur; contradictory continuation cannot authorize more work |
| Speech finalization | Quick release, trailing words, silence, delayed final, missing final, rapid repress | Finalization and cancellation are distinct; no partial becomes mutation authorization |
| Capability boundary | Generic click/type/URL attempts, unsupported effects, page labels | No generic escape hatch exists; unsupported effects cannot dispatch |
| Jev contribution | Paraphrases, state changes, already-complete, no-match, wait, ask | Real selection is visible in trace; baselines remain distinct |
| Response validation | Unknown ID, wrong type, wrong key, malformed probabilities, invalid confidence, oversized body | No dispatch and specific failure code |
| Service failure | Timeout, disconnect, `401`, `422`, `429`, `529`, unexpected status | Goal ends without fallback, resume, or replay |
| Supersession | Out-of-order responses, cancellation followed by response, old response during new goal | Old response cannot act |
| Target freshness | Window swap, app relaunch, duplicate labels, replaced control, fixture version change | Exact-target mismatch blocks execution |
| Focus | Panel interaction, app switch, focus change before dispatch | No action reaches unintended target |
| Permissions | Deny and revoke microphone, Speech, Accessibility, Automation | Safe stop, useful recovery, no false success |
| Stop | Capture, selection, confirmation, execution, verification, blocked native call | Future dispatch is inhibited; already-issued effect is disclosed |
| Hotkey | Lost release, repeated keydown, conflicts, secure input, sleep, lock | No indefinite recording or hidden execution |
| Injection | Hostile fixture text, labels, fake approval, copied instructions | Content cannot expand capability or supply approval |
| Navigation containment | Redirect, custom scheme, download, pop-up, changed fixture | Outside fixture contract is blocked |
| Duplicate effects | Callback duplication, timeout after dispatch, verification failure, crash | No automatic replay; uncertainty remains explicit |
| Confirmation | Expiry, changed payload, changed target, previous-goal approval, double approval | At most one exact authorized dispatch |
| Privacy | Synthetic secret canaries in transcript, title, AX fields, errors | Prohibited data absent from outbound state and ordinary logs |
| Budgets | Repeated wait, cyclic fixture navigation, excessive partials | Action, evaluation, wall-clock, and payload limits end the goal |
| Notes extension | Wrong account, unavailable folder, duplicate title, partial creation | Exact local destination and result are verified |

---

## 13. Evidence and video boundaries

### 13.1 Required proof artifacts

For the first slice, capture:

1. App off and armed.
2. Push-to-talk and partial transcript.
3. The exact capability Jev selected.
4. The controlled Safari fixture changing.
5. Exact verification state.
6. A stop during an active phase.
7. A blocked or ambiguous request.
8. A service failure or permission denial if part of the claim.
9. Timeline instrumentation without secrets or restricted raw outputs.
10. A continuous recording for any claim that an effect began before speech ended.

### 13.2 Defensible claims

Only after the relevant gates pass, the video may describe:

- A private native prototype.
- A controlled fixture.
- A bounded capability registry.
- Jev selecting among supplied operations.
- Code and the user retaining control of consequential effects.
- A measured behavior under named conditions.

Do not claim:

- General autonomous Mac control.
- Arbitrary navigation is safe.
- Jev provides the security guarantee.
- All processing is local merely because audio is not sent to Jev.
- One-second end-to-end response from a post-transcription timer.
- Guaranteed interruption or exactly-once execution.
- Better performance than another system without a controlled comparison.
- Generated content when no content-generation source exists.
- Publication of benchmarks, raw outputs, or performance information without applicable agreement clearance.

If the partial-speech effect is not reliable or produces unnecessary actions, remove it from the opening and describe the limitation honestly.

---

## 14. Risks, tradeoffs, and open facts

### Accepted tradeoffs

- A controlled fixture is less visually impressive than arbitrary Mac control, but produces stronger safety and attribution evidence.
- Removing generic actions reduces apparent flexibility, but prevents indirect forbidden effects.
- Delaying Notes reduces the immediate owner-operator usefulness, but avoids confusing the core Jev experiment with an app-specific integration.
- A fresh-goal retry is slower than automatic retry, but avoids replaying an uncertain side effect.
- Non-sandboxed private development may be required for direct assistive Accessibility control, but the actual signing and entitlement choice must be verified rather than assumed.

### Facts that Dev Life must resolve

1. Repository path and project conventions.
2. Swift, Xcode, and macOS versions.
3. Apple Silicon and Intel requirements.
4. Signing identity, entitlements, sandbox posture, and usage descriptions.
5. Feasible global hotkey mechanism.
6. Speech locale and on-device recognition support.
7. Speech data egress and consent mode.
8. Safari Accessibility attributes and reliable native operation.
9. Floating panel focus and Spaces behavior.
10. Applicable TypeSafe agreement, direct-client conditions, account access, and publication restrictions.
11. Mobbin and native UX research access.
12. For Notes, the exact local storage location, adapter, payload, and verifier.

These are factual gates, not invitations to silently guess.

---

## 15. Handoff checklist

- [ ] Keep the original broad plan as the audit baseline.
- [ ] Use this v2 plan as the implementation handoff.
- [ ] Identify the authorized Dev Life repository.
- [ ] Inspect repository instructions and existing SwiftUI/AppKit conventions.
- [ ] Record target Mac, OS, Swift, Xcode, signing, entitlements, and sandbox.
- [ ] Verify the applicable TypeSafe agreement and live API/model documentation.
- [ ] Choose and document speech data mode.
- [ ] Run speech, hotkey, panel, and Safari Accessibility probes.
- [ ] Run `/application-ui-ux` discovery and low-fidelity state design.
- [ ] Record `MagicPath: use` or `MagicPath: skip` before high fidelity.
- [ ] Define the trusted capability registry.
- [ ] Remove generic click, type, URL, clipboard, Notes, and uncontrolled browser operations from the first slice.
- [ ] Build fake domain and concurrency tests before live calls.
- [ ] Implement finish-capture and abort-session separately.
- [ ] Implement dispatch-time target and revision checks.
- [ ] Implement outcome-unknown handling with no automatic replay.
- [ ] Integrate live Jev only after API and agreement gates pass.
- [ ] Run the controlled Safari fixture experiment with paired baselines.
- [ ] Decide whether the evidence earns the Notes extension.
- [ ] Clear any video or publication claim separately.

**Implementation gate:** Do not begin broad SwiftUI or Mac automation implementation until Gate 0 and the relevant parts of Gate 1 are closed. Do not add Notes until Gate 3 passes.
