# Web access sense

Status: Active
Updated: 2026-10-06

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: 4ba4645abc1faf09fc751e1088d9b98824ffa5ee

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- handoff/README.md

## Fixed task-local choices

- The AI-level Web sense is fixed as `web-sense`.
- The deterministic Web control/access substrate is fixed as `web-control` for the current task design.
- Treat this as a general RumiAI capability, not an Amazon-specific scraper.
- The design must support dynamic JavaScript-driven sites and must permit site-specific helpers or specialist external tools where a generic browser is not the best provider.
- Avoid third-party scraping services such as ZenRows as a required architectural dependency.
- A user-owned machine/browser is an acceptable and likely necessary execution locus for the general capability.
- ChatGPT interoperability is a first-class usability requirement; the design must cover both API-based and non-API interaction paths.
- The capability must not be coupled to ChatGPT: ChatGPT is one possible client/integration surface.
- `web-control` must support authenticated user sessions through a dedicated persistent browser profile and may interact with sites through generic browser capabilities or deterministic site-specific adapters/helpers.
- The first deterministic implementation/design baseline is intentionally small: navigate a page, preserve/export/save page evidence, and expose controlled debugger/introspection access. Higher-level AI semantics belong to `web-sense` and come later.

## Acceptance scenarios

1. A user asks RumiAI in natural language to monitor a public Amazon wishlist for worthwhile offers; RumiAI can choose a reasonable schedule, use the web capability to obtain current observable data, and report meaningful changes without the user having to build an Amazon-specific application.
2. A user working in ChatGPT Desktop can invoke the RumiAI web capability with minimal setup and without requiring direct OpenAI API use when the product surface supports a local integration.
3. A cloud-scheduled ChatGPT task can use the same RumiAI capability when a supported secure bridge to the user's online machine is available, without exposing a raw browser debugging port to the public Internet.
4. When a specialized provider such as yt-dlp is a better fit than generic browser automation, the same public capability can route to it without changing the user's high-level intent.
5. A site requiring human login, consent or challenge handling can hand control to the user and then continue using the same persistent browser profile/session rather than attempting to bypass the challenge.

## Working design

### Naming

The task-local public sense identity is fixed as `web-sense`. It keeps the broad Web domain while making the architectural role explicit and avoiding ambiguity with generic `web` terminology. This remains task-local design state until the subsystem contract is promoted into a canonical specification.

### Initial deterministic baseline

Start from a deliberately small `web-control` browser-backed baseline before designing AI-level Web semantics:
- open/navigate a URL in a real browser session;
- retain authenticated session state in a dedicated persistent profile;
- export/save the observed page in useful forms (at minimum rendered/current document evidence, with exact formats still to be designed);
- expose layered introspection suitable for agents, from safe page/source/DOM/network/runtime inspection up to an explicitly privileged debugger attachment;
- keep raw debugger access local/controlled rather than making an unrestricted browser-debug endpoint the ordinary public interface.

This baseline should be sufficient to reproduce the earlier class of workflows such as saving complete ChatGPT conversations, while allowing later site adapters to build higher-level semantic operations.


### Sense / control boundary

Current preferred architecture:

```text
RumiAI / AI
    |
    v
web-sense
    |
    v
web-control
    |
    +-- browser/CDP/Playwright
    +-- HTTP
    +-- deterministic site adapters/helpers
    +-- specialist deterministic tools
```

`web-control` is the deterministic substrate. It owns concrete Web/browser state and operations: profiles, sessions, pages, navigation, capture/export, inspection, interaction primitives, downloads/uploads where applicable, network/runtime evidence and controlled debugger access. It performs explicitly requested operations and returns observable evidence; it does not infer user intent or autonomously plan a workflow.

`web-sense` is the AI/cognitive Web capability. It interprets evidence returned by `web-control`, understands page meaning in relation to the user's goal, chooses which deterministic operation or adapter to invoke next, and composes multi-step Web behavior. It may use generic browser interaction or deterministic site-specific helpers without exposing those implementation choices to the user.

This makes `sense` a higher-level perceptive/interactive modality rather than a raw sensor or control surface. The model parallels the earlier Computer Use / Computer Control separation: deterministic control below, AI-mediated use/perception above.

Generic scheduling remains outside the sense/control pair. RumiAI may schedule repeated use of `web-sense`, but neither `web-sense` nor `web-control` should own the general scheduling mechanism.

Site-specific adapters are classified by semantics rather than specificity: a deterministic Amazon wishlist extractor, ChatGPT conversation exporter or yt-dlp-backed metadata helper belongs below the AI boundary and may be exposed through `web-control`; an adapter that requires interpretation/planning belongs in or above `web-sense`.

The public AI-level name `browser-use` is rejected for this architecture because it is narrower than the Web domain and conflates one interaction mechanism with the broader sense. It remains a useful descriptive phrase for one behavior implemented by `web-sense` over `web-control`.

This remains task-local design until promoted to a canonical specification.

### Capability/provider separation

`web-control` should provide the deterministic provider-independent Web access/control surface. `web-sense` consumes that surface and keeps provider selection and low-level mechanics out of the user's intent. Candidate provider classes include:
- real browser via Chrome/Chromium + CDP/Playwright;
- raw HTTP for simple resources;
- site-native structured tools/protocols when available (including WebMCP-like capabilities);
- site-specific adapters/helpers for stable semantic extraction;
- specialist tools such as yt-dlp where they provide materially better domain behavior.

The real browser should use a dedicated persistent RumiAI-controlled profile rather than the user's ordinary browser profile. Human-interaction-required states (login, consent, CAPTCHA/challenge) should be surfaced rather than bypassed.

### ChatGPT integration model

Keep both `web-sense` and `web-control` independent from ChatGPT and add bridges/adapters around the AI-level capability as appropriate.

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
- User approved `web-sense` as the AI-level Web sense. After re-evaluating the meaning of "sense" against the Computer Use / Computer Control separation, the task design now uses `web-control` for the deterministic substrate and `web-sense` for the AI/cognitive layer. The initial deterministic browser baseline remains navigation, page export/save and controlled debugger/introspection access.

## Current state

The task is in architecture/naming exploration. No product/runtime implementation or canonical specification has been created or modified.

The task-local names are now fixed as `web-sense` for the AI/cognitive layer and `web-control` for the deterministic layer; canonical specification promotion has not happened yet.

The most important architectural boundary is one provider-independent local RumiAI web capability with multiple integration bridges, rather than separate Amazon/ChatGPT/browser subsystems.

## Next action

Design the smallest provider-independent `web-control` contract for page navigation, export/save, interaction primitives and layered introspection/debug access; then define the minimal `web-sense` contract that composes those deterministic capabilities before validating the split with a browser-backed PoC.

## Blockers / open questions

- Promote the `web-sense` (AI) / `web-control` (deterministic) boundary once the two minimal contracts are sufficiently settled.
- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
- Decide the exact export artifacts and introspection/debug privilege boundaries.
- Decide the minimal provider interface and provider-resolution semantics only after the public capability contract is clear.
