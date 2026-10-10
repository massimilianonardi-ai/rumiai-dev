# JavaScript development, module loading and distribution

Status: Active
Updated: 2026-10-10

## Goal

Independently investigate a general-purpose JavaScript development/distribution workflow that retains the useful behavior of the reference `m/jsc` and `m.js` dynamic loader, compares current standards and upstream tools critically, and integrates with current `mk` only at its established lifecycle boundary. This work is NOT editor architecture or column editing.

## Current repository revisions

- `rumiai-dev` main: `95f9c1e0b8bd73616ba6e7c7f02959fb8c7cfb71` (pre-checkpoint; re-verify remotely).
- `rumiai-os` main: `016c95dbfa384d5259a6200498c905b9bb8b61e0`.
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
- The user favors a new first-party `jsc` implementation and a dynamic-loader library as independent evaluable candidates, not immediate default compiler promotion. External engines such as esbuild and webpack are intended future candidates for `mk` tool orchestration and `pkg` package/provider integration; actual product contracts/installation remain to be evaluated separately. The current `mk` owns lifecycle orchestration and may delegate to third-party bundlers. No production change is implied by an exploratory PoC.
- **User correction (2026-10-10), overriding the earlier dual-format experiment:** keep `jsc`'s explicitly managed classic modules and standard ES Modules as separate paths, with no `jsc` reinterpretation, parsing, transpilation or emulation of ESM `import`/`export` semantics; no implicit mixed source graph and no `jsc`-generated native ESM output requirement. Users choose `jsc` + its controlled loader, or a native/externally built ESM project with its own loader semantics. Both paths may be orchestrated through `mk` and acquire external tools through `pkg` in the future without `mk` becoming a compiler. If one app uses outputs from both, interoperation must occur across an explicit application-level interface, not through transparent compiler/module-graph conversion.
- **User-mandated memory constraint (2026-10-09): unbounded retention of old module versions or unbounded cache growth during repeated dynamic reloads is unacceptable.** Do not use native browser ESM imports with ever-changing URLs as the hot-reload mechanism: the native module map cannot be selectively cleared in the same realm. Native ESM remains possible only as an independently chosen toolchain/runtime, not as input to `jsc`; the `jsc` hot-reload path must not rely on ever-growing cached module identities.

## Acceptance scenarios

1. Develop multiple `jsc`-managed JavaScript modules using one coherent classic module model; invoke an ordinary project build to produce a self-contained browser distributable without installing a developer toolchain on the consumer's computer.
2. During development load an optional module only when first requested, with deterministic dependency/exposure behavior; clearly distinguish lazy network fetch from deferred execution of code already present in one file.
3. Replace a changed development module in an already running app when supported, with clear accept/dispose/state rules and without unintended duplicated listeners/timers. Explicitly expose cases that need full reload.
3a. Repeatedly replace the same module across many development iterations, release obsolete references and resources, and show by real long-running heap/resource measurements that stale module versions do not accumulate without bound (account for garbage-collector variance rather than equating temporary heap growth with a leak).
4. Distribute one self-contained JavaScript file for use in a regular page (including file:// when possible), and optionally use a multi-file on-demand distribution without accidentally promising both physical properties simultaneously.
5. Reuse existing `mk` project declarations and generic process boundary where sufficient; any proposed extension must show an actual unmet general responsibility first.
6. After a web app deploy, a browser must not accidentally use incompatible old/new HTML, JS or manifest assets. Demonstrate coherent release/version resolution, proper HTTP response cache policy, and long-lived open-client migration, including when a service worker is installed; do not treat HTTP POST as a mandatory cache workaround.
7. Allow a project to choose the independent `jsc` toolchain or an independently configured native/externally built ESM toolchain. Confirm `jsc` does not silently accept, reinterpret or partially translate ESM syntax; surface a clear unsupported-source diagnostic when encountered. Any app-level use of separately produced outputs requires explicit interface boundaries, not hidden module conversion.

## Working design (not normative)

- Distinguish bundling, lazy fetching, lazy evaluation and hot module replacement. One-file delivery can defer execution but cannot avoid transmitting embedded source bytes.
- Legacy `jsc` reads an explicit JSON hierarchy and concatenates source/export/namespace code, optionally Closure-minifies and gzip-compresses. Its Java API reference and generated eval-based namespace code are not modern production-ready.
- Legacy `LibraryDynamic.js` reads manifest and sources through XHR, queues concatenation, executes/evaluates the assembled result and can remove/reinsert script or CSS elements. This is library-level dynamic loading/reinsertion, not yet demonstrated as fine-grained dependency-aware lazy import or safe state-preserving HMR. The XHR/POST/synchronous/eval patterns deserve replacement rather than direct reuse.
- Current standard alternatives: browser ESM `import()` and import maps; esbuild/Rollup for bundle generation and splitting; Vite/webpack for development HMR; SystemJS for an explicit managed runtime module registry; JSPM import-map tooling. Evaluation must cover import semantics, state continuity, CORS/file://, CSP, offline/self-contained delivery and toolchain complexity.
- The `jsc` path owns a distinct classic source/module descriptor and a managed runtime lifecycle. The independent ESM path uses `import`/`export` with native semantics and may use ordinary ESM-aware tools. Do not design a cross-format source graph or translate ESM into `jsc` factories: `jsc` is not expected to emulate live import bindings, module evaluation ordering or ESM module identity. Both toolchains may be compared at their compiled/distributed outcomes.
- The initial editor PoC 061 proved a single 305.2 KB minified JS in headless Chromium via file:// with zero HTTP requests. It did not validate the `mk` invocation, general-purpose hot loading, lazy loading, lifecycle replacement or the compiler design.
- Native ESM caching is intentional module-identity behavior, not a general JavaScript-engine defect; legacy dynamically inserted scripts likewise do not automatically dispose previously created objects, timers, event listeners or captured references. A replaceable runtime requires explicit lifecycle semantics regardless of source format.
- User rejected unbounded cache growth as a hard requirement. Native ESM repeated import with query/hash/Blob URL cache-busting in one long-lived realm is disqualified as the hot-replacement solution. Candidate implementations may use a managed registry with disposable factories/closures, or disposable execution realms such as a dedicated Worker/iframe where suitable, but must prove resource reclamation and handle DOM access limitations, CSP/security, and state transfer; deleting a registry entry alone is insufficient.
- HTTP freshness is separate from native ESM module identity: classic `<script>` requests honor server HTTP caching, `fetch(url, {cache:'no-store'})` bypasses the HTTP cache when fetching text, and a classic `<script src>` has no direct JS `fetch` cache-mode option. Historical reference loader used POST as a pragmatic cache workaround; a modern deployment also needs version-coherent HTML/JS/CSS and deployment activation. Cache-Control `no-cache` for mutable HTML/manifests, immutable content-addressed JS/CSS, retention of referenced old release assets, and explicit service-worker update policy are viable research paths rather than a completed deployment contract. `POST` is not categorically non-cacheable when explicitly configured.
- Candidate development and distribution strategies remain under evaluation; do not promote them as `mk` specification.
- There are two explicit independent toolchains rather than a matrix of interchangeable source formats and runtimes: `jsc` classic input/output with its controlled loader, and standards-native ESM input with appropriate native/external building and loading. `mk` can select/orchestrate either and `pkg` can provide their respective tools, but neither facility implies semantic conversion. Native ESM in a long-lived realm remains unsuitable for unbounded versioned-URL hot replacement.
- PoC 062 currently wraps classic sources as factories and parses the generated script as `node:vm.Script`; do not extend it with an ESM frontend or ESM transformation. If source is actually ESM, diagnose the unsupported path rather than rewriting or accepting it partially. Compare esbuild/Rollup/webpack via separate `mk`-orchestrated toolchains after their actual provider/install integration is ready.
- Do not claim ESM semantic compatibility for `jsc`, even for a syntactic subset. ESM-specific features such as live bindings, cycles, `import.meta` and top-level `await` are owned by the independent ESM toolchain. Any integration between separately built classic and ESM application components needs an explicit public interface and lifecycle agreement.
- Fresh comparison of reference `m/js/lib/js/m/Class.js` (39 KB) with ECMAScript 2026: legacy `m.Class` supplies multiple base constructor calls/behavior copying or getter-links, per-instance composed defaults (shallow copying), shared prototype state, fluent properties with getter/setter/listener/validator, before/after triggers, event bindings, singleton/call-mode choices, method aliasing and runtime changes. Standard `class` does not directly supply the combined metaobject model, although modern prototypes/accessors/Proxy/Reflect can implement many pieces. Legacy multi-base support is not native multiple prototype inheritance/automatic multiple `instanceof` identity.
- Hard interoperability mismatches from current source: `Class.prototype.inherit` enumerates prototype members using `for...in` (native `class` methods are nonenumerable), while `Class.prototype._construct` invokes base constructors via `.apply` (native class constructors reject function-call invocation). The `_inherit.length___` check in the first-base branch appears erroneous and needs specific tests; do not assert runtime failure without authentic execution.
- ES module syntax and ES class syntax are independent. A separately maintained adaptation of legacy function-constructor-based `m.Class` can theoretically be exposed by an ESM library, but that is not a `jsc` compilation or mixed-module requirement. ESM caching has no standard unload/reset API, so independent ESM clients inherit that native runtime constraint.
- Modern `#private` fields are not dynamically injected through prototype copying, and standard `super`/class-field initialization semantics differ from legacy constructor chaining. Stage 2.7 decorators are not a stable cross-browser replacement for `m.Class` listeners/triggers. Types (e.g. TypeScript interfaces) do not add runtime multiple inheritance or HMR functionality.

## Completed

- Verified current remote repository heads and read canonical development authority.
- Inspected current `mk` process-action implementation and reference `m` compilation/dynamic-loading code.
- Established upstream capability baselines from standards and upstream docs for native `import()`, import maps, Vite HMR, webpack HMR, esbuild splitting, Rollup inline dynamic imports, SystemJS loader/registry, JSPM import map tooling.
- Split task responsibility from the editor investigation after the user clarified the independent goals.
- Retrieved and inspected the full reference `m.Class` implementation; checked selected interoperability properties against Node.js 22 and consulted up-to-date ECMAScript/MDN/TC39 sources. This is a static/mechanical assessment, not full execution of the legacy `m.Class` implementation.
- Reassessed the earlier ESM recommendation against the user's hot-loading priority. Standards-first is not established as a requirement; an explicitly managed runtime registry and a classic-JS/bundler-compatible authoring path are first-class candidates.
- User explicitly rejected unbounded module cache accumulation; verified the native `import()` module namespace cache limitation against current MDN documentation and made bounded old-version retention a hard acceptance requirement. No browser memory PoC has yet been executed.
- Previously evaluated translating ESM input into `jsc`-managed output, but the user rejected this approach because of subtle semantic mismatch risks; it is no longer an active candidate. Native ESM and existing external build tools remain independent options for comparison, not source frontends for `jsc`.
- Built a **local-only experimental PoC** (conversation attachment `jsc-dynamic-loader-poc.zip`, contains `062-jsc-dynamic-loader/`) with classic JS source factories, module manifest, standalone Node `jsc.mjs` assembler, classic-script registry/loader, and unit + browser harnesses. No source files have yet been committed to `rumiai-dev-PoCs` and the archive must be preserved/recovered from this conversation before formal repository promotion.
- Local tests on Node 22 passed: one standalone browser script, lazy module evaluation, transitive invalidation and disposal, 2,000 repeated replacements with bounded **registry entry counts** (not browser memory), source-path and dependency checks, direct HTTP GET response bearing `Cache-Control: no-store`. `node --check` of compiled bundle passed. Generated demo bundle 6,156 bytes (unminified, 2 example modules).
- Browser test harness attempts real two-revision reload of the **same** script URL under restrictive CSP (no `unsafe-eval`); local `/usr/bin/chromium` hangs even with trivial headless `data:` document, so browser behavior and memory remain unvalidated. Report the infrastructure failure, not a browser PASS.

## Current state

A new experimental assembler/runtime PoC exists as a ZIP conversation artifact only, not as tracked source in `rumiai-dev-PoCs` or as promoted `m` product code. The Node tests passed; real browser checks are blocked locally due to Chromium hanging. No native `mk`/`pkg` integration was changed or exercised. The earlier PoC 061 is a separate editor bundling feasibility experiment, not a general compiler contract.

## Next action

First preserve the locally generated ZIP PoC 062 as versioned source in `rumiai-dev-PoCs` when safely transferred. Continue the classic `jsc`/controlled-loader path only; add a clear diagnostic for unsupported ESM input and run the real Chromium tests on a functioning host. Test repeatedly replacing a module while observing actual JavaScript heap/resource reclamation and its effect on extant references. Independently verify coherent multi-release browser deployment, including HTTP caches and service workers. Compare the independently selected `jsc` and external/native ESM toolchains against concrete build/deployment outcomes without translating modules between them. Independently test existing `m.Class` capability and compatibility with modern ES class semantics. Require a repeated-replacement memory/reclamation test for each viable runtime before selection. Then compare how esbuild/Rollup can produce the desired classic one-file output from each source model. Measure actual fetch, execution, re-evaluation/state cleanup, local-file/browser compatibility, output count, CSP constraints and integration through real `mk`. Promote a `mk` extension only if a concrete uncovered lifecycle responsibility is demonstrated.

## Blockers / open questions

- Is preserving state across hot reload mandatory for every module, or can modules declare accept/dispose boundaries and request a full reload for incompatible updates?
- How much should one-file distribution sacrifice in exchange for deferred evaluation, and should a separate multi-file lazy distribution be available?
- Which explicit application-level interoperability scenarios, if any, should be included in comparison when independently built classic and ESM outputs are consumed by the same app? This must not reintroduce implicit ESM-to-`jsc` conversion.
