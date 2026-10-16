# m — JavaScript object merge

Status: **Current / normative**
Updated: 2026-10-16

## Interface and responsibility

The JavaScript core exports `m.object.merge(target, source, levelMerge, levelCopy, append, instances)`. It combines own properties of compatible objects in place and replaces incompatible branches with depth-controlled copies. The new API is independent of the existing `m.util.merge` and non-exported JSON merge sources, which remain unchanged.

No native JavaScript operation has this full contract. `Object.assign` and object spread perform shallow property copying; `structuredClone` copies data but does not merge into an existing object.

Both first arguments are required. A compatible target is mutated and returned. Otherwise the operation returns a replacement (or a shared source reference for opaque types under the clone fallback). This operation is **not atomic**: a later error does not undo earlier writes.

## Depths

`levelMerge` and `levelCopy` are independent, default to `0`, accept `false` for zero, `true` or `Infinity` for unlimited depth, and floor nonnegative numbers. Other inputs fail with `TypeError`.

- `levelMerge=0` merges the root's own enumerable properties only. Child branches are replaced, not recursively merged.
- Larger `levelMerge` values allow further merging when both sides have compatible object shapes.
- `levelCopy=0` clones only the root of each replaced object branch; its deeper values remain references. Positive values allow a corresponding number of additional copied edges. `true` requests unbounded replacement copying.
- Scalar values replace the corresponding property directly.

Identity tracking maps each source node to one output node, preserving cycles and shared references among copied plain objects/arrays and merged nodes, including when branches initially target missing properties. Where a source node appears along multiple paths with different destination candidates, its first encountered pairing determines identity; it is not merged into multiple distinct targets.

## Object, array and instance policies

Plain objects (including null-prototype objects) merge by own enumerable string and Symbol keys. Inherited keys are never enumerated or mutated.

`append` and `instances` may be omitted, `null`, or Boolean; any other type raises `TypeError`.

- When both sides are arrays, `append=true` appends indexed entries, preserving holes. `append=false` merges by index, extending but not truncating the target. Otherwise, arrays are replaced by a copied array. Existing extra enumerable keys of an array participate in the indexed merge policy but not the append policy.
- `instances=true` opts into own-property merge of ordinary custom-class instances and best-effort cloning of replacement instances. Otherwise custom instances remain opaque under the `m.object.clone` default. Class private fields and arbitrary native/internal slots cannot be reconstructed generically.
- A root function target can merge enumerable properties from a function or plain-object source while retaining its function identity. Nested function values are shared.

## Descriptor, native and security rules

In merge mode, values of source own enumerable properties are read, including accessors (which may execute getter code). Target properties are defined through own descriptors, not inherited setters; existing non-writable/non-configurable restrictions are respected. `__proto__` and `constructor` are treated as ordinary own keys and cannot mutate inherited prototype state by assignment.

Replacement branches of plain objects, arrays and opted-in custom instances retain own property descriptors, non-enumerables, Symbols, accessors, array holes and length. Unsupported/native replacement types delegate to `m.object.clone` with the chosen copy depth and its native fallback policy. Distinct native container replacement branches do not guarantee global cross-container alias preservation. There is no security boundary for hostile proxies or user-defined getters.

## Integration and invariants

The implementation is `lib/sys/js/core/m/object/merge.js` published by `core/modules-js.json`; this is a `jsc` source fragment, not a standalone `*.lib.js` library. Permanent validation is in `rumiai-tests/tests/rumiai-os/js-core/.support/object-merge.mjs`, which invokes the real `jsc` compiler.

```text
OBJECT-MERGE-01  signature and merge/copy depths remain independently configurable
OBJECT-MERGE-02  compatible roots mutate their target; replacements follow the selected copy policy
OBJECT-MERGE-03  own-property traversal prevents inherited and __proto__ prototype pollution
OBJECT-MERGE-04  ordinary object graphs preserve cycles/aliases and native arrays remain arrays
OBJECT-MERGE-05  existing merge implementations and exports remain unchanged
```
