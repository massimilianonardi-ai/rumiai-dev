# Handoff — resource / srv physical validation failure

Date: 2026-09-15  
Status: remediation required

## Authority

This handoff is non-normative.

The current validation-pair authority is:

```text
decisions/rumiai-tests/2026-09-15-reconcile-resource-srv-validation-pair.md
```

The current resource and srv contracts remain:

```text
specifications/rumiai-os/RESOURCE-MODEL.md
decisions/rumiai-os/2026-09-14-srv-portable-service-lifecycle.md
TESTING.md
```

## Exercised pair

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests 16f3926a224dd32d7d226a39234c779fa4ce1353
selection    rumiai-os
```

No product revision was changed during the analysis of these failures.

## Published evidence

Ubuntu 26.04 ARM64:

```text
session 20260915T145047+0200-376171
branch  validation/20260915T145047+0200-376171
PASS 57 / FAIL 13 / ERROR 15 / TOTAL 85
```

macOS ARM64:

```text
session 20260915T145126+0200-42022
branch  validation/20260915T145126+0200-42022
PASS 56 / FAIL 14 / ERROR 15 / TOTAL 85
```

Both sessions are immutable failure evidence for the exact exercised pair.

## Confirmed test-side failures

### Superseded top-level `lang` fixture dependency

The current resource model removed the top-level:

```text
$m_ROOT/lang
```

and defines:

```text
$m_ROOT/res
m_RES_DIR=$m_ROOT/res
m_LANG_DIR=$m_ROOT/res/sys/lang
```

The shared current fixture reference already copies `res`, but multiple permanent tests retain historical inline copies of the older fixture primitive or direct checks/copies of the old top-level `lang` tree.

Published failure logs demonstrate this directly in at least:

```text
rumiai-os/bootstrap/branded-path-prepend.test
rumiai-os/bootstrap/system-profile-selector.test
rumiai-os/command/*
rumiai-os/osarch/update.test
rumiai-os/shell/*
rumiai-os/state-path/contract.test
```

These tests must be realigned to the current resource model. The product must not regain a compatibility `$m_ROOT/lang` root merely to satisfy stale tests.

### `pkg/setuid.test`

The test still addresses the technical authorization catalogs as:

```text
$root/lang/en_US/...
$root/lang/it_IT/...
```

The current technical resource path is:

```text
$root/res/sys/lang/en_US/...
$root/res/sys/lang/it_IT/...
```

This is a test-side resource-layout residue.

### Node.js artifact test

The first expected descriptor in:

```text
tests/rumiai-os/pkg-repository-nodejs/artifact.test
```

contains an expected SHA-256 payload with 61 hexadecimal characters. The adapter contract and the later osarch mapping table in the same test use 64 hexadecimal characters.

The observed failure:

```text
artifact descriptor differs from pkg_download contract
```

is therefore a test expectation defect, not evidence that the adapter emitted a non-SHA-256 digest.

## `srv` macOS-only failure

Linux passes:

```text
rumiai-os/srv/lifecycle.test
```

macOS fails with:

```text
service target was not canonicalized to fixture command
```

The active srv contract explicitly requires canonicalization of `<service>-start` before launch. Therefore the test must not be weakened to accept a merely equivalent non-canonical pathname.

Before any product modification, the permanent test should expose both the expected canonical pathname and the runtime `command` metadata value so the next macOS run can distinguish:

```text
test expectation/path spelling issue
host-specific canonical-path representation
actual product canonicalization defect
```

No `rumiai-os` change is authorized or justified by the current evidence alone.

## Required remediation sequence

```text
1. realign stale permanent-test fixture copies from top-level lang to res
2. realign pkg/setuid.test catalog paths to res/sys/lang
3. correct the malformed 61-character Node.js expected digest
4. improve srv lifecycle failure diagnostics without changing SRV-05
5. run proportionate static/synthetic checks on the changed tests
6. create a new revision-specific validation pair with unchanged rumiai-os only if product remains unchanged
7. rerun full selection rumiai-os on Ubuntu 26.04 ARM64 and macOS ARM64
8. only after a positive full-suite gate, execute the separate external/nodejs/install-live.test gate
```

## Consistency constraints

```text
- do not restore a top-level lang compatibility root in rumiai-os
- do not reinterpret ERROR/FAIL evidence as PASS
- do not weaken srv canonicalization semantics
- do not modify rumiai-os without explicit user authorization for that phase
- preserve the existing resource and testing contracts
- Git remains forward-only
```
