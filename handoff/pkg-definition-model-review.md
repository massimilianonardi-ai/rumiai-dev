# pkg definition model review and migration

Status: Active
Updated: 2026-11-04

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

- **User scope decisions (2026-11-04, current):** keep the existing
  package-store permission/trust behavior; do not add OS-enforced sealing,
  ownership barriers or mediated execution. Keep the existing
  `rumiai-validate` target contract unchanged (focused autonomous
  `m-os` runner tests remain non-formal evidence). Keep the current
  v2 design unchanged rather than extending its schema or reopening
  deferred metadata/resource decisions. Complete applicable integration
  validations and then proceed with forward-only reconciliation/promotion
  of the v2 runtime and catalog into their mainlines when the evidence
  and consistency gates permit. These directions override older
  unresolved next-action suggestions below; do not claim new validation
  or promotion until actually performed.
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

**Routing descriptor name.** The user agreed to `state-map/<area>`
for v2. It describes the existing static system-scoped routing of
specific useful-root paths into managed mutable state, including
factory/default initialization. The v1 `var/<area>` definition
remains unchanged. Do not reinterpret this as a generic map or as
dynamic user-state routing. V2 schema implementation remains pending.

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
- Implemented the first production migration unit, **v1 catalog
  relocation**, with no altered package/facility definition blob:
  `pkg-catalog/main@334506291aa9ce47a4d93323e7c97d0424ffb494`
  moved the former top-level `pkg/` and `facility/` trees
  under `v1/` by reusing their exact Git tree SHAs.
  `sync-version-history.mjs` and its workflow now use `v1/pkg`.
- `m/master@11e92a17b85c6511324b83cd82b45a6b2be532f9`
  teaches `pkg_catalog_init` to return the definition root
  `catalog/v1` while preserving support for a genuinely
  unversioned legacy catalog snapshot; it validates and rejects
  mixed flat-and-v1 shapes. Updated its library manual in the
  same commit. A new v1-specific validation workflow was
  published in `m@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a`.
- The current `PACKAGE-MODEL.md` was realigned in
  `rumiai-dev@a7c6394890ff364f4316897ccab6f8631a715291`
  to document current v1 root selection and the explicit
  pre-versioning fallback. V2 candidate semantics remain here
  in this handoff, not in that current v1 specification.
- Catalog CI workflow path filters were adjusted for `v1/pkg`;
  `pkg-catalog/main@82e11b135f3fdb27eabf7f483a7c52e5a2bd32bd`
  additionally introduced a local pre-migration snapshot pin
  for one legacy `rumiai-os` compatibility workflow without
  modifying the frozen product. Its workflow run still FAILED
  at legacy `pkg-depend nodejs` with `request-unresolvable`;
  do **not** claim compatibility PASS from this attempt.
- `pkg-catalog/main@032c00a426fc1163d88783565a15343f6eb2fccd`
  adds hosted real public v1 catalog verification using the
  exact autonomous `m@ff55fc9f` checkout.
  Workflow run `41615053850`: Ubuntu job `125846306687`
  **PASS**, macOS job `125846306489` **PASS**;
  the test covers `pkg requirement list` for mk/jsc, catalog
  snapshot layout and a facility contract.
- Follow-up `pkg-catalog/main@30ab3735a0945fff79ccb3266a9eb92745cea0a3`
  extends that real hosted workflow to `pkg install jq@jq-1.8.2`
  followed by the actual `m jq -n '21*2'` execution.
  Run `41615692369`: Ubuntu job `125848446369` **PASS**
  and macOS job `125848446011` **PASS**.
  These establish specific normal-path v1 catalog-backed install
  and command execution on both hosts, not all package families.
- Parallel forward-only `pkg-schema-v2` branches are in active
  development. Current verified branch HEADs (2026-11-03):
  `m/pkg-schema-v2@047550a27e97f0f0cc18cdfad50fa04a98c284f6`
  and `pkg-catalog/pkg-schema-v2@4a76b7756a3a4a63f8ca75b39e82bc8f3b2a20ce`.
  These are NOT merged into `m/master` or `pkg-catalog/main`.
  The `m` branch has first-pass v2 catalog stream preference and
  schema marker handling, link/bin direct and wrapped command
  materialization, wrapper private target lookup, package-default
  publication and schema-aware `context` views.
  The catalog branch has an initial v2 jq package definition for
  Linux and macOS, with link/bin pointing directly to useful-root
  executables. None of these v2 branches has a confirmed hosted
  workflow run or real v2 install/launch PASS; source is provisional
  and may still require corrective revisions.
- The v2 branch has NOT completed generic facility parameter
  realization, facility-command publication, `srv` launch path,
  state-map routing, the full link/lib projection, mixed installed
  v1/v2 lifecycle, or manuals and integration tests. The v2
  proof package is jq only; no v2 provider/service catalog
  migration is validated.
- A sync reconciler correction at
  `pkg-catalog/main@759127c79c576cacb22ba0c4bb55d4746279e0f3`
  removed leftover root-level pkg paths and refuses zero-stream
  scans. The corresponding release-history workflow
  `41616409159` reports success. Earlier green workflow results
  for this reconciler were insufficient evidence of a real scan
  because the previous loop could inspect zero repositories.
  The catalog v2 branch has been fast-forward reconciled
  to this main change before adding its v2 jq definitions.
- `rumiai-os` and `rumiai-tests` remain frozen and unchanged
  by this work.

- The resumed m-context/v2 environment checkpoint added contract-keyed v2
  facility-env validation, materialized the existing trusted flat runtime
  environment view, and tested it through the real public provider-default
  environment path on Ubuntu. Corrected a global environment selector mismatch:
  explicitly version-pinned providers must not require a package-class default.
  The integrated v2 facility-command fixture tests now reject unknown, missing,
  duplicate and root-escaping environment parameter values. Updated the
  affected context, facility and integration library manuals in the m branch.
  The change remains provisional on pkg-schema-v2 until macOS and further
  provider/service validation complete; no v2 mainline promotion occurred.

## Current state

**V2 gate check after P2 exact-head CI (2026-11-05, latest):**
- [P2 hosted run 42098513609](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098513609) is **COMPLETED SUCCESS** on Ubuntu job `127494805820` and macOS job `127494806453`. Both raw logs explicitly checked out the **current P2 branch head `m-os/m-os-completion-p2@0d3f877243af79e108cc19fda504a619cf57957b`** (not the temporary catalog workflow commit `1b105aa...`) and ended with `PASS: P2 real public package planner/install, repeat-root and corrupt-store rejection`. The real-public test also checks invalid-first/invalid-last batches, dependency-first fulfillment, platform-aware provider planning, a pre-existing root while a distinct root is installed, and rejection of an invalid installed symlink. This closes the previously queued *hosted P2 public smoke* at this exact revision on both platforms; it is **not** the complete P2 negative provider-ambiguity/failure-cleanup or independent permanent-suite acceptance.
- [P2 PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) remains **OPEN/DRAFT** and `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` has diverged from P2 (GitHub compare: P2 35 ahead / 7 behind); the P2 owner must still finish its own negative/rollback checks and reconcile master forward before releasing the shared-`pkg` writer. V2 `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` is likewise divergent from master (93 ahead / 20 behind). V1's prior 2-platform Java and published mk/jsc PASS remains revision-scoped and cannot validate a future P2+V2 merged binary.
- Independent v2 catalog [run 42094814482](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094814482) on `pkg-catalog/pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630` had five macOS jobs completed SUCCESS and two (v2-jq, facility commands) still QUEUED at this check; no full-current-matrix PASS is claimed. No runtime/catalog/test/legacy mainline modification was made in this gate check. P3/P4 and V2 promotion remain gated after P2 acceptance.

**V2 pre-integration overlap audit (2026-11-05; read-only):**
- Current independently retrieved heads: `m-os/master@15745d7b575d725073d0fd11d221bd0117ee916e`, `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, P2 draft `m-os/m-os-completion-p2@44b8133b4c0acbbc7bee54b765d48a0a51c9bf4b`; `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609` and feature `pkg-catalog/pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630`. These are snapshots, not assumed future HEADs.
- Current-HEAD GitHub compare shows `m-os/master` and v2 **diverged**; master-only changes are chiefly A-lane workflows and `bin/sys/extract`/manual, while feature v2 changes `context`, numerous shared `pkg` libraries/manuals and Java adapters. Catalog `main` and v2 also **diverged**: main has later `v1/pkg/electron` version-index edits that must survive any catalog promotion; v2 adds independent v2 definitions. This is source-path evidence, **not a tested clean merge**.
- Comparing P2 draft to current master and v2 to current master identifies **two shared changed paths**: `lib/sys/sh/pkg/pkg-install.lib.sh` and `res/sys/manual/pkg-install.lib.sh`. Current P2 replaces the old public `pkg_install_resolve_one` / `pkg_install_resolve` / `pkg_install_validate` helpers with underscored internal functions and introduces exact-root/same-snapshot public planning, root already-installed checks and per-branch diagnostics; the v2 feature still has prior public spellings and its distinct v2 schema selection/integration arguments. The v2 manual advertises older helper identities, while the P2 manual describes the new internal boundary. **V2 integrator must reconcile both contracts/implementation and manuals forward after P2**, not blindly overlay either whole file. No unverified claim of a mechanical Git merge conflict is made.
- P2 exact-source [run 42094006865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094006865) reported Ubuntu PASS and macOS FAIL at upstream GitHub Releases Node.js HTTP 403 *before P2 product assertions*. Its P2-owner successor [run 42095006573](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42095006573) currently has Ubuntu PASS and macOS QUEUED at last check; the P2 handoff owns further diagnosis/validation and shared writer access. The newer v2 catalog [run 42094814482](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094814482) has completed Ubuntu jobs but macOS jobs QUEUED. None authorizes V2 promotion.
- No source, catalog, test, mainline or frozen product modification was made during this read-only overlap audit; it is pre-integration evidence only. V1 prior hosted feature acceptance remains pinned; post-P2/P3/P4 integrated consumer retests are still required.

**V1 published mk/jsc Ubuntu+macOS public PASS (2026-11-05, latest):**
- [Run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769) **COMPLETED SUCCESS 2/2** on hosted Ubuntu `127457388880` and hosted macOS `127457389235`, with real `rumiai-test` `PASS 1, FAIL 0, ERROR 0` on both. Exact catalog `ed599dcd09a286eb3e0d21b4cc8f04adaada556c`, runtime `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, and unpromoted permanent test branch `rumiai-tests/pkg-v2-mk-jsc-validation@c7a8b2137e407bc33a942ec6c6ba346a6019fe66` were verified from the macOS raw job log. The test genuinely installs/executes the published v2 first-party mk/jsc packages; this closes only that exact hosted scenario, not physical validation.
- Java/Temurin/Maven already has [2/2 Ubuntu/macOS hosted PASS](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) at its own pinned revision; [jq retry attempt 2](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) remains an upstream HTTP 403 **acquisition FAIL before jq product assertions**, with an earlier independent macOS jq functional PASS on unchanged relevant paths. No source/catalog/release/frozen-suite files were changed for this update.
- V1's recorded first-party Java and mk/jsc two-platform hosted checks are now closed at their exact revisions; **V2 promotion is still gated by P2/P3/P4 integration and applicable post-integration evidence**, not automatically authorized by these V1 results.


**V1 macOS Java PASS and second jq upstream acquisition failure — 2026-11-05 (prior checkpoint):**
- [Java/Maven/Temurin run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) is now **COMPLETED SUCCESS** on both hosted platforms at `pkg-catalog@ae3e2011462be46c0326179f2117b81b85e5df5e`, `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` and permanent test branch `rumiai-tests/pkg-java-v1-validation@3f0eeb2db04ada295ee933ad6c0f4993c08c6ee5`. The actual macOS job `127448676953` log reports `PASS 1, FAIL 0, SKIP 0, ERROR 0, TOTAL 1` for `m-os/pkg-java-v1/java-provider-and-maven.test`, matching earlier Ubuntu job `127448677067` PASS 1/1. This closes the *hosted two-platform live Java v1 compatibility scenario* at those exact revisions; it does **not** claim reference-host physical validation or all Java behavior.
- [jq v2 run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502), attempted failed-jobs-only retry **attempt 2**, is now **COMPLETED FAILURE** solely for macOS `v2-jq` job `127446872211`. The log proves the exact v2 catalog snapshot and then three public `m pkg install jq@jq-1.8.2` attempts. All three receive HTTP **403** from `https://api.github.com/repos/jqlang/jq/releases/tags/jq-1.8.2` during `pkg-repository-github` artifact resolution; the job exits before `CHECKPOINT: v2 pkg install completed` or any jq runtime assertion. This is a **real upstream acquisition FAIL / product-behavior NOT TESTED** for this run, **not a demonstrated v2 jq logic regression**. The earlier [run 42012478148](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42012478148) macOS real jq install/direct/wrapped/context and mixed v1→v2 coexistence **PASS** remains independently valid for its unchanged relevant source/catalog paths, as compared in the preceding checkpoint.
- [Published mk/jsc run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769) has Ubuntu real `rumiai-test` 1/1 PASS, while macOS job `127457389235` is still **QUEUED**, no assertions executed; this is the remaining new V1 hosted platform gap. No repeat run is justified while its original job is awaiting a runner.
- No product/runtime/catalog/test branch content was changed in this follow-up; only V1 evidence and next-action classification are updated. V2 integration/promotion remains BLOCKED pending P2/P3/P4 plus applicable V1 acceptance, and physical reference-host execution remains PENDING.

**V1 macOS jq precedent recovered and initial queue classification — 2026-11-05 (superseded status):**
- [Catalog run 42012478148](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42012478148), commit `4f49861d90a54d20f8751894cf247cd6080ecdb6`, completed **14/14** direct-entrypoint matrix jobs PASS, including real `v2-jq (macos-latest)` job `127194689486` (public install, direct and wrapped `link/bin`, real jq commands, v1+v2 context coexistence) and real v1→v2 jq reinstall job `127194689594`. The actual logs contain their final `PASS:` assertions; this is not inferred from YAML alone.
- The verified forward catalog compare `4f49861d... → ed599dcd...` changes only the independent `mk/jsc` link descriptors, adds first-party `m-core/m-term/m-rsudo` package definitions, and adds Java/mk-jsc workflows; **no jq package definition or shared catalog facility contract changed**. The runtime compare `m-os@28d9ece9... → 1e3a038a...` changes only Java/Maven/Temurin adapters/manuals, README and CI metadata; **no jq adapter or shared pkg runtime source changed**. Thus the earlier macOS jq PASS remains directly relevant for the jq behavior it tested, although it is not a newly executed full-current-revision result. The later [run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) attempt-1 macOS v2-jq failure was an upstream HTTP 403 acquisition problem; the targeted attempt-2 retry remains QUEUED, and is not evidence of a product regression.
- The two distinct macOS `mk/jsc` and Java/Maven jobs in runs `42087769769` and `42085304112` also remain QUEUED without assertions. GitHub's 2026-11-04 [incident history](https://www.githubstatus.com/history) and public [macOS runner assignment reports](https://github.com/orgs/community/discussions/212069) make an infrastructure delay plausible, but **do not establish a causal diagnosis for these repository jobs**. Do not submit blind duplicate executions or claim macOS PASS for these two unpublished cross-platform paths.
- Actual previously successful V1 paths rechecked directly: macOS real Node.js v1→v2 migration/preserved HOME [run 41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220), macOS offline four-test mixed-schema/rollback selection [run 41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269), and Ubuntu real Ollama portable service/host-user/host-system three-job success [run 41830762283](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41830762283). Each is evidence only for its pinned tested revisions and behavior; hosted CI does not close physical reference-host validation.
- This follow-up changes **only evidence classification**; no runtime, catalog, test, mainline or frozen repository file was modified. V2 stays blocked on prerequisite P2/P3/P4 integration and complete applicable V1 results.

**V1 published mk/jsc real Ubuntu PASS — 2026-11-05 (earlier checkpoint):**
- Fresh remote preflight and current rules, package, MK/JSC, testing, handoff, implementation and upstream source-test review identified a distinct missing V1 hosted acceptance path: public installation/execution of the already released v2 `mk` and `jsc`, beyond the prior operator `vmdev` smoke. The existing independent source tests are v1-layout-oriented and do not establish the current v2 `link/bin` path.
- Created the **unpromoted** executable test `rumiai-tests/pkg-v2-mk-jsc-validation@c7a8b2137e407bc33a942ec6c6ba346a6019fe66`, `tests/m-os/pkg-v2-first-party/mk-jsc-public.test` (mode `100755` verified). `rumiai-tests/main` remains frozen/unchanged. Test uses real public `m pkg install` for Node.js 26 and the published `mk@v0.1.0` / `jsc@v0.1.0`, checks exact v2 concrete `link/bin` wrappers and package-local engines, executes `mk` using managed Node, compiles/consumes JavaScript and CSS via real `jsc`, and rejects source traversal. It has no mocked product component.
- `pkg-catalog/pkg-schema-v2@ed599dcd09a286eb3e0d21b4cc8f04adaada556c` adds only `.github/workflows/validate-v2-mk-jsc-live.yml`; it pins `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` and the above real test, using the event-exact current feature catalog. [Run 42087769769](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42087769769), Ubuntu job `127457388880`, is **PASS**: actual `rumiai-test` output `PASS 1, FAIL 0, SKIP 0, ERROR 0, TOTAL 1`. The corresponding macOS job `127457389235` remains **QUEUED/PENDING** at the last check.
- Existing Java/Temurin/Maven [run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) still has Ubuntu **PASS 1/1** and macOS `127448676953` queued. Existing [jq v2 attempt-2 recovery run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502) still has the sole macOS `v2-jq` job `127446872211` queued; the earlier attempt's upstream HTTP 403 is an acquisition failure, not a proven product defect. Do not infer success or report queued runners as executing tests.
- New commits are limited to feature-branch test and CI surfaces; no `m-os` runtime, catalog definition, source release, canonical package schema, `rumiai-tests/main`, frozen `rumiai-os`, or v2 mainline was modified. These hosted results are **not** designated reference-host physical validation, and V2 promotion remains dependent on V1 and P2/P3/P4 readiness.

**V1 activated — Java Ubuntu live PASS, macOS checks pending (2026-11-05):**
- Reverified current remote mainline and feature HEADs, canonical project/testing rules, this owning handoff and the actual workflow/test sources. No v2 schema, package metadata, runtime implementation, release, legacy product or frozen `rumiai-tests/main` source was changed by this V1 activation.
- `pkg-catalog/pkg-schema-v2@ae3e2011462be46c0326179f2117b81b85e5df5e` adds only `.github/workflows/validate-v2-java-v1-live.yml`. It checks out event-exact v1/v2 catalog definitions, `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`, and the already existing `rumiai-tests/pkg-java-v1-validation@3f0eeb2db04ada295ee933ad6c0f4993c08c6ee5`; it invokes the real public Java/Maven permanent test via `rumiai-test` on hosted Ubuntu and macOS, without embedding its assertions in CI. [Run 42085304112](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42085304112) executed on hosted Ubuntu: job `127448677067` **PASS**, with real `rumiai-test` output `PASS 1`, `FAIL 0`, `SKIP 0`, `ERROR 0`, `TOTAL 1` for `m-os/pkg-java-v1/java-provider-and-maven.test`. The macOS job `127448676953` was still queued. This is revision-pinned auxiliary hosted Java provider/Maven evidence, not a full cross-platform or reference-host physical PASS.
- In the prior current feature [run 42036487502](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42036487502), 13 of 14 initial matrix jobs succeeded. The sole `v2-jq (macos-latest)` job failed at real upstream GitHub Releases HTTP 403 during download, before integration assertions. A **failed-jobs-only** rerun (attempt 2) was accepted and was **queued** when last observed; it must be evaluated by its actual logs and cannot be credited as PASS yet.
- V1 owns evidence and bounded catalog-side CI here. V2/mainline promotion remains gated by actual V1 outcomes and the separately owned P2/P3/P4 shared-`pkg` reconciliations; no mainline promotion has been attempted.


**Published real m-core/m-term/m-rsudo v2 definitions and hosted consumer proof — 2026-11-05 (latest):**
- User explicitly replaced synthetic context fixtures with genuine first-party project source boundaries `m-core`, `m-term`, `m-rsudo`. The source-composition handoff owns the extraction, release, command-loading behavior and remaining interactive/remote test work.
- The independent projects published immutable `v0.1.0` real GitHub source archives and SHA256SUMS. Catalog owner `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7` now publishes exactly **45 new authoring files** for these three `all` package definitions, including direct GitHub upstream integration metadata, 17 `link/lib/sh` descriptors and seven `link/bin` command descriptors; no pre-existing v1/v2 package definitions or facility contracts were changed. No invented ordinary package dependencies: current `dependency` descriptor semantics refer to facility compatibility, not ordinary cross-package shell-library references.
- Genuine public `m pkg install` followed by real `context` shell-library lookups, actual `array` behavior, `menu`/`read-key` argument handling and `rsudo` module dispatch passed on BOTH hosted Ubuntu and macOS: [m-core workflow 42037725004](https://github.com/massimilianonardi-ai/m-core/actions/runs/42037725004), Ubuntu job `127280128346`, macOS `127280128084`, test branch `rumiai-tests/pkg-real-source-composition@a8db8cf5f681933d333e68f83e2d6220b62b32ea`, runtime `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd`. The initial test-run error was a CI detached-HEAD `git pull` setup failure; successful run checked out the actual feature catalog branch and asserted exact SHA before execution.
- Evidence boundary: this proves hosted publication/install/integration/argument and module-dispatch paths, not interactive TTY menu operation, real privileged SSH/sudo, `rssh`, `rsudo-admin` remote source injection, vmdev physical confirmation of these *new* three packages, or complete v2 mainline promotion. `PACKAGE-MODEL` remains the canonical published v1 baseline; new v2 definitions are feature-branch work only. Do not silently treat package-local source libraries as system `loadsyslib` identities.
 
**vmdev public mk/jsc execution PASS; context consumer delegated to source-composition owner — 2026-11-05 (latest):**
- Operator ran real `./m mk --project <temporary mk.json> check` and `./m jsc <temporary modules.json> <temporary bundle.js>` followed by `./m node` import/verification from the same `vmdev` checkout. Actual output was **`mk OK`** and **`jsc OK`**; `jsc` logged only a nonfatal missing optional minifier warning. Operator explicitly printed local `m-os@44ba31c190c63567bcc73604c7c87faff9ba73b6`, local `pkg-catalog@1d38ccf509797ae34f8aa6b090b934d0d6e65a51`, and platform `linux-arm64` (`os: linux`, `arch: arm64`). This is positive *real operator VM* composed Node/mk/jsc v2 evidence at exact revisions, not full product or stable host qualification.
- The operator's immediate next check concerns one `context`-selected package exporting POSIX shell libraries and another selected package using both those exports and `m` system shell libraries. Its implementation/test/validation ownership is the standing `handoff/rumiai-os-source-composition.md`; avoid duplicating details here. No new v2 schema or product mainline mutation is implied by this operator smoke.

**Operator pilot on vmdev: Node.js, mk, jsc installed; executable smoke pending — 2026-11-05 (prior):**
- Operator provided actual shell transcript from `admino@vmdev:/m/src/git`: cloned `m-os` branch `pkg-schema-v2` and `pkg-catalog` branch `pkg-schema-v2`; `m osarch update`; selected the local catalog Git checkout through `state-path system sys pkg conf/catalog`; `m pkg install nodejs` downloaded a 31.51 MiB artifact; `m node --version` printed **`v26.13.0`**; `m pkg install mk jsc` downloaded the real upstream **30,810-byte mk** and **6,799-byte jsc** archives; `m pkg default mk` and `m pkg default jsc` printed **`mk@v0.1.0`** and **`jsc@v0.1.0`**. No visible errors in provided output. This is genuine operator-host **installation and default-selection** evidence, not proof that `mk` goal execution or `jsc` compilation has yet been invoked, and not a formally recorded reference-host validation. Exact local checkout HEADs/OS identity were not printed; do not invent them.
- Fresh remote preflight on current repositories plus canonical `README`/rules/gate, package/boot/state, test and active handoff completed. At preflight, remote `m-os/pkg-schema-v2@44ba31c190c63567bcc73604c7c87faff9ba73b6` and `pkg-catalog/pkg-schema-v2@1d38ccf509797ae34f8aa6b090b934d0d6e65a51`; this is remote state, **not** a recorded exact local HEAD. No runtime/catalog code changes in this checkpoint.
- Rechecked latest `pkg-catalog` workflow [42012861706](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42012861706) for current catalog feature commit: **12/14 matrix jobs success**, including all 7 Ubuntu jobs and five of seven macOS jobs. Both failed macOS jq/v1-reinstall jobs stopped during upstream HTTP 403 at initial `jq@jq-1.8.2` download, rather than reaching alleged v2 property failures. None of these matrix jobs is a live `mk`/`jsc` v2 CLI functional test.
- User explicitly prioritizes beginning real `m-os` use with minimal overhead. The next proportional functional gate is a small real public-command smoke (`./m mk` against a disposable minimal mk project; `./m jsc` with a disposable modules descriptor) from vmdev, with exact local HEAD and OS/architecture recorded. This need not block unrelated ongoing use of the pilot. Defer full-suite refinements and preserve the independent `pkg-dependency-resolution` ownership.
 
**Fast path to first-use pilot and first independent v2 packages — 2026-11-05 (prior):**
- User prioritizes getting real autonomous `m-os` into use, reusing/exporting the existing technical packages and minimizing optional refinement, repository proliferation and validation work beyond meaningful evidence. Freeze existing v2 schema/trust/validator rules; use actual current repositories rather than proposing a new catalog authority.
- Fresh remote HEAD and applicable canonical preflight completed. `m-os/master` is available with a working v1 baseline; `m-os/pkg-schema-v2` is the v2-capable pilot branch; `pkg-catalog/main` contains **27 existing v1 packages and 8 v1 facility definitions**, while `pkg-catalog/pkg-schema-v2` had three v2 packages plus v2 facility definitions. `m-mk/main` and `m-jsc/main` are already independent source repositories with published `v0.1.0` GitHub release artifacts (archive and SHA256SUMS); there is no need to recreate those source repos or a second pkg-catalog.
- Documented a **concrete pilot** in `m-os/pkg-schema-v2` `README.md`, ending at `44ba31c190c63567bcc73604c7c87faff9ba73b6`: clone both feature branches beside each other, select the local `pkg-catalog` Git checkout using the existing catalog config, `./m osarch update`, install `nodejs`, then install `mk jsc` via public `./m pkg`. This avoids changing the catalog mechanism, creating new commands or publishing incomplete v2 semantics to mainlines. Proved locally that Git cloning a feature-branch checkout by local path retains that branch. The README deliberately warns that the catalog config file is tracked and that upstream HTTP failures are possible.
- Promoted **only the existing independently released `mk` and `jsc` package definitions** to the frozen v2 authoring layout on `pkg-catalog/pkg-schema-v2`, now HEAD `1d38ccf509797ae34f8aa6b090b934d0d6e65a51`: two new `v2/pkg/<name>/all/` definitions (11 files each), preserving each v1 archive regex, digest type, version/repository metadata, source wrapper, dependency `nodejs =26` and package files. Added correct `link/bin/<name> -> ../../cmd/<name>` and `link/target/<name> -> ../../root/bin/<name>` descriptors. The first draft accidentally reused jq-wrapped link contents; immediately corrected both in forward commits before acceptance. Re-read the final Git tree; exactly 22 added files versus previous catalog feature SHA, **zero existing files changed**, with exact source-blob equality and verified specific links/targets/dependencies. Five v2 package definitions now coexist with unchanged 27 v1 packages. No v2 schema change.
- This is a **ready-to-try pilot, not a recorded physical install** of the new mk/jsc v2 definitions: no authorized operator host access is available in chat and the current GitHub connection cannot dispatch a new workflow. Prior hosted `jq`/`nodejs` migration and four offline permanent checks remain independently PASS at their prior pinned revisions, not at these new HEADs. New mk/jsc descriptors have structural/source/release metadata checks but **no composed live PASS**. Java adapter/consumer workflow remains unexecuted; the older macOS-only v1 jq GitHub API 403 remains an external transfer blocker, and the independently owned `pkg-dependency-resolution` contract realignment remains open.
- Inventory from current repository trees: legacy `rumiai-os` has 33 `bin/sys` command entries, autonomous `m-os` has 16; the omitted commands are not automatically a migration backlog or justification for copying the monolith. First-party `mk`/`jsc` are already independent. Choose further source exports only when a concrete operator use case requires them, coordinated with the existing source-composition handoff, and avoid opening speculative repositories.
 
**Java v1 permanent test and workflow consistency realigned, execution pending — 2026-11-04 (prior):**
- Reverified remote HEADs for all involved repositories and reretrieved current `rumiai-dev` mandatory read order, package/testing/runner/library/manual/diagnostics rules and active handoff. Parallel unrelated changes to `rumiai-dev` and `rumiai-tests/main` were preserved; product/catalog mainlines and frozen v2 schema were not touched.
- Detected that the newly staged Java GitHub Actions workflow embedded live product assertions directly in YAML; per current `TESTING.md` GitHub Actions must prepare the environment and run the permanent suite through `rumiai-test` or `rumiai-validate`. Fixed this without reopening package contracts.
- Created a separate **unpromoted** `rumiai-tests/pkg-java-v1-validation` branch at commit `3f0eeb2db04ada295ee933ad6c0f4993c08c6ee5` with executable (Git tree mode `100755`) permanent test `tests/m-os/pkg-java-v1/java-provider-and-maven.test`. The test calls the real public `m pkg install`/provider/default commands and Java/Maven CLI on the supplied target, checks relevant v1 concrete identities, classifies upstream-unobservable installation as `ERROR` and observed contract failures as `FAIL`, checks existing target package/provider state before mutation and cleans up its own scenario. Separate test group avoids changing the already-PASS offline `m-os/pkg-schema-v2` selection. Its exact blob `146904ce4d2807daef854152f6a9bc0dfd728114` was checked against local POSIX shell text passing both `dash -n` and `bash -n`; **no real Java install was executed**.
- Updated `m-os/pkg-schema-v2` workflow `.github/workflows/m-pkg-java-v1-live.yml` in forward commit `6299f0b168a3b38cbbf7d10bb866b0d70220bd86`: checkout exact unchanged catalog `420e0870b81c77fb34cb125822ba76501516a35c` and pinned test `3f0eeb2db04ada295ee933ad6c0f4993c08c6ee5`, prepare local Git catalog and canonical `m osarch`, invoke `./tests/rumiai-test --list m-os/pkg-java-v1` and `./tests/rumiai-test m-os/pkg-java-v1` on hosted Ubuntu/macOS. The YAML exact blob `c5314be259437e06ff1cad185c027a3a4cd39d24` parses in PyYAML; this is only syntax/preflight evidence, **not** a hosted workflow pass. No test or product components are replaced in the intended execution path.
- GitHub Actions run query for `m-os` branch `pkg-schema-v2` still returns zero runs. The connected GitHub action API offers job reruns but no workflow dispatch operation, and the available auxiliary Linux terminal cannot resolve `github.com` to clone a live target. Thus the Java public-path test remains **unexecuted/unvalidated** on both hosts; do not promote `m-os` or `pkg-catalog` on this basis. Existing package-store trust and formal `rumiai-validate` target remain unchanged. The prior macOS v1-only jq upstream HTTP 403 and separately owned `pkg install` contract mismatch remain open.

**macOS v1 regression 403, Java adapter port staged for real CI — 2026-11-04 (prior):**
- Mandatory fresh remote HEAD/source/test/active-handoff preflight completed for `rumiai-dev`, `rumiai-os`, `m-os`, `pkg-catalog` and `rumiai-tests`. Parallel changes to other handoffs/specifications in `rumiai-dev` and other repository HEAD advances were preserved. No v2 catalog/schema changes or mainline promotions.
- Real v1-only regression on macOS [run 41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821), attempt `4`, job `126817651791` actually executed and **failed** before reaching any v1 behavior assertions. Authentic log shows three upstream `HTTP 403` responses to `https://api.github.com/repos/jqlang/jq/releases/tags/jq-1.8.2` during `m pkg install jq@jq-1.8.2`; public install exited at download stage/status `12`. This is a failed *CI job*, not demonstrated v1 compatibility regression. No primary cause (rate limit/authorization/other) may be asserted absent upstream response headers.
- Ported existing repository-type implementations from current `rumiai-os/main` into `m-os/pkg-schema-v2`: `lib/sys/sh/pkg/repository/pkg-repository-apache-maven.lib.sh` and `pkg-repository-temurin.lib.sh`, exactly byte-identical to current source blobs `2bd66aec...` and `fc9e3e68...`. Added matching operational manuals `res/sys/manual/pkg-repository-apache-maven.lib.sh` (existing current manual reused) and `res/sys/manual/pkg-repository-temurin.lib.sh` (written against current public functions). No catalog definition, existing API, adapter dispatch or schema modification. Forward-only `m-os/pkg-schema-v2@a4685a7011d7821ea918f651b49d951083510cf7` includes these five scoped additions.
- Added `.github/workflows/m-pkg-java-v1-live.yml` on the same feature branch to exercise real Apache Maven indexing, live Temurin installation, selected Java provider execution and public Maven installation/execution on GitHub-hosted Ubuntu and macOS, pinned to unchanged `pkg-catalog@420e0870b81c77fb34cb125822ba76501516a35c`. This new workflow **has no GitHub Actions run/result yet**; Actions run listing for `m-os` filtered to branch `pkg-schema-v2` was empty. Runtime libraries have only been source-compared and workflow text reviewed, **not** functionally or physically validated. The connected GitHub actions support rerun, not launching a new workflow_dispatch; do not invent a green run or promote the feature branch.
- Previous exact current-runtime permanent offline 4/4 suite remains PASS on both hosted platforms (run `41847205269` attempt 3); real jq and Node.js v1→v2 jobs remain PASS at separately pinned revisions. The canonical `pkg install` discrepancy stays with the independent `pkg-dependency-resolution` handoff; physical stable-host validation remains open.

**Current-runtime permanent macOS 4/4 PASS and v1-regression targeted retry — 2026-11-04 (prior):**
- Fresh mandatory remote HEAD, current project rules/specifications/handoff, pinned workflow and permanent-test preflight completed. Current feature and mainline product/catalog revisions are unchanged; parallel unrelated `rumiai-dev` and `rumiai-tests` commits were preserved.
- The exact current-runtime permanent offline mixed-v1/v2 suite is now **fully PASS on hosted macOS and Ubuntu**: [run 41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269), attempt `3`, run conclusion `success`. macOS job `126814019571` completed `success`; genuine `rumiai-test m-os/pkg-schema-v2` log independently confirms four PASS and no test failures: `default-transaction-rollback.test`, `mixed-default-lifecycle.test`, `mixed-provider-lifecycle.test`, `nodejs-index.test` (2026-11-04T19:40:44–19:41:02Z). Ubuntu job `126814112025` also completed `success`. Pinned `m-os@8fb1db493a3265f77bb36ac604a2a1a495a4d448`, `rumiai-tests@cf6ef10bc5d43f15988f23ba621515363a5bacb7`, `pkg-catalog@420e0870b81c77fb34cb125822ba76501516a35c`. Prior cancelled macOS attempts were infrastructure non-executions, not product FAIL.
- Previously verified genuine jq v1→v2 macOS migration [run 41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821), attempt 3 job `126784922095`, remains PASS; genuine Node.js v1→v2 [run 41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220), attempt 2, is complete PASS for Ubuntu and macOS. These are different pinned run revisions; do not combine into an invented single promoted baseline.
- The distinct macOS v1-only regression job in old broad matrix was `cancelled` before running. One targeted retry of job `126784977304` was accepted (`success=true`); [run 41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821) now attempt `4` with `v1-regression (macos-latest)` job `126817651791` `queued`. No result may be claimed until the real job runs. This older broad workflow pins `m-os@28d9ece912fef151e21a0bd0559904614c2a60e2` and `pkg-catalog@25ca1daca3095f71614af1e7e9201fb97dfb6996`.
- This closes the outstanding **hosted** permanent offline macOS validation gap. Remaining independent blockers: actual v1 regression macOS job pending, genuine catalog-backed Java adapter/consumer path, canonical `pkg install` contradiction owned by `pkg-dependency-resolution`, stable physical host checks, and normative v1-to-v2 promotion alignment. Only this handoff was changed; no source, suite, schema or mainline mutation.

**Verified jq macOS PASS; offline macOS retry 3 queued — 2026-11-04 (prior):**
- Fresh mandatory repository-HEAD, current rules/specification/handoff, pinned GitHub workflow and permanent-test preflight completed. Product/catalog feature and mainline code remain unchanged.
- Exact jq v1→v2 macOS migration **PASS**: [GitHub Actions run 41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821) attempt `3`, job `126784922095` completed `success`. Verified all job steps passed and authentic log emitted `CHECKPOINT: v1 concrete uninstalled through public pkg` and `PASS: real v1-to-v2 exact jq reinstall and public default restoration`. The *overall run* is `cancelled` because another macOS v1 regression matrix job was cancelled; do not confuse this with the successful jq migration job. Pinned source/catalog for jq remains `m-os@28d9ece912fef151e21a0bd0559904614c2a60e2` / `pkg-catalog@25ca1daca3095f71614af1e7e9201fb97dfb6996`.
- Exact current-runtime permanent offline [run 41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269) attempt `2` macOS job `126770988387` completed `cancelled` without any steps; no logs (`404 BlobNotFound` observed). This is no product PASS/FAIL. Issued a targeted rerun of that cancelled job; GitHub Actions returned `success=true`. Attempt `3` macOS job `126814019571` is now `queued`, and paired Ubuntu job `126814112025` has completed `success` on the same pinned suite. No extra retries while pending. Pinned inputs remain `pkg-catalog@420e0870b81c77fb34cb125822ba76501516a35c`, `m-os@8fb1db493a3265f77bb36ac604a2a1a495a4d448`, `rumiai-tests@cf6ef10bc5d43f15988f23ba621515363a5bacb7`.
- Prior genuine Node.js v1→v2 [run 41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220) attempt `2` remains successful on hosted Ubuntu and macOS. The task still lacks completed macOS offline permanent suite, real Java catalog-backed integration and stable physical-host evidence. The independent `pkg-dependency-resolution` owner retains canonical install-contract mismatch; v2 mainline promotion not yet authorized by evidence/consistency gate.
- No runtime, catalog, permanent-test or mainline changes; only this handoff checkpoint was updated.

**macOS jq retry 2 cancelled before execution, retry 3 accepted — 2026-11-04 (prior):**
- Fresh remote HEAD / current canonical package and testing / handoff / relevant workflow and test preflight completed. Exact catalog/runtime feature and mainline HEADs remain unchanged.
- Older broad real jq migration [41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821), exact catalog `25ca1daca3095f71614af1e7e9201fb97dfb6996` and runtime `28d9ece912fef151e21a0bd0559904614c2a60e2`: attempt `2` macOS jq job `126763358351` changed from queued to `completed/cancelled` **without any steps**. GitHub log fetch returned 404 BlobNotFound, so this is *not* a new HTTP 403, test PASS, test FAIL, or confirmed product regression. Job-specific cancellation cause was not exposed by the available evidence.
- Executed one focused rerun of that cancelled jq job and GitHub returned `success=true`. The same run is now attempt `3`, macOS jq job `126784922095`, `queued` at checkpoint; do not duplicate while queued.
- Current-runtime permanent offline [41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269), exact catalog `420e0870b81c77fb34cb125822ba76501516a35c`, runtime `8fb1db493a3265f77bb36ac604a2a1a495a4d448`, permanent suite `cf6ef10bc5d43f15988f23ba621515363a5bacb7`: attempt `2` macOS job `126770988387` remains queued, Ubuntu PASS. Previously confirmed genuine Node.js migration [41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220) attempt `2` is full Ubuntu+macOS hosted PASS.
- No runtime/catalog/schema/test/manual/mainline changes; physical validation, Java adapter gap and separate package-install contract realignment remain open.

**Offline macOS targeted retry accepted, jq rerun still queued — 2026-11-04 (prior):**
- Reverified current remote HEADs for `rumiai-dev`, `m-os`, `pkg-catalog` and `rumiai-tests`, and reread mandatory current package/testing specifications, handoff, workflow definitions and selected permanent tests. Product and catalog feature/mainline revisions remain unchanged.
- Issued an exact job rerun for the prior `cancelled` macOS current-runtime offline permanent suite job `126633727371`, receiving `success=true` from GitHub Actions. Run [41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269) now has attempt `2` with macOS job `126770988387` `queued` and no steps/results; it is NOT PASS or FAIL. Its unchanged pinned inputs are `pkg-catalog@420e0870b81c77fb34cb125822ba76501516a35c`, `m-os@8fb1db493a3265f77bb36ac604a2a1a495a4d448`, and `rumiai-tests@cf6ef10bc5d43f15988f23ba621515363a5bacb7`; attempt `1` Ubuntu job `126633726885` already passed the permanent 4/4 suite.
- Rechecked jq macOS v1→v2 retry [41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821), attempt `2`, job `126763358351`: still `queued`, with no executed steps or log. Do not duplicate this attempt; it uses older exact pinned catalog/runtime revisions. The real Node.js v1→v2 hosted Ubuntu+macOS PASS remains [41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220) attempt `2`.
- No product, package schema, test, manual or mainline mutation was made. Pending hosted macOS CI is not equivalent to physical reference-host validation. The Java adapter and canonical package-install contract consistency issues remain open.

**GitHub Actions pending macOS validation recheck — 2026-11-04 (prior):**
- Completed the mandatory fresh HEAD/specification/handoff/test preflight. At the new check, exact jq macOS v1→v2 rerun `41829939821` attempt `2`, job `126763358351`, is still `queued`; it has no new execution result or log. Do not duplicate this already-accepted rerun or classify it PASS/FAIL.
- Exact current-runtime permanent offline suite `41847205269` remains attempt `1`: Ubuntu job `126633726885` PASS, macOS job `126633727371` `cancelled`. A targeted rerun of the cancelled job was attempted, but the connected action was blocked and did not return success; subsequent GitHub run/job inspection still shows attempt `1` with the same cancelled macOS job. No retry execution may be claimed. Its concurrency policy cancels superseded runs of the same offline workflow; do not treat cancellation as product-test failure.
- Prior real Node.js v1→v2 Ubuntu and macOS PASS from `41846697220` attempt `2` remains intact. No runtime/catalog/test/mainline modification or physical validation occurred in this check.

**Targeted GitHub Actions re-executions after upstream HTTP 403 — 2026-11-04 (prior):**
- On user request after several hours, executed two GitHub Actions API job rerun operations against the exact previously failed macOS jobs. Both requests returned `success=true`: jq job `126574203579` in run [41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821), and Node.js job `126631953172` in run [41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220). GitHub created attempt `2` for each run. Despite individually targeted rerun requests, GitHub also listed fresh jobs for other matrix entries; do not claim only the failed jobs physically executed.
- **Node.js migration now PASS on both GitHub-hosted Ubuntu and macOS:** run `41846697220` attempt `2` completed SUCCESS. New macOS job `126763147857` completed PASS and full retrieved log shows real v1 Node.js removal with preserved managed HOME, live v2 Node.js HTTP index through public `pkg depend`, exact v2 install and provider/context/launcher assertions, v2 exact uninstall/reinstall, and successful rereading of both v1→v2 and v2→v2 HOME sentinels; terminal PASS marker at 2026-11-04T18:08:14Z. Pinned catalog `pkg-catalog@1a6190c29ba48bdef60d69022f6312c2e32122ae`, autonomous runtime `m-os@8fb1db493a3265f77bb36ac604a2a1a495a4d448`; this is hosted CI evidence, not a stable physical-host PASS.
- Older broad jq v1→v2 migration run `41829939821` attempt `2` was still queued at the latest check. The new macOS jq job `126763358351` is queued, without a result or log. Other scheduled matrix entries already reported 12 PASS, while macOS v1 regression job was cancelled. The older broad workflow pins `pkg-catalog@25ca1daca3095f71614af1e7e9201fb97dfb6996` and `m-os@28d9ece912fef151e21a0bd0559904614c2a60e2`; keep this separate from newer catalog/current-runtime validations.
- No source, schema, test or mainline code changes. The previous unresolved package-model/batch-install consistency issue, Java adapter gap and reference-host physical tests remain independently open.

**V2 CI and manual consistency checkpoint — 2026-11-04 (prior):**
- The exact Node.js migration run 41846697220 has Ubuntu PASS and macOS FAIL: macOS job 126631953172 received upstream GitHub Releases HTTP 403 during its first v1 Node.js install, before any schema transition. The cause of the 403 was not proven from response headers. No macOS migration PASS is claimed.
- Current-runtime permanent workflow 41847205269 has Ubuntu PASS (4/4) and macOS queued. Older broad matrix 41829939821 has 12 PASS, 1 macOS jq failure on upstream HTTP 403 before migration, and 1 macOS v1 regression queued.
- Audited current v2 runtime changed library/manual surfaces. The pre-existing pkg-install manual omitted three current public-named functions. A documentation-only correction is committed on m-os/pkg-schema-v2 at dad7c0d288f4e59f9f0f89174803e13622adb282; code, schema and mainline are unchanged. The separate pkg-dependency-resolution handoff still owns eventual public/internal naming realignment.
- Found an unresolved canonical discrepancy: PACKAGE-MODEL Installation describes best-effort invalid operands, while PKG-99 requires aborting before mutation for any invalid operand. The installed-source loop also exits on the first per-operand install failure. Coordinate with the existing pkg-dependency-resolution owner; do not silently reconcile or claim promotion readiness.
- Java catalog-backed consumer coverage, macOS launchd and physical Ubuntu ARM64 reference-host validation remain open. Retain v2 branches until applicable evidence and canonical consistency permit promotion.

**V2 real Node.js v1-to-v2 migration and fresh permanent suite pin — 2026-11-04 (prior):**
- Fresh mandatory remote-HEAD/specification/handoff/test preflight completed. `m-os/pkg-schema-v2@8fb1db493a3265f77bb36ac604a2a1a495a4d448` and `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` remain unchanged. Rechecked that `pkg-catalog/pkg-schema-v2` is ahead of `main@7892040e` with no commits behind; neither mainline was modified. Independent `rumiai-dev` and `rumiai-tests` changes touched unrelated chat and rsudo/web areas and were preserved.
- Inspected exact 14-job v2 matrix [41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821) at `pkg-catalog@25ca1daca3095f71614af1e7e9201fb97dfb6996` and pinned older `m-os@28d9ece9`. **12/14 jobs completed SUCCESS**, including real macOS v2 jq install/direct/wrapped command and Ubuntu real v1→v2 jq reinstall. macOS v1→v2 jq reinstall job `126574203579` **FAILED before the migration**: first real v1 `pkg install jq@jq-1.8.2` received upstream `https://api.github.com/repos/jqlang/jq/releases/tags/jq-1.8.2` HTTP 403, followed by expected missing-descriptor/install-failed diagnostics; no observed transition result. This establishes an upstream 403, not its precise rate-limit cause and not a product regression. macOS v1-regression job `126574203378` remains queued; run-level status is queued, not 14/14 PASS. Do not rapidly repeat the 14-job matrix.
- Updated **only** `pkg-catalog/.github/workflows/validate-v2-nodejs.yml` in `pkg-catalog/pkg-schema-v2@1a6190c29ba48bdef60d69022f6312c2e32122ae`: check out exact v1-only catalog `7892040e`, then use current real `m-os@8fb1db49` to install genuine v1 Node.js `v26.8.2`, execute public `m node`, create managed user HOME state, uninstall the exact v1 concrete, switch only the derived catalog cache/selector to v2, invoke the live Node.js HTTP index through public `pkg depend`, install exact v2 Node.js, validate preserved v1 data through public launched Node, then uninstall/reinstall v2 and revalidate both v1/v2 state sentinels, launcher/default/context/provider semantics. No synthetic artifact, API adapter or runtime bypass was used.
- New exact workflow [41846697220](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41846697220), Ubuntu job `126631952633`, **completed PASS** and its full log reached the new v1→v2 and v2→v2 state-preservation final PASS marker; macOS job `126631953172` remains queued. Workflow and code diff reviewed; no product/command/library/schema/manual change. This adds live catalog-backed v1→v2 mutable-state evidence on hosted Ubuntu, **not yet macOS**.
- Re-pinned the existing permanent offline mixed-schema workflow (one SHA line only) to exact current `m-os@8fb1db49`, retaining unchanged exact `rumiai-tests@cf6ef10bc5d43f15988f23ba621515363a5bacb7` suite, in `pkg-catalog/pkg-schema-v2@420e0870b81c77fb34cb125822ba76501516a35c`. New run [41847205269](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41847205269) Ubuntu job `126633726885` **PASS 4/4**, 0 FAIL/SKIP/ERROR; macOS job `126633727371` remains queued. The selected permanent-test files are unchanged from pinned suite revision despite independent `rumiai-tests/main` work. Latest `pkg-catalog/pkg-schema-v2` is **89 ahead / 0 behind** `main`; no product change and no mainline promotion.
- Remaining separate gaps: the autonomous `m-os` source lacks the catalog-required `apache-maven`/`temurin` adapters for a genuine Java consumer/provider pair; macOS `launchd` and physical Ubuntu 26.04 ARM64 reference hosts have not been exercised. `PACKAGE-MODEL.md` still canonically publishes v1; do not reclassify feature-branch v2 as promoted. Existing package-store trust and `rumiai-validate` target contracts remain untouched.

**V2 live Node.js evidence and forward-only catalog reconciliation — 2026-11-04 (prior):**
- Verified current repository HEADs and re-read canonical rules, package/testing contracts and the active handoff. The current `m-os/pkg-schema-v2` runtime remains `8fb1db493a3265f77bb36ac604a2a1a495a4d448`; no product/schema implementation was changed.
- Exact `pkg-catalog@2c71b2180a4c5e270f33e00a67ddb8ca190d2b8c` Node.js run **[41840170587](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41840170587)** completed **SUCCESS, 2/2 jobs**: GitHub-hosted Ubuntu job `126609358482` PASS and macOS job `126609359325` PASS. Retrieved both full job logs: each executed real public `m pkg depend nodejs` across the live external Node.js HTTP index, then real pinned `pkg install nodejs@v26.8.2`, launcher/HOME/context/provider checks, exact uninstall/reinstall and preserved HOME sentinel, reaching the terminal PASS marker. No FAIL was observed in either job. This is hosted evidence, not physical reference-host or formal `rumiai-validate` evidence.
- `pkg-catalog/main` contained two concurrent commits absent from `pkg-schema-v2`: a v1 workflow repository rename correction and three v1 Electron stream version additions. Reconciled **main into feature only**, with exact parent commits `pkg-schema-v2@2c71b2180` and `main@7892040e`, producing merge `pkg-catalog/pkg-schema-v2@6d810478657fc2937633b27e0e773b531e96e9d2`. Created its tree by retaining the feature tree and reusing the four current main blobs; advanced the feature ref without force. Verified `main...pkg-schema-v2` is now **87 ahead / 0 behind**, all four files equal main, and the v2 Node.js workflow blob unchanged. Neither mainline was promoted or modified.
- Broader exact `pkg-catalog@25ca1daca3095f71614af1e7e9201fb97dfb6996` CI run **[41829939821](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/41829939821)** remains **queued** at this checkpoint: its 7 Ubuntu jobs are completed PASS (including real jq v1→v2 reinstall) and 7 macOS jobs are queued. Do not assert 14/14 or transfer this pre-merge revision's result to the merge commit.
- A genuine catalog-backed Java consumer path remains unproven: current `v1/pkg/maven` and `v1/pkg/temurin` use repository adapter types `apache-maven` and `temurin`, whereas the autonomous `m-os` repository currently has only artifact/chrome/chromium/github/nodejs repository libraries. Do not disguise setup-java or synthetic Java provider fixtures as a full catalog-backed install. Adding missing adapters or changing schema is not authorized by this checkpoint.
- Concurrent `rumiai-dev` and `rumiai-tests` HEAD movements touched other task areas and were not overwritten. Physical Ubuntu 26.04 ARM64 and physical macOS launchd validation remain open. No `m-os/master` or `pkg-catalog/main` promotion occurred.

**V2 package-store permission audit and Node.js branch alignment — 2026-11-04 (prior):**
- Performed the current mandatory HEAD/specification/handoff preflight and inspected the live v2 `pkg-install`, `pkg-integration`, `pkg-uninstall`, state implementation, hosted permanent tests and current `rumiai-validate` target path.
- **Filesystem audit:** `pkg install` sets `umask 077`; `pkg_integrate` creates the concrete, moves the useful `root/` tree and materializes symlink views, but has no final ownership or OS-enforced read-only sealing step. The existing permanent adversarial tests successfully replace installed links while run as the same owner. Thus the spec's **immutable concrete** describes managed materialization semantics, not a proven filesystem access-control guarantee against that owner. No `chmod`, privileged ownership switch or new mediated execution model was added: those would affect lifecycle, update, mutable-state routing and portability, requiring a deliberate contract choice. The selection-time `pkg default`/`context`/global-facility checks cannot protect direct symlinks modified *after* selection.
- **Formal validation evaluation:** current `rumiai-validate` command, `lib/sh/rumiai-validate.lib.sh`, evidence metadata, checkout cloning and bootstrap are explicitly coupled to `rumiai-os`; simply adding a `validation/*.conf` selector for `m-os` would misidentify the target and would not prepare a clean autonomous checkout. Supported `m-os` formal validation needs a separately authorized target contract/launcher realignment, not an opportunistic config-only claim.
- **Node.js branch reconciliation:** current `m-os/master` filtered index records to the configured major while `pkg-schema-v2` independently excluded prerelease tags. `m-os/pkg-schema-v2@8d39c188e7a1a1f4a6d3f8308281411564360810` retains **both** conditions in a small internal record-filter function used by the real Node adapter; it still strictly rejects malformed selected-major stable releases and duplicate stable versions. Public adapter signatures and operational manual remain unchanged. An initial source extraction introduced a shell heredoc syntax defect; this was corrected **forward-only** before the final successful run, and the permanent test checks shell syntax to prevent a similar false SKIP.
- **Permanent offline regression:** `rumiai-tests/main@cf6ef10bc5d43f15988f23ba621515363a5bacb7` adds executable `tests/m-os/pkg-schema-v2/nodejs-index.test` exercising the actual adapter's new filter against parsed-index-shaped synthetic input, including foreign-major malformed data, current-major prerelease, valid stable versions and invalid selected-major data. It does **not** exercise `http-fetch`, upstream Node availability, archive checksums or full installation; those remain separate.
- Exact pinned `pkg-catalog/pkg-schema-v2@ed613dcbd8deea261f299b31eeaf8e7976c4b21c` workflow run **`41821850370`**, Ubuntu job **`126546677016` PASS 4/4** permanent offline tests, 0 FAIL/SKIP/ERROR; macOS job **`126546677383` completed PASS 4/4** at the same pinned revisions; exact workflow **`41821850370` completed SUCCESS, 2/2 jobs, 8/8 permanent tests PASS, 0 FAIL/SKIP/ERROR** as confirmed by both job logs on 2026-11-04. Previous superseded runs were cancelled and do not alter this revision-specific result. No GitHub Releases requests were made.
- All commits were forward-only; unrelated concurrent changes in other repos were preserved, and `m-os/master`/`rumiai-os/main`/`pkg-catalog/main` were not modified. Feature branch `pkg-schema-v2` remains unmerged and physical validation remains open.

**V2 global facility command projection confinement — 2026-11-04 (prior):**
- Current remote HEADs, mandatory `rumiai-dev` read order, authoritative package/diagnostics/library/manual/testing contracts, active handoff and exact `m-os` provider planner and permanent suite were checked before this work. The previous exact hosted run `41814931647` was **cancelled** (Ubuntu PASS, macOS never completed), so the formerly queued macOS test must not be counted as PASS.
- Source audit found that `_pkg_provider_global_plan_concrete` on v2 inspected a `facility-cmd/<facility>/<command>` symlink for executable resolution but did not verify that it still pointed to that concrete's own `../../link/bin/<command>` or that this nested v2 command view remained confined. This is distinct from previously fixed ordinary `pkg default` and `context` selection.
- Extended permanent `rumiai-tests/tests/m-os/pkg-schema-v2/mixed-provider-lifecycle.test` at `rumiai-tests/main@152131dac7503d58ebcbabfb9cb57dae32b5611b` with two isolated, deliberately corrupted *installed* v2 projections: an altered `facility-cmd` symlink and an altered underlying direct `link/bin` symlink. It asserts public `m pkg provider default` refusal, preservation of the previous global provider selector/command, and no accidental execution of the external sentinel. The original runtime was confirmed failing the first new assertion on Ubuntu at exact `pkg-catalog` run `41818025055` (other two tests PASS); that run's macOS job was not completed and the run was superseded/cancelled.
- `m-os/pkg-schema-v2@9e55d29fc6a1db285dac0715f03816e69e43a0de` adds a bounded v2-only validation at the existing provider-global-plan boundary: the installed facility member must retain its generated `../../link/bin/<same command>` projection, and the existing shared `_pkg_v2_installed_command_validate` must accept the concrete-local direct/wrapper view. Distinct internal errors use diagnostic identities `provider-global-command-link-unreadable`, `provider-global-command-link-invalid`, `provider-global-command-target-invalid` and statuses 3/4/5. Legacy v1 planning, public selector syntax and ownership model stay unchanged. `res/sys/manual/pkg-provider.lib.sh` was checked and updated for the observable selection-time behavior.
- Exact pinned `pkg-catalog/pkg-schema-v2@e0240815b64faec5c9233f9511f3792e16e17d5d` CI run **`41818454082`**, Ubuntu job **`126535190399` PASS 3/3** permanent lifecycle, provider and rollback tests; runner summary 0 FAIL, 0 ERROR, 0 SKIP. The corresponding macOS job **`126535191057` was queued at last inspection**, not PASS. The tests used the real autonomous `m-os` integration/selector/launcher on hosted runners with external fixture executables, not an upstream artifact-backed or physical validation. No GitHub Releases downloads were required.
- Trust boundary: all three selectors now validate installed v2 direct/wrapped paths **when changing selections**; subsequently modified package-store symlinks remain a filesystem integrity concern because native direct commands intentionally bypass the launcher. The current semantic model calls installed package materialization immutable but this increment does **not** establish OS-level write protection or a runtime sandbox. Do not claim post-selection resistance to an actor with filesystem write access or introduce a new execution boundary without an explicit settled contract.

**V2 context command-view validation — 2026-11-04 (prior):**
- Current repository preflight, mandatory read order and canonical package, bootstrap, library, diagnostics, documentation and testing rules were checked. Exact feature branches remain separate from mainline.
- Added a permanent context activation regression in `rumiai-tests`. The old runtime accepted a modified installed v2 direct command link that should have been rejected, confirmed by Ubuntu CI `41813611577` (other tests passed).
- `m-os/pkg-schema-v2@6168cb059592281700abe1e350f076afb1a7112e` shares one v2 command-target validation helper across `pkg default` and `context`. It preserves v1, checks root/wrapper destinations, and adds diagnostic `context-command-link-invalid` with return 18. Relevant operational manuals were updated.
- `rumiai-tests/main@9038a8c8d2b649ded2f0bf268f762714e776528d` checks rejection, unchanged prior PATH/default and return 18. `pkg-catalog/pkg-schema-v2@f675e9669954a9b62dacda944156f6c18ee2b0d4` pins exact revisions and adds same-branch CI concurrency to avoid redundant future offline runs.
- Run `41814931647`, Ubuntu job `126523175062`: **3/3 PASS** with no FAIL, ERROR or SKIP. macOS job `126523286614` was queued at last inspection; no result is claimed. No GitHub Releases downloads were used.
- Selection-time checks do not guarantee integrity after selection if the installed filesystem is later modified. Native direct commands intentionally do not traverse the package launcher. The immutable installed-concrete trust model and any stronger OS enforcement remain a separate consideration; no additional security property is claimed. Formal and physical validation remain open.

**V2 adversarial installed-link containment and post-mutation rollback checkpoint — 2026-11-04 (prior):**
- Fresh preflight checked involved remote HEADs and current `rumiai-dev` mandatory rules, specification router, package/state/bootstrap/library/documentation/diagnostics/testing contracts and this active handoff before modifying code. Current `m-os/pkg-schema-v2` implementation, library manual, permanent suite, exact workflow and expected default/global reconciliation phases were inspected. Forward-only changes preserve unrelated concurrent work.
- `rumiai-tests/main@ff7aeffdb5dbf619860fdf290bb429c405ea0a01` extends `mixed-default-lifecycle.test` with a **previously integrated v2 direct `link/bin` symlink redirected to a real executable outside the concrete**. The external sentinel executable is never run; only public `m pkg default` rejection, preserved legacy current/default and absence of the escaped public command are checked. Exact pre-fix `m-os@cc589863` + suite revision, catalog CI `41809197598`, failed that property on **both Ubuntu and macOS** while other lifecycle assertions passed: a real default-publication defect, not a fixture setup error.
- `m-os/pkg-schema-v2@f8d091a9a1e9194bf542273fee48029c676ad4b4` modifies only `lib/sys/sh/pkg/pkg-integration.lib.sh`: introduces internal `_pkg_default_command_validate` for installed v2 `link/bin` entries and invokes it in existing current/new binding validation and new binding creation. For v2, a wrapper symlink must retain exactly `../../cmd/<same-command>` pointing at an executable non-symlink wrapper of the same concrete; a direct symlink must be shaped `../../root/<relative>` and resolve to an executable within that useful root via the already-owned `_pkg_integration_v2_root_target_validate`. V1 command view and public API/status contract remain unchanged. No novel schema, resolver, namespace, manual API or runtime abstraction; library manual `res/sys/manual/pkg-integration.lib.sh` remains semantically correct, as does the current package contract. Exact CI `41809602076` **2/2 PASS** on hosted Ubuntu and macOS for the amended two-test suite (including the adversarial regression). This proves rejection **on subsequent package-default selection**, not that an already-selected direct command stays safe after a later arbitrary store tamper or that all consumers revalidate link/bin at execution.
- `rumiai-tests/main@009217b3` adds independent permanent `tests/m-os/pkg-schema-v2/default-transaction-rollback.test`. This test synthesizes only external provider contract/command input, integrates two real v2 package concretes with an env-only facility, selects version 1 and configures its **unversioned** global facility default, captures all seven materialized global-environment snapshot checksums and public command link, then corrupts the installed env value of version 2. The **real** `m pkg default <provider>@2` reaches package-default mutation but fails on global environment regeneration; assertions require restoration of package selector, command publication, facility-default intent, real bootstrap value, and identical snapshots. Repair of fixture metadata then permits v2 selection and renewed v1 selection. No product function/adapter replacement, race, API download or package-root clone.
- First rollback workflow `41810323686` produced `ERROR` before scenario execution because the new `.test` had erroneously been committed with non-executable Git mode `100644`. Corrected forward-only to `100755` in `rumiai-tests/main@ffd8967fe97a4d4cab56ad3bc4d2ab8452aee817`. `pkg-catalog/pkg-schema-v2@4b8fdc2b3296d5cc140323cef03f5bd5a6f6a829` pins exact `m-os@f8d091a9` and `rumiai-tests@ffd8967f`. Run **`41810556130` completed 2/2 hosted jobs PASS**: Ubuntu `126508432936` and macOS `126508433074` each log all **three permanent tests PASS**, with **0 FAIL, 0 ERROR, 0 SKIP**. This is six individual hosted test results; it covers the exact pinned technical runtime and suite revision, not physical-host or formal rumiai-os validation. Earlier two-test macOS link-fix PASS remains independently valid for `41809602076`. No anonymous GitHub Releases API requests were made.
- `rumiai-tests/main@5f69fb7b1279398b6e7d323dbd0f0b14aab8eeae` additionally documents explicit autonomous m-os target selection, optional pkg-catalog path, and non-formal runner versus formal `rumiai-validate` distinction in suite README; no test behavior changed. Neither frozen `rumiai-os` nor `m-os/master`, package catalog mainline, or canonical specification was changed by this work unit. Physical host validation and formal m-os validation pathway remain open.

**V2 permanent mixed-schema lifecycle suite checkpoint — 2026-11-04 (prior):**
- Mandatory fresh preflight checked all involved current remote HEADs, `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, specification router, current package/state/bootstrap/test/runner/test-authoring contracts, and this active handoff. Inspected the real `m-os/pkg-schema-v2` implementation and existing permanent tests in `rumiai-tests/main`; the existing permanent `rumiai-os/pkg/{default,uninstall,state,native-launcher-reinstall}` tests already protect legacy semantics, so this increment adds **target-specific v2 coverage** rather than duplicating those normal v1 tests.
- **Permanent tests committed** as `rumiai-tests/main@446e57294932d5add79d5d356f1d8a3a65dc8ff1`: `tests/m-os/pkg-schema-v2/mixed-default-lifecycle.test`, `mixed-provider-lifecycle.test` and the small `lib/m-os-target.lib` target-discovery helper. The two real integration/launcher fixture scenarios were transferred from m-os development scripts and run as independent executable `.test` files with canonical 0=PASS/1=FAIL/2=SKIP/3=ERROR statuses through `rumiai-test`. They require the **explicit** real autonomous `RUMIAI_TEST_M_OS_ROOT`; the provider test also requires `RUMIAI_TEST_PKG_CATALOG_ROOT` as a checked-out external facility-contract input. If no m-os target is supplied they are inapplicable and SKIP; a configured invalid target is an ERROR. These tests do not clone or fake the runtime or call GitHub Releases.
- `pkg-catalog/pkg-schema-v2@a8ef00cf` introduced exact suite pin `rumiai-tests@446e5729` and real `m-os@ba42d7b0` with `rumiai-test --list` followed by normal selected-group execution on hosted Ubuntu/macOS. Run `41806159425` **2/2 jobs PASS**, each with both permanent tests PASS and zero FAIL/SKIP/ERROR; no external release downloads.
- The now-duplicated `m-os/.github/scripts/pkg-v2-default-coexistence-test.sh` and `pkg-v2-mixed-provider-test.sh` were **deleted forward-only** (`m-os/pkg-schema-v2@cc589863090d5932f2d603985d6ec8dbd47ea696`). No production code was changed. `pkg-catalog/pkg-schema-v2@6cbc0effce563a06f218b43ec995a678a3553fb1` pins this new exact runtime commit; final workflow **`41806479535` 2/2 jobs PASS**, Ubuntu `126494649224` and macOS `126494649758`. Both logs show each test PASS and explicit runner summary **2 PASS, 0 FAIL, 0 SKIP, 0 ERROR**. This validates the retained permanent tests against the repository with duplicated scripts removed.
- Formal validation distinction: current `rumiai-validate` specifically prepares **rumiai-os** product revisions; the focused `m-os` feature-branch checks here run through the genuine `rumiai-test` runner and real technical target, but **not** a formal `rumiai-validate` disposable product session. Hosted runners are not the stable physical ARM64 or real macOS launchd service hosts, and synthetic node executable payloads do not validate upstream Node.js install.
- **Installed-link/rollback audit (source inspection only):** installed v2 `link/bin` commands are symlinks; `pkg default` checks their resolved file/executable state and the ownership of published *public* symlinks, but does not explicitly revalidate that a previously installed `link/bin` symlink still resolves only inside the concrete's `cmd` or useful `root`. The trusted launcher independently validates root containment for **wrapped** `link/target` execution, whereas a **direct** v2 symlink does not enter the launcher. Whether immutability of managed installed materialization is a sufficient post-install trust boundary or default revalidation should be strengthened needs a separate focused acceptance test and contract decision; no arbitrary executable-escaping link was actually executed in this increment, and no vulnerability/exploitability claim is established. Similarly, existing invalid-descriptor and broken-symlink tests prove **pre-mutation refusal**, not failure rollback after partial materialization. Both remain open; do not silently promote new semantics or fabricate a PASS.
- Scope: only the new permanent test files/helper in `rumiai-tests`, deletion of duplicate m-os fixture test scripts, exact pinned catalog CI orchestration and this handoff. Current canonical specifications, m-os product code/manuals, `m-os/master`, `pkg-catalog/main`, and frozen product implementations were not edited. `v2` remains unmerged and master/v2 Node.js adapter reconciliation remains pending.

**V2 mixed-schema uninstall, refusal and reintegration checkpoint — 2026-11-04 (prior):**
- Preflight verified current remote HEADs and followed the mandatory current `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, package/state/testing specifications and active handoff before editing. Inspected the real v2-branch `pkg-uninstall`, `pkg-integration`, `pkg-state`, `pkg-provider`, the current offline mixed-schema fixtures, and their existing catalog-hosted matrix. There is **no product/runtime change** in this checkpoint.
- `m-os/pkg-schema-v2@980401be` extends the existing mixed ordinary-package fixture with public `m pkg uninstall` of an unselected v2 concrete, local **re-`pkg_integrate`** from a fresh captured test payload, continued absence of an automatically selected default, and then removal of the current v2 concrete (the public selector and both ordinary command projections must disappear) while v1 remains independently installable/selectable. It checks `state-path user pkg <name> home` retains its user-written sentinel through both uninstall/reintegrate cycles and final legacy removal. A damaged **broken** installed link blocks a default change without losing the prior selection; an escaping `link/bin` **definition** is rejected before consuming the input root, publishing a concrete or altering the existing selected command. This does not establish rejection of *all* possible executable escaping installed links and does not exercise a partial post-mutation rollback; those are separate cases.
- `m-os/pkg-schema-v2@b2a96632` extends the existing mixed consumer/provider fixture: public provider uninstall refuses a concrete referenced by a consumer binding and a different one referenced by the global facility default, leaving the referenced concrete and consumer execution intact. It also verifies release of these references, successful provider removal when no explicit reference remains, implicit single-provider consumer resolution, consumer v2 uninstall/reintegration with v1 default unchanged, retention of managed consumer user HOME, and clearing of the selected consumer default on uninstall. Providers' external command payloads remain synthetic and the central v2 nodejs facility contract is copied unchanged; all tested package/provider/default/launcher mechanisms are real.
- Initial catalog workflow `41800303619` failed at fixture status 41: the fixture incorrectly expected `pkg provider default nodejs <provider>@999` to reject a **syntactically valid but currently unavailable explicit selector**. Canonical provider rules allow retaining that authoritative intent; resolution must fail rather than fall back. Corrected the **test**, not the product, in `m-os/pkg-schema-v2@ba42d7b0b5469ddefd164c1578c46531451b7098`: asserts the unavailable pinned default is stored; `pkg requirement resolve` fails; an independent consumer binding still wins; and a malformed selector syntax is rejected without altering a restored valid default.
- `pkg-catalog/pkg-schema-v2@78efe555fcf025623bb83583636fdb53d01daf7d` pins the isolated, no-GitHub-Releases `validate-v2-coexistence.yml` to exact `m-os@ba42d7b0`. GitHub Actions run **`41800547236` completed 2/2 PASS**: Ubuntu job `126474941297` and macOS job `126474940878` each logged both positive fixture PASS markers after real execution. It did not download jq, Node.js releases or any real software artifacts; it was not a full previously run 12-job suite or physical reference-host validation.
- Scope and limits: changes are confined to these two `m-os` test scripts, one exact pinned CI workflow ref, and this handoff. No code/library/manual/specification or frozen/mainline product files were modified; `pkg-schema-v2` remains unmerged. Material pending cases are post-mutation transaction rollback, more adversarial *existing executable* escaping-link tampering, current revision formal `rumiai-tests` integration, real artifact-backed uninstall/reinstall plus physical validation, and the previously logged master/v2 Node.js adapter divergence before any merge.

**V2 mixed installed-schema/default/provider lifecycle checkpoint — 2026-11-04 (prior):**
- Verified current involved remote HEADs, re-read the canonical `rumiai-dev` rules, package/default/launch/provider specs, testing contract and this active handoff, and inspected the existing current `m-os/pkg-schema-v2` launcher, schema reader, integrator, package-default transitions, provider selectors and prior fixture tests. The missing covered property was **transitioning an ordinary package default across genuine coinstalled v1 and v2 concretes of the same package identity**; the existing context coexistence fixture depended on an externally downloaded v2 jq and did not exercise package-default transitions.
- Added test-only `m-os/.github/scripts/pkg-v2-default-coexistence-test.sh` at `m-os@fe8c3047`: integrates actual v1@1 and v2@2 concrete layouts from local fixture useful roots, then exercises public `m pkg default` v1 → v2 → v1 → unset, public command symlink target updates/removal, v1 launcher, v2 wrapped entry with fixed argv and package environment, v2 direct entry (which deliberately does not apply wrapper environment), failed nonexistent-version change preserving the previous view, and independent shell-local `context` selection/reset. This is an integration/launch test through real m code, not a download or upgrade-in-place scenario.
- Added test-only `m-os/.github/scripts/pkg-v2-mixed-provider-test.sh` at `m-os@380d0f43`: copies the **actual** catalog v2 nodejs facility contract, integrates two synthetic-external-provider v2 package versions (same facility level), and both v1/v2 installed consumer schema versions declaring `nodejs =26`. It checks consumer version default transitions, global facility default provider@1 → provider@2 transitions (both provider concretes are v2 schema), explicit consumer binding precedence surviving a consumer default change, restoration after unbinding, failure on unresolved ambiguity when no default/binding exists, and binding-based recovery. Every observed consumer output comes from the real package launcher/real selected facility command (external `node` payloads are fixtures). No GitHub Releases downloads.
- The first focused catalog workflow `41796228855`, catalog `cb1f2b6b` pinned to `m-os@e79520a9`, completed **2/2 PASS** on hosted Ubuntu/macOS for the default/direct-wrapper scenario. Expanded exact workflow `pkg-catalog/pkg-schema-v2@a2f3e17a50b871bf935a9e4feee07c8ceafcab03` (run **`41796604094`, both jobs PASS**) checked both new fixtures on Ubuntu and macOS; verified each log prints both expected PASS markers and no failing assertions. Both checked out exact `m-os@380d0f43992c22123042cf389675c658e770d193`. This is **2/2 hosted CI jobs containing two genuine real-integration fixtures each**, not physical validation, and not a fresh rerun of prior jq/Ollama/Node.js workflows.
- A newly introduced m-os-hosted workflow did not schedule from the feature branch; its untriggered copy was **deleted forward-only** at current `m-os/pkg-schema-v2@7fee9e02bb7e7b2ef377c05cb085b0155bde8706`. That commit differs from the tested `m-os@380d0f43` **only by deletion of this unused workflow**, not by a code/test behavior change. The effective focused CI lives in `pkg-catalog/.github/workflows/validate-v2-coexistence.yml`; unlike the broad jq tests, it requires no release API calls. No production library, operational manual, promoted specification, mainline branch or frozen repository changed.
- Explicit remaining coverage: real upstream v1/v2 reinstall/migration and mutable-state preservation, uninstall/refusal/rollback branches, corrupt/escaping installed-link rejection, possible library/command collisions during transitions, macOS launchd host supervision, Ubuntu ARM64 reference host and eventual package-schema promotion. No new specification/implementation mismatch was established by these passing tests.
- Final HEAD reconciliation discovered **independent concurrent mainline work**: `m-os/master@31693e814f682690adfd48185da822f7f5007f9e` advanced its Node.js repository adapter and live-install workflow; `rumiai-os/main@755dfe2165af0cbb41b8081781675488153d5a39` and `rumiai-tests/main@2c84fc084e7a90110020d7103aff7383cbcf270d` also advanced on other tasks. These branches were not modified by this work unit and the offline v1/v2 tests exercise neither Node.js release discovery nor these concurrent changes. **Forward-reconcile before a v2 merge:** current master Node.js index filtering first restricts entries to the configured major, while the v2 feature branch has a distinct prerelease-filtering implementation; do not silently pick one or label the feature branch as synchronized with master. Keep both changes intact until the relevant current contract and live Node.js adapter tests establish the combined behavior.

**V2 macOS jq upstream-rate-limit recovery checkpoint — 2026-11-04 (prior):**
- User confirmed the repeated GitHub HTTP 403 is believed to arise from excessive anonymous requests and suggested staggered execution or waiting for the approximately hourly reset. Current GitHub REST documentation establishes **60 unauthenticated primary requests/hour per source IP**; a 403 itself is insufficient to establish the specific rate-limit category without `x-ratelimit-remaining`, `x-ratelimit-reset` or a secondary-limit response. Existing m GitHub adapter `_pkg_repository_github_get` uses unauthenticated `http-fetch` and the current workflow makes three attempts only four seconds apart. Earlier failed logs had HTTP 403 but did not capture authoritative rate-limit headers: exact cause remains an inference, not measured diagnosis.
- Rather than trigger another full 12-job matrix, re-ran **only the failed macOS v1-regression job** `126448527466` after more than one hour from its last failure, using the linked GitHub Actions job rerun. Run `41792388863` **attempt 2, job `126453299092`, completed PASS**; job logs include the actual `PASS: unmodified v1 package installs and launches on upgraded m` after a real `pkg install jq@jq-1.8.2` and command execution. With the 11 previously successful jobs in attempt 1, the workflow's **latest attempt reports success**; this is not a single all-12 fresh re-execution. Exact tested revisions remain `pkg-catalog/pkg-schema-v2@e64aed2939d750b0fe261503696c228cf207b2dc` and `m-os/pkg-schema-v2@2caeb3f95f0e0281920da55a79382096208e05b8`.
- Network-test operating decision for this active workstream: distinguish remote download failures from product regressions; do not rapidly repeat an entire matrix or use multiple four-second retries to diagnose a suspected primary limit. Where possible, inspect response rate-limit headers and wait until the reported reset (otherwise conservatively space retries) and re-run only the affected GitHub Actions job. Keep real upstream package installation tests intact; use independent no-network tests for implementation refinement. This work unit **did not change CI scheduling or runtime adapter**, because the targeted delayed rerun resolved the blocker without extra workflow activity or new commits.
- Audited current `pkg-launch.lib.sh`, `pkg-integration.lib.sh`, the v1/v2 `context` coexistence fixture and operator manuals against current `PACKAGE-MODEL.md`: the current launcher reads the installed schema, routes a v1 command through `link/<command>` and v2 through `link/target/<command>`, then applies the same state, package/provider/user environment phases. Existing v2 jq flow covers a real v2 direct/wrapped executable and a co-installed synthetic v1 command through `context`; the isolated macOS v1 regression also confirms an independently installed real v1 jq. More complete tests for lifecycle/default transitions across mixed v1/v2 provider/consumer selection remain open. Audit did not establish a new code-vs-contract mismatch.
- No product, fixture, canonical specification, or workflow files changed for this recovery work unit. Only this handoff changed; no mainline merge and no physical-host or macOS launchd validation claimed.

**V2 cross-facility global environment precedence checkpoint — 2026-11-04 (prior):**
- Verified remote repository HEADs and re-read the mandatory current rules/specifications, test contracts, implementation, existing workflow and this handoff before changing anything. The previously queued general v2 run `41790160639` (catalog `bb640f68` pinned to m-os `151cc990`) finished **10/12 jobs PASS**. Its macOS `v2-global-environment` failed during fixture setup due to nonportable `chmod +x --` (BSD `chmod` treated `--` as a pathname). Separately, macOS `v1-regression` failed after three upstream GitHub jq release API HTTP 403 responses. The other ten jobs, including macOS real v2 jq, passed. Neither failed job established a runtime product regression.
- `m-os/pkg-schema-v2@2caeb3f95f0e0281920da55a79382096208e05b8` changes only `.github/scripts/pkg-v2-global-environment-test.sh`: removes the nonportable `chmod --`, checks for pre-existing fixture concretes and facility defaults before installing a destructive cleanup trap, and extends the synthetic external provider input with a second **independent `nodejs` facility**. It exercises the real v2 integration, global default mutations, snapshots, platform/generic selection and fresh bootstrap with overlapping ordinary `CI_SHARED` values and `PATH` roots. `java` precedes `nodejs` in LC_ALL=C facility order, so the later `nodejs` assignment must win and its PATH segment must precede java's; checks cover all six generated osarch snapshots, both runner-host executions, and changing the earlier java selector to a host-qualified pin while nodejs remains selected. No product/runtime code or operational manual changed.
- `pkg-catalog/pkg-schema-v2@e64aed2939d750b0fe261503696c228cf207b2dc` pins all six matrix workflow jobs to that exact m-os revision. Workflow `41792388863` finished **11/12 PASS**: both `v2-global-environment` jobs (Ubuntu `126448527420`, macOS `126448527613`) PASS with explicit output; all v2 jq/other v2 fixture jobs and Ubuntu v1 regression PASS. The single failed job, macOS `v1-regression` `126448527466`, again received upstream jq release API HTTP 403 in all three installation attempts. This is an unresolved external fetch/CI reliability issue, **not** a 12/12 matrix PASS and not evidence of a v1 runtime regression. Earlier exact-revision real Node.js `41787611004` 2/2 and Ollama `41787617458` 3/3 PASS remain separately valid for their pinned runtime `71b33c6c`.
- Only `m-os` v2 test script, `pkg-catalog` v2 workflow pins, and this handoff were edited in this checkpoint. Mainline `m-os/master` and `pkg-catalog/main`, legacy `rumiai-os` and `rumiai-tests`, and canonical package contracts were not edited; v2 remains unmerged. Host-backed macOS CI and Ubuntu CI are not physical reference-host validation; service supervision through macOS launchd remains unchecked.

**V2 generic/osarch provider global environment checkpoint — 2026-11-04 (prior):**
- At the start of this increment, verified all involved remote branch HEADs and reread current `rumiai-dev` rules, specifications, test contracts and this handoff. The previously queued `pkg-catalog` generic v2 workflow **`41787604558` completed 10/10 PASS**, including both macOS jobs; Node.js `41787611004` 2/2 PASS and Ollama `41787617458` 3/3 PASS at prior exact m-os `71b33c6c`. This closes that checkpoint's macOS queue without assigning those successes to newer revisions.
- New `m-os/pkg-schema-v2@151cc99069e213d05469bce3f50665c02501910c` adds only `.github/scripts/pkg-v2-global-environment-test.sh`; `pkg-catalog/pkg-schema-v2@bb640f68b2ef48b98703327006beddb451dfc05e` adds the `v2-global-environment` Ubuntu/macOS CI matrix job and pins all six jobs to that exact m-os revision. Product implementation and operational manuals remain unchanged.
- The new test copies the existing v2 Java facility contract **as test input** and extends only that copy with typed `CI_SHARED`, `CI_CLASS` and `PATH` members. It exercises real `pkg_facility_provider_validate`, `pkg_integrate` for two same-package/version concretes (one generic and one for the live host's `m_OSARCH`), public `pkg provider default`, actual global snapshot materialization for all six supported osarch values and real `m` bootstrap/command execution on the runner. It checks host-specific preference, generic fallback on other osarch classes, common versus osarch-delta assignments, explicit host-only pin without other-class fallback, and unset cleanup. No real Java upstream download is implied; this is integration/selector/environment **with a synthetic external provider payload**, not physical six-host execution.
- Early trial runs isolated **fixture setup errors** before reaching the target property: missing explicit `osarch` library source, copied provider range outside required catalog `pkg/` tree, missing copied Java `env/PATH` contract marker, and uncreated real package store. Trace was removed once localized. The final Ubuntu `v2-global-environment` job in workflow `41790160639` **PASS**, and its other five Ubuntu regression/fixture jobs **PASS** at the last check (**6/12 PASS**, all six macOS jobs still queued). Do **not** claim complete current-revision macOS PASS until its jobs complete.
- Remaining scope: full current-revision macOS matrix completion, multiple independent facility-default collision/ordering cases (this increment covers generic-versus-specific classes of one facility), macOS launchd supervision and stable physical reference hosts; no v2 merge to `m-os/master` or `pkg-catalog/main`.

**V2 consumer-launch environment checkpoint — 2026-11-04 (prior):**
- Current inspected branch HEADs: `m-os/pkg-schema-v2@71b33c6c811a1a7b4840dba0d2a3f86aa054ef3a`, `pkg-catalog/pkg-schema-v2@cc6be43aca57c05c840ec960cfdd350be76633cd`; mainline `m-os/master@ff55fc9f`, `pkg-catalog/main@35b230d4` were not modified, and no v2 merge occurred.
- Verified a concrete v2 mismatch: `_pkg_integration_v2_validate_definition` rejected `dependency` even though the existing package dependency contract and v2 launcher consumed dependency metadata, and `pkg_integrate` already materialized it. Corrected the v2 envelope to reuse the **existing** `_pkg_dependency_file_validate` at `m-os@a4fc43e1`; no new dependency grammar, selector or projection interpreter introduced. Corrected outdated `res/sys/manual/pkg-launch.lib.sh` claim that facility `PATH` is invalid at `m-os@7763847e`; current contract permits ordered root/root-path PATH contributions.
- `m-os@71b33c6c` extends the existing `.github/scripts/pkg-v2-facility-command-test.sh` fixture by integrating a v2 consumer with declared `java =21` dependency, real `link/bin → cmd → launcher → upstream` execution, package `env`, real provider `facility-cmd` and `facility-env`, final user package `.m/env`, and explicit consumer provider binding after clearing the independent global facility default. The upstream payload asserts actual JAVA_HOME, PATH precedence, selected `javac`, managed HOME and selected ordinary variable at exec. It succeeded in all three variants in the Ubuntu job logs. The Java provider is an integrated **fixture using a temporary copied catalog facility contract**, not a real Java provider downloaded from the catalog; the consumer's integration/launch code is real.
- `pkg-catalog` pins all three workflows to exact m-os `71b33c6c`: general matrix at `c7c14dc1` run `41787604558`, Node.js at `35f613ff` run `41787611004`, Ollama at `cc6be43a` run `41787617458`. Node.js **2/2 PASS** (Ubuntu/macOS), Ollama portable/systemd user/system **3/3 PASS** (Ubuntu). At the last inspection the general matrix had **8/10 PASS**, including Ubuntu consumer launch, with only macOS `v2-facility-commands` and `v2-service-entry` still **queued**. Do not attribute PASS to those two jobs until their exact-run conclusions are confirmed.
- Current changes are deliberately confined to `m-os` v2 implementation, its fixture and manual, `pkg-catalog` v2 test workflow references, and this active handoff. No frozen legacy or mainline product branch was touched. Physical target-host, macOS launchd and osarch/generic provider cross-class precedence remain outside this validation.

**V2 provider PATH + context precedence checkpoint — 2026-11-04 (prior):**
- Latest checked v2 branches: `m-os/pkg-schema-v2@ff14e53f14ffbbeadbaf48a823cb0b7e3e7d3612`; `pkg-catalog/pkg-schema-v2@5503efb1c6ee088576d5a16b169bac75a98b3902`. Mainline `m-os/master@ff55fc9` and `pkg-catalog/main@35b230d` unchanged; no v2 merge. Only a test script and a pinned workflow changed, not product code or canonical package contracts.
- Previously pending real Node.js workflow `41719785578` completed **2/2 PASS** (Ubuntu/macOS), catalog `04c66fdf` pinned to m-os `d1136385`. Previously pending general v2 workflow `41718659259` completed **10/10 PASS** (five jobs per Ubuntu/macOS), catalog `e15c350e` pinned to m-os `d1136385`.
- To validate explicit precedence, the fixture in `m-os/.github/scripts/pkg-v2-facility-command-test.sh` extends only a **temporary copied** Java facility contract with `env/PATH` and two typed values (`root-path bin`, `root-path tools`). It exercises real v2 facility conformance/materialization, real public `pkg provider default`, fresh `m` bootstrap, and shell-local `context`. Assertions protect technical m command roots before global provider PATH, later PATH record before earlier, exact v2 `link/bin` first after context selection, unchanged global JAVA_HOME, repeated-selection idempotence and reset preserving non-context PATH. The catalog's actual Java contract is not modified, and this is not a real catalog-backed Java provider install.
- First new catalog matrix `41785796723` at `b3a67837` failed its two new fixture jobs because the fresh child `m sh -ec` test had not dot-sourced `core.lib.sh`, so the shell function `context` was unavailable: **test-harness error**, not established product defect. That run also saw a macOS jq upstream GitHub release API HTTP 403, before package install; it is external network failure at that revision. `m-os@ff14e53f` fixed the fixture by explicitly sourcing the core library; catalog `5503efb1` pinned all five matrix jobs to that revision.
- Corrected exact-revision workflow **`41785965939` completed 10/10 PASS on GitHub-hosted Ubuntu and macOS** (both v2 facility-precedence fixture jobs, v2 jq, v1 regression, v2 libraries and service-entry fixtures). These successes apply to the corrected revision, not retroactively to the prior failing run. This covers **global facility PATH ordering in the fixture and isolation of context from global JAVA_HOME**, not the still-open consumer-specific package/user environment precedence, osarch-specific versus generic provider combinations, macOS launchd supervision or reference-host physical validation.

**V2 user-host validation checkpoint — 2026-11-03 (prior):**
- New `pkg-catalog/pkg-schema-v2@2cf67084f2e21c78acf67fd107d2e2b77c213797` adds a real, isolated Ubuntu `srv host user` Ollama scenario on the existing runner POSIX account and its existing systemd user manager. It refuses a missing user manager, a conflicting unit or occupied Ollama endpoint; does not create a login session or enable systemd linger.
- GitHub Actions **`41722352670` PASS 3/3 Ubuntu jobs** using exact `m-os/pkg-schema-v2@d11363856ee06f32eadd7b2b3cb89ae390ef7ac3` and catalog `2cf67084`: portable `real-ollama-service` PASS, `real-ollama-host-system` PASS, and new `real-ollama-host-user` job `126218163468` PASS. User-host evidence: pre-existing `runner` account/systemd manager, unit install without starting, real Ollama client responsiveness, systemd MainPID owned by selected account, restart/stop, rejected start after clearing system provider default, and unit removal. The intentionally rejected start logged `provider-resolution-failed`.
- This establishes **Ubuntu GitHub-hosted systemd user and system supervision**, not macOS launchd, physical Ubuntu 26.04 ARM64, or production-host evidence. No `m-os` product code was modified and v2 remains unmerged. Updated Node.js matrix `41719785578` and the generic v2 matrix `41718659259` were still queued at last inspection; their current-revision success is not claimed.

**V2 host-supervision validation checkpoint — 2026-11-03 (prior):**
- Current technical branch under test: `m-os/pkg-schema-v2@d11363856ee06f32eadd7b2b3cb89ae390ef7ac3`; production `m-os/master` was not changed.
- `pkg-catalog/pkg-schema-v2@0a840c126a07e63b99c7bf0066bedcfb439b5edf` adds an independent real Ollama `srv host system` Ubuntu GitHub-hosted test and re-pins the portable Ollama test to exact current m-os. The new Node.js workflow pin was synchronized to this runtime in catalog commit `04c66fdfe21dd147e75fe2712a8655a4a41710d0`. Earlier host workflow commits `151c0793`/`04c66fdf` had invalid YAML job indentation; the corrected `0a840c12` workflow is the tested revision.
- Workflow **`41719853510` PASS 2/2 Ubuntu jobs**, at exact catalog `0a840c12` and m-os `d1136385`: real catalog-backed v2 Ollama portable `srv start/stop` job `126209423892` PASS; real disposable-runner **systemd system host-supervision** job `126209423383` PASS. The latter validates pre-existing non-root account, real exact-pinned service install, enabled-but-not-started state, dedicated system package HOME ownership/mode, actual responsive non-root process, restart/stop, rejected start after clearing provider default, uninstall and retained HOME. The log contains the expected `provider-resolution-failed` diagnostic on deliberately invalid start.
- `m-os` product code, `pkg-catalog/main`, frozen `rumiai-os` and `rumiai-tests` were not changed by this work unit. No merge was performed. These runs are GitHub-hosted Ubuntu execution evidence, **not physical Ubuntu ARM64 or macOS host-supervision validation**. User-host lifecycle, host-system macOS, and provider-precedence edge cases remain unvalidated.
- Node.js matrix `41719785578` (catalog `04c66fdf`, runtime `d1136385`) and general v2 matrix `41718659259` (catalog `e15c350e`, runtime `d1136385`) were still queued at last check; do not claim PASS.

**Resume/validation checkpoint (2026-11-03, after repository rename):**
`m-os/master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a`,
`m-os/pkg-schema-v2@d11363856ee06f32eadd7b2b3cb89ae390ef7ac3`,
`pkg-catalog/main@35b230d44d9e45ad2fb1e7473a838f5a485cf81a`.
The renamed-source v2 matrix run `41656568757` is now **10/10 PASS**
(5 Ubuntu and 5 macOS), including real jq acquisition and v1 regression;
Ollama portable run `41656568773` is **PASS**. The Node.js matrix
`41656569243` ran the real install, HOME, context and pinned provider path
on both hosts before failing on a missing closing `]` in the workflow's
final provider query assertion, not on the product behavior already reached.
`pkg-catalog/pkg-schema-v2@0ec577773b08721ca974ed13d187b34a7523d868`
repairs only that test syntax (single closing `]`). New Node.js workflow
run `41717928682` was queued when last inspected; do not mark PASS until
both host jobs finish successfully. A further test-only commit
`m-os/pkg-schema-v2@d11363856ee06f32eadd7b2b3cb89ae390ef7ac3`
extends mixed v1/v2 `context` assertions to most-recent-first PATH
ordering, re-selection and idempotence without changing product code.
`pkg-catalog/pkg-schema-v2@e15c350ee1ec288a4a544a7cc850edccec437e6c`
re-pins all five jobs in the v2 matrix to that exact updated runtime.
Matrix run `41718659259` was queued when inspected and has no PASS yet.
No `m-os` product change or mainline v2 merge was made in this
checkpoint. Host supervision and provider environment precedence remain
unvalidated.

**Current repository and v2 execution checkpoint (2026-11-03):**

The independent technical source repository was renamed from
`massimilianonardi-ai/m` to `massimilianonardi-ai/m-os`; its contents,
branch names and commit ancestry were preserved. The `m` command and
technical layer retain their names. The latest checked heads are
`m-os/master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a` and
`m-os/pkg-schema-v2@8c8397dbcf1df44822553aebd1891ab6db880945`.
The catalog's independent v2 branch was realigned to use `m-os` in its
checkout workflows at `pkg-catalog/pkg-schema-v2@56398be0661d395e0fd07af018da0a1bffbf0235`.
The published v1 catalog checkout was similarly realigned at
`pkg-catalog/main@35b230d44d9e45ad2fb1e7473a838f5a485cf81a`.
Older `m/...` revision strings below identify the same repository
before its rename, not another source repository.

Revision-scoped v2 validation since the older checkpoint:
- Real catalog-backed v2 Node.js exact install, wrapped node/npm/npx,
  managed HOME, context and explicit pinned facility default **PASS**
  on Ubuntu, workflow `41645063670`, runtime `m-os@8c8397db`,
  catalog `pkg-catalog@5096bd01`. The Node.js upstream adapter was
  corrected to ignore prerelease tags when listing stable versions.
- Real catalog-backed v2 Ollama installation, pinned provider and
  portable `srv start`, responsive client, `srv stop`, idempotent stop
  **PASS** on Ubuntu, workflow `41645645062`, catalog
  `pkg-catalog@90b81b40` and runtime `m-os@8c8397db`.
  Host-supervisor registration/start/stop remains unvalidated.
- Earlier workflow `41640555343` completed **9/10 PASS**:
  5/5 Ubuntu and 4/5 macOS. The only macOS failure was a real
  upstream GitHub jq release API HTTP 403 during download, before
  v2 materialization; this is not a v2 execution PASS.
- The renamed-repository Ollama validation workflow `41656568773`
  is **PASS**. The v2 matrix `41656568757` has 6 PASS and 4 macOS
  queued at the repository-rename consistency check.
- The renamed-source Node.js matrix `41656569243` checked out
  `m-os` successfully and completed the Ubuntu v2 installation,
  node/npm/npx, HOME, context and provider-selection assertions.
  Its final query assertion failed with shell `[: missing ]` in
  `.github/workflows/validate-v2-nodejs.yml` (not a product
  regression); the macOS job remained queued. Repair that test in the
  owning v2 validation work unit and rerun on its new exact revision.

The preceding checkpoint remains retained below as revision-specific
prior state rather than current evidence.

Checkpoint 2026-11-03, current verified revisions:
- `m/master@ff55fc9f220f8da3f1f90d1bf4aa2e46c55a5d2a`
- `m/pkg-schema-v2@dca35bafd1e7ab3993bb9b38e72877b200dfb5b5`
- `pkg-catalog/main@759127c79c576cacb22ba0c4bb55d4746279e0f3`
- `pkg-catalog/pkg-schema-v2@b47f3b69f69ff96de73d96cda3a698861d1e1327`

V1 remains published and previously validated for concrete jq install/launch
on Ubuntu and macOS. V2 is **still unmerged** into the main branches.
The v2 branch already supports schema-aware `context` command and ordinary
library views, link/bin direct/wrapped command publication, link/lib
shell/Java and library-only packages, installed v1/v2 coexistence,
state-map and fixture-based facility command and service-entry resolution.

**This checkpoint advances v2 provider environment parameterization:**
the provider now binds typed values to names declared by the independent
`facility/<name>/<compatibility>/env` contract under
`facility-env/<facility>/<variable>`. The v2 conformance validator rejects
missing/undeclared/duplicate/invalid members. Integration materializes the
validated bindings into the existing flat installed `facility-env/<facility>`
representation; `pkg-provider` remains the sole interpreter for applying
provider environments. `context` still only composes selected command/library
views. A current generic/global environment selector defect was found and
fixed: version-pinned selectors do not require package-class defaults,
whether the candidate is platform-specific or generic.

**Latest hosted verification:** `pkg-catalog` workflow run
`41640555343`, exact catalog `b47f3b69` and m `dca35baf`:
- **Ubuntu PASS 5/5:** real v2 jq direct/wrapped public install/execution;
  v1 jq regression on upgraded m; v2 library-only shell/JAR fixture;
  Node.js/Java provider-independent facility-command fixtures,
  contract-keyed JAVA_HOME environment validation and actual public
  `pkg provider default` applied in a fresh m shell; v2 Ollama-like
  exact link/bin service-entry fixture.
- **macOS not yet assessed at this checkpoint:** the five corresponding
  jobs were queued when last checked. Do not infer PASS/FAIL.
- A prior Ubuntu run at m `e84169b8` failed the new Java environment
  assertion (exit 43). Its investigation revealed the version-pinned
  selector defect corrected in `dca35baf`; the subsequent exact-revision
  Ubuntu facility job passes. Preserve this as a correction, not a generic
  download/network failure.

The Java and service checks here use locally constructed provider roots
and real m integration/provider commands; they are not claims of
**real catalog-backed Java/Ollama provider installations** or
full `srv start/stop`/host lifecycle conformance. Previous macOS jq
network HTTP 403 remains revision-specific external failure evidence.
No edits to frozen `rumiai-os` or `rumiai-tests`; no branch merge.

Previous Completed/Current state sections preserve prior checkpoints;
this Current state supersedes older stale 'no v2 PASS' claims.

## Next action

1. Preserve the exact 2/2 hosted PASS evidence for published v2 `mk/jsc` and Java/Temurin/Maven; do not rerun unchanged successful real scenarios merely to accumulate more green jobs.
2. Keep Java/Temurin/Maven hosted two-platform scenario **PASS at exact pinned revisions**; do not retest it without a materially changed path. Keep jq retry attempt 2 **FAIL at upstream 403 before product assertions** and retain independently proven earlier macOS jq functional PASS for unchanged relevant sources. Escalate repeated upstream HTTP 403 as acquisition environment evidence, not a speculative `pkg` code fix.
3. After the P2 owner validates and integrates its draft PR, reconcile the overlapping `pkg-install.lib.sh` and `pkg-install.lib.sh` manual changes with v2 schema/integration behavior in the single V2 integration lane; preserve unrelated current master extraction/workflow and catalog v1 Electron version updates. Then coordinate P3/P4 and select new post-integration real public hosted regressions. No frozen suite, mainline V2 promotion, or reference-host physical validation is yet authorized by the earlier feature-only PASS.

## Blockers / open questions

- Real Node.js and jq v1→v2 migrations and the 4/4 permanent offline suite PASS on hosted Ubuntu and macOS at their separate exact revisions. The older-matrix v1-only regression macOS job `126817651791` on attempt 4 actually FAILED during first jq install on three upstream GitHub Releases API HTTP 403 responses before any compatibility assertion; cause not proven and no product regression demonstrated. Java adapters have passed the real catalog-backed public Java/Maven test on both hosted platforms at pinned feature revisions (`42085304112`, 2/2 PASS); physical validation remains PENDING. None of these GitHub-hosted results substitutes for stable physical reference-host testing.
- The autonomous `m-os` feature branch has ported `apache-maven` and `temurin` adapters/manuals, plus a corrected `rumiai-test`-driven Java workflow at `6299f0b1...`; the executable permanent Java test lives on an unpromoted `rumiai-tests/pkg-java-v1-validation` branch at `3f0eeb2d...`. POSIX shell/YAML syntax checks preceded the real hosted Java test; the catalog-side Java run 42085304112 now has a genuine 2/2 Ubuntu/macOS PASS. The m-os-side Java workflow remains separately unexecuted.
- Physical Ubuntu 26.04 ARM64 and macOS launchd reference-host checks are not accessible through GitHub-hosted CI and remain unvalidated.
- Canonical `PACKAGE-MODEL.md` still specifies the published v1 baseline; v2 design in feature branches has not yet passed promotion and must not be described as current normative mainline.
- The P1 canonical upfront-batch syntax and exact-root/same-catalog-snapshot semantics are now reconciled in current PACKAGE-MODEL; the autonomous install implementation and operational manuals still need the separately owned P2 realignment before promotion.
- Older working-design candidates in this handoff are not permission to extend the frozen v2 scope; preserve the user's explicit instruction not to reopen schema, package-store security or formal-validation targets.
