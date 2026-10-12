# JavaScript source compilation and dynamic library loading

Status: Active
Updated: 2026-10-10

## Goal

Adapt the **original** `m/cmd/jsc.js` namespace/source compiler and the original `m` browser JavaScript/CSS source-list loader into the current first-party `m` repository layout. Preserve the original public developer model and correct concrete defects; do not create alternative module architectures or unrelated components.

## Current references (verify HEADs remotely on resumption)

- `rumiai-dev/main`: `656cc4a8d69b4291a5a15011612a09bad0db66ef` (review pre-checkpoint; re-verify remote HEAD).
- `rumiai-os/main`: `0c638074b0a031d7f75d62bf464faf2c0a272ef0` (user-committed original jsc; review target).
- `rumiai-tests/main`: `024f60b85fc94a49f5222cd1fac9f3e9a326f562` (review target).
- Original reference `m/master`: `2a57a29880c2d7a32e18782122062c695fcb1a3a`

## Mandatory sources

Follow `rumiai-dev/README.md` mandatory read order, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/JSC.md` and current command/library/diagnostic/manual/testing contracts, then inspect current product and permanent tests. The original source lives in `m/cmd/jsc`, `m/cmd/jsc.js`, `m/js/lib/js/m/mod/LibraryDynamic.js` and `m/js/lib/dynamic-loader/dynamic-loader.js` and is behavioral reference evidence.

## Fixed user direction

**There is only one model.** Keep the original ordered nested `modules` / `name` / `file` / `symbols` manifest, lexical namespaces and source order, source-list CSS assembly, original command arguments/stdout and browser JS/CSS loader responsibilities. Do not retain alternative registration/graph systems, optional alternate formats, or a new runtime registry. Maintain the product paths `bin/sys/jsc`, `lib/sys/js/jsc.lib.js` and `lib/sys/js/dynamic-loader.lib.js`. `mk` is separate. No native ESM translation.

The shebang/bootstrap inquiry is **deferred work only**, recorded in `todo/javascript-command-bootstrap.md` under the normal TODO lifecycle. It is NOT an active task, not a dependency, and must not be analyzed or implemented in this compiler/loader work unit. No supervision, lock, FIFO or external-effect coordination work.

## Current state

**Read-only review checkpoint, 2026-10-12.** The user committed their original `jsc` implementation to `rumiai-os/main@0c638074b0a031d7f75d62bf464faf2c0a272ef0`. Product `bin/sys/jsc.js` is **byte-identical** to reference `m/master:cmd/jsc.js`, Git blob SHA `c967f801db6b3e01e17492e0f42d21642a4cf821`. Product `bin/sys/jsc` is a m-integrated POSIX shell script with `#!/usr/bin/env m`; the JS engine currently lives beside it in `bin/sys/jsc.js` (regular non-executable) rather than under `lib/sys/js/`. The earlier `lib/sys/js/jsc.lib.js` and `lib/sys/js/dynamic-loader.lib.js` do **not** exist in this revision. The original `modules/name/file/symbols` compiler/namespace model is retained, with no id/deps or registry.

**Actual review observations, no product changes made:** Direct Node 22 execution of an exact-Git-blob reconstruction of `bin/sys/jsc.js` (verified `git hash-object`) successfully compiled a concrete nested `m.srv.data.MyClass` example when passed a directory and descriptor filename explicitly, and output executed correctly in Node's classic-script VM. The one-operand `jsc modules-js.json` wrapper pattern expands `${1%/*}` to the full filename when no `/` is present, resulting in `ENOTDIR` for `modules-js.json/modules-js.json`. The engine's no-descriptor auto-discovery path still calls `new java.io.File` and throws `ReferenceError: java is not defined` under Node. Adjacent source files without a trailing newline can swallow the following symbol-export statement into a `//` comment. The exact wrapper copy was reproduced using blob SHA `bce9026ba37dd702b24e1c9779a292cc47545a7f`: a failed compilation to a non-JS/CSS suffix can still exit 0 after `gzip`, producing an empty artifact, because child statuses are not checked. A relative `../outside.js` is currently read successfully (no source-root boundary), and an invalid symbol identifier produces invalid generated JS while the compiler exits 0. The wrapper directly calls `node` rather than first selecting the default m-managed runtime, emits `echo` diagnostics instead of `log/fatal`, and invokes `npx --yes` for minification (implicit external downloads may occur), contrary to current `JSC.md` and diagnostic/offline expectations.

**Cross-surface mismatch:** The current `rumiai-dev/specifications/rumiai-os/JSC.md`, product manuals `res/sys/manual/{jsc,jsc.lib.js,dynamic-loader.lib.js}`, and permanent `rumiai-tests/tests/rumiai-os/jsc` still describe/test the removed `lib/sys/js/jsc.lib.js` and `dynamic-loader.lib.js` layout; the manuals also claim validations, runtime selection and behavior not in the user's just-committed code. Exact product GitHub Actions [run 38208933554](https://github.com/massimilianonardi-ai/rumiai-os/actions/runs/38208933554) ended **failure** at the structural test `compiler engine file type/mode invalid`, before executing the current engine. The workflow pins `rumiai-tests@4e9e509f7d3d879cf9d59056e7a91aa2ba6eabec`, while the current tests main HEAD is different; no existing CI result proves the new product revision's functional paths. The prior handoff statement of a green hosted suite applies to an **older product revision only**.

**Review-only scope:** Do not silently rewrite the user's committed engine or promote replacement module architecture. User has requested an integration analysis; the findings above are pending realignment, not implemented fixes. The separate `todo/javascript-command-bootstrap.md` is deferred and must not be analyzed or activated by this task.

## Validation boundary and next action

The integration currently has **confirmed** mismatches at the CLI path split, runtime boundary, Java-specific auto-discovery branch, failure propagation, source validation/output integrity, product file ownership, and current tests/manuals. The first normal nested-manifest compilation path did work under real Node 22 using an exact byte-identical copy, but a successful invocation through the full m launcher on a host with managed Node was **not** demonstrated. No product edits, permanent test changes, or authoritative specification changes were made in this read-only analysis.

When the user requests implementation, adapt the user's original code minimally to the current m runtime, preserve only ordered `modules/name/file/symbols` and original JS/CSS behavior, then realign product paths, first-party manuals and permanent tests on the same revision. Keep the bootstrap/shebang TODO deferred; do not use this integration task to redesign it.
