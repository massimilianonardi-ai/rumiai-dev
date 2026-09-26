# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate a source-streaming mechanism that can inject the existing `m` menu and the required system shell libraries through `rsudo --interactive` and execute the menu on a remote host without copying or creating RumiAI helper files there.

## Current repository revisions

- rumiai-dev: 5ff784395afdca7d89ae3a0fde27d34e1213c432
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
- Do not introduce a `loadsyslib` runtime abstraction for this task. Existing shell-library imports remain ordinary POSIX dot commands.
- The source transformer recognizes RumiAI system-shell-library imports from shell syntax, not by line-oriented text replacement. Comments, quoted data, here-document bodies and other non-command text must not be mistaken for imports.
- A recognized import is expanded recursively at its original syntactic position. Imports are not hoisted or globally deduplicated because load timing, repetition and surrounding control flow are observable shell semantics.
- This task guarantees source streaming only for RumiAI-owned system shell libraries. Arbitrary runtime dot-sourcing remains a separate behavior and is not silently rewritten.

## Working design

The parser/transformer contract is being defined before implementation.

Candidate baseline for a recognized import:

```sh
. "$m_LIB_DIR/sys/sh/<relative-library-path>.lib.sh"
```

Recognition should operate on a parsed POSIX-shell simple-command node and validate the pathname word structurally. The initial contract should be deliberately narrow and fail closed for RumiAI-system-library source forms that cannot be proven safe to transform.

The intended replacement unit is a POSIX brace grouping command at the same syntactic command position, because `{ ...; }` executes in the current shell environment and returns the compound-list status. This preserves ordinary variable/function/state effects and surrounding AND-OR/list/pipeline placement better than preloading or function-based library simulation.

Known semantic hazards that must be handled explicitly before promotion:

- `return` whose target is the dot-script boundary cannot be preserved by plain inline grouping; imported sources with such control flow should initially be rejected rather than rewritten heuristically.
- source-position observables such as POSIX `LINENO` cannot in general retain their original file/line identity after bundling; the contract must either reject reliance on them in transformed sources or define that diagnostic/source-position identity is not preserved.
- cyclic static system-library imports have no finite recursive inline expansion and should fail deterministically.
- assignment prefixes, redirections or non-canonical operands on the dot command need an explicit support decision; the initial contract should not infer equivalence.
- dynamic RumiAI library paths must not be guessed. A source operation that references the RumiAI library root but is not statically resolvable should fail rather than leave a hidden remote RumiAI-file dependency.
- ordinary runtime dot-sourcing that is unrelated to the RumiAI system-library root should remain untouched.

The transformer should preserve source text outside replaced import command spans whenever practical instead of reformatting the full input.

## Completed

- Activated the previously deferred no-file remote-menu work.
- Rejected the earlier temporary-file/materialized-runtime interpretation of injection.
- Confirmed that current interactive `rsudo` consumes piped stdin into the remote command construction path before opening the interactive SSH PTY.
- Compared a runtime `loadsyslib` abstraction with source-level inline transformation and selected source-level parsing/inlining for this workstream.
- Identified the dot-script `return` boundary and source-line identity as the main semantic differences that the parser contract must address explicitly.

## Current state

The architecture direction is fixed, but the parser acceptance/rejection contract is still working design and has not yet been promoted to a canonical subsystem specification. No product/runtime code has been modified for this task.

## Next action

Finalize the parser/transformer contract precisely enough to implement a small proof of concept against the current menu dependency closure, then validate the generated stream through the existing `rsudo --interactive` path.

## Blockers / open questions

- Exact syntactic acceptance rules for the canonical system-library dot command.
- Exact inline-safety rejection rules, especially dot-boundary `return` and source-location-sensitive behavior.
- Whether the first PoC parser is implemented with an existing shell parser or a purpose-built parser remains open; implementation choice must not weaken the parsing contract.
