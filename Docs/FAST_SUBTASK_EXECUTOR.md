# Fast Subtask Executor

## Purpose

The executor runs a trusted, bounded subtask inside an already-authorized JevMacShell route. It reduces expensive planner calls without expanding the capability registry.

## Boundary

Planner or trusted local factory -> FastDesktopSubtask -> FastDesktopDecisionPolicy -> FastDesktopBackend -> FastDesktopVerifier -> result.

The runtime may choose only an operation and an ID from the current normalized snapshot. It may not invent capabilities, selectors, coordinates, text, URLs, shell commands, confirmation, or verification criteria.

## Initial operations

- `click` on an observed target that advertises `click`.
- `typeText` on an observed target that advertises `typeText`, using an input key supplied by the trusted subtask.
- `wait` with no target.
- Terminal decisions: `subtaskComplete`, `blocked`, `needsAgent`, `stopped`, `outcomeUnknown`.

## Required gates

- Freshness check immediately before every mutation.
- One dispatch per decision.
- Runtime-owned settle observation after mutation.
- Independent verifier before `subtaskComplete`.
- No automatic replay after `outcomeUnknown`.
- Bounded stale retries, no-change detection, and action budget.

## First implementation target

Only deterministic in-memory state and `FakeSafariFixture`. No live provider, OCR, screenshot, coordinate, Chrome, arbitrary CuaDriver, or current-Mac route is enabled by this document.
