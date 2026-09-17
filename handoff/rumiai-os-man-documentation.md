# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design remains a separate architecture problem whose build orchestration belongs to `mk`.

The current first-delivery completion scope now also includes mandatory operational-manual coverage for every RumiAI-owned directly executable command identity and permanent structural coverage that detects missing command manual topics.

## Current repository revisions

```text
rumiai-dev   1fbdf402eda0093d9e45303a3619e242bcaa2fb8  (pre-checkpoint HEAD after command/manual rule promotion)
rumiai-os    b18ae4439519bfe4081035a7d6d0a29423a81709  (current command/manual inventory inspected)
rumiai-tests d59a05417e91a97a10424f6dbc25047f9bfee383  (current remote HEAD; refresh before test writes)
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
specifications/rumiai-os/DOCUMENTATION-MODEL.md
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

The promoted first-delivery contract lives in `DOCUMENTATION-MODEL.md`, `COMMAND-ENTRYPOINTS.md` and `RESOURCE-MODEL.md`; it is not duplicated here.

## Fixed task-local choices

No task-local exception exists for technical/internal commands. Every RumiAI-owned directly executable command identity is part of the manual-coverage completion scope. Package-owned external executables and sourced libraries are outside that command-identity set.

## Completed

- Documentation ownership, first-delivery resource storage, extensionless topic identity, public command name, lookup, qualification, discovery and deterministic owner/topic ordering are promoted current contract.
- The first-delivery executable is fixed at `bin/sys/manual`, belongs to technical `m`, and is bootstrap-integrated through `#!/usr/bin/env m`.
- Public statuses are fixed as `0` success, `1` invalid request, `2` not found, `3` ambiguous and `4` execution/presentation failure.
- `rumiai-os` implements `bin/sys/manual`.
- Debian 13 x86_64 auxiliary development execution exposed that invoking util-linux `more` with redirected standard output can remain interactive/hang. The contract and implementation were corrected rather than treating that host behavior as portable pager semantics.
- Current presentation contract is: `--no-pager` always writes directly; without it, terminal stdout uses POSIX `more`, while non-terminal stdout writes directly for deterministic pipelines/redirections.
- The corrected `manual` implementation was exercised on the Debian auxiliary host across discovery, ordering, unique and qualified lookup, ambiguity, `--no-pager`, non-terminal default output and statuses `1` through `4`.
- A real pseudo-terminal exercise on Debian entered the system `more` pager and accepted `q` before the end of a long topic, confirming that the TTY branch is interactive.
- Permanent tests were added under `tests/rumiai-os/manual/`: `interface.test` and `paging.test`. They reuse the current target, isolated-replica and interactive helpers rather than duplicating test infrastructure.
- The permanent test files were syntax-checked and the exact committed blobs passed the auxiliary Debian development execution path. No formal persisted `rumiai-test` validation session was produced because the available auxiliary environment could not materialize a complete repository checkout/runner session from GitHub.
- The first operational topic set contains `res/sys/manual/manual`, `res/sys/manual/pkg`, `res/sys/manual/state-path` and `res/sys/manual/srv`. The latter three were written from their current canonical specifications and current command implementations rather than from remembered behavior.
- The Debian auxiliary execution path was also used to confirm that the added topic identities participate in `manual` discovery in deterministic lexical order.
- No physical validation has been performed.
- Concurrent unrelated changes in `rumiai-dev` and `rumiai-tests` were preserved; the active parallel suite-realignment work was not modified by this task.
- A later workflow correction promoted mandatory manual coverage for every RumiAI-owned directly executable command identity. `RULES.md`, `CONSISTENCY-GATE.md`, `COMMAND-ENTRYPOINTS.md`, `DOCUMENTATION-MODEL.md` and `specifications/README.md` now encode that command/manual lifecycle.
- The same correction requires permanent structural coverage that detects a command identity lacking its owner-local manual topic.

## Current state

The first-delivery `manual` framework is implemented and has permanent mechanical coverage for its lookup/presentation interface, but the newly promoted command-coverage invariant is **not yet satisfied by the current product tree**.

Current implementation provides:

```text
qualified ordered discovery
unique unqualified lookup
explicit ambiguity resolution
exact owner-qualified lookup
direct non-terminal output
explicit --no-pager output
interactive POSIX more presentation on a terminal
public statuses 0..4
```

At `rumiai-os@b18ae4439519bfe4081035a7d6d0a29423a81709`, the RumiAI-owned command identities observed are:

```text
sys:
    m
    digest
    extract
    http-fetch
    lang
    lang-set
    log
    manual
    menu-ext
    menu-ext-adv
    menu-ext-adv-fs
    mk
    osarch-update
    pkg
    pkg-analyze
    read-key
    readc
    shell
    srv
    state-path

ai:
    rumiai-os
    rumiai-os-sh
```

`bin/sys/m` is an exposure of the root `m` command and is therefore not a second command identity.

Current manual topics are only:

```text
sys manual
sys pkg
sys srv
sys state-path
```

No `res/ai/manual/` topics are currently materialized. Therefore 18 of the 22 currently observed command identities still require manual topics before this task can complete under the new contract.

The existing `interface.test` / `paging.test` coverage does not yet prove the new global command-to-manual completeness invariant. A structural permanent test must be added or existing coverage extended so a missing required manual topic fails mechanically.

Formal cross-host validation has not yet been claimed. The available Debian VM supplied auxiliary development evidence only; stable reference-host/validation-run evidence remains a later validation step.

## Working design state

The long-term source representation and documentation build toolchain remain intentionally unresolved active design. Sphinx, Asciidoctor and Pandoc have been considered as existing build-time candidates; this comparison is task working state, not current specification content.

The generated operational artifacts should remain usable without requiring the documentation-generation framework at runtime; that runtime/build separation is already promoted in `DOCUMENTATION-MODEL.md`.

## Next action

Before this handoff can close:

1. refresh current `rumiai-os` and derive the current RumiAI-owned directly executable command-identity inventory from the actual tree and command-entrypoint contract;
2. create the missing owner-local manual topics from current specifications plus current implementation behavior, including `sys m` and the branded `ai` command topics;
3. add/realign permanent structural coverage so every RumiAI-owned command identity must have its required manual topic while non-command manual topics remain allowed;
4. run proportional real validation of the complete manual surface under the current testing contract;
5. only then perform the normal final consistency gate and handoff completion lifecycle.

Long-term multi-channel source/toolchain design may continue independently as working design and does not block first-delivery completion unless the current task deliberately keeps that design in scope.

## Blockers / open questions

- The current product tree has incomplete mandatory command manual coverage: 18 currently observed command identities lack topics.
- Permanent tests do not yet enforce the command-to-manual completeness invariant.
- Formal multi-host/stable-host validation of the implemented first-delivery `manual` surface has not yet been executed.
- Long-term documentation source representation and external build toolchain remain unresolved working design, not a first-delivery command-coverage blocker.
