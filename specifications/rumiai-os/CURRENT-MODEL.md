# RumiAI OS — Current model

Status: **Current / normative**  
Updated: 2026-09-22

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

`mk` belongs to `m` and is responsible for management and orchestration of a project's development lifecycle.

The lifecycle engine is implemented in JavaScript and consumes declarative JSON project configuration from project-root `mk.json`. The public `mk` entrypoint remains bootstrap-integrated with `m` and delegates to the JavaScript engine through the current RumiAI-managed Node.js package runtime.

The lifecycle model distinguishes project `dependency`, operation `prerequisite` and external `requirement`. Project-defined goals select lifecycle roots; operation prerequisites form the detailed lifecycle graph.

Goal names are extensible project data rather than a mandatory hard-coded set. `mk` can delegate an operation to a suitable external lifecycle/build engine or orchestrate a fine-grained operation graph directly.

`mk.json` expresses declarative project intent and is not required to duplicate details derivable from authoritative current project/runtime context. Version 2 implements contextual file collections so the current members of a declared directory/tree can be resolved from the filesystem; explicit selection remains available when intended membership differs, including profile-specific subsets.

Version 2 also implements a trusted operation-provider boundary. The first generic `map-process` provider derives ordinary process operations from collection members without introducing compiler/language-specific behavior into the core. Project configuration selects trusted provider types/data and does not become an arbitrary executable JavaScript/module-loading surface.

Lifecycle planning is not required to produce a completely fixed graph before execution. Version-2 plans preserve pending collections/providers and conditional operations when required evidence does not yet exist. Conditions may observe operation results, declared outputs and current project state. Declared output evidence is tied to the producing operation's current request result so stale pathnames do not masquerade as newly produced output.

Version-2 execution follows the iterative model:

```text
resolve reachable context
→ execute ready work
→ observe results/outputs/state
→ resolve/refine
→ continue
```

This supports generated-source flows in which initial sources are known at plan time while later sources become authoritative only after a generator succeeds. It also supports explicit continued failure as branch evidence without treating that failure as an ordinary satisfied prerequisite.

Version 1 remains the original fully resolved static lifecycle model for compatibility. Both versions keep the shell-free `process` action and sequential executor baseline.

Version 2 also implements project-to-project dependency delegation. A dependency explicitly maps requested parent goals to child-project goals and delegates the child lifecycle to another `mk` engine process rooted at that project. Child lifecycle internals remain encapsulated; they are not flattened into the parent operation graph. Parent profiles are not inherited implicitly, project-dependency cycles are rejected through canonical project identity in the active invocation chain, and active direct dependencies must succeed before parent local lifecycle work begins. Version-2 plans preserve dependent-project requests as nested child plans. The baseline does not imply request-wide de-duplication across independent sibling branches.

Version 2 also implements named external requirements. The first requirement type is a `pkg` facility identity plus the package subsystem's existing compatibility constraints. Operations and trusted providers may reference named requirements; only requirements reachable from the requested lifecycle are resolved. `mk` queries them through the read-only `pkg requirement resolve` surface against the system facility default, never creates synthetic package-consumer bindings, and never installs or selects providers implicitly. Unsatisfied requirements remain visible in plans, block only their consumers and are re-resolved during runtime refinement.

Version 2 also implements explicit incremental freshness. Configured operations may declare first-class named `inputs` using path, collection or named-output sources and opt into reuse with `incremental: {}`; the previous `incremental.inputs` form remains a compatibility form normalized to the same shared input map. Freshness is content/SHA-256 based rather than mtime based and includes effective operation/action/environment identity plus resolved requirement-provider identities. A stored successful record is reusable only when the current fingerprint and current declared outputs both match. Verified hits appear as `up-to-date`, satisfy prerequisites/collection barriers/output evidence, but do not synthesize actual execution-result fields; reachable result-field observation forces real execution. Persistent freshness metadata is non-authoritative user-scoped `mk` cache state resolved through `state-path`.

Trusted `map-process` providers may also template ordinary inputs, outputs and `incremental: {}` for each derived collection member. Each member remains an ordinary derived operation and reuses the same per-operation fingerprint/freshness machinery; there is no provider-level aggregate cache record. The concrete mapped item is injected as a trusted private `$item` path input so item content participates without duplicate project declaration. Provider path inputs and output paths may use the existing `${item}` substitution. Derived operation identity remains item-based rather than collection-position-based, so adding/removing/reordering collection membership does not by itself invalidate unchanged reachable members.

Version 2 also implements a long-running `--watch` execution mode. Watch remains a thin supervisor around fresh ordinary one-shot lifecycle requests rather than extending one mutable `_executeV2` invocation indefinitely. Trusted `mk` resolution derives an opaque deterministic trigger identity from the selected normalized model plus currently reachable declared input/collection content, executable/effective-environment identity, requirement-provider identity and incremental output/fingerprint evidence. Ordinary non-incremental unconsumed output bytes are excluded from trigger identity. Active project dependencies contribute recursively through child-owned opaque trigger digests rather than graph flattening.

Every watch trigger pass and every lifecycle cycle enters through a fresh `m` bootstrap from the original caller environment. Temporary invalid root/active-child configuration pauses trigger availability, retains the previous valid baseline and runs no lifecycle work until valid resolution returns. Failed lifecycle cycles are reported and followed by waiting for another trigger change instead of terminating or busy-looping. SIGINT/SIGTERM are forwarded to an active lifecycle child. Portable polling is the first internal wakeup mechanism and has no public tuning surface in the baseline.

Artifact storage/restoration, shared/remote caching, parallel scheduling and remote execution remain unimplemented.

`mk` does not replace compilers, interpreters, external build engines or `pkg`; it orchestrates them through modular boundaries.

See `MK.md` for the current lifecycle contract.

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
CURRENT-30   mk lifecycle operation names are extensible rather than a mandatory hard-coded global set
CURRENT-31   mk supports both delegation to suitable external lifecycle/build engines and finer-grained direct orchestration
CURRENT-32   mk lifecycle engine implementation language is JavaScript
CURRENT-33   mk project configuration is JSON rooted at project-root mk.json
CURRENT-34   mk configuration expresses declarative intent and does not require duplication of details derivable from authoritative current project/runtime context
CURRENT-35   mk planning may preserve conditional alternatives whose selection depends on evidence produced only during lifecycle execution
CURRENT-36   mk plan inspection resolves current observable facts without executing project operations and preserves unresolved future-dependent alternatives
CURRENT-37   mk version 2 implements contextual collections, trusted operation providers, declarative conditions, named outputs and iterative runtime plan refinement
CURRENT-38   mk provider implementations are trusted runtime behavior selected declaratively; mk.json is not an arbitrary executable resolver/module-loading surface
CURRENT-39   mk declared-output observation is bound to current-request producer results rather than stale pathname existence alone
CURRENT-40   mk version 2 implements project-to-project dependencies by recursively delegating explicit child-goal requests to another mk engine process
CURRENT-41   dependent-project lifecycle internals remain owned by the child mk instance rather than being flattened into the parent operation graph
CURRENT-42   parent profiles are not inherited implicitly by dependent projects and recursive project cycles are rejected from canonical project identity
CURRENT-43   active direct project dependencies must succeed before parent local lifecycle work begins
CURRENT-44   mk project dependency semantics do not imply request-wide de-duplication across independent sibling branches
CURRENT-45   mk version 2 implements named external requirements and the first requirement type is a pkg facility with pkg compatibility constraints
CURRENT-46   reachable mk facility requirements are resolved through the read-only pkg requirement query against the system facility default
CURRENT-47   mk requirement resolution does not create synthetic package-consumer bindings, install packages or implicitly select providers
CURRENT-48   unsatisfied reachable requirements remain inspectable, block only their consumer lifecycle nodes and participate in iterative runtime refinement
CURRENT-49   mk version 2 implements first-class named operation input identity and explicit content-based incremental freshness for ordinary process operations
CURRENT-50   reusable incremental freshness requires both an effective fingerprint match and current declared outputs matching recorded successful output fingerprints
CURRENT-51   up-to-date work satisfies prerequisite/collection/output evidence without fabricating execution-result fields; result observation forces execution
CURRENT-52   mk incremental metadata is non-authoritative user-scoped cache state resolved through state-path
CURRENT-53   the incremental baseline does not imply artifact storage/restoration, remote/shared cache or request-wide project-dependency de-duplication
CURRENT-54   operation inputs participate in data/reachability semantics independently from incremental reuse; declaring inputs alone never makes an operation up-to-date
CURRENT-55   incremental freshness consumes the shared operation input map while legacy incremental.inputs remains accepted as a compatibility form
CURRENT-56   mk version 2 implements --watch as a lifecycle execution mode rather than a project goal or mk.json namespace
CURRENT-57   watch trigger identity is resolver-owned and content based over normalized reachable lifecycle/input/executable/requirement/incremental-output evidence
CURRENT-58   dependent-project watch trigger identity is recursively child-owned and opaque to the parent without graph flattening or request-wide de-duplication
CURRENT-59   every watch trigger pass and lifecycle cycle uses a fresh m bootstrap from the original caller environment
CURRENT-60   temporary invalid watch configuration pauses without work and resumes from the last valid baseline; failed lifecycle cycles report and wait for another trigger
CURRENT-61   the first watch baseline uses internal portable polling with no public polling/backend/stop-on-cycle-failure tuning surface
CURRENT-62   SIGINT/SIGTERM terminate watch supervision after forwarding to an active one-shot lifecycle child
CURRENT-63   map-process providers may template shared inputs, declared outputs and incremental opt-in for ordinary derived item operations
CURRENT-64   each derived provider member receives its concrete collection item as private $item path input and reuses ordinary per-operation freshness rather than provider-level cache state
CURRENT-65   provider-derived incremental identity is item-based and independent of collection enumeration position; add/remove/reorder does not by itself invalidate unchanged reachable members
CURRENT-66   provider incremental freshness does not imply cleanup of stale outputs or freshness metadata for collection members that become unreachable
```
