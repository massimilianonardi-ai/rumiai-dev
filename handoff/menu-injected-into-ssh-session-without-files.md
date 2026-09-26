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

- local mode: `loadsyslib <library> [args...]` resolves the local system library and dot-sources it as the final operation inside the `loadsyslib` function;
- injected mode: the generated stream contains only selected/preloaded system libraries and a runtime dispatcher that executes the selected embedded library inside the same `loadsyslib` function boundary;
- optional caller positional parameters are forwarded explicitly with `"$@"` when a library needs them;
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

The suggested caller pattern `set -- $(loadsyslib <lib> "$@")` is not suitable for preserving caller positional parameters: command substitution executes in a subshell environment, so library side effects such as variable and function definitions are lost, and unquoted command-substitution output cannot losslessly represent arbitrary positional parameters because of field splitting, globbing and empty-argument loss. A general caller-argv propagation mechanism, if ever required, needs a separate explicit contract and should not complicate the ordinary loader path.

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
