# RumiAI OS — Phase 1 runtime environment

Status: **Accepted architecture**  
Date: 2026-08-28  
Updated: 2026-09-08

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
    bin / lib / pkg / lang / src
    conf / data / home / cache / log / run / tmp
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

Current top-level semantic roots are:

```text
m_BIN_DIR=$m_ROOT/bin
m_LIB_DIR=$m_ROOT/lib
m_PKG_DIR=$m_ROOT/pkg
m_LANG_DIR=$m_ROOT/lang
m_SRC_DIR=$m_ROOT/src
m_CONF_DIR=$m_ROOT/conf
m_DATA_DIR=$m_ROOT/data
m_HOME_DIR=$m_ROOT/home
m_CACHE_DIR=$m_ROOT/cache
m_LOG_DIR=$m_ROOT/log
m_RUN_DIR=$m_ROOT/run
m_TMP_DIR=$m_ROOT/tmp
```

Each canonical top-level semantic root has a corresponding RumiAI environment variable. Ordinary subdirectories are derived from the appropriate semantic root and do not receive environment aliases merely for convenience. The executable subtree is the existing exception where separately named sub-roots have independent runtime and `PATH` roles.

The state-area roots remain semantically classified by the package/state decisions:

```text
persistent authoritative      conf / data / home
persistent non-authoritative  cache / log
transient                     run / tmp
```

There is no global `$m_ROOT/var/` semantic root and no bootstrap `m_VAR_DIR`; `var/` remains package-local only.

`m_LANG_DIR` remains `$m_ROOT/lang`. `data/` is authoritative persistent state rather than a generic resource container, so current language catalogs are not placed under `data/` or `data/sys/lang/`. `lang/current` remains the relative language-selection symlink under the top-level `lang/` tree.

A semantic-root variable identifies the canonical pathname but does not require the bootstrap itself to materialize the corresponding directory. A subsystem creates a root when its lifecycle actually requires it.

`m_SRC_DIR` remains the local development workspace root and is not a runtime dependency.

The expanded root contract is fixed by:

```text
decisions/rumiai-os/2026-09-08-top-level-semantic-roots-and-lang-placement.md
```

and is implemented in:

```text
massimilianonardi-ai/rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4
```

This semantic-root extension has not yet received a dedicated physical-validation run.

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
$m_CONF_DIR/sys/shell/
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
