# RumiAI system bootstrap v0 — physical validation

Date: 2026-08-30

Status: **PASSED on both current stable reference installations**

This document records the physical validation gates completed for the `rumi` bootstrap substrate.

---

# Gate 1 — system configuration and tabular data APIs

## Scope

This validation covers the bootstrap system data API implemented by `rumiai-os/lib/data.lib` and loaded by the `rumiai-os` bootstrap.

Validated public API surface:

```text
rumi_conf_validate
rumi_conf_get
rumi_conf_has
rumi_conf_namespace
rumi_conf_set
rumi_conf_remove

rumi_table_validate
rumi_table_header
rumi_table_rows
rumi_table_column
rumi_table_select
```

Physical test:

```text
rumiai-os/bootstrap/system-data-apis.test
```

Validation options:

```text
--validation
--snapshot=hash
--snapshot-scope=test
--snapshot-root .
```

The filesystem snapshot result was `CLEAN` on both hosts.

## Target revision

```text
massimilianonardi-ai/rumiai-os
ca696b7a0c7027d2b9f4c0989bc0a5ad7b2c75e6
Fix invalid configuration query status
```

## Test revisions

macOS validation:

```text
massimilianonardi-ai/rumiai-tests
11126d666832e338092e001fcd2af0dc7d475ea8
```

Ubuntu validation:

```text
massimilianonardi-ai/rumiai-tests
7324ca4ed79ee427335355808458d03d296ad19a
Restore single physical bootstrap data API test
```

`11126d666832e338092e001fcd2af0dc7d475ea8..7324ca4ed79ee427335355808458d03d296ad19a` has no final file diff. The intermediate mistaken test restructuring was reverted forward-only; therefore the physical test tree exercised on Ubuntu is equivalent to the one exercised on macOS.

## macOS arm64

Observed result:

```text
PASS   rumiai-os/bootstrap/system-data-apis.test
CLEAN  snapshot test rumiai-os/bootstrap/system-data-apis.test root-001
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
```

Result: **PASSED**.

## Ubuntu 26.04 ARM64

Reference host: `vmdev`.

Observed result:

```text
PASS   rumiai-os/bootstrap/system-data-apis.test
CLEAN  snapshot test rumiai-os/bootstrap/system-data-apis.test root-001
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
```

Result: **PASSED**.

## Validated properties

```text
SCF validation
SCF dot-notation lookup
SCF existence query
SCF namespace query
SCF mutation and removal
SCF duplicate/scalar-namespace/malformed rejection
opaque UTF-8 values

TSV header validation
exact field-count validation
row streaming
column lookup
row selection
UTF-8/path values
malformed dataset rejection
```

Gate conclusion:

```text
System Configuration Field API     VALIDATED
System Tabular Data API             VALIDATED
```

---

# Gate 2 — native platform and bootstrap platform primitives

## Scope

This validation covers the platform adapter implemented by `rumiai-os/lib/platform.lib` and its integration into the bootstrap.

Validated public API surface:

```text
rumi_platform
rumi_architecture
rumi_execution_platform
rumi_path_canonicalize_existing
rumi_fs_type
rumi_fs_mode
rumi_fs_readlink
rumi_digest_file
rumi_digest_text
rumi_atomic_replace
```

It also validates the bootstrap PATH precedence:

```text
RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>
RUMIAI_ROOT/bin
<inherited PATH>
```

Physical test:

```text
rumiai-os/bootstrap/system-platform-primitives.test
```

Validation options:

```text
--validation
--snapshot=hash
--snapshot-scope=test
--snapshot-root .
```

The filesystem snapshot result was `CLEAN` on both hosts.

## Target revision

Both validations exercised:

```text
massimilianonardi-ai/rumiai-os
8cd66322fde40ad019f008fec7bcda2968ab0fcf
Isolate bootstrap digest commands from RumiAI PATH
```

## Test revision

Before this gate the two Gate 1 validation sessions were committed into `rumiai-tests`; both hosts were then aligned to the same suite revision:

```text
massimilianonardi-ai/rumiai-tests
b4e147cc2f2f0177a6ed2ac9da36ef15e165a63b
Record Ubuntu 26.04 ARM64 bootstrap data API validation
```

The package platform primitive test itself was introduced earlier by:

```text
5a7bbbc36af79eaa3a5b2817de0a18841832d904
Add physical bootstrap platform primitive test
```

No test implementation change occurred between that revision and `b4e147cc2f2f0177a6ed2ac9da36ef15e165a63b`; the intervening commits only recorded Gate 1 validation evidence.

## macOS arm64

Observed result:

```text
PASS   rumiai-os/bootstrap/system-platform-primitives.test
CLEAN  snapshot test rumiai-os/bootstrap/system-platform-primitives.test root-001
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
```

Result: **PASSED**.

## Ubuntu 26.04 ARM64

Reference host: `vmdev`.

Observed result:

```text
PASS   rumiai-os/bootstrap/system-platform-primitives.test
CLEAN  snapshot test rumiai-os/bootstrap/system-platform-primitives.test root-001
PASS   1
FAIL   0
SKIP   0
ERROR  0
TOTAL  1
```

Result: **PASSED**.

## Validated properties

```text
native OS identity
native architecture identity
execution-platform identity
native @platforms PATH precedence
existing-path canonicalization API
filesystem file/directory/link classification
portable normalized file modes
symlink target reading
SHA-256 file digest
SHA-256 exact-text digest
host digest utility isolation from RumiAI PATH
same-directory atomic replace primitive
```

Gate conclusion:

```text
native platform identity             VALIDATED
native PATH specialization           VALIDATED
basic filesystem abstraction         VALIDATED
SHA-256 abstraction                  VALIDATED
atomic replace primitive             VALIDATED
```

---

# Remaining bootstrap platform gates

The completed gates do **not** yet physically validate:

```text
filesystem walk abstraction
Unicode NFC normalization
Unicode default case-fold
exclusive process locking
file durability sync
directory durability sync
atomic generation publish semantics
logical `rumi` command/shebang installation/discovery
```

These remain follow-up implementation/Physical Platform Validation work and are not implicitly satisfied by Gate 1 or Gate 2.
