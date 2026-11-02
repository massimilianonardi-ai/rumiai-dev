# Lightpanda Browser

Status: **External product evaluation / non-normative**
Evaluated: 2026-11-02

## Identity

- Upstream: https://github.com/lightpanda-io/browser
- Evaluated default branch: `main`, revision `0e162ada47378afb988f4da236946b58c6bbd9f5`
- License: AGPL-3.0 (upstream LICENSE)
- Main implementation: Zig, with V8, libcurl and html5ever dependencies.
- Discovery context: rapid popularity is a discovery signal, not compatibility, security or performance evidence.

## Purpose and upstream model

Lightpanda is a browser designed for headless automation, not a Chromium or WebKit fork. It executes JavaScript against a DOM/Web API implementation without a complete graphical rendering pipeline. The upstream README describes CDP and WebDriver BiDi servers, Puppeteer/Playwright client paths, native MCP (stdio and HTTP), a native agent, and replayable JavaScript PandaScripts.

The upstream benchmark reports approximately 16x less peak memory and 9x shorter execution time than Chrome in its chosen workload (100 of 933 network pages on one AWS m5.large). These are **vendor results**, not independently validated general performance claims.

## Deployment and integration surfaces

- `lightpanda fetch` for HTML, Markdown, structured data and text-oriented PNG/PDF output;
- `lightpanda serve` for CDP/BiDi, including a documented local Unix socket with owner-only permissions;
- `lightpanda mcp` for native tool access and isolated/shared session support;
- `lightpanda agent` and `lightpanda run` for AI-directed interaction and deterministic replay;
- provided Linux/macOS x86_64/arm64 nightlies, Docker images and source builds; Linux binaries have stated glibc requirements; no native Windows binary (WSL supported);
- usage telemetry is enabled by upstream default and can be disabled through `LIGHTPANDA_DISABLE_TELEMETRY=true`.

## RumiAI relevance

### Reuse

High as an independent low-resource Web extraction/automation runtime for workloads that do not need true visual rendering. The native MCP interface can be explored without making its protocol RumiAI's internal contract.

### Integration

Promising as an **additional specialized candidate**, not a current `web-control` facility provider. The RumiAI contract in `specifications/rumiai-os/WEB-CONTROL.md` already defines provider-independent deterministic operations, persistent profiles, captures including screenshots, and compatibility levels including the privileged level-3 persistent CDP debugger interface.

Lightpanda's lack of a graphical renderer means its PNG/PDF output does not establish equivalence to a real rendered-browser screenshot. CDP support also does not prove the complete RumiAI level-1/2/3 semantics, persistent authenticated-profile guarantees, browser sandbox guarantees or debugger-event lifecycle. A claimed `web-control` compatibility level requires separate real validation.

The native AI agent is not a deterministic `web-control` implementation: goal interpretation and next-action choice belong above that boundary in RumiAI.

### Reference

Very high for non-graphical browser design, browser-resource optimization, native CDP/BiDi/MCP surfaces, and turning agent exploration into repeatable scripts.

## Risks and cautions

- Incomplete Web API/graphics compatibility compared with Chromium, especially for visual actions, layout, browser fingerprints and authenticated sites.
- The AGPL-3.0 obligations must be reviewed for any planned modification, redistribution or network service deployment; this snapshot is not a license opinion.
- Upstream benchmarks, standards conformance and security claims have not been reproduced here.
- Native MCP/agent exposure, telemetry and private browser state require explicit operator-level security review.
- The source build requires Zig and nontrivial dependencies; executable portability is not synonymous with the RumiAI POSIX baseline.

## Current assessment

```text
reference     very high
integration   promising for a non-visual, replaceable specialized backend
reuse         high for independent headless extraction
adoption      not authorized; no facility compatibility claimed
```

Next validation, if considered: compare real sites and failure cases against the two current Chromium providers; test dynamic DOM, cookie/session continuity, capture fidelity, CDP operations, debugging, platform portability, security boundaries and repeatability. No runtime test was performed in this evaluation.
