# Project Overview

## Purpose

Meet Jev, Fastest Computer Use is a private macOS menu-bar prototype for testing bounded computer-use control with explicit local authority, cancellation, and verification. It is a proof system, not a generic assistant and not a production product.

## Corrected v0.1 Scope

The first vertical slice controls one preflighted, synthetic, local Safari fixture. It must use real speech revisions, deterministic eligibility, exact closed-set capabilities, Jev selection when authorized, native execution, exact verification, and fail-closed recovery.

The first slice includes only:

- Push-to-talk capture.
- Partial and final transcript revisions.
- A local eligibility gate.
- Jev selection from exact candidates, plus `wait`, `stop`, and `ask_user`.
- A preflighted Safari fixture operation.
- One trusted native dispatch path.
- An exact fixture postcondition verifier.
- Completed, blocked, stopped, failed, and `outcome_unknown` states.

Notes, arbitrary browser control, generic Mac automation, shell, AppleScript, clipboard, screenshots, vision, external websites, publishing, and public distribution are deferred.

## Current Status

The repository contains the v2 implementation handoff, safety artifacts, SwiftPM core, and 20 passing target-Mac pure tests. The minimal SwiftUI menu-bar shell now creates a visible AppKit command panel and retains the menu-bar item in a stable ad-hoc signed bundle. The target Mac previously observed the synthetic Safari identity, one trusted native fixture action, and exact postcondition verification; those Safari checks must be rerun after the final UI rebuild and Accessibility re-grant.

The development host is Ubuntu 24.04 under WSL2 and does not have a Swift toolchain. The target Mac is reachable through Tailscale and SSH is authenticated. Full Xcode 26.6 is available remotely through `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

## Safety Contract

- Push-to-talk only. No always-on listening.
- Candidate capabilities are locally defined and exact.
- Page content, Accessibility values, transcript text, and Jev responses are untrusted data.
- No generic click, type, URL, shell, AppleScript, or arbitrary Accessibility operation.
- Final speech is required for the first Safari operation unless a reviewed harmless preparation exception is explicitly implemented.
- Releasing the key finalizes capture; it does not cancel the session.
- Stop invalidates future authority and remains local.
- Unknown native outcome is not treated as success or failure that can be safely replayed.
- Credentials belong in Keychain, never in chat, source, fixtures, logs, or screenshots.

## Jev Gate

Live Jev transport remains disabled pending authoritative TypeSafe/Jev authorization, direct-client versus relay decision, provider retention review, data-egress review, and native target evidence. Jev-side credentials are not needed for repository orientation, fake adapters, or local policy tests.

## Repository Map

- `Design/`: UI/UX brief and acceptance checklist.
- `Docs/`: product contract, capability registry, privacy, platform probes, policy, tests, and publication gates.
- `Sources/JevCore/`: pure capability, policy, state, transcript, selection, and authority logic.
- `Sources/JevMacShell/`: permission-free SwiftUI menu-bar shell.
- `Tests/JevCoreTests/`: deterministic safety and lifecycle tests.
- `context/`: project, architecture, UI, code, workflow, progress truth, and build handoff.
- `context/specs/00-build-plan.md`: exact v2 implementation handoff.
- `context/specs/00-build-plan-v1-summary.md`: prior foundation summary retained for audit context.
- `docs/guides/diagnostic-runbook.md`: first-failure checks and safe recovery boundaries.

## Next Gate

Run target-Mac speech lifecycle, hotkey, panel, Safari Accessibility, native action, and verifier probes. Do not implement or claim live Jev readiness until the gate conditions in `Docs/PRODUCT_AND_SAFETY_CONTRACT.md` pass.
