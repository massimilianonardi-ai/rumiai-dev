# Keycloak package state mapping

Status: Active
Updated: 2026-10-05

## Goal

Determine which Keycloak installation-root paths are genuinely mutable state under the current RumiAI package model, identify Keycloak command-line/environment controls that relocate or suppress those writes, and realign the current pkg-catalog `var/` mapping only after empirical evidence.

## Current repository revisions

- rumiai-dev: be6cfd7487e5a76de9c674f1763cf2c0ca65dccb before this handoff synchronization
- rumiai-os: afd4cf7c84096e3d55cf753ff9bf4807e5033493
- rumiai-tests: 1b1833ffb04719648a93a5394b8ea39ac4d5b4e6
- pkg-catalog: b8fb0ec8f4022b99f805a3bbaf93c2f328213780
- rumiai-dev-PoCs: 5296ae5ed6a5bcac3ae63e252275e5df00cd3241

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- TEST-PATTERNS.md
- specifications/rumiai-os/STATE-MODEL.md
- specifications/rumiai-os/PACKAGE-MODEL.md

## Fixed task-local choices

- Use Keycloak `start-dev` for runtime probes; production `start` is out of scope for this investigation because it requires unrelated production hostname/TLS setup.
- Use the cataloged 26.7.3 range anchor as the direct upstream probe target while separately validating the current catalog-selected release through the real package path.
- Use `rumiai-dev-PoCs` for dynamic state-mapping experiments.
- Keep the existing `var/conf -> conf` mapping.
- Keep the existing `var/data -> data` mapping.
- Route `lib/quarkus` through package `cache`: `var/cache -> lib/quarkus`.
- Do not add a separate `log` mapping: observed/default Keycloak file logging is under `data/log`, already covered by the `data` mapping, and explicit file-log paths are configurable.
- Do not map `providers/` or `themes/` as part of this runtime-state work. They are operator-supplied customization surfaces, not state created by the observed `start-dev` path, and persistence across package upgrades is a separate design question.

## Empirical findings

### Direct upstream Keycloak 26.7.3 probes

PoC 055 ran real Keycloak 26.7.3 `start-dev` executions on GitHub Actions using current `pkg-analyze` plus SHA-256 tree manifests so modifications to existing files were visible.

Baseline `start-dev` created:

```text
data/h2/keycloakdb.mv.db
data/h2/keycloakdb.trace.db
data/transaction-logs/...
```

and modified:

```text
lib/quarkus/generated-bytecode.jar
lib/quarkus/quarkus-application.dat
lib/quarkus/transformed-bytecode.jar
```

With `--db=dev-mem`, the H2 database files disappeared but `data/transaction-logs/...` remained and the same three `lib/quarkus` files changed.

An external H2 file URL supplied through CLI relocated the database files outside the package root while `data/transaction-logs/...` and the three Quarkus build-artifact modifications remained. The equivalent `KC_DB` / `KC_DB_URL` environment case produced the same state-location behavior.

File logging redirected through CLI created the requested external log file while package-root state remained `data/transaction-logs/...` plus the three Quarkus modifications. The equivalent `KC_LOG` / `KC_LOG_FILE` environment case produced the same state-location behavior.

The direct upstream probe succeeded in GitHub Actions run 37271810703.

### Real composed package path

PoC 055 then executed the real RumiAI path:

```text
pkg install temurin
pkg install keycloak
keycloak start-dev --db=dev-mem
```

The catalog range resolved Keycloak 26.8.0 on linux-x86_64, confirming that `n0001=26.7.3` is an ordering/range anchor rather than an exact package pin.

After the catalog change the installed concrete had:

```text
root/conf        -> ../var/conf/conf
root/data        -> ../var/data/data
root/lib/quarkus -> ../../var/cache/lib/quarkus
```

The `start-dev` execution modified the three Quarkus artifacts in managed cache state and started Keycloak successfully. The composed PoC succeeded in run 37272718345. A later composed validation against current rumiai-os revision afd4cf7c84096e3d55cf753ff9bf4807e5033493 also completed successfully in run 37273219143.

## Implemented changes

### pkg-catalog

Added `var/cache` containing `lib/quarkus` to all four Keycloak osarch definitions:

- linux-arm64
- linux-x86_64
- macos-arm64
- macos-x86_64

Final catalog revision after these forward-only commits:

```text
b8fb0ec8f4022b99f805a3bbaf93c2f328213780
```

### rumiai-tests

The existing permanent `tests/external/keycloak/install-live.test` now also checks that:

- Keycloak cache state initializes `lib/quarkus`;
- the package root routes `lib/quarkus` through a symlink;
- factory Quarkus cache content is present.

Revision:

```text
1b1833ffb04719648a93a5394b8ea39ac4d5b4e6
```

### rumiai-dev-PoCs

PoC 055 contains:

- direct upstream `pkg-analyze` probes;
- SHA-256 content-delta detection;
- CLI/environment DB relocation cases;
- CLI/environment file-log relocation cases;
- real composed package installation/start-dev validation.

Current revision:

```text
5296ae5ed6a5bcac3ae63e252275e5df00cd3241
```

The latest workflow run 37273219143 has a successful composed integration job; its repeated direct-upstream probe was still running at the last checkpoint. Earlier run 37271810703 already provides successful direct-upstream evidence for all six cases.

## Validation status

The focused Keycloak state-mapping evidence is successful:

- direct upstream 26.7.3 state probes: passed;
- real composed package routing on current catalog-selected Keycloak 26.8.0: passed;
- composed routing recheck against rumiai-os afd4cf7c84096e3d55cf753ff9bf4807e5033493: passed.

The broader permanent-test validation path is currently blocked before reaching the newly added Keycloak cache assertions by pre-existing/current test-infrastructure mismatches:

1. the formal `package-provider-facility-final` workflow fails while expanding its validation selection with `rumiai-test: selection does not exist`;
2. a direct execution of the permanent Keycloak live test gets through target discovery and Temurin installation but then fails while querying current package requirements because the current product/test combination reports `pkg_install_requirement_list: not found`.

These failures are not evidence against the Keycloak cache mapping and must not be reported as successful Keycloak permanent validation. They require separate realignment of the current package-requirement/testing surfaces.

Physical validation has not been performed; current evidence is GitHub Actions execution.

## Current state

The runtime state classification and catalog mapping for the observed Keycloak `start-dev` path are implemented and empirically validated.

The task remains Active because the permanent Keycloak test cannot currently reach its new cache assertions through the existing broader package-requirement/test path.

## Next action

Realign or unblock the current permanent package-requirement validation path, then execute `tests/external/keycloak/install-live.test` through the supported runner and close this task if the cache assertions pass.

## Separate question not blocking this mapping

Whether operator-managed `providers/` and `themes/` should persist across Keycloak package upgrades remains a distinct customization/persistence design question. It is deliberately not inferred from runtime `start-dev` mutation evidence.
