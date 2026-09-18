# Product and Safety Contract

## Status

This is the corrected v0.1 contract for a private macOS prototype. It is approved for repository orientation and feasibility probes. It is not permission to implement generic Mac automation, enable live Jev, distribute the app, or publish performance claims.

## First Slice

The first slice controls one preflighted, synthetic, local Safari fixture:

```text
push to talk
  -> partial and final transcript revisions
  -> deterministic eligibility gate
  -> exact fixture capability candidates
  -> Jev selects one eligible operation, wait, stop, or ask_user
  -> policy revalidates target and authorization
  -> one trusted Safari fixture operation
  -> exact fixture state verification
  -> continue, complete, stop, or outcome_unknown
```

The first slice must exercise real candidate selection across varied commands and starting states. It must not be a fixed sequence with Jev inserted for appearance.

## First-Slice Capabilities

Only the reviewed capabilities in `Docs/CAPABILITY_REGISTRY.md` may be represented or dispatched:

- Activate a preflighted Safari fixture.
- Select a reviewed fixture view.
- Wait for a reviewed fixture state.
- Stop.
- Ask the user.

Observation is an internal service, not a Jev-selected capability. No generic click, type, URL, clipboard, Notes, shell, AppleScript, uncontrolled navigation, or arbitrary Accessibility operation exists in this slice.

## Authority and Safety

- Capability definitions are created locally from trusted code.
- Jev may select only an eligible capability ID supplied in the exact request.
- Page text, Accessibility labels, titles, URLs, copied content, and Jev output are untrusted data. They cannot create capabilities, alter risk, provide confirmation, expand allowlists, or override Stop.
- Policy checks transcript phase, target identity, payload provenance, permission, freshness, risk, confirmation, policy version, and deadline.
- The executor rechecks bindings immediately before dispatch and dispatches once.
- The verifier independently checks the exact postcondition.
- If a native effect may have occurred but cannot be proven, the state is `outcome_unknown`. No automatic retry or replay is permitted.

## Transcript Rules

- Push-to-talk is the only capture mode.
- Releasing the key ends capture and begins finalization. It does not cancel the session and does not authorize a mutation.
- Partial speech may authorize only a predeclared harmless fixture preparation effect, if the deterministic gate passes.
- Final speech is required for the first Safari fixture unless the action is that explicit preparatory exception.
- A late or contradictory transcript revision cannot authorize a new capability.
- `finishCaptureAndFinalize` and `abortSession` are distinct operations.

## Session Dimensions

Capture and action state are separate:

- Capture: `off`, `listening`, `finalizing`, `final`, `cancelled`, `failed`.
- Action: `idle`, `selecting`, `confirming`, `executing`, `verifying`, `completed`, `blocked`, `stopped`, `outcome_unknown`, `failed`.

Every decision and callback binds to session ID, goal ID, transcript revision, observation revision, request ID, candidate-set identity, payload version, policy version, target binding, confirmation identity, and deadline.

## Non-Goals

- Always-on listening.
- Generic Mac automation, arbitrary shell or AppleScript, coordinate clicking, arbitrary typing, arbitrary URLs, public search, uncontrolled websites, clipboard transfer, camera, screenshots, vision, browser extensions, Notes, public distribution, relay infrastructure, cloud sync, telemetry, installer, notarization, and production claims.
- Automatic recovery or replay after uncertain operations.

## Gates

1. **Orientation:** target repository, Mac toolchain, signing, sandbox, permissions, speech mode, hotkey, test capability, and applicable TypeSafe agreement recorded.
2. **Native feasibility:** speech, hotkey, panel, Safari Accessibility, native fixture action, and exact verification observed on the target Mac.
3. **Fake safety loop:** domain, policy, concurrency, stale-target, cancellation, confirmation, budget, and redaction tests pass without network or Accessibility permission.
4. **Live Safari fixture:** only after Jev/TypeSafe authorization, data-egress clearance, and all v2 acceptance criteria pass.
5. **Notes extension:** only if the Safari gate earns it and exact local account, payload provenance, confirmation, adapter, and verifier are observed.

## Evidence Boundary

The repository may state that a contract is defined or a fixture test passes. It must not state that the system is safe, fast, accurate, reliable, production-ready, or generally autonomous without the matching evidence and agreement clearance.
