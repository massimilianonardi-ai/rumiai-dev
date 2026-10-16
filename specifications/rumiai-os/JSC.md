# m — jsc JavaScript and CSS source compiler

Status: **Current / normative**
Updated: 2026-10-16

## Responsibility and boundary

`jsc` is a source compiler owned by the technical `m` layer. It reads an
ordered JSON source descriptor and its referenced local source files, and
generates a single JavaScript or CSS output. Its behavior is defined by the
descriptor, source contents and explicitly selected output destination.

`jsc` has no application- or distribution-specific responsibility: it
does not know which functions an application needs, choose a source
collection, discover dependencies, fetch files over HTTP, execute the
compiled result, or decide how an application deploys or loads it.
Different JSON descriptors may select different subsets of the same
source tree, including a complete selection. Those selections and their
intended uses are authored outside the compiler; `jsc` processes each
descriptor with identical semantics.

Source directory layout may reflect namespace organization, but `jsc`
does not require or infer a mapping between file paths and namespace
names. The JSON descriptor alone specifies namespace placement, ordered
source inclusion and public exports.

The public command remains `bin/sys/jsc`, using the established
`#!/usr/bin/env m` bootstrap-integrated shell entrypoint and the
default managed Node.js runtime. Its Node.js engine retains the
`jscMain(args)` entrypoint, returning a Promise of process-style status.
No alternative interpreter or command-bootstrap model is introduced.

## Ordered JSON source descriptor

The root contains an ordered `modules` array and may contain optional
Boolean `nodeGlobal` (default `false`).

Each entry is one of:

- **Namespace node:** optional JavaScript identifier `name` and nested
  ordered `modules` array.
- **Source node:** relative source pathname `file`, optional
  comma-separated `exports` identifiers, and optional object `imports`
  mapping local identifiers to qualified namespace-property references.

`exports` is the current spelling of the former `symbols` field;
there is no added export type or metadata system. `imports` is
supported, optional and recommended where it avoids coupling authored
source to a specific external namespace spelling. An import mapping
such as `{"A":"root.data.A"}` generates an ordinary lexical value
binding equivalent to `var A = root.data.A;`. The authored source may
instead contain that binding itself.

Imports are **references to values already made available by the
execution environment**, not dependency declarations. They never
cause additional files to be included, resolved, downloaded or loaded.
The compiler does not emit runtime `require()` or `import` statements
to provision referenced values. The application controls when those
values are available.

Source files are emitted in descriptor order. When the generated
JavaScript executes, nested namespace scopes retain lexical access to
earlier declarations, and
explicit exports become properties of their declared namespace.
Namespace objects can be reopened by later generated JavaScript without
discarding existing properties. Within the same namespace, later
source files can use earlier lexical declarations; parent namespace
scopes can refer to nested namespace objects; qualified namespace
references remain accessible wherever their root is visible.

A generated import captures the property value when the enclosing
source initializes. Replacing that namespace property later does not
automatically update the captured binding; a source expression that
reads the qualified property at call time instead observes its current
value. Neither form freezes an imported object's properties.

## Generated JavaScript

The output is one standalone, strict-capable classic JavaScript program
with an outer strict-mode closure around its nested namespace scopes.
Only explicitly exported identifiers become namespace properties;
internal lexical declarations are not automatically published.
Generation uses no `eval()`, `with`, dynamic code generator or
mandatory runtime registry.

Publication of the generated namespace roots depends on the execution
environment and the descriptor-root `nodeGlobal` setting:

- **Browser classic script:** publish/reopen roots on `globalThis`,
  irrespective of `nodeGlobal`.
- **Node.js CommonJS, `nodeGlobal` absent or `false`:** return the public
  namespace through `module.exports` without consulting or modifying an
  equally named `globalThis` namespace.
- **Node.js CommonJS, `nodeGlobal: true`:** reuse an existing namespace
  root on `globalThis` or publish one when absent; `module.exports`
  refers to the same namespace object.

`nodeGlobal` is a compile-time descriptor setting, not a command
option or a runtime environment variable. It neither includes extra
source files nor changes the semantics of `imports`.

These are general output semantics, not a prescribed deployment strategy
for independently generated outputs. Selection of one complete,
specialized or other compiled artifact belongs to the application.

## CSS compilation

A CSS descriptor is an ordered list of source files. CSS is concatenated
in declared order without JavaScript namespaces, `imports` or
`exports`. JavaScript and CSS are separate compilation outputs;
one descriptor must not mix the two source kinds.

## Public command and output

```text
jsc <modules.json> [output]
```

- Without `output`, emit only compiled JavaScript or CSS on stdout.
- With `output`, write the assembled content unchanged. If an
  appropriate installed minifier is present, additionally produce
  `<name>.min.js` using `google-closure-compiler` or
  `<name>.min.css` using `uglifycss`, and gzip that minified artifact.
  Without a minifier, gzip the unminified output. Never download or
  install tools implicitly.
- Resolve source paths relative to the descriptor directory. Referenced
  files must remain inside that directory, including after resolution
  of existing filesystem links.
- Reject invalid descriptors, mixed source kinds, unsafe identifiers,
  invalid source paths and generated JavaScript syntax with a nonzero
  status. Always syntax-check JavaScript. When installed, run
  `google-closure-compiler --checks_only` separately without mutating
  the generated source.
- Ordinary shell redirection may truncate an existing output before
  validation fails. Atomic replacement or preservation on failure is
  not required.
- The shell launcher uses the existing `m` `log`/`fatal` facilities;
  the Node subprocess reports its own branch-specific errors without
  duplicating those errors in the shell.

## Invariants

```text
JSC-01  jsc and its Node engine belong to the m compiler responsibility
JSC-02  ordered modules/name/file/exports descriptors support optional lexical reference imports; imports do not load or include sources
JSC-03  compilation preserves descriptor source order, nested namespaces, reopening and lexical visibility
JSC-04  output is strict-capable browser/Node JavaScript with private internals and explicit exports, or ordered CSS
JSC-05  stdout or file output; installed minifier creates minified and gzipped artifacts, otherwise gzip the original; no implicit tool installation
JSC-06  invalid descriptors, paths, identifiers and generated JavaScript syntax fail; shell output redirection need not preserve an existing file
JSC-09  import references neither provision dependencies nor require a runtime registry
JSC-10  captured import values and qualified property reads retain their distinct runtime semantics; generated code uses no eval
JSC-11  nodeGlobal defaults false; browser publishes roots; CommonJS exports the public API and shares globals only when opted in
JSC-12  compiler operation is agnostic to application, source selection, distribution purpose and runtime loading
```
