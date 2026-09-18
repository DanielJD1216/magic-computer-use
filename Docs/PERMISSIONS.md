# Permissions

This document describes the intended permission posture for the private macOS prototype. Exact Info.plist keys, bundle identifiers, and recovery URLs must be verified against the target Xcode/macOS version.

## Principle

Request the least permission needed for the capability the user explicitly enables. Explain scope and recovery before requesting. A denied or revoked permission must block the affected capability and never produce a false success.

## Permission Order

1. **Microphone**: only when push-to-talk capture starts or the user enables speech setup.
2. **Speech recognition**: only when the selected transcription adapter requires Apple's recognition service.
3. **Accessibility**: only when the user enables computer actions or an observation/executor requires it.
4. **Automation**: only for a specific workflow that cannot use a safer native or Accessibility path.

## UI Requirements

For each permission show:

- Name and current status.
- What the app can do with it.
- Why the current workflow needs it.
- What will not happen if it is denied.
- The exact next safe action, including System Settings when applicable.
- A cancel/continue-without-that-capability path.

## Privacy

- No permission is requested merely by launching the menu-bar app.
- Audio is not sent to Jev. The Jev state is text/JSON only.
- Accessibility values are minimized and sensitive values are omitted by default.
- Automation access is not treated as a general authorization to control every app.

## Test Matrix

| Permission | Allowed | Denied | Restricted/revoked | Expected app behavior |
| --- | --- | --- | --- | --- |
| Microphone | Capture begins | Capture does not begin | Show recovery | Remain safe and explain |
| Speech recognition | Partial/final events | No transcript | Show adapter limitation | Stop or allow typed/fake test |
| Accessibility | Observe/execute bounded action | No computer action | Recheck before execution | Block and explain |
| Automation | Specific integration works | Integration unavailable | Show workflow-specific recovery | Use safer fallback or stop |

## Open Mac Checks

- Confirm exact permission APIs and Info.plist usage on the supported macOS version.
- Confirm sandbox entitlements and signing behavior.
- Confirm Accessibility test strategy does not require granting permissions to an unreviewed build.
