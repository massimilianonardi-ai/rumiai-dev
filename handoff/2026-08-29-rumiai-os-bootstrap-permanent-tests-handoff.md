# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 40 validated; Phase 1F exposed realpath portability bug; product fix awaiting cross-host validation**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Last fully validated product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

Current candidate product commit:

```text
01db051c8bcaac840ce1eda9a9f5339ef1198388
```

The candidate changes both bootstrap-binary and command-entry canonicalization from unspecified default `realpath` semantics to explicit `realpath -e`, requiring the resolved pathname to exist.

## Canonical physical invocation

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test
```

All setup, fixtures, mutations, host-specific automation, assertions and cleanup belong inside autonomous `.test` files.

## Physically validated baseline — PASS 40

The complete suite at:

```text
9b0c5a6d42b3f8e07d372862f11907a76441d532
```

against product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

was physically executed on both stable hosts:

- macOS;
- Ubuntu 26.04 ARM64.

Both produced:

```text
PASS   40
FAIL   0
SKIP   0
ERROR  0
TOTAL  40
```

Validated coverage includes Phase 0, bootstrap semantic roots, bootstrap language/encoding preferences, isolated fixtures, i18n/logger bootstrap load boundaries, direct i18n resolution/data behavior, and direct logger filtering/validation/escaping behavior. Existing runner, setup-dev and reference-library groups remained green.

## Canonical level-2 test-authoring references

### Interactive TTY automation

```text
massimilianonardi-ai/rumiai-tests@7eed87d7cba441d248ae68de82762b73b2320f77:lib/interactive.lib
```

### Target discovery

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

### Isolated RumiAI OS fixture

```text
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

All three immutable references above have passed their physical validation gates on macOS and Ubuntu ARM64.

## Phase 1F / CLI suite

Current `rumiai-tests/main`:

```text
c259b2805377bb33d9bb70c9758d6af60a27a9e2
```

### Explicit source / command interpreter

```text
tests/rumiai-os/command/explicit-source-readable.test
tests/rumiai-os/command/command-bin-canonical.test
tests/rumiai-os/command/argument-shift.test
tests/rumiai-os/command/status-propagation.test
tests/rumiai-os/command/resolution-failure.test
tests/rumiai-os/command/invalid-directory-entry.test
tests/rumiai-os/command/self-entry-rejection.test
```

Contracts:

- a readable regular source explicitly passed to `rumiai-os` requires neither shebang nor executable bit;
- `RumiAI_COMMAND_BIN` is the physical/canonical source pathname;
- the source operand is removed before the body observes `$@`;
- source return status is propagated by `rumiai-os`;
- source resolution failure produces status 8 and `bootstrap.command-entry-resolution-failed`;
- a resolved non-regular entry produces status 9 and `bootstrap.invalid-command-entry`;
- `rumiai-os` refuses to source itself and returns status 9.

### Direct executable host-profile behavior

```text
tests/rumiai-os/command/direct-shebang-execution.test
tests/rumiai-os/command/active-runtime-selection.test
tests/rumiai-os/command/direct-symlink-alias.test
```

Coverage includes executable `#!/usr/bin/env rumiai-os` files, argument forwarding, physical `RumiAI_COMMAND_BIN`, renamed symlink aliases, and active runtime selection through inherited `PATH`.

### Initial no-argument shell branch

```text
tests/rumiai-os/shell/load-missing.test
tests/rumiai-os/shell/bash-selection.test
tests/rumiai-os/shell/default-config-invalid.test
```

The bash-launch tests use a controlled fake `bash` inside the isolated environment and do not open an operator-controlled interactive session.

## Physical result at c259b280 / product 4d1250b0

macOS:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

Ubuntu 26.04 ARM64:

```text
PASS   52
FAIL   1
SKIP   0
ERROR  0
TOTAL  53
```

The only Linux failure was:

```text
rumiai-os/command/resolution-failure.test
```

All other Phase 1F, direct-execution host-profile, shell, bootstrap, i18n, logger, runner and authoring-reference tests passed.

## realpath portability defect

The failing test deliberately supplies a nonexistent command pathname and requires command-entry resolution failure status 8.

The product used:

```sh
realpath -- "$path"
```

without selecting existence semantics.

POSIX.1-2024 defines both `realpath -e` and `realpath -E` and explicitly states that when neither is supplied implementation behavior may differ; portable applications should always specify one. GNU `realpath` accepts a missing final pathname component by default, so Ubuntu canonicalized the nonexistent command and then classified it as invalid entry status 9. The macOS implementation failed canonicalization and produced status 8.

RumiAI requires the command source to exist. The product fix therefore uses explicit:

```sh
realpath -e -- "$path"
```

for both bootstrap-binary and command-entry canonicalization.

Candidate product fix:

```text
01db051c8bcaac840ce1eda9a9f5339ef1198388
Require existing paths during canonicalization
```

The existing regression test is intentionally unchanged. The next complete physical run must validate the candidate product against the same `c259b280...` test suite on both stable hosts.

Expected result:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

Only after that result should the Phase 1F block and the explicit `realpath -e` portability rule be marked physically validated.

## Next block after PASS 53

Complete the actual `sh` interactive fallback and unsupported-shell behavior using the already validated interactive TTY reference rather than ad-hoc operator commands.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
