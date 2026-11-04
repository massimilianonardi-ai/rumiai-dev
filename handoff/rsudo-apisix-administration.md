# rsudo APISIX and Keycloak module replacement

Status: Active
Updated: 2026-11-04

## Goal

Replace the incomplete existing rsudo APISIX administration module with a safe, complete shell administration API across APISIX deployment modes, while retaining the previous implementation as explicitly named legacy source. Also preserve the existing Keycloak module under a legacy name and reserve the original module name for its new implementation. Keep both responsibilities separate from rsudo SSH/sudo execution.

## Current repository revisions

- rumiai-dev: bcbdb61757584a403e2e6325128c26a76c2c2ee9 (before this checkpoint)
- rumiai-os: 887f854178ff5a3eedf831f7341ebb7a3d1406b1 (read-only APISIX runtime evidence; unrelated concurrent commits preserved)
- rumiai-tests: c2f7b9e47108da1aa9c33e5463a06e9fb735c191 (permanent missing-pidfile boundary test)
- m-os: 31693e814f682690adfd48185da822f7f5007f9e (not involved)

Fresh HEAD checks remain mandatory before each further RumiAI action.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/RSUDO-APISIX.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/DIAGNOSTICS.md
- TESTING.md
- handoff/README.md

## Fixed task-local choices

- Rename the existing `lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh` to `rsudo-mod-apisixlegacy.lib.sh` and existing `rsudo-mod-keycloak.lib.sh` to `rsudo-mod-keycloaklegacy.lib.sh`. New development owns the two original leaf names.
- The new APISIX module uses a single shell library and INTERNAL routing, not alternative provider libraries that override common function names.
- APISIX deployment type must be discovered from authoritative effective remote configuration or a safe, verified management surface before operations. Do not silently guess a mode on failed discovery.
- Offer shell access to the complete supported administration capability, plus concise, low-parameter conveniences for common tasks.
- Do not require JSON files for ordinary use. JSON may remain the internal wire representation and may be supplied via shell input/stdin; files are optional, especially for templates.
- Preserve rsudo's SSH/sudo and credential-group behavior; avoid introducing a second transport or requiring remote m installation.
- Preserve user/concurrent changes and forward-only history.

## Acceptance scenarios

1. Operator with existing rsudo credentials can inspect remote APISIX mode with one shell command, without knowing where its config is installed. A fully qualified override may be offered when automatic evidence is genuinely ambiguous.
2. Operator can list/read route, upstream and service resources consistently on a supported mode; provider-specific details are hidden.
3. Operator can create an ordinary upstream, service and route with a few parameters and no temporary JSON file.
4. A caller can express any supported API operation and complex resource payload directly through arguments/stdin, optionally a template; shell source and JSON data remain separate.
5. On standalone API-driven, changing one resource cannot silently replace unrelated resources or publish stale versions. On file-driven, edits do not truncate a live configuration and do not bypass its required full-document validation.
6. Secrets do not appear in logs, normal output, remote command arguments or insecure temporary artifacts. Unsafe/unknown modes fail closed with an actionable diagnostic.
7. The legacy APISIX and Keycloak modules remain explicitly addressable without shadowing the new modules; the new Keycloak module evolves separately.

## Working design

### Complete development plan (active, detailed, not a promoted contract)

This is a resumable task implementation plan and a set of provisional technical decisions, not an additional normative knowledge base. The canonical sources above prevail. Every phase must update this section or the relevant current specification when a decision becomes binding. Phases may proceed in short increments, but no feature may be declared supported before its explicitly stated validation gate.

**Delivery target.** One current `rsudo-mod-apisix.lib.sh` with *internal routing* among supported APISIX administration modes; a complete version-aware shell administration API including obscure resources, plugins and specialty endpoints where APISIX permits them; convenient few-operand shell commands for ordinary use; no mandatory authored JSON files; a separately modernized `rsudo-mod-keycloak.lib.sh`; direct `apisixlegacy` and `keycloaklegacy` access until migration is proved. `rsudo` remains SSH/sudo, not an orchestrator. Complete means tested behavior, not a sketch of dispatch functions.

**Milestones and dependencies.** A baseline -> B capability inventory -> C effective instance discovery -> D secure transport -> E generic read-only interface -> F traditional CRUD -> G standalone file-driven CRUD -> H standalone API-driven snapshot CRUD -> I full Admin API coverage -> J low-operand conveniences -> K independent Keycloak and APISIX integration -> L migration, specs, validation and closure. B/C research can overlap; D may be prototyped while C is investigated; E and secure transport must precede any writes. F/G/H each have an independent readiness gate. Keycloak work may proceed separately when APISIX foundations exist. Never route unsupported requests to a superficially similar endpoint.

#### A. Baseline, consistency and truthful test evidence

- Refresh remote HEADs for `rumiai-dev`, `rumiai-os`, `rumiai-tests` and reconcile concurrent changes before each write.
- Inventory existing APISIX and Keycloak public shell functions, direct consumers/jobs, command dispatch, the 35/16 function legacy facades, manual topics and applicable permanent tests. Keep existing interfaces callable; do not silently redefine their behavior.
- Execute the focused legacy and mode tests through the real `m` entrypoint on a real development or isolated target, not solely by scanning source. Read actual GitHub runner outcomes by revision; a queued workflow is not PASS.
- Audit current `mode`: configured-on-disk versus running-process identity, ambiguous multiple installations, `-c`, `APISIX_PROFILE`, packaged/source/container root, launcher/symlink resolution, LuaJIT dependency search, runtime env substitutions, default roles and providers, error statuses and stdout discipline.
- Add targeted regression tests for any verified defect; only an external host/SSH/LuaJIT boundary may be simulated and such a test must not claim real APISIX-parser validation.
- **A exit**: real loader/forwarding tests PASS; mode fail-closed cases verified; unproved runtime identity remains visibly unproved.

#### B. Release/resource/capability matrix

- Choose a real initial APISIX release/commit and at least one representative second revision. Record their documented Admin API versions, configured defaults, OpenResty/LuaJIT and dependency requirements. Never infer universal behavior from one source checkout.
- For each role/provider, map supported actions and endpoint names: traditional etcd, control plane etcd, etcd data plane (no local Admin API), standalone file-driven YAML, standalone file-driven JSON, standalone API-driven.
- Inventory routes, stream routes, services, upstreams, consumers, consumer groups, SSL/certificates, global rules, plugin configs, plugin metadata, secrets, proto definitions, installed plugin schemas, health/status and other control endpoints. Record methods, path forms, IDs, pagination, server-generated IDs, body envelope and version gates; explicitly mark unsupported operations.
- Verify standalone `GET/PUT/HEAD /apisix/admin/configs`, whole-snapshot replacement, resource-version fields and accepted-versus-applied semantics against actual server behavior. Confirm special handling of plugin/TLS/secret fields.
- **B exit**: reviewed capability table per mode/version; no invented generic CRUD support for an endpoint absent from a provider.

#### C. Active-installation and configuration identity

- Design an APISIX-aware, remote read-only resolver for actual selected process/service/container, executable, deployment root, config `-c`, `APISIX_PROFILE`, provider, Admin API listener, mode/version and target namespace. Reuse APISIX-owned parser/effective-config mechanisms where possible.
- Treat `conf/.customized_config_path` as a CLI temporary index, not proof that a running process uses that configuration; never silently prefer an arbitrary `config.yaml` when multiple profiles/configs exist.
- Discover target identity from real service/process evidence on each supported platform. Do not assume `/proc` or systemd on all remote hosts. Allow an explicit advanced selector but verify it matches the target.
- Distinguish `configured-only`, `running-confirmed`, `not-running`, `ambiguous`, `unreadable`, `version-unsupported`, `no-admin-plane`. Preserve evidence provenance and refuse writes if actual instance/config identity is not established.
- **C exit**: verified runtime identity on representative traditional and standalone installations, plus fail-closed ambiguity/not-running tests.

#### D. Safe credential and data transport

- Reuse `rsudo` connection/SSH/sudo state and its stdin/authentication separation. Do not require an `m` daemon on target or make `rsudo` select API infrastructure.
- Resolve authorized Admin API keys from effective server config or explicit operator credential context; no hard-coded values, local key echo, `eval` assignment, credential inheritance leaks, or secret in command arguments.
- Design a remote static shell source/transport protocol in which user data remains inert data. Both JSON body and key may be streamed securely without either being interpolated into shell code. Audit remote process argv, shell tracing, temporary paths/permissions and diagnostic output.
- Prefer an existing suitable `m` HTTP facility where its documented capability fits; otherwise declare remote `curl` dependency and verify supported features. Set explicit timeout, TLS verification, listener address and proper HTTP status-body handling.
- Distinguish connection, timeout, TLS, missing key, 401, 403, 404, validation 4xx, conflict, 5xx and malformed response via local status/diagnostic identities.
- **D exit**: real rsudo transport and isolated HTTP server tests, including credential non-disclosure and arbitrary quoted/unicode JSON payloads; no unsafe request path enabled.

#### E. Internal routing and read-only resource API

- Keep a single APISIX library; private `_rsudo_mod_apisix_*` helpers own discovery, validation, capability lookup, HTTP/file adapters and normalization. Public `rsudo_mod_apisix_*` functions implement `rsudo apisix list/get/inspect/version/health` without requiring caller knowledge of the backend.
- Traditional/decoupled control plane: read via Admin API, preserving IDs, pagination and semantics of empty results versus missing resources.
- File-driven standalone: read and parse active YAML/JSON full document, select requested resources without changing or resolving-away unrelated fields or environment variables.
- API-driven standalone: read full in-memory snapshot and select requested resources without pretending there are per-resource endpoints.
- Return machine-usable data on stdout, diagnostics on stderr, status for unsupported/read failure; avoid leaking token/secret fields and do not mask transport errors as empty lists.
- **E exit**: real route/service/upstream reads for all supported modes; expansion to resource matrix only when each backend semantics are verified.

#### F. Traditional/decoupled control-plane mutation

- Implement correct create/replace/patch/delete verbs and collection-vs-ID paths for each supported resource. Respect actual APISIX version's POST/PUT conventions, IDs and server-side validation.
- Accept typed shell arguments and structured JSON from argument/stdin, with optional file/template. No shell code generation from user JSON and no mandatory JSON file creation.
- Separate one-resource operations from compound multi-resource recipes; do not invent cross-request transaction guarantees. Define idempotence, retry and partial failure semantics with clear destructive-action intent.
- **F exit**: isolated real control-plane CRUD per resource including duplicate, not found, invalid JSON, forbidden, stale/competing update and rollback of test-created objects.

#### G. Standalone file-driven YAML/JSON mutation

- Identify selected active `conf/apisix.yaml` or `conf/apisix.json` precisely; reject wrong config/version, unsafe symlinks and container namespace mismatches.
- Use APISIX-compatible full-document parsing, preserve unknown resource/plugin fields, anchors, quoting-sensitive content and environmental substitutions. Generate whole valid document; YAML requires terminal `#END`, JSON does not.
- Stage edits as private same-filesystem files with correct owner/permissions and cleanup; validate whole document with APISIX's real validator before publish. Enforce expected original revision and a suitable serialization/lock mechanism; ordinary compare-then-`mv` is insufficient if external writers are not coordinated.
- Publish atomically where filesystem guarantees exist; verify reload acceptance/convergence where exposed. Distinguish publication complete, accepted, visible and rejected. Define rollback on detected failure; fail closed if guarantees cannot be provided.
- **G exit**: real YAML and JSON standalone CRUD, concurrent writer, interrupted publish, corrupt config, unknown fields, unsafe permissions and post-reload tests.

#### H. Standalone API-driven whole-snapshot mutation

- Read authoritative in-memory full snapshot and exact server-supported resource-version/precondition fields. Never send a single-resource body directly to `/configs`.
- Transform only intended resource while retaining all unrelated resources, server-supported fields and plugin state; apply full replacement with correct version increments/schema.
- Prove optimistic concurrency if server supports atomic conditions. Otherwise require verified serialization/owner coordination; GET + unconditional PUT with stale-check alone **does not** prevent lost updates. Respect ownership by Ingress Controller/ADC and default to read-only for controller-managed configuration.
- Interpret HTTP `202` as accepted, not guaranteed applied. Verify effective state/convergence and classify uncertain/failed updates, with safe retry semantics and rollback limits.
- **H exit**: real standalone API-driven CRUD, simultaneous writers, stale version, unrelated resource retention, controller ownership, failure recovery and worker convergence tests.

#### I. Full provider-supported administration coverage

- Extend routes/services/upstreams to every resource in the matrix, including consumer/auth, certificate/SSL, stream routes, global and plugin-specific configuration, schemas, secrets and status/control features.
- Implement guarded advanced `request`/capability dispatch for documented but uncommon Admin API operations. Enforce supported verb/path/mode/version allowlists, consistent key handling and no arbitrary privileged URL reachability.
- Provide validation, inspect/export/diff and secret-redacted diagnostic functionality where server supports it; keep data model precise, not a lossy low-level JSON wrapper.
- **I exit**: matrix-driven coverage reports real success, unsupported and failure statuses for every targeted method/mode/resource/version.

#### J. Simple operator shell APIs without JSON files

- Add succinct public conveniences: one-node and multi-node upstream; service-to-upstream; host/path/method route; simple consumer/plugin setup; common inspection/update/delete actions.
- Use a few explicit positional/flag parameters and safe defaults only. Validate IPv6, URL encoding, Unicode, spaces, duplicate names and target existence; no default insecure OIDC session secret.
- Internally compose verified generic APIs rather than duplicating provider-specific behavior. Keep direct shell functions and `rsudo apisix <operation>` entrypoints aligned.
- **J exit**: operator creates/upgrades/inspects/removes an upstream + service + route with no JSON file on each supported backend, with permanent user-path tests.

#### K. Independently modernize Keycloak and cross-module recipes

- Preserve `rsudo-mod-keycloaklegacy.lib.sh`; inventory current Keycloak REST/OIDC capabilities, realm/client/user/group/role/authorization resources and target versions.
- Replace transitional `rsudo-mod-keycloak.lib.sh` forwarding with a real authorized token flow, TLS handling, expiration/refresh, safe request/error statuses and complete supported Admin API shell access. No `eval`, token in argv/logs or insecure defaults.
- Implement few-parameter common Keycloak actions; only then APISIX OIDC/authz recipes that compose the two modules without coupling basic APISIX to a Keycloak dependency.
- **K exit**: real isolated Keycloak CRUD/permission/expiry tests and an end-to-end APISIX authn/authz route where feasible.

#### L. Migration, canonical documentation, final validation

- Preserve two legacy library identities and their explicit command dispatch through migration. Inventory and migrate all real consumers before changing former function meanings; document old limitations and safe alternatives without breaking unsuspecting jobs.
- Promote **settled** APISIX and Keycloak subsystem contracts to their own current canonical specs under `rumiai-dev/specifications/rumiai-os/` and route via `specifications/README.md`; provisional designs stay in this handoff until resolved. Update `rsudo` and all current/legacy library manuals for observable changes.
- Keep permanent structural, behavioral, security, concurrency and integration tests in `rumiai-tests`. Test via real `m` entrypoints; external-boundary fixtures prove boundaries only, never full server integration. Test individual scripts on Ubuntu 26.04 ARM64, macOS and relevant auxiliary Linux; confirm against actual deployed APISIX/Keycloak versions before operational rollout.
- Run targeted development tests after each change, then clean-host and live-service validation when proportional. Record exact product/test revisions, real result classes and observed failure causes. Observe strict forward-only Git, concurrency reconciliation and handoff checkpoints.
- **Final L gate**: all advertised operations/modes and minimal-input workflows validated; unverified behavior rejected explicitly; no secret exposure, lost updates, missing manual, stale spec, unresolved working design or mislabeled PASS. Finish handoff with Complete snapshot, then remove in a later forward commit.

### Cross-cutting verification matrix

1. **Configuration identity:** no service, multiple APISIX instances, custom `-c`, profile, symlink, container/namespace, wrong/closed Admin API, on-disk vs process divergence.
2. **Providers:** traditional etcd, decoupled control plane and data plane, standalone file-driven YAML and JSON, standalone API-driven, disabled admin, unknown provider/version, external controller-owned state.
3. **Transport and security:** SSH/sudo/credential group, secret sourced securely, argument/log/trace secrecy, TLS, redirects, timeouts, invalid auth, 4xx/5xx, malformed bodies, interrupted streaming.
4. **Data:** empty/missing lists, pagination, arbitrary JSON, unknown plugin fields, Unicode/newlines/quotes, certificates and protected secrets, cross-resource references, version differences.
5. **Safety:** simultaneous writers, stale snapshots, fail-over, atomic file publication, partial API success, recovery after interruption, controller co-ownership and worker convergence.
6. **Test authenticity:** each claimed PASS must identify exactly what was run, server/host and revision; boundary fixture != live APISIX; passing focused test != passing full validation.

### Work-unit A observed evidence and B reconnaissance (2026-11-04)

- Run 41815144458, product `rumiai-os@d228cf32`, suite `rumiai-tests@7f047fa5`: Ubuntu 26.04 ARM64 `legacy-modules.test` PASS and `apisix-mode.test` PASS through actual `m`; macOS queued at inspection time. The mode test used an external LuaJIT fixture, not installed APISIX.
- Run 41816598717, product `rumiai-os@d228cf32`, suite `rumiai-tests@d5377fed`: Ubuntu 26.04 ARM64 focused task VALIDATED with three PASS tests; `apisix-parser-live.test` executes real APISIX 3.19.0 installed LuaJIT, `lyaml`, defaults and the exact `rsudo_mod_apisix_mode` remote shell program in the pinned Debian image. Only SSH/sudo is substituted by Docker stdin; this neither starts a gateway nor proves active runtime identity. Fixed multiarch image index digest: `sha256:9a7e45dc943fbf10ec916d1232bae4cda9302ae28a4696cfb83c2da01d261141`.
- `rumiai-tests@5dda91b2` extends the real-parser test to APISIX 3.16.0 (pinned image index `sha256:b921bdef3cfb2ca72e483d643f40e7843683ff8e188984489c2020f17654ee88`) and 3.19.0, with seven valid mode configurations and five rejection cases per image. Run 41817022586 completed its Ubuntu 26.04 ARM64 job successfully: both pinned image digests were pulled; `legacy-modules.test`, `apisix-mode.test` and `apisix-parser-live.test` were each PASS, and the task scope result was VALIDATED. These results are for `rumiai-os@d228cf3236` and `rumiai-tests@5dda91b275`. macOS remained queued at the last check; no macOS PASS is claimed.
- Both tagged APISIX sources `3.16.0` and `3.19.0` at `apisix/admin/init.lua` register core route, service, upstream, consumer, credentials, SSL, proto, stream routes, global rules, plugin metadata/config, consumer group and secrets handlers, as well as standalone `/apisix/admin/configs` paths. `3.19.0` additionally registers GraphQL cost decorations and a dedicated config validation handler. This is an implementation inventory, **not** proof that all HTTP methods or provider modes support those resources. Complete per-method/version evidence is Work-unit B, still open.
- The APISIX 3.16.0 and 3.19.0 source files `apisix/cli/config.lua` and `apisix/cli/file.lua` confirm shipped defaults and conditional deployment provider mapping. The current mode classifier deliberately rejects unresolved environment-dependent provider values rather than guessing the runtime environment (which may differ under sudo). This conservative behavior is covered by a negative real-parser case.
- Security boundary: the real-parser test runs without network, with a read-only container root and mounted synthetic read-only configuration. No real rsudo SSH/sudo, Admin API, remote credential source or deployed configuration was exercised.

### Current checkpoint and immediate implementation scope

- The previous response introduced `rsudo apisix mode` as configured-on-disk inspection. Its real provider parser and live-runtime identity remain unverified. It shall not authorize writes.
- **Immediate work unit: A**, first retrieve actual existing test outcomes, then strengthen a read-only, observable public operation in the current APISIX library and add a targeted permanent test/manual update. Do not modify any APISIX server configuration.

## Completed

- **Current checkpoint 2026-11-04 / Phase C partial:** introduced `rsudo apisix runtime <absolute-remote-apisix-home>` into the current APISIX library (`rumiai-os@d28a0986`), with matching operational manual (`rumiai-os@69feea0f`). This read-only operation checks a generated `conf/nginx.conf`, APISIX's standard `logs/nginx.pid`, and the visible nginx/OpenResty master `-p/-c` invocation through remote `ps`. It emits explicitly limited process evidence, never a verified source-config identity, health claim or mutation permission. Missing pidfile yields `pidfile-missing` (not `stopped`); malformed/mismatched evidence fails non-zero. Does not print process argv.
- **Canonical specification (`rumiai-dev@bcbdb617`):** extended `specifications/rumiai-os/RSUDO-APISIX.md` for `runtime`, while preserving the already-defined `mode` and `inspect` interfaces and the configured-versus-live boundary.
- **Test (`rumiai-tests@c2f7b9e`):** extended executable `tests/rumiai-os/rsudo/apisix-mode.test` through the real `m` entrypoint with a missing-PID read-only observation (SSH/sudo replaced at boundary). The matched master-process branch has **not** been exercised by a real APISIX instance. No gateway is started by this test.
- **Scoped validation run 41818917877:** Ubuntu 26.04 ARM64 job completed with `legacy-modules.test`, `apisix-mode.test`, `apisix-parser-live.test` all PASS and task scope `VALIDATED` at frozen `rumiai-os@08e659858046c6e89610cddaf758b0c36dd2bb9f` / `rumiai-tests@c2f7b9e47108da1aa9c33e5463a06e9fb735c191`. The frozen product includes the new runtime function. Latest product HEAD adds only unrelated web-analyze changes to that frozen revision; APISIX source/manual unchanged. macOS job queued at last inspection: no macOS result claimed.
- **Consistency gate:** read back current APISIX source/manual, new canonical spec, test, and focused GitHub Actions logs; compared work-unit diff across three repositories. Current `README.md` and `RULES.md` received unrelated concurrent explicit-`devplan` additions, re-read during reconciliation; plain `procedi` is not an invocation of that opt-in mode. No APISIX/Keycloak settings, credentials or running instances were modified.


- **Continuation 2026-11-04:** retrieved exact GitHub Actions job logs: Ubuntu ARM64 validated the previous scoped legacy/mode test run against `d228cf32`; added a new real-APISIX-parser test and fixed-digest Docker provisioning to the focused Actions workflow, then verified the APISIX 3.19.0 test PASSED in run 41816598717.
- **Comparative test checkpoint:** extended real parser execution to APISIX 3.16.0 and 3.19.0 with immutable multiarch digests. Run 41817022586 Ubuntu ARM64 PASS for three tests and scope VALIDATED against `rumiai-os@d228cf32` / `rumiai-tests@5dda91b2`. macOS still queued; this is parser validation, not a real gateway or SSH/sudo validation. No product code or APISIX service state was modified.

- Verified remote HEADs and current relevant rules/specifications, current module source and rsudo dispatcher.
- Compared the historical `m-os@fa3a90d` APISIX source with current rumiai-os: identical functional bodies except loader/logging differences; historical code is reference only.
- Verified three APISIX backend families against current upstream documentation.
- Checked current APISIX/Keycloak module manual topics: absent; documentation and permanent mechanical coverage must be realigned with the product changes.
- Confirmed no separate active APISIX module handoff exists; this task has independently resumable implementation/validation boundaries from the broader AI administrative-tools handoff.
- `rumiai-os@213f673c`: preserved APISIX/Keycloak code as `rsudo-mod-apisixlegacy.lib.sh` and `rsudo-mod-keycloaklegacy.lib.sh`, mechanically adjusted the function prefixes for direct legacy dispatch, and replaced the original module leafs with thin forwarding facades. Added all four operational library manuals, documenting the retained legacy public functions and limitations. No new backend behavior is claimed.
- `rumiai-tests@67905899`: added `tests/rumiai-os/rsudo/legacy-modules.test` for real shell source loading, wrapper forwarding and mandatory manuals; test has NOT been executed in this response.
- Reviewed product diff (`f68c72e..213f673c`): 8 expected files only. Verified current legacy code is exactly the previous implementation with a mechanical function-prefix replacement, with 35/16 functions represented by the new facades and both manual variants. These are source-level consistency checks, not executable validation.
- `rumiai-os@a8a532e`: added `rsudo apisix mode [remote-home [remote-config.yaml]]` as a read-only configured-backend discovery operation, using the remote installation's APISIX LuaJIT YAML parser and distributed defaults. Returned configured backend: traditional-admin, standalone-api, standalone-file-yaml, standalone-file-json, or no-admin-data-plane. Its private internal selection callable is `_rsudo_mod_apisix_backend`. The operation rejects unresolved launcher roots, ambiguous profile selections and unsupported modes, and is intentionally not used to authorize mutations. It does **not** prove live process config identity. Inferred default-home use is guarded by file existence and the reported mode is only on-disk configured mode.
- Added corresponding `res/sys/manual/rsudo-mod-apisix.lib.sh` behavior, prerequisites, limitation and status text in the product work unit. No existing public legacy wrapper was removed.
- `rumiai-tests@ad992490`: added `tests/rumiai-os/rsudo/apisix-mode.test` to verify source syntax, module public loading via a real `m` probe, remote-shell command and stdin transport up to the external LuaJIT boundary, positional path rejection, fail-closed profile ambiguity and explicit configuration selection. The LuaJIT external-boundary fixture does not prove APISIX's real parser or the live gateway. This new test has **not yet been executed**.
- Inspected the completed `rumiai-os-health` run 41806952411: `rumiai-os/rsudo/legacy-modules.test` PASS on macOS and Ubuntu ARM64 for `rumiai-os@213f673c`, but the full workflow failed in unrelated suites/environment preparation. The PASS is revision-specific and does not validate the new mode code.
- Final readback at `rumiai-os@a8a532e` confirms only the APISIX module and its manual were changed by this task since the previous checkpoint, with unrelated concurrent web-analyze commits preserved. The permanent test and handoff changes are separate and concurrent edits are preserved. Source/manual consistency and branch-specific failure review were completed; no sh -n execution, installed APISIX integration test or physical test of this new revision is claimed.
- **Current response / Phase A start:** saved this detailed twelve-phase A-L plan in the active handoff at `rumiai-dev@c96f2149` before making product changes, including stage gates, provider dependencies, legacy migration, Keycloak and the test/security/concurrency matrix.
- **Product `rumiai-os@d228cf32`:** added public `rsudo_mod_apisix_inspect` (dispatch `rsudo apisix inspect`) which composes the configured-only backend resolver, validates the returned backend and emits exactly four machine-usable evidence fields: `configured_mode`, `configuration_evidence=on-disk`, `runtime_identity=unverified`, `mutation_readiness=not-established`. Unexpected backend identity returns status 22. Updated the APISIX library manual in the same forward commit. No Admin API operations, live process introspection or gateway configuration were changed.
- **Tests `rumiai-tests@9507b2cf`:** expanded the real-`m`/external-LuaJIT-boundary test with inspection output and unexpected backend rejection. **Tests `rumiai-tests@7f047fa5`:** added focused `validation/rsudo-apisix.conf` and `rsudo-apisix.yml` GitHub Actions matrix on macOS and Ubuntu ARM64 to run both mode and legacy contract tests. The focused run 41815144458 was **queued** at last observation, not PASS.
- **Canonical spec `rumiai-dev@c03ed6f7`:** added current `specifications/rumiai-os/RSUDO-APISIX.md` and indexed it in `specifications/README.md`. The specification promotes only observed current legacy and read-only mode/inspect behavior, explicitly excluding unfinished runtime verification, safe provider routing, complete mutation and Keycloak modernization.
- **Consistency review:** compared changed paths against original per-repo HEADs, confirmed only the APISIX module/manual, APISIX scoped tests/workflow and APISIX handoff/spec/index were changed by this task. Unrelated concurrent web-analyze and other work remained intact. Read back `rsudo_mod_apisix_inspect`, manual entries, test assertions and Actions interpolation. A separately reconstructed isolated POSIX shell function was syntax-checked and executed on Debian auxiliary host, but this is **not** a test of the exact product checkout or composed `m` execution path. No live APISIX validation performed for the new code.


## Current state

Work units A/B/C remain active. The read-only configured-mode classifier `mode` has real installed-parser tests for APISIX 3.16.0 and 3.19.0 on Ubuntu ARM64; `inspect` states that this is disk-only evidence. The new `runtime` function records a *separate* process/PID observation for one explicitly identified installation, without asserting that the running gateway loaded the selected source configuration. It is not a full live-instance resolver. Traditional/standalone resource GET/list, safe authenticated transport, mutating backend routing and modern Keycloak are not yet implemented.

At frozen product `rumiai-os@08e659858046c6e89610cddaf758b0c36dd2bb9f` and test suite `rumiai-tests@c2f7b9e47108da1aa9c33e5463a06e9fb735c191`, Ubuntu ARM64 returned three focused PASS tests and task-scope VALIDATED in run 41818917877. This only proves scoped shell/parser/boundary behavior. No real APISIX master match, SSH/sudo credentials, profile `-c`, network Admin API or backend mutation was validated. macOS continues queued/unverified.

## Next action

1. Execute a **real APISIX gateway process** test with a known installation and verify the `runtime` master PID/evidence branch (including PID reuse, stale pidfile and wrong-prefix cases), preferably with isolated Docker or a disposable local target. Do not classify mutable `ps` titles alone as authoritative runtime identity. Keep automated external-boundary coverage honest.
2. Correlate a selected running process with its *actual source* config (`-c`, `APISIX_PROFILE`, service manager, container namespace), plus effective provider/version, using APISIX-supported evidence. If correlation cannot be established, maintain `runtime_identity=...unverified` and refuse new backend mutations.
3. Continue Work-unit B with a concrete per-resource/method/version matrix against APISIX 3.16.0 and 3.19.0, starting with route/service/upstream GET and standalone `/apisix/admin/configs` GET. Then Work-unit D secret-safe transport and Work-unit E generic read-only list/get, with tests and current manual/spec updates.
4. Retrieve the still-queued macOS result of run 41818917877 and reconcile any real regression. Do not claim cross-host validation without that result.

## Blockers / open questions

- The current read-only classifier resolves an on-disk installation/configuration and cannot prove which custom `-c` profile or dynamic configuration the active gateway process actually loaded. Active runtime identity and container/nonstandard installations remain unresolved; modifications must not trust this result alone.
- The actual installed APISIX LuaJIT/lyaml module paths and profile/environment behavior require real integration validation before this classifier can become a general supported guarantee.
- Full-document read/modify/write strategy, concurrency and rollback semantics for file-driven and API-driven backends.
- Retaining current Keycloak CLI usability while the new implementation is independently developed and legacy source is kept.
- Concrete supported APISIX version set and authentication representations must be proved rather than guessed.
