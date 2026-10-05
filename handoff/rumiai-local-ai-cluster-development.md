# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-05

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference, containerized deployment and workload distribution that remains effective despite relatively slow inter-host networking.

## Current repository revisions

```text
rumiai-dev  ec65039e73509ab961f65c57b83c47c5485ed7e4  (pre-checkpoint HEAD)
rumiai-os   f39d986e5d4269f742d138eb3ebf9092d1e3345c  (observed current remote HEAD; not modified by this checkpoint)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/RSUDO.md
handoff/README.md
```

Additional package, service, state or container specifications must be retrieved only when implementation reaches those responsibilities.

## Fixed task-local choices

- The cluster consists of the rsudo credential groups:
  `apisix`, `apisix_psn`, `apps`, `apps_psn`, `keycloak`, `keycloak_psn`, `gis`, `webgisrpr`.
- `10.100.*` and `10.0.*` are local networks; `10.200.*` hosts are geographically remote. Inter-host networking is relatively slow even among local servers.
- Prefer independent model workers and request/workload parallelism over tensor/model parallelism that requires frequent cross-host synchronization.
- `gis` and `webgisrpr` may be benchmarked and used without a task-level CPU cap; the user will manage production contention when necessary.
- Credentials are not exposed to the assistant. Operations use `rsudo` / `rsudo-admin` from an environment where the user has already loaded credentials, or an explicitly available ChatGPT Work/Codex execution session.
- Do not rely on host wall clocks for distributed correlation. Prefer run identifiers, operation identifiers and explicit command/result state.
- The large `/m` storage on `gis` is the preferred candidate for a shared central model repository. Treat this as model storage, not automatically as the writable Podman graphroot/container layer store.
- Keep models resident locally in worker RAM during inference where practical so shared-storage/network cost is concentrated mainly at load/startup time.

## Working design

- Initial inference direction: CPU-optimized `llama.cpp` / GGUF unless benchmark evidence supports a better fit.
- The three 16 GiB / 8-vCPU remote nodes are likely primary general workers; the 32 GiB `gis` node is a candidate for larger models; the 24 GiB `webgisrpr` node is a candidate for medium/larger models; the three 8 GiB / 4-vCPU local nodes are candidates for small LLMs, embeddings, reranking or lightweight specialist work.
- Exact model families, quantization levels, context sizes, thread counts and concurrency remain benchmark-dependent.
- Shared model storage protocol/export mechanism is not yet selected.
- Podman is not currently installed on the surveyed hosts; deployment mechanism and local writable storage placement remain to be designed after benchmarking.

## Completed

- First low-impact inventory pass was executed successfully across all eight hosts through `rsudo jobs`.
- The surveyed VMs expose x86_64, AVX2/FMA and VMware virtualization; AVX-512 was not visible to the guests.
- The three local 8 GiB hosts expose 4 vCPU and approximately 6-7 GiB available memory, but have very limited free root filesystem space.
- The three 16 GiB PSN hosts expose 8 vCPU and approximately 12-13 GiB available memory with materially more free root filesystem space.
- `gis` exposes 8 vCPU, approximately 29 GiB available memory and a large `/m` filesystem with hundreds of GiB free.
- `webgisrpr` exposes 8 vCPU, approximately 17 GiB available memory and a large `/m` filesystem.
- A second, deeper benchmark job has been prepared conceptually to compare sustained CPU scaling, memory behavior, storage and network characteristics without installing benchmark packages.

## Current state

The cluster topology and first inventory are known well enough to proceed to performance characterization. Architecture remains intentionally biased toward autonomous workers because network bandwidth/latency is a constraint and the nodes are heterogeneous.

The shared-storage idea based on `gis:/m` is accepted as the preferred direction for model files, subject to selecting and validating the concrete sharing mechanism.

## Next action

Run the deeper rsudo benchmark across all eight hosts, collect its unified log, then use the measured CPU scaling, memory throughput, storage and network results to select the first representative GGUF model(s) and build a real `llama.cpp` benchmark matrix.

## Blockers / open questions

- Select and validate the shared model-storage mechanism rooted on `gis:/m`.
- Determine suitable local storage for Podman writable layers on the three small-root local VMs.
- Measure actual network throughput, not only latency, before deciding whether any cross-host inference mechanism deserves experimentation.
- Model placement and concurrency remain open until real inference benchmarks are available.
