# Test Matrix

## Evidence Classes

- **Fixture:** pure local deterministic evidence, no Mac permission or network.
- **Mac:** manual/automated run on the target macOS environment with synthetic data.
- **Provider:** fixture-backed transport first; live provider only after the authorization gate.
- **UI:** SwiftUI/XCTest or approved runtime interaction evidence on a real Mac.

## Unit and Integration Coverage

| Area | Test cases | Evidence target |
| --- | --- | --- |
| Action domain | Codable round trip, unique IDs, risk encoding, payload remains non-executable | Fixture |
| Observation | ID/timestamp preservation, incomplete state, candidate stability, stale identity | Fixture |
| Session state | Valid transitions, terminal states, no concurrent actions | Fixture |
| Cancellation | Stop during speech, Jev request, executor, verifier | Fixture then Mac |
| Policy | Low/medium/high risk, threshold routing, hard confirmation precedence, reason codes | Fixture |
| Freshness | Changed app/window/focus, expired observation, mismatched candidate | Fixture then Mac |
| Response parsing | Valid Choice, probabilities, confidence, unknown/missing/malformed answer | Fixture |
| HTTP error mapping | `401`, `422`, `429`, `529`, timeout, cancellation | Fixture |
| Redaction | Authorization header, API key, passwords, clipboard/private values | Fixture |
| Permission UI | allowed, denied, restricted, revoked copy and action | Fixture then Mac |
| Speech | partial, final, ended, stale partial, cancellation, microphone denial | Fixture then Mac |
| Orchestrator | fake Jev/fake observation/fake executor/fake verifier end to end | Fixture |

## Real-Mac Acceptance

| Scenario | Expected result | Evidence |
| --- | --- | --- |
| Launch menu-bar app | App appears without requesting permissions | Mac/UI |
| Push-to-talk | Partial and final transcript appear; release ends capture | Mac/UI |
| Open Notes | Notes becomes active and verifier reports it | Mac |
| Create synthetic note | Note created only in test fixture/account | Mac |
| Search browser | Expected synthetic/local query opens | Mac |
| Cross-app copy | Only approved synthetic title transfers | Mac |
| Ambiguous command | Ask-user or stop; no action | Mac |
| Missing Accessibility | Explains block; no action | Mac |
| Stop | Current loop stops and no new action begins | Mac/UI |
| Delete/send/publish | Confirmation or default block; no mutation before approval | Mac |
| Jev unavailable | Consequential action stops; no replay | Provider/Mac |
| Network unavailable | Stop and explain; no replay | Provider/Mac |

## Gate Conditions

- No Mac readiness claim until the exact build and test commands pass on the target.
- No provider readiness claim until the terms/access gate is closed and fixture tests pass.
- No controlled-dogfooding claim until all required real-Mac scenarios pass with synthetic data.
