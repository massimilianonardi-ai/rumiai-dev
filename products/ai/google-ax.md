# Google AX

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `google/ax`
- Upstream branch: `main`
- Evaluated revision: `ac2332829f22360ff97b0ba34d94dd0dd782f17e`
- License: Apache-2.0 as declared by upstream
- Primary implementation: Go
- Discovery context: rapid recent GitHub growth; growth is a discovery signal, not adoption evidence.

## Purpose and upstream model

AX is Google's open agentic orchestration runtime. Upstream describes it as a high-throughput declarative orchestrator for autonomous agent workloads in clusters.

Its current model exposes three principal declarative resources: `Task`, `Workspace` and `Model`. Tasks execute in sandboxes supplied by Agent Substrate. AX supports suspend/resume, interactive inspection, workspace preparation, model configuration and cluster-scale scheduling.

Upstream warns that AX and several features are in heavy development and may undergo major breaking changes.

## Deployment and integration surfaces

The current deployment assumes Kubernetes plus Agent Substrate. The control plane exposes a gRPC API. State is stored in Redis rather than representing millions of short-lived tasks as Kubernetes CRDs.

Current binaries include:

- `ax`: developer CLI;
- `ax-server`: gRPC control plane and reconciliation service;
- `ax-task-runner`: task-container bootstrap/runtime entrypoint.

## RumiAI relevance

### Reuse

Potentially useful for specialized large-scale or remote agent execution. It is not a natural default for a sovereign local personal runtime because the current deployment model assumes cluster infrastructure.

### Integration

Plausible as an optional distributed execution provider behind a future RumiAI-owned execution boundary.

### Reference

Very high for distributed agent workload semantics:

- declarative task/workspace/model separation;
- sandboxed execution;
- suspend/resume and checkpointing;
- explicit resource limits;
- pre-wired repositories, MCP servers and skills;
- control-plane versus task-runner separation;
- watch/inspect/debug operations;
- state storage designed for very large numbers of ephemeral agent tasks.

## Strengths and useful mechanisms

AX treats agents as workloads with properties different from stateless services and ordinary batch jobs: they accumulate state, need isolation, consume external model/tool services and may require spending controls and human inspection. That framing is directly useful when reasoning about scalable agent execution.

## Risks and mismatches

- Kubernetes, Redis and Agent Substrate are substantial infrastructure assumptions.
- The upstream scale target is far beyond typical personal/local execution and should not distort simpler RumiAI requirements.
- `Task`, `Workspace` and `Model` are AX concepts, not RumiAI primitives.
- Heavy development and breaking-change risk make early coupling expensive.

## Current assessment

```text
reference     very strong for distributed/resumable agent execution
integration   plausible as an optional scale-out execution provider
reuse         specialized; strongest for cluster workloads
foundation    no current basis for importing AX resource semantics into RumiAI
```

## Verification notes

Refresh upstream before relying on suspend/resume semantics, Agent Substrate contracts, networking, credential handling, resource accounting or API stability.
