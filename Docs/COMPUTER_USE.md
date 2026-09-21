# Experimental Computer-Use Executor

This mode lets JevMacShell use the installed Mac `cua-driver` as the executor for two bounded local routes. It is a separate execution route, not a generic desktop agent.

## Current scope

- Default off.
- The existing `safari-fixture-v1` target is eligible for `select_reviewed_fixture_view` and the reversible `return_to_landing_fixture_view` transition.
- The former Jev-owned TextEdit scratchpad route is deferred. It is not eligible for execution until descriptor-bound file handoff and document identity are independently verified.
- The Safari route captures a fresh CuaDriver Accessibility snapshot for the already-bound Safari process and window, requires one of the exact fixed labels `Select reviewed fixture view` or `Return to landing fixture view` based on the current fixture state, and sends one Accessibility press.
- No workspace file is created or opened by the current bounded route.
- Safari verification remains native and must confirm the exact local fixture document and requested state, either `State: reviewed` or `State: landing`.

The mode does not accept model-provided coordinates, selectors, URLs, shell commands, passwords, system-setting actions, or arbitrary app targets. The deferred workspace route performs no action.

## Fast subtask proof boundary

The reusable `FastSubtaskExecutor` currently has a deterministic Safari fixture backend and end-to-end fixture tests for both reversible transitions. The native `select_reviewed_fixture_view` and `return_to_landing_fixture_view` capabilities are wired through a Mac-side Safari adapter into this bounded executor; the CuaDriver route remains a separate execution path. That proof covers bounded observation, legal action-space construction, trusted input-key materialization, freshness, settling, independent verification, cancellation, budgets, stale targets, no-change blocking, uncertain outcomes, and redacted evidence.

This fixture proof does not authorize arbitrary actions on the current Mac. It is not a live Jev policy adapter, OCR executor, Chrome DOM/CDP route, generic CuaDriver controller, or unrestricted desktop bridge. Those integrations remain separately gated and deferred.

## Flow

```text
push-to-talk transcript
  -> closed Jev capability selection
  -> native policy validation
  -> fixed Safari fixture target binding
  -> fresh CuaDriver Accessibility snapshot
  -> exact state-dependent fixed-label press
  -> native Safari postcondition verification
```

The former workspace probe is intentionally deferred while its target contract is being validated:

```text
explicit Jev workspace test action
  -> trusted ancestor descriptors
  -> descriptor-bound file handoff
  -> exact TextEdit document identity
  -> fresh AXTextArea snapshot
  -> exact fresh TextEdit readback
```

The capability registry and native Swift policy remain the authority for the Safari route. The workspace probe is not exposed to live Jev selection and is not dispatched by the current app. CuaDriver supplies only the execution mechanism for the exact local fixture route.

The former fast Notes and current-cursor shortcuts are intentionally deferred.
They do not run until each operation has an exact target binding and an
independent postcondition verifier.

## Enablement

In the app settings, enable **Enable bounded computer-use executor**. The setting is stored locally in `UserDefaults` and is disabled by default. It affects the next bounded action and does not enable live Jev selection.

The Mac must have the CuaDriver executable installed and its required macOS permissions enabled. The app resolves the executable from the known local installation path or standard executable locations. No credentials are passed to CuaDriver.

## Target-Mac evidence

The current deployed bundle exposes only the bounded Safari fixture route. The
former TextEdit workspace probe is deferred and does not create a document or
dispatch input. The current staging evidence uses only the declared Safari
target and the fixed landing capability:

```text
COMPUTER_USE_LANDING_BEFORE=Jev Fixture v1 | Reviewed / reviewed
COMPUTER_USE_LANDING_AFTER=Jev Fixture v1 | Landing / landing
COMPUTER_USE_LANDING_EXACT_POSTCONDITION=true
```

The first attempt failed closed because Safari still held the pre-change
fixture DOM and therefore did not expose the new landing control. Reloading
the synthetic fixture through Safari's native Accessibility reload control
loaded the reviewed/landing control pair; the rerun then passed. No provider
request, screenshot, personal document, clipboard value, or generic desktop
action was involved. The temporary probe was removed before the final clean
release build.

## Verification and failure

CuaDriver may report an effect as `unverifiable`. The app does not treat that field as success. It performs a fresh native readback through the Safari fixture adapter. A verified requested state is success; a missing or stale target blocks the action; an uncertain postcondition becomes `outcome_unknown` and is not replayed automatically.

If this mode needs to expand beyond the Safari fixture, add a new capability,
target contract, policy test, exact observation, confirmation rule, and
independent verifier first. Do not turn the executor into a free-form desktop
command bridge.

## Jev execution-mode UI

The command panel now exposes three explicit modes:

- **Native Swift:** deterministic execution for the registered Safari fixture.
- **Bounded CuaDriver:** CuaDriver may act only on the registered Safari
  fixture. The former TextEdit workspace route is deferred.
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
7. Strict SSH host-key verification through an explicitly managed `known_hosts`
   file for any remote CuaDriver or Hermes transport.

The UI contract is recorded in
`Design/EXPERIMENTAL_DESKTOP_MODE_SPEC.md`.
