# AI-oriented administrative tools

Status: Active
Updated: 2026-10-05

## Goal

Explore and develop administrative-tool patterns that allow RumiAI and other AI agents to operate real infrastructure safely and effectively while preserving human control over credentials, authorization and high-impact actions.

The workstream is broader than any single `rsudo` feature and must remain independently resumable from current rsudo implementation tasks.

## Current repository revisions

```text
rumiai-dev  ec65039e73509ab961f65c57b83c47c5485ed7e4  (pre-checkpoint HEAD)
rumiai-os   f39d986e5d4269f742d138eb3ebf9092d1e3345c  (observed current remote HEAD; not modified by this checkpoint)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/RSUDO.md
handoff/README.md
```

When a concrete idea touches another existing command, library or subsystem, retrieve its canonical specification before promoting or implementing that idea.

## Fixed task-local choices

- Keep this workstream separate from the local AI cluster development task: the cluster is a concrete deployment/infrastructure task; this handoff owns reusable administrative-tool ideas and AI-operation patterns.
- Treat `rsudo` as a privileged remote execution boundary, not as an orchestration, scheduling, inventory, configuration-management or AI-routing framework.
- Preserve the separation:
  ```text
  AI / planner
      -> orchestration / jobs
      -> rsudo execution boundary
      -> target host
  ```
- The AI should not need direct knowledge or possession of infrastructure credentials. The human/operator may load credentials into an authorized environment and expose only the resulting operational capability.
- Preserve the agentless-target advantage where possible: SSH + sudo plus injected/transient source should remain sufficient for useful remote administration without requiring a permanent RumiAI agent on every target.
- Prefer reusable composition above `rsudo` rather than growing `rsudo` into a broad administrative framework.
- Human-oriented and AI-oriented workflows may share the same low-level execution primitives while exposing different higher-level interaction surfaces.

## Working design

The following are active design directions, not yet promoted subsystem contracts:

- Structured job results suitable for deterministic machine/AI interpretation, while preserving human-readable diagnostics. The result format and owning facility are not yet selected.
- Job-level parallel execution with explicit concurrency limits and per-host status collection. Parallelism should normally live above `rsudo` unless evidence shows a lower-level responsibility is required.
- A controlled non-interactive path for AI/Work/Codex execution that can reuse the same job-library/job-source model as `rsudo-admin` without weakening credential or authorization boundaries.
- Explicit run/operation identifiers for correlation rather than dependence on synchronized host clocks.
- Clear separation between planning, authorization, execution and evidence/result collection.
- Capability-oriented execution may be preferable to secret-oriented execution: an AI receives the ability to perform an allowed operation in an already-authorized environment rather than receiving the underlying secret.
- Administrative tools should make destructive or high-impact actions explicit and reviewable without turning ordinary safe execution into excessive approval friction.
- Where temporary source/library injection is sufficient, prefer it over installing and maintaining permanent target-side agents.

## Completed

- Current `rsudo` / `rsudo-admin` behavior has been reviewed in a real multi-host administrative scenario.
- `rsudo jobs` successfully supported a credential-separated inventory operation across eight hosts while keeping the assistant outside the credential boundary.
- The practical use case confirmed that reusable credential groups, remote privilege execution, source transport/injection, observable stdout/stderr and propagated result status compose well for AI-assisted operations.
- The user explicitly agreed with preserving `rsudo` as a small composable execution primitive and keeping broader orchestration responsibilities above it.

## Current state

The central architectural direction is fixed for this workstream, but no new product API, command or subsystem has been authorized or designed yet.

Existing active handoffs such as `rsudo-injection-menu.md` continue to own their specific rsudo implementation/validation lifecycle. This handoff owns only the broader AI-oriented administrative-tool investigation and future independently scoped implementations that may emerge from it.

## Next action

Continue collecting concrete administrative scenarios from real RumiAI work. For each scenario, identify which responsibility belongs to existing primitives, which belongs in a higher-level job/orchestration layer, and whether any genuinely new capability is required.

When one idea becomes concrete enough to implement independently, either keep it here if it remains part of this same resumable responsibility or split a specialized child handoff without duplicating active state.

## Blockers / open questions

- What structured result contract, if any, should administrative jobs expose to AI callers?
- What higher-level component, if an existing one, should own multi-host concurrency and aggregation?
- What is the cleanest controlled non-interactive entry path for Work/Codex or future RumiAI agents using already-loaded credentials?
- Which actions require explicit human approval versus being safely executable within a previously granted capability boundary?
