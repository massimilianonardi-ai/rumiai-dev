# Package current plan after K2 validation test error

Date: 2026-09-11  
Status: **Accepted**

## Purpose

This document records the current operational state after the first physical-validation attempt of K2 dependency resolution and binding lifecycle.

It does not change the Accepted K2 product semantics. It records the validation evidence, classifies the observed error, records the permanent-test correction, and fixes the exact revision pair that must be revalidated.

Authoritative K2 semantics remain defined by:

```text
decisions/rumiai-os/2026-09-11-package-k2-dependency-binding-lifecycle-policy.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
```

## K2 implementation and permanent suite before physical validation

Product revision:

```text
rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
```

Permanent-suite revision exercised by the first K2 physical-validation attempt:

```text
rumiai-tests@6e2c9fdf7e758d56d65d2dc71c1324756d9135ce
```

Validation selection:

```text
rumiai-os/pkg
```

The suite contains seven package tests, including the K2 `dependency.test`.

## First K2 physical-validation evidence

### Ubuntu ARM64

Validation branch:

```text
validation/20260911T130814+0200-199536
```

Validation evidence commit:

```text
f8f02a240670e87a8714ce687365255442bf1d14
```

Host:

```text
Ubuntu 26.04.1 LTS
aarch64
Linux 7.0.0-31-generic
```

Result:

```text
PASS  rumiai-os/pkg/catalog-snapshot.test
PASS  rumiai-os/pkg/default.test
ERROR rumiai-os/pkg/dependency.test
PASS  rumiai-os/pkg/facility.test
PASS  rumiai-os/pkg/install.test
PASS  rumiai-os/pkg/uninstall.test
PASS  rumiai-os/pkg/versions.test
```

Runner exit status:

```text
2
```

The dependency-test diagnostic was:

```text
mkdir: /tmp/rumiai-pkg-dependency-200048/range-java21-1-generic: File exists
rumiai-os/pkg/dependency.test: cannot install preflight java provider
```

### macOS ARM64

Validation branch:

```text
validation/20260911T130830+0200-23782
```

Validation evidence commit:

```text
4faca00910d604daff5614fd3aac4d994f4fb60b
```

Host:

```text
macOS 26.6.2
arm64
Darwin 25.6.0
```

Result:

```text
PASS  rumiai-os/pkg/catalog-snapshot.test
PASS  rumiai-os/pkg/default.test
ERROR rumiai-os/pkg/dependency.test
PASS  rumiai-os/pkg/facility.test
PASS  rumiai-os/pkg/install.test
PASS  rumiai-os/pkg/uninstall.test
PASS  rumiai-os/pkg/versions.test
```

Runner exit status:

```text
2
```

The dependency-test diagnostic was:

```text
mkdir: <TMPDIR>/rumiai-pkg-dependency-24317/range-java21-1-generic: File exists
rumiai-os/pkg/dependency.test: cannot install preflight java provider
```

## Classification

The identical failure on both reference hosts is a permanent-test fixture **ERROR**, not an observed product **FAIL**.

`dependency.test` intentionally contains multiple independent internal scenarios separated by `reset_fixture()`.

Before the correction, `reset_fixture()` removed only:

```text
$m_PKG_DIR
$m_BIN_DIR
$m_DATA_DIR
```

but left scenario input material directly under the test `$tmp` directory.

An early scenario creates:

```text
$tmp/range-java21-1-generic
```

A later scenario, after `reset_fixture()`, legitimately installs the same provider identity again and attempts to create the same range path. Because the previous range was not removed, fixture setup fails at `mkdir` before the later K2 assertion is exercised.

The error therefore prevents the test from establishing the product result and is correctly classified as status `3 = ERROR` under `TESTING.md`.

## Test-only correction

The product is unchanged.

`reset_fixture()` now removes the whole test temporary workspace:

```text
$tmp
```

and recreates the package, binary and data roots before the next internal scenario.

This restores scenario isolation inside the permanent test and removes stale source ranges and roots from previous scenarios.

The net functional diff from the suite revision exercised above is exactly one line in:

```text
tests/rumiai-os/pkg/dependency.test
```

Current corrected suite revision:

```text
rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
```

The two forward-only commits used to reach that state are:

```text
7033a57184fa7cae4ac9532b14e4b5ddd39f7370  Fix dependency test fixture reset
0a337fff671b5f0e38fe89d2b054111627bf03b6  Restore dependency test final newline
```

The second commit only restores the final LF accidentally omitted while applying the first correction. Relative to `6e2c9fdf7e758d56d65d2dc71c1324756d9135ce`, the resulting file differs only in the intended `reset_fixture()` line.

## Current validation pair

The next physical-validation run must exercise exactly:

```text
rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
selection: rumiai-os/pkg
```

`rumiai-validate.conf` continues to pin the same product revision and the same selection.

Because the permanent-suite revision changed, K2 closure requires a new validation run on both reference hosts using the corrected suite revision.

The existing evidence branches are immutable and remain evidence only for the exact earlier revision pair.

## Operational sequence

```text
J1   pkg uninstall: contract/test/implementation                  [completed]
J2   physical validation pkg uninstall                            [completed]
J3a  pkg versions/default naming + public contract                [completed]
J3b  permanent test + implementation                              [completed]
J3c  physical validation versions/default + pkg regression       [completed]
K0   facility/dependency serialization + resolution policy        [completed]
K1a  facility provider lifecycle implementation + permanent test  [completed]
K1b  physical validation facility + pkg regression                [completed]
K2a  dependency/binding lifecycle policy                          [completed]
K2b  implementation + permanent test                              [completed]
K2c  physical validation dependency + pkg regression              [current: rerun required]
```

K2 must not be reported as physically validated until both reference hosts pass the corrected current suite revision.

## Invariants preserved

```text
product K2 revision remains 096645f9be29b5338379a13061aff71c60a848a2
no product change was made for this validation error
old validation evidence is immutable and revision-specific
both hosts observed the same test-harness ERROR
all six non-K2 package tests passed on both hosts
current validation selection remains rumiai-os/pkg
current product pin remains 096645f9be29b5338379a13061aff71c60a848a2
corrected suite revision is 0a337fff671b5f0e38fe89d2b054111627bf03b6
both reference hosts must rerun before K2c can close
Git history remains forward-only
```
