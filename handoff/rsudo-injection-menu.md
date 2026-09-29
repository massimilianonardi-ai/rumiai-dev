# rsudo injection menu

Status: Active
Updated: 2026-09-28

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo`
by streaming the required m-owned shell code and libraries in memory, without
requiring a remote m/RumiAI library tree.

## Current repository revisions

```text
rumiai-dev   54b6b5e6788e71ad4fa3c3fbc151c60cbc358c79  (pre-checkpoint HEAD)
rumiai-os    a015fb27cd5862808bef3f7fe8b92b2b8e8e8169
rumiai-tests ce64eab23d03fefc3b93eb2d6baf57d0e5ccd013
```

Fresh remote HEAD retrieval remains mandatory before future writes.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/RSUDO.md
specifications/rumiai-os/MENU.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
```

## Fixed task-local choices

- The root `m` bootstrap remains minimal and directly sources only
  `core.lib.sh` as its owned-library chicken/egg exception.
- The user implemented the accepted runtime split at
  `rumiai-os@0ac81dc2c1f3d792b9050782367e26d684306e48`:
  `core.lib.sh` defines the normal filesystem `loadlib` and loads
  `base.lib.sh`; `base.lib.sh` defines `loadsyslib` and contains the common
  runtime formerly held in core.
- Injection does not execute `core.lib.sh`. The generated stream owns an
  in-memory `loadlib`; no particular library identity is hardcoded by the
  generator.
- The caller owns the explicit injected dependency set; no dependency parsing or
  automatic transitive closure is added.
- Zero selected libraries are valid. Every selected library is embedded and
  loaded through the generated `loadlib` in caller-supplied order.
- Before the optional final `--`, callers may interleave explicit library
  references with repeatable `--command COMMAND_NAME LOCAL_SOURCE`
  registrations. Each named command is a reusable shell function backed by a
  subshell-isolated local source file.
- The final `-- COMMAND_SOURCE [ARG...]` form remains optional and
  non-repeatable. It preserves the caller-facing one-shot syntax while executing
  the source through a private subshell wrapper, so its positional/process state
  does not leak into subsequent source.
- The menu case continues to select `base array map term menu`, but `base` is
  now ordinary caller-selected data rather than generator policy.
- The generated stream owns its in-memory `loadlib` implementation directly;
  there is no separate `loadlib-inject.lib.sh` backend or second dispatch
  layer.
- Transport remains the existing `rsudo --interactive` source-injection path.

## Completed

- RumiAI-owned system-shell-library consumers were migrated to `loadsyslib`,
  with permanent structural coverage for direct owned-library dot-sourcing.
- `loadlib-inject-stream.lib.sh` generates wrappers for the caller-selected
  libraries and a direct in-memory `loadlib` case dispatch.
- The former double-dispatch `loadlib-inject.lib.sh` backend was removed.
- The earlier physical composed path reached privileged `menu -d /`
  successfully when loader ownership was still in the root bootstrap.
- After loader ownership was restored to core, a physical run reached the menu
  command body but failed at `menu_reset`; revision comparison established
  that embedded core had overwritten the injected loader.
- The user then split the normal loader from the common runtime as described
  above.
- `rumiai-os@a72f26850d421b0746521a6b25021dcbd7e2dc4c`
  first adapted `loadlib_inject_stream` to the split runtime.
- `rumiai-os@4654d858701e84fca0ce3a4fd3210a16f4275c7a`
  generalizes the interface to
  `loadlib_inject_stream [LIB...] [-- COMMAND [ARG...]]`, removes the
  hardcoded/mandatory `base` identity, permits zero selected libraries, loads
  selected libraries in caller order, and supports library-only streams.
- Canonical library-interface contract is realigned to this neutral generator
  semantics while the normal bootstrap remains `core -> base`.
- A local synthetic POSIX-sh harness exercised the exact generalized generator
  implementation with representative stub libraries. It passed generation and
  execution for libraries+command, library-only with receiving positional
  parameters preserved, zero-library empty-loader generation, and command-only
  mode. This is development evidence for generator mechanics, not a substitute
  for the permanent checkout test or the physical rsudo/menu rerun.

## Current state

The architectural mismatch that caused the observed `menu_reset: not found`
failure remains resolved by the `core -> base` split. The injection generator
is now more general than the menu use case: it has no built-in knowledge of the
normal runtime base, permits zero or more selected libraries, and makes command
execution optional.

The earlier physical composed menu PASS validated the previous
`generated in-memory loadlib -> base -> loadsyslib -> embedded libraries`
composition. The generalized interface at
`rumiai-os@4654d858701e84fca0ce3a4fd3210a16f4275c7a` still requires a fresh
physical rerun before that PASS can be attributed to the new revision.

The new `base.lib.sh` library identity and the changed `core.lib.sh` public
surface require operational-manual follow-up under the active
`rumiai-os-man-documentation` workstream; that documentation backfill does not
block functional injection validation.

## Next action

Run the permanent loader/injection and rsudo exec-inject tests against the
current product revision, then physically rerun the privileged menu case:

```sh
rsudo --interactive --connect "$USER@127.0.0.1" \
  exec inject \
  base array map term menu \
  -- "$m_BIN_SYS_DIR/menu" -d /
```

A follow-up physical case should also exercise one repeatable `--command`
registration plus stdin continuation to validate the complete composed transport,
not only generator mechanics.

## Accepted rsudo exec injection design

The accepted generator surface is now:

```text
[ shell-source | ] rsudo [options...] exec inject
    [LIB | --command COMMAND_NAME LOCAL_SOURCE]...
    [-- COMMAND_SOURCE [ARG...]]
```

`--command` is repeatable. The caller supplies an already-valid portable POSIX shell
function identifier and one readable local source file; no basename derivation,
purification or alias is performed. Each named command is generated as a
function whose body is a subshell and can be invoked repeatedly by the one-shot
command or subsequent stdin source.

The final `-- COMMAND_SOURCE [ARG...]` form remains source-compatible for the
caller and non-repeatable. Internally the source is placed in one private
subshell wrapper and invoked once with its supplied arguments.

This isolates command-local positional parameters, variables/functions, traps,
cwd, umask, additional file descriptors, shell options and explicit
`exit`/`exec` effects from subsequent generated source while keeping injected
library functions available.

Libraries and `--command` registrations may be interleaved before the final
`--`. Duplicate named-command identities, `loadlib`, and names beginning
`_loadlib_inject_stream_` are rejected. Other namespace collisions remain a
caller-composition responsibility.

The rsudo module remains a transport adapter, but it now completes generation
before recursive transport so generator failure is portable across current
shells:

```sh
rsudo_mod_exec_inject()
(
  source_with_sentinel=$(
    loadlib_inject_stream "$@"
    status=$?
    [ "$status" -eq 0 ] || exit "$status"
    printf x
  ) || return "$?"

  source=${source_with_sentinel%x}
  printf '%s' "$source" | rsudo
)
```

The actual implementation uses private module-local variable names. The
sentinel prevents command substitution from stripping source trailing newlines.

Current product revision
`rumiai-os@a015fb27cd5862808bef3f7fe8b92b2b8e8e8169` implements this
contract and operational documentation, including portable generator-status
propagation without requiring pipefail.

## Current validation state

Product, canonical specifications, operational manuals and permanent tests are
aligned to named/one-shot subshell-isolated command injection.

Permanent coverage now includes:

- existing explicit-library and incomplete-dependency behavior;
- repeatable `--command` registration interleaved with libraries;
- one-shot argv preservation behind its private subshell wrapper;
- named command invocation from both the one-shot command and stdin
  continuation;
- `exit` status isolation (named status 7 and one-shot status 6);
- no leakage of command-local positional parameters, variables/functions, cwd
  and umask into continuation source;
- invalid, POSIX-reserved/optionally-reserved, POSIX special-built-in,
  duplicate and generator-reserved command-name rejection;
- missing named-source failure;
- exec-inject generator-to-rsudo composition, generator failure propagation
  without invoking recursive rsudo, and recursive rsudo status propagation.

GitHub Actions validation against the previous product revision
`rumiai-os@94cb0620f62a481c8300432bb642367e81c11432` and frozen suite
`rumiai-tests@25fbd5320ecbe5b724e656f6426605bb36e4e33e` produced:

- macOS: both permanent tests PASS;
- Ubuntu: library-loading PASS, exec-inject FAIL because the host `/bin/sh`
  rejects `set -o pipefail`.

This exposed a real portability defect in the module rather than a test or
orchestration failure. Product revision
`rumiai-os@a015fb27cd5862808bef3f7fe8b92b2b8e8e8169` removes the pipefail
dependency and `rumiai-tests@ce64eab23d03fefc3b93eb2d6baf57d0e5ccd013`
strengthens regression coverage so generator failure must not invoke recursive
rsudo. GitHub Actions run 36543617957 is revision-specific evidence for the
pre-fix behavior and must not be relabelled as validation of the fixed revision.

A local synthetic POSIX-sh harness exercising the current generator mechanics
passed generation/syntax/execution, repeated named-command invocation,
one-shot/named status isolation, cwd/umask/variable/function isolation and
required/optionally-recognized reserved-name and special-built-in-name
rejection.

The permanent tests still require a fresh GitHub Actions rerun against the
fixed current revisions above. Fresh physical `rsudo exec inject` validation
also remains pending.

## Next design review

Review the current shell-command entrypoint standards against source/stream
injection compatibility. In particular, determine whether the existing
`main "$@"` structural guidance and command termination/status conventions
should be formalized more explicitly for commands that may be sourced as part of
a larger generated shell program.

This review must distinguish ordinary command-entrypoint correctness from
optional composability with subsequent injected source. Stream injection remains
a general facility: arbitrary external or user-supplied command sources are not
required to be continuation-compatible, and callers that compose a command
source with later shell source own that compatibility.

No command-entrypoint contract change has been promoted yet.

## Command-entrypoint audit against stream composition

A current-tree audit of every executable body under `bin/sys` was performed
against the proposed command-structure / continuation criteria. Current
`bin/ai` has no independent executable command bodies; `bin/ai-osarch`,
`bin/ext-osarch` and `bin/sys-osarch` are selector symlinks, while
`bin/sys/m` exposes the root `m` bootstrap rather than defining another
command body.

The audit separates three different migration concerns:

```text
structural isolation
    move non-trivial top-level operational code behind main "$@"
    so command parsing/shift/set -- do not directly mutate the containing
    source program's positional parameters

normal termination
    avoid exit used merely to report ordinary command completion when a return
    or fall-through can preserve the same status

lifecycle isolation
    commands that install traps, change umask/shell options, retain file
    descriptors or otherwise rely on immediate process exit require explicit
    cleanup/restoration before they can safely permit continuation
```

Observed command groups:

```text
already structurally clean / trivial wrappers
    lang
    log
    shell
    rsudo
    mk              (main exists; intentionally execs node)
    readpassv       (main exists; requires m_BIN_SYS_DIR/readpass)
    state-path      (small direct body; no normal exit but not main-isolated)
    rssh            (small session wrapper; deliberately mutates exported state)

high-value simple main/termination refactor candidates
    digest          top-level parsing/shift, normal exit 0, optional stdin data
    extract         top-level dispatch, normal exit 0
    http-fetch      top-level parsing/set --, explicit success/failure exits
    lang-set        top-level operation, no-arg normal exit, m resource-tree dependency
    manual          top-level parsing/shift, several ordinary exit paths
    menu            top-level getopts/shift, ordinary exit paths; otherwise a
                    strong injection candidate because it has no direct m path
                    dependency beyond explicitly injected libraries
    osarch          top-level dispatch and no-arg normal exit; selector filesystem dependency
    pkg             tiny top-level dispatcher/shift; dynamic library dependency

requires lifecycle work, not just main/return conversion
    pkg-analyze     owns fd 3, cleanup/signal traps and umask; normal exit drives cleanup
    srv             lock cleanup/signal traps and umask persist until process exit;
                    some internal run modes intentionally exec m
    vsed            changes xtrace/verbose options, installs exit/signal traps,
                    uses process-exit cleanup and explicit normal exits
    gitman          long-running top-level interactive loop with ordinary exit
                    paths; some operations alter umask and it relies on other
                    m commands being installed

special-purpose helpers / process-bound utilities
    editor          standalone; execs selected editor by design
    pager           standalone; execs selected pager by design
    read-key        standalone TTY reader with traps/exits
    #_readc         standalone/internal TTY reader with traps/exits
    readpass        standalone and already main-structured, but deliberately
                    installs process-exit/signal cleanup traps
    rsudo-askpass   security helper; set +x plus process-style exit contract
    ssh-askpass     security helper; set +x plus process-style exit contract
```

Additional stream-injection dependency findings:

- `menu`, `digest` and `http-fetch` have no direct `m_*` filesystem-root
  dependency in their command bodies; they are the clearest candidates for
  source portability once their libraries/external tools are available.
- `lang-set`, `manual`, `mk`, `osarch`, `readpassv`, `rssh`,
  `srv` and `state-path` directly depend on `m` filesystem/runtime state;
  injecting their source does not reproduce those resources.
- `gitman`, `manual`, `mk`, `pkg-analyze` and other commands invoke
  additional command identities by name/path; source injection of one command
  does not automatically inject those executable dependencies.
- `pkg` dynamically selects a library with
  `loadsyslib "pkg/pkg-${pkg_command}"`; explicit injection therefore requires
  the selected library and its complete runtime dependency set.
- stdin-as-data modes are distinct from injection-source stdin. In the current
  `rsudo --interactive` path the generated source is collected locally and
  executed remotely through `sh -c`, while the remote command receives the
  terminal as stdin. Commands such as `digest`, `pkg-analyze` and `vsed`
  therefore need their stdin semantics considered explicitly when used through
  this transport.

The audit supports strengthening the generic command standard around non-trivial
`main "$@"` structure and normal return/fall-through semantics, while treating
continuation compatibility as an additional composability property rather than
a universal requirement. No canonical entrypoint invariant has been changed yet.

## Command-entrypoint consequence of isolated injection

The previous command-entrypoint audit remains useful as a general shell-quality
review, but stream continuation no longer requires modifying every command to
replace ordinary `exit`, `exec`, traps, cwd, umask or file-descriptor
lifecycle. Named and one-shot injected command bodies now execute behind a
subshell boundary that isolates those effects.

Command-entrypoint standards may still be strengthened independently for
readability, invocation robustness and ordinary sourced-command hygiene; that
review is no longer a prerequisite for safe continuation after an injected
command.

## Blockers / open questions

No remaining injection-architecture blocker. Current-revision permanent-test
execution and physical validation are pending. The command-entrypoint standards
review remains an independent follow-up design task rather than an injection
prerequisite.
