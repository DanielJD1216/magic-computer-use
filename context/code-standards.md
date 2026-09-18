# Code Standards

## General

- Preserve the closed capability and fail-closed boundaries in `context/architecture.md`.
- Keep pure domain, registry, binding, and policy code independent of SwiftUI, AppKit, network, and Accessibility.
- Prefer explicit value types, dependency injection, typed errors, and small protocols.
- Do not add a provider, framework, permission, or capability without updating the product contract and test matrix.

## Swift Rules

- Swift is intended; exact Swift/Xcode/macOS versions remain open until target-Mac inspection.
- Use `Codable`, `Sendable`, and actor isolation at concurrency boundaries.
- Use typed enums for capture state, action state, capability IDs, risk, policy decisions, and failure reasons.
- Propagate cancellation, permission, stale-state, malformed-response, and verification errors.
- Keep credentials in Keychain accessors. Credential values never enter view models, fixtures, errors, or logs.

## Framework Rules

- SwiftUI owns presentation and state binding.
- AppKit is limited to menu-bar, command-panel, focus, hotkey, and native APIs not exposed by SwiftUI.
- `SessionOrchestrator` owns sequencing, identity binding, deadlines, and cancellation. Views send intents and render state.
- `SelectionAdapter` validates a response against the exact candidate set. A fixture adapter is the default.
- `NativeExecutor` accepts only a locally constructed validated operation and returns an observed result, not a Boolean.
- `FixtureVerifier` independently checks the exact postcondition.

## Data and Concurrency

- Candidates are locally created, exact, immutable, versioned, and bound to session, goal, transcript, observation, target, payload, policy, and deadline identities.
- Reject unknown IDs, unknown executable fields, stale revisions, malformed responses, and expired confirmations.
- Every callback checks session generation and action-attempt identity.
- Retry only bounded transient selection transport failures if later authorized. Never retry uncertain native effects.
- Persist only the allowlisted fields in `Docs/DATA_EGRESS.md`.

## Testing

- Use red-green-refactor for new behavior.
- Cover registry, candidate parsing, transcript finalization, state transitions, stale callbacks, cancellation, unknown effects, policy, redaction, and orchestrator behavior.
- Keep fakes deterministic and network-free.
- Real-Mac tests use only the versioned synthetic Safari fixture.
- Do not claim Swift or UI verification from WSL.

## File Organization

- `JevMacApp/Domain/`: contracts, IDs, state, registry, policy values.
- `JevMacApp/Application/`: orchestration and local decisions.
- `JevMacApp/Infrastructure/`: speech, fixture, transport, and platform adapters.
- `JevMacApp/Features/`: SwiftUI views and view models.
- `JevMacTests/`: unit and integration tests.
- `JevMacUITests/`: target-Mac UI tests.
- `Design/`, `Docs/`, and `context/`: requirements, gates, evidence, and operational truth.
