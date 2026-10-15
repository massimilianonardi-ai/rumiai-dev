# Web-control persistent debugger sessions

Status: Active
Updated: 2026-10-15

## Goal

Provide a **common** page-scoped, persistent debugger-session capability through web-control in both Playwright and Electron providers, enabling structured CDP event/breakpoint/call-frame workflows without a second browser or remote debugger TCP port. Publish through the package facility only after new compatibility and release validation.

## Current repository revisions

- rumiai-dev: 2696a9f8a06fb2a2c40143eb74e9d68eca442be8 (canonical level-3 contract, before this checkpoint)
- pwc-web-control: f060a3bf2c3e38441e41dac09476e5ace3011e9b (source-level implementation)
- electron-web-control: f78acc1963a2d341cd687216012a8b0dcbb22057 (source-level implementation)
- rumiai-dev-PoCs: 53f269a4cdc2e91ad494de9d0f65336e6fae950d (existing exporter consumer candidate)

## Applicable canonical sources

- README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md
- specifications/README.md
- specifications/rumiai-os/WEB-CONTROL.md (§6 and level 3)
- specifications/rumiai-os/DIAGNOSTICS.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- handoff/README.md

## Fixed task-local choices

- Level 3 extends complete level 2 and adds the same `debug session open/send/events/close` CLI and IPC semantics in both current Chromium providers. The identical controller-owned event-buffer/lifecycle implementation lives in both provider sources as `src/debug-sessions.mjs`. The CDP protocol method vocabulary is explicitly scoped to the current Chromium providers; hypothetical non-Chromium providers do not silently qualify as level 3.
- Level-1/2 published package semantics and compatibility declarations are unchanged. Published package catalog support for level 3 is still pending release/catalog work and MUST NOT be claimed merely because source CI passed.
- No remote debugger port; the controller Unix socket remains private. The existing PWC one-shot `debug cdp` remains; Electron now exposes the same one-shot command as well.
- Electron's transient CDP native input path reuses an active managed debugger attachment without detaching it; managed `message`/`detach` listeners are removed on close.
- Session event buffers are bounded (128 events, 4 MiB, 1 MiB/event) and cursor gaps return `debug.events-overflow` rather than silent loss.

## Acceptance scenarios

1. `web-control debug session open page-1` gives one opaque session; separate commands can `send` CDP methods, `events`-poll and `close` it.
2. Both providers preserve a live session through navigation, deliver `Debugger.paused`, accept `Debugger.evaluateOnCallFrame` and `Debugger.resume`, and handle normal input while attached.
3. Closing a page invalidates session handles; duplicate attaches and stale cursors fail with specific identities.
4. No second browser, raw TCP debugger listener or provider-specific identity is required for normal session usage.
5. Level-1/2 released provider packages remain valid until both providers ship a new declared level-3 compatibility release.

## Completed

- Performed initial remote HEAD preflight and authoritative read order, inspected both provider controllers/clients/tests and compared official Playwright and Electron debugger APIs.
- Added shared source-level `DebugSessions` manager in both repositories, identical CLI routes and command envelopes, provider attach/event/send/detach adapters, and Electron input coexistence.
- Updated canonical `specifications/rumiai-os/WEB-CONTROL.md` to define level 3 and explicitly distinguish the current Chromium CDP payloads from generic level-1/2 portability. Documented commands and unreleased status in both provider READMEs.
- Tests in both providers: 4 unit cases for session lifecycle, bounded overflow, page cleanup and operand failure identities; real browser fixture test for persistence over navigation, `Network.requestWillBeSent`, `Debugger.paused`, `Debugger.evaluateOnCallFrame`, `Debugger.resume`, page input while attached, one-shot CDP parity and page-close invalidation.
- GitHub Actions: exact PWC source `f060a3bf2c3e38441e41dac09476e5ace3011e9b`: run `38739536551`, Linux+macOS+build passed after one retry of a Linux controller startup/connect ENOENT failure. Exact Electron source `f78acc1963a2d341cd687216012a8b0dcbb22057`: run `38739847979`, Linux+macOS+build passed on first attempt. These are real hosted browser fixture tests, NOT the user's ChatGPT site/installation validation.
- Linked work from the broader `handoff/web-access-sense.md` and consumer `handoff/chatgpt-shared-link-export.md` without copying operational state into them.

## Current state

**Source implementation, canonical contract, both provider documentation and real hosted Linux/macOS tests are aligned.** No installed package has yet declared level-3 facility compatibility. The current package.json versions are still development v0.1.5; CI's successful build step is not evidence that a user installation was upgraded. The ChatGPT exporter remains a separate consumer task; its Node.js port has not been performed by this provider-interface work unit.

## Next action

Read current MK/package/release and facility catalog contracts, verify required artifacts, publish new provider releases compatible with level 3, declare the new facility compatibility in pkg-catalog, and perform a real installed `web-control` provider-switching test across both implementations. Then resume the Node.js ChatGPT exporter port using these shared commands under the exporter handoff.

## Blockers / open questions

- Provider distribution/catalog declaration and physical user-host validation remain. Do not claim release or actual ChatGPT shared-link structured snapshot support before evidence.
