# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Authenticated Tailscale SSH to the target Mac is complete.
- Full Xcode is installed and usable through `DEVELOPER_DIR`.
- The pure Swift safety suite and integrated bounded fixture checks pass on the target Mac with 81 tests and 0 failures after the fast subtask runtime slices.
- The target-Mac CuaDriver permissions and Hermes command preflight both return ready; no arbitrary task result has been independently verified after the earlier unknown outcome.
- The local Safari fixture loop is complete; the live Jev selector is implemented and compile-verified on the target Mac.
- The experimental desktop-mode UI is implemented and deployed as a separate, fail-closed surface; the live SSH-backed Hermes bridge and complete Hermes/CuaDriver preflight are green, while end-to-end task verification remains open.
- The fast native route now handles explicit Notes launch and current-cursor text insertion without Hermes; generic desktop tasks remain on the slower Hermes fallback.
- The panel lifecycle fix keeps the visible NSPanel available through the Accessibility tree after the app deactivates; target-Mac bounded and experimental states were read back successfully.

## Current Goal

Close out the bounded native fixture route after one harmless, user-approved desktop task completes with a visible verified postcondition.

## Completed

- Confirmed the authorized repository: `/home/jinni_doo/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Read the updated v2 handoff and installed it as `context/specs/00-build-plan.md`.
- Retained the prior foundation summary as `context/specs/00-build-plan-v1-summary.md`.
- Added the product and safety contract, capability registry, experiment protocol, data-egress boundary, platform-probe checklist, and publication-clearance gate.
- Reconciled README, architecture, UI context, UX brief/checklist, action policy, permissions, security, code standards, workflow rules, test matrix, latency instrumentation, and diagnostic runbook to Safari-fixture-first scope.
- Confirmed WSL lacks `swift` and `xcodebuild`.
- Confirmed Tailscale reachability and authenticated SSH to the Mac.
- Recorded target Mac evidence: macOS `26.5.1` build `25F80`, `arm64`, Xcode `26.6`, SwiftPM `6.3.3`.
- Confirmed Xcode first-launch and license status pass under `DEVELOPER_DIR`.
- Chose Swift Package Manager for the pure core and shell because the repository had no existing app project or package.
- Added capability, policy, session-authority, transcript, and bounded-selection logic.
- Observed the intended red test failures, then made each TDD slice green on the target Mac.
- Built `JevMacShell` successfully and completed a temporary unsigned process-launch smoke test.
- Created the stable ad-hoc signed bundle at `~/Applications/JevMacShell-Prototype.app`; strict codesign verification passes.
- Added the deterministic fake Safari fixture adapter and exact verifier.
- Added bounded native speech, Carbon hotkey, and Safari Accessibility probe paths plus the versioned local Safari fixture.
- Added an AppKit command panel that is visibly created at launch while retaining the menu-bar status item.
- Verified the prior final bundle created an on-screen command panel and passed the GUI-session Accessibility trust check.
- Verified the prior trusted bundle's synthetic Safari identity, fixed native button action, and exact reviewed-state postcondition.
- Added the real on-device Speech/AVFoundation push-to-talk adapter with explicit permission sequencing, finalization timeout, cancellation, and stale-callback rejection.
- Verified `swift test --disable-sandbox`: 23 tests, 0 failures.
- Cloned and synced the repository to the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Probed Speech for `en-CA`: available and on-device recognition supported; latest non-prompting status remains not determined until Hold to Speak is pressed.
- No Jev credential has been requested or used.
- Added a fixed-endpoint, Keychain-backed live Jev selector with minimized allowlisted state and strict Choice-response validation.
- Added Mac UI controls for SecureField credential entry, Keychain storage, and explicit live-selection enablement.
- Compile-verified the live selector build on the target Mac with `swift build --product JevMacShell --disable-sandbox`.
- Added the `JevCore` Hermes controller contract, endpoint vocabulary, one-run lifecycle state machine, deterministic mock tests, and the SSH-backed Hermes/CuaDriver transport. Target-Mac `swift test --disable-sandbox` passes with 46 tests and 0 failures; no credential value was introduced.
- Deployed the release `JevMacShell-Prototype.app` with the experimental voice controls, readiness refresh action, `⌘⌥L` shortcut, stop propagation, and redacted outcome handling. The deployed executable matches the release build and the app was restarted without stopping Hermes.
- Diagnosed the reported no-op: the noninteractive WSL SSH environment omitted `/home/jinni_doo/.local/bin`, so the relay's bare `hermes` command exited 127 before Hermes started while Jev hid stderr.
- Updated the relay to invoke the absolute Hermes launcher, include its directory in the child PATH, and include Hermes availability in preflight. The red/green shell regression passes, the nested Mac → WSL → Mac preflight returns `hermes_status: ready`, and the new release is deployed.
- Diagnosed the second false-success path: the remote CuaDriver manifest advertised a macOS executable path that Hermes could not spawn from WSL. The Mac proxy now rewrites the MCP invocation to the local WSL proxy while preserving stdio forwarding to the Mac.
- Added a structured `stream-json` relay result contract. A clean Hermes exit without a successful mutating `computer_use` action now becomes `outcome_unknown`; Jev no longer presents process exit status `0` as a verified task completion.
- Added shell regressions for the proxy manifest, successful input-action evidence, and no-action false-success handling. All relay regressions pass; the target-Mac Swift suite passes with 46 tests and 0 failures.
- Rebuilt, ad-hoc signed, deployed, and restarted the release bundle. The deployed binary contains the action-result gate, strict codesign verification passes, and the live Hermes/CuaDriver backend handshake and teardown are green.
- Added the pure `FastDesktopTaskRouter` and target-Mac native `FastDesktopActionAdapter`. Explicit `open Notes` and `write/type [text] where my cursor is` requests bypass Hermes; incomplete cursor-writing transcripts stop for clarification instead of entering the slow fallback. Target-Mac tests now pass with 51 tests and 0 failures.
- Rebuilt, ad-hoc signed, deployed, and relaunched the release bundle with the fast route. The deployed binary contains the fast-intent strings, strict codesign verification passes, and the app process is running.
- Reproduced the `open notesapp` latency as a router miss: the unspaced phrase fell through to Hermes. Added spaced, plural, and unspaced Notes variants; target-Mac tests now pass with 52 tests and 0 failures, and the release was redeployed.
- Added the bounded `FastSubtaskExecutor` value models, operation-specific action spaces, trusted input-key validation, backend/verifier seams, and deterministic Safari fixture adapter.
- Added executor coverage for stale targets, no-change blocking, action budgets, cancellation, uncertain post-action observations, independent verification, and end-to-end fixture execution.
- Added a local `FastDesktopExecutionEvidence` projection and lifecycle checkpoints; the target-Mac suite now passes with 81 tests and 0 failures, with canary values excluded from serialized evidence.
- Wired the native `select_reviewed_fixture_view` capability through the bounded `FastSubtaskExecutor`, a Mac Safari observation/action adapter, independent readback verification, and cancellation propagation. The CuaDriver bounded route remains separate.
- Daniel verified the deployed UI path after restoring Accessibility permission and selecting Native Swift mode: the Safari fixture connected, the reviewed-view command completed, and the visible postcondition read `State: reviewed`.

## In Progress

- Keep the experimental voice/send controls fail-closed until the complete Hermes and CuaDriver preflight returns `ready`.
- Preserve the transport evidence: Tailscale SSH identity, one active run, stop propagation, exit-status diagnostics, and uncertain outcomes become `outcome_unknown` without replay.
- The native fixture gate is closed with one Daniel-approved harmless task and a visible verified postcondition; no task was replayed automatically after the false-success reports.
- Measure the fast route from speech release to CuaDriver confirmation; the read-only target CuaDriver call is currently 0.048 seconds, excluding speech capture.
- Keep live dynamic Jev policy, OCR, Chrome DOM/CDP, and generic CuaDriver integration deferred. They require separate authorization, egress, target, and verification gates and are not part of this fixture runtime proof.

## Next Up

1. Scope and record the bounded-route changes without staging unrelated worktree files.
2. Preserve the explicit boundary: live dynamic Jev, OCR, Chrome DOM/CDP, and generic CuaDriver execution remain deferred.
3. Keep generic desktop control, real-user data, and public claims out of scope.

## Architecture Decisions

- First slice is one preflighted local Safari fixture, not Notes or generic Mac control.
- Jev selects exact locally generated capability IDs only.
- Observation is internal and is not a selectable action.
- Capture and action state are separate dimensions.
- Key release finalizes speech; explicit Stop aborts and invalidates authority.
- Final speech is required for the first Safari operation unless a reviewed harmless partial exception is separately implemented.
- Every callback validates session and action-attempt identity.
- Unknown native effect becomes `outcome_unknown`; no automatic replay.
- Fixture execution remains the default native path. Live Jev is an explicit selector mode and never receives execution authority.
- Credentials are entered only through the approved Mac/Keychain path and never through chat.

## Open Questions

- Native app bundle format, bundle ID, signing team, entitlements, and sandbox posture.
- Speech permission and actual on-device lifecycle behavior in the user session.
- Global hotkey and utility panel behavior on the target OS.
- Safari fixture hosting, accessibility identity, native action path, and verifier.
- Account-specific TypeSafe authorization and direct-client conditions.
- Provider retention/deletion/operational logging for Daniel's account.
- Hermes controller transport: the app uses the authenticated Tailscale SSH identity and remote Hermes CLI; preflight now covers both the Hermes launcher and Mac CuaDriver before enabling send/voice controls.
- CuaDriver 0.28.2 reports Accessibility and Screen Recording readiness; unrestricted-mode operation remains unclaimed until the correct daemon launch path is independently verified.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
