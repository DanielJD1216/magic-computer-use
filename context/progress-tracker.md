# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Authenticated Tailscale SSH to the target Mac is complete.
- Full Xcode is installed and usable through `DEVELOPER_DIR`.
- The pure SwiftPM safety core is implemented and verified with 10 target-Mac tests.
- Native app and runtime feasibility gates remain open.

## Current Goal

Build the smallest native menu-bar shell and isolated Mac probes without permissions at launch, then implement the fake Safari-fixture loop before any live Jev request.

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
- Chose Swift Package Manager for the pure core because the repository had no existing app project or package.
- Added `Package.swift` and the first capability/policy/lifecycle implementation.
- Observed the intended red test failures, then made the tests green on the target Mac.
- Verified `swift test --disable-sandbox`: 10 tests, 0 failures.
- Cloned and synced the repository to the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- No Jev credential has been requested or used.

## In Progress

- Native shell and platform probes: menu-bar/panel behavior, speech boundary, hotkey lifecycle, and fixture preparation.

## Next Up

1. Create a minimal native app target or executable shell using the verified Xcode/SwiftPM convention.
2. Build fake orchestrator, response validation, redaction, budget, and fixture-adapter tests.
3. Run isolated speech finalization/cancellation, on-device mode, hotkey, floating panel, Safari Accessibility, native fixture action, and exact verifier probes.
4. Implement the versioned synthetic Safari fixture and one trusted native operation.
5. Run the fixture acceptance matrix and egress canaries.
6. Resolve Jev/TypeSafe private-use authorization, direct client versus relay, provider retention, and credential-entry path before live transport.

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

- Native app target format, bundle ID, signing team, entitlements, and sandbox posture.
- Speech recognition mode and on-device support for the selected locale.
- Global hotkey and utility panel behavior on the target OS.
- Safari fixture hosting, accessibility identity, native action path, and verifier.
- Applicable TypeSafe/Jev agreement and whether this private client architecture is authorized.
- Direct client versus relay and provider retention/deletion/operational logging.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
