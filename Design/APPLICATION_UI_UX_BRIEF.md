# Application UI/UX Brief

## Orientation

- **Surface:** Native macOS menu-bar utility with a floating command panel.
- **User:** One developer/operator running controlled synthetic workflows.
- **First target:** One preflighted, local Safari fixture.
- **Primary job:** Speak a bounded goal, see transcript revisions and the selected exact capability, stop safely, and know whether the fixture state was verified.
- **Current evidence:** The target Mac has not yet been authenticated for inspection. No high-fidelity or native readiness claim is made.

## Product Feel

Compact, calm, and explicit. The UI should feel like a control surface, not a chat window. Prefer a single current goal over a conversation history. Every consequential transition has a readable state, target, action, and recovery path.

## Primary Surface

```text
[ status dot ]  Safari fixture                  [Stop]

Listening
"open the reviewed fixture view"

Target     Safari • Fixture v1
Decision   Selecting from 3 reviewed capabilities
Result     Not dispatched

[ Stop ]   [ Ask me ]
```

The menu-bar item exposes state using both text and color. The panel shows one current transcript revision, target identity, candidate/action summary, elapsed time, and the next safe control.

## Required States

| State | Meaning | Controls | Safe behavior |
| --- | --- | --- | --- |
| Off | No capture or action active | Activate, settings | No permission prompt on launch |
| Armed | Push-to-talk ready | Hold to speak, cancel | No audio sent, no action selected |
| Listening | Microphone active | Release, stop | Show clear capture indicator and partial transcript |
| Finalizing | Capture ended, final transcript pending | Stop | No mutation dispatch until finalization rules pass |
| Selecting | Exact candidates are being evaluated | Stop | Show target and candidate-set status, not confidence as authority |
| Confirming | Local policy requires approval | Confirm, stop | Explain exact effect and target |
| Executing | One approved operation is running | Stop | No concurrent dispatch |
| Verifying | Expected postcondition is being checked | Stop | Do not call executor success verified |
| Completed | Exact fixture result observed | Dismiss, next command | Show concise verified result |
| Blocked | Policy, permission, agreement, or stale state prevents action | Explain, settings, stop | Nothing consequential runs |
| Stopped | User ended the session | Dismiss, start again | No queued callback can resume it |
| Failed | Operation failed with known result | Fresh observation, dismiss | No silent retry |
| Outcome unknown | Native effect may have occurred | Fresh observation, dismiss | No retry or reversal claim |
| Permission required | Named macOS capability is missing | Explain, settings, cancel | Request only the current capability |

## Interaction Rules

1. Press and hold the push-to-talk control to enter `Listening`.
2. Show partial transcript revisions without creating chat history.
3. Release to enter `Finalizing`; keep the current goal alive while final speech resolves.
4. Show the exact Safari fixture target and locally generated candidate count.
5. Show the selected capability in plain language before dispatch.
6. Keep Stop visible during selection, execution, and verification.
7. After completion show the verified postcondition, not raw page content.
8. On stale state, invalid selection, timeout, permission failure, or uncertain effect, explain the safe next step and require a fresh goal where necessary.

## Accessibility and Permission UX

Status is never conveyed by color alone. Buttons have labels and keyboard paths. Permission copy names the capability, why it is needed, and how to revoke it. Do not request Accessibility just to render the panel.

## Visual Boundary

No screenshots, vision, browser extension, external site, Notes, or generic automation UI is required for this slice. Those are separate decisions after the Safari fixture gate.
