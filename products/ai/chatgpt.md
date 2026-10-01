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

This is particularly relevant to RumiAI because the project already has substantial standalone Computer Use and Computer Control implementations, while current m facilities separate lifecycle orchestration, persistent state, package/runtime resolution and live scenario instances. The remaining problem is not absence of computer-use capability; it is how mature standalone capabilities are reworked behind stable modular boundaries and supported by the portable substrate without reclassifying unrelated m contracts as an AI-agent runtime.

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

Those current rumiai-os contracts are only part of the comparison baseline. RumiAI also already has two substantial standalone projects that predate the broader modular integration work:

- `rumiai-computer-control` owns backend-neutral desktop observation and action semantics behind a versioned external boundary;
- `rumiai-computer-use` owns semantic task planning/orchestration, capability/provider/skill selection, context sessions, recovery, perception policy and task-success verification.

The current Computer Use implementation is not merely a prototype. Its recorded validation lineage includes a semantic-first visual fallback, explicit separation between event delivery and verified task success, provider-neutral visual interpretation, deterministic target resolution, explicit fallback authorization, independent post-action verification and trusted resource provenance through the product task-invocation boundary. The current active program moves outward toward higher-level invocation/integration.

This existing work materially changes the ChatGPT comparison: RumiAI does not need to discover computer use from zero. It already has a strong implementation and evidence base for one of the hardest agentic capabilities.

At the same time, the current standalone Computer Use and Computer Control products were not originally designed as modules inside a larger RumiAI composition model. Their absence from the current rumiai-os specification index is therefore not evidence that the capability was forgotten or that the documentation router is defective. It reflects the current integration boundary: these projects are valuable standalone implementations but are not yet promoted as integrated rumiai-os/RumiAI modules.

Computer Control is already comparatively close to a reusable external component because its repository exposes a backend-neutral contract, runtime, SDKs and adapters. It may therefore be reusable with relatively limited adaptation.

Computer Use needs more architectural work before it can serve the wider system. The intended direction is that higher-level RumiAI modules should be able to consume a compatible external Computer Use capability rather than being coupled to this implementation, while the current Computer Use implementation itself must expose a stable boundary suitable for use by other modules. Its current internal composition and standalone assumptions must not become the general RumiAI architecture merely because the implementation performs well.

This is also part of the motivation for the current rumiai-os/m work: mature AI modules need a stable substrate for portable, relocatable and isolated component installation, runtime/provider selection, state, services and lifecycle mechanics. The substrate is being generalized underneath those capabilities rather than embedding their one-off runtime assumptions into every module.

The architectural lesson from the existing RumiAI work therefore differs from a greenfield reading of ChatGPT:

```text
m / rumiai-os
    stable portable substrate

compatible external capabilities
    Computer Control
    Computer Use
    other future modules/providers

higher-level RumiAI composition
    consumes capabilities through stable boundaries
    without hard-coding one standalone implementation
```

This is a direction of integration, not a promoted API or namespace. The exact modular contracts, provider semantics and component identities still require their normal RumiAI design process before becoming current specification.

ChatGPT remains useful here because it exposes many of the same system-level pressures from another direction: persistent work, computer execution, tool composition, authorization, events, artifacts and human review. RumiAI can compare those pressures against capabilities it has already implemented and against the infrastructure now being generalized beneath them, rather than treating ChatGPT as a starting blueprint.

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

For RumiAI, the immediate value is to compare these observations with capabilities that already exist in standalone form, especially Computer Use and Computer Control, and to use the comparison while modularizing them over the stable m substrate. The goal is not to reproduce ChatGPT's product structure, but to preserve the strong existing behavior while making capabilities replaceable and consumable by other RumiAI modules through contracts that are deliberately designed rather than inherited from the standalone implementations.

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

## RumiAI comparison snapshot

RumiAI-side observations in this revision were checked against:

- `rumiai-dev` at `512d9e1cb3c1021e03118f61a059f8d26d2ebe23` before this update;
- `rumiai-computer-use` at `cd1d189776e96d7f8625b367eaa76a2572de394a`;
- `rumiai-computer-control` at `e3a3f13d66546cf8f0fca50075bd4607c2c3d003`.

The modular-integration assessment also incorporates the current project direction that the standalone Computer Use and Computer Control results are strong but are not yet the integrated modular form intended for the broader RumiAI system. In particular, future higher-level composition should be able to consume a compatible Computer Use capability through an explicit boundary rather than depending intrinsically on the present standalone implementation.

## Verification notes

This evaluation is based on OpenAI's official public product documentation and release notes as observed on 2026-10-01. Product availability, pricing, model access, rollout status and region restrictions are intentionally treated as time-sensitive upstream facts rather than RumiAI contracts.

No ChatGPT runtime behavior, security property or operational guarantee was independently validated by RumiAI testing in this work unit. RumiAI Computer Use/Computer Control claims are bounded to the current repository documentation and recorded validation state inspected for this comparison; this documentation update did not execute new physical validation.
