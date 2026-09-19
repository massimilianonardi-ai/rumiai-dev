# RumiAI OS — gitman

Status: **Current / normative**  
Updated: 2026-09-19

## 1. Scope

`gitman` is the technical `m` command for interactively managing a temporary set of local Git working trees and running read-only Git inspection commands against them.

Canonical executable:

```text
bin/sys/gitman
```

The command is bootstrap-integrated and uses:

```sh
#!/usr/bin/env m
```

The first delivery depends on the existing `menu`, `read-key` and `state-path` command surfaces and on an available external `git` executable.

## 2. Invocation

The public invocation is:

```text
gitman [directory ...]
```

Every operand is a candidate directory.

The first delivery introduces no command-local `-h`, `--help` or other help option. Operational reference is provided by `manual gitman`.

## 3. Initial directory sources

When one or more operands are supplied, those operands are the complete initial candidate set.

When no operands are supplied, `gitman` resolves:

```text
state-path user sys gitman conf
```

and looks for:

```text
<gitman-conf>/repositories
```

The configuration file is optional. Its first-delivery format is:

```text
one literal directory pathname per non-empty line
```

Blank lines are ignored. No shell parsing, quoting, tilde expansion, variable expansion or comment syntax is applied.

Relative pathnames from both operands and the configuration file are resolved from the invocation working directory.

If the configuration file is absent, or contains no non-empty entries, the initial candidate set is:

```text
.
```

If the configuration pathname exists but cannot be read as a regular file, `gitman` records that as the current error and falls back to `.`.

The configuration area is read-only for this first delivery. `gitman` does not create or rewrite the configuration file.

## 4. Repository identity

A candidate is accepted only when it belongs to a non-bare Git working tree.

For an accepted candidate, `gitman` resolves the Git working-tree top-level and then physically normalizes that directory. The resulting physical top-level pathname is the identity stored by `gitman`.

Consequences:

- a repository root and any of its ordinary subdirectories normalize to one entry;
- repeated candidates that normalize to the same working-tree top-level are deduplicated;
- symlink aliases that resolve to the same physical working-tree top-level are deduplicated;
- distinct linked Git worktrees remain distinct entries even when they share the same underlying Git repository;
- Git submodules and genuinely nested repositories are distinct when Git reports distinct working-tree top-levels;
- bare repositories are not supported by the first delivery.

Validation never changes repository content or Git configuration.

## 5. Error state and bottom footer

`gitman` maintains at most one current user-facing error message.

Every menu rendered by `gitman` passes that message through the menu bottom footer.

A validation operation may process multiple candidate directories. All failures from that one operation are combined into one error message so that no failure is hidden by a later failure in the same batch.

A later operation replaces the previous error message. A successful operation that produces no error clears it.

The command may still use normal fatal diagnostics for failures that prevent the interactive workflow itself from operating, such as an unavailable required command or a menu/terminal execution failure.

## 6. Main state model

The interactive state is determined by the number of currently stored repositories:

```text
0 repositories
    filesystem acquisition menu

1+ repositories
    repository menu
```

Repository-list changes are in-memory only. Removing an entry from `gitman` never deletes a directory, changes Git state or modifies the configuration file.

## 7. Filesystem acquisition

When no valid repository is currently stored, `gitman` opens `menu` in filesystem multi-selection mode starting from the invocation working directory.

The normal filesystem `menu` semantics apply:

```text
Enter       browse a directory
Space       mark/unmark
Backspace   parent directory
Tab         confirm the selection
Escape      cancel
```

Every confirmed filesystem selection is revalidated using the repository-identity rules in this specification.

Valid working trees are added to the current set. Invalid candidates contribute to the one aggregated bottom-footer error for that selection operation.

If no repository becomes valid, the filesystem acquisition state is shown again.

Cancelling filesystem acquisition while the repository set is empty exits `gitman` successfully.

## 8. Repository menu

When at least one repository exists, `gitman` presents a single-selection menu containing the physical top-level pathnames.

The repository menu uses:

```text
Enter   open the selected repository
a       add repositories
r       remove repositories
c       clear all repositories
Escape  exit gitman
```

### Add

`a` opens filesystem multi-selection from the invocation working directory.

Confirmed selections are validated and deduplicated exactly like initial candidates. Cancelling the add submenu returns to the repository menu.

### Remove

`r` opens a multi-selection list containing the current repositories.

```text
Space       mark/unmark
Enter       remove selected/current entries
Backspace   return without removing
Escape      return without removing
```

Removal affects only the in-memory repository set.

### Clear all

`c` clears the entire in-memory repository set without touching the filesystem or Git state.

Because the repository set then has size zero, the command returns to filesystem acquisition.

## 9. Repository action menu

Selecting a repository with Enter opens a single-selection Git action menu for that working tree.

Backspace is the default explicit return key:

```text
Enter       run selected Git action
Backspace   return to repository menu
Escape      return to repository menu
```

The first delivery exposes only read-only Git actions:

```text
status
log
branch
diff
```

Their concrete commands are:

```text
status
    git -C <repository> status --short --branch

log
    git -C <repository> log --oneline --decorate --graph -n 50

branch
    git -C <repository> branch -vv

diff
    git -C <repository> diff
```

No mutating Git operation is part of the first-delivery action set.

## 10. Terminal lifecycle around Git actions

A Git command is never executed while the `menu` session that selected it still owns terminal rendering state.

The required sequence is:

```text
menu selection completes
    ↓
menu restores its terminal session
    ↓
gitman runs the Git command on the normal terminal
    ↓
gitman displays "Press any key to continue..."
    ↓
read-key waits for one key
    ↓
gitman renders the Git action menu again
```

`gitman` does not implement a second terminal-mode stack around Git execution. It relies on the existing `menu` terminal restoration contract and on `read-key` for the one-key pause.

A non-zero Git command result does not terminate the interactive session. The Git command's own output remains visible, and `gitman` records a concise failure message as the current bottom-footer error before returning to the Git action menu.

A successful Git command clears the current error before the action menu is recreated.

Failure of the pause/input primitive itself is an execution failure of `gitman`.

## 11. Cancellation

Cancellation is interpreted by menu depth:

```text
top-level repository menu
    exit gitman successfully

filesystem acquisition with zero repositories
    exit gitman successfully

add/remove/action submenus
    return to the repository menu
```

## 12. Output and side effects

`gitman` is an interactive terminal command. Menu rendering is owned by `menu`; Git command output is emitted normally after menu terminal state has been restored.

The first delivery does not define a machine-readable stdout result.

The command does not:

- create, delete or modify repositories;
- change branches;
- stage, commit, reset, checkout, merge, rebase, fetch, pull or push;
- alter Git configuration;
- persist the interactive repository list;
- create or modify the optional repository configuration file.

## 13. Exit status

The first-delivery public status contract is:

```text
0   normal user exit/cancellation
1   execution failure after a valid invocation
2   invalid invocation
127 required external command unavailable
```

Individual Git action failures are reported interactively and do not become the final `gitman` exit status when the user continues the session and later exits normally.

Signal-derived statuses may propagate when the surrounding runtime terminates the command.

## 14. Layering

`gitman` owns:

- repository-set workflow and in-memory state;
- initial candidate/configuration loading;
- Git working-tree validation and normalization;
- repository-list management actions;
- mapping action identifiers to the approved read-only Git commands;
- error aggregation and bottom-footer content;
- orchestration between `menu`, Git execution and `read-key`.

`menu` continues to own menu rendering, selection state, filesystem browsing and restoration of its terminal session.

`read-key` continues to own normalized one-key terminal input.

`state-path` continues to own managed-state path resolution.

`gitman` must not duplicate the terminal internals of `menu` or `read-key`, and must not reconstruct the managed state tree directly.

## 15. Invariants

```text
GITMAN-01  gitman is a bootstrap-integrated technical m command at bin/sys/gitman
GITMAN-02  explicit directory operands override configured initial directories
GITMAN-03  zero operands use user sys/gitman/conf/repositories and fall back to . when absent or empty
GITMAN-04  repository identity is the physical top-level of a non-bare Git working tree
GITMAN-05  identical working-tree top-levels are deduplicated while distinct linked worktrees remain distinct
GITMAN-06  the bottom footer contains only the current error; one validation batch aggregates all of its failures into that message
GITMAN-07  zero repositories uses filesystem multi-selection and revalidates confirmed selections
GITMAN-08  one or more repositories uses a single-selection repository menu with add/remove/clear actions
GITMAN-09  repository removal and clear are in-memory only
GITMAN-10  the repository action menu returns with Backspace by default
GITMAN-11  first-delivery Git actions are status, log, branch and diff and are read-only
GITMAN-12  a Git action runs only after the selecting menu session has restored the terminal
GITMAN-13  after every Git action gitman waits for one key through read-key before recreating the action menu
GITMAN-14  Git action failure is interactive error state and does not terminate the session by itself
GITMAN-15  gitman has its required sys operational manual topic
```
