# m — JavaScript object traversal

Status: **Current / normative**
Updated: 2026-10-16

## Responsibility and public interface

The JavaScript core exports `m.object.traverse(object, callback)` and `m.object.traverse.advanced(object, fAnte, fPost, fRecurse)`.
The historical `m.json.traverse` is an alias for the **same function**, including its `.advanced` property. Both interfaces describe an object graph by identity; they are not JSON serialization operations.

Neither traversal mutates the input on its own. Callbacks may mutate the graph, and their exceptions propagate normally. Callbacks run synchronously; asynchronous callback results are not awaited.

## Graph and enumeration semantics

- Every object identity is visited **once**, at the first path by which it is reached. Cycles and shared references are not visited repeatedly. Later paths to the same object are omitted from the result arrays.
- Primitive values, including repeated equal primitive values, are visited separately at each occurrence.
- Functions are values/leaves, not traversed as objects. Null is also a leaf.
- Children are enumerated using JavaScript `for...in` behavior: **own and inherited enumerable string-keyed properties** participate, including inherited properties from multiple prototype levels. Non-enumerable properties and Symbol keys do not participate.
- Traversal is depth-first following `for...in` order. Child values are read when their edge is visited; earlier callbacks may affect later property values. The iterator's property-enumeration behavior under graph mutation is the host JavaScript engine's `for...in` semantics.
- Traversal uses an iterative frame stack and object-identity tracking, so internal recursion does not grow the JavaScript call stack with graph depth. Storing callback metadata and path strings can still be expensive for deep graphs.

## Paths and callback metadata

Every visited value has a path string rooted at `""` and a `pathArray` of property-key strings. Paths are built from bracket segments; canonical nonnegative decimal integer keys representable as safe integers use `[n]`, while other strings are represented using `[<JSON.stringify(key)>]`. Thus `"0"` uses `[0]`, while `"01"` and unsafe-large integer strings are quoted.

The callback positional metadata is:

```js
(value, path, pathArray, parents, parentsPaths)
```

`parents` and `parentsPaths` are nearest-ancestor-first arrays; they exclude the visited value itself. The root has empty arrays. Both traversal variants preserve this interface, and `fRecurse` also receives the full five arguments (the fifth is an additive correction).

## Ordinary traversal

`m.object.traverse(object, callback)` visits values in **preorder**. When `callback` is callable, it runs once for each visited value before that value's children; otherwise the calculation is `undefined`.

The result is exactly:

```js
{nodes, paths, calcs}
```

The three arrays are aligned in preorder; `calcs` contains callback return values.

## Advanced traversal

`m.object.traverse.advanced(object, fAnte, fPost, fRecurse)` retains the existing pre/post callback phases and postorder result contract:

1. `fAnte`, if callable, executes before visiting children.
2. `fRecurse`, if callable, executes once per eligible object after `fAnte`; a falsy result suppresses child traversal, but not `fPost`.
3. `fPost`, if callable, executes after descendants, whether or not recursion occurred.

All callback results are optional and are not awaited. Non-callable optional callbacks are ignored. The result is:

```js
{nodes, paths, calcs, calcsPost}
```

The arrays are aligned in **postorder**; `calcs` holds `fAnte` return values in postorder position, and `calcsPost` exposes `fPost` return values in the same order. `calcsPost` is an additive field; existing `nodes`, `paths` and `calcs` retain their meaning.

## Compatibility boundary

The `m.json.traverse` alias preserves both original callable signatures and its `advanced` member without duplicating the engine. `m.json.resolve` remains a consumer of the ordinary traversal API and its existing configuration directive behavior is not redefined by this contract.

This traversal's inherited enumerable property policy intentionally differs from the own-property policies of `m.object.clone` and `m.object.merge`; their independent contracts remain unchanged.
