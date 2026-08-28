# RumiAI OS — Phase 1 bootstrap environment

Status: **Accepted architecture**  
Date: 2026-08-28

## Purpose

Phase 1 begins immediately after phase 0 has established:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Its purpose is to initialize the smallest deterministic environment required to reach an internationalized logger without creating circular dependencies on the full configuration or package/runtime subsystems.

## Flow

```text
PHASE 0
    ↓
RumiAI_ROOT
    ↓
PHASE 1A — semantic roots
    RumiAI_BIN_DIR
    RumiAI_LIB_DIR
    RumiAI_CONF_DIR
    RumiAI_LANG_DIR
    ↓
PHASE 1B — command environment
    prepend RumiAI_BIN_DIR to PATH
    ↓
PHASE 1C — bootstrap interaction preferences
    conf/bootstrap/language
    conf/bootstrap/text-encoding
    host locale fallback for language
    ↓
PHASE 1D — i18n
    normalize language request
    resolve UTF-8 catalog
    guarantee en_US fallback
    normalize/fallback interaction encoding to UTF-8 when required
    prepare boundary transcoding if required
    ↓
PHASE 1E — logger
    initialize logger
    ↓
LOGGER ACTIVE
```

The labels 1A–1E describe dependency order and do not require separate product files or processes.

## Semantic roots

Current minimal roots:

```text
bin/   executable commands
lib/   sourced/imported implementation libraries
conf/  configuration
lang/  language/i18n catalogs
```

No `share/` or generic `resources/` root is created before a real cross-cutting resource category exists.

## PATH model

Only `bin/` participates in command lookup.

```text
RumiAI bin
    ↓
caller/host PATH
```

Libraries are loaded explicitly from `RumiAI_LIB_DIR`; data is loaded explicitly from its semantic root. This avoids implicit discovery and command/library namespace collisions.

## Bootstrap configuration model

The bootstrap must be able to initialize advanced infrastructure without already depending on that infrastructure.

The accepted first primitives are:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

They are minimal bootstrap data, not the final general configuration architecture and not sourced shell code.

Once the advanced configuration system is initialized, it may become authoritative and supersede bootstrap primitives according to:

```text
minimal primitive → initialize advanced subsystem → advanced subsystem authoritative
```

## Interaction language model

Canonical variable:

```text
RumiAI_LANGUAGE
```

Language/territory identity:

```text
language_TERRITORY
```

Examples:

```text
en_US
it_IT
```

Fallback input order:

```text
bootstrap config
LC_ALL
LC_MESSAGES
LANG
en_US
```

Host locale variables are input to language selection, not authoritative RumiAI state.

The i18n layer normalizes host locale syntax and avoids fatal failures whenever a usable English fallback exists.

## Text encoding model

Canonical user-interaction text-encoding variable:

```text
RumiAI_TEXT_ENCODING
```

The explicit bootstrap preference is read from:

```text
conf/bootstrap/text-encoding
```

Initial and guaranteed fallback value:

```text
UTF-8
```

The value is configurable at the interaction boundary so future implementations can support additional external encodings.

The internal RumiAI text model does not change with this setting:

```text
internal controlled text = UTF-8
internal control-plane language = English
```

User payloads may be in any language. Text entering RumiAI through a non-UTF-8 boundary is transcoded to UTF-8 before internal processing; UTF-8 internal text is transcoded to the configured external encoding only when leaving such a boundary.

## Catalog model

Language catalogs are always UTF-8 and are identified only by language/territory:

```text
lang/en_US/
lang/it_IT/
```

The codeset is not part of `RumiAI_LANGUAGE` and is not encoded in catalog directory names.

Rejected catalog identities include:

```text
lang/it_IT.UTF-8/
lang/it_IT/UTF-8/
```

Multiple external encodings MUST NOT require duplicate translation catalogs. Encoding adaptation belongs at the boundary.

This yields the architectural separation:

```text
language identity         RumiAI_LANGUAGE=it_IT
catalog representation    UTF-8
interaction encoding      RumiAI_TEXT_ENCODING=UTF-8 or future supported value
```

## Failure philosophy

The i18n path should minimize bootstrap-fatal conditions.

Missing requested language data normally falls back to `en_US`.

Missing, invalid or unsupported `conf/bootstrap/text-encoding` normally falls back to UTF-8 when the boundary remains usable in UTF-8, allowing the logger to report the degraded condition once active.
