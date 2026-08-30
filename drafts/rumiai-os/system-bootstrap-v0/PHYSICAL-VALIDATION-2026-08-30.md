# RumiAI system bootstrap v0 — physical validation

Date: 2026-08-30

Status: **Gate 1 and Gate 2 PASSED on both current stable reference installations; current corrected revision pending bundled revalidation**

This document records the physical validation gates completed for the RumiAI bootstrap substrate.

Important evidence rule:

> Physical validation evidence applies to the exact product/test revisions and API spelling exercised. Later corrections are not retroactively described as physically validated.

Historical commits remain the authoritative evidence for the exact source text exercised at each gate. Current documentation does not reproduce obsolete noncanonical terminology merely to describe that history.

---

# Gate 1 — system configuration and tabular data APIs

## Scope

This validation covered the bootstrap system data API implemented by `rumiai-os/lib/data.lib` and loaded by the `rumiai-os` bootstrap.

The validated revision used a noncanonical abbreviation-based API spelling that was corrected later. The exact historical spelling remains inspectable in the recorded target/test commits; it is not part of the current contract.

Current canonical API:

```text
RumiAI_conf_validate
RumiAI_conf_get
RumiAI_conf_has
RumiAI_conf_namespace
RumiAI_conf_set
RumiAI_conf_remove

RumiAI_table_validate
RumiAI_table_header
RumiAI_table_rows
RumiAI_table_column
RumiAI_table_select
```

The underlying SCF/TSV semantics validated below did not change. The current corrected product revision will be re-exercised together with the next substantive bootstrap physical gate.

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
System Configuration Field semantics     VALIDATED
System Tabular Data semantics             VALIDATED
current RumiAI_* API spelling             PENDING BUNDLED REVALIDATION
```

---

# Gate 2 — native platform and bootstrap platform primitives

## Scope

This validation covered the platform adapter implemented by `rumiai-os/lib/platform.lib` and its integration into the bootstrap.

The validated revision likewise used the same previous noncanonical abbreviation-based spelling for newly introduced APIs. The exact historical source is preserved in Git; the current contract is:

```text
RumiAI_platform
RumiAI_architecture
RumiAI_execution_platform
RumiAI_path_canonicalize_existing
RumiAI_fs_type
RumiAI_fs_mode
RumiAI_fs_readlink
RumiAI_digest_file
RumiAI_digest_text
RumiAI_atomic_replace
```

`RumiAI_path_canonicalize_existing` was already an established bootstrap primitive and is reused directly; no redundant alias is retained.

The validation also covered bootstrap PATH precedence:

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

Both hosts were aligned to:

```text
massimilianonardi-ai/rumiai-tests
b4e147cc2f2f0177a6ed2ac9da36ef15e165a63b
Record Ubuntu 26.04 ARM64 bootstrap data API validation
```

The platform primitive test itself was introduced earlier by:

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
existing-path canonicalization API semantics
filesystem file/directory/link classification
portable normalized file modes
symlink target reading
SHA-256 file digest
SHA-256 exact-text digest
host digest utility isolation from RumiAI PATH
same-directory atomic replace semantics
```

Gate conclusion:

```text
native platform identity semantics             VALIDATED
native PATH specialization                     VALIDATED
basic filesystem abstraction semantics         VALIDATED
SHA-256 abstraction semantics                  VALIDATED
atomic replace semantics                       VALIDATED
current RumiAI_* API spelling                  PENDING BUNDLED REVALIDATION
```

---

# Post-gate consistency corrections

After Gate 2, consistency review identified multiple issues in work added after the validated revisions:

1. newly introduced API naming did not respect the established `RumiAI_*` namespace;
2. required-library loading duplicated existence/readability prechecks before the same source operation;
3. conversational shorthand had been incorrectly promoted into a supposed bootstrap command/interpreter and custom shebang concept.

The current tree corrects these issues forward-only:

```text
namespaced RumiAI functions -> exact RumiAI_* namespace
existing RumiAI_path_canonicalize_existing reused directly
required library load -> one controlled source operation
no conversational shorthand promoted into product terminology
no invented bootstrap command/interpreter
shell executable rule remains canonical #!/bin/sh
```

The source-only load form used by the corrected bootstrap is:

```sh
if ! command -- . -- "$LIB"
then
  <single diagnostic/error path>
fi
```

The `command` wrapper preserves controlled error handling for the POSIX special built-in `.` while avoiding duplicate prechecks.

These corrections do not rewrite or falsify the semantic evidence from Gate 1/Gate 2. The current revision is not labelled physically validated until exercised in a later meaningful gate.

---

# Remaining bootstrap platform gates

The completed gates do **not** yet physically validate:

```text
current corrected bootstrap revision
filesystem walk abstraction
Unicode NFC normalization
Unicode default case-fold
exclusive process locking
file durability sync
directory durability sync
atomic generation publish semantics
```

No new bootstrap command/interpreter or custom shebang is an outstanding validation target because no such concept is part of the current architecture.
