# Contract-driven permanent-test audit

## Intent

Audit permanent tests in `rumiai-tests` against the current contract-first testing model: retain only materially useful contract/invariant coverage, remove implementation-proxy and incidental assertions, and keep product `FAIL` distinct from test/infrastructure `ERROR`.

## Why pending

The current gitman work exposed repeated false product failures caused by over-specified interactive tests and harness failures being collapsed into `FAIL`. The testing rules and gitman tests are being corrected in the current work unit, but a repository-wide audit is larger and independently resumable.

## Scope

```text
rumiai-tests
rumiai-dev/TESTING.md
rumiai-dev/TEST-PATTERNS.md
```

Review permanent tests for contract traceability, assertion relevance, duplicated coverage, source/implementation proxies, interactive-driver fragility, and incorrect FAIL/ERROR classification.

## Evidence

- `TESTING.md`: purpose of tests, observable contract before implementation, granularity/cost, individual test result, diagnostics, promotion/removal.
- `TEST-PATTERNS.md`: contract-first authoring gate.
- `tests/rumiai-os/gitman/contract.test`, `interactive.test`, and `terminal-output.test` provide the current concrete example that triggered the correction.
