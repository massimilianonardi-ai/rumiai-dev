# rumiai-tests suite realignment

Status: Complete
Updated: 2026-09-24

## Goal

Realign complete-product validation so the operator can validate the whole current product with one operation, while focused scopes such as `rumiai-validate mk` remain development conveniences rather than hidden prerequisite carriers.

## Final repository revisions

```text
rumiai-dev    2c0fdd51cbd5d56e7952fb3e762d52e839368638  (pre-final-snapshot HEAD)
rumiai-tests  280c0af57c84e95c91630983e2fc738354ce4a84
rumiai-os     d7cc1d463dfa1fb77a10cfa6fe3a4263a5ca2cb6
pkg-catalog   a642a1f4c8c6874abde9e85b894371b11468cf18
```

The `rumiai-os` HEAD above advanced after the last full-product health run cited below. This task does not claim that later product revision has passed a complete health validation; it closes the validation-suite redesign itself.

## Completed outcome

- Complete-product validation is first-class and the normal health scope represents the complete permanent `tests/` root.
- The normal current-product health scope is not pinned to a stale product commit.
- Validation scopes select tests only; execution prerequisites are suite-owned under `validation/requirements/`.
- `mk` has a current development scope selecting `rumiai-os/mk`, while its managed Node.js prerequisite is resolved automatically whether the tests are reached through `mk` or the complete-product path.
- Complete-product validation partitions the baseline from disjoint requirement-bearing groups and gives each requirement class its own disposable environment. This prevents Node.js prepared for `mk` from changing unrelated test preconditions.
- Missing or unpreparable declared prerequisites are validation errors rather than successful SKIPs.
- Runner exclusions are canonical set operations used by the validator; runner discovery remains single-sourced through `rumiai-test --list`.
- Hosted multi-host validation freezes one exact `rumiai-tests` revision and one exact `rumiai-os` revision before fan-out. The workflow uses the exact triggering suite revision, disables suite self-update and passes the same frozen product SHA to every host.
- `rumiai-validate` supports an invocation-level exact `--rumiai-os-commit=<commit>` override plus `--no-suite-update` for revision-coherent orchestration. Scope-level and invocation-level target pins are mutually exclusive.
- Permanent validator/runner self-tests protect discovery, exclusions, requirement resolution/grouping, target isolation, current-product target resolution, frozen revision behavior and evidence publication.
- Stale duplicate isolation-function definitions were removed; the current validator contains one definition of each isolation path.
- The health workflow triggers for changes to validator/runner logic, requirement metadata and all permanent tests.

## Final validation status

The current suite revision `rumiai-tests@280c0af57c84e95c91630983e2fc738354ce4a84` was exercised by hosted health run `35969903834` against frozen `rumiai-os@50cb1a6734f74bc8faa5296189e60c0e9cdc8bc0`.

macOS:

```text
baseline: 142 PASS / 4 FAIL / 12 SKIP / 0 ERROR / 158 total
mk requirement group: 11 PASS / 0 FAIL / 0 SKIP / 0 ERROR
```

The remaining baseline FAILs were product issues already represented as deferred work: branded bootstrap PATH, readable integrated command portability, `http-fetch` TTY progress and `osarch` compatibility entrypoints.

Ubuntu:

```text
baseline: 145 PASS / 3 FAIL / 10 SKIP / 0 ERROR / 158 total
requirement preparation: nodejs@v26.10.0 failed with upstream HTTP 403
```

The validator correctly stopped with infrastructure/preparation error instead of skipping `mk`. Therefore this particular Ubuntu run is not complete-product evidence. The baseline FAILs were branded bootstrap PATH, `osarch` compatibility entrypoints and the `pkg install` multi-operand contract mismatch.

Earlier hosted grouped runs and dedicated `mk` validation established successful automatic Node preparation and execution of all 11 permanent `mk` tests; the final macOS run above also executed all 11 with PASS.

The revision-coherent matrix mechanism itself was demonstrated in hosted run `35967138758`: both hosts reported the same frozen suite/product identity. Later run `35969903834` continued using that frozen mechanism on the current suite revision.

## Deferred product work

Current TODO ownership exists for the product failures exposed by the complete suite:

- `todo/branded-entrypoint-bootstrap-realignment.md`
- `todo/osarch-compatibility-entrypoints.md`
- `todo/macos-readable-integrated-command.md`
- `todo/macos-http-fetch-progress.md`
- `todo/pkg-install-best-effort-multi-operand.md`

These are product issues, not reasons to weaken or reopen the completed suite realignment.

## Consistency gate

Final consistency review confirmed:

- current canonical `TESTING.md` and `RUNNER.md` describe the implemented complete-product, requirement-group and frozen multi-host model;
- `validation/rumiai-os-health.conf` is a current unpinned health scope;
- `validation/mk.conf` is selection-only;
- `validation/requirements/mk.conf` owns the Node.js requirement;
- the current validator rejects prerequisite keys in task scopes;
- only one `run_validation_session_isolation` and one `run_validation_test_isolation` definition remain;
- the current workflow freezes revision identity before matrix fan-out;
- current `rumiai-tests` HEAD equals the suite revision exercised by the latest hosted health run;
- later concurrent `rumiai-os` changes were preserved and are not relabelled as validated by older evidence.

No task-local design, blocker or next action remains for this work unit.
