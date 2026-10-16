# JavaScript compilation and dynamic JS/CSS loading

Status: Complete
Updated: 2026-10-16

## Completed outcome

The `jsc` compiler remains a generic descriptor-driven compiler with its
own current contract in `specifications/rumiai-os/JSC.md`. The separately
compiled browser runtime `m.mod.DynamicLoader` is implemented from
`lib/sys/js/core/m/mod/DynamicLoader.js` and
`lib/sys/js/core/modules-dynamic-loader.json`, using the modern native
`m.mod.Queue`.

The user's final decision is explicit: `load()` succeeds when source
retrieval/composition and DOM insertion succeed; it does **not** guarantee
that loaded JavaScript executes correctly or even executes successfully
under CSP. Bundle/application code and its caller own correctness,
execution diagnostics, readiness and recovery. Source fetching errors
remain loader errors; `load()` may reject on invalid input or DOM
insertion/replacement failure. Replacement does not roll back side effects.
The compiler and runtime loader remain separate technical responsibilities.

The promoted current loader contract is
`specifications/rumiai-os/DYNAMIC-LOADER.md`, routed by
`specifications/README.md`. The new owner-local operational topic is
`rumiai-os/res/sys/manual/mod-dynamic-loader`; the `jsc`,
`jsc.lib.js` and existing distinct `dynamic-loader.lib.js` manuals
cross-link it. The old library and its manual were not deleted or
silently remapped.

## Current repo state and validation

Final task document state:
- `rumiai-dev`: canonical new spec, routing, and standalone deferred
  `todo/legacy-javascript-dynamic-loader-cleanup.md`.
- `rumiai-os`: product `m.mod.DynamicLoader` implementation unchanged by
  the final documentation unit; new operational manual and three manual
  cross-references, with current source still present.
- `rumiai-tests`: permanent special-bundle and real Chromium integration
  tests, including ordering, JS/CSS replacement, HTTP failures and CSP.

The exact product revision `rumiai-os@449448e1817156fbf5b5e86f1093ccc97dee7671`
passed its [core CI run 38920627883](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38920627883)
on hosted GitHub Linux/Chromium. The earlier exact revision
`rumiai-os@9e61714e68afd8eab28df201d7c71ce24b16cfeb`
passed [run 38917315188](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38917315188)
for specialized bundle compilation and CSP. Neither is a physical
validation of the user's host. The final change unit is documentation
only and was checked against live source/API and tests.

## Deferred work ownership

The user explicitly reserved legacy-file cleanup to themselves.
`todo/legacy-javascript-dynamic-loader-cleanup.md` owns that pending
separate activity, including review of legacy consumers, manual and
test references before deletion. No assistant product file deletion,
legacy migration or runtime error-capture feature is authorized or
needed to complete this development task.

## Completion

The current contract, operational reference, implementation and permanent
tested use path are aligned. There is no open design decision or next
action inside this handoff; the separate user-owned cleanup is tracked
by its TODO. This completed handoff is to be removed in a subsequent
forward commit according to the repository workflow.
