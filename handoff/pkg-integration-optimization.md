# pkg integration optimization

Status: Active
Updated: 2026-10-03

## Goal

Review and optimize the current `pkg_integrate` implementation while preserving the promoted package-integration contract unless a semantic change is explicitly justified and propagated.

## Current repository revisions

- rumiai-dev: 6ee2c5423907c2c5187ec7c411f1bef84caedac2 (pre-checkpoint HEAD)
- rumiai-os main: ea2eb22917edca77a44566ee415301f69ca61ad8
- rumiai-os work branch `pkg-integrate-optimization`: 527687b57d94dfde06e0a59d1a556b5fce20c930
- rumiai-tests: 95f2a8568433fa88b7da4e627842b2f3d426d08d

Fresh remote HEAD retrieval remains mandatory before future writes.

## Stable reference

The user selected the current rumiai-os revision:

```text
f2c3c0ae02258cc80d81f6e1be1ad2cee338d702
```

as version `2.0.1` and as the stable reference before optimization.

The Git tag `2.0.1` now exists remotely and resolves directly to commit `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702`, matching the stable reference selected before optimization. On 2026-10-02 the user explicitly authorized promotion of the reviewed optimization branch, and `main` was fast-forwarded to `527687b57d94dfde06e0a59d1a556b5fce20c930` without rewriting history.

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

- Preserve the current public `pkg_integrate`, `pkg_deintegrate` and `pkg_default_apply` interfaces.
- Preserve package-definition envelope validation in `pkg_integrate`, including the existing flat-pkg/dmg-pkg component, payload-root and overlay checks. Although extraction owns physical materialization, this validation is current documented and permanently tested integration behavior and is not removed as an implementation shortcut.
- Preserve pre-consumption validation of state/setuid metadata so invalid definitions do not consume caller-owned staging.
- Preserve the specialized rollback order for a failed setuid materialization: setuid rollback, then state rollback, then package-local concrete cleanup/root restoration only when both specialized rollbacks succeeded.
- Treat Git tag `2.0.1`, resolving to `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702`, as the stable comparison baseline.

## Completed in the work branch

### Centralized package-local rollback

`rumiai-os@ddc2c25b11c7bacd31c04c58f04896839a2fdbcf` introduces internal `_pkg_integration_restore_input`.

The helper owns the repeated package-local failure cleanup that was previously duplicated after command, environment, facility, facility-projection, dependency, state and setuid materialization failures:

```text
remove concrete entries other than root
→ move concrete/root back to the caller staging pathname
→ remove the now-empty concrete directory
```

The existing phase-specific diagnostics and return statuses remain unchanged. State/setuid specialized rollback remains outside this helper and retains its original ordering and failure handling.

### Reused canonical package identity validation

`rumiai-os@396d2734326cac24dac8e90a421d9fe2fe0343d6` makes the legacy private integration name/version/osarch validators delegate to the existing public validators in `pkg-common.lib.sh`, eliminating three duplicated grammar implementations without changing their current call shapes or statuses.

`rumiai-os@527687b57d94dfde06e0a59d1a556b5fce20c930` realigns `res/sys/manual/pkg-integration.lib.sh` to record the new explicit `pkg-common.lib.sh` dependency. The public integration API text did not otherwise change.

### Phase comments in pkg_integrate

`rumiai-os@c4a9a503da44ffed15f4a33112b2f229fefda3c7` adds structural comments inside `pkg_integrate` that identify the seven existing stages: invocation/package identity validation, input/concrete derivation, complete pre-consumption validation, concrete/root creation, runtime metadata materialization, state/setuid materialization with specialized rollback, and final setuid commit.

This is documentation-only source annotation: comparison with the previous revision confirms that the non-comment body of `pkg_integrate` is unchanged. The operational manual remains accurate and therefore required no textual change.

### Validator/local-library realignment

The user's validator refactor was completed forward from `14ca5027a4b285ff7fcb9ce3b5bd8d390c5ffa57`.

The user explicitly corrected the return-status convention: validator failures are numbered from 1 according to the function's own validation sequence rather than normalized to a previously inferred generic status convention. Current `pkg-common.lib.sh` therefore keeps:

- simple validators: status 1 for invalid invocation arity and 2 for an invalid value;
- `pkg_name_version_osarch_valid`: status 1 for too few operands, 2 for invalid package name, 3 for invalid version and 4 for invalid non-empty osarch.

Product commits:

- `66d4b3e6e06f0b5ea7c830c2020727a52a68a91f` migrates `pkg-local.lib.sh` from removed integration-private identity validators to `pkg-common.lib.sh`, corrects the remaining `pkg_deintegrate` / `pkg_default_apply` osarch checks to `pkg_osarch_valid`, updates `pkg-common.lib.sh` operational documentation to the implemented statuses, and adds the required `pkg-local.lib.sh` manual.
- During consistency verification, changing `pkg-local` exposed a previous transitive-load dependency: `pkg-default.lib.sh` and `pkg-uninstall.lib.sh` used integration functions without loading `pkg-integration` themselves. `395865b7fd02b13f8c3bc92c37eab6d663739404` makes those imports explicit and adds their required library manuals.

Permanent test commit `rumiai-tests@28714862afea52e06a2623996e7135ef281ccb85` adds direct coverage for simple-validator statuses and the composite 1/2/3/4 statuses, plus integration/deintegration/default rejection of unsupported osarch values.

Static final checks confirm that no active-library references to the removed `_pkg_integration_name_valid`, `_pkg_integration_version_valid` or `_pkg_integration_osarch_valid` remain; `pkg-local` has no public callable functions, and the new/updated manuals match the public functions of the changed libraries.

A follow-up complete pkg-library scan found the only residual eliminated-validator references in superseded `pkg-install_OLD.lib.sh`. `rumiai-os@6dbcd44419bdffdcf54580c9875b449764e7c116` removes both `pkg-install_OLD.lib.sh` and `pkg-extract_OLD.lib.sh`; a post-change scan of all 31 remaining pkg libraries finds zero references to all four eliminated helpers, including `_pkg_integration_command_name_valid`. The same commit fixes the stale `pkg-extract2.lib.sh` dependency name in the pkg-install operational manual.

### valid_dir adoption and explicit integration statuses

The user commit `rumiai-os@866df64a5f62e0e1813d0bd84c28022a6cb65e0e` adds public `valid_dir` to `base.lib.sh` for the recurring real-directory/non-symlink check and starts using it in `pkg_integrate`. The same commit makes `pkg_integrate` stage failures use explicit status values through 20 and changes `pkg_deintegrate` invalid arity to status 1.

Follow-up commits:

- `rumiai-os@d02d945047dc9cc358bca523e0107e3dbba41bba` replaces all 19 remaining exact `[ -d ... ] && [ ! -L ... ]` forms in `pkg-integration.lib.sh` with `valid_dir`. Eight simpler `[ -d ... ]` checks remain because they have different semantics and were deliberately not strengthened.
- `rumiai-os@0dd1efc0bd7ea360d75a08205804b2f2a5800aa7` adds the required `base.lib.sh` manual and documents the current `pkg_integrate` status map.
- `rumiai-os@ea2eb22917edca77a44566ee415301f69ca61ad8` clarifies the distinct `pkg_deintegrate` / `pkg_default_apply` status conventions.
- `rumiai-tests@824f8feaa7e4f4d8936f4abaccc772da17f6a21a` adds direct `valid_dir` coverage and updates duplicate-concrete integration to expect status 9.
- `rumiai-tests@95f2a8568433fa88b7da4e627842b2f3d426d08d` adds direct `pkg_integrate` invalid-arity coverage at status 1 and updates `pkg_deintegrate` invalid arity from 2 to 1.

Final static verification finds zero remaining duplicated real-directory/non-symlink expressions in `pkg-integration.lib.sh`, 22 `valid_dir` calls total, complete public-name coverage in the new base manual, and aligned explicit status expectations in the integration contract test.

## Review findings deliberately not changed in this checkpoint

- Current package libraries still contain pre-existing cross-library calls to underscore-prefixed `pkg-integration` helpers:
  - `pkg-install.lib.sh` and `pkg-uninstall.lib.sh` use `_pkg_integration_set_concrete`;
  - `pkg-state.lib.sh` uses `_pkg_integration_link_target_read`.
- The former `pkg-local.lib.sh` dependency on private integration identity validators has been removed; it now uses only the public `pkg-common.lib.sh` validators.
- These calls conflict with the current library-interface rule that underscore-prefixed functions are private and consumers must not depend on them.
- The broader legacy API-visibility migration is already owned by `todo/library-api-visibility-realignment.md`; do not duplicate that lifecycle here.
- Manual coverage for several legacy package libraries is still incomplete. That backlog is already owned by the active `handoff/rumiai-os-man-documentation.md`, coordinated with the same visibility-realignment TODO.
- The integration-side format/component/payload-root/overlay validation overlaps extraction metadata interpretation, but it is current documented/tested behavior. Removing or relocating it would be a semantic contract decision, not a safe optimization, so it remains unchanged.

## Validation performed

- The complete branch diff against stable `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702` was reread.
- The optimization diff through `527687b57d94dfde06e0a59d1a556b5fce20c930` changed:
  - `lib/sys/sh/pkg/pkg-integration.lib.sh`;
  - `res/sys/manual/pkg-integration.lib.sh`.
- The subsequent phase-comment commit `c4a9a503da44ffed15f4a33112b2f229fefda3c7` changes only `lib/sys/sh/pkg/pkg-integration.lib.sh`, with 13 comment-line additions and no executable-code changes.
- Before promotion, the branch was three commits ahead and zero behind the stable baseline.
- After explicit user authorization, `main` was fast-forwarded to the branch tip `527687b57d94dfde06e0a59d1a556b5fce20c930`.
- Post-promotion verification confirms `main` and `pkg-integrate-optimization` resolve to the same commit, while Git tag `2.0.1` resolves to the stable baseline `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702`.
- Public function discovery on the modified integration library still yields exactly:
  - `pkg_integrate`
  - `pkg_deintegrate`
  - `pkg_default_apply`
- A mechanical extraction of the major validation/materialization/diagnostic sequence from stable and optimized `pkg_integrate` reports the same sequence.
- The newly introduced helper and validator-delegation function bodies pass a local POSIX `sh -n` syntax check.
- The current permanent integration/state/environment/common tests were inspected and remain semantically applicable; no test expectation was changed by this behavior-preserving refactor.
- The final product diff from the user's `67e70b1391c9ab105874d3253017be55b92ca588` checkpoint is two forward commits and contains the validator/local-library/manual corrections described above.
- The permanent-test diff is one forward commit and adds validator-status plus unsupported-osarch regression coverage.
- GitHub Actions runs triggered by the test commit are not usable as final-task evidence: `package-provider-facility-bridge` is pinned by its validation config to historical `rumiai-os@0966ba9cb55dc7014ede2d726849fe83ed5cb757` and failed before test execution in runner selection expansion; the concurrently started `rumiai-os-health` run froze a product revision before the final dependency-import correction. No runtime PASS for final `rumiai-os@395865b7fd02b13f8c3bc92c37eab6d663739404` is claimed.

## Next action

1. Run proportional permanent package common/local/integration/default/uninstall/state/environment validation against final `rumiai-os@6dbcd44419bdffdcf54580c9875b449764e7c116` and `rumiai-tests@28714862afea52e06a2623996e7135ef281ccb85`.
2. Continue optimization only with contract-preserving changes; route the remaining cross-library private-helper visibility migration through `todo/library-api-visibility-realignment.md`.
3. Perform the final consistency gate after the next material optimization/validation checkpoint.

## Blockers / open questions

- Full runtime validation of final current `main` remains pending. GitHub Actions for `rumiai-tests@95f2a8568433fa88b7da4e627842b2f3d426d08d` were still queued/in progress at the final checkpoint; no runtime PASS is claimed.
