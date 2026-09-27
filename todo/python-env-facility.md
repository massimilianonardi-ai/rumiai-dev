# python-env facility catalog integration

## Intent

Define the exact provider-independent `python-env` facility contract and materialize its first concrete provider through the existing `micromamba` package.

## Why pending

The facility identity and current provider choice are now fixed in `specifications/rumiai-os/PYTHON-RUNTIME.md`, but the current `pkg-catalog` micromamba definitions expose only the concrete `micromamba` package command and do not yet declare a `python-env` facility. The exact compatibility level and provider-independent typed contract must be defined before catalog publication.

## Scope

```text
rumiai-dev
pkg-catalog
rumiai-os      only if the current generic facility part types cannot express the required contract
rumiai-tests   permanent coverage for the resulting contract/integration
```

## Evidence

```text
specifications/rumiai-os/PYTHON-RUNTIME.md
specifications/rumiai-os/PACKAGE-MODEL.md
pkg-catalog/pkg/micromamba/
```
