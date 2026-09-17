# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design remains a separate architecture problem whose build orchestration belongs to `mk`.

## Current repository revisions

```text
rumiai-dev   2f9762060ca9ef88ec633a57ce13fe4d9a9983bb  (current remote HEAD before this handoff checkpoint)
rumiai-os    8b0c7991e8242dac73b0a350530a5100385294f3  (manual first-delivery implementation)
rumiai-tests 0428a21be8f9be05193e2533672aa8f7864dbd30  (manual permanent coverage)
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
specifications/rumiai-os/MK.md
specifications/rumiai-os/MK-SOURCE-MATERIALIZATION.md
handoff/README.md
```

The promoted first-delivery contract lives in `DOCUMENTATION-MODEL.md` and `RESOURCE-MODEL.md`; it is not duplicated here.

## Completed

- Documentation ownership, first-delivery resource storage, extensionless topic identity, public command name, lookup, qualification, discovery and deterministic owner/topic ordering are promoted current contract.
- The first-delivery executable is fixed at `bin/sys/manual`, belongs to technical `m`, and is bootstrap-integrated through `#!/usr/bin/env m`.
- Public statuses are fixed as `0` success, `1` invalid request, `2` not found, `3` ambiguous and `4` execution/presentation failure.
- `rumiai-os` now implements `bin/sys/manual` and distributes `res/sys/manual/manual` as the first operational page.
- Debian 13 x86_64 auxiliary development execution exposed that invoking util-linux `more` with redirected standard output can remain interactive/hang. The contract and implementation were corrected rather than treating that host behavior as portable pager semantics.
- Current presentation contract is: `--no-pager` always writes directly; without it, terminal stdout uses POSIX `more`, while non-terminal stdout writes directly for deterministic pipelines/redirections.
- The corrected `manual` implementation was exercised on the Debian auxiliary host across discovery, ordering, unique and qualified lookup, ambiguity, `--no-pager`, non-terminal default output and statuses `1` through `4`.
- A real pseudo-terminal exercise on Debian entered the system `more` pager and accepted `q` before the end of a long topic, confirming that the TTY branch is interactive.
- Permanent tests were added under `tests/rumiai-os/manual/`: `interface.test` and `paging.test`. They reuse the current target, isolated-replica and interactive helpers rather than duplicating test infrastructure.
- The permanent test files were syntax-checked and the exact committed blobs passed the auxiliary Debian development execution path. No formal persisted `rumiai-test` validation session was produced because the available auxiliary environment could not materialize a complete repository checkout/runner session from GitHub.
- No physical validation has been performed.
- Concurrent unrelated changes in `rumiai-dev` and `rumiai-tests` were preserved; the active parallel suite-realignment work was not modified by this task.

## Current state

The first-delivery `manual` framework is implemented and has permanent mechanical coverage in the test repository.

The current implementation provides:

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

The self-reference page `res/sys/manual/manual` is distributed with the implementation. Additional operational topics can now be added incrementally as useful public interfaces are documented.

Formal cross-host validation has not yet been claimed. The available Debian VM supplied auxiliary development evidence only; stable reference-host/validation-run evidence remains a later validation step.

## Working design state

The long-term source representation and documentation build toolchain remain intentionally unresolved active design. Sphinx, Asciidoctor and Pandoc have been considered as existing build-time candidates; this comparison is task working state, not current specification content.

The generated operational artifacts should remain usable without requiring the documentation-generation framework at runtime; that runtime/build separation is already promoted in `DOCUMENTATION-MODEL.md`.

## Next action

The first-delivery mechanism no longer has an unresolved interface-design blocker. Next work can proceed along two independent tracks:

1. add useful operational pages for existing public interfaces, keeping each page revision-coupled and factual;
2. when validation infrastructure/hosts are available, run the committed `manual` permanent tests through the normal `rumiai-test` validation path and record only the evidence actually obtained.

The long-term documentation track separately remains to resolve canonical source representation and build toolchain under `mk`.

## Blockers / open questions

- Long-term documentation source representation and external build toolchain.
- Formal multi-host/stable-host validation of the implemented first-delivery `manual` surface has not yet been executed.
