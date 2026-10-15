# Web-control persistent debugger sessions

Status: Active
Updated: 2026-10-15

## Goal

Provide the same page-scoped, persistent debugger session lifecycle through the common `web-control` interface in both first-party implementations (Playwright and Electron), enabling long-lived event reception and call-frame commands without publishing a browser debugging port.

## Current repository revisions

- rumiai-dev: 6923fe2817b341077e9e0f497a86e14ef264921c
- pwc-web-control: 5f3c8d298ac916be72ea59461a167ac31610ca61
- electron-web-control: 22da3beab20e509cffcbd81866b51253df4e08a9
- rumiai-dev-PoCs: 53f269a4cdc2e91ad494de9d0f65336e6fae950d

## Applicable canonical sources

- README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, handoff/README.md
- specifications/README.md
- specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- The new public interface is common across BOTH current providers; do not equate a provider-only extension with the common interface.
- Preserve compatibility-level 1 and 2 releases. Any new complete interface level needs a distinct level and matching declaration/release before users can rely on it as installed capability.
- Keep browser debugger connections internal to local restricted provider IPC, with no raw remote debugging port.
- The ChatGPT export PoC is one consumer, not the owner of the generic debugger lifecycle.

## Acceptance scenarios

1. Open a page-scoped persistent debugger session using web-control, enable a domain, navigate, collect events, inspect paused JavaScript frames, resume, and close the session without a second browser.
2. Both Playwright and Electron provide the same CLI/request and response semantics.
3. Page/browser closure invalidates sessions; stale handles produce distinguishable errors; queued events are bounded and overflow is visible.
4. Ordinary page input and existing browser operations remain usable and safe while a debugger session exists.
5. Existing published web-control 1/2 operations are unchanged, with no external debugging endpoint.

## Working design

Both runtimes provide attach/send/event/detach natively: Playwright `newCDPSession` / `send` / `on('event')` / `detach`; Electron `webContents.debugger.attach` / `sendCommand` / `on('message')` / `detach`. Common session handles and events must be owned by the provider controller, not by CLI subprocesses. Electron's existing `withNativeInput` transient debugger usage must reuse an active managed attachment or otherwise safely serialize it.

Actual physical authentication and ChatGPT shared-page snapshot hook remain outside this task's validation; this task proves only the generic debug session interface.

## Completed

- Mandatory initial remote HEAD and current-source read, including provider implementations.
- Verified official Playwright and Electron documentation for persistent commands/events and Electron's DevTools-driven detach.
- Confirmed current pwc `debug.cdp` opens/detaches per call and Electron only uses its debugger internally.

## Current state

Pre-implementation. The shared lifecycle is not available in the released providers.

## Next action

Implement a common explicitly scoped session lifecycle on both providers, document the precise shared semantics in the canonical WEB-CONTROL contract and both operational READMEs, and run proportional real tests against actual browsers. Then run consistency gate and synchronize this handoff.

## Blockers / open questions

- Release/package catalog propagation is a separate step if not performed in this unit; do not represent source commits as released packages.
