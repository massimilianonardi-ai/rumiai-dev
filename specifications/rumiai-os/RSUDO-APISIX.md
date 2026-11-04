# rsudo APISIX Administration — Current Implemented Contract

Status: **Current / partial implementation**
Updated: 2026-11-04

## Scope and ownership

The `rsudo` APISIX module is an `m` shell library at `lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh`, loaded through the normal `rsudo` submodule dispatcher. SSH/sudo authentication, execution and stream semantics remain governed by `RSUDO.md`. This specification describes **only current implemented, operator-observable APISIX behavior**; it does not treat the active development plan as already delivered.

The library's operational function signatures and current limitations are maintained in `rumiai-os/res/sys/manual/rsudo-mod-apisix.lib.sh`. The active implementation plan, pending design and version validation are kept in `rumiai-dev/handoff/rsudo-apisix-administration.md`, which is not normative.

## Legacy separation

The previous APISIX implementation is retained under `rsudo-mod-apisixlegacy.lib.sh` and the `rsudo apisixlegacy` dispatcher identity. Its public functions carry the prefix `rsudo_mod_apisixlegacy_`. The current APISIX module still forwards its pre-existing public operations to that retained implementation unless explicitly replaced.

Similarly, the previous Keycloak module is retained under `rsudo-mod-keycloaklegacy.lib.sh`, while `rsudo-mod-keycloak.lib.sh` currently forwards to its retained implementation. Modern Keycloak administration is not yet delivered.

The legacy interfaces retain their own documented limitations and must not be mistaken for the new safe, multi-backend administration implementation. No default or implicit fallback from an unsupported new backend operation to the unsafe legacy path is permitted.

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

and direct function `rsudo_mod_apisix_runtime` observe a remotely selected installation. With no operands, the resolver checks the conventional `/usr/local/apisix/conf/nginx.conf` on the selected remote host and all accessible running Docker containers for an observed, ordinary readable non-symlink generated-configuration candidate. Exactly one candidate may be selected; the selected process is then rechecked with the same existing pidfile/master argument observer. A generated configuration without an observable master is **not** a successful automatic runtime discovery, although explicit runtime inspection may truthfully report `pidfile-missing` without inferring a stopped server. Automatic discovery is **best effort and limited to the conventional installation root**: unscanned nonstandard homes, service-manager instances, inaccessible containers and external namespaces are not certified absent. A present but inaccessible Docker manager prevents a uniqueness claim; invalid Docker ID records, no observed candidate or multiple candidates fail non-zero rather than selecting an arbitrary instance. Every running Docker candidate probe distinguishes an ordinary missing generated configuration from an unsafe/unreadable configuration or an execution failure (such as no shell or a disappearing container). Only a definite missing configuration is safely skipped; unsafe/unreadable sources (status 53) and indeterminate container probes (status 52) fail closed. A unique selected candidate without an observed master fails status 51, and unexpected master-observation output fails status 54, without a successful discovery payload. A system without Docker may still confirm a single conventional host candidate. The successful no-operand response prefixes the existing runtime evidence with `discovery_evidence=unique-conventional-candidate` and `discovered_scope=host` or `discovered_scope=docker`; for the Docker case, `container_id=<full-64-hex-id>` is also emitted. The caller may instead supply an absolute installation root to observe only the remote SSH/sudo host namespace. An optional *explicit* full lowercase 64-character hexadecimal Docker container ID scopes the unchanged read-only program to the selected running container via the existing remote rsudo SSH/sudo transport and `docker exec -i <id> sh -s`; this requires remote Docker access and a working shell in that container. Shortened IDs, names, invalid characters and Docker option operands are rejected before remote execution (status 44). The operation checks the generated `conf/nginx.conf` and `logs/nginx.pid` inside the selected namespace, then reads the PID's visible process arguments using POSIX `ps`, with a guarded Linux `/proc/<pid>/cmdline` fallback when minimal containers lack `ps`. A master may legitimately have namespace PID 1. `/proc` is a Linux capability, not a universal POSIX dependency. It recognizes the APISIX CLI's `-p <home> -c <home>/conf/nginx.conf` startup and the official Docker foreground startup using `-p <home> -g 'daemon off;'` (for the generated default `conf/nginx.conf`). Process-title quoting can differ; neither form proves the gateway's source configuration.

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

## Current limits and security boundary

The current read-only resolvers do not prove which `-c`/profile or effective configuration is active or bind the Admin listener to a selected running process. The no-operand conventional-host/Docker discovery and optional explicit Docker selector scope process observation, but cannot establish comprehensive installation discovery or authoritative source/listener attribution. It cannot be used by a new mutating backend router until live identity and safe update conditions are independently verified.

Mode inspection does not emit API keys or the selected configuration contents. Credentials and target data remain subject to `RSUDO.md` and `DIAGNOSTICS.md`. The legacy APISIX functions retain previously documented unsafe JSON/request behavior, and their existence is not evidence that modern secure mutation is complete.

The complete mode-routed Admin API, standalone file-driven mutation, standalone API-driven snapshot mutation, generic resource API, simple `list`/`get` conveniences, simplified shell recipes and new Keycloak functionality are **not yet implemented** by the current safe backend. The explicit low-level `admin-read` endpoint above does not imply that they exist. They are pending development, not current product guarantees.

## Required mechanical protection

The permanent tests `rumiai-tests/tests/rumiai-os/rsudo/legacy-modules.test`, `rumiai-tests/tests/rumiai-os/rsudo/apisix-mode.test` and `rumiai-tests/tests/rumiai-os/rsudo/apisix-admin-transport.test` exercise module loading, configured-mode inspection, runtime observation and curl transport through real `m`, substituting SSH/sudo only where those boundaries are not under test. The Linux-only `rumiai-tests/tests/rumiai-os/rsudo/apisix-admin-rsudo-ssh-live.test` also exercises real password-authenticated OpenSSH, both password-required and NOPASSWD sudo, preserved target stdin, a protected root-owned credential header and curl. Its isolated target first serves a synthetic loopback HTTP endpoint, then shares only its network namespace with pinned running Apache APISIX gateways; the resulting composed SSH/sudo/curl-to-real-APISIX read succeeds with authorized credentials and rejects an invalid key. The remote `runtime` check still rejects process identity when the SSH target lacks the APISIX installation in its own process/filesystem namespace. Separate installed-APISIX tests exercise parser, master-process and Admin API boundaries. The live runtime test also exercises the real APISIX master through the explicit full Docker-ID selector, verifies the original host-scoped result is preserved, and rejects invalid or absent container selectors. Its no-operand scenario checks unique conventional host and Docker observations, missing master PID (not accepted as a running instance), unsafe symlinked generated configuration (not accepted as a candidate), two simultaneous real APISIX Docker candidates (ambiguous and rejected), and the absence of candidates after the test gateways stop. Only rsudo's external SSH/sudo boundary is replaced in that test. These are isolated, scope-limited mechanical tests: none proves an arbitrary production gateway's active source, process-to-listener/namespace ownership, deployed SSH identity, credential provenance, TLS configuration or readiness for mutation.

## Invariants

- Configured mode and live runtime identity remain explicitly distinct.
- Inspection has no write side effects and does not expose API keys or configuration content.
- An unknown backend or ambiguous selection does not become a successful result.
- Legacy operations remain addressable by their explicit legacy identity; new backend requests do not silently route to legacy.
- New shell APIs and their operational manuals remain consistent with current implementation.
