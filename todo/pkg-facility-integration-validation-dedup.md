# Package facility integration validation deduplication

## Intent

Remove duplicated cmd/env realization validation from `pkg-integration.lib.sh` by reusing the generalized trusted facility typed-part validation responsibilities without changing package semantics.

## Why pending

Install-time provider conformance already validates cmd/env through the generalized facility layer, while integration retains earlier local validators. The duplication is real technical debt but not a semantic or correctness blocker, and refactoring it during package-task closure would add unnecessary regression risk.

## Scope

`rumiai-os` package integration/facility libraries and manuals plus directly affected permanent tests in `rumiai-tests`.

## Evidence

Current `pkg-integration.lib.sh` still contains `_pkg_integration_facility_cmd_validate`, `_pkg_integration_facility_env_validate` and their projection validation path alongside the generalized facility cmd/env handlers used by provider conformance.
