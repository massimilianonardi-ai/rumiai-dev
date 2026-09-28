# AG-UI

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: AG-UI  
Upstream repository: https://github.com/ag-ui-protocol/ag-ui  
License: MIT, as declared upstream  
Evaluated upstream revision: `024332cbb71e03e6a6bc055bed5af9c5c504471a`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

AG-UI is an open event-based protocol for connecting AI agents to user-facing applications. The current upstream design defines a small family of standard event types and compatible inputs, with middleware that can operate over transports such as SSE, WebSockets or webhooks.

Upstream explicitly positions AG-UI as complementary to MCP for agent-to-tool interaction and A2A for agent-to-agent interaction.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- event-oriented agent/UI communication;
- streaming conversational output;
- bidirectional state synchronization;
- structured and generative UI messages;
- real-time context enrichment;
- frontend-executed tools;
- human-in-the-loop interaction;
- transport independence through middleware.

For RumiAI, the separation between semantic events and transport is especially important.

## RumiAI evaluation

### Reuse

Useful through SDKs/reference implementations if RumiAI builds a compatible UI surface. It is not itself a complete UI or agent runtime.

### Integration

Potentially high. AG-UI may provide an ecosystem-compatible external boundary for rich interactive clients while allowing RumiAI internals to remain independent.

### Reference

Very high because RumiAI has long-term requirements that exceed simple request/response chat. AG-UI provides concrete design evidence for streaming, asynchronous events, state synchronization and frontend tool invocation.

## Risks and architectural cautions

Frontend tools and bidirectional state are security-sensitive. A UI must not gain implicit authority merely because a protocol can transport a tool call or state update.

AG-UI's event vocabulary is external protocol vocabulary. It should not automatically become RumiAI's internal channel/event model.

## Current assessment

AG-UI is a **strong protocol reference** for the agent-to-user-interface boundary and a plausible compatibility target. Its main immediate value is comparing its event semantics with RumiAI's eventual communication requirements, not importing its vocabulary internally.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
