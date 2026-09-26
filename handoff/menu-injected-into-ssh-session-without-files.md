# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate a source-streaming mechanism that can inject the existing `m` menu and the required system shell libraries through `rsudo --interactive` and execute the menu on a remote host without copying or creating RumiAI helper files there.

## Current repository revisions

- rumiai-dev: b9515af1086aae2eb3d562eea7f8e5238b3ae97a
- rumiai-os: 7e78fc9842d1fd6acd6f83584c3b0a931f8027e7
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

Dynamic loading remains the central bundle problem. Proposed bundle policy:

- statically identifiable `loadsyslib` targets are included automatically with their recursively discoverable static dependencies;
- dynamically computed library names are not guessed;
- the injection caller may explicitly request additional libraries to preload into the stream for dynamic selection;
- each explicitly preloaded library also pulls in its statically discoverable dependencies;
- a runtime request for a library not embedded in the stream fails deterministically rather than falling back to a remote RumiAI filesystem.

Caller positional-parameter mutation is currently an extreme/unobserved case and should not complicate the normal loader path. A pattern such as `loadsyslib <lib> "$@"; set -- $loadsyslib_args` would require `loadsyslib_args` to use an explicitly reversible representation; a plain unquoted expansion is not lossless because field splitting, pathname expansion and empty-argument loss can change the argument vector. If this case ever becomes real, use an explicit shell-quoted/decoded handoff or another dedicated contract rather than silently approximating caller `set --` semantics.

The exact library-name identity, preload syntax and static-dependency discovery mechanism remain open. Static discovery still needs syntax-aware parsing or another mechanism that cannot confuse comments/data with real `loadsyslib` invocations.

## Completed

- Activated the previously deferred no-file remote-menu work.
- Rejected the earlier temporary-file/materialized-runtime interpretation of injection.
- Confirmed that current interactive `rsudo` consumes piped stdin into the remote command construction path before opening the interactive SSH PTY.
- Compared a runtime `loadsyslib` abstraction with source-level inline transformation; after further POSIX function-scope analysis, `loadsyslib` has been reopened as the leading candidate because a deliberate function boundary can align local and injected semantics.
- Defined and then superseded a first parser/in-place-inline proposal after identifying that a function-boundary loader can handle top-level `return` consistently without source inlining.
- Verified from POSIX.1-2024 that `.` is not a valid alias name, so portable alias substitution cannot shadow the canonical dot command.

## Current state

No product/runtime code has been modified. The leading working design is now `loadsyslib` with a deliberate function-boundary contract plus static dependency closure and explicit preload declarations for dynamic library choices. The earlier parser/in-place-inline design is retained only as superseded exploration inside task history, not as the current candidate.

## Next action

Audit current system libraries for caller-positional-parameter dependence and dynamic source patterns, then define the minimal `loadsyslib` and preload/bundle contract before implementing a PoC for `menu`.

## Blockers / open questions

- Exact library identity accepted by `loadsyslib`.
- Exact preload declaration surface for dynamically selected libraries.
- Whether any current system library intentionally depends on mutating its caller's positional parameters.
- Static dependency discovery mechanism for `loadsyslib` calls.
- Exact reversible representation, only if caller positional-parameter mutation ever becomes a real requirement.
