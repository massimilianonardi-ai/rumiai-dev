# pkg integration optimization

Status: Active
Updated: 2026-10-02

## Goal

Review and optimize the current `pkg_integrate` implementation while preserving the promoted package-integration contract unless a semantic change is explicitly justified and propagated.

## Current repository revisions

- rumiai-dev: 3a8e21a1f844de80c773e1d2b709ee11a8fbf1bb (pre-checkpoint HEAD)
- rumiai-os main: 527687b57d94dfde06e0a59d1a556b5fce20c930
- rumiai-os work branch `pkg-integrate-optimization`: 527687b57d94dfde06e0a59d1a556b5fce20c930
- rumiai-tests: b0715c677c428af68ea507983db5443a89428f8f

Fresh remote HEAD retrieval remains mandatory before future writes.

## Stable reference

The user selected the current rumiai-os revision:

```text
f2c3c0ae02258cc80d81f6e1be1ad2cee338d702
```

as version `2.0.1` and as the stable reference before optimization.

The available GitHub connector does not expose tag creation and the execution environment cannot reach github.com directly, so the requested Git tag `2.0.1` has not yet been created. The stable commit remains the exact historical baseline by SHA. On 2026-10-02 the user explicitly authorized promotion of the reviewed optimization branch, and `main` was fast-forwarded to `527687b57d94dfde06e0a59d1a556b5fce20c930` without rewriting history.

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
- Treat the exact main commit above as the stable comparison baseline until the requested `2.0.1` tag can be created.

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
- Current diff scope is exactly:
  - `lib/sys/sh/pkg/pkg-integration.lib.sh`;
  - `res/sys/manual/pkg-integration.lib.sh`.
- Before promotion, the branch was three commits ahead and zero behind the stable baseline.
- After explicit user authorization, `main` was fast-forwarded to the branch tip `527687b57d94dfde06e0a59d1a556b5fce20c930`.
- Post-promotion verification confirms `main` and `pkg-integrate-optimization` resolve to the same commit, while the stable 2.0.1 reference remains `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702`.
- Public function discovery on the modified integration library still yields exactly:
  - `pkg_integrate`
  - `pkg_deintegrate`
  - `pkg_default_apply`
- A mechanical extraction of the major validation/materialization/diagnostic sequence from stable and optimized `pkg_integrate` reports the same sequence.
- The newly introduced helper and validator-delegation function bodies pass a local POSIX `sh -n` syntax check.
- The current permanent integration/state/environment/common tests were inspected and remain semantically applicable; no test expectation was changed by this behavior-preserving refactor.
- Full executable checkout validation has not been run: the available execution environment cannot obtain the GitHub checkout, and the available GitHub connector exposes no workflow-dispatch action. No runtime PASS is claimed.

## Next action

1. Materialize the requested Git tag `2.0.1` on stable commit `f2c3c0ae02258cc80d81f6e1be1ad2cee338d702` when a tag-capable Git interface is available.
2. Run the proportional permanent package integration/common/state/environment validation against current `main`.
3. Continue the optimization review only for changes that preserve the current integration contract; route legacy API-visibility/manual cleanup through its existing owners rather than duplicating it here.
4. Perform the final consistency gate after the next material optimization/validation checkpoint.

## Blockers / open questions

- The Git tag `2.0.1` cannot currently be created through the available connector.
- Full runtime validation of the work branch is not available in the current execution environment.
