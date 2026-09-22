# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-22

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   df441ef486b1e80d3772a40542a94ad39f7ad21b  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-tests 8a78802f536ca65052ddb3a3bc4d152fb361ebf1
rumiai-os    826da364cd9aaaed05b30f2c4cdbe0c47c730782
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
- `rumiai-tests@e3f7d42f03747b924b18b7915f7d860d9148c913` adds `tests/rumiai-os/editor/contract.test` for the new standalone editor abstraction. It exercises the real `editor` entrypoint against controlled external editor backends and protects the `nano` -> `vim` -> `vi` preference, unchanged argument forwarding, backend-status propagation, standalone shebang/syntax and operational-manual presence.\n- `rumiai-tests@8a78802f536ca65052ddb3a3bc4d152fb361ebf1` adds the `rumiai-os/readpass` permanent group and dedicated `readpass` validation scope/workflow. `contract.test` protects command class, shebangs, bootstrap independence, syntax, invocation status and mandatory manual presence. `pty.test` exercises the real `readpass` and `readpassv` entrypoints through a pseudo-terminal, including echo suppression, whitespace/backslash and `-n` preservation, terminal restoration after success and `SIGINT`, verification success and mismatch behavior.\n- Formal `readpass` validation against `rumiai-os@826da364cd9aaaed05b30f2c4cdbe0c47c730782` passed on Linux/x86_64 and Darwin/arm64 with audit status `CLEAN`; both permanent tests passed on both hosts.

## Current state

The source/contract audit has no remaining proven false-negative mechanism from the historical finding list in the deterministic core families reviewed so far.

The pager group is aligned to the 2026-09-20 wrapper contract: `contract.test` checks the standalone command/manual surface and simple stdin/file delegation, while `delegation.test` exercises the real pager entrypoint against controlled external pager backends to verify `less` preference, `more` fallback, unchanged operand/stdin forwarding, caller-environment preservation and backend-status propagation. The superseded PTY-oriented `interactive.test` was removed.

The editor group now contains one proportional contract test covering its complete wrapper responsibility; the editor backends are external dependencies and are controlled only at that boundary, while the real RumiAI-owned `bin/sys/editor` entrypoint is executed unchanged.

Current package repository-adapter tests intentionally remain library/unit tests where they exercise public `pkg_repository_*` functions and model only the external HTTP/provider boundary. They must not be used as composed `pkg install` evidence.

The 19 current external live tests passed the latest targeted source scan for the historical isolation/private-layout/pinning anti-patterns. A fresh recheck of the newly added/changed Keycloak, Java, Maven, NetBeans, Pulsar, Chrome, Chromium, Electron and GraalVM live tests found no private concrete-layout reads, fixed external version/digest/catalog-tree pins, replacement HOME or synthetic target patterns. They remain intrinsically sensitive to real host capabilities and upstream availability.

`pkg-analyze` permanent tests still assert several report vocabulary tokens such as `useful-root`, `executable`, `launch-like` and `exit-status`. The current manual specifies the report's semantic purpose but not a machine-stable field vocabulary. This is a contract/test-design ambiguity, not a currently proven false negative.

No current full-suite runtime result has been produced by this chat. The available execution container still does not provide a normal live GitHub checkout path, so it is not used as full-suite evidence. The current tree now includes a dedicated `readpass` validation workflow in addition to the existing targeted workflows. The hosted `readpass` scope passed on Linux/x86_64 and Darwin/arm64 for `rumiai-tests@8a78802f536ca65052ddb3a3bc4d152fb361ebf1` against `rumiai-os@826da364cd9aaaed05b30f2c4cdbe0c47c730782`; that targeted result does not substitute for a full-suite health run.

## Next action

Run the current health scope through `rumiai-validate` in a real executable environment against the configured current product revision. Classify every non-PASS result property-first before considering a product change.

If source work resumes before such a run is available, only pursue newly evidenced contract/test mismatches; do not mechanically rewrite already-clean families.

The `pkg-analyze` report-vocabulary ambiguity should be revisited only if a failing test or a product/documentation change makes the stable report interface material.

## Blockers / open questions

- Current full-suite runtime validation is not executable from this chat environment, so no current suite PASS claim exists.
- No unresolved execution-environment design remains; the validator-owned model is already canonical and implemented.
