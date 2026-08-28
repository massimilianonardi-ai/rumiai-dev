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

Contains RumiAI language/i18n data. It is distinct from the i18n implementation code, which belongs under `RumiAI_LIB_DIR`.

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

---

## 6. RumiAI language selection

The canonical variable representing the language selected for RumiAI is:

```text
RumiAI_LANGUAGE
```

The preferred RumiAI language identifier currently preserves language and territory using the form:

```text
language_TERRITORY
```

Examples:

```text
en_US
it_IT
```

The role of a codeset/encoding component such as `.UTF-8` is intentionally **open** until the i18n encoding contract is decided.

### Selection precedence

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

The final guaranteed fallback is:

```text
en_US
```

because the bootstrap must retain a usable technological lingua franca even when the requested or host language cannot be loaded.

---

## 7. i18n responsibility

The i18n module, not the pre-i18n bootstrap, owns normalization and catalog resolution.

This includes, as required by the final encoding decision:

```text
host locale parsing
language/territory normalization
codeset/encoding normalization
catalog lookup
fallback from specific to less-specific language data
fallback to en_US
```

The pre-i18n bootstrap SHOULD pass the selected/requested value with minimal interpretation.

The i18n subsystem SHOULD have as few fatal initialization errors as possible. Missing or unsupported requested language data SHOULD normally fall back rather than terminate bootstrap when an English catalog remains available.

---

## 8. Logger boundary

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
i18n initialization
    ↓
logger initialization
    ↓
LOGGER ACTIVE
```

After the logger becomes active, normal RumiAI diagnostics SHOULD be routed through it rather than printed directly by bootstrap code.

The exact logger API, catalog format and encoding model are outside this specification and remain the next design step.
