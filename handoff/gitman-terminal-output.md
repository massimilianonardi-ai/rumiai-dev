# gitman quick-action ordering and terminal headers

Status: Active
Updated: 2026-09-22

## Goal

Move the existing Sync + Push quick action to the first position in the root Git action menu and make terminal/no-pager execution print one three-line header per menu-selected command sequence: 50 hyphens, the selected menu label, then 50 hyphens.

## Current repository revisions

```text
rumiai-dev    526b3f398b50be2639cbeb83f23a24d740eef9a1  canonical/task state before this checkpoint
rumiai-os     0a45bddce0318e111a72b052f7bc8366d2911b0b  current main
rumiai-tests  8513947696dfc1290a52d669eab16f700a4c48dd
```

The task validation scope deliberately pins `rumiai-os` at `1683ff139cfa775adeb832ffae10944b40155256`. That revision contains the complete gitman change. Later current-main commits through `0a45bddc...` affect only unrelated package/http-fetch surfaces and were checked for forward-only compatibility.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
RUNNER.md
specifications/README.md
specifications/rumiai-os/GITMAN.md
specifications/rumiai-os/PAGER.md
specifications/rumiai-os/MENU.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
```

## Fixed task-local choices

- Preserve the existing public action name `Sync + Push`; only its root-menu position changes.
- The terminal-mode header is emitted once for the whole command sequence selected from a menu, not once for every internal Git subprocess of a composite action.
- The header text is the concrete selected menu label. For branch switching this is the concrete branch item such as `Switch: git switch feature/example`.
- Task validation must protect only the properties changed by this work unit; the broad historical `interactive.test` remains a general regression test and is not the task scope for the terminal-header change.

## Completed

- Mandatory preflight completed for all involved repositories.
- Canonical `GITMAN.md` contract updated: Sync + Push is first and terminal sequence headers are normative.
- `rumiai-os/bin/sys/gitman` updated to carry the selected menu label into execution, print the exact 50-hyphen header once per terminal-mode sequence, start the composite Sync + Push header before its preliminary Git status check, and preserve pager behavior.
- `rumiai-os/res/sys/manual/gitman` updated for the new root order and terminal output.
- Initial permanent tests were updated, but the first formal user run reported one PASS and one FAIL while normal gitman use remained functionally healthy. The exact failed-session log was not published in the repository, so that historical FAIL cannot be attributed to a specific property from repository evidence alone.
- Review found that `validation/gitman.conf` selected the entire `rumiai-os/gitman` group. Its broad `interactive.test` covers many unrelated properties (configuration, repository management, editor behavior, branches, stash, Sync + Push and output presentation), so one unrelated failure could incorrectly invalidate this narrow work unit.
- Added executable `tests/rumiai-os/gitman/terminal-output.test`, a focused real-entrypoint PTY test that verifies Sync + Push is first, exact 50-hyphen / selected-label / 50-hyphen terminal headers, one header for the composite Sync + Push sequence, one header for Status, and successful real local pull/push state against a temporary bare remote.
- Removed duplicate exact-header assertions from the broad `interactive.test`; it continues to verify its workflow/state properties without owning terminal-header formatting.
- Narrowed `validation/gitman.conf` to `rumiai-os/gitman/terminal-output.test` while retaining the exact task target revision.
- Verified the new test is stored with executable mode `100755`.
- Final static consistency review confirms the focused test is the behavioral owner of the changed terminal-header contract and the broad test contains no remaining exact-header helper/assertions.
- User executed the focused formal validation on Linux/x86_64 at target `1683ff139cfa775adeb832ffae10944b40155256`; session `20260922T093848+0200-65348` returned one FAIL after 10.36s and the validation environment was CLEAN.
- The published validation evidence is local to the user's checkout and is not available from GitHub, but source inspection identified a deterministic false-failure condition: the focused PTY test waited for the complete long Sync + Push label inside the rendered menu, while the current menu renderer explicitly truncates each item to terminal width (`_menu_term_cols - 2`). The observed ~10s duration matches the test's 10-second `wait_for` timeout.
- Updated `terminal-output.test` to verify menu ordering using the stable visible prefix `Sync + Push: git add --all`, while retaining the complete label assertion on the terminal-mode sequence header where no menu truncation occurs.
- Removed redundant Home-key driving from the PTY scenario; each recreated Git action menu starts at the first item, so the test now avoids an unrelated terminal-key dependency.
- Post-change consistency review confirms only `terminal-output.test` changed, its executable mode remains `100755`, no full-label menu wait remains, and the exact full-label header assertions remain intact.

## Current state

Implementation, specification and manual remain aligned. The task validation scope is now minimum-sufficient for the changed behavior rather than the complete historical gitman regression group.

A real formal execution of the focused test has now been obtained from the user's Linux/x86_64 checkout. That run failed because the test waited for a menu-rendered string that the menu contract truncates to terminal width; no product defect was established by that run. The false-failure condition has been corrected in `rumiai-tests`.

A successful formal rerun of the corrected focused test is still pending.

## Next action

From a real `rumiai-tests` checkout, run:

```sh
./rumiai-validate gitman
```

The scope executes only `rumiai-os/gitman/terminal-output.test`. The corrected suite revision is `8513947696dfc1290a52d669eab16f700a4c48dd`. Record the resulting evidence and complete/remove this handoff if it passes.

If the broad `rumiai-os/gitman/interactive.test` is run separately and still fails, treat that as a separate regression/health investigation using its concrete log rather than as evidence that this terminal-header task is broken.

## Blockers / open questions

- Formal rerun of the corrected focused task scope is still pending.
