# RumiAI OS — Resource model

Date: 2026-09-14  
Status: **Current**

## 1. Scope

This specification defines the current distributed-resource model of RumiAI OS after the `2.0.0` freeze.

The model distinguishes:

- global resources owned by the technical `sys` layer;
- global resources owned by the branded `ai` layer;
- resources owned by managed packages;
- mutable state.

This specification does not introduce a universal resource resolver, resource URI, registry, daemon or resource manager.

---

## 2. Resource definition

A resource payload is distributed content with an owner that is required or usable at runtime, is not mutable application state and is not an entrypoint.

Possible examples include language catalogs, images, icons, templates, schemas or other static assets when a concrete use case requires them.

Classification as a resource is semantic. It does not automatically authorize new resource classes or new APIs.

Selectors co-located with resources, such as `lang/current`, are mutable selection metadata. Their mutability does not reclassify the selected payloads as state.

---

## 3. Global `res` root

The global semantic root for system resources is:

```text
$m_ROOT/res/
```

The bootstrap exposes:

```text
m_RES_DIR=$m_ROOT/res
```

Global resources are ownership-qualified:

```text
res/
├── sys/
└── ai/
```

`sys` identifies resources of the technical `m` substrate.

`ai` identifies resources of the branded RumiAI layer.

The existence of `res/ai` does not create a semantic dependency of `m` on RumiAI. The substrate may know the general resource-model shape without knowing or requiring specific branded content.

No additional global owners are defined by this specification.

---

## 4. Resource classes

A resource class is located under its owner:

```text
res/<owner>/<resource-class>/
```

This specification initially fixes exactly one concrete class:

```text
lang
```

No additional generic namespaces are introduced in anticipation of future classes.

The presence of `res` does not automatically authorize directories such as `icons`, `themes`, `templates`, `models` or equivalents: each class is materialized only when a concrete requirement exists.

---

## 5. Global language resources

The current layout is:

```text
res/
├── sys/
│   └── lang/
│       ├── en_US/
│       ├── it_IT/
│       └── current -> <locale>
└── ai/
    └── lang/
        ├── en_US/
        ├── it_IT/
        └── current -> <locale>
```

Each `res/<owner>/lang/<locale>/` directory declares that the owner supports that locale in its `lang` class.

A supported language catalog may be empty. Messages do not need to be invented merely to materialize a supported language.

`current` must be a relative symbolic link whose target is the leaf locale name selected within the same `lang/` tree.

All materialized global language trees under:

```text
res/*/lang/
```

participate in global selection and must have the same selected locale.

The distributed initial selection is:

```text
en_US
```

---

## 6. Technical `lang` interface

The existing `lang` shell interface remains a technical `m` facility.

The bootstrap keeps:

```text
m_LANG_DIR=$m_RES_DIR/sys/lang
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANGUAGE_FALLBACK=en_US
m_LANG_FALLBACK_DIR=$m_LANG_DIR/$m_LANGUAGE_FALLBACK
```

`m_LANG_DIR` is retained as the existing semantic interface for the technical `lang` facility; its new value does not establish a general environment-alias rule for every `res` subdirectory.

The technical function:

```text
lang <domain> <message-id>
```

resolves only the `sys` catalog.

It does not search `res/ai/lang`, merge owners or introduce cross-owner fallback.

A future branded consumer may read `ai` resources only when a concrete requirement and appropriate contract exist. This specification does not anticipate that API.

---

## 7. Global selection with `lang-set`

The public command remains:

```text
bin/sys/lang-set
```

and is implemented by the technical `m` layer.

### 7.1 Query

With zero arguments:

```text
lang-set
```

it returns only the locale name selected by the technical selector:

```text
res/sys/lang/current
```

followed by a newline.

Example:

```text
it_IT
```

The query does not list catalogs or return counts.

If the `sys` selector is not a valid relative symbolic link to an available locale in its own tree, the query fails. It does not present the fallback as if it were the current selection.

### 7.2 Selection

With one argument:

```text
lang-set <locale>
```

the command:

1. discovers materialized global language trees of the form `res/*/lang/`;
2. verifies before any mutation that `<locale>` exists in every participating tree;
3. verifies that every participating `current` selector is valid;
4. prepares the new relative selectors;
5. updates all participating selectors;
6. updates the `sys` selector last as the logical commit of the selection observed by zero-argument `lang-set`;
7. on an ordinary update error, attempts to restore the previous selectors.

If the requested language is missing from even one participating global owner, the operation fails without modifying any selector.

`lang-set` must not contain an explicit semantic dependency on the name `ai`: it operates on the general shape of global language trees under `m_RES_DIR`.

Updating multiple symlinks is not a crash-atomic filesystem transaction. The contract requires consistency after success and rollback for handled ordinary errors; it does not introduce a journal, generation directory, lock framework or transaction manager.

---

## 8. Package resources

Package resources belong to the package and remain in its managed tree/version.

They are not copied or projected automatically under:

```text
$m_RES_DIR
```

This also applies to package language catalogs.

`lang-set` does not visit, modify or synchronize package-internal selectors or configuration.

Package integration may configure upstream software to follow the global system language or use its own override when supported. Translation between the RumiAI locale and an upstream locale scheme belongs to the package-specific integration.

This rule does not introduce a generic `lang=` syntax or a new package-configuration primitive.

---

## 9. Separation from state

`res/` is not a state area.

State areas and the `state-path` resolver retain their current semantics.

Payloads under `res/` are distributed as part of the product; `current` selectors are selection metadata co-located with resources under the specific contract that defines them.

The resource model does not reopen the state model and does not introduce a second state resolver.

---

## 10. No universal resolver

The following are not introduced:

```text
resource-path
res-path
resource://
resource registry
resource daemon
resource manager
```

A consumer uses the semantic root or specific contract already relevant to its responsibility.

A new resolution primitive requires a concrete requirement not already covered by existing interfaces.

---

## 11. Invariants

```text
RES-01  the global resource semantic root is $m_ROOT/res and is exposed as m_RES_DIR
RES-02  global resources are ownership-qualified; current owners are sys and ai
RES-03  sys belongs to the technical m substrate; ai belongs to the branded RumiAI layer
RES-04  resource payloads and mutable state remain distinct concepts
RES-05  a co-located current selector does not turn the resource tree into state
RES-06  the first fixed global resource class is lang
RES-07  m_LANG_DIR remains the technical lang interface and equals $m_RES_DIR/sys/lang
RES-08  the technical lang facility resolves only sys resources and does not depend on ai
RES-09  res/*/lang/current selects the same locale in every materialized global language tree
RES-10  lang-set with no arguments returns only the locale selected by res/sys/lang/current
RES-11  lang-set validates all global language trees before mutation and updates sys last
RES-12  lang-set does not visit or modify package resources or package configuration
RES-13  package resources remain package-local and private to the package unless a future explicit contract says otherwise
RES-14  no universal resolver, URI, registry, daemon or resource manager is introduced
RES-15  multi-owner selection is semantically single but is not promised as a crash-atomic filesystem transaction
RES-16  en_US is the distributed initial global selection and remains the technical fallback
```
