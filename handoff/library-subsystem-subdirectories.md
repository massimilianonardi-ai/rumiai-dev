# Library subsystem subdirectories

Status: Active
Updated: 2026-09-18

## Goal

Move the RumiAI-owned shell libraries whose leaf names begin with `pkg-` into `lib/sys/sh/pkg/` and those whose leaf names begin with `mk-` into `lib/sys/sh/mk/`, preserving library leaf identities and realigning all current loaders, specifications, operational references and permanent tests.

## Current repository revisions

```text
rumiai-dev   011859f7a24183182e3593d77ab29d546c93deab
rumiai-os    384677c6acc9424fd4ce4eca7aa9aed104bded5d
rumiai-tests 36f873c127e17cb42fdbbf077e3c9f32b014a737
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
- Canonical library-layout, package, mk and documentation specifications were realigned so physical grouping does not change library/manual identity.
- All 22 `pkg-*.lib.sh` libraries moved to `lib/sys/sh/pkg/`.
- Both `mk-*.lib.sh` libraries moved to `lib/sys/sh/mk/`.
- Product loaders, package repository adapter resolution, mk materialization adapter resolution and the affected operational manual reference were realigned.
- Permanent tests were updated on top of concurrently advancing `rumiai-tests` HEADs without discarding parallel changes.
- `model-2-layout.test` now requires the `pkg/` and `mk/` directories and rejects remaining flat subsystem libraries.
- Package repository adapter tests and core package/mk tests now reference the grouped paths.
- Final product tree inspection found no remaining flat `pkg-*.lib.sh` or `mk-*.lib.sh` library files.
- Diff review and targeted source scans found no stale flat-path references in the changed implementation/test surfaces except the intentional negative glob in the layout test.
- A real runtime test run could not be executed from this chat environment because DNS resolution for `github.com` is unavailable; no runtime PASS is claimed.

## Current state

Implementation, canonical specifications, operational reference and permanent test sources are aligned to the grouped library layout. Git history remained forward-only and concurrent `rumiai-tests` changes were preserved.

Runtime validation of the updated permanent tests remains pending in an executable environment with access to the exact repository revisions above.

## Next action

Run the proportional package/mk/layout test selections against `rumiai-os@384677c6acc9424fd4ce4eca7aa9aed104bded5d` and `rumiai-tests@36f873c127e17cb42fdbbf077e3c9f32b014a737` in a real validation environment.

## Blockers / open questions

- This chat environment cannot resolve `github.com`, so it cannot materialize and execute the exact current repository revisions for runtime validation.
