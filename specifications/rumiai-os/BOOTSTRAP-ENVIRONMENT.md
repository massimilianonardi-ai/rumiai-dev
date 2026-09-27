# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-09-28

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

This direct dot-source is the deliberate chicken/egg exception: the ordinary
library-loading functions do not exist until `core.lib.sh` has been loaded.
All subsequent owned system-shell-library loading follows
`LIBRARY-INTERFACES.md`.

Package/provider initialization is not a responsibility of the root bootstrap.
Its package-subsystem role is defined outside this bootstrap contract.

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
BOOT-06  core.lib.sh is the bootstrap core library
BOOT-07  state roots are semantic pathnames, not eagerly resolved selectors
BOOT-08  bootstrap does not derive user identity from host-id/UID
BOOT-09  m_COMMAND_BIN identifies the integrated command being sourced
BOOT-10  before core is loaded, m defines only readpathce and export_readonly as bootstrap helper functions
BOOT-11  m directly dot-sources core.lib.sh as the library-loading chicken/egg exception
BOOT-12  loadlib/loadsyslib are provided by core.lib.sh rather than by the root bootstrap
BOOT-13  package/provider initialization is not a root-bootstrap responsibility
BOOT-14  the root bootstrap is limited to root resolution, fundamental system-variable initialization, core loading and execution
BOOT-16  branded root entrypoints remain #!/bin/sh direct bootstraps but are sourced by m when passed back as exact root command bodies
```
