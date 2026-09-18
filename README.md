# Meet Jev, Fastest Computer Use

A private macOS menu-bar prototype for push-to-talk, bounded computer actions, and explicit verification. Swift code owns permissions, policy, execution, cancellation, and logging. Jev, when authorized, selects only from a closed set of action candidates.

## Current status

The repository is in foundation and design-gate work. It contains the product contract, UI state specification, privacy/action-policy boundaries, test matrix, latency instrumentation plan, and project context. No macOS app target or live Jev integration is claimed yet.

The current development host is Ubuntu 24.04 under WSL2 and does not have `swift` or `xcodebuild`. Mac build and real-permission verification must run on the supported target Mac.

## Intended first workflow

> Open Notes, create a synthetic note called `Video ideas`, and type three ideas. Do not send or publish anything.

Additional workflows are browser search and copying a synthetic page title into a note. All development and acceptance data must be synthetic and reversible.

## Safety boundaries

- Push-to-talk only. No always-on listening.
- No arbitrary shell commands or coordinate-only clicking.
- No automatic sending, deleting, purchasing, publishing, private-data sharing, or account changes.
- Every action is a closed candidate selected by local code, checked for risk and freshness, and verified after execution.
- `stop` and `askUser` are always available.
- Credentials belong in macOS Keychain, never in source, fixtures, logs, screenshots, or chat.

## Jev access gate

The current TypeSafe preview terms retrieved for this build prohibit using the Interfaces to provide a product or service to a third party, prohibit public benchmarks, and warn that the Interfaces may not be production-suitable. The planned client may fall within a similar-product boundary.

The live Jev adapter therefore remains disabled until the intended private use is authorized and the direct-client versus relay decision is closed. Jev-side credentials are **not needed yet**. When that gate is closed, credentials must be entered through the approved Mac/Keychain path, not pasted into chat or committed to the repository.

## Repository map

- `Design/`: UI/UX brief and acceptance checklist.
- `Docs/`: permissions, security, action policy, test matrix, and latency evidence plan.
- `context/`: project, architecture, UI, code, workflow, and progress truth.
- `context/specs/00-build-plan.md`: gated implementation sequence.
- `docs/guides/diagnostic-runbook.md`: first-failure checks and safe recovery boundaries.

## Next gate

Inspect a real Mac target and record:

- macOS minimum and architecture.
- Swift/Xcode versions.
- Xcode project versus Swift Package Manager layout.
- Bundle identifier, signing team, and sandbox posture.
- Accessibility and real-Mac test strategy.
- Exact build and test commands.

Do not treat this README as evidence that the application builds or that Jev has been called.
