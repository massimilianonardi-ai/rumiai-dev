# pkg-install-real-validation

## Intent

Exercise and debug the real composed public `pkg install` path with permanent coverage that satisfies the current testing authenticity contract.

## Why pending

Current permanent coverage for `pkg install` replaces parts of the package pipeline with artificial test components, so it cannot establish the current real-composed-path contract or reliably distinguish a product defect from a test reconstruction defect. This requires a dedicated work unit rather than being changed during historical recovery.

## Scope

```text
rumiai-tests
rumiai-os
pkg-catalog
```

## Evidence

```text
TESTING.md
specifications/rumiai-os/PACKAGE-MODEL.md
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea:tests/rumiai-os/pkg/install.test
```