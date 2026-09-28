# rsudo injection menu

Status: Active
Updated: 2026-09-28

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo` by streaming the required m-owned shell code and libraries in memory, without requiring a remote RumiAI/m installation.

## Current repository revisions

```text
rumiai-dev   ab9381fbcdc1db09b997b91fd1346464d0a14891
rumiai-os    a72f26850d421b0746521a6b25021dcbd7e2dc4c
rumiai-tests 1c19cb7148aceed4796b7ddcc8fb30192093a0c4
```

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

- Explicit user architecture correction: the root `m` bootstrap is deliberately minimal. Its only approved helper functions are `readpathce` for the root-resolution chicken/egg boundary and `export_readonly` for fundamental variable definition. The bootstrap responsibilities are limited to root resolution, fundamental system-variable definition, loading `core.lib.sh`, and execution. No additional function or responsibility may be added to `m` without explicit user approval.
- The accepted split implemented by the user at `rumiai-os@0ac81dc2c1f3d792b9050782367e26d684306e48` keeps the root bootstrap unchanged: it directly sources `core.lib.sh`; core defines the normal filesystem `loadlib` and loads `base.lib.sh`; base defines `loadsyslib` and contains the former core runtime.
- Use the existing explicit `loadlib_inject_stream` generator; dependency discovery is not added.
- The generated stream owns its in-memory `loadlib` implementation directly. There is no separate `loadlib-inject.lib.sh` backend or `_loadlib_inject_dispatch` layer.
- The menu stream explicitly embeds `base`, `array`, `map`, `term`, and `menu`.
- Transport the generated source through the current `rsudo --interactive` source-injection path.
- The immediate physical target is a Linux host with sshd already present; the end-to-end target remains the privileged remote filesystem browser.

## Completed

- RumiAI-owned system-shell-library consumers have been migrated to `loadsyslib`; permanent coverage scans for remaining direct m-owned system-library dot-sourcing.
- `loadlib-inject-stream.lib.sh` generates an explicit embedded-library stream and is covered by the existing permanent behavioral loader test.
- The former `loadlib-inject.lib.sh` backend and its operational manual were removed as redundant. The stream generator now emits `loadlib()` directly, with its `case` dispatching to the generated embedded-library wrappers.
- `LIBRARY-INTERFACES.md` and the `loadlib-inject-stream.lib.sh` operational manual were realigned to the direct generated-`loadlib` model.
- A local POSIX-sh harness validated the modified generator: library syntax, generated-stream syntax, direct embedded loading, argument preservation, execution with an unavailable remote `m_LIB_DIR`, and status 2 for an omitted library all passed.
- The existing permanent `library-loading.test` requires no implementation-specific change because it already protects the observable injection contract rather than the removed backend structure. It was inspected but could not be executed in the assistant environment because the GitHub checkout is unavailable there and outbound GitHub network resolution is blocked.
- `rsudo --interactive` consumes non-TTY stdin as source injection and is covered by permanent source-only and source-plus-command tests.
- Current `menu` dependency chain needed for injection has been verified from implementation: `menu -> array, map, term`, with `core` supplied explicitly by the stream generator contract.
- Physical composed execution reached the injected privileged `menu -d /` successfully before the loader simplification, using a pipeline whose first record is consumed by `--askpass` and whose remaining records are the generated source stream.
- Physical Linux rerun on 2026-09-28 after restoring core loader ownership reached the injected command body but failed at `menu_reset` with `sh: menu_reset: not found`; rsudo transport, askpass and privileged source execution all completed far enough to execute `bin/sys/menu`.
- The source dump observed after leaving the menu was caused by the final rsudo command log. Current rsudo keeps a concise info-level end log and emits the full effective command only at trace level.

## Current state

The user implemented the accepted split at `rumiai-os@0ac81dc2c1f3d792b9050782367e26d684306e48`: `core.lib.sh` now contains the normal filesystem `loadlib` plus `loadlib "sys/sh/base"`, while `base.lib.sh` contains `loadsyslib` and the former core runtime. The assistant then adapted `loadlib-inject-stream.lib.sh` at `rumiai-os@a72f26850d421b0746521a6b25021dcbd7e2dc4c`: `base` replaces `core` as the mandatory explicit runtime reference, the generated stream installs only its in-memory `loadlib`, and it loads `base` through that loader so base establishes `loadsyslib` and the common runtime.

A more fundamental architecture regression has been identified and takes precedence over the injection-local diagnosis.

The bootstrap/core regression has been repaired: the root `m` bootstrap directly loads `core.lib.sh`, and `loadlib`/`loadsyslib` are owned by core. The temporary package-default initialization that had then been placed at the end of core has now also been removed completely in `rumiai-os@5373b280f7da9fe159666012f6de25da47cb0ccd`. No current bootstrap/core path loads `pkg/pkg-provider` for global defaults or calls `pkg_provider_global_environment_apply`.

This exposes the next injection-specific design issue clearly. The current stream generator installs an injected `loadlib`/`loadsyslib` before loading embedded core. With loader ownership restored, embedded `core.lib.sh` now defines the normal filesystem-backed loader itself and therefore overwrites that injected loader. The previous generated-stream ordering is therefore no longer compatible with the restored core architecture.

The 2026-09-28 physical failure confirms this mechanism directly rather than indicating a missing menu dependency. `menu_reset` is defined by `menu.lib.sh`. After injected core runs, its normal filesystem-backed `loadlib`/`loadsyslib` replace the generated in-memory versions; the command body's initial `loadsyslib "menu"` therefore cannot load the embedded menu library on the remote host. `bin/sys/menu` does not stop at that load result and subsequently reaches `menu_reset`, producing the observed command-not-found failure. The explicit set `core array map term menu` remains the expected source-level dependency set.

Historical comparison requested by the user clarifies causality. The last physically successful composed menu state recorded `rumiai-os@c1aa711645b39f36850d35abc02c31d8db916120`; at that revision the architectural regression was already present: `m` defined `loadlib`/`loadsyslib` and `core.lib.sh` did not. The later `rumiai-os@ec9b122c529c5fced35f736acfcf1f5b93f87a72` simplification removed `loadlib-inject.lib.sh` from the generated stream and replaced `loadlib -> _loadlib_inject_dispatch -> wrapper` with direct generated `loadlib -> wrapper` case dispatch. Under the then-current architecture this was behaviorally equivalent because loading embedded core did not redefine either loader. The handoff at that time explicitly recorded that physical rerun after the simplification was still pending. Therefore there is no revision-specific evidence that `ec9b122c` itself broke the composed path. The currently observed break is mechanically explained by the later restoration of loader ownership to `core.lib.sh`: both the old double-dispatch backend and the simplified direct dispatcher would be overwritten when embedded core is executed in the current ordering.

This is now a subsystem-foundational injection decision and must not be solved by silently transforming or bypassing core. The stable injection contract remains explicit caller-selected embedding with no dependency discovery and no remote m library tree; the exact loader/core coexistence mechanism is again working design.

Permanent test structure is realigned through `rumiai-tests@1c19cb7148aceed4796b7ddcc8fb30192093a0c4`: it requires the root bootstrap function surface to contain only `readpathce` and `export_readonly`, requires exactly one direct bootstrap source of `core.lib.sh`, rejects package-default initialization from both `m` and `core.lib.sh`, and treats only that exact core source as the allowed direct-owned-library exception. Existing injection behavior assertions remain unchanged so the loader/core incompatibility is not hidden by weakening tests.

The assistant environment cannot execute the real checkout because outbound GitHub DNS is unavailable. No runtime PASS is claimed for these revisions.

## Next action

Rerun the permanent loader/injection test and the physical composed rsudo menu using the new explicit set `base array map term menu`. The generator has been adapted to install its in-memory `loadlib` first and load the common base through it; no injected `core.lib.sh` execution remains.

## Working design alternatives under evaluation

No loader architecture change is authorized yet. The current decision space includes:

- injection-local core bootstrap: embedded core is executed directly first, then the stream installs an in-memory `loadlib` (while core's `loadsyslib` can remain unchanged). This requires the top-level execution of `core.lib.sh` to remain self-contained and not load other libraries while core itself is being sourced;
- core mode switch through an explicit streaming/injection variable, with either two loader implementations or suppression of the filesystem loader. This keeps stream ordering simple but couples foundational core behavior to an injection-specific mode;
- ambient predefinition detection such as `command -v loadlib`, allowing a preinstalled loader to survive core loading. This avoids an injection-specific variable but makes core initialization depend on ambient shell command/function namespace and is therefore risky for deterministic bootstrap behavior;
- loader as a bootstrap-level primitive. One form would put loader functions back directly in `m`; a cleaner form would put the normal loader in a dedicated library loaded before core, allowing normal and injected loader implementations to be peers. Either form changes the foundational bootstrap/core boundary and requires explicit architectural approval;
- stable core-owned public `loadlib` plus a replaceable loader backend. Core always owns the public API, while filesystem-backed and injected-memory behavior are backend strategies. This deliberately reintroduces one dispatch layer but avoids two competing public `loadlib` definitions. It still requires deciding whether core's own top-level sourcing must remain dependency-free or whether backend selection exists before core runs.

Evaluation should distinguish the smallest repair from the longer-term architectural model. Criteria include bootstrap minimality, deterministic shell initialization, whether core may have top-level library dependencies, injection coupling, public API ownership, extensibility beyond streaming, and failure/isolation behavior.

## Leading working design — split bootstrap loader from runtime base

The user proposed a refinement that preserves the external bootstrap/shell contract while separating the loader primitive from the former core runtime.

Conceptually:

```text
normal runtime

m
  -> direct source core.lib.sh
       -> define filesystem loadlib
       -> loadlib common-base
            -> define loadsyslib
            -> establish the former core runtime
  -> execution / shell / integrated command
```

```text
injected runtime

generated injected loadlib
  -> loadlib common-base from embedded source
       -> define the same loadsyslib
       -> establish the same former core runtime
  -> embedded command libraries
  -> command body
```

The eventual common-base library name is intentionally unresolved.

This design keeps the root bootstrap unchanged: it still directly sources only `core.lib.sh`. Shell and integrated-command behavior remain transparent because the common base is fully established before the source of `core.lib.sh` returns. Components therefore do not need to load two libraries.

The important semantic split is:

- `core.lib.sh` becomes the minimum normal-runtime loader/bootstrap library: define the filesystem `loadlib` primitive and immediately load the common base;
- the common base contains the former core runtime and can define `loadsyslib` as the system-library specialization built on whichever `loadlib` is already installed;
- the injected environment does not execute the normal filesystem-loader core; it installs its injected `loadlib` first and then loads the same common base;
- because a loader already exists before the common base is entered in both modes, the common base is not required to remain forever dependency-free: any deliberate top-level library loads can use the active loader implementation;
- no streaming flag, ambient `command -v loadlib` detection, dual public loader definition, or backend-dispatch layer is required.

This also clarifies that the current injection requirement to embed/load `core` would need to be revisited. Under this model the shared runtime payload is the common base, while `core.lib.sh` is the normal filesystem-loader bootstrap adapter. Whether the generator includes the common base implicitly as infrastructure or requires it explicitly in the selected set remains a working-design choice.

One compatibility point requires explicit protection: `core.lib.sh` should become bootstrap-initialization surface rather than an ordinary re-loadable library in injected execution, because reloading the normal core there would intentionally replace the injected `loadlib` with the filesystem implementation.

## Blockers / open questions

The remaining blocker is injection design, not bootstrap ownership: core now correctly owns the local loader, while the current injected-loader ordering assumes that loading core will not replace it. Package-default bootstrap integration is no longer part of this active task and is tracked separately in `todo/pkg-default-bootstrap-integration.md`.
