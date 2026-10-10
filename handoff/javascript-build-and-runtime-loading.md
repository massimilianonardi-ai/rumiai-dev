# JavaScript source compilation and dynamic library loading

Status: Active
Updated: 2026-10-10

## Goal

Adapt the **original** `m/cmd/jsc.js` namespace/source compiler and the original `m` browser JavaScript/CSS source-list loader into the current first-party `m` repository layout. Preserve the original public developer model and correct concrete defects; do not create alternative module architectures or unrelated components.

## Current references (verify HEADs remotely on resumption)

- `rumiai-dev/main`: `7c4e0ab7d2ef595914082700b09f7260b2745b32` (pre-handoff commit)
- `rumiai-os/main`: `95c8e54ecc697027e9a857ba638321ce76bbe147`
- `rumiai-tests/main`: `4e9e509f7d3d879cf9d59056e7a91aa2ba6eabec`
- Original reference `m/master`: `2a57a29880c2d7a32e18782122062c695fcb1a3a`

## Mandatory sources

Follow `rumiai-dev/README.md` mandatory read order, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/JSC.md` and current command/library/diagnostic/manual/testing contracts, then inspect current product and permanent tests. The original source lives in `m/cmd/jsc`, `m/cmd/jsc.js`, `m/js/lib/js/m/mod/LibraryDynamic.js` and `m/js/lib/dynamic-loader/dynamic-loader.js` and is behavioral reference evidence.

## Fixed user direction

**There is only one model.** Keep the original ordered nested `modules` / `name` / `file` / `symbols` manifest, lexical namespaces and source order, source-list CSS assembly, original command arguments/stdout and browser JS/CSS loader responsibilities. Do not retain alternative registration/graph systems, optional alternate formats, or a new runtime registry. Maintain the product paths `bin/sys/jsc`, `lib/sys/js/jsc.lib.js` and `lib/sys/js/dynamic-loader.lib.js`. `mk` is separate. No native ESM translation.

The shebang/bootstrap inquiry is **deferred work only**, recorded in `todo/javascript-command-bootstrap.md` under the normal TODO lifecycle. It is NOT an active task, not a dependency, and must not be analyzed or implemented in this compiler/loader work unit. No supervision, lock, FIFO or external-effect coordination work.

## Current state

- The published `jsc.lib.js` contains only the original nested ordered compiler model, adapted to modern Node with explicit source validation, namespace reopening, source/stdout emission, offline gzip and installed-compiler minification where available.
- The `bin/sys/jsc` shell command uses the existing m bootstrap `log`/`fatal` functions and manages Node through `pkg default nodejs`. It takes one or two path operands.
- The independent `dynamic-loader.lib.js` implements original JS/CSS descriptor/source loading and public functions `loadModulesDynamically`, `replaceModulesDynamically`, `loadJSLibraryDynamically`, `loadCSSLibraryDynamically`, `loadLibraryDynamically`. It preserves the original standalone auto-initialization and `dynamicLibs` behavior. The current implementation uses browser fetch and promises internally instead of the original monolithic XMLHttpRequest helper/Queue.
- Fixed a real original namespace reload defect: previously imported bindings no longer override newly exported same-name declarations.
- Current canonical `JSC.md` contains only this contract; the three product manual topics were rewritten to explain only this API.
- Permanent tests in `rumiai-tests/tests/rumiai-os/jsc` verify real compiled namespace visibility, source order, CSS, stream/file output, gzip, invalid operands/paths, namespace reopening, actual DOM insertion and dynamic JS/CSS replacement, plus execution of the public manual example in real Chrome.
- [GitHub Actions run 38089401516](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38089257191) **completed successfully**, exact product revision `ae22b4174b7aa71cf1803b627c394aa40b28cf0e` and tests revision `9c3e3a123920775833c5e17d4c3b6e51388c6573`; hosted Node and headless Chrome exercised real product sources. Existing `m` launcher invalid-input diagnostic path is also tested.
- Git forward-only and concurrent unrelated work preserved.

## Validation boundary and next action

A complete successful invocation of the public command with a real default `m`-managed Node package on a physical reference host is not yet demonstrated by the hosted suite. Host-specific minifier availability across supported platforms was not asserted. Any further work should be restricted to concrete original-reference behavior gaps, product/manual consistency and proportional real tests, not new architecture. The separate bootstrap TODO stays deferred.
