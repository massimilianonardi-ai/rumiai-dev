# Web access sense

Status: Active
Updated: 2026-10-06

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: 5ecf510b1fc8c232bf902e3820a00c94ebe4b9cc
- rumiai-os: f4d28822c4a2a875bd816ec3b15477dcfa905706
- rumiai-tests: 80176d5e8cef61d5bc792555a9b957c0f3600044
- rumiai-dev-PoCs: 3c00148a4800cb8556be1f8856546d529001c6cb
- rumiai-web-control: 92f9e377c10ef3bc9dc8bba31648da273bd5f0e0
- pkg-catalog: 86f668dab8fe71b656176c0fe2b86d402e872bf9

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/SENSE-MODEL.md
- specifications/rumiai-os/WEB-CONTROL.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/MK.md
- specifications/rumiai-os/SERVICE-LIFECYCLE.md
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

### Remaining implementation design

The canonical `web-sense` / `web-control` boundary, `web-control` ownership, independent-project placement, package/facility identity and baseline deterministic contract now live in `specifications/rumiai-os/WEB-CONTROL.md` and are no longer duplicated here.

The first concrete provider is still planned around Node.js + Playwright + a Chromium-class browser, using PoC 057 as implementation evidence. Playwright/CDP/Chromium remain provider details rather than canonical API.

The independent `rumiai-web-control` repository now exists and contains the promoted controller implementation, client/service commands, `mk.json`, end-to-end tests and release build workflow. The current remaining promotion step is to obtain a successful multi-platform build/release artifact and then add the concrete runtime package/provider metadata to `pkg-catalog`.

Open packaging questions that remain implementation-specific:

- exact Node.js facility compatibility range for the first provider;
- whether the first provider consumes an explicit Chromium-class browser facility or temporarily owns a concrete browser package dependency until such a facility contract is justified;
- release artifact construction for vendored/bundled Playwright runtime dependencies without requiring network package installation at runtime;
- exact private local IPC transport, while preserving the canonical requirement that raw debugger exposure is not the ordinary interface.

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
- The project-wide definition of `sense` has been promoted to `specifications/rumiai-os/SENSE-MODEL.md` and referenced by the high-level current model.
- The general first-party source/distribution placement rule has been promoted into `CURRENT-MODEL.md`: semantic ownership is independent from repository/release placement; coherent independently releasable capabilities may live in separate projects even when semantically owned by `m` or RumiAI.
- `specifications/rumiai-os/WEB-CONTROL.md` now canonically defines `web-control` as the deterministic `m` capability, `web-sense` above it, independent project/package identity `rumiai-web-control`, facility identity `web-control`, persistent profile/page semantics, deterministic inspect/capture/interaction baseline, privileged debug boundary and `srv` lifecycle.
- `pkg-catalog` now defines facility `web-control` compatibility 1 with public command `web-control` and provider-backed foreground service semantics. No concrete provider is declared until a real release artifact exists.
- PoC 057 (`rumiai-dev-PoCs/pocs/057-web-control-browser-controller`) implements the proposed controller boundary with Node.js + Playwright + persistent Chromium behind a local Unix-domain socket. GitHub Actions run 37440924848 completed successfully on Ubuntu 24.04 / Node 22. The experiment mechanically validated dynamic post-fetch DOM observation, deterministic fill/click, popup page registration, HTML/text/PNG/MHTML capture, page-scoped raw CDP `Runtime.evaluate`, and cookie/localStorage persistence across controller/browser restart using the same dedicated profile.
- Local syntax checks for the PoC JavaScript passed. Local runtime execution was not obtained because dependency installation could not complete in the local tool environment; the successful GitHub Actions run is the runtime validation evidence.

## Current state

The Web control contract is canonical in `specifications/rumiai-os/WEB-CONTROL.md`. `web-control` is semantically `m`-owned but source/distribution-independent as project `rumiai-web-control`; `mk` owns project development lifecycle and `pkg` owns runtime installation/integration. `pkg-catalog` contains provider-independent facility `web-control` compatibility 1 but still intentionally has no concrete `rumiai-web-control` provider package until a real release artifact exists.

`rumiai-web-control` now contains the first real provider implementation derived from PoC 057: Node.js + Playwright + persistent Chromium, public `web-control` client, foreground `web-control-service`, local private socket, persistent profile, navigation/inspection/capture/interactions, page-scoped CDP extension, end-to-end tests and release-build automation. Current CI run 37452061908 is still in progress for Linux and macOS; both jobs have completed Node/dependency setup and are currently installing Playwright Chromium before runtime/build validation. No GitHub release has been published yet.

## Next action

Complete current Linux/macOS validation and publish the first versioned `rumiai-web-control` release artifact. Then add the concrete `rumiai-web-control` provider package metadata to `pkg-catalog`, validate `pkg install` + facility selection + `srv start/stop web-control`, and only after that start the `web-sense` consumer/integration layer.

## Blockers / open questions

Current CI has already exposed and resolved several integration mismatches: package-default Node.js versus facility projection, explicit `osarch update` on clean `rumiai-os` checkouts, and a macOS CI-only fallback for obtaining Node.js 26 when the managed package download path receives HTTP 403. The latter is validation-environment handling, not a change to the runtime package contract.

- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
- Settle the first provider's Node/browser dependency packaging and release-artifact shape before adding the concrete `rumiai-web-control` package definition/provider realization to `pkg-catalog`.
