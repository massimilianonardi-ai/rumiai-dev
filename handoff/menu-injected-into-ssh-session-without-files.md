# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate a source-streaming mechanism that can inject the existing `m` menu and the required system shell libraries through `rsudo --interactive` and execute the menu on a remote host without copying or creating RumiAI helper files there.

## Current repository revisions

- rumiai-dev: f1e06b50f99acada4bfb66503fc0ae0e8457cf90
- rumiai-os: 4d55321e42167ec0fe8a6f6a449db2d1442ed3dd
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

Candidate semantic model:

- local mode: `loadsyslib <library> [args...]` can remain a small resolver that dot-sources the resolved local system library as the final operation inside the `loadsyslib` function;
- injected mode may override/redefine `loadsyslib` with an injection-specific implementation backed only by libraries embedded in the stream; the caller surface remains unchanged even though the backend is different;
- optional caller positional parameters are forwarded explicitly with `"$@"` when a library needs them, e.g. `loadsyslib <library> "$@"`;
- top-level `return` naturally terminates the current library load in both modes;
- `set --` and `shift` affect the loader/library positional parameters only and do not mutate the caller's positional parameters after `loadsyslib` returns;
- variable/function definitions and other current-shell effects remain visible because no subshell is introduced by the normal loader call.

This model deliberately changes one property of direct caller-level `.`: caller positional-parameter mutation is not preserved. That difference should be treated as part of the `loadsyslib` contract rather than hidden as an implementation accident.

Injection dependency selection is intentionally explicit. The injector does not discover, parse or compute library dependencies, whether static or dynamic. The caller constructing the stream is responsible for naming every system library that must be embedded, including transitive dependencies and every runtime candidate that may be selected dynamically. A runtime `loadsyslib` request for a library not embedded in the stream fails deterministically rather than falling back to a remote RumiAI filesystem.

Caller positional-parameter mutation is currently an extreme/unobserved case and should not complicate the normal loader path. A pattern such as `loadsyslib <lib> "$@"; set -- $loadsyslib_args` would require `loadsyslib_args` to use an explicitly reversible representation; a plain unquoted expansion is not lossless because field splitting, pathname expansion and empty-argument loss can change the argument vector. If this case ever becomes real, use an explicit shell-quoted/decoded handoff or another dedicated contract rather than silently approximating caller `set --` semantics.

The exact library-name identity and preload declaration surface remain open. No shell parser or static dependency-discovery mechanism is required by the injection design.

A further refinement is to layer the loader responsibility:

- `loadsyslib <library> [args...]` specializes system-shell library loading;
- a lower-level `loadlib <library-reference> [args...]` owns resolution/checking and the actual local dot load;
- injected execution may replace only the `loadlib` backend while preserving the `loadsyslib` caller surface.

When local `loadlib` shifts its library operand and then dot-sources the resolved file, the library executes with the loader's remaining positional parameters. A top-level `set --` changes those loader positional parameters, and after the dot command returns the loader can serialize the resulting argument vector with the existing `quote` primitive before returning. A top-level library `return` returns control to the loader with that status. This behavior was mechanically checked with POSIX `sh`.

The loader should capture the library status immediately after the dot command, serialize any resulting argument vector only when the contract requests it, and then return the preserved load status. Plain unquoted restoration from one string is not lossless; any future caller-positional-parameter propagation must use an explicitly reversible representation.

The current runtime library root is `m_LIB_DIR`. `core.lib.sh` also already defines an unused `validlib()` helper that appears related to library resolution/validation, so implementation must reconcile that existing responsibility instead of duplicating it.

The current `rumiai-os` branch now contains a concrete local implementation candidate in `core.lib.sh`:

```sh
loadsyslib()
{
  loadlib "sys/sh/$@"
}

loadlib()
{
  [ "$#" -ge 1 ] || return 1

  [ -f "$m_LIB_DIR/${1}.lib.sh" ] && [ -r "$m_LIB_DIR/${1}.lib.sh" ] || return 2

  eval 'shift; . "$m_LIB_DIR/'"${1}"'.lib.sh"'
}
```

This implementation is now factual product state but its contract is not yet promoted. Mechanical `sh` validation confirmed that the embedded-prefix `"sys/sh/$@"` form preserves additional arguments, `eval` performs the `shift` before the dot load, and a top-level library `return` propagates its status through `loadlib`. Two open correctness points remain: `loadsyslib` needs an explicit zero-argument guard if invalid invocation must be distinguishable from a missing library, and the `eval` interpolation is acceptable only if the library reference is first constrained to the controlled internal library-reference grammar. File readability alone does not prove that constraint.

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

Define the minimal local/injected `loadsyslib` and explicit preload/bundle contract, then implement the smallest PoC for `menu` using a caller-supplied complete library set.

## Blockers / open questions

- Exact library identity accepted by `loadsyslib`.
- Exact preload declaration surface for dynamically selected libraries.
- Whether any current system library intentionally depends on mutating its caller's positional parameters.
- Exact reversible representation, only if caller positional-parameter mutation ever becomes a real requirement.
- Exact validation grammar for the `loadlib` library reference before interpolation into `eval`.
- Zero-argument status contract for `loadsyslib`.
