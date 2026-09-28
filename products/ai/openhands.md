# OpenHands / Agent Canvas

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: OpenHands / Agent Canvas  
Upstream repository: https://github.com/OpenHands/OpenHands  
License: MIT, as declared upstream  
Evaluated upstream revision: `f174ba8465233e46e66ab2c5667b358f1d6676d6`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

The current OpenHands repository presents Agent Canvas as a self-hosted developer control center for coding agents and automations. It can run the OpenHands agent or third-party agents such as Claude Code, Codex, Gemini and ACP-compatible agents across local, container, VM and cloud backends.

The current architecture is explicitly multi-repository: Agent Canvas owns the frontend/control center, `software-agent-sdk` owns the Agent Server and agent runtime APIs, a TypeScript client consumes that API, and a separate automation service owns schedules/webhooks/run dispatch.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- UI/control plane separated from agent runtime;
- multiple independently located Agent Servers;
- backend switching across local, Docker, VM and cloud execution;
- agent interoperability through ACP;
- automation scheduling separated from execution semantics;
- sandboxed versus unsandboxed execution choices;
- explicit repository/responsibility boundaries.

The current architecture is useful evidence for separating "where/when work runs" from "what an agent does".

## RumiAI evaluation

### Reuse

Potentially useful as an external developer automation/control product. Direct reuse is more plausible for development workflows than as a generic RumiAI runtime.

### Integration

Interesting if RumiAI later exposes or consumes an agent-server style boundary or ACP compatibility. Any integration should remain external to RumiAI's internal semantics.

### Reference

High for studying execution placement, multi-backend agent control, sandbox boundaries and decomposition of UI, automation and runtime responsibilities.

## Risks and architectural cautions

The project warns that unsandboxed agents have full filesystem access. This is a concrete reminder that agent capability and execution isolation are separate responsibilities.

OpenHands is also evolving rapidly; older descriptions of it simply as a coding agent no longer capture the current repository boundary.

## Current assessment

OpenHands is a strong **reference for agent execution/control-plane decomposition** and a possible external development tool. Its multi-repository responsibility split is currently more valuable to RumiAI study than adopting its agent implementation.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
