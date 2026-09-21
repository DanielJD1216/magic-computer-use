# UX Acceptance Checklist

This checklist gates the private Safari-fixture prototype. It is not representative-user usability evidence and does not authorize live Jev, distribution, or external claims.

## Orientation and Trust

- [ ] Menu-bar item has a text-accessible state label and does not rely on color.
- [ ] Panel identifies the exact Safari fixture target and fixture version.
- [ ] User can distinguish off, armed, listening, finalizing, and final transcript.
- [ ] Current transcript revision is visible and marked partial or final.
- [ ] Selected capability is plain language and maps to a closed registry ID.
- [ ] Selecting, confirming, executing, verifying, completed, blocked, stopped, failed, and `outcome_unknown` are distinct.
- [ ] Stop remains available during all active phases and does not wait on Jev/network.

## Permissions

- [ ] Launch does not request microphone, speech, or Accessibility by itself.
- [ ] Each permission explains purpose and recovery before request.
- [ ] Speech denial or unavailability has a safe recovery path.
- [ ] Accessibility is requested only for the reviewed fixture path.
- [ ] Missing permission never shows success.

## Capability Safety

- [ ] Registry contains only the exact reviewed v0.1 capabilities.
- [ ] Observation is internal, not a selectable action.
- [ ] Unknown IDs, unknown executable fields, stale bindings, malformed responses, and expired confirmations are rejected.
- [ ] Final speech is required for the first Safari operation.
- [ ] Key release finalizes capture and does not cancel.
- [ ] Executor accepts only locally constructed operations.
- [ ] No shell, arbitrary URL, generic typing, coordinate clicking, clipboard, screenshot, vision, external website, Notes, or publication path exists.
- [ ] Verification is independent of executor success.

## Recovery

- [ ] Stop during speech, selection, execution, and verification invalidates future callbacks.
- [ ] Every asynchronous callback rejects stale session or action identity.
- [ ] Timeout, disconnect, crash, or uncertain native boundary shows `outcome_unknown` where appropriate.
- [ ] Unknown effect requires fresh observation and does not auto-replay.
- [ ] Contradictory partial speech cannot authorize an unreviewed effect.
- [ ] Hostile fixture text cannot create a capability or override policy.

## Privacy and Experiments

- [ ] Speech mode is documented as on-device or explicitly consented remote.
- [ ] Egress is field-allowlisted and tested with synthetic canaries.
- [ ] Provider retention and agreement status are recorded before live transport.
- [ ] Ordinary logs contain no credentials, raw transcripts, clipboard, private values, or raw bodies.
- [ ] Experiment modes, timing checkpoints, baselines, samples, and failure handling are predeclared.
- [ ] No public performance, safety, or accuracy claim is made without `Docs/PUBLICATION_CLEARANCE.md`.

## Mac Gate

- [ ] Menu-bar app launches with no side effects.
- [ ] Push-to-talk partial and final revisions work on the target Mac.
- [ ] Safari fixture identity and Accessibility path are verified.
- [ ] One registered native fixture operation executes and exact postcondition verifies.
- [ ] Already-satisfied, ambiguous, stale-target, missing-permission, timeout, disconnect, and stop scenarios pass.

## Experimental Desktop Mode

- [ ] Native Swift, bounded CuaDriver, and experimental desktop modes are visibly distinct.
- [ ] Experimental mode names the current Mac session and states that it is not isolated.
- [ ] Enabling experimental mode requires an explicit confirmation.
- [ ] Bounded mode remains available as the recovery path and is mutually exclusive with experimental mode.
- [ ] The task composer, current target, controller status, Stop, Reset, and activity history are present.
- [ ] Send remains disabled when the Hermes controller bridge is unavailable.
- [ ] The UI does not claim that unrestricted CuaDriver daemon state is a working Hermes bridge.
- [ ] No task body, credential, screenshot, raw Accessibility tree, or provider response is written to activity history.
- [ ] All active controls have accessible labels, keyboard focus, and non-color status text.
- [ ] Permission, unavailable, blocked, executing, stopped, failed, and outcome-unknown states have an explicit recovery or explanation.

## Evidence Labels

- **Contract defined:** docs specify behavior.
- **Fixture verified:** deterministic tests pass without Mac or live network.
- **Mac verified:** exact scenario, OS, app, permissions, and observed result recorded on target Mac.
- **Live authorized:** agreement, provider handling, egress, and credential gate are closed.
- **Ready for controlled internal use:** all fixture and Mac gates pass. This does not mean safe, fast, accurate, or production-ready.
