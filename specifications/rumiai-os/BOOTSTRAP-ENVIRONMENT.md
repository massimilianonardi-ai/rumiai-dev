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

The initial supported public grammar remains:

```text
context
context pkg=<package>@<version>[!<osarch>] ...
```

A no-argument invocation clears the active package selections owned by
this function. A `pkg=` operand selects an already installed exact
package concrete. Selections are folded left-to-right. A later selection
of the same package replaces its earlier version, while unrelated
package selections are retained. The most recent selection has the
highest search-path precedence. This is a shell-local context, not a
new persisted package default.

This describes the currently implemented initial package/library phase. The
agreed generalized-context migration changes bare `context` to initialize
the effective context from persistent per-account defaults and adds an
explicit operation to clear those persisted defaults. Its exact public clear
syntax is selected as `context --clear-defaults`; the operation clears only
persistent per-account preferences and leaves the active shell context and
saved presets unchanged. Clearing an already empty preference record is
idempotent. Until that migration is implemented,
bare `context` retains the shell-local reset behavior above.

The selected generalized-context management forms are:

```text
context
context key=value ...
context --set-defaults key=value ...
context --clear-defaults
context --define-preset <name> key=value ...
context --delete-preset <name>
```

Activation operands replace the current shell context after complete
validation; they do not persist implicitly. `full-context=<name>` is an
activation operand that expands named preset selections in place before later
operands are folded. `--set-defaults` changes only the supplied per-account
preference dimensions, while preset definition/deletion and default mutation
do not change the active shell context. The account record is versioned,
strict data and is never sourced or evaluated. This is the selected target
interface, not a claim that these operations are currently implemented. The
management option spellings and package/preset selection forms are fixed. The
complete generalized `key=value` dimension grammar and runtime migration
remain unimplemented and are not inferred by the package-only phase.
System-profile inventory and baseline authority is an installation-managed
registry at `$m_ROOT/state/system/profile/.inventory`. The installer or
installation administrator provisions and atomically updates it; `m` consumes
it read-only and provides no profile-provisioning commands. Its strict
`m-system-profile-inventory-v1` format, bounded canonical identity list,
baseline membership, owner/mode rules and fail-closed behavior are specified
in `STATE-MODEL.md`. Only identities in a validated registry may be selected or
imported by migration; directory scanning and the legacy `system/current`
target cannot replace an absent or invalid registry.

### Child context continuity

An ordinary child may inherit a versioned, data-only context envelope that
describes the resolved selections needed to continue the caller's context.
It binds to the canonical `m_ROOT` identity and effective POSIX UID and carries
semantic profile/user identities, exact installed package/provider concrete
selections, locale/osarch and only explicitly permitted inherited values. It
contains no arbitrary filesystem paths, secrets, CA approval, service
registration or administrative authority.

Every child treats the envelope as untrusted input and validates its version,
root, UID, field grammar, installed identities and compatibility before use.
A malformed or unsupported version, or a root/UID mismatch, fails closed; a
present invalid envelope is not silently replaced with defaults. A child with
no envelope resolves its own context. Host-supervised services ignore caller
envelopes and use only the trusted service registration identity/profile.
This is the target contract; current `m` does not yet implement generalized
envelope propagation.

The generalized-context default store is `$m_ROOT/state/<effective-UID>`.
UID lookup and default loading occur only when the shell `context` function is
invoked; the technical root bootstrap continues not to derive UID or load
account defaults. A user-owned installation may create its own UID directory
only when the existing `state` parent is trusted and not group/world-writable.
Shared or read-only installations require an installer or account-lifecycle
administrator to pre-provision an account-owned mode `0700` directory.
Ordinary `context` execution never elevates privileges, changes parent
permissions or creates another account's directory. Missing, unsafe or
unwritable authority causes a diagnostic failure before changing the active
shell context. Never make the shared parent group/world-writable or sticky to
enable provisioning. Deployment and multi-account validation remain pending.

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

Provider environment/service coherence, dependency resolution, state
profiles, named full-context presets and protected propagation policies
remain outside this initial package command/library lookup phase.
The existing package launcher continues to own those responsibilities.

The technical root bootstrap merely loads the function definition as
part of `core.lib.sh`. Ordinary `m` command execution uses an
external `exec`, and therefore does not transfer shell functions
into that child; callers needing `context` in a new shell must
source `core.lib.sh` there.

## Approved generalized-context boundaries (not yet implemented)

The supported first-phase `context` grammar and no-argument reset above remain the current executable contract until a separately validated, coordinated migration. The approved **future generalized-context** requirements are:

- Two managed shells and their ordinary managed child processes must be able to select distinct system profiles and logical user-state identities concurrently. One shell's selection must not mutate `state/system/current`, `state/user/current` or another process's active selection.
- Package commands, libraries, provider resolution, mutable state and inherited environment must agree on the effective selected context. If an installed package cannot safely honor the selected profile using an upstream-supported state-path adaptation or an already prepared compatible per-profile view, its launch must fail before it could use another profile's state; it must never silently fall back to the global profile.
- Host-supervised service profiles and system TLS CA authority are **not** untrusted shell-context selections. Their ownership rules are in `SERVICE-LIFECYCLE.md` and `TLS-TRUST.md`; mutable state routing is governed by `STATE-MODEL.md`.

These are binding design and migration constraints, **not** claims that profile-aware bootstrap, `state-path`, package `var/` routing or trusted child propagation already exist. Existing global-selector consumers remain supported under their current contracts until an explicitly validated transition; unsupported concurrent-profile use must fail closed rather than silently alter global state. The management operation spellings above are selected. The installation-managed system-profile registry is authoritative for allowed identities and baseline; installers/administrators provision it and `m` consumes it without a provisioning API. Its exact path/wire format, permission validation, complete operand-dimension grammar, persistence format and trusted propagation mechanics remain unimplemented; no executable API beyond the documented package-only phase is implied.

Future generalized-context behavior is that bare `context` initializes the
active context from persisted defaults, and an explicit clear operation
clears those persisted defaults. The defaults belong to the real POSIX
account running the shell and are stored under
`$m_ROOT/state/<effective-UID>`. This storage identity is distinct from the
logical `user` context dimension and grants no service-registration, CA
approval or other host-administrative authority. This is a settled migration
target, not the current executable API: the existing package-only no-argument
reset remains in effect until a coordinated migration is validated. The
selected management command spellings and account-store authority/provisioning
policy are documented above and in `STATE-MODEL.md`; implementation and
deployment validation remain pending. The generalized record wire format and
complete dimensions remain implementation work behind the selected API.

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
