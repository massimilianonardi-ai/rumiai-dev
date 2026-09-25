# rsudo runtime authentication realignment

## Intent

Realign `lib/sys/sh/rsudo/rsudo.lib.sh` with the current rsudo authentication contract: separate sudo password transport from target stdin/TTY, validate with `sudo -S --prompt='' -v`, and execute targets through `sudo -n`.

## Why pending

The current documentation/test work unit is intentionally limited to canonical documentation, operational manual and permanent tests. The runtime implementation remains unchanged in this unit.

## Scope

- `rumiai-os/lib/sys/sh/rsudo/rsudo.lib.sh`
- corresponding rsudo runtime/manual consistency checks
- `rumiai-tests/tests/rumiai-os/rsudo/` validation against the real updated target

## Evidence

- `specifications/rumiai-os/RSUDO.md`
- `res/sys/manual/rsudo.lib.sh`
- `tests/rumiai-os/rsudo/contract.test`
- `tests/rumiai-os/rsudo/interactive.test`
- current `rsudo.lib.sh` still uses an unrelated `sudo -n true` probe in non-interactive mode and does not force `sudo -n` for the interactive target.
