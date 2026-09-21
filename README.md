# Meet Jev, Fastest Computer Use

A private macOS menu-bar prototype for testing bounded computer-use control with explicit local authority, cancellation, and verification.

## Current Status

The repository follows the corrected v0.1 Safari-fixture-first handoff in `context/specs/00-build-plan.md`. It contains the product and safety contract, exact capability registry, egress boundary, experiment protocol, platform probe checklist, UX states, action policy, test matrix, and a SwiftPM core plus shell.

The pure Swift safety core and local Safari-fixture loop are implemented. The minimal SwiftUI menu-bar shell launches a visible AppKit command panel and retains the menu-bar item in a stable ad-hoc signed app bundle. The shell contains on-device push-to-talk Speech/AVFoundation capture, a live Jev selector adapter that sends only a minimized closed-capability request, and bounded execution for the two reversible Safari-fixture transitions. The former TextEdit workspace expansion is deferred until its descriptor-bound file handoff is independently verified. The shell also exposes an explicit experimental desktop-mode surface with task, stop/reset, status, and activity-history affordances. Its Hermes send action remains disabled until the controller bridge exists. The live selector remains default-off until a TypeSafe key is entered through the Mac UI and explicitly enabled.

The target Mac is reachable through Tailscale and SSH is verified. Full Xcode 26.6 is installed and usable through `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. The WSL host remains unable to build Swift natively.

## First Workflow

> Push to talk, choose a reviewed state in the local Safari fixture, perform one registered fixture operation, and verify the exact postcondition.

Only synthetic, local, reversible fixture data is allowed. Notes and generic Mac control are deferred.

## Safety Boundaries

- Push-to-talk only. No always-on listening.
- No arbitrary shell, AppleScript, coordinate clicking, generic typing, arbitrary URLs, clipboard transfer, screenshots, vision, external websites, or uncontrolled navigation.
- The bounded computer-use executor is limited to the versioned Safari fixture's two fixed reversible controls. The TextEdit workspace expansion is deferred and does not dispatch input. The executor does not enable generic desktop control.
- Experimental desktop mode is retained only as a visibly deferred UI state. It cannot submit Hermes tasks or change the native capability registry in this checkpoint.
- Jev may select only an exact locally constructed capability ID.
- No automatic sending, deleting, purchasing, publishing, sharing, account changes, or privacy-sensitive actions.
- Stop is local, idempotent, and always available.
- Unknown native effects become `outcome_unknown` and are never replayed automatically.
- Credentials belong in macOS Keychain, never in source, fixtures, logs, screenshots, or chat.

## Jev Access Gate

The live selector is implemented and conditionally approved for the current bounded private prototype. Daniel confirmed the applicable account, DOO MADE approval, direct-client posture, refill setting, and retention conditions. The app still requires explicit Mac-side enablement and a Keychain credential before any provider request can occur; broader data and production use remain outside this approval.

Credentials must be entered through the SecureField in **Jev Command Panel → Settings… → TypeSafe credential** and stored only in the Mac Keychain. Do not paste passwords, API keys, or tokens into chat or commit them. See `Docs/LIVE_JEV.md` and `Docs/DATA_EGRESS.md`.

## Repository Map

- `Design/`: UI/UX brief and acceptance checklist.
- `Docs/`: product contract, capability registry, policy, egress, probes, tests, experiments, and publication clearance.
- `Sources/JevCore/`: pure capability, policy, state, transcript, selection, and authority logic.
- `Sources/JevMacShell/`: SwiftUI menu-bar shell, visible command panel, bounded speech/fixture adapters, the default-off CuaDriver fixture executor, deferred workspace boundary, Keychain storage, and live Jev selection transport.
- `Tests/JevCoreTests/`: deterministic safety and lifecycle tests.
- `context/`: project, architecture, UI, code, workflow, progress truth, and build handoff.
- `context/specs/00-build-plan.md`: corrected v2 implementation handoff.
- `context/specs/00-build-plan-v1-summary.md`: prior foundation summary retained for audit context.
- `docs/guides/diagnostic-runbook.md`: first-failure checks and safe recovery boundaries.

## Next Gate

The bounded Accessibility expansion currently retains only the two reversible Safari fixture transitions. The TextEdit workspace route is explicitly deferred, and the experimental desktop UI is rendered fail-closed. The Hermes controller bridge remains a separate implementation gate because the authenticated Hermes API endpoint is not configured for JevMacShell. The live selector remains an independent account, privacy, egress, and cost gate. Any further Accessibility expansion must add a new capability, exact target contract, race-resistant handoff, policy test, and independent verifier before implementation. See `Docs/COMPUTER_USE.md`.
