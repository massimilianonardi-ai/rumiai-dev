# pkg install catalog matrix validation

Status: Complete
Updated: 2026-09-18

## Goal

Validate the real public `pkg install` path against every package currently defined in `pkg-catalog`, including package-specific integration behavior rather than only command exit status.

## Current repository revisions

```text
rumiai-dev   c1af369c114ae0b485269fc3db9724003f40e5d4  (parent of this completion snapshot)
rumiai-os    25ab0e5a5b8267af715f320bd9ee17405a2b41f6
rumiai-tests 92f959dfec65e2f53772c8d6375b96d80fc1fcc2
pkg-catalog  8407f2308cf0c5e7bdc3abd8aeb9538410e55b90
```

The final Linux matrix evidence was produced against `rumiai-tests@ab331c94371c7146eb2feeab8d1036f0c4ad13fd`. The current suite is forward-only from that revision; the later changes affect only the Electron macOS stale-status correction and unrelated CLI tests, not the thirteen matrix selections.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `RUNNER.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

- Exercise every current top-level package definition in `pkg-catalog`.
- Use the real public `pkg install` command and real current catalog/repository adapters.
- Verify package-specific post-install properties when applicable.
- On Linux x86_64 Chromium exports `CHROME_DEVEL_SANDBOX` to its concrete `root/chrome_sandbox`.

## Completed

- The current catalog contains thirteen packages: chrome, chromium, dbeaver, electron, graalvm, java, jq, keycloak, maven, micromamba, netbeans, nodejs and pulsar.
- Eclipse Temurin Java 25 was added as package `java` in `pkg-catalog@8407f2308cf0c5e7bdc3abd8aeb9538410e55b90`, providing facility `java 25`.
- The install scratch pathname regression was restored forward to PID-qualified `install-$$`; the current `rumiai-os` implementation preserves that correction.
- Chromium Linux sandbox integration and permanent regression coverage were completed.
- The current State contract and implementation support a declared absent `var/` leaf as an initially empty directory when its parent hierarchy is valid. Keycloak therefore keeps its mutable `data/` outside the immutable package root without a package-specific exception.
- Permanent live-install coverage was added or realigned for Java, Keycloak, Maven, NetBeans, Chrome and Pulsar. Historical pre-install status handling was corrected across the affected external package tests.
- Keycloak, Maven and NetBeans now validate dependency binding through the Temurin `java` provider where selected by their tests.
- Final clean Linux x86_64 matrix run `35352230971` passed all thirteen package selections with no SKIP, FAIL or ERROR against `rumiai-os@25ab0e5a5b8267af715f320bd9ee17405a2b41f6`, `rumiai-tests@ab331c94371c7146eb2feeab8d1036f0c4ad13fd` and `pkg-catalog@8407f2308cf0c5e7bdc3abd8aeb9538410e55b90`.
- The later `rumiai-tests@10fdd6ef63d5501da6d20387df0737576d9388fc` correction removed the same stale pre-install status pattern from the Electron macOS launch test. That host-specific test was not executed on macOS in this work unit.
- A final scan of the current external suite found no remaining `if run_pkg versions` stale-status pattern.
- `pkg-install.lib.sh` public/internal visibility and operational manual consistency were checked. The `install-$$` correction is internal-only; the existing `pkg-install.lib.sh` and `pkg` manual topics remain accurate.
- The temporary validation pull request was closed without merge after the final matrix completed.

## Current state

The `pkg install` catalog-matrix task is complete. Every current catalog package has successful real Linux x86_64 composed-path installation evidence for the package properties selected by this task. There is no known package-level blocker remaining in this scope.

## Next action

None.

## Blockers / open questions

None.
