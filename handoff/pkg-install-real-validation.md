# pkg install real validation

Status: Active
Updated: 2026-09-18

## Goal

Rebuild `pkg install` from authentic execution and retain only validation evidence that traverses the real public command and composed package pipeline.

## Current repository revisions

```text
rumiai-dev   189d870eb247fbc5625e37dcf2cc955209e8fc87
rumiai-os    0376b12d54d5df02a7c391db6abf5583ce392978
rumiai-tests bd333e6c8b5c4cc0555de06498e3b17394b18d8a
pkg-catalog  dd96a82e9022fb7c6f926d2b4b81f4718e824bb6
```

Refresh all remote HEADs before continuing.

## Fixed task-local choices

- Target-specific catalog streams use `<package>/<os>-<arch>`, without the old `catalog-` prefix.
- A behavioral `pkg install` test must execute the real public command and real composed package pipeline.
- The isolated Debian host may replay captured real upstream HTTPS responses only at the external network boundary; the reusable mechanism is documented in `TEST-PATTERNS.md`.
- Functional debugging takes priority over deferred CLI-policy questions while the install path is being made operational.
- Mixed valid/invalid operand semantics remain unresolved.
- Reinstall/already-installed semantics remain unresolved.
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

## Confirmed bootstrap command-resolution bug

Physical invocation from `$m_ROOT`:

```text
./m pkg install jq
```

fails after `$m_ROOT/pkg` exists because the root bootstrap's `readpathce` overloads pathname canonicalization and slashless command lookup.

For a slashless argument, current logic is effectively:

```text
if an object named ./<name> exists in caller CWD
    resolve that object
else
    resolve <name> through PATH
```

Therefore, from `$m_ROOT`:

```text
command operand: pkg
CWD object:      $m_ROOT/pkg/          (package store directory)
PATH command:    $m_ROOT/bin/sys/pkg   (real command)
```

The CWD directory wins before PATH lookup. `readpathce` canonicalizes it successfully; only afterward the bootstrap requires the resolved command to be a readable regular file and rejects the directory:

```text
filesystem.path-invalid
command-original="pkg"
command-resolved="$m_ROOT/pkg"
```

This happens before `bin/sys/pkg` or any package library runs.

The bug is semantic: slashless command resolution allows any existing CWD object to shadow a command. The bootstrap should distinguish explicit pathname resolution from command-name resolution instead of using existence in CWD as command precedence. No product fix has yet been applied to `m`.

Temporary diagnostic bypass only:

```text
./m bin/sys/pkg install jq
```

Do not treat this bypass as the product fix.

## Other confirmed/open behaviors

### Reinstall

Repeating installation of the same concrete version reaches `pkg_integrate()` and fails when the concrete pathname already exists. Desired reinstall semantics remain undecided.

### Mixed valid/invalid operands

Desired behavior remains explicitly undecided. Do not reintroduce a simplistic all-or-nothing rule without resolving the user-facing behavior.

### Adjacent existing test failures

During broader selected regression execution, current tests exposed:
- `tests/rumiai-os/pkg/dependency.test`: provider remained blocked after consumer removal.
- `tests/rumiai-os/pkg/uninstall.test`: unversioned current uninstall failed.

These failures occur outside the live jq install criterion and have not yet been attributed to the entrypoint/install-binding changes. They require separate tracing before any conclusion or fix.

## Next action

1. Decide and fix the root-bootstrap slashless command-resolution bug in `readpathce` / command resolution without breaking legitimate explicit-path and bootstrap-root semantics.
2. Reproduce and trace the current dependency/uninstall failures separately.
3. Later resolve reinstall behavior and mixed valid/invalid operand policy.
4. After functional behavior stabilizes, realign any remaining manual/API documentation required by the library-interface/documentation contracts.
