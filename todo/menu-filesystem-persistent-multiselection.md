# menu-filesystem-persistent-multiselection

## Intent

Evaluate and, if justified, add filesystem multi-selection that survives navigation into child directories and back to parent directory views.

## Why pending

The current menu engine stores marks by provider index within one view and resets them on directory changes. Persistence would require a stable cross-view identity and output-order contract, plus explicit treatment of path/symlink changes. Those semantics are not justified as a low-cost extension of the current generic engine and need a dedicated design work unit before promotion.

## Scope

```text
rumiai-dev    menu contract if promoted
rumiai-os     menu command / menu.lib.sh as justified by the chosen boundary
rumiai-tests  permanent behavioral coverage
```

## Evidence

```text
specifications/rumiai-os/MENU.md
bin/sys/menu
lib/sys/sh/menu.lib.sh
tests/rumiai-os/menu/interactive.test
```
