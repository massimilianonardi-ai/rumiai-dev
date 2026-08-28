# RumiAI OS — Phase 1 bootstrap environment

Status: **Accepted architecture**  
Date: 2026-08-28

## Purpose

Phase 1 begins immediately after phase 0 has established:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Its purpose is to initialize the smallest deterministic environment required to reach an internationalized logger and public-command dispatch without creating circular dependencies on the full configuration or package/runtime subsystems.

## Flow

```text
PHASE 0
    ↓
RumiAI_ROOT
    ↓
PHASE 1A — semantic roots
    RumiAI_BIN_DIR
    RumiAI_COMMAND_DIR
    RumiAI_LIB_DIR
    RumiAI_CONF_DIR
    RumiAI_LANG_DIR
    ↓
PHASE 1B — command environment
    prepend RumiAI_BIN_DIR to PATH
    cmd remains outside PATH
    ↓
PHASE 1C — bootstrap interaction preferences
    conf/bootstrap/language
    conf/bootstrap/text-encoding
    host locale fallback for language
    ↓
PHASE 1D — i18n
    normalize language request
    select available language
    guarantee en_US fallback
    normalize/fallback interaction encoding to UTF-8
    ↓
PHASE 1E — logger
    initialize logger
    report non-fatal bootstrap fallback conditions
    ↓
LOGGER ACTIVE
    ↓
PHASE 1F — public command selection/dispatch
    rumiai-os <command> ...
    or multicall alias <command> ...
```

The labels describe dependency order and do not require separate product files or processes.

## Semantic roots

Current minimal roots:

```text
bin/   public command entrypoints participating in PATH
cmd/   private command implementations outside PATH
lib/   sourced/imported implementation libraries
conf/  configuration
lang/  language/i18n catalogs
```

Canonical variables:

```text
RumiAI_BIN_DIR     = $RumiAI_ROOT/bin
RumiAI_COMMAND_DIR = $RumiAI_ROOT/cmd
RumiAI_LIB_DIR     = $RumiAI_ROOT/lib
RumiAI_CONF_DIR    = $RumiAI_ROOT/conf
RumiAI_LANG_DIR    = $RumiAI_ROOT/lang
```

No `share/` or generic `resources/` root is created before a real cross-cutting resource category exists.

## PATH model

Only `bin/` participates in command lookup.

```text
RumiAI bin
    ↓
caller/host PATH
```

`cmd/` is intentionally outside `PATH`; the front controller dispatches private implementations through explicit pathnames derived from `RumiAI_COMMAND_DIR`.

Libraries are loaded explicitly from `RumiAI_LIB_DIR`; data is loaded explicitly from its semantic root.

## Bootstrap configuration model

The bootstrap must be able to initialize advanced infrastructure without already depending on that infrastructure.

Accepted primitives:

```text
conf/bootstrap/language
conf/bootstrap/text-encoding
```

They are minimal bootstrap data, not sourced shell code.

The initial reader treats them as one-value files. Missing configuration is not inherently an error. Invalid/unreadable explicit configuration should normally degrade to the defined fallback path and can be reported after logger activation.

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

Preference order:

```text
bootstrap config
LC_ALL
LC_MESSAGES
LANG
en_US
```

The i18n layer normalizes host locale syntax, strips host codeset/modifier information needed only for locale parsing, selects an available language catalog, and falls back to `en_US` when required.

## Text encoding model

Canonical user-interaction text-encoding variable:

```text
RumiAI_TEXT_ENCODING
```

Explicit preference:

```text
conf/bootstrap/text-encoding
```

Initial and guaranteed fallback value:

```text
UTF-8
```

The internal RumiAI text model remains UTF-8 regardless of this interaction-boundary setting.

## Catalog model

Language catalogs are always UTF-8 and are identified only by language/territory:

```text
lang/en_US/
lang/it_IT/
```

The codeset is not part of `RumiAI_LANGUAGE` and is not encoded in catalog directory names.

## Multicall/public command direction

Public `bin/<command>` entries may be symbolic links to `../rumiai-os`.

Both forms converge to the same command identity:

```text
log warn ...
rumiai-os log warn ...
```

An external symlink/alias may live outside `RumiAI_ROOT`. Its physical location does not define the RumiAI root: phase 0 canonicalizes the symlink target and derives `RumiAI_ROOT` from the physical `rumiai-os` target.

For an alias basename to be accepted as a RumiAI multicall command, a corresponding official:

```text
$RumiAI_BIN_DIR/<basename>
```

must exist and canonicalize to the same `RumiAI_BOOTSTRAP_BIN`.

This permits external installation aliases while preventing arbitrary unregistered basenames from becoming RumiAI commands.

## Failure philosophy

Missing requested language data normally falls back to `en_US`.

Missing, invalid or unsupported text-encoding configuration normally falls back to UTF-8 when the boundary remains usable in UTF-8.

Shared front-controller failures use exact stable numeric statuses. The current accepted pre-stability sequence begins at `1` and is append-only; command-local status mapping remains a separate contract to finalize before public CLI stabilization.
