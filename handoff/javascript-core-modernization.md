# Legacy JavaScript core modernization

Status: Active
Updated: 2026-10-14

## Goal

Modernize the imported first-party JavaScript source tree `rumiai-os/lib/sys/js/core/` for the current `jsc` while preserving established public namespace and behavior. `core-ext` remains outside this initial workstream.

## Current repository revisions

- `rumiai-dev/main`: `1b3ee45def875f42389e80a8c12cb18d00aaca9d` before this checkpoint; concurrently advanced from the initial handoff commit on the unrelated AI-cluster handoff.
- `rumiai-os/main`: `3cd5b6a61d5d96cfb18cefc53af34ec4ce037fc8`.
- `rumiai-tests/main`: `47e87d32c9b38e1b7fd49155c98d47008019f3e6`.

Always retrieve fresh remote HEADs on resumption.

## Applicable canonical sources

- `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `TESTING.md`.
- `specifications/rumiai-os/JSC.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md`, `DIAGNOSTICS.md`.

## Fixed task-local choices

- Work on `core` only; do not change `jsc` compiler or its separate dynamic-loader responsibilities, which are owned by `handoff/javascript-build-and-runtime-loading.md`.
- Start from historic core sources, preserve `m` namespace, authored source order, `m.Class` and public signatures; repair demonstrated runtime defects and modernize incrementally.
- Avoid mass mechanical class/var rewrites and do not implicitly redefine legacy `@eval` or JSON reference behavior.
- Browser and CommonJS are both supported by the generated core bundle through the current `jsc` contract.

## Acceptance scenarios

- The real `jsc` compiles `core/modules-js.json` with strict syntax.
- The generated script executes in actual Chrome as a classic browser script, publishing representative `m` Class, utility, JSON and logging interfaces.
- The generated script executes as an independent CommonJS module and returns its public `m` namespace without publishing `globalThis.m`.

## Completed

- Current mandatory preflight and initial review of imported core and permanent `jsc` tests.
- Product `870977c55366e502af48a13cea22b3907a995b7c`: changed manifest `symbols` to `exports`, fixed strict-mode `g` assignment and DOM-only initialization, removed `new Function` from environment detection, restored strict-compatible legacy `json.path` return behavior.
- Product `b1d8b6c82cd9bb9734ed15f9cb36ddb615327344`: simplified browser/Node/Electron and mobile detection, bound `globalThis.performance.now` correctly for `m.util.timestamp`, removed conflicting `timestamp` declaration from benchmark utility while preserving `Date.now()` there, and made `uniqueID` sequence lexical.
- Permanent tests `rumiai-tests@47e87d32c9b38e1b7fd49155c98d47008019f3e6`: `tests/rumiai-os/js-core/compile.test` with real compiler, browser-like VM + CommonJS contract checks, and actual headless Chrome with HTTP-served classic script. Clock binding and mobile fallback are covered.
- Product CI `.github/workflows/js-core.yml` tracks `core/**`, uses Node.js 22 and real Chrome, pins the permanent test revision. Earlier checkout-origin setup issue fixed.
- [GitHub Actions run 38554124248](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38554124248): **SUCCESS** on exact product `3cd5b6a61d5d96cfb18cefc53af34ec4ce037fc8` with the pinned permanent tests. Hosted Linux + Chrome execution, not physical reference-host validation.
- Reviewed forward diff: product changes limited to `core` fragments and their CI workflow; tests limited to new core regression suite. Existing `jsc`, `core-ext`, other tasks and source loaders were not changed.

## Current state

First compiler/runtime compatibility and basic utility modernization are complete and mechanically protected. **Full core modernization remains active.** The current manifest still includes historic `Class`, JSON resolver, logger, other utility and queue implementations.

## Working design

- Analyze `m/Class.js` semantics and coupling before modernizing; it is not interchangeable with native `class` on a textual substitution basis.
- `m/json/path.js` retains legacy expression evaluation using `eval` for compatibility. `m/json/resolve.js` still contains numerous `eval`-based behaviors including `@eval`; redesign requires explicit compatibility analysis and dedicated regression before removal.
- `core/lib-dynamic.js` appears to duplicate the separate established browser loader; verify actual consumers before changing/removing it.
- Grouped `core` source fragments are not `*.lib.js` library leaves. Reassess library distribution identity and operational manual coupling when promoting a standalone library; do not invent an API leaf now.

## Queue analysis checkpoint — 2026-10-14

- User requested analysis only, with **no product code changes**.
- Current sources inspected at `rumiai-os@ef466362e9630b86d81b07ca647c2f2fbfd97a22`: `core/m/mod/Queue.js`, the relevant `Class.js` constructor/composition machinery, source manifest, `core-ext/m/mod/Module.js`, and a separate legacy internal `Queue` in `core/lib-dynamic.js`. Permanent core tests inspected at `rumiai-tests@b8d5cbea34784d1a42af2b00bf22c09fec9d478c` contain no Queue-specific assertions.
- Semantics observed: FIFO *callback delivery* in registration order despite out-of-order completion; completion closures preserve their invocation `this` and arguments; `Class.compose` provides distinct instance arrays; omitted/null callback is a no-op ordering barrier; invalid callback throws TypeError; callback failures are logged and swallowed so later ready callbacks continue.
- In-memory runtime exercises used the exact current `Class.js` and `Queue.js` sources (not the actual compiled `jsc` artifact). Results: normal ordering/contexts/instance isolation pass; duplicate completion while pending overwrites pending arguments (last completion wins); callbacks added and completed inside a running callback execute reentrantly; a burst of 14,000 ready callbacks triggered V8 `RangeError: Maximum call stack size exceeded` and left 5,691 items queued in that exercise.
- Root causes: recursive `exec()` (unbounded stack) and repeated `splice(0,1)` (potential quadratic drain cost); no timeout/cancellation/error propagation; head-of-line blocking is expected FIFO semantics, not automatically a bug. Exposed `queue` array can be mutated externally. The `thread race condition` guard is not evidence of actual JavaScript threading; ordinary code between observing the head and `splice` is synchronous.
- The existing `core/lib-dynamic.js` has a separate internal copy of the Queue algorithm. The `core-ext` Module consumer invokes `m.mod.Queue`; no refactor was authorized or performed.
- Follow-up when implementation is authorized: preserve ordered callback delivery and completion-context semantics, establish permanent Queue regression coverage through real `jsc` output, then consider iterative draining, controlled duplicate-completion semantics, and explicit error policy. These are working analysis findings, not promoted subsystem contracts.

## `m.log.*` analysis checkpoint — 2026-10-15

- User requested source analysis only: do **not** modify product code. Inspected the five current logging fragments, `m/init.js`, `m/Class.js`, descriptor, relevant canonical diagnostics/JSC contracts, and core smoke tests at `rumiai-os@9385d13786130ceb84cb541b5da9eeb71f692ded` and `rumiai-tests@b8d5cbea34784d1a42af2b00bf22c09fec9d478c`.
- Actual interface: `m.log.Log` is a level-filtered broadcaster with `add/remove`, `level`, and `fatal/error/warn/info/debug/trace`; `Logger` is a no-op interface base; `LoggerConsoleSimple` uses `console.log`; `LoggerConsoleTrace` uses `console.trace`; `LoggerStore` currently only `console.log(..., JSON.stringify(data))` and does not persist. `m/init.js` sets `m.global.log = m.log.Log()`, adds one simple console sink, sets WARN.
- In-memory runtime checks using *exact current* `Class.js` and logging sources (not the real jsc-assembled artifact): `new LoggerConsoleSimple()/LoggerConsoleTrace()/LoggerStore() instanceof Logger` all false, and `Log.remove(instance)` throws TypeError. This traces to `Class.prototype.inherit` first-inheritance condition `this._inherit.length___ === 0`, so the expected prototype link is not established. Affects `Class` more generally; do not repair silently within a logging-only change.
- More observed defects/risks: `add` accepts arbitrary and duplicate sinks while object-based `remove` requires `instanceof Logger`; numeric `remove` permits negative/out-of-range positions; sink errors abort remaining fan-out; `Log.log` throws `data[0]` when it is an Error *only if level passes filtering*, coupling logging to control flow. `Log.level` accepts arbitrary types. Caller extraction uses hard-coded `Error.stack` line/space parsing and throws on missing/short stack; date is UTC but time local. `LoggerStore` has no actual store and JSON serialization fails for cycles, reduces native Error objects to `{}`.
- Canonical `DIAGNOSTICS.md` uses structured diagnostic identity `<domain>.<message-id>`, meaningful context, stable severity. Legacy JS `m.log` currently carries unstructured arguments and guessed stack caller; explicit consistency design is needed, not an implicit new architecture or renaming. Distinguish this JS namespace from the general `m` `log` runtime facility.
- Permanent `js-core` tests check only `typeof m.log.Log === 'function'`; no specific logging/transport/inheritance/sink-contract regressions. Proposed future order: preserve the existing public surface and establish real `jsc` logging regression tests, resolve the shared `m.Class` inheritance defect with its own bounded coverage, then decide the failure/exception policy, sink removal and dispatch, diagnostic representation, and whether/how `LoggerStore` should persist.
- No product or test source edits were made for this investigation; in-memory targeted probes are not validation of the compiled bundle.

## Native `m.log.Log` analysis checkpoint — 2026-10-15

- User requested analysis of the *new current* `m.log.Log` without product code changes. Read current `rumiai-os/main@3c5b5460f4bc284142e271f039fd61eff9538750`: `core/m/log/Log.js`, all four native `Logger` classes, `core/m/init.js`, core descriptor, plus the separate `core-ext` legacy logger sources and its manifest/init. Read permanent `rumiai-tests@b8d5cbea34784d1a42af2b00bf22c09fec9d478c` core smoke tests and canonical `JSC.md`/`DIAGNOSTICS.md`.
- New `Log` uses native `class`, static frozen level constants, per-instance private `#level` and `#loggers`; `core/m/init.js` now calls `new m.log.Log()`. In-memory behavior probes with the exact current logger source verified level filtering, multi-sink dispatch and argument format, native-instance add/remove, distinct instance state, and current failure behavior; these probes were not the real jsc bundle.
- Material API delta: `add` now enforces `instanceof Logger`, rejects former duck-typed sinks and throws `ReferenceError` on invalid type, while `remove` uses `TypeError` for invalid type. `remove(index)` still permits negative indices. `level(value)` accepts invalid types (non-numeric strings effectively suppress logging).
- Confirmed legacy runtime risks remain: `log` rethrows its first `Error` data item **only when its severity passes filtering**; a sink exception aborts delivery to subsequent sinks; stack caller parsing uses a hard-coded position; date comes from UTC while time is local; `log(level,levelString)` with absent data can throw `TypeError`; no structured diagnostic identity per `DIAGNOSTICS.md`.
- `core-ext/m/init.js` remains legacy and calls `m.log.Log()` without `new`, incompatible **if** executed against native `core` `Log`; its own legacy logging sources still exist but are not included in the inspected `core-ext/modules-js.json`. No claim that this legacy composition is active or successfully built, and no `core-ext` change authorized.
- Current GitHub Actions [run 38729337423](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38729337423) reports **success** for exact product HEAD `3c5b5460f4bc284142e271f039fd61eff9538750`, validating the existing real-jsc/browser smoke scope, not comprehensive logging behavior. Existing permanent tests assert `typeof m.log.Log`, but not the above logger semantics.
- No product/test code edits. Future alignment requires explicit contract choices for log-exception policy, accepted sink interface/errors, level validation and index removal, and structured diagnostics, with real compiled-bundle regression tests before integration.

## `Log.level` and `core-ext` initialization follow-up — 2026-10-15

- User requested analysis of new `rumiai-os/main@2c6c53ef617a2b840bba50e130399d99d42396fc` commit `js m log` (parent `3c5b5460f4bc284142e271f039fd61eff9538750`), not a product implementation. Its only semantic edits: `core/m/log/Log.js` `level(value)` now throws `TypeError` for non-number arguments; `core-ext/m/init.js` uses `new m.log.Log()` instead of `m.log.Log()`. Whitespace-only change in `Log.add`.
- Direct in-memory probes on the exact updated core Log/Logger source confirm the new type guard rejects explicit undefined/null/strings/booleans, but still accepts `NaN`, `Infinity`, `-Infinity`, negative numbers and fractional/unlisted levels. `NaN` filters all logging; no domain validation yet. No real core-ext composed runtime test executed.
- `core-ext/m/init.js` still assigns `g = m.g` without declaring `g` in that file; a strict isolated execution with no pre-existing `g` raises `ReferenceError`. This alone does **not** establish real core-ext bundle failure, since other earlier source bindings could influence execution. Direct document/location dependence also remains. The core-ext manifest still uses legacy `symbols` descriptors; legacy core-ext modernization remains separately scoped/pending.
- [GitHub Actions run 38731376797](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38731376797) succeeded at this exact product revision. Current `.github/workflows/js-core.yml` includes `core/**`, but not `core-ext/**`, and runs the existing compiler/classic browser/CommonJS smoke scope, not level-edge-case or core-ext execution coverage. `rumiai-tests/main` remains `b8d5cbea34784d1a42af2b00bf22c09fec9d478c`.
- No product or test code edited; this checkpoint updates task evidence only. Outstanding design choice: constrain `Log.level` to the defined enum if that is the intended contract, and plan authentic compatibility tests for core-ext before claiming it is aligned.

## Next action

Incrementally inventory and regression-test `Class`, JSON and remaining utilities, then modernize one cohesive responsibility at a time without changing historical contracts silently.

## Blockers / open questions

No blocker to continued scoped refactoring. Full legacy `@eval` semantics and any future behavioral redesign remain undecided; no user authorization to change them was assumed.
