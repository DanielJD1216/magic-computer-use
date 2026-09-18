# Platform Feasibility Probes

## Status

- Repository orientation: completed for the current Dev Life repository.
- Target Mac Tailscale reachability: observed. Mac is online at `100.105.165.39`.
- Remote Login: enabled; TCP 22 is reachable.
- SSH authentication: blocked pending installation of the generated public key on the Mac or enabling Tailscale SSH.
- Xcode/Swift/toolchain: not observed yet.
- Speech, hotkey, panel, Safari Accessibility, native fixture action, and exact verification: not run.

No Mac readiness or implementation claim is earned by this document.

## Target-Mac Orientation Commands

Run on the Mac after authenticated SSH is available:

```bash
sw_vers
uname -m
xcode-select -p
xcodebuild -version
swift --version
system_profiler SPHardwareDataType SPSoftwareDataType
```

Record outputs without credentials or private data. Inspect the repository from the authorized path and record `.xcodeproj`, `Package.swift`, `AGENTS.md`, CI, bundle identifier, signing identity, entitlements, sandbox posture, and exact build/test commands.

## Speech Probe

Record selected locale, microphone and Speech permission behavior, on-device recognition support, partial revisions, finalization after key release, cancellation, delayed/missing final callbacks, interruption, sleep, and permission withdrawal.

Pass only when finalization and cancellation are distinct and stale callbacks cannot mutate a newer session.

## Hotkey Probe

Test press/release, lost key-up, repeated keydown, conflicts, app switching, secure input, sleep, lock, denial, and app event handling. Do not assume a generic global monitor can suppress arbitrary events.

## Floating Panel Probe

Verify transcript display, confirmation, keyboard focus, focus restoration to the Safari fixture, Spaces/full-screen behavior, Stop availability, and dismissal without losing session state. A nonactivating panel can still affect focus and must be observed.

## Safari Fixture Probe

Use a local, versioned, synthetic fixture with a fixed route, known identity, reviewed accessible elements, no redirects/external links/custom schemes/downloads/pop-ups/login state, deterministic states, and a fixture version recorded in every acceptance event.

Verify process/window/fixture identity, Accessibility attributes and supported actions, invalid-element behavior, timeout, focus, and relaunch. Do not infer native behavior from a browser mock.

## Native Readiness Gate

Gate 1 passes only when speech finalization, hotkey lifecycle, panel focus, Safari Accessibility target identity, one native fixture action, and exact postcondition verification are observed on the target Mac. Any unknown remains deferred.
