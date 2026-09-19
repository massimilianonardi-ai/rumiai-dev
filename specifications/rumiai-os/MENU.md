# RumiAI OS — Terminal menu

Status: **Current / normative**  
Updated: 2026-09-19

## 1. Scope

This specification defines the current reusable terminal-menu capability of the technical `m` layer:

```text
bin/sys/menu
lib/sys/sh/menu.lib.sh
```

`menu` is the public command surface. `menu.lib.sh` owns reusable menu-engine behavior and a pluggable provider contract. Terminal/TTY mechanics remain delegated to `term.lib.sh`.

The command supports two input modes:

```text
explicit command-line items
directory-backed filesystem browsing
```

The two modes share navigation, action-key handling, multi-selection, rendering and result semantics through `menu.lib.sh`.

## 2. Entrypoint and runtime

`menu` belongs to the technical `m` layer and depends on `m` runtime facilities and RumiAI-owned libraries. Its executable is:

```text
bin/sys/menu
```

and uses:

```sh
#!/usr/bin/env m
```

`menu.lib.sh` is a non-executable shell library under:

```text
lib/sys/sh/menu.lib.sh
```

## 3. Command interface

The current invocation forms are:

```text
menu [-H <header>] [-F <footer>] [-B <bottom-footer>]
     [-K <action-key> ...] [-S <toggle-key>] [--] <item> ...

menu [-H <header>] [-F <footer>] [-B <bottom-footer>]
     -K <action-key> [-K <action-key> ...] [-S <toggle-key>]
     [-n] [-m] [-c] -d <directory>
```

The first form is list mode. The second is filesystem mode.

`-H`, `-F` and `-B` configure the normal header, immediate footer and bottom-anchored footer respectively.

`-K` is repeatable and adds an action key. In list mode Enter remains the built-in confirmation action and `-K` adds alternate actions. In filesystem mode at least one `-K` is required because Enter is reserved for browsing.

`-S` changes the multi-selection toggle key. The default is Space.

The first delivery does not add `-h`, `--help` or another command-local help surface; operational reference is provided by `manual` under `DOCUMENTATION-MODEL.md`.

## 4. List mode

Each command-line item has one of these forms:

```text
<label>
<value>@:=<label>
```

Without `@:=`, the value and displayed label are identical. With `@:=`, the text before the first delimiter is the returned value and the text after the first delimiter is the displayed label.

Values are opaque shell strings except that POSIX shell variables cannot represent NUL. Values may contain whitespace, wildcard characters and newlines. A rendered label occupies one terminal row and therefore must not contain a newline.

List mode requires at least one item.

## 5. Filesystem mode

`-d <directory>` selects filesystem mode. The starting directory is resolved physically to an absolute directory path before interaction begins.

The current absolute directory is included in the menu header. If `-H` is supplied, the user header is shown first and the current directory follows on the next line.

The displayed entries are constructed from the current directory with these defaults:

```text
hidden entries are shown
directories sort before non-directories
each group uses ascending bytewise lexical order
.. is available when navigation to the parent is allowed
```

Filesystem options are:

```text
-n  hide hidden entries
-m  mix directories and non-directories into one lexical ordering
-c  confine browsing to the physical subtree rooted at the starting directory
```

Confinement applies to navigation, including directory symlinks: Enter must not move the browser to a physically resolved directory outside the starting subtree. At the confinement root, the parent entry is absent.

Displayed filesystem labels are single-line safe representations of entry names. Returned values preserve the selected absolute path rather than the display sanitization.

Enter on a directory resolves and enters that directory. Enter on a non-directory does not finish the menu. A configured action key returns the current/marked path values.

Changing directory is a provider reset and therefore clears the multi-selection marks of the previous directory view.

## 6. Navigation and keys

The engine owns these keys:

```text
Escape
Up / Down
PageUp / PageDown
Home / End
Enter
```

Escape cancels. Navigation keys move the current row. Enter is delivered to the provider as an event so the provider can implement confirmation or browsing semantics.

The multi-selection toggle key is also reserved. Its default is Space. `-S` may replace it with another configurable key, after which the new key is reserved and Space becomes available as an action key if explicitly configured.

Action/toggle keys may use one text key or supported named terminal keys. The command recognizes `space` as the symbolic name for Space and accepts `arrow_left` / `arrow_right` as input aliases for the canonical `left` / `right` key names.

A key cannot simultaneously be a navigation key, multi-selection toggle and action key. Duplicate action keys are invalid.

## 7. Multi-selection semantics

Space, or the key selected by `-S`, toggles a mark on the current item without finishing the menu.

When an action finishes the menu:

```text
no marked items
    return the current item

one or more marked items
    return all marked items and do not implicitly add the current unmarked item
```

Marked values are returned in provider order, not in the chronological order in which they were marked.

The reusable engine stores marks by provider index for the current provider view:

```text
reload
    preserves marks whose indices remain valid and prunes indices beyond the new count

reset
    clears all marks and resets the cursor to index 0
```

A dynamic provider that changes item identity/order incompatibly with index preservation must use `reset` rather than `reload`.

## 8. Command result format

The terminal UI is written to the selected TTY. Standard output is reserved for a successful machine-readable result.

A successful result is one shell-safe serialized argument vector produced with the existing `quote` primitive:

```text
<action-key> <value-1> ... <value-n>
```

The first argument is the canonical action key. The remaining arguments are returned values. Space is emitted as the symbolic key name `space`; Enter is emitted as `enter`.

The intended POSIX-shell consumption pattern is:

```sh
result=$(menu ...)
status=$?
[ "$status" -eq 0 ] || exit "$status"
eval "set -- $result"
key=$1
shift
# "$@" now contains the returned values.
```

Direct unquoted word splitting such as `set -- $(menu ...)` is not the result contract because it cannot preserve arbitrary shell-string values.

The same serialized vector can be passed to the existing array API, for example after successful execution:

```sh
eval "array result set $result"
```

## 9. Exit status

The command and library use:

```text
0  successful action result
1  user/provider cancellation
2  invalid invocation, invalid API usage, provider failure or menu/terminal failure
```

Signal-derived statuses from an interrupted menu session are propagated rather than converted into one of the semantic statuses above.

Failure diagnostics are written to standard error. Cancellation produces no successful result on standard output.

## 10. `menu.lib.sh` public interface

The library exposes these public functions:

```text
menu_reset
menu_key_clear
menu_key_add <key>
menu_toggle_key_set <key>
menu_run_provider <provider-function>
menu_array_provider
```

`menu_reset` restores default configuration, clears configured action keys and resets public result state.

`menu_key_add` adds one validated action key. `menu_key_clear` clears the action-key set. `menu_toggle_key_set` validates and changes the reserved multi-selection key.

`menu_run_provider` executes one menu session against the provider. On success it sets:

```text
menu_result_key
menu_result_value
menu_result_values
```

`menu_result_values` is an `array.lib.sh` array containing every returned value in provider order. `menu_result_value` is the first element as a single-result convenience. The library does not expose the command's serialized stdout format as its public result representation.

`menu_array_provider` adapts two parallel `array.lib.sh` arrays named by:

```text
menu_array_values
menu_array_labels
```

The arrays must have equal size.

## 11. Provider contract

A provider function is called as:

```text
<provider> count
<provider> item <index>
<provider> event <key> <index> <value> <label>
```

For `count`, it sets `menu_provider_count` to a positive integer.

For `item`, it sets:

```text
menu_provider_value
menu_provider_label
```

For `event`, the engine initializes:

```text
menu_provider_action=return
```

and the provider may leave it unchanged or set one of:

```text
return
reload
reset
ignore
cancel
```

These actions have the selection/cursor semantics defined above.

Provider failures are menu failures; providers do not print successful command results themselves.

## 12. Layering

`menu.lib.sh` owns reusable menu policy:

```text
provider dispatch
cursor/navigation policy
multi-selection state
configurable action keys
layout/rendering of menu text
terminal-session lifecycle coordination
structured result state
```

`term.lib.sh` owns terminal/TTY/terminfo mechanics. `menu.lib.sh` must not reimplement `stty`, `tput`, raw-byte decoding or terminal capability discovery.

Filesystem enumeration, path confinement and directory-navigation policy belong to the `menu` command's filesystem provider rather than to the generic menu engine.

## 13. Invariants

```text
MENU-01  menu is a bootstrap-integrated technical m command at bin/sys/menu
MENU-02  menu supports explicit list input and directory-backed browsing
MENU-03  Space is the default multi-selection toggle and the configured toggle key is reserved
MENU-04  marked values are returned in provider order; with no marks the current value is returned
MENU-05  command stdout is a quote-serialized argument vector: action key followed by values
MENU-06  filesystem Enter navigates directories and does not finish on non-directories
MENU-07  filesystem confinement prevents physical navigation outside the starting subtree
MENU-08  changing filesystem directory resets marks for the previous provider view
MENU-09  menu.lib.sh exposes structured key + array result state rather than command serialization
MENU-10  provider reload preserves/prunes valid index marks; provider reset clears marks and cursor state
MENU-11  menu.lib.sh delegates terminal mechanics to term.lib.sh
MENU-12  internal menu.lib.sh functions follow the leading-underscore visibility contract
MENU-13  menu and menu.lib.sh each have their required sys operational manual topic
```
