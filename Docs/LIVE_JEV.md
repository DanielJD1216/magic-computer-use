# Live Jev Selector

## Scope

This adapter is the live TypeSafe integration for the private Safari-fixture prototype. Jev is a bounded selector only. Native Swift remains authoritative for target binding, capability membership, policy, dispatch, cancellation, and exact verification.

The adapter cannot represent generic click, typing, navigation, shell, AppleScript, publishing, account, purchase, deletion, or sharing operations.

## Provider contract

- Endpoint: `https://api.typesafe.ai/v1/systemone`
- Model: `jev-latest`
- Question: one `choice` question named `capability`
- Credential: TypeSafe API key stored only in the macOS Keychain
- Transport: one bounded request, no automatic retry, no fallback to the local deterministic router when live mode is enabled

The implementation was based on the current official TypeSafe API, State, Choice, Models, and legal-index pages. Daniel has confirmed the applicable account agreement, DOO MADE approval, direct transport posture, refill setting, and retention/data-processing conditions for this bounded private prototype. That owner confirmation does not authorize production use or broader data egress.

## Allowlisted outbound state

The request contains only:

- A bounded final command fragment, maximum 240 characters.
- Request, candidate-set, session-generation, and action-attempt identities.
- The synthetic fixture version and current local fixture view.
- The exact locally generated candidate IDs and descriptions.
- The fixed question asking Jev to select one supplied capability ID.

The request never contains audio, screenshots, full Accessibility trees, clipboard contents, credentials, authenticated URLs, arbitrary selectors, shell text, page instructions, or full session history. Common credential and URL markers in the final command are rejected before serialization.

## Response boundary

The response must contain exactly one `capability` answer of type `choice`. The adapter rejects malformed JSON, wrong answer types, probability keys that differ from the exact candidate set, non-finite or out-of-range probabilities/confidence, and IDs outside the local registry. The native executor receives a locally reconstructed `SelectionResponse`, never provider data or executable parameters.

A stale response is discarded by the session-generation and action-attempt checks. A live transport error blocks the goal. It does not invoke the local router, retry a native effect, or replay an uncertain action.

## Mac activation

1. Open the **Jev Command Panel** from the menu-bar app.
2. Click **Settings…** at the bottom of the panel. You can also use the app's macOS **Settings…** menu item.
3. In the settings sheet, use the **TypeSafe credential** section.
4. Enter the TypeSafe API key directly into the SecureField on the Mac.
5. Click **Save to Keychain**.
6. Enable **live Jev selection**.
7. Re-add the newly rebuilt app bundle to Accessibility if macOS invalidates the ad-hoc identity.
8. Connect the exact local Safari fixture and use the existing final-transcript flow.

The UI shows only whether a Keychain credential exists. It never displays or logs the credential.

Do not use `security find-generic-password -w` over SSH to export the credential for a live probe. A Keychain item can be present while non-GUI secret export fails; the native app must read it through `JevCredentialStore` and send the request through its own URLSession path. Diagnostic harnesses must fail closed if the credential read fails or returns an empty value.
