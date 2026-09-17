# RumiAI OS — Language bootstrap (`lang`)

Date: 2026-09-14  
Status: **Current**

## 1. Scope

This specification defines the bootstrap/runtime contract for `m` technical text localization and global language selection.

The general resource layout is defined by:

```text
specifications/rumiai-os/RESOURCE-MODEL.md
```

The technical facility remains named:

```text
lang
```

The previous `i18n` name is superseded.

---

## 2. Environment

The bootstrap exposes:

```text
m_RES_DIR=$m_ROOT/res
m_LANG_DIR=$m_RES_DIR/sys/lang
m_LANGUAGE_FALLBACK=en_US
m_TEXT_ENCODING=UTF-8
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANG_FALLBACK_DIR=$m_LANG_DIR/$m_LANGUAGE_FALLBACK
```

`m_RES_DIR` is the top-level semantic root of global resources.

`m_LANG_DIR` remains the existing semantic interface of the technical `lang` facility and identifies only the `sys` owner catalog.

These variables are derived from `m_ROOT` and remain relocatable.

---

## 3. Technical catalogs

The canonical technical-catalog layout is:

```text
$res = $m_RES_DIR

$res/sys/lang/<locale>/<domain>/<message-id>
```

Example:

```text
res/sys/lang/en_US/filesystem/path-invalid
res/sys/lang/it_IT/filesystem/path-invalid
```

Each message file contains UTF-8 text treated exclusively as data.

Catalog content is not evaluated as shell code.

`<domain>` and `<message-id>` must satisfy the current `lang` function contract: non-empty components using only `a-z`, `0-9`, `.`, `_`, `-`, not starting with separators and not ending in `.`, `_` or `-`.

---

## 4. Branded catalogs

Language resources for the branded layer are separate:

```text
$res/ai/lang/<locale>/...
```

Participation of `res/ai/lang` in global selection does not transfer those catalogs into the technical `lang` facility.

The `m` shell function `lang` does not resolve `ai` and does not merge or fall back across owners.

A locale supported by an owner may have an empty catalog.

---

## 5. `current` selector

Every materialized global language tree under:

```text
$res/*/lang/
```

contains:

```text
current -> <locale>
```

`current` must be a relative symbolic link to an available local directory in the same language tree.

The distributed baseline uses:

```text
res/sys/lang/current -> en_US
res/ai/lang/current  -> en_US
```

All materialized global selectors must represent the same locale.

Co-locating the mutable selector with catalogs does not reclassify the catalogs as state.

---

## 6. Technical `lang` resolver

The function:

```text
lang <domain> <message-id>
```

uses only the technical tree identified by `m_LANG_DIR`.

Lookup order remains:

1. selected-language catalog:

   ```text
   $m_LANG_CURRENT_DIR/<domain>/<message-id>
   ```

2. technical fallback catalog:

   ```text
   $m_LANG_FALLBACK_DIR/<domain>/<message-id>
   ```

3. identifier fallback:

   ```text
   <domain>.<message-id>
   ```

Global selection and fallback are distinct concepts: `current` expresses the configured language, while `en_US` remains the lookup fallback when a message is absent from the selected catalog.

The public command:

```text
bin/sys/lang <domain> <message-id>
```

delegates to the shell `lang` facility through the normal `m` integrated-command model.

---

## 7. `lang-set` — query

The public command is:

```text
bin/sys/lang-set
```

With zero arguments:

```text
lang-set
```

it returns only the locale selected by:

```text
$m_RES_DIR/sys/lang/current
```

followed by a newline.

Example:

```text
it_IT
```

It does not return a locale list, message counts or table prefixes.

The query requires the `sys` selector to be a valid relative symbolic link to an available locale in the same tree. A missing, non-symlink, broken or out-of-tree selector is an error and is not implicitly replaced by the fallback.

---

## 8. `lang-set` — selection

With exactly one argument:

```text
lang-set <locale>
```

the command operates on materialized global language trees of the form:

```text
$m_RES_DIR/*/lang
```

The contract is:

1. at least the technical `$m_LANG_DIR` tree must exist;
2. `<locale>` must correspond to an available local directory in every participating language tree;
3. every existing `current` selector must be a valid relative symbolic link to an available locale in the same tree;
4. all validation occurs before any selector is changed;
5. new selectors are relative symbolic links whose target is exactly `<locale>`;
6. non-`sys` trees are updated before the `sys` tree;
7. the `sys` tree is updated last as the logical commit of the selection observed by the query;
8. if an ordinary error interrupts the update, the command attempts to restore all selectors to the previous selection;
9. on success the command produces no output.

If `<locale>` is missing from even one participating language tree, the command fails without mutation.

The command does not encode the name `ai`: synchronization uses the general language-tree shape under `m_RES_DIR` and therefore does not create a semantic `m -> RumiAI` dependency.

The multi-owner operation does not promise filesystem crash atomicity. It introduces no journal, generation directory, lock framework or transaction manager.

---

## 9. Packages

`lang-set` does not visit `$m_PKG_DIR` and does not modify package resource trees, selectors or configuration.

Each package keeps its resources, including any language catalogs, inside its managed tree/version.

A package-specific integration may configure upstream software to follow the global language or use its own override. Any mapping between RumiAI locale and upstream locale belongs to that specific integration.

No universal package-language API is introduced.

---

## 10. Error handling

Behavior remains consistent with the current logging/fatal model:

- invalid argument count: fatal `execution.invalid-arguments`;
- requested locale unavailable in all participating trees: fatal `execution.invalid-arguments`, with the requested locale as a field when applicable;
- structurally invalid selector or path: fatal `filesystem.path-invalid`;
- operational error during preparation, update or rollback: fatal `execution.execution-failed` when the normal logging path is available.

The command must not overwrite non-symlink objects located at the `current` pathname.

---

## 11. Invariants

```text
LANG-01  m_LANGUAGE_FALLBACK remains en_US
LANG-02  m_TEXT_ENCODING remains UTF-8
LANG-03  m_LANG_DIR equals $m_RES_DIR/sys/lang
LANG-04  m_LANG_CURRENT_DIR equals $m_LANG_DIR/current
LANG-05  m_LANG_FALLBACK_DIR equals $m_LANG_DIR/en_US
LANG-06  lang resolves selected -> fallback -> domain.message-id within the sys owner only
LANG-07  catalog content is data and is not executed as shell code
LANG-08  res/*/lang/current is a relative symlink to an available locale in the same tree
LANG-09  all materialized global lang selectors represent the same locale
LANG-10  lang-set with no arguments returns only the locale selected by sys/current
LANG-11  lang-set with a locale pre-validates all participating trees before mutation
LANG-12  lang-set updates sys last and attempts rollback for handled ordinary errors
LANG-13  lang-set does not modify package resources or package configuration
LANG-14  m has no semantic dependency on the ai catalog
LANG-15  the distributed initial selection is en_US
```
