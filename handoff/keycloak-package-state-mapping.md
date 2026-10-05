# Keycloak package state mapping

Status: Active
Updated: 2026-10-05

## Goal

Determine which Keycloak installation-root paths are genuinely mutable state under the current RumiAI package model, identify Keycloak command-line/environment controls that relocate or suppress those writes, and realign the current pkg-catalog `var/` mapping only after empirical evidence.

## Current repository revisions

- rumiai-dev: 0ad97b917375246d5f6a22943b4f0dc5b2c91df2 before this handoff synchronization
- rumiai-os: 2693e5695e7b75c45b1cda0a490435480960534d
- rumiai-tests: b1fb39a774bdd317730da69c9a34e6ed8368d33f
- pkg-catalog: f97a989d795192f8b2acb72a9b658817184633ab
- rumiai-dev-PoCs: efdec306d2765c193e4261e3d576b7ae58ce021a

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
- Treat Keycloak as a platform-independent `all` package. Its concrete identity must therefore be `keycloak@<version>` without an `!<osarch>` suffix; its Java dependency still resolves against the applicable target osarch.
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

The catalog range resolved Keycloak 26.8.0, confirming that `n0001=26.7.3` is an ordering/range anchor rather than an exact package pin. After the user's platform-independence correction, the catalog was migrated to the `all` stream and the real composed path resolves the concrete as `keycloak@26.8.0`, with no osarch suffix.

After the catalog change the installed concrete had:

```text
root/conf        -> ../var/conf/conf
root/data        -> ../var/data/data
root/lib/quarkus -> ../../var/cache/lib/quarkus
```

The `start-dev` execution modified the three Quarkus artifacts in managed cache state and started Keycloak successfully. The composed PoC succeeded in run 37272718345. A later composed validation against current rumiai-os revision afd4cf7c84096e3d55cf753ff9bf4807e5033493 also completed successfully in run 37273219143.

## Implemented changes

### pkg-catalog

Keycloak is now represented by one platform-independent `pkg/keycloak/all` stream. The former four osarch-specific duplicate definitions were removed forward-only. The `all` range retains:

```text
var/conf  -> conf
var/data  -> data
var/cache -> lib/quarkus
```

Final catalog revision after these forward-only changes:

```text
f97a989d795192f8b2acb72a9b658817184633ab
```

### rumiai-tests

The existing permanent `tests/external/keycloak/install-live.test` now also checks that:

- Keycloak cache state initializes `lib/quarkus`;
- the package root routes `lib/quarkus` through a symlink;
- factory Quarkus cache content is present;
- the installed Keycloak concrete is platform-independent and carries no `!<osarch>` suffix.

A focused PKG-86 regression check was also added to `tests/rumiai-os/pkg/catalog.test`.

Current test-suite revision:

```text
b1fb39a774bdd317730da69c9a34e6ed8368d33f
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
efdec306d2765c193e4261e3d576b7ae58ce021a
```

Workflow run 37282725049 passed both direct upstream and composed jobs. The composed result installed `keycloak@26.8.0` without an osarch suffix, preserved the three state links, and successfully started Keycloak in development mode.

## Validation status

The focused Keycloak state-mapping evidence is successful:

- direct upstream 26.7.3 state probes: passed;
- real composed package routing on current catalog-selected Keycloak 26.8.0: passed;
- composed routing recheck against rumiai-os afd4cf7c84096e3d55cf753ff9bf4807e5033493: passed.

The previous direct Keycloak permanent-test blocker `pkg_install_requirement_list: not found` was traced to a real product mismatch: current `pkg-requirement.lib.sh` still called a removed `pkg-install` helper even though PKG-86 requires catalog-backed read-only requirement listing. The product now implements requirement listing directly through `pkg-catalog` and `pkg-dependency`, and its manual has been realigned at rumiai-os revision `2693e5695e7b75c45b1cda0a490435480960534d`.

The broad `package-provider-facility-final` workflow still has an independent historical selection/configuration problem and is not treated as Keycloak evidence.

Physical validation has not been performed; current evidence is GitHub Actions execution.

## Dependency ambiguity diagnostic realignment

A direct operator attempt to run `pkg install keycloak` with no configured Java provider exposed a separate dependency-planning UX issue. The failure is semantically correct: current catalog data offers both Temurin 25 and GraalVM 25 as compatible providers for Keycloak's `java =25` requirement, so PKG-93 requires ambiguity rather than silent ranking.

The diagnostic path has now been realigned without changing provider-selection semantics:

- `pkg depend` reports `reason=provider-ambiguous` with facility, combined constraints, target osarch and exact compatible provider candidates;
- `pkg install` preserves that planner diagnostic and classifies the valid-request failure as `execution-failed`, not `invalid-arguments`;
- PACKAGE-MODEL now records this as PKG-100;
- `depend.test` protects the structured ambiguity detail;
- `install-dependency-order.test` protects propagation/classification through `pkg install`.

Current revisions for this diagnostic work:

```text
rumiai-dev   643bc6f536f0af39e5ae33aea7027e8e6962652d
rumiai-os    f39d986e5d4269f742d138eb3ebf9092d1e3345c
rumiai-tests 654c02991b3e9e6ad7b2f1e3d69be1a5fd189bcf
```

The automatically triggered hosted validation runs were still queued at the last checkpoint, so they are not yet PASS evidence.

## Current state

The runtime state classification, `all` stream correction and catalog mapping for the observed Keycloak `start-dev` path are implemented and empirically validated through the composed PoC.

The task remains Active pending completion of the current permanent-suite validation run against the repaired PKG-86 requirement-list path.

## Next action

Review the current `rumiai-os-health` result for rumiai-os `2693e5695e7b75c45b1cda0a490435480960534d` and current tests. If the focused catalog/Keycloak assertions pass, perform the final consistency gate and close the task; otherwise correct only the observed remaining mismatch.

## Separate question not blocking this mapping

Whether operator-managed `providers/` and `themes/` should persist across Keycloak package upgrades remains a distinct customization/persistence design question. It is deliberately not inferred from runtime `start-dev` mutation evidence.
