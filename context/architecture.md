# Architecture

## Boundary

The application is a native macOS menu-bar utility with a small command surface. The first proof slice is one local Safari fixture. It is intentionally not a generic computer-use agent. The command panel now makes the native, bounded, and experimental desktop modes explicit; the experimental surface is a fail-closed preparation for a future Hermes controller bridge, not an execution path by itself.

```text
Push-to-talk
  -> Speech adapter
  -> Transcript revisions
  -> Eligibility gate
  -> Observation service
  -> Local capability registry
  -> Selection adapter
  -> Policy engine
  -> Executor selector: native Swift or bounded CuaDriver fixture route
  -> Fixture verifier
  -> UI state and redacted evidence
```

## Components

- `AppShell`: menu-bar item, command panel, permission status, and lifecycle.
- `SessionOrchestrator`: owns goal/session IDs, transcript revisions, observation revisions, candidate-set identity, request identity, deadlines, and state transitions.
- `SpeechAdapter`: push-to-talk capture and partial/final revisions behind a protocol.
- `EligibilityGate`: determines whether a transcript revision is allowed to create a candidate request. It never performs a native action.
- `ObservationService`: reads a minimized, versioned Safari fixture state. Observation is internal and never a Jev-selected capability.
- `CapabilityRegistry`: creates the exact reviewed candidates in `Docs/CAPABILITY_REGISTRY.md`.
- `SelectionAdapter`: fixture adapter first; live Jev only after authorization and egress gates.
- `PolicyEngine`: revalidates transcript phase, target, provenance, permission, freshness, risk, confirmation, policy version, deadline, and binding identities.
- `FastSubtaskExecutor`: runs a trusted, bounded multi-step subtask beneath the closed capability and policy layers. It builds operation-specific action spaces, materializes only trusted input keys, checks freshness before dispatch, settles after mutation, enforces budgets and cancellation, and requires independent verification. It cannot create capabilities or authorize arbitrary current-Mac actions.
- `NativeExecutor`: maps a validated capability ID to one trusted adapter operation. No arbitrary parameters or executable model output enter this layer.
- `ComputerUseExecutor`: default-off CuaDriver bridge for the reviewed-fixture capability and the app-owned TextEdit workspace probe. Each route receives a native target contract, requires a fresh Accessibility element, and returns to an independent verifier. It is not a generic desktop command surface.
- `ExperimentalDesktopSurface`: explicit current-Mac mode, warning, task composer, controller status, stop/reset controls, and redacted activity history. It does not grant execution authority; the Hermes send action stays disabled until the controller bridge is verified.
- `HermesControllerBridge`: `JevCore` protocol and lifecycle contract for authenticated Hermes capabilities, one active run, status/events, stop, and fail-closed `outcome_unknown` handling. The current build includes no live transport implementation.
- `FixtureVerifier`: checks the exact action-specific postcondition independently.
- `EvidenceLogger`: records only the allowlisted redacted fields in `Docs/DATA_EGRESS.md`.

## State Model

Capture and action state are separate dimensions.

### Capture

`off`, `listening`, `finalizing`, `final`, `cancelled`, `failed`.

### Action

`idle`, `selecting`, `confirming`, `executing`, `verifying`, `completed`, `blocked`, `stopped`, `outcome_unknown`, `failed`.

Releasing the push-to-talk key moves capture to `finalizing` and requests the final transcript. It does not move action state to cancelled. `abortSession` is a separate explicit operation.

## Request and Candidate Binding

Every request carries:

- `sessionID`, `goalID`, `requestID`.
- `transcriptRevision` and transcript phase.
- `observationRevision` and observation identity.
- `candidateSetID` and registry/policy version.
- `payloadVersion` and payload provenance.
- `targetBinding` for the Safari process, window, and fixture version.
- Confirmation identity when required.
- Monotonic deadline and attempt identity.

A Jev response can select only an ID in the exact candidate set. The native executor receives a locally constructed operation, not a response object or free-form parameters.

## Concurrency Invariants

- One active goal per command panel.
- One selection request per candidate-set identity.
- One native dispatch per action attempt.
- Stop increments the session generation and invalidates request and action identities.
- Late speech, selection, permission, executor, and verifier callbacks are ignored unless all identities match the active state.
- Expired or stale observations rebuild the candidate set instead of retrying.
- Any uncertain native effect produces `outcome_unknown`; no automatic replay.

## Capability Boundary

First-slice capabilities are limited to activating the preflighted Safari fixture, selecting a reviewed fixture view, waiting for a reviewed fixture state, `stop`, and `ask_user`. See `Docs/CAPABILITY_REGISTRY.md` for exact contracts.

No model, page, fixture, transcript, or Accessibility tree can create a new capability, add a target, supply an executable selector, override confirmation, or expand the registry.

## Transport Boundary

The live adapter is disabled by default and can be enabled only through the Mac settings UI after a Keychain credential is present. The bounded CuaDriver executor is separately disabled by default and can be enabled only through the Mac settings UI. Its Safari route is limited to `safari-fixture-v1` and `select_reviewed_fixture_view`; its workspace route is limited to a unique file below the app-owned Application Support directory and a fixed TextEdit probe. Fresh Accessibility snapshots supply element tokens, while native Swift retains target binding, action policy, and postcondition verification. The experimental desktop surface is a separate current-Mac UI state. Its `JevCore` Hermes bridge contract is present, but no authenticated Hermes controller endpoint or live transport is configured in this build; it must not be treated as a generic executor or as proof that the external daemon is ready. Live Jev receives minimized allowlisted state only. It never receives raw audio, screenshots, full Accessibility trees, clipboard contents, credentials, shell text, arbitrary URLs, or full session history.

## Permission Boundary

Ask for microphone and speech permissions only when the speech capability is selected. Ask for Accessibility only when the reviewed Safari capability requires it. Keep live Jev and all consequential actions unavailable when permissions are denied, withdrawn, stale, or not verifiable.

## Build Boundary

Use SwiftUI for state presentation and `MenuBarExtra` for menu-bar access, subject to target-Mac probes. Use AppKit only where the command panel, focus, global key handling, or native Accessibility integration requires it. Do not choose an implementation from memory when the actual target Mac can resolve the question.
