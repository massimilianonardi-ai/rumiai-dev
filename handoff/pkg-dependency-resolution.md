# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the catalog/install resolver cleanup in progress.

## Current repository revisions

- `rumiai-dev/main@b4fb815a9a8307fc0375fdc6e59c94a96973d33e` observed before this checkpoint; current canonical `PACKAGE-MODEL.md` P1/P2 root semantics are promoted.
- `m-os/master@15745d7b575d725073d0fd11d221bd0117ee916e` remains unmodified by P2; [draft PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) stages `m-os/m-os-completion-p2@44b8133b4c0acbbc7bee54b765d48a0a51c9bf4b`, including a forward-only merge of concurrent A3 `extract` source/manual.
- `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`; temporary isolated P2 CI at `pkg-catalog/m-os-completion-p2-ci@00d7f704b8e51931a6b3c33fbc1552018e7a5b16` tests the exact P2 candidate. V2 feature `pkg-catalog/pkg-schema-v2@a75f9be1c9a62a72899022eddf55e163d86ab630` is independent.
- Frozen for modification/execution: `rumiai-tests/main@9138cc274d79e6c42f933b676f694e2cd96aaa69` and `rumiai-os/main@6c205154d436534ebf3d3f4d1d7625f72c13f6eb`. Read-only inspection only.

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
- After validation, `pkg install` initializes one catalog snapshot, resolves every requested root to an exact concrete identity, applies the same dependency planner to those exact roots **using that snapshot** (not a second public `pkg depend` invocation), then installs dependency concretes before those exact roots.
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

### Auxiliary P2 exact-commit public execution (2026-11-05)

- I1 used a **separate CI-only runner** at `pkg-catalog/m-os-completion-p2-ci@2894eaa483eeb32132c59cd09ebd767d8659a2c7` to check out and run **unchanged** `m-os/m-os-completion-p2@f74ecbabe552fc9e2284c26caea5f5dd4cbb1a3f` workflow `.github/workflows/m-pkg-p2-public.yml`. No P2 runtime, master, package catalog definitions, release, legacy product or frozen tests were changed. The full new file/diff and original source script identity were inspected.
- [Run 42094006865](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094006865), hosted Ubuntu job `127479173970` **completed SUCCESS**, raw log ends with `PASS: P2 real public package planner/install, repeat-root and corrupt-store rejection`. Real `nodejs@v26.13.0!linux-x86_64`, published `mk/jsc` and public install/default/Node execution were exercised; explicit already-installed errors, mixed root behavior, valid/invalid request boundary, and concrete-store symlink rejection were checked. This is bounded authentic public-path evidence, not a formal/physical PASS or the whole P2 test matrix.
- macOS job `127479174626` was **QUEUED/PENDING** at the latest observation. The original `m-os` P2 workflow had no directly reported Actions run; this hosted clone is correctly recorded as `pkg-catalog`-orchestrated execution of the exact P2 source.
- Source-review acceptance risk still needing targeted coverage: an installed historical exact root may be re-resolved by `pkg_depend_plan` in `request` mode via repository discovery. Provider ambiguity and failure cleanup remain independent scenarios. [PR #3 review and evidence thread](https://github.com/massimilianonardi-ai/m-os/pull/3). P2 remains DRAFT; I1 remains gated.

### P2 exact-root planner correction and current hosted execution (2026-11-05)

- The P2 branch now separates `pkg_depend_plan <catalog-root> <exact-concrete>...` (same snapshot, exact root, **no second live repository version lookup**) from the unchanged standalone `pkg depend <package-spec>...` request-mode command. This closes the prior installed-historical-root second-resolution risk on the staged branch, without changing standalone read-only query behavior; the shared recursive planner implementation is not duplicated.
- The exact-root mode validates class, target osarch, existing concrete or catalog range before graph planning. New local exact-root failure branches use separate statuses; `_pkg_install_resolve_one` rejects malformed explicit installed-concrete symlinks with its own status. The `pkg-depend.lib.sh` operational manual was updated to match. The final P2 head `44b8133b4c0acbbc7bee54b765d48a0a51c9bf4b` includes a forward-only reconciliation with A3 `extract` changes on `m-os/master@15745d7b575d725073d0fd11d221bd0117ee916e`; no P2-owned file conflicts were present.
- [Hosted current-source run 42095006573](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42095006573) via isolated `pkg-catalog/m-os-completion-p2-ci@00d7f704b8e51931a6b3c33fbc1552018e7a5b16`: original P2 public shell script executed from an exact `m-os@44b8133b4c0acbbc7bee54b765d48a0a51c9bf4b` checkout; **Ubuntu job 127482609528 SUCCESS**, **macOS job 127482609187 QUEUED/PENDING** at this observation. Real public tests cover invalid-batch status 2, actual published Node/mk/jsc dependency-first installation, default/Node command, explicit-root overlap and repeat-root status 1, mixed-existing/fresh roots, uninstall and symlink-store rejection. A hosted Ubuntu success is not macOS, formal frozen-suite or physical-reference-host evidence.
- Intermediate exact-source Ubuntu jobs also succeeded for [42094446208](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094446208) and [42094701542](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42094701542), but belong to their earlier pinned product SHAs, not to the final integrated head. The original `m-os` repository has not reported a native P2 Actions job; do not invent one. PR #3 stays **draft/unmerged** until current-source macOS and remaining negative-provider/failure-cleanup checks are adequately verified.

### P2 exact-head Ubuntu/macOS public PASS (2026-11-05)

- [Catalog-side run 42098513609](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42098513609) completed **SUCCESS 2/2** at exact `m-os/m-os-completion-p2@0d3f877243af79e108cc19fda504a619cf57957b`, independently confirmed by both raw hosted job logs: Ubuntu `127494805820` and macOS `127494806453`. The run's own catalog CI commit `1b105aa...` is only the isolated orchestrator; both jobs checked out the exact P2 product HEAD. Each reaches the final `PASS: P2 real public package planner/install, repeat-root and corrupt-store rejection` assertion. The apparently severe `already-installed` and `root-resolution-failed` log entries are intentional negative-path probes, not CI failures.
- The tested unchanged source workflow `.github/workflows/m-pkg-p2-public.yml` covers public invalid-first/invalid-last batch status 2 and no package store creation, real upstream Node + first-party `mk/jsc` dependency-first install, provider-target planning, dependency-fulfilled explicit root, public default/command invocation, preinstalled and mixed roots, uninstall/reinstall and symlinked managed-concrete rejection. It is **not** complete P2 acceptance: independent provider ambiguity, targeted failed-install cleanup and legacy-installed-root mismatch tests still need proof under the P2 owner. The [P2 PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) is still **OPEN/DRAFT**, unmerged at `0d3f877...`; `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` includes unrelated concurrent changes and must be reconciled forward.
- This is a documentation-only evidence synchronization by the coordinating V workstream; **P2 remains the single shared-`pkg` writer**, no change to its implementation, frozen legacy repositories, catalog definitions or public contract. Hosted success does not substitute for physical reference-host or formal frozen-suite validation.

### P2 targeted negative acceptance and corrupt-download boundary (2026-11-06)

- **Real two-host negative-path PASS:** [isolated catalog CI run 42193302580](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42193302580) completed **2/2 PASS** against unchanged exact `m-os/m-os-completion-p2@0d3f877243af79e108cc19fda504a619cf57957b` using a CI-only appended regression at `pkg-catalog/m-os-completion-p2-ci@29d093f47c6847e1069c9d24512f48d07970836e`. Genuine public `./m pkg depend` and `./m pkg install` fail status 1 with detailed `provider-ambiguous` for an installed-provider fixture pair; no consumer package is installed. An installed `mk@v0.0.0` historical exact root not listed by current remote release metadata is recognized as `already-installed` (not re-resolved remotely). A malformed historical dependency fails at planning and leaves root/staging state unchanged. The real target planner/install code was not replaced; the injected provider/store metadata are fixtures, **not genuine installed provider releases**.
- **Retained source tests:** `m-os/m-os-completion-p2@573ac82e466c5d452ccb30b9b4475b75769c638d` now retains those negative checks in `.github/scripts/m-pkg-p2-negatives.sh` and adds the bounded corrupt download check in `.github/scripts/m-pkg-p2-corrupt-download.sh`. `.github/workflows/m-pkg-p2-public.yml` executes both after the existing real published Node/mk/jsc smoke. The latter uses the real `m node` to host controlled local HTTP bytes, feeds a same-size/wrong-SHA256 descriptor to the real `pkg_download` through `m sh`, requires `digest-mismatch` and checks that the corrupt staging file was removed. **It validates the download boundary only, not a full `pkg install` artifact-stage rollback or GeoServer's real installation.** All source changes are test/CI-only; shared `pkg` product libraries/manuals remain unchanged.
- **Latest exact-head hosted CI:** [run 42194425875](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42194425875) from isolated `pkg-catalog/m-os-completion-p2-ci@9df861540cba7ec8c2f22ef5c56b195fa7680746` checks out product `573ac82e...`, executes original public smoke plus retained negative and corrupt-download scripts: **Ubuntu job 127814008166 PASS**. Its raw log contains explicit `provider-ambiguous`, `dependency-planning-failed`, `pkg-download reason=digest-mismatch` with actual computed digest and both extra final PASS lines. macOS job `127814008817` was **QUEUED/PENDING** when checked; do not relabel the older 2/2 PASS as a current-head macOS PASS. No duplicate workflow run is needed while it remains queued.
- [Draft P2 PR #3](https://github.com/massimilianonardi-ai/m-os/pull/3) remains open, head `573ac82e...`, not merged. Read-only comparison to `m-os/master@1f8880c78febf390596faa9b6662ec8cab5c5e42` shows the P2 branch diverged, with 7 master-only commits affecting `m-transfer-integrity-public.yml`, `bin/sys/extract` and its manual. Preserve them forward; do not promote PR, pass writer ownership to P3/P4 or touch frozen `rumiai-tests/main` / `rumiai-os/main` before acceptance. No physical reference-host validation was executed.

## Current implementation state

The **unmerged `m-os/master` mainline** `lib/sys/sh/pkg/pkg-install.lib.sh` validates all requested syntax before `_pkg_install_init`. However, that mainline `pkg_install` still invokes public `pkg depend` on unmodified roots, then installs those unmodified roots. Its existing `pkg_install_resolve` helper is not used in this public flow. Public `pkg depend` creates its own catalog snapshot. **Thus mainline does not yet implement exact roots and the shared immutable catalog snapshot; draft P2 does, under the pending integration/validation gates above.**

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

1. Inspect only the pending **macOS job `127814008817`** on latest exact-source [run 42194425875](https://github.com/massimilianonardi-ai/pkg-catalog/actions/runs/42194425875); preserve Ubuntu PASS, and classify any real functional failure separately from acquisition/runner blockage. The earlier 2/2 public+negative smoke at run 42193302580 is already PASS and must not be redundantly rerun.
2. Close any remaining **full-public-install artifact failure/rollback** and **real GeoServer/dependency** acceptance that can be executed proportionately; record unavailable artifact/privileged/platform paths explicitly as PENDING. The new local HTTP digest failure proves `pkg_download` corruption rejection and cleanup only. Review and correct any observed P2 source/manual/test mismatch without substituting synthetic data for a genuine full package execution.
3. Once actual P2 evidence is sufficient, refresh remote HEADs, forward-reconcile `m-os/master` and draft PR #3 without dropping concurrent extraction/workflow changes, and then transfer shared `pkg` ownership to P3/P4/V2. Frozen legacy product/suite and stable physical reference-host tests remain untouched/PENDING.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, remains intentionally deferred until the user's next review of `pkg`.
