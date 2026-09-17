# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-17

## Goal

Deliver a useful operational documentation surface with `rumiai-os` while keeping development contracts in `rumiai-dev`, and establish a deliberate long-term path toward documentation whose informational content is independent from presentation channel.

The first delivery is intentionally simple and terminal-first. The future multi-channel design remains a separate architecture problem whose build orchestration belongs to `mk`.

The current first-delivery completion scope includes mandatory operational-manual coverage for every RumiAI-owned directly executable command identity **and every RumiAI-owned library identity**, plus permanent structural coverage that detects missing mandatory topics.

## Current repository revisions

```text
rumiai-dev   16fb262ef5c0bace2ace918b161b011858700762  (handoff checkpoint before publication of prepared product commit)
rumiai-os    db0b25c20b08247cd68818ef9caea61a1cf02451  (current remote HEAD; descendant fce90adde7ee5901a6c71560a7cf72b8df9492b2 prepared for publication)
rumiai-tests 122011d7aeb64d7d6a15a44a133b497c962fa89d  (parallel suite work; not modified by this documentation work unit)
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
specifications/rumiai-os/LANG-BOOTSTRAP.md
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
- Unqualified `manual <topic>` gives exact matches priority. Only when there are zero exact matches, it performs a literal substring search over topic leaf names equivalent to `*<topic>*`; non-empty results are written as sorted `<owner> <topic>` identities with status `0`, while an empty fallback preserves not-found status `2`. Qualified lookup remains exact-only.
- Trustworthy permanent coverage is coordinated with the active test-suite realignment task rather than treating known-broken legacy manual tests as closure evidence.

## Completed

- Documentation ownership, terminal-first resource storage, topic identity, lookup/discovery and deterministic ordering are promoted current contract.
- `bin/sys/manual` is implemented and delegates normal exact-topic presentation to `pager`.
- Current `manual` public statuses remain `0` success, `1` invalid request, `2` not found, `3` exact ambiguity and `4` execution/presentation failure.
- `pager` is the host-normalizing presentation boundary. Current Linux behavior prefers `less` and falls back to `more`; Debian auxiliary execution has exercised the degraded `more` path, and the richer `less` path was exercised using the VM's BusyBox `less` capability. This is development evidence, not physical/stable-host validation.
- Manual substring fallback was implemented in `bin/sys/manual`, documented in `res/sys/manual/manual`, and promoted into `DOCUMENTATION-MODEL.md` as the current contract.
- Debian 13 x86_64 targeted auxiliary execution exercised the exact committed manual logic for: exact unique lookup, exact ambiguity, substring fallback with one/multiple results and lexical qualification, `--no-pager` substring listing, empty fallback -> status `2`, and qualified lookup remaining exact-only. All targeted cases passed. `sh -n` also passed. This is development evidence, not a permanent-suite or stable-host PASS.
- A product commit `fce90adde7ee5901a6c71560a7cf72b8df9492b2` has been prepared from current `rumiai-os@db0b25c20b08247cd68818ef9caea61a1cf02451` containing the 18 previously missing command manuals plus three manuals for already visibility-aligned libraries. Publication of that commit to `main` is the next immediate action; it is not treated as current product state until the ref advances.
- The prepared command pages cover `sys m`, `digest`, `extract`, `http-fetch`, `lang`, `lang-set`, `log`, `menu-ext`, `menu-ext-adv`, `menu-ext-adv-fs`, `mk`, `osarch-update`, `pkg-analyze`, `read-key`, `readc`, `shell`, plus branded `ai rumiai-os` and `ai rumiai-os-sh`. Existing `manual`, `pager`, `pkg`, `srv` and `state-path` topics remain preserved in the prepared tree.
- The prepared aligned-library pages cover `array.lib.sh`, `mk-materialize.lib.sh` and `mk-materialize-copy.lib.sh`; the concurrent package work's existing `pkg-install.lib.sh` manual is preserved.
- Mandatory command/library manual coverage remains subject to permanent structural coverage in the parallel test-suite task before this documentation task can close.
- No physical validation has been performed by this assistant for the manual/pager surface.
- Concurrent repository changes were preserved forward-only.

## Current state

The first-delivery `manual` framework, `pager` abstraction and substring fallback are implemented on the current product branch. Complete command-manual coverage and three additional aligned-library manuals are prepared in descendant product commit `fce90adde7ee5901a6c71560a7cf72b8df9492b2` pending fast-forward publication.

Current unqualified lookup is:

```text
manual <topic>
    -> one exact match: present topic
    -> multiple exact matches: status 3 + qualified alternatives
    -> zero exact matches: search topic leaves for *<topic>*
        -> non-empty: sorted qualified result list, status 0, no pager
        -> empty: status 2
```

Current normal exact-topic presentation is:

```text
manual lookup
    -> --no-pager: direct output
    -> normal: pager
        -> stdout non-TTY: direct output
        -> Linux TTY + less available: less
        -> Linux TTY + less unavailable: more (accepted degraded interaction)
        -> other TTY: more
```

Library documentation is not yet complete. Even after publication of the prepared pages, many legacy `lib/sys/sh/*.lib.sh` identities still cannot be documented safely without first resolving their public/internal function intent under `todo/library-api-visibility-realignment.md`.

The prior permanent `manual` tests must not currently be treated as reliable closure evidence; the separate active test-suite task owns trustworthy test reconstruction and must also add/realign command-to-manual and library-to-manual structural completeness coverage.

Formal cross-host/stable-host validation has not been claimed.

## Next action

1. Publish `rumiai-os@fce90adde7ee5901a6c71560a7cf72b8df9492b2` by forward-only fast-forward if the remote HEAD remains its parent, then mechanically recheck command coverage.
2. Activate/complete the dedicated legacy library API visibility realignment work or otherwise establish the intended public function sets for the remaining libraries without guesswork.
3. Create the remaining mandatory library manual topics from those aligned public APIs.
4. Have permanent tests enforce both command-to-manual and library-to-manual structural completeness under the active test-suite task, including the new substring-fallback behavior where appropriate.
5. Run proportional real validation of the complete manual surface, then perform the final consistency gate and handoff completion lifecycle.

Long-term multi-channel source/toolchain design remains independent working design and does not block first-delivery coverage.

## Blockers / open questions

- Remaining mandatory library manual topics depend on explicit public/internal API classification for legacy libraries; that work is deferred in `todo/library-api-visibility-realignment.md` and must not be guessed from unprefixed legacy function names.
- Trustworthy permanent manual-completeness and substring-fallback coverage is pending the active test-suite reimplementation/realignment task.
- Formal multi-host/stable-host validation has not yet been executed.
- Long-term documentation source representation and external build toolchain remain unresolved working design.
