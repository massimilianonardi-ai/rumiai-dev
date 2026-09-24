# rumiai-tests suite realignment

Status: Active
Updated: 2026-09-24

## Goal

Realign the permanent RumiAI test suite so that failures are evidence about current contracted behavior rather than false negatives caused by obsolete implementation coupling, reconstructed targets, private-layout assumptions, stale revision binding or non-contractual diagnostics.

## Current repository revisions

```text
rumiai-dev   9da67ab98ee543111cea2cb65d30529db14b0b07  (pre-checkpoint HEAD)
rumiai-tests 21556a6230048a2973530a5c4523c43450b97594
rumiai-os    7d5a1c75b4e40b60c3a831edf2aa2b9d3da04f6a  (current HEAD at this checkpoint)
pkg-catalog  be0ecd84afc65699d55225b1aa4adaa3b6c20a54
```

The `rumiai-dev` revision above is the authoritative source revision read before this handoff checkpoint; this update itself advances that repository. Fresh HEAD retrieval remains mandatory before resumption.

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
- The user-facing full-product validation contract is now promoted in `TESTING.md` and `RUNNER.md`: the normal health path resolves current committed `rumiai-os` HEAD, discovers the whole permanent suite, resolves suite-owned execution requirements automatically, and does not require the operator to compose task scopes.
- `rumiai-tests` now has `validation/requirements/mk.conf` for `nodejs@v26.10.0`, a current `validation/mk.conf` selector, and an unpinned `validation/rumiai-os-health.conf` for current-product validation.
- Runner exclusion support was added so complete-product validation can execute a baseline without requirement-bearing tests and then execute each disjoint requirement group in a separately prepared environment; this prevents a prerequisite such as Node.js from changing the starting conditions of unrelated tests such as the Node.js release test.
- A first hosted full-product run confirmed the original defect was removed: all 11 permanent `mk` tests executed and passed after automatic Node.js preparation, while the same full run exposed failures in unrelated product areas.
- Consistency review then found stale duplicate definitions of `run_validation_session_isolation` and `run_validation_test_isolation` later in `lib/sh/rumiai-validate.lib.sh`; POSIX shell last-definition semantics silently restored the old single-environment behavior. `rumiai-tests@49c4e51f8134a9c52c866d293aaedd20dd3e7f40` removed those stale overrides.
- `rumiai-tests@386328536f06ec41fa1f04d61c49e76d2e7c6e96` initialized the validation-evidence fixture required by `environment-isolation.test` after target preparation began recording `target-osarch`.
- `rumiai-tests@f18bec19ae34eaa9b33af888798fae48ef0a8241` extends the requirement-resolution self-test to protect the complete grouped execution shape: baseline environment without Node, `mk` excluded from that baseline, then an independent Node-prepared environment containing the `mk` tests.
- The current permanent suite contains 169 tests, including exactly 11 under `tests/rumiai-os/mk/`.
- Hosted run `35965239854` demonstrated the grouped full-product execution on both hosted systems: the baseline excluded all 11 `mk` tests, `external/nodejs/release-live.test` returned PASS from the Node-free baseline, and the separate Node-prepared requirement group executed all 11 `mk` tests with PASS. Validator self-tests `environment-isolation.test` and `requirements-resolution.test` also returned PASS after their fixture corrections.
- `extract/dispatch.test` was realigned with the current DMG native-backend precondition (`ditto + plutil + diskutil|hdiutil`) and returned PASS on Ubuntu and macOS in run `35965239854`.
- That run also exposed a cross-host evidence defect: Ubuntu and macOS independently updated the product source checkout and therefore validated different `rumiai-os` commits while belonging to the same matrix run.
- Canonical `TESTING.md` now requires one exact `rumiai-tests` revision and one exact `rumiai-os` revision per multi-host validation. The product revision is resolved once before fan-out; repository advancement during the run belongs to a later validation.
- `rumiai-validate` now supports `--rumiai-os-commit=<commit>` as an invocation-level exact target override and `--no-suite-update` to preserve an already-frozen suite revision. Scope-level and invocation-level product pins are mutually exclusive. Permanent launcher self-tests cover both semantics.
- The health workflow now has a `resolve-product` job, checks out the exact triggering suite revision on every host, disables suite self-update and passes the same resolved product commit to every matrix job.
- GitHub Actions run `35967138758` is the first revision-coherent hosted full-product validation of this redesign; it uses `rumiai-tests@21556a6230048a2973530a5c4523c43450b97594`. The exact frozen product SHA will be confirmed from both matrix job transcripts before closure.
- The prior Ubuntu `pkg/install-live.test` failure protects the current `PACKAGE-MODEL.md` best-effort multi-operand install contract: an invalid operand must not prevent a later valid independent operand from being attempted. If it reproduces on the frozen current-product run, it is a product defect/deferred item rather than a stale test.

## Current state

The complete-product/current-target redesign and requirement-group isolation are implemented and mechanically demonstrated.

The remaining validation-specific issue from the previous checkpoint—different product revisions entering different matrix hosts—has now been corrected structurally. A multi-host run has one frozen suite/product revision identity; hosts cannot silently substitute a newer repository HEAD after fan-out.

Run `35967138758` is currently exercising that exact mechanism. The run must complete before this work unit can be closed. Its two matrix jobs must report the same `rumiai-tests` SHA and the same `rumiai-os` SHA, the validator/runner self-tests must remain clean, and the 11 `mk` tests must continue to execute in the Node-prepared requirement group.

Known current product failures that are already represented outside this task include branded bootstrap PATH recursion, `osarch` compatibility entrypoints, macOS readable integrated commands and macOS `http-fetch` progress. They must remain visible as product evidence rather than being weakened in the suite.

## Next action

1. Inspect run `35967138758` on hosted Ubuntu and macOS and confirm identical suite/product revision identity.
2. Classify the remaining FAIL/SKIP set against current contracts; create/update minimal TODO only for newly confirmed out-of-scope product defects not already represented.
3. Re-read the final `rumiai-tests` diff and canonical testing contracts, confirm no superseded scope-owned-prerequisite or non-coherent matrix mechanism remains, and run the final consistency gate.
4. If the suite realignment is complete, write a final `Status: Complete` handoff snapshot and remove the handoff in a later forward commit.

## Blockers / open questions

None at this checkpoint.
