# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, specification promotion, command/library manual consistency, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    e82ce555d051916f96d65f14cef795db2e0bbbbd  (pre-checkpoint HEAD after library-manual synchronization)
rumiai-os     14e413342261b23df840f40b355166c4d55f1b41  (current remote HEAD; library inventory previously inspected at e9cad500)
rumiai-tests  ae0f41b23ae477bf2f1b13332b4c52bf2df16f2f  (current remote HEAD; active parallel suite work)
pkg-catalog   94f58995cbd487b17f3b82bc2724c70540927b88  (last recorded; not involved in this correction)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
todo/README.md
handoff/README.md
```

Subsystem specifications are added only when a concrete workflow question reaches their responsibility.

## Fixed task-local choices

- Stable task identity: `workflow-optimization` / `handoff/workflow-optimization.md`.
- This task is intentionally long-lived across chats while the workflow continues to be evaluated.
- Its handoff is synchronized automatically at meaningful checkpoints according to `handoff/README.md`.
- It governs workflow health and reusable lessons; it must not become a second copy of canonical rules/specifications or a catch-all implementation task.
- Durable workflow rules are propagated to canonical current documentation.
- Known concrete but inactive work belongs under `todo/`; active resumable work belongs under `handoff/`; completed/past state belongs in Git history.
- `specifications/` contains promoted current contract only; unresolved active design belongs in handoff `Working design` until promotion.
- Every RumiAI-owned directly executable command identity requires operational manual coverage regardless of audience.
- Every RumiAI-owned library identity requires exactly one operational manual topic.
- Library public/internal API visibility is explicit in naming: public functions do not begin with `_`; internal functions begin with `_`.
- Library manuals expose the complete public function interface and do not expose internal functions as callable API.
- Command/library lifecycle changes and manual realignment are one development consistency obligation.

## Completed

### Current-only documentation and retrieval model

The documentation was reorganized around:

```text
current branch = present
Git history = past
```

The root `README.md` is the deterministic retrieval router. Current contracts live in one canonical location; historical patch composition is not used to reconstruct current meaning.

### Deferred-work and active-design lifecycle

The current lifecycle separates:

```text
promoted contract       → specifications/
active working design   → handoff/<task>.md / Working design
deferred future work    → todo/
past/completed state    → Git history
implementation/tests    → current mechanical state and evidence
```

A specification promotion gate prevents candidates, postponed decisions and comparison state from being preserved as normative architecture merely for memory retention.

### Command/manual completeness

Every RumiAI-owned directly executable command identity must have an owner-local operational manual topic. Command creation, rename, removal and behavior-affecting changes are coupled to manual realignment; every command modification requires an explicit manual-consistency check. Structural permanent coverage is required to detect missing command topics.

The active `rumiai-os-man-documentation` handoff owns the current command-manual backfill rather than duplicating it as deferred work.

### Library interface and manual completeness

The same completeness model has now been extended to RumiAI-owned libraries.

Canonical model:

```text
lib/<owner>/<runtime>/<library-name>.lib.<runtime>
    ↓
res/<owner>/manual/<library-name>.lib.<runtime>
```

Each library has one manual page. Its public API is defined by functions whose names do not begin with `_`; internal functions must begin with `_` and are implementation-private. The manual exposes every public function and does not present internal functions as callable API.

`specifications/rumiai-os/LIBRARY-INTERFACES.md` is now the canonical library-interface contract. `RULES.md`, `CONSISTENCY-GATE.md`, `DOCUMENTATION-MODEL.md` and `specifications/README.md` route and enforce the same lifecycle without creating a second authority.

Current product inspection established that newer/current examples such as `array.lib.sh` and `mk-materialize.lib.sh` already visibly use underscore-prefixed private helpers and unprefixed public functions. Legacy code such as `core.lib.sh` contains unprefixed helper-shaped functions whose intended API visibility cannot safely be inferred from spelling alone.

Therefore the correction was deliberately split:

```text
active manual task
    library manual backfill and structural library→manual completeness

todo/library-api-visibility-realignment.md
    dedicated legacy API classification/rename/caller/test migration where required
```

This avoids both silent breaking renames and documentation that accidentally promotes legacy implementation helpers to public API.

### Concurrency evidence

Concurrent `rumiai-dev` movement occurred again during this correction. A write to the active manual handoff was rejected because another chat had changed the same file; the new state was fetched and the library/manual delta was reapplied forward. No concurrent change was overwritten.

## Current state

`workflow-optimization` remains active.

The workflow now has explicit consistency gates for both directly executable commands and libraries:

```text
command identity  → mandatory operational manual
library identity  → mandatory operational manual
library function  → explicit public/internal visibility by leading underscore
```

The legacy library visibility migration is not hidden as current compliance: it is explicit deferred work, while documentation backfill remains owned by the active manual task.

## Next action

Observe the TODO lifecycle, specification promotion gate and command/library manual gates in normal use. In particular:

1. verify every new/modified command retrieves and checks its operational manual;
2. verify every new/modified library retrieves `LIBRARY-INTERFACES.md`, checks function visibility naming and checks its single library manual;
3. verify internal library helpers are not accidentally documented/promoted as public API;
4. verify the active manual task closes command/library topic gaps and adds structural permanent coverage;
5. verify the legacy visibility TODO is activated as a dedicated product/API migration rather than folded silently into unrelated work;
6. watch for TODO/handoff/specification/manual duplication or taxonomy drift.

## Blockers / open questions

None for the workflow rule itself. Current command/library manual backfill belongs to `handoff/rumiai-os-man-documentation.md`; legacy library API visibility realignment is represented by `todo/library-api-visibility-realignment.md`.
