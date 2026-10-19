# Olla

Status: **External product evaluation / non-normative**
Evaluated: 2026-10-15

## Identity

Product/project: Olla
Upstream repository: https://github.com/thushan/olla
Documentation: https://thushan.github.io/olla/
License: Apache-2.0 (upstream `LICENSE` and repository metadata)
Evaluated release: `v0.0.29` (published 2026-08-10)
Evaluated upstream commit: `421fd808e59a2879059062728d2dcec06d2b23ae`
Verified release source: https://github.com/thushan/olla/releases/tag/v0.0.29

This is a revision-specific product assessment, not a RumiAI architecture or package contract.

## Upstream purpose and observed capabilities

Olla is a Go-based, stand-alone proxy/load balancer for existing self-hosted
model inference HTTP servers. It does not run or deploy models itself.

The upstream `v0.0.29` release and accompanying documentation provide:
- multiple statically configured Ollama endpoints with native health checks,
  model discovery via `/api/tags`, and a unified catalog of available models;
- model-aware routing, `least-connections`, `round-robin` and priority
  routing; automatic endpoint health recovery/circuit breakers;
- HTTP proxying of Ollama `/api/chat` and other supported inference APIs,
  including streaming, plus OpenAI-compatible proxy routes;
- native status, Prometheus `/internal/metrics`, and a read-only dashboard;
- binary releases for Linux amd64 and a Docker distribution, with a YAML
  configuration (no mandatory application database for basic proxying).

Relevant upstream sources:
- https://thushan.github.io/olla/integrations/backend/ollama/
- https://thushan.github.io/olla/concepts/model-unification/
- https://thushan.github.io/olla/concepts/model-routing/
- https://thushan.github.io/olla/api-reference/overview/
- https://github.com/thushan/olla/blob/v0.0.29/config.yaml

## RumiAI evaluation

### Reuse and integration

For the **initial eight-host CPU-only Ollama inference pool**, Olla is the
selected existing-product candidate for the *inference-dispatch layer*, as
recorded in the active
`handoff/rumiai-local-ai-cluster-development.md`. The user has explicitly
selected **`gis` (`10.200.0.19`)** as the host for the first Olla installation.
Olla is intended to run there as a separate process, accepting requests from
RumiAI or other allowed callers and routing to the planned network-visible
Ollama endpoints. This location is a RumiAI task-local decision, not an
upstream Olla product requirement. No RumiAI-owned dispatcher is needed at this stage.

Olla does **not** provide the higher-level RumiAI task/tool/memory orchestration;
those are separate responsibilities and are not newly assigned or implemented
by choosing this proxy. Olla also does not own Ollama installation, model
pull/push/delete or server configuration.

LiteLLM remains an alternative for broad hosted-provider API normalization,
virtual credentials and API governance, but entails a larger operational
footprint for the current narrowly scoped local Ollama fleet. LocalAI is a
separate inference-serving/backend platform, not a necessary replacement for
the eight already-running Ollama servers. The current choice is based on
fit-for-purpose, not a measured RumiAI benchmark against those alternatives.

### Risks and verification boundaries

- **No inbound proxy authentication:** upstream v0.0.29 says proxy-level
  authentication is not implemented. Ollama's self-hosted HTTP API likewise
  lacks local client authentication. Olla rate limiting is **not** a substitute
  for an access-control boundary.
- Binding the future Ollama processes to `0.0.0.0` does not determine
  reachability or protection. Corporate routing, firewall/authorized client
  policies, validation of `gis`-to-worker HTTP connectivity, and security
  approval are still open.
- Upstream Olla `v0.0.29` includes an unauthenticated read-only dashboard,
  with its own access-policy controls; verify its effective exposure before
  live deployment, particularly with published container ports.
- The upstream default `proxy.retry.enabled: true` retries certain
  connection failures, including reset/timeout, on another worker. Whether
  the first request was accepted may be ambiguous: do **not** claim at-most-once
  inference semantics from this default. Evaluate disabling automatic retries
  or accepting explicit replay semantics for read-only inference.
- Least-connections counts admitted requests; it is not necessarily the least
  busy CPU or shortest-latency worker on heterogeneous, remote nodes.
- At the initial 2026-10-15 product evaluation only upstream sources
  had been inspected. On 2026-10-19, the independent
  `rumiai-dev-PoCs/pocs/070-olla-gis/` experiment ran the **real pinned
  v0.0.29 Olla binary** on a GitHub Ubuntu runner, verified the upstream
  asset digest and configuration, and routed an actual chat over HTTP
  through Olla to a deliberately mocked local Ollama backend. Exact-source
  CI [run 39207500993](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/39207500993)
  passed at `c7bc5e39a329f1491a725a7175c75638c4d3f33c`.
  A follow-up GitHub Actions
  [run 39208513826](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/39208513826)
  (at `2781b640e5fcc25f9cf70144c388e56d0de3a4d1`) also executed the
  **same remote installer program** from the GIS operator library against
  an actual Ubuntu runner: preflight, install, `systemd` start/enable,
  health and proxied mock chat, and repeat-install all passed.
  These CI results are **not** real GIS deployment, real CPU inference,
  corporate SSH/rsudo, eight-host routing or runtime security validation.

## Current assessment

Use the existing Olla product on the user-selected `gis` host for the
first **inference-routing canary**, as authorized by the user on 2026-10-19.
A GIS-local `rsudo-admin` operator install job now exists in
`rumiai-dev-PoCs/pocs/070-olla-gis/`, with loopback-only Olla and the
existing GIS-local Ollama endpoint as its first backend. The pinned Olla
release and its exact remote `systemd` installer program passed isolated
Ubuntu GitHub execution, but the operator's SSH access and installation on
the actual `gis` host, and real CPU inference, remain **pending physical
validation**. The initial
eight-node HTTP routing and client security boundary remain a subsequent
explicitly reviewed deployment phase. Keep Olla behind an application
consumer boundary rather than promoting its configuration names into
RumiAI architecture.
