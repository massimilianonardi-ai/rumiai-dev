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
- The earlier user-approved direction is to keep package `cmd/` as an
  **intentional, package-specific executable launcher/wrapper layer**,
  distinct from upstream useful-root binaries. Do not generalize `cmd`
  scripts in this phase; do not bypass them through `PATH`.
- The favored *future* organization groups existing file projections under
  `link/bin/` (command target executables) and `link/lib/<runtime>/`
  (runtime-specific library exports), keeping `cmd/` separate and exact
  concrete version binding. `link/bin/` must not be placed on `PATH`.
  The physical layout is not yet implemented/promoted; `link` today is
  flat for commands, while `lib/sh` and `lib/java` are sibling views.
- Retain separate provider-independent `facility/` catalog contracts;
  ordinary shared libraries must not be recast as facility parts.
- Preserve existing provider resolution, immutable catalog snapshots,
  exact concrete identities, state/scoped HOME semantics, privilege rules,
  and package-specific resource ownership.

## Acceptance scenarios

1. Install one package whose specific `cmd` wrapper requires environment and
   fixed arguments: its `link/bin/<command>` target resolves to the exact
   selected useful root, and public command execution still uses the wrapper
   and trusted `pkg-launch`.
2. Install a package exporting both a shell library and a Java JAR, and a
   library-only package: `pkg` validates/materializes version-pinned
   `link/lib/sh` and `link/lib/java` views once; `context` composes only
   their runtime lookup directories, without constructing links.
3. New upstream versions that do not change a defined range's behavior
   require no new package descriptor; platform-common metadata is not
   duplicated merely because catalog streams differ.
4. A provider package with direct facility executables and one delegating
   facility command maintains its current facility cmd/env/service contracts;
   ordinary library exports do not alter provider selection.
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

**1. Projection topology.** Favor a consistent authored
`link/bin/<command>`, `link/lib/sh/<name>.lib.sh`,
`link/lib/java/<name>.jar` representation, and matching
concrete-local projections. A command uses `cmd/<command>` plus
`link/bin/<command>`; library-only packages need no `cmd`.
No automatic PATH exposure of `link/bin`. Exact names/placement
are candidates until committed with runtime and migration.

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

**5. Migration and compatibility.** No destructive catalog-only
rename. Define how explicit old and new installed link layouts are
distinguished, whether a schema/revision marker is needed, and whether
legacy concretes require reinstall. `pkg-launch`,
`pkg-integration`, `pkg-state`, `context`, catalog descriptors,
manuals, tests and public installed-package behaviors must realign in
one coordinated rollout; preserve state/default/provider references.
Do not use silent path-probing fallback as an accidental new contract.

### Schema-versioned catalog, facility ownership and resource exports (2026-11-03, working design)

Current user proposals refine the ongoing pkg model review; **not yet a
promoted specification or catalog migration**.

**Catalog compatibility namespace.** Prefer a common versioned root
`v01/{pkg,facility}/...`, with possible later `v02/{pkg,facility}`
coexisting. The schema version is distinct from (a) upstream package
version/range anchor `nNNNN=<version>`, (b) exact facility compatibility
level, and (c) immutable catalog Git snapshot revision. The existing flat
`pkg/` and `facility/` roots are a legacy unversioned schema;
do not silently reinterpret them as `v01` when semantics differ.
Decide explicitly whether `v01` preserves existing interpretation or
starts with revised links and declarative provider parameters. A directory
name alone cannot keep old installed concretes executable when a new
`pkg-launch` reads different link paths. New concrete installations
need explicit schema/provenance identity, and the runtime needs coherent
schema-specific readers or an explicit coordinated reinstall/migration.
Previously installed unmarked concretes require a safe legacy policy.
Avoid an accidental ambiguous same concrete-version identity between
schema versions; a Git revision remains required for reproducible
definition recovery. Current `m` catalog resolver uses snapshot-relative
`pkg/` and `facility/`; catalog sync script and workflow also hardcode
the top-level `pkg` folder. Those consumers must move together.

**Facility contract ownership.** User wants **all facility definitions**
and required member names in `facility/<facility>/<compatibility>`,
not repeated as provider `facility-cmd`, `facility-env`, and
`facility-service` member inventories in each package range. The package
declares which facility level it provides and only the implementation
parameters needed to satisfy the central contract: e.g. a root-relative
binary directory, specific command-path exceptions/delegation to its
`cmd` wrappers, environment target paths/values and service-start
command binding. The generic `m` facility handlers validate required
members, synthesize projections and reject incompatible bindings.
**Do not put provider-specific paths inside the central facility
contract:** the central facility defines what/validation, while
the provider supplies where/how realized. This narrows the provider
realization rather than erasing it. Evidence: `facility/java/21` already
has independent required `cmd/java`, `cmd/javac`, `env/JAVA_HOME`
markers, but Temurin and GraalVM redundantly map many
`facility-cmd/java/* = bin/*` entries; Node.js needs
`package-command node`, and `ollama` needs a package-specific
`start=ollama-serve` binding. A central member list plus typed
parameter mapping must handle all these without a second
provider-defined facility schema or generic executable template
language. Exact proposed parameter names/structure are open.

**Static resource exports versus code libraries.** User identifies
missing package-resource export descriptors for `lang`, `manual`,
possible icons and other static assets. The current
`RESOURCE-MODEL.md` requires package-owned manuals and translations
to ship in their same concrete artifact, and keeps them private unless
an explicit exposure contract is introduced. They must not be
automatically copied into global `$m_RES_DIR` or synchronized by
global `lang-set`. Prefer separate semantic projection classes
`link/lib/<runtime>` for code/JAR imports and candidate
`link/res/<class>` for static payload access, with the same generic
validated link-materialization mechanism underneath. Publication
scope, namespace/ownership, locale fallback, manual lookup,
version selection and collision rules remain to be defined per class.
Icons are not a current globally fixed resource class; only add a
typed export when a concrete consumer/access rule is established.
Do not invent a universal `resource-path` API solely for symmetry.

**Acceptance scenarios to resolve before schema promotion:** install
legacy-unversioned and new-versioned packages together; launch both
through real `cmd` wrappers after a runtime upgrade; preserve exact
installed schema identity, mutable state and facility defaults. Validate
Temurin/GraalVM Java, Node.js delegated commands, Ollama service,
Chromium environment and a library-only package. Export and access a
package's revision-matched manual/lang resource without leaking it
to global `sys` or `ai`; verify collisions and invalid paths fail
before changing installed state. Keep all assertions based on actual
public package install/launch, not only component stubs.

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

Resolve the common `v01/{pkg,facility}` schema version boundary,
legacy installed-concrete provenance and runtime compatibility, central
facility-owned member definitions with package-owned binding parameters,
and distinct resource export semantics as the smallest coherent
declarative contract, using representative real package classes.
Compare the strict two-tier current range model with a minimal
explicit defaults/override option before deciding syntax.
Then stage authorized, coordinated `m` + `pkg-catalog` implementation,
operational manuals and real public package install/launch tests.
Only after successful implementation/validation promote stable current
contracts to `PACKAGE-MODEL.md` and relevant `context` spec.

## Blockers / open questions

- Exact authorship and installed layout semantics for
  `link/bin` / `link/lib`, and migration/compatibility strategy.
- Minimum non-imperative ordinary package `env` shape, including
  scope/precedence and safe checks.
- Whether stable metadata inheritance pays for its complexity while
  retaining range anchors and `all`/osarch stream selection.
- Real hosted sh/Java library workflow and catalog-backed consumer
  validation have not yet been reported PASS for the relevant
  `m` source revision.
