# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-06

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference and workload distribution that remains effective despite relatively slow inter-host networking and severe local-disk constraints on part of the fleet.

## Current repository revisions

```text
rumiai-dev   a895ce779ff51e75ac22660bb338df08c228dd7e  (pre-checkpoint HEAD)
rumiai-os    f4d28822c4a2a875bd816ec3b15477dcfa905706  (observed current remote HEAD; not modified by this checkpoint)
pkg-catalog  c1425bd5097bd18526a42da866ea98906a3325a4  (observed current remote HEAD; no llama.cpp package/facility found)
```

Fresh remote HEAD retrieval remains mandatory before future analysis or writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/RSUDO.md
handoff/README.md
products/README.md
products/ai/llama-cpp.md
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
- No further synthetic/network benchmarking is required before proceeding. The current hardware evidence is sufficient for deployment design.
- The large `/m` storage on `gis` is the shared-storage basis for the cluster because the VM disks cannot currently be enlarged.
- The first shared export should be read-only on worker nodes and should contain model/runtime artifacts. Persistent writable AI services such as Hindsight remain local to `gis` storage rather than writing through the worker share.
- The three small-root local VMs should not depend on Podman for the first llama.cpp deployment. Their first worker path is native execution of a shared llama.cpp runtime plus shared GGUF models.
- Do not place a normal rootless Podman graphroot on NFS/distributed storage. Podman may still be used later on nodes where local writable storage is sufficient or where a deliberately compatible storage layout is established.
- The intended workload model is hybrid: strong external reasoning (for example ChatGPT/Work) remains available as coordinator/reviewer, while local workers provide persistent, private and parallel inference capacity.

## Working design

- Initial worker runtime direction: CPU-only `llama-server` / GGUF behind its existing HTTP service boundary.
- Prefer one centrally staged x86_64 Ubuntu CPU runtime under `gis:/m/ai/runtime/llama.cpp/<revision>` and models under `gis:/m/ai/models`.
- Prefer a read-only NFS export of the shared runtime/model tree to workers. The concrete export/mount configuration still requires physical deployment validation.
- Current upstream llama.cpp stable release is v0.6.0 (2026-10-05). The release points to nightly build `b11429`; its official Ubuntu x64 CPU binary archive is about 17.7 MB and therefore makes direct shared execution practical without local compilation or container images.
- The first physical staging of official build `b11429` on `gis` verified the archive and ELF layout but `llama-server --version` failed because `libgomp.so.1` is absent on `gis`. Keep OpenMP enabled; prefer satisfying the standard OpenMP runtime dependency on worker hosts rather than maintaining a custom OpenMP-disabled build unless a later constraint requires it.
- Before accepting direct execution from the NFS mount, physically verify all remaining official-archive runtime dependencies and that `llama-server` runs correctly on both Ubuntu/kernel classes present in the fleet.
- Do not introduce Paperclip or CrewAI merely to distribute inference across the hosts. Multi-agent frameworks solve orchestration/state/control-plane problems, not the core CPU-inference bottleneck.
- Prefer the smallest orchestration layer that can dispatch independent jobs to model workers. RumiAI/its higher-level orchestration may own this directly unless concrete workflow requirements justify an external framework.
- Hindsight is a comparatively strong near-term experiment for persistent AI memory because it exposes a service/API boundary and can use an external local llama.cpp/OpenAI-compatible server; it is not itself an inference accelerator.
- Ollama is now an explicit parallel runtime experiment on `gis`: evaluate it as a managed model/API layer while keeping direct `llama.cpp` for lean workers. Do not assume it replaces llama.cpp until the physical trial proves its storage, CPU and lifecycle tradeoffs.
- The official Ollama Linux distribution has now been staged successfully under `gis:/m/ai/runtime/ollama/current` and executes directly from `/m`; system-wide installation is not required for the current trial.
- Set any Ollama model store used in this experiment under `gis:/m/ai/ollama/models` through `OLLAMA_MODELS`; do not consume small worker root filesystems with Ollama model blobs.
- The staged Ollama distribution is 2.2 GiB extracted, but logged file sizes show approximately 2.15 GB in bundled CUDA 12/13 libraries and about 44 MB in Vulkan support; the remaining listed CPU/core runtime is only about 62 MB. A separate CPU-only copy is therefore worth validating after the unmodified runtime passes `ollama serve`/API checks.
- Ollama bundles its own `libgomp.so.1`, avoiding the system OpenMP-runtime dependency encountered by the standalone llama.cpp release.
- LocalAI remains a plausible optional unifying runtime/API layer if multiple model backends/modalities are needed; it is not required for the first CPU-only LLM worker deployment.
- The cluster should be optimized for aggregate useful work and parallel task throughput, not for making one serial model response faster through cross-node cooperation.
- Exact model families and quantizations remain to be selected by practical fit rather than additional synthetic benchmarking.

## Completed

- First inventory and deeper synthetic benchmark passes completed successfully across all eight hosts.
- The surveyed VMs expose x86_64, AVX2/FMA and VMware virtualization; AVX-512 was not visible to the guests.
- The three local 8 GiB hosts expose 4 vCPU and approximately 6-7 GiB available memory, but have very limited free root filesystem space.
- The three 16 GiB PSN hosts expose 8 vCPU and approximately 12-13 GiB available memory with materially more free root filesystem space.
- `gis` exposes 8 vCPU, approximately 29 GiB available memory and a large `/m` filesystem with hundreds of GiB free.
- `webgisrpr` exposes 8 vCPU, approximately 17 GiB available memory and a large `/m` filesystem.
- Synthetic results established enough differentiation between the VM classes to stop hardware benchmarking and move to workload architecture/deployment.
- Current product/catalog state was checked: no current `llama.cpp` package/facility exists in `pkg-catalog`.
- Current upstream llama.cpp deployment surface was refreshed. The project still provides `llama-server`, supports CMake builds including static builds, and publishes an Ubuntu x64 CPU archive suitable for a first physical shared-runtime test.
- Official `b11429` Ubuntu x64 CPU archive was downloaded and SHA-256 verified on `gis`; extraction succeeded. `ldd` showed bundled llama/ggml shared libraries resolving from the staged directory and normal system libraries resolving from Ubuntu, with only `libgomp.so.1` unresolved. `llama-server --version` therefore exited 127. No NFS export or worker-side change has been made yet.
- Official Ollama Linux amd64 runtime was staged physically on `gis`. Download size was about 1.4 GiB, extracted footprint 2.2 GiB, and `/m/ai/runtime/ollama/current/bin/ollama --version` executed successfully from `/m` reporting client version 0.35.1. The distribution includes CPU variants, its own `libgomp`, Vulkan support and large CUDA 12/13 runtime trees.

## Current state

The task is now in deployment design.

The first deployment should deliberately avoid solving the container-storage problem on the smallest VMs. Instead, `gis` acts as the central artifact host and the workers execute the same native llama.cpp distribution and read the same GGUF artifacts through a read-only shared filesystem.

Conceptual layout:

```text
gis local storage
/m/ai/
    runtime/llama.cpp/<revision>/
    models/
    data/
    hindsight/

read-only worker share
/m/ai/
    runtime/llama.cpp/<revision>/
    models/

worker
    shared llama-server
        + shared GGUF
        -> model resident in worker RAM
```

Podman remains available as a later tool for services that actually benefit from containerization, not as a prerequisite for every LLM worker.

## Next action

Perform the first physical deployment preflight and shared-runtime validation:

1. run one temporary `ollama serve` from `/m/ai/runtime/ollama/current` on `gis` with `OLLAMA_MODELS=/m/ai/ollama/models`, bound to loopback, and verify `/api/version`, `/api/tags`, process lifecycle and logs without pulling a model;
2. create a separate experimental CPU-only Ollama runtime by removing only the CUDA 12/13 and Vulkan payloads, then repeat the same server/API checks; retain the untouched staged runtime as control;
3. install/provide the minimal OpenMP runtime needed by the standalone llama.cpp runtime and re-run `llama-server --version` on `gis`;
4. compare the validated Ollama CPU-only runtime with direct llama.cpp, then proceed with the read-only shared-runtime/model export for lean workers.

## Blockers / open questions

- Physical NFS package/tool availability and enterprise firewall/export-policy compatibility are not yet verified.
- `libgomp.so.1` is currently missing on `gis`; fleet-wide availability has not yet been checked.
- Direct execution of the official llama.cpp Ubuntu x64 archive from NFS has not yet been validated on the two Ubuntu/kernel classes in the fleet.
- Select the first local model set by role after the shared runtime path works.
- Decide whether Ollama remains only on `gis`/larger managed nodes or is useful on additional nodes after the physical trial.
- Decide whether Hindsight should be part of the first deployment or introduced after the basic local worker pool is operational.
