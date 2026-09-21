# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Authenticated Tailscale SSH to the target Mac is complete.
- Full Xcode is installed and usable through `DEVELOPER_DIR`.
- The prior target-Mac baseline after the reversible Safari Accessibility slice was 92 tests and 0 failures; the latest Swift changes still require secure target-Mac validation.
- The fixture-backed TypeSafe Choice client now has provider-shaped request/response models and six focused target-Mac tests; no live provider request or credential was used.
- The target-Mac CuaDriver permissions and Hermes command preflight both return ready; no arbitrary task result has been independently verified after the earlier unknown outcome.
- The local Safari fixture loop is complete; the live Jev selector is implemented and compile-verified on the target Mac.
- The experimental desktop-mode UI is retained as a visibly deferred, fail-closed surface; no Hermes task submission or arbitrary desktop route is reachable in the current checkpoint.
- The former fast Notes and current-cursor routes are intentionally deferred until exact target binding and independent postcondition verification exist.
- The panel lifecycle fix keeps the visible NSPanel available through the Accessibility tree after the app deactivates; target-Mac bounded and experimental states were read back successfully.
- The current bounded Accessibility scope retains the Safari fixture's reviewed and landing transitions. The TextEdit workspace expansion is deferred until descriptor-bound file handoff and exact document identity are independently verified.

## Current Goal

- Expand Accessibility only through separately bounded targets, exact postconditions, and independent readback while keeping generic desktop control closed.

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
- A prior deployed build exercised the bounded Mac Workspace Typing Test, but the route is now deferred after review found unresolved ancestor and file-handoff race conditions. No workspace action is part of the current bounded scope.
- Added the reversible `return_to_landing_fixture_view` capability with exact Safari target binding, state-dependent fixed-label CuaDriver/native execution, bounded FastSubtask observation, and independent landing-state verification. The target-Mac full suite passed with 92 tests and 0 failures.
- Deployed the clean release bundle after removing the temporary landing probe. Re-approved the ad-hoc bundle's Accessibility permission, reloaded the synthetic fixture after detecting stale pre-change DOM, and verified the live bounded CuaDriver transition from reviewed to landing with exact readback. Live Jev remained enabled, the bounded executor remained enabled, experimental desktop mode remained disabled, and no additional provider request occurred.
- Revalidated the official TypeSafe System One request and Choice response contract, then added the network-free `TypeSafeChoiceClient` with explicit status, timeout, cancellation, malformed-response, closed-choice, probability, and payload-limit handling.
- The SSH TypeSafe smoke harness was invalidated: the target Mac's Keychain item exists, but `security -w` under the SSH-executed shell returns exit 36 with an empty value. The harness had not checked that failure and could send an empty Bearer value, so its 403 results are not account evidence. The hardened harness now fails closed before curl.
- With separate approval, a temporary GUI app invoked the existing `LiveJevSelectionAdapter` through the native Keychain and URLSession path using the bounded Safari fixture. It received `select_reviewed_fixture_view`, dispatched no capability, mutated no Safari state, and confirmed the probe-time flag was `0`. The temporary probe bundle and probe mode were removed afterward. The target Mac's Release bundle was then deployed, code-signature verified, relaunched, and explicitly configured with `jev.liveSelection.enabled=1`; no live decision was triggered during deployment. The deployed bundle was subsequently approved in macOS Accessibility settings, and the bounded Safari route was verified without another provider request. The workspace route is now deferred.

## In Progress

- Keep the experimental voice/send controls fail-closed until the complete Hermes and CuaDriver preflight returns `ready`.
- Preserve the transport evidence: Tailscale SSH identity, one active run, stop propagation, exit-status diagnostics, and uncertain outcomes become `outcome_unknown` without replay.
- The native fixture gate is closed with one Daniel-approved harmless task and a visible verified postcondition; no task was replayed automatically after the false-success reports.
- The Accessibility expansion gate is closed only for the two bounded Safari fixture transitions. The app-owned TextEdit workspace probe remains deferred pending race-resistant file handoff and independent document verification.
- Keep the fast Notes/current-cursor routes deferred until exact target binding and independent postcondition verification are implemented.
- Keep live dynamic Jev policy, OCR, Chrome DOM/CDP, and generic CuaDriver integration deferred. Gate 2 is conditionally approved for the current bounded private prototype after Daniel confirmed the DOO MADE approval, company TypeSafe contract/Order, direct API, manual funding, automatic-refill setting, and retention/data-processing conditions. Broader data egress and production use remain outside the gate.

## Next Up

1. The Safari-only Gate 2 and bounded Accessibility checkpoint is staged and passed independent security review; commit only after target-Mac Swift validation is available or the validation gap is explicitly accepted.
2. Keep automatic refill off and the current bounded payload allowlist; review any broader field set separately before changing code.
3. Preserve the explicit boundary: live dynamic Jev, OCR, Chrome DOM/CDP, and generic CuaDriver execution remain deferred.

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
- Broader TypeSafe data scope, production authorization, and any future public-service use.
- Provider retention/deletion/operational logging for Daniel's account.
- Hermes controller transport: the app uses the authenticated Tailscale SSH identity and remote Hermes CLI; preflight now covers both the Hermes launcher and Mac CuaDriver before enabling send/voice controls.
- CuaDriver 0.28.2 reports Accessibility and Screen Recording readiness; unrestricted-mode operation remains unclaimed until the correct daemon launch path is independently verified.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
