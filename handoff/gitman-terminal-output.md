# gitman quick-action ordering and terminal headers

Status: Active
Updated: 2026-09-22

## Goal

Move the existing Sync + Push quick action to the first position in the root Git action menu and make terminal/no-pager execution print one three-line header per menu-selected command sequence: 50 hyphens, the selected menu label, then 50 hyphens.

## Current repository revisions

```text
rumiai-dev    fd79342a101a7d167f6b2e386da2328f516ff7e5  canonical sources before this checkpoint
rumiai-os     0a45bddce0318e111a72b052f7bc8366d2911b0b  current main
rumiai-tests  528dd8e72eb89cd8bb2d64aef243ee144e87dbdb
```

The task validation scope deliberately pins `rumiai-os` at `1683ff139cfa775adeb832ffae10944b40155256`. That revision contains the complete gitman change. Later current-main commits through `0a45bddc...` affect only unrelated package/http-fetch surfaces and were checked for forward-only compatibility.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
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

## Completed

- Mandatory preflight completed for all involved repositories.
- Canonical `GITMAN.md` contract updated: Sync + Push is first and terminal sequence headers are normative.
- `rumiai-os/bin/sys/gitman` updated to carry the selected menu label into execution, print the exact 50-hyphen header once per terminal-mode sequence, start the composite Sync + Push header before its preliminary Git status check, and preserve pager behavior.
- `rumiai-os/res/sys/manual/gitman` updated for the new root order and terminal output.
- Permanent contract and PTY interactive tests updated. The interactive test checks Sync + Push ordering, exact header shape, concrete labels including branch selection, and one header per composite sequence.
- `validation/gitman.conf` updated to the exact target revision `1683ff139cfa775adeb832ffae10944b40155256`.
- Final static consistency review found no remaining `Repository:` / `Action:` terminal-header expectations and reconciled concurrent unrelated repository movement forward.

## Current state

Implementation, specification, manual and permanent tests are aligned and committed.

No real executable validation result has been obtained in this ChatGPT session. The available auxiliary Linux container has no RumiAI checkout, direct network clone/download is unavailable, and no existing GitHub Actions workflow targets gitman. This is a validation limitation, not a PASS or FAIL.

## Next action

From a real `rumiai-tests` checkout, run the current formal task scope:

```sh
./rumiai-validate gitman
```

Record the resulting session evidence and then complete/remove this handoff according to the normal completion protocol if all required tests pass.

## Blockers / open questions

- Formal/real execution of the gitman task scope is still pending.
