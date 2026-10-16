# Legacy JavaScript dynamic loader cleanup

## Intent

Retire or retain the superseded standalone dynamic loader files and their
associated operational manual/tests only after verifying current consumers.
The user explicitly owns this file-cleanup work.

## Why pending

The user chose to perform legacy-file cleanup personally after the
separately compiled `m.mod.DynamicLoader` was validated and documented.
The current repository still contains the older
`lib/sys/js/dynamic-loader.lib.js` and legacy loader directory, and
separate browser tests/manuals still reference them.

## Scope

- `rumiai-os`: legacy loader source files, its owner-local manual and
  any affected CI/test references; do not change the new
  `core/m/mod/DynamicLoader.js` by implication.
- `rumiai-tests`: only tests specific to the retired loader after their
  current responsibility is verified.
- Inspect actual consumers before removals; preserve unrelated
  `jsc` compiler behavior and the new `m.mod.DynamicLoader` contract.

## Evidence

- `specifications/rumiai-os/DYNAMIC-LOADER.md` defines the distinct
  current `m.mod.DynamicLoader` interface.
- `rumiai-os/lib/sys/js/dynamic-loader.lib.js`, its manual under
  `res/sys/manual/dynamic-loader.lib.js` and
  `lib/sys/js/dynamic-loader/` are currently present.
- `rumiai-tests/tests/rumiai-os/jsc/` retains regression coverage for
  the legacy loader.
