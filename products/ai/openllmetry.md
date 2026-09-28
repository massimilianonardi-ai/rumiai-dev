# OpenLLMetry

Status: **External product evaluation / non-normative**  
Evaluated: 2026-09-28

## Identity

Product/project: OpenLLMetry  
Upstream repository: https://github.com/traceloop/openllmetry  
License: Apache-2.0, as declared upstream  
Evaluated upstream revision: `6102f9e02675db537497c40bc43e68b7a4faac07`

This record is a revision-specific external-product evaluation. Upstream terminology does not define RumiAI architecture.

## Upstream purpose

OpenLLMetry is a set of LLM/GenAI observability extensions built on OpenTelemetry. It instruments model providers, vector databases and agent/framework integrations while emitting standard OpenTelemetry data that can be routed to multiple observability backends.

The upstream project notes that its semantic-convention work is now participating in the OpenTelemetry semantic-conventions process.

## Mechanisms relevant to RumiAI study

Relevant mechanisms include:

- AI-specific tracing built on a general observability standard;
- instrumentation separated from telemetry destination;
- provider/framework-specific adapters producing common telemetry;
- traces that can join ordinary API/database/system traces;
- export through existing OpenTelemetry infrastructure;
- semantic conventions for model and agent operations.

This is a strong example of extending an established standard instead of inventing a vertically isolated AI telemetry stack.

## RumiAI evaluation

### Reuse

Potentially useful if its language/runtime integration fits the component being instrumented. Direct reuse is less important than compatibility with the underlying OpenTelemetry model.

### Integration

High conceptual integration potential through OpenTelemetry even if RumiAI never depends directly on OpenLLMetry. Specific instrumentations could remain optional adapters.

### Reference

Very high for observability architecture: standard traces, replaceable exporters and AI-specific semantics layered over a general telemetry substrate align well with modularity.

## Risks and architectural cautions

AI traces can contain prompts, outputs, retrieved context, tool arguments, identifiers and other sensitive data. Local-first observability therefore needs explicit capture/redaction/storage/export policy.

OpenLLMetry's Python implementation should not cause RumiAI-owned code to adopt Python; the more durable architectural asset is the OpenTelemetry-compatible semantic model.

## Current assessment

OpenLLMetry is a strong **reference for AI observability and standards reuse**. The key lesson is not necessarily to adopt its SDK, but to investigate OpenTelemetry as the lower-level interoperability substrate for future RumiAI tracing.

## Verification notes

This evaluation is based primarily on the upstream repository and current README at the revision recorded above. Runtime behavior, security properties, performance claims and operational characteristics have not been independently validated by RumiAI testing in this work unit.
