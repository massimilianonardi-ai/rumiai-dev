# Opt-in executable development planning (`devplan`)

Status: **Current / canonical**
Updated: 2026-11-04

## Purpose, authority and activation

`devplan` is an explicitly requested, **planning-only** RumiAI workflow. It first verifies whether the existing current specifications and operating conditions are sufficiently defined to permit reliable software development planning. It produces an executable plan for independently working chats or agents **only when that gate passes**. It must not fabricate a missing contract or convert provisional proposals into accepted design.

This document owns this optional workflow. It is reached through root `README.md` after the ordinary mandatory preflight. `RULES.md`, `CONSISTENCY-GATE.md`, the applicable current specifications, `TESTING.md` for testing rules, and `handoff/README.md` for active task state remain authoritative in their respective areas. `devplan` does not override them.

**Trigger:** activate only when the current user message, after optional leading whitespace, begins with the exact, case-sensitive, lowercase token `devplan` followed by whitespace and a task description. A message consisting of just `devplan` (ignoring surrounding whitespace) invokes the mode but lacks a target: ask for the task identity. Examples:

```text
devplan astronave
devplan implementare la libreria definita dalle specifiche correnti
```

The token inside a quotation, code sample, word such as `devplanning`, or elsewhere in a sentence does not activate the mode. Mere discussion about `devplan` does not activate it. Each invocation applies to one planning task; explicit follow-ups that revise its plan may continue that task without repeating the token. Unrelated requests never inherit the mode. Normal software requests must not silently be reclassified as `devplan`.

`devplan` authorizes assessment and planning, and ordinary handoff checkpointing when material resumable state arises. It does **not** authorize implementation, product or permanent-test changes, deployment, approval of a new architecture, integration commits, or automatic agent execution. Those operations require the normally applicable user authorization. This file defines an assistant procedure, **not** a native ChatGPT parser, globally installed slash command or background process. Recognition in a new chat depends on the RumiAI bootstrap retrieving `README.md` and this file.

## Mandatory source-first preflight

Before evaluating the task, verify remote HEADs of every repository materially involved; read root `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, the smallest complete set of current subsystem specifications, and the owning active handoff where one exists. Inspect the current implementation, manuals, tests and relevant package definitions where the proposed plan depends on actual state. Read `TESTING.md` for test/validation requirements and `handoff/README.md` for handoff lifecycle when relevant.

Locate existing responsibilities and active task ownership before proposing new interfaces or handoffs. Record source paths and revision checkpoints rather than copying canonical requirements. Do not use chat memory, historical commits, unpromoted design or an old handoff revision as current authority.

**If an essential source cannot be retrieved or the preflight cannot finish**, report `Verifica non completabile`, with the exact missing evidence and its effect. Missing access is not evidence that a specification is absent. Do not claim the task sufficient or definitively insufficient without the necessary inspection.

## Mandatory sufficiency gate

First describe the requested outcome independently of any implementation strategy. Assess only the conditions materially relevant to the target:

1. **Identity, purpose and scenarios:** what is being developed or changed, for whom, the intended user/operator outcome and representative normal interactions.
2. **Scope and ownership:** which current component/repository owns the responsibility, what is in and out of scope, what existing facilities must be reused, what authorizations apply.
3. **Behavior and interfaces:** observable behavior, public APIs/CLI, inputs, outputs, data/state formats, compatibility, error handling, diagnostics, and performance constraints where material.
4. **Architecture and standards:** relevant platform/runtime requirements, responsibility boundaries, naming, security, permissions, trust, concurrency, environment, integration and deployment assumptions.
5. **Dependencies and operability:** upstream/downstream interfaces, constraints imposed by real systems, knowledge the caller can reasonably provide versus what the implementation can discover.
6. **Acceptance and validation:** success and failure scenarios, authentic test/validation method, operational manuals, evidence thresholds and required physical/host verification where applicable.
7. **Feasibility of delegation:** prerequisites, settled shared contracts, potential file/interface overlap and remaining decisions affecting independent work.

### Mandatory finished-product operability demonstration

Before treating specifications as sufficient, write at least one **concrete,
end-to-end normal operator interaction** with the proposed finished product.
For a CLI, show the exact command entrypoint, required arguments, identity
and credential source, execution host, relevant network boundary and visible
success/failure result. For a graphical/service product, show the equivalent
actual entry path, actors, interactions and observable outcome. Use the
existing command/package inventory to check name collisions and ownership,
not merely the existence of a plausible implementation technique.

This is a design-level acceptance demonstration, **not** a fabricated
runtime test or an assumption that the user's network/hosts/browser exist.
Every prerequisite must be grounded in a current source, directly
discoverable, or explicitly supplied by the user. If a normal operator
cannot complete the depicted flow without deciding a missing host,
callback, credential, command identity, authorization policy or required
service, that is a **blocking gap** unless current authority deliberately
leaves the choice to the operator. Mark it `Specifiche insufficienti`,
not a ready implementation task.

A proposed plan MUST NOT replace the finished-product demonstration
with a sequence of component proofs, external-service experiments,
internal protocol tests or generic validation tasks. After the sufficiency
gate passes, make a **first usable vertical slice exercised through the
actual public interface** an explicit early acceptance milestone before
assigning broad implementation/test matrices. If this milestone fails,
stop and reconcile the product contract before scaling out parallel tasks.
Tests are evidence for the declared operator outcome; they cannot silently
become that outcome.

For each material condition classify it as: **settled by current authority**, **derivable through existing evidence or authorized local technical judgment**, **expressly non-constraining**, **blocking gap/conflict**, or **unverifiable due to access**. Name the canonical source/section that supports settled claims. Do not invent a universal checklist of mandatory product features: relevance depends on the task.

A gap **blocks planning** only when different reasonable answers would materially change the intended outcome, contract, ownership, interoperability, important risk boundary, normal user path or acceptance test. Ordinary local algorithm choices and reversible internal implementation decisions inside settled contracts are not user questions. A high-impact/foundational decision cannot be silently made by an executor just because a local solution looks convenient.

If specification and implementation disagree, or two normative sources conflict, make the mismatch explicit and apply current authority. Do not silently choose the most convenient one. Do not reinterpret unresolved provisional work as a promoted contract.

### If conditions are insufficient

Report the exact verdict **`Specifiche insufficienti`** and include:

- The task and established facts, with actual source coverage.
- A prioritized **minimal set of blocking gaps/questions**. For each, explain its consequence for planning and where the answer was sought.
- A clear distinction between gaps requiring an explicit user/contract decision and non-blocking implementation details agents can decide.
- The smallest next action that will close the gate. Alternatives, when useful, must be labeled as proposals, not assumptions.

Do **not** synthesize a fake complete design, claim ready execution units, schedule implementation or save speculative requirements as authoritative specifications. A partial dependency sketch is permissible only if explicitly marked provisional. Do not create an artificial handoff solely to store an elementary insufficient-request reply.

### If conditions are sufficient

Report **`Specifiche sufficienti per la pianificazione`** and produce the executable plan below. This verdict means readiness to plan, not proven runtime correctness. Recheck it whenever relevant sources or task scope change.

## Executable plan — required content after a positive gate

**Whole-work overview:** state the objective, outcome deliverables, integration boundaries, validation expectations, and a complete coarse dependency graph. Identify prerequisites, dependency bottlenecks, currently ready units and the path to final acceptance. Use a directed acyclic graph when possible; do not assert a critical path without justified duration or schedule assumptions.

**Progressive detail:** fully describe only ready or near-ready cohesive units. Keep later units at an outcome/dependency level until upstream interfaces and evidence are settled. Avoid speculative future function-by-function plans that become stale.

**Each executable unit**, with a stable local identifier, must contain enough information for a fresh executor to work without the original chat:

```text
Concrete outcome and deliverable(s)
Applicable current canonical source paths/sections
Target repository and relevant baseline revision checkpoint
Prerequisites and provided/consumed interfaces
Authorized modification boundary and explicit exclusions
Representative acceptance scenarios and completion criteria
Authentic tests/validation and exact evidence expected
Required operational manual and permanent-test consistency
Downstream integration and shared-file/interface ownership
Independent decisions delegated to the executor; escalation triggers
Observed state, blockers, and next action when active
```

Split work where a coherent deliverable has a meaningful acceptance and integration boundary, not merely to maximize parallel agents. Quality is part of the owning work unit: relevant permanent tests, manuals, diagnostics and consistency checks must not be deferred to a final generic cleanup phase.

**Parallel orchestration:** separate *functional independence* (no output dependency) from *operational independence* (no conflicting concurrent writes or public contract changes). Parallelize only where both hold, or where an explicit single-owner integration and reconciliation strategy handles overlap. Indicate which units can run together, which interfaces must stabilize first, and the integration order. Ownership of separate handoffs follows the existing resumable-responsibility rule; different task labels alone do not justify splitting a handoff.

**Execution protocol for future agents:** each agent re-verifies fresh remote HEADs, retrieves current authority, checks the unit's prerequisites, operates within its contract, runs proportional authentic validation and the post-change consistency gate, documents actual evidence and persists material state. Keep Git forward-only, preserve concurrent changes and reconcile branch movement instead of overwriting. A locally passing test cannot be reported as proof of a full composed workflow.

**Escalation:** unresolved public/API or architecture changes, ambiguous ownership, significant security/operability deltas, inaccessible authoritative sources, and validation failures implying a wrong contract must stop the affected unit and be escalated. Do not silently expand scope or reinterpret specifications. Revise dependencies and readiness only after the decision is settled through existing authority.

## Plan-level validation

Before reporting an executable plan ready, perform a **clean-chat resumption simulation**: with only current repository sources and the persisted task state, could a new chat identify the next ready unit, its exact authorized boundary, required inputs, acceptance and validation, and expected integration without assumptions from this conversation?

Verify that every deliverable has an acceptance owner; every prerequisite has an upstream outcome; there are no hidden design decisions in ready units; parallel assignments have non-conflicting ownership; no plan duplicates or overrides a canonical contract; real validation claims remain proportionate; the primary user/operator workflow is covered. When a check fails, correct or block the unit, not the evidence. A plan review is not a runtime test or proof that future agents will obey the procedure.

## Persistence and output

Use the existing active handoff if it owns the resumable responsibility. For genuinely independent substantial work, follow `handoff/README.md` before creating a new handoff. Persist only source references, a concise dependency map, ready-unit execution state, material decisions, blockers, evidence and next action. The plan must not become a duplicate specification; a nontrivial provisional decision belongs in handoff working design until resolved. Synchronize significant checkpoints and verify successful writes before claiming persistence.

Each `devplan` response includes **target and sources inspected**, **sufficiency verdict**, **blocking gaps or established readiness basis**, **executable plan only after a positive verdict**, **limits of actual verification**, and **persistence status**. An insufficient request should receive a focused actionable gap report, not pages of invented tasks.

## Illustrative calls

```text
devplan astronave
```

If no current authoritative source defines `astronave`, its intended software outcome, interfaces or acceptance, the response is `Specifiche insufficienti`, with the concrete missing decisions. No spacecraft architecture is guessed.

```text
devplan <existing, already specified RumiAI command or library>
```

If all material contracts and conditions are available after fresh retrieval, the response is `Specifiche sufficienti per la pianificazione` plus a dependency graph, ready independently verifiable units, safe integration strategy and applicable handoff checkpoint. Neither example authorizes actual implementation.
