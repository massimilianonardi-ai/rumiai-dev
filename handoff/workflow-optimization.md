# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain an ongoing meta-workstream for continuously evaluating and improving the RumiAI development workflow itself: retrieval, documentation organization, Project Instructions, task handoffs, parallel work, repository coordination, testing/validation workflow, and any other mechanism that affects how development work is performed and resumed.

The task should identify normal evolution opportunities, mechanisms that do not behave as expected, avoidable friction, stale process assumptions, retrieval inefficiencies, concurrency problems, and corrections needed to keep the workflow simple, reliable and efficient over time.

## Current repository revisions

```text
rumiai-dev  2f045fa61eddd08ea2ce8eea536fbfecfa587c19  (pre-handoff HEAD for this task)
```

Only `rumiai-dev` is currently involved. Any future work that materially involves other repositories must freshly retrieve their remote HEADs before analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
handoff/README.md
```

No RumiAI OS subsystem specification is currently needed for this meta-workflow discussion.

## Fixed task-local choices

- Task name and stable handoff identity: `workflow-optimization` / `handoff/workflow-optimization.md`.
- This task is intentionally long-lived and remains active across chats while the workflow is still being continuously evaluated.
- The handoff must be synchronized automatically at meaningful checkpoints according to `handoff/README.md`.
- This task is about workflow/process evolution and must not become a second copy of canonical project rules or subsystem specifications; durable changes are propagated to their canonical current documents.

## Completed

### Documentation reset and current-only knowledge model

The project documentation was audited and reorganized with a "tabula rasa" principle while preserving Git history forward-only.

The resulting model is:

- the current `rumiai-dev` branch describes the current project directly;
- historical/superseded analyses, decisions, drafts, chats, architecture snapshots, completed handoffs and stale specifications are absent from the current tree and remain recoverable through Git history;
- current rules/specifications must not require mental composition of old specification + later decision + later correction + handoff;
- one current contract has one canonical location;
- accepted durable changes are propagated into the canonical current document;
- Git history, not a parallel history directory, preserves the past.

A root `README.md` was introduced as the deterministic retrieval router. The mandatory project retrieval order became:

```text
verify current remote HEADs
→ README.md
→ RULES.md
→ CONSISTENCY-GATE.md
→ specifications/README.md + smallest complete relevant current source set
→ active task handoff when applicable
→ implementation/tests when factual/mechanical state matters
```

The documentation reset also introduced/realigned current RumiAI OS specifications including the current model, bootstrap, entrypoints, root resolution, naming, portability, state model, package model and service lifecycle, while preserving current resource/lang/mk/read-key documents that remained valid.

Development and physical-testing documentation were also reduced toward current operational contracts rather than historical chronicles.

### Project Instructions optimization

ChatGPT Project Instructions were redesigned as a bootstrap into `rumiai-dev`, not as a second RumiAI knowledge base.

The governing principle is:

- Project Instructions contain only stable bootstrap rules needed before repository retrieval;
- architecture, POSIX rules, naming, testing semantics, package/state contracts and similar evolving details live only in `rumiai-dev`;
- if external instructions duplicate or diverge from repository authority, the repository remains the canonical maintenance location and the external instructions should be simplified.

`README.md` now explicitly documents this bootstrap-only model.

The user replaced the ChatGPT Project Instructions with the optimized version produced in this chat.

### Parallel task / handoff protocol

A persistent handoff model for parallel and multi-chat tasks was designed and implemented.

Current contract:

- substantial, parallel or multi-chat tasks use exactly one stable active handoff under `handoff/<task-name>.md` unless deliberately split into independent workstreams;
- the handoff is the persistent boundary between volatile chat context and durable resumable task state;
- a new clean chat resumes through the normal project preflight and then reads the relevant active handoff;
- stored SHAs in an handoff are resumption state, never substitutes for fresh remote HEAD retrieval;
- separate parallel tasks have separate handoffs, but repository write concurrency is still governed by fresh HEAD checks, forward reconciliation and no force-push/history rewrite;
- the same handoff may be continued from another chat after fresh preflight/reconciliation.

Meaningful checkpoints requiring automatic handoff synchronization include:

```text
a task-local decision becomes fixed
a modification is completed
a material test/validation is executed
a problem/mismatch/regression/blocker is discovered
a blocker is resolved
task scope changes materially
next action changes materially
relevant repository revisions change in a way resumption must know
```

A response itself is not a checkpoint.

Before a final user-visible response that materially advances an active handoff task, required persistence must happen in the same response cycle:

```text
perform work
→ perform applicable consistency/validation checks
→ synchronize handoff
→ verify persistence succeeded
→ send final response
```

If persistence is required but fails, the assistant must explicitly report the unsynchronized state rather than rely silently on chat memory.

Completed task archival uses Git history only:

```text
propagate durable state to canonical sources
→ final consistency gate
→ commit final handoff snapshot with Status: Complete
→ remove handoff in a later forward commit
```

No `completed/`, `archive/` or equivalent handoff history directory is kept in the current tree.

This protocol was self-tested operationally during its own implementation: the temporary `parallel-task-handoff-protocol` handoff was created, advanced, committed with `Status: Complete`, then removed in a later forward commit. The current branch retained only `handoff/README.md` afterwards.

### Git/history discipline established during the reorganization

- Git is forward-only.
- Historical documentation/content is preserved by Git history rather than retained in the current retrieval surface.
- No force push/history rewrite is used for cleanup.
- Concurrent/user changes must be preserved; moved HEADs require fresh retrieval and forward reconciliation.

During the large documentation reset, some temporary no-op / `__tmp*__` commits were accidentally created through tool selection. They were cleaned from the current tree without rewriting history. This is relevant workflow evidence: operational tooling mistakes should be corrected forward and can themselves motivate workflow improvements.

## Current state

`workflow-optimization` is now the persistent meta-task for monitoring and evolving the RumiAI development workflow.

The first open topic is how to keep the newly reorganized documentation efficient, current, responsive and low-noise over time without recreating the historical problems that the documentation reset removed.

The user specifically asked whether documentation-maintenance evolution should be discussed and governed inside this `workflow-optimization` task or whether a separate persistent task should be created for it.

## Proposed direction under discussion

Recommended model (not yet user-confirmed as a fixed task choice):

- keep **continuous documentation-health policy, observations, drift detection, retrieval efficiency, lifecycle rules and small corrections** inside `workflow-optimization`, because these are part of the workflow itself;
- create a **dedicated task/handoff only for a substantial documentation work unit** when the change becomes independently resumable, large/risky, touches many canonical surfaces, requires migration/restructuring, or would otherwise make the workflow-optimization handoff carry implementation detail unrelated to its long-lived meta-state;
- after the dedicated documentation task completes, propagate its durable workflow conclusions back into canonical docs and record only the resulting lesson/state in `workflow-optimization` if still relevant.

This gives `workflow-optimization` the role of continuous governance/observation without making it a catch-all implementation task.

## Next action

Discuss and fix the documentation-maintenance strategy, including:

1. what ongoing signals/checks should indicate documentation drift or retrieval degradation;
2. what maintenance belongs directly in `workflow-optimization`;
3. the threshold for spawning a dedicated documentation task;
4. whether any periodic or event-driven review mechanism should be introduced beyond the existing consistency gate.

## Blockers / open questions

- Decide whether to adopt the proposed hybrid model: documentation-health governance in `workflow-optimization`, substantial documentation refactors as dedicated tasks.
- Define the most efficient long-term mechanism for keeping current documentation concise, complete, internally consistent and aligned with actual development without creating unnecessary recurring maintenance work.
