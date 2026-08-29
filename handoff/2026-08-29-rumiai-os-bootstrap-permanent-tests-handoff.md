# Handoff — RumiAI OS permanent bootstrap tests

Date: 2026-08-29
Status: **physical validation progressing through i18n/logger load paths**

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

Canonical physical invocation remains:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test
```

All fixtures, target discovery, temporary roots, environment isolation, assertions and cleanup live inside `.test` files.

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

Validated bootstrap coverage now includes:

- absolute invocation;
- relative invocation;
- invocation through `PATH`;
- invocation through a symlink;
- physical/canonical `RumiAI_BOOTSTRAP_BIN` and `RumiAI_ROOT`;
- CWD independence;
- Phase-0 PATH resolution failure and status 1;
- Phase-0 circular-symlink/realpath failure and status 2;
- absence of premature Phase-0 output beyond the expected fatal token;
- semantic roots `RumiAI_BIN_DIR`, `RumiAI_LIB_DIR`, `RumiAI_CONF_DIR`, `RumiAI_LANG_DIR`;
- prepend of `RumiAI_BIN_DIR` to `PATH`;
- locale language selection `it_IT.UTF-8 -> it_IT`;
- unsupported-language fallback to `en_US` and warning event;
- default `RumiAI_TEXT_ENCODING=UTF-8`;
- language preference precedence over locale environment;
- structurally invalid language preference and warning event;
- proof that bootstrap preference contents are data and are not sourced as shell code;
- text-encoding normalization `utf8 -> UTF-8`;
- structurally invalid text-encoding preference and warning event;
- unsupported text-encoding fallback and structured warning fields.

The runner, setup-dev and reference-library tests also remained green in the same complete-suite runs.

## Canonical level-2 test-authoring references

### Target discovery

```text
massimilianonardi-ai/rumiai-tests@5af68cbff09ce979df3dff91e398e287eadd48b7:lib/rumiai-os-target.lib
```

Physically validated on both stable hosts. Pattern documentation:

```text
patterns/rumiai-os-target-discovery.md
```

### Isolated RumiAI OS fixture

```text
massimilianonardi-ai/rumiai-tests@251ec2bde45a197590ec7dc23b8b41e60a79543f:lib/rumiai-os-fixture.lib
```

The fixture self-test and all six first preference tests passed in the complete `PASS 28` run on both stable hosts. This closes its validation gate and makes this immutable version the canonical level-2 source for new inline fixture copies until superseded by a separately validated version.

The fixture copies product runtime material into a temporary root while creating a fresh empty:

```text
conf/bootstrap/
```

so tests can mutate configuration and runtime files without modifying the real `rumiai-os` checkout.

## Current next block — i18n/logger load paths

The next permanent tests exercise bootstrap failure boundaries around Phase 1C and Phase 1D using isolated fixtures.

Planned cases are kept behavior-specific:

```text
i18n library missing          -> status 5 + raw fatal token
i18n library source failure   -> status 5 + raw fatal token
log library missing           -> status 6 + raw fatal token
log library source failure    -> status 6 + raw fatal token
```

The distinction matters because the normal logger is not active until after `log.lib` has loaded successfully. These failures therefore belong to the bootstrap's pre-logger fatal path and must not be converted into ordinary structured log events merely for test convenience.

After these load boundaries are validated, the next logical group is direct `i18n.lib` and `log.lib` behavior under `tests/rumiai-os/i18n/` and `tests/rumiai-os/log/`.

## Forward-only rule

All repository updates remain forward-only. Existing physical evidence and historical test provenance must not be rewritten when later defects are discovered; affected copies are identified by immutable provenance commit and updated deliberately in new commits.
