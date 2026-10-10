# Advanced browser/Electron text editor

Status: Active — user-fixed performance, editing and portability requirements; design comparison pending
Updated: 2026-10-10

## Goal

Design and eventually build an extremely fast, memory-efficient advanced JavaScript text editor capable of handling very large documents while retaining MadEdit-Mod-like intuitive 2D/non-linear editing semantics. Keep a powerful text-management core independent of a lightweight browser DOM UI and usable by optional Electron hosts.

The JavaScript compilation, module loading and distribution concern has **independent ownership** at `handoff/javascript-build-and-runtime-loading.md`. This handoff must not make bundler/loader decisions.

## Current repository revisions

- `rumiai-dev` main: `e266250d911759015fb621c746b8a2ab487d2406` (before this checkpoint).
- `rumiai-dev-PoCs` main: `66efd4e361cfb33cf6601e562cea1ec243c1c9e3`.
- Reference `m` master: `2a57a29880c2d7a32e18782122062c695fcb1a3a`.
- `rumiai-os` main: `382369cfde55b158bdf9bb8c7c7ba352fb00ca5e`.

Always recheck current remote HEADs before resuming or changing files.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`.
- Reference `m/js/lib/ui-text-edit/m/text/TextEdit.js`, `m/js/lib/ui-text-edit/m/ui/`, `m/js/electron-app-editor/`.
- The separately deferred terminal `vsed` advanced-editor work is `todo/vsed-advanced-editor-evaluation.md` and is not this editor.
- The JavaScript toolchain is owned by `handoff/javascript-build-and-runtime-loading.md`.

## Fixed task-local choices

- This editor is an independently useful product, not a test fixture for a bundler or an extension of the terminal `vsed`.
- MadEdit-Mod is the starting functional benchmark; its unusually intuitive multiline/Excel-column/CSV paste across many target lines is a defining requirement, beyond generic rectangular selection or multicursor parity. Exact outcomes for differing source/target shapes must be characterized rather than assumed.
- Extreme editing speed, low memory footprint, and responsiveness on very large documents are primary acceptance constraints, not later optimizations. Test realistically rather than promising size-independent latency for operations inherently touching huge ranges.
- Monaco, CodeMirror, Ace and comparable existing editor libraries are excluded as the new editor's engine: inspect their useful concepts/techniques, but do not select or embed them as the editor architecture. PoC 061 remains historical feasibility evidence only.
- Generalize multiple cursors/selections as a foundation for several 2D/non-linear editing modes, rather than implementing only one rectangular-selection special case.
- Undo/redo must preserve complete editing transactions and interaction state, including selections and caret positions, with potentially unlimited history. Do not impose an arbitrary fixed undo-depth cap; actual RAM/storage constraints and offloading policy require evaluation.
- Keep advanced text management and editing semantics decoupled from GUI/browser DOM, so the core architecture could later be translated to C/C++ or another language without redesign, while the GUI may be rewritten independently.
- Prefer a very lightweight DOM view backed by a powerful text object/model rather than using the DOM as the canonical document. The specific rendering/input method remains subject to measurements.
- The historical `m` code is deliberately dirty architectural exploration, not a production baseline or a defect-fix backlog. Preserve insights, not its implementation compromises.
- Browser-embeddable JavaScript remains desirable for reuse across browser, local and optional secure Electron contexts. JavaScript compilation/distribution remains independently owned by the JavaScript toolchain handoff.

## Acceptance scenarios

1. Paste multiline text, a spreadsheet column or CSV-like rows across many existing lines with MadEdit-Mod-like predictable, human-intuitive placement, including unequal source/target line counts, short target lines and mixed character widths; characterize actual expected behavior as executable cases.
2. Make and transform multiple cursors/selections in different 2D/non-linear editing modes, including rectangles, disconnected spans and edits across many lines, without losing text fidelity.
3. Undo/redo complete grouped edits with document contents, cursor positions and selection ranges/direction restored correctly, across repeated long editing sessions without an arbitrary depth cap; test bounded RAM and realistic storage exhaustion behavior.
4. Open, navigate, select, paste and edit realistically very large and long-line documents with stable low memory overhead and responsive viewport interaction; record document sizes, work patterns, latencies and peak memory rather than a generic pass/fail claim.
5. Keep the GUI lightweight and correct under tabs, wide/combining characters, wrapping, scrolling and line numbering, with coherent hit testing and viewport update costs tied to visible content wherever feasible.
6. Run the advanced text core independently of the browser view and embed it in an ordinary browser page or a secure Electron host; verify the core does not assume DOM APIs or renderer-specific state.

## Working design (not normative)

- Compare two main rendering approaches: separate text and left-gutter DOM regions whose alignment is coordinated via CSS/layout/scroll calculations, versus a coordinated DOM structure that gives gutters and editable lines shared layout geometry. Evaluate performance, virtualization, line wrap, scrolling and hit testing before selecting either.
- Compare data structures for huge editable documents (e.g. piece table, rope, balanced indexed tree, piece-tree hybrids), indexing, lazy line geometry and copy-minimizing batch edits; benchmark editing complexity, retained memory, random navigation, Unicode/tabs and long-line behavior before selecting.
- Compare a minimal viewport-only DOM projection with alternative input/rendering strategies; document/editing state must not be mirrored in a full-file DOM. Validate correctness of IME, accessibility, selection hit testing, line numbering and scrolling while minimizing DOM churn.
- Investigate generalized non-linear selection/edit transaction representation separately from any renderer coordinates: document positions, visual columns/virtual spaces and grouped transformations are distinct concerns. Avoid prescribing concrete API/object names before experiments.
- Undo/redo strategy candidates include compact edit deltas and periodically indexed checkpoints, with RAM-bounded storage and optionally persistent/disk-backed history where supported. A potentially unlimited logical history is not a promise of infinite physical storage.
- Examine MadEdit-Mod multiline/column paste semantics with a table of concrete input documents, selection shapes, pasted text, expected output and restored undo state; separate tabular parsing/import behavior from general text placement.
- Compare underlying data and rendering ownership: native DOM/contenteditable versus a controlled document model and separate view/input projection; tradeoffs include column geometry, selection, IME, accessibility, rendering cost and memory.
- Static source review at `m` master `2a57a298`: `m/text/TextEdit.js` holds one string, sorted offset ranges (`start`, `end`, `forward`), mutation listeners and multi-range insertion/removal; `insertText(text, columnMode)` distributes newline-separated input over existing ranges. It does not derive rectangles from visual coordinates, support virtual columns, or define tab/Unicode display-cell geometry.
- `m/ui/TextEdit.js` is a skeleton; `m/ui/editor.js` is not included in `modules-js.json`. The actual Electron `editor.html` loads a separate host `html/js/editor.js`, while the dynamic library manifest exports the text model and skeletal UI. Thus reference UI/model/selection synchronization is incomplete: the host starts with no model selection ranges and does not project browser selections back into them.
- Source-level defects/risks needing targeted executable regression checks: `addSelectionRange` can accept overlap with an earlier range; `getSelectionRangesCopy` assigns an undeclared variable; `collapseSelectionRanges` uses `indexTo || length`; negative removal at file start reaches JS `slice` with a negative offset; `reverse.js` still contains unexpanded combining-mark template placeholders. Mutation callbacks are not an undo/redo transaction history.
- The host paste handler uses clipboard plain text as `innerHTML` (DOM injection risk), and the old Electron host disables sandbox, web security and context isolation while enabling Node integration and `eval`-based IPC/menu handling; do not reuse that host as a security baseline.
- Upstream MadEdit-Mod documents column-mode switching, column alignment and optional paste autofill across selected rows (the Mod explicitly extends original MadEdit). Treat these as benchmark candidates to reproduce/verify against the user's Windows MadEdit workflow, not as already adopted editor requirements.
- CodeMirror, Monaco and Ace are technique/reference sources only, not engine candidates. The first-party core and view must be validated with targeted, real benchmarks rather than presumed faster merely because it is custom.
- A prior exploratory PoC 061 demonstrated CodeMirror rectangular mouse selection, typing, undo, separate instances and offline single-JS inclusion. It was a narrow feasibility check and does not validate the user benchmark or fix the editor architecture. Bundling-related research belongs to the separate JavaScript toolchain handoff.

## Completed

- An initial feasibility PoC was created in `rumiai-dev-PoCs/pocs/061-web-editor-column-bundle/`; hosted runs `37973245759`, `37973599869` and `37973843577` passed the narrow browser interaction/build checks.
- The last hosted PoC published an ephemeral `editor-single-js` artefact (ID `11638197519`, expires 2027-01-07). This is not a formal product release.
- Re-scoped this handoff to editor semantics and foundational architecture after the user's explicit separation of the independent JavaScript compilation/deployment problem.
- Inspected current reference `m` text model, module manifests, experimental UI and old Electron pages/host, and re-read PoC 061 source/browser-test coverage (static review only in this checkpoint; no new runtime test or editor implementation).
- Recorded the user's newly fixed high-performance, memory, MadEdit-Mod, non-linear-editing, undo/redo and replaceable-core requirements (2026-10-10). No editor implementation or performance tests were added in this checkpoint.

## Current state

Editor architecture remains unselected, but the decision space is narrower: a first-party, performance-oriented text core decoupled from a lightweight GUI is required; mainstream embedded editor engines are not candidates. Historical `m` is experimental reference evidence rather than a product to repair; PoC 061 is only narrow browser feasibility. Data representation, input/view rendering, history storage and exact MadEdit-Mod paste behavior remain unvalidated. No new execution/benchmark evidence exists at this checkpoint; the JavaScript toolchain remains a separate workstream.

## Next action

Build a small behavior-first MadEdit-Mod acceptance corpus centered on multiline/tabular paste, multi-cursor/non-linear editing and complete undo/redo state. In parallel design small independent core benchmarks for very large documents and memory/history growth, then evaluate storage/selection structures and viewport-only DOM rendering with targeted experiments. Select concrete representations only after measured tradeoffs; do not revive CodeMirror/Monaco/Ace as engine options or conflate this work with the JavaScript toolchain.

## Blockers / open questions

- Which exact MadEdit column-editing interactions distinguish it from competitors, and how do they behave for short lines, virtual columns, tabs, Unicode and clipboard?
- Which huge-document data structure, generalized selection model, edit/undo transaction form, viewport geometry and input strategy meet the performance/memory constraints?
- What are defensible benchmark scales, RAM/latency budgets and persistence limits for potentially unlimited undo/redo in browsers versus native hosts?
