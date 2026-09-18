# pkg install real validation

Status: Active
Updated: 2026-09-18

## Goal

Rebuild `pkg install` from authentic execution and retain only validation evidence that traverses the real public command and composed package pipeline.

## Current repository revisions

```text
rumiai-dev   2c59983c3b2f4f9f9fecad26b579d37fae23da21
rumiai-os    5e47a3f0a242a57f8431fece2357532c19342cd9
rumiai-tests 13867b6e82b33b16c0316f844be77419354815fa
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

Refresh all remote HEADs before continuing.

## Fixed task-local choices

- Target-specific catalog streams use `<package>/<os>-<arch>`, without the old `catalog-` prefix.
- A behavioral `pkg install` test must execute the real public command and real composed package pipeline.
- The isolated Debian host may replay captured real upstream HTTPS responses only at the external network boundary; the reusable mechanism is documented in `TEST-PATTERNS.md`.
- Functional debugging takes priority over deferred CLI-policy questions while the install path is being made operational.
- The `pkg` dispatcher remains generic. For every public subcommand `<name>`, `lib/sys/sh/pkg-<name>.lib.sh` exposes `pkg_<name>`. This is now canonical in `PACKAGE-MODEL.md`.
- A live install test is not successful merely because a concrete package exists. For jq it must establish the public binding and successfully execute jq through the normal `m` command path.

## Completed

- `pkg-catalog@dd96a82e...` removed the obsolete `catalog-` target-stream prefix.
- Package stream selection was realigned to the new catalog layout.
- The Debian network-boundary workaround was proven and documented in `TEST-PATTERNS.md`.
- The previous false-positive package-install tests were replaced by a real live jq install test.
- The command-entrypoint convention was standardized without modifying `bin/sys/pkg`:
  - command-level `pkg_default_command` was renamed to `pkg_default`;
  - the lower-level binding operation formerly named `pkg_default` was renamed to `pkg_default_apply`;
  - callers/tests were realigned;
  - stale `pkg_default_command` references are absent from current `rumiai-os` and `rumiai-tests` searches.
- `pkg install` now completes integration after concrete materialization by invoking `pkg_default_apply` directly with the already-resolved package/version/osarch. It does not re-enter the CLI parser.
- Current live test `tests/rumiai-os/pkg/install-live.test`:
  - builds a complete isolated target replica;
  - initializes normal osarch selectors;
  - executes `m pkg install jq@jq-1.8.2`;
  - verifies the concrete package and internal command/link;
  - verifies `pkg/jq!<osarch>` selector;
  - verifies `bin/ext-<osarch>/jq` public binding;
  - finally executes `m jq --version` and requires `jq-1.8.2`.
- GitHub Actions run `35323394218` against exact `rumiai-os@0376b12d...` and `rumiai-tests@bd333e6c...` completed successfully. Evidence:
  ```text
  installed=jq@jq-1.8.2!linux-x86_64
  catalog-head=dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
  jq=jq-1.8.2
  ```

## Bootstrap command-resolution collision — resolved

The previously confirmed collision between slashless command names and same-named CWD objects has been corrected in current `rumiai-os@9e7a67c...`.

Current `readpathce()` behavior in both the root bootstrap and `core.lib.sh` is:

```text
operand contains "/"
    treat it as an explicit pathname

operand contains no "/"
    resolve it through PATH
```

The implicit `./<name>` precedence was removed. Therefore, after `$m_ROOT/pkg/` exists, invoking:

```text
cd "$m_ROOT"
./m pkg ...
```

still resolves `pkg` through the active m command PATH to `$m_ROOT/bin/sys/pkg`; the package-store directory no longer shadows the command.

The current canonical `ENTRYPOINT-ROOT-RESOLUTION.md` was realigned to this behavior.

Permanent regression coverage now includes:
- `tests/rumiai-os/command/command-bin-canonical.test`: a same-named directory in the caller CWD must not shadow a slashless command available in PATH;
- `tests/rumiai-os/pkg/install-live.test`: executes `./m pkg install jq@jq-1.8.2` from the product root, verifies the store/bindings, invokes `./m pkg default jq` again after `./pkg/` exists, and executes `./m jq --version`.

GitHub Actions run `35324867683` against exact `rumiai-os@9e7a67c...` and `rumiai-tests@ad260660...` completed successfully:
- command-resolution regression: PASS;
- live pkg install from product root: PASS;
- `installed=jq@jq-1.8.2!linux-x86_64`;
- `catalog-head=dd96a82e9022fb7c6f926d2b4b81f4718e824bb6`;
- `jq=jq-1.8.2`.

## Other confirmed/open behaviors

### Install batch/already-installed behavior — resolved

The current canonical behavior is defined in `PACKAGE-MODEL.md`:

- `pkg install` is best-effort per operand;
- invalid/unavailable/already-installed operands emit errors but do not prevent later independently installable operands from being attempted;
- a partially successful install batch returns status `1`;
- status `2` remains for a globally invalid invocation;
- an already installed concrete is not reinstalled;
- its diagnostic includes `reason="already-installed"`, `already-installed="<concrete>"` and `current-default="<concrete|empty>"`.

Current `rumiai-os@5e47a3f0...` implements that behavior. `res/sys/manual/pkg` and `res/sys/manual/pkg-install.lib.sh` were updated in the same work unit.

Current `tests/rumiai-os/pkg/install-live.test` validates through the real public command that:
- an invalid-only install returns `1`, reports the bad operand and does not create `$m_PKG_DIR`;
- a normal jq install succeeds and jq executes through `m`;
- reinstalling the same jq concrete returns `1` and reports the installed/current-default identities without damaging the package;
- jq can be uninstalled;
- a mixed `invalid + jq` install returns `1` but still installs, integrates and successfully executes jq.

GitHub Actions run `35328551119` against exact `rumiai-os@5e47a3f0...` and `rumiai-tests@13867b6e...` completed successfully after the final work-path correction.

A broader permanent package regression also passed in run `35328620632` on the same revisions:
- default.test
- dependency.test
- env.test
- facility.test
- install-live.test
- setuid.test
- state.test
- uninstall.test
- versions.test

Live evidence remained:

```text
installed=jq@jq-1.8.2!linux-x86_64
catalog-head=dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
jq=jq-1.8.2
```

### Uninstall/dependency regression — resolved

The two previously observed failures had one shared cause in `pkg-uninstall.lib.sh`: the calls that unset the current/default binding before deintegration had malformed shell quoting after the `pkg_default_apply` rename.

That prevented the current selector from being cleared. `pkg_deintegrate()` then correctly refused to remove a concrete package that was still current. This surfaced both as:
- `uninstall.test`: unversioned current uninstall failed;
- `dependency.test`: provider remained blocked after consumer uninstall.

Current `rumiai-os@75ce970e...` fixes those two calls without changing uninstall semantics.

GitHub Actions run `35325311689` against exact `rumiai-os@75ce970e...` and `rumiai-tests@ad260660...` completed successfully:
- package dependency regression: PASS;
- package uninstall regression: PASS;
- live pkg install + jq execution: PASS;
- `installed=jq@jq-1.8.2!linux-x86_64`;
- `catalog-head=dd96a82e9022fb7c6f926d2b4b81f4718e824bb6`;
- `jq=jq-1.8.2`.

## Next action

1. Re-run the current live install behavior on the isolated Debian VM using the documented external HTTPS replay bridge, against the exact current product/test revisions.
2. If that replay passes without a new product defect, complete and retire this handoff according to the normal handoff lifecycle.
