# UI Context

## Theme

Native macOS utility UI for an action controller, not a chat window. The interface should be compact, calm, status-forward, and explicit about consequence. Prefer system materials and semantic macOS colors over decorative custom styling. The command bar should make the sequence legible at a glance: state, words heard, proposed action, target application, decision, result, and stop.

## Colors

Use SwiftUI semantic colors and the macOS accent configured by the user. Do not introduce raw hex colors until a visual-system decision is made on a real Mac.

| Role | SwiftUI semantic token | Meaning |
| --- | --- | --- |
| Primary surface | `Color(nsColor: .windowBackgroundColor)` | Utility window and menu-bar popover |
| Secondary surface | `Color(nsColor: .underPageBackgroundColor)` | Activity rows and grouped controls |
| Primary text | `Color.primary` | State and action labels |
| Muted text | `Color.secondary` | Timestamps, supporting context, recovery hints |
| Accent | `Color.accentColor` | Active listening, focused control, selected candidate |
| Success | `Color.green` used semantically | Verified result only |
| Warning | `Color.orange` used semantically | Confirmation, stale or incomplete observation |
| Error | `Color.red` used semantically | Blocked, failed, permission, or network state |

## Typography

Use the macOS system font through SwiftUI defaults. Keep status labels and action names readable at the user's selected accessibility size. Use monospaced text only for stable technical identifiers such as observation IDs or event IDs in diagnostics, never for ordinary transcript or action copy.

## Border Radius

Use native macOS control and container shapes. Avoid large rounded-card styling. If custom panels are needed, use one restrained utility-panel radius and preserve focus rings, hover states, keyboard access, and reduced-motion behavior.

## Component Library

No existing component library is present. Use SwiftUI controls and AppKit utility-window behavior first. Create reusable components only for repeated product states: `StatusIndicator`, `TranscriptView`, `ActionProposalRow`, `ConfirmationView`, `StopButton`, `PermissionRow`, and `ActivityEventRow`. The native platform adapter is SwiftUI/AppKit, not the preferred web adapter.

## Layout Patterns

- Menu-bar popover: current state, target app, primary action, stop, and settings/permissions access.
- Floating command bar: compact vertical status sequence with transcript above the proposed action and one persistent stop affordance while active.
- Confirmation surface: plain-language action, target, consequence, and explicit confirm/cancel buttons. No ambiguous primary action.
- Activity history: chronological redacted events with phase, action, result, and delete-history control.
- Permission guidance: one permission at a time, why it is needed, current status, and the exact macOS recovery action.
- Error and blocked states: show what was not done, why it stopped, and the next safe user action.

## Icons

Use SF Symbols with labels, not icon-only controls for consequential actions. Keep stop, microphone, lock/permission, warning, checkmark, and xmark semantics consistent. Use tooltips and VoiceOver labels. Never rely on color alone to communicate listening, confirmation, blocked, or verified states.
