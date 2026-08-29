# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **physical validation progressing through bootstrap preferences**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current product commit:

```text
4d1250b02a25050ff60da2b9818519026523d6b0
```

No product code was changed while building the permanent bootstrap tests described here.

## Permanent test suite

Repository:

```text
massimilianonardi-ai/rumiai-tests
```

The suite is invoked physically using only the canonical operator workflow:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test
```

All fixtures, target discovery, temporary roots, environment isolation, assertions and cleanup live inside `.test` files.

## Physically validated baseline — PASS 21

The complete suite at:

```text
4f5eaa513dd8d6df16f4815193fc1f268c9ea38b
```

was physically executed on both stable hosts:

- macOS;
- Ubuntu 26.04 ARM64.

Both produced:

```text
PASS   21
FAIL   0
SKIP   0
ERROR  0
TOTAL  21
```

The validated bootstrap coverage includes:

- absolute invocation;
- relative invocation;
- invocation through `PATH`;
- invocation through a symlink;
- physical/canonical `RumiAI_BOOTSTRAP_BIN`;
- physical/canonical `RumiAI_ROOT`;
- CWD independence;
- Phase-0 PATH resolution failure and status 1;
- Phase-0 circular-symlink/realpath failure and status 2;
- absence of premature Phase-0 output beyond the expected fatal token;
- semantic roots `RumiAI_BIN_DIR`, `RumiAI_LIB_DIR`, `RumiAI_CONF_DIR`, `RumiAI_LANG_DIR`;
- prepend of `RumiAI_BIN_DIR` to `PATH`;
- locale language selection `it_IT.UTF-8 -> it_IT`;
- unsupported-language fallback to `en_US` and warning event;
- default `RumiAI_TEXT_ENCODING=UTF-8`.

The existing runner, setup-dev and reference-library tests also remained green in the same complete-suite run.

## Validated test-authoring reference

The target-discovery primitive:

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

is physically validated on both stable hosts and is the current canonical level-2 source for inline target-discovery copies.

The corresponding pattern is documented in:

```text
patterns/rumiai-os-target-discovery.md
```

## Current next block — isolated bootstrap preferences

A new level-2 candidate reference has been extracted:

```text
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

Its purpose is to materialize an isolated runnable RumiAI OS root by copying product runtime material while creating a fresh empty:

```text
conf/bootstrap/
```

This permits preference tests without modifying the real product working tree.

The candidate remains **not yet physically validated** until its self-test passes on both stable hosts.

Current `rumiai-tests/main` preparing that validation:

```text
07a9a6a1fb3918c1763e8ce3ffe4982d9c369d22
```

New tests in this block:

```text
tests/rumiai-tests/lib/rumiai-os-fixture-reference.test
tests/rumiai-os/bootstrap/language-config-precedence.test
tests/rumiai-os/bootstrap/language-config-invalid.test
tests/rumiai-os/bootstrap/language-config-data-not-code.test
tests/rumiai-os/bootstrap/text-encoding-config-normalization.test
tests/rumiai-os/bootstrap/text-encoding-config-invalid.test
tests/rumiai-os/bootstrap/text-encoding-fallback.test
```

They cover:

- bootstrap language preference precedence over locale environment;
- structurally invalid language preference and warning event;
- proof that preference contents are data and are not sourced as shell code;
- text-encoding normalization `utf8 -> UTF-8`;
- structurally invalid text-encoding preference and warning event;
- unsupported text-encoding fallback and structured warning fields;
- isolated fixture construction itself.

The expected complete-suite size after this block is 28 tests.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
