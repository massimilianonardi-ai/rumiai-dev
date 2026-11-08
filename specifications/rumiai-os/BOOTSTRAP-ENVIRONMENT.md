# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-11-08

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

The technical `m` bootstrap does not add the RumiAI `ai` executable layer. Any upper-layer activation is outside this bootstrap contract.

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
load the common runtime followed by the shell context implementation:

```text
sys/sh/base
sys/sh/context
```

`base.lib.sh` establishes the common runtime, including `loadsyslib` and the
runtime facilities that historically lived in core. Therefore the source of
`core.lib.sh` does not return to the root bootstrap until the common base
runtime has been established.

The root bootstrap still knows only the single `core.lib.sh` entry library;
it does not load `base.lib.sh` separately.

The root bootstrap performs no package/provider resolution or initialization.

## Shell context selection and library search roots

The core runtime exposes the POSIX shell **function** `context` in the
shell that sources `core.lib.sh`. It is not an external executable and
cannot modify the invoking shell when run in a child process.

The current public shell-local grammar for package selections and account
preferences is:

```text
context
context pkg=<package>@<version>[!<osarch>] ...
context preset=<name> ...
context defaults set pkg=<package>@<version>[!<osarch>] ...
context defaults clear
context preset set <name> pkg=<package>@<version>[!<osarch>] ...
context preset clear <name>
context reset
```

A no-argument invocation initializes or replaces the active shell context
from an empty package-selection baseline plus that POSIX account's persisted
package defaults. It does not write defaults. `context reset` explicitly removes the
active context's owned shell contributions and restores the host values captured
before activation. `context defaults clear` removes persisted account defaults;
it does not change the active shell context. `context defaults set` updates
only the dimensions named by its operands and preserves other saved dimensions.
`context preset set` stores a named, data-only
selection sequence, and `context preset clear` removes that preset. Presets may
be expanded inline with `preset=<name>` and are folded at their position in the
operand list. These operations never mutate package defaults, facility defaults,
consumer bindings or global `current` selectors.

The currently implemented selection dimension is an exact installed package
concrete. A later selection of the same package replaces its earlier concrete,
while unrelated package selections are retained. Selection operands and inline
presets are folded left-to-right. The most recent package selection has the
highest search-path precedence. Activation replaces the one active context in
the invoking shell; there is no restore stack. Failed validation leaves the
active shell state and persisted preferences unchanged.

Account defaults and presets are stored below
`$m_ROOT/state/<effective-UID>/context/`. The effective UID is obtained using
the host's `id -u` utility and validated as a decimal identifier; it only
selects the preference directory and is not the
logical `m` user identity and grants no authentication, service, system-state
or TLS authority. Preference records are versioned data, never shell source or
expressions. A record starts with `m-context-v1`; each subsequent line contains
exactly one validated selection operand. Empty lines, unknown versions and
malformed operands fail closed. Defaults updates replace only the dimensions
named by their operands and preserve other saved dimensions.
Preset updates replace that named preset. Updates use a same-directory
temporary regular file and atomic rename. `$m_ROOT/state` must be a real
directory owned by root or the effective account and must not be group- or
world-writable. The account directory is owned by the effective UID with mode
0700; preference records are owned by that UID with mode 0600. A shared
protected installation requires administrator
provisioning of the account directory; ordinary `context` never escalates
privilege. Missing account preferences contribute no overrides and are not
seeded from `state/system/current`, `state/user/current`, package defaults or
facility defaults. Those existing installation-wide authorities remain the
read-only baseline for dimensions the account has not overridden. An invalid,
unavailable or unsafe preference store fails closed; there is no `$HOME`
fallback.

For each selected concrete, `context` reads existing, separately
materialized lookup views when present:

```text
<concrete>/cmd        -> PATH, executable command lookup
<concrete>/lib/sh     -> PATH, POSIX dot-source lookup
<concrete>/lib/java   -> CLASSPATH, literal <directory>/* wildcard
```

A package may publish only libraries and no ordinary executable
commands. The function neither builds nor refreshes the symlink
views on activation. Libraries are ordinary package exports, not
facility parts or independent provider selections.

For selected `cmd` entries, command names must not collide with
one another or protected `m` sys command names. Library projections
must be existing, non-symlink directories containing appropriately
typed readable library links. Identical library leaf names between
independently selected concretes for the same runtime are rejected
rather than ambiguously ordered. POSIX shell source files must be
non-executable; the two runtime groups are selected from the same
pinned package-concrete identity.

Before changing caller state, `context` validates operand identities,
applicable platform, available concrete/lookup views, collisions,
and the ownership of its previously installed search-path segments.
It then replaces only its own `PATH` and `CLASSPATH` contributions;
host contributions are retained. Repeated application is idempotent.
When the incoming `CLASSPATH` was unset or set-empty, the two states
are preserved on a no-argument reset. Failed selection does not
change `PATH`, `CLASSPATH` or the previously active package set.

`PATH` is shared between executable command lookup and POSIX dot
lookup, so publishing `lib/sh` has a common namespace and must not
silently redefine existing `m`-owned `loadlib/loadsyslib` identities.
For Java, the wildcard `<directory>/*` includes JARs in that
directory but does not guarantee JAR enumeration order. An explicit
Java `-cp` option overrides `CLASSPATH`; this variable does not
govern every Java launch method.

Generalized context dimensions include system profile, logical user-state,
locale and provider choice. They are not yet executable operands in this
package-selection increment and fail as unsupported input. Provider
environment/service coherence, dependency resolution, context-aware state
profiles and protected propagation policies are not implied by selecting
`pkg=` or by an account preference. Existing package launchers continue to own
package environment and provider resolution. If a selected context cannot be
honored by a package's state or provider view, that package must fail before
launch rather than silently use another context's or the global profile's
mutable state.

The technical root bootstrap merely loads the function definition as
part of `core.lib.sh`. Ordinary `m` command execution uses an
external `exec`, and therefore does not transfer shell functions
into that child; callers needing `context` in a new shell must
source `core.lib.sh` there.

## Generalized-context authority and propagation

The following requirements govern the coordinated context migration. Existing
global-selector consumers remain supported under their current contracts while
their context-aware implementations are being completed. The accepted selection
dimensions are system profile, logical user-state identity, locale, provider
choice and exact package concrete; each is resolved only through its owning
state, localization or package/provider authority, never from an arbitrary
filesystem path.

- Two managed shells and their ordinary managed child processes must be able to select distinct system profiles and logical user-state identities concurrently. One shell's selection must not mutate `state/system/current`, `state/user/current` or another process's active selection.
- Package commands, libraries, provider resolution, mutable state and inherited environment must agree on the effective selected context. For provider-backed package consumers, selection precedence is explicit consumer binding, explicit context provider choice, account context default, configured system facility default, then the existing unique-compatible-installed-provider rule. An authoritative configured choice that is missing, invalid or incompatible fails; it does not fall through. A context override never writes a package default, consumer binding or system facility default.
- If an installed package cannot safely honor the selected profile using an upstream-supported state-path adaptation or an already prepared compatible per-profile view, its launch must fail before it could use another profile's state; it must never silently fall back to the global profile.
- A context envelope propagated through the environment is versioned, data-only and untrusted continuity information. Every cooperating `m` process validates its format, effective UID, selected identities, installed concrete/provider compatibility and available state view before use. It conveys no service registration, administrator, filesystem ownership or TLS CA approval authority. Invalid inherited context fails closed.
- Context-owned environment fields are protected from package environment scripts. Package-defined environment effects remain available when compatible, but may not rewrite context identity, selected state roots or protected inherited values. Package launch and nested execution must preserve the coherent effective HOME and other explicitly protected values.
- Host-supervised service profiles and system TLS CA authority are **not** untrusted shell-context selections. Their ownership rules are in `SERVICE-LIFECYCLE.md` and `TLS-TRUST.md`; mutable state routing is governed by `STATE-MODEL.md`.

These are binding migration constraints, **not** claims that profile-aware
bootstrap, `state-path`, package `var/` routing or trusted child propagation
are already implemented. Existing global-selector consumers remain supported
under their current contracts until an explicitly validated transition;
unsupported concurrent-profile use must fail closed rather than silently alter
global state. The existing C1 `pkg=` package-command/library API remains
implemented. The package-only account defaults and named presets described
above are implemented in the current candidate increment. Generalized profile,
user, locale and provider operands, state routing and trusted child propagation
remain unimplemented and require coordinated implementation and validation
before they are reported as available.

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

A missing generated environment is valid and contributes nothing. For each of
the two expected pathnames, `m` tests `-f` and sources the pathname when that
test succeeds. The bootstrap does not validate or regenerate selector structure
for `env-osarch`; ownership of materializing that state remains outside the
bootstrap. A source failure is a runtime execution error.

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

Without command operands, `m` invokes the managed technical shell facility.

For a command operand, `m` attempts to resolve and canonicalize the first operand so that dispatch back to the bootstrap itself can be rejected. It clears any inherited legacy `m_COMMAND_BIN` state and invokes the original command vector externally using `exec "$@"`. No command is sourced by the bootstrap and shebang text does not select a special command class.

Commands requiring `m` environment variables validate nonempty `m_ROOT` at entry; POSIX shell commands load the shell libraries they need within their own process. The bootstrap exports roots and the generated global execution environment, not live shell functions or a command-local identity. See `COMMAND-ENTRYPOINTS.md`.

## Invariants

```text
BOOT-01  m is the technical root bootstrap
BOOT-02  m uses #!/bin/sh
BOOT-03  m_BOOTSTRAP_BIN and m_ROOT are physical validated roots
BOOT-04  m PATH contains sys/ext layers, not ai
BOOT-05  the technical m bootstrap does not add the RumiAI ai executable layer
BOOT-06  core.lib.sh is the bootstrap entry library that defines filesystem loadlib and loads base.lib.sh
BOOT-07  state roots are semantic pathnames, not eagerly resolved selectors
BOOT-08  bootstrap does not derive user identity from host-id/UID
BOOT-09  the bootstrap provides no inherited per-command m_COMMAND_BIN identity
BOOT-10  before core is loaded, m defines only readpathce and export_readonly as bootstrap helper functions
BOOT-11  m directly dot-sources core.lib.sh as the library-loading chicken/egg exception
BOOT-12  loadlib is provided by core.lib.sh; base.lib.sh provides loadsyslib and the common base runtime
BOOT-13  the root bootstrap performs no package/provider resolution or initialization
BOOT-14  the root bootstrap is limited to root resolution, fundamental system-variable initialization, core loading, generated global-environment sourcing and execution
BOOT-15  generated global environment is sourced from system sys/environment cache as env then env-osarch
BOOT-16  command dispatch does not inspect shebang text or source the command
BOOT-17  technical m PATH roots precede provider PATH contributions, which precede inherited host PATH
BOOT-18  every command operand is executed externally with the original command vector
```
