# Legacy JavaScript core modernization

Status: Active
Updated: 2026-10-14

## Goal

Modernize the imported first-party JavaScript source tree `rumiai-os/lib/sys/js/core/` for the current `jsc` compiler while retaining its established public namespace and behavior wherever possible. Keep `core-ext` outside this initial work unit.

## Current repository revisions

- `rumiai-dev/main`: `7f90a5ed35570b4c9a7c9451546f6c018074eb2b` at preflight.
- `rumiai-os/main`: `3b073db8b91b74c467322eae20d3a9e5f196b420` at preflight (imported legacy core).
- `rumiai-tests/main`: `f81ad51aa8d7bd0135819149910159f68f313aa5` at preflight.

Fresh HEAD verification is mandatory on resumption.

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`.
- `specifications/rumiai-os/JSC.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`.

## Fixed task-local choices

- Begin with `core` only; do not blend in `core-ext` or revise `jsc` compiler semantics.
- Use the original sources as the starting point; preserve `m` namespace, ordered declarations, `m.Class` semantics and public APIs unless a concrete defect forces a correction.
- Establish executable compilation/runtime baseline before larger code cleanup. Avoid a bulk automatic `var`/class rewrite and do not silently redesign legacy `@eval` behavior.
- The existing `handoff/javascript-build-and-runtime-loading.md` separately owns the `jsc` compiler and dynamic loader, not modernization of these imported application sources.

## Acceptance scenarios

- Compiling `core/modules-js.json` through the real `jsc` engine succeeds as classic JavaScript.
- Loading that compiled JavaScript as a browser classic script publishes `m` and initializes representative `Class`, utility, JSON and logging interfaces without a strict-mode startup error.
- Loading it as a CommonJS bundle exposes `m` through `module.exports` without mandatory namespace publication to globalThis.

## Working design

- Review legacy direct `eval` in `json/path.js` / `json/resolve.js` and code-generated environment detection separately from the minimal startup compatibility corrections. Do not infer a new JSON expression language or remove previously supported behaviors as an incidental refactor.
- Existing legacy `core/lib-dynamic.js` appears to duplicate dynamic-loader functionality; verify actual consumers before any removal.
- Physical grouping as source fragments under `lib/sys/js/core` is not by itself an owned `*.lib.js` leaf identity. Check public distribution/manual coupling as the modernization advances.

## Completed

- Mandatory initial repository preflight and canonical source retrieval.
- Initial source inspection identified legacy `symbols` manifest entries, strict-mode assignment to undeclared `g`, a Node-incompatible DOM initialization path and `new Function`-based environment detection.

## Current state

Legacy `core` is present; no product code or permanent test changes are included in this handoff creation.

## Next action

Make and validate the smallest `core` runtime compatibility patch against the real `jsc`, establish permanent representative tests, then progressively modernize other source files with regression protection.

## Blockers / open questions

No user decision required for the first compatibility patch. Broader behavioral redesign of legacy JSON/eval features is not yet approved.
