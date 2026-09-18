# Meet Jev, Fastest Computer Use

A private macOS menu-bar prototype for testing bounded computer-use control with explicit local authority, cancellation, and verification.

## Current Status

The repository now follows the corrected v0.1 Safari-fixture-first handoff in `context/specs/00-build-plan.md`. It contains the product and safety contract, exact capability registry, egress boundary, experiment protocol, platform probe checklist, UX states, action policy, and test matrix.

No Swift source, Xcode target, live Jev adapter, native build, or real-Mac acceptance evidence is claimed yet. The current development host is Ubuntu 24.04 under WSL2 and lacks `swift` and `xcodebuild`.

The target Mac is reachable through Tailscale and Remote Login is enabled. SSH authentication remains pending because the key command was run on WSL rather than on the Mac. See `Docs/PLATFORM_PROBES.md`.

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
- `context/`: project, architecture, UI, code, workflow, progress truth, and build handoff.
- `context/specs/00-build-plan.md`: corrected v2 implementation handoff.
- `context/specs/00-build-plan-v1-summary.md`: prior foundation summary retained for audit context.
- `docs/guides/diagnostic-runbook.md`: first-failure checks and safe recovery boundaries.

## Next Gate

Install the generated SSH public key on the target Mac itself, authenticate over Tailscale, run the platform probes, then record the real toolchain, signing, sandbox, speech, hotkey, panel, Safari Accessibility, native action, and verifier evidence. Do not treat this README as evidence that the app builds or that Jev has been called.
