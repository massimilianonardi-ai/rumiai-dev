# RumiAI OS — Phase 1 runtime environment

Status: **Accepted architecture**  
Date: 2026-08-28  
Updated: 2026-09-02

## Purpose

Phase 1 begins after Phase 0 has established:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

Its purpose is to expose the relocatable RumiAI runtime environment, initialize language and logging primitives, then either interpret a RumiAI command file or enter the interactive RumiAI shell.

## Flow

```text
PHASE 0
    m_BOOTSTRAP_BIN
    m_ROOT
    ↓
PHASE 1A — semantic roots
    bin / lib / conf / lang
    ↓
PHASE 1B — executable PATH
    bin/sys-osarch
    bin/sys
    bin/ext-osarch
    bin/ext
    inherited host PATH
    ↓
PHASE 1C — language runtime
    lang/current
    fallback lang/en_US
    UTF-8 fixed
    ↓
PHASE 1D — logger
    log
    ↓
PHASE 1E — dispatch
    no operands → interactive shell
    operands    → command/source entry
```

## Environment-variable namespace

RumiAI-owned environment variables use:

```text
m_*
```

This convention applies only to environment variables.

## Semantic roots

Current roots include:

```text
m_BIN_DIR=$m_ROOT/bin
m_LIB_DIR=$m_ROOT/lib
m_CONF_DIR=$m_ROOT/conf
m_LANG_DIR=$m_ROOT/lang
```

`bin/` is a container for executable directories; it is not itself inserted in `PATH`.

## Executable layout

Canonical classes:

```text
bin/sys/             RumiAI, platform-independent
bin/sys-<osarch>/    RumiAI, platform-specific
bin/sys-osarch       symlink to active sys-<osarch>

bin/ext/             third-party, platform-independent
bin/ext-<osarch>/    third-party, platform-specific
bin/ext-osarch       symlink to active ext-<osarch>
```

The platform-link update mechanism is intentionally not part of the bootstrap contract yet.

## PATH model

Exact precedence:

```text
m_BIN_SYS_OSARCH_DIR
m_BIN_SYS_DIR
m_BIN_EXT_OSARCH_DIR
m_BIN_EXT_DIR
inherited PATH
```

This allows RumiAI system commands to take precedence over bundled third-party commands and the host environment while retaining host tools as fallback.

## Language model

The bootstrap no longer reads language or text-encoding preference files and does not derive the RumiAI language from host locale variables.

Current language selection is the relative symlink:

```text
lang/current -> <language_TERRITORY>
```

Fallback:

```text
lang/en_US
```

Encoding:

```text
UTF-8
```

The bootstrap resolver/API name is `lang`; `i18n` is superseded terminology.

## Runtime exposure for command shebangs

Direct RumiAI command files retain:

```text
#!/usr/bin/env rumiai-os
```

The portable/activated runtime exposes itself through:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

Because `bin/sys` participates in the RumiAI `PATH`, `/usr/bin/env rumiai-os` can resolve the active portable runtime without mandatory host integration.

This symlink is runtime exposure only and is not multicall routing.

## Command entry

With one or more operands, the first operand is resolved/canonicalized as an existing readable regular file, exposed as:

```text
m_COMMAND_BIN
```

removed from `$@`, then sourced in-process. The command body therefore has access to the functions initialized in the bootstrap process and observes only its own arguments in `$@`.

## Interactive shell

With no operands, RumiAI launches:

```text
$SHELL
```

when it is set and non-empty, otherwise:

```text
sh
```

RumiAI does not automatically prefer Bash and does not read `conf/shell/default` for shell selection.

The interactive RumiAI shell must expose RumiAI environment variables and the required RumiAI functions. Environment variables are inherited naturally; the portable mechanism for making the functions available in the newly executed shell remains an explicit open design item.

## Open items

Still to be designed:

1. detection of `<osarch>` and update of `sys-osarch` / `ext-osarch`;
2. invocation policy for that update mechanism;
3. language-selection utility that updates `lang/current`;
4. function-loading mechanism for the interactive shell.

These open items must not silently reintroduce superseded language configuration, host-locale selection, Bash-preferred behavior or a multicall command model.
