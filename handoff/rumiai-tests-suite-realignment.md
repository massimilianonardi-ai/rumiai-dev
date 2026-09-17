# rumiai-tests-suite-realignment

Status: Active
Updated: 2026-09-17 21:12 +02:00

## Goal

Audit the current permanent test suite and realign only evidence-confirmed legacy tests with the current authenticity, shared-infrastructure, minimality and complete-replica contracts.

## Current repository revisions

```text
rumiai-dev   dc137e2bffeab95664b0067ab72b9d8963b653cb
rumiai-tests 9eb8c7d2aadebde2cb7671ab84a2a3b313364119
rumiai-os    8b0c7991e8242dac73b0a350530a5100385294f3
```

These revisions are task state only; fresh HEAD retrieval remains required before later writes.

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
```

Current `rumiai-tests` implementation, shared test libraries and permanent tests are implementation/evidence sources.

## Fixed task-local choices

- This task activates `todo/rumiai-tests-suite-realignment.md`; the TODO and active handoff must not coexist after activation.
- The audit is suite-wide, but modifications are evidence-driven: existing tests are not rewritten merely because they are old.
- Shared `rumiai-tests` infrastructure is reused when its current contract matches; inline copies require a test-specific justification.
- Behavioral tests that need isolation must exercise the real target or a complete isolated replica through the real execution path; partial target reconstructions are not acceptable evidence for composed behavior.

## Completed

- Completed mandatory remote-HEAD preflight and current testing-source retrieval.
- Reconciled a concurrent `rumiai-dev` HEAD advance; it affected only the parallel `pkg-install-real-validation.md` handoff.
- Inspected current shared `lib/rumiai-os-target.lib` and `lib/rumiai-os-fixture.lib`.
- Confirmed legacy realignment candidates in `tests/rumiai-os/command/active-runtime-selection.test` and `tests/rumiai-os/srv/lifecycle.test`.

## Current state

`active-runtime-selection.test` still embeds historical copies of both target-discovery and isolated-root helpers even though current shared libraries own those responsibilities. `srv/lifecycle.test` contains its own target discovery and constructs a partial runtime by copying only selected target files and linking target libraries; this conflicts with the current complete-replica rule for the composed behavior it claims to exercise.

The suite-wide audit is still in progress; no assumption is made that other tests require modification until inspected against the current contracts.

The available auxiliary container cannot resolve `github.com`, so repository cloning and real test execution are unavailable there. GitHub-connected repository inspection and writes remain available. No runtime PASS/FAIL claim is made from static inspection.

## Next action

Complete the current-suite audit, classify evidence-confirmed candidates as keep/simplify/merge/remove, then apply the smallest coherent test/library realignment in `rumiai-tests`. Re-read the resulting diff and perform the strongest executable validation available; if real execution remains unavailable, record that limitation revision-specifically.

## Blockers / open questions

- A network-capable executable environment is not currently available in this chat for real test execution.
- No `rumiai-os` product change is authorized or assumed necessary by this test-suite task; any product defect discovered by real execution must be handled explicitly under the current product-change authorization rules.
