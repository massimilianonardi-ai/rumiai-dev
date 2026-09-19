# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-09-19

This specification defines the environment established by the technical root runtime `$m_ROOT/m`.

## Root resolution

`m` resolves its own physical executable pathname into:

```text
m_BOOTSTRAP_BIN
```

and derives:

```text
m_ROOT
```

as the containing physical directory. Both are exported and readonly after validation.

Root resolution must not depend on the caller CWD except for resolving an explicitly invoked relative pathname, and must support invocation through PATH/symlink forms according to the current implementation contract.

## Core semantic roots

The bootstrap exports readonly:

```text
m_BIN_DIR=$m_ROOT/bin
m_BIN_SYS_DIR=$m_BIN_DIR/sys
m_BIN_SYS_OSARCH_DIR=$m_BIN_DIR/sys-osarch
m_BIN_EXT_DIR=$m_BIN_DIR/ext
m_BIN_EXT_OSARCH_DIR=$m_BIN_DIR/ext-osarch
m_LIB_DIR=$m_ROOT/lib
m_PKG_DIR=$m_ROOT/pkg
m_RES_DIR=$m_ROOT/res
m_LANG_DIR=$m_RES_DIR/sys/lang
m_SRC_DIR=$m_ROOT/src
```

It must not introduce derived convenience variables merely to abbreviate deeper paths without a real contract need.

## PATH

`m` prepends:

```text
$m_BIN_SYS_OSARCH_DIR
$m_BIN_SYS_DIR
$m_BIN_EXT_OSARCH_DIR
$m_BIN_EXT_DIR
```

before the inherited host PATH.

RumiAI branded activation is separate and prepends:

```text
$m_BIN_DIR/ai-osarch
$m_BIN_DIR/ai
```

The technical `m` bootstrap does not add the `ai` layer by itself.

## Localization environment

The technical runtime exports readonly:

```text
m_LANGUAGE_FALLBACK=en_US
m_TEXT_ENCODING=UTF-8
m_LANG_CURRENT_DIR=$m_LANG_DIR/current
m_LANG_FALLBACK_DIR=$m_LANG_DIR/$m_LANGUAGE_FALLBACK
```

`m_LOG_LEVEL` may be supplied/exported as runtime configuration and is not made readonly by the bootstrap.

## Core library

After establishing the technical roots/PATH, `m` sources:

```text
$m_LIB_DIR/sys/sh/core.lib.sh
```

The bootstrap does not source arbitrary feature libraries pre-emptively. The package provider library is the explicit exception required by the facility-default global-environment contract described below.

## State roots

The bootstrap exports readonly semantic pathnames:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/current
m_STATE_USER_DIR=$m_STATE_DIR/user/current
```

It does not resolve/canonicalize the targets of `system/current` or `user/current`, does not derive host-id or UID, and does not require those selectors to exist merely to initialize `m`.

See `STATE-MODEL.md`.

## Facility-default global environment

After the core library and semantic state roots exist, `m` loads the package provider library:

```text
$m_LIB_DIR/sys/sh/pkg/pkg-provider.lib.sh
```

and applies the environment projections of currently resolvable system facility defaults before command dispatch or technical-shell entry.

This bootstrap integration is derived directly from authoritative facility-default configuration and installed provider metadata. It does not create or consume a generated environment snapshot as a second authority.

The active platform class is taken from a valid technical external selector:

```text
bin/ext-osarch -> ext-<osarch>
```

when present. Bootstrap does not run platform selection, validate the complete sys/ext/ai selector set or require an osarch selector merely to start. Without a valid active `ext-osarch` selector, only a resolvable generic provider class can contribute environment.

Facility defaults are processed in ascending `LC_ALL=C` facility-name order. Their ordinary environment assignments override inherited values in that new bootstrap; if multiple defaults export the same variable, the later facility assignment wins. `PATH` is not valid `facility-env` metadata: executable exposure remains owned by the already-established `sys-osarch:sys:ext-osarch:ext` PATH layers and facility command publication.

A configured selector that is currently unresolved or inapplicable to the active platform contributes no environment. Invalid/corrupt default or projection data makes the global environment application fail as one unit; `m` reports that projection failure but preserves bootstrap availability rather than partially applying provider environment.

Facility-default and provider-package-default changes affect later `m` bootstraps. They do not mutate an already-running parent process or managed shell. Commands launched later through `#!/usr/bin/env m` receive a fresh bootstrap and therefore re-resolve current selector intent.

See `PACKAGE-MODEL.md`.

## Command execution

When invoked without command operands, `m` enters the technical shell facility.

For an integrated command, `m` resolves the supplied command pathname, rejects self-recursion to the bootstrap, exports readonly:

```text
m_COMMAND_BIN
```

sources the command body in the initialized runtime and returns its status.

Integrated command files therefore use:

```sh
#!/usr/bin/env m
```

when directly executable.

## Branded entrypoints

`rumiai-os-sh` resolves its product root, invokes `m` with itself as the command body, prepends the `ai` executable layer and enters the shell.

The current `rumiai-os` entrypoint follows the same shell-oriented implementation baseline. This equivalence is not a permanent GUI contract.

## Invariants

```text
BOOT-01  m is the technical root bootstrap
BOOT-02  m uses #!/bin/sh
BOOT-03  m_BOOTSTRAP_BIN and m_ROOT are physical validated roots
BOOT-04  m PATH contains sys/ext layers, not ai
BOOT-05  branded activation prepends ai-osarch and ai
BOOT-06  core.lib.sh is the bootstrap core library
BOOT-07  state roots are semantic pathnames, not eagerly resolved selectors
BOOT-08  bootstrap does not derive user identity from host-id/UID
BOOT-09  m_COMMAND_BIN identifies the integrated command being sourced
BOOT-10  every new m bootstrap derives facility-default environment before dispatch without persisting a second environment authority
BOOT-11  facility-default environment uses a valid ext-osarch class when available and never triggers implicit platform selection
BOOT-12  facility defaults are applied in LC_ALL=C facility-name order and later assignments win on duplicate ordinary variables
BOOT-13  facility-env cannot replace PATH; executable exposure remains owned by the technical command-path layers
BOOT-14  a failed global provider-environment projection does not make the technical bootstrap unavailable or leave a partially applied provider environment
```
