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

The **primary `jsc` contract** preserves the original `m/jsc`
authoring model: an ordered, nested `modules` tree whose namespace nodes
use `name` and source nodes use `file` plus optional comma-separated
`symbols`. Source files are concatenated in descriptor order; namespace
wrappers assemble scope and expose declared symbols into their namespace.
Already declared symbols remain usable unqualified within their namespace,
and already opened descendant namespace objects remain usable by their
short names in their ancestor scope. Qualified paths such as
`m.srv.data.MyClass` are provided by the same assembled tree.
The manifest must not require the author to repeat those lexical relations
in `id/deps` declarations. Nested source assembly executes as an ordinary
classic script, without a runtime registry requirement.

The primary public invocation is:

```text
jsc <modules.json> [output]
```

With no output operand, generated source goes to standard output without
status prose contaminating it. With an output operand, the compiled file
is written there. Source file paths are resolved relative to the manifest
directory. The compatibility model retains the original `name`/`modules`
nesting and `file`/`symbols` records, in their authored order. Filesystem
containment, syntax, identifier validation, contextual errors and safe
failure semantics must be improved without changing normal program meaning.
CSS manifests consisting of ordered CSS source files are also accepted as
raw concatenated CSS; CSS is not evaluated as JavaScript.

The previously promoted explicit `version:1` `{id,file,deps,format?}`
format remains a distinct compatibility mode for experiments/consumers that
use the independent runtime module registry. That format generates
`globalThis.JscRuntime.installBatch` registrations, validates its declared
graph, and does not embed a loader. It is **not** a requirement for authoring
the original nested namespace assembly. The two modes are selected by the
manifest's data shape; there is no automatic ESM translation or implicit
mixed graph.

The classic compiler does not reinterpret static native ESM
`import`/`export` or `import.meta`. A native `import()` expression
inside otherwise classic code remains outside `jsc`'s control.
`mk` remains separate orchestration, not a second compiler.

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

In explicit registry mode, a single physically bundled classic script may contain the loader plus
compiled registrations through a separate packaging step. Legacy namespace
assembly instead produces a standalone classic script; it does not require
the registry loader. That bundle can
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

This current contract promotes the original nested namespace source assembly as
`jsc`'s primary workflow while retaining the separately declared module-registry
mode and independent loader. It does not promote PoC 062's operator/supervisor/file-lock experiments,
HMR state migration for arbitrary applications, ESM transpilation,
esbuild/webpack replacement, or a new package integration contract.

## Invariants

```text
JSC-01  jsc command and jsc.lib.js engine belong to m; the loader is an independent m classic library
JSC-02  primary jsc mode assembles ordered nested name/modules/file/symbols sources and namespaces without a runtime loader
JSC-03  static ESM import/export and import.meta are rejected rather than translated
JSC-04  source paths, descriptors and source syntax are validated before writing output; explicit registry graphs additionally validate dependencies
JSC-05  loader supports manually authored registrations, independent of jsc
JSC-06  loader registration is lazy and replacement disposes affected instantiated consumers
JSC-07  invalid graph/stale revision update leaves active instances unchanged
JSC-08  application effects and stale exports are not transactionally rolled back by replacement
JSC-09  single-file packaging defers execution, not physical transfer
JSC-10  controlled loader registry versions do not grow without bound merely from replacement
JSC-11  original nested JS and ordered CSS source manifests remain primary jsc inputs; output can go to stdout
JSC-12  experimental explicit id/deps registration is a separate optional manifest shape, not mandatory namespace metadata
```
