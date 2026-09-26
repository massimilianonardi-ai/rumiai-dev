# osarch command surface cleanup

Status: Active
Updated: 2026-09-26

## Goal

Remove the obsolete `osarch-update` and `osarch-set` compatibility commands so the current product, canonical contract, operational manuals and permanent tests expose only the canonical `osarch` command with its `update` and `set` subcommands.

## Current repository revisions

```text
rumiai-dev   17fea0e7f6912afd12823b8fcd409ac5fec4ac13
rumiai-os    b6f33c542155d58b770e5afabd460d116936318d
rumiai-tests 9302b65fc9e386390695bb8161fe135b04e2155b
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- The user explicitly corrected the current contract: `osarch-update` and `osarch-set` are obsolete and must not remain as compatibility commands.
- The canonical public surface is `osarch`, `osarch show`, `osarch update` and `osarch set <osarch>`.

## Completed

- Fresh preflight completed.
- Historical lineage identified: commit `2b4e7871365ae2dfc6f9ec071f7d0242e6389271`, timestamp 2026-09-26T19:55:17Z, restored the obsolete wrappers because the then-current specification and TODO incorrectly required them.

## Current state

No product/test/specification cleanup has yet been committed.

## Next action

Remove the obsolete commands and their manuals, remove compatibility assertions from the osarch permanent test, realign canonical/current documentation, then run the proportional consistency checks.

## Blockers / open questions

- None.
