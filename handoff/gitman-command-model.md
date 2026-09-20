# gitman command model

Status: Complete
Updated: 2026-09-20

## Goal

Refactor `gitman` so Git actions and nested action menus are simple to extend while preserving explicit, inspectable execution. Remove the former read-only product restriction without adding mutating Git actions in this work unit.

## Current repository revisions

- `rumiai-dev`: `4ff787e954b364fcf24f9a45a2e3d92324be40f6`
- `rumiai-os`: `22d5e1a57dcbd7e95c268f4357fac2d7478eb058`
- `rumiai-tests`: `a7571571fc099584c8af283048e7f07943e300f0`

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/PAGER.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Completed

- Removed the normative read-only restriction from the gitman action model while keeping the currently delivered action set non-mutating.
- Defined action menus as action-id/display-label pairs with concrete Git command/templates shown by leaf entries.
- Defined explicit `gitman_action_<id>` handler dispatch, one generic Git runner for simple handlers, and ordinary shell handlers/call-stack return context for future nested menus.
- Refactored `bin/sys/gitman` so `status`, `log`, `branch` and `diff` are separate handlers using the generic runner; command labels are descriptive only and Git execution uses argument vectors rather than command-string evaluation.
- Realigned `res/sys/manual/gitman`, permanent contract coverage and the interactive action-label assertion.
- Corrected the macOS interactive test to compare the physical repository identity required by the existing gitman contract.
- Hosted validation run `35491746462` exercised `rumiai-os` `22d5e1a57dcbd7e95c268f4357fac2d7478eb058` with `rumiai-tests` `33ab5a2656faaf0bc9aeb53ac40f3250bcb182e5`; the `rumiai-os/gitman` scope passed on both Ubuntu and macOS.
- The temporary validation workflow was removed afterward. A concurrent unrelated `rumiai-tests` change was preserved; the current gitman contract/interactive test blobs remain the same as those exercised by the successful run.
- Final consistency review found no remaining old central gitman action executor/runner or obsolete read-only test prohibition in the affected current surfaces.

## Current state

The canonical specification, implementation, operational manual and permanent gitman tests are aligned on the extensible handler model. The currently exposed Git actions remain `status`, `log`, `branch` and `diff`; adding new leaf actions or submenus is the next independent gitman feature work, not unfinished work from this refactor.

Physical validation was not performed. The completed validation evidence is hosted Ubuntu/macOS evidence only and remains revision-specific to the revisions recorded above.

## Next action

None for this task.

## Blockers / open questions

None.
