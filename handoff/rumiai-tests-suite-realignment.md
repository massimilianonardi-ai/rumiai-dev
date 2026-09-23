# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-23

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   d268c4be5d1a93acc415ab24d39daf8ca4bf27de  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-tests 91290e23b7c7a26aaa8c5419e7b7e7c1769ca64d
rumiai-os    58d797ac8d286f54420b279713c431ce97c1d53a
pkg-catalog  6a77995d317f2ec08c98585c4462b92557ccfaea
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

The historical 31-ERROR suite-root failure and the later package/srv fixture cascade are resolved as test-suite defects. The current Ubuntu evidence is now concentrated rather than noisy.

Health run `35825284621` was triggered from `rumiai-tests@af30a9a528b6dff8416c131b8fb10e4bc0557a0e` against `rumiai-os@f2747e16560d0fbbe1cc0fe6e4d5c6c836ef041b`. Its Ubuntu job completed with 146 PASS / 4 FAIL / 14 SKIP / 0 ERROR. Its macOS job was still running at this checkpoint. That run includes the bootstrap/command executable-fixture fixes and MacGPG mode fix, but predates the later menu, pipefail-prerequisite and shared-osarch-discovery commits.

Two residual failures are already classified as current product/spec mismatches rather than stale tests:

- `bootstrap/branded-path-prepend.test`: the current branded-entrypoint implementation recursively re-enters `m` until PATH/environment growth causes execution failure, while `BOOTSTRAP-ENVIRONMENT.md` still requires branded activation to delegate to `m`, prepend the AI executable layers and enter the shell.
- `osarch/update.test`: `CURRENT-MODEL.md` still requires compatibility commands `osarch-update` and `osarch-set`, while the current product exposes only the consolidated `osarch` command.

`pkg/uninstall.test` now reaches its intended package setup but fails while selecting an osarch-specific current/default version before the uninstall operation. It must be classified against the current public package-default contract before any test rewrite.

The current branch contains additional realignments after the running gate: terminal-width-independent menu interaction, pipefail prerequisite classification and shared osarch target discovery. A later current-HEAD health gate is therefore still required before closure.

The assistant execution container still cannot resolve `github.com`; local duplicate runs there are unavailable and must not be reported as validation evidence.

## Next action

1. Inspect the completed macOS evidence from health run `35825284621`; classify only the residual failures after the executable-fixture fixes.
2. Classify `pkg/uninstall.test` against the current package/default implementation and public contract without bypassing a genuine product defect.
3. Run a fresh current-HEAD cross-host health gate including `56f44d4a`, `81b2649d` and `91290e23` after a new HEAD check and exact target binding.
4. Preserve real product/spec mismatches as failing evidence; do not make the suite green by weakening `branded-path`, `osarch` compatibility or another settled contract.
5. Perform the final consistency gate and synchronize this handoff again before reporting completion.

## Blockers / open questions

- The macOS half of health run `35825284621` had not completed at this checkpoint.
- `pkg/uninstall.test` still fails during setup when selecting an osarch-specific package default; the exact source of that failure remains to be classified.
- The macOS behavior of the dedicated readable/non-executable integrated-command test and of `http-fetch/progress.test` must be judged from the current post-fixture health evidence rather than from the obsolete broad-failure run.
- External live tests remain host/upstream-sensitive; failures such as upstream HTTP errors are evidence about that live validation attempt, not automatically deterministic RumiAI product-contract failures.
- Parallel product/catalog development can advance HEAD during validation. Every health result remains revision-specific, and a final current-HEAD gate must be rebound after a fresh HEAD check.
