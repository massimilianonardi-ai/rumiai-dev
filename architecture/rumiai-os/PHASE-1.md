# RumiAI OS — Phase 1 bootstrap environment

Status: **Accepted architecture, encoding detail open**  
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
PHASE 1C — bootstrap language preference
    conf/bootstrap/language
    or host locale fallback
    ↓
PHASE 1D — i18n
    normalize request
    resolve catalog
    guarantee en_US fallback
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
lang/  language/i18n data
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

The first concrete example is:

```text
conf/bootstrap/language
```

This is a minimal bootstrap primitive, not the final general configuration architecture.

Once the advanced configuration system is initialized, it may become authoritative and supersede the primitive according to the general progression:

```text
minimal primitive → initialize advanced subsystem → advanced subsystem authoritative
```

## Language model

Canonical RumiAI variable:

```text
RumiAI_LANGUAGE
```

Current language/territory identity:

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

Host locale variables are input to language selection, not the authoritative RumiAI language state.

The i18n layer should normalize host locale syntax and avoid fatal failures whenever a usable English fallback exists.

## Open encoding decision

The architecture deliberately does not yet decide whether language catalog pathnames and/or `RumiAI_LANGUAGE` include a codeset suffix.

The open alternatives include at least:

```text
lang/it_IT/
lang/it_IT.UTF-8/
```

and the deeper question is whether RumiAI supports multiple catalog encodings or standardizes its own controlled text resources on one encoding while treating host locale codesets only as input metadata.

This issue must be resolved before the concrete i18n catalog layout and implementation are frozen.
