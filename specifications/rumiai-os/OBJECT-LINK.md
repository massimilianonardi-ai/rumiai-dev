# m — JavaScript read-through object linking

Status: **Current / normative**
Updated: 2026-10-16

## Responsibility and public interfaces

The `m` JavaScript core exports:

```javascript
m.object.linkProperty(source, target, property, renamed)
m.object.link(source, target, property, renamed, deep, arrays)
```

These interfaces create **read-through links with write detachment**: reading a linked property consults its source at read time; writing the linked property on the receiver converts it into an ordinary own writable, enumerable, configurable value property. The source is never assigned by the link's setter. This is not two-way binding, generic object merging, cloning, or deep copy-on-write.

Existing `m.util.link`, `m.util.linkProperty` and non-exported `m/json/link.js` remain unchanged and independent. The historical incomplete bulk/deep dispatch and unconditional `console.log` calls are not reproduced.

Both source and target must be non-null objects or functions; the two required positional arguments cannot be omitted. Property names and optional renames are strings or Symbols; source properties need not exist when the link is installed. The operation mutates and returns `target`. A target's existing configurable property may be replaced by a link; non-configurable collisions raise an exception.

## Single-property link

`linkProperty(source, target, property[, renamed])` installs one accessor on `target[renamed ?? property]`. Getters consult `source[property]` (including inherited/accessor properties and future source assignments) on every read. The first target assignment detaches the property; later changes to the source no longer alter the detached value.

When a linked accessor is inherited by another receiver, assignment detaches that receiver only; the original target remains linked. Directly linking a property to itself on the same source/target object is rejected to avoid infinite recursive reads. Linking different names on the same object is allowed.

## Bulk and historical overloads

`link` accepts the following call forms:

```javascript
link(source, target)
link(source, target, deep, arrays)
link(source, target, property)
link(source, target, property, renamed)
link(source, target, property, deep, arrays)
link(source, target, property, renamed, deep, arrays)
```

`deep` and `arrays` default to `false`; Boolean values may be omitted at their trailing positions. An explicit property name takes precedence over the bulk signature. `renamed` is available only when a specific property is selected. Invalid shapes or types throw.

Bulk selection enumerates own and inherited **enumerable string and Symbol properties** at link time. The selected key set is a snapshot, not a live enumeration of new keys, but each read of an individual linked property remains live. `link(source,target)` links each selected key directly using the same mechanism as `linkProperty`. Bulk linking an object to itself is rejected.

## Deep linking and arrays

With `deep=true`, a traversed **data property** whose value is a plain object is represented on the destination by a fresh container mirroring that object's original prototype. Its enumerable properties are then linked in the same fashion. Repeated object identities and cycles encountered during this structural traversal map to the same destination containers; traversal is iterative.

With `arrays=true`, ordinary arrays may likewise become real array containers with corresponding indices, original length, holes and nested links. Without `arrays=true`, arrays are linked as whole values and remain shared until their parent property is detached. Functions, custom instances, native objects and accessor-valued properties are linked as **leaf references**, not recursively reconstructed. A single property may be renamed while constructing a deep destination container.

**Structural snapshot limitation:** deep mode mirrors the reachable object/array property layout *at the time of linking*. Reading linked leaves remains dynamic against the corresponding original source node, but replacing an entire source subtree or adding/removing keys later does **not** rebuild previously created destination containers. Assigning to a nested linked leaf detaches that leaf; assigning to a whole deep container property replaces the destination container without modifying the source. A shallow linked object property is still a shared reference, so mutating the referenced nested object can mutate the source.

Deep linking does not provide a proxy, automatic array-length synchronization, atomic changes, property-descriptor preservation of source values, or isolated deep-copy semantics.

## Ownership, safety and validation

Each installed link is an own accessor defined via `Object.defineProperty`, including for keys such as `__proto__`: it does not assign through inherited setters or modify the target's prototype. Symbols and inherited enumerable keys are deliberate inputs to the bulk link. User-defined getters and Proxy traps may execute on subsequent reads or during deep structural observation; the link operation makes no security-boundary guarantee for hostile objects.

Implementation: `rumiai-os/lib/sys/js/core/m/object/link.js`, included and exported by `lib/sys/js/core/modules-js.json`. It is a `jsc` source fragment, not a separate `*.lib.js` library identity. Permanent tests: `rumiai-tests/tests/rumiai-os/js-core/.support/object-link.mjs` exercised via the real `jsc` assembly and the browser/Chrome core suite.

## Invariants

```text
OBJECT-LINK-01  read-through getters observe current source values until individual receiver write detaches
OBJECT-LINK-02  bulk/property/renamed and Boolean deep/arrays overloads have documented meanings
OBJECT-LINK-03  deep links construct separate plain-object/array shells and preserve shared/cyclic identities
OBJECT-LINK-04  own accessor definition avoids inherited setter and __proto__ prototype mutations
OBJECT-LINK-05  old utility and private JSON implementations remain unchanged and separately exported as before
```
