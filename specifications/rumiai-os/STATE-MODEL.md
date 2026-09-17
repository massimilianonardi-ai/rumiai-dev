# RumiAI OS — State model

Status: **Current / normative**  
Updated: 2026-09-17

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

`m` exports readonly semantic roots:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/current
m_STATE_USER_DIR=$m_STATE_DIR/user/current
```

These values are semantic pathnames. Bootstrap does not canonicalize selector targets and does not require the selectors to exist merely to start the technical runtime.

## System state

System state is selected through:

```text
state/system/current -> profile/<profile>
```

`current` is operational state managed outside ordinary bootstrap.

Consumers using system state resolve paths under the semantic `system/current` root. They do not copy the target profile pathname into their own contract.

Changing the system profile is an administrative concern; no ordinary consumer should reconstruct profile selection semantics.

## User state

The `user` scope is an `m` namespace, not POSIX account identity.

The only explicit global user binding pathname is:

```text
state/user/current
```

An explicit binding exists only when that pathname is a symbolic link.

When it is a symlink, `state-path user ...` preserves the semantic `state/user/current` pathname.

When it is not a symlink, the implicit user state root is:

```text
state/user/default
```

`default` is not an authenticated principal, not a POSIX user mapping and not a security boundary.

The current `m` state model does not derive user identity from:

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

RumiAI-managed package configuration lives under the reserved `.m/` namespace inside package `conf`, for example:

```text
<package-conf>/.m/env
```

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

Such routing is static and **system-scoped**. Persistent bindings deliberately traverse:

```text
state/system/current
```

so a later system-profile switch is observed without rewriting every installed package.

`var/` never becomes a dynamic user-state router.

## Git boundary

Operational state is not product source. In particular user state remains ignored by the product repository and is not committed merely to establish a binding/default identity.

## Invariants

```text
STATE-01  state/ is the single semantic mutable-state root
STATE-02  scopes are system and user
STATE-03  owners are sys, ai and pkg
STATE-04  identity precedes area
STATE-05  bootstrap exports unresolved semantic current roots
STATE-06  bootstrap does not derive user identity from host-id/UID
STATE-07  only a user/current symlink is an explicit user binding
STATE-08  absent explicit binding, user state resolves under user/default
STATE-09  user binding is not authentication/security identity
STATE-10  state-path is the canonical public resolver and has no side effects
STATE-11  package State Instance uses @! in the identity
STATE-12  package HOME is resolved through state-path at launch
STATE-13  package var routing is static, system-scoped and follows system/current
STATE-14  consumers do not duplicate deep state layout knowledge
```
