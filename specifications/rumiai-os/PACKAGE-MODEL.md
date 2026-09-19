# RumiAI OS — Package model

Status: **Current / normative**  
Updated: 2026-09-18

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
pkg provider default [args...]
pkg provider bind [args...]
```

The dispatcher is intentionally generic. For every public subcommand `<name>`, the command library:

```text
lib/sys/sh/pkg/pkg-<name>.lib.sh
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

A catalog range anchor is ordering metadata, not by itself a request to install or download that exact version. Repository comparison logic must therefore be able to order a syntactically valid historical anchor without treating current upstream availability as a prerequisite when the provider's version ordering can be determined locally. Concrete version resolution and artifact resolution remain responsible for enforcing actual upstream availability and integrity.

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

Package identity and facility identity are distinct contracts:

- a concrete package identity names the concrete software distribution/provider being installed; it must not be replaced by the generic name of one capability merely because the package provides that capability;
- a package may declare one or more facilities independently of its package name;
- different installed packages may declare the same facility and compatibility level simultaneously;
- installing another provider of an already-provided facility is valid and must not fail merely because the facility already has a provider.

Provider multiplicity therefore belongs to the normal installed state.

### Provider selection

Provider installation and provider selection are separate responsibilities.

For each facility required by a consumer, the effective provider selector is determined in this order:

1. an explicit binding for that consumer and facility, when present;
2. otherwise the default provider selector for that facility;
3. otherwise no provider is selected and dependency resolution fails.

There is no implicit fallback to "the only installed provider". Installing or removing an unrelated additional provider must not silently change a consumer's provider-selection semantics.

A consumer binding is mutable independently of package installation and may be changed later. Removing a binding restores inheritance from the facility default.

Package default and facility default are distinct selections:

- a package default selects the current concrete version within one package/platform class;
- a facility default selects which provider selector supplies that facility globally.

### Provider selectors

A provider selector expresses intent rather than necessarily storing an already-resolved concrete identity.

A provider selector uses the package-spec shape:

```text
<package>
<package>@<version>
<package>!<osarch>
<package>@<version>!<osarch>
```

Selector semantics are:

- when version is omitted, the provider package's current/default concrete for the applicable platform class is resolved when the selector is used;
- when version is present, that provider version is pinned until the selector is changed;
- when osarch is omitted, the consumer's applicable platform class is used;
- when osarch is present, it must be eligible for the consumer.

Resolution of a selector must validate that the selected installed concrete declares the required facility and satisfies the consumer's compatibility constraints.

A resolved concrete may be cached as derived state, but such a cache is not authoritative over the configured selector.

### Dependency installation policy

The baseline package-install contract does not automatically install missing dependency providers and does not silently choose a provider from the catalog.

When installing a package with facility dependencies, every dependency must already have an effective provider selector that resolves to an installed compatible provider. Otherwise installation fails.

Automatic provider discovery, preference policy and transitive dependency installation may be added later as a separate resolution capability; their absence does not weaken the baseline dependency contract.

### Runtime provider application

A consumer with no explicit binding inherits the facility default at runtime. A consumer with an explicit binding uses that selector instead.

Runtime launch must resolve and validate the effective selector before using the provider so that mutable bindings, mutable facility defaults and package-default changes are observed according to selector semantics.

A facility provider may require a facility-specific runtime projection, including commands and environment needed to consume that facility. The facility default owns global command publication for that facility. A consumer-specific binding may override provider selection for a launched consumer through the package launcher without changing the global facility command publication.

The public provider-selection configuration surface is:

```text
pkg provider default <facility>
pkg provider default <facility> <provider-selector>
pkg provider default -u [--] <facility>

pkg provider bind <consumer> <facility>
pkg provider bind <consumer> <facility> <provider-selector>
pkg provider bind -u [--] <consumer> <facility>
```

The query forms print the configured selector. The set forms replace the configured selector. The unset forms remove it; unsetting a consumer binding restores inheritance from the facility default.

Provider-selection configuration is system-scoped authoritative configuration.

A consumer binding is stored directly in that consumer package's system `conf` area as:

```text
<consumer-package-conf>/binding/<facility>
```

The binding file contains exactly one provider selector followed by newline. If the binding file is absent, the consumer inherits the system facility default. Binding files are configuration, not installed-package material, and changing or removing one does not reinstall or rewrite the consumer package.

Facility defaults belong to the package subsystem's system `conf` area. Their concrete pathname layout is owned by the package subsystem and must not be reconstructed by consumers.

Provider runtime application is owned generically by the launcher. Package command wrappers and package environment scripts must not contain provider-specific dependency logic such as Java-provider lookup, concrete binding reads or hardcoded `JAVA_HOME` construction.

Provider packages describe the commands and environment values exported by each facility through declarative package metadata. The launcher resolves the effective provider selector, validates the selected concrete against the consumer dependency, interprets that facility metadata and applies the resulting command-path and environment projection before launching the consumer.

Launch-time environment precedence is:

```text
consumer package environment
→ selected provider facility projections
→ user package environment
→ exec
```

Provider facility command directories are prepended while applying projections, so selected-provider commands precede the consumer's inherited/package PATH. The user package environment remains the final configuration layer and may explicitly override projected environment when desired.

A facility-specific projection is data, not executable provider-specific shell logic.

The catalog projection schema is:

```text
facility-cmd/<facility>/<command>
facility-env/<facility>
```

A `facility-cmd` entry is a scalar text file containing exactly one relative pathname, followed by newline, to an executable inside the provider useful root. The entry name is the command name exposed by that facility. Integration validates that the target remains inside the useful root and materializes a provider-private command projection for the facility. When a selected provider is applied to a consumer, that facility command directory is prepended to the consumer process PATH.

A `facility-env/<facility>` entry is a text file containing one or more tab-separated records:

```text
<variable><TAB><descriptor>
```

Records are sorted by variable name and each variable appears at most once. `<variable>` is a valid POSIX environment-variable name. The descriptor uses one of these forms:

```text
root
root-path <relative-path>
literal
literal <value>
```

`root` sets the variable to the provider useful-root pathname. `root-path` sets it to a pathname below that root after containment validation. `literal` sets an ordinary literal value; the form without a value denotes the empty string. No shell expansion or evaluation is performed on projection metadata.

Every facility referenced by `facility-cmd` or `facility-env` must also be declared by the package's `facility` metadata. Projection metadata is validated and interpreted generically by the package subsystem; provider-specific shell code is not part of the projection contract.

Facility-specific consumer runtime projection is distinct from global facility command publication.

A configured facility default publishes that facility's commands through the existing technical external-command roots:

```text
generic provider package class
    bin/ext/<command>

osarch-specific provider package class
    bin/ext-<osarch>/<command>
```

The publication follows provider-selector intent:

- an unversioned provider selector publishes through the corresponding provider package-default selector, so changing the provider package default changes the concrete command reached without changing selector intent;
- a versioned provider selector publishes through the pinned provider concrete;
- an explicitly osarch-qualified provider selector publishes only for that osarch class;
- a selector without an osarch may publish independently for each provider package class that currently has a resolvable package default.

The set of public command names is derived from the selected concrete's materialized `facility-cmd/<facility>` projection. Publication is reconciled whenever the facility default changes and whenever a provider package-default transition can change the selected concrete or its facility command set.

Global publication must not overwrite an unrelated pathname in an external-command root. An existing pathname may be replaced or removed as part of a facility-default transition only when it is the exact projection owned by that same facility. A collision causes the selecting mutation to fail rather than silently stealing another package/facility command name.

Consumer-specific bindings never alter global facility command publication.

`facility-env` remains a consumer-launch projection. Configuring a facility default does not inject those environment variables into the ambient `m` bootstrap, an already-running parent process or a managed shell merely because the default exists. When a package consumes the facility, the package launcher applies the selected provider environment according to the runtime precedence defined above.

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
PKG-13  concrete package identity names the installed distribution/provider, not a generic facility
PKG-14  facility declarations are independent of package identity
PKG-15  multiple installed providers of the same facility/compatibility are valid
PKG-16  explicit consumer binding overrides facility default; absent both, dependency resolution fails
PKG-17  provider selectors use package-spec grammar; omitted version follows package default and explicit version pins
PKG-18  pkg install does not auto-install or silently choose missing dependency providers
PKG-19  runtime re-resolves and validates mutable provider selection before provider use
PKG-20  pkg provider configures facility defaults and per-consumer bindings
PKG-21  provider-selection configuration is system-scoped authoritative conf state
PKG-22  provider runtime projection is declarative facility metadata interpreted generically by launcher
PKG-23  consumer bindings live in system package conf at binding/<facility> and contain one provider selector
PKG-24  facility-cmd and facility-env are declarative provider projection metadata, never provider shell code
PKG-25  facility command targets remain inside the provider useful root and are projected through PATH
PKG-26  facility environment metadata uses root, root-path or literal typed scalar values without shell evaluation
PKG-27  a facility default publishes facility commands through existing bin/ext or bin/ext-<osarch> roots according to provider-selector intent
PKG-28  global facility command publication never silently overwrites unrelated external-command paths and is reconciled on relevant facility/package-default transitions
PKG-29  consumer-specific bindings do not alter global facility command publication
PKG-30  facility-env is consumer-launch projection and is not injected globally into the ambient m bootstrap or managed shell merely because a facility default exists
```
