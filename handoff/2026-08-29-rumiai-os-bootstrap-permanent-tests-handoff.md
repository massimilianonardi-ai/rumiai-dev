# Handoff — RumiAI OS bootstrap milestone closed

Date: 2026-08-29
Status: **BOOTSTRAP PHASE 0/1 CLOSED — PACKAGE MANAGER IS THE ACTIVE PRIORITY**

## Stable product baseline

Repository:

```text
massimilianonardi-ai/rumiai-os
```

Validated product commit:

```text
8698504f715ed61cec8a31b46ded5b79f3924eb5
Separate pathname validation from canonicalization
```

The Phase 0/1 bootstrap, semantic roots, PATH model, bootstrap preferences, i18n, logger, command interpreter, direct `#!/usr/bin/env rumiai-os` host profile, Bash selection where available, and POSIX `sh` path have been physically exercised on both stable hosts.

The accepted pathname rule remains:

```text
VALIDATE EXISTENCE
        ↓
CANONICALIZE EXISTING PATH
        ↓
VALIDATE REQUIRED TYPE
```

`realpath` is only a canonicalizer of an already-existing pathname. The rejected `realpath -e` commit remains historical evidence and must not be revived for the reference macOS host.

## Permanent test suite

The artificial test:

```text
tests/rumiai-os/shell/bash-fallback-to-sh.test
```

has been removed intentionally.

Reason: absence of Bash is not a material RumiAI portability requirement. POSIX `sh` is the required portable shell baseline; Bash is only an optional user-facing convenience when available. A permanent test that manufactures Bash absence added complexity without protecting an important product contract.

The removal commit is:

```text
e6534b734a170ad5334aedcfe0e6347d5da64814
Remove irrelevant bash absence test
```

The remaining suite contains 55 tests.

No additional full-suite run is required merely because this test was deleted. In the immediately preceding macOS run all other 55 tests were PASS and the deleted test was the sole FAIL. In the corresponding Ubuntu ARM64 run all 56 tests were PASS. Therefore every remaining test has already physically passed on both stable hosts against the unchanged product baseline.

## Validation policy — selective by impact

Physical validation is no longer automatically equivalent to running the complete suite after every change.

Use the smallest test scope that proves the changed contract:

```text
single test
    when one isolated behavior changes

group / subsystem
    when shared code inside that subsystem changes

full suite
    only when a cross-cutting bootstrap/runtime/runner primitive changes,
    at a major milestone,
    or before a release/certification checkpoint
```

Do not re-run tests for unchanged behavior merely to reproduce already-established evidence.

Do not create permanent tests for hypothetical failure modes that are outside the product contract or contradict the selected platform baseline. External properties should be tested only when RumiAI materially relies on them and their failure would change a supported behavior.

## Why the package manager is the active priority

The new portable runtime was not created because the previous portable environment was non-functional. The previous line worked, but its evolution exposed two structural limitations:

1. missing advanced runtime capabilities, especially a package manager capable of growing with the system;
2. insufficient architectural and workflow discipline, which allowed working PoCs and tests to accumulate abandoned fragments, mixed responsibilities, stale refactors and code in the wrong subsystem.

The bootstrap/test/development separation built in the current cycle exists to prevent that history from repeating.

Therefore bootstrap work is now infrastructure and the active development priority is the **RumiAI package manager**.

The package manager must inherit the vision of `massimilianonardi/m` and especially its historical predecessor line under `var/#_os`, rather than becoming a generic clone of an existing package manager.

## Package-manager genealogy already audited

The `m` audit is stored under:

```text
analysis/m-audit/
```

Key existing documents:

```text
2026-08-27-architecture-inventory.md
2026-08-27-package-manager-deep-dive.md
2026-08-27-mk-target-profile-deep-dive.md
2026-08-27-bootstrap-and-deployment-deep-dive.md
```

The current package-manager lineage/design extraction is:

```text
analysis/m-audit/2026-08-29-package-manager-lineage-design-input.md
```

Source snapshot:

```text
massimilianonardi/m@e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Recovered package-manager vision

The key lineage is:

```text
var/#_os historical package manager
    package/root/integration/state model

+

cmd/pkg current generation
    practical upstream/provider/artifact handling

+

new rumiai-os discipline
    relocatability
    declarative metadata
    plan-before-side-effects
    receipts
    transactionality
    explicit trust
```

The package manager is best understood as a **software environment composition substrate**, not merely an archive installer.

Core distinctions to preserve:

```text
package request
package definition
provider discovery
resolved package
artifact
materialization
integration intent
mutable state
installation receipt
```

Important inherited principles:

- package definition is not the vendor artifact;
- materialization is not integration;
- package is not mutable application/user state;
- dynamic discovery (`latest`) is not immutable resolution;
- resolution must precede side effects;
- uninstall/rollback should operate from recorded committed state, not reinterpret the current manifest;
- upstream ecosystems such as GitHub/Maven/Codeberg are providers/adapters, not RumiAI's internal package model;
- operations occur relative to an explicit RumiAI root, not through global host paths;
- host-specific integration belongs behind adapters/materializers.

## Current PoC direction

A new experimental PoC is being built in:

```text
rumiai-dev-PoCs/pocs/005-package-manager-foundation/
```

Its first contract is deliberately small:

```text
arbitrary temporary root
        ↓
declarative package definition
        ↓
static/local artifact
        ↓
resolution plan with zero root side effects
        ↓
materialization
        ↓
command integration
        ↓
installation receipt
        ↓
remove definition + plan
        ↓
receipt-driven uninstall
        ↓
root restored to initial state
```

No network/provider/version/dependency complexity belongs in this first PoC.

Only after this foundation is demonstrated should the next PoCs add, one property at a time:

```text
provider discovery → immutable resolution
artifact cache/digest verification
dependency graph resolution before execution
staging/transaction/rollback
hosted integration adapter
state compatibility/migration
additional system materializers
```

## Git rule

All repositories remain forward-only. Failed experiments and superseded decisions stay in Git history; current operational documents should describe only the accepted state and active next steps.
