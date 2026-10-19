# ChatGPT Electron snapshot exporter — JavaScript port

Status: Active
Updated: 2026-10-19

## Goal
Implement `rumiai-os/lib/sys/js/chatgpt-export.lib.js` as a faithful JavaScript port of the attached Python exporter from CDP attachment through snapshot export, accepting a caller-supplied CDP host and port, without requiring Python, Playwright, SQLite or ChatGPT launching.

## Current repository revisions
- rumiai-dev: c4c3872c0751365175780613b63bdecbe20711cc (before this checkpoint)
- rumiai-os: 508909a085147f52e54c944f47d8b18a3106207c
- rumiai-tests: 6ee9b70314d4779dbc41df0141eaff5d1f15f85d

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
4. Snapshot serialization fails: an appropriate error is raised, while a successfully received debugger pause is always resumed.

## Completed
- Published the CommonJS library and its required operational manual to `rumiai-os`.
- Published a permanent focused contract test at `rumiai-tests/tests/rumiai-os/chatgpt-export/contract.test`; the new remote test itself has not been run in the native test runner in this work unit.
- Local `node --check` passed on the final published-equivalent file (Node v22.16.0).
- Local synthetic-snapshot comparison against the attached original Python exporter passed: `TRANSCRIPT.md`, parsed JSONL, `NON_TEXT_PARTS.json`, `AUDIT.json`, and `README.md` matched; ZIP entry contents and GZIP decompression verified.
- Local native Node WebSocket/TCP CDP test server exercised script discovery, breakpoint, navigation, call-frame evaluation, resume, cleanup and export, both with and without a conversation ID; passed.
- Final source obeys multiline delimiter alignment (zero mismatches in local token-based scan); GitHub copy verified against local source with hash `1033ef10` using the transfer-specific code-point FNV check.
- Post-change Git comparison showed new library/manual/test/handoff only, besides concurrent changes to the separate `web-page-analyze.md` handoff, which were preserved.

## Current state
Implementation, manual and permanent test are committed and the local downloadable artifact is `/mnt/data/chatgpt-export.lib.js`. The initial preflight, source diff review, local JavaScript delimiter/style check and proportional local functional checks are complete. The public workflow against an actual ChatGPT Electron renderer and the committed permanent test inside the official runner remain unverified.

## Next action
Run the focused permanent contract test in the real RumiAI test environment and physically exercise the exporter against an authorized ChatGPT Electron application with debugging enabled on the caller-provided host/port. Review the resulting RAW/transcript data, breakpoint cleanup, and real app behavior before declaring physical validation.

## Blockers / open questions
Real ChatGPT Electron/macOS process is not available in this execution environment. The application-specific minified hook cannot be physically validated here.
