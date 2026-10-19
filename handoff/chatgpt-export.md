# ChatGPT Electron snapshot exporter — JavaScript port

Status: Active
Updated: 2026-10-19

## Goal
Implement `rumiai-os/lib/sys/js/chatgpt-export.lib.js` as a faithful JavaScript port of the attached Python exporter from CDP attachment through snapshot export, accepting a caller-supplied CDP host and port, without requiring Python, Playwright, SQLite or ChatGPT launching.

## Current repository revisions
- rumiai-dev: 2b1be9e048ef8d5f1886f105b0a4487ec4333007 (pre-change)
- rumiai-os: 9f7f6bb1715b3d8ec9959262d0862b1c5d969ad6
- rumiai-tests: db7b323f9adb9d3eb6ef09c33c1fe82439ae226d

## Applicable canonical sources
`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`, `WEB-CONTROL.md`, `handoff/README.md`.

## Fixed task-local choices
- The library is a CommonJS Node.js module under `lib/sys/js`, with matching `res/sys/manual/chatgpt-export.lib.js`.
- Primary function `chatgptExport(host, port, options={})`; optional `conversationId` enables original automatic `/work/conversation/<id>` navigation. Without it, retry current renderer by reload, then accept the next snapshot captured.
- The reusable `exportChatgptSnapshot(rawJson, selected, outputRoot)` does not interact with CDP.
- Use native CDP WebSocket/TCP and Node core facilities; preserve original message/node classification, active-branch transcript, forensic artifacts and checksums; ZIP is implemented without packages.
- No new command entrypoint, no browser launcher, no ChatGPT share-site port in this task.

## Acceptance scenarios
1. Caller knows host/port and a conversation ID: application navigates, captures matching snapshot and writes forensic files.
2. Caller knows only host/port: reload the current renderer, intercept a conversation snapshot without consulting SQLite, export it.
3. Captured snapshot contains branches, tool traffic, commentary and multimodal parts: RAW retains all mapping data and derived artifacts preserve original Python semantics.
4. Debugger frame evaluation fails: renderer is always resumed and underlying failure is reported.

## Completed
- Port authored locally; Node syntax check passed.
- On a synthetic conversation fixture, Python/JavaScript transcripts, JSONL, non-text JSON and audit matched. ZIP contents and gzip roundtrip validated.
- Native Node WebSocket client exercised against a local TCP/CDP protocol test server: attach, breakpoint, navigate, call-frame evaluation, resume and archive creation passed.

## Current state
Local artifact exists at `/mnt/data/chatgpt-export.lib.js`. Repository publication, permanent test integration, post-change consistency and real ChatGPT macOS validation are outstanding.

## Next action
Publish the tested library and manual to `rumiai-os`, add proportionate permanent tests to `rumiai-tests`, rerun consistency checks and record the exact validation scope.

## Blockers / open questions
Real ChatGPT Electron/macOS process is not available in this execution environment. The application-specific minified hook cannot be physically validated here.
