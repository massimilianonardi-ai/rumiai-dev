# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   5de558e61638c1d4a5cd1e34e7582fbdccbaa606
rumiai-os    8a179b38b07fbd35e475b7df6b8f05e976cc0fdb
rumiai-tests c864d3080e22fcdce50877823aa5f741ef98b3f0
pkg-catalog  8407f2308cf0c5e7bdc3abd8aeb9538410e55b90
```

The revisions above are the latest observed main HEADs at this checkpoint. Concurrent test-suite work may advance `rumiai-tests/main`; recheck before every subsequent modification or validation claim.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `RUNNER.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`

## Fixed task-local choices

- Exercise every current top-level package definition in `pkg-catalog`.
- Use the real public `pkg install` command and real current catalog/repository adapters.
- Verify package-specific post-install properties exposed by each catalog definition, not only command exit status.
- Correct product, catalog or permanent-test defects discovered by the matrix within this work unit when authorized by the current task.
- On Linux x86_64 Chromium must export `CHROME_DEVEL_SANDBOX` to the concrete package's `root/chrome_sandbox` before launching Chromium.

## Completed

- Mandatory preflight and catalog classification completed.
- Current package set is: chrome, chromium, dbeaver, electron, graalvm, java, jq, keycloak, maven, micromamba, netbeans, nodejs, pulsar.
- Exploratory live matrix run `35335325381` exercised the public install path against all twelve packages.
- Chrome exposed a composed-path adapter defect because Google's current Packages index no longer retained the catalog's historical range anchor. Chrome version ordering was corrected in `rumiai-os@7eaebea5a134efb033872e2db3357834ed2fa03f`; concrete version and artifact resolution still enforce upstream availability. The canonical range-anchor contract was aligned in `PACKAGE-MODEL.md`.
- Live Chrome installation subsequently succeeded as `chrome@153.0.8010.52-1!linux-x86_64`, including setuid sandbox validation.
- The install scratch path regression `install-$` was corrected forward to PID-qualified `install-$$` in `rumiai-os@8177082a4254774db96d94aff2aff3d971da659f`.
- Dependency-aware validation confirmed Maven and NetBeans install successfully when GraalVM is installed first; Maven also executes through its normal launcher.
- Final Linux x86_64 live matrix run `35336831593` passed package-specific checks for dbeaver, electron, chrome, chromium, graalvm, jq, maven, micromamba, netbeans and pulsar. Node.js hit one transient upstream HTTP 403 in that parallel run, then isolated retry run `35336942552` passed with node v26.9.0 and npm/npx 11.19.1.
- Keycloak resolution, download and extraction succeed after GraalVM, but integration fails in state validation because upstream Keycloak 26.7.4 contains `conf/` and no `data/`, while the catalog declares both `var/conf -> conf` and `var/data -> data`. Both official tar.gz and zip archives were inspected and neither contains `data/`.
- User-specified Chromium Linux requirement was added to `pkg-catalog@d589fb5f5da62a3aece551a8f48bab0ed054f3da`: the Linux x86_64 range now materializes an `env` that derives and exports `CHROME_DEVEL_SANDBOX=<concrete>/root/chrome_sandbox` from `m_COMMAND_BIN` and validates that the sandbox is an executable regular file.
- Chromium exploratory live run `35337621028` passed: `chromium@1700613!linux-x86_64`, sandbox root:root mode 4755, exact `CHROME_DEVEL_SANDBOX` binding, and public `chromium --version` execution.
- Permanent `tests/external/chromium/install-live.test` was added, made executable, and corrected to capture the pre-install `pkg versions` status explicitly instead of relying on the historical broken `if ...; fi; $?` pattern.
- Permanent Chromium test run `35338500382` passed through canonical `rumiai-test` after the Actions target was initialized with `osarch-update`.
- Eclipse Temurin Java 25 was added as package `java` in `pkg-catalog@8407f2308cf0c5e7bdc3abd8aeb9538410e55b90` for Linux x86_64/ARM64, macOS x86_64/ARM64 and Windows x86_64. It is a provider of facility `java 25`, matching the existing GraalVM provider model.
- The install scratch path was found regressed again to literal `install-# pkg install catalog matrix validation

Status: Active
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only simple executable installation.

## Current repository revisions

```text
rumiai-dev   5de558e61638c1d4a5cd1e34e7582fbdccbaa606
rumiai-os    8a179b38b07fbd35e475b7df6b8f05e976cc0fdb
rumiai-tests c864d3080e22fcdce50877823aa5f741ef98b3f0
pkg-catalog  8407f2308cf0c5e7bdc3abd8aeb9538410e55b90
```

The revisions above are the latest observed main HEADs at this checkpoint. Concurrent test-suite work may advance `rumiai-tests/main`; recheck before every subsequent modification or validation claim.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `RUNNER.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`

## Fixed task-local choices

- Exercise every current top-level package definition in `pkg-catalog`.
- Use the real public `pkg install` command and real current catalog/repository adapters.
- Verify package-specific post-install properties exposed by each catalog definition, not only command exit status.
- Correct product, catalog or permanent-test defects discovered by the matrix within this work unit when authorized by the current task.
- On Linux x86_64 Chromium must export `CHROME_DEVEL_SANDBOX` to the concrete package's `root/chrome_sandbox` before launching Chromium.

## Completed

- Mandatory preflight and catalog classification completed.
- Current package set is: chrome, chromium, dbeaver, electron, graalvm, java, jq, keycloak, maven, micromamba, netbeans, nodejs, pulsar.
- Exploratory live matrix run `35335325381` exercised the public install path against all twelve packages.
- Chrome exposed a composed-path adapter defect because Google's current Packages index no longer retained the catalog's historical range anchor. Chrome version ordering was corrected in `rumiai-os@7eaebea5a134efb033872e2db3357834ed2fa03f`; concrete version and artifact resolution still enforce upstream availability. The canonical range-anchor contract was aligned in `PACKAGE-MODEL.md`.
- Live Chrome installation subsequently succeeded as `chrome@153.0.8010.52-1!linux-x86_64`, including setuid sandbox validation.
- The install scratch path regression `install-$` was corrected forward to PID-qualified `install-$$` in `rumiai-os@8177082a4254774db96d94aff2aff3d971da659f`.
- Dependency-aware validation confirmed Maven and NetBeans install successfully when GraalVM is installed first; Maven also executes through its normal launcher.
- Final Linux x86_64 live matrix run `35336831593` passed package-specific checks for dbeaver, electron, chrome, chromium, graalvm, jq, maven, micromamba, netbeans and pulsar. Node.js hit one transient upstream HTTP 403 in that parallel run, then isolated retry run `35336942552` passed with node v26.9.0 and npm/npx 11.19.1.
- Keycloak resolution, download and extraction succeed after GraalVM, but integration fails in state validation because upstream Keycloak 26.7.4 contains `conf/` and no `data/`, while the catalog declares both `var/conf -> conf` and `var/data -> data`. Both official tar.gz and zip archives were inspected and neither contains `data/`.
- User-specified Chromium Linux requirement was added to `pkg-catalog@d589fb5f5da62a3aece551a8f48bab0ed054f3da`: the Linux x86_64 range now materializes an `env` that derives and exports `CHROME_DEVEL_SANDBOX=<concrete>/root/chrome_sandbox` from `m_COMMAND_BIN` and validates that the sandbox is an executable regular file.
- Chromium exploratory live run `35337621028` passed: `chromium@1700613!linux-x86_64`, sandbox root:root mode 4755, exact `CHROME_DEVEL_SANDBOX` binding, and public `chromium --version` execution.
- Permanent `tests/external/chromium/install-live.test` was added, made executable, and corrected to capture the pre-install `pkg versions` status explicitly instead of relying on the historical broken `if ...; fi; $?` pattern.
 at the then-current product HEAD and was restored forward to PID-qualified `install-$` in `rumiai-os@8a179b38b07fbd35e475b7df6b8f05e976cc0fdb`.
- Permanent `tests/external/java/install-live.test` was added and made executable. It installs through the public `pkg install java` path, verifies default/version identity, materialized `java 25` facility, normalized runtime layout and execution of the installed Java 25 runtime.
- The same stale pre-install status pattern was corrected in `tests/rumiai-os/pkg/install-live.test` at `rumiai-tests@c864d3080e22fcdce50877823aa5f741ef98b3f0`.
- Clean Linux x86_64 Actions run `35346731350` passed both the permanent Temurin adapter contract and `external/java/install-live.test` through canonical `rumiai-test`. A separate attempt to include the unrelated jq live install reached the real download and encountered upstream HTTP 403; this was not used as Java/package-manager failure evidence.

## Current state

Twelve of the thirteen current Linux x86_64 catalog packages have successful real install evidence with their relevant integration properties exercised. Java/Temurin now has permanent real-install regression coverage, and Chromium retains permanent regression coverage for the Linux sandbox environment requirement.

Keycloak remains the only known package-level incompatibility. The current State model permits `var/` routing for mutable package paths that already exist in the extracted artifact, but it does not define how a catalog should represent a package-local mutable directory that upstream intentionally omits initially. Removing the Keycloak data mapping is not accepted as a fix because it would permit runtime data to be written into the immutable package root.

The existing historical live-test pre-install status pattern was also shown to be unreliable: an `if command; then ...; fi` construct does not preserve the command status for a later `$?` assertion. Chromium, Java and the generic pkg live-install test now capture the status explicitly. Other concurrent suite realignment is outside this checkpoint unless selected by the remaining package-validation scope.

## Next action

1. Define the smallest canonical State/package representation for an upstream runtime directory that is absent from the distributed artifact, then realign Keycloak and validate it end to end.
2. Re-run the final all-catalog matrix after the Keycloak realignment so every current package path has composed-path evidence.

## Blockers / open questions

- Keycloak needs a canonical representation for a package-local mutable runtime directory that upstream does not ship initially. Current `var/` semantics do not cover that case.
