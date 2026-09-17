# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

The task should identify normal evolution opportunities, mechanisms that do not behave as expected, avoidable friction, stale process assumptions, retrieval inefficiencies, concurrency problems and corrections needed to keep the workflow simple, reliable and efficient over time.

## Current repository revisions

```text
rumiai-dev  de593dea958a2059b01b677588f47ba84c0f381a  (last retrieved before this checkpoint)
rumiai-os   36c29d8412a523f722fd90004b78a07fdf0b06c8  (last inspected while activating the man-documentation task)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
handoff/README.md
```

Subsystem specifications are added only when a concrete workflow question reaches their responsibility.

## Fixed task-local choices

- Stable task identity: `workflow-optimization` / `handoff/workflow-optimization.md`.
- This task is intentionally long-lived across chats while the workflow continues to be evaluated.
- Its handoff is synchronized automatically at meaningful checkpoints according to `handoff/README.md`.
- It governs workflow health and lessons; it must not become a second copy of canonical rules/specifications or a catch-all implementation task.
- Durable workflow rules are propagated to canonical current documentation.
- Documentation maintenance uses the accepted hybrid model now canonical in `README.md`:
  - continuous documentation-health governance and drift observation remain in workflow governance;
  - small/local corrections are made in the work unit that discovers them;
  - substantial, independently resumable, broad/risky or restructuring documentation work gets a dedicated handoff/task;
  - maintenance is event-driven by default, with broader review at natural structural milestones rather than recurring calendar audits.
- Current canonical development documentation in `rumiai-dev` is maintained in English; product/user-facing localization is a separate concern.

## Completed

### Current-only documentation model

The documentation was reorganized around the principle:

```text
current branch = present
Git history = past
```

Current rules/specifications describe the current project directly. Superseded analyses, decisions, drafts, chats, historical handoffs and stale specifications are absent from the normal retrieval surface and remain recoverable through Git history.

The root `README.md` became the deterministic router with mandatory order:

```text
verify current remote HEADs
→ README.md
→ RULES.md
→ CONSISTENCY-GATE.md
→ specifications/README.md + smallest complete relevant current source set
→ active task handoff when applicable
→ implementation/tests when factual/mechanical state matters
```

The model enforces one current contract per canonical location and rejects historical patch composition as a way to discover current meaning.

### Project Instructions optimization

ChatGPT Project Instructions were reduced to a bootstrap into the repository rather than a second RumiAI knowledge base. Evolving architecture, platform, naming, testing, package/state and similar rules remain in `rumiai-dev`; external instructions force fresh retrieval and safe Git behavior only.

The user installed the optimized Project Instructions produced during this workflow.

### Parallel task handoff protocol

Substantial, parallel and multi-chat tasks use one stable handoff per active task. A handoff is the persistent boundary between volatile conversation context and durable resumable task state.

Meaningful checkpoints include fixed task-local decisions, completed modifications, material tests/validation, discovered/resolved blockers, material scope/next-action changes and relevant revision movement.

When a response materially advances an active task, required persistence occurs before the final user-visible response:

```text
perform work
→ consistency/validation checks
→ synchronize handoff
→ verify persistence
→ final response
```

Completed handoffs are archived only through Git history:

```text
propagate durable state
→ final consistency gate
→ commit Status: Complete snapshot
→ delete handoff in a later forward commit
```

The protocol was exercised successfully during its own implementation.

### Git/history discipline

- Git is forward-only.
- No force push/history rewrite is used for ordinary cleanup.
- Concurrent/user changes are preserved; moved HEADs require fresh retrieval and forward reconciliation.
- Historical evidence is revision-specific and is never upgraded retroactively.

During the large documentation reset, temporary no-op / `__tmp*__` commits were accidentally created through tool selection. They were removed from the current tree through forward commits without rewriting history. This remains useful workflow evidence: tooling mistakes should be corrected forward and may motivate process improvement.

### Documentation maintenance model fixed

The user accepted the hybrid/event-driven documentation-maintenance model. It was promoted into the root `README.md` on 2026-09-17, including concrete drift signals such as historical composition being required for current meaning, duplicated rules, ambiguous routing, over-retrieval, mixed responsibilities, handoff knowledge leakage, uncaptured spec/implementation drift and inability of a clean chat to resume without conversation memory.

### Documentation language normalization

The first substantial documentation-health issue was split into a dedicated `documentation-language-normalization` task, validating the hybrid model in practice.

The audit found five current Italian/mixed-language documents:

```text
TESTING.md
RUNNER.md
TEST-PATTERNS.md
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
```

They were normalized to English in one atomic commit. The pass also exposed and removed stale current-tree material: old repository-role wording and revision-specific historical validation evidence embedded in current testing/pattern documents.

The dedicated task completed its full lifecycle: its `Status: Complete` snapshot was committed and the handoff was removed from the current active tree in a later forward commit. Git history is now its archive.

### `rumiai-os` man-style documentation task activated

A separate active handoff now exists at:

```text
handoff/rumiai-os-man-documentation.md
```

The task investigates a runtime/user operational reference distributed with `rumiai-os` while preserving a strict boundary from normative development specifications in `rumiai-dev`.

Activation findings:

- current `rumiai-os` exposes many public commands but no discovered `man` or `help` documentation mechanism;
- placement cannot be inferred from filesystem symmetry;
- `res/` cannot simply be assumed as the destination because the current resource contract fixes only `lang` as a concrete global resource class;
- the key design problem is single-source-of-truth ownership between normative development contracts and operational software reference.

No directory, command, source format, man section scheme, generator or localization mechanism has been fixed yet.

## Current state

`workflow-optimization` remains active as the continuous governance/observation task.

The documentation-maintenance and language policies are canonical. The language-normalization implementation task is completed and archived through Git history. `rumiai-os-man-documentation` remains active at design stage.

A major workflow concern to continue observing is the long-term shape of `specifications/`: the current router makes omissions visible, which is beneficial, but the directory must not evolve into a monolithic catch-all. The man-style documentation task may reduce pressure by moving operational reference out of normative specifications, provided no duplicated authority is created.

## Next action

Continue workflow observation while the dedicated `rumiai-os-man-documentation` task designs the boundary between normative specifications and runtime/user reference. Use its findings to decide whether the specification taxonomy/routing model needs further structural refinement.

## Blockers / open questions

- Whether `specifications/` eventually needs a stronger taxonomy beyond the current flat `rumiai-os/` topic index; do not restructure pre-emptively without evidence from real retrieval.
- Which facts currently present or missing in `specifications/` are genuinely normative design contracts versus operational reference better owned by the future man-style documentation surface.
