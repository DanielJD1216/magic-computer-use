# Meet Jev, Fastest Computer Use

A private macOS menu-bar prototype for testing bounded computer-use control with explicit local authority, cancellation, and verification.

## Current Status

The repository follows the corrected v0.1 Safari-fixture-first handoff in `context/specs/00-build-plan.md`. It contains the product and safety contract, exact capability registry, egress boundary, experiment protocol, platform probe checklist, UX states, action policy, test matrix, and a SwiftPM core plus shell.

The pure Swift safety core is implemented and verified on the target Mac with 20 passing tests. The minimal SwiftUI menu-bar shell now launches a visible AppKit command panel and retains the menu-bar item in a stable ad-hoc signed app bundle. The prior bundle passed the first trusted Safari action and exact postcondition probe; that probe must be rerun after the final UI rebuild and Accessibility re-grant. Speech permissions/lifecycle, physical hotkey behavior, panel focus, and live Jev remain unverified or disabled.

The target Mac is reachable through Tailscale and SSH is verified. Full Xcode 26.6 is installed and usable through `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. The WSL host remains unable to build Swift natively.

## First Workflow

> Push to talk, choose a reviewed state in the local Safari fixture, perform one registered fixture operation, and verify the exact postcondition.

Only synthetic, local, reversible fixture data is allowed. Notes and generic Mac control are deferred.

## Safety Boundaries

- Push-to-talk only. No always-on listening.
- No arbitrary shell, AppleScript, coordinate clicking, generic typing, arbitrary URLs, clipboard transfer, screenshots, vision, external websites, or uncontrolled navigation.
- Jev may select only an exact locally constructed capability ID.
- No automatic sending, deleting, purchasing, publishing, sharing, account changes, or privacy-sensitive actions.
- Stop is local, idempotent, and always available.
- Unknown native effects become `outcome_unknown` and are never replayed automatically.
- Credentials belong in macOS Keychain, never in source, fixtures, logs, screenshots, or chat.

## Jev Access Gate

Live Jev remains disabled until the applicable TypeSafe/Jev agreement, private-use authorization, direct-client versus relay decision, provider retention review, and data-egress review are closed. Jev-side credentials are **not needed yet**.

When that gate is closed, credentials must be entered through the approved Mac/Keychain path. Do not paste passwords, API keys, or tokens into chat or commit them.

## Repository Map

- `Design/`: UI/UX brief and acceptance checklist.
- `Docs/`: product contract, capability registry, policy, egress, probes, tests, experiments, and publication clearance.
- `Sources/JevCore/`: pure capability, policy, state, transcript, selection, and authority logic.
- `Sources/JevMacShell/`: permission-free SwiftUI menu-bar shell.
- `Tests/JevCoreTests/`: deterministic safety and lifecycle tests.
- `context/`: project, architecture, UI, code, workflow, progress truth, and build handoff.
- `context/specs/00-build-plan.md`: corrected v2 implementation handoff.
- `context/specs/00-build-plan-v1-summary.md`: prior foundation summary retained for audit context.
- `docs/guides/diagnostic-runbook.md`: first-failure checks and safe recovery boundaries.

## Next Gate

Run native speech, hotkey, panel, Safari Accessibility, native action, and verifier probes using the verified Xcode toolchain. Do not treat passing core tests or a process-launch smoke test as evidence that the native app is fully verified or that Jev has been called.
