# pkg definition model review and migration

Status: Active
Updated: 2026-11-03

## Goal

Review the complete authoring schema in `pkg-catalog`, preserving the existing
package semantics while making package definitions more declarative and
minimizing future per-package edits. Centralize repeatable installation,
publication, environment and runtime behavior in `m`. Explicitly exclude
abstraction/generalization of package-specific `cmd` scripts in this phase.
Design and migration require coordinated catalog/runtime work; this handoff
has its own cross-repository validation and completion lifecycle.

## Current repository revisions

- Preflight 2026-11-03: `rumiai-dev/main` at `e1ffbcbfa67f112413a8898d65471cb486038118`
  before this handoff creation.
- `m/master`: `3feb1f0cfa2b2bd74c82ec3aaf9e57726a6cd841`.
- `pkg-catalog/main`: `17a08adc0bb5bf708d3357d1f5e70d5110cdc9cc`.

Refresh HEADs and reconcile forward before all subsequent work.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`,
  `specifications/README.md`, `handoff/README.md`.
- `specifications/rumiai-os/{PACKAGE-MODEL,BOOTSTRAP-ENVIRONMENT,CURRENT-MODEL,RESOURCE-MODEL,STATE-MODEL}.md`.
- Active related `handoff/rumiai-os-source-composition.md`;
  independent `handoff/pkg-integration-optimization.md` and
  `handoff/pkg-dependency-resolution.md` retain their separate narrower
  responsibilities.
- `m/lib/sys/sh/pkg/{pkg-catalog,pkg-install,pkg-integration,pkg-state,pkg-launch,pkg-extract,pkg-setuid}.lib.sh`
  and `m/lib/sys/sh/context.lib.sh` are implementation evidence.

## Fixed task-local choices

- Explicit user direction: package definitions should describe product facts,
  while reusable behaviors belong in runtime `m`; minimizing edits when new
  versions/platforms appear is a primary goal.
- **Current user correction (2026-11-03):** for the next package schema,
  `link/bin/<command>` is the *uniform public executable entrypoint*.
  It resolves either directly to the exact concrete's useful-root executable
  or, when adaptation is needed, relatively to
  `../../cmd/<command>` inside the same concrete.
  `cmd/` contains only package-specific optional wrappers, not the complete
  published command set. `context`, ordinary defaults and facility/service
  consumers should use the selected concrete's `link/bin` command view,
  not expose `cmd/` directly as a second public namespace.
  Do not attempt to abstract wrapper bodies in this schema work.
- `link/lib/<runtime>/` remains the intended ordinary-library projection
  view. `link/bin/` is intentionally included in `PATH` when selected
  through a validated exact concrete, unlike the prior superseded
  target-only interpretation. Symlinks targeting `cmd/` are optional,
  and unwrapped commands may not bypass required package environment,
  dependency or state preparation.
- **Current user decision (2026-11-03):** the pre-existing flat
  `pkg/`+`facility/` catalog schema is placed under `v1/`
  **without changing its internal format**, so its definitions remain
  usable. The next revised schema is `v2/` (no leading zeroes).
  Catalogue schema versions are independent of upstream software versions,
  facility compatibility levels and immutable Git snapshots.
- **Current user decision (2026-11-03):** retain static `res` as distinct
  from libraries but explicitly defer new package-resource export
  descriptors and projections to `v3` or later. No `link/res` in v2.
- **Current user proposal under evaluation:** rename the `var/`
  package-definition routing descriptor to a less ambiguous name,
  potentially `map/`; do not confuse its existing *static, system-scoped
  useful-root to managed-state routing* with a generic arbitrary map,
  the state area itself, or the upstream `root/var` directory.
- Retain separate provider-independent `facility/` catalog contracts;
  ordinary shared libraries must not be recast as facility parts.
- Preserve existing provider resolution, immutable catalog snapshots,
  exact concrete identities, state/scoped HOME semantics, privilege rules,
  and package-specific resource ownership.

## Acceptance scenarios

1. Install two ordinary commands: an unwrapped command with
   `link/bin/<name> -> ../../root/...` and a wrapped command with
   `link/bin/<name> -> ../../cmd/<name>`. Public PATH/default/`context`
   resolution reaches the correct exact concrete through `link/bin`;
   only the wrapped command runs its package-specific wrapper.
   Required environment/state/dependency/NSS behavior is not silently lost.
2. Install a package exporting a shell library and a Java JAR, and a
   library-only package: `pkg` validates/materializes version-pinned
   `link/lib/sh` and `link/lib/java` views once; `context` composes
   lookup directories without constructing links.
3. New upstream versions that do not change a defined range's behavior
   require no new package descriptor; platform-common metadata is not
   duplicated merely because catalog streams differ.
4. A facility provider maps its required command members to selected
   exact-concrete `link/bin` entries, whether direct or wrapped, and
   validates them against the central facility contract. A service
   similarly starts one exact provider-selected `link/bin` entry
   through `srv` (never a global PATH search) and retains foreground,
   HOME/state and lifecycle ownership semantics. Ordinary library exports
   do not alter provider selection.
5. A browser or service retaining controlled HOME, declared environment,
   privilege and mutable state preserves the same behavior after migration.
6. A legacy installed concrete, including its state, defaults and provider
   bindings, is either supported unambiguously by an explicit transitional
   reader or migrated through a separately validated maintenance procedure.
   The new runtime must never silently reinterpret a legacy installed link.
7. Invalid descriptor paths, collisions, broken/escaping links, inconsistent
   inheritance overrides, and partial install failures fail safely and
   preserve previous visible state; the exact normal public install/launch
   workflow is validated, not only a synthetic component test.

## Inventory / factual findings (2026-11-03)

- Recursive GitHub tree of `pkg-catalog@17a08adc`: 27 package names,
  73 platform/generic streams with a `repository/` metadata directory,
  96 ordered `nNNNN=<version>` **range anchors** (not one-per-upstream-
  release definitions), 1451 package-namespace file entries.
- Current range root fields (number of ranges having each field):
  `archive_regex` 96, `digest_type` 96, `format` 96, `cmd` 82,
  `link` 82, `dependency` 39, `facility` 54,
  `facility-cmd` 52, `facility-env` 20, `facility-service` 21,
  `env` 12, `var` 2, `setuid_root` 7,
  `component` 2, `payload-root` 2, `overlay` 1.
  No current `lib/` export descriptor appears in these 96 ranges.
- Duplicated content (Git blob identities): among 96 `format` files
  only 10 distinct values; among 96 `digest_type` only 3;
  among 119 `cmd/` files only 29 distinct bodies;
  among 119 `link/` descriptors only 44;
  among 453 `facility-cmd/` leaves 99 distinct bodies.
  Duplication is evidence for factoring repeated stable metadata, not
  authorization to merge semantically distinct streams/versions.
- `pkg_catalog_range_resolve` already chooses the applicable greatest
  ordered range anchor <= selected version; its
  `pkg_catalog_stream_resolve` chooses exact osarch stream when present,
  otherwise `all`. Preserve both semantics and avoid treating every
  release as requiring a new descriptor.
- Existing `m/pkg-integrate` validates `cmd/<command>` paired to
  `link/<command>`, creates per-concrete wrapper `cmd/` and flat
  `link/` symlinks, and independently creates `lib/sh` and
  `lib/java` symlink views; `pkg-launch` reads the exact
  `<concrete>/link/<command>` target. `pkg-state` currently
  validates direct `range/link/*` targets against state mappings.
  Thus the proposed move affects more than `pkg-catalog` and `context`.
- `env` is currently imperative shell content (e.g. Node.js prepends its
  useful-root `bin` to PATH, Chromium validates the sandbox executable);
  `facility-env` already uses typed descriptors (`root`,
  `root-path`, `literal` and managed PATH contributions). Examine
  reuse of that interpreter/semantics for ordinary package environment,
  without erasing distinct scope/precedence or the explicit user's
  `cmd` scripting exception.
- `format`, `component`, `payload-root`, `overlay` describe
  artifact extraction; `var` describes mutable state routing;
  `setuid_root` is privileged file policy; `dependency`/facility
  declarations are separate provider/runtime contracts; `repository`
  metadata selects existing source-specific adapters. These existing
  responsibilities must not be replaced by a new universal mini-language.
- Specific package examples inspected: `nodejs`, `maven`,
  `graalvm`, `geoserver`, `ollama`, `chromium`,
  `playwright`, `keycloak`, `micromamba`, `macgpg`,
  `podman`, `electron`, `temurin`.
  `ollama-serve` is a simple `cmd` wrapper with fixed `serve`
  argument; `micromamba-python-env` carries much more complex
  procedural semantics. Neither is to be abstracted here.

## Working design (not yet current contract)

**1. Projection topology.** In the planned v2 authoring and installed
layouts, `link/bin/<command>` is the one public command entrypoint.
Each materialized executable link points to a useful-root executable
or to an optional same-concrete `../../cmd/<command>` wrapper.
`cmd/` has no mandatory 1:1 correspondence with commands;
a library-only package has no `link/bin/` requirement.
`context` composes the exact selected `link/bin/` directory into PATH;
package default publication and facility command projections also select
the validated `link/bin` command, with no per-context symlink writes.
`link/lib/sh` and `link/lib/java` remain version-pinned library views.
Catalog descriptors must distinguish a root target from a wrapper target
unambiguously, even if the final materialized links have relative paths.
The exact descriptor encoding is still to be decided, not a v1 contract.

**2. Keep typed responsibility boundaries:** source identity and
version stream (`repository/` + range anchors), acquisition/integrity,
artifact extraction, immutable export mapping, environment composition,
facility/dependency conformance, service realization, state routing and
privileged effects. Declarative data describes targets and requirements;
`m` performs validation, synthesis, rollback and projection. Preserve
`cmd` as an explicit procedural exception.

**3. Stable metadata factoring.** Study optional package/stream-level
defaults inherited by exact platform/range declarations (e.g. common
`format`, `digest_type`, requirements, stable link export names),
with explicit overrides. Keep existing ordered range anchor selection
and `all` vs osarch stream resolution. A strict inheritance/merge
contract (presence, deletion, precedence, conflict detection) is
required before inventing the physical `common/` schema.
Do not introduce a generic template language or per-release generator.

**4. Declarative environment.** Evaluate a package-scoped typed
environment descriptor using the existing facility-env resolution
primitives where appropriate (e.g. `PATH` root-path prepend,
`JAVA_HOME` root, a required executable check). Do not equate
package env with facility env or silently reorder package, provider,
user and inherited protected variables. Package-specific script env
cases that cannot yet be modeled safely remain explicit and are
counted rather than abstracted speculatively.

**5. Migration and compatibility.** `v1` is the exact existing
catalog structure beneath a versioned parent; `v2` introduces the
new `link/bin` public entrypoint and v2 facility parameter model.
New installed concretes must retain schema identity; legacy unmarked
ones must be treated deterministically as v1 only when verified.
Installing a v2 definition over an already-installed exact v1 concrete
is not an implicit replacement. The v1 catalog relocation is not
literally only one code edit: the catalog resolver, facility lookup,
catalog sync script/workflow and external snapshot consumers must
address the `v1` base, while legacy installed launch paths remain
supported. For v2, `pkg-launch`, `pkg-integration`, `pkg-state`,
`context`, facility/service command resolution, defaults, manuals and
real tests need coordinated realignment; retain state/default/provider
references and do not use speculative path-probing compatibility.

### Schema-versioned catalog and facility ownership (2026-11-03, revised working design)

**Catalog generations.** The user's explicit choice is
`v1/{pkg,facility}` preserving the present flat descriptor format
exactly, followed by `v2/{pkg,facility}` for the revised model.
The version label uses unpadded integers (`v1`, `v2`), not
`v01`/`v02`. Retaining the v1 definitions is necessary for
compatibility but does not by itself make an upgraded launcher
compatible with old installed concretes; identity/provenance and
schema-specific readers matter. The present runtime resolves
snapshot-relative `pkg/` and `facility/` and the
`pkg-catalog` synchronization code stages top-level `pkg`.
For v1, these must consistently use the selected v1 base without
changing the nested catalog data. Do not silently rewrite old
concrete layouts in place, or confuse schema version with Git snapshot,
upstream version, or facility compatibility.

**One effective executable namespace in v2.** A user invokes a
`link/bin` symlink. For a simple binary it points into that same
concrete's useful root. For a wrapper it points to
`../../cmd/<command>`. The wrapper remains specific code, not an
ordinary public PATH namespace. Direct symlink execution is permitted
only when its requisite runtime preparation is already satisfied;
packages needing launch-time HOME/dependency/environment/NSS setup
must use a suitable wrapper or a defined generic preparation
boundary. This is substantive: the current `pkg-launch` assumes
`$0` resolves into `<concrete>/cmd/` and reads
`<concrete>/link/<command>` as the *upstream target*. That assumption
cannot continue when the new public link may point at the wrapper
itself; the v2 wrapper must convey/discover the upstream target
without circular resolution. The exact v2 descriptor representation
is pending. Also validate upstream scripts that derive installation
paths or behavior from argv[0]/symlink execution.

**Facility and service transparency.** The facility owns member
names and conformance, the provider binds only implementation-specific
paths/parameters. The v2 facility-command realization should
consume the exact concrete's public `link/bin` entries, with no
`package-command` vs `root` distinction imposed on consumers.
For services, `srv` resolves the system-selected exact provider
and executes the service's validated entry in that exact
`link/bin` directory, not through an unpinned/global PATH.
The existing baseline `service/start=package-command` and
`pkg_facility_service_start_resolve` returning an exact `cmd/`
path are **current v1 behavior** and need a deliberate v2
service-contract change. Preserve foreground process lifecycle,
host-supervisor, recorded instance identity, state scope and
package launcher environment/privilege guarantees.

**Routing descriptor name.** The current `var/<area>` files map
specified useful-root relative paths to static system-scoped mutable
state, including factory/default initialization. `var` is
misleading as a *descriptor* because it need not correspond to a
physical `root/var` directory. Bare `map` would be too generic:
prefer a responsibility-specific candidate such as `state-map/<area>`
(or `state-link/<area>` if link creation is chosen as the defining
semantic), while leaving existing managed `state-path` semantics
and v1 `var` descriptors unchanged. The v2 exact name and any
state-map syntax are still under review.

**Resources deferred.** Resources remain distinct from libraries.
No package resource-export descriptor or `link/res` materialization
belongs to v2; defer that capability to v3 or later and preserve
existing package-local/manual/language distribution and privacy
semantics. This supersedes the previous working proposal to include
`link/res` in the immediately upcoming schema.

**Acceptance focus.** Validate v1 install/launch after relocating
its catalog definitions, then v1/v2 installed coexistence and
unchanged exact identity/default behavior. In v2 test a direct binary,
a wrapper requiring fixed argv and state/environment, a Java
facility with many members, a Node-like delegated launcher, and an
Ollama-like service through both portable and host paths. Verify
no fallback through a different package version and reject missing,
escaping or cyclic links. Resource export testing is out of scope.

## Completed

- Verified current involved repository HEADs and read current authoritative
  `rumiai-dev` sources before review.
- Inventoried current package descriptors, compared common real
  package variants with `m` code and identified existing reusable
  responsibilities and path consumers.
- Prepared working design only. No `m` runtime, `pkg-catalog`
  package definition, installed concrete, or frozen repository changed.
  No tests run: this checkpoint is source/schema analysis only.

## Current state

Design review in progress. No final new schema or migration procedure
has passed the specification promotion/implementation gate.

## Next action

Fix the exact v2 `link/bin` authored descriptor/launcher
target contract, while v1 remains the unchanged current catalog
schema moved under `v1/{pkg,facility}`. Define how v1/v2 installed
concretes identify their schema and how facility and `srv`
entrypoints follow the uniform selected `link/bin` path without
losing launch-time state/environment requirements. Choose a precise
replacement name for v2 `var` routing; keep new resource
exports deferred to v3+ and outside the v2 migration.
Compare the strict two-tier current range model with a minimal
explicit defaults/override option before deciding syntax.
Then stage authorized, coordinated `m` + `pkg-catalog` implementation,
operational manuals and real public package install/launch tests.
Only after successful implementation/validation promote stable current
contracts to `PACKAGE-MODEL.md` and relevant `context` spec.

## Blockers / open questions

- Precise v2 wrapper-target descriptor semantics and generic launcher
  contract once the public `link/bin` symlink may point at `cmd`.
- V1/v2 installed-concrete schema identity and safe mixed-version
  launch, plus coordinated facility/`srv` migration.
- Exact v2 replacement for the `var/<area>` state-routing name.
- Minimum non-imperative ordinary package `env` shape, including
  scope/precedence and safe checks.
- Whether stable metadata inheritance pays for its complexity while
  retaining range anchors and `all`/osarch stream selection.
- Real hosted sh/Java library workflow and catalog-backed consumer
  validation have not yet been reported PASS for the relevant
  `m` source revision.
