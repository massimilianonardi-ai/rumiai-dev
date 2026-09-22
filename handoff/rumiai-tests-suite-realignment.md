# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-22

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   2ca53e446691acd24c5ec4841cc390e29675c1e0  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-tests 2ad28a4516f47875020f34e46f249aba5ce27f74
rumiai-os    bdb66dde9e8fe45caef98c78f9084ed836232594
pkg-catalog  64d67a73f4f9485749e1b47712e42f77afb4773e
```

The `rumiai-dev` revision above is the authoritative source revision read before this handoff checkpoint; this handoff update itself advances that repository. Fresh HEAD retrieval remains mandatory before resumption.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- other routed subsystem specifications only when auditing their tests

## Fixed task-local choices

- Audit tests property-first: identify the current property and valid execution path before preserving or rewriting an assertion.
- Repository-adapter tests that call current public adapter-library functions with synthetic external-service responses are classified as library/unit evidence, not as proof of the composed public `pkg install` path.
- Live external tests remain host/upstream/revision-sensitive evidence and must not be interpreted as deterministic product-contract evidence merely because they are part of the root suite.

## Completed

- The validator-owned execution-environment redesign is canonical and implemented:
  - `rumiai-test --list` is the shared deterministic discovery interface;
  - direct execution uses the caller environment;
  - `rumiai-validate` creates an independent exact target clone plus isolated mutable user roots;
  - metadata filesystem audit is automatic;
  - both session and per-test isolation are implemented.
- Runner/validator self-tests cover discovery, isolation, scope orchestration and evidence publication.
- The historical `rumiai-os-fixture.lib` target-replica mechanism and its self-test were removed.
- Permanent tests were realigned to use the supplied target/environment rather than reconstructed RumiAI roots or replacement HOME environments.
- Core package tests were reclassified and rewritten around current public command/library interfaces; tests coupled mainly to private package helpers were removed.
- The shared package-release helper was reduced to public install/default/versions/runtime/HOME behavior; private concrete-layout inventory and fixed catalog-tree assertions were removed.
- Bootstrap and shell families were audited and realigned; current targeted scans show no reconstructed target/runtime or replacement-HOME pattern.
- `mk/materialize.test` no longer depends on the private staging pathname.
- The former `srv/lifecycle.test` PID-parser finding is superseded: the current test gets service PIDs from process-written markers and no longer contains that false-negative mechanism.
- Exact non-contractual diagnostic wording was removed from the audited digest, extract, http-fetch, log and package-install checks while preserving status/effect semantics.
- `extract/dispatch.test` and the remaining audited package/adapter tests use shared target discovery rather than local copies.
- Current external live tests no longer contain the audited replacement-HOME, synthetic-target, private-concrete-layout, fixed catalog-tree or known obsolete version-pin patterns.
- Chrome/Pulsar setuid and Java/Maven/NetBeans facility/dependency live evidence no longer reads private concrete paths. Successful composed integration is relied upon for setuid/facility/dependency materialization; Maven additionally executes through its public command and NetBeans checks its public command binding.
- `validation/rumiai-os-health.conf` remains the broad health-scope binding from the earlier checkpoint; pager-specific validation is independently bound by `validation/pager.conf` to `rumiai-os@ee7811a9ff9211ee0f6806447b115d0cdc00bf58`.
- The pager contract change was product work in `rumiai-os`; this suite task only realigned the affected permanent pager tests and validation binding.
- `rumiai-tests@e3f7d42f03747b924b18b7915f7d860d9148c913` adds `tests/rumiai-os/editor/contract.test` for the new standalone editor abstraction. It exercises the real `editor` entrypoint against controlled external editor backends and protects the `nano` -> `vim` -> `vi` preference, unchanged argument forwarding, backend-status propagation, standalone shebang/syntax and operational-manual presence.
- `rumiai-tests@8a78802f536ca65052ddb3a3bc4d152fb361ebf1` adds the `rumiai-os/readpass` permanent group and dedicated `readpass` validation scope/workflow. `contract.test` protects command class, shebangs, bootstrap independence, syntax, invocation status and mandatory manual presence. `pty.test` exercises the real `readpass` and `readpassv` entrypoints through a pseudo-terminal, including echo suppression, whitespace/backslash and `-n` preservation, terminal restoration after success and `SIGINT`, verification success and mismatch behavior.
- Formal `readpass` validation against `rumiai-os@826da364cd9aaaed05b30f2c4cdbe0c47c730782` passed on Linux/x86_64 and Darwin/arm64 with audit status `CLEAN`; both permanent tests passed on both hosts.
- A full-suite health validation was produced on 2026-09-22: outer validation `20260922T152932+0200-246048`, runner session `20260922T152933+0200-247370`, Linux/x86_64 (Ubuntu 24.04.5 LTS), `rumiai-tests@2ad28a4516f47875020f34e46f249aba5ce27f74`. It executed all 156 tests and recorded 34 PASS, 84 FAIL, 7 SKIP and 31 ERROR, aggregate status 2, audit status `CHANGED`.

## Current state

The first current full-suite runtime result is now available, but it does **not** establish current-product health.

The health scope `validation/rumiai-os-health.conf` in `rumiai-tests@2ad28a4516f47875020f34e46f249aba5ce27f74` is still bound to `rumiai-os@25ab0e5a5b8267af715f320bd9ee17405a2b41f6`. Current `rumiai-os` HEAD is `bdb66dde9e8fe45caef98c78f9084ed836232594`, 160 commits ahead of that configured target. The current suite therefore runs newly realigned/current tests against a substantially older product revision. Representative FAIL logs directly reflect that mismatch: current tests expect `editor`, `gitman`, `menu`, `readpass`, `vsed` and the current package-library layout, all absent from the configured old target.

The runner/validator infrastructure itself executed and its current self-tests passed in the full-suite session. The 31 ERROR results are not product failures: all 31 ERROR logs report `rumiai-os target helper is unavailable`. Representative source inspection shows an off-by-one suite-root derivation in affected tests, causing them to search for `lib/rumiai-os-target.lib` above the actual suite root even though the helper exists in the same suite revision.

The remaining 84 FAIL results cannot be treated as evidence that current `rumiai-os` is broken. Many are already explained by the stale target binding; the residual set must be re-run against the intended current target after the test-root defect is corrected, then classified property-first. External live tests remain separately sensitive to real host capabilities and upstream availability.

The full-suite result is therefore useful diagnostic evidence about the test system, but it is not a valid current RumiAI health verdict.

## Next action

1. Correct the affected permanent tests so suite-root/shared-helper discovery resolves the actual current `rumiai-tests` root.
2. Rebind `validation/rumiai-os-health.conf` to the intended current `rumiai-os` revision after a fresh HEAD check.
3. Re-run the complete health scope and classify every residual FAIL/ERROR/SKIP property-first before considering any product change.

## Blockers / open questions

- The current full-suite health scope is revision-stale relative to current `rumiai-os`, so its aggregate result cannot be interpreted as current-product health.
- The affected permanent tests have a suite-root discovery defect that must be corrected before their ERROR results can become meaningful.
