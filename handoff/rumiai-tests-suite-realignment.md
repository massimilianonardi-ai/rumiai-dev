# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-20

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   5e9afbb1380b34674fbfac49b77291a30419956c
rumiai-tests 818ff15403efe62ba56e40ed76f1e9c829a25dcf
rumiai-os    ee7811a9ff9211ee0f6806447b115d0cdc00bf58
pkg-catalog  5372c160441b0346b976db7f7a022196784c9425
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

## Current state

The source/contract audit has no remaining proven false-negative mechanism from the historical finding list in the deterministic core families reviewed so far.

The pager group is aligned to the 2026-09-20 wrapper contract: `contract.test` checks the standalone command/manual surface and simple stdin/file delegation, while `delegation.test` exercises the real pager entrypoint against controlled external pager backends to verify `less` preference, `more` fallback, unchanged operand/stdin forwarding, caller-environment preservation and backend-status propagation. The superseded PTY-oriented `interactive.test` was removed.

Current package repository-adapter tests intentionally remain library/unit tests where they exercise public `pkg_repository_*` functions and model only the external HTTP/provider boundary. They must not be used as composed `pkg install` evidence.

The 19 current external live tests passed the latest targeted source scan for the historical isolation/private-layout/pinning anti-patterns. A fresh recheck of the newly added/changed Keycloak, Java, Maven, NetBeans, Pulsar, Chrome, Chromium, Electron and GraalVM live tests found no private concrete-layout reads, fixed external version/digest/catalog-tree pins, replacement HOME or synthetic target patterns. They remain intrinsically sensitive to real host capabilities and upstream availability.

`pkg-analyze` permanent tests still assert several report vocabulary tokens such as `useful-root`, `executable`, `launch-like` and `exit-status`. The current manual specifies the report's semantic purpose but not a machine-stable field vocabulary. This is a contract/test-design ambiguity, not a currently proven false negative.

No current full-suite runtime result has been produced by this chat. A fresh 2026-09-20 probe again confirmed that the available execution container cannot resolve `github.com`, so it cannot materialize the current repositories through Git. The current tree contains only the package-provider/facility bridge workflow; no pager or general health workflow was available for this checkpoint. Historical or unrelated workflow results must not be relabelled as validation of the current HEADs.

## Next action

Run the current health scope through `rumiai-validate` in a real executable environment against the configured current product revision. Classify every non-PASS result property-first before considering a product change.

If source work resumes before such a run is available, only pursue newly evidenced contract/test mismatches; do not mechanically rewrite already-clean families.

The `pkg-analyze` report-vocabulary ambiguity should be revisited only if a failing test or a product/documentation change makes the stable report interface material.

## Blockers / open questions

- Current full-suite runtime validation is not executable from this chat environment, so no current suite PASS claim exists.
- No unresolved execution-environment design remains; the validator-owned model is already canonical and implemented.
