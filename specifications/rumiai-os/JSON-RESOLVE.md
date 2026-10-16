# m — JSON configuration resolution

Status: **Current / normative**
Updated: 2026-10-16

## Purpose and public interface

`m.json.resolve(config, references, allowGlobals)` synchronously interprets a JSON configuration as a limited declarative construction language and returns a new JavaScript result. It does **not** mutate the JSON input through its own resolution operations.

- `config` is required and is one parsed JSON value (including scalar or `null` roots), not JSON source text.
- `references` is an optional object/function namespace of external JavaScript values, classes, and functions; omitted or `null` means an empty namespace.
- `allowGlobals` is an optional Boolean, default `false`. When true, names absent as **own properties** of `references` may be looked up on `globalThis`; explicit registered names always take precedence. This is ordinary property lookup, not source-code evaluation. Lexical bindings are not automatically visible.
- An invalid input or option throws; a missing named value or an impossible resolution raises an error identifying its location. Exceptions from explicitly called user functions/constructors propagate. There is no asynchronous waiting or automatic retry.

This API belongs to `m.json`, not `m.object`: its accepted input is JSON data and its specific duty is interpreting directives, whereas the object primitives own arbitrary JavaScript object graphs.

## Input boundary

The input is structurally the result of `JSON.parse`: `null`, strings, Boolean values, finite numbers, ordinary JSON records with own string data properties, and dense arrays of those values. Literal JSON special keys such as `__proto__` are ordinary data.

The resolver verifies this input tree before executing user-supplied operations. Invalid input includes functions, `undefined`, `Symbol`, `BigInt`, nonfinite numbers, typed/native instances, arbitrary class instances, customized/null-prototype objects, nonstandard own property descriptors, getters/setters, symbol properties, sparse/extended arrays, and structural cycles or shared object identities. Inputs need not prove historical provenance from `JSON.parse`; structurally equivalent values are accepted. A JSON document cannot represent graph identity or custom prototype inheritance.

**Only own JSON data keys participate.** The intentional inherited-enumeration behavior of `m.object.traverse` remains separate and unchanged. Resolving a JSON configuration does not clone, inspect or automatically interpret JavaScript objects supplied through `references`, `globalThis`, or outputs of callable directives.

## Directives and static paths

A directive is an array with exactly the recognized first element and the following form:

```js
["@ref", "$.services.main"]
["@ref", "external.resource"]
["@ref", "^^.color"]
["@new", "api.Service", [argument1, argument2]]
["@call", "api.create", [argument1, argument2]]
```

- `@ref` requires exactly two elements, with a string static path.
- `@new` and `@call` require a string static external callable name and optionally an array of arguments; omitted arguments mean none.
- Directive arguments can themselves contain JSON objects, arrays, and directives. They are resolved before invocation; the callable is invoked exactly once. `@new` uses the native JavaScript constructor contract (`Reflect.construct`, including ES classes); `@call` uses the JavaScript function contract, with `this` bound to the owning external object of a qualified callable, or to `references`/`globalThis` for a directly registered/global name.
- Other arrays are ordinary JSON data arrays. The formerly supported directive `@eval` is rejected. Strings such as `"@ref:$.x"` or `"@eval:..."` are **literal strings**, not directives.
- The external namespace path's first segment is an identifier resolved from `references` or an explicitly opted-in global. Subsequent segments are ordinary JavaScript property lookup on that external value; missing properties throw. External values are opaque and references preserve their identities.
- `$` designates the root of the **new output**. Each `^` designates one ascent from the current directive's position (`^` is its containing object/array, `^^` the next container, etc.). A relative path cannot escape the root. These references may point forward to as-yet-unresolved fields.
- Paths contain **only static segments**: `.identifier`, `[0]` (canonical safe nonnegative decimal integer), or `["JSON string property name"]`. Quoted segments use JSON string syntax, not single-quoted JavaScript strings. There is no expression evaluation, dynamic indexing, method call, or JavaScript program execution in a path.
- Local path navigation follows keys of the original JSON structure until a directive is reached. Properties after a resolved directive are read as ordinary JavaScript properties of its result; that result is not recursively interpreted as configuration.

Malformed recognized directives and paths fail with a location-bearing error rather than executing an approximate or similarly prefixed operation.

## New result, identity, ordering and errors

For every normal JSON object or array in the input, `resolve` constructs a **new** object/array, preserving JSON key/value structure. JSON scalars are returned unchanged. Input prototype chains do not participate; output JSON records are ordinary JavaScript records with own properties. Keys including `__proto__` must be created as own data properties, without triggering inherited prototype setters.

A resolved `@ref` uses the exact target value rather than copying it. Multiple references to one result share identity; references to the new root or other output containers may create structural cycles. JSON input itself cannot contain shared identities or cycles. A cycle consisting only of unresolved directive dependencies (e.g. `a → b → a`) is an error. Construction/call results may be arbitrary JavaScript values, including functions, instances and native objects; no automatic traversal or second resolution is performed inside them.

Dependencies are resolved on demand, not necessarily in the textual order of references; independent operations follow normal depth-first input order. As a consequence, no guaranteed invocation order is promised when dependencies force forward resolution. References to a currently-being-populated output container can observe its shell during explicit calls; its properties are complete when the outer `resolve` succeeds.

The resolver validates the JSON structure and directive syntax before performing any invocation. Later named-value lookup and execution may still fail. It makes **no transactional rollback promise**: callable code can have external effects and may deliberately mutate values visible to it. The nonmutation guarantee covers the resolver's own processing of the original JSON tree, not arbitrary effects of user code executed through `@call` or `@new`.

An external JSON configuration is not resolved automatically when referenced. A supplied `@call` function can explicitly call `m.json.resolve` on it; that nested call returns an independently resolved result without having to mutate the external JSON input.

## Integration and verification

The core namespace descriptor `rumiai-os/lib/sys/js/core/modules-js.json` exports `m.json.resolve`. Implementation lives in `rumiai-os/lib/sys/js/core/m/json/resolve.js`. The `m.object.traverse`, `m.object.clone`, `m.json.traverse`, `m.json.canonicalize` and `m.json.path` contracts are independent and are not redefined by this resolver.

Permanent test coverage belongs to `rumiai-tests/tests/rumiai-os/js-core/.support/json-resolve.mjs`, executed by `compile.test` against the real `jsc` output, with browser/CommonJS smoke integration.

## Invariants

```text
JSON-RESOLVE-01  JSON-only parsed input; invalid JS-only structures rejected
JSON-RESOLVE-02  input unchanged by resolver; new JSON-derived result containers
JSON-RESOLVE-03  exact @ref/@new/@call directives and static paths; no eval
JSON-RESOLVE-04  external/global capabilities explicit; globals opt-in and lower priority
JSON-RESOLVE-05  forward local/relative references; shared output identity and valid structural cycles
JSON-RESOLVE-06  circular unresolved directives and missing names fail with context
JSON-RESOLVE-07  user call/construct executes once, after args resolve; opaque results
JSON-RESOLVE-08  no automatic external graph interpretation, rollback, or async execution
```
