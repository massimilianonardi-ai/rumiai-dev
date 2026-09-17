# rumiai-tests-suite-realignment

Status: Active
Updated: 2026-09-17 22:12 +02:00

## Goal

Audit the current permanent test suite and realign only evidence-confirmed legacy tests with the current authenticity, shared-infrastructure, minimality and complete-replica contracts.

## Current repository revisions

```text
rumiai-dev   3f98e108c499d41de8e6264375689b16a6ee0ce0
rumiai-tests bec37b4368f474dcb6ea8ef418af090384478df3
rumiai-os    e9cad50042e1b74613630af33bb239d34a855c99
```

These revisions are task state immediately before this checkpoint update; fresh HEAD retrieval remains required before later writes.

Concurrent forward movement has been reconciled throughout the task. `rumiai-tests` manual-test additions from the parallel documentation workstream were preserved unchanged. Later `rumiai-dev` and `rumiai-os` movement was confined to package-validation handoff updates and manual/pager documentation or implementation; no runtime implementation exercised by the command/language/service/shell/state/read-key/log/digest realignments changed after those tests were inspected. A prior `rumiai-os` package-path change remains relevant when the `pkg` cohort is audited and must be read at the then-current revision.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
RUNNER.md
TEST-PATTERNS.md
handoff/README.md
todo/README.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
specifications/rumiai-os/READ-KEY.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/STATE-MODEL.md
```

Current `rumiai-tests/AUTHORING.md`, shared test libraries and permanent tests are implementation/evidence sources. Current target implementation is read when needed to establish whether a fake represents an external boundary or replaces behavior claimed by the test.

## Fixed task-local choices

- The original `todo/rumiai-tests-suite-realignment.md` was activated into this handoff and removed in the same activation commit.
- The audit is suite-wide, but modifications are evidence-driven: existing tests are not rewritten merely because they are old.
- Shared `rumiai-tests` infrastructure is reused when its current contract matches; inline copies require a test-specific justification.
- Behavioral tests that need isolation exercise the real target or a complete isolated replica through the real execution path; partial target reconstructions are not acceptable evidence for composed behavior.
- Test assertions protect current specified/public behavior rather than private runtime file layouts when those layouts are explicitly non-contractual.
- Fake host utilities remain valid test boundaries when the real RumiAI component under test selects or drives those host utilities; they must not replace RumiAI components whose behavior the test claims to verify.

## Implemented realignment

Seventeen evidence-confirmed legacy tests have now been realigned across five coherent tranches.

### Tranche 1 — command, language and service lifecycle

- `tests/rumiai-os/command/active-runtime-selection.test`
  - removed historical inline copies of target discovery and isolated-root construction;
  - now uses current `lib/rumiai-os-target.lib` and `lib/rumiai-os-fixture.lib` while preserving the active-runtime selection property.
- `tests/rumiai-os/command/argument-shift.test`
  - removed the same historical helper copies;
  - now exercises argument forwarding on a complete isolated replica through the shared libraries.
- `tests/rumiai-os/lang/selection.test`
  - removed local target-discovery and full-copy fixture implementations;
  - now uses the shared target and complete-replica helpers while preserving the current language-selection checks.
- `tests/rumiai-os/srv/lifecycle.test`
  - removed custom target discovery and the partial runtime assembled from selected files plus a linked `lib` tree;
  - now starts from a complete isolated replica;
  - resolves lifecycle state via the real `state-path` command instead of hard-coding the private runtime metadata directory;
  - removes assertions/manipulation of private `pid`/`owner`/`command` files;
  - observes current lifecycle behavior through the public command: start, logging, idempotent start/stop, target canonicalization, same-service concurrency serialization, caller ownership and `-f`, SIGTERM normal stop, stale-state recovery caused by an externally terminated service, and failure of invalid/unavailable starts.

### Tranche 2 — shell and state-path

- `tests/rumiai-os/shell/selection.test`
  - removed local target-discovery functions and local whole-tree copy logic;
  - now uses the current target and complete-replica helpers while preserving explicit-shell and fallback-shell selection observations.
- `tests/rumiai-os/state-path/contract.test`
  - removed local target-discovery functions and the duplicated complete-runtime copy loop;
  - now uses the shared target and fixture helpers while preserving semantic-path, validation, user-binding and no-side-effect checks from `STATE-MODEL.md`.

### Tranche 3 — read-key

- `tests/rumiai-os/read-key/contract.test`
- `tests/rumiai-os/read-key/pty.test`

Both tests keep their distinct current properties and now source `lib/rumiai-os-target.lib` instead of embedding historical target-discovery copies. The Python PTY driver remains local to `pty.test`: it is test-specific infrastructure explicitly suitable for deterministic terminal-byte validation, not a duplicated RumiAI implementation and not a prompt/response case served by `lib/interactive.lib`.

### Tranche 4 — log

The five current log tests:

```text
tests/rumiai-os/log/field-values.test
tests/rumiai-os/log/invalid-fields.test
tests/rumiai-os/log/invalid-level.test
tests/rumiai-os/log/invalid-severity.test
tests/rumiai-os/log/severity-filter.test
```

retain their distinct observable logging properties and now source the shared target-discovery helper instead of maintaining five local copies of the same discovery responsibility.

### Tranche 5 — digest

The four current digest tests:

```text
tests/rumiai-os/digest/backends.test
tests/rumiai-os/digest/cli.test
tests/rumiai-os/digest/md5-backends.test
tests/rumiai-os/digest/sha512.test
```

now use the shared target-discovery helper. Fake checksum executables remain because they represent host backend capabilities selected by the real `bin/sys/digest`; the RumiAI command itself remains real.

`sha512.test` also contained an independent path bug: it derived `suite_root` as the `tests/` directory and therefore attempted to source `tests/lib/rumiai-os-target.lib`. The test now computes the actual suite repository root consistently with the other permanent tests before sourcing the helper.

During post-commit diff review, the first digest commit was found to have accidentally lengthened the fake SHA-256 `cksum` value in `backends.test`. That transcription regression was corrected immediately in the forward commit `bec37b4368f474dcb6ea8ef418af090384478df3`; the final committed fixture was re-read and contains the intended 64 hexadecimal characters.

No `rumiai-os` product implementation file has been modified by this task.

## Audit evidence beyond the implemented tranches

Additional duplicated target-discovery infrastructure remains in current families including:

```text
bootstrap
extract
http-fetch
json
mk
pkg
```

`http-fetch/backends.test` and `http-fetch/cli.test` have been fully inspected and are classified `simplify`: their local target-discovery copies should be replaced by `lib/rumiai-os-target.lib`, while their fake `curl`/`wget` programs should remain because they model external host backends selected by the real `bin/sys/http-fetch` command.

Representative remaining inspected files include `bootstrap/absolute-invocation.test`, `extract/dispatch.test`, `json/structure.test`, `mk/materialize.test` and `pkg/dependency.test`. Remaining files are not classified solely from family membership; each property still requires inspection before modification.

## Validation evidence obtained

- `sh -n` passed locally for the exact four tranche-1 rewritten shell tests before commit.
- `sh -n` passed locally for the exact two tranche-2 rewritten shell tests before commit.
- `sh -n` passed locally for both read-key rewritten shell tests before commit; this is syntax-only evidence for the shell wrapper and does not execute the Python PTY behavior.
- `sh -n` passed locally for all five rewritten log tests before their batch commit.
- `sh -n` passed locally for all four rewritten digest tests before their batch commit.
- The aggregate comparison from `d59a05417e91a97a10424f6dbc25047f9bfee383` to `bec37b4368f474dcb6ea8ef418af090384478df3` contains exactly the eleven files changed in tranches 3-5: two read-key, five log and four digest tests.
- The digest commit diff was re-read; the accidental SHA-256 fixture-length drift was detected by the consistency gate and corrected forward. The final `backends.test` content was then re-read from `bec37b4368f474dcb6ea8ef418af090384478df3`.
- Current `bin/sys/read-key`, `bin/sys/digest` and `bin/sys/http-fetch` implementations were inspected when classifying their permanent test boundaries.
- Relevant current specifications and test-authoring/shared-helper contracts were rechecked before the rewrites.
- Final concurrent `rumiai-dev` changes are confined to package-validation/manual/pager documentation. Final concurrent `rumiai-os` changes after the digest/http-fetch inspection add or modify only manual/pager files and do not change the runtime code exercised by the completed cohorts.
- The available auxiliary Linux container cannot resolve `github.com`, so repository cloning and real execution of the target tests are unavailable in this session. `rumiai-tests` has no current GitHub Actions workflow available as an existing execution route. No runtime PASS/FAIL claim is made for the rewritten tests.

## Current state

Seventeen legacy tests have been realigned. The explicit partial-replica violation from the original TODO is gone, multiple generations of copied target/fixture infrastructure have been reduced, and one independently broken permanent test (`digest/sha512.test`) has been repaired.

The task remains Active because the suite-wide audit still has confirmed and unclassified legacy infrastructure, and revision-specific runtime execution has not been obtained.

## Next action

Start with the already classified `http-fetch` pair and replace only their local target-discovery copies. Then continue file-by-file through `json`, `extract`, `mk`, `bootstrap` and `pkg`, reading the current target contract/implementation for each cohort before deciding `keep`, `simplify`, `merge` or `remove`. Re-read the current package path before any `pkg` test change because that implementation moved concurrently during this task.

After each coherent tranche, run syntax checks, re-read the committed diff, reconcile any concurrent HEAD movement and use the strongest real execution environment available.

## Blockers / open questions

- A network-capable executable environment is not currently available in this chat for real test execution.
- No current GitHub Actions workflow exists in `rumiai-tests` to provide an already-approved executable fallback from this session.
- No `rumiai-os` product change is authorized or assumed necessary by this test-suite task; any product defect discovered by real execution must be handled explicitly under the current product-change authorization rules.
