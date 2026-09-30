# RumiAI OS — Package model

Status: **Current / normative**  
Updated: 2026-09-27

This document defines the current semantic contract of the `m` package subsystem without duplicating implementation internals that belong in `rumiai-os`.

## Ownership

`pkg` belongs to the technical `m` substrate.

Package definitions, provider-independent facility contracts and related catalog data live in the separate:

```text
pkg-catalog
```

repository. Runtime package logic lives in `rumiai-os` under the `m` layer.

The catalog has two disjoint top-level semantic areas:

```text
pkg-catalog/
    pkg/<package>/...
    facility/<facility>/...
```

`pkg/` contains installable package definitions. `facility/` contains provider-independent facility-contract definitions. The two namespaces are intentionally separate: a facility definition is never an installable package merely because both are catalog data. Both are read from the same immutable catalog revision/snapshot, so a package/provider realization and the facility contract it claims to satisfy are revision-coupled without a second catalog authority. The exact contents of `facility/<facility>/` are defined only by the promoted facility-contract meta-model; this layout decision does not predefine that still-open schema.

## Public command

The public package command is:

```text
pkg
```

Current public subcommands include:

```text
pkg install <package-spec>...
pkg uninstall <package-spec>...
pkg versions [args...]
pkg depend <package-spec>...
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

A requested package name is resolved only beneath:

```text
pkg/<package>
```

inside the selected `pkg-catalog` snapshot. The `facility/` area is therefore outside the installable-package namespace and must never be enumerated or interpreted as a package merely because it is present in the same repository.

Each installable package may expose one or both of these package streams:

```text
pkg/<package>/<osarch>/...
pkg/<package>/all/...
```

For a requested/current target, an exact `<osarch>` stream has precedence. When
that exact stream is absent, `all` is the platform-independent fallback stream.
A package installed from `all` has platform-independent concrete identity and
therefore does not gain an `!<osarch>` suffix merely because resolution happened
on a particular host. The historical name `catalog` is not a package stream name
and has no fallback semantics.

Package definitions describe how a package is resolved/integrated. Repository-specific behavior belongs behind repository adapters rather than leaking provider-specific assumptions into the generic package orchestration.


A repository `type` is a **complete default adapter**. Selecting a type must be
sufficient to provide that type's normal version and artifact behavior; optional
artifact overrides do not turn the type into a partial adapter.

A repository descriptor may replace specific artifact-resolution responsibilities
through trusted typed subdescriptors:

```text
repository/
    type
    ...
    download/      # optional
        type
        <type-specific declarative fields>

    metadata/      # optional
        type
        <type-specific declarative fields>
```

An absent override means "use the repository type's default behavior" for that
responsibility. A present override replaces only its own responsibility; all
other behavior, including version discovery/order/exact-release semantics,
continues to come from the repository type. Repository types may internally
reuse the same trusted handler mechanisms without requiring those mechanisms to
be exposed as catalog overrides.

Override metadata is inert declarative data. Every supported override type has a
closed schema implemented by trusted `m` package-subsystem code. Catalog data must not
supply shell code, callbacks, arbitrary expressions, executable parsers or an
open-ended property bag.

The current download override type is:

```text
template-url
```

It resolves a deterministic artifact name and HTTPS URL from closed templates.
The current template vocabulary is deliberately small: `{version}` is accepted
for artifact-name templates; URL templates may additionally use the already
resolved `{name}`. Platform/vendor spelling remains ordinary stream-specific
catalog data rather than creating a second generic os/arch translation system.

The current metadata override types are:

```text
checksum-sidecar
checksum-manifest
sourceforge-rss
```

They resolve authoritative artifact metadata through their own closed schemas.
`checksum-sidecar` supports two closed record formats: `digest-name`, which
requires exactly one checksum record bound to the resolved artifact name, and
`digest-only`, which requires exactly one checksum-only record from an
artifact-specific sidecar URL. `checksum-manifest` selects the checksum for
exactly the resolved artifact name. These checksum handlers also obtain a
positive byte size for the resolved download. `sourceforge-rss` selects the
RSS entry for the exact resolved download URL and obtains its positive byte size
and digest.

The existing range value `digest_type` remains the required integrity
**algorithm** where applicable (for example `md5`, `sha256` or `sha512`).
It is independent of the metadata-handler type and must not be overloaded to
select an override implementation.

Regardless of which default/override mechanisms produced it, artifact resolution
converges to the same canonical artifact descriptor consumed by `pkg-download`.
The generic downloader therefore remains unaware of repository type, override
type and upstream metadata protocol.

Current package-library physical organization keeps public subcommand entrypoint libraries and cross-cutting package orchestration directly under `lib/sys/sh/pkg/`. Internal facility/dependency libraries live under `lib/sys/sh/pkg/facility/`. Repository-specific upstream adapters live under `lib/sys/sh/pkg/repository/`. Physical grouping does not change library leaf identity or manual-topic identity. `pkg-provider.lib.sh` remains directly under `lib/sys/sh/pkg/` because it is both the public `pkg provider` subcommand entrypoint and the provider-selection API; internal facility-contract responsibilities must not be added to it merely to avoid creating appropriately owned internal libraries.

A catalog range anchor is ordering metadata, not by itself a request to install or download that exact version. Repository comparison logic must therefore be able to order a syntactically valid historical anchor without treating current upstream availability as a prerequisite when the provider's version ordering can be determined locally. Concrete version resolution and artifact resolution remain responsible for enforcing actual upstream availability and integrity.

The current catalog is external to `rumiai-os`; the exact package set and package-specific definitions are facts of the current `pkg-catalog` revision and must be inspected there when needed.

Do not duplicate package catalog contents in `rumiai-dev` as a second editable source of truth.

## Installation

`pkg install` owns orchestration of the real install path.

For a multi-operand invocation, installation is best-effort per operand. An operand that is syntactically invalid, unavailable, already installed or otherwise not installable does not prevent later independently installable operands from being attempted. Each failed operand emits an error diagnostic. The overall command succeeds only when every requested operand succeeds; a partially successful batch returns status `1`. Status `2` is reserved for a globally invalid invocation rather than for one bad operand inside an otherwise processable batch.

If the resolved concrete package identity already exists as an installed concrete, `pkg install` does not reinstall or replace it. That operand fails with an `already-installed` diagnostic identifying both the installed concrete identity and the current/default concrete identity for the same package/platform class when one exists. Other operands in the same invocation continue to be processed.

The generic pipeline must keep provider-specific discovery/resolution behind the applicable adapter and use the generic download/extract/integration facilities where their contracts apply.

A resolved artifact descriptor contains exactly one artifact name, exactly one positive
expected size, optional integrity digest metadata, and **one or more ordered URL
candidates** for the same artifact. Repository adapters own provider-specific mirror
discovery/selection and candidate ordering; generic download code does not encode
SourceForge, GitHub or another upstream's mirror policy.

`pkg-download` attempts URL candidates in descriptor order. A candidate is accepted
only after the transferred file satisfies the descriptor's expected size and, when a
digest is present, the expected digest. A failed transfer or failed size/digest check
removes that candidate's partial output and may advance to the next candidate.
Success through a later candidate never weakens or bypasses the descriptor's
integrity requirements. If no candidate validates, the download fails.

Artifact integrity information supplied by the package definition/adapter must be enforced by the current package contracts rather than bypassed for convenience.

Package materialization supports ordinary single-format artifacts and two macOS installer-package forms:

```text
flat-pkg
dmg-pkg
```

Both forms materialize files from an Apple flat installer package **without running installer scripts or performing the package's system-install side effects**. The selected package range MUST provide exactly one scalar `component` value naming the primary component package as a basename with no path separators.

`flat-pkg` represents a flat macOS product installer package directly. Materialization expands the package with the host package tooling, selects the named component package and copies only that component's expanded `Payload` into package staging. Installer metadata, preinstall/postinstall scripts and other non-Payload content are not executed or materialized into the managed package root.

`dmg-pkg` represents an Apple disk image containing exactly one top-level flat installer package. Materialization first extracts the outer DMG, then expands that installer and extracts the named primary component's `Payload`.

A `flat-pkg` or `dmg-pkg` range MAY additionally provide one scalar `payload-root` relative pathname when the primary component Payload contains installer-only siblings or an intermediate staging prefix around the useful package tree. `payload-root` must be a non-empty relative pathname with no empty, `.` or `..` path component and must resolve to a real directory inside the extracted Payload. When present, only that directory's contents become primary package staging; Payload siblings outside it are discarded. When absent, the complete primary Payload becomes staging.

A `dmg-pkg` range MAY also contain:

```text
overlay/
    <controlled-name>/
        component
        payload-root    # optional
        target-root     # optional
```

Each overlay entry is declarative package data. `component` is one scalar component-package basename. Optional `payload-root` uses the same source-subtree rules as the primary component. Optional `target-root` is a safe relative directory pathname below package staging; when absent, the overlay targets the staging root. The selected overlay Payload/subtree is materialized independently and its direct entries are merged into that target directory. Overlay materialization MUST reject an existing destination entry rather than silently replace primary or earlier overlay content. Overlay entry order therefore carries no overwrite precedence. The normal useful-root normalization is applied once, after the primary component and all selected overlays have been materialized.

Component names, Payload-root selectors and overlay target paths are package-definition data; generic package code must not hardcode provider-specific component identities or Payload paths. Supplying `component` or `payload-root` for a format other than `flat-pkg` or `dmg-pkg`, supplying `overlay` for a format other than `dmg-pkg`, omitting the primary `component` for either installer-package form, selecting a Payload root outside an extracted component, using an unsafe overlay target, or producing an overlay collision is invalid package metadata/materialization.

These installer-package forms are host-specific materialization behind the package abstraction; they do not change package identity or state semantics. Mutable state exposed by software installed this way remains governed by the normal package HOME/conf/state model rather than being stored in the immutable package root.

A package-specific exception belongs in the package definition/adapter/integration boundary that owns it, not as an accidental special case in unrelated generic code.

## Uninstall, versions and default

`pkg uninstall`, `pkg versions` and `pkg default` are parts of the public package surface and must preserve the contracts protected by current implementation/tests.

The package manager must not infer a new public semantic merely from an implementation shortcut; changes to these interfaces require a current specification update.

## Launch model

Integrated package commands execute through the package launcher contract.

For a launched package, the launcher:

- identifies the concrete managed package command/version from the real command pathname;
- validates that the useful root/command target belongs to the managed package store;
- normally resolves user package `home` and `conf` through `state-path`;
- when invoked through the trusted system-service context owned by `srv`, resolves
  system package `home` and `conf` with State Instance equal to the service
  identity instead;
- creates/validates the selected package HOME as needed;
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

Package HOME is normally selected at launch through user-scoped state.

The system-host service path is the explicit exception: it reuses the same launcher
with `scope=system` and State Instance equal to the service identity. This does not
create a second launcher/state model, and ordinary package commands must not infer
system scope from POSIX UID, username or inherited HOME. The system-service launch
context is supplied only by the `srv` host-system path; filesystem permissions
remain the enforcement boundary for service-account access to prepared state.

`m`-managed package configuration uses the reserved:

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

Installed concrete package metadata is the source of truth for provider discovery: a concrete that materializes a valid `facility` declaration is discoverable directly from the managed package store. `pkg` does not require a second mutable provider-index registry to determine installed providers. Derived caches may be introduced only as non-authoritative acceleration and must never make stale index state block otherwise valid install, resolution or uninstall operations.

### Facility contract

A facility is a **provider-independent, substitutable capability contract** owned by the `pkg` subsystem.

The facility identity describes what a consumer may depend on independently of which concrete package provides it. A consumer requirement therefore names a facility and compatibility constraint, not a concrete provider package. A provider declaration states that one concrete package realizes that facility at the declared compatibility level and is subject to the facility contract for that level.

A facility is not defined by how many runtime objects it exposes. Its contract may require one or several typed declarative parts. A capability whose complete interoperable contract consists of one command may legitimately be a facility when provider substitution and provider-independent consumption are real requirements. Conversely, installing or globally linking an ordinary package command does **not** by itself create a facility or provider-selection layer.

The provider-independent contract, the provider's concrete realization of that contract and mutable provider-selection configuration are distinct classes of information:

```text
facility contract
    provider-independent semantics and compatibility

provider realization
    concrete package metadata that satisfies the contract

system conf
    mutable facility default, consumer binding and later selection policy
```

Mutable `conf` is not the authority for what a facility means. Changing a facility default or consumer binding selects another realization; it does not redefine the facility contract.

Provider-selector configuration remains private under the normal state permission
model by default. When `srv host system install` reconciles a service for a
different non-root execution account, it may prepare only the non-secret selector
metadata required by bootstrap and dependency resolution as read-only/traversable
for that runtime. This preparation must not grant that account mutation rights over
facility defaults, consumer bindings or enclosing authoritative configuration.

Facility contracts are extensible through typed declarative parts with defined generic semantics. They must not degrade into an arbitrary provider-specific property bag or executable configuration. Provider-specific shell logic is not a facility-contract mechanism.

`pkg` owns facility identity, compatibility/conformance validation, provider registration and selection, and interpretation or dispatch of provider realization metadata. When one typed part belongs to an already-existing subsystem responsibility, `pkg` delegates that operation to the owning subsystem rather than creating a parallel implementation or provider graph. For example, portable service process lifecycle remains owned by `srv`; project development/build lifecycle remains owned by `mk` where applicable.

The current facility model supports trusted command, environment and service parts. Additional typed parts require their own explicit generic semantics before providers may use them.

### Typed facility parts

A facility contract is a composition of trusted **typed parts**. The generic facility layer owns only the common envelope and conformance orchestration:

```text
facility/<facility>/<compatibility>/<part>/...
```

The content below `<part>/` belongs to that part type's schema. The generic layer must not force every part into one universal member/value format.

A supported part type is implemented by trusted `m` package-subsystem code. Catalog data cannot install executable validators, handlers or runtime logic. Unknown part types are invalid.

For each supported part type, the facility/provider layer defines:

```text
contract schema
provider-realization schema
mechanical conformance validation
```

The generic facility layer enumerates the parts of the exact facility contract, dispatches validation to the trusted handler for each part and rejects undeclared or unsupported provider realization data. It does not interpret type-specific command names, environment descriptors, lifecycle operations or equivalent domain data itself.

There is deliberately no universal runtime `apply` operation for facility parts. Runtime use belongs to the subsystem that owns the operation. Command projection, environment application and service lifecycle may therefore have different consumers without weakening the common facility contract.

The current supported contract part types are:

```text
cmd
env
service
```

For these types, the provider-independent contract contains the required names as regular marker files:

```text
facility/<facility>/<compatibility>/cmd/<command>
facility/<facility>/<compatibility>/env/<variable>
```

The `cmd/<command>` leaf follows the package command-name grammar. The `env/<variable>` leaf preserves the environment-variable identifier exactly and therefore uses the environment-name grammar, including uppercase letters and underscore, as a specific exception to the general lowercase controlled pathname rule. `PATH` remains excluded by the env-part contract.

The existing provider-realization surfaces remain authoritative for these types:

```text
facility-cmd/<facility>/...
facility-env/<facility>
```

They are not renamed merely for symmetry. The `cmd` handler owns command-name and executable-target conformance. The `env` handler owns environment-name and `root | root-path | literal` descriptor conformance; `PATH` remains invalid environment metadata.

The `service` part marks a facility as portable-service-capable under `srv`. Baseline service identity is exactly facility identity; no second service registry or service-provider namespace is introduced.

The exact baseline service contract is:

```text
facility/<facility>/<compatibility>/service/start
    package-command

facility/<facility>/<compatibility>/service/process
    foreground

facility/<facility>/<compatibility>/service/stop
    sigterm
```

These scalar values are trusted schema tokens, not provider-defined properties:

- `start = package-command` requires each provider to map service start to one ordinary command of that same provider package;
- `process = foreground` requires the provider command to remain the managed foreground process rather than self-daemonizing and abandoning `srv` process ownership;
- `stop = sigterm` delegates normal termination to generic `srv` SIGTERM lifecycle and does not require a provider-specific stop command.

The corresponding provider realization is:

```text
facility-service/<facility>/start
```

and contains exactly one package-command name. That command is lifecycle implementation mapping only; it does not become a consumer-visible `cmd` facility member unless the facility contract independently declares it under `cmd/`.

Service conformance validates the declarative shape, the package-command mapping and mechanically checkable target properties. Static validation cannot prove that an external process truly remains foreground or obeys SIGTERM correctly; those behavioral claims require real provider/service validation.

Runtime execution of the service part remains owned by `srv`. A global provider-backed `srv start <facility>` uses the configured system facility default; consumer bindings do not participate because there is no package consumer identity for that global lifecycle operation. After provider selection, `srv` must launch the start command belonging to that exact provider concrete rather than performing an unrelated PATH lookup. The normal package launcher remains responsible for package HOME, environment and dependency preparation.

Facility and provider definitions are **inert declarations**. Validating or reading them does not create a facility default, create a consumer binding, publish commands or export environment variables. Package-consumer runtime resolution may derive an unambiguous provider from installed validated declarations, but that read-only derivation creates no persistent selection state. Runtime application happens only when a consumer or owning subsystem actually uses the facility.

The `service` part uses the same trusted contract/realization/conformance boundary as `cmd` and `env`, while process execution remains owned by `srv`. Endpoint, readiness and health are not implied by service capability and are not fields of the baseline service part. A later provider-independent contract for one of those responsibilities must use its own explicit semantics rather than extending `service` into an arbitrary property bag.

### Facility compatibility levels

A facility compatibility value identifies one **exact provider-independent contract level** for that facility. Different compatibility levels of the same facility are not required to form a monotonic or backward-compatible lineage. A later/higher numeric level may preserve the previous surface, extend it, reduce it or change it substantially.

`pkg` therefore does **not** infer backward compatibility from numeric ordering and does not require a higher facility level to include the guarantees of a lower level.

A concrete provider declaration names the exact facility level realized by that provider. The provider realization is validated against the complete contract for that exact `<facility, compatibility>` pair.

A consumer requirement declares the set of compatibility levels it accepts by using the dependency constraint language. Exact constraints express exact acceptance; ordered constraints and combinations of constraints express ranges. For example:

```text
java =25
java >=17
java >=17 <26
```

The semantic correctness of such an acceptance range belongs to the package/catalog authors that declare the provider and consumer metadata. `pkg` evaluates the declared constraints; it does not attempt to prove that two facility levels are behaviorally backward-compatible.

Each published `<facility, compatibility>` contract is complete and self-contained. It is not interpreted as a delta inherited from another level. Its consumer-visible meaning is semantically immutable once published: changing required guarantees requires another compatibility level, while non-semantic editorial/catalog maintenance may leave the identity unchanged.

The baseline facility-contract model exposes only the required interoperable surface. Every member of the contract is mandatory for every provider that declares that exact level. Provider-specific extras remain outside that facility realization as ordinary package capabilities, or are represented by another facility when they deserve their own provider-independent substitutable contract. Optional facility members are not part of the baseline model.

Provider conformance is validated against the facility contract from the same immutable `pkg-catalog` snapshot that supplied the provider package definition. For the normal installation path, `pkg install` performs this conformance check after artifact extraction and before package-store mutation, while it simultaneously owns the exact snapshot, selected package range and extracted useful root. Integration then materializes only provider realization metadata that has passed that composed install-time boundary. Runtime provider selection/application does not reinterpret facility meaning from another catalog revision; it relies on installed validated provider declaration/realization and on the immutable meaning of the declared facility level.

Mechanical conformance validation proves only properties that can actually be established from the package artifact and declarative metadata. It must not be described as proof of the provider's full behavioral implementation of the external capability.

### Provider selection

Provider installation and explicit provider configuration are separate responsibilities.

For each facility required by a **package consumer**, runtime dependency resolution uses this precedence:

1. an explicit binding for that consumer and facility, when present;
2. otherwise the configured system facility default, when present;
3. otherwise deterministic implicit resolution from installed compatible provider concretes.

Implicit resolution is deliberately narrow. If exactly one compatible installed concrete exists for the consumer's applicable platform class, it is selected. If multiple compatible concretes all belong to the same provider package, that package's normal package default may disambiguate them when it resolves to one of those compatible concretes. Otherwise the requirement is ambiguous and resolution fails with the compatible candidates reported.

An explicit binding or facility default is authoritative intent. If it exists but is unavailable, invalid or incompatible, resolution fails rather than silently falling back to another installed provider.

This fallback does not install packages and does not establish persistent provider configuration. Adding another distinct compatible provider may therefore turn an otherwise implicit resolution into an explicit ambiguity instead of silently changing the selected provider.

A consumer binding is mutable independently of package installation and may be changed later. Removing a binding restores the facility default when one is configured, otherwise the deterministic implicit package-consumer rule applies.

Package default and facility default are distinct selections:

- a package default selects the current concrete version within one package/platform class and may disambiguate installed versions of that same provider package during implicit package-consumer resolution;
- a facility default explicitly selects which provider selector supplies that facility globally and remains required for global/non-package projection semantics.

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

Package distribution class and dependency-consumer platform class are distinct when
the consumer concrete came from the `all` stream. Such a concrete remains
platform-independent and has no `!<osarch>` suffix, but its dependencies are still
resolved for an applicable target platform. During `pkg install`, that platform is
the target osarch used for exact-stream selection before falling back to `all`.
At runtime, a platform-independent consumer concrete uses the active `m_OSARCH`.
An unqualified provider selector may therefore resolve to a matching
osarch-specific provider, with the normal generic-provider fallback, while an
explicitly osarch-qualified selector is eligible only when it matches that
applicable target. Dependency resolution does not add the target osarch to the
consumer's concrete identity.

A resolved concrete may be cached as derived state, but such a cache is not authoritative over the configured selector.

### Dependency installation policy

The baseline package-install contract does not automatically install missing dependency providers and does not choose a provider from the catalog.

Installation validates the package's dependency declarations as catalog metadata before artifact download, but current runtime satisfiability is **not** an installation precondition. A package may therefore be installed while one or more declared facilities are currently unavailable or ambiguous. The dependency declaration is materialized with the concrete and is resolved again when the consumer is actually launched.

After resolving the artifact descriptor but before artifact transfer, `pkg install` reports currently unsatisfied dependencies as warnings so the operator sees the facility, compatibility constraints and resolution reason before a potentially large download begins. The warning is informational: mutable runtime/provider state remains outside the artifact-install gate and is resolved again when the consumer is actually launched.

Automatic transitive dependency installation remains outside the baseline. Explicit provider bindings/defaults remain available when stable policy is desired, while deterministic implicit resolution handles the non-ambiguous installed-provider case without requiring redundant setup.

### Runtime provider application

A package consumer with an explicit binding uses that selector. Without a binding it uses the configured system facility default when one exists; when neither explicit surface exists it uses deterministic implicit installed-provider resolution according to the provider-selection rules above.

Runtime launch must resolve and validate the effective provider before using it so that mutable bindings, mutable facility defaults, package-default changes and changes to the installed compatible-provider set are observed according to their respective semantics.

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

The public read-only requirement query surfaces are:

```text
pkg requirement list <package-spec>
pkg requirement resolve <facility> <constraint>...
```

`pkg requirement list` resolves the requested package/version/platform definition from the current catalog and prints its declared dependency lines without downloading or extracting the package artifact. An empty successful result means that the selected definition declares no facility dependencies.

`pkg requirement resolve` is the global/non-package requirement query. It resolves only the configured **system facility default** through the normal global package-class/osarch semantics, validates that the selected installed concrete declares the requested facility and satisfies every supplied compatibility constraint, and prints that concrete provider identity on success. It deliberately does not use package-consumer implicit fallback because a non-package caller has no consumer-specific runtime projection path. A status-1 failure reports whether the facility default is unconfigured, configured but unresolvable, or resolves to an incompatible provider, together with the facility and requested constraints.

Neither query installs packages or mutates provider configuration. Status 1 means the requested catalog/requirement state cannot currently be resolved; status 2 means invalid invocation or syntax.

The public read-only dependency-planning surface is:

```text
pkg depend <package-spec>...
```

`pkg depend` resolves every explicit request and recursively discovers facility dependencies against one exact catalog snapshot. Requirements that share the same effective provider-selection bucket are collected before provider concretization so every constraint in that bucket must be satisfied by the selected provider. Consumer binding remains highest precedence, followed by the system facility default. Without either selector, the planner prefers a compatible provider already present in the current plan, then an unambiguous compatible installed provider, and only then an unambiguous compatible provider package from the same catalog snapshot. Multiple compatible provider packages are an ambiguity and are never silently ranked.

Catalog fallback is planning only: it may add a concrete provider identity to the returned plan when no compatible planned or installed provider exists and exactly one provider package can satisfy the requirement. It does not download, extract, integrate or install that provider. When the repository-selected current/latest version of the unique provider package satisfies the complete constraint set, that concrete is selected; otherwise the newest compatible catalog range anchor is used as the concrete version.

The returned dependency plan is deduplicated and dependency-first. Provider dependencies are themselves discovered recursively until the selected-provider set and requirement graph stabilize; cycles or a non-stabilizing/unsatisfiable plan fail rather than producing a partial order.

`pkg depend` prints only dependency concrete identities. The explicit requested roots are not part of its output unless the same concrete is also selected as a dependency node of another requested root. Every emitted dependency is an exact concrete package identity and therefore a valid install operand.

The public `pkg install <package-spec>...` command first validates the complete original request list syntactically. If any request is invalid, installation fails before dependency planning, catalog resolution or package-store mutation.

After successful validation, `pkg install` composes the two responsibilities directly:

```text
validate original requests
dependencies = pkg depend <original requests>
install sequence = dependencies + original requests
```

Dependency concretes are prepended to the untouched original request list. The dependency operands are therefore installed first, while requested roots retain their original package-spec form and are resolved by installation when reached. This keeps dependency discovery independent from requested-root installation and prevents a root package from disappearing merely because dependency planning changes.

`pkg depend` owns the catalog snapshot used to discover dependencies. Its snapshot is not shared state with installation. `pkg install` resolves each operand against its own installation snapshot; exact dependency concretes remain exact requests, while original non-concrete roots are resolved normally by the installer.

`pkg depend` does not mutate package/provider state. Catalog cache refresh and invocation-private snapshot materialization are permitted operational side effects. Recursive dependency installation is now part of the canonical `pkg install` pipeline.

The query forms print the configured selector. The set forms replace the configured selector. The unset forms remove it; unsetting a consumer binding restores inheritance from the facility default.

Provider-selection configuration is system-scoped authoritative configuration.

A consumer binding is stored directly in that consumer package's system `conf` area as:

```text
<consumer-package-conf>/binding/<facility>
```

The binding file contains exactly one provider selector followed by newline. If the binding file is absent, a package consumer uses the system facility default when configured and otherwise falls through to deterministic implicit installed-provider resolution. Binding files are configuration, not installed-package material, and changing or removing one does not reinstall or rewrite the consumer package.

Facility defaults belong to the package subsystem's system `conf` area. Their concrete pathname layout is owned by the package subsystem and must not be reconstructed by consumers.

Provider runtime application is owned generically by the launcher. Package command wrappers and package environment scripts must not contain provider-specific dependency logic such as Java-provider lookup, concrete binding reads or hardcoded `JAVA_HOME` construction.

For the currently supported command/environment parts of a facility realization, provider packages describe the concrete commands and environment values through declarative package metadata. The launcher resolves the effective provider using explicit binding/default precedence and the deterministic implicit fallback when neither is configured, validates the selected concrete against the consumer dependency, interprets the applicable realization metadata and applies the resulting command-path and environment projection before launching the consumer.

Launch-time environment precedence is:

```text
consumer package environment
→ selected provider facility projections
→ user package environment
→ exec
```

Provider facility command directories are prepended while applying projections, so selected-provider commands precede the consumer's inherited/package PATH. The user package environment remains the final configuration layer and may explicitly override projected environment when desired.

Command/environment facility projection is data, not executable provider-specific shell logic. Service realization is likewise declarative data, but is consumed by `srv` rather than projected into a consumer process.

The current provider-realization schema includes:

```text
facility-cmd/<facility>/<command>
facility-env/<facility>
facility-service/<facility>/start
```

These paths describe how one provider realizes command, environment and service portions of a facility; they are not the provider-independent facility-contract definition itself.

A `facility-cmd` entry is a scalar text file whose entry name is the command name exposed by that facility. It has exactly one of these realization forms:

```text
<relative-useful-root-executable>
package-command<TAB><ordinary-package-command>
```

The first form preserves the existing behavior: the relative pathname must resolve to an executable inside the provider useful root.

The `package-command` form delegates the facility member to one validated ordinary package command of the **same provider concrete**. The named package command must exist in that provider definition and its own `link` target must resolve to an executable inside the provider useful root. Integration materializes the facility member as a provider-private projection to that concrete's integrated package command; runtime never re-resolves the command through global PATH or another provider/package default.

This form is generic facility-command delegation. It does not make provider-specific wrapper semantics part of `pkg`: the ordinary package command remains responsible for adapting its concrete upstream software to the provider-independent facility command contract.

When a selected provider is applied to a consumer, its materialized facility command directory is prepended to the consumer process PATH.

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

`PATH` is reserved to facility command projection and MUST NOT be declared by `facility-env`. Provider command availability is expressed through `facility-cmd` and the package subsystem's PATH projection rather than by replacing PATH from environment metadata.

Every facility referenced by `facility-cmd`, `facility-env` or `facility-service` must also be declared by the package's `facility` metadata. Provider realization metadata is validated through the trusted facility-part semantics; provider-specific shell code is not a facility-contract mechanism.

For `cmd`/`env`, facility-specific consumer runtime projection and facility-default command publication consume the same declarative provider metadata. Consumer launch applies only the facilities required by that consumer. Configured system facility defaults currently publish `facility-cmd` globally; there is no current bootstrap-global application of `facility-env`. The `service` realization is not part of this PATH/environment projection path.

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

When a package consumes a facility, the package launcher continues to apply the selected provider environment according to the runtime precedence defined above.

## `mk` boundary

`mk` is the project development-lifecycle orchestrator of `m`. It may invoke package commands or consume package-provided tools/facilities as part of a project lifecycle, but it is not a second package manager and does not replace package selection, catalog, provider/facility, dependency-resolution or integration semantics owned by `pkg`.

The project-to-project `dependency` relation defined by the `mk` project model is distinct from package/facility dependency semantics owned by `pkg`. Where a build requirement is satisfied through a `pkg` facility/provider contract, `mk` consumes that existing contract through `pkg requirement resolve` rather than creating a parallel provider-selection graph.

A project is not a package consumer and does not receive a synthetic package-consumer binding. Project facility requirements use the configured system facility default, matching the existing global non-package-consumer selection pattern. The query is read-only and preserves the baseline package policy of no automatic provider installation or implicit provider choice.

See `MK.md`.

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
PKG-08  .m is reserved for `m`-managed package configuration
PKG-09  State Instance uses @! in package state identity
PKG-10  var routing is static and system-scoped, never dynamic user routing
PKG-11  factory/default state is distinct from mutable current state
PKG-12  mk lifecycle orchestration does not replace package-management, provider/facility or package-dependency semantics
PKG-13  concrete package identity names the installed distribution/provider, not a generic facility
PKG-14  facility declarations are independent of package identity
PKG-15  multiple installed providers of the same facility/compatibility are valid
PKG-16  package-consumer resolution uses explicit binding, then facility default, then deterministic implicit installed-provider resolution; explicit configured intent never silently falls back
PKG-17  provider selectors use package-spec grammar; omitted version follows package default and explicit version pins
PKG-18  pkg install discovers recursive dependency providers through pkg depend, prepends their exact concrete identities to the original request list and installs dependencies before requested roots
PKG-19  runtime re-resolves and validates mutable provider selection before provider use
PKG-20  pkg provider configures facility defaults and per-consumer bindings
PKG-21  provider-selection configuration is system-scoped authoritative conf state
PKG-22  provider runtime projection is declarative facility metadata interpreted generically by launcher
PKG-23  consumer bindings live in system package conf at binding/<facility> and contain one provider selector
PKG-24  facility-cmd, facility-env and facility-service are declarative provider realization metadata, never provider shell code
PKG-25  facility commands are projected through PATH and each realization is either an executable inside the provider useful root or a validated ordinary package command of the same provider concrete
PKG-26  facility environment metadata uses root, root-path or literal typed scalar values without shell evaluation
PKG-27  a facility default publishes facility commands through existing bin/ext or bin/ext-<osarch> roots according to provider-selector intent
PKG-28  global facility command publication never silently overwrites unrelated external-command paths and is reconciled on relevant facility/package-default transitions
PKG-29  consumer-specific bindings do not alter global facility command publication
PKG-30  facility-default environment projection is not currently integrated into the m bootstrap
PKG-33  PATH is reserved to facility command projection and is not a valid facility-env variable
PKG-34  a facility is a provider-independent substitutable capability contract owned by pkg
PKG-35  consumers depend on facility identity/compatibility rather than concrete provider identity
PKG-36  a provider declaration claims conformance and supplies the concrete realization required by the facility contract
PKG-37  ordinary package command publication does not by itself create a facility; a single-command facility is valid only when it represents a real provider-independent substitutable capability
PKG-38  facility contract, provider realization metadata and mutable provider-selection conf are distinct authorities
PKG-39  facility contracts extend through typed declarative parts with defined generic semantics, not arbitrary provider-specific executable metadata
PKG-40  delegation of a facility-contract part to srv, mk or another existing subsystem does not create a second provider/dependency model
PKG-41  facility-cmd, facility-env and facility-service are current provider-realization surfaces and are not the exhaustive definition of a facility
PKG-42  pkg-catalog separates installable package definitions under pkg/<package> from provider-independent facility definitions under facility/<facility>
PKG-43  package and facility catalog data used together are revision-coupled through the same pkg-catalog snapshot
PKG-44  package resolution never treats the facility catalog area as an installable package namespace
PKG-45  package repository adapters live under lib/sys/sh/pkg/repository and internal facility/dependency libraries live under lib/sys/sh/pkg/facility; public pkg subcommand entrypoint libraries remain directly under lib/sys/sh/pkg
PKG-46  each facility compatibility value identifies one exact complete contract level; levels of the same facility are not required to be monotonic or backward-compatible
PKG-47  pkg never infers backward compatibility from compatibility ordering; consumer exact/range constraints define the accepted level set
PKG-48  a concrete provider declares one exact facility compatibility level and is validated against that exact self-contained contract
PKG-49  published facility-level semantics are immutable; a change to required guarantees uses another compatibility level
PKG-50  the baseline facility contract contains required interoperable members only; provider-specific extras are not optional members of that facility
PKG-51  provider conformance validation uses the facility contract from the same pkg-catalog snapshot as the provider package definition
PKG-52  runtime provider resolution/application does not reinterpret facility contracts from another catalog revision
PKG-53  facility contracts use the generic envelope facility/<facility>/<compatibility>/<part>/..., while each trusted part handler owns the schema below <part>
PKG-54  supported facility part types are implemented by trusted `m` package-subsystem code; unknown catalog part types are invalid and catalog data never supplies executable handlers
PKG-55  the generic facility layer orchestrates contract/provider conformance but defines no universal runtime apply operation
PKG-56  cmd, env and service are supported facility contract part types; cmd/env retain facility-cmd/facility-env and service uses facility-service/<facility>/start as its provider realization
PKG-57  facility/provider definitions and conformance validation are inert: they do not create defaults/bindings or apply commands/environment/services merely by existing or being validated
PKG-58  env contract marker leaves preserve environment-variable identifiers and use the env-name grammar as an explicit exception to general controlled-path lowercase naming
PKG-59  baseline service identity is facility identity; a service-capable facility is identified by a service typed part and no second service registry/provider graph exists
PKG-60  baseline service contract semantics are start=package-command, process=foreground and stop=sigterm
PKG-61  a provider service start realization names one ordinary command of that same provider package and does not by itself add that command to the consumer-visible cmd facility surface
PKG-62  srv owns service process lifecycle; pkg owns service-part contract/provider conformance and provider selection
PKG-63  provider-backed service start launches the command from the exact selected provider concrete rather than re-resolving an unrelated PATH command
PKG-64  endpoint, readiness and health are outside the baseline service typed part
PKG-65  normal pkg install validates provider conformance against the exact catalog snapshot and extracted useful root before package-store mutation
PKG-66  integration materializes validated facility-service realization into the installed concrete for later srv consumption
PKG-67  global provider-backed srv lifecycle uses the system facility default for the service facility and does not consult consumer bindings
PKG-68  the trusted srv system-host launch path reuses the normal package launcher with system scope and State Instance equal to service identity; ordinary package launch remains user-scoped
PKG-69  provider selectors remain private by default; system-host reconciliation may expose only required non-secret selector metadata read-only/traversable to the service runtime without granting mutation rights
PKG-70  a resolved artifact descriptor carries one or more ordered URL candidates for the same artifact; repository adapters own provider-specific mirror candidate construction
PKG-71  pkg-download accepts a candidate only after expected size and configured digest verification, removes failed candidate output before fallback, and fails when no candidate validates
PKG-72  package stream resolution prefers pkg/<package>/<osarch> and falls back only to pkg/<package>/all; catalog is not a package stream name
PKG-73  packages resolved from the all stream use platform-independent concrete identity without an !<osarch> suffix
PKG-74  an all-stream consumer resolves dependencies against its applicable target osarch (install target or active runtime m_OSARCH) without adding that osarch to the consumer concrete identity
PKG-75  pkg requirement resolve is a read-only system-facility-default query that validates existing facility compatibility constraints and prints the selected concrete provider on success
PKG-76  project/non-package requirement queries do not create synthetic package-consumer bindings and do not install or implicitly select providers
PKG-77  flat-pkg and dmg-pkg materialization extract a named flat-installer component payload without hardcoding provider-specific component identity
PKG-78  component metadata is required only for flat-pkg and dmg-pkg and ordinary package state remains outside the immutable package root
PKG-79  optional flat-pkg/dmg-pkg payload-root selects one validated relative subtree as the useful package tree without hardcoding provider paths in generic code
PKG-80  dmg-pkg overlays add only explicitly selected component payloads at validated relative targets and reject overwrite collisions
PKG-81  flat-pkg and dmg-pkg materialization never execute installer scripts or perform installer-owned system integration side effects
PKG-82  package-command facility-cmd delegation resolves only to the ordinary package command of the exact same provider concrete and never re-resolves through global PATH or another selector
PKG-83  implicit package-consumer provider resolution selects a single compatible concrete, or the compatible package default when all candidates belong to one provider package; otherwise multiple compatible candidates are an error
PKG-84  installed provider discovery is derived from managed concrete facility metadata and no separate mutable provider index is authoritative
PKG-85  package integration materializes validated dependency declarations without resolving mutable runtime provider state
PKG-86  pkg requirement list resolves and prints catalog dependency declarations without downloading the package artifact
PKG-87  pkg requirement resolve status-1 diagnostics distinguish unconfigured, unresolvable and incompatible global facility-default states
PKG-88  pkg install reports currently unsatisfied runtime dependencies before artifact transfer without treating them as an installation failure
PKG-89  pkg depend is a read-only dependency-planning query that prints a deduplicated dependency-first list of dependency concrete identities and performs no package installation
PKG-90  one pkg depend plan resolves explicit roots only for dependency discovery, then recursively resolves dependency declarations, provider candidates and provider compatibility against one exact pkg-catalog snapshot
PKG-91  pkg depend collects all constraints belonging to the same effective provider-selection bucket before selecting its concrete provider
PKG-92  pkg depend preserves consumer binding then facility-default precedence; without either selector it prefers compatible planned providers, then unambiguous compatible installed providers, then a catalog provider only when the compatible provider package is unambiguous
PKG-93  pkg depend treats multiple compatible provider packages as ambiguity and never silently ranks them
PKG-94  pkg depend omits requested root nodes from output unless the same concrete is also selected as a dependency node
PKG-95  every pkg depend output item is an exact concrete package identity valid as a direct install operand
PKG-96  pkg install prepends pkg depend output to the untouched original request list so dependency concretes are installed before requested roots
PKG-97  pkg install resolves original package-spec roots when reached while preserving exact dependency concretes as exact requests
PKG-98  recursive dependency installation is part of the canonical pkg install pipeline
PKG-99  pkg install validates the complete original request list before dependency planning, catalog resolution or package-store mutation; any syntactically invalid request aborts the whole invocation

```
