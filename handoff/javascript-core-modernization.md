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

## Next action

Incrementally inventory and regression-test `Class`, JSON and remaining utilities, then modernize one cohesive responsibility at a time without changing historical contracts silently.

## Blockers / open questions

No blocker to continued scoped refactoring. Full legacy `@eval` semantics and any future behavioral redesign remain undecided; no user authorization to change them was assumed.
