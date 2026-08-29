# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 40 physically validated; Phase 1F / CLI test block next**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Validated product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

No product code was changed while building the permanent tests described here.

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

Validated coverage now includes:

- Phase 0 absolute, relative, PATH and symlink invocation;
- physical/canonical `RumiAI_BOOTSTRAP_BIN` and `RumiAI_ROOT`;
- CWD independence;
- Phase-0 PATH-resolution and circular-symlink/realpath failures;
- semantic roots and `PATH` prepend;
- locale language selection and language fallback;
- text-encoding default, normalization and fallback;
- isolated bootstrap preference files;
- structural validation of preference files;
- bootstrap preference data-not-code behavior;
- missing and failing-source `i18n.lib` load boundaries with status 5 and raw fatal token;
- missing and failing-source `log.lib` load boundaries with status 6 and raw fatal token;
- direct i18n selected-language -> `en_US` -> stable identifier resolution order;
- direct i18n catalog data-not-code behavior;
- invalid/multiline catalog fallback;
- logger severity threshold filtering;
- invalid severity status 12;
- invalid structured-field status 15;
- invalid log-level status 16;
- logger escaping of backslash, quote, tab and newline while preserving one physical line.

The existing runner, setup-dev and reference-library groups remained green in the same complete-suite runs.

## Canonical level-2 test-authoring references

### Interactive TTY automation

```text
massimilianonardi-ai/rumiai-tests@7eed87d7cba441d248ae68de82762b73b2320f77:lib/interactive.lib
```

Physically validated on macOS and Ubuntu ARM64.

### Target discovery

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

Physically validated on both stable hosts.

### Isolated RumiAI OS fixture

```text
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

Physically validated on both stable hosts. It copies runtime material into a temporary root and creates a fresh empty:

```text
conf/bootstrap/
```

so tests can mutate configuration and runtime files without touching the real product checkout.

## Next block — Phase 1F / CLI

The next permanent-test block should follow the accepted command-interpreter architecture and normative command-entry specification.

Primary contracts to exercise separately:

```text
explicit readable source without shebang/executable bit
canonical RumiAI_COMMAND_BIN
source operand removed from positional arguments
command/source return status propagation
explicit symlink source canonicalization
source resolution failure -> status 8 + structured logger event
invalid/non-readable/non-regular source -> status 9 + structured logger event
self-entry rejection -> status 9
host-profile direct #!/usr/bin/env rumiai-os execution
PATH-selected active runtime semantics
no-argument shell load/default/fallback behavior
```

Direct executable command behavior is an explicit RumiAI host-profile extension and must be physically exercised on each stable host; it must not be inferred merely from explicit `rumiai-os file` tests.

The shell branch must remain separate from explicit source execution so failures identify whether the regression belongs to command interpretation or no-argument interactive-shell startup.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
