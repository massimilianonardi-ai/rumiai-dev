# RumiAI OS — Current model

Status: **Current / normative**  
Updated: 2026-09-18

This document is the canonical high-level architecture contract for the current `rumiai-os` mainline.

It replaces the need to reconstruct the present from the historical Model 2.0 migration document plus later corrections.

## 1. Repository and semantic layers

The repository remains:

```text
rumiai-os
```

It contains two semantic layers:

```text
m
    low-level, general-purpose technical runtime/substrate

RumiAI
    branded upper product layer built on m
```

`m` MUST NOT semantically depend on RumiAI.

`pkg`, package runtime infrastructure and `pkg-catalog` belong to `m`.

## 2. Root entrypoints

The technical root runtime is:

```text
$m_ROOT/m
```

It is implemented as a POSIX-shell bootstrap with:

```sh
#!/bin/sh
```

Its runtime exposure is:

```text
bin/sys/m -> ../../m
```

The branded root entrypoints are:

```text
$m_ROOT/rumiai-os
$m_ROOT/rumiai-os-sh
```

The current implementation of both branded entrypoints follows the shell-oriented baseline and delegates into `m`; this does not establish a permanent GUI architecture contract for `rumiai-os`.

## 3. Executable ownership and PATH

`m` owns:

```text
bin/sys/
bin/sys-<osarch>/
bin/sys-osarch -> sys-<osarch>
bin/ext/
bin/ext-<osarch>/
bin/ext-osarch -> ext-<osarch>
```

RumiAI owns:

```text
bin/ai/
bin/ai-<osarch>/
bin/ai-osarch -> ai-<osarch>
```

The technical `m` PATH is ordered:

```text
sys-osarch
sys
ext-osarch
ext
inherited host PATH
```

RumiAI activation prepends:

```text
ai-osarch
ai
```

Platform selection is explicit and keeps the three active executable selectors aligned:

```text
bin/sys-osarch
bin/ext-osarch
bin/ai-osarch
```

The canonical platform command is:

```text
osarch
osarch show
osarch update
osarch set <osarch>
```

Bare `osarch` reports only the currently selected normalized `osarch`. The active selection is valid only when all three selectors are relative symbolic links to existing platform directories and represent the same supported identity.

`osarch show` reports the selected `osarch`, its operating-system and architecture components, and for each selector its pathname, relative link target and resolved physical pathname.

`osarch update` detects the normalized operating system and architecture of the host on which it is executing and selects that identity. `osarch set <osarch>` selects an explicit supported normalized identity instead of using host detection. Both mutation forms ensure the corresponding `sys-<osarch>`, `ext-<osarch>` and `ai-<osarch>` directories exist and make all three selector symlinks relative to those roots.

`osarch-set` and `osarch-update` remain compatibility commands for the previous command surface. Platform selection is never run implicitly by the bootstrap.

Command-name collisions between `m` and RumiAI SHOULD be avoided. A real exception requires an explicit current contract.

## 4. Internal libraries

Library ownership mirrors executable ownership:

```text
lib/sys/<runtime>/<name>.lib.<runtime>
lib/ai/<runtime>/<name>.lib.<runtime>
```

For shell:

```text
lib/sys/sh/<name>.lib.sh
lib/ai/sh/<name>.lib.sh
```

Libraries are imported/sourced files, not commands. Shell libraries do not contain shebangs and are not executable.

No `lib/ext` contract exists merely for symmetry; packages remain the external software mechanism.

## 5. Product metadata

Universal scalar metadata lives at the repository/product root:

```text
product-name
product-version
```

The current release lineage is Model 2.x. Historical release/migration checkpoints remain immutable in Git/tags and do not redefine current mainline behavior after later forward corrections.

## 6. State model

Mutable state is rooted at:

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

The canonical semantic order is:

```text
scope -> owner -> identity -> area
```

with package State Instance encoded in the identity when present.

The bootstrap exports semantic roots:

```text
m_STATE_DIR=$m_ROOT/state
m_STATE_SYS_DIR=$m_STATE_DIR/system/current
m_STATE_USER_DIR=$m_STATE_DIR/user/current
```

These are semantic pathnames. The bootstrap does not resolve or validate their selector targets merely to start the runtime.

System state uses:

```text
state/system/current -> profile/<profile>
```

User state uses one optional explicit global binding:

```text
state/user/current
```

Only a symbolic link at `state/user/current` constitutes the explicit binding. Without it, user state resolves under:

```text
state/user/default/
```

The `user` scope is an `m` state namespace. It is **not** derived from POSIX UID, account name, host-id or `$HOME`, and it is not itself an authentication/security boundary.

The public resolver is:

```text
state-path <scope> <owner> <identity> <area> [<state-instance>]
```

Consumers MUST use `state-path` rather than reconstructing deep state paths, except for explicitly documented structural mechanisms such as static package `var/` routing.

Full state semantics are in `STATE-MODEL.md`.

## 7. State areas

The canonical areas are:

```text
conf
    persistent authoritative configuration

data
    persistent authoritative data

home
    application/compatibility home state

cache
    persistent non-authoritative/regenerable state

log
    persistent operational history

run
    transient runtime coordination state

tmp
    transient scratch/intermediate state
```

Directories are materialized only when needed.

## 8. Package model

The public package command is:

```text
pkg
```

Current public subcommands include:

```text
install
uninstall
versions
default
```

Package definitions/catalog data live in the separate `pkg-catalog` repository. Runtime adapters, resolution, download, extraction, integration and launcher logic belong to `m` inside `rumiai-os`.

Package launchers resolve mutable state through `state-path`. Package HOME is user-scoped state selected at launch. RumiAI-managed package configuration uses the reserved `.m/` subnamespace within the package configuration area.

Package `var/` compatibility routing is static and system-scoped; it does not become a dynamic user-state router.

Full package invariants are in `PACKAGE-MODEL.md`.

## 9. Resources

Global distributed resources use:

```text
$m_ROOT/res
```

Resource ownership is separated between technical `sys` and branded `ai` where applicable. Package-owned resources remain in the managed package tree/version rather than being projected into the global resource root.

Mutable state is not reclassified as a resource.

Full resource semantics are in `RESOURCE-MODEL.md`.

## 10. Localization

The technical localization facility is:

```text
lang
```

The previous `i18n` subsystem/API name is superseded.

The current global language resource root is under:

```text
res/sys/lang
```

See `LANG-BOOTSTRAP.md`.

## 11. Project development lifecycle

`mk` belongs to `m` and is responsible for management and orchestration of the development lifecycle of a project.

It interprets structured declarative configuration, manages projects and profiles, resolves and orchestrates development requirements and dependencies, coordinates external tools, manages development workspace/state/output, and performs lifecycle operations such as build, test, run, clean and production of outputs required by later consumers.

`mk` does not replace compilers, interpreters, external build engines or `pkg`; it orchestrates them through modular boundaries.

Project configuration consumed by `mk` is data and MUST NOT be shell-sourced, `eval`ed or treated as executable configuration merely to describe a project.

See `MK.md` for the promoted lifecycle contract.

The currently implemented `mk materialize` source-materialization capability remains specified by `MK-SOURCE-MATERIALIZATION.md`; it is one capability of the broader lifecycle subsystem rather than the complete definition of `mk`.

## 12. Local service lifecycle

`srv` belongs to `m` and provides the current portable local service lifecycle baseline.

It does not make `systemd` or `launchd` part of the portable core and does not introduce a generic internal supervisor daemon.

See `SERVICE-LIFECYCLE.md`.

## 13. Development workspace

`src/` is the local development-workspace anchor in a `rumiai-os` checkout.

Operational nested repositories below it are not product/runtime dependencies and are ignored by the product repository.

## 14. Portability boundary

The system targets POSIX.1-2024 Issue 8. Host differences required by real functionality are isolated behind explicit facilities/adapters and must not leak into the general semantic contract.

See `POSIX-PORTABILITY-LAYER.md` and `RULES.md`.

## 15. Explicitly non-current assumptions

The following historical assumptions MUST NOT be used as current contracts:

```text
rumiai-os as the technical bootstrap/runtime identity
#!/usr/bin/env rumiai-os as the integrated-command shebang
lib/<runtime>/ as the current internal-library ownership layout
global m_CONF_DIR/m_DATA_DIR/m_HOME_DIR/... roots
user state identity derived from <host-id>-<uid>
bootstrap fail-closed validation of state/system/current
old i18n subsystem/API naming
decision documents used as patches over stale current specifications
```

Historical commits/tags that correctly describe those older checkpoints remain valid history.

## 16. Current-model invariants

```text
CURRENT-01   rumiai-os remains the product repository
CURRENT-02   m is the low-level technical substrate
CURRENT-03   RumiAI is the branded upper layer
CURRENT-04   m has no semantic dependency on RumiAI
CURRENT-05   pkg and pkg-catalog belong to m
CURRENT-06   technical runtime root is m
CURRENT-07   integrated commands use #!/usr/bin/env m
CURRENT-08   internal libraries are ownership-qualified under lib/sys or lib/ai
CURRENT-09   state root is $m_ROOT/state
CURRENT-10   state scopes are system and user
CURRENT-11   state owner classes are sys, ai and pkg
CURRENT-12   bootstrap exports semantic, unresolved system/current and user/current roots
CURRENT-13   user state is not derived from POSIX UID or host-id
CURRENT-14   absent an explicit user/current symlink, user state resolves under user/default
CURRENT-15   state-path is the canonical public state resolver
CURRENT-16   package HOME/state is resolved through state-path
CURRENT-17   package var routing is static and system-scoped
CURRENT-18   resource root is res and package resources remain package-owned
CURRENT-19   lang is the current localization facility name
CURRENT-20   srv host supervision integrations are separate from the portable baseline
CURRENT-21   POSIX.1-2024 Issue 8 is the platform baseline
CURRENT-22   Git history and historical evidence remain forward-only and revision-specific
CURRENT-23   mk owns project development-lifecycle management and orchestration
CURRENT-24   mk project configuration is structured declarative data, not shell-sourced/evaled configuration code
CURRENT-25   osarch is the canonical executable-platform query/selection command
CURRENT-26   bare osarch reports the active selection only when sys-osarch, ext-osarch and ai-osarch are valid and aligned
CURRENT-27   osarch show reports selector targets and their resolved physical paths
CURRENT-28   osarch update selects the detected host osarch and osarch set selects an explicit supported osarch
CURRENT-29   osarch-set and osarch-update remain compatibility commands for the previous selector surface
```
