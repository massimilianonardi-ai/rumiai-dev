# Advanced browser/Electron text editor

Status: Active — paused while independent JavaScript toolchain work is examined
Updated: 2026-10-09

## Goal

Design and eventually build an advanced JavaScript text editor whose column-editing usability is informed by the specific behavior of the Windows MadEdit editor, rather than assuming that conventional multicursor or rectangular selection implementations cover the user's actual needs. Target reusable browser/library and optional Electron hosts.

The JavaScript compilation, module loading and distribution concern has **independent ownership** at `handoff/javascript-build-and-runtime-loading.md`. This handoff must not make bundler/loader decisions.

## Current repository revisions

- `rumiai-dev` main: `f25e6e5f9ba1a7cf47dab76bc52a333af9a18d6f` (before this checkpoint).
- `rumiai-dev-PoCs` main: `0f9c5b7fd78f22716cdd1be4423fda91b557eb78`.
- Reference `m` master: `2a57a29880c2d7a32e18782122062c695fcb1a3a`.
- `rumiai-os` main: `6a964ba3f5c8acf462737e3b92daaf1af32de57e`.

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
- Reference `m` TextEdit already has multirange operations and a `columnMode` insertion switch; it does not prove full MadEdit-like column semantics. The old Electron host is not a secure integration baseline.
- CodeMirror, Monaco, Ace and first-party editing/rendering remain candidates, not approved architecture.
- A prior exploratory PoC 061 demonstrated CodeMirror rectangular mouse selection, typing, undo, separate instances and offline single-JS inclusion. It was a narrow feasibility check and does not validate the user benchmark or fix the editor architecture. Bundling-related research belongs to the separate JavaScript toolchain handoff.

## Completed

- An initial feasibility PoC was created in `rumiai-dev-PoCs/pocs/061-web-editor-column-bundle/`; hosted runs `37973245759`, `37973599869` and `37973843577` passed the narrow browser interaction/build checks.
- The last hosted PoC published an ephemeral `editor-single-js` artefact (ID `11638197519`, expires 2027-01-07). This is not a formal product release.
- Re-scoped this handoff to editor semantics and foundational architecture after the user's explicit separation of the independent JavaScript compilation/deployment problem.

## Current state

Editor architecture is not yet selected. Functional benchmark definition and foundational rendering/model comparison remain outstanding. Work on this editor is paused while the independent JavaScript toolchain question is examined; the initial PoC remains experimental evidence only.

## Next action

When editor work resumes, first characterize MadEdit's distinctive column-editing workflows and compare foundational document/rendering choices. Do not treat the earlier CodeMirror feasibility prototype as an approved engine or develop more editor features before the architecture analysis.

## Blockers / open questions

- Which exact MadEdit column-editing interactions distinguish it from competitors, and how do they behave for short lines, virtual columns, tabs, Unicode and clipboard?
- Which text model, selection representation, editable/input approach and gutter/line geometry strategy can support those interactions robustly?
