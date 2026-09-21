# TypeSafe Live Synthetic Smoke Result

## Result

**Native transport smoke passed. Live selection is enabled on the deployed target Mac by explicit instruction. No live decision was triggered during deployment.**

The first probe at `2026-09-20T19:13:53-07:00` was invalid harness evidence because its temporary curl config did not construct the documented Bearer authorization header. It returned 403, but that result cannot diagnose the account.

The later SSH probes were also not valid API-key evidence. They attempted to export the credential with `security find-generic-password -w` from an SSH-executed shell. A presence-only Keychain lookup succeeded, but the value lookup returned exit `36` with an empty value. The harness did not check that command's exit status and could therefore send a request without a usable credential. The hardened harness now fails closed before curl when the Keychain value cannot be read.

The one valid native-app probe launched a temporary GUI bundle in the Mac's logged-in user session. It called the existing `LiveJevSelectionAdapter`, which read the Keychain through the app-owned credential store and sent the bounded request through native `URLSession`. It recorded a valid closed-choice selection:

```text
LIVE_NATIVE_PROBE=selection_received
LIVE_NATIVE_SELECTION=select_reviewed_fixture_view
```

The native probe did not dispatch the selected capability, change Safari, or enable live selection.

## Post-deployment action attempt

After deployment, one separate bounded GUI action probe checked the exact Safari fixture before sending a provider request. It failed closed at the macOS Accessibility preflight:

```text
LIVE_NATIVE_ACTION_PROBE=blocked
LIVE_NATIVE_ACTION_REASON=Accessibility permission is required for the Safari fixture.
```

No TypeSafe request, capability dispatch, or Safari mutation occurred in that attempt. The target app remained enabled, but the deployed bundle still required macOS Accessibility approval at that point. That approval was subsequently completed before the bounded workspace verification below.

After the user approved the deployed bundle in macOS Accessibility settings,
the normal bounded command-panel flow was exercised without another provider
request. The Jev-owned TextEdit workspace route completed with this local
readback:

```text
Jev Completed
Workspace test complete.
Verified CuaDriver text input in the Jev-owned TextEdit workspace.
Fresh TextEdit accessibility readback matched exactly.
```

This proves the deployed Accessibility permission and bounded CuaDriver
workspace route, not a new TypeSafe entitlement or a generic desktop-control
path.

The workspace evidence above is historical evidence from the earlier deployed
build. The current checkpoint deliberately defers that route after review
identified unresolved ancestor and file-handoff race conditions. It is not
available to the current app and must not be treated as current acceptance.

The subsequent bounded Safari Accessibility expansion was exercised without
another TypeSafe request. After re-approving the clean ad-hoc deployed bundle,
the fixed reviewed-to-landing transition returned:

```text
COMPUTER_USE_LANDING_BEFORE=Jev Fixture v1 | Reviewed / reviewed
COMPUTER_USE_LANDING_AFTER=Jev Fixture v1 | Landing / landing
COMPUTER_USE_LANDING_EXACT_POSTCONDITION=true
```

The first landing attempt failed closed because Safari still had the prior
fixture DOM loaded and the new landing control was absent from its Accessibility
tree. Reloading the synthetic fixture through Safari's native Accessibility
reload control restored the declared control pair; the rerun passed. The
temporary probe was removed before the final clean release build.

The intended bounded Safari-fixture payload was:

- Model: `jev-latest`
- Workflow: `jev-mac-safari-fixture-v1`
- Final command fragment: `Show me the reviewed fixture`
- Fixture version: `safari-fixture-v1`
- Fixture view: `landing`
- Closed capability IDs and descriptions from the local registry
- Synthetic request, candidate-set, session, and action-attempt identities

The payload contained no screenshots, audio, Accessibility trees, personal data, credentials, URLs, shell text, or full session history.

## Invalid SSH harness output

```text
LIVE_PROBE_HTTP_STATUS=403
LIVE_PROBE=provider_error
PROVIDER_ERROR_KEYS=detail
```

The resulting HTTP `403` values from those SSH probes are invalid evidence about the account because the request did not contain a verified non-empty credential. They are consistent with the provider receiving no usable API key. No selection was received, no local capability was dispatched, and no action was replayed.

At `2026-09-20T22:35:30-07:00`, after the active console key was manually refreshed into the target Mac's Keychain, the same SSH export failure remained. The probe therefore did not establish a valid direct API request.

At `2026-09-20T23:11:08-07:00`, one separately authorized native GUI-app probe used the app-owned Keychain and URLSession path. It returned a valid closed-choice selection:

```text
LIVE_NATIVE_PROBE=selection_received
LIVE_NATIVE_SELECTION=select_reviewed_fixture_view
```

This is the first valid evidence that the refreshed credential, direct TypeSafe API path, current `jev-latest` model alias, and bounded request are working together. The selection was observed only; no native capability was dispatched.

## Signed-in console comparison

At `2026-09-20T22:27:56-07:00`, the signed-in TypeSafe Playground ran its default synthetic state with one harmless Noul question. The console returned:

```text
MODEL=jev-latest
QUESTION=new_noul_1
DISPLAYED_PROBABILITY=50%
ANSWER=true
```

This proves the signed-in account session can evaluate Jev. It does not prove that the secret currently stored in the target Mac's Keychain is the same active organization-scoped key shown in the console, nor that the direct API-key path has the same permission as the console session.

## Preflight evidence

- Target-Mac tests before the live smoke: **87 tests, 0 failures**
- Debug `JevMacShell` build before the live smoke: passed
- Release `JevMacShell` build before the live smoke: passed
- GUI app Keychain presence/read path: the app reports the credential as stored through `JevCredentialStore.hasCredential()`
- SSH `security -w` value export: failed with exit `36`; value empty; no credential value exposed
- Hardened SSH probe: failed closed with `LIVE_PROBE=keychain_read_failed`; no provider request sent
- Native GUI-app probe: **selection received** through `LiveJevSelectionAdapter` and native `URLSession`
- Native probe postcondition: no capability dispatch, no Safari mutation, and the probe left `jev.liveSelection.enabled=0`; deployment later set the target Mac preference to `1`
- No credential value was displayed, logged, or copied into the repository

## Decision

The direct TypeSafe transport is **technically working** through the native JevMacShell path. The earlier SSH `403` values were invalid evidence because the harness sent an empty or unverified Bearer value after `security -w` failed. The public-launch/API-entitlement hypothesis is therefore not the cause of this incident. The target Mac's deployed user app now has live selection enabled by explicit instruction; this is an operational configuration change, not a claim that the independent account, privacy, egress, or cost gates are resolved.

The broader Gate 2 authorization, privacy, account-agreement, and egress decisions remain separate. The app still permits only the reviewed closed capability registry, and no automatic retry, live capability dispatch, or fallback action occurred during deployment.

No further provider request is authorized in this probe sequence. Future tests must use the native app path, not export the credential over SSH, and must remain separately approved and fixture-only.

See also: `Docs/TYPESAFE_GATE_2_REVIEW.md` and `Docs/DATA_EGRESS.md`.
