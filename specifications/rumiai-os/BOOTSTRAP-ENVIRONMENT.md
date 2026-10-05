# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-10-05

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

Before command execution, `m` sources the current generated global environment
described below. Provider PATH contributions from those files are therefore applied
to the inherited host PATH first.

The technical bootstrap then prepends:

```text
$m_BIN_SYS_OSARCH_DIR
$m_BIN_SYS_DIR
$m_BIN_EXT_OSARCH_DIR
$m_BIN_EXT_DIR
```

so the resulting technical order is:

```text
m sys/ext command roots
global provider osarch PATH contributions
global provider osarch-independent PATH contributions
inherited host PATH
```

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

## Bootstrap function surface and core library

The root `m` bootstrap deliberately keeps its function surface minimal. Before
`core.lib.sh` is loaded, the only approved bootstrap helper functions are:

```text
readpathce
export_readonly
```

`readpathce` exists for the root-resolution chicken/egg boundary.
`export_readonly` is the helper used while establishing the fundamental
bootstrap variables. Feature/runtime functions are not added to the root
bootstrap without an explicit architectural decision.

After root resolution and fundamental system-variable initialization, `m`
loads the core shell library directly:

```sh
. "$m_LIB_DIR/sys/sh/core.lib.sh"
```

This direct dot-source is the deliberate chicken/egg exception. `core.lib.sh`
defines the filesystem-backed `loadlib` primitive and immediately uses it to
load:

```text
sys/sh/base
```

`base.lib.sh` establishes the common runtime, including `loadsyslib` and the
runtime facilities that historically lived in core. Therefore the source of
`core.lib.sh` does not return to the root bootstrap until the common base
runtime has been established.

The root bootstrap still knows only the single `core.lib.sh` entry library;
it does not load `base.lib.sh` separately.

The root bootstrap performs no package/provider resolution or initialization.

## Generated global execution environment

The execution phase consumes derived global environment state rooted at:

```text
$m_STATE_SYS_DIR/sys/environment/cache
```

The package/provider subsystem may materialize:

```text
env
env-linux-x86_64
env-linux-arm64
env-macos-x86_64
env-macos-arm64
env-windows-x86_64
env-windows-arm64
env-osarch -> env-<selected-osarch>
```

`env` is the osarch-independent generated environment. `env-osarch` is a
relative selector owned by the `osarch` command and points to the generated
environment for the currently selected osarch.

After `core.lib.sh` has established the common runtime and before command
execution, `m` sources `env` when present and then sources the selected
`env-osarch` target when present. These files contain only generated shell
assignments/exports from trusted subsystem materialization; the bootstrap does
not resolve facility defaults, package defaults, provider selectors or package
concretes.

A missing generated environment is valid and contributes nothing. Existing
environment objects with invalid type, invalid selector shape or source failure
are runtime-state errors rather than a request for the bootstrap to regenerate
them.

## State roots

The bootstrap exports readonly semantic pathnames:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/current
m_STATE_USER_DIR=$m_STATE_DIR/user/current
```

It does not resolve/canonicalize the targets of `system/current` or `user/current`, does not derive host-id or UID, and does not require those selectors to exist merely to initialize `m`.

See `STATE-MODEL.md`.

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

The two branded root entrypoints are an explicit bootstrap exception to the shebang-based integrated-command recognition. They remain directly bootstrappable `#!/bin/sh` root entrypoints, but when `m` receives either exact root pathname as its command body:

```text
$m_ROOT/rumiai-os
$m_ROOT/rumiai-os-sh
```

it sources that body in the initialized `m` runtime rather than executing it as an external child. This gives the branded body access to `m_COMMAND_BIN`, the initialized runtime functions and the technical PATH exactly once, avoiding recursive bootstrap and duplicate technical PATH prefixes.

## Branded entrypoints

`rumiai-os-sh` resolves its product root and, when invoked directly, invokes `m` with itself as the command body. `m` recognizes that branded root pathname explicitly and sources the body in the initialized runtime. The body then prepends the `ai` executable layer and enters the shell.

The current `rumiai-os` entrypoint follows the same shell-oriented bootstrap/source/activation model using its own root pathname. This equivalence is not a permanent GUI contract.

## Invariants

```text
BOOT-01  m is the technical root bootstrap
BOOT-02  m uses #!/bin/sh
BOOT-03  m_BOOTSTRAP_BIN and m_ROOT are physical validated roots
BOOT-04  m PATH contains sys/ext layers, not ai
BOOT-05  branded activation prepends ai-osarch and ai
BOOT-06  core.lib.sh is the bootstrap entry library that defines filesystem loadlib and loads base.lib.sh
BOOT-07  state roots are semantic pathnames, not eagerly resolved selectors
BOOT-08  bootstrap does not derive user identity from host-id/UID
BOOT-09  m_COMMAND_BIN identifies the integrated command being sourced
BOOT-10  before core is loaded, m defines only readpathce and export_readonly as bootstrap helper functions
BOOT-11  m directly dot-sources core.lib.sh as the library-loading chicken/egg exception
BOOT-12  loadlib is provided by core.lib.sh; base.lib.sh provides loadsyslib and the common base runtime
BOOT-13  the root bootstrap performs no package/provider resolution or initialization
BOOT-14  the root bootstrap is limited to root resolution, fundamental system-variable initialization, core loading, generated global-environment sourcing and execution
BOOT-15  generated global environment is sourced from system sys/environment cache as env then env-osarch
BOOT-16  branded root entrypoints remain #!/bin/sh direct bootstraps but are sourced by m when passed back as exact root command bodies
BOOT-17  technical m PATH roots precede provider PATH contributions, which precede inherited host PATH
```
