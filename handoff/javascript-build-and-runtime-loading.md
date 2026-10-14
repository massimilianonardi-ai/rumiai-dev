# JavaScript compilation and dynamic JS/CSS loading

Status: Active  
Updated: 2026-10-14

## Responsibility and authority

Keep the first-party `m/jsc` compiler, its classic-browser dynamic JS/CSS loader, operational manuals and permanent tests aligned. The current normative contract is `specifications/rumiai-os/JSC.md`. Follow the entire mandatory read order of `rumiai-dev/README.md` on resumption. The separate bootstrap/shebang item remains deferred in `todo/javascript-command-bootstrap.md`; do not activate it as part of this work.

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

## Next action

The user-authorized compiler and browser-loader implementation has passed
revision-specific hosted CI. No further launcher modification is required
for the two previously flagged issues. An optional follow-up may validate
the managed Node provider on a reference host and the real installed
minifier paths; neither is presently an established jsc defect.
