# pkg eliminated-function caller cleanup

Status: Complete
Updated: 2026-10-03

## Goal

Remove current pkg-library references to the integration validator functions eliminated by the user's pkg-integrate refactor, without restoring obsolete private APIs.

## Current repository revisions

- rumiai-dev: 8c0f700d427bb45f7a6dd52effc9c2ac8b9e6398 (pre-completion HEAD)
- rumiai-os: 6dbcd44419bdffdcf54580c9875b449764e7c116
- rumiai-tests: 28714862afea52e06a2623996e7135ef281ccb85

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- handoff/pkg-integration-optimization.md
- handoff/rumiai-os-man-documentation.md

## Fixed task-local choices

- The eliminated functions are not restored.
- Superseded backup libraries are removed from the current library tree rather than maintained against current APIs.
- The separate issue of calls to underscore-prefixed helpers that still exist remains deferred under the general library API-visibility TODO.

## Completed

- Verified from the eliminating commit that the removed functions were:
  - `_pkg_integration_name_valid`
  - `_pkg_integration_version_valid`
  - `_pkg_integration_osarch_valid`
  - `_pkg_integration_command_name_valid`
- Scanned every current pkg library before cleanup. The only remaining caller was superseded `lib/sys/sh/pkg/pkg-install_OLD.lib.sh`.
- Verified the current `pkg` dispatcher loads `pkg/pkg-install`, not the `_OLD` library, and proportional permanent pkg tests contain no references to either pkg `_OLD` library or to the eliminated validator functions.
- `rumiai-os@6dbcd44419bdffdcf54580c9875b449764e7c116` removes superseded `pkg-install_OLD.lib.sh` and `pkg-extract_OLD.lib.sh` and corrects the stale `pkg-extract2.lib.sh` dependency name in `res/sys/manual/pkg-install.lib.sh`.
- Post-change scan covers all 31 remaining pkg libraries and finds zero references to the four eliminated functions.
- The diff is one forward commit; no runtime implementation file used by the current pkg dispatcher was changed.

## Current state

The eliminated-function caller problem in the current pkg library tree is resolved. No permanent-test change was required because the removed files were not part of the runtime/test surface.

Runtime checkout execution was unavailable because the auxiliary execution environment cannot resolve `github.com`; no runtime PASS is claimed. Structural/current-source validation is complete for this cleanup.

## Next action

None.

## Blockers / open questions

None.
