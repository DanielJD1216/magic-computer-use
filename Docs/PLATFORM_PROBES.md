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
- Code-signing identities: `0 valid identities found` in the user keychain
- Stable shell bundle: ad-hoc signed with `codesign --sign -`; `codesign --verify --deep --strict` passed

## Repository and Build Status

- Repository cloned on the Mac at `~/Dev Life/active/Meet Jev, Fastest Computer Use`.
- Mac working copy is clean and matches `af9aeb0bac0b0055e50cf60c22acda9e0b70ab2c`.
- Project format: Swift Package Manager core package, with `Package.swift` targeting macOS 14 and an executable `JevMacShell` target.
- `xcodebuild -checkFirstLaunchStatus` passed under `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- `xcodebuild -license status` passed under the same developer directory.
- `swift build --product JevMacShell --disable-sandbox` passed on the target Mac.
- `swift test --disable-sandbox` passed on the target Mac: 20 tests, 0 failures.
- A stable temporary unsigned app bundle exists at `~/Applications/JevMacShell-Prototype.app`; it launches without requesting permissions. This proves process launch only, not visual, focus, permission, or Accessibility behavior.
- The system-wide selector still points to `/Library/Developer/CommandLineTools`; per-command `DEVELOPER_DIR` is the verified workaround. Switching it globally requires the Mac administrator password and was not attempted interactively.
- Swift command-line type-check probes passed for `Foundation`, `AppKit`, `SwiftUI`, `Speech`, `AVFoundation`, `ApplicationServices`, and `Carbon`.

## Gate Status

- Repository orientation: **partial**. Runtime, Xcode, SDK, SwiftPM format, and exact test/build commands are recorded. Signing, sandbox, app bundle, permissions, hotkey path, and applicable TypeSafe agreement remain open.
- Native feasibility: **permission-blocked**. The shell launches and `en-CA` Speech reports available with on-device recognition support, but `AXIsProcessTrusted()` returns `false`; signing identities are absent. Speech lifecycle, hotkey lifecycle, panel focus, Safari Accessibility identity, native fixture action, and exact verification have not been observed.
- Fake safety loop: **partial**. Twenty pure domain, transcript, lifecycle, bounded-selection, and fake-fixture tests pass. Fake orchestrator, response transport parsing, redaction, and budget tests remain.
- Live Jev: **disabled**. No credential or live request is needed.

## Required Next Mac Action

Continue using `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for remote commands unless the administrator runs:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

The next user-session action is to remove any old Jev shell entry from System Settings → Privacy & Security → Accessibility, add the signed bundle at `~/Applications/JevMacShell-Prototype.app` again, enable its toggle, and then tell me `Accessibility re-added`. Do not install or request Jev credentials as a substitute.

- **Accessibility trust probe:** the remote probe and the actual stable app bundle both return `AXIsProcessTrusted() == false`. No permission prompt was triggered. The stable bundle is now ad-hoc signed and passes strict codesign verification.
- **Speech capability probe:** locale `en-CA` returned available and on-device recognition supported. The actual recognition lifecycle remains untested.

## Hotkey Probe

**Status: not run.** Test press/release, lost key-up, repeated keydown, conflicts, secure input, sleep, lock, denial, and event handling. Do not assume a generic global monitor can suppress arbitrary events.

## Floating Panel Probe

**Status: process launch only.** Visual layout, transcript display, confirmation, keyboard focus, focus restoration to the Safari fixture, Spaces/full-screen behavior, Stop availability, and dismissal without losing session state remain unverified.

## Safari Fixture Probe

**Status: not run.** Use a local, versioned, synthetic fixture with a fixed route, known identity, reviewed accessible elements, no redirects/external links/custom schemes/downloads/pop-ups/login state, deterministic states, and fixture version recorded in every acceptance event.

## Native Readiness Gate

Gate 1 remains closed until speech finalization, hotkey lifecycle, panel focus, Safari Accessibility target identity, one native fixture action, and exact postcondition verification are observed on the target Mac. Passing pure Swift tests, framework type-checks, or process launch does not close a native feasibility gate.
