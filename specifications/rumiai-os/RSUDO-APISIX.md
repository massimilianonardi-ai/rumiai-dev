# rsudo APISIX Administration — Current Implemented Contract

Status: **Current / partial implementation**
Updated: 2026-11-05

## Scope and ownership

The `rsudo` APISIX module is an `m` shell library at `lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh`, loaded through the normal `rsudo` submodule dispatcher. SSH/sudo authentication, execution and stream semantics remain governed by `RSUDO.md`. This specification describes **only current implemented, operator-observable APISIX behavior**; it does not treat the active development plan as already delivered.

The library's operational function signatures and current limitations are maintained in `rumiai-os/res/sys/manual/rsudo-mod-apisix.lib.sh`. The active implementation plan, pending design and version validation are kept in `rumiai-dev/handoff/rsudo-apisix-administration.md`, which is not normative.

## Legacy separation

The previous APISIX implementation is retained under `rsudo-mod-apisixlegacy.lib.sh` and the `rsudo apisixlegacy` dispatcher identity. Its public functions carry the prefix `rsudo_mod_apisixlegacy_`. The current APISIX module still forwards its pre-existing public operations to that retained implementation unless explicitly replaced.

Similarly, the previous Keycloak module is retained under `rsudo-mod-keycloaklegacy.lib.sh`. The current `rsudo-mod-keycloak.lib.sh` retains forwarding for its sixteen compatibility functions and separately implements a partial modern `auth` interface. Its scope and remaining work are owned by `RSUDO-KEYCLOAK.md`, not by this APISIX contract.

The legacy interfaces retain their own documented limitations and must not be mistaken for the new safe, multi-backend administration implementation. No default or implicit fallback from an unsupported new backend operation to the unsafe legacy path is permitted.

## Operator-selected context and independent discovery boundary

The operator is responsible for selecting the APISIX instance and the deployment mode
used for administration. Read-only `discovery` is an independent inventory
operation: it does **not** initialize or modify environment variables, does
not choose a candidate, and does not require uniqueness. Explicit target
context, rather than a universal automatic runtime-source certification
procedure, is the planned basis for backend routing. Each actual mutation
must still satisfy operation-specific safety and integrity preconditions;
operator selection is not authorization to corrupt a file or overwrite a
concurrently owned snapshot. A complete context parser and the
provider-independent administration router are **not yet implemented**.

The current first-stage public command

```sh
rsudo apisix discovery [absolute-remote-scan-root]
```

and library function `rsudo_mod_apisix_discovery` perform a **best-effort,
read-only host inventory** over the selected rsudo remote target. The
optional absolute scan root defaults to `/`; nonabsolute or unavailable
roots are rejected. The implementation uses host `find` to report
candidate `conf/config.yaml`, `conf/config-*.yaml`, `conf/apisix.yaml`
and `conf/apisix.json` files when additional APISIX installation evidence
is present, or when the installation directory carries a conventional
APISIX leaf name. Host `ps` is optional and can contribute an independent
candidate PID or a weak pathname/process-prefix correlation. Such evidence
is labelled `configured-only`, `process-candidate`, or
`process-prefix-candidate`, never silently promoted to verified runtime
identity. Scanning `/` excludes virtual system directories and common
container storage, and inaccessible subtrees may be omitted. The operation
never reads or returns the contents of configuration files or credentials.

When the remote host has Docker or Podman, discovery also lists containers
in every manager state. For stopped containers it examines only mount source
and destination metadata to find APISIX configuration mount candidates. Running
containers are probed through the manager
with a fixed read-only `sh` program that searches for the same configuration
filenames; returned config paths are qualified by the full container ID.
Stopped containers whose image or name contains `apisix`, or whose inspected
mount points expose an APISIX configuration path, remain visible as candidates,
but their filesystems cannot be searched. Only mount source/destination metadata
is inspected; container environment values are never requested. A running container
with a failed probe is surfaced as uncertain when manager metadata suggests
APISIX, and a manager-level partial/unavailable row records incomplete
coverage. A stopped container whose metadata does not suggest APISIX can be
missed; correlation of mount sources to host-discovered files is not
implemented. Running-container YAML and JSON files receive targeted
connect-only netcat probes inside that container's network namespace, with
the manager and full container ID in the row. JSON files are validated and
queried with the standalone RumiAI `json` command for
`deployment.admin.admin_listen.ip` and `.port`; no `jq` or Python dependency is
required. If `json` is missing on the remote host/container or validation/query
fails, discovery emits an uncertainty row. JSON snapshots without deployment
admin listener settings yield no endpoint. These records are candidates only,
not runtime identity.

On hosts with `systemctl`, the inventory includes APISIX-matching loaded unit
names/descriptions and installed unit-file names with their reported state.
Descriptions are used only to match and are not returned. For active loaded
units, the reported MainPID is compared with APISIX nginx-master process
evidence from `ps`; readable procfs cgroup membership is an additional
correlation when it matches the unit ControlGroup. This does not prove which
APISIX source configuration the process loaded. For host
YAML candidates, discovery extracts numeric `port`/`ip` values only beneath
`admin_listen`. It uses `nc` for a TCP connect-only probe when the bind is
loopback, wildcard, or an address verified local by `ip`; remote or
unverified addresses are reported as unprobed. JSON candidates are validated
and queried with RumiAI's standalone `json` command; a missing command, invalid
JSON or unsupported query is reported as uncertainty. `open`/`not-open`
reports socket reachability only and does not identify APISIX or an Admin API.

For this first increment, successful stdout contains a tab-separated header
`kind scope state identifier evidence` followed by zero or more candidate
rows with exactly those five columns. An empty inventory is successful if the
scan runs and no candidate is found. A host may yield multiple rows for the
same installation when different profiles or data files are found; this is
intentional, not an ambiguity error. A process candidate alone is not proof
of a running, selected APISIX gateway. The local `discovery` status codes are 1 (invalid argument count) and
2 (nonabsolute root); the remote scanner uses 1 (invalid root),
2 (unavailable root) and 3 (find unavailable). The caller preserves
remote rsudo status as an explicit transport result. Partial coverage is not proof that other instances do not exist.

The first-stage `rsudo apisix context` / `rsudo_mod_apisix_context`
command parses caller-owned environment without remote discovery, changing
environment variables or issuing network requests. It requires
`RSUDO_APISIX_SCOPE=host|docker|podman` and
`RSUDO_APISIX_DEPLOYMENT` set to one of the five current mode identifiers.
`RSUDO_APISIX_HOME` is an optional absolute installation root.
Docker/Podman scopes require a full lowercase 64-hex
`RSUDO_APISIX_CONTAINER_ID`; a container ID is forbidden in host scope.
File-driven modes require an absolute `RSUDO_APISIX_DATA_FILE`;
traditional-admin and standalone-api require an `http(s)`
`RSUDO_APISIX_ADMIN_URL` and absolute `RSUDO_APISIX_HEADER_FILE`.
The last two values are operator declarations, not independently verified
endpoints or credentials. The read-only result includes
`selection=operator-supplied-unverified`, `scope`, `deployment`,
`adapter` and relevant nonsecret selectors; the credential file
is represented only as configured/not-configured. Supported internal
adapter identifiers are `rest`, `snapshot`, `file-yaml`,
`file-json` and `none`. Generic `list/get` currently route only the explicit
host traditional-admin context to REST; other adapter operations fail
explicitly. Invalid inputs use
distinct new-context status values 1–11 as described in the operational manual.
The context is a **local declaration**: it does not establish a running
process, an authorized listener, actual backend support or write readiness.

**Not yet implemented:** stronger service-to-process ownership evidence,
complete container source/mount attribution,
JSON discovery output, standalone
reads/writes and modern write operations. Initial host YAML port probes and
textual systemd unit candidates are implemented. Initial host and
Docker/Podman candidate inventory and traditional REST `list/get` support are
described above/below. This staged implementation does
not alter the older `mode`, `inspect`, `runtime`,
`admin-read` or explicit legacy operations. In particular, the old
no-argument runtime resolver may reject multiple candidates; the independent
new `discovery` is intentionally allowed to report all of them.

## Read-only APISIX configured-mode interface

The public command

```sh
rsudo apisix mode [remote-apisix-home [remote-config.yaml]]
```

and direct function `rsudo_mod_apisix_mode` inspect one selected on-disk APISIX configuration using the installed APISIX LuaJIT/YAML parser and distributed defaults. Both optional selection paths must be absolute. Automatic discovery is best effort and fails for unresolved/ambiguous installations or profiles instead of silently claiming one.

On success, stdout contains exactly one configured backend identifier:

```text
traditional-admin
standalone-api
standalone-file-yaml
standalone-file-json
no-admin-data-plane
```

Only one of these values is printed. Unknown roles/providers, invalid selections or missing dependencies yield non-zero status with a distinguishable diagnostic; no mode is guessed on failure. A successful result is evidence of the **selected on-disk configuration**, not of the actual running process.

## Read-only APISIX inspection interface

The public command

```sh
rsudo apisix inspect [remote-apisix-home [remote-config.yaml]]
```

and direct function `rsudo_mod_apisix_inspect` reuse the configured-mode resolver. On success, stdout contains four newline-separated key/value records, in this order:

```text
configured_mode=<one of the configured backend identifiers>
configuration_evidence=on-disk
runtime_identity=unverified
mutation_readiness=not-established
```

If mode discovery fails, inspection fails without a successful inspection payload. An unexpected backend identifier is rejected. The inspection operation does not modify APISIX state, does not grant privileged API access and cannot be treated as a live health check or proof of configuration convergence.

## Read-only APISIX runtime process evidence

The public command

```sh
rsudo apisix runtime [absolute-remote-apisix-home [full-docker-container-id]]
```

and direct function `rsudo_mod_apisix_runtime` observe a remotely selected installation. With no operands, the resolver checks the conventional `/usr/local/apisix/conf/nginx.conf` on the selected remote host and all accessible running Docker containers for an observed, ordinary readable non-symlink generated-configuration candidate. Exactly one candidate may be selected; the selected process is then rechecked with the same existing pidfile/master argument observer. A generated configuration without an observable master is **not** a successful automatic runtime discovery, although explicit runtime inspection may truthfully report `pidfile-missing` without inferring a stopped server. Automatic discovery is **best effort**: the conventional installation root is checked on the remote host and inside running Docker containers; a Linux host-namespace master observed via readable procfs (same PID and mount namespaces as the remote shell) may select a safe nonconventional absolute `-p` root, and a Linux Docker master observed through readable procfs, whether namespace PID 1 or a background process, may additionally provide its own selected nonconventional `-p` prefix when an ordinary generated `conf/nginx.conf` is readable under that absolute root. Neither process title nor path discovery proves source-configuration content. Other nonstandard host installations, service-manager instances, unobservable or inaccessible processes and external namespaces are not certified absent. Host-namespace process observation requires readable procfs plus `tr` and `readlink`; otherwise conventional host discovery remains available. Multiple observed host masters fail closed (status 64); invalid/unresolved host process prefixes (61), missing generated configuration (62), unsafe generated configuration (63), failed process scans (65) and unavailable observer namespace evidence (66) have distinct nonzero statuses. Invalid host selection on recheck fails status 67. Host process-prefix discovery remains process evidence only, not a verified service unit or loaded source. Procfs scanning is best effort and is not a complete process census; more than one observed master in one container fails closed (status 59), as does a failed procfs command-line read during scanning (status 60). A present but inaccessible Docker manager prevents a uniqueness claim; invalid Docker ID records, no observed candidate or multiple candidates fail non-zero rather than selecting an arbitrary instance. Every running Docker candidate probe distinguishes an ordinary missing generated configuration from an unsafe/unreadable configuration or an execution failure (such as no shell or a disappearing container). Only a definite missing configuration is safely skipped; unsafe/unreadable Docker sources (status 53), unsafe host sources (status 55), and indeterminate container probes (status 52) fail closed. A unique selected candidate without an observed master fails status 51, and unexpected master-observation output fails status 54, without a successful discovery payload. A system without Docker may still confirm a single conventional host candidate. The successful no-operand response prefixes the existing runtime evidence with `discovery_evidence=unique-conventional-candidate` and `discovered_scope=host` or `discovered_scope=docker`; for the Docker case, `container_id=<full-64-hex-id>` is also emitted. When an observed master in the selected host or Docker process namespace advertises a safe nonconventional absolute `-p` prefix and the selected generated config/pidfile/master arguments agree, the output instead uses `discovery_evidence=unique-process-prefix-candidate`, `discovered_scope=host` or `discovered_scope=docker`, with `container_id=<full-64-hex-id>` for Docker only and `installation_root=<absolute-prefix>` for either scope, before the unchanged process-consistent, configuration-unverified evidence. Unsafe process-root input fails with a specific nonzero status (56 for probe-time unsafe prefix; 57 for invalid selection) without executing it as shell source; an observed master whose advertised prefix has no generated `nginx.conf` fails with status 58 instead of being excluded as an absent container candidate. Explicit selection remains available for installation roots outside this restricted automatic observation. The caller may instead supply an absolute installation root to observe only the remote SSH/sudo host namespace. An optional *explicit* full lowercase 64-character hexadecimal Docker container ID scopes the unchanged read-only program to the selected running container via the existing remote rsudo SSH/sudo transport and `docker exec -i <id> sh -s`; this requires remote Docker access and a working shell in that container. Shortened IDs, names, invalid characters and Docker option operands are rejected before remote execution (status 44). The operation checks the generated `conf/nginx.conf` and `logs/nginx.pid` inside the selected namespace, then reads the PID's visible process arguments using POSIX `ps`, with a guarded Linux `/proc/<pid>/cmdline` fallback when minimal containers lack `ps`. A master may legitimately have namespace PID 1. `/proc` is a Linux capability, not a universal POSIX dependency. It recognizes the APISIX CLI's `-p <home> -c <home>/conf/nginx.conf` startup and the official Docker foreground startup using `-p <home> -g 'daemon off;'` (for the generated default `conf/nginx.conf`). Process-title quoting can differ; neither form proves the gateway's source configuration.

If the PID file is missing, successful stdout is exactly:

```text
runtime_evidence=pidfile-missing
runtime_identity=unverified
mutation_readiness=not-established
```

This does **not** prove that the server is stopped. When a readable, ordinary PID file refers to an observable nginx/OpenResty master whose visible startup arguments match either the verified CLI `-p`/`-c` pair or the Docker foreground `-p`/`-g` form for the expected generated nginx configuration, stdout is:

```text
runtime_evidence=pidfile-and-master-args
process_pid=<decimal-pid>
runtime_identity=process-consistent-config-unverified
mutation_readiness=not-established
```

On Linux, host-scoped successful master inspection may insert two additional fields between `process_pid` and `runtime_identity` when an independent systemd service-manager correlation is verified:

```text
service_manager_evidence=systemd-mainpid-and-cgroup
service_unit=<validated-service-unit>
```

The correlation uses the observed master's kernel cgroup v2 membership to obtain a service unit name, then requires `systemctl show` to independently report the same `Id`, the same `MainPID`, an `ActiveState=active` unit and a matching `ControlGroup` for that process. Absent, unreadable or inconsistent cgroup/manager evidence omits these optional fields and leaves the previous process-only result intact; the operation does not infer a service unit. The selected Docker namespace never queries an optional or potentially host-mounted systemd manager. A verified unit association is service-manager evidence only: it does not prove an effective APISIX `config.yaml`, a custom profile, the actual Admin listener or readiness for writes.

On Linux, a separate optional observation may add `listener_socket_evidence=master-fd-loopback-tcp` and `listener_socket=127.0.0.1:9180` after any optional service fields and before `runtime_identity`, for either the selected host or Docker namespace. The observer uses the selected master's own `/proc/<pid>/net/tcp` network namespace view, requires exactly one loopback TCP port 9180 socket in `LISTEN` state, and matches its kernel inode to a socket descriptor in that master's own `/proc/<pid>/fd`. If procfs, `awk`, `readlink` or sufficient permission is unavailable, or there is no unique match, these records are omitted without changing the process observation's success status. An unrelated process listening on port 9180 cannot qualify. This is independent **TCP socket ownership** evidence only, not an Admin API endpoint identification: an HTTP GET, identity of the configuration loaded by APISIX, profile provenance, alternate IP/IPv6/ports, authentication, authorization and write readiness are not established.

Unexpected or unavailable process evidence fails non-zero. The operation never emits the process command line itself, because other process arguments might be sensitive. A PID file and process title can be stale or misleading and do **not** prove which source `config.yaml`, custom `-c`, profile, listener or effective gateway settings the active process loaded. An explicit Docker ID or a uniquely discovered conventional candidate selects an observation namespace through the remote manager or host, but does **not** establish source configuration provenance, Admin API listener ownership, deployment-controller ownership or write readiness. The method is a partial process observation, not a confirmed APISIX runtime identity, a healthy-server result, or permission to write configuration. An installation that exposes neither POSIX `ps` nor a readable Linux procfs command line, or is started with unrecognized OpenResty arguments, returns a distinct failure rather than guessing a matching instance. Even matched arguments do not establish which source APISIX configuration is active.

## Explicit read-only Admin API transport (advanced, interim)

The public shell command

```sh
rsudo apisix admin-read <resource> <absolute-remote-credential-header-file> [port]
```

and direct function `rsudo_mod_apisix_admin_read` perform one authorized read-only HTTP GET from the selected remote system, through the existing `rsudo` SSH/sudo execution. This is an **explicit low-level transport**, not the normal automatic provider-routed `list`/`get` interface.

The permitted `resource` values are `configs`, `routes`, `services`, and `upstreams`. The target is *only* `http://127.0.0.1:<port>/apisix/admin/<resource>` within the remote host, with port 9180 used when unspecified. Resource names and ports are validated before remote execution and again on the target. The operation cannot follow redirects or contact a proxy; ordinary HTTP response content is forwarded on stdout unchanged for successful requests. Curl's exit status is propagated for transport and HTTP failures (including curl's code 22 for `--fail` HTTP error responses).

The caller deliberately supplies the pathname of a **pre-existing operator-provisioned remote credential file**, containing exactly one newline-terminated `X-API-KEY: <non-whitespace-secret>` header. This file must be a readable regular file, not a symlink, and must have no group/other permission bits. The remote shell checks the single-header byte count and format before passing only the **file path**, using curl's supported `--header @file` syntax (curl 7.55.0 or later). Credential content is not interpolated into shell source or carried as an argument or diagnostic. This implementation does not provision or rotate credentials and does not require a locally authored JSON file.

This provisional operation does **not** prove the caller selected the running APISIX instance, authenticate the host identity beyond the operator-selected remote system and loopback port, discover active deployment mode, or provide an automatic abstraction over traditional and standalone resource paths. The caller is responsible for choosing an authorized target and a protected credential file. In standalone API-driven mode `configs` is the full snapshot resource, while ordinary per-resource `routes`/`services`/`upstreams` endpoints are not exposed. This operation cannot authorize changes and is not evidence that the mutation safety gate has passed.

Invalid local arguments and remote preconditions produce distinct non-zero statuses in the range 44–51 with non-sensitive diagnostics. An unavailable/unsupported remote `curl` is a prerequisite failure, not a reason to fall back to legacy behavior.

## Traditional REST list/get (initial read-only backend)

The generic public `rsudo apisix list routes|services|upstreams` and
`rsudo apisix get routes|services|upstreams <id>` use the internal REST
adapter only when the caller explicitly selects `RSUDO_APISIX_SCOPE=host`
and `RSUDO_APISIX_DEPLOYMENT=traditional-admin`. The operator supplies an
`RSUDO_APISIX_ADMIN_URL` origin and an absolute remote
`RSUDO_APISIX_HEADER_FILE`. The origin is restricted to HTTP or HTTPS and a
hostname/port authority: userinfo, path, query and fragment are rejected
locally before the value is passed to rsudo, and validated again remotely.
The ID alphabet is ASCII letters, digits, dot, underscore, tilde and hyphen;
`.` and `..` are rejected. Collection pagination and API-version negotiation
are not implemented in this initial adapter.

The remote header file must be an ordinary readable non-symlink file with
mode 0600 and exactly one newline-terminated `X-API-KEY` header. Curl uses
normal HTTPS trust verification, disables proxy use and redirects, and has
connect/total timeouts. Successful JSON is passed through unchanged; HTTP
errors return nonzero without writing the response body to stdout. These
checks protect the transport but do not prove that the URL belongs to the
selected APISIX process or that credentials are authorized.

Other scopes/adapters fail explicitly. Generic `create`, `update`, `delete`,
`apply` and `request` currently fail as unimplemented; none falls back to a
legacy function. Existing operation-specific compatibility functions retain
their previous forwarding behavior. The permanent transport test exercises
these reads against a local synthetic HTTP endpoint through the product
module, not a live APISIX installation or deployed rsudo target.

## Current limits and security boundary

The current read-only resolvers do not prove which `-c`/profile or effective configuration is active or bind the Admin listener to a selected running process. The no-operand conventional host/Docker and narrowly process-prefix-derived same-namespace host/Docker discovery, plus the optional explicit Docker selector, scope process observation but cannot establish comprehensive installation discovery or authoritative source/listener attribution. This does not globally block operations with explicit operator context; each operation must enforce the safety checks appropriate to its selected backend, target and effect. The initial REST reads above remain read-only and do not certify process identity.

Mode inspection does not emit API keys or the selected configuration contents. Credentials and target data remain subject to `RSUDO.md` and `DIAGNOSTICS.md`. The legacy APISIX functions retain previously documented unsafe JSON/request behavior, and their existence is not evidence that modern secure mutation is complete.

The complete mode-routed Admin API, standalone file-driven and API-driven
reads/mutations, generic writes, pagination, and simplified shell recipes
are **not yet implemented** by the current safe APISIX backend. The initial
traditional REST `list/get` support above is partial and does not imply
those capabilities. They are pending development, not current guarantees.

## Required mechanical protection

The permanent tests `rumiai-tests/tests/rumiai-os/rsudo/legacy-modules.test`, `rumiai-tests/tests/rumiai-os/rsudo/apisix-mode.test` and `rumiai-tests/tests/rumiai-os/rsudo/apisix-admin-transport.test` exercise module loading, configured-mode inspection, runtime observation and curl transport through real `m`, substituting SSH/sudo only where those boundaries are not under test. The Linux-only `rumiai-tests/tests/rumiai-os/rsudo/apisix-admin-rsudo-ssh-live.test` also exercises real password-authenticated OpenSSH, both password-required and NOPASSWD sudo, preserved target stdin, a protected root-owned credential header and curl. Its isolated target first serves a synthetic loopback HTTP endpoint, then shares only its network namespace with pinned running Apache APISIX gateways; the resulting composed SSH/sudo/curl-to-real-APISIX read succeeds with authorized credentials and rejects an invalid key. The remote `runtime` check still rejects process identity when the SSH target lacks the APISIX installation in its own process/filesystem namespace. Separate installed-APISIX tests exercise parser, master-process and Admin API boundaries. A Linux-only real-systemd test exercises both positive manager-MainPID correspondence and a supervised-master mismatch using real transient systemd-managed nginx processes through the real product module and local sudo. The additional `rumiai-tests/tests/rumiai-os/rsudo/apisix-systemd-apisix-live.test` runs an installed official pinned APISIX 3.19 gateway in a disposable Linux container with its own real systemd service manager: APISIX's own CLI generates the runtime configuration and starts the OpenResty master from a transient `Type=forking` service. The test confirms the actual unit `MainPID` equals the installed APISIX master and verifies that both explicit-root and automatic, host-like process observations report only the independently corroborated unit. It substitutes the rsudo SSH/sudo boundary with execution inside the selected isolated namespace, not APISIX, the process observer or systemd. The special systemd-capable test container uses restricted network isolation and disposable elevated Docker privileges solely to run its independent manager. Its isolated profile-drift scenario now starts the real service with a named API-driven `APISIX_PROFILE`, independently classifies the conflicting default file-driven source, requires implicit on-disk mode selection to reject ambiguity, performs an authorized read-only Admin API `/configs` GET and verifies through Linux kernel TCP socket inodes and the master process's open file descriptors that the selected master owns that listening socket. This proves a **scenario-specific** service-to-process-to-loopback-socket association for real APISIX and demonstrates source-selection ambiguity; it does **not** implement a general active-source/loaded-profile resolver or portable Admin listener attribution. It also does not prove general bare-metal service discovery, source snapshot identity, credentials on production machines or write readiness; a normal explicit Docker-ID inspection does not infer host systemd ownership. The live runtime test also exercises the real APISIX master through the explicit full Docker-ID selector, verifies the original host-scoped result is preserved, and rejects invalid or absent container selectors. Its no-operand scenario checks unique conventional host and Docker observations, missing master PID (not accepted as a running instance), unsafe symlinked generated configuration (not accepted as a candidate), two simultaneous real APISIX Docker candidates (ambiguous and rejected), a real paused container whose failed Docker exec must not be treated as negative discovery, and the absence of candidates after the test gateways stop. The same test runs both pinned APISIX versions using actual OpenResty masters at nonconventional `-p` prefixes, including a non-PID1 master observed within its isolated host-like namespace, verifies automatic process-prefix observation, and checks both that a missing generated configuration for an observed master fails closed and that a stale conventional generated configuration does not override the live process prefix. Only rsudo's external SSH/sudo boundary is replaced in that test. These are isolated, scope-limited mechanical tests: none proves an arbitrary production gateway's active source, process-to-listener/namespace ownership, deployed SSH identity, credential provenance, TLS configuration or readiness for mutation.

## Invariants

- Configured mode and live runtime identity remain explicitly distinct.
- Inspection has no write side effects and does not expose API keys or configuration content.
- An unknown backend or ambiguous selection does not become a successful result.
- Legacy operations remain addressable by their explicit legacy identity; new backend requests do not silently route to legacy.
- New shell APIs and their operational manuals remain consistent with current implementation.
