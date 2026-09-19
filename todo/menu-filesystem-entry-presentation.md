# menu-filesystem-entry-presentation

## Intent

Evaluate richer filesystem entry presentation, starting with an explicit type indicator and potentially optional portable metadata such as execution state, permissions and timestamps.

## Why pending

A simple directory/non-directory marker is inexpensive, but the browser can encounter symlinks and other filesystem object types, so a D/F-only taxonomy may be misleading. Richer permission/date metadata also needs a POSIX-portable retrieval/display contract and a proportional terminal-width/performance model before implementation is justified.

## Scope

```text
rumiai-dev    menu/filesystem presentation contract if promoted
rumiai-os     filesystem provider/rendered labels and any portability abstraction
rumiai-tests  permanent cross-host presentation coverage
```

## Evidence

```text
specifications/rumiai-os/MENU.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
bin/sys/menu
tests/rumiai-os/menu/interactive.test
```
