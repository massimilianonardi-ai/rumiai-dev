# Web access sense

Status: Active
Updated: 2026-10-07

## Goal

Define a general-purpose RumiAI web-access sense that lets RumiAI observe and interact with modern web sites through a real user-side browser/runtime, including JavaScript-heavy sites and site-specific helpers, while keeping the capability simple to use from ordinary prompts and interoperable with ChatGPT both with and without OpenAI APIs.

## Current repository revisions

- rumiai-dev: b5356803413037d902d9ab8be56a9826ddec52f0
- rumiai-os: 6a964ba3f5c8acf462737e3b92daaf1af32de57e
- rumiai-tests: b22a939aacc098ace6b51170e3894284b03a7a76
- rumiai-dev-PoCs: 3c00148a4800cb8556be1f8856546d529001c6cb
- rumiai-web-control: 8b7cb7ac41cd413b531a9777b8786df6544dc938
- pkg-catalog: 2fd85c0f0a9b1dbdee3fc9954250d8c2b500e0bc

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

The independent `rumiai-web-control` repository contains the promoted controller implementation, client/service commands, `mk.json`, end-to-end tests and release build workflow. Release `v0.1.2` is now published. Project CI run 37611308646 passed on Linux and macOS and mechanically verified that Chromium is launched without Playwright's default `--no-sandbox`, that external browser closure terminates the provider foreground process, and that the persistent profile survives the resulting service restart. `pkg-catalog` contains `rumiai-web-control@v0.1.2` as `n0003`, preserving the earlier immutable release artifacts.

The first provider packaging choices remain mechanically settled: the package depends on facilities `chromium =1` and `nodejs =26`, the release artifact is `all`, and the extracted artifact is normalized by `pkg-extract` before package link validation. `v0.1.1` introduced bounded client retries for startup-compatible local-socket `ENOENT`/`ECONNREFUSED`; `v0.1.2` additionally enables Playwright Chromium sandboxing explicitly and ties the service process lifetime to the controlled browser application. Current `pkg-catalog` also projects `CHROME_DEVEL_SANDBOX` through facility `chromium =1`: Linux maps it to `root-path chrome_sandbox`, while non-Linux provider realizations project an empty value. This is required because package-level `env` is applied when Chromium is launched as its ordinary package command, whereas a facility consumer receives only the selected provider's declarative facility projection.

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
- The user subsequently confirmed on the physical host that the `v0.1.1` immediate post-`srv start` workflow works, closing the original ENOENT readiness issue. The same physical check exposed two follow-up defects: Playwright launched Chromium with `--no-sandbox`, and closing the browser window left `web-control-service` alive.
- `WEB-CONTROL.md` now requires browser sandbox/isolation by default and requires external browser-runtime termination to terminate the provider foreground service; closing an individual `web-control` page remains page-local.
- `rumiai-web-control v0.1.2` fixes both follow-up defects. It sets `chromiumSandbox: true` and listens for BrowserContext closure so the foreground service exits when the browser application exits/crashes. Project CI run 37611308646 passed on Linux and macOS; its tests inspect the actual managed browser command line for absence of `--no-sandbox`, close the browser through CDP, verify service termination, restart the service and verify persistent browser state.
- Permanent test `external/rumiai-web-control/install-live.test` now exercises browser-driven service exit through the composed `pkg -> srv -> web-control` path by closing the browser and requiring a subsequent `srv start web-control` to start a new service before checking status again.
- Initial composed validation of `v0.1.2` exposed a separate Chromium facility-projection defect: with sandboxing enabled, the managed Chromium provider could not find a usable sandbox because `CHROME_DEVEL_SANDBOX` was only provided by Chromium's ordinary package `env`, not by its facility projection. `pkg-catalog` commit 2fd85c0f0a9b1dbdee3fc9954250d8c2b500e0bc adds the required declarative `chromium =1` facility env projection. Subsequent hosted attempts have not yet exercised that correction because GitHub returned HTTP 403 during dependency resolution before the live test reached service startup; those failures are validation-infrastructure/external-access failures, not evidence against the sandbox/lifecycle implementation.

## Current state

The original physical ENOENT/readiness issue is closed: the user confirmed the `v0.1.1` immediate-start workflow works on the physical host. The current first provider release is now `rumiai-web-control v0.1.2`.

`v0.1.2` removes Playwright's default unsandboxed launch by explicitly enabling Chromium sandboxing and makes browser application lifetime part of provider service lifetime. Project-level Linux/macOS CI is green for both properties. Current `pkg-catalog` contains `n0003=v0.1.2` and the Chromium facility projection required to export `CHROME_DEVEL_SANDBOX` to package consumers.

The permanent composed test has been strengthened accordingly, but hosted composed validation against the latest catalog state is still open. Run 37611619061 attempt 2 reached `v0.1.2` before the Chromium facility-env correction and correctly failed because no usable sandbox was projected. Attempts 3 and 4 occurred after the catalog correction but stopped earlier with HTTP 403 during dependency resolution, so they provide no evidence for or against the corrected composed runtime. The latest catalog correction therefore still needs one real composed execution, preferably on the user's physical host and later in hosted validation when external GitHub access permits it.
## Next action

On the physical Linux host, ensure the Chromium concrete used by `web-control` is newly integrated from the current catalog so it contains the new `facility-env/chromium` projection, then install/select `rumiai-web-control@v0.1.2`. Start `web-control`, verify Chromium no longer runs with `--no-sandbox`, close the Chromium application window manually, and confirm that the service is no longer considered running and can be started again normally. After that physical composed check passes, rerun/record the hosted `web-control-package` validation when GitHub dependency access succeeds.
## Blockers / open questions

The original ENOENT readiness blocker is closed. The active provider blocker is revision-specific validation of the new sandbox/lifecycle behavior through the corrected managed Chromium facility projection. Project-level `v0.1.2` tests are green; the latest hosted composed attempts are currently blocked before execution by HTTP 403 during external GitHub dependency resolution.

- Determine which ChatGPT integration paths are baseline versus optional compatibility bridges.
