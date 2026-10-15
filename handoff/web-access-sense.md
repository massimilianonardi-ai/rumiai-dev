# Web access sense

Status: Active
Updated: 2026-10-11

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: 5e2b1c8fa47d30a2013c070cf89a8078d3888c85
- rumiai-os: 6a964ba3f5c8acf462737e3b92daaf1af32de57e
- rumiai-tests: 89cd8308ba6a5272e7d4163864f5f28c1de88e66
- rumiai-dev-PoCs: 3c00148a4800cb8556be1f8856546d529001c6cb
- rumiai-web-control: 8ed3ab888ecdc4970d90a6f14f0d7b7b93fce122
- pkg-catalog: 7d63806188414d5e872c7802bc59209375db9fa6

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

### User agency, accessibility and site acceptance (open evaluation)

The user explicitly wants future automation across Computer Use, Computer Control, browser use and Web control to be as unobtrusive and indistinguishable from ordinary user interaction as technically feasible. This request follows observed differences in Google sign-in acceptance between browser-control mechanisms; the exact detection causes are not established. Treat compatibility with the user's normal authenticated workflow, minimal unnecessary automation fingerprints, local OS accessibility/native controls and provider substitution as candidates to evaluate empirically, not as a guaranteed-undetectable implementation contract or permission to bypass login challenges.

Accessibility and independent use by people with disabilities are essential motivating scenarios: automation restrictions can impede assistive technology and force additional human dependence. Preserve the user's concern about advertising/business incentives as their perspective, not a verified motive for a specific Google restriction. Future evaluation must compare real-site acceptance, reliability, permissions, user agency and security without prematurely selecting a stealth technique or changing the current `WEB-CONTROL.md` safety boundary.

### Current deterministic provider baseline

The provider-independent contract remains specifications/rumiai-os/WEB-CONTROL.md. Current independent concrete providers are pwc-web-control (Playwright/Chrome v0.1.4) and electron-web-control (Electron v0.1.3), realized through the web-control compatibility-1 facility. The earlier rumiai-web-control project remains only a legacy compatibility package and is not a current provider development plan.

Electron Linux ARM64 user-observed physical checks include Gmail login, authenticated restart, search and unsent composition with draft persistence; these do not prove universal site acceptance or live event trust flags. The separate provider-split handoff owns its final acceptance and Mac deferral.

The published web-control 1/2 facility does not include debugger sessions. New source-level persistent CDP session support is now implemented in BOTH Playwright and Electron providers behind the same proposed compatibility-3 command shape; the separate handoff `handoff/web-control-debug-sessions.md` owns its contract, validation, release/catalog alignment and operational next steps. The Amazon Wishlist extractor remains an application concern under `handoff/amazon-price-watch.md`; higher-level web-sense orchestration remains independent.

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

Scheduling and notification policy for the concrete Amazon Price Watch application is now owned by the separate active handoff `handoff/amazon-price-watch.md`.

This Web-access task keeps only reusable architectural consequences. Amazon Price Watch remains one motivating/use-case source for `web-control` and future `web-sense`, but its polling cadence, product extraction policy, spreadsheet state and notification behavior are not part of this task's design state.

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
- The permanent `web-control-package` validation was re-run after `v0.1.1` was published and added to current `pkg-catalog`. GitHub Actions run 37602432475 attempt 2 completed successfully on 2026-10-07. Aggregate validation `validation/20261007T101704+0000-2437` recorded `aggregate-status 0`; live session `validation/20261007T101722+0000-6758` recorded `PASS external/rumiai-web-control/install-live.test` and `web-control-package-live=ok`. The live test starts `web-control` through `srv` and invokes `web-control status` immediately before page create/navigate/inspect, so the hosted composed path now protects the startup-readiness regression. This is hosted Linux validation, not physical validation of the user's host.
- The user subsequently confirmed on the physical host that the `v0.1.1` immediate post-`srv start` workflow works, closing the original ENOENT readiness issue. The same physical check exposed that Playwright launched Chromium with `--no-sandbox`; it also showed that closing the browser window left the controller service alive.
- The user then clarified the intended browser/service lifecycle: keeping the controller service alive is correct. The browser is a subordinate managed runtime; after manual closure or crash, the service must detect browser absence and recreate Chromium only when a later browser-required operation needs it.
- `WEB-CONTROL.md` now canonically requires browser sandboxing by default, a controller service that outlives browser-runtime termination, browser-absence observation without implicit relaunch, and on-demand browser recreation without preserving old live page identities.
- `rumiai-web-control v0.1.2` was published as an immutable intermediate release with sandboxing enabled and browser closure terminating the service. That lifecycle was superseded forward-only by `v0.1.3`; no history or release was rewritten.
- `rumiai-web-control v0.1.3` implements the corrected lifecycle. Project CI run 37612637545 passed on Linux and macOS and explicitly reported successful checks for Chromium sandboxing, controller survival after browser closure, `status` detection of an absent browser without relaunch, `page new` browser relaunch on demand, and persistent profile survival across that relaunch.
- `pkg-catalog` contains `n0004=v0.1.3`. A concurrent catalog correction also projects `CHROME_DEVEL_SANDBOX` through facility `chromium =1` so Linux facility consumers receive the prepared `chrome_sandbox` helper rather than falling back to an unsandboxed Chromium launch.
- Permanent test `external/rumiai-web-control/install-live.test` now protects the composed lifecycle through public surfaces: after browser closure it requires `web-control status` to report `browserRunning: false`, requires `srv start web-control` to report the controller is already running, then requires `page new` to relaunch the browser and normal navigation/inspection to work.
- Hosted composed validation run 37612915808 attempts 1 and 2 did not reach service startup. Both failed during `pkg install rumiai-web-control` with an external GitHub HTTP 403 reported as dependency-unresolvable. Those attempts provide no evidence for or against the current `v0.1.3` lifecycle; project-level Linux/macOS validation remains green.
- During physical refresh, `pkg uninstall rumiai-web-control` returned only `reason="package-failed"`. Current `pkg-uninstall.lib.sh` checks `_pkg_dependency_provider_unreferenced` before clearing a package default, and the current `web-control` provider selector still references the installed `rumiai-web-control` concrete. The required operator sequence is therefore: stop the service, inspect/clear the `web-control` provider default, then uninstall the package. The generic uninstall diagnostic does not expose this provider-reference cause.
- The user then completed the physical cleanup successfully: the `web-control` provider was detached and the old `rumiai-web-control`/related test install state was removed. The physical host is ready for a clean install of current `rumiai-web-control@v0.1.3` through the normal dependency path.
- The clean physical install then failed at dependency planning with `reason="dependency-unresolvable"`. Direct `pkg depend rumiai-web-control@v0.1.3` confirmed the same HTTP 403 from GitHub already observed in hosted composed validation. Current catalog data itself is sufficient (`chromium =1` -> `chromium@1697793!linux-x86_64`; `nodejs =26` -> `nodejs@v26.8.2!linux-x86_64`); the blocker is the current GitHub repository adapter's unauthenticated REST access during current/latest/exact-release resolution.
- Re-evaluated ChatGPT integration/scheduling against current OpenAI product capabilities on 2026-10-08. Secure MCP Tunnel provides an outbound-only path from a private/local MCP server to supported OpenAI products; local MCP apps remain desktop-local, while cloud scheduled/event-triggered tasks use supported plugins/apps. Current event-triggered task sources explicitly include Gmail, Slack and GitHub, not Google Drive. This supports local deterministic polling plus an event bridge to ChatGPT instead of model-driven polling.
- The concrete Amazon Price Watch work has been split into `handoff/amazon-price-watch.md`. This handoff retains only reusable Web architecture work; Amazon-specific scheduling, extraction, persistence and notification state no longer belongs here.
## Current state

Both current concrete providers are published and Linux package/service integration is validated for released revisions. The original first-provider ENOENT issue and the historical rumiai-web-control GitHub 403 physical-install blocker do not describe the current independent provider acceptance status. The Electron provider has a successful, user-reported Gmail smoke path; macOS package validation remains deferred separately.

This handoff continues the RumiAI web-sense and ChatGPT/private-machine integration work, not provider-split implementation or Amazon-specific monitoring.

## Next action

Design and test a minimal web-sense orchestration/adaptation workflow over the existing web-control baseline. Retain human intervention for login/challenges and validate accessible user-side interaction empirically. Evaluate only currently supported secure local/remote ChatGPT integration paths; do not assume the cloud scheduler directly controls the user's local VM.

## Blockers / open questions

- AI-level page interpretation and supported ChatGPT/private-browser bridge are not implemented.
- Site-acceptance, accessibility and OS-native input equivalence beyond user-observed Gmail scenarios need targeted evidence, not stealth claims.
- Electron macOS ARM64 package validation is deferred; the general pkg subsystem remains independently owned.
