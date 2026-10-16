# m — browser dynamic source loader

Status: **Current / normative**
Updated: 2026-10-16

## Responsibility and separation

`m.mod.DynamicLoader` composes and inserts browser JavaScript or CSS from an
HTTP-accessible, ordered JSON source descriptor. It belongs to the technical
`m` runtime and does not depend on the RumiAI product layer.

The compiler `jsc` and the browser loader have separate responsibilities.
`jsc` compiles author-selected local files using the contract in
`JSC.md`. It does not fetch, select or load browser runtime sources.
The runtime loader downloads explicitly listed remote source files,
assembles them in descriptor order and optionally inserts the resulting
classic script or style. It does not discover dependencies or invoke `jsc`
at runtime.

The established source fragment is
`lib/sys/js/core/m/mod/DynamicLoader.js`. The distinct descriptor
`lib/sys/js/core/modules-dynamic-loader.json` explicitly selects the
native `m.mod.Queue` source followed by `m.mod.DynamicLoader`.
This descriptor may be compiled with `jsc` to produce a browser script
that publishes the two exports under `m.mod`. No implicit bootstrapping,
automatic descriptor selection or bundle filename is required.

`lib/sys/js/dynamic-loader.lib.js` is a **separate, presently existing**
browser library with different global entrypoints. It is not an alias for
`m.mod.DynamicLoader`; its continued presence does not expand the new
loader's API. Legacy-library cleanup and migration are separate from this
contract and belong to the caller or maintainer performing that work.

## Public class and methods

Construct `new m.mod.DynamicLoader()` after loading the compiled browser
bundle. The public instance interface consists of:

```javascript
async compose(manifest, {signal} = {})
async load(manifest, {replace = null, signal, nonce} = {})
```

`manifest` is a nonempty string resolving relative to
`document.baseURI`. Both methods return Promises.

### compose()

The loader fetches the descriptor, validates its structure, resolves
referenced source paths relative to the descriptor URL directory,
downloads source text asynchronously and assembles it in **manifest order**
regardless of HTTP completion order. It uses a local `m.mod.Queue` per
composition with blocking source failures. Concurrent compositions do
not share their Queue state.

A valid descriptor has a `modules` array containing ordered namespace
nodes (`name` and `modules`) or file nodes (`file`, with optional JS
`exports` and `imports`). A root `nodeGlobal` value, if supplied, must
be Boolean; this browser loader does not use it to publish Node globals.
The descriptor must contain at least one source file and all files must
be of the same kind: JavaScript `.js` or CSS `.css`.

JavaScript output uses classic-script nested namespace scopes with
explicit `exports` and reference-only lexical `imports`, applying the
existing `jsc` namespace model. It does not provision imported
dependencies, use eval or create a runtime dependency registry.
CSS output is concatenated in declaration order; CSS descriptor nodes
may not declare JavaScript imports/exports or namespaces.

The result is:

```javascript
{kind: "js" | "css", code: "<assembled source>"}
```

Successful composition means that the requested source text was
retrieved and assembled. It does **not** certify the correctness,
semantics or successful execution of the resulting code.

### load()

`load()` first calls `compose()`, creates a `script` for JavaScript or
a `style` for CSS, sets its text, optionally sets `element.nonce`,
and appends the element to `document.head`. If `replace` was supplied,
it must be an attached element with the matching tag type. The newly
created element is appended before the original is removed.

The Promise resolves with the newly inserted DOM element when those
operations complete; failures of descriptor retrieval, validation,
source downloads, replacement validation or DOM insertion reject it.

**The success boundary is insertion/loading, not bundle correctness or
successful execution.** In particular, `load()` does not guarantee that
JavaScript parses at browser runtime, executes without throwing, fulfills
its intended behavior, or is accepted by the browser's Content Security
Policy. A script blocked by CSP or one that throws at execution time may
therefore coexist with a fulfilled `load()` Promise. The calling
application and the loaded bundle own execution correctness, readiness
checks, application-level diagnostics and recovery.

The loader does not roll back effects caused by an executed script.
Removing or replacing a `script` element does not undo global changes,
event listeners, timers or other side effects. The loader does not
provide transactional reload or application rollback semantics.
For nonce-based CSP, callers must pass the appropriate `nonce` on
**each** script insertion/replacement; the loader does not inherit the
old element's nonce. An inserted replacement can lead to removal of the
old element even if the replacement script was blocked by CSP. This is
not a promise of successful code execution.

## Network and error boundary

Manifest URLs must be same-origin with the current document location.
Source files are restricted to the descriptor's base pathname and
origin; absolute paths, parent traversal and disallowed URL forms are
rejected. Descriptor, HTTP, network, read and validation failures reject
`compose()` and thus `load()` when applicable.

Failures of a queued source download are blocking. The first failure
reached in manifest FIFO order rejects composition through the Queue's
single error notification; failures need not be reported in wall-clock
completion order. There is no partial-bundle success after a rejected
download. In-flight requests are **not** automatically canceled merely
because the Queue stops; late Queue completions are ignored. An optional
`AbortSignal` is passed to fetch, but source cancellation policy beyond
that remains the caller's responsibility.

No additional error-observer API, global exception interception or
automatic logging of errors emitted by loaded application code is
part of this loader's interface.

## Responsibility and validation boundaries

The loader owns descriptor validation, bounded URL resolution,
retrieval, ordered assembly, DOM insertion and replacement validation.
The application owns selecting descriptors, serving compatible
resources, setting browser security policy and validating the behavior
of loaded code. Bundles created by `jsc` and runtime-composed bundles
are alternative ways to supply code, not mandatory dependencies of
one another.

The permanent browser regression in `rumiai-tests` exercises the
specialized `jsc` output with a real HTTP fixture and Chromium:
namespace publication, ordering, JavaScript/CSS insertion and
replacement, error branches, and nonce-based CSP. This establishes
the tested browser behavior, not correctness of arbitrary loaded
applications or physical validation of a user host.

## Invariants

```text
DYNAMIC-LOADER-01  runtime source composition is independent of jsc compilation and legacy global loader functions
DYNAMIC-LOADER-02  one descriptor chooses an ordered homogeneous JS or CSS source collection; no dependency discovery
DYNAMIC-LOADER-03  fetch completions can be unordered, but assembled output preserves descriptor order
DYNAMIC-LOADER-04  source retrieval/validation errors reject compose; failures are blocking at the Queue boundary
DYNAMIC-LOADER-05  load resolves after the generated element is inserted, not after successful bundle execution
DYNAMIC-LOADER-06  bundle semantics and execution diagnostics belong to the loaded bundle and its caller
DYNAMIC-LOADER-07  replacement and element removal do not roll back script side effects
DYNAMIC-LOADER-08  callers provide nonce for each CSP-constrained insertion; nonce inheritance is not implicit
DYNAMIC-LOADER-09  a stopped queue ignores late completions but does not itself cancel HTTP requests
```
