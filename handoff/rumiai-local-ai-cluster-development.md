# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-06

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference and workload distribution that remains effective despite relatively slow inter-host networking and severe local-disk constraints on part of the fleet.

## Current repository revisions

```text
rumiai-dev   a895ce779ff51e75ac22660bb338df08c228dd7e  (pre-checkpoint HEAD)
rumiai-os    f4d28822c4a2a875bd816ec3b15477dcfa905706  (observed current remote HEAD; not modified by this checkpoint)
pkg-catalog  7e42e1d9fd6d986eba5fc8ac671641ac3b99f1b3  (Ollama package/service facility added in this work unit; no llama.cpp package/facility)
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
- Prefer a read-only NFS export of the shared runtime/model tree to workers. The first physical worker pair is fixed as `apps` (`10.100.0.34`) and `apisix_psn` (`10.200.0.13`), representing the two network classes. Export only the versioned CPU-only Ollama runtime and central Ollama model store from `gis` (`10.200.0.19`) to those exact client IPs for the first trial.
- Current upstream llama.cpp stable release is v0.6.0 (2026-10-05). The release points to nightly build `b11429`; its official Ubuntu x64 CPU binary archive is about 17.7 MB and therefore makes direct shared execution practical without local compilation or container images.
- The first physical staging of official build `b11429` on `gis` verified the archive and ELF layout but `llama-server --version` failed because `libgomp.so.1` is absent on `gis`. Keep OpenMP enabled; prefer satisfying the standard OpenMP runtime dependency on worker hosts rather than maintaining a custom OpenMP-disabled build unless a later constraint requires it.
- Before accepting direct execution from the NFS mount, physically verify all remaining official-archive runtime dependencies and that `llama-server` runs correctly on both Ubuntu/kernel classes present in the fleet.
- Do not introduce Paperclip or CrewAI merely to distribute inference across the hosts. Multi-agent frameworks solve orchestration/state/control-plane problems, not the core CPU-inference bottleneck.
- Prefer the smallest orchestration layer that can dispatch independent jobs to model workers. RumiAI/its higher-level orchestration may own this directly unless concrete workflow requirements justify an external framework.
- Hindsight is a comparatively strong near-term experiment for persistent AI memory because it exposes a service/API boundary and can use an external local llama.cpp/OpenAI-compatible server; it is not itself an inference accelerator.
- Ollama is now an explicit parallel runtime experiment on `gis`: evaluate it as a managed model/API layer while keeping direct `llama.cpp` for lean workers. Do not assume it replaces llama.cpp until the physical trial proves its storage, CPU and lifecycle tradeoffs.
- The official Ollama Linux distribution has now been staged successfully under `gis:/m/ai/runtime/ollama/current` and executes directly from `/m`; system-wide installation is not required for the current trial.
- Set any Ollama model store used in this experiment under `gis:/m/ai/ollama/models` through `OLLAMA_MODELS`; do not consume small worker root filesystems with Ollama model blobs.
- The staged Ollama distribution is 2.2 GiB extracted, but physical validation showed that removing only the bundled CUDA 12/13 and Vulkan payloads yields a 60 MiB CPU-only runtime. Both the untouched and CPU-only runtimes start `ollama serve`, expose `/api/version` and `/api/tags`, bind successfully to loopback, and detect CPU inference on `gis`.
- Ollama bundles its own `libgomp.so.1`, avoiding the system OpenMP-runtime dependency encountered by the standalone llama.cpp release.
- The temporary `ollama serve` test generated an SSH identity below the effective root home (`/root/.ollama`). Future managed execution should redirect process HOME/state to `/m/ai/ollama/home` (or another explicit persistent Ollama state directory) so cluster state does not leak into the small root filesystem.
- Real inference with `qwen3:4b` on `gis` is now validated through the CPU-only Ollama runtime. The model occupies about 2.4 GiB in the central model store and appears as about 3.2 GB loaded by Ollama at 4096 context; the llama runner RSS was about 3.1 GiB and total host memory used about 4.6 GiB during the request.
- The first request generated 1492 output tokens because Qwen3 thinking was enabled by default. Measured prompt processing was about 50.6 tokens/s and generation about 7.2 tokens/s by the end of the request, with model startup about 5.3 s. For bounded worker tasks, prefer explicit non-thinking mode unless reasoning is actually useful; current Ollama APIs support `"think": false` for Qwen3-class thinking models.
- The successful real inference makes CPU-only Ollama the preferred initial managed worker runtime candidate across the fleet; direct llama.cpp remains the lower-level fallback/reference until worker-side shared-mount validation is complete.
- The `think:false` worker profile has now been physically validated on `gis`: the same qwen3:4b request completed in about 17.4 s total generation time with 256 output tokens, prompt processing about 63.7 tokens/s and average generation about 15.0 tokens/s. The response hit the 256-token ceiling and was truncated, so worker contracts must combine non-thinking mode with task-appropriate output limits rather than assuming a single low global cap.
- For read-only shared Ollama model stores, set `OLLAMA_NOPRUNE=true` on workers so startup/runtime does not try to prune shared blobs. Keep worker `HOME` writable and local; the first trial uses a tiny local state directory under `/var/lib/ollama-worker`, while runtime and models remain on the read-only NFS mount.
- The first NFS attempt exposed two setup defects before any distributed inference ran: the Ollama model tree contains metadata files that are not world-readable, so the intended `root_squash` export cannot expose them until the share tree is made read/execute accessible; and the `apisix_psn` worker job reached `mount` without a surviving mount-point directory. These were deployment-script issues and have now been corrected.
- The corrected NFS deployment is physically validated across the full worker fleet. `apisix`, `apps`, `keycloak`, `apisix_psn`, `apps_psn`, `keycloak_psn`, and `webgisrpr` all mount the 60 MiB runtime and 2.4 GiB model store read-only over NFSv4.2 with `root_squash`, start Ollama from the shared runtime, see the shared qwen3:4b model, and complete local CPU inference successfully.
- LocalAI remains a plausible optional unifying runtime/API layer if multiple model backends/modalities are needed; it is not required for the first CPU-only LLM worker deployment.
- The cluster should be optimized for aggregate useful work and parallel task throughput, not for making one serial model response faster through cross-node cooperation.
- Exact model families and quantizations remain to be selected by practical fit rather than additional synthetic benchmarking.
- The catalog package uses the official `ollama/ollama` GitHub release stream for `linux-x86_64`, current anchor/tag `v0.35.1`, exact asset `ollama-linux-amd64.tar.zst`, SHA-256 metadata from GitHub release assets, and `tar.zst` extraction. It exposes ordinary package commands `ollama` and `ollama-serve`; `ollama-serve` launches `ollama serve` and is the foreground start realization for service facility `ollama` compatibility level `1`.
- Cluster-specific service settings remain mutable service-instance configuration rather than package metadata. In particular `OLLAMA_MODELS`, `OLLAMA_HOST`, and `OLLAMA_NOPRUNE` should be supplied through the system package State Instance configuration used by `srv`.
- The official upstream Linux amd64 package is still the full distribution (~1.44 GB compressed / ~2.2 GiB extracted) including CUDA/Vulkan payloads. The catalog package intentionally follows the official artifact and does not silently encode the experimental 60 MiB CPU-only pruning. This footprint remains a deployment concern for the smallest worker roots.

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
- Temporary server validation completed for both the full and pruned CPU-only Ollama runtimes. Both returned version `0.35.1`, an empty model list, and HTTP 200 responses on loopback. The CPU-only runtime footprint is 60 MiB and Ollama correctly selected CPU compute with about 31.3 GiB total memory visible on `gis`.
- `qwen3:4b` was pulled into `/m/ai/ollama/models` and a real `/api/chat` inference completed successfully on CPU. The central model store consumed about 2.4 GiB. Ollama reported the loaded model at about 3.2 GB, context 4096, 100% CPU. The host still showed about 26 GiB available memory. The request's 3m32s wall time was dominated by 1492 generated thinking/output tokens, not model loading.
- A second real request with `think:false` and `num_predict:256` completed successfully. Ollama kept the same ~3.2 GB loaded model footprint, host memory remained ~26 GiB available, and generation throughput improved materially to ~15 tokens/s average; the response was truncated exactly because the imposed 256-token limit was too low for the requested five-point explanation.
- Distributed worker inference now succeeds across all seven worker hosts. The local 8 GiB class (`apisix`, `apps`, `keycloak`) remains usable with qwen3:4b loaded, leaving roughly 3.1-4.0 GiB available in the observed runs; cold model startup from geographically remote `gis` storage is materially slower there (roughly 35-44 s observed) than on 10.200 workers. The 16 GiB PSN class starts the model in roughly 8-10 s and retains roughly 9-10 GiB available memory. `webgisrpr` also passed with about 13 GiB available.
- `think:false` disables Ollama/llama.cpp thinking mode (`thinking = 0` in the runner log), but qwen3:4b may still emit verbose self-explanatory/reasoning-like prose in normal assistant content. Treat concise-output control as a prompt/output-policy concern in addition to the runtime thinking flag.
- First NFS rollout attempt did not reach a mounted worker. On `gis`, the preflight correctly rejected `/m/ai/ollama/models/metadata/...json` as unreadable under `root_squash`, so the server export was never activated. `apps` and `apisix_psn` then installed `nfs-common`; `apps` saw `Connection refused` because no NFS server/export was active, while `apisix_psn` additionally exposed a job defect where the expected mount directory was absent at mount time.

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

1. physically validate the new catalog definition on `gis`: `pkg install ollama`, command/default identity, `ollama --version`, provider/facility discovery, and a foreground `srv` start path with service-instance environment configured away from the default model store;
2. decide how the production worker deployment reconciles the official 2.2 GiB package root with the already-validated 60 MiB CPU-only shared runtime on small-root nodes; do not introduce package-specific pruning into generic `pkg` without an explicit reusable contract;
3. once package/service ownership and worker artifact layout are aligned, make NFS mounts and worker endpoints persistent and validate restart/reboot behavior;
4. introduce the first dispatcher/orchestrator boundary over the validated worker pool and select model/role profiles, including at least one non-thinking model/profile for terse deterministic worker tasks.

## Blockers / open questions

- NFSv4.2 server/client operation, read-only shared Ollama runtime/model access, and local CPU inference are physically validated across every worker host in the current fleet.
- `libgomp.so.1` is missing on seven of the eight surveyed hosts; `webgisrpr` already has it. This remains relevant only for the standalone llama.cpp runtime because the validated Ollama CPU runtime bundles its own OpenMP library.
- Direct execution of the official llama.cpp Ubuntu x64 archive from NFS has not yet been validated on the two Ubuntu/kernel classes in the fleet.
- Select the first local model set by role after the shared runtime path works.
- Ollama is physically useful on every current worker class. The user has now selected the `pkg`/`srv` ownership direction: an `ollama` package and `ollama` service facility were added to `pkg-catalog` at commit `7e42e1d9fd6d986eba5fc8ac671641ac3b99f1b3`. Physical `pkg install`/`srv` validation is still pending.
- Decide whether Hindsight should be part of the first deployment or introduced after the basic local worker pool is operational.
