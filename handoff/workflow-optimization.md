# workflow-optimization

Status: Active
Updated: 2026-09-17

## Goal

Maintain a long-lived meta-workstream for continuously evaluating and improving the RumiAI development workflow: retrieval, documentation organization, Project Instructions, handoffs, deferred-work visibility, parallel work, repository coordination, testing/validation workflow and other mechanisms that affect how work is performed and resumed.

## Current repository revisions

```text
rumiai-dev    c97be83db453c17abd431935c66e72ef41dd4d5a  (pre-checkpoint HEAD)
rumiai-os     36c29d8412a523f722fd90004b78a07fdf0b06c8  (last inspected for pending-work verification)
rumiai-tests  298931c1dca03d44755893d64b9b3a7c0058b7ea  (current state inspected for pending-work verification)
pkg-catalog   94f58995cbd487b17f3b82bc2724c70540927b88  (current state recorded for package-related recovery)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
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
- Documentation maintenance uses the accepted hybrid/event-driven model now canonical in `README.md`.
- Current canonical development documentation in `rumiai-dev` is maintained in English; product/user-facing localization is separate.
- Known work that is concrete but intentionally deferred is represented under `todo/`; active resumable work is represented under `handoff/`; completed/past state is preserved by Git history.
- A TODO is minimal planning state, not a specification or active task state.
- Activation transfers ownership from `todo/<topic>.md` to `handoff/<task>.md` in the same work unit, ideally the same commit, without keeping duplicate current representations.
- `todo/` is not part of the mandatory read order for unrelated tasks.

## Completed

### Current-only documentation and retrieval model

The documentation was reorganized around:

```text
current branch = present
Git history = past
```

The root `README.md` is the deterministic retrieval router. Current contracts live in one canonical location; historical patch composition is not used to reconstruct current meaning.

### Project Instructions optimization

ChatGPT Project Instructions were reduced to a bootstrap into the current repository knowledge base rather than a second RumiAI knowledge base.

### Parallel task handoff protocol

Substantial, parallel and multi-chat tasks use one stable active handoff each. Meaningful checkpoints are synchronized before the final user-visible response. Completed handoffs receive a final `Status: Complete` snapshot and are then removed from the active tree; Git history is the archive.

### Documentation maintenance and language

The hybrid/event-driven documentation-maintenance model was made canonical. A dedicated normalization task translated remaining current Italian/mixed-language documents to English and removed stale current-tree material discovered during that work.

### `rumiai-os` operational documentation task

A dedicated `handoff/rumiai-os-man-documentation.md` task is active to design the boundary between normative development specifications and runtime/user operational reference.

### Deferred-work TODO lifecycle

The previously missing lifecycle layer for **known but not-yet-active work** has been implemented.

Current separation is now:

```text
specifications/     current normative contracts
todo/               concrete known work intentionally deferred
handoff/            active/resumable task state
Git history         past/completed state
implementation/tests current mechanical state and evidence
```

The canonical TODO contract is `todo/README.md`. Root routing, `CONSISTENCY-GATE.md` and `handoff/README.md` were updated so the lifecycle is integrated rather than being a standalone convention.

Important properties now fixed:

- one small TODO file per independently activatable topic;
- minimal shape: intent, why pending, scope, evidence;
- no detailed execution state, progress narrative or project-management ranking by default;
- no duplicate current TODO + handoff for the same work;
- activation removes the TODO and creates the handoff in the same work unit;
- removed TODOs are archived by Git history only;
- TODO inventory is retrieved only when relevant, not during every task preflight.

### One-time historical pending recovery

A dedicated historical-recovery task was executed with explicit authorization to inspect Git history for work that became invisible during the current-only documentation reset.

The recovery deliberately treated historical material only as candidate discovery and verified candidates against current specifications, implementation, tests and active handoffs.

Two current TODOs were recovered:

```text
todo/pkg-install-real-validation.md
todo/rumiai-tests-suite-realignment.md
```

The first captures the current gap between the real-composed `pkg install` testing contract and the present permanent test that substitutes parts of the package pipeline. It is phrased as validate/debug so a future task does not pre-judge whether the actual defect is in product behavior or in the legacy test construction.

The second captures a broader audit/realignment of the permanent suite. Current shared test infrastructure and authoring rules exist, while representative tests still preserve historical inline copies/reconstructed fixtures. The TODO explicitly requires evidence-based auditing rather than assuming every test needs rewriting.

Historical candidates deliberately not restored include:

- runner persistence/snapshot work, because current runner contracts/implementation/tests now contain it;
- resource/srv remediation, because historical test-side remediation is reflected in current tests and the remaining old physical gate was revision-specific;
- `mk`, because it is already represented by an active handoff;
- older bootstrap/shell/naming/CLI/language/log/physical-pass items that are now completed, consolidated, superseded or represented by current contracts;
- overlapping historical test-structure work, consolidated into the single suite-realignment TODO.

The recovery completed its full handoff lifecycle: a final `Status: Complete` snapshot was committed and `handoff/historical-pending-recovery.md` was removed in a later forward commit. Git history is its archive.

This was the intended transitional use of Git history. Future concrete deferred work should enter `todo/` when discovered, so routine workflow should not need historical mining to recover forgotten pending work.

### Specification promotion boundary

A real workflow defect was observed during the active `mk` design task: provisional design state — postponed decisions, candidate implementation languages/runtimes, candidate serialization formats, comparison criteria and unresolved questions — had been written into `specifications/rumiai-os/MK.md` and routed by `specifications/README.md` as "open design choices".

That made persistent task memory look like current normative architecture and broke the intended meaning of `specifications/` as current promoted contract.

The workflow was corrected with a specification promotion gate:

```text
promoted / binding current contract      → specifications/
active provisional / unresolved design   → handoff/<task>.md / Working design
experimental evidence needed to decide   → rumiai-dev-PoCs, referenced by handoff
concrete work deferred outside task       → todo/
past design state after completion        → Git history
```

`RULES.md`, `CONSISTENCY-GATE.md` and `handoff/README.md` now encode this lifecycle. An active handoff has an optional `Working design` section specifically for persistent non-authoritative candidates, provisional assumptions, comparison criteria and postponed in-task choices.

The rule includes one narrow exception: a specification may state that it does not constrain a dimension when that absence of constraint is itself a stable current boundary. It must state only the boundary, not the candidate list or decision process.

The concrete `mk` misuse was remediated in the same work unit:

- `specifications/README.md` no longer routes `MK.md` as a source of open design choices;
- `MK.md` now contains promoted lifecycle contract only;
- provisional Python/JavaScript runtime directions, JSON/TOML comparison state, unresolved lifecycle/API/workspace choices and documentation-tool candidates were moved into `handoff/mk-tool-development.md` under `Working design`;
- `CURRENT-MODEL.md` no longer presents undecided runtime/serialization state as architecture content;
- `MK-SOURCE-MATERIALIZATION.md` was cleaned of future-planning sections and now limits itself to the current implemented capability and stable scope boundaries.

No `rumiai-os` implementation or permanent test was changed by this workflow/documentation correction.

### Concurrency evidence

During earlier workflow work, other chats advanced `rumiai-dev` multiple times and introduced/modified independent documentation and handoffs, including `service-model`. Each movement was detected before writes and reconciled forward; unrelated concurrent work was preserved. This provides real evidence that the HEAD/reconciliation protocol is functioning under parallel work.

## Current state

`workflow-optimization` remains active.

The pending-work visibility gap is resolved through `todo/`, and the active-design/specification boundary is now explicit through the specification promotion gate and handoff `Working design` state.

The first observed misuse (`mk`) has been corrected, providing a concrete reference case for future tasks. Future workflow observation should verify that assistants keep provisional design in active task state and promote only sufficiently settled rules into current specifications.

## Next action

Observe both the TODO lifecycle and the specification promotion gate in normal use. In particular:

1. verify that new deferred work is captured only when concrete and intentionally postponed;
2. verify that TODO activation cleanly transfers state into one active handoff;
3. verify that active design candidates/open questions remain in `Working design` rather than being promoted for memory retention;
4. verify that promoted specification changes contain only binding current contract;
5. watch for TODO/handoff/specification accumulation, duplication or taxonomy drift.

## Blockers / open questions

None for the current TODO or specification-promotion lifecycle. Future corrections should be driven by observed workflow evidence rather than speculative expansion.