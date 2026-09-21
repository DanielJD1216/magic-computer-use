# Capability Registry

This registry is the trust boundary for v0.1. Code creates these exact capabilities. Jev selects an ID; it never supplies executable parameters.

## Registry Entries

| ID | Target binding | Allowed effect | Transcript requirement | Confirmation | Verifier |
| --- | --- | --- | --- | --- | --- |
| `activate_preflighted_safari_fixture` | Known Safari process and versioned local fixture window | Activate the known fixture only | Final transcript, unless explicitly pre-authorized as harmless preparation | No external visibility; local policy still checks | Safari process, window, and fixture identity |
| `select_reviewed_fixture_view` | Known fixture window and reviewed local view identity | Select one reviewed fixture view through the tested native path | Final transcript | No, if the view operation is explicitly classified harmless and current | Exact fixture view state |
| `return_to_landing_fixture_view` | Known fixture window and reviewed local view identity | Press the fixed control that returns the local fixture to its landing view | Final transcript | No, reversible synthetic fixture transition | Exact fixture view state |
| `wait_for_reviewed_fixture_state` | Known fixture and named state | Wait with a deadline and budget | Final or stable eligible transcript | No | Named state observed before deadline |
| `stop` | Current session | Invalidate future dispatch authority | Any phase | No | Session cannot dispatch after invalidation |
| `ask_user` | Current session | Request clarification or approval without native effect | Any ambiguous or confirmation-required phase | User response is separate, exact, and expiring | Explicit response identity |

`observe_fixture_state` is an internal observation service. It is not a candidate and cannot be selected as an action.

## Candidate Shape

The implementation may map this logical shape into repository conventions:

```swift
struct CapabilityCandidate: Identifiable, Codable, Equatable {
    let id: String
    let description: String
    let targetBinding: TargetBinding
    let effect: AllowedEffect
    let payloadProvenance: PayloadProvenance
    let transcriptRequirement: TranscriptRequirement
    let confirmationRequirement: ConfirmationRequirement
    let expiresAt: Date
    let verifierID: String
    let policyVersion: String
}
```

The candidate must also bind to session ID, goal ID, transcript revision, observation revision, request identity, candidate-set identity, and an immutable payload version before dispatch.

## Construction Rules

- The registry is locally defined and versioned.
- Candidate IDs are stable and unique within a candidate set.
- Targets are exact process/window/fixture identities, not labels supplied by a page or model.
- Payload provenance must be `none`, `explicit_user_input`, or `declared_fixture`; arbitrary model-generated or page-generated payloads are not allowed.
- The candidate contains no executable selector, arbitrary URL, AppleScript, shell text, credential, page command, or free-form keyboard command.
- Candidates expire when the target, transcript revision, observation, payload, policy version, or deadline changes.
- Unsupported effects cannot be represented, even behind confirmation.

## Jev Response Boundary

Accept only the selected ID plus documented response metadata. Validate:

- Response type and question key.
- Candidate ID membership in the exact request candidate set.
- Probability keys, finite values, ranges, and confidence type/range.
- Request identity, session identity, transcript/observation revisions, policy version, deadline, and response size.

Reject unknown IDs, wrong answer types, unknown fields that could carry executable data, malformed distributions, stale bindings, and late responses. The native executor accepts only a locally constructed validated operation.

## Deferred Capabilities

These do not exist as Jev-selected capabilities yet:

- `create_exact_local_note`, pending Safari gate and Notes feasibility.
- The current TextEdit workspace probe is an explicit app action, not a live Jev or voice-selected capability.
- Generic click, type, copy, URL, browser navigation, shell, AppleScript, send, delete, purchase, publish, share, account, or system-setting operations.
