# RumiAI system bootstrap v0 — physical validation

Date: 2026-08-30

Status: **PASSED on both current stable reference installations**

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

The physical test is:

```text
rumiai-os/bootstrap/system-data-apis.test
```

The validation run used:

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
ca696b7a0c7027d2b9f4c0989bc0a5ad7b2c75e6
Fix invalid configuration query status
```

## Test revisions

The macOS validation used:

```text
massimilianonardi-ai/rumiai-tests
11126d666832e338092e001fcd2af0dc7d475ea8
```

The Ubuntu validation used the later forward-only revision:

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

Result:

```text
PASSED
```

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

Result:

```text
PASSED
```

## Validated properties

The single coordinated physical scenario validates the bootstrap data substrate needed by `pkg`, including:

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

## Gate conclusion

The following bootstrap capabilities are now physically validated on both current stable reference installations:

```text
System Configuration Field API
System Tabular Data API
```

This closes the physical validation gate for SCF/STD.

It does **not** validate the later platform-adapter primitives still to be implemented separately:

```text
native platform identity
filesystem/stat/readlink/walk abstraction
digest abstraction
Unicode NFC/default case-fold abstraction
exclusive lock
file/directory sync
atomic rename/replace
```
