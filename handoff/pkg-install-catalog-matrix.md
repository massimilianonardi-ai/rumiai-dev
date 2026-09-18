# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   5b951758f57513a18baa679e6c41efe3cc9fdbba
rumiai-os    8177082a4254774db96d94aff2aff3d971da659f
rumiai-tests d94d5ad97d3185278275c41943ab1740e16115da
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
- Chrome exposed a composed-path adapter defect: catalog range anchor 153.0.8010.36-1 is no longer present in Google's current Packages index.
- Chrome ordering was corrected in `rumiai-os@7eaebea5...`: comparison of syntactically valid versions is local, while concrete resolution/artifact resolution still enforce upstream availability. The corresponding permanent adapter regression is in `rumiai-tests`, and the canonical range-anchor contract is in `PACKAGE-MODEL.md`.
- Live Chrome installation then succeeded as `chrome@153.0.8010.52-1!linux-x86_64`, including the catalog-defined setuid sandbox check.
- Maven and NetBeans both succeeded when GraalVM was installed first; Maven also executed `mvn --version` through the normal package launcher.
- Keycloak still fails after GraalVM. The trace reaches state validation after successful resolve/download/extract and fails because current upstream Keycloak 26.7.4 contains `conf/` but no `data/`, while the catalog declares both `var/conf -> conf` and `var/data -> data`.
- Official Keycloak 26.7.4 tar.gz and zip archives were both inspected and neither contains `data/`; this is therefore not archive-format-specific.
- The trace also exposed a separate current implementation regression in the install scratch pathname (`install-# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   5b951758f57513a18baa679e6c41efe3cc9fdbba
rumiai-os    8177082a4254774db96d94aff2aff3d971da659f
rumiai-tests d94d5ad97d3185278275c41943ab1740e16115da
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
 instead of PID-qualified `install-$`); it was corrected forward in `rumiai-os@8177082a...`.

## Current state

Eleven packages are expected to be fully exercisable on Linux x86_64 with current contracts. Keycloak exposes a real catalog/state-model incompatibility: `var/` mappings currently require the mapped source path to exist in the extracted artifact, while current Keycloak requires a runtime `data/` directory that its official distribution no longer pre-creates.

The current State model defines package `var/` as routing for mutable paths inside the package tree, but it does not define a representation for a mutable directory that is intentionally absent from the upstream artifact. Removing the Keycloak data mapping would make installation pass while allowing runtime data into the immutable package root, so that is not treated as a valid fix.

## Next action

1. Run the final dependency-aware Linux x86_64 matrix against `rumiai-os@8177082a...`, with package-specific assertions for all eleven currently installable packages and an explicit diagnostic assertion for the Keycloak incompatibility.
2. Run the relevant permanent package/adapter/live regressions against current `rumiai-tests`.
3. Decide the smallest contract-compliant representation for an upstream runtime directory that is absent from the artifact before changing Keycloak/state semantics.

## Blockers / open questions

- Keycloak needs a canonical way to represent a package-local mutable runtime directory that upstream does not ship initially. Current `var/` semantics do not cover that case.
