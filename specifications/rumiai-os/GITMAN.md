# RumiAI OS — gitman

Status: **Current / normative**  
Updated: 2026-09-20

## 1. Scope

`gitman` is the technical `m` command for interactively managing a temporary set of local Git working trees and running explicit Git actions against them.

Canonical executable:

```text
bin/sys/gitman
```

The command is bootstrap-integrated and uses:

```sh
#!/usr/bin/env m
```

The first delivery depends on the existing `menu`, `pager`, `read-key` and `state-path` command surfaces and on an available external `git` executable.

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

The configuration file is optional. Its first-delivery format is one encoded directory pathname per non-empty line.

The encoding is deliberately minimal:

```text
\\n   pathname newline
\\\\   literal backslash
```

Every other character is literal. A backslash before any character other than `n` or backslash is preserved as a literal backslash followed by that character. This keeps the file line-oriented while allowing a pathname containing a newline to round-trip without ambiguity with a pathname containing the literal two-character sequence `\n`.

Blank lines are ignored. No shell parsing, quoting, tilde expansion, variable expansion or comment syntax is applied.

Relative pathnames from both operands and the configuration file are resolved from the invocation working directory.

If the configuration file is absent, or contains no non-empty entries, the initial candidate set is:

```text
.
```

If the configuration pathname exists but cannot be read as a regular file, `gitman` records that as the current error and falls back to `.`.

`gitman` may save the current in-memory repository set to this same configuration file through the explicit repository-menu save action defined below. It does not otherwise rewrite the file automatically.

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
s       save current repositories to configuration
e       edit repositories configuration
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

### Save configuration

`s` saves the current repository set to:

```text
<gitman-conf>/repositories
```

using the line encoding defined in section 3.

The configuration directory is materialized lazily when the save action needs it.

If the configuration file does not exist or has zero bytes, the save proceeds without an overwrite prompt.

If the configuration file already exists and has non-zero content, `gitman` must ask for explicit confirmation before replacing it. The confirmation menu defaults to the non-destructive choice. Cancelling or choosing not to overwrite returns to the repository menu without changing the file.

A successful save replaces the configuration file with the current repository set in repository-menu order and clears the current error. A save failure leaves the interactive repository set unchanged and reports one concise error through the bottom footer.

The save action persists the current in-memory repository set.

### Edit configuration

`e` edits:

```text
<gitman-conf>/repositories
```

through a conventional external text editor.

Editor selection is:

```text
VISUAL, when non-empty
EDITOR, when VISUAL is empty/unset
vi, when both are empty/unset
```

`nano` is not a required or implicit dependency. A user who prefers it selects it through `VISUAL=nano` or `EDITOR=nano`.

The selected environment value is treated as one executable identity/pathname, not as shell syntax. `gitman` does not evaluate editor variables as arbitrary shell command strings.

Before launching the editor, `gitman` ensures the configuration directory exists. An absent configuration file may be created by the editor; `gitman` does not implicitly save the current repository set before editing.

The editor is launched only after the repository-menu invocation has completed and restored normal terminal state.

A non-zero editor exit leaves the current repository set unchanged and records one concise bottom-footer error.

After a successful editor exit, `gitman` asks whether to reset the current repository set and reload the edited configuration. The confirmation menu defaults to the non-destructive choice:

```text
No
Yes
```

No or cancellation preserves the current in-memory repository set.

Yes clears the current set and loads only non-empty entries from the configuration file using the normal configuration decoding, Git working-tree validation, physical normalization and deduplication rules. Validation failures from that one reload are aggregated into the current bottom-footer error.

The explicit post-edit reload does not apply the startup `.` fallback. If the edited configuration is absent, empty, unreadable or contains no valid repositories, the resulting repository set is empty and `gitman` returns to filesystem acquisition; unreadable/invalid configuration contributes the corresponding current error.

## 9. Repository action menu

Selecting a repository with Enter opens a single-selection Git action menu for that working tree.

Backspace is the default explicit return key. Git action menus also own a presentation-mode toggle:

```text
Enter       run the selected leaf action or open the selected submenu
p           toggle output mode: pager ↔ terminal
Backspace   return to the parent menu
Escape      return to the parent menu
```

For the root Git action menu, the parent is the repository menu. For a nested Git action submenu, the parent is the calling action menu.

The current output mode is shown by the Git action menu. The initial mode for every `gitman` invocation is:

```text
pager
```

The selected mode is session state: toggling it applies to subsequent Git actions and remains in effect when returning to the repository list and opening another repository.

The currently delivered Git actions are:

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

The action model is not restricted to read-only Git operations. Mutating actions may be added when their concrete semantics, interaction and validation are explicitly defined.

Leaf action entries show the concrete Git command or command template they execute, for example:

```text
Status: git status --short --branch
Commit: git commit -m <commit-message>
```

The display label is descriptive only. It is never evaluated or parsed as shell code.

### Action composition model

Action menus are defined from pairs of:

```text
<action-id> <display-label>
```

An action identifier dispatches to an explicit shell handler named:

```text
gitman_action_<action-id>
```

Simple handlers delegate to one generic Git runner with a repository and an argument vector. Complex handlers remain ordinary shell functions and may perform additional selection, confirmation or parameter acquisition before invoking Git.

A submenu is an ordinary action handler that invokes the same action-menu selection helper for its own entries and returns to its caller when the submenu exits. The shell call stack is the submenu return context; `gitman` does not introduce a generic menu-stack object or command-definition DSL.

The generic action-menu helper performs one menu selection and returns control to its caller. This keeps nested menus POSIX-safe without relying on non-standard function-local variables.

Git commands are executed from explicit shell argument vectors. Command labels and templates are never passed to `eval`, a shell parser or another command-string interpreter.

Git output presentation is explicit and owned by `gitman`.

### Pager mode

Pager mode is the default. Every supported Git action is executed with Git's global `--paginate` switch so paging is requested even for commands that would not normally page.

For the Git process, `gitman` selects the RumiAI `pager` command through `GIT_PAGER=pager`. The caller's existing `LESS` options are retained and extended so the selected `less` backend:

- enables raw control/color handling with `-R`;
- disables `F`, preventing automatic exit when the output fits on one screen;
- disables `X`, allowing normal terminal initialization/deinitialization and screen restoration.

The effective appended less options are:

```text
-R -+F -+X
```

Pager-mode output therefore remains in the pager until the user exits it. Pager exit is itself the acknowledgement step: `gitman` recreates the Git action menu immediately afterward and does not show the separate `Press any key to continue...` prompt.

### Terminal mode

Terminal mode intentionally leaves Git output in the normal terminal. Every supported action is executed with Git's global `--no-pager` switch.

Before the command, `gitman` prints a concise repository/action header so accumulated output remains attributable. After the command it displays:

```text
Press any key to continue...
```

and waits through `read-key` before recreating the Git action menu.

The two explicit modes replace ad-hoc terminal clearing or insertion of arbitrary blank-line batches. `gitman` does not clear the user's normal terminal merely to separate Git actions.

## 10. Terminal lifecycle around Git actions

A Git command is never executed while the `menu` session that selected it still owns terminal rendering state.

The common sequence begins:

```text
menu selection completes
    ↓
menu restores its terminal session
    ↓
gitman runs the Git command on the normal terminal
```

It then diverges by presentation mode:

```text
pager
    Git → pager → user exits pager → Git action menu

terminal
    Git → "Press any key to continue..." → read-key → Git action menu
```

`gitman` does not implement a second menu-style terminal-mode stack around Git execution. It relies on the existing `menu` terminal restoration contract, on the selected pager for pager-mode terminal presentation, and on `read-key` only for terminal-mode acknowledgement.

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

add/remove/edit-confirmation submenus
    return to the repository menu

root Git action menu
    return to the repository menu

nested Git action submenu
    return to its parent Git action menu
```

## 12. Output and side effects

`gitman` is an interactive terminal command. Menu rendering is owned by `menu`; Git command output is emitted normally after menu terminal state has been restored.

The first delivery does not define a machine-readable stdout result.

The currently delivered `status`, `log`, `branch` and `diff` actions do not modify repository state.

The `gitman` action model itself is not read-only. Any mutating action added to the current action tree must expose its concrete command or command template in the leaf menu and must define its required interaction, side effects, failure handling and proportional permanent tests.

Repository-list persistence remains independent of Git actions: `gitman` changes the configured repository list only when the user explicitly invokes the repository-menu save or edit actions.

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
- initial candidate/configuration loading and configuration line encoding/decoding;
- Git working-tree validation and normalization;
- repository-list management actions, including explicit configuration save and edit/reload;
- action-menu composition from explicit identifiers and display labels;
- convention-based dispatch from action identifiers to explicit `gitman_action_<id>` handlers;
- one generic Git runner for common repository/presentation/error handling;
- error aggregation and bottom-footer content;
- orchestration between `menu`, Git execution, `pager` and `read-key`.

`menu` continues to own menu rendering, selection state, filesystem browsing and restoration of its terminal session.

`pager` continues to own host/backend paging mechanics and caller pager-environment preservation.

`read-key` continues to own normalized one-key terminal input.

`state-path` continues to own managed-state path resolution.

`gitman` must not duplicate the terminal internals of `menu` or `read-key`, and must not reconstruct the managed state tree directly.

## 15. Invariants

```text
GITMAN-01  gitman is a bootstrap-integrated technical m command at bin/sys/gitman
GITMAN-02  explicit directory operands override configured initial directories
GITMAN-03  zero operands use user sys/gitman/conf/repositories and fall back to . when absent or empty
GITMAN-03A configuration stores one encoded pathname per line; \\n represents newline and \\\\ represents backslash
GITMAN-04  repository identity is the physical top-level of a non-bare Git working tree
GITMAN-05  identical working-tree top-levels are deduplicated while distinct linked worktrees remain distinct
GITMAN-06  the bottom footer contains only the current error; one validation batch aggregates all of its failures into that message
GITMAN-07  zero repositories uses filesystem multi-selection and revalidates confirmed selections
GITMAN-08  one or more repositories uses a single-selection repository menu with add/remove/clear/save/edit actions
GITMAN-09  repository removal and clear are in-memory only
GITMAN-09A save explicitly persists the current set and confirms before replacing a non-empty configuration file
GITMAN-09B edit selects VISUAL, then EDITOR, then vi; editor variables are executable identities, not shell fragments
GITMAN-09C editor execution occurs outside menu terminal state; successful edit asks whether to reset/reload and defaults to No
GITMAN-09D explicit post-edit reload loads only configuration entries, without the startup . fallback
GITMAN-10  the repository action menu returns with Backspace by default
GITMAN-11  the currently delivered Git actions are status, log, branch and diff; the action model is not restricted to read-only operations
GITMAN-12  a Git action runs only after the selecting menu session has restored the terminal
GITMAN-13  terminal-mode Git actions wait for one key through read-key; pager-mode actions return after pager exit without a second acknowledgement
GITMAN-14  Git action failure is interactive error state and does not terminate the session by itself
GITMAN-15  gitman has its required sys operational manual topic
GITMAN-16  gitman starts in pager output mode and p toggles pager/terminal presentation for subsequent Git actions
GITMAN-17  pager mode forces Git --paginate through the RumiAI pager and disables less F/X while retaining caller LESS options
GITMAN-18  terminal mode forces Git --no-pager, leaves output accumulated, prints an action header and uses the explicit read-key pause
GITMAN-19  gitman does not clear the normal terminal or inject arbitrary blank-line batches to separate action output
GITMAN-20  leaf action labels show the concrete Git command or command template and are display-only, never executable command strings
GITMAN-21  action menus are composed from action-id/display-label pairs and dispatch to explicit gitman_action_<id> shell handlers
GITMAN-22  simple handlers use one generic Git runner while complex interactions remain ordinary shell handlers
GITMAN-23  nested action menus use ordinary handler calls and the shell call stack; no generic menu-stack state or command DSL is required
GITMAN-24  Git execution uses explicit argument vectors and never evaluates action labels/templates as shell code
```
