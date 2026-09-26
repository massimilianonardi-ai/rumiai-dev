# osarch command surface cleanup

Status: Complete
Updated: 2026-09-26

## Goal

Remove the obsolete `osarch-update` and `osarch-set` compatibility commands so the current product, canonical contract, operational manuals and permanent tests expose only the canonical `osarch` command with its `update` and `set` subcommands.

## Current repository revisions

```text
rumiai-dev   3092f91d0e43b2d0d76c0a3ad972b1216b55f5ed
rumiai-os    51d0cba5696a94caaf5ae39e2e476a31598a0ae1
rumiai-tests 1341e7790bb0e33f70fab915322ee75020ec9ec3
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- The user explicitly corrected the current contract: `osarch-update` and `osarch-set` are obsolete and are not compatibility commands.
- The canonical public surface is `osarch`, `osarch show`, `osarch update` and `osarch set <osarch>`.

## Completed

- Historical lineage identified: `rumiai-os@2b4e7871365ae2dfc6f9ec071f7d0242e6389271`, authored/committed by GitHub account `massimilianonardi-ai` at 2026-09-26T19:55:17Z, restored the wrappers because the then-current specification/TODO required them.
- Removed `todo/osarch-compatibility-entrypoints.md`.
- Removed the compatibility requirement and invariant from `CURRENT-MODEL.md`.
- Removed `bin/sys/osarch-update` and `bin/sys/osarch-set`.
- Removed `res/sys/manual/osarch-update` and `res/sys/manual/osarch-set`.
- Realigned `res/sys/manual/osarch` and the active manual-documentation handoff.
- Removed compatibility-command assertions from `tests/rumiai-os/osarch/update.test`.
- Final tree inspection confirms the obsolete executable/manual paths are absent and the canonical specification/manual/test no longer require them.
- The remaining `osarch-update-failure` language-resource identity belongs to the current `osarch update` subcommand diagnostic and is not a compatibility command.

## Current state

Only the canonical `osarch` command surface remains.

## Next action

None.

## Blockers / open questions

None.