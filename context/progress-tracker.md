# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

- Foundation and design gate in progress. Repository is an empty public project; no Mac build evidence yet.

## Current Goal

- Establish the product contract, native UI states, local fake action loop, and a testable domain boundary before any live Jev request.

## Completed

- Confirmed target repository: `/home/jinni_doo/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Confirmed clean `main` branch at `c9ac67d`, origin `DanielJD1216/magic-computer-use`, with only the initial README before scaffolding.
- Created project context and diagnostic runbook files.
- Read current TypeSafe API, state, Choice, confidence, and terms pages.
- Recorded that Jev accepts text/JSON state only and returns typed Choice probabilities/confidence.
- Recorded terms constraints: preview access, no third-party product/service use, no public benchmarks, no production suitability assumption, and user responsibility for input rights.
- Recorded the live access gate as unresolved. No Jev credential has been requested or used.
- Confirmed current execution host is Ubuntu 24.04 under WSL2 with neither `swift` nor `xcodebuild` available.
- Mobbin MCP was searched for the required UI research gate and was unavailable in this session. High-fidelity external pattern evidence is therefore unverified.
- MagicPath decision: skip. The product contract already specifies the native utility workflow, and the real implementation stack is SwiftUI/AppKit rather than a concept generator.

## In Progress

- Create the design brief, acceptance checklist, build plan, and local fake domain/application slice.

## Next Up

1. Inspect a real Mac target for macOS minimum, Apple Silicon/Intel support, Xcode/Swift version, bundle identifier, signing, sandbox, and Accessibility test capability.
2. Implement and test pure domain contracts and policy using a verified Swift/Xcode environment or a separately authorized cross-platform core target.
3. Implement fake orchestrator loop and UI shell without requesting permissions at launch.
4. Resolve the legal/access decision before enabling the TypeSafe transport or asking for Jev-side credentials.

## Open Questions

- Is the intended private prototype permitted under the current TypeSafe preview terms, given the planned computer-use client may be considered a similar product or service?
- Does Jev/TypeSafe provide written authorization for this specific internal development use and direct client architecture?
- What exact macOS minimum and architecture are required?
- Xcode project or Swift Package Manager plus an app target?
- Sandboxed private prototype or non-sandboxed local prototype?
- Direct Keychain-backed calls or a controlled relay if direct client use is not permitted?
- Which browser is the controlled acceptance target, and how will synthetic pages be hosted locally?

## Architecture Decisions

- The model selects only a stable candidate ID; local code resolves and executes the operation.
- Confidence routes policy but never grants permission by itself.
- `stop` and `askUser` are always available; stale, incomplete, ambiguous, or low-confidence state fails closed.
- Push-to-talk is the default interaction. Always-on listening is not part of version 0.1.
- The first demo uses Notes and browser workflows with synthetic/reversible data only.
- The live Jev integration remains disabled until terms and Jev-side authorization are explicitly closed.

## Session Notes

- The current WSL environment can create and test repository documentation and platform-neutral logic, but it cannot produce Mac build or real-permission evidence.
- Do not report the prototype as built, safe, fast, accurate, or ready for dogfooding until the Mac build and acceptance gates pass.
