# JavaScript development, module loading and distribution

Status: Active
Updated: 2026-10-09

## Goal

Independently investigate a general-purpose JavaScript development/distribution workflow that retains the useful behavior of the reference `m/jsc` and `m.js` dynamic loader, compares current standards and upstream tools critically, and integrates with current `mk` only at its established lifecycle boundary. This work is NOT editor architecture or column editing.

## Current repository revisions

- `rumiai-dev` main: `de82b9c5d2044d81615f2339406d2aa7d68ff463` (preflight).
- `rumiai-os` main: `6a964ba3f5c8acf462737e3b92daaf1af32de57e`.
- Reference repository `m` master: `2a57a29880c2d7a32e18782122062c695fcb1a3a`.
- `rumiai-dev-PoCs` main: `0f9c5b7fd78f22716cdd1be4423fda91b557eb78`.

Always recheck remote HEADs on resumption and before writes.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`.
- `specifications/rumiai-os/CURRENT-MODEL.md`, `specifications/rumiai-os/MK.md`.
- If modifying an owned `m` command or library: `COMMAND-ENTRYPOINTS.md`, `FILESYSTEM-NAMING.md`, `LIBRARY-INTERFACES.md`, `DOCUMENTATION-MODEL.md` and corresponding manuals.
- Source evidence: reference `m/cmd/jsc`, `m/cmd/jsc.js`, `m/js/lib/js/m/mod/LibraryDynamic.js`, `m/js/lib/dynamic-loader/dynamic-loader.js`; current `rumiai-os/lib/sys/js/mk.lib.js`.
- The separate editor task is `handoff/browser-column-editor.md`; its initial PoC 061 is only evidence of single-bundle feasibility, not the compiler's governing task.

## Fixed task-local choices

- JavaScript build/distribution is an independent objective, not a hidden editor subsystem.
- The user wants to preserve the useful capability of changing/loading libraries dynamically during development and testing, and loading modules only when needed, while still being able to ship a simple distribution (possibly one file).
- Prefer existing standards and tools when they satisfy the requirements, but compare them against the reference `m` behavior rather than treating bundle size/speed alone as success.
- The current `mk` owns lifecycle orchestration and may delegate to third-party bundlers. There is no accepted need yet for a new native compiler, loader, provider or command.

## Acceptance scenarios

1. Develop multiple JS source modules using one coherent source/module model; invoke an ordinary project build to produce a self-contained browser distributable without installing a developer toolchain on the consumer's computer.
2. During development load an optional module only when first requested, with deterministic dependency/exposure behavior; clearly distinguish lazy network fetch from deferred execution of code already present in one file.
3. Replace a changed development module in an already running app when supported, with clear accept/dispose/state rules and without unintended duplicated listeners/timers. Explicitly expose cases that need full reload.
4. Distribute one self-contained JavaScript file for use in a regular page (including file:// when possible), and optionally use a multi-file on-demand distribution without accidentally promising both physical properties simultaneously.
5. Reuse existing `mk` project declarations and generic process boundary where sufficient; any proposed extension must show an actual unmet general responsibility first.

## Working design (not normative)

- Distinguish bundling, lazy fetching, lazy evaluation and hot module replacement. One-file delivery can defer execution but cannot avoid transmitting embedded source bytes.
- Legacy `jsc` reads an explicit JSON hierarchy and concatenates source/export/namespace code, optionally Closure-minifies and gzip-compresses. Its Java API reference and generated eval-based namespace code are not modern production-ready.
- Legacy `LibraryDynamic.js` reads manifest and sources through XHR, queues concatenation, executes/evaluates the assembled result and can remove/reinsert script or CSS elements. This is library-level dynamic loading/reinsertion, not yet demonstrated as fine-grained dependency-aware lazy import or safe state-preserving HMR. The XHR/POST/synchronous/eval patterns deserve replacement rather than direct reuse.
- Current standard alternatives: browser ESM `import()` and import maps; esbuild/Rollup for bundle generation and splitting; Vite/webpack for development HMR; SystemJS for an explicit managed runtime module registry; JSPM import-map tooling. Evaluation must cover import semantics, state continuity, CORS/file://, CSP, offline/self-contained delivery and toolchain complexity.
- Avoid duplicate hand-written module manifests where ESM static/dynamic imports already describe the necessary dependency graph; an explicit manifest is only potentially justified for product-specific selection/publishing rules that cannot be derived.
- The initial editor PoC 061 proved a single 305.2 KB minified JS in headless Chromium via file:// with zero HTTP requests. It did not validate the `mk` invocation, general-purpose hot loading, lazy loading, lifecycle replacement or the compiler design.
- Candidate development and distribution strategies remain under evaluation; do not promote them as `mk` specification.
- Fresh comparison of reference `m/js/lib/js/m/Class.js` (39 KB) with ECMAScript 2026: legacy `m.Class` supplies multiple base constructor calls/behavior copying or getter-links, per-instance composed defaults (shallow copying), shared prototype state, fluent properties with getter/setter/listener/validator, before/after triggers, event bindings, singleton/call-mode choices, method aliasing and runtime changes. Standard `class` does not directly supply the combined metaobject model, although modern prototypes/accessors/Proxy/Reflect can implement many pieces. Legacy multi-base support is not native multiple prototype inheritance/automatic multiple `instanceof` identity.
- Hard interoperability mismatches from current source: `Class.prototype.inherit` enumerates prototype members using `for...in` (native `class` methods are nonenumerable), while `Class.prototype._construct` invokes base constructors via `.apply` (native class constructors reject function-call invocation). The `_inherit.length___` check in the first-base branch appears erroneous and needs specific tests; do not assert runtime failure without authentic execution.
- ES module syntax and ES class syntax are independent. A legacy function-constructor-based `m.Class` can be exported/imported as ESM without redesigning its inheritance model, provided legacy global coupling is adapted explicitly. ESM static exports are live read-only imported bindings and ESM caching has no standard unload/reset API, so module HMR requires explicit lifecycle indirection. Native `import()` supplies loading on demand; experimental `import defer` (TC39 Stage 3 in 2026, limited browser support) separates eager fetching/linking from deferred evaluation.
- Modern `#private` fields are not dynamically injected through prototype copying, and standard `super`/class-field initialization semantics differ from legacy constructor chaining. Stage 2.7 decorators are not a stable cross-browser replacement for `m.Class` listeners/triggers. Types (e.g. TypeScript interfaces) do not add runtime multiple inheritance or HMR functionality.

## Completed

- Verified current remote repository heads and read canonical development authority.
- Inspected current `mk` process-action implementation and reference `m` compilation/dynamic-loading code.
- Established upstream capability baselines from standards and upstream docs for native `import()`, import maps, Vite HMR, webpack HMR, esbuild splitting, Rollup inline dynamic imports, SystemJS loader/registry, JSPM import map tooling.
- Split task responsibility from the editor investigation after the user clarified the independent goals.
- Retrieved and inspected the full reference `m.Class` implementation; checked selected interoperability properties against Node.js 22 and consulted up-to-date ECMAScript/MDN/TC39 sources. This is a static/mechanical assessment, not full execution of the legacy `m.Class` implementation.

## Current state

Investigation and working design only. No JS compiler or runtime-loader implementation was created or modified in this work unit; no hosted/browser runtime comparisons of hot swap/lazy loading have been run. The earlier PoC 061 is a separate editor-driven bundling feasibility experiment, not proof of a complete general JavaScript toolchain.

## Next action

First devise a focused compatibility matrix and real PoC for legacy `m.Class` capabilities versus current ECMAScript classes/prototypes, with old constructors packaged inside ESM modules, including multiple inheritance, observable properties and hot method replacement. Then compare native ESM + dynamic import, esbuild/Rollup output and SystemJS or Vite development-time replacement using the same small source graph. Measure actual fetch, execution, re-evaluation/state cleanup, local-file/browser compatibility, output count, CSP constraints and integration through real `mk`. Promote a `mk` extension only if a concrete uncovered lifecycle responsibility is demonstrated.

## Blockers / open questions

- Is preserving state across hot reload mandatory for every module, or can modules declare accept/dispose boundaries and request a full reload for incompatible updates?
- How much should one-file distribution sacrifice in exchange for deferred evaluation, and should a separate multi-file lazy distribution be available?
- Can an existing standard module graph fully replace the legacy JSON descriptor's explicit order/namespace/exposure semantics for the cases that still matter?
