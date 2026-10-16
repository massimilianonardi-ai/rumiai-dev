# m — Object graph cloning

Status: **Current / normative**
Updated: 2026-10-16

## Responsibility and public interface

The JavaScript core exports `m.object.clone(source, level, bitmask)`.
This is a general-purpose `m` object-graph operation, independent of JSON serialization.
The legacy `m.util.clone` and unexported `m/json/clone.js` sources remain unchanged; this interface neither delegates to them nor silently replaces their contracts.

`source` is required. Primitive values, null and callable values are returned unchanged. Objects are cloned without invoking user-defined constructors.

## Depth

- Omitted `level`, `false` and `0`: clone the root object; its property values normally retain their original references.
- A nonnegative number: clone that many additional property/reference edges beyond the root; fractional levels are floored.
- `true` or positive infinity: clone all reachable supported object nodes without a fixed depth limit.
- Negative, NaN and nonnumeric levels are rejected with `TypeError`; a missing source raises `SyntaxError`.

Graph traversal is iterative, preserving cycles and shared identity among cloned nodes. When the same object is encountered at different permitted depths, the most extensive encountered depth determines its populated clone. A reference beyond the selected depth remains shared. Intrinsic binary backing memory of a cloned binary view is nevertheless copied so the view is usable and independent.

## Bitmask flags

`bitmask` is optional, defaults to zero, and must be a nonnegative safe integer containing only the defined six bits.

| Flag | Value | Meaning |
|---|---:|---|
| `clone.error` | 1 | Throw `TypeError` instead of returning a reference for an unsupported object type. |
| `clone.value` | 2 | Read property values (including getters) and create ordinary writable/configurable data properties instead of preserving their descriptors. |
| `clone.enum` | 4 | Include only enumerable own properties, apart from essential intrinsic structure such as array length. |
| `clone.instance` | 8 | Opt in to best-effort cloning of ordinary custom-class instances; otherwise preserve their references. |
| `clone.ideep` | 16 | For opted-in instances, preserve descriptors even if `clone.value` is set. |
| `clone.iall` | 32 | For opted-in instances, retain non-enumerable properties even if `clone.enum` is set. |

Flags can be combined with bitwise OR. The flag properties on the exported function are frozen.

## Object semantics

- Ordinary objects, including null-prototype objects, preserve their prototype and own property descriptors by default. Own string and Symbol keys are included; inherited keys are not copied. Accessor functions are retained without invoking them unless `clone.value` is explicitly requested.
- Real arrays remain arrays, retaining length, holes, own property metadata, Symbol keys and graph references.
- Native types reconstructed with appropriate internal state include `Map`, `Set`, `Date`, `RegExp` (including `lastIndex`), boxed primitives, `ArrayBuffer`, `SharedArrayBuffer` where available, `DataView`, supported typed arrays, `Blob`/`File` where available, `URL`, `URLSearchParams` and `Error`. Own user-defined properties are copied by the same descriptor/depth rules. Map keys/values and Set values participate in the graph.
- Typed arrays and DataViews preserve relative offsets and sharing of a cloned backing buffer. Array/string intrinsic index/length constraints are not overwritten with incompatible descriptors.
- Unsupported stateful objects (for example `Promise`, `WeakMap`, `WeakSet` or DOM objects) are preserved by reference by default or rejected under `clone.error`. A copied custom prototype does **not** imply that JavaScript private fields or unknown internal slots have been reconstructed: `clone.instance` is explicitly best-effort and callers must not assume it supports such classes.
- Clone operations do not modify the source graph. In value mode getters can execute user code, and host/native operations may raise their own exceptions; no claim of atomicity or a security boundary is made for hostile Proxy objects or accessors.

## Integration and verification

The current `lib/sys/js/core/modules-js.json` publishes `m.object.clone` for both browser classic JavaScript and independent CommonJS `jsc` outputs. Source implementation is `lib/sys/js/core/m/object/clone.js`.
Permanent behavior coverage is maintained by `rumiai-tests/tests/rumiai-os/js-core/.support/object-clone.mjs` through the actual `jsc` compiler.

This source fragment is part of the core descriptor and is not an independently imported `*.lib.js` library identity; no separate library operational manual is implied by this fragment.

## Invariants

```text
OBJECT-CLONE-01   source and depth/flags have the documented input and validation semantics
OBJECT-CLONE-02   ordinary graphs preserve own descriptors, string/Symbol keys, cycles and shared identity within selected depth
OBJECT-CLONE-03   native arrays and supported native objects have valid internal structure after cloning
OBJECT-CLONE-04   unknown instances/unsupported internal state never masquerade as complete clones by default
OBJECT-CLONE-05   new m.object.clone is independent of unchanged legacy utility/JSON clone implementations
```
