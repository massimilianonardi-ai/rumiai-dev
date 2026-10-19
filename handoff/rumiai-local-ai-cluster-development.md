# RumiAI local AI cluster development

Status: Active
Updated: 2026-10-14

## Goal

Develop and validate a practical local AI cluster for RumiAI using the available Ubuntu VMware servers, with CPU-only inference and workload distribution that remains effective despite relatively slow inter-host networking and severe local-disk constraints on part of the fleet.

## Current repository revisions

Remote HEADs verified for the 2026-10-15 post-consolidation consistency gate
(refresh before any later RumiAI task):

```text
rumiai-dev      233dba230bc1a577fa0c05a41266efd224da28b6  (pre-checkpoint)
rumiai-os       ef466362e9630b86d81b07ca647c2f2fbfd97a22
rumiai-tests    b8d5cbea34784d1a42af2b00bf22c09fec9d478c
pkg-catalog     d8156212ed8212bdb53931c3e2595686527ea951
rumiai-dev-PoCs a451b7903fddf4d4e5b2e8cbf66d82d51ac88932
```

The **physically deployed fleet** is aligned to the exactly pinned
`rumiai-os` revision `9f4524d9af44cc031ba039b88cfda8d2df0e1c65`
as verified by the successful operator job on 2026-10-14 (15:24:38–15:27:56
Europe/Rome). This is deliberately not the current GitHub `main` HEAD:
at the time of this preflight, `rumiai-os/main` was 29 commits ahead
of the deployed pin. Fresh remote HEAD retrieval remains mandatory.

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

- **2026-10-19 explicit execution authorization:** The user's `procedi` after fixing Olla on `gis` starts the **GIS Olla installation/validation phase**; the earlier 2026-10-15 no-configuration-change instruction described the *preceding design-only phase*. Stage and activate a conservatively loopback-bound Olla on `gis` using the existing product; do not treat this as blanket authorization to expose the other seven Ollama APIs or an unauthenticated enterprise gateway before source networks, firewall policy, and access rights are determined. An operator job under `rumiai-dev-PoCs/pocs/070-olla-gis/` has now physically installed and validated the first GIS-local Olla canary (2026-10-19 10:45); the seven other Ollama workers remain unconfigured in Olla. Run only from the credential-loaded enterprise operator environment.

- **2026-10-15 explicit user instruction — use an existing product for orchestration.** For the first inference-routing layer of the eight-node Ollama cluster, select **Olla** (https://github.com/thushan/olla) rather than designing/developing a RumiAI-owned dispatcher. Its isolated proxy/load-balancing responsibilities and upstream v0.0.29 release are evaluated at `products/ai/olla.md`. The user explicitly fixed `gis` (`10.200.0.19`) as the Olla installation host; the security perimeter and high-level AI task orchestration remain separate and not yet implemented; the first GIS-local Olla installation is now physically validated. Keep the current `0.0.0.0` future-binding direction for Ollama; the earlier no-configuration-change constraint is superseded **only for the GIS-local Olla canary** by the 2026-10-19 `procedi` instruction.

- **2026-10-15 explicit Olla placement:** Install the first Olla instance on `gis` (`10.200.0.19`), where the central Ollama instance and authoritative model/artifact storage are already deployed. This is a fixed user decision, **not** a recommendation to choose a separate VM or `apps`. Olla v0.0.29 installation on `gis` completed successfully at 10:45 on 2026-10-19; public network/service exposure and the seven remote workers are still outside the approved GIS-local canary. Co-location does not prove `gis` can reach the other seven HTTP endpoints; validate that connectivity and permitted callers before operational deployment.

- **2026-10-15 current explicit first-deployment choice:** plan for network-accessible Ollama HTTP endpoints, each bound to `0.0.0.0` when a later separately authorized configuration phase takes place. **No blanket changes to existing Ollama, NFS, firewall, network, or RumiAI product configuration are approved by the GIS Olla installation authorization.** The physically validated services still bind their respective loopback port `127.0.0.1:11435`. Binding all interfaces is not evidence of Internet reachability, network permission or caller authentication: the actual access perimeter, source networks and security controls remain to be established before exposure. This is a provisional first deployment direction, not approval of a permanent enterprise topology.

- The cluster consists of the rsudo credential groups:
  `apisix`, `apisix_psn`, `apps`, `apps_psn`, `keycloak`, `keycloak_psn`, `gis`, `webgisrpr`.
- `10.100.*` and `10.0.*` are local networks; `10.200.*` hosts are geographically remote. Inter-host networking is relatively slow even among local servers.
- Prefer independent model workers and request/workload parallelism over tensor/model parallelism that requires frequent cross-host synchronization.
- `gis` and `webgisrpr` may be used without a task-level CPU cap; the user will manage production contention when necessary.
- Credentials are not exposed to the assistant. Operations use `rsudo` / `rsudo-admin` from an environment where the user has already loaded credentials, or an explicitly available ChatGPT Work/Codex execution session.
- All eight servers keep their older `m` installation, and the current deployment of the `rumiai-os` runtime is installed on every server at `/m/src/git/rumiai-os`. The fleet physically completed a forward-only update from `6a964ba3f5c8acf462737e3b92daaf1af32de57e` to the exact operator-pinned revision `9f4524d9af44cc031ba039b88cfda8d2df0e1c65` on 2026-10-14. `gis` and `apps` both passed canary apply and service/inference verification before the other six were advanced. The earlier runtime-platform/bootstrap checks remain earlier milestone evidence; this rollout does not itself prove a fresh post-update reboot.
- Do not rely on host wall clocks for distributed correlation. Prefer run identifiers, operation identifiers and explicit command/result state.
- No further synthetic/network benchmarking is required before proceeding. The current hardware evidence is sufficient for deployment design.
- The large `/m` storage on `gis` is the shared-storage basis for the cluster because the VM disks cannot currently be enlarged.
- The first shared export should be read-only on worker nodes and should contain model/runtime artifacts. Persistent writable AI services such as Hindsight remain local to `gis` storage rather than writing through the worker share.
- The three small-root local VMs should not depend on Podman for the first llama.cpp deployment. Their first worker path is native execution of a shared llama.cpp runtime plus shared GGUF models.
- Do not place a normal rootless Podman graphroot on NFS/distributed storage. Podman may still be used later on nodes where local writable storage is sufficient or where a deliberately compatible storage layout is established.
- The intended workload model is hybrid: strong external reasoning (for example ChatGPT/Work) remains available as coordinator/reviewer, while local workers provide persistent, private and parallel inference capacity.
- Persistent Ollama system-host deployment uses a dedicated pre-existing POSIX service account named `ollama`. The account is system/non-login and is not managed by `srv`; deployment creates it administratively before `srv host system install`. Ownership remains least-privilege: package/runtime roots and the shared model store remain root-owned/read-only to the service, while `srv host system install` owns only the service State Instance HOME as `ollama`; configuration remains administrator-owned but readable by the service account.
- Physical system-host validation exposed a generic runtime-access bug: `srv host system install` prepared provider/default/dependency configuration and service HOME but not read/traverse access to the selected concrete package tree. Real `pkg install` uses private creation modes, so the non-root service account could not read `facility`/`facility-service`/`cmd` metadata and `--host-system-run` failed with `service-realization-invalid`. This is not Ollama-specific.
- `rumiai-os` commit `1f6476f6c1ebc50b5135adab8cd790be63133f61` fixes that by extending the existing recursive `pkg_dependency_runtime_access_prepare` path so each selected provider/dependency concrete becomes read/traverse/execute-accessible without changing ownership or granting write access. `rumiai-tests` commit `633e9207138c5eb4c44846765cc35bd6bc0cf8a8` removes the synthetic `umask 022` escape from `srv/host-system.test` and adds regression coverage for service-account access to private provider/dependency runtime metadata.

## Acceptance scenarios (current operator-path work)

- An operator `rsudo-admin jobs` template begins with POSIX `exec > "/m/src/git/rsudo-jobs.log" 2>&1`, preserving the explicitly required fixed-path log before any job work (each run truncates the previous log). This redirection is scoped to the job's nested subshell. Its scope starts only after `rsudo-admin` has selected/sourced the library and passed job editing/syntax validation. The controller must also forward preflight remote stdout/stderr on failure rather than discarding stdout held in a failed command substitution.
- With already-loaded rsudo credential groups, an operator selects exact runtime,
  catalog and CPU artifact pins; `check` inspects all eight deployed hosts without
  changing service registration or the checked-out runtime.
- Only managed tracked `osarch` selector changes are tolerated. Other tracked
  edits fail safely; untracked package projections and state are retained.
  Concurrent HEAD movement fails rather than being silently overwritten.
- `canary` first preflights all hosts, then reconciles `gis` and `apps` only.
  `rollout` performs the same canaries first, then the remaining six workers
  sequentially, stopping immediately when a node fails.
- Each successful updated node retains its installed exact Ollama provider and
  CPU artifact, remains boot-persistent, answers its API and exposes the shared
  model; a bounded real inference is required as a success check.

## Working design

### First inference-routing boundary — task-local working design, not a promoted API

**Product selection now supersedes a bespoke dispatcher PoC:** run the planned Olla HTTP proxy/load balancer on `gis` for the initial eight Ollama endpoints, not a custom router or a `rsudo`/SSH inference path. Olla upstream v0.0.29 provides model-aware selection, native health checks and registry, load balancing (least-connections/round-robin/priority), streaming and observability. Subsequent experiments should exercise **the real Olla distribution** at a pinned revision rather than reimplementing its routing mechanics. Do not claim Olla has been deployed or validated against the RumiAI hosts; all physical Ollama services remain loopback-bound until a later separately authorized configuration step. The higher-level AI task/tool/state orchestration remains outside Olla and is not selected by this decision.

**2026-10-15 current design scope:** The user's first network mode is direct HTTP from applications/orchestration to Ollama endpoints after a later bind change to `0.0.0.0`. The orchestrator must not assume application inference travels through privileged `rsudo` or SSH tunnels. There is no authorization to change host/service/network configuration in this work unit. Organize design into two separate responsibilities: (a) distributed inference dispatch, model eligibility, health, admission/queues, bounded concurrency, retry and metrics; (b) higher-level AI task/tool/state orchestration consuming inference. The latter is not the responsibility of an inference engine or a RumiAI sense, and is not approved as a new product component by this design note. Evaluate only the minimal first inference-dispatch workflow now.

**Candidate first-dispatch scenarios (not promoted contracts):** callers name a model/task profile rather than a concrete host; a configured inventory identifies eligible live workers; each worker has an explicit conservative in-flight capacity limit; failures before request acceptance may choose an alternate eligible worker, whereas uncertain/partially streamed requests must not be silently replayed; the response may stream through with per-request identifiers, timeout status and timing/token metrics. Existing Ollama `/api/tags`, `/api/ps` and `/api/chat` can provide model inventory, loaded-model visibility and inference timing, but `/api/ps` does not by itself prove the number of in-flight calls: the dispatcher must track its own admitted operations. Node selection can initially favor model availability, free admission slots and observed latency rather than assuming uniform hardware or equal network paths. All are design candidates for the user's review before implementation.

**Security/open deployment boundary:** Ollama's local HTTP API does not natively authenticate callers (Ollama official API authentication documentation, checked 2026-10-15). Binding `0.0.0.0` exposes the listening interface to whichever sources networking/firewalls allow, not necessarily the Internet. The application orchestrator cannot impose exclusive access control on clients that bypass it to call raw Ollama endpoints. Before the later exposure/configuration phase, establish who can reach the nodes, how that reachability is restricted, and whether the intended first deployment is a trusted experiment or must enforce application identity. Do not silently deploy an API gateway, proxy, VPN or firewall rule. The existing `11435` service port is not an implied choice of a new port.

Goal: a RumiAI caller requests bounded model inference without knowing the
individual Ollama host or making privilege-bearing `rsudo-admin` calls.
The existing eight-host inventory is evidence for possible workers; it is
not a newly established public scheduler/worker registry contract.

For the first Olla validation, check these responsibilities separately:
- request/role intent and optional execution limits at the caller-facing boundary;
- eligibility and health checks for candidate workers and explicit capacity/concurrency
  observations (no assumption of uniform latency on the two network classes);
- deterministic dispatch of one bounded, independent request at a time;
- transport to the selected worker and mapping of its real Ollama response/error
  to a provider-independent result, without leaking remote host identity into
  the caller's normal path;
- observable result metadata (worker choice, duration, status, retry decision)
  suitable for validating scheduling and diagnosing failures.

**Deployment-design boundary:** The operator's successfully tested SSH administration
does not define the intended AI inference transport; the current user choice
for the initial deployment is direct Ollama HTTP with planned `0.0.0.0`
listeners, with no configuration mutations now. The wider enterprise
topology, source network reachability, access policy, caller identity,
service placement and operational constraints still require explicit review
before a real network-facing deployment. Neither the currently bound
`127.0.0.1:11435` services nor the planned all-interface bind demonstrate
authorized access or network reachability. The user permits experimental
"build before complete system design" sequencing only when explicitly chosen
for a bounded validation; it is not a default planning method. Inference
dispatch should first be designed for the selected future HTTP topology,
and neither SSH tunneling nor a proxy is selected by implication.

First acceptance scenarios:
1. A caller supplies the inference task and bounded response constraints, not
   a host address; the dispatcher can select from a configured known-good
   worker set.
2. If one worker is unreachable before accepting a request, the dispatcher
   reports the failure or selects another eligible worker under an explicit
   retry policy. It must not blindly duplicate a possibly accepted inference.
3. If the selected worker answers, the caller gets the model result and
   interpretable execution metadata. A timeout is distinguishable from a model
   error or worker-unavailable outcome.
4. Concurrent requests do not all pile onto one worker merely because the
   others exist; the first PoC must measure dispatch decisions and in-flight
   concurrency, not claim a capacity improvement without evidence.
5. The first configured profile may use the physically validated
   `qwen3:4b` with `think:false`, but this flag alone does not guarantee
   terse output. Evaluate at least one non-thinking model/profile with actual
   measured accuracy/latency before establishing task-role defaults.

The initial Olla-backed experiment should test independent inference routing only. Memory,
Hindsight and generic multi-agent workflow engines are excluded from that
minimum experiment. The `m` substrate and RumiAI cognitive layer remain
distinct per `CURRENT-MODEL.md`; generic global orchestration is not a sense
per `SENSE-MODEL.md`.


- Worker reboot-safe model access persists the validated NFS model source and filesystem type, but uses a normalized declarative NFSv4.2 option set rather than replaying runtime-derived `findmnt` state. The stable worker mount options are `ro,vers=4.2,hard,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev`. Because the Ollama package root is local, only the model mount is a service dependency. On systemd hosts, a deployment-level drop-in for `m-srv-ollama.service` adds `RequiresMountsFor=/mnt/rumiai-ai/models` plus network/remote-fs ordering so the persistent Ollama service cannot start before the model store is mounted.

- Worker package realization is now fixed: each worker will materialize a normal concrete package identity `ollama@v0.35.1!linux-x86_64` through the existing `pkg_integrate` path, but the integration input root will be the already validated 60 MiB CPU-only pruned runtime instead of the full upstream 2.2 GiB extracted root. Package-local metadata/projections (`cmd`, `link`, `facility`, `facility-service`, dependencies/state) and package default/public bindings remain produced by normal `pkg` integration. This deliberately makes the pruned root the package root on worker hosts rather than introducing a separate runtime abstraction.

- Worker Ollama deployment now uses a derived CPU-only runtime artifact rather than installing the full official package on every worker. `gis` remains the authoritative build/staging host: derive from the already-validated official concrete package, remove only the validated CUDA 12, CUDA 13 and Vulkan payloads, verify the resulting runtime, record a deterministic manifest/digest, publish the immutable versioned CPU artifact on the shared runtime tree, and copy that small artifact locally to workers. Models remain on the read-only shared NFS store and worker HOME/state remains local. This is a cluster deployment procedure, not a new generic `pkg` primitive or package-specific pruning rule in `pkg`.

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
- The catalog package uses the official `ollama/ollama` GitHub release stream for `linux-x86_64`, current anchor/tag `v0.35.1`, exact asset `ollama-linux-amd64.tar.zst`, SHA-256 metadata from GitHub release assets, and `tar.zst` extraction. It exposes ordinary package commands `ollama` and `ollama-serve`; `ollama-serve` launches `ollama serve` and is the foreground start realization for service facility `ollama` compatibility level `1`. The archive matcher now uses POSIX ERE `[.]` literals rather than `\.` because the GitHub adapter passes the expression through `awk -v`; this removes awk escape warnings while preserving exact matching.
- Cluster-specific service settings remain mutable service-instance configuration rather than package metadata. Portable `srv start` consumes the normal user-scoped package configuration (`state-path user pkg ollama conf`); persistent `srv host system` consumes the service State Instance (`state-path system pkg ollama conf ollama`). In both cases `OLLAMA_MODELS`, `OLLAMA_HOST`, and `OLLAMA_NOPRUNE` belong in that mutable configuration rather than package metadata.
- The official upstream Linux amd64 package is still the full distribution (~1.44 GB compressed / ~2.2 GiB extracted) including CUDA/Vulkan payloads. The catalog package intentionally follows the official artifact and does not silently encode the experimental 60 MiB CPU-only pruning. This footprint remains a deployment concern for the smallest worker roots; the fleet rollout observed only about 804 MiB free on `apisix`, 1.5 GiB on `apps`, and 2.2 GiB on `keycloak` after installing the current runtime checkout.
- `osarch update` is an expected runtime mutation of the tracked selectors `bin/sys-osarch`, `bin/ext-osarch`, and `bin/ai-osarch`: the repository revision currently carries `linux-arm64` selector targets while the Ubuntu fleet correctly selects `linux-x86_64`. Therefore deployed runtime checkouts become Git-dirty in exactly those three paths after platform activation. Future rollout/update logic must treat those selector mutations as managed runtime state while still rejecting unrelated local changes.

## Completed

- 2026-10-15 follow-up CI on **current PoC HEAD**
  `a451b7903fddf4d4e5b2e8cbf66d82d51ac88932`: [run 38702868797](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/38702868797)
  completed with conclusion `success`. This is the final README-only follow-up
  on top of the previously green tested source commit
  `e516e5fd314716a2315392067ac9ef3ceab5d6f3`; it does not add
  new live-host evidence.


- 2026-10-15 GitHub CI result: `rumiai-dev-PoCs` at `e516e5fd314716a2315392067ac9ef3ceab5d6f3`, [run 38702344501](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/38702344501), job `operator-regressions`: success. Four relevant steps passed: `sh`/`dash`/`bash` syntax; simulated all-eight-host controller check/canary/failure sequence; isolated real-SHA-256 manifest/content verifier; and root disposable real-Git fast-forward, stale HEAD, untracked preservation and second-pin apply without extra `srv` actions. The job log contains all three explicit test `PASS` markers. This is not physical rsudo, systemd, Ollama or network validation of the committed variant; the 2026-10-14 8/8 log remains separate proof of the chat-inline variant.

- 2026-10-15 **repository operator-PoC consolidation (not physical revalidation)**.
  `rumiai-dev-PoCs/pocs/067-ollama-cluster-rollout/` now provides exactly
  the two selected operator sources `controller.lib.sh` and `rollout.job`.
  The former embeds the complete remote script and calls the actually
  defined `repair_ollama_nfs_worker` for all seven worker applies; the
  obsolete `host.sh` was deleted from main. The job begins *exactly*
  `exec > "/m/src/git/rsudo-jobs.log" 2>&1` and defaults to `check`.
  The worker verification resolves a pinned, external CPU `MANIFEST.sha256`
  when absent from the integrated package and verifies the real installed
  payload. Real-Git fixture and operator-sequencing tests were updated;
  a focused worker-manifest SHA-256 fixture test and GitHub Actions workflow
  were added. An isolated locally replicated verifier ran with real
  `sha256sum` and passed happy path, corrupted payload, corrupted
  manifest and absent manifest; this is NOT an execution of the exact
  repository test files. The exact committed source additionally passed
  GitHub Actions run `38702344501` at `rumiai-dev-PoCs` SHA
  `e516e5fd314716a2315392067ac9ef3ceab5d6f3`: real `sh`/`dash`/`bash`
  parsing, simulated 8-host controller sequencing, real disposable SHA-256
  fixture validation and real local-Git safety/second-pin verification all
  passed. This is **isolated-host/fixture** evidence, not actual production
  rsudo/NFS/systemd/HTTP execution of the consolidated source; physical
  validation remains outstanding. The consolidated PoC deliberately
  retains fail-closed validation of existing worker NFS/fstab/systemd
  configuration rather than the chat-inline operator's conservative NFS
  repair. It is not byte-for-byte or behavior-for-behavior identical to
  the physically successful sources; do not conflate the two validation
  scopes. The deployed fleet remains at the separately evidenced
  `9f4524d9af44cc031ba039b88cfda8d2df0e1c65` pin.


- 2026-10-14 **physical one-shot operator rollout complete**. The uploaded `rsudo-jobs(20261014-133231).log` contains 736 lines of host-generated results for 15:24:38–15:27:56 Europe/Rome. All eight hosts passed global preflight at old HEAD `6a964ba3f5c8acf462737e3b92daaf1af32de57e`, artifact/content checksum validation and existing NFS/systemd model dependency checks without requiring NFS reconciliation. Canary `gis` then `apps` both passed. The remaining six worker applies (`apisix`, `keycloak`, `apisix_psn`, `apps_psn`, `keycloak_psn`, `webgisrpr`) all passed. The evidence contains eight `Fast-forward` updates, eight `CLUSTER APPLY OK` markers, sixteen `rsudo.end status=0` reports, no `CLUSTER ERROR` or `REMOTE ERROR`, and final `CLUSTER ROLLOUT OK (8/8) revision=9f4524d9af44cc031ba039b88cfda8d2df0e1c65`. The executed inline script's successful apply path requires service registration and active/enabled checks, Ollama 0.35.1 readiness/version, visibility of `qwen3:4b` and completed bounded `/api/chat` inference. The uploaded log reports aggregate success markers rather than raw per-host HTTP JSON; attribute that evidence accurately. Repeated `rsudo.env-file-fallback reason=not-provided` warnings did not prevent successful remote execution. No actual host reboot, repeat-run idempotence test, or new benchmark is established by this log. The two successful operator sources were supplied in chat, not committed in a repository. **Pending realignment:** current `rumiai-dev-PoCs/pocs/067-ollama-cluster-rollout/host.sh` still requires in-package `MANIFEST.sha256`; it is not identical to the physically successful inline version, which checks the pinned external manifest against the integrated CPU package root. Update the persistent PoC/operator path and corresponding tests/documentation before claiming a repository-backed repeatable implementation. The separate historical `rsudo-admin` terminal-close / `): not found` issue is not proven repaired by this rollout.

- 2026-10-14 live operator preflight evidence: the uploaded `rsudo-jobs(20261014-124218).log` shows `gis` preflight OK at deployed `6a964ba3f5c8acf462737e3b92daaf1af32de57e` but `apps` exited `REMOTE ERROR [25]` because the attempted job assumes `/m/src/git/rumiai-os/pkg/ollama@v0.35.1!linux-x86_64/root/MANIFEST.sha256`. The integrated concrete root is not contractually required to retain the deployment artifact sidecar. No fleet mutation occurred in that run. An uncommitted two-file operator correction was composed for the chat: on workers, resolve a pinned `MANIFEST.sha256` from the concrete root when present, else the previously validated local artifact tree `/var/lib/ollama-worker/runtime/0.35.1-cpu/`, else `/mnt/rumiai-ai/runtime/`; hash the manifest against the immutable pinned SHA-256 and verify every listed payload file from within the concrete package root. `gis` continues verifying its central artifact tree. Isolated real-sha256 fixture checks passed for missing in-package manifest, local and NFS sidecars, absent sidecar, altered manifest and altered installed payload; simulated controller flow covered 8 preflights, 2 canaries and 6 remaining workers. POSIX parsing, selected-library function, exact fixed first-line log redirect passed. No physical `rsudo` execution of this correction, and no non-gis host physical checks beyond the recorded `apps` error, have occurred. This is chat-supplied operator code, not a deployed change.

- 2026-10-14 explicit operator correction: the job's exact first line is `exec > "/m/src/git/rsudo-jobs.log" 2>&1` (fixed absolute log path, not a timestamped relative pathname). This corrects two incorrect references in this handoff and supersedes previously chat-supplied job sources. No new job execution, service validation or physical fleet test was performed for this documentation correction.

- 2026-10-14 replacement operator one-shot was rebuilt from the current rsudo-admin/rsudo implementations as exactly two chat-inline POSIX shell sources: a selected local library embedding its entire remote program and a job whose first line redirects stdout/stderr via exec. The library defines and actually calls `repair_ollama_nfs_worker` for all seven workers. One run preflights eight hosts, records exact old HEADs, applies gis/apps canaries and then the remaining workers with fail-fast behavior. Safe reconciliation is restricted to the validated NFS model entry/mount/systemd dependency and an exact forward-only rumiai-os pin; CPU manifest/provider mismatch or unknown tracked/foreign NFS state fails closed. Local sh/dash/bash parsing, source/function-availability, rsudo stdin/argv simulated-boundary sequencing, exit/log propagation, disposable real-Git fast-forward/tracked/untracked/concurrency cases, and disposable worker NFS/systemd idempotence/conflict fixture checks passed. Actual rsudo-admin interactive UI, SSH/remote sudo, physical hosts, NFS, systemd, inference and the operator-host GitHub catalog fetch were not exercised here; physical rollout remains **unvalidated**. Two sources were supplied in chat, not committed to a product/PoC repository. The separate observed `): not found`/terminal-closing rsudo-admin issue is not validated as fixed.

- 2026-10-14 operator v2 (chat-inline, no downloadable-file dependency): after repeated
  uploaded logs showed only a legacy `repair_ollama_nfs_worker: not found`
  call, produced a visibly versioned **two-source** pair:
  `cluster-ollama-v2.lib.sh` defines `cluster_ollama_remote`,
  `cluster_ollama_call` and `cluster_ollama_run` including the complete
  remote script; `cluster-ollama-v2.job` prints `CLUSTER JOB v2`, checks
  the matching library version/function before any remote activity and calls
  `cluster_ollama_run` once with three pinned SHAs. One invocation checks
  all eight servers before mutations, tests gis/apps canaries, and advances
  through six other workers with stop-on-failure. Local `sh -n`, source
  execution, in-memory simulated rsudo/catalog controller tests (8+8,
  early canary failure and mismatch rejection), remote script shell parsing,
  and a disposable **real-Git** test of remote forward-only update,
  untracked-state preservation, tracked-edit rejection and stale-HEAD
  rejection passed. Remote systemd/API/provider responses were mocked;
  no physically connected rsudo-host operation has passed, and the prior
  legacy log is not physical evidence for this v2. This version is presented
  explicitly as full code in chat; old job/library must both be replaced.

- 2026-10-14 operator simplification for the first physical rollout:
  a single `rsudo-admin jobs` invocation now uses only two operator-facing
  files (`cluster.lib.sh` and `rollout.job`), supplied to the user directly
  in the chat as runnable shell sources. The remote host program is embedded
  inside the library instead of requiring a separately selected `host.sh`.
  The job pins the previously prepared `rumiai-os` target
  `9f4524d9af44cc031ba039b88cfda8d2df0e1c65`, catalog
  `5f3edca59cdc2dd721c50856d99736392f0fff0b`, and CPU manifest
  `f181030a940abc79aa98797c6ac13bd149d6d1cba545f1111886eea8c3445cfd`.
  Its single execution globally preflights all eight nodes, applies and
  checks gis/apps canaries, then the other six in sequence. This is a
  site-specific operator program, not a new product interface.
  Local POSIX syntax, controller sequencing and canary-stop tests passed,
  and the embedded remote shell passed an isolated real-Git forward-only,
  preservation and stale-head fixture with external service/API boundaries
  simulated. It has not been executed over real rsudo/SSH on the fleet and
  must not be reported as physically validated. The chat-supplied two-file
  version is distinct from the earlier, committed three-source PoC.
  No real fleet revisions or running services were changed in this work unit.

- 2026-10-14 second independent execution of the exact published
  `host.sh`, `controller.lib.sh`, `test-controller.sh`, and
  `test-git-safety.sh` sources on an isolated Linux runtime:
  POSIX `sh -n` PASS, controller sequencing PASS, and real local-Git
  safety fixture PASS (fast-forward, tracked-change rejection, untracked
  preservation, and stale-HEAD rejection). Source-text hashes were checked
  against the GitHub blob contents before execution. The controller test
  substitutes `rsudo` and catalog Git access; the Git test substitutes
  Ollama/systemd/provider boundaries while using real local Git.
  This is test evidence for the operator PoC control-flow and Git handling,
  not physical validation of the live fleet or service API. The central
  `gis` SSH port was not reachable from the isolated execution host, and
  no credential-bearing `rsudo-admin` session is available here.
  The PoC operator README was additionally clarified: `check` does not
  mutate checkouts/services but does fetch Git remote-tracking metadata.

- 2026-10-14 operator-path PoC committed at `rumiai-dev-PoCs` revision
  `7af19c24d0193fb9c8b5f51e42a711a528c63943` under
  `pocs/067-ollama-cluster-rollout/`. It reuses the existing
  `rsudo-admin jobs` workflow and remote `rsudo`, not a new package manager
  or `srv` supervisor. The editable pinned job defaults to preflight-only
  `check` and supports `canary` (gis/apps) and `rollout` (remaining workers).
  On remote hosts, it guards managed `osarch` changes and forward-only Git,
  preserves untracked operational state, verifies the selected concrete Ollama
  identity and artifact manifest, reconciles the host service, and verifies
  API/model/inference after restart. POSIX shell syntax checks, an isolated
  real-Git safety test, and a controller-sequencing test with simulated
  SSH/Git boundaries passed. No real rsudo connection, NFS/systemd operation,
  installed worker manifest, or physical service restart was exercised by
  this new job. It is not yet validated as the normal production path.


- NFS/service persistence is now uniform and physically validated across all seven Ollama workers. The final normalization on `apps` and `apisix` replaced their earlier verbatim-runtime fstab entries with the same declarative NFSv4.2 options used elsewhere, and both passed the cold dependency test. Together with the five recovered workers and the earlier real reboot canary on `apps`, the worker pool is now reboot-safe at the infrastructure level: persistent model mount, persistent `srv host system` service, local pruned package root, and shared read-only model store are all validated.

- Recovery after the PATH-collision fix is successful on all five affected workers. `keycloak`, `apisix_psn`, `apps_psn`, `keycloak_psn`, and `webgisrpr` now each contain the normalized declarative NFSv4.2 fstab entry (`ro,vers=4.2,hard,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev`), remount the shared model store successfully, pass the cold dependency test in which starting `m-srv-ollama.service` remounts `/mnt/rumiai-ai/models` automatically, expose Ollama 0.35.1 and `qwen3:4b`, and end with the expected `RequiresMountsFor` dependency active. This validates the corrected persistence procedure on both Ubuntu 24.04 and 26.04 worker classes.

- The representative repair on `keycloak` and `apisix_psn` exposed the exact cause of the previous persistence failure: the deployment job used bare `install -m 644` to replace `/etc/fstab`, but on these hosts `install` is shadowed by another command in the inherited PATH (the run emitted `ENV_PATH=...` instead of replacing the file). Consequently the managed NFS entry was absent and `mount /mnt/rumiai-ai/models` failed with “can't find in /etc/fstab”. This is a job-path bug, not an NFS or systemd dependency failure. Repair must use path-stable system utilities (for example `command -p cp` plus `command -p chmod`) rather than bare `install`.

- The first six-worker NFS persistence rollout exposed that live `findmnt -o OPTIONS` output must not be copied verbatim into `/etc/fstab`. `apisix` passed, but `keycloak`, `apisix_psn`, `apps_psn`, `keycloak_psn`, and `webgisrpr` failed during the cold unmount/service-start validation after the managed fstab entry and drop-in had been written. The captured option sets contain runtime-derived fields such as `clientaddr=`, `addr=`, `namlen=`, and on Ubuntu 26.04 `fatal_neterrors=none`; these are observed mount state, not the stable declarative mount contract. Repair with a normalized NFSv4.2 option set derived from the validated deployment intent (`ro,vers=4.2,hard,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev`), first on representative failed hosts `keycloak` and `apisix_psn`, then on the remaining workers.

- The actual reboot canary on `apps` is fully successful. After a real host reboot, `/mnt/rumiai-ai/models` was mounted automatically from the persisted NFS entry, `m-srv-ollama.service` came back enabled and active without manual intervention, the service drop-in remained effective, Ollama 0.35.1 listened on `127.0.0.1:11435` with `OLLAMA_MODELS=/mnt/rumiai-ai/models` and `OLLAMA_NOPRUNE=true`, `qwen3:4b` was visible, and the running process used the pruned concrete package root. This closes reboot-safety validation for the representative worker.

- The reboot-safety pre-canary on `apps` is successful. The live validated model mount was persisted into `/etc/fstab`, the `m-srv-ollama.service` systemd drop-in now declares `RequiresMountsFor=/mnt/rumiai-ai/models` with network/remote-fs ordering, and the cold dependency test passed: after stopping Ollama and unmounting the model store, starting the service caused systemd to remount the NFS model store automatically before Ollama became ready; Ollama 0.35.1 then exposed `qwen3:4b`. The remaining canary is an actual reboot of `apps`.

- Persistent pruned-package rollout is now complete on all seven worker hosts. After the successful `apps` canary, `apisix`, `keycloak`, `apisix_psn`, `apps_psn`, `keycloak_psn`, and `webgisrpr` each integrated the same 60 MiB CPU-only root as the normal concrete `ollama@v0.35.1!linux-x86_64`, selected the package/facility defaults, created/used a non-login `ollama` account, installed/enabled the native system service, started Ollama 0.35.1 from the pruned concrete root, exposed the shared `qwen3:4b` model, and completed validation with the service running persistently. This closes worker persistence validation for 7/7 workers.

- The corrected pruned-package canary on `apps` is now fully successful. The normal concrete `ollama@v0.35.1!linux-x86_64` remains only 60 MiB, the system service State Instance exports `OLLAMA_HOST=127.0.0.1:11435`, `OLLAMA_MODELS=/mnt/rumiai-ai/models`, and `OLLAMA_NOPRUNE=true`, `srv host system restart ollama` starts Ollama 0.35.1 from the pruned concrete root under account `ollama`, the shared `qwen3:4b` model is visible, the effective runtime environment matches the intended values, and the service is enabled/active. This validates the full worker deployment chain from pruned root through normal `pkg` integration and persistent `srv host system` lifecycle.

- The second pruned-package canary on `apps` successfully integrated the 60 MiB CPU-only root as the normal concrete `ollama@v0.35.1!linux-x86_64`, selected it as package default and facility provider, created/used account `ollama`, installed/enabled the native systemd unit, and launched `ollama serve` from the pruned concrete root. The readiness probe failed only because the service-instance `.m/env` file contained unexported shell assignments. The package launcher sources that file and then `exec`s the target, so service variables intended for Ollama must be exported. The running process therefore used Ollama defaults (`127.0.0.1:11434`, State Instance HOME model path, `OLLAMA_NOPRUNE=false`) instead of the intended `11435`/NFS/NOPRUNE settings.

- First pruned-package canary on `apps` did not reach `pkg_integrate`. Preflight and pinned catalog retrieval succeeded, including the expected artifact manifest digest, but the job incorrectly chose `$m_ROOT/pkg/.ollama-pruned-root.*` as its caller-owned staging path before the package store existed on that worker. The run stopped at `mkdir` with no package-model mutation. Retry with a staging root outside the package store (for example under `/tmp`) and let the normal integration path create/move the concrete payload into managed package storage.

- CPU-only local runtime rollout is now complete on all seven worker hosts. The remaining five workers (`apisix`, `keycloak`, `apps_psn`, `keycloak_psn`, and `webgisrpr`) each verified shared artifact digest `f181030a940abc79aa98797c6ac13bd149d6d1cba545f1111886eea8c3445cfd`, copied the 60 MiB runtime locally to `/var/lib/ollama-worker/runtime/0.35.1-cpu`, passed the full payload manifest, started Ollama 0.35.1 from the local runtime, exposed the shared `qwen3:4b` model over NFS, and completed a real `/api/chat` inference. Together with the earlier `apps` and `apisix_psn` canaries, this closes local-runtime deployment validation for 7/7 workers.

- Local-copy CPU runtime canaries are now physically successful on both representative workers. On `apps` and `apisix_psn`, the adopted 60 MiB artifact was copied locally, every payload file passed `MANIFEST.sha256`, local `ollama --version` reported 0.35.1, `ollama serve` started from the local runtime, the shared NFS model store exposed `qwen3:4b`, and a real `/api/chat` inference completed. The job returned status 1 only because the validation additionally required exact assistant content `worker-ok`; Qwen3 instead emitted ordinary explanatory text and stopped at the imposed `num_predict=16` limit. Exact-string compliance is not a runtime/deployment criterion and must not invalidate these canaries.

- The published CPU-only artifact is now formally adopted. Re-derivation from the official concrete package produced a 60 MiB tree that was byte-for-byte identical to the previously validated published runtime; its deterministic payload manifest verifies successfully and has digest `f181030a940abc79aa98797c6ac13bd149d6d1cba545f1111886eea8c3445cfd`.
- The corrected local-copy canary reached the copy step on both `apps` and `apisix_psn`, then failed before runtime validation because `cp -a` attempted to preserve permissions/attributes unsupported by the destination filesystem under `/var/lib/ollama-worker`. This does not indicate artifact corruption. Worker deployment should copy payload structure/content without archive-level ownership/timestamp preservation, then apply deterministic local modes and verify the manifest before execution.

- First CPU-artifact formalization run on `gis` successfully re-derived the official Ollama runtime from 2.2 GiB to 60 MiB by removing only `cuda_v12`, `cuda_v13`, and `vulkan`, and produced manifest digest `c3d7f446c8050d9b8dff8167c615bb9ac5c8583558184a11baf5ed6a06e14d6a`. Publication stopped safely because `/m/ai/runtime/ollama/0.35.1-cpu` already exists from the earlier validated deployment; do not overwrite that proven runtime blindly. The next step is to re-derive into a temporary tree, compare a payload manifest with the existing published runtime, and only adopt it as the immutable artifact if the manifests are identical.
- The first local-copy canary job on `apps` and `apisix_psn` exited before copying because it used the wrong shared path. The worker NFS mount `/mnt/rumiai-ai/runtime` already points directly at the exported `gis:/m/ai/runtime/ollama/0.35.1-cpu`; workers must copy from that mount root, not from a nested `/mnt/rumiai-ai/runtime/ollama/0.35.1-cpu` path.

- Current-head fleet rollout is complete at `rumiai-os` revision `6a964ba3f5c8acf462737e3b92daaf1af32de57e`. `gis` first passed the current-head canary with the persistent Ollama system service: account/provider/state configuration were preserved, concrete runtime access succeeded, Ollama 0.35.1 started under account `ollama`, the shared `qwen3:4b` model was visible, and `m-srv-ollama.service` remained enabled and active. Only after that canary passed, the exact same `rumiai-os` revision was rolled to `apisix`, `apisix_psn`, `apps`, `apps_psn`, `keycloak`, `keycloak_psn`, and `webgisrpr`; every node selected `linux-x86_64`, passed the runtime smoke check, and reported `RUMIAI UPDATE SUCCESS`. The fleet job ended with `RUMIAI FLEET ROLLOUT SUCCESS` for the exact target revision.

- Persistent Ollama system-host deployment is now physically validated on `gis` at `rumiai-os` revision `1f6476f6c1ebc50b5135adab8cd790be63133f61`. The deployment preserved operational untracked state, reapplied `linux-x86_64`, reconciled `srv host system install ollama ollama`, verified provider runtime access as the non-root `ollama` account, started the native systemd unit, exposed Ollama 0.35.1 at `127.0.0.1:11435`, exposed the shared `qwen3:4b` model, ran `ollama serve` as user `ollama`, and ended with the unit both enabled and active. This physically validates the generic concrete-package runtime-access fix for this real package/service path. Evidence for this earlier milestone is revision-specific to `1f6476f6c1ebc50b5135adab8cd790be63133f61`; the later fleet milestone above supersedes the need to treat that earlier revision as the deployment target.

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
- Current `rumiai-os` revision `f4d28822c4a2a875bd816ec3b15477dcfa905706` was cloned successfully to `/m/src/git/rumiai-os` on all eight cluster hosts. Every node reported RumiAI 2.0.0, selected `linux-x86_64`, resolved system state through the new runtime, and passed the `pkg` and `srv` bootstrap smoke checks. The fleet job ended with `RUMIAI FLEET INSTALLATION SUCCESS`.
- The first attempt to update `gis` to the runtime-access fix did not reach Git checkout or service revalidation: its preflight awk expression was syntactically invalid. The observed working tree contains the three expected tracked `osarch` selector mutations plus untracked operational/runtime material (`bin/ext-linux-x86_64/` and system-state configuration/registration paths). Those untracked paths are authoritative runtime state and public package bindings and must be preserved; rollout safety should reject unexpected **tracked** modifications while allowing existing untracked operational state unless it conflicts with the target checkout.
- First persistent `srv host system` attempt on `gis` created system account `ollama` (uid 995), preserved root-owned readable model storage, installed/enabled `m-srv-ollama.service`, and assigned the service State Instance HOME to `ollama`. The unit then failed immediately with `service-realization-invalid` before Ollama launch. Inspection identified the generic private-concrete runtime access defect described above; product and regression-test fixes are committed but not yet physically validated on `gis`.
- Portable `pkg ollama` service validation is complete on `gis`. With configuration in `state-path user pkg ollama conf`, `srv start ollama` launched the selected provider `ollama@v0.35.1!linux-x86_64`, Ollama consumed `OLLAMA_HOST=127.0.0.1:11435`, `OLLAMA_MODELS=/m/ai/ollama/models`, and `OLLAMA_NOPRUNE=true`, `/api/version` returned 0.35.1, `/api/tags` exposed the existing `qwen3:4b` model, CPU inference capability initialization succeeded, and `srv stop ollama` terminated the managed process cleanly. This closes resolver/download/extraction/integration/public-command/provider/portable-service validation for the package on linux-x86_64.
- The next Ollama service validation confirmed both public command bindings under `bin/ext-linux-x86_64`, `ollama --version` through the new `m` PATH (client 0.35.1), and system facility default `ollama@v0.35.1!linux-x86_64`. `srv start ollama` successfully launched a live process, but the readiness probe to `127.0.0.1:11435` timed out. Root cause is test-state scope mismatch: portable `srv start` uses the ordinary user-scoped package launcher, whereas the test wrote `OLLAMA_HOST=127.0.0.1:11435` into the system service State Instance used only by `srv host system`; therefore the portable process did not consume that configuration and used its default endpoint instead.
- First `pkg ollama` physical validation attempt before current RumiAI deployment stopped before package resolution because only the legacy `m` was available. After fleet deployment, the next physical validation reached the new package engine successfully: `pkg install ollama` resolved and installed `ollama@v0.35.1!linux-x86_64`, and `pkg default ollama` returned that exact identity. The test then failed with status `127` only because it incorrectly invoked `/m/src/git/rumiai-os/bin/ext/ollama`; platform-specific packages are publicly bound under `bin/ext-<osarch>` and are reached through the `m` PATH, so the correct test invocation is `/m/src/git/rumiai-os/m ollama --version`. The same run exposed awk warnings from the archive regex; the catalog regex was corrected forward-only.
- First NFS rollout attempt did not reach a mounted worker. On `gis`, the preflight correctly rejected `/m/ai/ollama/models/metadata/...json` as unreadable under `root_squash`, so the server export was never activated. `apps` and `apisix_psn` then installed `nfs-common`; `apps` saw `Connection refused` because no NFS server/export was active, while `apisix_psn` additionally exposed a job defect where the expected mount directory was absent at mount time.

## Current state

**2026-10-19 11:31 Europe/Rome — read-only seven-worker integration preflight prepared:** After the successful physical GIS-only Olla installation, the user instructed `procedi` toward connecting the seven remaining workers. The current authoritative worker evidence still shows Ollama bound only to `127.0.0.1:11435` on each worker. Direct GIS-to-worker HTTP will therefore remain unavailable without a separate server-network configuration change. Created `rumiai-dev-PoCs/pocs/070-olla-gis/network-check.lib.sh` and `network-check.job` for execution as the existing `rsudo-admin jobs` two-file workflow, with the required first-line fixed log redirect. The controller queries the seven documented rsudo groups for active/enabled service, loopback `/api/tags`, listening socket, actual global IPv4 addresses and route source toward GIS. It then checks GIS Olla health and performs bounded read-only route and GET `/api/tags` probes from GIS toward only dynamically discovered addresses in the documented `10.0.*`, `10.100.*` and `10.200.*` ranges. Multiple interfaces are reported separately and no source IP is selected by guesswork. The job **does not** change listener bind, Olla config, services, firewalls, NFS or routes. An isolated rsudo transport-boundary test was added to `test-network-check.sh` and wired to the existing Olla PoC CI. **No physical enterprise network check has been executed yet**, and no remote workers are configured in Olla. This is the minimum safe evidence-gathering boundary before a narrowed network exposure/ACL decision and subsequent authorized worker rollout.

**2026-10-19 10:45:24–10:45:33 Europe/Rome — GIS Olla physical installation and real inference PASS.** User-provided `rsudo-jobs(20261019-084549).log` records `rsudo.start` at `10.200.0.19` with `sh -s -- install`; verified SHA-256 for `olla_v0.0.29_linux_amd64.tar.gz` (`OK`); official Linux amd64 Olla `v0.0.29` with embedded build commit `421fd808e59a2879059062728d2b23ae`; Olla config validation `Result: PASS` (three profiles, embedded models defaults); created the systemd enablement symlink for `olla-gis-poc.service`; and reported `OLLA GIS INSTALL OK: real qwen3:4b proxied inference; remote workers NOT configured`. The `rsudo` operation completed with `status=0`. The `rsudo.env-file-fallback reason=not-provided` warning did not affect success. The pinned controller's success path also requires local Olla `/internal/health`, discovery of `qwen3:4b` and an HTTP `done:true` result from real `/olla/ollama/api/chat` proxied to the pre-existing GIS Ollama API; the response content is not printed in the operator log. The first canary is therefore **physically installed and operational for a bounded real local inference**. Physical post-reboot persistence, multi-worker selection/failover, remote worker reachability, security perimeter and off-host caller access remain unvalidated/not configured. The installed GIS-local Olla listener is intended as `127.0.0.1:40114` targeting existing Ollama at `127.0.0.1:11435`; no worker-wide changes are established by this log.

**2026-10-19 10:24 Europe/Rome operator transition:** On the user's renewed explicit `procedi`, changed only the existing GIS PoC `install.job` to default to `olla_gis_deploy install` and strengthened `test-local.sh` to assert the install mode and required fixed-path log redirection. Updated the PoC README for the already-passed physical `check`. The application install/controller implementation and all eight Ollama settings are unchanged. GitHub Actions [run 39222848277](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/39222848277) completed **SUCCESS** at exact PoC revision `fd6015d3e01daafd9ec83ad9b543edfc152b5635`: the real pinned Olla archive, digest and mock HTTP route were checked, and the real remote POSIX installer was executed under actual systemd on a disposable Ubuntu runner, including repeated install; test source asserted the new install-mode job and fixed-path log redirect. **The subsequent 10:45 physical GIS `install` run has now passed, as recorded above.** Fresh TCP connect from this assistant's environment to `10.200.0.19:22` again returned `ConnectionRefusedError`, so remote execution still requires the user's credential-loaded operator session.

**2026-10-19 physical GIS Olla preflight — PASS (superseded by completed installation):** The user supplied `rsudo-jobs(20261019-065800).log`, whose server-generated entries at 08:57:25–08:57:26 Europe/Rome report `rsudo.start user=mnardi host=10.200.0.19 command="sh -s -- check"`, `OLLA GIS CHECK: local Ollama healthy`, `OLLA GIS CHECK: Olla not staged`, `OLLA GIS CHECK OK`, and `rsudo.end status=0`. This physically proves that the existing enterprise `rsudo` operator path reaches `gis` and the read-only Olla check observed the pre-existing Ollama HTTP endpoint. The single `rsudo.env-file-fallback reason=not-provided` warning did not affect the exit status. It does **not** prove Olla installation, systemd startup, release download, or proxy inference on `gis`. The operator subsequently ran the committed `install` mode and supplied its successful 10:45 physical log; no additional installation rerun is required merely to prove the same result. The assistant still does not have an operator credential session to run this remotely.

**2026-10-19 GIS Olla install work unit:** `rumiai-dev-PoCs/pocs/070-olla-gis/` contains a two-file `rsudo-admin jobs` operator flow (`controller.lib.sh`, `install.job`) with pinned Olla v0.0.29 Linux amd64 archive SHA-256 `fafb482e50def1f56f210ef28b46c67021bb6e25b0ff0a595682e2aac214fcc4`. The initial job defaulted to a read-only `check`, which passed physically; **the committed `install.job` has now been changed to `olla_gis_deploy install`** after the user's renewed explicit `procedi`. The operator must refresh the local checkout before selecting it. `controller.lib.sh` retains a callable read-only `check` mode. The complete remote POSIX program downloads/verifies Olla, validates its YAML, protects pre-existing foreign config/binary/unit from overwrite, installs a dedicated `olla` account and separate `olla-gis-poc.service` on `gis`, listens on **`127.0.0.1:40114`**, connects only to GIS Ollama at **`127.0.0.1:11435`**, disables Olla's automatic retries and dashboard, and checks actual proxied `qwen3:4b` inference before reporting success. This is an Ubuntu/systemd-specific operator PoC, not a provider integrated into the m `pkg`/`srv` facility. **Physical installation and the first proxied GIS-local CPU inference have now passed** in the user's credential-loaded `rsudo` environment. The assistant's separate container still has no corporate `gis:22` access or operator credentials, which does not invalidate the operator's physical evidence. The existing Ollama configuration and the other seven workers have not been changed.

**Isolated execution evidence (2026-10-19):** GitHub Actions [run 39208513826](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/39208513826) **passed** at PoC revision `2781b640e5fcc25f9cf70144c388e56d0de3a4d1`. Its two steps exercised the pinned **real Olla v0.0.29** archive/digest, YAML validation and live proxy routing to a simulated Ollama HTTP backend; then extracted the **exact remote POSIX program** from `controller.lib.sh` and ran check, install, actual Ubuntu **systemd** service activation, health/proxied chat and repeated install on a disposable runner. Thus the upstream binary and systemd-based **operator remote program** are tested; the fixture Ollama does not compute tokens, and no encrypted credentials, actual `rsudo` transport, `gis`, physical inference or multi-worker network path is validated. The initial fixture lacked support for chunked proxy uploads, which was corrected in a forward commit. The current PoC revision after documentation updates differs from the CI-tested commit but does not change the remote installer; verify exact-source CI again if changed.

**2026-10-15 orchestration product and placement selection:** the user has explicitly rejected building a new dispatcher in favor of an existing product, and has fixed the installation host as **`gis` (`10.200.0.19`)**. Olla v0.0.29 is the selected first **inference-routing** candidate, based on current upstream release/docs and a non-normative assessment in `products/ai/olla.md`. The real pinned Olla executable has been started in isolated GitHub CI, with proxy traffic to a mocked Ollama backend and with actual systemd service management on the temporary runner. The user's subsequent 10:45 operator run physically installed and started Olla on `gis` and validated one real GIS-local proxied inference; eight-host routing has **not** been tested via Olla, existing Ollama fleet/client configuration has not been changed by this work unit, and no RumiAI runtime/package code was modified for Olla.

The user has selected a **future initial direct HTTP / `0.0.0.0` Ollama network binding direction** for a later networked deployment. The earlier no-config-change requirement was superseded *only* by the user's 2026-10-19 authorization of the new GIS-local Olla canary. Deployed Ollama bindings remain loopback-only as last physically evidenced; neither multi-host HTTP connectivity nor corporate security policy under the new network mode has been validated. This work unit does not reconfigure the existing Ollama fleet.

The follow-up two-file operator PoC is now committed but is *not* the source of the physically successful 8/8 log. Its isolated GitHub CI passed on 2026-10-15; physical validation and resolution of the NFS-repair behavior gap are still required before replacing the known-good operator scripts. No additional fleet mutation was performed during this repository-consolidation work unit.

The initial local AI worker pool is physically deployed and persistent. The 2026-10-14 operator run validated successful in-place updates across all eight hosts to the exact `rumiai-os` pin `9f4524d9af44cc031ba039b88cfda8d2df0e1c65`; the full 8/8 sequence returned success after HTTP readiness, shared-model visibility and real bounded inference on each host. This is physical deployment evidence for the exact pin, not for a later GitHub HEAD, another reboot, or repeat-run behavior.

`gis` is the authoritative central model/artifact host. Each of the seven worker hosts runs the normal concrete package identity `ollama@v0.35.1!linux-x86_64`, whose package root is the validated 60 MiB CPU-only pruned runtime. Worker services run persistently through `srv host system` under the dedicated non-login `ollama` account and use the shared read-only NFS model store at `/mnt/rumiai-ai/models`.

Worker model mounts use the normalized declarative NFSv4.2 configuration:

```text
10.200.0.19:/m/ai/ollama/models
    -> /mnt/rumiai-ai/models
    nfs4
    ro,vers=4.2,hard,proto=tcp,timeo=600,retrans=2,sec=sys,_netdev
```

On every worker, `m-srv-ollama.service` has a deployment-level systemd dependency on `/mnt/rumiai-ai/models` through `RequiresMountsFor`, so service startup causes the model mount to be satisfied first. Cold unmount/service-start recovery is validated on all seven workers; an actual reboot is validated on `apps`.

The previous shared-runtime llama.cpp direction is no longer the current worker deployment. Direct llama.cpp remains only a lower-level fallback/reference experiment.

## Next action

1. With isolated GitHub CI now **green** for the consolidated two-file PoC,
   resolve whether its explicit fail-closed NFS configuration check should
   regain the conservative NFS repair behavior of the successful chat-inline
   operator; do not silently treat the two variants as identical.
   Then perform a proportional credential-loaded physical `check` and,
   if justified, repeat-pin/idempotence test on that exact source. A
   post-update reboot check remains distinct. Keep the mandatory first line
   `exec > "/m/src/git/rsudo-jobs.log" 2>&1`, preserve all untracked
   operating state and never repeat the completed 2026-10-14 8/8 rollout
   merely to create test evidence.
2. **The GIS-local Olla v0.0.29 canary is physically installed and
   has completed one real proxied `qwen3:4b` inference**, evidenced by the
   user's 2026-10-19 10:45 `rsudo` log (exact result summarized above). Do not
   re-run installation simply to generate evidence. The immediate remaining
   GIS-local checks are post-reboot persistence and any operator-desired
   repeated bounded inference; they have not been evidenced by this log.
   **Immediate next operator step:** from the credential-loaded enterprise
   `rsudo-admin jobs` menu select `pocs/070-olla-gis/network-check.lib.sh`
   and `network-check.job`; review and execute the read-only inventory,
   then inspect the resulting fixed-path `/m/src/git/rsudo-jobs.log`.
   The new job inspects all seven workers and probes GIS-to-worker HTTP
   without changing server settings. On the basis of actual host addresses,
   routes, service bind/listeners and HTTP results, establish
   corporate client/source-network policy, GIS outbound reachability,
   authenticated or explicitly restricted API access perimeter and
   exposure limits. Do **not** open network-facing Ollama or Olla listeners,
   change firewalls or add the seven endpoints solely on the strength of
   the GIS-local PASS. After that separate security/network approval,
   exercise model-aware multi-worker routing, concurrent streams, worker
   outage/failover, queue/load behavior and observability on real hosts.
   Higher-level AI task/tool orchestration remains a separate decision.
3. Decide whether Hindsight belongs in the first orchestrated deployment or
   should follow after dispatcher/model-role validation; do not put its
   writable state on the read-only NFS model share.

## Blockers / open questions

- **2026-10-19 GIS-local install resolved; later validation remains:** The assistant's own runtime still cannot directly access enterprise GIS SSH, but the user's successful `rsudo-admin` log is actual physical evidence that Olla v0.0.29 was installed on `gis`, systemd enabled it and a bounded real proxied chat completed. The log does not establish persistence after reboot, a durable monitoring period, authenticated off-host client access or multi-worker routing. The next deployment boundary is the separate seven-node network/security plan, not a repeat of the now successful local install.

- Olla v0.0.29 is selected as a **first inference-routing product**, not as a new authenticated enterprise gateway or a task/agent orchestrator. Current upstream documents no inbound proxy authentication. Its default retry-on-connection-error may replay a request whose acceptance was ambiguous. Before use, define permitted source networks, client access to the fixed `gis` placement, allowed actions, dashboard exposure, retry policy, and how to validate available model/worker capacity. Product evaluation plus physical GIS-local install/inference evidence is available; live routing among eight RumiAI hosts remains unvalidated. The GIS-local Olla canary has been installed, but no general Ollama/network change has been authorized or performed.

- 2026-10-15 explicit methodological correction: the successful CPU Ollama
  eight-host experiment preceded clarification of the user's intended
  enterprise deployment topology. Neither admin SSH reachability nor current
  loopback bindings authorize a final application transport or coordinator
  location. Do not solve the missing requirements by choosing SSH/tunnels/
  proxies unilaterally. First establish the deployment goals, enterprise
  constraints and acceptance scenarios with the user; only deliberately
  user-authorized experiments may reverse that design-before-build order.
  This is a current open architecture decision, not a defect in the evidence
  supporting the completed 8/8 validation.


- The operator's **exact first job line** remains `exec > "/m/src/git/rsudo-jobs.log" 2>&1`; never replace it with a timestamped/relative pathname. A **two-file version with corrected manifest verification is now committed** in the PoC, but it is not the exact physical 8/8 source: the committed version fails closed on NFS mismatch while the successful chat-inline version offered conservative NFS reconciliation. Both sources actually define and invoke the repair-named worker function in their own rollout path. No physical re-run of the committed code; isolated GitHub Actions run `38702344501` passed at SHA `e516e5fd314716a2315392067ac9ef3ceab5d6f3` with mocked external services. The separately reported `rsudo-admin` terminal-closure / `): not found` behavior remains unproven as fixed.

- The user's four rsudo-jobs attachments dated 06:58, 08:00, 09:10 and 09:36 have been read from mounted file bytes and are all exactly 264 bytes with identical SHA-256 `016ee951114b3758690f42238feab2b7bda88dd8076eeec3e2541235e348cdcb`; each contains the same old `repair_ollama_nfs_worker: not found` output and the same job token; none records `cluster_rollout`. The user clarified that `): not found` came from `rsudo-admin` itself, not from the cluster job or library, and disappeared after an execution of the scripts unexpectedly closed the entire terminal. The rsudo-admin implementation places sourced job effects in nested subshells and ordinarily returns to its menu; terminal closure is not established as a normal or repaired condition. Do not conflate the two defects or assume the rsudo-admin issue is resolved by a new session. None of the repeated 264-byte legacy logs establishes a new fleet rollout.

- A complete real-host 8/8 operator rollout is evidenced by the
  2026-10-14 log and exact deployment SHA. The newly committed self-contained
  two-file PoC fixes the superseded in-package manifest assumption but has
  only isolated helper-level SHA evidence so far; its shell tests are
  committed and passed isolated GitHub Actions workflow run `38702344501`.
  Repeat-run idempotence of the exact committed code was exercised using
  disposable real Git and mocked service/API boundaries; the corresponding
  physical repeat-run, NFS recovery parity and post-update reboot have
  not been demonstrated. The assistant
  cannot access the operator's credential-loaded rsudo session.

- NFSv4.2 server/client operation, read-only shared Ollama runtime/model access, and local CPU inference are physically validated across every worker host in the current fleet.
- `libgomp.so.1` is missing on seven of the eight surveyed hosts; `webgisrpr` already has it. This remains relevant only for the standalone llama.cpp runtime because the validated Ollama CPU runtime bundles its own OpenMP library.
- Direct execution of the official llama.cpp Ubuntu x64 archive from NFS has not yet been validated on the two Ubuntu/kernel classes in the fleet.
- Select the first local model set by role after the shared runtime path works.
- Ollama is physically useful on every current worker class. The user selected the `pkg`/`srv` ownership direction. All seven workers now run the same digest-derived 60 MiB CPU-only root as the normal concrete package `ollama@v0.35.1!linux-x86_64` under persistent `srv host system`, use the shared read-only NFS model store, pass cold mount/service dependency recovery, and are configured uniformly for reboot-safe startup; an actual reboot is physically validated on `apps`.
- Decide whether Hindsight should be part of the first deployment or introduced after the basic local worker pool is operational.
