# pkg integration optimization

Status: Active
Updated: 2026-10-02

## Goal

Review and optimize the current `pkg_integrate` implementation while preserving the promoted package-integration contract unless a semantic change is explicitly justified and propagated.

## Current repository revisions

- rumiai-dev: 7bbd40c99dcbdd1e6b44fabf147da7f6c7a1345d (pre-checkpoint HEAD)
- rumiai-os main: bee47839fa1b6c1865ddffcde25063380705d695
- rumiai-os work branch `pkg-integrate-optimization`: 527687b57d94dfde06e0a59d1a556b5fce20c930
- rumiai-tests: b0715c677c428af68ea507983db5443a89428f8f

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

### User refactor review at 14ca5027

The user committed `rumiai-os@14ca5027a4b285ff7fcb9ce3b5bd8d390c5ffa57` to simplify package identity validation. The direction is consistent with removing integration-local validator wrappers, but the current revision has blocking defects:

- The initial `14ca5027` version of `pkg_name_version_osarch_valid` validated its optional osarch operand with `pkg_version_valid`; follow-up commit `bee47839fa1b6c1865ddffcde25063380705d695` corrected that helper to call `pkg_osarch_valid`.
- `pkg_deintegrate` and `pkg_default_apply` still validate osarch with `pkg_version_valid`, so unsupported identities such as `banana` or `linux-sparc64` remain accepted because they satisfy the version grammar.
- The removed `_pkg_integration_name_valid`, `_pkg_integration_version_valid` and `_pkg_integration_osarch_valid` functions are still called eight times by current `pkg-local.lib.sh`. Normal consumers including `pkg-versions.lib.sh`, `pkg-default.lib.sh` and `pkg-uninstall.lib.sh` depend on `pkg-local`, so the migration is incomplete and leaves undefined-function paths.
- The new `pkg_name_version_osarch_valid` function is public by naming but is absent from `res/sys/manual/pkg-common.lib.sh`, conflicting with the current library/manual contract.
- Its invocation/status behavior is also inconsistent with the existing pkg-common public validator convention: it accepts extra operands, returns 1 for too few operands, 2 for invalid name, 3 for invalid version and 4 for invalid osarch, whereas the current pkg-common manual defines 1 as invalid value and 2 as invalid invocation.
- Current permanent `pkg/common.test` has no direct coverage for the new helper, and the integration contract has no explicit osarch case. The existing integration contract does exercise `pkg versions`, so a real run should expose the broken pkg-local dependency path.

Positive part of the refactor: replacing the integration-local command-name/overlay/version wrapper calls with the canonical `pkg_name_valid` / `pkg_version_valid` functions removes unnecessary indirection and is consistent with the current shared-validator responsibility.

## Review findings deliberately not changed in this checkpoint

- Current package libraries contain pre-existing cross-library calls to underscore-prefixed `pkg-integration` helpers:
  - `pkg-install.lib.sh` and `pkg-uninstall.lib.sh` use `_pkg_integration_set_concrete`;
  - `pkg-local.lib.sh` uses the private integration name/version/osarch validators;
  - `pkg-state.lib.sh` uses `_pkg_integration_link_target_read`.
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
- Full executable checkout validation of current `main` has not been run: the available execution environment cannot obtain the GitHub checkout, and the available GitHub connector exposes no workflow-dispatch action. No runtime PASS is claimed.

## Next action

1. Repair the validation refactor before treating current `main` as a validated optimization checkpoint:
   - use `pkg_osarch_valid` for every osarch validation;
   - complete migration of current `pkg-local.lib.sh` callers away from removed integration-private validator functions;
   - avoid introducing `pkg_name_version_osarch_valid` as a new public API unless it has a real shared responsibility; if retained, define exact arity/status semantics, document it and add proportional permanent coverage.
2. Run proportional permanent package common/local/integration/default/uninstall/state/environment validation against the repaired current revision.
3. Continue optimization only with contract-preserving changes and perform the final consistency gate after the next material checkpoint.

## Blockers / open questions

- Current `rumiai-os@bee47839fa1b6c1865ddffcde25063380705d695` fixes the composite helper's osarch validator, but still contains the remaining blocking validator/migration defects recorded above and should not be treated as a validated optimization checkpoint.
- Full runtime validation of current `main` is not available in the current execution environment.
