# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-05

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference, containerized deployment and workload distribution that remains effective despite relatively slow inter-host networking.

## Current repository revisions

```text
rumiai-dev  43a2368bcff4b8a2b602724672a47b2d8dab030c  (pre-checkpoint HEAD)
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
products/README.md
```

Additional package, service, state or container specifications must be retrieved only when implementation reaches those responsibilities.

## Fixed task-local choices

- The cluster consists of the rsudo credential groups:
  `apisix`, `apisix_psn`, `apps`, `apps_psn`, `keycloak`, `keycloak_psn`, `gis`, `webgisrpr`.
- `10.100.*` and `10.0.*` are local networks; `10.200.*` hosts are geographically remote. Inter-host networking is relatively slow even among local servers.
- Prefer independent model workers and request/workload parallelism over tensor/model parallelism that requires frequent cross-host synchronization.
- `gis` and `webgisrpr` may be used without a task-level CPU cap; the user will manage production contention when necessary.
- Credentials are not exposed to the assistant. Operations use `rsudo` / `rsudo-admin` from an environment where the user has already loaded credentials, or an explicitly available ChatGPT Work/Codex execution session.
- Do not rely on host wall clocks for distributed correlation. Prefer run identifiers, operation identifiers and explicit command/result state.
- No further synthetic/network benchmarking is required before proceeding. The current hardware evidence is sufficient for the next design/deployment phase.
- The large `/m` storage on `gis` is the shared-storage basis for the cluster because the VM disks cannot currently be enlarged.
- Models, datasets, application caches and persistent AI data may use the shared `gis:/m` storage.
- A normal rootless Podman graphroot must not simply be placed on an NFS/distributed mount: current Podman documentation does not support that configuration. Container/image storage on the shared filesystem therefore requires an explicitly compatible storage approach rather than assuming ordinary local OverlayFS semantics.
- The intended workload model is hybrid: strong external reasoning (for example ChatGPT/Work) remains available as coordinator/reviewer, while local workers provide persistent, private and parallel inference capacity.

## Working design

- Initial worker runtime direction: CPU-optimized `llama.cpp` / GGUF behind a simple service boundary.
- Do not introduce Paperclip or CrewAI merely to distribute inference across the hosts. Multi-agent frameworks solve orchestration/state/control-plane problems, not the core CPU-inference bottleneck.
- Prefer the smallest orchestration layer that can dispatch independent jobs to model workers. RumiAI/its higher-level orchestration may own this directly unless concrete workflow requirements justify an external framework.
- Hindsight is a comparatively strong near-term experiment for persistent AI memory because it exposes a service/API boundary and can use an external local llama.cpp/OpenAI-compatible server; it is not itself an inference accelerator.
- Paperclip remains primarily a reference or later control-plane candidate for long-running autonomous multi-agent work with approvals, lifecycle, task ownership and governance.
- CrewAI remains mainly a PoC/reference candidate for agent workflows; it is not the preferred first dependency for this cluster, especially because it adds an agent framework where simple dispatch may suffice.
- LocalAI remains a plausible optional unifying runtime/API layer if multiple model backends/modalities are needed; it is not required for the first CPU-only LLM worker deployment.
- The cluster should be optimized for aggregate useful work and parallel task throughput, not for making one serial model response faster through cross-node cooperation.
- Local models are expected to be materially weaker and generally slower per difficult interactive response than current frontier ChatGPT models, but can still provide real value for bounded, repetitive, parallel, private or background development tasks.
- Exact model families and quantizations remain to be selected by practical fit rather than additional synthetic benchmarking.

## Completed

- First inventory and deeper synthetic benchmark passes completed successfully across all eight hosts.
- The surveyed VMs expose x86_64, AVX2/FMA and VMware virtualization; AVX-512 was not visible to the guests.
- The three local 8 GiB hosts expose 4 vCPU and approximately 6-7 GiB available memory, but have very limited free root filesystem space.
- The three 16 GiB PSN hosts expose 8 vCPU and approximately 12-13 GiB available memory with materially more free root filesystem space.
- `gis` exposes 8 vCPU, approximately 29 GiB available memory and a large `/m` filesystem with hundreds of GiB free.
- `webgisrpr` exposes 8 vCPU, approximately 17 GiB available memory and a large `/m` filesystem.
- Synthetic results established enough differentiation between the VM classes to stop hardware benchmarking and move to workload architecture/deployment.
- Current external-product evaluations for Paperclip, Hindsight, llama.cpp, LocalAI and LangGraph were re-read; current upstream information for CrewAI and Hindsight was checked before this checkpoint.

## Current state

The task has moved from infrastructure characterization to workload architecture.

The main question is no longer whether the servers are fast enough to run local AI at all. They are expected to be useful as a pool of independent specialist/background workers, while not competing with frontier hosted models on single-request reasoning quality or latency.

The preferred initial shape is:

```text
ChatGPT / RumiAI high-level reasoning
             |
      dispatch / review
             |
   independent local workers
      llama.cpp / GGUF
             |
   shared models/data on gis:/m
```

Optional services such as Hindsight should be introduced only when they solve a specific higher-level responsibility.

## Next action

Design the first useful worker topology and workload catalog: choose a small set of local model roles, decide which hosts carry each role, define the minimal service/dispatch boundary, and define the compatible Podman/shared-storage layout.

## Blockers / open questions

- Select the concrete shared-filesystem export/mount mechanism for `gis:/m`.
- Select a Podman image/container-storage arrangement compatible with the shared filesystem and the very small local root filesystems.
- Select the first local model set by role (coding/review, extraction/classification, embeddings/reranking, general assistant, memory-support LLM).
- Decide whether Hindsight should be part of the first deployment or introduced after the basic local worker pool is operational.
