# rsudo injection menu

Status: Active
Updated: 2026-09-28

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo`
by streaming the required m-owned shell code and libraries in memory, without
requiring a remote m/RumiAI library tree.

## Current repository revisions

```text
rumiai-dev   86688abee8419dbd099b9c0dde26f01827b96ec7  (pre-checkpoint HEAD)
rumiai-os    e0874d7e09995b28cdd729684a85f0ea99994c77
rumiai-tests 44d2e74fda81e800e0c429a56b6446b5fcda21c5
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/RSUDO.md
specifications/rumiai-os/MENU.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
```

## Fixed task-local choices

- The root `m` bootstrap remains minimal and directly sources only
  `core.lib.sh` as its owned-library chicken/egg exception.
- The user implemented the accepted runtime split at
  `rumiai-os@0ac81dc2c1f3d792b9050782367e26d684306e48`:
  `core.lib.sh` defines the normal filesystem `loadlib` and loads
  `base.lib.sh`; `base.lib.sh` defines `loadsyslib` and contains the common
  runtime formerly held in core.
- Injection does not execute `core.lib.sh`. The generated stream owns an
  in-memory `loadlib`; no particular library identity is hardcoded by the
  generator.
- The caller owns the explicit injected dependency set; no dependency parsing or
  automatic transitive closure is added.
- Zero selected libraries are valid. Every selected library is embedded and
  loaded through the generated `loadlib` in caller-supplied order.
- The `--` separator is optional. Without it, the stream contains only the
  injected loader plus selected library loads and does not modify positional
  parameters. With it, one command source is mandatory and remaining operands
  become that command's positional parameters.
- The menu case continues to select `base array map term menu`, but `base` is
  now ordinary caller-selected data rather than generator policy.
- The generated stream owns its in-memory `loadlib` implementation directly;
  there is no separate `loadlib-inject.lib.sh` backend or second dispatch
  layer.
- Transport remains the existing `rsudo --interactive` source-injection path.

## Completed

- RumiAI-owned system-shell-library consumers were migrated to `loadsyslib`,
  with permanent structural coverage for direct owned-library dot-sourcing.
- `loadlib-inject-stream.lib.sh` generates wrappers for the caller-selected
  libraries and a direct in-memory `loadlib` case dispatch.
- The former double-dispatch `loadlib-inject.lib.sh` backend was removed.
- The earlier physical composed path reached privileged `menu -d /`
  successfully when loader ownership was still in the root bootstrap.
- After loader ownership was restored to core, a physical run reached the menu
  command body but failed at `menu_reset`; revision comparison established
  that embedded core had overwritten the injected loader.
- The user then split the normal loader from the common runtime as described
  above.
- `rumiai-os@a72f26850d421b0746521a6b25021dcbd7e2dc4c`
  first adapted `loadlib_inject_stream` to the split runtime.
- `rumiai-os@4654d858701e84fca0ce3a4fd3210a16f4275c7a`
  generalizes the interface to
  `loadlib_inject_stream [LIB...] [-- COMMAND [ARG...]]`, removes the
  hardcoded/mandatory `base` identity, permits zero selected libraries, loads
  selected libraries in caller order, and supports library-only streams.
- Canonical library-interface contract is realigned to this neutral generator
  semantics while the normal bootstrap remains `core -> base`.

## Current state

The architectural mismatch that caused the observed `menu_reset: not found`
failure remains resolved by the `core -> base` split. The injection generator
is now more general than the menu use case: it has no built-in knowledge of the
normal runtime base, permits zero or more selected libraries, and makes command
execution optional.

The earlier physical composed menu PASS validated the previous
`generated in-memory loadlib -> base -> loadsyslib -> embedded libraries`
composition. The generalized interface at
`rumiai-os@4654d858701e84fca0ce3a4fd3210a16f4275c7a` still requires a fresh
physical rerun before that PASS can be attributed to the new revision.

The new `base.lib.sh` library identity and the changed `core.lib.sh` public
surface require operational-manual follow-up under the active
`rumiai-os-man-documentation` workstream; that documentation backfill does not
block functional injection validation.

## Next action

Run the permanent loader/injection test against the generalized interface, then
physically rerun the menu case using:

```sh
loadlib_inject_stream base array map term menu -- "$m_BIN_SYS_DIR/menu" -d /
```

The previous composed PASS remains historical evidence for the architecture; the
new syntax/library-only behavior still needs current-revision validation.

## Blockers / open questions

No remaining loader-architecture design blocker. Current-revision permanent and
physical validation are pending.
