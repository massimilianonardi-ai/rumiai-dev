# RumiAI OS — Bootstrap environment

Status: **Current / normative**  
Updated: 2026-11-16

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

The managed POSIX shell function `context` is loaded by `core.lib.sh`; it changes only its invoking shell. The **generalized context** contract is the accepted `m` runtime's selection and persistence interface:

```text
context
context [system=<profile> | user=<identity> | pkg=<package>@<version>[!<osarch>] | provider.<facility>=<selector> | locale=<locale> | osarch=<id> | full-context=<preset> ...]
context --set-defaults [system=... | user=... | pkg=... | provider.<facility>=... | locale=... | osarch=... ...]
context --clear-defaults
context --define-preset <name> [system=... | user=... | pkg=... | provider.<facility>=... | locale=... | osarch=... ...]
context --delete-preset <name>
context --migrate-legacy
```

Bare `context` **initializes** the effective POSIX account's saved dimensions merged with validated installation baselines; it no longer means reset-to-empty. `--clear-defaults` deletes only persisted defaults, not named presets or the already active shell; a later bare invocation returns to the installation baseline. `--set-defaults` merges provided dimensions atomically into account preferences without changing the active selection. Named presets are account-scoped records expanded at their left-to-right `full-context=` position; preset define/delete do not activate. `--migrate-legacy` imports only independently validated **direct** former `system/current`, `user/current`, locale and osarch selectors into otherwise unspecified account defaults, without altering those selectors.

The installation-managed registry at `state/system/profile/.inventory` declares an explicit baseline and permitted real system profiles. The runtime validates it as data, not sourced shell syntax, and fails closed on missing, unsafe, malformed or unregistered profiles. Independent managed shells and ordinary nested `m` processes can select different system profiles without changing a global `current` symlink. `user=` selects an `m` logical state identity under `state/user`, not a POSIX account or an authorization grant. Persisted preference **ownership** is based on effective POSIX UID and its protected `$m_ROOT/state/<uid>/context` store; these are distinct concepts. Locale and osarch selections validate actual supported resources/targets; a selected package's concrete still must be compatible with the real host platform.

Selections fold left-to-right starting with saved defaults. Repeated dimensions replace their previous value, repeated `pkg=` replaces that package's version, and unrelated packages remain selected. `provider.<facility>=` pins an already installed concrete declaring the facility; consumer bindings still take precedence and package resolution remains owned by `pkg`. `context` does not install packages, materialize missing command views, rerun catalog discovery, execute package `env` source directly or grant CA/host-service authority.

Selected v1 package views are `cmd`, `lib/sh` and `lib/java`; v2 views are `link/bin`, `link/lib/sh` and `link/lib/java`. Existing validated command and shell-library directories contribute to PATH; the Java JAR directory contributes its literal `<dir>/*` entry to CLASSPATH. Most recent package PATH contribution comes first, but protected `m` system identities and package/library leaf collisions are rejected. Selected shell libraries must be non-executable; Java libraries are JAR links. Unsupported language-specific loaders are not implied. A failed selection leaves PATH, CLASSPATH, and the old active selection unchanged; repeated selection does not duplicate path entries.

A versioned **data-only** inherited context envelope binds the selected dimensions to the runtime root, effective UID and registered system profile and is revalidated by each nested `m` bootstrap. Callers cannot obtain host administrative permission by forging HOME, an inherited variable or a logical identity. `state-path` and the package launcher consume the validated selected profile and user state; installed static package `var/` links still require the actual supported profile, and incompatible launches fail before execution instead of silently using global state. See `STATE-MODEL.md`, `PACKAGE-MODEL.md`, `SERVICE-LIFECYCLE.md` and `TLS-TRUST.md` for ownership boundaries.

## Generalized-context ownership and authorization boundary

Generalized shell/process profiles, provider/package selections, UID-owned preference persistence and inherited validated child contexts are part of the release-candidate runtime contract. The context function is not authentication and never grants authority beyond host filesystem/account permissions. It does not mutate the installation profile inventory or retarget independently registered native host services.

Host-service registration fixes the authorized service system profile separately from interactive selections; see `SERVICE-LIFECYCLE.md`. CA authorization/revocation remains separately controlled by the protected selected system CA configuration, while clients consume only that verified selected profile's approved certificates; see `TLS-TRUST.md`. A package whose installed mutable `var/` state cannot honor the selected system profile is rejected before launch. These are fail-closed limits, not permission to make global links process-local through unvalidated symlinks.

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

The technical bootstrap exports readonly `m_STATE_DIR=$m_ROOT/state`. It initializes the compatibility roots `m_STATE_SYS_DIR=$m_STATE_DIR/system/current` and `m_STATE_USER_DIR=$m_STATE_DIR/user/default` before loading core; the validated `context` then selects a registered **real** system profile root and logical user-state root for its process and children. Those selected roots are no longer globally readonly aliases for `system/current`/`user/current`. The logical `user` selection never derives its identity from UID or hostname; effective UID is used only as authority for the preference store.

A validated versioned envelope is consumed on nested bootstrap, otherwise `context` initializes account defaults and installation baselines. The bootstrap rejects an invalid envelope/registry before executing a target. `state-path` returns selected semantic state paths without creating or mutating them; see `STATE-MODEL.md`.

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
BOOT-05  m bootstrap does not add the RumiAI ai executable layer
BOOT-06  core.lib.sh is the bootstrap entry library defining loadlib and loading base.lib.sh
BOOT-07  bootstrap initializes compatibility state roots; validated context selects effective profile/user roots process-locally
BOOT-08  logical m user-state identity is not derived from host-id/UID; effective UID owns persisted account context preferences only
BOOT-09  bootstrap provides no inherited per-command m_COMMAND_BIN identity
BOOT-10  before core is loaded, m defines only readpathce and export_readonly as bootstrap helpers
BOOT-11  m dot-sources core.lib.sh as the library-loading exception
BOOT-12  loadlib comes from core.lib.sh; base.lib.sh provides loadsyslib and base runtime
BOOT-13  bootstrap initializes and validates context (or inherited envelope), but never installs or refreshes packages/catalogs
BOOT-14  bootstrap performs root, base variables, core load, context validation, generated environment and external dispatch
BOOT-15  derived environment is consumed from the validated selected profile sys/environment/cache as env then env-osarch
BOOT-16  command dispatch does not inspect shebang text or source command bodies
BOOT-17  protected technical command roots precede selected package/provider and inherited host PATH
BOOT-18  dispatched operands are executed externally with the original vector
BOOT-19  independent shells/children can select different registered system profiles without changing global current selectors
BOOT-20  saved account context defaults and presets never grant system CA or host-service authority
```
