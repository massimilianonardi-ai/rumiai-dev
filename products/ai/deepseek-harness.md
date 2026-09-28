# DeepSeek Harness

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `deepseek-ai/deepseek-harness`
- Upstream branch: `master`
- Evaluated revision: `4878cdabd87d4041bdaff61d04c966883b9fd07a`
- License: MIT as declared by upstream
- Primary implementation: TypeScript
- Discovery context: unusually strong recent GitHub star acceleration; growth is a discovery signal, not adoption evidence.

## Purpose and upstream model

DeepSeek Harness (`dsh`) is an open-source agent harness built around an "everything is a plugin" architecture. The upstream architecture uses Cordis: plugins contribute services, typed events and reversible effects to a shared context.

The model adapter, tool registry, session log and agent loop are plugins rather than privileged fixed core components. Runtime composition is expressed through profiles, bundles and ordered configuration patches.

Upstream explicitly labels the product a developer preview and warns that compatibility-breaking changes are expected.

## Deployment and integration surfaces

The project ships Web, headless, SDK, minimal-SDK and ACP-oriented profiles behind the same launcher. The TypeScript SDK uses a JSON-RPC server profile; a Python SDK packages and launches the normal runtime rather than defining a separate architecture.

The base composition includes model adapters, tools, persistence, sandbox and approval policy, settings, credentials and telemetry.

## RumiAI relevance

### Reuse

Potentially useful for external experiments or applications that need a highly composable agent harness. Its preview status makes direct foundational dependence premature.

### Integration

Plausible behind a RumiAI-owned boundary if a future use case benefits from running DeepSeek Harness as an independently replaceable agent runtime.

### Reference

Very high. Particularly relevant mechanisms are:

- plugin composition without a privileged application core;
- reversible plugin effects and unload semantics;
- profiles and bundles as runtime compositions;
- replaceable model, tool, persistence and agent-loop seams;
- durable session events separated from live process events;
- guarded tool execution;
- sandbox and approval policy as composable capabilities;
- explicit headless, SDK and protocol-facing runtime profiles;
- session persistence, migration and resume semantics.

## Strengths and useful mechanisms

The most interesting architectural property is not simply extensibility but the attempt to make the harness itself a composition of replaceable plugins. The durable-event versus live-event distinction is also useful when studying resumable agents, auditability and recovery.

## Risks and mismatches

- Upstream is explicitly unstable and may introduce breaking changes.
- Cordis and DeepSeek-specific composition vocabulary must not become RumiAI primitives merely because the implementation is attractive.
- A broad plugin surface increases the importance of trust, permission, lifecycle and configuration validation.
- Direct reuse would introduce a Node/TypeScript runtime dependency; this is acceptable for external software but must not silently dictate RumiAI-owned implementation choices.

## Current assessment

```text
reference     very strong
integration   plausible later behind an explicit RumiAI boundary
reuse         useful for experiments and selected external applications
foundation    no current basis for adopting the upstream architecture as RumiAI contract
```

## Verification notes

Before architectural or implementation reliance, refresh the upstream revision and re-check plugin lifecycle, persistence, sandbox/approval semantics, protocol surfaces and stability status.
