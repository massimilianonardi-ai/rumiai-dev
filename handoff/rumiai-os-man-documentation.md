# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design remains a separate architecture problem whose build orchestration belongs to `mk`.

The current first-delivery completion scope includes mandatory operational-manual coverage for every RumiAI-owned directly executable command identity **and every RumiAI-owned library identity**, plus permanent structural coverage that detects missing mandatory topics.

## Current repository revisions

```text
rumiai-dev   33a29bc39d58feecf8b033ccbaa189131df916d2  (pre-checkpoint HEAD after concurrent pager reconciliation; library contract changes are being layered forward)
rumiai-os    e9cad50042e1b74613630af33bb239d34a855c99  (library inventory inspected; refresh before product/documentation writes)
rumiai-tests bec37b4368f474dcb6ea8ef418af090384478df3  (current remote HEAD observed for parallel suite work)
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
specifications/rumiai-os/LIBRARY-INTERFACES.md
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

The promoted first-delivery documentation contract lives in `DOCUMENTATION-MODEL.md`. Command identity is owned by `COMMAND-ENTRYPOINTS.md`; library identity/API visibility is owned by `LIBRARY-INTERFACES.md` plus `FILESYSTEM-NAMING.md`; paging is owned by `PAGER.md`.

## Fixed task-local choices

- No task-local exception exists for technical/internal commands. Every RumiAI-owned directly executable command identity is part of manual-coverage completion scope.
- No task-local exception exists for RumiAI-owned libraries. Every library identity requires exactly one manual topic.
- Library topic identity is exactly the runtime-qualified library leaf `<library-name>.lib.<runtime>` under the semantic owner's manual tree, e.g. `res/sys/manual/array.lib.sh`.
- A library manual exposes every public function and does not expose internal functions as callable API.
- Stable library-manual backfill must not guess legacy API visibility. Legacy public/internal function naming realignment is tracked separately by `todo/library-api-visibility-realignment.md`.
- Normal `manual` presentation delegates to the technical `pager` command; `manual` does not own host backend policy.
- Current Linux pager policy prefers `less`; when unavailable it degrades to `more`. Other current hosts use `more` until concrete evidence requires another adapter.
- Caller `LESS`, `LESSOPEN` and `LESSCLOSE` values are neutralized when Linux `less` is selected.
- Trustworthy permanent coverage is coordinated with the active test-suite realignment task rather than treating known-broken legacy manual tests as closure evidence.

## Completed

- Documentation ownership, terminal-first resource storage, topic identity, lookup/discovery and deterministic ordering are promoted current contract.
- `bin/sys/manual` is implemented and delegates normal presentation to `pager`.
- Current `manual` public statuses remain `0` success, `1` invalid request, `2` not found, `3` ambiguous and `4` execution/presentation failure.
- `pager` is the host-normalizing presentation boundary. Current Linux behavior prefers `less` and falls back to `more`; Debian auxiliary execution has exercised the degraded `more` path, and the richer `less` path was exercised using the VM's BusyBox `less` capability. This is development evidence, not physical/stable-host validation.
- Current command topics under owner `sys` include `manual`, `pager`, `pkg`, `state-path` and `srv`.
- Mandatory command manual coverage is promoted into project rules/specifications and requires structural permanent coverage.
- Mandatory library manual coverage is now also promoted. `LIBRARY-INTERFACES.md` defines library identity and public/internal visibility; `DOCUMENTATION-MODEL.md` defines deterministic library-topic mapping and public-function-only content.
- Current `rumiai-os` inspection confirms many `lib/sys/sh/*.lib.sh` libraries and no materialized `<library-name>.lib.<runtime>` topics under `res/sys/manual/`.
- `array.lib.sh` and `mk-materialize.lib.sh` visibly follow the desired underscore-private/unprefixed-public pattern. Legacy code such as `core.lib.sh` requires explicit API-visibility classification rather than mechanical renaming from memory.
- The legacy naming/API migration is therefore represented separately by `todo/library-api-visibility-realignment.md`; this documentation task does not silently redefine product API.
- No physical validation has been performed by this assistant for the manual/pager surface.
- Concurrent repository changes were preserved forward-only.

## Current state

The first-delivery `manual` framework and `pager` abstraction are implemented, but mandatory documentation completeness is not yet satisfied.

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

The current product command identity set includes `pager`; the previously established count of command identities still missing mandatory manual topics remains 18.

At `rumiai-os@e9cad50042e1b74613630af33bb239d34a855c99`, `res/sys/manual/` contains only `manual`, `pager`, `pkg`, `srv` and `state-path`; no mandatory library-identity topic of the form `<library-name>.lib.<runtime>` is materialized.

Library manuals cannot be completed safely by assuming every legacy unprefixed function is intentionally public. Libraries with already-unambiguous public API can be documented immediately; ambiguous legacy libraries depend on the dedicated visibility-realignment work.

The prior permanent `manual` tests must not currently be treated as reliable closure evidence; the separate active test-suite task owns trustworthy test reconstruction.

Formal cross-host/stable-host validation has not been claimed.

## Working design state

The long-term source representation and documentation build toolchain remain intentionally unresolved active design. Sphinx, Asciidoctor and Pandoc have been considered as existing build-time candidates; this comparison is task working state, not current specification content.

## Next action

Before this handoff can close:

1. refresh current command and library inventories from `rumiai-os`;
2. create all missing command manual topics;
3. create one manual topic for each library whose public API is already unambiguous;
4. coordinate/sequence legacy API visibility realignment through `todo/library-api-visibility-realignment.md`, then finish manuals for affected libraries from the aligned public API;
5. have permanent tests enforce both command-to-manual and library-to-manual structural completeness under the active test-suite task;
6. run proportional real validation of the complete manual surface;
7. only then perform the final consistency gate and handoff completion lifecycle.

Long-term multi-channel source/toolchain design remains independent working design and does not block first-delivery coverage.

## Blockers / open questions

- 18 previously identified command identities still lack mandatory operational topics.
- Mandatory library manual topics are currently absent.
- Some legacy libraries require explicit public/internal API classification and naming realignment before a stable public-only manual can be authored; that work is deferred in `todo/library-api-visibility-realignment.md`.
- Trustworthy permanent manual-completeness coverage is pending the active test-suite reimplementation/realignment task.
- Formal multi-host/stable-host validation has not yet been executed.
- Long-term documentation source representation and external build toolchain remain unresolved working design.
