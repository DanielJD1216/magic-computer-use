# TypeSafe Live Synthetic Smoke Result

## Result

**Failed closed. Do not retry automatically.**

Observed at `2026-09-20T19:13:53-07:00` from the configured target Mac.

One live TypeSafe request was explicitly authorized and sent using the existing macOS Keychain credential. The request used the bounded Safari-fixture payload only:

- Model: `jev-1.13.0`
- Workflow: `jev-mac-safari-fixture-v1`
- Final command fragment: `Show me the reviewed fixture`
- Fixture version: `safari-fixture-v1`
- Fixture view: `landing`
- Closed capability IDs and descriptions from the local registry
- Synthetic request, candidate-set, session, and action-attempt identities

The payload contained no screenshots, audio, Accessibility trees, personal data, credentials, URLs, shell text, or full session history.

## Sanitized provider result

```text
LIVE_PROBE_HTTP_STATUS=403
LIVE_PROBE=provider_error
PROVIDER_ERROR_KEYS=detail
```

The response body was not retained. The exact provider-side reason is therefore unknown. No selection was received, no local capability was dispatched, and no action was replayed.

## Preflight evidence

- Target-Mac tests: **87 tests, 0 failures**
- Debug `JevMacShell` build: passed
- Release `JevMacShell` build: passed
- Keychain item presence after the request: confirmed
- `jev.liveSelection.enabled` immediately after the request: `1`
- Fail-closed reset after the 403: `jev.liveSelection.enabled=0` confirmed
- No credential value was displayed, logged, or copied into the repository

## Decision

Gate 2 remains **blocked**. The 403 proves that the current configured account/request combination cannot be treated as an approved live path. The supported causes include account authorization, agreement, model/API access, or provider policy, but this result alone does not distinguish them.

No further provider call should be made until the account owner or TypeSafe support confirms the applicable agreement and the reason for the 403. If a retry is later authorized, it must be a newly approved request with fresh request identity and the same synthetic-only egress boundary.

See also: `Docs/TYPESAFE_GATE_2_REVIEW.md` and `Docs/DATA_EGRESS.md`.
