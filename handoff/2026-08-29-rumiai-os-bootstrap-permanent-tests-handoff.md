# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 53 physically validated; interactive sh fallback validation prepared**

## Repositories

Product:

```text
massimilianonardi-ai/rumiai-os
```

Tests:

```text
massimilianonardi-ai/rumiai-tests
```

Canonical physical invocation remains:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test
```

All setup, fixtures, host-specific automation, assertions and cleanup belong inside autonomous `.test` files.

## Current physically validated baseline — PASS 53

Product:

```text
8698504f715ed61cec8a31b46ded5b79f3924eb5
Separate pathname validation from canonicalization
```

Suite:

```text
c259b2805377bb33d9bb70c9758d6af60a27a9e2
Add Phase 1F command and shell tests
```

Both stable hosts were physically exercised against that exact pair:

- macOS;
- Ubuntu 26.04 ARM64.

Both produced:

```text
PASS   53
FAIL   0
SKIP   0
ERROR  0
TOTAL  53
```

This closes the Phase 1F command-interpreter and initial shell gate, including direct `#!/usr/bin/env rumiai-os` host-profile behavior.

## Path canonicalization portability history

### Defect discovered

With product `4d1250b0...` and suite `c259b280...`, macOS produced PASS 53 while Ubuntu produced PASS 52 / FAIL 1. The only failure was:

```text
rumiai-os/command/resolution-failure.test
```

The product was passing an unchecked nonexistent pathname to optionless `realpath`. GNU/Linux accepted the missing final component and later classified the entry as invalid (status 9); macOS rejected the path during canonicalization (status 8).

### Rejected attempted fix

Commit:

```text
01db051c8bcaac840ce1eda9a9f5339ef1198388
Require existing paths during canonicalization
```

changed the product to `realpath -e`. This is permanently rejected because the reference macOS `/bin/realpath` physically rejects `-e`.

Observed against suite `c259b280...`:

```text
macOS:              PASS 19 / FAIL 34
Ubuntu 26.04 ARM64: PASS 53 / FAIL 0
```

This failed result is historical evidence and MUST NOT be rewritten or presented as a viable portability solution.

### Stable accepted rule

RumiAI now separates validation from canonicalization:

```text
VALIDATE EXISTENCE
        ↓
CANONICALIZE EXISTING PATH
        ↓
VALIDATE REQUIRED TYPE
```

`realpath` is never used to decide whether an unchecked pathname exists.

The product primitive:

```text
RumiAI_path_canonicalize_existing
```

requires existence first with `test -e`, calls only:

```sh
command -p -- realpath -- "$pathname"
```

on that already-existing pathname, then verifies an absolute still-existing result. Callers separately enforce regular-file/readability requirements.

The same primitive is used for both:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND_BIN
```

Normative specification commit:

```text
1bc4b4f204a2448f0bac229146aac6afe94e0ca0
Separate pathname validation from realpath semantics
```

The specification explicitly supersedes both earlier incorrect shortcuts:

1. requiring `realpath -e` merely because POSIX Issue 8 defines it;
2. passing an unchecked pathname to optionless `realpath` and validating only afterwards.

The unchanged regression `rumiai-os/command/resolution-failure.test` now passes on both hosts and permanently protects the missing-source status-8 contract.

## Canonical level-2 authoring references

```text
interactive TTY:
massimilianonardi-ai/rumiai-tests@7eed87d7cba441d248ae68de82762b73b2320f77:lib/interactive.lib

target discovery:
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib

isolated RumiAI OS fixture:
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

All three references are physically validated on macOS and Ubuntu ARM64.

## Prepared interactive shell block — expected PASS 56

Current `rumiai-tests/main`:

```text
c15cb2aaaaa0a7d209f6437f529b22840e4f1b98
Add interactive sh fallback tests
```

New permanent tests:

```text
tests/rumiai-os/shell/sh-selection.test
tests/rumiai-os/shell/bash-fallback-to-sh.test
tests/rumiai-os/shell/unsupported-fallback-to-sh.test
```

They copy the already validated interactive TTY primitive inline with immutable provenance and drive a real host `sh -i` through a PTY. No operator interaction is required.

Contracts:

- explicit `conf/shell/default = sh` enters the RumiAI sh branch and exposes the RumiAI prompt without a fallback warning;
- requested `bash` with `bash` deliberately absent from inherited `PATH` emits `shell.fallback`, selects `sh`, reaches the RumiAI prompt and exits autonomously;
- a structurally valid but unsupported shell value (`zsh`) emits `shell.unsupported`, selects `sh`, reaches the RumiAI prompt and exits autonomously.

The bash-fallback test restricts only the child wrapper's inherited `PATH`; product calls that intentionally use `command -p` continue to resolve through the implementation-provided standard utility path. This specifically tests the documented distinction between caller-PATH shell preference lookup and standard-path `sh` fallback.

The next complete physical run should contain:

```text
PASS   56
FAIL   0
SKIP   0
ERROR  0
TOTAL  56
```

on both stable hosts before this shell block is declared validated.

## Forward-only rule

All repository updates remain forward-only. Rejected commits and failed physical results remain part of the historical evidence; they are corrected only by later commits, never rewritten.
