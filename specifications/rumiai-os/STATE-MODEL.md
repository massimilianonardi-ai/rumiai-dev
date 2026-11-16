# RumiAI OS — State model

Status: **Current / normative**  
Updated: 2026-10-05

This document defines the current mutable-state contract.

## Semantic root

All managed mutable state is rooted at:

```text
$m_ROOT/state
```

The baseline scopes are:

```text
system
user
```

The owner classes are:

```text
sys
ai
pkg
```

The semantic order is:

```text
scope -> owner -> identity -> area
```

For packages, an optional State Instance is encoded in the identity as `<package>@!<instance>`.

## Bootstrap roots

`m` exports readonly `m_STATE_DIR=$m_ROOT/state` and initializes compatibility `m_STATE_SYS_DIR=$m_STATE_DIR/system/current` and `m_STATE_USER_DIR=$m_STATE_DIR/user/default` before loading core. After core loading, generalized `context` chooses the validated effective registered system profile and logical user identity for the current managed process; inherited `m` children revalidate the data-only envelope. These effective roots are process-local selections, not immutable global-selector aliases.

With no inherited envelope, startup loads the effective POSIX account's context preferences from its protected `state/<effective-UID>/context` record and falls back to the validated installation profile inventory baseline. Effective UID controls preference record ownership and is **not** the `m` logical user-state identity. Ordinary selection neither changes `system/current`/`user/current` nor materializes state paths.

## System state

An installation declares valid real profiles and one baseline in `state/system/profile/.inventory`. Registered profile directories are real, validated installation-managed state; the registry is a strict data record, not shell code. A generalized managed context selects one registered system profile for its process, inherited commands and `state-path system` resolutions. Distinct processes may use distinct profiles concurrently without changing global selectors. Context selection is not authorization to edit registry membership or protected state.

Legacy `state/system/current -> profile/<profile>` remains a compatibility selector for older static package `var/` links and for explicit validated `context --migrate-legacy`; it is not the authority for an already context-selected process. A missing, malformed, indirect or escaping legacy selector must not be auto-imported into preferences. System profile administration and host permissions stay independent of caller-selected shell dimensions.

## User state

The `user` scope is a logical `m` state namespace, **not** a POSIX account or authentication principal. Generalized `context user=<identity>` selects `state/user/<identity>` for that managed process and its validated children. With no saved or explicit logical user selection, the baseline identity is `default`. `state-path user` is a pure resolver against that effective identity.

`state/user/current` may exist as a legacy global symlink and is considered only by explicit validated `context --migrate-legacy`; it is not followed to retarget a concurrently selected context. The identity is never inferred from `UID`, username, host-id, HOME or hostname. A separate *per-effective-UID* `state/<uid>/context` store contains default and preset **preferences**; it does not authenticate or grant access to arbitrary logical user state. POSIX filesystem permissions remain the security boundary.

## Areas

The canonical areas are:

```text
conf   persistent authoritative configuration
data   persistent authoritative data
home   application/compatibility home state
cache  persistent non-authoritative/regenerable state
log    persistent operational history
run    transient runtime coordination
tmp    transient scratch/intermediate state
```

Directories are created lazily when needed, not as a full Cartesian product.

The technical global execution-environment cache is the derived system state:

```text
state-path system sys environment cache
```

which resolves under the semantic current system profile to:

```text
$m_STATE_SYS_DIR/sys/environment/cache
```

It contains regenerable environment snapshots such as `env`, `env-<osarch>` and
the `env-osarch` selector. Authoritative provider/package selector intent does
not live there; it remains in the package subsystem's configuration state.

## `state-path`

The public resolver is:

```text
state-path <scope> <owner> <identity> <area> [<state-instance>]
```

Accepted scopes:

```text
system | user
```

Accepted owners:

```text
sys | ai | pkg
```

Accepted areas:

```text
conf | data | home | cache | log | run | tmp
```

The optional State Instance is valid only with `owner=pkg`.

`state-path` is a pure resolver. It does not create directories, mutate selectors, select package versions or canonicalize the selected binding target.

On success it prints exactly one absolute semantic pathname followed by newline.

## Package state and HOME

Package consumers use `state-path`; they do not rebuild the state tree manually.

A normal user-scoped package HOME is obtained through:

```text
state-path user pkg <package> home
```

The package launcher creates/validates that HOME as needed and exports it for the launched process.

A package launched as a system-hosted service uses the existing system scope plus a
package State Instance equal to the service/facility identity:

```text
state-path system pkg <package> home <service>
state-path system pkg <package> conf <service>
```

This is service-specific package state, not a new state scope or owner class. The
selected POSIX execution account is a host security principal and does not become
part of the `m` state identity. Administrative service installation may prepare
and assign host filesystem ownership for the exact mutable State Instance paths it
requires; `state-path` itself remains a pure resolver.

`m`-managed package configuration normally lives under the reserved `.m/` namespace inside package `conf`, for example:

```text
<package-conf>/.m/env
```

Package provider bindings are a specific package-configuration surface owned by the package dependency contract and live directly under:

```text
<package-conf>/binding/<facility>
```

for the system-scoped consumer package configuration. Each binding file contains one provider selector. This explicit binding surface is not duplicated under `.m/`.

## State Instances

Package State Instance grammar is:

```text
normal:    <package>
instance:  <package>@!<instance>
```

Example:

```text
state-path user pkg foo conf test
```

resolves under identity:

```text
foo@!test
```

No separate `instance/<name>` subtree is part of the current model.

## Package `var/` routing

Package-local `var/` is a compatibility mechanism for upstream software that insists on mutable paths inside its installation tree.

Each path declared under a package `var/<area>` definition is an explicit mutable package-root path. When that path exists in the extracted useful root as a regular file or real directory, its content is the factory/default state used only when no authoritative mutable state already exists.

When the declared final path is absent but every parent component in the useful root exists as a real directory, the declaration represents an initially empty **directory**. Integration materializes an empty factory/default directory and an empty mutable directory when needed, then routes the package-root path to managed state. This absent-leaf rule never infers an empty file, never accepts a symlink or special object, and does not make a missing parent hierarchy valid.

Such routing is static and **system-scoped**. Persistent bindings deliberately traverse:

```text
state/system/current
```

so a later system-profile switch is observed without rewriting every installed package.

`var/` never becomes a dynamic user-state router.

## Concurrent profiles and package mutable-state boundary

Independent managed shells and ordinary managed child processes may select different registered system profiles and logical user identities simultaneously without changing global `current` symlinks. `m_STATE_SYS_DIR` and `m_STATE_USER_DIR` are validated selected roots consumed through canonical `state-path`; the inherited envelope binds selection to runtime root, effective UID and registry and fails closed when tampered with.

Installed package `var/` links are still **static and system-scoped**, following `state/system/current`. They do not magically become process-local or user-state routers. When a selected context's system profile would route an installed concrete's mutable `var/` path to a different global profile, the normal package launcher rejects that concrete **before upstream execution**. A specific upstream-supported adapter or validated per-profile view is required to enable that consumer safely; without one, incompatibility is an explicit error. The package's HOME/config state for supported profile-local launches continues to use the chosen `state-path` scope and service State Instance.

The above is the scope of the integrated generalized-context contract; it does not assert universal automatic profile migration for every upstream product. Host-service registration binds a separate authorized service profile, and TLS CA authorization remains protected host/system state, not a user preference.

## Git boundary

Operational state is not product source. In particular user state remains ignored by the product repository and is not committed merely to establish a binding/default identity.

## Invariants

```text
STATE-01  state/ is the single semantic mutable-state root
STATE-02  scopes are system and user
STATE-03  owners are sys, ai and pkg
STATE-04  identity precedes area
STATE-05  bootstrap initializes compatibility roots then validates process-local context profile/user selection
STATE-06  logical user identity is not derived from host-id/UID; account preferences are separately owned by effective UID
STATE-07  legacy user/current symlink is not the effective selector for a generalized managed context
STATE-08  absent a saved/explicit user selection, logical user identity is default
STATE-09  user identity and user binding do not establish authentication/security identity
STATE-10  state-path remains a pure resolver and creates no state
STATE-11  package State Instance uses @! in the identity
STATE-12  package HOME is resolved through state-path at launch
STATE-13  installed package var routing is static/system-scoped through legacy system/current; incompatible context launches fail closed
STATE-14  consumers do not duplicate deep state layout knowledge
STATE-15  an explicitly declared absent var leaf denotes an initially empty directory only with valid parents
STATE-16  system package provider bindings live under package conf/binding/<facility>, not .m
STATE-17  system-hosted package services use system package State Instance equal to service identity, never POSIX account as m user scope
STATE-18  system sys/environment cache is derived and not provider authority
STATE-19  system profiles are selected only from a validated installation-managed inventory
STATE-20  managed processes select system/user profiles independently; global current links are not mutated by context
```
