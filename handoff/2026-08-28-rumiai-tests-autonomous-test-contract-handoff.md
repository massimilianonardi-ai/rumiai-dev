# RumiAI tests — autonomous test contract handoff

Date: 2026-08-28

## Canonical repositories

- `massimilianonardi-ai/rumiai-dev`: rules, specifications, decisions, architecture and development memory.
- `massimilianonardi-ai/rumiai-os`: stable product/runtime.
- `massimilianonardi-ai/rumiai-dev-PoCs`: experimental PoCs and evidence.
- `massimilianonardi-ai/rumiai-tests`: permanent executable tests and validation sessions.

## Current source of truth

Testing rules are canonical in:

```text
rumiai-dev/TESTING.md
```

This handoff records the latest approved runner/test contract. If details conflict, `TESTING.md` prevails.

## Approved test hierarchy

- `*.test` identifies a test.
- Every normal directory under `tests/` is a group.
- Groups may be nested.
- `tests/` is the root group and represents the whole suite.
- Selecting a group executes recursively all tests below it.
- Hidden pathnames beginning with `.` are internal material and are excluded from discovery.
- All other files are ignored by discovery.
- Test/group identity is the pathname relative to `tests/`.

## Independence and ordering

Every test is absolutely independent.

A test must not depend on another test, shared setup/teardown, state produced by another test, or execution order. If multiple coordinated steps are necessary before cleanup, all of them belong inside one independent test.

Groups provide no orchestration.

Serial traversal is deterministic and lexicographic, but the order has no semantic meaning. A test that passes only because another test ran first is invalid.

## Universal host model

Tests are unique and universal for the property being verified. Do not duplicate the same property into macOS/Linux/Windows variants merely because behavior differs by host.

Current stable reference hosts:

```text
macOS
Ubuntu 26.04 ARM64
```

Periodic additional hosts:

```text
Ubuntu 26.04 x64
Windows 10 x64
Windows 11 x64
```

The session records the execution environment. A real incompatibility remains `FAIL`; it must not be converted to `PASS` or `SKIP` merely because the project later accepts that incompatibility.

## Status contract

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

Status belongs to the test, not to the program under test.

## Autonomous test contract

A `.test` is a standalone program and contains all test-specific knowledge.

The test itself owns:

- self-discovery when its physical location is needed;
- resolution of its invocation pathname, symlinks and canonicalization as necessary;
- target discovery;
- fixture/support discovery;
- preconditions;
- setup specific to the verification;
- temporary resources;
- execution of commands/operations;
- expectations and comparisons;
- test-specific diagnostics;
- cleanup;
- final exit status.

Logical names and relative relationships may be hardcoded, for example:

```text
.fixtures/input
.support/helper
bin/log
rumiai-os
expected/status
```

Host-specific checkout paths, personal home paths, Homebrew paths and other local developer paths must not be hardcoded.

Shared libraries such as `lib/test.lib` are optional code reuse only. They are not runner services and should be expanded only when real repeated code justifies abstraction.

## Direct execution and shebang

A test must be executable directly, for example:

```text
./canonicalization.test
```

Direct execution and runner execution exercise the same test logic.

The test shebang identifies only the interpreter used by the test implementation. For a POSIX-shell test the normal shebang is:

```sh
#!/bin/sh
```

Neither `rumiai-test` nor `rumiai-os` is an implicit interpreter for `.test` files.

## Minimal runner contract

The key approved principle is:

> `rumiai-test` observes execution; it does not prepare it.

Runner responsibilities:

- locate its suite and perform discovery;
- select a test or group;
- traverse groups;
- preserve deterministic lexicographic order for serial execution;
- collect global host/session context;
- execute each `.test` directly according to its shebang;
- capture the test output;
- collect status 0..3;
- produce summaries;
- persist logs, results and validation metadata.

The runner -> test contract is intentionally empty.

The runner does **not**:

- pass RumiAI-specific arguments;
- define RumiAI-specific environment variables for target, id, temp paths or metadata;
- discover the target for the test;
- locate fixture/support files;
- perform test setup or cleanup;
- create an implicit temporary workspace;
- change CWD to prepare a test;
- rewrite `HOME` or `TMPDIR` to construct an artificial environment;
- provide assertion semantics;
- decide whether target behavior is correct;
- provide an implicit sandbox.

The runner does not promise to protect the host from a badly written test.

Future containment/sandbox modes, including possible host-specific mechanisms such as `chroot`, are separate explicit capabilities, not part of the base contract. If such a mode is used for a validation session, it must be recorded because it can affect interpretation of results.

## Logging contract

The test emits only its own verification output/diagnostics. Global context is logged by the runner separately.

`stdout` and `stderr` of each test are captured into one combined stream. The canonical model is equivalent to:

```sh
1>logfile 2>&1
```

Do not capture them separately and later attempt to reconstruct ordering from timestamps.

The test -> runner contract is therefore only:

```text
combined stdout/stderr stream
exit status 0..3
```

## Current repository state

`rumiai-tests` already exists and is initialized.

Runner skeleton exists as executable `rumiai-test`; `lib/test.lib` currently contains the canonical status constants only.

Latest documentation commits at the time of this handoff:

```text
rumiai-dev TESTING.md   b9a81c7a373ebcc5f11d0048346dfacff1a5b841
rumiai-tests README.md  1c725664c4e28c7d63a0059ba2064f22e5dd7baa
```

## Next design step

The architectural boundary between runner and test is now defined.

The next useful design decision is the public CLI of `rumiai-test`: minimal syntax for selecting the root suite, a group, or one test; distinction between development and validation runs; and the persistent session/result layout. Do not reintroduce target arguments or runner-to-test configuration while designing that CLI.
