# Handoff — RumiAI tests hierarchical independent groups

Date: 2026-08-28
Status: **test grouping model approved and canonicalized**

## Canonical repositories

```text
rumiai-dev       rules, specifications, decisions and architecture
rumiai-os        stable product/runtime
rumiai-dev-PoCs  experimental laboratory and proof-of-concept work
rumiai-tests     permanent regression and validation suite
```

Canonical testing rules:

```text
rumiai-dev/TESTING.md
```

## Approved grouping model

The filesystem hierarchy under `rumiai-tests/tests/` is the primary grouping and selection model.

Every directory under `tests/` is a group.

Groups may contain tests and nested subgroups.

Selecting a group means recursively executing all tests belonging to that group and its subgroups.

`tests/` is the root group and therefore represents the entire suite.

The pathname relative to `tests/` is the natural identifier for both tests and groups and is intended to be used for selection, reporting, diagnostics and validation-session records.

## Fundamental invariant: absolute test independence

Every test is an autonomous validation unit.

A test must be executable individually and must produce the same result, for the same target/configuration/relevant host conditions, regardless of which tests run before or after it.

A test may not depend on:

- another test having already executed;
- state left by another test;
- setup or cleanup belonging to another test;
- files, processes, services, configuration or intermediate output produced by another test;
- its position in the suite execution order.

Canonical rule:

> A test that passes only because another test ran before it is invalid.

If a validation requires several coordinated operations before cleanup, the whole sequence belongs inside one independent test. Such a test may contain internal steps, but remains one suite-level validation unit.

## Groups do not orchestrate

Groups are only hierarchical containers and recursive selection units.

Group-level orchestration is explicitly excluded.

Groups do not define:

- test dependencies;
- shared setup required for correctness;
- shared teardown required for correctness;
- communication/state passing between tests;
- custom functional order;
- before/after-style primitives that make tests group-dependent.

If coordinated behavior is required, implement it inside one independent test.

## Execution order

When a group is executed, tests and subgroups are traversed in deterministic lexicographic order of their identifiers.

This order exists only to make runs predictable, reproducible, readable and comparable across hosts and sessions.

It has no functional meaning. No test may depend on serial position or on lexicographic order.

Future parallel execution is compatible with the model only if it preserves the observable suite contract and test independence.

## Cleanup and resource ownership

Each test owns and manages its own temporary resources.

Cleanup belongs to the test that created the resource and may not be delegated to a later test or to a group.

Independence takes precedence over optimizing away repeated setup/cleanup cost.

## Documents updated

`rumiai-dev/TESTING.md`

commit:

```text
f3de55cde7e76d30d52aae8d559dac406a534efa
```

`rumiai-tests/README.md`

commit:

```text
2aecfd55c89ddf400b37769b4530132c1e43daf5
```

## Current rumiai-tests state

Repository:

```text
massimilianonardi-ai/rumiai-tests
```

Initial structure already exists:

```text
rumiai-test
lib/test.lib
tests/
  rumiai-os/
    bootstrap/
    command/
    i18n/
    log/
    shell/
  external/
sessions/
```

`rumiai-test` is executable (`100755`).

Current test result status contract:

```text
0 PASS
1 FAIL
2 SKIP
3 ERROR
```

The runner is still intentionally only a skeleton. CLI, target discovery and test-file discovery rules have not yet been defined.

## Next design question

Before implementing the first permanent Phase 1 regression tests, define what constitutes a test entry in the filesystem and how `rumiai-test` distinguishes executable test units from fixtures, configuration, support files and other material that may live under the hierarchy.

On resume, read the newest handoff in `rumiai-dev/handoff/`; do not assume this filename remains the newest.
