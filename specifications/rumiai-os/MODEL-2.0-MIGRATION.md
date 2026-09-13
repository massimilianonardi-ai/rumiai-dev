# RumiAI OS — Model 2.0 Migration Specification

Status: **Normative specification — pending activation until the 1.0.0 checkpoint is tagged**  
Date: 2026-09-13

## 1. Scope and authority

This specification consolidates the complete architectural contract for the transition from the current RumiAI OS model to the new internal `m` + RumiAI model.

It is normative for the migration itself. Until the frozen current product checkpoint is physically tagged as `1.0.0`, this document does not authorize product writes that implement the new model. Once that tag exists and the user explicitly activates the migration, this specification supersedes every incompatible exploratory direction and every incompatible current-model contract only to the extent required by the migration.

The migration remains governed by:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
Git forward-only
revision-specific physical evidence
```

Historical decisions and evidence remain immutable history. They are not rewritten or relabelled.

## 2. Frozen 1.0.0 baseline

The pre-migration product is the exact stable checkpoint:

```text
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests  bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
```

The exact `rumiai-os` commit above is the content to be tagged:

```text
1.0.0
```

The tag MUST NOT use a `v` prefix.

The 1.0.0 release records the old architecture permanently. No migration compatibility layer is required for an already-running 1.x installation.

## 3. Versioning across the architecture boundary

The architecture transition is represented explicitly by the product version boundary:

```text
1.0.0
    frozen old model

2.0.0
    first frozen release after the complete model migration
```

The product MUST NOT be called 2.0.0 while the migration is incomplete.

During the migration, the repository may contain intermediate forward-only commits, but the product version remains a migration work state until the complete model is validated and frozen.

After 2.0.0, normal version evolution may continue with versions such as:

```text
2.0.1
2.1.0
3.0.0
```

according to the versioning policy that will be defined before a later version change becomes necessary.

No concrete stable/development/private API stratification is promoted during the 1.0.0 -> 2.0.0 migration. Contract classification is performed only after the complete 2.0 model exists. The design principle remains:

> stabilize little, but stabilize it very well.

This rule supersedes the earlier migration-readiness assumption that initial stable contracts had to be classified before migration.

## 4. Repository and product identity

The repository remains:

```text
rumiai-os
```

No separate `m` repository is created.

The architecture has two semantic layers:

```text
m
    low-level, general-purpose technical runtime/substrate

RumiAI
    branded upper product/layer built on m
```

`m` MUST NOT semantically depend on RumiAI.

The current contents of `rumiai-os`, because they are almost entirely general-purpose infrastructure, migrate by default to ownership by `m` unless a concrete RumiAI-specific responsibility is identified.

`pkg` and `pkg-catalog` belong to `m`.

Service/daemon infrastructure is not introduced by this migration. It will be designed only when a concrete requirement exists.

## 5. Root runtime and branded entrypoints

The future technical runtime root entrypoint is:

```text
$m_ROOT/m
```

Its portable runtime exposure is:

```text
bin/sys/m -> ../../m
```

Bootstrap-integrated `m`-layer commands use:

```text
#!/usr/bin/env m
```

The branded top-level product entrypoints are:

```text
$m_ROOT/rumiai-os
    RumiAI GUI/product entrypoint

$m_ROOT/rumiai-os-sh
    RumiAI shell entrypoint
```

The initial implementation MAY keep `rumiai-os` deliberately simple and delegate immediately to `rumiai-os-sh`. This is an initial implementation choice, not a permanent GUI architecture contract, and may be reconsidered later.

The initial bootstrap into `m` is performed through a direct pathname controlled by the product. PATH-based resolution of `m` is guaranteed only after the `m` environment is active. No special host-command collision mechanism is required.

## 6. Executable layout and PATH

`m` owns the existing general-purpose executable classes:

```text
bin/sys/
bin/sys-<osarch>/
bin/sys-osarch -> sys-<osarch>
bin/ext/
bin/ext-<osarch>/
bin/ext-osarch -> ext-<osarch>
```

RumiAI adds its own executable classes:

```text
bin/ai/
bin/ai-<osarch>/
bin/ai-osarch -> ai-<osarch>
```

The base `m` PATH is:

```text
sys-osarch
sys
ext-osarch
ext
inherited host PATH
```

The RumiAI activation layer prepends:

```text
ai-osarch
ai
```

so the activated RumiAI PATH is:

```text
ai-osarch
ai
sys-osarch
sys
ext-osarch
ext
inherited host PATH
```

RumiAI and `m` command names SHOULD NOT collide. If a concrete need requires a collision, the exception and its reason MUST be documented explicitly before implementation.

## 7. Library layout

The 2.0 migration separates library ownership analogously to executables.

The target library model is:

```text
lib/sys/<runtime>/<library-name>.lib.<runtime>
lib/ai/<runtime>/<library-name>.lib.<runtime>
```

Examples:

```text
lib/sys/sh/core.lib.sh
lib/sys/sh/pkg-launch.lib.sh
lib/ai/sh/<future-ai-library>.lib.sh
```

This intentionally supersedes the current `lib/<runtime>/...` layout.

No `lib/ext` or `lib/ext-<osarch>` contract is introduced by the migration. Package facilities and the existing package model remain the preferred mechanism until a real requirement proves that a separate external-library namespace is necessary.

## 8. Environment namespace

RumiAI-owned environment variables continue to use the `m_*` namespace.

The future RumiAI upper layer MAY use `m_ai_*` only for real values with real consumers. No matrix of speculative `m_ai_*` aliases is created.

The following state roots are part of the 2.0 model:

```text
m_STATE_DIR
m_STATE_SYS_DIR
m_STATE_USER_DIR
```

with meanings:

```text
m_STATE_DIR
    $m_ROOT/state

m_STATE_SYS_DIR
    concrete, canonical root of the system profile selected at bootstrap

m_STATE_USER_DIR
    concrete root of the current POSIX principal state
```

The previous global area roots:

```text
m_CONF_DIR
m_DATA_DIR
m_HOME_DIR
m_CACHE_DIR
m_LOG_DIR
m_RUN_DIR
m_TMP_DIR
```

MUST NOT be retained merely as aliases for deeply nested 2.0 paths. The physical state layout is resolved through the universal state resolver described below.

## 9. Branding and product metadata

Branding is separate from the technical runtime identity.

Universal, non-localized scalar product metadata uses one file per value, following:

```text
filename = variable/concept name
file content = scalar value
```

The initial product metadata is:

```text
$m_ROOT/product-name
    RumiAI

$m_ROOT/product-version
    current product version
```

The product brand is universal and is not localized.

Descriptions, user-facing messages and other localizable strings belong to the branded RumiAI domain and therefore to the `rumiai-os` language domain, not to a generic `m` language domain merely because the implementation uses `m`.

The broader static-resource layout is explicitly deferred until after 2.0.0 and is not a migration prerequisite.

## 10. Package release compatibility

The release guarantee is for a clean installation of the release.

The 2.0 migration does not promise in-place migration of:

```text
materialized package installations
runtime state
previously running 1.x installations
```

An explicit upgrade/migration procedure may be designed in the future for changes that can be handled safely, but it is not part of the 2.0 baseline.

`pkg` and `pkg-catalog` are migrated as `m` responsibilities.

Existing package definitions and catalog consumers are updated to the new runtime/shebang/layout contract. Previously materialized packages are not a repository migration concern.

## 11. State semantic root

The 2.0 state model introduces the single semantic root:

```text
$m_ROOT/state/
```

The model separates:

```text
security/execution scope
owner
identity
optional State Instance
area
```

There are exactly two security/execution scopes in the baseline:

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

The identity precedes the state area.

## 12. System state and system profiles

System state is organized as:

```text
$m_ROOT/state/system/
├── current -> profile/main
└── profile/
    └── main/
        ├── sys/<identity>/<area>/
        ├── ai/<identity>/<area>/
        └── pkg/<identity>/<area>/
```

`main` is the initial system profile name.

A system profile is a complete system-wide mutable state image. There is no base state plus profile overlay and no profile fallback merge.

Only the system administrator selects the system profile. A POSIX user does not own, select or map to a system profile.

`current` MUST be a relative symlink.

At bootstrap, `m` resolves and canonicalizes `state/system/current` exactly once. The resulting concrete profile root is exported as:

```text
m_STATE_SYS_DIR
```

A running process MUST NOT repeatedly follow `current` for ordinary state access.

## 13. System profile switch protocol

A system profile switch is an administrative, quiescent operation.

The new profile MUST already exist and satisfy the profile validity contract before switching.

The selector replacement protocol uses only destinations that do not exist:

```text
1. prepare the new relative selector object
2. move current to a temporary old-selector pathname
3. current is now absent
4. move the prepared new selector to current
5. if step 4 succeeds, remove the old selector
6. if step 4 fails, restore the old selector to current and fail
```

The two moves occur within the same selector directory/filesystem and use the normal POSIX `mv` contract with non-existing destinations. No GNU/BSD-specific destination-symlink option is required.

The switch protocol is recoverable, not claimed to be globally atomic across both moves.

Bootstrap behavior is fail-closed:

```text
missing current -> failure
broken current  -> failure
invalid target  -> failure
```

No implicit fallback profile is selected.

If a crash leaves the selector in an intermediate recoverable state, administrative recovery restores either the old valid selector or completes the prepared new selector before restarting dependent processes.

## 14. POSIX principal identity

User state is identified physically by:

```text
<host-id>-<uid>
```

where:

```text
host-id
    native stable machine identifier normalized to exactly 32 lowercase hexadecimal characters

uid
    effective POSIX UID of the principal
```

The path is:

```text
$m_ROOT/state/user/<host-id>-<uid>/
```

and contains:

```text
sys/<identity>/<area>/
ai/<identity>/<area>/
pkg/<identity>/<area>/
```

The host-id is produced behind a host-specific facility/adapter because POSIX does not define a universal machine identifier.

The current reference strategy is:

```text
Linux
    native machine-id source

macOS
    native platform UUID source
```

The adapter normalizes the native identifier into the canonical 32-hex form. Username, hostname, OS name and architecture are descriptive information only and are not part of the persistent principal identity.

The resulting principal root is exported as:

```text
m_STATE_USER_DIR
```

## 15. State areas

The canonical state areas remain:

```text
conf
    persistent authoritative configuration

data
    persistent authoritative data

home
    compatibility/application home state; not POSIX user identity

cache
    persistent non-authoritative/regenerable state

log
    persistent non-authoritative operational history

run
    transient runtime coordination state

tmp
    transient scratch/intermediate state
```

The classification remains:

```text
persistent authoritative:      conf data home
persistent non-authoritative:  cache log
transient:                     run tmp
```

Directories are materialized only when needed. The full scope x owner x identity x area Cartesian product is never created merely for symmetry.

`run` and `tmp` are never shared between system profiles. Their presence on disk does not make stale transient contents reusable after restart/profile activation.

## 16. Universal `state-path` resolver

The physical state tree MUST NOT become a pathname convention hardcoded throughout scripts and applications.

The canonical cross-runtime resolver command is:

```text
state-path
```

Its baseline interface is:

```text
state-path <scope> <owner> <identity> <area> [<state-instance>]
```

Accepted baseline values are:

```text
scope:  system | user
owner:  sys | ai | pkg
area:   conf | data | home | cache | log | run | tmp
```

The optional `<state-instance>` is initially valid only for `owner=pkg`.

On success, `state-path` writes exactly one resolved absolute pathname followed by a newline to stdout and exits successfully.

It is a pure resolver. It MUST NOT:

```text
create directories
initialize defaults
change profiles
change permissions
select package versions
mutate State Instance state
```

For normal package state:

```text
state-path user pkg foo conf
```

resolves semantically to the package `foo` user configuration root.

For a State Instance:

```text
state-path user pkg foo conf test
```

resolves using the physical identity form:

```text
foo@!test
```

Consumers MUST use the resolver instead of rebuilding the physical tree contract from `m_STATE_SYS_DIR` or `m_STATE_USER_DIR`.

The bootstrap and resolver are the canonical owners of physical state-layout knowledge for normal runtime resolution.

## 17. HOME and launch isolation

`m` does not assign one global application HOME at bootstrap because the relevant identity is not necessarily known at that point.

The launch context that knows the concrete owner/identity/State Instance resolves the appropriate `home` area through `state-path` and exports:

```text
HOME=<resolved home path>
```

For a normal user-scoped package this is semantically equivalent to:

```text
HOME=$m_STATE_USER_DIR/pkg/<package>/home
```

but that concatenation MUST NOT be duplicated by consumers; it is produced by `state-path`.

For a user-scoped package State Instance the same resolver naturally selects:

```text
pkg/<package>@!<instance>/home
```

The package launcher remains the normal place where package HOME isolation is applied because it knows the concrete package launch identity.

## 18. `var/` compatibility routing

`var/` is not a generic state router and is not a user-state mechanism.

Its role is exclusively to externalize mutable state that upstream software insists on reaching through paths inside its installation tree.

State reached through package-local `var/` is system-scoped.

The target model is:

```text
<package-version>/var/<area>
    -> $m_ROOT/state/system/current/pkg/<package>/<area>
```

or the equivalent correct relative symlink.

This is an intentional exception to the normal process-local use of `m_STATE_SYS_DIR`: persistent package `var/` routing MUST traverse `state/system/current` so a later administrative profile switch changes the package's system state without rewriting every installed package.

`var/` MUST NEVER route to:

```text
state/user/...
```

A package may mix:

```text
system state through var/
user state through native runtime routing
```

Classification is per state binding, not per whole package.

If user-private state cannot be externalized natively and requires shared `var/`, that state is system-scoped or the software is not supported as user-isolated with a shared installation.

## 19. State Instances

State Instance remains distinct from both POSIX principal and system profile.

For packages, the physical grammar remains:

```text
normal identity:
    <package>

State Instance identity:
    <package>@!<state-instance>
```

Therefore the 2.0 identity-first form is:

```text
.../pkg/foo/<area>
.../pkg/foo@!test/<area>
```

The migration does not introduce an `instance/` subtree.

For state that is fully natively addressable at runtime, different processes may select different State Instances concurrently.

Static `var/` routing does not become per-invocation. A state binding reached through `var/` cannot simultaneously select different State Instances for separate launches through the same shared package installation.

State Instance management beyond path resolution remains a later package-management capability unless required by concrete migration behavior.

## 20. Permissions and security

The user principal root is private by default:

```text
owner = corresponding UID
mode  = 0700
```

Creation SHOULD use a restrictive default equivalent to `umask 077` unless a concrete child object requires another contract.

The system selector/profile structure is administratively controlled and is not writable by ordinary users merely because those users can launch software.

System-owned state contents MAY use component/package-specific permissions required by the actual upstream software.

No global world-writable policy is introduced for system state.

RumiAI does not prohibit ordinary users from launching a package merely because some package state is system-scoped and writable. If multiple users reach the same writable system state, they intentionally share it. Application-level concurrency and locking remain the responsibility of the upstream software unless RumiAI later adopts an explicit stronger contract for a specific package.

## 21. Reserved package configuration namespace

RumiAI-managed metadata/configuration stored inside a package `conf` area uses the reserved subnamespace:

```text
.m/
```

The namespace exists to avoid collisions with upstream software configuration.

For example, a RumiAI-managed environment fragment may live conceptually at:

```text
<package-conf>/.m/env
```

When the relevant system conf binding is var-backed, the same namespace is reachable through:

```text
<package-version>/var/conf/.m/...
```

When configuration is user-scoped and natively routed, it is resolved through the corresponding user package conf area rather than by making `var/` dynamic.

Package integration MUST reject or otherwise explicitly resolve a real upstream collision with the reserved `.m` namespace; it MUST NOT silently merge unrelated meanings.

## 22. Default/factory state

Package `default` is independent from `var/`.

It means:

```text
factory/seed state distributed by the package integration
```

and is distinct from:

```text
current mutable state
State Instance
var routing
```

A package that is completely native/env-routed may still provide defaults, for example to standardize hotkeys, application preferences or integration behavior.

System-scoped defaults may be materialized during installation when the destination is absent.

User-scoped defaults managed by RumiAI are initialized lazily/at first use for the POSIX principal when required, because the user may not exist at package-install time.

Upstream-managed first-run initialization remains preferable when it already provides the required behavior.

## 23. Static product resources

The migration does not define a final generic namespace for static/versioned product resources.

No new root such as `share`, `resources` or equivalent is introduced merely to complete the 2.0 migration.

Existing resources such as language catalogs may remain in their current static location unless another migration requirement directly forces a change.

The static-resource architecture is explicitly deferred until after 2.0.0.

Mutable configuration may legitimately live in state `conf`, including shell configuration where that classification is appropriate.

## 24. Git-ignore and operational state migration

The final Git-ignore refinement for the new state tree is deferred until the structural migration is complete and can be evaluated against the actual resulting repository.

The 1.0 -> 2.0 transition does not migrate ignored operational runtime state.

Only repository-tracked product content is migrated.

Operational recovery for this architecture transition is clean reinstall, not state rollback.

Git protects tracked source/history only and remains forward-only.

## 25. Migration execution order

The migration is one approved architecture transition executed in checkpointable forward-only work units.

Repository order for operational cutover is:

```text
1. rumiai-os
2. pkg-catalog
3. rumiai-tests
```

`rumiai-dev` remains authoritative and is updated first whenever normative contracts must be fixed or corrected before the corresponding operational change.

The product work is organized conceptually as:

```text
Block A — non-state model
    technical runtime identity m
    branded entrypoints
    shebang/runtime exposure
    PATH and ai executable roots
    library ownership/layout
    product metadata/version plumbing
    package/catalog runtime alignment
    non-state permanent-test updates

Checkpoint A
    new non-state model coherent

Block B — state model
    state root
    host-id + POSIX principal
    system profile main/current
    selector protocol
    state roots
    state-path
    HOME isolation
    owner/identity/area layout
    var routing
    .m configuration namespace
    defaults
    State Instance physical grammar
    permissions
    transient-state rules
    state permanent-test updates

Checkpoint B
    complete new model coherent
```

No implementation unit may silently mix an unresolved incompatible old/new contract. Intermediate commits must remain internally understandable and forward-repairable.

## 26. Testing and evidence

Permanent tests are the mechanical authority for deterministic properties of the migrated model.

They MUST be updated after the corresponding product contract exists and MUST protect at least the applicable portions of:

```text
m bootstrap and integrated shebang
root product entrypoints
PATH order
sys/ai executable ownership
library layout
product metadata
state roots
host-id normalization contract
system profile selection
selector failure/recovery behavior
state-path mapping
HOME isolation
user principal isolation
var -> system/current routing
var never -> user routing
State Instance @! mapping
.m reserved namespace
default state independence from var
run/tmp profile separation
clean-install package/catalog behavior
```

Host-dependent behavior is physically validated only where material, using revision-specific evidence under the existing testing contract.

A passing test on one host is never relabelled as evidence for another host.

## 27. Completion and 2.0.0 freeze

The model migration is complete only when:

```text
rumiai-os implements the complete normative model
pkg-catalog is aligned with the new package/runtime contract
rumiai-tests protects the migrated contract
applicable physical validation passes on the required reference hosts
active documentation contains no unresolved old-model contract for the migrated subsystem
stale/superseded terminology and mechanisms have been scanned
Git history is forward-only
```

Only after that complete checkpoint is reached is the product frozen and tagged/released as:

```text
2.0.0
```

Only after the complete 2.0 model exists is the stable/development/private contract stratification performed.

## 28. Explicit supersession for the migration

Upon activation, this specification supersedes the following incompatible future-model assumptions:

```text
pre-migration promotion/classification of initial stable contracts
POSIX principal represented only by username or uid without host identity
unresolved initial system profile name
unresolved system selector replacement protocol
global seven-area environment roots as the 2.0 state API
hardcoded deep state pathname construction by consumers
an `instance/<name>` State Instance subtree
user-state routing through dynamic package var
static-resource redesign as a prerequisite of 2.0
runtime-state migration as a requirement of the architecture transition
```

It also deliberately supersedes, during implementation, current 1.0 contracts that are structurally incompatible with the 2.0 model, including:

```text
root technical runtime identity rumiai-os
integrated shebang #!/usr/bin/env rumiai-os
lib/<runtime>/... ownership layout
top-level area-first mutable state
absence of $m_ROOT/state
current package var targets under top-level areas
current global area-root environment contract
```

Supersession occurs only through the authorized forward migration and corresponding specification/test updates; historical commits and evidence remain unchanged.

## 29. Invariants

```text
MODEL2-01   rumiai-os repository remains the product repository
MODEL2-02   m is the low-level technical runtime; RumiAI is the branded upper layer
MODEL2-03   m has no semantic dependency on RumiAI
MODEL2-04   pkg and pkg-catalog belong to m
MODEL2-05   1.0.0 identifies the exact frozen old-model checkpoint
MODEL2-06   2.0.0 is assigned only after complete migration and validation
MODEL2-07   no stable/development/private promotion occurs during migration
MODEL2-08   root runtime is m; branded root entrypoints are rumiai-os and rumiai-os-sh
MODEL2-09   m PATH excludes ai; RumiAI activation prepends ai-osarch and ai
MODEL2-10   libraries are ownership-qualified under lib/sys and lib/ai
MODEL2-11   state root is $m_ROOT/state
MODEL2-12   scopes are system and user
MODEL2-13   owners are sys, ai and pkg
MODEL2-14   state ordering is scope/profile? -> owner -> identity -> area
MODEL2-15   initial system profile is main
MODEL2-16   m_STATE_SYS_DIR is a concrete profile root frozen at bootstrap
MODEL2-17   user principal pathname identity is <host-id>-<uid>
MODEL2-18   host-id is native-machine-derived and normalized to 32 lowercase hex
MODEL2-19   consumers use state-path instead of hardcoding deep state paths
MODEL2-20   State Instance package identity remains <pkg>@!<instance>
MODEL2-21   var is static, system-scoped and never routes into user state
MODEL2-22   persistent var routing traverses state/system/current
MODEL2-23   HOME is resolved at launch from the relevant user package home state
MODEL2-24   .m is reserved inside managed package conf
MODEL2-25   default state is independent from var
MODEL2-26   user state is private by default; system-state permissions are responsibility-specific
MODEL2-27   run and tmp are not shared between system profiles
MODEL2-28   static-resource redesign is deferred until after 2.0.0
MODEL2-29   no operational 1.x runtime state migration is required; clean reinstall is the baseline
MODEL2-30   operational repository order is rumiai-os -> pkg-catalog -> rumiai-tests
MODEL2-31   permanent tests provide mechanical evidence; physical evidence remains revision-specific
MODEL2-32   Git remains forward-only
```
