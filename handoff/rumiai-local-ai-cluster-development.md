# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-05

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference, containerized deployment and workload distribution that remains effective despite relatively slow inter-host networking.

## Current repository revisions

```text
rumiai-dev  438966a8114a98c5f31917d7e9f69606a94ec269  (pre-checkpoint HEAD)
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
- Synthetic CPU results are useful only as relative evidence. OpenSSL versions differ across some hosts, so cross-host comparisons must not substitute for a real `llama.cpp` benchmark.
- The `/dev/shm` test is a lightweight comparative memory-path proxy, not a calibrated DRAM-bandwidth benchmark.

## Completed

- First low-impact inventory pass was executed successfully across all eight hosts through `rsudo jobs`.
- The surveyed VMs expose x86_64, AVX2/FMA and VMware virtualization; AVX-512 was not visible to the guests.
- The three local 8 GiB hosts expose 4 vCPU and approximately 6-7 GiB available memory, but have very limited free root filesystem space.
- The three 16 GiB PSN hosts expose 8 vCPU and approximately 12-13 GiB available memory with materially more free root filesystem space.
- `gis` exposes 8 vCPU, approximately 29 GiB available memory and a large `/m` filesystem with hundreds of GiB free.
- `webgisrpr` exposes 8 vCPU, approximately 17 GiB available memory and a large `/m` filesystem.
- Deeper benchmark run `ai-benchmark-30624` completed successfully on all eight hosts.
- The three 4-vCPU local hosts scale almost linearly on the synthetic all-core SHA-256 workload (~3.98-4.00x over single-process).
- The 8-vCPU hosts show materially non-uniform effective scaling (~4.67-6.05x), confirming that nominally identical vCPU counts do not imply identical effective capacity.
- At the 16 KiB SHA-256 result, the local 4-vCPU hosts are tightly clustered around ~341 MB/s single-process and ~1.36 GB/s aggregate. The 8-vCPU hosts range roughly ~360-444 MB/s single-process and ~1.96-2.18 GB/s aggregate.
- `keycloak_psn` and `webgisrpr` are among the strongest single-process results; `apps_psn` is notably weaker single-process despite the same nominal Xeon Gold / 8-vCPU presentation.
- The lightweight `/dev/shm` read proxy is broadly similar across hosts (~6.6-7.7 GB/s), suggesting that the real LLM benchmark will be necessary to expose useful memory-bound differences.
- Virtual NICs report 10 Gb/s full duplex, but actual TCP throughput has not yet been measured.
- Measured latency is very low inside the 10.100 site (~0.03-0.14 ms to `apisix`) and generally low inside the 10.200 site to `gis` (~0.6-1.5 ms for other remote nodes). Cross-site 10.100 <-> 10.200 latency is roughly ~8-12 ms in this run.
- One `apps_psn` -> `apisix` ping sample showed 10% packet loss; this must be repeated before treating it as a persistent network property.
- `nc` is available on all surveyed nodes; iperf availability is inconsistent.
- The benchmark's `MODEL-STORAGE-M` check used any existing writable `/m` directory, so on hosts where `/m` is not a dedicated mount it actually measured the root filesystem. Only dedicated `/m` mount results, notably `gis` and `webgisrpr`, are relevant to shared model-storage evaluation. Temporary files were removed by the benchmark cleanup.

## Current state

The cluster topology and synthetic performance classes are now characterized well enough to proceed to two decisive measurements: real TCP throughput to the proposed model store and real LLM inference throughput.

The existing evidence continues to favor autonomous model workers. The remote 10.200 site has low intra-site latency to `gis`, which makes `gis:/m` especially promising as a central model repository for those workers. Cross-site loading from 10.100 remains plausible for startup-time model access but requires throughput measurement.

## Next action

1. Measure TCP throughput to/from `gis` using the already available `nc`, with representative 10.100 and 10.200 peers and explicit run IDs/status collection.
2. Run a representative `llama.cpp` / GGUF benchmark matrix on each hardware class, separating prompt-processing and token-generation throughput and testing thread counts rather than assuming all-vCPU is optimal.

## Blockers / open questions

- Select and validate the shared model-storage mechanism rooted on `gis:/m`.
- Determine suitable local storage for Podman writable layers on the three small-root local VMs.
- Measure actual network throughput before deciding whether any cross-host inference mechanism deserves experimentation.
- Model placement, quantization, context size and concurrency remain open until real inference benchmarks are available.
