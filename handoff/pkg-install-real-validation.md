# pkg install real validation

Status: Active
Updated: 2026-09-18

## Goal

Rebuild `pkg install` from authentic execution and retain only validation evidence that traverses the real public command and composed package pipeline.

## Current repository revisions

```text
rumiai-dev   cec2ec355a87811b57a960f614a5b65e06bed69e
rumiai-os    eae5a7203fab8676e5914f073c2ab9e0c124dddf
rumiai-tests d2c487ecdfb672ac7343019098fda98381f5cf82
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

These SHAs are task state only; refresh remote HEADs before further work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

## Fixed task-local choices

- Target-specific catalog streams use `<package>/<os>-<arch>`, without the old `catalog-` prefix.
- A `pkg install` behavioral test must execute the real public command and real package pipeline.
- The isolated Debian host may replay captured real upstream HTTPS responses only at the external network boundary; the reusable mechanism is documented in `TEST-PATTERNS.md`.
- During the current debugging phase, functional defects in the install path take priority. Exit-status policy, manuals/contracts and the mixed-valid/invalid operand policy are intentionally deferred until the command works.
- The correct behavior for a batch containing both valid and invalid operands is unresolved and must not be inferred from the current implementation.
- The correct behavior when the requested concrete package is already installed is also unresolved.

## Completed

- `pkg-catalog@dd96a82e...` removed the `catalog-` prefix from target stream directories.
- The package stream selector was realigned to the new catalog layout.
- The Debian auxiliary-host bridge was proven using GitHub Actions capture/transfer plus local HTTPS replay with temporary `/etc/hosts` and CA trust.
- The bridge pattern is documented in `TEST-PATTERNS.md`.
- Earlier package-install tests that did not provide trustworthy composed-path evidence were replaced with a real `pkg install` live test.
- The user corrected the dispatcher typo from `pkg-${pkg_command}` to `pkg_${pkg_command}` for the current install path.
- Diagnostic execution against exact `rumiai-os@eae5a720...` on a clean GitHub-hosted Ubuntu replica with live Internet proved:
  - `pkg install jq@jq-1.8.2` on a clean store returns 0;
  - `pkg install jq` on a separate clean store returns 0;
  - the clean pinned path resolves the real catalog/repository data, downloads the official 2,267,912-byte jq asset, verifies SHA-256 `b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f`, extracts and integrates successfully;
  - repeating `pkg install jq@jq-1.8.2` on the same store returns 1.
- The repeated-install failure was traced exactly: `_pkg_install_one()` reaches `pkg_integrate()`, which computes `$m_PKG_DIR/jq@jq-1.8.2!linux-x86_64`; because that concrete path already exists, the guard `[ ! -e "$pkg_integration_concrete" ] && [ ! -L "$pkg_integration_concrete" ] || return 1` rejects the reinstall.

## Current state

The user is actively reimplementing/debugging `pkg install` and asked for analysis/debugging only; do not modify product main unless explicitly requested.

For exact current revision `eae5a720...`, `_pkg_install_one()` is proven to complete successfully for both clean pinned and clean unpinned jq installation. Therefore a failure observed locally is not evidence that the generic clean `_pkg_install_one` path is broken.

A confirmed state-dependent failure exists for reinstalling the same concrete version. That failure is inside `pkg_integrate()`, not version resolution/download/extraction: the pre-existing concrete package directory is rejected immediately.

Temporary diagnostic workflows exist only on branch `tmp/pkg-install-vm-transfer-20260917`; product `main` was not changed by the assistant.

## Next action

If the user's observed failure is a repeated install of an already present concrete package, decide later what reinstall semantics should be and then implement that choice. If the user's observed failure occurs on a genuinely clean store, reproduce that exact package/host/invocation and trace its first non-zero operation, because the clean jq path is already known to pass.

## Blockers / open questions

- Mixed valid/invalid operand batch behavior is intentionally unresolved.
- Already-installed/reinstall behavior is intentionally unresolved.
- Product code remains under active user debugging.

## Newly confirmed bootstrap collision

A separate failure was reproduced from the user's real invocation form:

```text
./m pkg install jq
```

When the caller CWD is `$m_ROOT` and `$m_ROOT/pkg` already exists, the bootstrap's current `readpathce` resolution checks `./$1` before PATH for an operand without `/`. Therefore command operand `pkg` resolves to the package-store directory `$m_ROOT/pkg` instead of `$m_BIN_SYS_DIR/pkg`.

The subsequent bootstrap validation rejects that directory because `m_COMMAND_BIN` must be a readable regular file, producing:

```text
filesystem.path-invalid
command-original="pkg"
command-resolved="$m_ROOT/pkg"
```

This happens before `bin/sys/pkg`, `pkg_install()` or `_pkg_install_one()` is entered.

Important consequence: a first install can succeed on a clean tree, create `$m_ROOT/pkg`, and make subsequent `./m pkg ...` invocations from `$m_ROOT` fail at bootstrap command resolution. This is distinct from the already-confirmed reinstall rejection inside `pkg_integrate()`.

Temporary debugging bypasses that preserve the package implementation are:

```text
./m bin/sys/pkg install jq
```

or invoking `m pkg ...` from a CWD that does not contain an object named `pkg`.

Do not treat either bypass as the product fix. The bootstrap command-resolution behavior must be repaired deliberately so a non-command CWD object cannot shadow an integrated command.
