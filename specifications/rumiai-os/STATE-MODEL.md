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

`m` exports semantic roots for the process's effective context:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/<effective-profile>
m_STATE_USER_DIR=$m_STATE_DIR/user/<effective-logical-identity>
```

The active context is process-local and is validated before bootstrap uses it.
If no explicit context envelope is inherited, the managed baseline is used; the
bootstrap does not read or mutate the legacy `current` selectors to choose an
identity. The `state-path` command remains a pure resolver and does not create
directories.

## System state

Legacy global system state is selected through:

```text
state/system/current -> profile/<profile>
```

`current` is legacy operational state. Generalized `context` selection uses a
registered profile identity without changing this selector.

Consumers using system state resolve paths under the process's semantic
`m_STATE_SYS_DIR` root. They do not copy the target profile pathname into their
own contract.

The installation-managed registry is the authority for selectable system
profiles and declares exactly one baseline. A directory or symlink alone does
not make a profile selectable. Changing the legacy system profile remains an
administrative concern; ordinary consumers use the validated process context.

## User state

The `user` scope is an `m` namespace, not POSIX account identity.

The legacy global user binding pathname is:

```text
state/user/current
```

The legacy selector is recognized only by explicit `context --migrate-legacy`.
Ordinary `state-path user ...` resolution does not read, follow or mutate it. If
no context identity is selected, the baseline user state root is:

```text
state/user/default
```

`default` is not an authenticated principal, not a POSIX user mapping and not a security boundary.

Generalized context supports canonical logical user identities as direct real
directories under `state/user/`. `default` is the baseline identity. These
identities are distinct from POSIX accounts and do not grant authority. A
process resolves its selected identity directly and never changes
`state/user/current`. The current `m` state model does not derive logical user
identity from:

```text
UID
username
host-id
$HOME
hostname
```

Physical file permissions remain governed by the host and by responsibility-specific code; the user binding itself is not authentication.

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

## Accepted concurrent-context state boundary (future integration)

Independently running managed shells and ordinary child processes select their
own registered system profile and canonical logical user identity without
changing either global `current` selector. Logical `user` selection remains
separate from authenticated POSIX account authority. The one-time explicit
`context --migrate-legacy` operation may import only validated direct legacy
selector values; it does not infer identities by directory scanning or change
the legacy selectors.

The current static, system-scoped package `var/` links cannot express two different per-process system profiles for the same installed concrete. A profile-aware package launch must use a verified upstream state-path adapter or an already prepared compatible profile-specific execution/state view; otherwise it rejects the incompatible selection **before** launching, without silently following another process's/global profile. Ordinary context activation does not regenerate package views.

The `state-path` resolver and package launcher consume validated context identity.
Legacy consumers that cannot honor the selected profile fail closed. The
accepted behavior does not make unsupported upstream packages profile-aware;
each adapter requires real consumer verification.

## Git boundary

Operational state is not product source. In particular user state remains ignored by the product repository and is not committed merely to establish a binding/default identity.

## Invariants

```text
STATE-01  state/ is the single semantic mutable-state root
STATE-02  scopes are system and user
STATE-03  owners are sys, ai and pkg
STATE-04  identity precedes area
STATE-05  bootstrap exports semantic roots for the effective validated context
STATE-06  logical user identity is distinct from POSIX account identity
STATE-07  context selection does not mutate the legacy user/current selector
STATE-08  absent explicit context selection, user state resolves under user/default
STATE-09  user binding is not authentication/security identity
STATE-10  state-path is the canonical public resolver and has no side effects
STATE-11  package State Instance uses @! in the identity
STATE-12  package HOME is resolved through state-path at launch
STATE-13  package var routing is static, system-scoped and follows system/current
STATE-14  consumers do not duplicate deep state layout knowledge
STATE-15  an explicitly declared absent var leaf denotes an initially empty directory only when its parent hierarchy is valid
STATE-16  system package provider bindings live at <package-conf>/binding/<facility>, not under .m
STATE-17  system-hosted package services use system package State Instance equal to service identity rather than mapping POSIX accounts into state/user
STATE-18  system sys/environment cache owns regenerable global execution-environment snapshots and is never authoritative provider configuration
STATE-19  selectable system profiles come only from the installation-managed registry and its declared baseline
STATE-20  logical user identities are canonical direct state/user directories; the identity itself grants no host authority
STATE-21  context --migrate-legacy imports only validated direct selector values and never scans or changes legacy selectors
STATE-22  package var paths that cannot honor the effective system profile fail closed before launch
```
