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
- Do not introduce a `loadsyslib` runtime abstraction for this task. Existing shell-library imports remain ordinary POSIX dot commands.
- The source transformer recognizes RumiAI system-shell-library imports from shell syntax, not by line-oriented text replacement. Comments, quoted data, here-document bodies and other non-command text must not be mistaken for imports.
- A recognized import is expanded recursively at its original syntactic position. Imports are not hoisted or globally deduplicated because load timing, repetition and surrounding control flow are observable shell semantics.
- This task guarantees source streaming only for RumiAI-owned system shell libraries. Arbitrary runtime dot-sourcing remains a separate behavior and is not silently rewritten.

## Working design

### Proposed parser / transformer contract

The implementation mechanism remains open, but the accepted behavior should be independent from the parser implementation.

#### Input and parsing boundary

- Input is trusted RumiAI POSIX-shell source.
- The complete source unit must be tokenized and parsed as POSIX.1-2024 shell syntax before transformation. Invalid shell syntax is a transformation failure.
- Import recognition operates on parsed simple-command nodes, never on raw substring matching.
- Shell comments, quote contents, here-document bodies, arithmetic text and other non-command source text are not import candidates.
- Nested shell programs such as command substitutions and function bodies are parsed normally, so a real import occurring there is still a candidate.

#### Canonical recognized system-library import

Initial recognition is deliberately narrow. A system-library import is eligible only when the simple command has:

- no assignment prefix;
- command name exactly the literal special built-in `.`;
- exactly one pathname operand;
- no redirections and no extra operands;
- pathname word structurally equivalent to the canonical double-quoted form:

```sh
. "$m_LIB_DIR/sys/sh/<relative-library-path>.lib.sh"
```

The pathname must contain the literal `m_LIB_DIR` parameter expansion followed only by the literal system-shell-library prefix and a statically known controlled relative path. No command substitution, arithmetic expansion, secondary parameter expansion, globbing, `.`, `..` or dynamic pathname component is accepted.

Grouped current library layouts are allowed through the relative path, for example a physical import below `sys/sh/pkg/`; the parser does not invent a new logical library identity.

A dot command that explicitly refers to the RumiAI system-library root but does not satisfy the canonical static form is a hard failure rather than a guessed transformation.

Dot commands unrelated to the RumiAI system-library root are preserved unchanged.

#### Resolution and recursive expansion

- The recognized relative library path is resolved against the local RumiAI system shell-library root.
- Resolution must remain within that root after physical resolution; missing, unreadable or escaping targets fail.
- The imported library is parsed and transformed recursively under the same contract before insertion.
- Every import occurrence is expanded independently. The transformer does not deduplicate repeated imports or move them elsewhere.
- An active expansion-stack cycle is a deterministic failure because there is no finite static inline expansion.

#### Inline replacement semantics

The whole recognized dot simple-command node is replaced at the same syntactic command position by a POSIX brace grouping command containing the recursively transformed library body:

```sh
{
    <transformed library body>
}
```

The generated group must be syntactically terminated correctly for its surrounding grammar. An empty/comment-only library becomes an explicit zero-status group rather than an invalid empty group.

The purpose of brace grouping is to retain execution in the current shell environment and preserve the command status at the original import position. The transformer must not wrap the library in a shell function or subshell and must not hoist it.

Source text outside replaced command spans should remain byte-for-byte unchanged whenever the implementation permits that without weakening correctness.

#### Initial inline-safety failures

The first contract is fail-closed. At minimum transformation fails when an imported source contains:

- a `return` command syntactically outside a shell-function body, because its original target can be the dot-script boundary and plain brace inlining cannot preserve that boundary;
- a direct dependency on source-line identity through POSIX `LINENO`, unless a later contract defines a preservation strategy;
- a cyclic recognized system-library import;
- a recognized RumiAI system-library dot command with assignment prefix, redirection, extra operand, dynamic path or another unsupported form.

`return` inside an ordinary function definition is allowed because the function boundary survives unchanged.

Ordinary current-environment behavior such as function definitions, variable assignments, `set --`, `shift`, `cd`, `umask`, shell-option changes and traps is not rejected merely for being stateful; preserving that state is one reason for inline brace grouping. Additional semantic hazards discovered by differential testing must be added to the fail-closed contract rather than silently approximated.

Alias-dependent parsing and dynamically generated shell control flow remain candidates for explicit safety restrictions before promotion if experiments show that they can distinguish dot execution from inline execution.

#### Output / failure discipline

- Successful output is one deterministic POSIX-shell source stream with every recognized system-library import recursively replaced.
- No partial transformed source should be emitted on failure; validation completes before stdout is committed.
- Successful stdout contains source only. Diagnostics go to stderr and should identify the source file/import chain and failing construct.
- Non-zero status indicates parse, resolution, cycle or inline-safety failure.
- The generated source must itself be reparsed successfully as POSIX shell before it is considered valid output.

### Bundle boundary

The parser resolves explicit system-library dot imports only. It does not infer implicit facilities normally supplied by the `m` bootstrap. A higher-level bundle step may therefore supply explicit root sources/facilities before the transformed command. For the first menu experiment this distinction must be handled deliberately rather than hidden inside import parsing.

## Completed

- Activated the previously deferred no-file remote-menu work.
- Rejected the earlier temporary-file/materialized-runtime interpretation of injection.
- Confirmed that current interactive `rsudo` consumes piped stdin into the remote command construction path before opening the interactive SSH PTY.
- Compared a runtime `loadsyslib` abstraction with source-level inline transformation and selected source-level parsing/inlining for this workstream.
- Defined a first fail-closed parser/transformer contract proposal around parsed canonical POSIX dot imports, recursive in-place brace expansion, cycle detection and explicit rejection of dot-boundary `return`.

## Current state

The architecture direction is fixed. The detailed parser/transformer contract above is working design pending review/promotion; no parser implementation or product/runtime change has been made yet.

## Next action

Review/fix the proposed parser contract, then implement the smallest PoC able to transform the current menu dependency closure and validate the generated source before connecting it to the real `rsudo --interactive` stream.

## Blockers / open questions

- Confirm whether direct `LINENO` use should be a hard inline-safety error or an explicitly documented non-preserved source-location observable.
- Decide whether alias-affecting commands need to be rejected in the first inline-safe subset.
- Parser implementation choice remains open; it must satisfy this contract rather than define it.
