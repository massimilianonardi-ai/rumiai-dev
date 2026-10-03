# extract OLD command cleanup

## Intent

Remove or otherwise explicitly resolve the superseded executable `bin/sys/extract_OLD` so the current command tree contains only current command identities.

## Why pending

The file was discovered during the pkg eliminated-function consistency gate. It is outside the authorized pkg-library cleanup, but it is executable and therefore conflicts with the current-tree/manual-completeness model unless it is intentionally retained under a current contract.

## Scope

```text
rumiai-os     bin/sys/extract_OLD and any current references/manual impact
rumiai-tests  affected command/manual structural coverage
rumiai-dev    documentation-task state if required
```

## Evidence

```text
bin/sys/extract_OLD
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
handoff/rumiai-os-man-documentation.md
```
