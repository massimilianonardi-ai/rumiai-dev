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

## Known pending realignments, outside the user-authorized two-line launcher change

1. **Output safety mismatch:** the existing shell redirection `> "$output"` truncates a previously valid output before the child compilation succeeds. `JSC.md` currently requires rejecting malformed JS/descriptors before overwriting a valid output. The direct engine two-argument path validates first, but the public launcher does not. Correcting this requires modifying more than the two launcher invocation lines that the user explicitly asked to preserve. Do not silently claim this guarantee for the launcher.
2. **Runtime-selection evidence:** the launcher still directly invokes `node` and relies on the `m` bootstrap environment's `PATH`. The canonical specification describes an `m`-managed default Node runtime; hosted tests proved actual Node execution but did not demonstrate that managed-runtime selection path on all reference hosts.
3. **Installed-tool branch:** no target-revision validation with a real installed `google-closure-compiler` and `uglifycss` was executed in this work unit; only the absent-tool fallback was exercised in CI and orchestration was exercised with test substitutes locally. The product's check-only and minification flags are supported by the upstream Closure documentation, but don't attribute a full real-tool pass.

The first two items are inherited integration defects, not reasons to redesign `jsc` or add import registries. Preserve the current two-line launcher scope unless the user explicitly authorizes a follow-up change. Prior PoC evidence remains at `rumiai-dev-PoCs/pocs/064-jsc-no-eval-scope/` and `pocs/065-jsc-closure-imports/`; it is not product validation.

## Next action

The user-authorized compiler/loader implementation and documented minifier behavior have passed hosted validation. The two inherited launcher integrity/runtime-selection gaps and real-installed-minifier branch remain explicit pending validation/realignment items; do not change the launcher beyond its two approved invocation lines without further authorization. No further bundle architecture redesign is pending.
