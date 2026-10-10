# RumiAI OS — `jsc` and independent classic JavaScript dynamic loader

Status: **Current / normative**
Updated: 2026-10-10

## 1. Scope and ownership

The technical `m` layer provides a first-party classic JavaScript compiler and a
separate dynamic-loading library, distributed directly in the current product tree:

```text
bin/sys/jsc
lib/sys/js/jsc.lib.js
lib/sys/js/dynamic-loader.lib.js
```

`jsc` is a bootstrap-integrated command with `#!/usr/bin/env m`. Its engine is
`jsc.lib.js`, executed with the default `m`-managed Node.js runtime (Node
22+). It must not silently install a runtime as a side effect.

The loader is an independent, non-executable **classic JavaScript** library:
it must operate without the compiler, including for manually registered module
factories. Compiler-generated code depends on the consumer explicitly loading
the compatible loader first. The compiler does **not** embed a runtime.

`mk` may orchestrate normal external compiler invocations through its current
project operations; `jsc` does not become an alternative build engine or
package manager. The packaging experiment in PoC 062 is not a separate
mandatory public `m` command or integrated service.

## 2. Compiler format and semantics

The command takes exactly:

```text
jsc <manifest.json> <output.js>
```

The manifest is JSON with `version: 1` and a `modules` array. Each entry has
an `id`, a source `file` relative to the manifest directory, a `deps` array of
module IDs, and optional `format: "classic"`. Source files must resolve
inside the manifest directory. A source is a classic factory body receiving
`require`, `module` and `exports` when evaluated by the loader.

Compilation validates manifest metadata, source syntax, complete dependency
references and acyclicity before writing output. Output is one classic script
that calls `globalThis.JscRuntime.installBatch` with all factories. A failed
validation must not replace a pre-existing compiled output. This does not
guarantee atomic overwrite after a filesystem write failure.

This is **not** an ESM compiler: it must not reinterpret, translate, partially
accept or emulate static ES `import`/`export` or `import.meta`. Native ESM
projects remain independent. A native `import()` expression within an otherwise
classic script is not managed by the `jsc` module registry.

## 3. Loader registry and lifecycle

The library exposes the `JscRuntime` global API with these public calls:

```text
install(id, deps, factory)
installBatch(changes, { expectedRevisions? })
require(id)
invalidate(id)
remove(id)
revision(id)
state()
loadScript(url, { nonce?, expect? })
```

`module.onDispose(callback)` is the per-instance application cleanup
registration exposed within each factory.

- Installing a definition is separate from executing its factory. `require`
  performs lazy evaluation and caches the resulting exports.
- Only explicitly declared dependencies may be required from a factory.
  Missing references and cycles are rejected before batch installation.
- Installing a replacement invalidates instantiated transitive consumers and
  invokes explicitly registered cleanup, consumer-first.
- Invalid batches and stale revision expectations must fail before touching
  active instances. However disposal is **not** a transaction over arbitrary
  application effects: a throwing disposer is reported after definitions
  have committed, and a full page reload can be necessary.
- Existing captured exports are not automatically rebound when a module is
  replaced. Consumers must reacquire exports via `require`.
- The module registry must not retain unbounded obsolete factory definitions
  merely as a side effect of replacement cycles. Application-retained
  references, event listeners, timers and network resources must be released
  through explicit application cleanup.
- `loadScript` is a browser-only classic script transport and checks that
  explicitly expected module revisions advanced. It does not guarantee
  atomic application/network effects, cryptographic content integrity or
  coherent multi-asset production deployment.

## 4. Distribution and portability

A single physically bundled classic script may contain the loader plus
compiled registrations through a separate packaging step. That bundle can
defer **evaluation**, but cannot avoid downloading embedded module bytes.
A multi-file layout can instead defer network transfer of optional modules.

Development servers must use suitable freshness headers for reloadable scripts.
Production release consistency and service-worker upgrades remain separate
application/deployment responsibilities; `jsc` does not own them.

The loader library is a browser classic-script asset, **not** an ESM import
implementation. The Node compiler engine is a host build-time facility and
must not be required in the consumer browser. Public command/library
documentation is maintained under `res/sys/manual` alongside the product
revision.

## 5. Boundaries

This current contract promotes only the proven `jsc` and loader source
model. It does not promote PoC 062's operator/supervisor/file-lock experiments,
HMR state migration for arbitrary applications, ESM transpilation,
esbuild/webpack replacement, or a new package integration contract.

## Invariants

```text
JSC-01  jsc command and jsc.lib.js engine belong to m; the loader is an independent m classic library
JSC-02  compiler output consists of classic registrations and never embeds the loader
JSC-03  static ESM import/export and import.meta are rejected rather than translated
JSC-04  sources and dependencies are validated before writing compiled output
JSC-05  loader supports manually authored registrations, independent of jsc
JSC-06  loader registration is lazy and replacement disposes affected instantiated consumers
JSC-07  invalid graph/stale revision update leaves active instances unchanged
JSC-08  application effects and stale exports are not transactionally rolled back by replacement
JSC-09  single-file packaging defers execution, not physical transfer
JSC-10  controlled loader registry versions do not grow without bound merely from replacement
```
