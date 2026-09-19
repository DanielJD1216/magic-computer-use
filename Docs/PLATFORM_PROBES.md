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
- Mac working copy is clean and matches `935a3081c52dae80d1a843d7a80c59c300cdf524`.
- Project format: Swift Package Manager core package, with `Package.swift` targeting macOS 14 and an executable `JevMacShell` target.
- `xcodebuild -checkFirstLaunchStatus` passed under `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- `xcodebuild -license status` passed under the same developer directory.
- `swift build --product JevMacShell --disable-sandbox` passed on the target Mac.
- `swift test --disable-sandbox` passed on the target Mac: 20 tests, 0 failures.
- A stable ad-hoc signed shell bundle exists at `~/Applications/JevMacShell-Prototype.app`; it launches without requesting permissions. This proves process launch and codesign verification, not visual, focus, or Safari acceptance behavior.
- The system-wide selector still points to `/Library/Developer/CommandLineTools`; per-command `DEVELOPER_DIR` is the verified workaround. Switching it globally requires the Mac administrator password and was not attempted interactively.
- Swift command-line type-check probes passed for `Foundation`, `AppKit`, `SwiftUI`, `Speech`, `AVFoundation`, `ApplicationServices`, and `Carbon`.

## Gate Status

- Repository orientation: **partial**. Runtime, Xcode, SDK, SwiftPM format, and exact test/build commands are recorded. Signing, sandbox, app bundle, permissions, hotkey path, and applicable TypeSafe agreement remain open.
- Native feasibility: **partial and probeable**. The final bundle is Accessibility-trusted in the GUI session. Carbon hotkey registration succeeds. The synthetic Safari fixture identity, native button action, and exact postcondition verifier pass. Real speech permissions/lifecycle, physical hotkey lifecycle, and panel focus remain unverified.
- Fake safety loop: **partial**. Twenty pure domain, transcript, lifecycle, bounded-selection, and fake-fixture tests pass. Fake orchestrator, response transport parsing, redaction, and budget tests remain.
- Live Jev: **disabled**. No credential or live request is needed.

## Required Next Mac Action

Continue using `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for remote commands unless the administrator runs:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

The final native-probe bundle is trusted in the GUI session. The next probes can run without another app rebuild or permission change. Do not install or request Jev credentials as a substitute.

- **Accessibility trust probe:** the final bundle returned `AX_TRUSTED=true` when launched through the GUI session. Strict ad-hoc codesign verification also passes.
- **Speech capability probe:** locale `en-CA` is available and on-device recognition is supported. The non-prompting status probe reports speech and microphone authorization as `notDetermined`; it did not request either permission. The request object supports on-device mode, explicit finalization, and cancellation paths, but real microphone recognition remains untested.

## Hotkey Probe

**Status: partial.** Carbon event-handler installation and `RegisterEventHotKey` both returned status `0` for Command-Option-L. Suppression is not claimed, and physical press/release, lost key-up, conflict, secure-input, lock, and app-switch behavior remain untested.

## Floating Panel Probe

**Status: process launch only.** Visual layout, transcript display, confirmation, keyboard focus, focus restoration to the Safari fixture, Spaces/full-screen behavior, Stop availability, and dismissal without losing session state remain unverified.

## Safari Fixture Probe

**Status: observed for the first native slice.** The versioned local fixture opened in Safari with title `Jev Fixture v1 | Landing`; the trusted probe found the known Safari process and fixture window, found the fixed reviewed-view button, received AX press status `0`, and verified title `Jev Fixture v1 | Reviewed` plus `State: reviewed`. The probe recorded Safari PID `52138` and window ID `178338` for this run. No external URL, login state, or uncontrolled action was used.

## Native Readiness Gate

Gate 1 remains open for real speech finalization/cancellation, physical hotkey lifecycle, and panel focus. The Accessibility target identity, one native fixture action, and exact postcondition verification are now observed on the target Mac. Passing pure Swift tests or process launch alone still does not close native feasibility.
