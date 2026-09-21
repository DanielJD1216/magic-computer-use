# Test Matrix

## Evidence Classes

- **Fixture:** deterministic local tests with no Mac permission, network, or live Jev.
- **Mac:** target-Mac runtime and permission evidence using synthetic data.
- **Provider:** fixture transport first; live provider only after agreement and egress gates.
- **UI:** SwiftUI/AppKit interaction evidence on the target Mac.

## Domain and Policy Tests

| Area | Required cases | Evidence |
| --- | --- | --- |
| Capability registry | Exact IDs, unique IDs, immutable payload provenance, no executable parameters | Fixture |
| Candidate validation | Membership, unknown ID, wrong answer type/key, malformed confidence/probability, stale request | Fixture |
| Binding | Session, goal, transcript, observation, candidate set, payload, policy, target, confirmation, deadline | Fixture |
| Transcript | Partial revisions, contradiction, finalization, missing final, late callback, abort versus release | Fixture |
| State model | Independent capture/action dimensions, legal transitions, terminal states, no concurrent dispatch | Fixture |
| Cancellation | Stop during speech, selection, execution, verification, permission callback | Fixture then Mac |
| Unknown effect | Timeout, crash, disconnect, ambiguous native result, failed verification | Fixture then Mac |
| Policy | Final speech gate, target check, permission, risk, confirmation, expiry, reason codes | Fixture |
| Redaction | Audio, credentials, URLs, clipboard, Accessibility values, raw HTTP body, fixture canaries | Fixture |
| Transport mapping | `401`, `422`, `429`, `529`, timeout, cancellation, oversized/invalid response | Fixture |
| Orchestrator | Fake speech, observation, selector, executor, verifier end to end | Fixture |

## Fast Subtask Fixture Tests

| Area | Required cases | Evidence |
| --- | --- | --- |
| Action space | Visible, enabled, operation-compatible targets only | Fixture |
| Input materialization | Trusted input-key lookup; unknown keys and literal model values rejected | Fixture |
| Freshness | Stale target recovery and stale retry limit | Fixture |
| Progress guard | No-change blocking and action-budget termination | Fixture |
| Verification | Independent completion verification before terminal success | Fixture |
| Uncertain effect | Post-action observation failure becomes `outcome_unknown` without replay | Fixture |
| Evidence | Redacted history and canary exclusion from serialized evidence | Fixture |
| Native route wiring | Existing `select_reviewed_fixture_view` enters the bounded executor and returns through an exact Safari readback | Mac |

## First Safari Fixture Acceptance

| Scenario | Expected result | Evidence |
| --- | --- | --- |
| Launch | Menu-bar app opens without unnecessary permissions | Mac/UI |
| Push-to-talk | Partial revisions appear and release begins finalization | Mac/UI |
| Contradictory partial | No unauthorized mutation; final decision follows policy | Fixture/Mac |
| Exact candidate choice | Only a locally registered fixture capability can dispatch | Fixture/Mac |
| Already-satisfied state | Wait or complete according to explicit verifier logic, no duplicate effect | Mac |
| Ambiguous command | Ask user or stop; no operation | Fixture/Mac |
| Missing Accessibility | Clear block; no native action | Mac/UI |
| Stop | No later callback can dispatch | Fixture/Mac |
| Timeout or disconnect | Failure or `outcome_unknown`; no automatic replay | Fixture/Mac |
| Hostile fixture text | Cannot create capability, confirmation, or policy override | Fixture/Mac |
| Privacy canary | Prohibited values stay out of egress and ordinary logs | Fixture/Mac |

## Gate Conditions

- No native readiness claim until platform probes and exact build/test commands pass on the target Mac.
- No live Jev readiness claim until authorization, provider handling, egress, and fixture tests pass.
- No Notes extension until the Safari fixture gate earns it.
- No controlled dogfooding or public claim until the full v2 acceptance criteria and publication clearance pass.
