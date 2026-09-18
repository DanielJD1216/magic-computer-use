# Permissions

This document describes the intended least-privilege posture for the private Safari-fixture prototype. Exact API names, Info.plist keys, bundle identifier, entitlements, and recovery URLs must be verified on the target macOS version.

## Principle

Request only the capability needed by the current user intent. Explain scope and recovery before requesting. A denied or revoked permission blocks the affected capability and never produces a false success.

## Permission Order

1. **Microphone:** when push-to-talk capture starts or speech setup is explicitly enabled.
2. **Speech recognition:** only for the selected transcription adapter.
3. **Accessibility:** only when the reviewed Safari observation or execution path requires it.
4. **Automation:** not part of the first slice; only consider it for a specific later workflow that cannot use a safer path.

## UI Requirements

Show the permission name, current status, capability requiring it, why it is needed, what will not happen if denied, the exact next safe action, and a cancel path. Request one permission at a time.

## Speech Privacy

Speech mode is unresolved until target-Mac probes. Prefer on-device recognition if supported. Never silently switch to remote speech recognition. Any remote speech path requires explicit consent, allowlisted fields, provider handling, and agreement clearance. Live Jev remains disabled while these are unresolved.

## Safari Fixture

Accessibility values are minimized. Do not request Accessibility merely to render the menu-bar or command panel. The app cannot dispatch a fixture operation if Accessibility is missing, withdrawn, stale, or not verifiable.

## Test Matrix

| Permission | Allowed | Denied/revoked | Expected behavior |
| --- | --- | --- | --- |
| Microphone | Capture begins | Capture does not begin | Explain and remain safe |
| Speech recognition | Partial/final events | No transcript | Explain adapter limitation or use a fake test |
| Accessibility | Reviewed fixture path works | No fixture action | Block and explain |
| Automation | Not required in v0.1 | N/A | Do not request |

## Open Mac Checks

- Confirm exact permission APIs and Info.plist use.
- Confirm on-device speech support and locale behavior.
- Confirm sandbox entitlements and signing.
- Confirm Accessibility testing does not grant an unreviewed build broad access.
