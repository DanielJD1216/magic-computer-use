# Platform Feasibility Probes

## Observed Target

- SSH target: `daniels-macbook-pro.tail96e845.ts.net`
- Hostname returned by Mac: `Daniels-MBP.ht.home`
- User: `danieljindoo`
- macOS: `26.5.1`, build `25F80`
- Architecture: `arm64`
- Swift from Command Line Tools: Apple Swift `6.2.0.19.9`
- Swift from Xcode: Swift Package Manager `6.3.3`
- Git: Apple Git `2.50.1`
- Xcode: `26.6`, build `17F113`
- Xcode app: `/Applications/Xcode.app`
- Xcode SDK: macOS `26.5`

## Repository and Build Status

- Repository cloned on the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Mac working copy is clean and matches `cbf9a25d8a64d35db55568dd7db940a569eb2cba`.
- Project format: Swift Package Manager core package, with `Package.swift` targeting macOS 14. A native app target remains a later task.
- `xcodebuild -checkFirstLaunchStatus` passed under `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- `xcodebuild -license status` passed under the same developer directory.
- The system-wide selector still points to `/Library/Developer/CommandLineTools`; per-command `DEVELOPER_DIR` is the verified workaround. Switching it globally requires the Mac administrator password and was not attempted interactively.
- `swift test --disable-sandbox` passed on the target Mac: 10 tests, 0 failures.
- Swift command-line type-check probes passed for `Foundation`, `AppKit`, `SwiftUI`, `Speech`, `AVFoundation`, `ApplicationServices`, and `Carbon`.

## Gate Status

- Repository orientation: **partial**. Runtime, Xcode, SDK, SwiftPM format, and exact test command are recorded. Signing, sandbox, app bundle, permissions, speech mode, hotkey path, and applicable TypeSafe agreement remain open.
- Native feasibility: **blocked for observation**. Speech finalization/cancellation, hotkey lifecycle, panel focus, Safari Accessibility identity, native fixture action, and exact verification have not been observed in a running app.
- Fake safety loop: **partial**. The first 10 pure domain/lifecycle tests pass. Fake orchestrator, response validation, redaction, budget, and fixture adapter tests remain.
- Live Jev: **disabled**. No credential or live request is needed.

## Required Next Mac Action

The full Xcode toolchain is now available. Continue using `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for remote commands unless the administrator runs:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

The next implementation gate is the native shell and isolated probes. Do not install or request Jev credentials as a substitute.

## Speech Probe

**Status: not run.** Record selected locale, on-device recognition support, partial revisions, finalization after key release, cancellation, delayed/missing final callbacks, interruption, sleep, and permission withdrawal. Pass only when finalization and cancellation are distinct and stale callbacks cannot mutate a newer session.

## Hotkey Probe

**Status: not run.** Test press/release, lost key-up, repeated keydown, conflicts, secure input, sleep, lock, denial, and event handling. Do not assume a generic global monitor can suppress arbitrary events.

## Floating Panel Probe

**Status: not run.** Verify transcript display, confirmation, keyboard focus, focus restoration to the Safari fixture, Spaces/full-screen behavior, Stop availability, and dismissal without losing session state.

## Safari Fixture Probe

**Status: not run.** Use a local, versioned, synthetic fixture with a fixed route, known identity, reviewed accessible elements, no redirects/external links/custom schemes/downloads/pop-ups/login state, deterministic states, and fixture version recorded in every acceptance event.

## Native Readiness Gate

Gate 1 remains closed until speech finalization, hotkey lifecycle, panel focus, Safari Accessibility target identity, one native fixture action, and exact postcondition verification are observed on the target Mac. Passing pure Swift tests and framework type-checks does not close a native feasibility gate.
