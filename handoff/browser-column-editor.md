# Browser/Electron text editor and JavaScript bundling

Status: Active
Updated: 2026-10-09

## Goal

Investigate and prototype an advanced JavaScript text editor with first-class rectangular/column editing, able to run offline in a browser, embed as a single-file library in websites, and reuse the same browser engine under a secure Electron host. Establish a build path compatible with the existing `m`/`mk` responsibilities rather than inventing a parallel lifecycle engine.

## Current repository revisions

- `rumiai-dev` main: `846fdbb84888cd14b5cdd0007075a34d0b5d2593` (before this handoff).
- `rumiai-dev-PoCs` main: `87508593ce64626e7ca82c4fa9d1d0c6db4a5a46` (before experiment).
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

## Current state

External package installation cannot currently be verified in the assistant's local container because npm registry DNS access failed. This is not evidence of a flaw in CodeMirror or esbuild. No browser behavior, build success, Electron integration or `mk` execution is yet validated.

## Next action

Create a minimal PoC under `rumiai-dev-PoCs/pocs/061-web-editor-column-bundle/`; validate the single-JS build with real dependency resolution in an available hosted environment and then validate actual rectangular editing in a browser. Revisit the legacy text engine only against concrete test failures/differences. Promote decisions and modify `mk` only if evidence justifies it.

## Blockers / open questions

- Prove the bundler path and column editing in a real browser; initial tool comparison alone is insufficient.
- Determine whether strict single-file distribution also includes themes/language assets/workers, or only the core editor JS, by empirical build inspection.
- Decide if a separately releasable first-party editor project is warranted after the PoC; no product placement is promoted yet.
