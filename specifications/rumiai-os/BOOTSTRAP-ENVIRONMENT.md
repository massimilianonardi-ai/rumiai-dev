# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-11-02

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

After loading core, each fresh `m` process without an inherited context envelope
initializes its effective context from account defaults and the installation
baseline before sourcing the selected profile's generated environment. An
inherited envelope is validated instead. This initializes only the selected
context and lookup views; it does not install packages or resolve provider
dependencies.

## Shell context selection and library search roots

The core runtime exposes the POSIX shell **function** `context` in the
shell that sources `core.lib.sh`. It is not an external executable and
cannot modify the invoking shell when run in a child process.

Package command and library lookup remains part of the public context function;
the complete generalized grammar and default semantics are defined below.

```text
context [<generalized context operands>]
```

A no-argument invocation initializes the context from persisted account
defaults and the managed baseline. A `pkg=` operand selects an already
installed exact package concrete. Selections are folded left-to-right. A later selection
of the same package replaces its earlier version, while unrelated
package selections are retained. The most recent selection has the
highest search-path precedence. The active selection is shell-local; persisted
defaults are changed only by the explicit default-management operations below.

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
are preserved when the context-owned Java lookup contribution is replaced.
Failed selection does not
change `PATH`, `CLASSPATH` or the previously active package set.

`PATH` is shared between executable command lookup and POSIX dot
lookup, so publishing `lib/sh` has a common namespace and must not
silently redefine existing `m`-owned `loadlib/loadsyslib` identities.
For Java, the wildcard `<directory>/*` includes JARs in that
directory but does not guarantee JAR enumeration order. An explicit
Java `-cp` option overrides `CLASSPATH`; this variable does not
govern every Java launch method.

This section describes how already installed concretes contribute search
paths. Generalized context can also select process-local profiles, logical
user-state roots and provider pins as specified below. It does not materialize
provider environments or service state: the package launcher continues to own
provider dependency and environment preparation, while service and TLS trust
remain under their separate authorities.

The technical root bootstrap loads the function definition as part of
`core.lib.sh`. Ordinary `m` command execution uses an external `exec` and does
not transfer shell functions into that child. A managed child receives its
selected context values through the validated context envelope; a shell that
needs to call the `context` function must source `core.lib.sh` itself.

## Generalized shell context

`context` is a POSIX shell function. It replaces the active context in the
calling shell; it has no stack. A fresh managed shell initializes its effective
context from that POSIX account's persisted defaults and the managed baseline.
Calling `context` without operands performs this initialization again. It does
not clear the active context. `context --clear-defaults` explicitly removes the
account's persisted preference record and does not change the current shell.

The public operand grammar is:

```text
context [system=<profile>] [user=<identity>] [pkg=<concrete>] ...
        [provider.<facility>=<selector>] [locale=<locale>]
        [osarch=<id>] [full-context=<name>] ...
context --set-defaults <context operand> ...
context --clear-defaults
context --migrate-legacy
context --define-preset <name> <context operand> ...
context --delete-preset <name>
```

Operands are data, never shell source. Repeated package selections replace the
same package's prior selection; repeated selections of another dimension replace
that dimension. `full-context=<name>` expands a named account preset at that
position, after which later operands override matching dimensions. Invalid or
unavailable selections fail before changing the caller's environment or active
context.

`system` names a profile in the installation-managed system profile registry;
an omitted value uses its declared baseline. `user` names a logical `m` state
identity, not a POSIX account, and defaults to `default`. Names use the canonical
identity grammar in `STATE-MODEL.md` and resolve directly beneath
`state/user/`; if the identity directory already exists, it must be a real
directory rather than a symlink or special object. `pkg` names an exact installed concrete. `provider.<facility>` pins
the package selector for that facility in this process. `locale` names an
available technical catalog directory. `osarch` names the dependency-resolution
target; executable package/provider concretes must still be compatible with the
actual host architecture. Omitting these dimensions uses the managed baseline
and configured package/provider defaults.

Persisted defaults and named presets are account-scoped data under
`$m_ROOT/state/<effective-UID>/context/`, protected by host ownership and mode
checks. They are separate from logical `user` state identities. `context
--migrate-legacy` is the only operation that imports legacy selector state. It
imports only validated direct selector values whose targets are registered or
canonical managed identities; it does not scan directories, follow arbitrary
paths, or change/delete legacy selectors. Repeating migration preserves already
stored explicit choices.

Selections apply to the calling shell and are propagated to ordinary child
processes through the validated, data-only context envelope. They never mutate
`state/system/current`, `state/user/current`, language `current`, or another
process's selection. `lang` uses the active context locale when present and
otherwise the global locale. Package provider selection follows
`PACKAGE-MODEL.md`. Host-supervised service profiles and system TLS CA authority
remain separately trusted according to `SERVICE-LIFECYCLE.md` and `TLS-TRUST.md`.

Package commands, libraries, provider resolution, mutable state and inherited
environment must agree on the effective context. Package `var/` state may use a
selected profile only through a verified upstream-supported state-path adapter
or an already prepared compatible profile view. If neither is available, launch
fails before execution; it never follows another process's or the global
profile's mutable state. This contract defines the behavior; implementation and
acceptance evidence remain tied to their exact `m-os` revisions.

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

The bootstrap exports semantic pathnames for the effective context:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/profile/<effective-profile>
m_STATE_USER_DIR=$m_STATE_DIR/user/<effective-logical-identity>
```

Context initialization validates the selected profile through the installation
registry and resolves logical user state directly under `state/user/`. The
legacy `current` selectors do not select ordinary process context and are read
only by explicit migration. POSIX UID identifies the protected account-default
store; it does not define a logical user identity. State leaves remain lazily
materialized.

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
BOOT-07  state roots are semantic pathnames for the validated effective context
BOOT-08  logical user identity is not derived from host-id/UID; UID scopes only account-owned context preferences
BOOT-09  the bootstrap provides no inherited per-command m_COMMAND_BIN identity
BOOT-10  before core is loaded, m defines only readpathce and export_readonly as bootstrap helper functions
BOOT-11  m directly dot-sources core.lib.sh as the library-loading chicken/egg exception
BOOT-12  loadlib is provided by core.lib.sh; base.lib.sh provides loadsyslib and the common base runtime
BOOT-13  after core loading, each m process initializes or validates its effective context before sourcing profile environment
BOOT-14  m bootstrap performs no package installation or provider-dependency resolution
BOOT-15  generated global environment is sourced from system sys/environment cache as env then env-osarch
BOOT-16  command dispatch does not inspect shebang text or source the command
BOOT-17  technical m PATH roots precede provider PATH contributions, which precede inherited host PATH
BOOT-18  every command operand is executed externally with the original command vector
```
