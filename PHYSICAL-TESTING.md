# RumiAI Physical Testing Rules

Status: **Current / canonical**  
Updated: 2026-09-17

This document defines physical validation on real reference hosts. General testing rules remain in `TESTING.md`; runner behavior remains in `RUNNER.md`.

## 1. Role

Physical validation is the **final confirmation stage** for a work unit whose preceding real executions and permanent tests already make success the expected outcome.

It is not the normal place to discover whether the product works for the first time.

Use development hosts, the ChatGPT Linux environment and GitHub-hosted runners earlier when they can expose correctness/portability defects without consuming the final physical gate.

The normal expectation is that most physical validations pass on the first attempt.

If functional defects are repeatedly discovered first during physical validation, treat that pattern as evidence that the earlier development/testing model is insufficient and strengthen it.

## 2. Reference hosts

The stable reference-host policy is defined in `TESTING.md`.

Current stable host classes are:

```text
macOS
Ubuntu 26.04 ARM64
```

A GitHub-hosted runner, AI-provided VM, headless display or other auxiliary environment is not physical validation of a stable host it did not physically exercise.

## 3. Exact revisions

Physical evidence is revision-specific.

Before a validation run, the relevant product/test repositories must be committed and the revisions that will be exercised must be known.

Do not relabel an old physical PASS as evidence for a later revision merely because the delta appears small. Reuse of earlier evidence must follow the proportional-validation rules and must preserve the exact property/revision claims actually established.

## 4. Normal physical session

Treat each command block as starting from a newly opened terminal with no assumed RumiAI CWD, PATH or environment.

The normal operator sequence is intentionally small:

```text
1. cd to the real rumiai-os checkout on that host
2. git pull --ff-only
3. cd to the real rumiai-tests checkout for that workspace
4. git pull --ff-only
5. invoke rumiai-test or rumiai-validate with the predeclared selection/scope
```

Conceptual form:

```sh
cd <rumiai-os-path-for-this-host>
git pull --ff-only
cd <rumiai-tests-path-for-this-host>
git pull --ff-only
./rumiai-test <selection>
```

or the corresponding `rumiai-validate` invocation when a validation scope is being published.

Host-local checkout paths are operational facts, not permanent-test contracts and must not be hardcoded into portable test logic.

## 5. Test-owned setup

Target-specific setup belongs in the `.test`, not in long manual shell recipes for the operator.

This includes as applicable:

```text
complete isolated replica creation
mutable-state isolation
HOME isolation
temporary directories
pseudo-terminal/input preparation
assertions
cleanup
```

The test must still exercise the real target or a complete real replica through the real execution path required by the claimed property.

A fixture/mock/redefined target component does not become valid merely because the overall run occurs on a physical host.

## 6. Interactive commands

If an exceptional manual diagnostic step reads directly from the terminal, that command must be the last command in the pasted block.

Do not append later shell commands after an interactive program that may consume queued terminal input.

Run later checks in a separate block after the interactive program terminates, and verify its status/state before assuming success.

The desired permanent form is still to automate reliable PTY/input behavior inside `rumiai-tests` whenever practical.

## 7. Validation scope

The required validation scope must be fixed before the physical run according to `TESTING.md`.

A required test that returns `SKIP` is not a PASS for that host/property.

Failures outside the declared task scope remain real evidence but do not automatically invalidate an unrelated work unit unless analysis shows that the work unit caused or depends on them.

The scope must not be narrowed after a failure merely to exclude a newly inconvenient dependency.

## 8. Evidence ownership

Executable/revision-specific validation evidence belongs to `rumiai-tests` and its validation/session mechanisms.

`rumiai-dev` defines the validation rules and expected contracts; it does not maintain a parallel chronological archive of old PASS transcripts in current documentation.

Historical physical-validation narratives remain available through Git history when needed for archaeology, but they are not loaded into normal current-task retrieval.

A formal evidence record should include at least the applicable:

```text
target revision(s)
rumiai-tests revision
selection/scope
host and architecture
date/time
individual results
runner/launcher status
logs or references to persisted logs
```

## 9. Failure feedback

When physical validation fails:

1. determine the concrete cause;
2. determine whether an earlier real development/hosted test could have exposed it;
3. if yes, strengthen the permanent test or earlier environment so the same class of failure moves earlier in the workflow;
4. correct the product/test contract forward-only;
5. rerun the proportional earlier checks before returning to physical validation.

Do not normalize repeated physical-only discovery as unavoidable host noise.

## 10. Documentation-only changes

Pure documentation/naming corrections normally do not require a fresh physical run unless they change observable execution, invalidate an existing test path or modify a validation procedure itself in a way that requires physical proof.

State accurately that no physical validation was run when none was required.

## 11. Invariants

```text
PHYS-01  physical validation is final confirmation, not first-line debugging
PHYS-02  stable-host evidence is host- and revision-specific
PHYS-03  the operator session stays minimal; scenario mechanics belong in tests
PHYS-04  physical execution does not legitimize mocked/replaced target behavior
PHYS-05  required SKIP is not PASS
PHYS-06  validation scope is fixed before execution and cannot be narrowed opportunistically
PHYS-07  executable evidence is owned by rumiai-tests/session mechanisms
PHYS-08  repeated physical-only failures require strengthening earlier testing
PHYS-09  Git/history/evidence remain forward-only and are never relabelled retroactively
```
