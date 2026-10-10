# m — JavaScript source compiler and dynamic JS/CSS library loading

Status: **Current / normative**
Updated: 2026-10-10

## Role and placement

The first-party `m` implementation retains the original `m/jsc` compiler
and browser JS/CSS dynamic source loader model, adapted to the current
product tree:

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

The single public source format is a JSON object with an ordered
`modules` array. Entries are either:

- **Namespace node:** `name` (optional JavaScript identifier) and nested
  `modules` (ordered array).
- **Source node:** `file` (relative source path) and optional comma-separated
  `symbols` (exported JavaScript identifiers).

Files are evaluated in the declared order. The compiler creates nested
namespace objects, retains earlier declarations in the lexical scope of
later source files and exposes explicitly named symbols as namespace
properties. A source in `m.srv.data` can refer directly to a prior
`MyClass`; `m.srv` can use `data.MyClass`; the fully qualified
`m.srv.data.MyClass` is available where `m` is visible. Namespace
objects can be reopened by subsequent assemblies.

The descriptor itself supplies ordering and namespacing; **no additional
dependency graph, module IDs or runtime registry is part of this system**.
The compiler must not impose or translate native ESM syntax.

JavaScript and CSS are assembled separately. CSS manifests list source
files in order, without JavaScript namespaces or exports.

## Public jsc command and engine

```text
jsc <modules.json> [output]
```

- Without `output`, emit only the compiled script or CSS to stdout.
- With `output`, write the assembled file and create a gzip artifact.
  When a compatible JS or CSS minifier is already installed, create its
  normal minified sibling and compressed release artifact as well.
  Minification is not an implicit software download or installation.
- Source file names are resolved relative to the descriptor directory.
  Existing source files must remain inside that directory when resolved.
- Invalid descriptors, unsafe symbol names and generated JS syntax errors
  fail before overwriting a previously valid output file.
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
JSC-02  ordered modules/name/file/symbols descriptors are the only jsc input model
JSC-03  compilation preserves namespace lexical visibility and authored source order
JSC-04  jsc outputs standalone classic JavaScript or ordered CSS without a runtime registry
JSC-05  stdout-only and optional file-output plus offline gzip follow the original command form
JSC-06  invalid descriptors, sources, identifiers and generated JS fail before writing output
JSC-07  dynamic loader accepts original JS and CSS source lists and preserves public function identities
JSC-08  browser code is loaded as classic script/style; existing side effects are not undone by removal
JSC-09  no ESM conversion, module IDs, explicit dependency graph or new bootstrap model is introduced
```
