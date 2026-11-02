# OpenBot

Status: **External product evaluation / non-normative**
Evaluated: 2026-11-02

## Identity

- Upstream: https://github.com/CopilotKit/OpenBot
- Evaluated default branch: `main`, revision `c396a5f68c817043846f1ca3c2b42061ee73ceb5`
- License: MIT for the repository, as declared in upstream LICENSE.
- Main implementation: TypeScript, Bun, React/Vite, Hono, PostgreSQL, Docker and Chromium.
- Upstream labels the project beta and explicitly calls it **a template, not a finished packaged product**.

## Purpose and upstream model

OpenBot is a self-hostable starting point for a customizable AI coworker environment: channels and bots use AG-UI endpoints, each bot receives governed tools and browser/file access, and an operator can watch live operation, interrupt, approve or take control. Browser/file/MCP actions pass through a server-side authorization/audit gateway.

The architectural roles described upstream include a frontend app, API/policy/audit gateway, bot endpoints, browser computers, optional computer supervisor, database, routine worker and CopilotKit Intelligence for durable threads/memory. AG-UI is an external interoperability protocol, not a mandate to use OpenBot's internal model.

## Deployment and dependency realities

- Docker Compose for a development stack; the published single-image deployment includes app, API, Chromium and optional embedded PostgreSQL.
- A CopilotKit Intelligence project/license is required even if the Intelligence service is self-hosted; the self-hosted developer offering has its own terms and limitations. A model API/provider is also necessary.
- The single image does **not** include the multi-computer supervisor or automatic routine/attachment cleanup scheduling; those need distinct deployment support. Without the supervisor, browser computers are shared and are not a tenant-isolation boundary.
- The documented local `OPENBOT_SINGLE_USER=true` mode is an evaluation convenience, not production authentication.
- The shipped startup policy is an explicit allow-all (`allow: ["true"]`) unless replaced, despite the rule evaluator's fail-closed behavior for absent/malformed policies. A real deployment must replace and validate this security policy.
- Optional gVisor integration and other sandbox/network controls depend on the actual host and deployment configuration.

## RumiAI relevance

### Reuse

Moderate only as a self-hostable, customizable application template. It is not a dependency-sized library or a ready-made drop-in orchestration component.

### Integration

Potentially high at the **external application/agent UI** boundary through AG-UI, already separately assessed in `products/ai/ag-ui.md`. That possibility must remain independent of RumiAI's internal sense/control architecture and of OpenBot's Intelligence dependency.

### Reference

Very high for:

- authorization before effects plus auditable decisions and failures;
- treating unattended run origin separately from the person whose authority it carries;
- per-person/per-bot browser/file execution environments and lifecycle;
- manual takeover around authentication/challenges;
- explicit connector/MCP tool grants and effect classification;
- AG-UI interaction, multi-agent handoff, persistent responsibilities and routine scheduling;
- separating cognitive agent endpoints from deterministic computer execution.

## Risks and architectural cautions

- Rapid beta development and the need to clone/customize limit out-of-the-box reuse.
- MIT on OpenBot does not remove the operational/license requirements of CopilotKit Intelligence or its other dependencies.
- Action authorization, process isolation and egress control are distinct; upstream documents limitations of proxy-only egress filtering.
- Browser profiles, delegated credentials, secrets and unattended actions demand independent threat modeling.
- The demo's permissive startup policy must not be mistaken for a secure-by-default authorization posture.
- Do not promote terms such as coworker, computer, channel, responsibility or its policy DSL into RumiAI primitives merely by adopting the example.

## Current assessment

```text
reference     very high for governed agent execution, audit and human control
integration   plausible through AG-UI as an optional external client/host
reuse         moderate; template-level customization, not a small component
adoption      not authorized
```

This is source/documentation analysis at the stated revision. No deployment, security audit, runtime behavior test, user login test or Intelligence license review was executed.
