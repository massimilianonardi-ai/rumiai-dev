# Advanced browser/Electron text editor

Status: Active — reference editor analyzed; model/renderer comparison pending
Updated: 2026-10-10

## Goal

Design and eventually build an advanced JavaScript text editor whose column-editing usability is informed by the specific behavior of the Windows MadEdit editor, rather than assuming that conventional multicursor or rectangular selection implementations cover the user's actual needs. Target reusable browser/library and optional Electron hosts.

The JavaScript compilation, module loading and distribution concern has **independent ownership** at `handoff/javascript-build-and-runtime-loading.md`. This handoff must not make bundler/loader decisions.

## Current repository revisions

- `rumiai-dev` main: `52b57b0ec86cd0398176cf57bb8d556cc57010d7` (before this checkpoint).
- `rumiai-dev-PoCs` main: `12c2f061aae5561663f62ce52723a294a73b4918`.
- Reference `m` master: `2a57a29880c2d7a32e18782122062c695fcb1a3a`.
- `rumiai-os` main: `0cc8ac2a7886209cf871e0ac24b205fe814d508c`.

Always recheck current remote HEADs before resuming or changing files.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/CURRENT-MODEL.md`.
- Reference `m/js/lib/ui-text-edit/m/text/TextEdit.js`, `m/js/lib/ui-text-edit/m/ui/`, `m/js/electron-app-editor/`.
- The separately deferred terminal `vsed` advanced-editor work is `todo/vsed-advanced-editor-evaluation.md` and is not this editor.
- The JavaScript toolchain is owned by `handoff/javascript-build-and-runtime-loading.md`.

## Fixed task-local choices

- This editor is an independently useful product, not a test fixture for a bundler or an extension of the terminal `vsed`.
- Column editing is a primary functional requirement; MadEdit for Windows is the user's benchmark for useful behavior, even when other editors offer more overall features.
- Browser-embeddable JavaScript is desirable for reuse across browser, local and Electron contexts.
- The core editor architecture must be evaluated **before** adopting a renderer or editing engine. The early CodeMirror PoC does not settle the choice of editor engine.

## Acceptance scenarios

1. The user can reproduce the actual useful MadEdit column-editing workflows, which first need specific characterization; mere support for rectangular selection and multiple cursors is not enough.
2. Text, cursor, selection, character alignment and line numbering remain correct under realistic long lines, fonts, tabs, line wraps and scrolling.
3. The same editor logic can be embedded into an ordinary browser page and wrapped by a secure Electron application without imposing an unrelated web framework.
4. Large documents and repeated editing operations remain responsive and correct without losing undo/redo, clipboard or textual fidelity.

## Working design (not normative)

- Compare two main rendering approaches: separate text and left-gutter DOM regions whose alignment is coordinated via CSS/layout/scroll calculations, versus a coordinated DOM structure that gives gutters and editable lines shared layout geometry. Evaluate performance, virtualization, line wrap, scrolling and hit testing before selecting either.
- Compare underlying data and rendering ownership: native DOM/contenteditable versus a controlled document model and separate view/input projection; the tradeoffs influence column geometry, selection, IME, accessibility and performance.
- Static source review at `m` master `2a57a298`: `m/text/TextEdit.js` holds one string, sorted offset ranges (`start`, `end`, `forward`), mutation listeners and multi-range insertion/removal; `insertText(text, columnMode)` distributes newline-separated input over existing ranges. It does not derive rectangles from visual coordinates, support virtual columns, or define tab/Unicode display-cell geometry.
- `m/ui/TextEdit.js` is a skeleton; `m/ui/editor.js` is not included in `modules-js.json`. The actual Electron `editor.html` loads a separate host `html/js/editor.js`, while the dynamic library manifest exports the text model and skeletal UI. Thus reference UI/model/selection synchronization is incomplete: the host starts with no model selection ranges and does not project browser selections back into them.
- Source-level defects/risks needing targeted executable regression checks: `addSelectionRange` can accept overlap with an earlier range; `getSelectionRangesCopy` assigns an undeclared variable; `collapseSelectionRanges` uses `indexTo || length`; negative removal at file start reaches JS `slice` with a negative offset; `reverse.js` still contains unexpanded combining-mark template placeholders. Mutation callbacks are not an undo/redo transaction history.
- The host paste handler uses clipboard plain text as `innerHTML` (DOM injection risk), and the old Electron host disables sandbox, web security and context isolation while enabling Node integration and `eval`-based IPC/menu handling; do not reuse that host as a security baseline.
- Upstream MadEdit-Mod documents column-mode switching, column alignment and optional paste autofill across selected rows (the Mod explicitly extends original MadEdit). Treat these as benchmark candidates to reproduce/verify against the user's Windows MadEdit workflow, not as already adopted editor requirements.
- CodeMirror, Monaco, Ace and first-party editing/rendering remain candidates, not approved architecture.
- A prior exploratory PoC 061 demonstrated CodeMirror rectangular mouse selection, typing, undo, separate instances and offline single-JS inclusion. It was a narrow feasibility check and does not validate the user benchmark or fix the editor architecture. Bundling-related research belongs to the separate JavaScript toolchain handoff.

## Completed

- An initial feasibility PoC was created in `rumiai-dev-PoCs/pocs/061-web-editor-column-bundle/`; hosted runs `37973245759`, `37973599869` and `37973843577` passed the narrow browser interaction/build checks.
- The last hosted PoC published an ephemeral `editor-single-js` artefact (ID `11638197519`, expires 2027-01-07). This is not a formal product release.
- Re-scoped this handoff to editor semantics and foundational architecture after the user's explicit separation of the independent JavaScript compilation/deployment problem.
- Inspected current reference `m` text model, module manifests, experimental UI and old Electron pages/host, and re-read PoC 061 source/browser-test coverage (static review only in this checkpoint; no new runtime test or editor implementation).

## Current state

Editor architecture remains unselected. The reference `m` analysis shows reusable multi-range concepts but no complete visual-column geometry or coherent text/model/DOM editing path; it also exposes concrete source-level correctness and host-security risks. This checkpoint is static inspection, not runtime validation. PoC 061 still establishes only narrow browser feasibility; bundler/loader design remains independently owned.

## Next action

Characterize representative Windows MadEdit column workflows as an executable acceptance matrix: rectangular drag and keyboard selection; caret/typing beyond short-line EOL; multiline paste with fewer/more rows; tabs, wide/combining characters, CRLF, wrapping and scroll; undo/redo grouping and clipboard. Then compare candidate document/selection representations and DOM/contenteditable versus controlled-renderer input/geometry with minimal targeted experiments, before selecting an engine. Keep the separate JavaScript toolchain decisions in its owning handoff.

## Blockers / open questions

- Which exact MadEdit column-editing interactions distinguish it from competitors, and how do they behave for short lines, virtual columns, tabs, Unicode and clipboard?
- Which text model, selection representation, editable/input approach and gutter/line geometry strategy can support those interactions robustly?
