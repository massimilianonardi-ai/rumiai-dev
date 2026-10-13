# m — JavaScript source compiler and dynamic JS/CSS library loading

Status: **Current / normative — approved redesign directions; product, manuals and permanent tests pending realignment**
Updated: 2026-10-13

## Role and placement

The first-party `m` design evolves the existing `m/jsc` source compiler
and preserves the independent browser JS/CSS dynamic source loader
responsibility. The established product locations remain:

```text
bin/sys/jsc
lib/sys/js/jsc.lib.js
lib/sys/js/dynamic-loader.lib.js
```

The command is bootstrap-integrated through the normal
`#!/usr/bin/env m` shell entrypoint, invoking the Node.js engine through
the default managed Node.js runtime. The browser loader is a separate
non-executable classic JavaScript library with no compiler dependency.
No different command interpreter/entrypoint model is introduced here.

## Ordered source descriptor

The ordered JSON `modules` descriptor remains the source-assembly model.
Entries are:

- **Namespace node:** `name` (optional JavaScript identifier) and nested
  `modules` (ordered array).
- **Source node:** `file` (relative source path), optional comma-separated `exports` (the
  former `symbols`, retaining its meaning and without type or metadata
  additions) and optional `imports` for explicit external symbols.

Import declarations in the JSON are **supported, optional and recommended**
to keep JavaScript source files decoupled from the build description. They
describe **references to values exposed by already available namespace
objects**, not file imports or dependency loading. For example, an optional
JSON import of `A` from `m.data.A` generates an ordinary lexical binding
equivalent to `const A = m.data.A;`. A developer may instead write that
binding directly in JavaScript, without mentioning it in the JSON.
`jsc` does **not** resolve and load source files, emit `require()`/`import`
to fetch an external bundle, duplicate provider implementations, or change
the authored source's namespace placement on account of these references.
Provisioning the referenced provider namespace is the responsibility of
the embedding/application environment, not an import declaration.

Files are evaluated in the declared order. The compiler creates nested
namespace objects, retains earlier declarations in the lexical scope of
later source files and exposes explicitly named exports as namespace
properties. A source in `m.srv.data` can refer directly to a prior
`MyClass`; `m.srv` can use `data.MyClass`; the fully qualified
`m.srv.data.MyClass` is available where `m` is visible. Namespace
objects can be reopened by subsequent assemblies, retaining the original
namespace and lexical visibility goals.

Declared cross-bundle imports produce lexical bindings to the exported
values when the consumer bundle initializes; later replacement of a
namespace property does not automatically replace an already captured
function reference. Source code that deliberately uses a qualified
namespace property access instead obtains the property's current value
when executed. These semantics do not freeze the properties of imported
objects.

The generated library encapsulates its internal declarations and publishes
only the explicit public API, following the established standalone TextEdit
model. Output is usable in both classic browser scripts and Node.js without
`eval()`, `with`, a dynamic code generator, or a mandatory runtime registry.
The existing CSS source-list model remains unchanged.

JavaScript and CSS are assembled separately. CSS manifests list source
files in order, without JavaScript namespaces or exports.

## Public jsc command and engine

```text
jsc <modules.json> [output]
```

- Without `output`, emit only the compiled script or CSS to stdout.
- With `output`, write the assembled file and create a gzip artifact.
  Optimization and minification are not automatic `jsc` responsibilities;
  developers may perform them independently.
- Source file names are resolved relative to the descriptor directory.
  Existing source files must remain inside that directory when resolved.
- Invalid descriptors, unsafe import/export identifiers and generated JS
  syntax errors fail before overwriting a previously valid output file.
  Google Closure Compiler is the intended syntax verification engine.
- The internal `jsc.lib.js` exposes the public Node function
  `jscMain(args)`, returning a Promise of process-style status.
- The launcher uses the existing `m` `log`/`fatal` facilities, and
  the Node subprocess reports its own branch-specific errors without
  duplicating them in the shell.

The compiler does not require the browser dynamic loader for its output.

## Independent browser dynamic loader

`dynamic-loader.lib.js` implements the original source-list loading
responsibility, with the following public functions:

```text
loadModulesDynamically(path, modulesFile, callback)
replaceModulesDynamically(path, modulesFile, libraryElement, defaultModulesFile, tag)
loadJSLibraryDynamically(path, jsModulesFile, jsElement)
loadCSSLibraryDynamically(path, cssModulesFile, cssElement)
loadLibraryDynamically(path, jsModulesFile, cssModulesFile, jsElement, cssElement)
```

The loader reads the same ordered JSON descriptors and original source files
over browser HTTP, builds the classic script/style content, and inserts or
replaces DOM elements. JavaScript namespace assembly preserves the original
ordering and lexical visibility. With no explicit path and a configured
global `dynamicLibs` array, the loader follows the original multi-library
initialization model. Loaded JavaScript can create application effects that
DOM-element removal does not reverse.

The standalone browser library has no implicit runtime module registry,
`require` graph, revision mechanism, or ESM translation responsibility.

## Invariants

```text
JSC-01  jsc and its engine belong to m; independent JS/CSS source loader is an m library
JSC-02  ordered modules/name/file/exports descriptors support optional JSON reference imports or developer-written lexical bindings; neither loads files
JSC-03  compilation preserves original namespace reopening, lexical visibility and authored source order
JSC-04  jsc outputs standalone strict-capable browser/Node JavaScript with private internals and explicit public exports, or ordered CSS
JSC-05  stdout-only and optional file-output plus offline gzip; minification/optimization are user-managed
JSC-06  invalid descriptors, sources, identifiers and generated JS syntax fail before writing output
JSC-07  dynamic loader accepts original JS and CSS source lists and preserves public function identities
JSC-08  browser code is loaded as classic script/style; existing side effects are not undone by removal
JSC-09  source imports do not require a runtime module registry or alternative bootstrap model
JSC-10  cross-bundle imports capture values on bundle initialization; qualified accesses remain dynamic; no eval
```
