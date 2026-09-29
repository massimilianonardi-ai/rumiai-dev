# rsudo injection menu

Status: Active
Updated: 2026-09-28

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo`
by streaming the required m-owned shell code and libraries in memory, without
requiring a remote m/RumiAI library tree.

## Current repository revisions

```text
rumiai-dev   336e293c88d146ecf22be674b82c4e36c3bb3e5e  (pre-checkpoint HEAD)
rumiai-os    156d64819a43b4e5611c764cb36fc0dba19ba3ba
rumiai-tests 476e0e9737e79282f9e857a093ff3d9cc6ef23c9
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
- The `--` separator is optional. Without it, the stream contains only the
  injected loader plus selected library loads and does not modify positional
  parameters. With it, one command source is mandatory and remaining operands
  become that command's positional parameters.
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

Run the permanent loader/injection test against the generalized interface, then
physically rerun the menu case using:

```sh
loadlib_inject_stream base array map term menu -- "$m_BIN_SYS_DIR/menu" -d /
```

The previous composed PASS remains historical evidence for the architecture; the
new syntax/library-only behavior still needs current-revision validation.

## Accepted rsudo exec injection design

The user implemented the rsudo `exec inject` module and then refined its
composition with the generator.

Current accepted form:

```text
[ shell-source | ] rsudo [options...] exec inject [LIB...]
                         [-- COMMAND_SOURCE [ARG...]]
```

`loadlib_inject_stream` retains its existing argv grammar for selected
libraries and optional command-source. Independently, non-TTY stdin is appended
as shell source after the generated libraries and optional command-source.

The resulting source order is:

```text
generated in-memory loadlib
selected library loads
optional command argv setup
optional command source
optional stdin shell source
```

The stdin source is not runtime stdin for the command source.

The rsudo module is intentionally minimal:

```sh
rsudo_mod_exec_inject()
(
  set -o pipefail

  loadlib_inject_stream "$@" | rsudo
)
```

The user also changed rsudo state semantics: `RSUDO_AS_USER` and
`RSUDO_INTERACTIVE` are no longer reset by recursive calls and are reusable
caller state; `RSUDO_ASKPASS` and `RSUDO_NO_PRESERVE_QUOTES` remain
invocation-local and are reset. Canonical RSUDO contract and manuals are
realigned accordingly.

Product revision `rumiai-os@156d64819a43b4e5611c764cb36fc0dba19ba3ba`
implements stdin-source composition, simplifies `rsudo-mod-exec.lib.sh`, and
adds its required operational manual.

## Current validation state

Product, canonical specifications, manuals and permanent tests are now aligned
to the accepted stdin-source composition and reusable rsudo target-user /
interactive state.

Permanent coverage includes:

- generator command-source followed by stdin-source in one shell state;
- exec-inject generator-to-rsudo composition;
- generator failure propagation through pipefail;
- recursive rsudo status propagation;
- reusable RSUDO_AS_USER and RSUDO_INTERACTIVE behavior;
- invocation-local reset of askpass and no-preserve-quotes.

The permanent tests have been updated in `rumiai-tests` but have not been
executed by the assistant against a materialized current checkout in this work
unit. A Linux-laboratory execution attempt was made, but the environment could
not resolve `github.com` and therefore could not materialize the exact current
checkouts; this is an infrastructure limitation, not product validation
evidence. A fresh physical `rsudo exec inject` rerun is also still pending.

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

## Working design — isolated injected command wrapper

A new candidate design is under review for command-source mode in
`loadlib_inject_stream`: instead of appending command-source inline, embed it
inside one generated shell function whose body is a subshell compound command,
then invoke that wrapper with the requested command arguments before any
subsequent stdin source.

Conceptually:

```sh
_loadlib_inject_stream_command()
(
  <command-source>
)

_loadlib_inject_stream_command <args...>
<optional subsequent stdin source>
```

This would isolate command-local positional parameters, variables/functions,
traps, cwd, umask, file descriptors, shell options and explicit `exit` /
`exec` effects from the continuation shell. Injected libraries remain visible
inside the subshell. The command status remains the wrapper status, so subsequent
source can observe it through ordinary `$?` semantics.

The wrapper MUST NOT use the command basename (even purified) as its actual
function name. Current commands such as `log`, `lang`, `shell` and
`rsudo` intentionally call same-named library functions; defining a wrapper
under that name would overwrite the dependency the command body needs. A
generator-owned private wrapper identity avoids this collision and also avoids
lossy filename-to-function-name purification.

An optional public alias is feasible for command identities that are valid POSIX
alias names. POSIX alias names permit alphabetics, digits and `! % , - @ _`,
while POSIX function names are shell Names (alphabetics/digits/underscore, not
starting with a digit). This makes current lowercase hyphen-separated m command
names naturally aliasable even though many are not valid function names.

Candidate mapping:

```text
public command basename  state-path
private wrapper          _loadlib_inject_stream_command
optional alias           state-path -> _loadlib_inject_stream_command
```

The alias would be defined only after the wrapper function has been parsed so it
does not rewrite literal same-named calls inside the embedded command body at
definition time. The wrapper can additionally remove that alias inside its own
subshell if runtime-evaluated shell text must not see the public bridge.

Automatic lossy "purification" of arbitrary command filenames into a public
alias is not favored because distinct names can collide and POSIX aliases cannot
represent every valid filename (notably names containing `.` or `/`). The
current leading option is therefore:

```text
internal wrapper name: fixed/generator-owned, always available
public alias: derived automatically from basename only when it is a valid,
              non-reserved POSIX alias identity
explicit caller-supplied command name: defer unless a real requirement appears
```

The alias is a convenience bridge, not complete command-namespace virtualization:
`command name` suppresses alias substitution, aliases are not inherited by
separate shell invocations, and dynamic source/eval behavior requires explicit
consideration.

This design is not yet promoted to the canonical library-interface contract and
has not been implemented or tested.

## Blockers / open questions

No remaining architecture blocker. Current-revision permanent-test execution and
physical validation are pending. The command-entrypoint compatibility review
above remains a follow-up design task.
