# TypeSafe Gate 2 Review

## Status

**GATE 2 CONDITIONALLY APPROVED FOR THE CURRENT BOUNDED PAYLOAD. BROADER DATA SCOPE REMAINS CLOSED.**

Last checked: `2026-09-21T02:05:37-07:00`.

The decision under review is whether JevMacShell may make live TypeSafe requests for a minimized, synthetic Safari-fixture policy state. This is an operational and product authorization review, not legal advice. One malformed harness probe and three later SSH harness probes were made; the SSH probes failed to export the Keychain value and their 403 outputs are invalid direct-API evidence. One separately authorized native GUI-app probe then used the app-owned Keychain and URLSession path and received a valid closed-choice selection. No credential value was requested, displayed, or used in chat.

## Accelerated disposition

This Gate 2 review is intentionally split into evidence that code and public
documentation can close, and owner decisions that they cannot:

### Closed by evidence

- The official API contract and `jev-latest` alias were rechecked on
  `2026-09-21`; the documented endpoint is the TypeSafe System One HTTP API
  with bearer authentication and typed questions.[5]
- The native app transport is technically proven with a minimized synthetic
  fixture request. The earlier SSH `403` results remain invalid because the
  SSH Keychain value read failed with exit `36`.
- The local payload boundary is implemented as fixed workflow and fixture
  metadata, closed capability IDs and descriptions, and a bounded final
  command fragment. It excludes screenshots, audio, Accessibility trees,
  credentials, URLs, documents, and customer content.[6] The command fragment
  is screened for known secret and URL canaries but is not a general privacy
  classifier.
- The deployed bounded Accessibility routes are technically verified without
  another provider request. This does not expand the provider authorization.

### Closed by owner confirmation

- Daniel confirmed that the signed-in account, company TypeSafe contract or
  Order, DOO MADE approval, automatic-refill setting, and applicable
  retention/data-processing conditions were checked and verified.
- This is owner confirmation recorded from chat, not an independent legal or
  account audit. It is sufficient to proceed with the current bounded private
  prototype posture, not to make a production, public-service, or broader-data
  authorization claim.

The fast path is complete. No additional provider request, Mac deployment, or
Accessibility cycle is needed to close this review for the current bounded
payload.

## Owner-stated posture

On `2026-09-21`, Daniel stated the following intended posture in plain
English:

- DOO MADE is the approving entity for this use.
- A company TypeSafe contract or Order should govern the account.
- Direct TypeSafe API calls from the Mac app are acceptable in principle.
- TypeSafe usage may continue against the existing account balance, with
  automatic refill off. Daniel stated that the balance is about `$5`; if more
  usage is needed, he will fund it manually. No payment details are recorded.
- Daniel stated that non-secret information may leave the Mac. This is an
  owner-level intent, not permission for the implementation to bypass its
  current bounded payload allowlist.
- Daniel subsequently confirmed that the account, contract or Order,
  DOO MADE approval, refill setting, and applicable retention/data-processing
  conditions were verified.

The implementation keeps two safeguards in force:

- Automatic refill remains disabled. The stated `$5` balance is not an
  independently verified billing or pricing record.
- The live adapter remains limited to its existing bounded request shape. Any
  broader payload requires a field-by-field data-egress review and a code
  change; it is not enabled by the owner statement alone. In particular,
  transcripts, screenshots, Accessibility trees, documents, customer content,
  credentials, URLs, and secrets remain prohibited by the current build.

## Actual outbound fields in the current build

The current `LiveJevSelectionAdapter` request is bounded, but its boundary is
more precise than the phrase “all non-secret information.” The request can
contain:

- fixed workflow and model identifiers;
- request, candidate-set, session-generation, and action-attempt identifiers;
- `transcriptPhase = final`;
- a trimmed `commandFragment` from the final recognized command, limited to
  240 characters and rejected when it contains the current secret, token, or
  URL canaries;
- fixture version and current fixture view;
- locally generated candidate IDs and descriptions; and
- the closed Choice question instructions and criteria for those candidates.

The response is parsed locally for model, one selected capability, the exact
probability set, and confidence. Raw provider bodies are not retained or
logged by the client. The command-fragment screen is not a general-purpose
privacy classifier. Therefore the owner statement allowing non-secret data
does not authorize arbitrary user text, personal data, or customer content to
be sent. A broader boundary requires an explicit field-by-field review and a
code change.

## Direct verdict

The public sources confirm the API shape and current Jev model aliases. The signed-in console can run Jev, and the native JevMacShell path can also run the bounded direct API request: it returned `select_reviewed_fixture_view` through `LiveJevSelectionAdapter`. The earlier HTTP `403` outputs came from an SSH harness that ignored `security -w` exit `36` and could send an empty Bearer value; they do not establish provider denial. The technical transport issue is resolved. The target Mac's deployed user app is configured for live selection by explicit instruction, while the independent authorization, egress, and account-agreement gates remain open.[1][3][5] After the deployed bundle received Accessibility approval, the bounded Safari and Jev-owned TextEdit routes were exercised without sending another provider request.

## Confirmed public evidence

### API contract

The official API reference documents `POST https://api.typesafe.ai/v1/systemone` with a bearer API key, a `state`, a `model`, and a named `questions` map. It currently identifies `jev-latest` as the flagship model.[5]

The `Choice` primitive returns a selected option and a full probability distribution. The documentation allows up to 255 options per Choice and documents `401`, `422`, `429`, and `529` response classes.[5]

The repository's fixture-backed client matches this shape, validates the exact local option set, and deliberately does not implement a live transport or automatic action replay.[6]

### Preview terms

The public Terms of Service page is marked last updated November 19, 2025.[1] It describes access to the Playground and APIs solely for evaluating the Interfaces, prohibits using the Interfaces on behalf of or to provide a product or service to a third party, and says the preview Interfaces may not be suitable for production use.[1]

Those terms grant TypeSafe a broad license to process Inputs, Outputs, and technical or usage logs to operate and improve its services, while stating that TypeSafe will not train or fine-tune models on Input.[1]

### Privacy policy

The public Privacy Policy says that prompts, data, instructions, and other Input may be collected, and that Input will not be used to train or fine-tune models.[2] It also lists service improvement and analysis of service use as purposes, and permits retention for as long as reasonably necessary for service or business purposes.[2]

The policy says the Services are hosted in the United States, so a live request from the Vancouver-based Mac would cross the local-only boundary even if the payload contains only synthetic fixture data.[2]

### Master customer agreement

The public Master Customer Agreement is a separate entity-and-Order agreement marked last updated August 27, 2026.[3] It expressly describes integrating the API into Customer Applications, but that permission is conditional on the applicable Order, Documentation, usage limits, and the rest of the agreement.[3]

That agreement says TypeSafe may process Customer Data to provide the service and derive Telemetry, and may process Telemetry without restriction to improve services. It also describes TypeSafe-managed credits consumed by submitted Input.[3]

### Data processing addendum

The public DPA describes a controller/processor relationship, documented instructions, subprocessors, security measures, and international transfers for Customer Personal Data.[4] It does not prove that the DPA applies to Daniel's account or to a synthetic-only private prototype.[unverified]

## Gate checklist

| Gate item | Status | Evidence or blocker |
| --- | --- | --- |
| Applicable account agreement | **Owner-verified, not independently audited** | Daniel confirmed that the signed-in account and company TypeSafe contract or Order were checked. The agent did not inspect account credentials or reproduce the private agreement.[1][3] |
| Authority to accept/use the applicable agreement | **Owner-verified, not independently audited** | Daniel confirmed the DOO MADE approval posture. The agent did not inspect a private authorization artifact. |
| Intended use is permitted | **Conditionally approved for current private prototype** | Daniel confirmed the account and applicable conditions. This does not authorize production, public service, or broader data use.[1] |
| Direct API call versus relay | **Owner-verified: direct API** | Daniel confirmed the direct Mac-to-TypeSafe posture for this bounded prototype.[5] |
| Payload data classification | **Conditionally bounded** | The implementation sends the fixed request fields listed above, including a bounded final command fragment. This reduces exposure but does not eliminate provider processing, retention, telemetry, or transfer.[2][3][6] |
| Retention, deletion, telemetry, and subprocessors | **Owner-verified for current prototype, not independently audited** | Daniel confirmed the applicable retention/data-processing conditions were checked. The public sources still describe provider processing and U.S. hosting.[2][3][4] |
| Credits, rate limits, and material cost | **Conditionally owner-approved** | Daniel confirmed automatic refill is off, stated that the account has about `$5` available, and will add funds manually if needed. The agent did not inspect the billing view.[3] |
| Credential path | **Native GUI path works; SSH export fails** | The GUI app's `JevCredentialStore.hasCredential()` reports a stored item, and the native GUI probe used the app-owned Keychain read successfully. SSH `security -w` returns exit `36` with an empty value and must not be used to drive a provider request. |
| Live synthetic smoke test | **Native selection passed; bounded Accessibility routes verified** | The native GUI probe returned `select_reviewed_fixture_view` through `LiveJevSelectionAdapter` and native `URLSession`. Deployment set the target user's `jev.liveSelection.enabled` preference to `1`. After Accessibility approval, both reversible bounded Safari fixture transitions and the Jev-owned TextEdit workspace route were verified locally. No additional provider request was made during the Accessibility verification. |

## Conditions of approval

1. Use direct API transport only for the current bounded private prototype and
   only through the approved Mac/Keychain path.[5]
2. Keep automatic refill off. Any additional funding remains a manual owner
   action; no payment details are stored in this repository or chat.
3. Keep the implementation's current bounded payload allowlist and the fields
   listed above. If the owner wants broader non-secret data sent, perform a
   separate field-by-field data-egress review before changing code.[2][4][6]
4. Keep production release, public service, customer content, and unrestricted
   desktop automation outside this approval.

## Recommended next action

The native app path proves that the Keychain credential, direct API transport, current model alias, and bounded request work together. The earlier SSH 403 values were invalid because the harness sent an empty or unverified Bearer value. The target Mac is enabled for live selection by explicit instruction, and the deployed bundle now has verified Accessibility approval for the bounded routes. Daniel then confirmed the account, company contract or Order, DOO MADE approval, refill setting, and applicable retention/data-processing conditions. Gate 2 is therefore conditionally approved for the current bounded private prototype. Do not use SSH secret export for future tests, and do not widen the payload without a separate review.

## Live smoke outcome

The first probe used a malformed Authorization header and returned 403, so it is invalid evidence. Three later SSH probes attempted to use the target Mac's Keychain, but `security -w` returned exit `36` with an empty value; the harness failed to check that condition and could send an empty Bearer value. Their 403 outputs are therefore invalid for account diagnosis. Separately, the signed-in console Playground evaluated a default synthetic Noul request successfully with `jev-latest`, and the native JevMacShell probe evaluated the bounded Safari-fixture Choice request successfully with `select_reviewed_fixture_view`. No local capability action resulted. Full sanitized evidence is recorded in `Docs/TYPESAFE_LIVE_SMOKE_RESULT.md`.

## Sources

[1] https://typesafe.ai/terms-and-conditions
    > "User will not, and will not attempt to: (i) use the Interfaces on behalf of, or to provide any product or service to, a third party;"
    > "Typesafe will not train or fine tune any artificial intelligence or machine learning models on Input"
[2] https://typesafe.ai/privacy-policy
    > "We retain personal data about you for as long as reasonably necessary to provide you with the Services, or otherwise in support of our business or commercial purposes."
    > "The Services are hosted in the United States (“U.S.”)."
[3] https://typesafe.ai/legal/mca
    > "TypeSafe may Process Telemetry without restriction, including to improve the Services or TypeSafe’s other products and services."
    > "In order to generate Output or otherwise use the Services, Customer must obtain TypeSafe-managed credits that are consumed by each Input submitted to the Services through Customer’s account"
[4] https://typesafe.ai/legal/data-processing
    > "Typesafe will only Process Customer Personal Data to provide the Services and in accordance with Customer’s documented instructions"
[5] https://docs.typesafe.ai/api
    > "A map of option to rubric description; use null when an option needs no extra detail. You can have a maximum of 255 options per Choice."
    > "When you receive a `429 Too Many Requests` or `529 Overloaded` response, retry the request with exponential backoff instead of retrying immediately."
[6] file:///home/jinni_doo/Dev%20Life/active/Meet%20Jev%2C%20Fastest%20Computer%20Use/Sources/JevCore/TypeSafeChoiceClient.swift
    > "public protocol TypeSafeChoiceTransport: Sendable {"
    > "Set(question.criteria.keys) == allowedChoiceIDs"
    > "try Task.checkCancellation()
        guard !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty"
