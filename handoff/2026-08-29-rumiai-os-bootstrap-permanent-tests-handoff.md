# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 40 physically validated; PASS 53 Phase 1F/CLI validation prepared**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Validated/current product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

No product code was changed while building these permanent tests.

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

## Prepared Phase 1F / CLI block — expected PASS 53

Current `rumiai-tests/main`:

```text
c259b2805377bb33d9bb70c9758d6af60a27a9e2
```

This commit is a direct forward-only child of the physically validated `PASS 40` suite commit.

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

These tests exercise the explicit host-profile extension rather than inferring it from explicit-source behavior:

- executable `#!/usr/bin/env rumiai-os` command files;
- command-file pathname forwarding through `/usr/bin/env`;
- command arguments under direct execution;
- physical `RumiAI_COMMAND_BIN` for direct execution;
- renamed symlink aliases canonicalizing to the implementation file;
- active runtime selected by inherited `PATH`, even when the command file physically belongs to another isolated RumiAI root.

These properties must pass independently on each stable host before host-profile support is considered physically validated.

### Initial no-argument shell branch

```text
tests/rumiai-os/shell/load-missing.test
tests/rumiai-os/shell/bash-selection.test
tests/rumiai-os/shell/default-config-invalid.test
```

Contracts:

- missing `shell.lib` after logger activation -> status 7 + `shell.load-failed` event;
- default `bash` selection invokes bash with `--noprofile --rcfile <RumiAI bashrc> -i` and `BASH_SILENCE_DEPRECATION_WARNING=1`;
- structurally invalid `conf/shell/default` emits `shell.default-config-invalid` and falls back to bash.

The bash-launch tests use a controlled fake `bash` inside the isolated test environment, so they validate selection/arguments/environment without opening an operator-controlled interactive session.

The remaining actual `sh` interactive fallback/unsupported-shell path should be implemented only after this block is physically green, using the already validated interactive TTY reference rather than ad-hoc terminal commands.

All 13 new `.test` files were authored against the accepted Phase 1 / command-entry specifications, checked with `sh -n` and `dash -n` before publication, and committed with executable Git mode.

The next complete physical run should therefore contain:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

on both stable hosts before this block is declared validated.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
