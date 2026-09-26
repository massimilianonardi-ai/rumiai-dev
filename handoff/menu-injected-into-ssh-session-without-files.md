# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate a source-streaming mechanism that can inject the existing `m` menu and the required system shell libraries through `rsudo --interactive` and execute the menu on a remote host without copying or creating RumiAI helper files there.

## Current repository revisions

- rumiai-dev: 310d91de37e17784a148449a5742ccafd70ab179
- rumiai-os: a084c418ba8417b7d548bed5f85b2cf464d6df6d
- rumiai-tests: 4bad71ec5b75adfb5e6ee1c98d5256e356bef605

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/MENU.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md

## Fixed task-local choices

- The remote execution model is source injection through the existing interactive `rsudo` stdin path; the design must not require materializing RumiAI helper files or a temporary RumiAI tree on the remote host.
- This task guarantees source streaming only for RumiAI-owned system shell libraries. Arbitrary runtime dot-sourcing remains a separate behavior and is not silently rewritten.

## Working design

The earlier parser/in-place-inline design is no longer the only preferred direction. A `loadsyslib` abstraction is being reconsidered because defining it deliberately as a shell-function boundary can make local and injected execution share the same semantics instead of trying to emulate raw caller-level dot sourcing.

Current semantic model:

- `loadsyslib` and `loadlib` are pure library-loading primitives; library positional parameters are not part of their contract.
- local `loadlib` resolves one library reference below `m_LIB_DIR`, checks that the resulting file is readable, then dot-sources it in the current shell environment;
- `loadsyslib` specializes `loadlib` for `sys/sh`;
- injected execution may replace the `loadlib` backend while preserving the `loadsyslib` caller surface;
- top-level `return`, function definitions, variable changes and ordinary current-shell side effects remain relevant; caller/library `$@` propagation does not.

Injection dependency selection is intentionally explicit. The injector does not discover, parse or compute library dependencies, whether static or dynamic. The caller constructing the stream is responsible for naming every system library that must be embedded, including transitive dependencies and every runtime candidate that may be selected dynamically. A runtime `loadsyslib` request for a library not embedded in the stream fails deterministically rather than falling back to a remote RumiAI filesystem.

The exact library-name identity and preload declaration surface remain open. No shell parser or static dependency-discovery mechanism is required by the injection design.


A further refinement is to layer the loader responsibility:

- `loadsyslib <library> [args...]` specializes system-shell library loading;
- a lower-level `loadlib <library-reference> [args...]` owns resolution/checking and the actual local dot load;
- injected execution may replace only the `loadlib` backend while preserving the `loadsyslib` caller surface.

The current runtime library root is `m_LIB_DIR`. `core.lib.sh` also already defines an unused `validlib()` helper that appears related to library resolution/validation, so implementation must reconcile that existing responsibility instead of duplicating it.

The current `rumiai-os` branch contains the simplified local implementation in `core.lib.sh`:

```sh
loadsyslib()
{
  [ "$#" -ge 1 ] || return 1

  loadlib "sys/sh/$@"
}

loadlib()
{
  [ "$#" -ge 1 ] || return 1

  set -- "$m_LIB_DIR/${1}.lib.sh"
  [ -f "$1" ] && [ -r "$1" ] || return 2

  . "$1"
}
```

This deliberately drops positional-parameter forwarding semantics. The next refinement should make that contract explicit by rejecting extra operands rather than silently ignoring them if exact-one-operand loading is selected.


## Completed

- Activated the previously deferred no-file remote-menu work.
- Rejected the earlier temporary-file/materialized-runtime interpretation of injection.
- Confirmed that current interactive `rsudo` consumes piped stdin into the remote command construction path before opening the interactive SSH PTY.
- Compared a runtime `loadsyslib` abstraction with source-level inline transformation; after further POSIX function-scope analysis, `loadsyslib` became the leading candidate because a deliberate function boundary can align local and injected semantics.
- Defined and then superseded a first parser/in-place-inline proposal after identifying that a function-boundary loader can handle top-level `return` consistently without source inlining.
- Removed automatic static dependency discovery from the injection design: the caller now owns the complete embedded library set, so injection requires no shell parser or dependency closure engine.
- Refined the loader into a `loadsyslib` specialization over a lower-level `loadlib`.
- Reconciled a concurrent `rumiai-os` advance: `core.lib.sh` now implements `loadsyslib`/`loadlib` using an embedded-prefix `"sys/sh/$@"` call and an `eval` that shifts before dot-loading the selected file.
- Verified from POSIX.1-2024 that `.` is not a valid alias name, so portable alias substitution cannot shadow the canonical dot command.

## Current state

No product/runtime code has been modified. The leading working design is now `loadsyslib` with a deliberate function-boundary contract and fully explicit caller-selected library embedding. The injector performs no dependency discovery or automatic closure. The earlier parser/in-place-inline and automatic-static-closure designs are superseded exploration, not current candidates.

## Next action

1. Finalize the exact-one-library operand contract for `loadlib`/`loadsyslib`.
2. Route the current menu dependency closure through `loadsyslib`: `bin/sys/menu` -> `menu`, then `menu.lib.sh` -> `array`, `map`, `term`.
3. Implement the injected `loadlib` backend using only the caller-supplied embedded library set.
4. Connect the generated stream to the existing `rsudo --interactive` stdin injection path and validate the real menu remotely.
5. Promote the settled loader/injection contract, add permanent tests, and align mandatory manuals.

## Blockers / open questions

- Exact library reference/identity accepted by `loadlib`.
- Exact preload declaration surface.
- Final location/ownership of `loadlib` and `loadsyslib`: they currently live in `core.lib.sh`, but the injected backend must not be overwritten when core is loaded.
- Core/library manual completeness remains to be aligned when the loader API is promoted.
