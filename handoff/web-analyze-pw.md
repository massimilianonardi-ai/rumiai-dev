# Playwright webpage analysis library

Status: Active
Updated: 2026-10-19

## Goal
Implement `rumiai-os/lib/sys/js/web-analyze-pw.lib.js` and a `web-analyze-pw <URL>` CLI entrypoint for deep deterministic analysis of an arbitrary HTTP(S) page. Validate first against `https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835`.

## Current repository revisions
- rumiai-dev: 1254bf75916b0db51a19e81d3708d9db1d388fcf (pre-change HEAD)
- rumiai-os: f7f35e2ccd56e9c21530f94e28ee9eb5e6d82e0a
- rumiai-tests: 6523644e7c7e4932910f22ca64ec718b4af809bb440864766a03fe6 (pre-change)
- pkg-catalog: 68b576f138400770ce1c1bd69ebf169cccc3c3df (read-only)

## Applicable canonical sources
README.md, RULES.md, CONSISTENCY-GATE.md, TESTING.md, specifications/README.md, specifications/rumiai-os/{CURRENT-MODEL,FILESYSTEM-NAMING,LIBRARY-INTERFACES,DOCUMENTATION-MODEL,COMMAND-ENTRYPOINTS,DIAGNOSTICS,WEB-CONTROL,PACKAGE-MODEL}.md.

## Fixed task-local choices
- New `web-analyze-pw` is distinct from native-CDP `web-analyze`; no changes to that existing task or provider-independent web-control.
- Resolve and launch the literal `playwright` command through PATH; do not require callers to enter or hardcode its filesystem location.
- Deep browser inspection requires the real Playwright Node API rather than pretending `playwright screenshot` provides it. Obtain the API location from the Node process launched by the existing package command, using a temporary NODE_OPTIONS preload probe, and use the exact corresponding package.
- Dedicated private output folder; structured logs, observable network metadata, DOM snapshots/screenshot checkpoints, Playwright trace, script/runtime errors; no automatic credential/cookie/body capture into ordinary JSONL logs.
- Default automated downward/upward wheel sweep of the actual document or dominant nested scrolling container. Virtualized DOM snapshots are explicitly time/scroll-position scoped, not falsely described as an entire ChatGPT conversation.
- Test site is the supplied public shared ChatGPT URL, not a replacement for a real browser execution.

## Acceptance scenarios
1. `web-analyze-pw https://chatgpt.com/share/6ad1c0d5-49ec-83eb-a79b-85b04b938835 --headless` resolves `playwright` on PATH, starts matching Chromium and emits private reports.
2. Captures network/navigation/console/error evidence plus successive HTML and screenshot snapshots while wheel-scrolling through a possibly virtualized nested container down and back up.
3. Missing command/browser, navigation failure and partial capture produce distinct diagnostics; trace/event files close on cancellation.
4. JS module is callable from a separate Node consumer with documented interface and no runtime change to the external Playwright package.

## Current state
Preflight and source inspection in progress. No implementation/test modifications committed yet.

## Next action
Implement library, command, manuals, proportional permanent tests; run the available Node checks and actual browser where available; review diff and reconcile real-host validation limitations.

## Blockers / open questions
The assistant environment has no `m` runtime or RumiAI Playwright package; a real ubuntu-arm64 `m` integration run may require user host evidence.
