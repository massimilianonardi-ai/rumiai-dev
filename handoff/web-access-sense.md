# Web access sense

Status: Active
Updated: 2026-10-06

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: 864b55bb78cb132ddf614d4e559f7d9e8c9d83d2
- rumiai-os: 6a964ba3f5c8acf462737e3b92daaf1af32de57e
- rumiai-tests: b8eb4633287958c73c16d369b240cd56eae3d060
- rumiai-dev-PoCs: 3c00148a4800cb8556be1f8856546d529001c6cb
- rumiai-web-control: a3cbc96da7f72c92382fdc76a4e930e661bbc088
- pkg-catalog: 9d3760b950267a7d16bb4e850144570ef60cd3ff

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

The independent `rumiai-web-control` repository contains the promoted controller implementation, client/service commands, `mk.json`, end-to-end tests and release build workflow. Release `v0.1.1` is now published after Linux canonical `mk` validation and macOS runtime validation succeeded in CI run 37604677458. `pkg-catalog` contains `rumiai-web-control@v0.1.1` as `n0002`, preserving `v0.1.0` as the earlier immutable concrete.

The first provider packaging choices remain mechanically settled: the package depends on facilities `chromium =1` and `nodejs =26`, the release artifact is `all`, and the extracted artifact is normalized by `pkg-extract` before package link validation. `v0.1.1` additionally makes the public client tolerate the bounded controller-readiness window after `srv start`: it retries only local-socket `ENOENT`/`ECONNREFUSED` until a 15-second default deadline, configurable through `WEB_CONTROL_CONNECT_TIMEOUT_MS`.

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
- Physical install attempt on 2026-10-07 initially failed at `rumiai-web-control@v0.1.0` provider validation because package link metadata targeted paths before archive-root normalization. `pkg-catalog` was corrected forward so ordinary package commands target normalized-root paths `bin/web-control` and `bin/web-control-service`.
- A subsequent physical install succeeded and the `web-control` facility provider could be selected. `srv start web-control` started the provider process, but an immediate `web-control status` failed with `ENOENT` on the local socket. Inspection showed this was not a user/service HOME mismatch: both commands launch the same package identity. The failure was the documented `srv` readiness gap—`srv start` proves initial process survival but not application readiness, while the controller binds its socket only after Chromium startup. `rumiai-web-control v0.1.1` fixes the client side by performing bounded retries for startup-compatible local-socket errors, and CI run 37604677458 passed on Linux/macOS with the revised implementation.

## Current state

The Web control contract is canonical in `specifications/rumiai-os/WEB-CONTROL.md`. `web-control` is semantically `m`-owned but source/distribution-independent as project `rumiai-web-control`; `mk` owns project development lifecycle and `pkg` owns runtime installation/integration. `pkg-catalog` contains provider-independent facility `web-control` compatibility 1 and first-party provider concretes `rumiai-web-control@v0.1.0` and current `rumiai-web-control@v0.1.1`.

`rumiai-web-control v0.1.1` contains the current first provider implementation: Node.js + Playwright + managed Chromium, public `web-control` client, foreground `web-control-service`, local private socket, persistent profile, navigation/inspection/capture/interactions, page-scoped CDP extension, end-to-end tests and release-build automation. CI run 37604677458 succeeded on Linux and macOS and published the release artifact. Physical `v0.1.0` installation and provider selection succeeded after the catalog link correction; the only observed failure was immediate client connection before the controller socket became ready. That startup-readiness race is fixed in `v0.1.1`, but `v0.1.1` has not yet been physically re-installed and exercised on the user's host.

## Next action

On the physical host, update/install current `rumiai-web-control` so `pkg` selects `v0.1.1`, configure the `web-control` provider if needed, and re-run `srv start web-control` followed immediately by `web-control status`, then one page create/navigate/inspect operation and `srv stop web-control`. If that passes, record the physical result and run/record the permanent `web-control-package` validation scope before starting the `web-sense` consumer/integration layer.

## Blockers / open questions

Current CI and physical installation have resolved package-default/facility projection, explicit `osarch update`, browser acquisition/runtime selection, portable persistent authentication state, controller/browser signal lifecycle, normalized archive link targets and the immediate post-`srv start` readiness race. The remaining blocker is physical end-to-end validation of current `v0.1.1` followed by permanent validation evidence.

- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
