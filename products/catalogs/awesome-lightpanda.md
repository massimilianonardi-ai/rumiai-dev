# Awesome Lightpanda

Status: **External discovery catalog evaluation / non-normative**
Evaluated: 2026-11-02

## Identity and role

- Upstream: https://github.com/lightpanda-io/awesome-lightpanda
- Evaluated default branch: `main`, revision `a494f7a6f157a7f7b74785f03d6aec04f5fe5504`
- License: Apache-2.0 for this list; linked projects retain their own licenses.
- Type: curated external repository index, **not an executable product or a Lightpanda provider**.

The list links Lightpanda use cases, integrations and independent projects grouped into Web Data Extraction, AI Agents and Automation, Language Bindings and Drivers, and Resources.

## RumiAI-oriented discovery value

Useful **reference/discovery** entry point when evaluating alternatives to Chromium and browser-agent interfaces. Particularly interesting entries to verify separately, rather than treating catalog inclusion as proof:

- `vercel-labs/agent-browser`: external agent browser CLI with a Lightpanda backend;
- `monostate/node-scraper` and `LocalKinAI/kinbrowser`: tiered HTTP/Lightpanda/Chromium-style fallback patterns;
- `sscode/browserlab` and `pleasedodisturb/web-agent-comparison`: comparative browser tooling/test resources;
- third-party CDP, MCP, SDK and local agent integrations.

The fallback structure is relevant to RumiAI's existing replaceable `web-control` provider boundary, but does not itself prescribe a RumiAI API, dispatch mechanism or fallback policy.

## Risks and verification boundary

- The list is community/vendor-curated, not a verification program.
- Entry descriptions, security claims, compatibility, maintenance activity, performance and licenses have **not** been independently checked in this evaluation.
- Some projects discuss bot-detection or challenge bypass; inclusion is not endorsement or permission to bypass human challenges.
- Links may become stale; use each candidate's own current upstream and independent tests before selection.

## Assessment

High value as a recurring **discovery index**; no direct reuse/integration of the catalog as a runtime and no adoption decision.
