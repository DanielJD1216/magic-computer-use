# Platform Feasibility Probes

## Observed Target

- SSH target: `daniels-macbook-pro.tail96e845.ts.net`
- Hostname returned by Mac: `Daniels-MBP.ht.home`
- User: `danieljindoo`
- macOS: `26.5.1`, build `25F80`
- Architecture: `arm64`
- Swift: Apple Swift `6.2.0.19.9`, target `arm64-apple-macosx26.0`
- Git: Apple Git `2.50.1`
- Active developer directory: `/Library/Developer/CommandLineTools`
- SDK: `/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk`

## Repository and Build Status

- Repository cloned on the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Mac working copy is clean and matches `f71a65687119fb1215fda0ae1c3b7af50e807151`.
- No `Package.swift`, `.xcodeproj`, or `.xcworkspace` exists yet.
- `xcodebuild` is present at `/usr/bin/xcodebuild` but fails because the active developer directory is Command Line Tools rather than a full Xcode installation.
- No Xcode app was found in the checked locations `/Applications/Xcode.app`, `/Applications/Xcode-beta.app`, or `~/Applications/Xcode.app`.
- Swift command-line type-check probes passed for `Foundation`, `AppKit`, `SwiftUI`, `Speech`, `AVFoundation`, `ApplicationServices`, and `Carbon`.

## Gate Status

- Repository orientation: **partial**. Repository and target runtime are recorded. Project format, signing, sandbox, exact build/test commands, and entitlements remain unknown because no app target exists.
- Native feasibility: **blocked**. Speech finalization/cancellation, hotkey lifecycle, panel focus, Safari Accessibility identity, native fixture action, and exact verification have not been observed.
- Fake safety loop: **not started**. It must not be claimed from documentation alone.
- Live Jev: **disabled**. No credential or live request is needed.

## Required Next Mac Action

Install the full Xcode application on the target Mac, open it once, accept the license if prompted, and select it with `xcode-select`. Do not install or request Jev credentials as a substitute. After Xcode is available, record:

```bash
xcode-select -p
xcodebuild -version
swift --version
```

Then create or choose the project format according to the repository conventions and run isolated speech, hotkey, panel, and Safari fixture probes.

## Speech Probe

**Status: not run.** Record selected locale, on-device recognition support, partial revisions, finalization after key release, cancellation, delayed/missing final callbacks, interruption, sleep, and permission withdrawal. Pass only when finalization and cancellation are distinct and stale callbacks cannot mutate a newer session.

## Hotkey Probe

**Status: not run.** Test press/release, lost key-up, repeated keydown, conflicts, secure input, sleep, lock, denial, and event handling. Do not assume a generic global monitor can suppress arbitrary events.

## Floating Panel Probe

**Status: not run.** Verify transcript display, confirmation, keyboard focus, focus restoration to the Safari fixture, Spaces/full-screen behavior, Stop availability, and dismissal without losing session state.

## Safari Fixture Probe

**Status: not run.** Use a local, versioned, synthetic fixture with a fixed route, known identity, reviewed accessible elements, no redirects/external links/custom schemes/downloads/pop-ups/login state, deterministic states, and fixture version recorded in every acceptance event.

## Native Readiness Gate

Gate 1 remains closed until speech finalization, hotkey lifecycle, panel focus, Safari Accessibility target identity, one native fixture action, and exact postcondition verification are observed on the target Mac. A Swift framework type-check is useful toolchain evidence but does not close a native feasibility gate.
