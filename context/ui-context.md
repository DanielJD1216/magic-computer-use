# UI Context

## Theme

Native macOS utility UI for a bounded action controller, not a chat window. Keep it compact, calm, status-forward, and explicit about target, capability, result, and recovery. The first slice is one local Safari fixture.

## Visual Rules

- Use SwiftUI semantic colors and the user’s macOS accent. Do not invent raw hex values before a real-Mac visual pass.
- Use the macOS system font and accessibility sizes. Monospaced text is reserved for stable diagnostic IDs.
- Use native controls, focus rings, keyboard access, VoiceOver labels, and reduced-motion behavior.
- Status is communicated by text and iconography, never color alone.

| Role | Token | Meaning |
| --- | --- | --- |
| Surface | `Color(nsColor: .windowBackgroundColor)` | Menu-bar popover and panel |
| Secondary surface | `Color(nsColor: .underPageBackgroundColor)` | Activity and recovery rows |
| Primary text | `Color.primary` | State, target, capability |
| Muted text | `Color.secondary` | Timing and recovery context |
| Accent | `Color.accentColor` | Listening and focused control |
| Success | Semantic green | Exact postcondition verified |
| Warning | Semantic orange | Finalizing, confirming, stale, incomplete |
| Error | Semantic red | Blocked, failed, permission, unknown effect |

## Components

Create reusable components only for repeated product states:

- `StatusIndicator`
- `TranscriptRevisionView`
- `TargetBindingRow`
- `CapabilityProposalRow`
- `ConfirmationView`
- `StopButton`
- `PermissionRow`
- `VerificationResultView`
- `ActivityEventRow`

## Layout

- Menu-bar popover: current state, Safari fixture target, primary capability/result, Stop, and settings/permissions.
- Floating command panel: transcript above target and capability, one current goal, persistent Stop while active.
- Confirmation surface: exact effect, target, consequence, expiry, Confirm and Stop. No ambiguous primary action.
- Error/blocked surface: what did not happen, why it stopped, and one safe next action.
- Activity history: redacted event IDs, phases, capability, result, timing, and delete-history control.

## Interaction Semantics

Show partial and final transcript revisions distinctly. Release moves to `Finalizing`; Stop is a separate explicit action. Show selection, execution, verification, completion, blocked, failed, and `outcome_unknown` as distinct states. Never show a model confidence value as permission.
