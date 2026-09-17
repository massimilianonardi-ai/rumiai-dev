# RumiAI Development Rules

Status: **Current / canonical**  
Updated: 2026-09-17

This document contains project-wide rules that apply across RumiAI subsystems. Subsystem details belong in current specifications; historical rationale belongs in Git history.

## 1. Authority and retrieval

`rumiai-dev` is authoritative for current development rules, workflow and semantic specifications.

Before every RumiAI task, follow the read order in `README.md`. Current repository sources and explicit current user corrections prevail over model memory, conversation summaries, inference, old proposals, superseded documents and implementation convenience.

A historical commit is not current authority merely because it contains a formerly accepted decision.

## 2. Documentation model

The current branch must describe the current project directly.

Therefore:

- one current contract has one canonical location;
- current specifications must state the rule that applies now;
- a new decision must not become a permanent patch that readers have to apply mentally to an older specification;
- when a contract changes, update the canonical current specification in the same work unit whenever possible;
- superseded documents, completed plans, closed handoffs, chats and exploratory analysis are removed from the current tree once their durable content has been propagated;
- Git history preserves those documents and their rationale forward-only;
- historical evidence is never rewritten or relabelled as evidence for another revision.

`specifications/README.md` is the canonical topic-to-specification router.

`specifications/` contains only **promoted current contracts**. A design statement may enter a current specification only when it is sufficiently settled that current implementation and future work must treat it as binding now.

The following are not specification content merely because they may later become contractual:

```text
candidate choices
provisional working assumptions
alternatives still being compared
decisions deliberately postponed inside an active task
open questions
evaluation criteria for an unresolved choice
future-work or decision backlogs
```

During an active task, that material belongs in the task handoff as **working design state** when it is needed for safe resumption. Experiments used to resolve an open design question belong in `rumiai-dev-PoCs` and are referenced from the handoff. Concrete work postponed outside the active task belongs under `todo/`.

A specification may state that it deliberately does **not constrain** a dimension only when that absence of constraint is itself a stable current boundary that future implementation must respect. Such a statement must express the boundary directly; it must not turn the specification into a list of candidates, comparisons or decisions still to be made.

When working design becomes a durable subsystem contract, promote the resulting rule into the canonical current specification and remove the duplicated provisional material from the handoff. When an active task ends, any remaining working-design item must be promoted, converted into deferred work when still relevant, or discarded; it must not survive by being mislabeled as a specification.

`handoff/` contains only active task state. A handoff never overrides `RULES.md`, `CONSISTENCY-GATE.md` or current specifications.

## 3. Repository roles

```text
rumiai-dev
    rules, workflow and current semantic specifications

rumiai-os
    product/runtime implementation

rumiai-tests
    permanent tests, runner and revision-specific validation evidence

rumiai-dev-PoCs
    experiments for questions that are not yet settled

pkg-catalog
    package definitions/catalog data used by the m package subsystem
```

Historical/reference repositories are design input only unless a current RumiAI source explicitly adopts a contract from them.

## 4. Git

Git history is forward-only.

Do not rewrite history or force-push unless the user explicitly requests it for a concrete reason. Normal corrections are new commits.

Before writing any involved repository, verify its current remote HEAD. If the user or another actor has advanced a repository during the task, do not overwrite or discard those changes; re-read the new state and reconcile forward.

## 5. Authorization to modify product repositories

Product/runtime modifications require explicit user authorization for the applicable phase or task. Authorization may cover an entire clearly defined task; it need not be repeated file by file.

Documentation, PoCs and permanent tests follow their normal repository roles, but no successful PoC, test or assistant recommendation silently authorizes an unrelated product change.

## 6. Current architecture boundary

The current architecture is defined by `specifications/rumiai-os/CURRENT-MODEL.md`.

The repository `rumiai-os` contains two semantic layers:

```text
m
    low-level general-purpose technical substrate

RumiAI
    branded upper product layer built on m
```

`m` must not semantically depend on RumiAI.

`pkg` and `pkg-catalog` belong to `m`.

The current technical runtime entrypoint is `$m_ROOT/m`. The branded entrypoints are `$m_ROOT/rumiai-os` and `$m_ROOT/rumiai-os-sh`.

Do not infer new layers, namespaces or components from conversational shorthand.

## 7. Platform contract

RumiAI OS develops against **POSIX**, not Linux, macOS, Windows or one distribution.

The current baseline is:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

Host-specific behavior is allowed only behind an explicit abstraction/adapter when POSIX is insufficient or a real host divergence requires it. Host-specific details must not contaminate the general contract.

A baseline change requires a concrete RumiAI requirement, verification of the relevant normative specification, and material host validation where the behavior is host-dependent.

Windows does not redefine RumiAI architecture; RumiAI requires a POSIX-compatible environment.

## 8. Shell and interpreter contract

Shell code and shell command bodies must remain POSIX `sh` unless an explicitly approved contract establishes another runtime.

The technical root bootstrap `$m_ROOT/m` uses exactly:

```sh
#!/bin/sh
```

A command integrated with `m` or using `m`/RumiAI runtime facilities uses:

```sh
#!/usr/bin/env m
```

A shell utility may use `#!/bin/sh` as a directly executable standalone utility only when its independence from `m` is intentional, durable and explicitly documented by a current specification.

A standalone utility must not depend on `m_*`, `log`, `lang`, `m_COMMAND_BIN`, `m`-sourced libraries or other bootstrap facilities.

Do not accidentally depend on Bash syntax or unapproved GNU/vendor extensions.

## 9. Defensive shell quoting

In RumiAI `sh` code, quote variable expansions, substitutions and value operands with double quotes whenever doing so preserves the intended shell semantics.

Protection must derive from code shape, not assumptions about current data.

The pattern positions of `case` branches are syntax and need not be quoted. `fatal`/`log` call style may omit cosmetic quotes only where argument structure remains unambiguous; expansions still require quoting whenever needed to prevent word splitting or pathname expansion.

## 10. Naming and libraries

Public executable names describe function, not implementation language; do not add `.sh`, `.py`, `.js` and similar suffixes merely to reveal the interpreter.

RumiAI-owned environment variables use the `m_*` namespace. This does **not** establish an `m_*` namespace for functions, commands, files, APIs or components.

Current unnamespaced shell interfaces include `log` and `lang`. The previous name `i18n` is superseded.

Internal libraries are ownership- and runtime-qualified:

```text
lib/sys/<runtime>/<name>.lib.<runtime>
lib/ai/<runtime>/<name>.lib.<runtime>
```

Shell libraries such as `lib/sys/sh/*.lib.sh` are sourced files: no executable bit and no shebang.

Before introducing a helper, alias, namespace, primitive or abstraction, search the current subsystem for an existing responsibility with the same semantic contract.

## 11. Command syntax and `--`

Commands that accept options should follow the POSIX Utility Syntax Guidelines unless an explicit contract requires otherwise.

For every tool that actually supports `--` as an option terminator, use `--` when passing one or more data operands. Do not invent `--` for tools that do not support it, and do not add a trailing `--` when no operand follows.

The rule follows the real contract of the invoked tool, POSIX or otherwise.

### Operational manual completeness

Every RumiAI-owned directly executable command identity defined by the command-entrypoint model must have a corresponding operational manual topic under the owner-specific `manual` resource tree defined by `DOCUMENTATION-MODEL.md`.

This requirement applies regardless of whether the command is intended primarily for end users, developers, maintenance or internal technical workflows. Internal sourced libraries are not commands and are outside this requirement. Package-owned external commands are also outside this RumiAI-owned command requirement.

Creating a command and creating its manual topic are one development obligation and belong to the same work unit. Renaming or removing a command must realign its manual topic in the same work unit.

Every modification of a command requires an explicit manual-consistency check. If purpose, invocation syntax, operands, options, output, exit statuses, environment/files, side effects or other documented observable behavior changes, update the affected manual topic in the same work unit. A purely internal implementation change requires no manual edit when the existing topic remains fully accurate, but the check is still required.

A command work unit is not complete while its implementation and operational manual disagree.

## 12. Paths and relocatability

RumiAI OS must be relocatable.

Do not hardcode personal paths, Homebrew paths, mount points, checkout locations or other host-local spellings into product code or permanent tests.

Derive managed paths from the appropriate semantic roots. Consumers must not duplicate a deeper physical layout when a current resolver owns that knowledge.

Default behavior is portable; host/local override is explicit.

## 13. Development workspace

`rumiai-os/src/` is the local development anchor. Its operational contents are not product content and are Git-ignored.

Typical independent nested repositories include:

```text
rumiai-os/src/rumiai-tests/
rumiai-os/src/rumiai-dev-PoCs/
```

They are not submodules and not runtime dependencies.

`DEVELOPMENT.md` and `setup-dev.sh` define the workspace bootstrap.

## 14. Testing

`TESTING.md` is canonical for permanent tests, development runs, GitHub Actions usage, validation scopes and evidence.

`RUNNER.md` defines the runner. `PHYSICAL-TESTING.md` defines physical validation. `TEST-PATTERNS.md` contains current authoring patterns.

Behavioral tests must exercise the real target or a complete isolated replica through the real execution path for the property claimed. A mock, fixture or replaced component proves only the boundary it actually exercises.

## 15. Software/tool selection

If the user specifies only an outcome, choose the most appropriate deterministic and verifiable tool/interface.

If the user explicitly specifies a software product, interface or execution mode, that choice becomes part of the task intent and must be respected unless impossible or unsafe.

GUI/computer-use is one execution modality, not the universal interaction model.

## 16. Development workflow

The normal sequence is:

```text
retrieve current authority
→ extract applicable invariants
→ keep unresolved active design in the task handoff
→ experiment only if a question is genuinely open
→ promote only settled contract into current specifications
→ implement in the proper repository
→ create/realign operational manual content for every affected command
→ add/realign proportional permanent tests
→ execute real development tests
→ use broader/hosted testing when it adds evidence
→ perform physical validation last when required
→ reread the diff and scan for stale mechanisms/terminology
```

Do not consider a RumiAI task complete until the preflight and final consistency check required by `CONSISTENCY-GATE.md` have both been performed.
