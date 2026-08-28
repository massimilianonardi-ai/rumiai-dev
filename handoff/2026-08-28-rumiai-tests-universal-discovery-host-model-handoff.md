# Handoff — RumiAI tests universal discovery and host model

Date: 2026-08-28
Status: **testing discovery and host model consolidated**

## Canonical repositories

```text
rumiai-dev       rules, specifications, decisions, architecture
rumiai-os        stable product/runtime
rumiai-dev-PoCs  experimental laboratory and PoCs
rumiai-tests     permanent test and validation suite
```

## Canonical testing rules

Primary source:

```text
rumiai-dev/TESTING.md
```

Latest update defining discovery and host behavior:

```text
a5cf7653b9731ceefd9244cfc310ef462b00e003
```

`rumiai-tests/README.md` is aligned at:

```text
6370a1545fd2742ffe71377b81cd4b9079c6f607
```

## Test hierarchy

- every normal directory under `tests/` is a group;
- groups can be nested;
- `tests/` is the root group and represents the whole suite;
- selecting a group recursively selects all tests in the group and its subgroups;
- relative path from `tests/` is the natural identifier for tests and groups;
- group members are traversed in deterministic lexicographic order;
- execution order has no functional meaning.

## Absolute test independence

Every test is a completely independent validation unit.

A test must not depend on:

- another test having run before it;
- state left by another test;
- shared group setup or teardown;
- output or intermediate artifacts from another test;
- its position in execution order.

A test that passes only because another test ran first is invalid.

If a validation requires multiple coordinated operations before cleanup, all of those operations belong inside one independent test.

Groups provide no orchestration, dependencies, before/after hooks or shared lifecycle.

## Discovery rules

The filesystem rules are intentionally minimal:

1. a regular file whose name ends in `.test` is a test;
2. every normal directory under `tests/` is a group;
3. hidden pathnames/directories whose name starts with `.` are internal material and are excluded from discovery;
4. every other file is ignored by the runner.

Typical support layout:

```text
tests/rumiai-os/bootstrap/
├── absolute.test
├── relative.test
├── README.md
├── .fixtures/
└── .support/
```

The `.test` suffix is semantic and does not identify the implementation language.

## Test result contract

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

A real host incompatibility against the required property is `FAIL`.

It must not be changed to `PASS` or `SKIP` merely because the incompatibility is known or accepted.

`SKIP` means the test is not applicable or a declared execution precondition is unavailable.

`ERROR` means the test/runner/environment prevented the test from determining a result.

## Universal host model

Tests are unique and universal for the hosts on which the property is applicable.

Do not normally duplicate the same property into macOS/Ubuntu/Windows-specific test trees.

The suite describes **what property is tested**.

The validation session describes **where and under which host conditions it was tested**.

Current stable reference hosts:

```text
macOS
Ubuntu 26.04 ARM64
```

Periodically used additional hosts:

```text
Ubuntu 26.04 x64
Windows 10 x64
Windows 11 x64
```

A validation session must record at least:

- target revision;
- rumiai-tests revision;
- OS;
- OS version;
- architecture;
- relevant shell/POSIX environment when material;
- other host characteristics needed to interpret results;
- executed tests and PASS/FAIL/SKIP/ERROR results.

If a test fails on one host, the project evaluates the failure together with the session metadata.

The project may explicitly accept an incompatibility without changing the product if that host/case is not important enough to justify the complexity of a fix. The recorded session result remains `FAIL`.

## Current rumiai-tests state

Repository:

```text
massimilianonardi-ai/rumiai-tests
```

Current skeleton includes:

```text
README.md
rumiai-test
lib/test.lib
tests/
sessions/
```

`rumiai-test` is executable and still intentionally contains no discovery/selection implementation beyond the initial skeleton.

## Next design step

Define the minimal runner-to-test contract before implementing the first permanent Phase 1 suite.

Key decisions still open include:

- how `rumiai-test` locates or receives the target;
- how a test receives target and temporary workspace paths;
- exact invocation contract for one `.test` file;
- minimum stdout/stderr conventions;
- aggregation behavior for a selected group/root suite;
- exact development-run versus validation-run CLI.

Do not introduce orchestration, host-specific duplicate suites, manifests per test, tag databases or other complexity unless a concrete need emerges.

The repository remains the source of truth; on resume, read the newest file in `handoff/` rather than assuming this filename is still current.
