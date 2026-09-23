# RumiAI Development Consistency Gate

Status: **Current / canonical**  
Updated: 2026-09-17

This document defines the mandatory consistency process for RumiAI work. Its purpose is to prevent drift between current rules, current specifications, implementation, tests, operational documentation, deferred work and active task state.

## 1. Mandatory preflight

Before analysing, proposing or modifying an established RumiAI subsystem:

1. verify the current remote HEAD of every involved repository;
2. read `README.md`;
3. read current `RULES.md`;
4. read this `CONSISTENCY-GATE.md`;
5. use `specifications/README.md` to retrieve the smallest complete set of current specifications relevant to the task;
6. read the active handoff under `handoff/` when the task has one;
7. inspect the current implementation and permanent tests when behavior, API shape or mechanical coverage matters.

This is an execution precondition, not a recommendation.

Conversation memory, summaries and historical commits do not satisfy the preflight when current repository sources can answer the question.

For any task that creates, renames, removes or modifies a `m`- or RumiAI-owned directly executable command, `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md` and `specifications/rumiai-os/DOCUMENTATION-MODEL.md` are part of the smallest complete source set, and the affected operational manual topic must be inspected together with the command.

For any task that creates, renames, removes or modifies a `m`- or RumiAI-owned library or one of its functions, `specifications/rumiai-os/FILESYSTEM-NAMING.md`, `specifications/rumiai-os/LIBRARY-INTERFACES.md` and `specifications/rumiai-os/DOCUMENTATION-MODEL.md` are part of the smallest complete source set, and the affected library manual topic must be inspected together with the library.

`todo/` is not part of the mandatory preflight for unrelated tasks. Read `todo/README.md` and the relevant TODO item when choosing deferred work, checking whether a newly discovered deferred issue is already known, activating a TODO or maintaining the pending-work inventory.

## 2. Extract the applicable invariants

Before writing, identify the fixed constraints that apply to the task, including as relevant:

```text
architecture/layer boundaries
canonical terminology
existing primitives
public interfaces
command/manual consistency
library public/internal visibility and manual consistency
filesystem layout
state/resource/package ownership
POSIX/platform contract
shell/interpreter rules
serialization/data formats
exit statuses and error classes
permissions/security boundary
transaction/concurrency semantics
testing and evidence requirements
Git workflow
active task-local decisions
explicit current user corrections
```

Reason inside those constraints before choosing an implementation.

## 3. Current source, not historical patch composition

The current branch is expected to describe the current project directly.

A current rule must not require this reading strategy:

```text
old specification
+ later decision
+ later correction
+ later handoff
= current meaning
```

Instead, when a contract changes, update the canonical current specification and remove superseded documents from the current tree once their durable content is propagated.

Historical rationale remains in Git history. It must not compete with current authority during normal retrieval.

If a current specification and current implementation disagree, do not silently choose one. Determine whether implementation is pending realignment or the specification itself is intentionally being changed, then make that state explicit before proceeding.

### Specification promotion gate

Before adding a design statement to `specifications/`, determine whether it is already a **promoted current contract**.

A statement passes the gate only when all applicable conditions are true:

```text
it is settled enough to constrain current implementation and future work now
it expresses what must remain true, not what is merely being considered
it is not a candidate, provisional assumption, comparison, open question or postponed decision
it is not a backlog of future design work
its canonical ownership belongs to the specification being changed
```

If the statement does not pass, do not put it in a specification merely to preserve memory. During an active task, persist it in the task handoff under working design state. If experimental evidence is required, use `rumiai-dev-PoCs` and reference the experiment from the handoff. If the work is intentionally deferred outside the active task, use `todo/`.

A stable statement that a specification deliberately leaves a dimension unconstrained may pass the gate when that **absence of constraint** is itself part of the current contract and materially prevents false inference. Express only that boundary. Do not attach candidate lists, evaluation matrices, preferred directions or the plan for making the later decision.

## 4. No silent design changes

If a proposed implementation contradicts a fixed invariant, stop treating the difference as an implementation detail.

A deliberate contract change must be made explicit and propagated to the canonical current specification in the same work unit whenever possible.

Do not reopen an already-settled choice merely because another design is locally convenient.

## 5. Existing responsibility first

Before introducing a helper, alias, primitive, namespace, component, suffix, format or abstraction, search the current subsystem for an existing responsibility with the same semantic role.

Reuse the existing primitive when its contract already matches.

Do not create a second spelling for the same responsibility merely to make local code convenient.

## 6. Conversational shorthand has no product authority

Temporary wording, abbreviations and labels used in conversation are not automatically product terminology.

Do not promote them into commands, APIs, namespaces, components, filesystem names, configuration keys or architecture concepts unless the user or a current authoritative source explicitly establishes them.

## 7. Correction propagation

When a fixed invariant changes, inspect all materially dependent current surfaces:

```text
canonical specification
implementation
operational manual/reference
permanent tests
reference descriptors/examples
active handoff
relevant deferred-work TODO
validation scope/configuration
user-facing current documentation
```

Update every surface that belongs to the same authorized work unit. When another repository or validation phase cannot be changed yet, record the pending realignment explicitly in the appropriate current surface.

If the remaining work is concrete but intentionally deferred and is not already active, represent it through the minimal `todo/` lifecycle rather than burying it in a specification, historical note or conversation memory.

If a design choice remains unresolved inside the active task, keep it in the handoff working-design state rather than turning the unresolved choice into a pseudo-contract.

Do not rewrite historical commits or historical validation evidence.

## 8. Command/library manual consistency gate

Every `m`- or RumiAI-owned directly executable command identity is coupled to an owner-local operational manual topic under `DOCUMENTATION-MODEL.md`.

For any command change:

```text
create / rename / remove
    realign the command manual in the same work unit

modify
    manual-consistency check is mandatory
```

When documented observable behavior changes, update the manual in the same work unit. A purely internal command implementation change requires no textual manual edit when the existing page remains fully accurate.

Every `m`- or RumiAI-owned library identity is likewise coupled to exactly one owner-local manual topic, and every defined library function is classified public or internal under `LIBRARY-INTERFACES.md`.

For any library change:

```text
create / rename / remove
    realign the library manual in the same work unit

modify
    verify public/internal function naming
    perform a library/manual consistency check

add/change/remove public function
    update the library manual in the same work unit
```

Public function names must not begin with `_`; internal function names must begin with `_`. Internal functions must not be presented as callable API in the library manual. A purely internal library implementation change requires no manual text edit when the public page remains fully accurate.

Command-to-manual and library-to-manual topic presence MUST be protected mechanically by permanent tests. These structural checks prove required topic presence/identity, not prose/API semantic correctness. If the applicable permanent coverage has not yet been implemented or realigned, the corresponding documentation-completeness work remains open rather than being reported complete.

## 9. Testing authenticity

Mechanical checks must preserve the authenticity rules in `TESTING.md`.

For a behavioral claim, execute the real target or a complete isolated replica through the real entrypoint/components that provide the claimed behavior.

Mocks, fixtures, stubs and synthetic input are permitted only at boundaries where simulation is explicitly appropriate. They validate only the property actually exercised and cannot be credited as proof of a replaced composed path.

Automation environments, including GitHub Actions and AI-provided Linux VMs, are execution infrastructure; they are not alternative implementations of the target or test contract.

## 10. Proportional validation

During development, use the fastest real environment that can materially exercise the property. Broaden to clean/multi-host automation when useful. Reach physical validation only when preceding evidence makes success the expected outcome.

A recurring pattern of defects first discovered in physical validation is evidence that the earlier model is insufficient and must be improved.

A GitHub-hosted runner, headless GUI session or AI-provided VM is not physical validation of a stable reference host it did not actually exercise.

GitHub required status checks are not part of the current RumiAI workflow and must not be introduced without a new explicit decision.

## 11. Post-change diff review

After every modification:

1. reread the resulting diff;
2. re-evaluate it against `RULES.md` and the applicable current specifications;
3. when a specification was changed, reclassify every added design statement through the specification promotion gate;
4. when a `m`- or RumiAI-owned command was created, renamed, removed or modified, perform the command/manual consistency gate;
5. when a `m`- or RumiAI-owned library or function was created, renamed, removed or modified, verify library visibility naming and perform the library/manual consistency gate;
6. scan the touched subsystem for superseded terminology/mechanisms;
7. verify no unrelated user/repository changes were overwritten;
8. run only tests proportional to the change under `TESTING.md`;
9. state physical-validation status accurately and revision-specifically;
10. verify Git history remains forward-only;
11. if concrete unfinished work was discovered but intentionally deferred, ensure it is either already represented by an active task or captured once under `todo/`;
12. when the task has an active handoff, determine whether the resulting state is a meaningful checkpoint and synchronize it before the final response when required.

## 12. Documentation consistency checks

When documentation is touched, additionally verify:

- no current document claims a superseded contract;
- no old decision is required to interpret the current specification;
- topic routing in `README.md` / `specifications/README.md` still reaches the authoritative source directly;
- no completed handoff remains in the current tree as competing authority;
- no historical evidence is presented as current behavior;
- cross-references point to paths that exist in the current tree;
- repeated normative text is minimized;
- current specifications contain only promoted contract and do not accumulate provisional design;
- operational manual content remains revision-coupled to the implementation/API it describes;
- mandatory command manual topics are not omitted because a command is technical/internal;
- mandatory library manual topics are present for every `m`- or RumiAI-owned library identity;
- library manuals expose the complete public function API and do not expose underscore-prefixed internal functions as callable API;
- public/internal library function naming follows `LIBRARY-INTERFACES.md`;
- TODO files contain only deferred-work planning state and do not become substitute specifications or task handoffs;
- the same work is not represented simultaneously by a current TODO and an active handoff.

## 13. Deferred work and active handoffs

`todo/README.md` defines the lifecycle for concrete known work that is intentionally deferred and not yet active. `handoff/README.md` defines the lifecycle for active resumable tasks.

A TODO may record only the minimal future intent, why the work remains pending, its scope and pointers to evidence. It must not accumulate active task progress, detailed design decisions or execution state.

When a TODO is intentionally activated, ownership of current task state moves from `todo/` to `handoff/`:

```text
delete todo/<topic>.md
create handoff/<task>.md
```

Perform both changes in the same authorized work unit and, when practical, the same commit. Do not retain duplicate current TODO and handoff representations for the same work.

An active handoff exists only to preserve task continuity across chats/sessions. `handoff/README.md` defines its lifecycle and structure.

Working design in a handoff is persistent task memory, not authority. It must be promoted, deferred or discarded before the task handoff is removed.

For a substantial, parallel or multi-chat task, create the handoff after preflight and before the first material task change when the need is already known.

When a response materially advances an active handoff task, required synchronization must complete **before** the user-visible final response.

When the task closes:

1. propagate durable content to canonical current sources;
2. resolve remaining working design;
3. capture concrete out-of-scope deferred work as minimal TODO items when applicable;
4. complete the normal final consistency gate;
5. write and commit a final handoff snapshot with `Status: Complete`;
6. remove the handoff from the current tree in a later forward commit.

Git history is the archive.

## 14. Completion checklist

A RumiAI task is ready to report as complete only when every applicable item is true:

```text
[ ] current remote HEADs were verified before writes
[ ] README.md was used to route retrieval
[ ] current RULES.md and CONSISTENCY-GATE.md were read
[ ] relevant current specifications and active handoff were read
[ ] relevant implementation/tests were inspected
[ ] applicable invariants were identified before writing
[ ] no existing responsibility was duplicated under a new name
[ ] no contract was changed silently
[ ] every statement added to a current specification passed the specification promotion gate
[ ] every affected command has its required manual and passed a manual-consistency check
[ ] every affected library has its required manual and passed a manual-consistency check
[ ] every affected library function follows the public/internal leading-underscore contract
[ ] each library manual exposes all public functions and no internal function as callable API
[ ] mandatory command/library manual structural coverage is present or the corresponding completeness work remains explicitly open
[ ] tests/evidence claim no more than what was actually exercised
[ ] resulting diff was reread and stale terminology/mechanisms were scanned
[ ] cross-references/current routing remain valid
[ ] user/concurrent repository changes were preserved
[ ] proportional tests were run or correctly classified as unnecessary
[ ] concrete intentionally deferred work is represented once under todo/ when applicable
[ ] no current TODO duplicates an active handoff for the same work
[ ] active handoff was synchronized for every material checkpoint before the final response
[ ] physical-validation status is stated accurately
[ ] Git changes are forward-only
```

Failure of an applicable item means the work is not complete.
