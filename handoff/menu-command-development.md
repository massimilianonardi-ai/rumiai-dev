# menu command development

Status: Active
Updated: 2026-09-19

## Goal

Implement the public `menu` command on top of `menu.lib.sh`, covering command-line lists and filesystem browsing, subtree confinement, configurable action keys and configurable multi-selection, while evolving `menu.lib.sh` only through reusable capabilities.

## Current repository revisions

```text
rumiai-dev   81103bb979fc2df9853fd62083a8e5da3738fd5e
rumiai-os    7e2a4bfe519ac3ee87dab9c820a50bbcdfa2303f
rumiai-tests 3809d5854a5c9349786de463a5a803d39e29613c
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/RESOURCE-MODEL.md`

## Fixed task-local choices

- `menu` is a bootstrap-integrated technical `m` command.
- The command accepts either an explicit command-line list or a starting directory.
- Filesystem mode can confine browsing to the starting directory subtree.
- Multi-selection is toggled by Space by default; the toggle key is configurable and reserved while configured.
- An action returns marked values in provider order; when nothing is marked, it returns the current item.
- Filesystem mode reserves Enter for directory navigation; configured action keys return selected absolute paths.
- Command stdout is a shell-safe argument vector serialized with `quote`: action key first, followed by selected values.
- `menu.lib.sh` keeps result state structurally as key plus a collection rather than making serialized stdout its library API.
- Reusable behavior belongs in `menu.lib.sh`; filesystem-specific command policy must not contaminate the generic engine.

## Completed

- Mandatory preflight completed against the revisions above.
- Existing `menu.lib.sh`, terminal/array/map dependencies, command conventions and testing patterns inspected.
- Existing mismatch identified: `menu.lib.sh` private helpers use nonconforming `menu__...` names and the mandatory `menu.lib.sh` operational manual is absent. This task will realign the touched library.

## Current state

No product or test implementation changes have been written yet.

## Next action

Implement and validate the canonical menu contract, product code/manuals and proportional permanent tests.

## Blockers / open questions

None.
