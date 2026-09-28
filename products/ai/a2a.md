# Agent2Agent (A2A)

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: Agent2Agent (A2A)  
Upstream repository: https://github.com/a2aproject/A2A  
License: Apache-2.0, as declared upstream  
Evaluated upstream revision: `72b3761bd84c59291da694dcd97cdfc2c010df39`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

A2A is an open protocol for communication and interoperability between opaque agentic applications. Its stated goal is collaboration without requiring agents to expose internal memory, proprietary logic or tool implementations.

The evaluated revision uses JSON-RPC 2.0 over HTTP(S), Agent Cards for discovery, and supports synchronous interactions, SSE streaming and asynchronous push notifications.

## Mechanisms relevant to RumiAI study

Important mechanisms are:

- agent capability discovery through Agent Cards;
- opaque-agent interoperability;
- task-oriented interaction independent of internal implementation;
- synchronous, streaming and asynchronous communication modes;
- text, file and structured-data exchange;
- explicit security/authentication considerations;
- SDKs in multiple languages.

A2A therefore addresses an architectural boundary rather than supplying an agent implementation.

## RumiAI evaluation

### Reuse

Not a product to reuse as a runtime; the reusable asset is the protocol and its SDKs. A future RumiAI agent-facing endpoint could implement A2A if interoperability requirements justify it.

### Integration

Potentially very high. A2A should be evaluated whenever RumiAI needs to communicate with independently developed agents across process, machine or organizational boundaries.

### Reference

Very high. It is evidence that the ecosystem is separating agent-to-agent communication from tool access and user-interface communication.

## Risks and architectural cautions

A standard can still encode assumptions that do not match RumiAI. Agent Cards, task lifecycle and JSON-RPC transport semantics must be evaluated against actual requirements rather than adopted because of ecosystem momentum.

Protocol support also creates a security boundary: discovery, authentication, authorization, remote content and asynchronous callbacks need explicit trust semantics.

## Current assessment

A2A is a **high-value interoperability reference and plausible future protocol integration**. It should be studied alongside MCP and AG-UI, while preserving the distinction between their responsibilities.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
