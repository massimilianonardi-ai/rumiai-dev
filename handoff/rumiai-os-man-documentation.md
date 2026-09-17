# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design remains a separate architecture problem whose build orchestration belongs to `mk`.

The current first-delivery completion scope also includes mandatory operational-manual coverage for every RumiAI-owned directly executable command identity and permanent structural coverage that detects missing command manual topics.

## Current repository revisions

```text
rumiai-dev   45defc6f76743cf204790048ff2b0e2157c797df  (current remote HEAD before this handoff checkpoint; includes concurrent unrelated documentation/test-workflow changes)
rumiai-os    14e413342261b23df840f40b355166c4d55f1b41  (manual -> pager separation plus Linux less preference with more fallback)
rumiai-tests fbb6a95d1c90a723366f8b78a9cd08ae57dfc45d  (last inspected remote HEAD from parallel test-suite work; not modified by this pager work unit)
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
RUNNER.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/CURRENT-MODEL.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/PAGER.md
specifications/rumiai-os/RESOURCE-MODEL.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/MK.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
handoff/README.md
```

The promoted first-delivery documentation contract lives in `DOCUMENTATION-MODEL.md`, `COMMAND-ENTRYPOINTS.md` and `RESOURCE-MODEL.md`. The host-normalizing terminal paging contract lives in `PAGER.md`; it is not duplicated here.

## Fixed task-local choices

- No task-local exception exists for technical/internal commands. Every RumiAI-owned directly executable command identity is part of the manual-coverage completion scope. Package-owned external executables and sourced libraries are outside that command-identity set.
- Normal `manual` presentation delegates to the technical `pager` command; `manual` no longer selects `more`/`less` or owns TTY backend policy.
- `pager` belongs to `m`, is `bin/sys/pager`, and is bootstrap-integrated through `#!/usr/bin/env m`.
- `pager <file>` owns terminal detection: non-terminal output is copied directly; terminal output selects the host backend.
- Current Linux policy prefers `less` for the richer bidirectional stay-at-end interaction. If `less` is unavailable, `pager` deliberately degrades to `more` rather than fail solely because the preferred viewer is absent. Other current hosts use `more` until concrete host evidence requires another adapter.
- Caller `LESS`, `LESSOPEN` and `LESSCLOSE` values are neutralized when the Linux `less` backend is selected.
- This pager work unit does not modify `rumiai-tests`; test-suite reimplementation is an active parallel task.

## Completed

- Documentation ownership, first-delivery resource storage, extensionless topic identity, public command name, lookup, qualification, discovery and deterministic owner/topic ordering are promoted current contract.
- The first-delivery executable is fixed at `bin/sys/manual`, belongs to technical `m`, and is bootstrap-integrated through `#!/usr/bin/env m`.
- Public `manual` statuses are fixed as `0` success, `1` invalid request, `2` not found, `3` ambiguous and `4` execution/presentation failure.
- `rumiai-os` implements `bin/sys/manual`.
- Earlier Debian 13 x86_64 development execution exposed util-linux `more` behavior that is unsuitable as a uniform cross-host interactive contract. User physical/manual observation additionally confirmed that `POSIXLY_CORRECT=1` produces undesirable interaction on the real host and is not an acceptable normalization mechanism.
- The canonical contract introduces `pager` as the explicit host-normalizing paging boundary. `specifications/rumiai-os/PAGER.md` defines ownership, interface, terminal/non-terminal behavior and current host backend policy; `DOCUMENTATION-MODEL.md` delegates normal manual presentation to that facility.
- Separation checkpoint: `rumiai-os@f93259aedf0f2aca1da1afe0a558edaeb093f19e` introduced `bin/sys/pager`, changed `manual` to delegate to it, and kept the interactive backend as `more` only. A Debian 13 x86_64 targeted development run passed direct non-TTY output, `--no-pager`, direct `pager`, invalid invocation status and real pseudo-terminal `manual -> pager -> util-linux more` presentation (`--More--`). This confirmed separation before host-specific behavior was added.
- A later intermediate revision made Linux `less` mandatory and failed when it was unavailable. The user corrected that interpretation: no project-wide rule required failure, and degraded `more` behavior is explicitly preferable to losing paging availability when `less` is absent. The correction was applied forward-only to specification, implementation and operational manual.
- Current host-normalization checkpoint: `rumiai-os@14e413342261b23df840f40b355166c4d55f1b41` prefers `less` on Linux and falls back to `more` when `less` is unavailable. Other current hosts continue to use `more` until concrete host evidence establishes another adapter need.
- Current Debian 13 x86_64 targeted execution confirms the degradation path on the actual auxiliary host, where `less` is absent and util-linux `more` 2.41 is present: direct non-TTY output succeeds, interactive execution enters `more`, presents `--More--`, accepts `q` and exits with status `0`.
- The richer Linux `less` branch was previously exercised on the same Debian VM by exposing the VM's real BusyBox 1.37.0 `less` applet under the normal command name `less` as an external host capability. With caller `LESS=-E`, input `G`, `b`, `q` reached `(END)`, remained in the viewer, paged backward and then quit with status `0`; no `--More--` prompt appeared. This remains targeted auxiliary development evidence, not stable-host or physical validation.
- `res/sys/manual/pager` documents the current preferred-`less`/fallback-`more` policy. `res/sys/manual/manual` describes delegation to `pager` rather than a host backend.
- The first operational topic set therefore includes `manual`, `pager`, `pkg`, `state-path` and `srv` under owner `sys`.
- A later workflow correction promoted mandatory manual coverage for every RumiAI-owned directly executable command identity. `RULES.md`, `CONSISTENCY-GATE.md`, `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md` and `specifications/README.md` encode that command/manual lifecycle.
- The same correction requires permanent structural coverage that detects a command identity lacking its owner-local manual topic.
- No physical validation has been performed by this assistant for the pager change.
- Concurrent unrelated changes in `rumiai-dev`, `rumiai-os` and `rumiai-tests` were preserved; Git history remained forward-only.

## Current state

The first-delivery `manual` framework and the `pager` abstraction are implemented.

Current normal presentation is:

```text
manual lookup
    -> --no-pager: direct output
    -> normal: pager
        -> stdout non-TTY: direct output
        -> Linux TTY + less available: less
        -> Linux TTY + less unavailable: more (accepted degraded interaction)
        -> other TTY: more
```

The current product command identity set includes `pager` in addition to the previously observed command identities. Because its required `sys pager` manual topic was added in the same work unit, the count of command identities still missing mandatory manual topics remains 18 rather than increasing.

The prior permanent `manual` tests must not currently be treated as reliable validation evidence: the user reports that real manual execution works while those tests fail substantially, and a separate active task owns test-suite reimplementation/realignment. This pager work unit deliberately did not alter `rumiai-tests` or claim a permanent-test PASS.

Formal cross-host/stable-host validation has not been claimed. The Debian VM supplied targeted auxiliary development evidence only.

## Working design state

The long-term source representation and documentation build toolchain remain intentionally unresolved active design. Sphinx, Asciidoctor and Pandoc have been considered as existing build-time candidates; this comparison is task working state, not current specification content.

The generated operational artifacts should remain usable without requiring the documentation-generation framework at runtime; that runtime/build separation is already promoted in `DOCUMENTATION-MODEL.md`.

## Next action

For the documentation task itself, remaining first-delivery work is still dominated by command/manual completeness:

1. refresh current `rumiai-os` and derive the current RumiAI-owned directly executable command-identity inventory from the actual tree and command-entrypoint contract;
2. create the remaining missing owner-local manual topics from current specifications plus current implementation behavior, including `sys m` and the branded `ai` command topics;
3. let the separate active test-suite task establish trustworthy permanent coverage, including the command-to-manual completeness property, before using automated tests as closure evidence;
4. run proportional real validation of the complete manual surface under the corrected testing contract;
5. only then perform the normal final consistency gate and handoff completion lifecycle.

The pager abstraction itself has no remaining design blocker in this work unit. Host-specific policy can be extended later only from concrete host evidence.

Long-term multi-channel source/toolchain design may continue independently as working design and does not block first-delivery command coverage.

## Blockers / open questions

- The current product tree still has 18 command identities without their mandatory operational manual topics.
- Trustworthy permanent-test coverage is pending the active separate test-suite reimplementation task; existing failing manual tests are not closure evidence.
- Formal multi-host/stable-host validation of the implemented first-delivery `manual`/`pager` surface has not yet been executed.
- Long-term documentation source representation and external build toolchain remain unresolved working design, not a first-delivery command-coverage blocker.
