# JavaScript compilation and dynamic JS/CSS loading

Status: Active  
Updated: 2026-10-14

## Responsibility and authority

Maintain the compiler's independent contract and coordinate the separately designed runtime dynamic-loading responsibility, without coupling either into the other's specification. The current `specifications/rumiai-os/JSC.md` defines only compilation. The dynamic-loading redesign stays as task-local design here until its interface and behavioral contract are ready for promotion to a separately routed canonical source. Follow the full `rumiai-dev/README.md` mandatory read order on resumption. The separate bootstrap/shebang item remains deferred in `todo/javascript-command-bootstrap.md`; do not activate it as part of this work.

## Completed implementation checkpoint — 2026-10-14

- Product `rumiai-os`: compiler implemented in `lib/sys/js/jsc.lib.js` (CommonJS, non-executable); superseded `bin/sys/jsc.js` removed. Outer strict IIFE wraps the existing ordered nested namespace structure. JSON `symbols` is renamed to `exports`, and optional per-source `imports` generates lexical value references without loading source files. Browser publishes namespace roots globally. CommonJS publishes the root through `module.exports`; optional root-descriptor `nodeGlobal: true` additionally reuses/publishes the corresponding `globalThis` namespace, while default false does not read/write the matching global.
- `bin/sys/jsc`: exactly the two former `$m_COMMAND_BIN.js` invocations were changed to invoke `$m_ROOT/lib/sys/js/jsc.lib.js`. All existing minifier / gzip branches remain. The engine always validates generated JavaScript syntax using Node VM and, when installed, runs `google-closure-compiler --checks_only` against a disposable source file before emitting the original bytes. The public launcher can additionally produce `.min.js` / `.min.css` when the respective installed minifier exists and gzip the selected release artifact.
- `lib/sys/js/dynamic-loader.lib.js`: browser-only independent source-list loader restored with the original five public function names; supports the new descriptor, strict namespaces and ordered JS/CSS loading without eval. A follow-up consistency fix rejects CSS namespaces/imports/exports.
- Three operational manuals in `rumiai-os/res/sys/manual/` were realigned.
- `rumiai-tests`: updated permanent namespace/import/Node-sharing regression, real-Chromium browser loader probe and public launcher JS/CSS/gzip-artifact regression; removed superseded legacy test. `rumiai-os/.github/workflows/jsc-classic-loader.yml` pins the tested suite revision.

## Real validation evidence

- Local exact-source Node.js 22 tests: generated JS in isolated VM contexts (browser-like and CommonJS), namespace reopening and identity, static captured references versus qualified live references, opt-in and default Node publication, CSS source ordering, invalid exports and path rejection: pass.
- Local dynamic-loader DOM simulator with stubbed HTTP and document boundary: pass, including insertion, callback and source-list behavior. Headless Chromium in this container timed out without usable DOM evidence; do not count it as a browser result.
- Local public shell-path release orchestration using test executables standing in for minifiers: pass for check-only invocation, original bundle preservation, JS/CSS .min filenames and corresponding gzip decompression. This verifies the launcher orchestration only, **not** the real minifiers.
- Real GitHub-hosted product-and-permanent-tests revision `rumiai-os@bbaaea5791765c0792a66dd6c0b0ba387686c4b3` with `rumiai-tests@f81ad51aa8d7bd0135819149910159f68f313aa5`: [run 38523562948](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38523562948) SUCCESS. Real m launcher regression and artifact test passed; real headless Chrome JS/CSS loader and manual quickstart passed; Node/shell syntax passed.
- Subsequent `rumiai-os@2c6be876be6edc113cbf2927d0f9ae6c3f2cd763` only adds CSS descriptor rejection in the loader, with current GitHub Actions [run 38523847097](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38523847097). GitHub Actions [run 38523847097](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38523847097) has now completed SUCCESS on that exact revision, including the real m launcher, real Chromium loader, manual quickstart and Node/shell syntax checks.

## Final consistency and hosted regression — 2026-10-14

Following the initial green run, the compiler's nonpublic functions and
dynamic-loader's nonpublic functions were renamed with the mandatory `_`
prefix. Only the five loader entrypoints and `jscMain` remain public.
Both changed code blobs matched the locally syntax-checked and behaviorally
tested copies exactly. Product `rumiai-os/main@0dc5678a1401c5a0a8786e739f237dc26dbfb8e7`
passed the [real GitHub Actions run 38524337570](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38524337570):
real `m` launcher, permanent namespace/Node tests, JS/CSS artifact test,
Chromium loader/reload and manual quickstart, Node/shell syntax all success.
Permanent suite pinned at `rumiai-tests/main@f81ad51aa8d7bd0135819149910159f68f313aa5`.
This is a hosted Linux runner test, **not** physical validation on the user's Ubuntu host.
The final cross-surface review found no remaining public/internal function-naming
or operational-manual identity mismatches; environment-specific validation limits below
remain distinct from the completed implementation.

## General multiline delimiter alignment — 2026-10-14

The user clarified that the previous JavaScript-specific function brace
convention was too narrow: in all RumiAI source languages, whenever
`{}`, `[]` or `()` pairs span multiple lines, their opening and closing
characters must align in the same column unless prevented by the
language's syntax or semantics. The previous narrower rule was **replaced**
in canonical `RULES.md`, not duplicated as a JSC-only contract.

Product `rumiai-os/lib/sys/js/jsc.lib.js` and
`lib/sys/js/dynamic-loader.lib.js` were reformatted to align multiline
block pairs, call/array/object delimiters and the JavaScript nested / outer
IIFE wrappers they generate. Developer-authored JS input is still copied
verbatim. The changes are stylistic and do not change the public API,
descriptor semantics or emitted bundle execution behavior.

The final product revision for this work unit is
`rumiai-os/main@f628abfd95250f26a2ee04f54feae7027b51849e`.
A delimiter-pair audit over both product sources found zero misaligned
multiline pairs; an isolated execution of the actual compiled engine with
stubbed filesystem/Node imports generated a browser bundle (nested `m.data`)
that evaluated to the expected value 42 and preserved aligned IIFEs.
[GitHub Actions run 38532430086](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38532430086)
completed **success** on that revision: real Node compiler and launcher
regressions, Chrome dynamic loader, manual quickstart and syntax checks
passed. This is hosted CI, not a physical test on the user's host.

## Accepted output behavior and remaining environment checks

The user explicitly accepts ordinary shell redirection `> "$output"`:
an unsuccessful compile may truncate/replace a previous output, and this
is **not a product defect or a pending fix**. Canonical `JSC.md` now reflects
that acceptance. Do not add atomic output protection.

The launcher invokes `node` through `PATH`. Current `rumiai-os/m`
loads the generated global provider environment first, then prepends the
managed sys/ext binary directories; the resulting lookup order follows the
bootstrap contract in `BOOTSTRAP-ENVIRONMENT.md`. This is the intended
resolution model, **not an established launcher defect**. Hosted tests
proved Node 22 execution, but they do not separately validate a custom
managed Node provider installation on the user's own hosts.

Another testing limit remains: no run with real installed
`google-closure-compiler` and `uglifycss` was executed in this work unit.
The CI covers the no-minifier fallback and local test stubs covered launcher
orchestration. Do not claim installed-minifier host validation.

Prior PoC evidence remains at `rumiai-dev-PoCs/pocs/064-jsc-no-eval-scope/`
and `pocs/065-jsc-closure-imports/`; it is not product validation.

## Current compiler-contract correction — 2026-10-16

The user explicitly separated `jsc` from all application/runtime-loading
responsibilities. Canonical `specifications/rumiai-os/JSC.md` was rewritten
as a compiler-only contract, and `specifications/README.md` routing was
corrected. `jsc` compiles whatever ordered descriptor the caller supplies;
it neither selects a distribution nor knows how its output is loaded.
The existing generated JavaScript semantics (namespace scopes, exported
symbols, optional captured references, browser/CommonJS publication),
CSS compilation, validation and artifact generation remain within its scope.
The old JSC-07/JSC-08 loader-only invariants were retired without reusing
their identifiers. Its existing compiled-output reopening capability is
generic compiler behavior, not a product requirement to load multiple
prebuilt distributions together.

At this checkpoint, `rumiai-os` implementation, operational manuals
and `rumiai-tests` were **not modified**. The existing product
`dynamic-loader.lib.js`, its manual and the permanent browser-loader
tests still reflect the previous design. This is an explicit pending
product/manual/test realignment, not evidence that those changes have
already happened or an instruction to change runtime code now.

## Fixed task-local design direction — runtime dynamic loading

- Selectively reimplement useful concepts from the legacy source trees,
  with modern JavaScript instead of mechanically porting old constructs.
- Organize authored source fragments according to the established
  `m` namespace hierarchy; a family of author-supplied JSON descriptors
  creates alternative predefined bundles. A global bundle covers the
  full intended selection; specialized bundles cover smaller selections.
  **Different predefined bundles are alternatives for different
  deployment needs, not parts intended to be loaded together.**
- An application with unusual needs may author a specific build JSON or
  choose runtime composition through the dynamic loader instead.
- The new dynamic-loading responsibility belongs within the existing
  `m.mod.*` namespace and will itself be assembled from separate
  source fragments by `jsc` using a dedicated manifest.
- Reuse `m.mod.Queue` rather than embedding a duplicate queue. The
  existing `core/m/mod/Queue.js` is to be modernized into a **native
  JavaScript class** under the distinct core-modernization ownership,
  retaining its essential FIFO/completion guarantees unless explicitly
  revised. Do not silently implement Queue modernization in the loader.
- Redesign file/module downloading completely; do not treat the old
  `ajax`, synchronous POST, callback and failure paths as an implementation
  template. Source composition should use the current `jsc` semantics as
  its reference, not an independent arbitrary namespace/evaluation model.
  `jsc` itself must never be coupled to this runtime responsibility.
- `core-ext/m/mod/Module.js` has a different purpose and is out of
  current redesign scope; its usefulness can be reassessed later.
- Source/code changes are under **user control**: while this working
  arrangement is in force, propose any necessary code in chat and let
  the user apply it. This checkpoint changes documentation only.

## Open design, pending promotion

The exact public `m.mod.*` entrypoints, loader bootstrapping, browser
resource-fetch mechanism, failure propagation, source caching and
replacement/side-effect semantics still require design and acceptance.
No automatic reuse of the five historic global functions is implied.
Maintain separation between one-time compiler output generation and
runtime source composition; neither is a dependency graph for the other.
When the dynamic-loading design is fixed, give it its own canonical
contract/routing and realign owner-local manual and permanent tests with
user-applied product changes. Do not put loader behavior back into
`JSC.md`.

## New dynamic source and manifest checkpoint — 2026-10-16

The user expressly authorized creation of exactly two product files and
retained control of edits to previously existing sources. New files in
`rumiai-os/main@1e4d9fdaa2c444c5268b8529ff525a9cf63e693d`:

- `lib/sys/js/core/m/mod/DynamicLoader.js` (new browser-only fragment),
  exporting proposed `m.mod.DynamicLoader` when assembled by `jsc`.
- `lib/sys/js/core/modules-dynamic-loader.json` (new specialized
  descriptor, including only the current native `m.mod.Queue` and
  `m.mod.DynamicLoader` in that order).

The user's separate `Queue.js` modernization had already landed before
the files were created and was preserved unchanged. Existing `core`
manifest, `jsc`, old dynamic loader, manuals and permanent tests were
not modified. The new loader uses `fetch` and `Queue.add` to preserve
manifest order, generates browser classic-script namespace scopes or
ordered CSS, and offers proposed `compose()` and `load()` entrypoints.
This is an implementation proposal checkpoint, **not yet a promoted
public-interface contract** or a completed library distribution.
The legacy runtime loader and manuals/tests remain pending realignment.

Revision-specific validation: the *actual GitHub source strings* for native
`Queue`, `DynamicLoader` and the new manifest were exercised in an
isolated JavaScript evaluator with stand-in `URL`, `fetch` and DOM.
Manifest path order, JS assembly and execution (result 43), CSS order,
DOM style replacement and HTTP 404 rejection passed. The evaluation
does **not** establish actual `jsc` compilation, real-network HTTP, real
Chromium behavior, CSP acceptance, generated output syntax under all
inputs or physical validation. A native Node/Chromium tool is present
in the workspace, but authoritative source bytes were not materialized
there; no `jsc`/Chromium run was claimed.

The Queue callback-exception policy described during the initial loader
checkpoint was subsequently agreed and committed by the user. The current
Queue API and integration implications are recorded in the current Queue
integration review below and in `handoff/javascript-core-modernization.md`.
Asynchronous resource cancellation stays outside Queue.

## Current Queue integration review — 2026-10-16

Product HEAD inspected: `rumiai-os/main@16b7f725f5b85de3207d4e2c40ea7539651c14c5`; current permanent tests HEAD: `rumiai-tests/main@11f62d1dc471ded4968e0b7c06470c3acb0c083d`.
The user committed the new native Queue with per-round reuse and persistent `completed`, `success`, and `error` observer setters, and `add(callback, continueOnError = false)`. `DynamicLoader.js` and its specialized two-source descriptor remain present and unchanged. In `DynamicLoader.compose`, file download failures are passed as ordinary `{error}` results through `Queue.add`; the queued callback only pushes the result into an ordered array. Thus the newly committed Queue API does not mechanically require a DynamicLoader source edit for this current path. Unexpected exceptions thrown by the queued callback would now be internally captured without observer notification in DynamicLoader, which lacks a Queue error observer; this edge still needs robust regression coverage.

The exact current product HEAD's JavaScript core workflow run 38908894786 is SUCCESS, but its pinned permanent core tests do not mention `DynamicLoader` and do not cover the specialized descriptor. The current permanent Chrome loader test exercises `lib/sys/js/dynamic-loader.lib.js` (the previous public-loader implementation), not `m.mod.DynamicLoader`. No production build of the new specialized descriptor and no actual-browser integration of the new loader have been verified in this checkpoint.

Pending: compile the specialized descriptor with real `jsc`, serve it and a fixture manifest in a real browser, verify JS/CSS source order, namespace semantics, fetch/network errors, replacement semantics, CSP and runtime errors. Decide and promote the new loader interface as a distinct normative contract only after its remaining design is settled. Existing standalone loader, manual and permanent tests require intentional realignment. Product code remains user-controlled; this checkpoint changes documentation only.

## Queue-driven download coordination implemented — 2026-10-16

**User-authorized bounded product change:** the user explicitly approved
implementing the previously proposed Queue-driven download-coordination
replacement in existing `DynamicLoader.js`. Product
`rumiai-os/main@6c7d2eacc710b98f65ca896584955eac25b09d8b`
changes exactly one file:
`lib/sys/js/core/m/mod/DynamicLoader.js`. The public `compose()` and
`load()` entrypoints, Queue.js, source descriptor, manifests, rendering,
legacy loader and manuals were not changed.

`compose()` now creates one local Queue and `sources` array per invocation,
registers `success(() => resolve())` and
`error(entry => reject(entry.error))`, and gives each fetch one default
fail-fast `add` callback. A successful fetch contributes source text in
manifest FIFO order; a failed fetch supplies its original Error to the
operational callback, which throws it inside Queue and causes a single
blocking Queue error notification. The former `Promise.all` and
`ordered.find(result => result.error)` were removed. Queue still does not
cancel in-flight Fetch operations; late completions are ignored after a
stopped round. Errors are observed in Queue entry order, so an earlier
pending request can delay notification of a later failed one.

**Validation at this exact product revision:** targeted V8 execution of
the current actual GitHub Queue.js and DynamicLoader.js sources using
stand-in URL, document/location and fetch passed:
(1) out-of-order JS source completion with correctly ordered executable
assembled classic JS, (2) HTTP 503 failure propagation,
(3) ordered CSS concatenation and (4) network rejection with original
cause preserved. This is actual source-level invocation of `compose()`,
but **not** a full `jsc` compilation or real browser/network run.
[JavaScript core CI run 38914095662](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38914095662)
completed SUCCESS on the exact product revision; its pinned tests
exercise the existing core manifest, **not** the new specialized loader.
The commit diff was reviewed and only the agreed source block changed.
Current old-loader operational manual covers `dynamic-loader.lib.js`, a
different existing library; this code change did not alter its API.
The new `m.mod.DynamicLoader` documentation and permanent integration
tests remain pending until that separate interface is consolidated.

**Remaining loader work:** build the dedicated
`modules-dynamic-loader.json` with the real `jsc`, execute it in an
actual browser with JS/CSS fixtures and network failures, settle script
execution/CSP and replacement semantics, then promote a separate
normative loader contract and align the new interface's operational
documentation and permanent tests. This specific product change did
not imply authorization to change any other existing runtime sources.

## Real specialized-bundle and Chromium regression — 2026-10-16

Latest validated product HEAD:
`rumiai-os/main@9e61714e68afd8eab28df201d7c71ce24b16cfeb`.
The actual runtime loader implementation remains the previously approved
`DynamicLoader.js` code from product commit
`6c7d2eacc710b98f65ca896584955eac25b09d8b`.
New permanent coverage lives in
`rumiai-tests/main@76d2fb64836cf863e2b65ab89e05277415df1416`:
`tests/rumiai-os/js-core/.support/dynamic-loader.mjs` is invoked from
the existing executable `tests/rumiai-os/js-core/compile.test`; product
`.github/workflows/js-core.yml` pins that exact test revision.
The new test invokes the **real first-party jsc Node engine** on
`core/modules-dynamic-loader.json`, parses the generated bundle, and
checks `m.mod.Queue` and `m.mod.DynamicLoader` are published.
It then starts a real local HTTP fixture and headless Chromium, verifying
JS source downloads completed C/B/A but composed in descriptor order,
actual nested namespace execution (42), CSS ordering and DOM styles,
JS and CSS replacement (including JS result 73), script nonce, malformed
descriptor JSON, source and manifest HTTP 404, cross-origin rejection,
wrong-type replacement, and execution under restrictive
`script-src 'self' 'nonce-test-nonce'` CSP with explicitly supplied
nonce for every script insertion.

[GitHub Actions run 38917315188](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38917315188)
**SUCCESS** on exact product revision `9e61714...`, with log messages
confirming the real specialized `jsc` compilation, real Chrome JS/CSS
integration, and real CSP nonce integration. The final test source also received a delimiter-alignment/readability review; the resulting exact suite revision passed the real CI tests again. The first non-CSP iteration
also passed as run 38916044188. Intermediate run 38916323363 failed
because the *test page*, not the loader, omitted nonce on its replacement
script under CSP. Updating the test to pass nonce explicitly resolved
that failure; the product runtime was unchanged.

Important boundary confirmed by that failure: current `load()` resolves
after DOM element insertion, not after verified inline script execution.
Browsers can block a script under CSP without the returned Promise
necessarily rejecting, and JS replacement can remove the old script
element even when the new element's code was blocked. Callers currently
must supply `nonce` to each JS load/replacement under nonce-based CSP;
no implicit nonce inheritance is established. The separate policy for
execution-failure observation, diagnostics, replacement safety and
whether loader promises guarantee execution is **not yet promoted**.
Do not infer automatic rollback of JavaScript side effects or cancellation
of running fetches.

Remaining project work: settle public runtime-loader contract and
execution/error observability explicitly, align its own operational
reference without replacing the old distinct library manual prematurely,
and decide migration/removal of the legacy `dynamic-loader.lib.js` only
when existing usage is reconciled. Browser testing is CI evidence on the
GitHub runner, not physical testing on the user's host.

## Next action

Resolve the pending dynamic-loader interface and script execution/error
contract, then promote the settled specification and align operator docs,
migration strategy and any remaining permanent regression. Retain the
actual existing `jsc` compiler boundary and the independent legacy loader
until an explicit migration decision is made.
