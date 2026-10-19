# Chromium manual-session analysis — web-analyze

Status: Active
Updated: 2026-10-19

## Goal

Provide the `m` JavaScript library at `rumiai-os/lib/sys/js/web-analyze.lib.js` to launch the `chromium` executable from the effective `m` PATH, observe the user's manual browsing via native Chromium CDP on loopback TCP, and record extensive structured JSONL evidence. No Playwright dependency or separate provider/PoC is required.

## Current repository revisions

- rumiai-dev: 192f9d6ef49c1743ecdf32a79ea7ee5779487751 (prior to this checkpoint)
- rumiai-os: 9f7f6bb1715b3d8ec9959262d0862b1c5d969ad6 (published library and manual)
- rumiai-tests: db7b323f9adb9d3eb6ef09c33c1fe82439ae226d (permanent API, CLI and share-page tests)

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`, `TEST-PATTERNS.md`, `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`, `BOOTSTRAP-ENVIRONMENT.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`, `WEB-CONTROL.md`, `handoff/README.md`.

## Fixed task-local choices

- User-facing invocation: `nodejs <path-to-lib> <url> <analisys-dir>`. The library doubles as CommonJS import and direct Node.js entrypoint; no extra CLI wrapper.
- The destination analysis directory, including missing parents, is created automatically; any user-chosen pathname component is handled as pathname data rather than parsed as a CLI option. An existing directory can be used if it contains no conflicting evidence files. Existing JSONL streams and `summary.json` are never overwritten.
- Chromium is launched directly from the effective PATH, without Playwright, using a dedicated profile and ephemeral CDP TCP debugging port bound to `127.0.0.1`; sandbox and TLS verification remain enabled by default.
- Interactive CLI capture lasts until Chromium exits or SIGINT/SIGTERM; API callers may also stop explicitly. The capture finalizes multiple correlated JSONL streams plus `summary.json`.
- URLs are logged without query/fragment, and keystroke/input values, cookies and HTTP/WebSocket payloads are not recorded. Capture is detailed but not claimed lossless.
- User-provided real acceptance URL: `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`.

## Acceptance scenarios

1. In an `m` shell with `nodejs` and `chromium` available, invoke the library with the shared-page URL and an absent `analisys-dir`; a visible Chromium window opens and the nested directory is created.
2. Navigate/interact manually, close Chromium or press Ctrl+C, then read timestamped lifecycle, interaction, DOM, network, console, performance and error logs and summary.
3. Repeat against a directory with existing evidence: fail without overwriting prior log files. An existing directory without conflicting evidence is accepted.
4. On an externally reachable host, verify actual shared-page navigation/response independently of debugger launch and logging mechanics.

## Completed

- Created and published `lib/sys/js/web-analyze.lib.js` inside `rumiai-os` and mandatory matching `res/sys/manual/web-analyze.lib.js`; public function is `startWebAnalyze(options)`.
- Added direct `nodejs <path-to-lib> <url> <analisys-dir>` executable behavior in that same library, automatic recursive analysis directory creation, existing-evidence refusal, and graceful signal/browser-exit finalization; changes committed forward-only.
- Added permanent test scenarios in `rumiai-tests/tests/rumiai-os/web-analyze/`: `web-analyze.test` (real Chromium API observer), `cli.test` (direct graphical Chromium invocation with directory creation, signal shutdown and overwrite refusal), and `share-page.test` (exact shared ChatGPT URL).
- On an auxiliary Linux host using real Chromium and Node.js 22, direct CLI launched with Xvfb, created an absent nested analysis folder, recorded events, completed on SIGINT (status 0 and `summary.json`) and rejected a subsequent run against existing evidence (status 1). Local permanent CLI and API probes passed again against the last tested library blob SHA 0985a89d6033d23abef396528f619c5901c549af. Remote source and CLI test blobs were verified against tested local files.
- On that same host the real shared-page navigation returned `net::ERR_BLOCKED_BY_ADMINISTRATOR`. The dedicated remote-page test therefore reported SKIP, not PASS. Chromium process/CDP transport/capture success is independently evidenced; actual page-content loading is not.

## Current state

The requested direct invocation, managed directory behavior, native TCP CDP library, manual and permanent coverage are published. Full graphical/manual interaction on the user's physical `m` workstation and actual shared-page HTTP 200 have not been validated here. This auxiliary host does not expose a `nodejs` executable alias, so the smoke used the equivalent Node.js executable `node`; the exact spelling `nodejs` remains to be verified in the `m` reference environment.

## Next action

When the workstream continues, exercise the exact `nodejs` command in the user's `m` shell against the specified share URL on an unblocked host, inspect the captured evidence, and correct any real Chromium/page issues with new forward-only commits and proportional validation.

## Blockers / open questions

The auxiliary host administrator policy blocks loading the ChatGPT share URL. Physical-reference-host validation remains pending.
