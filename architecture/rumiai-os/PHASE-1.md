# RumiAI OS — Phase 1 bootstrap environment

Status: **Accepted architecture**  
Date: 2026-08-28

## Purpose

Phase 1 begins immediately after phase 0 has established:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

Its purpose is to initialize the smallest deterministic environment required to reach an internationalized logger and then execute a RumiAI command file through the active `rumiai-os` interpreter.

## Flow

```text
COMMAND FILE
    #!/usr/bin/env rumiai-os
    ↓
PATH selects active rumiai-os
    ↓
PHASE 0
    RumiAI_BOOTSTRAP_BIN
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
PHASE 1F — command interpreter
    canonicalize command-file operand
    validate RumiAI command shebang
    expose RumiAI_COMMAND_BIN
    remove command-file operand from "$@"
    source command file in-process
    propagate command status
```

The labels describe dependency order and do not require separate product files or processes.

## Semantic roots

Current minimal roots:

```text
bin/   executable commands intended for PATH
lib/   sourced/imported implementation libraries
conf/  configuration
lang/  language/i18n catalogs
```

Canonical variables:

```text
RumiAI_BIN_DIR  = $RumiAI_ROOT/bin
RumiAI_LIB_DIR  = $RumiAI_ROOT/lib
RumiAI_CONF_DIR = $RumiAI_ROOT/conf
RumiAI_LANG_DIR = $RumiAI_ROOT/lang
```

`cmd/` and `RumiAI_COMMAND_DIR` are no longer part of the accepted architecture. The command file is its own implementation entrypoint.

No `share/` or generic `resources/` root is created before a real cross-cutting resource category exists.

## PATH model

`RumiAI_BIN_DIR` is prepended to the inherited `PATH` after bootstrap:

```text
RumiAI bin
    ↓
caller/host PATH
```

Libraries are loaded explicitly from `RumiAI_LIB_DIR`; data is loaded explicitly from its semantic root.

The command-interpreter model has one additional pre-bootstrap requirement: the caller environment must already be able to resolve an executable named:

```text
rumiai-os
```

through `PATH`, because `/usr/bin/env` must find the interpreter before RumiAI itself starts.

How an installation or activation process exposes `rumiai-os` in the caller's `PATH` is a separate installation/environment concern and is not solved by phase 1 itself.

## Command entrypoint model

Canonical first line:

```text
#!/usr/bin/env rumiai-os
```

A command file contains its own POSIX shell implementation body.

Example:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

The host passes the command-file pathname to the active `rumiai-os` runtime. After phase 1 initializes i18n and the logger, the runtime canonicalizes the command file, removes its pathname from the positional arguments, and sources the file in the initialized shell.

This gives the command direct access to bootstrap state and sourced libraries without a second bootstrap or an implementation shadow tree.

Canonical command pathname variable:

```text
RumiAI_COMMAND_BIN
```

`RumiAI_COMMAND_BIN` is the absolute physical/canonical pathname of the command file being interpreted.

## Host-profile extension

The command-entry mechanism intentionally relies on behavior outside the abstract POSIX.1-2024 guarantee.

RumiAI therefore requires reference hosts to provide and validate:

```text
/usr/bin/env
executable #! scripts
PATH-based resolution of rumiai-os
command-file pathname forwarded to rumiai-os
source-compatible treatment of the initial #! line by the reference /bin/sh
```

POSIX remains the contract for the shell code and standard utilities used after the runtime has started; the shebang/interpreter bootstrap is an explicit documented host-profile extension.

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

## Command aliases and duplicate names

Because the command-file pathname is passed to the interpreter, routing does not depend on a global basename registry.

These can coexist:

```text
package-a/bin/foo
package-b/bin/foo
```

A renamed symlink may point to a command file:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

The runtime canonicalizes the command-file pathname, so the external alias name does not determine the implementation.

## Active runtime semantics

The active interpreter is the `rumiai-os` selected by the inherited `PATH`.

A command file physically belonging to one installation may therefore be interpreted by another active runtime if the environment's `PATH` selects it.

This is intentional. Runtime/version/capability compatibility checks are deferred until a concrete requirement emerges.

## Failure philosophy

Missing requested language data normally falls back to `en_US`.

Missing, invalid or unsupported text-encoding configuration normally falls back to UTF-8 when the boundary remains usable in UTF-8.

Shared bootstrap failures use exact stable numeric statuses. The accepted pre-stability phase-0 sequence is:

```text
1  PATH resolution failure
2  realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
```

The current command-interpreter draft tentatively continues with i18n/logger load and command-entry errors. Final external command status mapping remains to be consolidated before public CLI stabilization.
