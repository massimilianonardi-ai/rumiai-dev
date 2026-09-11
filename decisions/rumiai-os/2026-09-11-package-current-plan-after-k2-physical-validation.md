# Package current plan after K2 physical validation

Date: 2026-09-11  
Status: **Accepted**

## Purpose

This document records the successful physical validation of K2 dependency resolution and resolved binding lifecycle and updates the current package-manager operational state.

It supersedes `decisions/rumiai-os/2026-09-11-package-current-plan-after-k2-validation-test-error.md` only for current operational status and sequencing. Historical validation evidence remains immutable and revision-specific.

Authoritative K2 semantics remain defined by:

```text
decisions/rumiai-os/2026-09-11-package-k2-dependency-binding-lifecycle-policy.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
decisions/rumiai-os/2026-09-07-package-facility-dependency-and-provider-index.md
```

## Validated revision pair

Product revision:

```text
rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
```

Permanent-suite revision:

```text
rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
```

Validation selection:

```text
rumiai-os/pkg
```

`rumiai-validate.conf` at the validated suite revision pins that product revision and that selection.

## Successful physical-validation evidence

### Ubuntu ARM64

Validation branch:

```text
validation/20260911T132202+0200-234493
```

Validation evidence commit:

```text
4c3b879579d5f3a17fb0db6780205e6db96ec66f
```

Host:

```text
Ubuntu 26.04.1 LTS
aarch64
Linux 7.0.0-31-generic
```

Suite revision recorded by the session:

```text
0a337fff671b5f0e38fe89d2b054111627bf03b6
```

Result:

```text
PASS rumiai-os/pkg/catalog-snapshot.test
PASS rumiai-os/pkg/default.test
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/pkg/facility.test
PASS rumiai-os/pkg/install.test
PASS rumiai-os/pkg/uninstall.test
PASS rumiai-os/pkg/versions.test
```

Runner exit status:

```text
0
```

### macOS ARM64

Validation branch:

```text
validation/20260911T132218+0200-26272
```

Validation evidence commit:

```text
ded249479030b27bd44688471bd1ed2274cb1ffb
```

Host:

```text
macOS 26.6.2
arm64
Darwin 25.6.0
```

Suite revision recorded by the session:

```text
0a337fff671b5f0e38fe89d2b054111627bf03b6
```

Result:

```text
PASS rumiai-os/pkg/catalog-snapshot.test
PASS rumiai-os/pkg/default.test
PASS rumiai-os/pkg/dependency.test
PASS rumiai-os/pkg/facility.test
PASS rumiai-os/pkg/install.test
PASS rumiai-os/pkg/uninstall.test
PASS rumiai-os/pkg/versions.test
```

Runner exit status:

```text
0
```

## K2 closure

The exact current K2 product/suite pair therefore passes the complete `rumiai-os/pkg` selection on both reference hosts.

K2 dependency resolution, binding lifecycle and provider-reference protection are now physically validated.

The earlier evidence branches with `dependency.test` status `ERROR` remain immutable evidence for the previous permanent-suite revision and are not relabelled as product failures or as validation of the corrected suite.

No additional `rumiai-os` change was required after `096645f9be29b5338379a13061aff71c60a848a2`.

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
K2c  physical validation dependency + pkg regression              [completed]
```

No subsequent stage name or package-manager feature is fixed by the current authoritative material. Further package work therefore returns to planning and must begin with the normal authority preflight before a new scope is defined.

## Current invariants

```text
K2 product revision validated = rumiai-os@096645f9be29b5338379a13061aff71c60a848a2
K2 permanent-suite revision validated = rumiai-tests@0a337fff671b5f0e38fe89d2b054111627bf03b6
Ubuntu K2 evidence = validation/20260911T132202+0200-234493
macOS K2 evidence = validation/20260911T132218+0200-26272
both current evidence sessions are PASS 7/7 with runner status 0
K2 is completed and physically validated
old evidence remains immutable and revision-specific
dependency requirement remains distinct from resolved binding
normal launch performs no resolution
provider removal remains forbidden while referenced by an installed binding
provider removal performs no automatic re-resolution
no reverse reference index exists
multi-operand package operations remain sequential and are not a global transaction
no crash-recovery transaction engine was introduced by K2
no public re-resolution command was introduced by K2
no subsequent package stage name is currently fixed
Git remains forward-only
```