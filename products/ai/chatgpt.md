# ChatGPT

Status: **External product evaluation / non-normative**  
Evaluated: 2026-10-01

## Identity

Product: ChatGPT  
Vendor: OpenAI  
Primary upstream source: https://chatgpt.com/  
Product documentation: https://help.openai.com/  
Release notes: https://help.openai.com/en/articles/6825453-chatgpt-release-notes

ChatGPT is evaluated here as a hosted product and evolving agent platform rather than as an open-source codebase, so no repository revision applies. This record is a date-specific snapshot of publicly documented product behavior. OpenAI terminology does not define RumiAI architecture.

## Scope of this snapshot

The evaluation focuses on architectural changes visible through September 2026, especially the convergence of:

- Chat, Work and Codex as distinct work surfaces;
- persistent and asynchronous task execution;
- reusable cloud execution environments;
- always-on agents;
- plugins, connected apps and MCP-based integrations;
- scheduled and event-triggered automations;
- projects, Space, Pages and collaborative artifacts;
- Voice as another interaction surface over the same tools;
- permissions, approvals and human review.

The purpose is not to reproduce ChatGPT's product taxonomy. It is to study which responsibilities appear repeatedly once an AI system moves beyond a transient conversation.

## Current product direction

ChatGPT is increasingly organized as a set of cooperating execution and interaction surfaces rather than a single conversational interface.

Chat remains the general conversational surface. ChatGPT Work is documented as an agent for longer, multi-step work that can research, analyze, use connected apps and files, work in a browser and create finished artifacts. Codex remains specialized for software-development work.

The important architectural observation is that these surfaces can share capabilities without becoming the same thing. Connected apps and plugins can be available across ChatGPT and Codex, Voice can invoke Work capabilities, and unfinished Work started through Voice can continue after the live voice interaction ends.

This supports a useful separation between:

- interaction channel;
- task intent;
- execution environment;
- connected capabilities;
- persistent context and artifacts;
- authorization and approval.

That separation is reference evidence only. It does not establish equivalent RumiAI primitives.

## Persistent work and asynchronous execution

### ChatGPT Work and scheduled tasks

ChatGPT Work can continue longer tasks and can use Scheduled Tasks for one-time, recurring, monitoring and supported event-triggered work.

By late August 2026, OpenAI documented webhook-triggered tasks for supported external events such as Gmail messages, Slack channel messages and GitHub pull-request activity. On September 29, OpenAI documented MCP events as another mechanism through which supported plugins can start automations from connected-app changes.

This is significant because work is no longer necessarily initiated only by an active conversation. A durable instruction plus a schedule or event source can cause later execution.

### Codex Cloud

Codex Cloud uses reusable project environments containing repositories, tools, dependencies and access settings. Each task runs in its own isolated workspace on OpenAI-managed computers and can continue while the user's computer is asleep.

The useful reference distinction is:

- reusable environment definition;
- per-task isolated execution instance;
- task state that outlives the initiating client session.

This is particularly relevant to RumiAI because current m facilities already separate lifecycle orchestration, persistent state, package/runtime resolution and live scenario instances, but none of those current contracts should be reclassified as an AI-agent runtime by analogy alone.

### Dots

On September 29, 2026 OpenAI introduced dots as always-on agents that can hold an ongoing goal, use connected apps, run on their own cloud computer, continue making progress between conversations and return results for review.

The most relevant architectural property is not the product name. It is the explicit distinction between an ongoing responsibility and an individual conversation. The agent can persist while conversations come and go.

OpenAI also exposes controls around what a dot may do autonomously, connected-app access and, in eligible managed workspaces, computer capabilities and custom rules. This makes authorization and autonomy policy first-class concerns rather than incidental prompt text.

## Plugins, apps and MCP

OpenAI's current plugin model separates reusable workflow packaging from external service connectivity.

A plugin may contain:

- reusable instructions or skills;
- connected apps;
- app templates;
- interactive extensions and views.

An app connects ChatGPT or Codex to an external service and remains subject to its own authorization and workspace controls. Installing a plugin does not bypass the underlying provider's permissions.

Custom MCP apps can expose tools and, where supported, write or modify actions. OpenAI also documents MCP events for starting automations and interactive plugin extensions for forms, sidebars, viewers and editors.

The architectural lessons worth studying are:

- capability packaging is separate from account authorization;
- workflow guidance is separate from external service connectivity;
- read access, write actions and approval requirements can have different controls;
- the same capability can be surfaced through different interaction modes;
- event delivery can initiate work without making the external service the owner of task semantics.

These patterns are conceptually compatible with RumiAI's general preference for provider-independent contracts, but ChatGPT plugins must not be mapped directly onto m package facilities. Package facilities currently describe package/runtime capabilities with their own provider and compatibility semantics; SaaS accounts, user authorization and AI actions are different responsibilities.

## Projects, Space, Pages and artifacts

Projects group related chats, files and instructions so work can continue with shared context over time.

On September 29, OpenAI introduced ChatGPT Space as a home for files, Pages and related work, while Projects remain separate. Pages are editable collaborative documents that can be created from conversations or directly, and multiple collaborators can work on the same Page while each uses their own ChatGPT.

This suggests several distinct forms of persistence:

- conversational history;
- project-scoped context;
- shared source files;
- editable produced artifacts;
- collaboration and access-control metadata.

A future RumiAI design should not assume that all persistent AI context is one undifferentiated memory store. The current RumiAI state model already provides storage classes and ownership mechanics, but it does not currently define the semantic AI concepts above.

## Voice and channel independence

In September 2026 OpenAI added plugin use to Live voice and made Voice available in Work. A user can start work by speaking, invoke connected capabilities, and let unfinished work continue in text after the voice session ends.

This is useful evidence that interaction modality and task lifecycle should remain separable. Voice, text, browser interaction and other future channels need not own the underlying task semantics.

## Human control, permissions and safety boundaries

Current ChatGPT behavior exposes several different control layers:

- provider-account permissions for connected apps;
- workspace-level enablement and role controls;
- action approval requirements;
- per-agent autonomy/rule controls for dots;
- confirmation before consequential browser actions;
- model-side safety monitoring that may pause or stop an agentic interaction for review.

The important reference point for RumiAI is that capability, authorization, execution and approval are separate dimensions.

This also reinforces an existing RumiAI boundary: the current m user-state scope is explicitly not an authentication or security identity. A future AI authorization model must not be inferred automatically from state/user or filesystem placement.

## Relationship to the current RumiAI architecture

Current RumiAI authority defines:

- m as the low-level technical substrate;
- RumiAI as the branded upper layer;
- state-path and the state model for managed mutable state;
- pkg for package/provider/facility resolution;
- mk for development lifecycle orchestration;
- srv for portable service lifecycle;
- testlab for developer-facing live scenario environments.

These mechanisms already demonstrate useful separation of responsibilities such as selection versus realization, declarative intent versus execution, persistent lifecycle state versus transient process state and scenario definition versus scenario instance.

However, the current specifications do not promote ChatGPT-like concepts such as always-on AI agents, AI-task identity, conversational memory, agent authorization, AI capability composition or collaborative AI workspaces as RumiAI contracts.

That absence is important. The correct use of ChatGPT here is as an external reference for discovering responsibilities and failure modes, not as a vocabulary source from which to copy product concepts into RumiAI.

## RumiAI evaluation

### Reuse

Low as a RumiAI foundation.

ChatGPT is a hosted product whose internal runtime is not a reusable RumiAI component. It can of course be used as an external development or productivity service, but that is different from reusing its architecture inside RumiAI.

### Integration

Potentially useful where a concrete future requirement justifies connecting RumiAI to OpenAI services or standards that ChatGPT exposes or consumes.

Any integration should depend on an independently defined RumiAI contract and should not make ChatGPT-specific product concepts such as Work, dots, Space or plugins into RumiAI primitives by convenience.

MCP and other published interoperability surfaces deserve separate evaluation where a real integration requirement appears.

### Reference

Very high.

ChatGPT is currently one of the strongest live references for studying the transition from conversational AI to a broader agentic operating environment. Particularly useful subjects are:

- long-lived responsibility versus individual conversation;
- asynchronous and event-triggered work;
- per-task execution isolation;
- reusable execution environments;
- capability composition;
- external-account authorization;
- action approval;
- collaboration and artifact ownership;
- interaction-channel independence;
- human supervision of autonomous work.

## Architectural cautions

### Rapid product evolution

ChatGPT changes quickly and many features are staged rollouts, plan-dependent, workspace-dependent or region-dependent. This document must therefore remain a dated snapshot and must be refreshed before supporting a new RumiAI design decision.

### Product taxonomy is not architecture

Names such as Work, dot, Space, Page, plugin and Site are OpenAI product concepts. Similar-looking RumiAI responsibilities may ultimately have different boundaries or may not be needed at all.

No RumiAI command, API, namespace, directory or component name is established by this evaluation.

### Cloud and account assumptions

Several important ChatGPT capabilities depend on OpenAI-managed cloud computers, OpenAI accounts and workspace administration.

RumiAI's current architecture targets a portable technical substrate and has its own state and package semantics. Cloud placement, account identity, collaboration and remote execution must therefore be evaluated independently rather than imported as defaults.

### Security and autonomy

Persistent agents with connected accounts and write-capable tools create stronger consequences than conversational retrieval alone.

A future RumiAI design would need explicit answers for authority, approval, credentials, provenance, auditing, recovery after interruption and the boundary between user intent and autonomous continuation before granting comparable capabilities.

## Current assessment

ChatGPT should be treated as a **high-value reference architecture under active observation**, not as a blueprint.

The most important signal from the September 2026 changes is the convergence of persistent intent, asynchronous execution, isolated computers, reusable capabilities, connected data/actions, event sources, artifacts and human approval into one product ecosystem while still keeping several of those responsibilities separately controllable.

For RumiAI, the immediate value is to use these observations when identifying future upper-layer responsibilities while preserving the existing m/RumiAI boundary and avoiding premature naming or architecture.

## Open verification work

Future refreshes should pay particular attention to:

- how dots evolve after the initial rollout, especially lifecycle, memory, recovery and ownership;
- whether plugin/app/MCP permission boundaries stabilize across Chat, Work, Codex and dots;
- the relationship between Scheduled Tasks, event-triggered automations and always-on agents;
- persistence and portability of Codex Cloud environments and task state;
- how Space, Projects and Pages divide context, artifacts and collaboration;
- how approval rules are represented and audited;
- whether additional public interoperability surfaces appear for agent execution, identity or task state.

## Upstream sources consulted

- ChatGPT release notes: https://help.openai.com/en/articles/6825453-chatgpt-release-notes
- ChatGPT Work and Codex: https://help.openai.com/en/articles/20001275-chatgpt-work-and-codex
- Plugins in ChatGPT and Codex: https://help.openai.com/en/articles/20001256-plugins-in-chatgpt-and-codex
- Scheduled tasks in ChatGPT: https://help.openai.com/en/articles/10291617-scheduled-tasks-in-chatgpt
- Using Codex Cloud: https://help.openai.com/en/articles/20001545-using-codex-cloud
- Getting started with your dot: https://help.openai.com/en/articles/20001530-getting-started-with-your-dot
- ChatGPT Space sharing/data/controls: https://help.openai.com/en/articles/20001544-chatgpt-space-sharing-data-and-controls
- Projects in ChatGPT: https://help.openai.com/en/articles/10169521-projects-in-chatgpt
- Developer mode and MCP apps in ChatGPT: https://help.openai.com/en/articles/12584461-developer-mode-and-full-mcp-connectors-in-chatgpt

## Verification notes

This evaluation is based on OpenAI's official public product documentation and release notes as observed on 2026-10-01. Product availability, pricing, model access, rollout status and region restrictions are intentionally treated as time-sensitive upstream facts rather than RumiAI contracts.

No ChatGPT runtime behavior, security property or operational guarantee was independently validated by RumiAI testing in this work unit.
