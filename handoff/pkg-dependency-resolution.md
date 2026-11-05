# pkg dependency resolution and recursive install

Status: Active
Updated: 2026-11-05

## Goal

Complete and validate the promoted recursive `pkg install` model built around the public read-only `pkg depend` dependency planner, while continuing the catalog/install resolver cleanup in progress.

## Current repository revisions

- `rumiai-dev/main`: 2026-11-05 canonical PACKAGE-MODEL update at `639e990c5ad61a5092f42561e8d151a99f2ef6b8`; refresh remote HEAD for later work.
- `m-os/master@e0bcf2d69ba4e4209a93fd7d0c9b08a00def3a0f` current runtime (A1 CI-only addition since inspected pkg source at `31693e8`); feature `m-os/pkg-schema-v2@1e3a038a5abf6f8c176272d8e44464c842d3cefd` independent.
- `pkg-catalog/main@3ee97d21bae3ee885b0fa987e1faee718fad8609`; `pkg-catalog/pkg-schema-v2@9d889cc265c29eeae456b8fe1ad638654c36e8c7`.
- Frozen for modifications and execution: `rumiai-os/main@8ae78944ef5e8d6297c50898d856db1a20c6fd9a` and `rumiai-tests/main@b8e1c71db7aa4b94fedef323c5b3f1030dab1c24`. Read-only source inspection remains permitted.

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

1. P2 under one `m-os/lib/sys/sh/pkg` integration writer: ensure exact root resolution and dependency planning share the current installation catalog snapshot, without breaking standalone read-only `pkg depend`.
2. Restore strict concrete-store validation, remove the obsolete duplicate resolver after equivalence check, reconcile function visibility and the `pkg`/install-library manuals. Explicitly reconcile already-installed and valid-execution exit-status drift before changing their public behavior.
3. Execute proportional authentic public CLI regression tests on isolated `m-os` and coordinate P3/P4 before changing shared provider/default/integration hooks. Keep frozen suite and legacy product untouched.

## Deferred

Further simplification of package/catalog temporary-directory lifecycle, including whether `pkg_catalog_init` should own its cleanup trap and whether `_pkg_install_init` / `_pkg_install_end` should disappear, remains intentionally deferred until the user's next review of `pkg`.
