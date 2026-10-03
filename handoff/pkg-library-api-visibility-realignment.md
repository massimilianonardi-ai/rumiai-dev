# pkg library API visibility realignment

Status: Active
Updated: 2026-10-03

## Goal

Remove cross-library dependencies inside the pkg subsystem on implementation-private underscore-prefixed functions, with the immediate focus on callers left coupled to pkg-integration internals, while preserving existing public package behavior.

## Current repository revisions

- rumiai-dev: a76a965dcecf9bc8e3acec4a8651edfd7d287f7c (pre-activation HEAD)
- rumiai-os: 395865b7fd02b13f8c3bc92c37eab6d663739404
- rumiai-tests: 28714862afea52e06a2623996e7135ef281ccb85

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- handoff/pkg-integration-optimization.md
- handoff/rumiai-os-man-documentation.md

## Fixed task-local choices

- Do not make pkg-integration private helpers public merely to preserve legacy callers.
- Shared responsibilities must move to an existing appropriate shared owner when one exists; callers must use public interfaces only.
- Preserve current public pkg command/library behavior unless a current canonical contract requires otherwise.
- Keep public API/manual/test changes in the same work unit.

## Completed

- Activated the pkg subset of the deferred library API-visibility work.
- The broader non-pkg library visibility audit remains deferred under a separate TODO.

## Current state

Known current pkg cross-library private-helper dependencies include pkg-install/pkg-uninstall callers of pkg-integration concrete-identity state and pkg-state use of pkg-integration relative-link-target parsing. Current implementation/tests must be inspected before choosing the owning public interfaces.

## Next action

Audit the exact current callers/owners and realign each dependency to public library APIs, then update manuals and proportional permanent tests.

## Blockers / open questions

- None.
