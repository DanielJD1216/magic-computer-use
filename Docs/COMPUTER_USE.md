# Experimental Computer-Use Executor

This mode lets JevMacShell use the installed Mac `cua-driver` as the executor for two bounded local routes. It is a separate execution route, not a generic desktop agent.

## Current scope

- Default off.
- The existing `safari-fixture-v1` target is eligible for `select_reviewed_fixture_view`.
- The Jev-owned TextEdit scratchpad under `~/Library/Application Support/JevMacShell/Sandbox` is eligible for the fixed workspace probe.
- The Safari route captures a fresh CuaDriver Accessibility snapshot for the already-bound Safari process and window, requires the exact element label `Select reviewed fixture view`, and sends one Accessibility press.
- The workspace route creates a unique empty text document under the app-owned workspace, opens it in TextEdit, finds the exact `AXTextArea` in a fresh window snapshot, and types only the fixed probe string.
- Safari verification remains native and must confirm `State: reviewed`; workspace verification is a fresh exact TextEdit accessibility readback.

The mode does not accept model-provided coordinates, selectors, URLs, shell commands, passwords, system-setting actions, or arbitrary app targets. The workspace probe's text is native-owned and fixed; it is not yet a free-form voice or live Jev capability.

## Fast subtask proof boundary

The reusable `FastSubtaskExecutor` currently has a deterministic Safari fixture backend and an end-to-end fixture test. The native `select_reviewed_fixture_view` capability is now wired through a Mac-side Safari adapter into this bounded executor; the existing bounded CuaDriver route remains a separate execution path. That proof covers bounded observation, legal action-space construction, trusted input-key materialization, freshness, settling, independent verification, cancellation, budgets, stale targets, no-change blocking, uncertain outcomes, and redacted evidence.

This fixture proof does not authorize arbitrary actions on the current Mac. It is not a live Jev policy adapter, OCR executor, Chrome DOM/CDP route, generic CuaDriver controller, or unrestricted desktop bridge. Those integrations remain separately gated and deferred.

## Flow

```text
push-to-talk transcript
  -> closed Jev capability selection
  -> native policy validation
  -> fixed Safari fixture target binding
  -> fresh CuaDriver Accessibility snapshot
  -> exact fixed-label press
  -> native Safari postcondition verification
```

The workspace probe is an explicit app action while its target contract is being validated:

```text
explicit Jev workspace test action
  -> app-owned workspace file
  -> exact TextEdit window discovery
  -> fresh AXTextArea snapshot
  -> fixed probe text through CuaDriver
  -> exact fresh TextEdit readback
```

The capability registry and native Swift policy remain the authority for the Safari route. The workspace probe is not exposed to live Jev selection yet. CuaDriver supplies only the execution mechanism for these allowlisted routes.

## Enablement

In the app settings, enable **Enable bounded computer-use executor**. The setting is stored locally in `UserDefaults` and is disabled by default. It affects the next bounded action and does not enable live Jev selection.

The Mac must have the CuaDriver executable installed and its required macOS permissions enabled. The app resolves the executable from the known local installation path or standard executable locations. No credentials are passed to CuaDriver.

## Verification and failure

CuaDriver may report an effect as `unverifiable`. The app does not treat that field as success. It performs a fresh native readback through the Safari fixture adapter. A verified `State: reviewed` is success; a missing or stale target blocks the action; an uncertain postcondition becomes `outcome_unknown` and is not replayed automatically.

If this mode needs to expand beyond the Safari fixture or Jev-owned TextEdit workspace, add a new capability, target contract, policy test, exact observation, confirmation rule, and independent verifier first. Do not turn the executor into a free-form desktop command bridge.

## Jev execution-mode UI

The command panel now exposes three explicit modes:

- **Native Swift:** deterministic execution for the registered Safari fixture.
- **Bounded CuaDriver:** CuaDriver may act only on the Safari fixture or the
  Jev-owned TextEdit workspace.
- **Experimental desktop:** a clearly labelled current-Mac surface intended
  for a future Hermes controller bridge.

Experimental desktop mode is mutually exclusive with the bounded executor and
requires an explicit confirmation in Settings. The panel keeps the warning
visible:

> This targets the current Mac session. It is not isolated.

The mode switch does not start, stop, or scope the external CuaDriver daemon.
It also does not change the native capability registry.

### Controller bridge gate

The experimental task composer is present for the interaction contract, but
**Send task to Hermes** remains disabled until JevMacShell has a verified,
authenticated Hermes controller bridge. This build has no configured Hermes API
server endpoint or app-side run lifecycle, so no desktop task is sent from the
panel.

A bridge implementation must close all of these gates before enabling the
button:

1. Authenticated Hermes API endpoint and session identity.
2. Explicit computer-use toolset and permission mode for the run.
3. Run status, progress, and local Stop/cancellation mapping.
4. Independent observation after any CuaDriver effect.
5. `outcome_unknown` handling that prohibits automatic replay.
6. Redacted activity events without raw task bodies, screenshots, credentials,
   or provider response bodies.

The UI contract is recorded in
`Design/EXPERIMENTAL_DESKTOP_MODE_SPEC.md`.
