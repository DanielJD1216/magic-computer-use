# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Authenticated Tailscale SSH to the target Mac is complete.
- Target-Mac platform probing is partially complete and currently blocked by the absence of full Xcode.
- No Swift source, Xcode target, live Jev transport, native build, or Mac acceptance evidence exists.

## Current Goal

Install full Xcode on the target Mac, close the remaining orientation facts, then implement the fake Safari-fixture safety loop with executable tests before any live Jev request.

## Completed

- Confirmed the authorized repository: `/home/jinni_doo/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Read the updated v2 handoff and installed it as `context/specs/00-build-plan.md`.
- Retained the prior foundation summary as `context/specs/00-build-plan-v1-summary.md`.
- Added the product and safety contract, capability registry, experiment protocol, data-egress boundary, platform-probe checklist, and publication-clearance gate.
- Reconciled README, architecture, UI context, UX brief/checklist, action policy, permissions, security, code standards, workflow rules, test matrix, latency instrumentation, and diagnostic runbook to Safari-fixture-first scope.
- Confirmed WSL lacks `swift` and `xcodebuild`.
- Confirmed Tailscale reachability and authenticated SSH to the Mac.
- Recorded target Mac evidence: macOS `26.5.1` build `25F80`, `arm64`, Swift `6.2.0.19.9`, Apple Git `2.50.1`.
- Confirmed the Mac active developer directory is Command Line Tools and `xcodebuild` cannot run without full Xcode.
- Confirmed Swift framework type-checks for Foundation, AppKit, SwiftUI, Speech, AVFoundation, ApplicationServices, and Carbon.
- Cloned the repository to the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use` and verified clean commit `f71a656`.
- No Jev credential has been requested or used.

## In Progress

- Target-Mac setup: install full Xcode, open it once, accept any license prompt, select it with `xcode-select`, and rerun platform orientation.

## Next Up

1. Record Xcode, project format, signing identity, entitlements, sandbox, and exact build/test commands.
2. Run speech finalization/cancellation, on-device mode, hotkey, floating panel, Safari Accessibility, native fixture action, and exact verifier probes.
3. Build domain, capability, state, policy, stale-callback, cancellation, unknown-effect, budget, and redaction tests with fake adapters.
4. Build the menu-bar/panel shell without permission requests at launch.
5. Implement the versioned synthetic Safari fixture and one trusted native operation.
6. Run the fixture acceptance matrix and egress canaries.
7. Resolve Jev/TypeSafe private-use authorization, direct client versus relay, provider retention, and credential-entry path before live transport.

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

- Full Xcode installation and selected developer directory.
- Project format, bundle ID, signing team, entitlements, and sandbox posture.
- Speech recognition mode and on-device support for the selected locale.
- Global hotkey and utility panel behavior on the target OS.
- Safari fixture hosting, accessibility identity, native action path, and verifier.
- Applicable TypeSafe/Jev agreement and whether this private client architecture is authorized.
- Direct client versus relay and provider retention/deletion/operational logging.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
