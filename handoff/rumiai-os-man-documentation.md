# rumiai-os-man-documentation

Status: Active
Updated: 2026-09-22

## Goal

Deliver the current terminal-first operational documentation surface for RumiAI OS, including reliable lookup/presentation and mandatory manual coverage for RumiAI-owned command and library identities.

The long-term multi-channel documentation source/rendering architecture remains independent working design and does not block this first-delivery surface.

## Current repository revisions

```text
rumiai-dev   df441ef486b1e80d3772a40542a94ad39f7ad21b  (pre-checkpoint HEAD before this handoff synchronization)
rumiai-os    826da364cd9aaaed05b30f2c4cdbe0c47c730782
rumiai-tests 8a78802f536ca65052ddb3a3bc4d152fb361ebf1
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Fixed task-local choices

- `manual <topic>` gives exact unqualified matches priority.
- If exact-match count is zero, `manual` performs a literal substring search over topic leaf names equivalent to `*<topic>*`.
- Non-empty substring results are emitted as sorted `<owner> <topic>` identities with status `0` and are never paged.
- If the substring fallback is also empty, unqualified lookup returns status `2`.
- Exact ambiguity remains status `3`; owner-qualified lookup remains exact-only with no substring fallback.
- Normal exact-topic presentation delegates to `pager`; `--no-pager` writes an exactly selected topic directly.
- `pager` is a standalone POSIX-sh wrapper: it selects `less` whenever available and otherwise `more`, delegates stdin/file operands directly, does not inspect terminal state, does not pre-resolve files, and does not normalize backend statuses.
- `editor` is a standalone POSIX-sh wrapper: it selects `nano`, then `vim`, then `vi`, forwards arguments unchanged, and leaves editing behavior and status to the selected backend.
- Every RumiAI-owned directly executable command identity requires an owner-local manual topic.
- Every RumiAI-owned library identity requires exactly one owner-local `<library-name>.lib.<runtime>` manual topic that exposes all public functions and no internal functions as callable API.
- Legacy library API visibility must not be inferred from historical unprefixed helper names. `todo/library-api-visibility-realignment.md` owns the separate product/API migration needed before those libraries can receive stable compliant manuals.
- Broader `rumiai-tests` ownership remains with the active suite-realignment task; the pager-specific permanent tests were realigned in this work unit because the newly accepted pager contract made the previous tests stale.

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
- `pager` was deliberately reduced to a standalone backend-selection wrapper at `rumiai-os@ee7811a9ff9211ee0f6806447b115d0cdc00bf58`: no TTY branch, no `cat` substitution, no path resolution/validation and no status normalization. Its operational manual was realigned in the same product work unit.
- `rumiai-os@564b27ce776b91f32870bdf771052dbe7afac38c` adds the standalone `bin/sys/editor` wrapper and its required `res/sys/manual/editor` topic. The command uses the fixed backend order `nano` -> `vim` -> `vi` and delegates arguments/status without adding editor-specific policy.
- `rumiai-os@fce90adde7ee5901a6c71560a7cf72b8df9492b2` materialized the 18 command topics that were previously missing. Together with the pre-existing topics, every command identity at that checkpoint had an owner-local manual topic:
  - technical/root and sys: `m`, `digest`, `extract`, `http-fetch`, `lang`, `lang-set`, `log`, `manual`, `menu-ext`, `menu-ext-adv`, `menu-ext-adv-fs`, `mk`, `osarch-update`, `pager`, `pkg`, `pkg-analyze`, `read-key`, `readc`, `shell`, `srv`, `state-path`;
  - branded ai: `rumiai-os`, `rumiai-os-sh`.
- The same product commit adds manuals for the libraries whose public/internal API is already explicit and naming-aligned:
  - `array.lib.sh` -> public `array` API;
  - `mk-materialize.lib.sh` -> public `mk_materialize` API;
  - `mk-materialize-copy.lib.sh` -> public `mk_materialize_type` adapter API.
- The concurrently added `pkg-install.lib.sh` manual is preserved. These four aligned library topics are materialized in the current product tree.
- The user explicitly identified the legacy random helper as library identity `rand.lib.sh`. The product now realigns `lib/sys/sh/rand.sh` to `lib/sys/sh/rand.lib.sh` without changing its content, sets the shell library to non-executable mode, and adds `res/sys/manual/rand.lib.sh`.
- The `rand.lib.sh` manual exposes exactly the four implemented public functions `randhex`, `rand64`, `randuint` and `randstr`, including operands, outputs, dependencies and actual return-status behavior. No internal function API is advertised.
- `map.lib.sh` is now covered by `res/sys/manual/map.lib.sh`. Its already-aligned public surface is exactly the single public function `map`; underscore-prefixed helpers remain internal and are not advertised as callable API.
- The map manual documents creation/reset, `size`, `keys`, `get`, `put`, `rem`, `set` and `unset`, including insertion-order/duplicate-key behavior, output serialization, public statuses `0/1/2`, destination restrictions and the runtime `quote()` dependency.
- The same work unit corrected `lib/sys/sh/map.lib.sh` from executable mode to the required non-executable `100644` mode and replaced its stale `arg.lib.sh` dependency comment with the current bootstrap `core.lib.sh`/`quote()` reality; executable logic was unchanged. Structural/documentation consistency validation passed; no new runtime behavior test was required.
- `term.lib.sh` is now covered by `res/sys/manual/term.lib.sh`. Its explicit public interface comprises 21 `term_*` functions plus the documented public state for selected TTY, terminal dimensions, last byte/key data and escape timeout; underscore-prefixed helpers remain internal.
- The terminal-library manual documents TTY selection/save/restore and character modes, size discovery, terminfo screen/keypad/cursor/clear operations, text-key validation, byte/key decoding, keymap initialization and secret-line input, together with public status semantics, caller restoration obligations and external utility dependencies.
- The same work unit removed the legacy `#!/bin/sh` shebang from `lib/sys/sh/term.lib.sh`, preserving its existing non-executable `100644` mode as required for a sourced shell library. Executable function logic was unchanged. Mechanical consistency validation confirmed that every current public function appears in the manual and no underscore-prefixed helper is advertised.
- `osarch.lib.sh` is now covered by `res/sys/manual/osarch.lib.sh`. The library exposes no public callable functions; its public interface is source-time initialization of readonly exported `m_OSARCH_OS`, `m_OSARCH_ARCH` and `m_OSARCH`.
- The osarch-library manual documents POSIX `uname -s` / `uname -m` detection, normalization of known Linux/macOS/Windows and x86_64/arm64 spellings, preservation of unknown host values, combined identity construction, source-time fatal failure behavior and caller obligations. The implementation itself required no modification.
- `enc.lib.sh` is now covered by `res/sys/manual/enc.lib.sh`. Its classified public API is exactly `encode`, `decode`, `encoded_file_eval`, `encoded_file_edit`, `a2o` and `o2a`. The manual also documents `m_ENC_PASS`, the GnuPG OCB profile, streaming/authentication caveats, `vsed`/`pipefail` encrypted editing, metadata and optional mtime preservation, octal conversion, dependencies and security boundaries. Structural validation confirmed that every current public function is represented and no internal `_enc_*` / `_encoded_file_*` symbol is advertised.
- Later product work first introduced `osarch-set`; current `rumiai-os@e25f2aaaf9ba56d8a86eb285bec1bb24e9df71be` consolidates the public surface under `osarch` with query, `show`, `update` and `set`, adds `res/sys/manual/osarch`, and retains `osarch-set` / `osarch-update` as compatibility commands with their own manuals. Command/manual completeness therefore remains true for the current product revision.
- Targeted auxiliary-host development validation on Debian 13 x86_64 exercised the exact current `bin/sys/osarch` command body for explicit `set`, bare query, `show`, host `update`, selector-mismatch rejection and invalid explicit osarch rejection; all exercised cases behaved as specified. A direct GitHub clone of the complete checkout was unavailable in that environment because DNS resolution for github.com failed, so this is development evidence for the exact command body rather than formal/full-checkout validation.
- `rumiai-os@826da364cd9aaaed05b30f2c4cdbe0c47c730782` adds the required `res/sys/manual/readpass` and `res/sys/manual/readpassv` topics alongside the hardened command implementations. Both new command identities therefore satisfy mandatory owner-local manual coverage.\n- `specifications/rumiai-os/READPASS.md` now owns the promoted secret-line input contract and is routed directly from `specifications/README.md`.\n- Formal `readpass` task validation at `rumiai-tests@8a78802f536ca65052ddb3a3bc4d152fb361ebf1` against `rumiai-os@826da364cd9aaaed05b30f2c4cdbe0c47c730782` passed on hosted Linux/x86_64 and Darwin/arm64 with filesystem audit `CLEAN`; both `contract.test` and `pty.test` passed on both hosts.\n- No unrelated concurrent product or test-suite work was overwritten; Git history remained forward-only.

## Current state

The `manual` lookup/paging surface and command-manual completeness requirement are implemented for the current product revision. `pager` now has only the accepted `less`-when-available / `more`-otherwise wrapper responsibility.

Current unqualified lookup is:

```text
manual <topic>
    -> exactly one exact match: present it
    -> multiple exact matches: status 3 + qualified alternatives
    -> zero exact matches: literal topic-leaf substring search
        -> non-empty: sorted qualified list, status 0, no pager
        -> empty: status 2
```

All current command identities, including `editor`, `readpass`, `readpassv`, the unified `osarch` command and its compatibility wrappers, have manual topics.

Library documentation is only partially complete. The current product contains compliant manuals for `array.lib.sh`, `enc.lib.sh`, `map.lib.sh`, `mk-materialize.lib.sh`, `mk-materialize-copy.lib.sh`, `osarch.lib.sh`, `pkg-install.lib.sh`, `rand.lib.sh` and `term.lib.sh`. The remaining legacy libraries cannot safely receive final public-API manuals until their intended public/internal function sets are classified and, where necessary, renamed with callers/tests realigned. That work is already represented by `todo/library-api-visibility-realignment.md` and is deliberately not guessed inside this documentation work unit.

The existing permanent manual tests are not closure evidence for the whole documentation task. Pager-specific coverage has been realigned to the new wrapper contract; the active parallel suite-realignment task still owns broader trustworthy coverage, including substring fallback and command/library-to-manual structural completeness.

Targeted formal cross-host validation has been performed for the `readpass`/`readpassv` work unit on hosted Linux/x86_64 and Darwin/arm64, with both required tests passing and audit status `CLEAN`. No full documentation-surface physical/stable-host validation is claimed by that targeted result.

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
