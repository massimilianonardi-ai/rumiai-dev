# Menu injected into SSH session without files

## Intent

Define and validate a way to inject and run the existing `m` menu in an SSH session without copying or creating helper files on the remote host.

## Why pending

The capability has been explicitly identified as desired future work, but its transport and execution mechanism are intentionally deferred.

## Scope

- existing menu entrypoint and library surfaces in `rumiai-os`;
- SSH session/command transport needed to execute the menu without remote file materialization;
- canonical documentation and permanent tests required by the resulting design.

## Evidence

- Current menu surfaces include `rumiai-os/bin/sys/menu` and `rumiai-os/lib/sys/sh/menu.lib.sh`.
- The current menu contract is routed through `specifications/rumiai-os/MENU.md`.
