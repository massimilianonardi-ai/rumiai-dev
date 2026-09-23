# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-23

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   249d06c00ae6732f3555aa4bd3e21c525ae7eba2  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-tests f51de6247535f87a2e61d03a087c1d8d8ac57e42
rumiai-os    5f01f0bccef37020057195c98809ba492f02443c
pkg-catalog  da7507439b71737cf4a40d85cac059824e4b9a63
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

- `rumiai-tests@0de32c1d78da8ab764f9e011f0347564f38a9646` corrected the executable modes of the new `pkg-extract/dmg-pkg.test` and `pkg-repository-gpgtools/contract.test`; a whole-tree mode audit later found no remaining `.test` blob outside mode `100755`.
- `rumiai-tests@f690ba79847c31df2808b4b283350069c77fa739` realigned 13 synthetic package/srv integration fixtures with the current mandatory package-range `format` metadata. Health run `35824640188` confirmed the former package/srv cascade was removed on Ubuntu: `pkg-integration`, `pkg-launch`, default/dependency/env/facility/state/versions and all four `srv` tests passed.
- `rumiai-tests@d43848bb96d035f445caa43948eada5d7261f88f` and `rumiai-tests@7a7b5fd58481ae40d236590a61648407343eb342` removed accidental non-executable-command assertions from bootstrap, command, log and osarch fixtures. The dedicated `command/explicit-source-readable.test` remains the only intentional readable/non-executable integrated-command test.
- `rumiai-tests@0ee770c633ce89296edd617734221db6365b9052` made the new MacGPG live test executable; Ubuntu health now classifies it as the intended platform SKIP rather than infrastructure ERROR.
- `rumiai-tests@56f44d4a183fce0da1eb34daea6360b341d62dbf` made filesystem-menu dialogue synchronization independent of the full temporary pathname so terminal-width truncation on macOS is not mistaken for a navigation failure.
- `rumiai-tests@81b2649ddc79b509e4485505c6966094c3ca5881` classified absence of the documented `set -o pipefail` shell capability as a prerequisite SKIP for `enc/encoded-file-edit.test`, rather than a function-contract FAIL on hosts whose `/bin/sh` does not yet provide that POSIX.1-2024 option.
- `rumiai-tests@91290e23b7c7a26aaa8c5419e7b7e7c1769ca64d` removed the remaining private target-discovery copy from `osarch/detection.test` and uses `lib/rumiai-os-target.lib`.
- Health run `35824640188`, `rumiai-tests@fa5e811b84954e734e1b3fde4b0bb946998fa80e` against `rumiai-os@f2747e16560d0fbbe1cc0fe6e4d5c6c836ef041b`, completed on Ubuntu with 146 PASS / 4 FAIL / 14 SKIP / 0 ERROR across 164 tests. The four FAILs were `bootstrap/branded-path-prepend.test`, `enc/encoded-file-edit.test`, `osarch/update.test`, and `pkg/uninstall.test`; the first and third match current product/spec mismatches, the second is already realigned in the current suite as described above, and the fourth remains under classification.

## Current state

The historical 31-ERROR suite-root failure, the package/srv fixture cascade, the accidental non-executable probe coupling, the MacGPG test mode defect, menu terminal-width coupling, the unsupported-shell pipefail classification and the former `pkg/uninstall.test` setup mismatch have all been resolved as test-suite issues.

Current permanent evidence is now concentrated. Health run `35840466032` (`rumiai-tests@c6b218840ea14d71334e4c6b97fd0043622ae34f` against `rumiai-os@e856f31039f1c42820f920837e7c1d471396ca04`) completed with:
- Ubuntu/x86_64: 143 PASS / 3 FAIL / 17 SKIP / 0 ERROR across 163 tests.
- macOS/arm64: 131 PASS / 13 FAIL / 19 SKIP / 0 ERROR across 163 tests.
- `pkg/uninstall.test` passes on both hosts in that gate.
- deterministic residual failures are already separated from test realignment: branded entrypoint bootstrap recursion/state growth, missing public `osarch-set`/`osarch-update` compatibility entrypoints, macOS readable/non-executable integrated-command dispatch, and macOS `http-fetch -o` TTY progress. Each has a current dedicated TODO under `todo/`.
- the remaining external live failures are host/upstream-sensitive observations, predominantly HTTP 403/timeout failures; they are not evidence that the permanent test mechanics are stale.

A later exact current-head gate was required because parallel `mk` work advanced both the suite and product revision. `rumiai-tests@f51de6247535f87a2e61d03a087c1d8d8ac57e42` therefore binds `rumiai-os-health` to `rumiai-os@5f01f0bccef37020057195c98809ba492f02443c` and triggered GitHub Actions run `35842193417`.

The Ubuntu half of run `35842193417` is complete: outer validation `20260923T091901+0000-2292`, runner session `20260923T091902+0000-3752`, Ubuntu 24.04.5 LTS / Linux x86_64. It executed 164 tests and recorded 136 PASS / 10 FAIL / 18 SKIP / 0 ERROR, aggregate status 1 and audit status `CHANGED`. The only deterministic/non-live FAILs are the already-classified `bootstrap/branded-path-prepend.test` and `osarch/update.test`. The other eight FAILs are external live tests, and every inspected failure is an HTTP 403 from the live upstream path. No new test-suite defect is exposed by this current-head Ubuntu evidence.

The macOS half of run `35842193417` is still executing at this checkpoint, so this task remains Active. Closure requires reading that exact revision-pinned macOS result; a previous macOS gate cannot be relabelled as evidence for the later `f51de624/5f01f0bc` pair.

The assistant execution container still cannot resolve `github.com`; no local duplicate run is being counted as validation evidence.

## Next action

1. Read the completed macOS result of GitHub Actions run `35842193417`.
2. If it exposes no new test-suite defect, classify its residuals against the already-created TODOs/live-upstream category and complete the suite-realignment handoff.
3. Perform the final consistency gate against fresh remote HEADs, record the final Complete handoff snapshot, then remove the completed handoff in a later forward commit as required by the handoff lifecycle.
4. If macOS instead exposes a new permanent-test defect, fix only that test/infrastructure issue, preserve product mismatches, and rerun the smallest sufficient cross-host evidence before closure.

## Blockers / open questions

- The macOS job of final current-head health run `35842193417` is still in progress.
- Product/runtime mismatches discovered by this task are intentionally deferred and already represented by current TODOs: `branded-entrypoint-bootstrap-realignment.md`, `osarch-compatibility-entrypoints.md`, `macos-readable-integrated-command.md`, and `macos-http-fetch-progress.md`.
- Live package tests remain subject to real external service availability/rate limits; current HTTP 403 observations are retained as live evidence rather than converted into deterministic suite failures.
