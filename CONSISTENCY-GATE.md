# RumiAI Development Consistency Gate

Status: **Current / canonical**  
Updated: 2026-09-17

This document defines the mandatory consistency process for RumiAI work. Its purpose is to prevent drift between current rules, current specifications, implementation, tests, deferred work and active task state.

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

`todo/` is not part of the mandatory preflight for unrelated tasks. Read `todo/README.md` and the relevant TODO item when choosing deferred work, checking whether a newly discovered deferred issue is already known, activating a TODO or maintaining the pending-work inventory.

## 2. Extract the applicable invariants

Before writing, identify the fixed constraints that apply to the task, including as relevant:

```text
architecture/layer boundaries
canonical terminology
existing primitives
public interfaces
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
permanent tests
reference descriptors/examples
active handoff
relevant deferred-work TODO
validation scope/configuration
user-facing current documentation
```

Update every surface that belongs to the same authorized work unit. When another repository or validation phase cannot be changed yet, record the pending realignment explicitly in the appropriate current surface.

If the remaining work is concrete but intentionally deferred and is not already active, represent it through the minimal `todo/` lifecycle rather than burying it in a specification, historical note or conversation memory.

Do not rewrite historical commits or historical validation evidence.

## 8. Testing authenticity

Mechanical checks must preserve the authenticity rules in `TESTING.md`.

For a behavioral claim, execute the real target or a complete isolated replica through the real entrypoint/components that provide the claimed behavior.

Mocks, fixtures, stubs and synthetic input are permitted only at boundaries where simulation is explicitly appropriate. They validate only the property actually exercised and cannot be credited as proof of a replaced composed path.

Automation environments, including GitHub Actions and AI-provided Linux VMs, are execution infrastructure; they are not alternative implementations of the target or test contract.

## 9. Proportional validation

During development, use the fastest real environment that can materially exercise the property. Broaden to clean/multi-host automation when useful. Reach physical validation only when preceding evidence makes success the expected outcome.

A recurring pattern of defects first discovered in physical validation is evidence that the earlier model is insufficient and must be improved.

A GitHub-hosted runner, headless GUI session or AI-provided VM is not physical validation of a stable reference host it did not actually exercise.

GitHub required status checks are not part of the current RumiAI workflow and must not be introduced without a new explicit decision.

## 10. Post-change diff review

After every modification:

1. reread the resulting diff;
2. re-evaluate it against `RULES.md` and the applicable current specifications;
3. scan the touched subsystem for superseded terminology/mechanisms;
4. verify no unrelated user/repository changes were overwritten;
5. run only tests proportional to the change under `TESTING.md`;
6. state physical-validation status accurately and revision-specifically;
7. verify Git history remains forward-only;
8. if concrete unfinished work was discovered but intentionally deferred, ensure it is either already represented by an active task or captured once under `todo/`;
9. when the task has an active handoff, determine whether the resulting state is a meaningful checkpoint and synchronize it before the final response when required.

## 11. Documentation consistency checks

When documentation is touched, additionally verify:

- no current document claims a superseded contract;
- no old decision is required to interpret the current specification;
- topic routing in `README.md` / `specifications/README.md` still reaches the authoritative source directly;
- no completed handoff remains in the current tree as competing authority;
- no historical evidence is presented as current behavior;
- cross-references point to paths that exist in the current tree;
- repeated normative text is minimized; where duplication is useful for orientation it must not create an independently editable second contract;
- TODO files contain only deferred-work planning state and do not become substitute specifications or task handoffs;
- the same work is not represented simultaneously by a current TODO and an active handoff.

## 12. Deferred work and active handoffs

`todo/README.md` defines the lifecycle for concrete known work that is intentionally deferred and not yet active. `handoff/README.md` defines the lifecycle for active resumable tasks.

A TODO may record only the minimal future intent, why the work remains pending, its scope and pointers to evidence. It must not accumulate active task progress, detailed design decisions or execution state.

When a TODO is intentionally activated, ownership of current task state moves from `todo/` to `handoff/`:

```text
delete todo/<topic>.md
create handoff/<task>.md
```

Perform both changes in the same authorized work unit and, when practical, the same commit. Do not retain duplicate current TODO and handoff representations for the same work.

An active handoff exists only to preserve task continuity across chats/sessions. `handoff/README.md` defines its lifecycle and structure.

It may record:

```text
task goal
current status
exact repository revisions last observed
already-fixed task-local choices
completed work
next concrete action
known blockers
```

It must not duplicate project-wide rules or subsystem specifications.

For a substantial, parallel or multi-chat task, create the handoff after preflight and before the first material task change when the need is already known. If the task becomes substantial later, create it as soon as that becomes clear.

A handoff checkpoint is required when resumable task state changes materially, including fixed decisions, completed modifications, executed tests/validation, discovered/resolved blockers, material scope/next-action changes or relevant revision movement.

When a response materially advances an active handoff task, required synchronization must complete **before** the user-visible final response. If it cannot be completed, the response must say that the persistent task state is not synchronized.

When the task closes:

1. propagate durable content to canonical current sources;
2. capture any concrete out-of-scope work that is intentionally deferred as minimal TODO items when applicable;
3. complete the normal final consistency gate;
4. write and commit a final handoff snapshot with `Status: Complete` and final revisions/validation state;
5. remove the handoff from the current tree in a later forward commit.

Git history is the archive. Do not create a completed-handoff/archive directory in the current tree.

## 13. Completion checklist

A RumiAI task is ready to report as complete only when every applicable item is true:

```text
[ ] current remote HEADs were verified before writes
[ ] README.md was used to route retrieval
[ ] current RULES.md was read
[ ] current CONSISTENCY-GATE.md was read
[ ] relevant current specifications were read
[ ] active handoff was read when applicable
[ ] relevant implementation/tests were inspected
[ ] applicable invariants were identified before writing
[ ] substantial/parallel/multi-chat task has an active handoff when required
[ ] no existing responsibility was duplicated under a new name
[ ] no contract was changed silently
[ ] current specification was updated for intentional contract changes
[ ] tests/evidence claim no more than what was actually exercised
[ ] resulting diff was reread
[ ] stale/superseded mechanisms and terminology were scanned
[ ] cross-references/current routing remain valid
[ ] user/concurrent repository changes were preserved
[ ] proportional tests were run or correctly classified as unnecessary
[ ] concrete intentionally deferred work is represented once under todo/ when applicable
[ ] no current TODO duplicates an active handoff for the same work
[ ] active handoff was synchronized for every material checkpoint before the final response
[ ] completed task has a committed final handoff snapshot and no active handoff remaining in the current tree
[ ] physical-validation status is stated accurately
[ ] Git changes are forward-only
```

Failure of an applicable item means the work is not complete.
