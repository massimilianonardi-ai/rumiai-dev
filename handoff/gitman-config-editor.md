# gitman configuration editor

Status: Active
Updated: 2026-09-19

## Goal

Add a portable repository-configuration editing workflow to `gitman` without introducing a hard dependency on a non-standard editor.

## Current repository revisions

```text
rumiai-dev   2a1c64ef2b5c7f5b1c0e84940d919a43a4b9c2ba
rumiai-os    7f6ced69baef8484d96e7db1572686d67c6bdaaf
rumiai-tests b461be38979abd50f7f5f587eb316022fd17c924
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `specifications/README.md`
- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`

## Fixed task-local choices

- Repository-menu action key: `e` edits the repositories configuration.
- Editor selection follows the conventional portable order: non-empty `VISUAL`, then non-empty `EDITOR`, then `vi`.
- `nano` is not a dependency or implicit backend; users who prefer it select it through `VISUAL=nano` or `EDITOR=nano`.
- The editor runs only after the selecting `menu` invocation has returned and restored normal terminal state.
- A successful editor exit is followed by a single-select confirmation asking whether to discard the current in-memory repository set and reload the edited configuration.
- Reload confirmation defaults to No; No/cancel preserves the current in-memory set.
- Yes clears the current set and loads only entries from the configuration file, with normal decoding, Git working-tree validation, normalization, deduplication and aggregated bottom-footer errors. The startup `.` fallback is not applied to this explicit reload.
- If explicit reload yields zero valid repositories, `gitman` naturally returns to filesystem acquisition.
- A non-zero editor exit leaves the repository set unchanged and reports one concise bottom-footer error.

## Completed

- Mandatory preflight completed.
- Current gitman specification, implementation, manual and permanent tests inspected.
- Current gitman already has repository save/config encoding and pager/terminal output-mode support; those behaviors must be preserved.

## Current state

No specification, product or permanent-test modification for this editor workflow has been made yet.

## Next action

Promote the accepted editing contract into `GITMAN.md`, implement command/manual changes, add permanent tests, then run development and formal validation plus final consistency gate.

## Blockers / open questions

None.
