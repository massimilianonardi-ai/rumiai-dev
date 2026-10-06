# Web access sense

Status: Active
Updated: 2026-10-06

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: c5514ead3073b2aafcddcf8521a33f38db0201f5

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- handoff/README.md

## Fixed task-local choices

- The public sense name is fixed as `web-sense`.
- Treat this as a general RumiAI capability, not an Amazon-specific scraper.
- The design must support dynamic JavaScript-driven sites and must permit site-specific helpers or specialist external tools where a generic browser is not the best provider.
- Avoid third-party scraping services such as ZenRows as a required architectural dependency.
- A user-owned machine/browser is an acceptable and likely necessary execution locus for the general capability.
- ChatGPT interoperability is a first-class usability requirement; the design must cover both API-based and non-API interaction paths.
- The capability must not be coupled to ChatGPT: ChatGPT is one possible client/integration surface.
- `web-sense` must support authenticated user sessions through a dedicated persistent browser profile and may interact with sites through generic browser capabilities or site-specific adapters/helpers.
- The first implementation/design baseline is intentionally small: navigate a page, preserve/export/save page evidence, and expose controlled debugger/introspection access. Higher-level site semantics come later.

## Acceptance scenarios

1. A user asks RumiAI in natural language to monitor a public Amazon wishlist for worthwhile offers; RumiAI can choose a reasonable schedule, use the web capability to obtain current observable data, and report meaningful changes without the user having to build an Amazon-specific application.
2. A user working in ChatGPT Desktop can invoke the RumiAI web capability with minimal setup and without requiring direct OpenAI API use when the product surface supports a local integration.
3. A cloud-scheduled ChatGPT task can use the same RumiAI capability when a supported secure bridge to the user's online machine is available, without exposing a raw browser debugging port to the public Internet.
4. When a specialized provider such as yt-dlp is a better fit than generic browser automation, the same public capability can route to it without changing the user's high-level intent.
5. A site requiring human login, consent or challenge handling can hand control to the user and then continue using the same persistent browser profile/session rather than attempting to bypass the challenge.

## Working design

### Naming

The task-local public sense identity is fixed as `web-sense`. It keeps the broad Web domain while making the architectural role explicit and avoiding ambiguity with generic `web` terminology. This remains task-local design state until the subsystem contract is promoted into a canonical specification.

### Initial baseline

Start from a deliberately small browser-backed baseline before designing site-specific semantics:
- open/navigate a URL in a real browser session;
- retain authenticated session state in a dedicated persistent profile;
- export/save the observed page in useful forms (at minimum rendered/current document evidence, with exact formats still to be designed);
- expose layered introspection suitable for agents, from safe page/source/DOM/network/runtime inspection up to an explicitly privileged debugger attachment;
- keep raw debugger access local/controlled rather than making an unrestricted browser-debug endpoint the ordinary public interface.

This baseline should be sufficient to reproduce the earlier class of workflows such as saving complete ChatGPT conversations, while allowing later site adapters to build higher-level semantic operations.


### Deterministic / AI boundary

Preferred working boundary: `web-sense` is deterministic. It exposes observable web/browser operations and returns evidence; it does not interpret user goals, choose autonomous plans, judge business meaning, or own scheduling policy.

AI reasoning stays above `web-sense` in the RumiAI layer. The AI layer interprets page evidence, chooses subsequent operations, composes workflows and decides when or why work should be scheduled or notifications emitted.

Site-specific adapters may still belong inside `web-sense` when they implement deterministic semantic operations. For example, an Amazon wishlist extractor or ChatGPT conversation exporter can be deterministic even though it is site-specific. AI belongs above the boundary only when interpretation or planning is required.

This remains working design until promoted to a canonical specification.

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
2. ChatGPT plugin/custom MCP -> RumiAI MCP capability. ChatGPT itself connects to remote MCP endpoints; a server that remains local/private is reached through Secure MCP Tunnel where the user's plan/workspace supports it.
3. ChatGPT cloud/web scheduled task -> the same plugin/MCP surface only when the task runtime supports that plugin and the tunnel/private endpoint is reachable while the user-owned machine is online.
4. Browser/UI automation of ChatGPT itself -> compatibility fallback for environments where no programmatic/plugin bridge is available; this should not become the primary contract.

Current OpenAI product evidence indicates:
- ChatGPT custom MCP connections target remote MCP servers; OpenAI explicitly documents that a localhost/private/on-prem server is not connected directly and should use Secure MCP Tunnel when supported.
- Plugins can include local app components on ChatGPT Desktop, but that is distinct from ChatGPT directly attaching to an arbitrary localhost MCP server; local plugin tools are not automatically available on web/mobile.
- Full custom MCP read/write support is currently plan/workspace dependent; OpenAI documents full MCP for Business/Enterprise/Edu and more limited developer-mode access for Pro, so RumiAI must not make current ChatGPT plan entitlements part of its own core contract.
- scheduled tasks can use supported plugin/connected-app capabilities, but a private RumiAI capability remains dependent on the supported plugin/tunnel path and on the user's machine being online/reachable.
- ChatGPT Desktop site tools use WebMCP when a website exposes them, making site-native structured interaction relevant to provider selection.
- ChatGPT's built-in desktop browser has its own browser state and can share a live page with ChatGPT; this is a separate integration surface from RumiAI controlling its own browser.

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
- Verified current OpenAI support for custom MCP plugins, Secure MCP Tunnel for private/local MCP reachability, scheduled tasks using supported apps/plugins, desktop site tools backed by WebMCP, and the built-in ChatGPT desktop browser. Corrected the earlier provisional assumption that ChatGPT could directly attach to an arbitrary localhost MCP server.
- User approved `web-sense` as the task-local public identity and fixed the initial browser baseline around navigation, page export/save and debugger/introspection access.

## Current state

The task is in architecture/naming exploration. No product/runtime implementation or canonical specification has been created or modified.

The task-local name is now fixed as `web-sense`; canonical specification promotion has not happened yet.

The most important architectural boundary is one provider-independent local RumiAI web capability with multiple integration bridges, rather than separate Amazon/ChatGPT/browser subsystems.

## Next action

Design the smallest provider-independent baseline contract for page navigation, export/save and layered introspection/debug access, then validate it with a browser-backed PoC before adding site-specific adapters.

## Blockers / open questions

- Confirm and promote the preferred deterministic `web-sense` boundary, with planning/interpretation/scheduling remaining above it.
- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
- Decide the exact export artifacts and introspection/debug privilege boundaries.
- Decide the minimal provider interface and provider-resolution semantics only after the public capability contract is clear.
