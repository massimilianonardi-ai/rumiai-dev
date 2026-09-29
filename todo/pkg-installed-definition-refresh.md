# Installed package definition refresh

## Intent

Define a generic forward-only mechanism for refreshing or reintegrating catalog-derived metadata of an already installed package concrete when its catalog definition changes without changing the upstream package version/artifact identity.

## Why pending

The current `pkg install` path returns `already-installed` as soon as the concrete identity already exists, before reintegrating a newer definition for that same upstream version. Therefore a micromamba 2.9.0-0 concrete installed from a catalog snapshot predating `python-env` does not automatically acquire the later facility declaration/adapter metadata. Solving this is a generic package-definition evolution concern and is intentionally outside the completed `python-env` work unit.

## Scope

```text
rumiai-dev
rumiai-os package subsystem
pkg-catalog contract/versioning implications
rumiai-tests
```

## Evidence

```text
specifications/rumiai-os/PACKAGE-MODEL.md
rumiai-os/lib/sys/sh/pkg/pkg-install.lib.sh
pkg-catalog/pkg/micromamba/
```
