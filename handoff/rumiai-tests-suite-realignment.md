# rumiai-tests-suite-realignment

Status: Active
Updated: 2026-09-17 21:31 +02:00

## Goal

Audit the current permanent test suite and realign only evidence-confirmed legacy tests with the current authenticity, shared-infrastructure, minimality and complete-replica contracts.

## Current repository revisions

```text
rumiai-dev   d1ca9216d454f91c65d76af04b6df4ecf137757d
rumiai-tests d59a05417e91a97a10424f6dbc25047f9bfee383
rumiai-os    8c69d50bf675f6fab7ab447b71542c7808c988a8
```

These revisions are task state immediately before this checkpoint update; fresh HEAD retrieval remains required before later writes.

Concurrent forward movement was reconciled during this work unit. `rumiai-dev` changes after activation were confined to the parallel manual-documentation handoff. `rumiai-tests` gained `tests/rumiai-os/manual/interface.test` and `tests/rumiai-os/manual/paging.test` from that parallel workstream before this task's test commits; those files were preserved unchanged. The later `rumiai-os` advance from `8b0c7991e8242dac73b0a350530a5100385294f3` to `8c69d50bf675f6fab7ab447b71542c7808c988a8` added only `res/sys/manual/pkg`, `res/sys/manual/srv` and `res/sys/manual/state-path`; no runtime implementation used by these rewrites changed.

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
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/STATE-MODEL.md
```

Current `rumiai-tests/AUTHORING.md`, shared test libraries and permanent tests are implementation/evidence sources.

## Fixed task-local choices

- The original `todo/rumiai-tests-suite-realignment.md` was activated into this handoff and removed in the same activation commit.
- The audit is suite-wide, but modifications are evidence-driven: existing tests are not rewritten merely because they are old.
- Shared `rumiai-tests` infrastructure is reused when its current contract matches; inline copies require a test-specific justification.
- Behavioral tests that need isolation exercise the real target or a complete isolated replica through the real execution path; partial target reconstructions are not acceptable evidence for composed behavior.
- Test assertions protect current specified/public behavior rather than private runtime file layouts when those layouts are explicitly non-contractual.

## Implemented realignment

Two coherent tranches are committed in `rumiai-tests` after the concurrent manual-test commit `0428a21be8f9be05193e2533672aa8f7864dbd30`.

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

No `rumiai-os` product implementation file has been modified by this task.

## Audit evidence beyond the implemented tranches

Current inspection has confirmed additional local target-discovery duplication in at least these functional families:

```text
bootstrap
digest
extract
http-fetch
json
log
mk
pkg
read-key
```

Representative inspected files include `bootstrap/absolute-invocation.test`, `digest/cli.test`, `extract/dispatch.test`, `http-fetch/cli.test`, `json/structure.test`, `log/field-values.test`, `mk/materialize.test`, `pkg/dependency.test` and `read-key/pty.test`.

The remaining tests are not classified solely from family membership; each file still needs inspection before modification. Already-fixed `shell/selection.test` and `state-path/contract.test` were examples of local whole-runtime copy logic whose responsibility is now centralized in `lib/rumiai-os-fixture.lib`.

## Validation evidence obtained

- `sh -n` passed locally for the exact four tranche-1 rewritten shell tests before commit.
- `sh -n` passed locally for the exact two tranche-2 rewritten shell tests before commit.
- Each committed file was re-read from its resulting commit after the write.
- The aggregate comparison from `0428a21be8f9be05193e2533672aa8f7864dbd30` to `c028b9b9e1d432bcd83a2a8e4220fc10338b98d7` contained exactly the intended four tranche-1 files.
- The aggregate comparison from `c028b9b9e1d432bcd83a2a8e4220fc10338b98d7` to `d59a05417e91a97a10424f6dbc25047f9bfee383` contains exactly the intended tranche-2 files `shell/selection.test` and `state-path/contract.test`.
- Relevant current specifications and test-authoring/shared-helper contracts were rechecked before each rewrite.
- The final observed `rumiai-os` concurrent delta adds only manual-resource files and does not change runtime code exercised by the rewritten tests.
- The available auxiliary Linux container cannot resolve `github.com`, so repository cloning and real execution of the target tests are unavailable in this session. No runtime PASS/FAIL claim is made for the rewritten tests.

## Current state

Six evidence-confirmed legacy tests have been realigned, including the explicit partial-replica violation called out by the original TODO. The task remains Active because the suite-wide audit found further duplicated test infrastructure and because revision-specific runtime execution has not been obtained.

## Next action

Continue the suite-wide classification file by file. Migrate the next evidence-confirmed cohort to `lib/rumiai-os-target.lib` and, where isolation is required, `lib/rumiai-os-fixture.lib`; start with the already confirmed `read-key` candidate, then finish the inspected `bootstrap`, `digest`, `extract`, `http-fetch`, `json`, `log`, `mk` and `pkg` families. Preserve each test's distinct current property, merging/removing only where duplicate or non-contractual claims are established. Re-run syntax checks and the strongest real tests available after each coherent tranche.

## Blockers / open questions

- A network-capable executable environment is not currently available in this chat for real test execution.
- No `rumiai-os` product change is authorized or assumed necessary by this test-suite task; any product defect discovered by real execution must be handled explicitly under the current product-change authorization rules.
