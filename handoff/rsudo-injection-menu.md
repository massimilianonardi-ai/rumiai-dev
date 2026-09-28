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
- Injection does not execute `core.lib.sh`. The generated stream installs its
  in-memory `loadlib` and loads the same common `base.lib.sh` through it.
- The caller owns the explicit injected dependency set; no dependency parsing or
  automatic transitive closure is added.
- `base` is an explicit mandatory injected reference.
- The menu stream therefore uses the explicit set
  `base array map term menu`.
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
  adapted `loadlib_inject_stream` to require `base`, install only the
  in-memory `loadlib`, and load `sys/sh/base` through it.
- `rumiai-os@e0874d7e09995b28cdd729684a85f0ea99994c77`
  aligned the injection operational manual with base-owned common runtime
  facilities.
- `rumiai-tests@44d2e74fda81e800e0c429a56b6446b5fcda21c5`
  realigned permanent loader/injection coverage to the `core -> base` split
  and explicit injected `base` requirement.
- Canonical bootstrap and library-interface contracts have been promoted to the
  accepted `core -> base` model.

## Current state

The architectural mismatch that caused the observed `menu_reset: not found`
failure is removed from the generated-stream design. Normal and injected
execution now converge on the same `base.lib.sh` runtime while using different
`loadlib` implementations:

```text
normal:
    m -> core/filesystem loadlib -> base -> loadsyslib -> libraries

injected:
    generated in-memory loadlib -> base -> loadsyslib -> embedded libraries
```

The new product/test revisions have not yet received a valid physical composed
`rsudo + menu` rerun. Two attempted reruns on 2026-09-28 did not exercise the
generated stream because the local shell did not have `loadlib_inject_stream`
loaded. The attempted preload used `loadsyslib loadlib_inject_stream`, but the
library reference is `loadlib-inject-stream` (hyphenated). That preload therefore
failed and the subsequent pipeline sent only the askpass password record; rsudo
entered an ordinary privileged remote shell. No injection behavior can be
inferred from those two attempts, and no physical PASS is claimed yet.

The new `base.lib.sh` library identity and the changed `core.lib.sh` public
surface require operational-manual follow-up under the active
`rumiai-os-man-documentation` workstream; that documentation backfill does not
block functional injection validation.

## Next action

Load the generator library locally with
`loadsyslib "loadlib-inject-stream"`, verify that
`command -v loadlib_inject_stream` succeeds, then run the permanent
loader/injection test against the current product checkout and rerun the
physical command with the explicit set:

```sh
loadlib_inject_stream "$m_BIN_SYS_DIR/menu" base array map term menu -- -d /
```

through the existing `rsudo --interactive --askpass` pipeline.

## Blockers / open questions

No remaining loader-architecture design blocker. Physical validation of the
current composed path is pending.
