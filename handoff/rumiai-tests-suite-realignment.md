# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-22

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   ea6f1c68bb8affdcac179587d6c7d045665ed24c  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-tests 37fd46063c33d1b080c4b2da5fb23d53254241b9
rumiai-os    7e6d4483071eccd2acad670e4986a8ddb542df0b
pkg-catalog  8695de7ba57ad4da2b26692dc73aff6b63275e2a
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
- `rumiai-tests@828b739a717160ca2912f1e385e424492b19d81d` corrected the known off-by-one suite-root derivation in `tests/rumiai-os/bootstrap/current-layout.test`.
- The broad health binding was advanced again in `rumiai-tests@af74470aecf0106b2df07d6a13424c01a02e0670` to `rumiai-os@1973e4469ba40b5f085820ac018507ec8aca1873`, which triggered GitHub Actions health run `35781423515` on Ubuntu and macOS.
- Concurrent forward changes after that checkpoint were preserved: `rumiai-tests` advanced by two test-only commits realigning Chrome/Electron live command lookup, and the product/catalog repositories also advanced under parallel work.

## Current state

The original 31-ERROR suite-root defect and the original stale product binding are no longer the current blockers described by the first health run.

The new cross-host health run `35781423515` is executing from `rumiai-tests@af74470aecf0106b2df07d6a13424c01a02e0670` against the revision-pinned target `rumiai-os@1973e4469ba40b5f085820ac018507ec8aca1873`. At the latest checkpoint, both Ubuntu and macOS jobs were still inside the real `rumiai-validate rumiai-os-health` step, so no result from that run has yet been classified.

A local duplicate run could not be executed in the assistant container because that environment could not resolve `github.com`; this is an environment limitation and provides no product/test result.

Repositories continued to advance during the run. Current observed HEADs at this checkpoint are `rumiai-tests@37fd46063c33d1b080c4b2da5fb23d53254241b9`, `rumiai-os@7e6d4483071eccd2acad670e4986a8ddb542df0b` and `pkg-catalog@8695de7ba57ad4da2b26692dc73aff6b63275e2a`. The health run remains valid evidence only for its pinned revisions; it must not be relabelled as health evidence for later HEADs.

The two forward `rumiai-tests` commits after `af74470` change only Chrome/Electron live tests and must be preserved when continuing this task.

## Next action

1. Inspect the completed evidence from health run `35781423515` for both hosts and classify every residual FAIL/ERROR/SKIP property-first.
2. Apply only test-suite realignments supported by those logs; do not infer product defects from obsolete/private/non-contractual assertions.
3. Before launching a later current-HEAD health gate, fresh-check all involved HEADs and bind the health scope to the exact intended target revision; repository movement during an already-running revision-pinned validation does not invalidate that older run's evidence.
4. Preserve the concurrent Chrome/Electron live-test realignments already present at current `rumiai-tests` HEAD.

## Blockers / open questions

- No current result from health run `35781423515` had completed at the checkpoint, so residual failures cannot yet be classified from that run.
- Parallel product/catalog development is advancing HEAD while health validation is revision-pinned. This is not itself a validation defect, but a later health gate intended to describe then-current HEAD must be rebound after a fresh HEAD check.
