# Library subsystem subdirectories

Status: Complete
Updated: 2026-09-19 14:50 +02:00

## Goal

Move the RumiAI-owned shell libraries whose leaf names begin with `pkg-` into `lib/sys/sh/pkg/` and those whose leaf names begin with `mk-` into `lib/sys/sh/mk/`, preserving library leaf identities and realigning all current loaders, specifications, operational references and permanent tests.

## Current repository revisions

```text
rumiai-dev   c1e5b1d0e9a210fb7dd992dddf9c780f9072112b
rumiai-os    34671a5a1e9917fa39e3bbbd4b155590202c9b22
rumiai-tests 88b4e48f170da883889c2f418a34e8ad24066e9d
```

The final closure check re-inspected the current product tree and current permanent layout coverage at these revisions.

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
- Canonical library-layout, package, mk and documentation specifications were realigned so physical grouping does not change library/manual identity.
- All 22 `pkg-*.lib.sh` libraries moved to `lib/sys/sh/pkg/`.
- Both `mk-*.lib.sh` libraries moved to `lib/sys/sh/mk/`.
- Product loaders, package repository adapter resolution, mk materialization adapter resolution and the affected operational manual reference were realigned.
- Permanent tests were updated on top of concurrently advancing `rumiai-tests` HEADs without discarding parallel changes.
- `model-2-layout.test` now requires the `pkg/` and `mk/` directories and rejects remaining flat subsystem libraries.
- Package repository adapter tests and core package/mk tests now reference the grouped paths.
- Final product tree inspection found no remaining flat `pkg-*.lib.sh` or `mk-*.lib.sh` library files.
- Diff review and targeted source scans found no stale flat-path references in the changed implementation/test surfaces except the intentional negative glob in the layout test.
- A real runtime test run was not executed for the historical restructuring work unit; no runtime PASS is claimed for that earlier revision.
- Final closure re-inspected the current `rumiai-os` tree and confirmed all current `pkg-*.lib.sh` and `mk-*.lib.sh` libraries remain under `lib/sys/sh/pkg/` and `lib/sys/sh/mk/`, with no remaining flat subsystem libraries.
- Current permanent layout coverage still requires those grouped directories and rejects flat `pkg-*.lib.sh` / `mk-*.lib.sh` paths.
- The user explicitly declared the restructuring task complete and requested that it be closed; no additional runtime-validation phase remains part of this task.

## Current state

The restructuring is complete and current sources remain aligned to the grouped library layout. The user explicitly closed the task on 2026-09-19. Historical runtime validation was not added retroactively and is not claimed.

## Next action

None. Remove this completed handoff from the current tree in the required later forward commit.

## Blockers / open questions

None.
