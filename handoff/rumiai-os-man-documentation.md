# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-18

## Goal

Deliver the current terminal-first operational documentation surface for RumiAI OS, including reliable lookup/presentation and mandatory manual coverage for RumiAI-owned command and library identities.

The long-term multi-channel documentation source/rendering architecture remains independent working design and does not block this first-delivery surface.

## Current repository revisions

```text
rumiai-dev   0f1a33c2a73dee434b71a7f833fa1a2a54fb5509  (remote HEAD immediately before this checkpoint)
rumiai-os    e25f2aaaf9ba56d8a86eb285bec1bb24e9df71be
rumiai-tests 1fbd3eab0507179417d0f78122a5d4f54b4a0468  (parallel suite work; not modified by this checkpoint)
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Fixed task-local choices

- `manual <topic>` gives exact unqualified matches priority.
- If exact-match count is zero, `manual` performs a literal substring search over topic leaf names equivalent to `*<topic>*`.
- Non-empty substring results are emitted as sorted `<owner> <topic>` identities with status `0` and are never paged.
- If the substring fallback is also empty, unqualified lookup returns status `2`.
- Exact ambiguity remains status `3`; owner-qualified lookup remains exact-only with no substring fallback.
- Normal exact-topic presentation delegates to `pager`; `--no-pager` writes an exactly selected topic directly.
- Linux `pager` prefers `less` and degrades to `more` when `less` is unavailable; other current hosts use `more` until concrete evidence requires another adapter.
- Every RumiAI-owned directly executable command identity requires an owner-local manual topic.
- Every RumiAI-owned library identity requires exactly one owner-local `<library-name>.lib.<runtime>` manual topic that exposes all public functions and no internal functions as callable API.
- Legacy library API visibility must not be inferred from historical unprefixed helper names. `todo/library-api-visibility-realignment.md` owns the separate product/API migration needed before those libraries can receive stable compliant manuals.
- `rumiai-tests` remains owned by the active parallel suite-realignment task; this documentation work unit does not modify it.

## Completed

- `bin/sys/manual` implements exact lookup, exact ambiguity, qualified lookup, discovery and the new substring fallback.
- `res/sys/manual/manual` describes the same current behavior.
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md` promotes the substring fallback as current contract, including direct qualified-list output and status semantics.
- Targeted Debian 13 x86_64 development execution exercised the exact manual path for:
  - exact unique lookup -> `0`;
  - exact ambiguity -> `3` with sorted qualified alternatives;
  - substring fallback with one/multiple results -> `0` with sorted qualified identities;
  - substring fallback under `--no-pager` -> direct result list;
  - empty exact + empty fallback -> `2`;
  - owner-qualified missing topic -> `2` with no fallback;
  - shell syntax check -> PASS.
- After the command-manual backfill, a further Debian targeted check confirmed that `manual menu` lists `sys menu-ext`, `sys menu-ext-adv`, `sys menu-ext-adv-fs`, while exact `manual mk` still selects the exact topic rather than entering substring search.
- `pager` remains the host-normalizing presentation boundary; earlier Debian development evidence exercised both Linux `more` degradation and a real available `less` backend. This remains auxiliary development evidence, not physical/stable-host validation.
- `rumiai-os@fce90adde7ee5901a6c71560a7cf72b8df9492b2` materialized the 18 command topics that were previously missing. Together with the pre-existing topics, every command identity at that checkpoint had an owner-local manual topic:
  - technical/root and sys: `m`, `digest`, `extract`, `http-fetch`, `lang`, `lang-set`, `log`, `manual`, `menu-ext`, `menu-ext-adv`, `menu-ext-adv-fs`, `mk`, `osarch-update`, `pager`, `pkg`, `pkg-analyze`, `read-key`, `readc`, `shell`, `srv`, `state-path`;
  - branded ai: `rumiai-os`, `rumiai-os-sh`.
- The same product commit adds manuals for the libraries whose public/internal API is already explicit and naming-aligned:
  - `array.lib.sh` -> public `array` API;
  - `mk-materialize.lib.sh` -> public `mk_materialize` API;
  - `mk-materialize-copy.lib.sh` -> public `mk_materialize_type` adapter API.
- The concurrently added `pkg-install.lib.sh` manual is preserved. These four aligned library topics are materialized in the current product tree.
- Later product work first introduced `osarch-set`; current `rumiai-os@e25f2aaaf9ba56d8a86eb285bec1bb24e9df71be` consolidates the public surface under `osarch` with query, `show`, `update` and `set`, adds `res/sys/manual/osarch`, and retains `osarch-set` / `osarch-update` as compatibility commands with their own manuals. Command/manual completeness therefore remains true for the current product revision.
- Targeted auxiliary-host development validation on Debian 13 x86_64 exercised the exact current `bin/sys/osarch` command body for explicit `set`, bare query, `show`, host `update`, selector-mismatch rejection and invalid explicit osarch rejection; all exercised cases behaved as specified. A direct GitHub clone of the complete checkout was unavailable in that environment because DNS resolution for github.com failed, so this is development evidence for the exact command body rather than formal/full-checkout validation.
- No unrelated concurrent product or test-suite work was overwritten; Git history remained forward-only.

## Current state

The `manual` lookup/paging surface and command-manual completeness requirement are implemented for the current product revision.

Current unqualified lookup is:

```text
manual <topic>
    -> exactly one exact match: present it
    -> multiple exact matches: status 3 + qualified alternatives
    -> zero exact matches: literal topic-leaf substring search
        -> non-empty: sorted qualified list, status 0, no pager
        -> empty: status 2
```

All current command identities, including the unified `osarch` command and its compatibility wrappers, have manual topics.

Library documentation is only partially complete. The current product contains compliant manuals for `array.lib.sh`, `mk-materialize.lib.sh`, `mk-materialize-copy.lib.sh` and `pkg-install.lib.sh`. The remaining legacy libraries cannot safely receive final public-API manuals until their intended public/internal function sets are classified and, where necessary, renamed with callers/tests realigned. That work is already represented by `todo/library-api-visibility-realignment.md` and is deliberately not guessed inside this documentation work unit.

The existing permanent manual tests are not closure evidence for this task. The active parallel suite-realignment task must provide trustworthy coverage for the current behavior, including substring fallback and command/library-to-manual structural completeness.

No physical or formal cross-host/stable-host validation has been performed for this final revision.

## Next action

1. Activate and complete `todo/library-api-visibility-realignment.md` as its own product/API work unit, including caller/test realignment where legacy names must change.
2. From the resulting aligned APIs, add the remaining mandatory library manual topics.
3. Let the active test-suite task provide trustworthy permanent coverage for substring fallback and command/library manual completeness.
4. Run proportional real validation of the complete manual surface.
5. Perform the final consistency gate, write a Complete handoff snapshot, then remove this handoff in a later forward commit.

## Blockers / open questions

- Remaining library manuals depend on the explicit legacy library API-visibility realignment already captured in `todo/library-api-visibility-realignment.md`.
- Trustworthy permanent structural/behavioral coverage is pending the active test-suite reimplementation/realignment task.
- Formal multi-host/stable-host validation remains pending.
- Long-term documentation source representation and external build toolchain remain unresolved working design and do not block first-delivery command/manual functionality.
