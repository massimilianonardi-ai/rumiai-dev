# RumiAI OS — Package model

Status: **Current / normative**  
Updated: 2026-09-17

This document defines the current semantic contract of the `m` package subsystem without duplicating implementation internals that belong in `rumiai-os`.

## Ownership

`pkg` belongs to the technical `m` substrate.

Package definition/catalog data live in the separate:

```text
pkg-catalog
```

repository. Runtime package logic lives in `rumiai-os` under the `m` layer.

## Public command

The public package command is:

```text
pkg
```

Current public subcommands include:

```text
pkg install <package>...
pkg uninstall <package>...
pkg versions [args...]
pkg default [args...]
```

The dispatcher is intentionally generic. For every public subcommand `<name>`, the command library:

```text
lib/sys/sh/pkg-<name>.lib.sh
```

exposes the command entrypoint:

```text
pkg_<name>
```

Command-specific implementation helpers must adapt to this interface; the dispatcher must not accumulate per-subcommand naming exceptions.

Invalid command/subcommand usage is a CLI error and must not be silently reinterpreted.

## Real composed pipeline

Package behavior is composed from real package responsibilities such as:

```text
catalog/package definition
repository adapter
version/stream/range selection
artifact resolution
integrity metadata
download
extraction/materialization
integration
current/default binding
launcher/runtime state
```

Those responsibilities are implemented by `m`; they are not independent fakeable layers for a test that claims to validate the composed public command.

A behavioral test of `pkg install` must execute the real public command against the real components/pipeline required by the property claimed, under `TESTING.md`.

## Package store

The package store root is:

```text
$m_PKG_DIR=$m_ROOT/pkg
```

Concrete installed package versions live beneath the managed package store and expose their useful root/command integration through the package subsystem.

Consumers must not assume private integration paths beyond a current documented contract.

## Catalog and repository adapters

Package definitions describe how a package is resolved/integrated. Repository-specific behavior belongs behind repository adapters rather than leaking provider-specific assumptions into the generic package orchestration.

The current catalog is external to `rumiai-os`; the exact package set and package-specific definitions are facts of the current `pkg-catalog` revision and must be inspected there when needed.

Do not duplicate package catalog contents in `rumiai-dev` as a second editable source of truth.

## Installation

`pkg install` owns orchestration of the real install path.

For a multi-operand invocation, installation is best-effort per operand. An operand that is syntactically invalid, unavailable, already installed or otherwise not installable does not prevent later independently installable operands from being attempted. Each failed operand emits an error diagnostic. The overall command succeeds only when every requested operand succeeds; a partially successful batch returns status `1`. Status `2` is reserved for a globally invalid invocation rather than for one bad operand inside an otherwise processable batch.

If the resolved concrete package identity already exists as an installed concrete, `pkg install` does not reinstall or replace it. That operand fails with an `already-installed` diagnostic identifying both the installed concrete identity and the current/default concrete identity for the same package/platform class when one exists. Other operands in the same invocation continue to be processed.

The generic pipeline must keep provider-specific discovery/resolution behind the applicable adapter and use the generic download/extract/integration facilities where their contracts apply.

Artifact integrity information supplied by the package definition/adapter must be enforced by the current package contracts rather than bypassed for convenience.

A package-specific exception belongs in the package definition/adapter/integration boundary that owns it, not as an accidental special case in unrelated generic code.

## Uninstall, versions and default

`pkg uninstall`, `pkg versions` and `pkg default` are parts of the public package surface and must preserve the contracts protected by current implementation/tests.

The package manager must not infer a new public semantic merely from an implementation shortcut; changes to these interfaces require a current specification update.

## Launch model

Integrated package commands execute through the package launcher contract.

For a launched package, the launcher:

- identifies the concrete managed package command/version from the real command pathname;
- validates that the useful root/command target belongs to the managed package store;
- resolves user package `home` and `conf` through `state-path`;
- creates/validates the package HOME as needed;
- exports that HOME to the process;
- applies package-level environment materialization when present;
- applies user package environment from `<package-conf>/.m/env` when present;
- executes the real target command with the caller arguments.

The launcher does not create a second package-state model.

## Package state

Mutable package state is resolved through:

```text
state-path <scope> pkg <package> <area> [<state-instance>]
```

Package State Instance uses:

```text
<package>@!<instance>
```

inside the state identity.

Package HOME is selected at launch through user-scoped state.

RumiAI-managed package configuration uses the reserved:

```text
.m/
```

subnamespace inside package `conf`.

## `var/` compatibility

Package-local `var/` exists only for upstream software that requires mutable paths inside its installation tree.

It is static and system-scoped. It may route to state under:

```text
state/system/current
```

and must never become a dynamic path into user state.

## Defaults

Factory/default state distributed as part of package integration is distinct from current mutable state, State Instance and `var/` routing.

Default materialization must not overwrite already-authoritative mutable state merely because a package is reinstalled or a default exists.

## Dependencies/facilities

Dependency/provider resolution belongs to the package subsystem contract. A dependency concept must not be duplicated into a second service/build/runtime graph unless a new requirement establishes that separate responsibility.

## `mk` boundary

`mk` is the source-materialization facility. It may be used when source must be transformed into a useful root, but it is not a second package manager and does not replace package selection/catalog/integration semantics.

See `MK-SOURCE-MATERIALIZATION.md`.

## Package-specific truth

For questions such as:

```text
which URL/provider does package X use?
which archive is selected?
which platform variants exist?
what exact integration descriptor does X have?
```

inspect the current `pkg-catalog` definition and the current relevant `rumiai-os` adapter. Do not infer those facts from old decision documents.

## Invariants

```text
PKG-01  pkg belongs to m
PKG-02  pkg-catalog is the catalog-data source, not rumiai-dev
PKG-03  generic orchestration does not absorb provider-specific adapter semantics
PKG-04  public pkg behavior is tested through the real composed command path
PKG-05  package store root is m_PKG_DIR
PKG-06  package launch validates/uses the managed concrete package target
PKG-07  package HOME/conf are resolved through state-path
PKG-08  .m is reserved for RumiAI-managed package configuration
PKG-09  State Instance uses @! in package state identity
PKG-10  var routing is static and system-scoped, never dynamic user routing
PKG-11  factory/default state is distinct from mutable current state
PKG-12  mk materialization does not replace package management semantics
```
