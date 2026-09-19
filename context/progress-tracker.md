# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Authenticated Tailscale SSH to the target Mac is complete.
- Full Xcode is installed and usable through `DEVELOPER_DIR`.
- The pure SwiftPM safety core and minimal shell compile successfully.
- The pure safety suite has 20 passing target-Mac tests.
- Accessibility trust is not yet granted to the final clean ad-hoc app bundle after the visible-panel rebuild; no developer signing identities are installed.
- Native runtime feasibility gates remain open.

## Current Goal

Run native speech, hotkey, panel, and local Safari fixture probes without enabling live Jev, then complete the fake orchestrator and fixture adapter loop.

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
- Verified the final clean bundle creates an on-screen command panel; the final Accessibility grant must be re-established because the rebuild changed the ad-hoc code hash.
- Verified `swift test --disable-sandbox`: 20 tests, 0 failures.
- Cloned and synced the repository to the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Probed Speech for `en-CA`: available and on-device recognition supported.
- No Jev credential has been requested or used.

## In Progress

- Native speech lifecycle, hotkey, panel focus, and Safari fixture probes.
- Fake orchestrator, response transport parsing, redaction, and budget tests.

## Next Up

1. Remove any old Jev shell entry from Accessibility and re-add the final clean `~/Applications/JevMacShell-Prototype.app` with its toggle enabled; do not rebuild afterward.
2. Rerun the final-bundle GUI trust check and Safari Accessibility/native action verifier.
3. Complete real speech permission/lifecycle, physical hotkey press/release, and floating-panel focus/restoration probes.
4. Run the fixture acceptance matrix and egress canaries.
5. Resolve Jev/TypeSafe private-use authorization, direct client versus relay, provider retention, and credential-entry path before live transport.

## Architecture Decisions

- First slice is one preflighted local Safari fixture, not Notes or generic Mac control.
- Jev selects exact locally generated capability IDs only.
- Observation is internal and is not a selectable action.
- Capture and action state are separate dimensions.
- Key release finalizes speech; explicit Stop aborts and invalidates authority.
- Final speech is required for the first Safari operation unless a reviewed harmless partial exception is separately implemented.
- Every callback validates session and action-attempt identity.
- Unknown native effect becomes `outcome_unknown`; no automatic replay.
- Fixture adapter is the default. Live Jev remains disabled until authority and privacy gates close.
- Credentials are entered only through the approved Mac/Keychain path and never through chat.

## Open Questions

- Native app bundle format, bundle ID, signing team, entitlements, and sandbox posture.
- Speech permission and actual on-device lifecycle behavior in the user session.
- Global hotkey and utility panel behavior on the target OS.
- Safari fixture hosting, accessibility identity, native action path, and verifier.
- Applicable TypeSafe/Jev agreement and whether this private client architecture is authorized.
- Direct client versus relay and provider retention/deletion/operational logging.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
