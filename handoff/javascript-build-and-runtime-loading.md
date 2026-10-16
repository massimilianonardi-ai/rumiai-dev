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

A new user question concerns `Queue` callback exception policy.
Current behavior catches and logs callback exceptions then continues.
The assistant proposed, but the user has **not accepted** as binding,
per-callback `continueOnError` defaulting to false, structured error
retention and explicit stopped state. Keep this as an open design choice
owned by `handoff/javascript-core-modernization.md`, not a stealth
change to existing `Queue.js`; asynchronous resource cancellation stays
outside Queue.

## Next action

Continue the design review of the new `m.mod.*` dynamic-loading
interface and its runtime download/composition semantics. The user will
apply all proposed runtime code manually. After implementation is
authorized and supplied by the user, validate against real compiled
artifacts and browser operation, and realign current manuals/tests.
The separate optional reference-host Node provider/minifier checks from
the completed compiler implementation are not established defects.
