# Web access sense

Status: Active
Updated: 2026-10-07

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: e6e2ca70f8607b92af6705942282c3baefbf549a
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

### Remaining implementation design

The canonical `web-sense` / `web-control` boundary, `web-control` ownership, independent-project placement, package/facility identity and baseline deterministic contract now live in `specifications/rumiai-os/WEB-CONTROL.md` and are no longer duplicated here.

The first concrete provider is still planned around Node.js + Playwright + a Chromium-class browser, using PoC 057 as implementation evidence. Playwright/CDP/Chromium remain provider details rather than canonical API.

The independent `rumiai-web-control` repository contains the promoted controller implementation, client/service commands, `mk.json`, end-to-end tests and release build workflow. Current release `v0.1.3` is published and is represented in `pkg-catalog` as `n0004=v0.1.3`, preserving earlier immutable releases. Project CI run 37612637545 passed on Linux and macOS and mechanically verified the current lifecycle: Chromium sandboxing is enabled by default; external browser closure keeps the controller service alive; `status` detects browser absence without relaunching it; `page new` relaunches the browser on demand using the same persistent profile.

The first provider packaging choices remain mechanically settled: the package depends on facilities `chromium =1` and `nodejs =26`, the release artifact is `all`, and the extracted artifact is normalized by `pkg-extract` before package link validation. `v0.1.1` introduced bounded client retries for startup-compatible local-socket `ENOENT`/`ECONNREFUSED`. `v0.1.2` was an immutable intermediate release that enabled Chromium sandboxing but briefly used the now-superseded browser-exit-means-service-exit behavior. `v0.1.3` preserves sandboxing while making the Node controller the durable service lifecycle and Chromium a subordinate managed runtime that can be absent and lazily recreated. Current `pkg-catalog` also projects `CHROME_DEVEL_SANDBOX` through facility `chromium =1`: Linux maps it to `root-path chrome_sandbox`, while non-Linux provider realizations project an empty value.

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
## Current state

The original physical ENOENT/readiness issue is closed. The current first-provider release is `rumiai-web-control v0.1.3`, with catalog concrete `n0004=v0.1.3`.

The current lifecycle is intentionally asymmetric: `web-control-service` remains the long-running controller even when Chromium is manually closed or crashes. `web-control status` remains available and reports browser absence without reopening it; the next `page new` recreates Chromium under the same logical persistent profile. Chromium sandboxing is explicitly enabled, and the current Linux Chromium facility projects `CHROME_DEVEL_SANDBOX` to the prepared sandbox helper.

Project-level runtime validation is green on Linux and macOS in run 37612637545. The current permanent composed package test is aligned to the same semantics, but its hosted execution is presently blocked before runtime by repeatable HTTP 403 responses during live GitHub dependency resolution in `pkg install`. Physical validation of `v0.1.3` through the current package/catalog path is therefore still required.
## Next action

On the physical Linux host, first detach the currently installed provider before replacing it: `srv stop -f web-control`, inspect `pkg provider default web-control`, clear it with `pkg provider default -u -- web-control`, then `pkg uninstall rumiai-web-control`. Continue by refreshing/reintegrating the current Chromium package so its installed concrete contains the current `facility-env` sandbox projection, install current `rumiai-web-control@v0.1.3`, select it again as the `web-control` provider, and start the service. Verify Chromium is not launched with `--no-sandbox`; close the Chromium application manually; verify `web-control status` still works and reports `browserRunning: false`; then run `web-control page new` and confirm Chromium is relaunched without restarting the service, followed by one navigate/inspect operation. If that passes, record the physical composed result and rerun hosted `web-control-package` validation when GitHub live dependency access is available.
## Blockers / open questions

The original ENOENT readiness blocker is closed. The active provider blocker is physical composed validation of `v0.1.3` with the current Chromium sandbox facility projection. Hosted composed validation is additionally blocked before service execution by HTTP 403 from the live GitHub dependency boundary; this is currently validation/external-access evidence, not a `web-control` runtime failure.

- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
