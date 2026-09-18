# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-18

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   76b7704453d050f585073f264801f68168688c9e
rumiai-tests 20f04ab2665fdb0c7310226f57a12a39b701f212
rumiai-os    25ab0e5a5b8267af715f320bd9ee17405a2b41f6
pkg-catalog  8407f2308cf0c5e7bdc3abd8aeb9538410e55b90
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
- `validation/rumiai-os-health.conf` is aligned to current `rumiai-os` revision `25ab0e5a5b8267af715f320bd9ee17405a2b41f6`.
- This task has not modified `rumiai-os` product implementation.

## Current state

The source/contract audit has no remaining proven false-negative mechanism from the historical finding list in the deterministic core families reviewed so far.

Current package repository-adapter tests intentionally remain library/unit tests where they exercise public `pkg_repository_*` functions and model only the external HTTP/provider boundary. They must not be used as composed `pkg install` evidence.

The 19 current external live tests passed the latest targeted source scan for the historical isolation/private-layout/pinning anti-patterns. They remain intrinsically sensitive to real host capabilities and upstream availability.

`pkg-analyze` permanent tests still assert several report vocabulary tokens such as `useful-root`, `executable`, `launch-like` and `exit-status`. The current manual specifies the report's semantic purpose but not a machine-stable field vocabulary. This is a contract/test-design ambiguity, not a currently proven false negative.

No current full-suite runtime result has been produced by this chat. The repository has no persistent GitHub Actions workflow that can be dispatched through the available connector, and the local execution environment has not provided a network-capable current checkout. Historical or package-matrix Actions results must not be relabelled as validation of the current HEADs.

## Next action

Run the current health scope through `rumiai-validate` in a real executable environment against the configured current product revision. Classify every non-PASS result property-first before considering a product change.

If source work resumes before such a run is available, only pursue newly evidenced contract/test mismatches; do not mechanically rewrite already-clean families.

The `pkg-analyze` report-vocabulary ambiguity should be revisited only if a failing test or a product/documentation change makes the stable report interface material.

## Blockers / open questions

- Current full-suite runtime validation is not executable from this chat environment, so no current suite PASS claim exists.
- No unresolved execution-environment design remains; the validator-owned model is already canonical and implemented.
