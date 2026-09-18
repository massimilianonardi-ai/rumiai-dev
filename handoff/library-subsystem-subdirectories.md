# Library subsystem subdirectories

Status: Active
Updated: 2026-09-18

## Goal

Move the RumiAI-owned shell libraries whose leaf names begin with `pkg-` into `lib/sys/sh/pkg/` and those whose leaf names begin with `mk-` into `lib/sys/sh/mk/`, preserving library leaf identities and realigning all current loaders, specifications, operational references and permanent tests.

## Current repository revisions

```text
rumiai-dev   0d1474259f299caa26b6f2445b7fa704d11d5bb9
rumiai-os    f45ece69192fe3d08ef77361a4c2be6c131d19c6
rumiai-tests 074aec26a590f2989e71f2060c319f191442c1f6
```

Fresh remote HEAD retrieval remains mandatory before later writes.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/MK.md`
- `specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md`

## Fixed task-local choices

- The new physical grouping directories are `lib/sys/sh/pkg/` and `lib/sys/sh/mk/`.
- Library leaf names remain unchanged, so manual topic identities remain the existing `<library-name>.lib.sh` leaves under `res/sys/manual/`.
- No compatibility copies remain at the previous flat paths.

## Completed

- Mandatory preflight completed.
- Current product tree and relevant specifications were inspected.
- Existing flat-path consumers in product code and permanent tests were identified.
- Current `rumiai-tests` HEAD was refreshed after concurrent advancement.

## Current state

No product/specification/test implementation change has been made yet. The current product still uses flat `lib/sys/sh/pkg-*.lib.sh` and `lib/sys/sh/mk-*.lib.sh` paths.

## Next action

Realign the canonical specifications, then move/update the product libraries and finally realign permanent tests and execute proportional validation.

## Blockers / open questions

None.
