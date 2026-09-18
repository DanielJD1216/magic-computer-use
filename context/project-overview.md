# Meet Jev, Fastest Computer Use

## Overview

A private macOS menu-bar prototype for push-to-talk computer control. The user speaks a bounded goal, sees the live transcript and proposed action, and the application decides locally whether a typed Jev judgment may be used to select one of a closed set of native Mac actions. Swift code owns permissions, policy, execution, verification, cancellation, and redacted local history. The first release is controlled dogfooding only, not a public automation service or a safety/performance claim.

## Goals

1. Prove one inspectable, cancellable action loop from push-to-talk through verified low-risk Mac actions.
2. Keep consequences under local code and user control: no arbitrary commands, coordinate-only clicking, sending, deleting, purchasing, publishing, or unattended account changes.
3. Produce measurable evidence for transcript, Jev decision, policy, executor, verification, cancellation, permission, and network timing.

## Primary User

A single developer/operator testing a private macOS prototype with synthetic notes, browser pages, and reversible workflows. The user must always know whether the app is off, listening, choosing, waiting for confirmation, executing, blocked, stopped, or verified.

## Core User Flow

1. The user opens the menu-bar control and presses push-to-talk.
2. The app shows listening status and partial speech transcription.
3. The app observes only the active application metadata and bounded accessibility candidates required for the next decision.
4. A Jev adapter may choose one candidate from the supplied closed set, including `stop` and `askUser`.
5. Local policy checks freshness, risk, confidence, permissions, and confirmation requirements.
6. The app either asks for confirmation, executes one native action, or stops with a reason.
7. A verifier checks the expected visible result and records a redacted activity event.
8. The user can stop locally at any point, including while the network request is in flight.

## Features

### Command control

- Menu-bar status and floating command bar.
- Push-to-talk with visible armed and listening states.
- Partial and final transcript display.
- Immediate local stop and cancellation.

### Bounded computer use

- Closed action model with stable candidate IDs.
- Active application and focused accessibility observation.
- Native adapters for opening apps and URLs, web search, Notes and browser fixtures, typing into a verified target, scroll, back, wait, and stop.
- Action-specific verification and stale-observation rejection.

### Trust and diagnostics

- First-run permission explanation.
- Confirmation for medium-risk and all externally visible or destructive actions.
- Redacted local activity history with deletion.
- Timing checkpoints without ordinary-log credentials, tokens, passwords, clipboard contents, or private document text.
- Fake speech, Jev, observation, executor, and verifier adapters for deterministic tests.

## Scope

### In Scope

- macOS-native SwiftUI menu-bar and utility-window shell.
- Push-to-talk speech adapter boundary with Apple Speech as the first replaceable adapter.
- Domain models, orchestrator state machine, local policy, cancellation, stale-state guard, and verification contracts.
- A TypeSafe HTTP adapter that remains disabled until current access terms and Jev-side authorization permit the intended private use.
- Real-Mac acceptance instructions using synthetic and reversible data.

### Out of Scope

- Always-on passive listening.
- Arbitrary shell commands or arbitrary coordinate clicking.
- Automatic sending, deleting, purchasing, publishing, sharing private data, or system-account changes.
- Real customer data, real secrets in fixtures, multi-user accounts, billing, cloud sync, relay production service, or public distribution.
- Public latency, accuracy, safety, cost, or benchmark claims.
- Windows client, browser extension, camera workflow, or screenshot/vision fallback in version 0.1.

## Success Criteria

1. The project has a reproducible macOS build and test command documented once the target Mac toolchain is available.
2. Fake-adapter tests prove candidate validation, policy precedence, stale-state rejection, cancellation precedence, response parsing, redaction, and orchestrator transitions without network or Mac permissions.
3. The real app visibly communicates listening, transcript, selected action, confirmation, execution, verification, blocked, error, permission, stopped, and off states.
4. No action executes unless local policy approves the current observation and the app can verify the intended result.
5. Jev credentials are never requested, stored, or used until the access/terms gate and the Jev-side authorization decision are closed.
