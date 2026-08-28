# RumiAI OS — Minimal Bootstrap Environment

Status: **Normative specification**  
Date: 2026-08-28

## 1. Scope

This specification defines the minimal environment initialized immediately after phase 0 and before the full RumiAI configuration system, i18n subsystem and logger are available.

Its purpose is to break bootstrap dependency cycles by establishing only the primitives required to locate and initialize more advanced subsystems.

Normative baseline:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

---

## 2. Bootstrap progression principle

RumiAI MAY use a minimal bootstrap primitive when the advanced subsystem that will eventually own the same responsibility cannot yet be initialized without that primitive.

The intended progression is:

```text
minimal bootstrap primitive
        ↓
advanced subsystem initialization
        ↓
advanced subsystem becomes authoritative
```

The bootstrap primitive MUST remain narrowly scoped and MUST NOT grow into a second competing implementation of the advanced subsystem.

This principle applies initially to bootstrap configuration and internationalization selection.

---

## 3. Fundamental directories

Immediately after successful phase 0, the bootstrap environment defines exactly the following current directory roots:

```sh
RumiAI_BIN_DIR=$RumiAI_ROOT/bin
RumiAI_LIB_DIR=$RumiAI_ROOT/lib
RumiAI_CONF_DIR=$RumiAI_ROOT/conf
RumiAI_LANG_DIR=$RumiAI_ROOT/lang
```

### `RumiAI_BIN_DIR`

Contains RumiAI executable commands intended to participate in command lookup.

### `RumiAI_LIB_DIR`

Contains sourced/imported bootstrap and runtime libraries. Libraries MUST be loaded using explicit pathnames derived from `RumiAI_LIB_DIR`; they are not discovered through `PATH`.

### `RumiAI_CONF_DIR`

Contains RumiAI configuration data. The bootstrap subset is located beneath:

```text
$RumiAI_CONF_DIR/bootstrap/
```

### `RumiAI_LANG_DIR`

Contains RumiAI language/i18n catalogs. Catalog identity is based on language/territory, not output text encoding.

Canonical shape:

```text
$RumiAI_LANG_DIR/en_US/
$RumiAI_LANG_DIR/it_IT/
```

All RumiAI-controlled language catalogs are encoded in UTF-8.

No generic `share/` or `resources/` directory is introduced at this stage. Such a directory may be introduced only if a concrete future requirement establishes a useful common semantic category.

The four directory variables SHOULD be exported if child processes initialized during bootstrap require the same semantic roots, and SHOULD be marked readonly after their values are successfully established.

---

## 4. PATH initialization

RumiAI commands take precedence over the inherited host/caller path while preserving the inherited path as fallback.

Required conceptual form:

```sh
PATH=$RumiAI_BIN_DIR${PATH:+:$PATH}
export PATH
```

Only executable-command directories belong in this bootstrap `PATH` construction.

The following MUST NOT be added merely to make sourcing/discovery convenient:

```text
$RumiAI_LIB_DIR
$RumiAI_CONF_DIR
$RumiAI_LANG_DIR
```

Libraries and data are addressed explicitly through their semantic roots.

When bootstrap code explicitly requires a standard POSIX utility rather than a RumiAI command or caller override, it MAY use `command -p` according to the existing POSIX/tool contract.

---

## 5. Minimal bootstrap configuration

The bootstrap MUST NOT require the advanced RumiAI configuration subsystem merely to obtain the information needed to initialize that subsystem and the logger.

The initial language preference is stored, when explicitly configured, at:

```text
$RumiAI_CONF_DIR/bootstrap/language
```

This file is bootstrap data, not shell code. It MUST NOT be sourced as executable shell configuration.

The initial implementation SHOULD keep the file format deliberately minimal: a single language/locale preference value after the bootstrap reader's defined whitespace/line handling rules are established.

The full configuration subsystem may later supersede this primitive after it becomes available.

The exact bootstrap configuration source/path for the user-interaction text encoding remains to be specified before phase-1 product implementation. This does not change the accepted runtime variable or encoding model below.

---

## 6. Language and interaction encoding

### `RumiAI_LANGUAGE`

The canonical variable representing the selected user-interaction language is:

```text
RumiAI_LANGUAGE
```

Its canonical identity preserves language and territory using:

```text
language_TERRITORY
```

Examples:

```text
en_US
it_IT
```

A codeset suffix MUST NOT be appended to `RumiAI_LANGUAGE`.

### `RumiAI_TEXT_ENCODING`

The canonical variable representing the text encoding requested at the user-interaction boundary is:

```text
RumiAI_TEXT_ENCODING
```

The only encoding implemented initially is:

```text
UTF-8
```

`RumiAI_TEXT_ENCODING` is intentionally configurable so later implementations may support additional external encodings without changing the internal RumiAI text model.

The guaranteed bootstrap/default fallback is UTF-8.

### Internal text invariant

RumiAI-controlled internal text uses UTF-8.

The RumiAI control plane uses English identifiers/messages and UTF-8 as its canonical internal representation. User payloads and external data may contain any language; when represented as internal text they are normalized to UTF-8 rather than changing the system's internal encoding.

---

## 7. Language selection

The bootstrap/i18n initialization SHOULD resolve the requested language in this order:

```text
1. $RumiAI_CONF_DIR/bootstrap/language
2. host LC_ALL
3. host LC_MESSAGES
4. host LANG
5. RumiAI fallback en_US
```

The host locale variables are fallback input; they are not themselves the RumiAI language contract.

RumiAI MUST NOT needlessly overwrite the host's `LANG`, `LC_ALL`, or `LC_MESSAGES` merely to record its own selected language.

The final guaranteed language fallback is:

```text
en_US
```

The final guaranteed text-encoding fallback is:

```text
UTF-8
```

---

## 8. Catalog and transcoding model

Language catalogs are always stored in UTF-8 and are selected only by language identity.

Canonical catalog path shape:

```text
$RumiAI_LANG_DIR/$RumiAI_LANGUAGE/
```

Examples:

```text
lang/en_US/
lang/it_IT/
```

The following forms are NOT part of the catalog identity:

```text
lang/it_IT.UTF-8/
lang/it_IT/UTF-8/
```

RumiAI MUST NOT duplicate the same translation catalog merely to materialize different output encodings.

Encoding conversion belongs at the interaction boundary:

```text
external/user text in configured encoding
        ↓ decode/transcode
internal UTF-8
        ↓ RumiAI processing / catalog rendering
internal UTF-8
        ↓ encode/transcode
external/user text in RumiAI_TEXT_ENCODING
```

When `RumiAI_TEXT_ENCODING=UTF-8`, no transcoding is required.

Additional encodings may be implemented later through boundary adapters/transcoders while catalogs and internal RumiAI-controlled text remain UTF-8.

---

## 9. i18n responsibility

The i18n module, not the pre-i18n bootstrap, owns normalization and catalog resolution.

Its responsibilities include as needed:

```text
host locale parsing
language/territory normalization
catalog lookup
fallback from requested language to en_US
boundary encoding normalization
selection of an available transcoder/adapter
```

The pre-i18n bootstrap SHOULD pass requested/fallback values with minimal interpretation.

The i18n subsystem SHOULD have as few fatal initialization errors as possible. Missing requested language data SHOULD normally fall back to `en_US` when the English catalog is available. Missing support for a requested external text encoding SHOULD normally fall back to UTF-8 when the interaction boundary remains usable in UTF-8, and the condition can be reported after the logger becomes active.

---

## 10. Logger boundary

The intended startup order is:

```text
phase 0
    ↓
fundamental directories
    ↓
PATH
    ↓
minimal bootstrap language preference
    ↓
RumiAI_LANGUAGE + RumiAI_TEXT_ENCODING
    ↓
i18n initialization
    ↓
logger initialization
    ↓
LOGGER ACTIVE
```

After the logger becomes active, normal RumiAI diagnostics SHOULD be routed through it rather than printed directly by bootstrap code.

The exact logger API and catalog file format remain separate design work; the language/catalog encoding model is fixed by this specification.
