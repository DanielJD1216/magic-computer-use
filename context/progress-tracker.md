# Progress Tracker

Update this file after every meaningful change.

## Current Phase

- Corrected v0.1 contract and repository orientation are complete.
- Platform feasibility is blocked at authenticated target-Mac access.
- No Swift source, Xcode target, live Jev transport, native build, or Mac acceptance evidence exists.

## Current Goal

Establish authenticated Mac access, run the v2 platform probes, then implement the smallest fake Safari-fixture safety loop before any live Jev request.

## Completed

- Confirmed the authorized repository: `/home/jinni_doo/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Read the updated v2 handoff and installed it as `context/specs/00-build-plan.md`.
- Retained the prior foundation summary as `context/specs/00-build-plan-v1-summary.md`.
- Added the product and safety contract, capability registry, experiment protocol, data-egress boundary, platform-probe checklist, and publication-clearance gate.
- Reconciled README, architecture, UI context, UX brief/checklist, action policy, permissions, security, code standards, workflow rules, and test matrix to Safari-fixture-first scope.
- Confirmed the current host is Ubuntu 24.04 under WSL2 without `swift` or `xcodebuild`.
- Confirmed Tailscale reachability to `daniels-macbook-pro` at `100.105.165.39`.
- Confirmed macOS Remote Login is enabled and TCP 22 is reachable.
- Generated a local Ed25519 key at `/home/jinni_doo/.ssh/jev-mac-ed25519`; the private key is outside the repository and has not been shared.
- Tested SSH with the generated key. Authentication failed because the public key has not been installed on the Mac.
- No Jev credential has been requested or used.

## In Progress

- Target-Mac access: install the generated public key on the Mac itself or enable Tailscale SSH, then run the platform probes.

## Next Up

1. Authenticate to the Mac over Tailscale.
2. Record macOS, architecture, Xcode/Swift, project format, signing, sandbox, speech, hotkey, panel, Safari Accessibility, native action, and verifier evidence.
3. Create the pure domain and policy layer with fixture adapters and tests.
4. Create the menu-bar/panel shell without permission requests at launch.
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

- Target Mac OS, architecture, Xcode/Swift versions, project format, bundle ID, signing team, and sandbox posture.
- Speech recognition mode and on-device support for the selected locale.
- Global hotkey and utility panel behavior on the target OS.
- Safari fixture hosting, accessibility identity, native action path, and verifier.
- Applicable TypeSafe/Jev agreement and whether this private client architecture is authorized.
- Direct client versus relay and provider retention/deletion/operational logging.

## Evidence Boundary

Do not report the prototype as built, safe, fast, accurate, reliable, ready for internal use, or production-ready until the relevant fixture, Mac, authority, privacy, and publication gates pass.
