# rsudo APISIX and Keycloak module replacement

Status: Active
Updated: 2026-11-04

## Goal

Replace the incomplete existing rsudo APISIX administration module with a safe, complete shell administration API across APISIX deployment modes, while retaining the previous implementation as explicitly named legacy source. Also preserve the existing Keycloak module under a legacy name and reserve the original module name for its new implementation. Keep both responsibilities separate from rsudo SSH/sudo execution.

## Current repository revisions

- rumiai-dev: 1db3ef07fbf306233994cafd3745b62631d6556f (before APISIX B/C evidence checkpoint)
- rumiai-os: c7353b51e0560aa0b187e9397610a280b1709457 (unchanged product implementation in this work unit)
- rumiai-tests: 42c32dfde8b625dc8fbb7a9c6c64d9f51afcb546 (five-test scoped real APISIX HTTP matrix, identity-drift validation)
- m-os: 31693e814f682690adfd48185da822f7f5007f9e (not involved)

Fresh remote HEAD checks remain mandatory before each further RumiAI action.

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

- **2026-11-04 operator scope for new Keycloak:** support Keycloak versions starting at **26.7.3** and subsequent versions with version/capability-specific evidence; future unverified versions are not pre-certified.
- Support every **Keycloak-supported administrative authentication/token-acquisition modality applicable to the selected server, client and realm**, including interactive mechanisms where applicable. Do not force a prohibited grant, assume granted admin roles or bypass server policy. Distinguish administrator authentication from Keycloak's separately configurable end-user authentication.
- Expose **general administration through JSON** and **common specialized administration operations with few CLI operands**. The exact public function and command contracts must be derived/promoted in their own current specification before implementation; the legacy module remains explicitly addressable as `keycloaklegacy`.

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

#### K. Independently modernize Keycloak — executable development plan (2026-11-04)

**Sufficiency:** `Specifiche sufficienti per la pianificazione`. The operator has fixed the minimum supported version (26.7.3), the requirement to support all Keycloak-supported relevant administrative authentication modes, and a general JSON API plus few-operand CLI conveniences. Upstream release-specific behavior is investigated, not invented. This is *planning-only*: no new product/test writes or deployment are authorized by `devplan` itself.

**Baseline revisions at planning:** `rumiai-dev@e200aba49ace8d80454e5a691ed03aca193bf473`, `rumiai-os@c7353b51e0560aa0b187e9397610a280b1709457`, `rumiai-tests@cf6ef10bc5d43f15988f23ba621515363a5bacb7`, `pkg-catalog@7892040e906723ef6641df88a03964c041cee9bc`. Reverify live heads before every unit; these are checkpoints only.

**Current source inputs:** root `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `DEVPLAN.md`, `TESTING.md`, `specifications/README.md`, `specifications/rumiai-os/{RSUDO,CURRENT-MODEL,FILESYSTEM-NAMING,LIBRARY-INTERFACES,DOCUMENTATION-MODEL,DIAGNOSTICS}.md`; current implementation `rumiai-os/lib/sys/sh/rsudo/rsudo-mod-keycloak{,legacy}.lib.sh`, related `rsudo.lib.sh` and `res/sys/manual/rsudo-mod-keycloak{,legacy}.lib.sh`; `rumiai-tests/tests/rumiai-os/rsudo/legacy-modules.test`; current `pkg-catalog/v1/pkg/keycloak/all/`. Upstream Keycloak 26.7.3 Admin REST API reference: `https://www.keycloak.org/docs-api/26.7.3/rest-api/index.html`; current OIDC/token-discovery documentation: `https://www.keycloak.org/securing-apps/oidc-layers`; version changes from official release/migration references. These upstream sources are technical evidence, not replacements for RumiAI contract promotion.

**Operator acceptance scenarios:** (1) With existing rsudo credentials and an explicitly selected or unambiguously discovered Keycloak endpoint, list realms and inspect a realm through the JSON API without guessing an endpoint or running a remote `m` installation. (2) An authorized principal can create/inspect/update/delete a realm, client, user or group using general JSON, preserving arbitrary valid JSON content and appropriate server-defined paths. (3) Common client/user/group/role actions require a few meaningful CLI operands and no hand-authored JSON file; complex options still have a JSON path. (4) Authorized administrators can use every selected server-supported acquisition method, including interactive hand-off where required, without exposing tokens/passwords in argv, trace, stdout or logs; expired/unauthorized/forbidden sessions fail correctly. (5) The old `keycloaklegacy` identity remains explicit, and current public forwarding functions are not silently reinterpreted or left documented incorrectly.

**Coarse DAG (no assumed schedule):**

```text
K01: version/resource matrix ─────┐
                                 ├─> K03: public contract → K04: auth/transport → K05: JSON administration → K06: simplified CLI
K02: auth/endpoint matrix ────────┘                                           │                            │
                                                                               └─────────────┬──────────────┘
APISIX integration contract/readiness ────────────────────────────────────────────────────────> K07: optional APISIX-Keycloak recipes
K04 + K05 + K06 (+ K07 when in scope) ────────────────────────────────────────────────────────> K08: composed acceptance / closure
```

**K01 — supported-version and Admin API capability matrix (READY for source investigation).** Owner: Keycloak API inventory; target `rumiai-dev` handoff working-design checkpoint, with pinned upstream evidence and no product changes. Input: upstream 26.7.3 REST API, representative later released version(s) (26.8.1 available at planning time), migration notes, current catalog definition and legacy function inventory. Deliverable: resource × method × version × JSON/body/response shape inventory, including global and per-realm endpoints, querying/pagination, realm/client/user/group/role/authorization, special endpoints, generated IDs, non-JSON/binary exceptions, idempotence and known missing/preview behavior. Acceptance: every promised general capability is linked to the upstream method/path evidence; unsupported/unknown are explicitly distinguished. Validation: document/source inspection only until a real isolated server probe is run; never label source inventory as live execution. Manuals/tests: enumerate expected later coverage, do not rewrite them during research. Escalate only on a real conflict over the requested public scope, not local method mapping. Next: build the matrix and record the exact source versions.

**K02 — administrative endpoint, authentication and trust matrix (READY for independent investigation).** Owner: authentication/security research, separate working-design section in this handoff; no product change. Input: current `RSUDO.md`, `DIAGNOSTICS.md`, Keycloak discovery, grant/client-auth documentation and deployment/profile/URL evidence. Deliverable: server-supported grant × client-authentication × interactive/non-interactive × refresh/revocation × administrator-permission matrix, distinguishing externally supplied bearer tokens, service accounts, interactive authorization/device flows, conditional grants and deprecated/disabled flows. Include identity of admin server/realm/endpoint versus SSH host, explicit overrides and fail-closed ambiguity; TLS trust, remote-vs-local token handling, redaction, no sensitive argv/eval, expiration, HTTP error and retry boundaries. Do not treat every end-user login-factor or Keycloak-configurable authenticator as a separate CLI token grant, and do not require server-disabled/insecure grants to succeed. Acceptance: each offered auth path has an actual supported protocol, prerequisite/configuration, error contract and legitimate authority boundary; no silently selected insecure fallback. Validation: upstream/docs plus isolated proof where useful; not live auth evidence until executed. Manuals/tests: define the scenarios later needing real server verification. Escalate only if authenticated administration would require a new high-impact trust/deployment architecture. K01 and K02 can investigate in parallel, but a single handoff owner serializes edits to this file.

**K03 — settle and promote Keycloak public interface (NEAR READY; after K01/K02).** Owner: one Keycloak contract integrator. Targets: `rumiai-dev/specifications/rumiai-os/` and `specifications/README.md` (use the existing index; do not create a competing contract), with corresponding planning checkpoint here. Deliverable: promoted specification for the general JSON method/path/query/body/response interface and short-operand specialized commands; explicit endpoint discovery/selection, auth configuration, output and exit/status rules, data-validation/escaping, no JSON-file prerequisite, HTTP 204/binary response boundaries, authentication/authorization failure cases, capability/version reporting and legacy compatibility/migration. Reuse existing `rsudo keycloak` dispatcher and check existing public `rsudo_mod_keycloak_*` names before inventing identities. Acceptance: a clean chat can implement any documented operation without choosing a foundational public contract; an operator can achieve the normal acceptance scenarios without knowledge of private code; all former public functions and the `keycloaklegacy` command have an explicit non-silent migration disposition. Validation: spec-to-upstream method matrix review plus caller-path simulation; no runtime PASS claimed. No executable implementation until the promoted contract is coherent. Escalate any conflict with a fixed public interface or a materially new security boundary.

**K04 — secure authentication and remote transport (AFTER K03; implementation authorization required).** Owner: `rumiai-os` new Keycloak library + same-work-unit operational manual, plus dedicated `rumiai-tests` permanent tests. Real `m`/`rsudo` entrypoint and documented external SSH/HTTP boundary must be exercised; use live isolated Keycloak for grant/expiry/permissions where feasible, while fixtures prove only substituted boundaries. No logs, process args, untrusted shell interpolation, implicit legacy path or insecure TLS default may expose or weaken credentials. Acceptance: all inventoried and server-enabled admin grant/client-auth paths act according to the promoted contract; fail closed on insufficient permissions, expired credentials, redirects/malformed payload, unsupported version and endpoint ambiguity. Owner may choose private functions, not change public contracts. Escalation: transport requires changing `RSUDO.md` or additional trust boundary.

**K05 — full general JSON Admin REST API (AFTER K04; implementation authorization required).** Owner: one library/public-API integrator and coupled manual/permanent tests. Implement verb/path/query, JSON payload and response semantics over the trusted transport, with version/resource/method coverage from K01; avoid restricted ad-hoc endpoint assumptions and accidental arbitrary URL reachability. Include status and structured, redacted diagnostic identity; preserve paging, Unicode, unknown fields and empty/no-body response distinctions. Acceptance: real isolated Keycloak 26.7.3 plus a representative subsequent version exercise supported CRUD and representative admin/authorization endpoints; 400/401/403/404/409/5xx, timeouts and malformed inputs have truthful distinct results. Non-JSON endpoint exceptions must be explicit, not silently treated as JSON. The manual and permanent tests belong to the same unit, not cleanup. Escalate incompatible server/API behavior to K03 rather than redefining it silently.

**K06 — short-operand specialized administrator commands (AFTER K05; implementation authorization required).** Owner: one distinct set of CLI/public-function surfaces + corresponding manual/tests; use K05 rather than another transport. Prioritize ordinary realm/client/user/group/role and authorization actions; extend from the K01 matrix where operator value and stable semantics justify them. Inputs are domain-level identifiers and a few required values, with safe programmatic JSON construction and explicit complex-JSON escape hatch; no mandatory authored JSON file. Acceptance: ordinary create/list/show/update/delete and representative role/permission workflows through real public `m`/rsudo path, real server permissions, and failures involving whitespace, Unicode, absent/ambiguous identities and conflicts. Change existing forwarding functions only through an explicit K03 migration disposition, including corresponding permanent-test updates. Escalate material caller-visible semantic breakage.

**K07 — APISIX/Keycloak composition (AFTER K05 and APISIX readiness; separately gated).** Owner: cross-module integration; no change to basic APISIX discovery or Keycloak auth ownership. Deliverables: documented and tested OIDC/authz recipes consuming stable interfaces of both modules, rather than hidden coupling. Exercise an actual isolated APISIX/Keycloak flow before claiming end-to-end success. APISIX branch/process/config mode readiness and authn/authz route contract must be settled first; absence of this integration evidence does not invalidate standalone Keycloak CRUD evidence. Escalate any shared interface change to the respective module owner before integrating.

**K08 — acceptance, migration and closure (AFTER predecessor units).** Each preceding unit owns its tests, manuals, diagnostics and consistency gate; K08 only composes and audits outcomes against the K01/K02 matrices and acceptance scenarios. Test authentic live Keycloak 26.7.3 and at least one later release, multi-host cases only when real evidence adds value; record exact product/test revisions, target host/container version and what was actually exercised. Do not label test doubles, source inventory or a single-release PASS as all-version certification. Resolve remaining legacy forwarding, canonical specification/manual consistency, cross-module scope and validation gaps before completing the task handoff via its forward-only lifecycle.

**Orchestration boundaries:** K01 and K02 are functionally independent research units; run concurrently only when their produced artifacts/edits are separately owned and the single handoff writer merges them forward. K03 stabilizes public API/trust before any implementation. K04 is the only transport/auth owner; K05 the only general JSON dispatch owner; K06 owns convenience commands; K07 owns recipes with explicit APISIX interface coordination. No two agents concurrently replace the Keycloak library or its manual. An executor must refresh remote HEADs, read canonical sources and the handoff, verify prerequisites/authorization, implement only its assigned unit, run authentic proportional tests, reread diff, reconcile other writes forward and persist evidence/next action. Failed acceptance, source conflicts or changed high-impact boundaries stop the affected unit.

**Clean-chat check at planning:** another chat can start K01/K02 immediately from the named sources and bounded documentation deliverables; K03 requires both inventories, and code units K04–K07 require the promoted contract, applicable authorization and prior outputs. No unit is implicitly authorized to implement. The plan is not proof of future execution or of Keycloak runtime correctness.

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

### Keycloak `devplan` sufficiency gate update (2026-11-04)

The initial assessment was blocked by unselected supported versions, authentication and public API styles. The operator explicitly closed those scope choices: Keycloak >= 26.7.3, all supported relevant administrative authentication modes, general JSON administration and short-operand specialized CLI functions. Positive planning gate: `Specifiche sufficienti per la pianificazione`. Section K above now owns the readiness-gated executable plan. This promotes no provisional upstream methods, function spellings or unverified runtime claims to current specification. K01/K02 are the next independently researchable units; code requires the normal separate execution authorization.

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

- **2026-11-04, APISIX work units B/C — live read-only HTTP behavior and disk/runtime mismatch:** added executable `rumiai-tests/tests/rumiai-os/rsudo/apisix-admin-read-live.test` and its selection/trigger to the existing focused `rsudo-apisix` validation, preserving actual `m` product mode resolution. The fixture launches Apache APISIX **3.16.0 and 3.19.0** using the two already-pinned Debian images, in isolated standalone API-driven mode (`traditional` role, YAML provider) with network disabled, no host-exposed ports, and synthetically scoped test-only viewer/admin credentials. It queries real HTTP via Bash `/dev/tcp` inside the container; this is **not** the secure rsudo/curl management transport.
- **Live endpoint matrix (tested, not yet a product API):** in both releases, `GET /apisix/admin/configs` is HTTP 200 with valid viewer key and returns a versioned JSON snapshot containing `routes_conf_version` and `services_conf_version`. `GET /apisix/admin/routes`, `/services`, `/upstreams` return HTTP 404 under standalone API-driven routing; they are **not** traditional resource endpoints in this mode. Invalid admin key is denied (401/403). `HEAD /apisix/admin/configs` with viewer key is HTTP 401, whereas admin role returns HTTP 200; upstream `apisix/admin/init.lua` for 3.16.0 and 3.19.0 grants viewer **GET only**. Do not equate an HTTP route's registered methods with every credential's permissions.
- **Empirical active-config provenance limit:** after standalone API-driven gateway startup, the test **edits only the mounted synthetic `config.yaml`** to `data_plane/yaml` without reloading. Product `rsudo_mod_apisix_mode` through real `m` now classifies the changed disk file as `standalone-file-yaml`, while the same running gateway still authenticates `GET /apisix/admin/configs` as standalone API-driven (200). This demonstrates a concrete configuration/runtime divergence; on-disk mode and PID/master title must not authorize routing or mutations.
- **Scoped Actions:** initial B/C test revision `rumiai-tests@6a4b8596` had five PASS tests and scope VALIDATED on Ubuntu ARM64 in run **41824147187** against `rumiai-os@c7353b51e0560aa0b187e9397610a280b1709457`. Extension `rumiai-tests@eec4fce2` correctly found HEAD with viewer key returns 401, but its test assumed 200 and scope was NOT VALIDATED in run **41824513868**. Corrected test `rumiai-tests@42c32dfd` separates viewer HEAD=401 and admin HEAD=200, checks resource 404 and snapshot-version fields; **run 41824947531**, frozen product `rumiai-os@c7353b51e0560aa0b187e9397610a280b1709457`, has **five PASS** and scope **VALIDATED** on Ubuntu ARM64. macOS job was still queued at checkpoint, so no macOS PASS is claimed.
- **Upstream source provenance boundary:** `apisix/core/profile.lua` and `apisix/cli/ops.lua` for 3.19.0 show `-c` source-path selection is used during CLI initialization and its temporary index `conf/.customized_config_path` is cleared by cleanup. Neither inspecting master Nginx args nor reading current source YAML proves loaded runtime identity. New mutating operations remain disabled; no deployed APISIX/Keycloak service or secret was touched.


- **2026-11-04, APISIX real-process validation checkpoint:** verified upstream Apache APISIX Docker entrypoint starts OpenResty using `-p <home> -g 'daemon off;'`, unlike the CLI `-p <home> -c <home>/conf/nginx.conf` path. Modern current `rsudo-mod-apisix.lib.sh` was aligned forward to recognize both verified startup forms while retaining `runtime_identity=process-consistent-config-unverified` and `mutation_readiness=not-established` (`rumiai-os@0b3b45b6`). No privileges, routing, HTTP APIs or deployed services were changed.
- **Container-specific failures found and fixed:** first integration run 41820176631 failed before execution because the newly added `apisix-runtime-live.test` had Git tree mode `100644`, corrected to `100755` in `rumiai-tests@9440718f`. Next live run 41820471877 failed because the official Docker entrypoint preserved an existing traditional/etcd `config.yaml` even with `APISIX_STAND_ALONE=true`; the test was corrected to mount its own standalone YAML config in the disposable container (not on deployed hosts) at `rumiai-tests@91155723`. Run 41820921134 then exposed that official APISIX Docker master can be namespace PID 1 and Debian image lacks `ps`. `rumiai-os@8cd6233b` permits PID 1 and uses a guarded Linux `/proc/<pid>/cmdline` fallback when POSIX `ps` is absent; `rumiai-os@a7d5b60c` distinguishes stale PID from absent inspector. Branch-specific failure statuses 40-43 were allocated for procfs failures without changing existing 30-39.
- **Permanent real-gateway integration:** `rumiai-tests/tests/rumiai-os/rsudo/apisix-runtime-live.test` launches both immutable APISIX 3.16.0 and 3.19.0 official Debian images as genuinely running isolated standalone gateways with no network or host ports. It invokes the actual product module via real `m` and an external-boundary `docker exec` replacement for `rsudo`; verifies positive PID/master evidence, rejects an alternate fake installation root while the genuine master runs, and rejects an expired PID. It does **not** prove SSH/sudo transport, loaded source config identity, active provider selection on company infrastructure or API key security.
- **Real scoped validation:** GitHub Actions `rsudo-apisix` run **41821503037**, Ubuntu 26.04 ARM64, froze `rumiai-os@a7d5b60cebc114954cbaae671552a5d4c8857d50` and `rumiai-tests@3b385bf2c4f0f6cecc0bec9a7b65ac40926f0993`. All four scoped tests PASS: `legacy-modules.test`, `apisix-mode.test`, `apisix-parser-live.test`, `apisix-runtime-live.test`; task scope `VALIDATED`. Both target APISIX release images were exercised with live master PID. macOS job was still queued at the checkpoint: no cross-host PASS. Current `rumiai-os@c7353b51e0560aa0b187e9397610a280b1709457` changes only the APISIX manual since the frozen product revision; current suite `cf6ef10bc5d43f15988f23ba621515363a5bacb7` includes subsequent unrelated concurrent changes.
- **Documentation consistency:** current APISIX manual and `rumiai-dev/specifications/rumiai-os/RSUDO-APISIX.md` now cover official Docker foreground startup, PID 1 in a container and guarded Linux procfs fallback. The contract still reports only process-consistent evidence, never verified live source configuration, authorization to mutate, or gateway health.
- **Work-unit B source reconnaissance (not tested HTTP behavior):** upstream APISIX tags `3.16.0` and `3.19.0`, `apisix/admin/init.lua`, register traditional/etcd `/apisix/admin/*` routing for GET/PUT/POST/DELETE/PATCH, and standalone API-driven `/apisix/admin/configs` GET/PUT/HEAD plus `/apisix/admin/configs/validate` POST. Resource-specific handlers, authorization, response semantics and per-method support still require verification; file-driven standalone has no equivalent local Admin API. Do not infer safe generic CRUD from route registration.
- **Hosted macOS limitation:** earlier focused run 41816598717 completed `legacy-modules.test` PASS on macOS but failed at `rumiai-validate` evidence push, before the remaining tests; this is a publication failure, not a demonstrated APISIX regression. The current run's macOS matrix result is still pending.


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

Work units A/B/C are still active. The current module's read-only `mode` and `inspect` distinguish selected-on-disk configuration from the gateway process. `runtime` now observes both APISIX CLI master and official Docker foreground master, including valid container PID 1, with POSIX `ps` and guarded minimal Linux `/proc` fallback. This is **process consistency evidence only**; there is no verified correlation to the active source `config.yaml`, `-c`, `APISIX_PROFILE` or running container namespace ownership. Mutation readiness is always `not-established`; all 35/16 legacy APISIX/Keycloak functions remain available through existing forwarding.

The current five-test APISIX scope PASSed on Ubuntu ARM64 in Actions run **41824947531**, frozen `rumiai-os@c7353b51e0560aa0b187e9397610a280b1709457` and `rumiai-tests@42c32dfd`. Besides real 3.16.0/3.19.0 process and installed-parser tests, it proves standalone API-driven GET/HEAD auth behavior and a real divergence between changed on-disk config and effective running HTTP API. The **provider API was tested**, but no new rsudo secure credential transport or resource-read API is yet implemented; no real SSH/sudo or company APISIX installation was exercised. The actual source config loaded by a running gateway remains unverified. macOS remains queued and unrelated/concurrent changes are preserved.

## Next action

- Keycloak planning branch: K01 version/API matrix and K02 authentication/endpoint matrix may start independently as source-only research; do not conflate them with the APISIX next-action sequence. See work unit K for dependencies and evidence boundaries.

1. Inspect the still-queued macOS result for run 41821503037; classify failures by cause, including known possible validation-evidence publication errors, rather than interpreting a hosted job failure as a product failure.
2. Continue Work-unit C: correlate the selected running APISIX gateway with the **actual source configuration** (`-c`, `APISIX_PROFILE`, deployment manager/container namespace and effective provider) with authoritative APISIX/service evidence. Keep all new mutating paths disabled until provenance is proven; process title/PID alone are insufficient.
3. Continue Work-unit B with real traditional/etcd **per-resource GET/list** capability, authorization and version response envelopes, then file-driven standalone local document read; the two-release standalone API-driven `GET /configs` and viewer/admin HEAD distinction are now verified. Do not infer generic CRUD from router registrations.
4. Work-unit D: design/validate secret-safe authenticated Admin API access over real `rsudo`, then implement Work-unit E read-only resource list/get through the internal mode router; support common low-operand workflows without mandatory authored JSON files only after backend and security gates pass.

## Blockers / open questions

- The current read-only classifier resolves an on-disk installation/configuration and cannot prove which custom `-c` profile or dynamic configuration the active gateway process actually loaded. Active runtime identity and container/nonstandard installations remain unresolved; modifications must not trust this result alone.
- The APISIX LuaJIT/lyaml mode classifier has executed successfully in real official 3.16/3.19 Debian images, but other packages, runtime environment variable substitution, explicit `-c`/profiles and effective process identity remain unverified.
- Full-document read/modify/write strategy, concurrency and rollback semantics for file-driven and API-driven backends.
- Retaining current Keycloak CLI usability while the new implementation is independently developed and legacy source is kept.
- Concrete supported APISIX version set and authentication representations must be proved rather than guessed.
