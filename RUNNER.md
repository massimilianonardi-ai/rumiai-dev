# RumiAI Test Runner Contract

This document defines the canonical contract of `rumiai-test`.

General suite rules, validation scopes and task validation are defined in `TESTING.md`.

## 1. Fundamental principle

`rumiai-test` remains intentionally simple and agnostic about target semantics.

> `rumiai-test` observes execution; it does not prepare the target and does not decide which properties are required to close a task.

Validation-scope selection belongs to the validation launcher/configuration, not to the runner.

## 2. CLI

The canonical CLI remains:

```text
rumiai-test [options] [--] [selection]
```

Current options:

```text
--list
--validation
--snapshot=metadata|hash
--snapshot-scope=selection|test|both
--snapshot-root <pathname>
```

`--list` is discovery-only. It prints one discovered test identifier per line in the exact deterministic order that normal execution would use, then exits without executing tests and without creating `.runs/`, `sessions/`, logs or snapshots. It accepts the same optional single `selection` as normal execution. `--list` cannot be combined with `--validation` or snapshot options.

`--snapshot-root` is repeatable.

An omitted `selection` selects the `tests/` root; a directory pathname recursively selects the group; a `*.test` pathname selects the individual test.

The runner intentionally continues to accept exactly one selection per run. The need to validate multiple selections for one work unit is handled by `rumiai-validate`, which may execute multiple elementary validation runs and aggregate their scope result.

The form `rumiai-test .` is not allowed. `--snapshot-root .` remains valid.

## 3. Development and validation runs

Development and validation runs execute the same `.test` in the same way.

`--validation` adds reproducibility and evidence-persistence controls; it does not change the test's internal logic.

`--list` performs only selection validation and canonical discovery. It is specifically suitable for `rumiai-validate` orchestration because it reuses the runner's discovery implementation without creating execution evidence.

The runner does not perform `git add`, `commit`, `push`, checkout or target updates.

## 4. Discovery and order

The runner applies the rules in `TESTING.md`:

1. `*.test` identifies a test;
2. normal directories are groups;
3. hidden pathnames are excluded;
4. other files are ignored.

A group selection is recursive. During serial execution, order is deterministic lexicographic order and is semantically irrelevant.

A selected group containing no tests is a `RUNNER ERROR`.

Normal execution and `--list` must use the same discovery implementation and therefore produce the same ordered set of test identifiers for the same selection.

## 5. Runner -> test contract

The contract remains empty.

The runner does not communicate target, test-id, temporary directory or RumiAI-specific metadata; it does not prepare setup/cleanup; it does not change CWD; it does not modify `HOME`/`TMPDIR`; it does not provide implicit assertions or sandboxing. When invoked by `rumiai-validate`, it simply inherits the disposable target/user environment prepared by the launcher and passes that environment through to the tests.

A test may use shared `rumiai-tests` libraries by locating them independently from its own position. Those libraries are not runner services.

## 6. Test -> runner contract

The contract is:

```text
combined stdout/stderr
exit status 0..3
```

```text
0 PASS
1 FAIL
2 SKIP
3 ERROR
```

Any other exit status or abnormal termination is recorded as `ERROR`, including the actually observed termination when possible.

## 7. Logging

The runner captures stdout and stderr into one stream equivalent to:

```sh
1>logfile 2>&1
```

The test log contains only test output. Global metadata, result and timing remain separate.

## 8. Runner responsibilities

The runner:

- locates the suite;
- validates the CLI;
- resolves the selection;
- performs canonical discovery and, in `--list` mode, emits that ordered discovery result without execution;
- collects host/session context for execution runs;
- executes each `.test` according to its shebang;
- captures the combined log;
- classifies the exit status;
- continues after an individual test FAIL/ERROR unless an infrastructure error prevents it;
- produces a summary;
- persists the run/session;
- performs snapshots when requested.

It does not semantically interpret output or failures to decide whether the target is correct.

## 9. Runner exit status

```text
0 SUCCESS
1 FAIL
2 TEST ERROR
3 RUNNER ERROR
```

- `0`: no FAIL/ERROR; PASS and SKIP may be present;
- `1`: at least one FAIL and no ERROR;
- `2`: at least one ERROR;
- `3`: the runner could not complete the run correctly.

Precedence:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

Runner status describes **the session**, not task validation. A task-scope launcher may consider a scope containing required SKIPs not validated even when the runner returns `0`.

An external interruption preserves normal signal semantics as far as possible (for example 130/143) and is not masked as semantic status 0..3.

## 10. Terminal output

During a serial run, the runner displays at least test-id and result. At the end it displays PASS/FAIL/SKIP/ERROR/TOTAL counts.

For FAIL/ERROR it may also display the relevant log.

## 11. Persistence

`--list` creates no persisted run.

Development run:

```text
.runs/<run-id>/
```

Completed validation run:

```text
sessions/<run-id>/
```

Run-id format:

```text
YYYYMMDDThhmmss+zzzz-PID
```

Base structure:

```text
<run-id>/
├── session
├── results
├── logs/
└── snapshots/   # only when requested
```

During validation, the directory initially exists as `sessions/.<run-id>/` and becomes visible only when the run completes.

Test FAIL/SKIP/ERROR does not make a session incomplete; a runner error may leave it hidden/incomplete.

A completed session is immutable.

## 12. `session` file

Format:

```text
key<TAB>value
```

It records at least, when applicable:

```text
type
start
end
selection
os
os-version
architecture
kernel
hostname
rumiai-tests-commit
runner-exit-status
```

The runner does not perform target discovery and does not invent generic target metadata.

## 13. `results` file

One record per test:

```text
result<TAB>test-id<TAB>observed-termination
```

Totals are derived, not stored as duplicated records.

`logs/` mirrors the test-id hierarchy; an empty log is valid.

## 14. Filesystem snapshot

The snapshot capability remains observational, explicit and optional. It is not a sandbox.

Snapshot outcomes:

```text
CLEAN
CHANGED
ERROR
```

`CHANGED` does not automatically change the test result. `ERROR` from a requested audit produces `RUNNER ERROR`.

Modes:

```text
metadata
hash
```

`hash` includes metadata plus SHA-256 of regular files.

Scopes:

```text
selection
test
both
```

Roots are provided through `--snapshot-root`, may be multiple and are canonicalized/recorded.

The runner excludes only the current run directory when it falls inside an observed root; it does not implicitly exclude `.git`, `sessions`, `rumiai-tests` or other areas.

Snapshots are persisted separately from logs and results.

## 15. Relationship with `rumiai-validate`

`rumiai-test` remains the only canonical runner.

`rumiai-validate` may:

- self-update the suite;
- use validation-scope configuration;
- prepare an independent disposable clone of the exact target revision together with isolated mutable user-state roots;
- invoke `rumiai-test --list` to expand selections canonically when per-test isolation is requested;
- invoke the runner one or more times, one selection per execution run;
- perform and retain the outer validation-environment filesystem audit;
- publish runner sessions and validation-level evidence;
- aggregate outcomes to determine whether the task scope is validated.

These target/environment responsibilities do not move into the runner.

## 16. Simplicity and portability

The runner must prefer linear representations, simple primitives and uniform behavior across hosts.

Small host-specific normalization is allowed only to implement runner capabilities such as filesystem metadata or SHA-256, without contaminating the test contract.
