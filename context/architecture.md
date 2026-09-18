# Architecture Context

## Stack

| Layer | Technology | Role |
| --- | --- | --- |
| App shell | SwiftUI with AppKit integration | Menu-bar item, utility command bar, settings, permissions, activity history |
| Native runtime | macOS Accessibility APIs, `NSWorkspace`, URL loading, narrowly scoped AppleScript/Shortcuts only where required | Observe and execute bounded Mac actions |
| Speech | Protocol-backed adapter, Apple Speech first | Partial and final transcript events |
| Jev boundary | Swift concurrency and `URLSession` | Send text/JSON state to the current TypeSafe API shape and parse typed Choice answers |
| Local secrets | macOS Keychain | Personal prototype credential storage only, when authorized |
| Local diagnostics | Redacted file or SQLite-backed event store, implementation choice pending | Timing and action history without private raw content by default |
| Tests | XCTest and SwiftUI UI tests | Domain, application, infrastructure, and real-Mac boundary coverage |
| Build | Xcode/macOS target, exact scheme and minimum OS pending Mac inspection | Reproducible private prototype build |

The repository initially contained only a README and has no existing package, Xcode project, CI, signing configuration, or context conventions. The current WSL host has no `swift` or `xcodebuild`, so Mac build evidence is unavailable here.

## System Boundaries

- `JevMacApp/App/`: application composition, dependencies, environment, and lifecycle.
- `JevMacApp/Domain/`: Codable value types and closed action/state contracts with no network or Accessibility side effects.
- `JevMacApp/Application/`: orchestration, policy, cancellation, freshness, action resolution, and verification decisions.
- `JevMacApp/Application/ActionResolver.swift`: strict local candidate-to-operation mapping. It rejects unknown fields, unknown IDs, mismatched observation bindings, malformed payload references, and candidate-kind/payload mismatches before an executor can run.
- `JevMacApp/Features/`: SwiftUI state presentation and user controls. Views do not hold credentials or execute Mac actions directly.
- `JevMacApp/Infrastructure/Audio/`: speech capture and transcription adapters.
- `JevMacApp/Infrastructure/TypeSafe/`: request/response models and Jev transport. This boundary is disabled until the terms and access gate is closed.
- `JevMacApp/Infrastructure/MacAutomation/`: permission checks and native executors. No arbitrary shell path exists.
- `JevMacApp/Infrastructure/Observation/`: active-app and accessibility observation with data minimization.
- `JevMacApp/Infrastructure/Security/`: Keychain access and redacting logging.
- `JevMacApp/Infrastructure/Telemetry/`: local timing and redacted event persistence.
- `JevMacTests/` and `JevMacUITests/`: deterministic tests and UI state/interaction tests.
- `Design/` and `Docs/`: product contract, permissions, policy, security, test matrix, and latency evidence.

## Storage Model

- **Keychain**: the TypeSafe credential, only in an explicitly authorized personal-prototype mode. Never source, `Info.plist`, UI state, ordinary logs, fixtures, screenshots, or crash reports.
- **Local event store**: session ID, candidate ID, risk, phase, observation ID, timing checkpoints, policy result, executor result, verification result, and redacted stop/error reason. Full transcripts are opt-in and deletable if implemented.
- **Application settings**: local preferences such as confirmation mode, privacy switch, allowlists, and log-retention choice. No cloud sync.
- **No remote database or server state** in version 0.1.

## Auth and Access Model

- The user grants macOS permissions deliberately and only when the enabled capability needs them: microphone, speech recognition, Accessibility, and narrowly scoped Automation.
- Jev API authentication is bearer-key based according to the current TypeSafe reference. The key must be resolved from Keychain inside the transport boundary.
- No multi-user identity or account system exists.
- Action authorization is local policy, not model confidence alone. Closed candidate IDs, current observation ID, permission state, risk class, and confirmation mode must all be checked before execution.

## External Services

- **TypeSafe API**: `POST https://api.typesafe.ai/v1/systemone`. Sends minimized text/JSON state and one typed Choice question. Current docs specify model `jev-latest`, state as string/object/array, and Choice answers with the selected option, probability distribution, and confidence. Live calls are blocked pending Jev-side authorization and terms review for this intended client use.
- **Apple Speech**: local/system framework for the first transcription adapter. Exact availability and behavior must be validated on the target Mac.
- **Apple macOS frameworks**: local-only Accessibility, Workspace, and permission APIs.

## Background Jobs and AI Flows

- **Push-to-talk session**: local state machine owns listening, transcription, selection, policy, execution, verification, and terminal states.
- **Jev selection request**: one cancellable network request for a stable observation/transcript snapshot. Superseded partial requests are cancelled and never authorize a stale action. Every callback carries and checks a `sessionGeneration`; every selected operation carries an `actionAttemptID`.
- **Retry policy**: only bounded transport retry for transient `429` or `529` responses, with no side-effect replay. `401`, `422`, timeout, cancellation, malformed response, unknown candidate, and stale observation fail closed.
- **Unknown-effect handling**: if cancellation, crash, timeout, or a native API boundary leaves it impossible to prove whether an action took effect, the session enters `unknownEffect`, records a redacted event, and requires a fresh user-visible observation. It never retries automatically.

## Invariants

1. Jev returns a candidate ID; it never invents executable tool names, selectors, URLs, paths, or commands.
2. `stop` and `askUser` are always available as local candidates.
3. Every attempted action has a local policy decision and redacted audit event.
4. An action selected against a stale or incomplete observation cannot execute.
5. High-risk, destructive, externally visible, privacy-sensitive, or financially consequential actions require explicit user confirmation and remain outside version 0.1 execution scope.
6. Local cancellation wins over an in-flight network request and stops future execution.
7. Credentials and private raw content are never emitted to ordinary logs or committed to the repository.
8. TypeSafe preview terms and Jev-side authorization govern whether the live adapter may be enabled; fake adapters remain the default development path.
9. Provider output is never an executable payload. Only a selected candidate ID from the exact request is accepted; strict response validation rejects malformed or extra executable fields.
10. Every speech event, provider response, retry, permission callback, executor completion, and verifier result must match the active session generation before it can mutate session state.
11. A native operation without a provable outcome enters `unknownEffect` and cannot be replayed automatically.
12. The target Mac signing, sandbox, entitlement, and provider retention posture must be recorded before real-Mac readiness or dogfooding claims.
