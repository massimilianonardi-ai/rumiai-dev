# gitman command

Status: Active
Updated: 2026-09-19

## Goal

Implement the technical `gitman` command as an interactive manager for local non-bare Git working trees, with repository acquisition/management menus and an initial read-only Git action menu.

## Current repository revisions

```text
rumiai-dev   c10167ab80c69d0efea53e7e502f1298bad77552
rumiai-os    34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests 88b4e48f170da883889c2f418a34e8ad24066e9d
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/MENU.md`
- `specifications/rumiai-os/READ-KEY.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`

## Fixed task-local choices

- Command identity: `gitman`, technical `m` layer, bootstrap-integrated.
- Positional operands are candidate directories. With zero operands, read initial candidates from user-scoped `sys/gitman/conf`; if no usable configured candidate exists, fall back to `.`.
- Initial configuration remains one logical directory pathname per non-empty line, with minimal escaping: `\n` encodes a pathname newline and `\\` encodes a literal backslash. Other characters remain literal. Relative entries resolve against the invocation working directory; shell expansion is not applied.
- Candidates are accepted only when they belong to a non-bare Git working tree.
- Accepted candidates normalize to the physical Git working-tree top-level; duplicate top-levels are stored once.
- Distinct linked Git worktrees remain distinct entries even when they share the same underlying Git repository.
- The bottom footer contains only the most recent validation/configuration error. Multiple candidate failures from one validation operation are aggregated into one message.
- Zero repositories opens filesystem `menu` multi-selection; confirmed selections are revalidated and added.
- One or more repositories opens a single-select repository menu.
- Repository-menu management actions: `a` add, `r` remove via multi-select, `c` clear all, `s` save current repositories to configuration.
- Save confirms before replacing an existing non-empty configuration file; the confirmation defaults to No.
- Repository selection with Enter opens the Git action menu.
- Git action menu uses Backspace to return to the repository menu; Escape also cancels the submenu back to its parent.
- Initial Git actions are read-only: status, log, branch, diff.
- Git actions preserve Git's normal pager behavior. gitman must not force `--no-pager`, override `GIT_PAGER`/`PAGER`, or otherwise replace Git's pager-selection policy.
- A Git action runs only after the menu session has returned and restored the terminal. After the Git command finishes, `gitman` prompts `Press any key to continue...`, waits through `read-key`, then recreates the Git action menu.
- Top-level Escape/cancellation exits `gitman` successfully. Submenu cancellation returns to the parent menu.
- Repository-list add/remove/clear operations are in-memory only unless the user explicitly selects save; `gitman` never deletes repositories or modifies Git state in this first delivery.

## Working design

None currently required.

## Completed

- Mandatory preflight completed.
- Current command, state, menu, terminal-input, documentation and testing contracts inspected.
- Canonical `GITMAN.md` created and routed from `specifications/README.md`.
- Initial `gitman` command and operational manual implemented.
- Permanent contract and interactive tests added.
- First development run: contract test PASS; interactive test FAIL due a test expectation that searched for the colorized Git status token without allowing ANSI sequences. Product output itself showed correct terminal restoration, Git status output and pause prompt.
- User refinement accepted during the active task: configuration now supports newline/backslash escaping and repository menu gains explicit save with overwrite confirmation.
- Canonical specification, command and manual have been updated for that refinement.
- Concurrent `rumiai-os` movement was reconciled forward; the unrelated package-layout commit was preserved.
- Revised permanent tests later passed 2/2 in development validation.
- Two formal-validation bridge attempts were classified as infrastructure failures caused by detached-HEAD checkouts before the validation runner could execute the scope.

## Current state

```text
rumiai-dev   15a6cea5b376094751f7596f66c27292b81f1270
rumiai-os    50b760bd3cfe08922068ceb7d973d7edee12251c
rumiai-tests 5b39aeefc6af2198aacd014df31d4c03a4d24b66
```

Permanent gitman tests were realigned and a later development run passed both contract and interactive coverage, including configuration escaping/save/overwrite confirmation.

Two formal-validation attempts failed before testing because the bridge checkout shape was incompatible with `rumiai-validate`: first `rumiai-tests`, then the target `rumiai-os`, was left on detached HEAD and the launcher refused its required fast-forward self-update. This is validation-infrastructure failure, not product/test evidence.

User testing exposed that the current RumiAI `pager` is not a conventional pager command: it requires one file operand and therefore cannot serve correctly as a stdin-driven pager selected by Git. The temporary `git --no-pager` workaround now present in product/spec/tests contradicts the user's required standard Git behavior and must be removed.

## Next action

Expand the canonical `pager` contract/implementation to support stdin with zero operands and multiple file operands while preserving caller pager environment, restore ordinary Git commands in gitman, update manuals/tests, then rerun development/formal validation on exact revisions.

## Blockers / open questions

None.
