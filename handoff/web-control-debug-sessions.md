# Web-control persistent debugger sessions

Status: Active
Updated: 2026-10-15

## Goal

Provide a **common** page-scoped, persistent debugger-session capability through web-control in both Playwright and Electron providers, enabling structured CDP event/breakpoint/call-frame workflows without a second browser or remote debugger TCP port. Publish through the package facility only after new compatibility and release validation.

## Current repository revisions

- rumiai-dev: 2581c3c3ad3097424990498bd20cf2a274c5724f (last pre-checkpoint HEAD)
- pwc-web-control: 403f4fa9bbea419715e9c834e847c6f2b60ae421 (published v0.1.6)
- electron-web-control: 077eb502f1d68235b4e5c9c28e4a7560795bce17 (published v0.1.6)
- pkg-catalog: 7cd9b7585b9343a153e516c9c47b6fb92b7330e0 (both v0.1.6 providers declare web-control 3)
- rumiai-tests: 9a4130edbe7ca9e7171e3f5b8dde14e2d3b77984 (installed provider tests)
- rumiai-dev-PoCs: 7df999257366577eec418b4813a35bef57635611 (Node.js consumer implementation)

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
- Level-1/2 published package semantics and compatibility declarations are unchanged. Separate v0.1.6 releases now provide declared compatibility 3 in pkg-catalog; the user's local installation is not automatically upgraded.
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

- Published PWC v0.1.6 and Electron v0.1.6 from source revisions `403f4fa9bbea419715e9c834e847c6f2b60ae421` and `077eb502f1d68235b4e5c9c28e4a7560795bce17`. Both GitHub Actions validate/build/publish workflows succeeded, and each release contains its `-all.tar.gz` archive.
- Added `facility/web-control/3` and both providers' `pkg/*/all/n0007=v0.1.6/` realizations to pkg-catalog, updated version indexes, preserved all prior version files. Final catalog head `7cd9b7585b9343a153e516c9c47b6fb92b7330e0`; diff and realization fields reread.
- Updated real installed-provider integration tests in `rumiai-tests`: exact v0.1.6/default selection and page-scoped open/send/events/close via `pkg` and `srv`. Formal PWC package validation run `38742849198` completed successfully on Linux x86_64 and ARM64; Electron run `38742912001` passed Linux x86_64 and ARM64, while macOS ARM64 was still queued at checkpoint.
- The separate exporter handoff now owns the Node.js port; PoC `export-share.mjs` is committed and tested on hosted fixtures, but no physical ChatGPT shared URL success is claimed.
- Performed initial remote HEAD preflight and authoritative read order, inspected both provider controllers/clients/tests and compared official Playwright and Electron debugger APIs.
- Added shared source-level `DebugSessions` manager in both repositories, identical CLI routes and command envelopes, provider attach/event/send/detach adapters, and Electron input coexistence.
- Updated canonical `specifications/rumiai-os/WEB-CONTROL.md` to define level 3 and explicitly distinguish the current Chromium CDP payloads from generic level-1/2 portability. Documented commands and unreleased status in both provider READMEs.
- Tests in both providers: 4 unit cases for session lifecycle, bounded overflow, page cleanup and operand failure identities; real browser fixture test for persistence over navigation, `Network.requestWillBeSent`, `Debugger.paused`, `Debugger.evaluateOnCallFrame`, `Debugger.resume`, page input while attached, one-shot CDP parity and page-close invalidation.
- GitHub Actions: exact PWC source `f060a3bf2c3e38441e41dac09476e5ace3011e9b`: run `38739536551`, Linux+macOS+build passed after one retry of a Linux controller startup/connect ENOENT failure. Exact Electron source `f78acc1963a2d341cd687216012a8b0dcbb22057`: run `38739847979`, Linux+macOS+build passed on first attempt. These are real hosted browser fixture tests, NOT the user's ChatGPT site/installation validation.
- Linked work from the broader `handoff/web-access-sense.md` and consumer `handoff/chatgpt-shared-link-export.md` without copying operational state into them.

## Current state

**Release and catalog publication are complete:** two genuine tagged v0.1.6 artifacts exist, both provider version realizations advertise facility compatibility level 3, and real installed-package tests passed on both Linux architectures. The Electron package macOS ARM64 formal-validation runner remains queued, not falsely marked passed. The user's workstation has not been modified.


## Next action

Check the pending Electron macOS ARM64 formal validation (`38742912001`) and reconcile its result. For physical user-host acceptance, install/select v0.1.6 via the normal package/facility workflow, verify `web-control debug session open/send/events/close` and provider switching, without overwriting user-managed profiles or service configurations. Keep the source contract and release artifacts pinned in validation evidence.


## Blockers / open questions

- User physical installation and exact hosted Electron macOS ARM64 package validation remain; no actual ChatGPT shared-link structured snapshot has been observed. Release/catalog work is finished.
