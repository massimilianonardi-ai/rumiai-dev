# Browser/Electron text editor and JavaScript bundling

Status: Active
Updated: 2026-10-09

## Goal

Investigate and prototype an advanced JavaScript text editor with first-class rectangular/column editing, able to run offline in a browser, embed as a single-file library in websites, and reuse the same browser engine under a secure Electron host. Establish a build path compatible with the existing `m`/`mk` responsibilities rather than inventing a parallel lifecycle engine.

## Current repository revisions

- `rumiai-dev` main: `a56180ed515add7e4a395700e68c4d212429750d` (last inspected before checkpoint).
- `rumiai-dev-PoCs` main: `0f9c5b7fd78f22716cdd1be4423fda91b557eb78` (PoC including downloadable workflow artifact).
- `rumiai-os` main: `6a964ba3f5c8acf462737e3b92daaf1af32de57e`.
- Reference repository `m` master: `2a57a29880c2d7a32e18782122062c695fcb1a3a`.

Fresh remote HEAD verification is still required before every resumed task and before repository writes.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`.
- `specifications/rumiai-os/CURRENT-MODEL.md`, `specifications/rumiai-os/MK.md`.
- If core `m` commands/libraries are touched: `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, operational manuals.
- Independent terminal-editor TODO `todo/vsed-advanced-editor-evaluation.md` is not activated by this browser-editor task.

## Fixed task-local choices

- Browser functionality cannot require Electron, Node.js, online APIs or a runtime service.
- Keep modular JavaScript development sources; evaluate a self-contained single JavaScript browser distribution. Electron is an optional separate host.
- Reuse current `mk` for project lifecycle orchestration and external bundler delegation first; do not silently extend `mk` or promote a new general-purpose builder from an experiment.
- No product/runtime changes are authorized merely by this PoC; code experiments belong in `rumiai-dev-PoCs`.

## Acceptance scenarios

1. An operator opens a local HTML page referencing the built JS artifact, without a server, account, or network, and can edit ordinary text.
2. A website embeds the same JS artifact, instantiates independent editor instances, reads/sets text and destroys the instance without requiring a framework.
3. A user switches column mode, makes a rectangular mouse selection across uneven lines, edits/pastes columns, uses undo/redo and sees correct cursor/selection behavior.
4. The same editor engine runs under Electron without exposing Node APIs or disabling browser isolation in its renderer.
5. From a modular source tree, a declared `mk` goal invokes an appropriate bundler and emits one browser JS artifact without unexpected chunks, CSS files, fetched runtime modules or worker assets.

## Working design (not normative)

- Browser editor candidates: CodeMirror 6 (rectangularSelection and multiple ranges), Monaco (columnSelection option), Ace (multiselection), versus adapting legacy `m/js/lib/ui-text-edit`.
- Bundlers: start with esbuild as a delegated engine; compare Rollup, Vite library mode and the older `m/cmd/jsc` + `jsc.js` approach before selecting long-term packaging.
- Legacy `m/js/lib/ui-text-edit/m/text/TextEdit.js` already has multirange selections and `insertText(text, columnMode)`, but no evidence yet of reliable screen-rectangular geometry, large-document rendering, arbitrary Unicode/tab/line-ending correctness or undo/redo.
- Legacy `m/cmd/jsc.js` implements JSON-ordered source concatenation/namespace export and contains Java runtime references plus dynamic `eval` patterns; not suitable for direct production adoption.
- Legacy Electron editor disables context isolation/sandbox/web security and enables Node integration; it is research input, not a secure host implementation.
- A browser-only prototype should prove column interaction and single-asset packaging before any permanent `mk` adapter is considered.

## Completed

- Verified relevant remote HEADs and completed the canonical read order.
- Retrieved current `mk` contract, existing handoff ownership and the separate deferred terminal-editor TODO.
- Inspected legacy `m` bundler, editor text engine and Electron host, and compared public editor and bundler APIs.
- Identified a first experimental path based on CodeMirror 6 + esbuild delegated through `mk`.
- Created `rumiai-dev-PoCs/pocs/061-web-editor-column-bundle/` with modular ES source, `mk.json`, single-IIFE build, local-file demo, Playwright Chromium interaction test, and GitHub Actions workflow.
- Hosted run `37973245759` at `1d523b9...` passed with initial 681.3 KB unminified bundle.
- Hosted run `37973599869` at `070076170dea9e3c60da50f6dfb19584359d26ed` passed with a single 305.2 KB minified `dist/editor.js`: real headless Chromium loaded via `file://`, mouse rectangle produced multiple selections, typing and undo worked, independent editor instances worked and zero HTTP(S) requests were observed. Logs/steps report PASS; no test substitution for the browser interaction.
- Workflow-only follow-up `0f9c5b7fd78f22716cdd1be4423fda91b557eb78` run `37973843577` passed build/browser tests and published downloadable Actions artifact `editor-single-js` (ID `11638197519`, compressed upload 101637 bytes, expires 2027-01-07). This is an ephemeral CI artifact, not a formal release.

## Current state

GitHub Actions real hosted Ubuntu/Chromium validation passed (runs `37973599869` and `37973843577`); latest run also published the built JS artifact; local container still lacks npm registry access, but hosted dependency resolution and build succeeded. The browser test checks a representative real rectangle interaction and offline loading, not comprehensive column semantics. The current `mk.json` is declarative and its real `mk` invocation has not been exercised. Electron host, physical macOS, large files, clipboard, tabs/virtual columns, Unicode and CRLF remain unvalidated.

## Next action

Extend the real-browser acceptance tests to rectangle pasting and deletion across uneven/short lines, tabs, Unicode/graphemes, CRLF and clipboard. Validate real `mk --plan build`, `mk build` and `mk check` through the managed runtime when available; evaluate a secure Electron host and alternative engines as warranted. Keep provider/compiler changes out of `mk` until demonstrated necessary.

## Blockers / open questions

- The current core CodeMirror build demonstrably produces one JS file with no observed browser HTTP(S) requests. Whether optional themes, language modes, workers and future features can retain single-file distribution remains open.
- The actual managed `mk` lifecycle and Electron shell are not yet validated.
- Decide if a separately releasable first-party editor project is warranted after the PoC; no product placement is promoted yet.
