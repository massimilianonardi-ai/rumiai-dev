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

**V2 mixed installed-schema/default/provider lifecycle checkpoint — 2026-11-04 (latest):**
- Verified current involved remote HEADs, re-read the canonical `rumiai-dev` rules, package/default/launch/provider specs, testing contract and this active handoff, and inspected the existing current `m-os/pkg-schema-v2` launcher, schema reader, integrator, package-default transitions, provider selectors and prior fixture tests. The missing covered property was **transitioning an ordinary package default across genuine coinstalled v1 and v2 concretes of the same package identity**; the existing context coexistence fixture depended on an externally downloaded v2 jq and did not exercise package-default transitions.
- Added test-only `m-os/.github/scripts/pkg-v2-default-coexistence-test.sh` at `m-os@fe8c3047`: integrates actual v1@1 and v2@2 concrete layouts from local fixture useful roots, then exercises public `m pkg default` v1 → v2 → v1 → unset, public command symlink target updates/removal, v1 launcher, v2 wrapped entry with fixed argv and package environment, v2 direct entry (which deliberately does not apply wrapper environment), failed nonexistent-version change preserving the previous view, and independent shell-local `context` selection/reset. This is an integration/launch test through real m code, not a download or upgrade-in-place scenario.
- Added test-only `m-os/.github/scripts/pkg-v2-mixed-provider-test.sh` at `m-os@380d0f43`: copies the **actual** catalog v2 nodejs facility contract, integrates two synthetic-external-provider v2 package versions (same facility level), and both v1/v2 installed consumer schema versions declaring `nodejs =26`. It checks consumer version default transitions, global facility default provider@1 → provider@2 transitions (both provider concretes are v2 schema), explicit consumer binding precedence surviving a consumer default change, restoration after unbinding, failure on unresolved ambiguity when no default/binding exists, and binding-based recovery. Every observed consumer output comes from the real package launcher/real selected facility command (external `node` payloads are fixtures). No GitHub Releases downloads.
- The first focused catalog workflow `41796228855`, catalog `cb1f2b6b` pinned to `m-os@e79520a9`, completed **2/2 PASS** on hosted Ubuntu/macOS for the default/direct-wrapper scenario. Expanded exact workflow `pkg-catalog/pkg-schema-v2@a2f3e17a50b871bf935a9e4feee07c8ceafcab03` (run **`41796604094`, both jobs PASS**) checked both new fixtures on Ubuntu and macOS; verified each log prints both expected PASS markers and no failing assertions. Both checked out exact `m-os@380d0f43992c22123042cf389675c658e770d193`. This is **2/2 hosted CI jobs containing two genuine real-integration fixtures each**, not physical validation, and not a fresh rerun of prior jq/Ollama/Node.js workflows.
- A newly introduced m-os-hosted workflow did not schedule from the feature branch; its untriggered copy was **deleted forward-only** at current `m-os/pkg-schema-v2@7fee9e02bb7e7b2ef377c05cb085b0155bde8706`. That commit differs from the tested `m-os@380d0f43` **only by deletion of this unused workflow**, not by a code/test behavior change. The effective focused CI lives in `pkg-catalog/.github/workflows/validate-v2-coexistence.yml`; unlike the broad jq tests, it requires no release API calls. No production library, operational manual, promoted specification, mainline branch or frozen repository changed.
- Explicit remaining coverage: real upstream v1/v2 reinstall/migration and mutable-state preservation, uninstall/refusal/rollback branches, corrupt/escaping installed-link rejection, possible library/command collisions during transitions, macOS launchd host supervision, Ubuntu ARM64 reference host and eventual package-schema promotion. No new specification/implementation mismatch was established by these passing tests.

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

1. Extend the focused, no-release-download mixed v1/v2 integration
   scenario to **uninstall/refusal/rollback and reinstallation** across
   schemas, including preservation of current/default selectors and
   mutable state, and rejection of malformed/escaping installed links.
   Distinguish synthetic payload verification from real upstream
   v1/v2 migration; do not introduce implicit conversion.
2. Reconcile representative real mixed-schema scenarios into the
   permanent `rumiai-tests` suite at the appropriate validation scope;
   use `pkg-catalog` hosted fixtures as exact-revision integration
   evidence, not a substitute for formal or physical validation.
3. Preserve real upstream install tests while pacing GitHub Releases
   API usage: on a suspected 403 limit, inspect rate-limit headers
   when available and retry only the failed job after reset, not
   whole matrices repeatedly.
4. Validate macOS launchd user/system on an eligible controlled host
   and Ubuntu 26.04 ARM64 on the physical reference host when available.
   Audit remaining v2 wrapper/provider edge cases, then promote only
   settled complete semantics and coordinate forward-only merge.
   Resource export remains deferred to v3+; metadata inheritance is
   still a separate open design choice.

## Blockers / open questions

- Precise v2 wrapper-target descriptor semantics and generic launcher
  contract once the public `link/bin` symlink may point at `cmd`.
- V1/v2 installed-concrete schema identity and safe mixed-version
  launch, plus coordinated facility/`srv` migration.
- Minimum non-imperative ordinary package `env` shape, including
  scope/precedence and safe checks.
- Whether stable metadata inheritance pays for its complexity while
  retaining range anchors and `all`/osarch stream selection.
- The v2 shell/Java library-only fixture has hosted PASS on both
  Ubuntu and macOS, but a real catalog-backed Java consumer is not yet
  independently proven. Ollama portable and systemd user/system supervision
  passed on GitHub-hosted Ubuntu; macOS launchd and physical reference hosts
  remain unvalidated.
