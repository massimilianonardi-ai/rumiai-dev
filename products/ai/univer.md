# Univer

Status: **Current reference snapshot / non-normative**  
Evaluated: 2026-09-28

## Identity

- Upstream: `dream-num/univer`
- Upstream branch: `dev`
- Evaluated revision: `a77bd5d48c17f7d769edf0210db80d4a6a50047c`
- License: Apache-2.0 for the open-source repository surface as declared upstream
- Primary implementation: TypeScript
- Discovery context: recent GitHub acceleration brought the project into the AI-product scan; growth is a discovery signal, not adoption evidence.

## Purpose and upstream model

Univer is an embeddable Office SDK/runtime covering spreadsheets, documents, presentations and additional structured productivity surfaces. The current upstream positioning explicitly describes it as an "Office Harness for AI Agents".

Its architecture uses plugins, a Canvas-based renderer, a formula engine and a facade API that works in browser and Node.js contexts. Upstream separates the open-source package surface from optional Pro functionality.

## Agent-relevant capabilities

Current upstream documentation highlights:

- programmatic inspection and editing of Office content;
- output verification through content inspection, rendered screenshots and layout diagnostics;
- isolated draft/worktree collaboration with human review;
- browser and Node.js execution;
- plugin-based composition;
- AI-native spreadsheet integration through a separate Univer MCP project.

## RumiAI relevance

### Reuse

Potentially substantial for applications that need rich spreadsheet/document/presentation editing without building an office engine from scratch.

### Integration

Promising behind a document/artifact capability boundary, particularly if agents need structured editing plus rendered verification.

### Reference

High for the agent-to-document boundary: structured object APIs, visual verification, plugin composition, browser/headless execution and human review of agent-produced artifacts.

## Strengths and useful mechanisms

The important idea is not simply "AI can edit spreadsheets". Univer provides both a structured editing model and a rendered surface that can be inspected, allowing an agent workflow to combine semantic manipulation with visual verification.

## Risks and mismatches

- Open-source and Pro capabilities must be distinguished feature by feature.
- A document runtime is a specialized capability, not a general RumiAI agent architecture.
- Browser/rendering dependencies and collaboration services may be substantial.
- MCP integration is a useful interoperability surface but should not dictate RumiAI's internal document model.

## Current assessment

```text
reference     strong for agent-native document/artifact manipulation
integration   promising behind an explicit document capability boundary
reuse         potentially substantial for Office-class editing
foundation    specialized capability, not a general RumiAI foundation
```

## Verification notes

Before reuse or integration, verify the exact OSS/Pro boundary for required document types, import/export, collaboration, server-side rendering, AI SDK and MCP capabilities.
