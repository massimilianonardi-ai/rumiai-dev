# RumiAI OS — Phase 1 runtime environment

Status: **Accepted architecture**  
Date: 2026-08-28  
Updated: 2026-09-06

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

The explicit platform-link updater is `osarch-update`. It is not invoked automatically by the bootstrap; any future lifecycle automation requires a separate decision.

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

The bootstrap resolver/API name is `lang`; `i18n` is superseded terminology. The explicit selector that updates `lang/current` is `lang-set`.

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

The function `shell [args...]` invokes the selected shell forwarding the received arguments. The startup contract is fixed by:

```text
decisions/rumiai-os/2026-09-05-interactive-shell-startup.md
```

The primary RumiAI integration target is the supported interactive non-login shell. In that path the adapter makes the RumiAI environment, interactive functions, prompt and `m_SHELL_EXT` available while preserving the native startup files appropriate to the shell.

Login shells are not normalized or emulated by RumiAI: their native login startup takes precedence and RumiAI does not guarantee or force core/`m_SHELL_EXT` loading through that path. Non-interactive shells do not load `m_SHELL_EXT` through the RumiAI startup path.

Current adapter coverage is:

```text
bash
zsh
sh / dash / ash
```

Other shells are executed directly without a RumiAI startup guarantee. Bash- and Zsh-specific alias-control operations are approved only inside their dedicated adapters; the generic shell/core contract remains POSIX.

The canonical configuration subtree for the base `shell` component is:

```text
$m_ROOT/conf/sys/shell/
```

The current implementation is:

```text
massimilianonardi-ai/rumiai-os@90a68a7c5e8c80e36bad12035c39b6d3e8d75b56
```

and the corresponding permanent shell test baseline is:

```text
massimilianonardi-ai/rumiai-tests@c39b1a2c0b6e96e8e43809a6e66d16918cf90a7d
```

These revisions are aligned to the accepted startup and state-namespace contracts but have not yet received a dedicated current physical-validation pass.

## Open items

The former Phase-1 open items for language selection, explicit platform-link updating and interactive-shell function loading have been resolved by later decisions.

The following related lifecycle question remains separate from the bootstrap contract:

1. whether `osarch-update` should ever be invoked automatically during installation, activation or another lifecycle operation.

This open point must not silently reintroduce superseded language configuration, host-locale selection, Bash-preferred behavior or a multicall command model.
