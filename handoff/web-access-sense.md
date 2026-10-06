# Web access sense

Status: Active
Updated: 2026-10-06

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: 3f2f5209f2bb27915f36ddc1318f1cc059e0cee5

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- handoff/README.md

## Fixed task-local choices

- Treat this as a general RumiAI capability, not an Amazon-specific scraper.
- The design must support dynamic JavaScript-driven sites and must permit site-specific helpers or specialist external tools where a generic browser is not the best provider.
- Avoid third-party scraping services such as ZenRows as a required architectural dependency.
- A user-owned machine/browser is an acceptable and likely necessary execution locus for the general capability.
- ChatGPT interoperability is a first-class usability requirement; the design must cover both API-based and non-API interaction paths.
- The capability must not be coupled to ChatGPT: ChatGPT is one possible client/integration surface.

## Acceptance scenarios

1. A user asks RumiAI in natural language to monitor a public Amazon wishlist for worthwhile offers; RumiAI can choose a reasonable schedule, use the web capability to obtain current observable data, and report meaningful changes without the user having to build an Amazon-specific application.
2. A user working in ChatGPT Desktop can invoke the RumiAI web capability with minimal setup and without requiring direct OpenAI API use when the product surface supports a local integration.
3. A cloud-scheduled ChatGPT task can use the same RumiAI capability when a supported secure bridge to the user's online machine is available, without exposing a raw browser debugging port to the public Internet.
4. When a specialized provider such as yt-dlp is a better fit than generic browser automation, the same public capability can route to it without changing the user's high-level intent.
5. A site requiring human login, consent or challenge handling can hand control to the user and then continue using the same persistent browser profile/session rather than attempting to bypass the challenge.

## Working design

### Naming under evaluation

Candidate public sense identity: `web`.

Reasons currently favoring `web`:
- names the domain/capability rather than one implementation;
- does not conflate the capability with an autonomous agent;
- does not bind the contract to browser automation;
- can encompass a real browser, raw HTTP, site-native protocols, site-specific adapters and specialist extractors.

Names currently considered weaker:
- `browser-use`: implementation-oriented and collides conceptually with existing product/project naming;
- `web-agent`: suggests ownership of agency/planning rather than a sense/capability;
- `browser`: too narrow for non-browser providers such as specialist extractors.

No public name is promoted yet.

### Capability/provider separation

The public capability should describe web observation/interaction. Provider selection remains an internal concern. Candidate provider classes include:
- real browser via Chrome/Chromium + CDP/Playwright;
- raw HTTP for simple resources;
- site-native structured tools/protocols when available (including WebMCP-like capabilities);
- site-specific adapters/helpers for stable semantic extraction;
- specialist tools such as yt-dlp where they provide materially better domain behavior.

The real browser should use a dedicated persistent RumiAI-controlled profile rather than the user's ordinary browser profile. Human-interaction-required states (login, consent, CAPTCHA/challenge) should be surfaced rather than bypassed.

### ChatGPT integration model

Keep the web sense contract independent from ChatGPT and add bridges/adapters around it.

Candidate interaction paths:
1. OpenAI API client -> RumiAI capability.
2. ChatGPT Desktop local MCP/plugin -> local RumiAI capability, where supported.
3. ChatGPT cloud/web scheduled task -> secure tunnel/remote MCP bridge to the local capability while the user-owned machine is online, where supported.
4. Browser/UI automation of ChatGPT itself -> compatibility fallback for environments where no programmatic/plugin bridge is available; this should not become the primary contract.

Current OpenAI product evidence indicates:
- ChatGPT plugins may contain local MCP apps that run on the user's computer in ChatGPT Desktop; those local tools are not automatically available on web/mobile.
- ChatGPT can connect to private/local MCP servers via Secure MCP Tunnel on supported product surfaces.
- scheduled tasks run in ChatGPT cloud and can use supported connected apps/plugins, but a local-only tool cannot be assumed reachable when the user's machine/bridge is unavailable.
- ChatGPT Desktop site tools use WebMCP when a website exposes them, making site-native structured interaction relevant to provider selection.

### Scheduling ownership

Do not assume scheduling belongs to one product.

Candidate policy:
- if the initiating client has a scheduler capable of reaching the sense at run time, it may own the schedule;
- otherwise RumiAI owns the local schedule and may use ChatGPT as a reasoning/interface client at execution time;
- the user intent should remain the same regardless of which scheduler ultimately owns execution.

This is still working design and requires explicit contract design before promotion.

## Completed

- Performed mandatory RumiAI preflight against current rumiai-dev main.
- Confirmed no current canonical browser/web-agent/sense responsibility exists in rumiai-dev.
- Established ChatGPT interoperability as a first-class design dimension before implementation design starts.
- Verified current OpenAI support for local MCP apps in ChatGPT Desktop, remote/private MCP access through Secure MCP Tunnel, scheduled tasks using supported apps/plugins, and WebMCP-backed site tools.

## Current state

The task is in architecture/naming exploration. No product/runtime implementation or canonical specification has been created or modified.

The strongest current naming candidate is `web`, but it is not yet promoted.

The most important architectural boundary is one provider-independent local RumiAI web capability with multiple integration bridges, rather than separate Amazon/ChatGPT/browser subsystems.

## Next action

Settle the public identity and the capability boundary first; then design the smallest provider-independent contract and the ChatGPT bridge behavior before choosing implementation details.

## Blockers / open questions

- Confirm the public sense name (`web` is the current leading candidate).
- Define the exact boundary between sense/capability, planning/agent behavior and scheduling.
- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
- Decide the minimal provider interface and provider-resolution semantics only after the public capability contract is clear.
