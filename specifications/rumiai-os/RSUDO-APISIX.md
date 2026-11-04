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
rsudo apisix runtime <absolute-remote-apisix-home>
```

and direct function `rsudo_mod_apisix_runtime` observe a specifically selected remote installation. Automatic instance discovery is **not** implemented by this operation. The caller supplies an absolute installation root. The operation checks the generated `conf/nginx.conf` and `logs/nginx.pid`, then reads the PID's visible process arguments using remote POSIX `ps`, with a guarded Linux `/proc/<pid>/cmdline` fallback when minimal containers lack `ps`. A master may legitimately have namespace PID 1. `/proc` is a Linux capability, not a universal POSIX dependency. It recognizes the APISIX CLI's `-p <home> -c <home>/conf/nginx.conf` startup and the official Docker foreground startup using `-p <home> -g 'daemon off;'` (for the generated default `conf/nginx.conf`). Process-title quoting can differ; neither form proves the gateway's source configuration.

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

Unexpected or unavailable process evidence fails non-zero. The operation never emits the process command line itself, because other process arguments might be sensitive. A PID file and process title can be stale or misleading and do **not** prove which source `config.yaml`, custom `-c`, profile, container namespace, or effective gateway settings the active process loaded. The method is a partial process observation, not a confirmed APISIX runtime identity, a healthy-server result, or permission to write configuration. An installation that exposes neither POSIX `ps` nor a readable Linux procfs command line, or is started with unrecognized OpenResty arguments, returns a distinct failure rather than guessing a matching instance. Even matched arguments do not establish which source APISIX configuration is active.

## Current limits and security boundary

The current read-only resolvers do not prove which `-c`/profile, container, process or namespace is actively in use. It cannot be used by a new mutating backend router until live identity and safe update conditions are independently verified.

Mode inspection does not emit API keys or the selected configuration contents. Credentials and target data remain subject to `RSUDO.md` and `DIAGNOSTICS.md`. The legacy APISIX functions retain previously documented unsafe JSON/request behavior, and their existence is not evidence that modern secure mutation is complete.

The full traditional Admin API, standalone file-driven mutation, standalone API-driven snapshot mutation, generic resource API, simplified shell recipes and new Keycloak functionality are **not yet implemented** by the current safe backend. They are pending development, not current product guarantees.

## Required mechanical protection

The permanent tests `rumiai-tests/tests/rumiai-os/rsudo/legacy-modules.test` and `rumiai-tests/tests/rumiai-os/rsudo/apisix-mode.test` exercise module presence, loading and read-only selection/inspection/runtime observation behavior through the real `m` entrypoint up to the modeled external dependency boundary. A fixture boundary result does not prove live APISIX identity or production behavior. Real instance validation is separate and required before advertising corresponding backend support.

## Invariants

- Configured mode and live runtime identity remain explicitly distinct.
- Inspection has no write side effects and does not expose API keys or configuration content.
- An unknown backend or ambiguous selection does not become a successful result.
- Legacy operations remain addressable by their explicit legacy identity; new backend requests do not silently route to legacy.
- New shell APIs and their operational manuals remain consistent with current implementation.
