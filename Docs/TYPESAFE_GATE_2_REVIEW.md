# TypeSafe Gate 2 Review

## Status

**BLOCKED BY PROVIDER RESPONSE. Do not retry or treat live TypeSafe transport as ready.**

Last checked: `2026-09-20T19:13:53-07:00`.

The decision under review is whether JevMacShell may make live TypeSafe requests for a minimized, synthetic Safari-fixture policy state. This is an operational and product authorization review, not legal advice. One explicitly authorized synthetic request was made and failed closed; no credential value was requested, displayed, or used in chat.

## Direct verdict

The public sources confirm the API shape and describe more than one possible commercial or preview agreement, but they do not establish which agreement governs Daniel's account, whether the intended DOO MADE prototype use is permitted under that agreement, whether credits or paid usage apply, or whether direct client calls are authorized.[1][3][5] Keep live transport disabled until those account-specific facts are confirmed.

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
| Applicable account agreement | **Unknown** | The public preview terms and entity Master Customer Agreement have materially different scopes.[1][3] Account-specific agreement and Order are not available in the repository.[unverified] |
| Authority to accept/use the applicable agreement | **Unknown** | No account owner or organizational authorization has been recorded for this integration.[unverified] |
| Intended use is permitted | **Unknown** | The preview terms restrict third-party/service use and preview evaluation.[1] The intended DOO MADE prototype relationship to those restrictions requires an account-specific decision. |
| Direct API call versus relay | **Unknown** | Public API docs show an API-key request, but do not decide whether this account permits a direct client, relay, or both.[5] |
| Payload data classification | **Conditionally bounded** | The implementation can send only a minimized synthetic fixture state.[6] This reduces exposure but does not eliminate provider processing, retention, telemetry, or transfer.[2][3] |
| Retention, deletion, telemetry, and subprocessors | **Insufficient for enablement** | Public policies describe broad retention or telemetry handling.[2][3] The account-specific terms and applicable DPA are not confirmed.[4][unverified] |
| Credits, rate limits, and material cost | **Unknown** | The entity agreement describes credits,[3] but the active account balance, pricing, refill behavior, and agreement are unknown.[unverified] |
| Credential path | **Locally designed, not authorized** | The intended storage boundary is macOS Keychain only.[unverified] No credential should be entered until the provider and account gates close. |
| Live synthetic smoke test | **Blocked** | Requires the preceding decisions and explicit approval of a live provider call.[unverified] |

## Required owner decisions

1. Identify the agreement that governs the TypeSafe account used for this prototype: preview Terms of Service, an entity Master Customer Agreement and Order, or another account-specific document.
2. Confirm that the intended use is Daniel's private synthetic-fixture evaluation and state whether it is allowed to support a DOO MADE-owned prototype. Do not assume that a private UI makes it acceptable under the preview restrictions.[1]
3. Choose direct API transport or an approved relay. The implementation should not infer this from the existence of a public endpoint.[5]
4. Confirm whether consuming credits or triggering any paid or auto-refill behavior is authorized.[3] No paid or live call is included in this phase.
5. Confirm the permitted data boundary. The recommended first probe remains synthetic Safari-fixture state only, with no raw transcripts, personal data, screenshots, Accessibility values, credentials, URLs, or customer content.[2][4][6]

## Recommended next action

Keep the code and UI default-off. The next physical action is to inspect the TypeSafe account's governing agreement, credit status, and account-specific data handling, or obtain written confirmation from TypeSafe. Do not paste an API key into chat or the repository. Once those facts are available, a separate approval can authorize or reject a target-Mac synthetic smoke test.

## Live smoke outcome

One explicitly authorized synthetic request was sent from the configured target Mac after the local test and build gates passed. It returned HTTP `403` with a provider error body whose only retained field was `detail`; the response body was not retained. No selection or local action resulted, and no retry was made. Full sanitized evidence is recorded in `Docs/TYPESAFE_LIVE_SMOKE_RESULT.md`.

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
