# Code Standards

## General

- Preserve the closed-action and fail-closed boundaries from `context/architecture.md`.
- Keep pure domain and policy code independent of SwiftUI, AppKit, network, and Accessibility APIs.
- Prefer explicit value types, dependency injection, and small protocols over global state.
- Do not add a provider, framework, permission, or action category without updating the product contract and test matrix.

## Language Rules

- Swift is the intended implementation language. The exact Swift/Xcode/macOS versions remain open until a real Mac target is inspected.
- Use `Codable`, `Sendable`, and actor isolation where concurrency crosses the transport, audio, or orchestration boundary.
- Use typed enums for action kinds, risks, session states, policy decisions, and failure reasons.
- Propagate errors with typed errors. Never swallow cancellation, permission, stale-state, malformed-response, or verification failures.
- Keep credentials in Keychain accessors; no credential value may enter a view model or log message.

## Framework Rules

- SwiftUI owns presentation and state binding. AppKit is allowed only for menu-bar/utility-window behavior and native Mac APIs not exposed by SwiftUI.
- `ComputerUseOrchestrator` owns sequencing and cancellation. Views send intents and render state; they do not execute actions.
- `TypeSafeClient` owns URLSession transport and status mapping. `JevActionSelector` validates responses against the exact sent candidate set.
- Native executors return observed `ActionResult` values, not bare booleans.

## Styling

- Use the native macOS system font, semantic colors, accessibility sizes, focus indicators, and reduced-motion settings.
- Keep the floating command bar compact and status-forward. Do not turn it into a general chat transcript.
- Every active state must expose a visible stop control and a text label in addition to iconography.

## API and Data

- Build TypeSafe requests from an explicit state object and one Choice question whose criteria descriptions explain each candidate.
- Never accept an answer choice not present in the exact request's candidate map.
- Preserve observation ID and capture timestamp through selection and verify freshness immediately before execution.
- Redact authorization headers, API keys, passwords, full clipboard contents, and private document values before persistence or diagnostics.
- Retry only transient `429` and `529` transport failures with a bounded policy. Never retry an uncertain side effect.

## Testing

- Use strict red-green-refactor for new behavior: write one failing test, observe the expected failure, implement the smallest passing behavior, then refactor.
- Cover domain encoding, candidate validation, policy precedence, stale-state rejection, cancellation, transport response parsing, redaction, permission rendering, and orchestrator transitions.
- Keep fake adapters deterministic and network-free. Real-Mac tests use synthetic notes/pages and reversible workflows only.
- Exact build/test commands are pending a Mac/Xcode inspection. Do not claim Swift or UI verification from this WSL host.

## File Organization

- `JevMacApp/Domain/`: pure contracts and value types.
- `JevMacApp/Application/`: orchestration and local decisions.
- `JevMacApp/Infrastructure/`: external boundaries and platform adapters.
- `JevMacApp/Features/`: SwiftUI views and view models.
- `JevMacTests/`: unit/integration tests by boundary.
- `JevMacUITests/`: UI tests for states and controls.
- `Design/` and `Docs/`: requirements, acceptance, privacy, security, policy, test, and evidence records.
