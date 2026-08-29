# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **PASS 28 validated; PASS 40 validation prepared**

## Product under test

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Current product commit:

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

All setup, fixtures, mutations, assertions and cleanup belong inside autonomous `.test` files.

## Physically validated baseline — PASS 28

The complete suite at:

```text
07a9a6a1fb3918c1763e8ce3ffe4982d9c369d22
```

was physically executed on both stable hosts:

- macOS;
- Ubuntu 26.04 ARM64.

Both produced:

```text
PASS   28
FAIL   0
SKIP   0
ERROR  0
TOTAL  28
```

Validated coverage includes Phase 0 invocation/root resolution/failures, Phase 1 semantic roots and PATH, language/encoding selection and fallback, isolated bootstrap preferences, preference structural validation, and the data-not-code property for bootstrap configuration.

The runner, setup-dev and reference-library groups also remained green.

## Canonical level-2 test-authoring references

### Target discovery

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

Physically validated on both stable hosts.

### Isolated RumiAI OS fixture

```text
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

The fixture self-test and all first preference tests passed in the complete `PASS 28` run on both stable hosts. This immutable version is therefore canonical for new inline copies until superseded by a separately validated version.

The fixture copies runtime material into a temporary root and creates a fresh empty:

```text
conf/bootstrap/
```

so tests can mutate configuration and runtime files without touching the real product checkout.

## Prepared validation block — expected PASS 40

Current `rumiai-tests/main`:

```text
9b0c5a6d42b3f8e07d372862f11907a76441d532
```

### Bootstrap pre-logger load boundaries

```text
tests/rumiai-os/bootstrap/i18n-load-missing.test
tests/rumiai-os/bootstrap/i18n-load-source-failure.test
tests/rumiai-os/bootstrap/log-load-missing.test
tests/rumiai-os/bootstrap/log-load-source-failure.test
```

Expected contracts:

```text
i18n library missing          -> status 5 + RumiAI_BOOTSTRAP_FATAL_I18N_LOAD_ERROR
i18n library source failure   -> status 5 + RumiAI_BOOTSTRAP_FATAL_I18N_LOAD_ERROR
log library missing           -> status 6 + RumiAI_BOOTSTRAP_FATAL_LOG_LOAD_ERROR
log library source failure    -> status 6 + RumiAI_BOOTSTRAP_FATAL_LOG_LOAD_ERROR
```

The raw fatal token is intentional because the normal logger is not active yet.

### Direct i18n behavior

```text
tests/rumiai-os/i18n/resolution-order.test
tests/rumiai-os/i18n/catalog-data-not-code.test
tests/rumiai-os/i18n/invalid-catalog-fallback.test
```

Coverage:

- selected-language catalog -> `en_US` -> stable `domain.message-id`;
- catalog text is data and is never executed as shell code;
- structurally invalid/multiline catalog objects are skipped and resolution continues to the next fallback.

### Direct logger behavior

```text
tests/rumiai-os/log/severity-filter.test
tests/rumiai-os/log/invalid-severity.test
tests/rumiai-os/log/invalid-fields.test
tests/rumiai-os/log/invalid-level.test
tests/rumiai-os/log/field-escaping.test
```

Coverage:

- threshold filtering;
- explicit invalid-severity status 12;
- invalid structured-field status 15;
- invalid log-level status 16;
- escaping of backslash, quote, tab and newline while preserving one physical log line.

All 12 newly added tests were linted with both `sh -n` and `dash -n` before publication. All `.test` files are executable in Git.

The next physical complete-suite run should therefore contain:

```text
PASS   40
FAIL   0
SKIP   0
ERROR  0
TOTAL  40
```

on both stable hosts before this block is declared validated.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
