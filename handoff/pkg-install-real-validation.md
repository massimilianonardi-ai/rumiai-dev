# pkg install real validation

Status: Active
Updated: 2026-09-18

## Goal

Rebuild `pkg install` from authentic execution and retain only validation evidence that traverses the real public command and composed package pipeline.

## Current repository revisions

```text
rumiai-dev   3b3be78224514b7cba876a4a98e2829df1e3cddc
rumiai-os    01a3f40b2a9d5d253b1f0b1ceaaa45c4f60e6345
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
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
```

## Fixed task-local choices

- Target-specific catalog streams use `<package>/<os>-<arch>`, without the old `catalog-` prefix.
- A `pkg install` behavioral test must execute the real public command and real package pipeline.
- The isolated Debian host may replay captured real upstream HTTPS responses only at the external network boundary; the reusable mechanism is documented in `TEST-PATTERNS.md`.

## Completed

- `pkg-catalog@dd96a82e...` removed the `catalog-` prefix from target stream directories.
- The package stream selector was realigned to the new catalog layout.
- The Debian auxiliary-host bridge was proven using GitHub Actions capture/transfer plus local HTTPS replay with temporary `/etc/hosts` and CA trust.
- The bridge pattern is now documented canonically in `TEST-PATTERNS.md`.
- Earlier package-install tests that did not provide trustworthy composed-path evidence were replaced with a real `pkg install` live test.
- Before the current user reimplementation, the rebuilt live test had passed against committed product/test revisions.

## Current state

The user is actively reimplementing/debugging `pkg install` and asked for analysis only; do not modify the current product code unless explicitly requested.

Current `rumiai-os@01a3f40b...` has deterministic regressions:

1. `bin/sys/pkg` sources `pkg-${pkg_command}.lib.sh` and then executes `pkg-${pkg_command}`. The current libraries expose shell functions `pkg_install`, `pkg_uninstall`, `pkg_versions`, and `pkg_default_command`; there is no `pkg-install`/etc. command. Therefore the dispatcher cannot invoke the sourced implementation. The latest commit changed the attempted call from `install` to `pkg-install`, but neither matches `pkg_install`.
2. Bare `pkg` now calls `fatal` without a numeric status. Under the current `fatal()` contract this defaults to exit status 1, while the current `pkg` manual specifies status 2 for invalid command/subcommand usage.
3. `pkg_install()` now creates `$m_PKG_DIR`, package temporary state and a catalog snapshot before validating package operands. This contradicts the current command/library manuals and the permanent regression property that all operands are syntax-validated before installation side effects. On an offline/failed catalog path, an invalid operand can fail as an installation/catalog error before it is ever parsed.
4. Because of item 3, `res/sys/manual/pkg` and `res/sys/manual/pkg-install.lib.sh` currently disagree with implementation.

The dispatcher issue affects all current `pkg` subcommands, not only install. A generic transformation such as `pkg_${pkg_command}` would still not cover `default`, whose command-level entry function is `pkg_default_command`; any simplification must respect the actual public library interfaces rather than infer them from filenames.

## Next action

Wait for or inspect the user's next committed `pkg` revision, then refresh HEADs and re-analyse the exact committed implementation before running any validation.

## Blockers / open questions

- Product code is intentionally left untouched while the user is debugging it.
- Current `rumiai-tests` evidence predates `rumiai-os@01a3f40b...` and must not be attributed to this reimplementation until rerun against the exact new revision.
