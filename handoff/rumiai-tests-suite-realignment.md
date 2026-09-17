# rumiai-tests-suite-realignment

Status: Active
Updated: 2026-09-17 21:23 +02:00

## Goal

Audit the current permanent test suite and realign only evidence-confirmed legacy tests with the current authenticity, shared-infrastructure, minimality and complete-replica contracts.

## Current repository revisions

```text
rumiai-dev   8e127cb00271e76822a5c7d3301a59e8a7be91c9
rumiai-tests c028b9b9e1d432bcd83a2a8e4220fc10338b98d7
rumiai-os    8b0c7991e8242dac73b0a350530a5100385294f3
```

These revisions are task state only; fresh HEAD retrieval remains required before later writes.

Concurrent forward movement was reconciled during this work unit. `rumiai-dev` changes after activation were confined to the parallel manual-documentation handoff. `rumiai-tests` gained `tests/rumiai-os/manual/interface.test` and `tests/rumiai-os/manual/paging.test` from that parallel workstream before this task's test commits; those files were preserved unchanged.

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
```

Current `rumiai-tests/AUTHORING.md`, shared test libraries and permanent tests are implementation/evidence sources.

## Fixed task-local choices

- The original `todo/rumiai-tests-suite-realignment.md` was activated into this handoff and removed in the same activation commit.
- The audit is suite-wide, but modifications are evidence-driven: existing tests are not rewritten merely because they are old.
- Shared `rumiai-tests` infrastructure is reused when its current contract matches; inline copies require a test-specific justification.
- Behavioral tests that need isolation exercise the real target or a complete isolated replica through the real execution path; partial target reconstructions are not acceptable evidence for composed behavior.
- Test assertions should protect current specified/public behavior rather than private runtime file layouts when those layouts are explicitly non-contractual.

## Implemented realignment

The first coherent tranche is committed in `rumiai-tests` between `0428a21be8f9be05193e2533672aa8f7864dbd30` and `c028b9b9e1d432bcd83a2a8e4220fc10338b98d7` and changes exactly four files:

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
  - observes the public/current lifecycle properties instead: start, logging, idempotent start/stop, target canonicalization, same-service concurrency serialization, caller-ownership behavior and `-f`, SIGTERM normal stop, stale-state recovery caused by an externally terminated service, and failure of invalid/unavailable starts.

No `rumiai-os` product file has been modified.

## Audit evidence beyond the first tranche

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
shell
state-path
```

Representative inspected files include `bootstrap/absolute-invocation.test`, `digest/cli.test`, `extract/dispatch.test`, `http-fetch/cli.test`, `json/structure.test`, `log/field-values.test`, `mk/materialize.test`, `pkg/dependency.test`, `read-key/pty.test`, `shell/selection.test` and `state-path/contract.test`.

`shell/selection.test` and `state-path/contract.test` also contain local complete-copy fixture implementations matching the responsibility already owned by `lib/rumiai-os-fixture.lib`; they are current `simplify` candidates. The remaining tests are not classified solely from family membership; each file still needs inspection before modification.

## Validation evidence obtained

- `sh -n` passed locally for the exact four rewritten shell-test contents before they were committed. This is syntax-only evidence.
- Each committed file was re-read from its resulting commit after the write.
- The aggregate comparison from `0428a21be8f9be05193e2533672aa8f7864dbd30` to `c028b9b9e1d432bcd83a2a8e4220fc10338b98d7` contains exactly the intended four files.
- The relevant current specifications and test-authoring/shared-helper contracts were rechecked before the rewrite.
- The available auxiliary Linux container cannot resolve `github.com`, so repository cloning and real execution of the target tests are unavailable in this session. No runtime PASS/FAIL claim is made for the rewritten tests.

## Current state

The first evidence-confirmed legacy cohort has been realigned, including the explicit partial-replica violation called out by the original TODO. The task remains Active because the suite-wide audit found further duplicated test infrastructure and because revision-specific runtime execution has not been obtained.

## Next action

Continue the suite-wide classification file by file. Migrate the next evidence-confirmed cohort to `lib/rumiai-os-target.lib` and, where isolation is required, `lib/rumiai-os-fixture.lib`; start with the already confirmed `read-key`, `shell` and `state-path` candidates, then finish the inspected functional families. Preserve each test's distinct current property, merging/removing only where duplicate or non-contractual claims are established. Re-run syntax checks and the strongest real tests available after each coherent tranche.

## Blockers / open questions

- A network-capable executable environment is not currently available in this chat for real test execution.
- No `rumiai-os` product change is authorized or assumed necessary by this test-suite task; any product defect discovered by real execution must be handled explicitly under the current product-change authorization rules.
