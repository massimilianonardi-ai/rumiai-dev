# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   b6720b06d95e8e3042d6e9fd021119a414ffc64c
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests ede6002711b84272be2618b0b5e4e8cbd4ea260b
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`

## Fixed task-local choices

- Exercise every current top-level package definition in `pkg-catalog`.
- Use the real public `pkg install` command and real current catalog/repository adapters.
- Verify package-specific post-install properties exposed by each catalog definition, not only command exit status.
- Correct product, catalog or permanent-test defects discovered by the matrix within this work unit when authorized by the current task.

## Completed

- Mandatory preflight completed.
- Current catalog contains: chrome, chromium, dbeaver, electron, graalvm, jq, keycloak, maven, micromamba, netbeans, nodejs, pulsar.
- Linux x86_64 catalog definitions were classified by repository adapter, format and integration features.
- Exploratory live matrix run 35335325381 exercised the real public install command against all twelve packages.
- Isolated install succeeded for chromium, dbeaver, electron, graalvm, jq, micromamba, nodejs and pulsar.
- Maven and NetBeans failed at dependency resolution because their Java provider was intentionally absent in isolated jobs; Keycloak also failed in the provider-less isolated scenario and must be retested after GraalVM.
- Chrome exposed a composed-path adapter defect: catalog range anchor 153.0.8010.36-1 is no longer present in Google's current Packages index, and the Chrome comparison function currently requires both operands to remain upstream-available.

## Current state

Chrome exact-version resolution must continue to reject vendor-removed concrete versions, but range-anchor ordering must be local because Google does not retain old stable versions in the current Packages index. The current Chrome unit test incorrectly requires comparison with a removed version to fail and therefore encodes the composed-path defect.

Dependency-aware validation must install GraalVM before Keycloak, Maven and NetBeans, then verify their Java bindings/env integration. Package-specific checks must also cover setuid_root, facility publication, Keycloak var routing, Node.js env materialization and the catalog's different extraction formats.

## Next action

1. Correct Chrome version comparison semantics and the corresponding adapter regression test.
2. Run a dependency-aware all-catalog live matrix with package-specific post-install assertions.
3. Convert the validated matrix into permanent test coverage and run the final package regression.

## Blockers / open questions

None currently.
