# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the catalog/install resolver cleanup in progress.

## Current repository revisions

- `rumiai-dev/main@b487238ec4b481e7c6256b857d733817baaf5c71` observed before this checkpoint; canonical `PACKAGE-MODEL.md` P1 reconciliation committed at `639e990c5ad61a5092f42561e8d151a99f2ef6b8`.
- `m-os/master@5884cf05ebd3033524db3890a7e34fc0decdd4f6` remains the target mainline. P2 implementation lives on forward-only `m-os/m-os-completion-p2@f74ecbabe552fc9e2284c26caea5f5dd4cbb1a3f`, [draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3), not yet merged.
- `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`; `pkg-catalog/pkg-schema-v2@ed599dcd09a286eb3e0d21b4cc8f04adaada556c`.
- `rumiai-tests/main@5675ed30e34b6ac795134965a5c8b6b2dd5c88d0` and `rumiai-os/main@461f4baf8c6f010a2891d104f0a58a0a69e06abf` remain frozen for edits/execution under this program. Read-only inspection was performed.

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md

## Fixed task-local choices

- `pkg depend <package-spec>...` is read-only and returns recursive dependency concrete identities only, in dependency-first order.
- Explicit requested roots are omitted from `pkg depend` output unless the same concrete is also selected as a dependency node of another request.
- `pkg install <package-spec>...` validates the complete original request list before catalog initialization, dependency planning or installation.
- After validation, `pkg install` initializes one catalog snapshot, resolves every requested root to an exact concrete identity, calls `pkg depend` on those exact concrete roots, prepends the returned dependency concretes, then installs the resulting dependency-first concrete sequence.
- Dependency planning and root installation therefore operate on the same exact root identities selected from the same catalog snapshot.
- No new public `pkg_local_current` API is being introduced at this stage. Per the user's current direction, the simplified install resolver temporarily reuses the existing private `_pkg_local_class_scan` behavior directly.
- The direct cross-library private call is a task-local implementation choice, not a promoted library-interface contract and must not be generalized as public API.
- Further cleanup of `_pkg_install_init` / `_pkg_install_end` and catalog/workspace lifecycle remains deferred until the user's later review of `pkg`.
- The user has promoted the temporary `extract2` / `pkg-extract2.lib.sh` implementation identities to the canonical `extract` / `pkg-extract.lib.sh` names. The old `*2` identities are no longer part of the intended current surface.

## Acceptance scenarios

- `pkg depend geoserver` returns only the concrete Java provider dependency (plus recursive provider dependencies), not the GeoServer root.
- A dependency-free requested root produces empty successful `pkg depend` output.
- If one explicit root is also selected as a dependency of another root, that concrete still appears in `pkg depend` output.
- Any syntactically invalid request in a `pkg install` batch fails before catalog initialization or dependency planning and prevents all installation.
- `pkg install geoserver` resolves GeoServer to an exact concrete root, plans dependencies from that concrete root, installs dependency concretes first and then installs the GeoServer concrete.
- Multiple requested roots preserve their request order after root concretization and after all dependency concretes are prepended.
- Already-installed compatible dependency concretes may satisfy dependency nodes without reinstallation.
- An unversioned root may reuse the valid installed current/default concrete for the selected package/platform class.
- Malformed managed-store entries must not be accepted as valid already-installed concretes.

## Completed

- P1 canonical authority reconciliation committed as `639e990c5ad61a5092f42561e8d151a99f2ef6b8`: `PACKAGE-MODEL.md` now states upfront full-request syntax validation, one catalog snapshot, exact concrete requested roots before dependency planning, and dependency-first installation of those same roots; PKG-18/96/97 match. This is **specification-only**, not product validation.
- On inspected autonomous `m-os/master`, `extract` and `pkg-extract.lib.sh` with current manual identities already replace the old `*2` and `*_OLD` source identities; older frozen-legacy extractor issues are not current autonomous-source blockers.

- P2 forward-only implementation staged on `m-os/m-os-completion-p2` in draft PR #3: existing dependency planner is exposed as `pkg_depend_plan <catalog-root> <roots...>` (one existing implementation, no parallel planner), and `pkg install` now resolves all requested roots to exact concretes before planning against the same catalog snapshot. The old duplicate installer resolver was removed; internal-only installer helpers were renamed with leading underscore; exact installed-concrete shortcut rejects symlink/non-directory entries. Dependency reuse and explicitly requested already-installed root errors are differentiated, with valid-execution status 1 / invalid-request status 2. The `pkg`, install-library and depend-library manuals and an existing repeat-root CI expectation were realigned.
- P2 added `.github/workflows/m-pkg-p2-public.yml` for real public Ubuntu/macOS invalid-batch and genuine published mk/jsc/Node installation coverage, with branch push/PR triggers. The PR is draft because **no new Actions run was returned by GitHub** at the checkpoint. The source diff and manual/interface mapping were inspected; no runtime PASS, hosted PASS or formal/physical validation is claimed. P2 completion is pending actual execution and any required corrections.
  
- P2 follow-up diff review identified and corrected the same-batch overlap case: an explicit requested root first installed as another requested root's dependency now counts as fulfilled, while an actual pre-existing root or a duplicate independently installed root still produces already-installed. Canonical Installation prose clarified at `rumiai-dev@ac307ceae78c45bf06913a3211296ffd6cdfadcb`; command/install manuals and the public CI scenario were updated on the P2 branch. Invalid concrete statuses now have distinct branch-specific diagnostic identities.
- PR #3 remains draft and unmerged. New Github Actions runs were not available via the repository run endpoint; the CI workflow file exists but is **not execution evidence**. The auxiliary Linux container could not resolve github.com for an authentic checkout. The latest read-only `m-os/master@f8515ad8ef397ca2d37c95f66d6a2dd2d5d93d5c` has unrelated transfer/TLS workflow edits; they do not overlap P2 files and are to be reconciled forward only when integrating the PR. `rumiai-tests/main@588986b88fce5cbd571acaebf298c032bab37fc1` remains frozen.

## Current implementation state

Current `m-os/lib/sys/sh/pkg/pkg-install.lib.sh` validates all requested syntax before `_pkg_install_init`. However, `pkg_install` still invokes public `pkg depend` on unmodified roots, then installs those unmodified roots. Its existing `pkg_install_resolve` helper is not used in this public flow. Public `pkg depend` creates its own catalog snapshot. **Thus exact roots and the shared immutable catalog snapshot are not implemented yet.**

Other current source/manual divergences:
- `pkg_install_resolve_one` exact-installed shortcut tests only `-d` and can accept a symlinked concrete directory; obsolete `___pkg_install_resolve_one` remains.
- `pkg_install_resolve_one`, `pkg_install_resolve`, `pkg_install_validate` are non-underscore, hence public under the naming contract, but not listed in `res/sys/manual/pkg-install.lib.sh`. Check actual consumers and reconcile interfaces; do not invent a new external API for an internal helper.
- Both `res/sys/manual/pkg` and `pkg-install.lib.sh` still document planning from untouched roots; change with the runtime.
- Existing valid concrete currently returns success without reinstalling, while current Installation prose still prescribes `already-installed` failure. Public valid-execution failure codes also require comparison with the 1/2 manual. These are **open mismatches**, not silently resolved public-policy changes.
- No runtime/CI/permanent-suite test was executed in this P kickoff. Earlier evidence remains revision-specific.

## Validation / permanent-test state

The frozen `rumiai-tests` suite may be inspected only. `m-os/.github/workflows/m-pkg-live-install.yml`, `m-pkg-provider-lifecycle.yml`, `m-pkg-v1-catalog.yml` and `m-composed-pkg-live.yml` can support current autonomous `m-os` development evidence, but do not automatically prove the changed contract.

Required P2 checks on a disposable real `m-os` target: invalid-first/valid-second and valid-first/invalid-second batch fail before catalog/store mutation; valid multi-root exact-root dependency-first planning uses one snapshot; corrupt/symlinked concrete is not reused; failure statuses, provider ambiguity propagation and cleanup match canonical contracts. Retain precise source/catalog/host revisions for any PASS.

## Next action

1. Execute and inspect `m-pkg-p2-public.yml` on the exact draft PR #3 head (or an equivalent isolated genuine `m-os` checkout on Ubuntu/macOS) and correct any authentic failures before merging. No successful new Actions workflow was observed via repository API during this response.
2. Validate exact-root same-snapshot planning, invalid-first/invalid-last no-mutation, dependency-first true artifacts, malicious/symlinked managed-store rejection, provider ambiguity and failure cleanup. Inspect root already-installed behavior and current/default diagnostics with real public CLI, plus relevant extractor and uninstall/reinstall cases. Current separate `pkg` publication still has runtime-test and upstream artifact availability risk.
3. After actual proportional validation, reconcile any concurrent `m-os/master` changes forward, integrate PR #3 without force, update evidence/handoff and release the shared `pkg` writer boundary to P3/P4. Keep frozen suite and legacy product untouched.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, remains intentionally deferred until the user's next review of `pkg`.
