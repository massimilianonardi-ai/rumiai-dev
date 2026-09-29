# rsudo injection menu

Status: Active
Updated: 2026-09-29

## Goal

Run the existing `menu` filesystem browser remotely under privileged `rsudo`
by streaming the required m-owned shell code and libraries in memory, without
requiring a remote m/RumiAI library tree.

## Current repository revisions

```text
rumiai-dev   fd834b5d9e67834c1d112751fab7aa625865a2eb  (pre-checkpoint HEAD)
rumiai-os    e31d930534e6536c62d7953fca9398f9006eee28
rumiai-tests 12a22021fadf49250464f053700e48bcec9ad012
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

- Concurrent cleanup removed obsolete `bin/sys/#_readc` and
  `bin/sys/rsudo-askpass`; the current-tree entrypoint audit above no longer
  treats either as a current helper.

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

The user subsequently simplified the same buffered-generation implementation at
`rumiai-os@36d6b53b461c91db790873625f2f5349972768fb`. The current implementation
does not itself require pipefail; this is independent from the open global
runtime-policy question above.

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

A later exhaustive pipefail review corrected the interpretation of the earlier
Ubuntu failure.

The project platform baseline is POSIX.1-2024 / Issue 8, where `set -o
pipefail` is required. The temporary validation that first failed used
`ubuntu-latest`, which resolved to Ubuntu 24.04.5 rather than the canonical
formal-validation Linux target `ubuntu-26.04-arm`.

GitHub Actions diagnostic runs established:

- Ubuntu 22.04.5: `/bin/sh -> dash`,
  `dash 0.5.11+git20210903+057cd650a4ed-3build1`; pipefail unsupported;
- Ubuntu 24.04.5: `/bin/sh -> dash`, `dash 0.5.12-6ubuntu5`; pipefail
  unsupported;
- Ubuntu 26.04.1: `/bin/sh -> dash`, `dash 0.5.12-12ubuntu3`; pipefail
  supported with the required pipeline-status behavior;
- current macOS hosted validation: `/bin/sh` supports pipefail.

Debian added the upstream dash pipefail implementation in package revision
`0.5.12-7`; Ubuntu 24.04's `0.5.12-6ubuntu5` predates that backport, while
Ubuntu 26.04's `0.5.12-12ubuntu3` includes it.

GitHub Actions run 36547637504 reproduced the exact pre-change
`rumiai-os/rsudo/exec-inject.test` against
`rumiai-os@94cb0620f62a481c8300432bb642367e81c11432`:

- PASS on Ubuntu 26.04 ARM and macOS;
- FAIL at `set -o pipefail` on Ubuntu 22.04 and 24.04.

Therefore the earlier characterization of this as a product portability defect
was incorrect relative to the current POSIX.1-2024 baseline. It is evidence
that the older Ubuntu `/bin/sh` implementations do not implement this Issue 8
requirement. Distribution-diversity testing remains valuable, but such an older
host must not silently redefine the current POSIX baseline.

No global RumiAI decision has yet been promoted about where pipefail should be
enabled. The design question remains whether the `m` bootstrap should establish
pipefail once as a runtime invariant, with separate handling for standalone
`#!/bin/sh` utilities and generated/injected shell programs.

A local synthetic POSIX-sh harness exercising the current generator mechanics
passed generation/syntax/execution, repeated named-command invocation,
one-shot/named status isolation, cwd/umask/variable/function isolation and
required/optionally-recognized reserved-name and special-built-in-name
rejection.

GitHub Actions run 36548443993 validates the user's current simplified
`rsudo_mod_exec_inject` at
`rumiai-os@36d6b53b461c91db790873625f2f5349972768fb` with
`rumiai-tests@ce64eab23d03fefc3b93eb2d6baf57d0e5ccd013`:

- Ubuntu 26.04 ARM: library-loading PASS, exec-inject PASS;
- macOS: library-loading PASS, exec-inject PASS;
- Ubuntu 24.04 diversity check: both tests PASS because the current
  implementation does not itself request pipefail.

A later real-hosted transport validation reused the shipped `testlab`
`rsudo` scenario instead of an SSH boundary fixture. GitHub Actions run
`36584756699`, with `rumiai-os@e31d930534e6536c62d7953fca9398f9006eee28`
and `rumiai-tests@12a22021fadf49250464f053700e48bcec9ad012`, exercised:

```text
testlab rsudo scenario
  -> real Podman container
  -> real OpenSSH client/server
  -> real sudo
  -> current rsudo exec inject
  -> injected array library
  -> repeatable named command
  -> one-shot command
  -> continuation stdin source
```

The remote one-shot and continuation source both observed privileged UID 0;
named-command status 7 and one-shot status 6 remained observable across the
generated stream, and the task scope returned `VALIDATED` with one PASS and
zero FAIL/SKIP/ERROR.

This is real SSH/sudo transport evidence, not a physical operator-host/TUI run.
Fresh physical validation remains relevant only for the interactive privileged
menu/TTY path and other operator-terminal properties that hosted non-TTY
execution does not prove.

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
    readpass        standalone and already main-structured, but deliberately
                    installs process-exit/signal cleanup traps
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

## Working design — pipefail runtime policy with graceful degradation

The user agrees with establishing `pipefail` broadly across the `m` shell
runtime, while retaining best-effort execution on older `/bin/sh`
implementations that do not yet implement the POSIX.1-2024 Issue 8 requirement.

### Verified baseline and host evidence

The current canonical platform baseline remains POSIX.1-2024 / Issue 8.
`set -o pipefail` is therefore a baseline shell feature, not a non-portable
extension relative to the RumiAI contract.

Exhaustive hosted diagnostics established the current host split:

```text
Ubuntu 22.04.5
    /bin/sh -> dash
    dash 0.5.11+git20210903+057cd650a4ed-3build1
    set -o pipefail: unsupported

Ubuntu 24.04.5
    /bin/sh -> dash
    dash 0.5.12-6ubuntu5
    set -o pipefail: unsupported

Ubuntu 26.04.1
    /bin/sh -> dash
    dash 0.5.12-12ubuntu3
    set -o pipefail: supported
    false | true under pipefail -> status 1

current macOS hosted runner
    /bin/sh supports pipefail
    false | true under pipefail -> status 1
```

Debian incorporated dash pipefail support beginning with package revision
`0.5.12-7`. Ubuntu 24.04's `0.5.12-6ubuntu5` predates that revision, while
Ubuntu 26.04's `0.5.12-12ubuntu3` includes it.

The exact pre-change rsudo exec-inject permanent test was reproduced across
these hosts: it passed on Ubuntu 26.04 and macOS and failed at
`set -o pipefail` on Ubuntu 22.04/24.04. This is evidence that those older
shell packages do not fully implement the selected Issue 8 baseline; it is not
evidence that pipefail is non-POSIX for the project.

### Accepted direction

The preferred runtime policy is graceful capability establishment:

```sh
if (set -o pipefail) 2>/dev/null
then
  set -o pipefail
else
  # emit one warning after the normal logging runtime is available
  :
fi
```

The capability probe MUST run in a subshell. On older dash implementations an
unsupported `set -o pipefail` is fatal to that probing shell; the subshell
boundary prevents the capability check from terminating the bootstrap itself.

The intended semantics are:

```text
Issue 8 shell with pipefail
    -> enable pipefail
    -> m/runtime pipelines use Issue 8 pipeline-status semantics

older shell without pipefail
    -> continue running in best-effort compatibility mode
    -> emit a warning
    -> pipeline behavior falls back to that shell's ordinary last-command status
```

This is deliberately a warning/degradation model, not an emulation layer. If no
pipeline component fails, supported and unsupported hosts normally behave the
same. The semantic difference appears when an earlier pipeline component fails
while a later component succeeds; without pipefail that failure can remain
masked.

### Preferred ownership: bootstrap, not base.lib.sh

For the normal integrated `m` runtime, the preferred owner is the root
bootstrap `m`, not `base.lib.sh`.

Reasons:

1. Pipefail is shell execution state for the entire runtime, not a library
   service.
2. It should be established before ordinary runtime code begins to rely on
   pipeline status.
3. A library should not repeatedly mutate global shell options merely because it
   is sourced.
4. Enabling it in `base.lib.sh` would be later than necessary and would couple
   an execution invariant to one library identity.
5. Injection deliberately permits zero selected libraries and does not require
   `base`; therefore `base.lib.sh` cannot be the general owner of the
   injection/runtime policy.

The likely normal-bootstrap shape is therefore:

```sh
_m_pipefail=false

if (set -o pipefail) 2>/dev/null
then
  set -o pipefail
  _m_pipefail=true
fi

... normal bootstrap ...
. "$m_LIB_DIR/sys/sh/core.lib.sh"

if [ "$_m_pipefail" != "true" ]
then
  log warn ...pipefail unsupported...
fi

unset _m_pipefail
```

The exact warning domain/message identity is not fixed yet and MUST be derived
from current logging/localization conventions rather than invented casually.

The probe should occur early enough that the bootstrap establishes the runtime
state before normal library/command execution. The warning can be deferred until
after `core -> base` has installed the normal `log` facility. If a warning
must be available even when core/base fails to load, a bootstrap-level
`printf` fallback may be appropriate, but that is a separate failure-reporting
choice.

No exported/public `m_PIPEFAIL` variable has been accepted. A private
bootstrap-local flag is sufficient unless a concrete runtime introspection
requirement appears.

### Generated/injected source is a separate shell boundary

Setting pipefail in the local `m` bootstrap does not propagate into a remote or
otherwise separately invoked `sh` that executes source generated by
`loadlib_inject_stream`.

Therefore, if pipefail becomes an `m` runtime invariant, generated/injected
programs should establish the same capability policy explicitly in their
generated preamble, independently of whether the caller selected `base`.

Conceptually:

```text
normal m execution
    m bootstrap establishes pipefail policy

loadlib_inject_stream output
    generated program establishes pipefail policy
    generated loader/libraries/commands execute afterward

standalone #!/bin/sh utility
    does not inherit m bootstrap state
    must be reviewed separately if the invariant is intended to apply there
```

The generator warning path cannot assume the ordinary localized `log` facility
exists, because zero-library injection is valid. If generated source warns on an
unsupported shell, that warning should use a minimal generator-owned stderr
message unless/until a more general runtime diagnostic primitive is adopted.

### Why graceful degradation is useful

The proposed probe allows RumiAI to use the selected Issue 8 semantics where the
host implements them without unnecessarily refusing to run on older hosts such
as Ubuntu 22.04/24.04.

On an older host, code can still behave correctly whenever the semantic
difference is irrelevant to the executed path. The warning makes the weaker
failure-propagation guarantee visible rather than silently pretending the host
fully satisfies the selected baseline.

This gives a useful compatibility envelope:

```text
conforming/current host
    full RumiAI pipeline semantics

older partially conforming host
    best-effort execution + explicit warning
    no guarantee that earlier pipeline failures are reflected in pipeline status
```

The project baseline itself remains Issue 8; graceful degradation does not
redefine older shells as fully conforming.

### Audit required before global enablement

Global pipefail changes the status of existing pipelines, intentionally exposing
failures that were previously masked by a successful final pipeline component.
Before promotion/implementation, audit all current pipelines and the many
existing patterns that were written to avoid dependence on pipefail.

The audit MUST distinguish at least two categories:

```text
status-propagation workaround
    exists only because pipeline status otherwise reports the last command
    candidate for simplification/removal after pipefail becomes invariant

behavioral / atomicity / sequencing workaround
    guarantees something stronger than final pipeline status
    MUST NOT be removed merely because pipefail exists
```

A concrete example of the second category is the current
`rsudo_mod_exec_inject` buffering pattern:

```sh
_rsudo_mod_exec_inject_source="$(loadlib_inject_stream "$@" || exit "$?"; printf x)" || exit "$?"
_rsudo_mod_exec_inject_source=${_rsudo_mod_exec_inject_source%x}
printf '%s' "$_rsudo_mod_exec_inject_source" | rsudo
```

Even with pipefail, replacing this mechanically with:

```sh
loadlib_inject_stream "$@" | rsudo
```

would change behavior: the right-hand `rsudo` process can start and consume
partial source before the generator eventually fails. Pipefail would preserve
the final failure status, but it would not provide the current
generate-completely-before-transport guarantee. Therefore this buffering is not
merely an anti-pipefail workaround.

The next audit should locate every pipeline and every apparent anti-pipefail
pattern in `m`, `bin/` and shell libraries, then classify each by the
stronger property it protects.

### Proposed promotion path for the next chat

Do not immediately scatter `set -o pipefail` across libraries.

Resume with:

1. fresh mandatory preflight and current HEAD retrieval;
2. exhaustive inventory of shell pipelines and anti-pipefail workarounds in the
   current `rumiai-os` tree;
3. classify each workaround as status-only vs stronger sequencing/atomicity;
4. decide the exact bootstrap warning behavior and whether standalone utilities
   participate in the invariant;
5. decide the generated-stream preamble/warning behavior;
6. promote the accepted runtime rule into
   `POSIX-PORTABILITY-LAYER.md` and `BOOTSTRAP-ENVIRONMENT.md`;
7. implement the bootstrap and generated-stream policy only after that audit;
8. update permanent tests, including:
   - Ubuntu 26.04/macOS: pipefail enabled and effective;
   - an older-shell diversity case: safe probe, warning, continued execution;
   - generated injection stream establishes the same policy;
   - existing pipeline semantics remain correct;
9. run the normal consistency gate and hosted validation.

No product change implementing this policy has been made in this checkpoint.

## Blockers / open questions

No remaining injection-architecture blocker. Current-revision permanent-test
execution and physical validation are pending. The command-entrypoint standards
review remains an independent follow-up design task rather than an injection
prerequisite.

## Pipefail current-tree audit checkpoint — 2026-09-29

This checkpoint completes the requested pre-implementation audit. No
`rumiai-os` product change and no permanent-test change was made.

### Reconciled repository state

The audit began against:

```text
rumiai-dev    01a3cc2d0ec7eead3fbccc7919727a6eaef3d159
rumiai-os     4e6d33f224bcba77a4e553b1e4bd5299a57d555c
rumiai-tests  b1c3fb58ae9306392c34e10800b963f025b0e452
```

The remote HEADs advanced during the audit. Forward reconciliation established:

```text
rumiai-dev    1e132c822e213c0e7ac33eac996cd84da4306682
rumiai-os     0c56665c5be7b6aac4c097dad1b000ce97bb6ac7
rumiai-tests  238ab53839814579ed0ed49400ae59864028a405
```

The `rumiai-os` and `rumiai-tests` compare ranges contain no net file
changes, so the audited implementation/test trees remain exact. The only
`rumiai-dev` file changed in the compare range is
`specifications/rumiai-os/SSH.md`; it was reread at the new HEAD. Its status
contract says that, when local setup/cleanup succeed, the SSH facility returns
the OpenSSH invocation status. That is consistent with the pipeline-status
exception identified below.

### Exhaustive pipeline inventory result

Actual shell pipelines, excluding case-pattern alternation and literal text,
occur in the following current-tree files:

```text
bin/sys/#_readc
bin/sys/digest
bin/sys/gitman
bin/sys/http-fetch
bin/sys/manual
bin/sys/menu
bin/sys/pkg-analyze
bin/sys/read-key
bin/sys/srv
bin/sys/testlab

lib/sys/sh/enc.lib.sh
lib/sys/sh/env.lib.sh
lib/sys/sh/host-id.lib.sh
lib/sys/sh/menu.lib.sh
lib/sys/sh/rand.lib.sh
lib/sys/sh/term.lib.sh
lib/sys/sh/pkg/pkg-download.lib.sh
lib/sys/sh/pkg/pkg-extract.lib.sh
lib/sys/sh/pkg/pkg-provider.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-apache-maven.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-artifact.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-chrome.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-geoserver.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-github.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-gpgtools.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-graalvm.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-podman.lib.sh
lib/sys/sh/pkg/repository/pkg-repository-temurin.lib.sh
lib/sys/sh/rsudo/rsudo-mod-apisix.lib.sh
lib/sys/sh/rsudo/rsudo-mod-exec.lib.sh
lib/sys/sh/rsudo/rsudo-mod-fs.lib.sh
lib/sys/sh/rsudo/rsudo-mod-keycloak.lib.sh
lib/sys/sh/rsudo/rsudo.lib.sh
```

The root `m` bootstrap and the branded root entrypoints contain no actual
pipeline. Several other files contain `|` only as shell case alternation,
regular-expression/data syntax or documentation text.

The dominant pipeline families are pure in-memory filters
(`printf | awk/sed/tr`), sorted enumerations, terminal-byte conversion,
package/repository metadata parsing, and rsudo/transfer stream boundaries.

### Classification of current anti-pipefail-looking patterns

The audit found three distinct classes.

**Status propagation only / potentially simplifiable**

- The clearest example is `digest`: the hashing backend is first captured and
  checked, then its already-complete textual output is parsed through
  `printf | awk`. Once pipefail is a reliable runtime invariant, a direct
  backend-to-parser pipeline could preserve upstream failure status. This is a
  possible simplification, not a required one; retaining the two-stage form is
  low risk and keeps backend completion explicit.
- Many existing `... | parser || return/fatal` forms are not workarounds to
  remove. Under global pipefail their existing status check simply becomes a
  full-pipeline check instead of a last-stage-only check.

**Stronger sequencing / atomicity / lifecycle properties — retain**

- `rsudo_mod_exec_inject` complete-source buffering MUST remain. It protects
  RSUDO-23: generator failure is resolved before recursive rsudo can start.
  Pipefail cannot provide that sequencing property.
- `encoded_file_edit` temporary-file staging, source checksum recheck and
  final rename MUST remain. Pipefail can expose `decode` or `vsed` failure,
  but cannot replace the atomicity/race protections.
- `rsudo fs get/put` extraction/staging/promotion/rollback structure MUST
  remain. Pipefail improves transfer-pipeline failure visibility but does not
  replace the destination-preservation guarantees protected by RSUDO-15..19.
- Producer loops feeding `sort` in `manual`, `testlab` and
  `pkg-provider` contain explicit output-failure termination. Those checks
  must remain: pipefail sees only the final status of each pipeline component;
  without terminating the producer component, a later successful loop
  iteration could overwrite an earlier emission failure.
- Sentinel suffix patterns such as `; printf x` followed by `${value%x}`
  are newline/empty-output preservation mechanisms, not pipefail workarounds.
  They must not be removed on pipefail grounds.

**Pipeline-status authority exceptions**

The non-interactive rsudo transport is semantically different:

```sh
(printf password; cat payload) | ssh ...
```

The current rsudo contract requires the remote/OpenSSH result to be authoritative.
A remote target may legitimately terminate successfully without consuming all
stdin. In that case the local feeder can receive SIGPIPE while SSH still
returns success. Global pipefail would incorrectly turn that successful remote
result into a local feeder failure.

Therefore the future global policy needs a narrowly scoped exception around
this transport boundary: execute that specific pipeline with ordinary
rightmost-command status semantics while leaving pipefail enabled in the
surrounding m runtime. On an old shell the opt-out itself must also be guarded
by the safe capability probe; an unconditional `set +o pipefail` is not safe
on a shell that does not recognize the option.

The final `printf complete_source | rsudo` in `exec inject` does not have the
same practical early-close shape: recursive interactive rsudo buffers the
injected source before remote execution. If recursive rsudo is non-zero it
remains the rightmost non-zero stage; if it succeeds it has consumed the source.
The complete-source pre-buffer remains required independently.

### Early-success consumer hazard

Pipefail is not semantically monotonic for pipelines whose right-hand consumer
intentionally succeeds before draining input. A successful early exit can close
the pipe and cause an upstream producer to fail with SIGPIPE.

A current auxiliary Linux `/bin/sh` (dash with Issue 8 pipefail support)
demonstrated:

```text
large producer | awk 'NR==1 { ...; exit }'  -> status 141 under pipefail
large producer | grep -q early-match        -> status 141 under pipefail
```

Current-tree cases that need hardening before global enablement include:

- `enc.lib.sh`: `printf ... | grep -q` capability checks. Replace the
  early-success `-q` form with a draining match check (for example normal
  grep with output redirected) so a match does not intentionally close input.
- `menu.lib.sh::_menu_safe_item_text`: its awk exits after the first record.
  It should preserve first-record output semantics while continuing to drain
  the supplied input.
- `host-id.lib.sh`: the macOS ioreg parser exits after the UUID match. It
  should retain the first match while draining the finite ioreg output.

Several other parsers use early `exit` only with contractually tiny/bounded
one-record producers (digest text, one-path du/df/ls probes, one-line
name-validation inputs). They are lower risk, but the implementation work unit
should remove unnecessary successful early exits where this can be done without
changing semantics. Early exit on an already-failing validation path is not the
same problem: the pipeline is supposed to fail.

### Concrete effect of global pipefail

The m runtime does not globally enable `errexit`. Enabling pipefail therefore
does not itself make every non-zero pipeline terminate the shell. It changes the
status observed by existing callers, predicates, command substitutions,
functions and `&&`/`||` handling.

Expected desirable changes include:

- `enc` edit detects upstream decode/editor failure before promotion;
- `pkg-extract` detects `cpio` listing failure even if its awk parser would
  otherwise succeed;
- host/account and metadata parsers with existing `|| return/fatal` checks can
  see producer failure;
- rsudo filesystem transfer pipelines can see either producer or consumer
  failure;
- grouped enumeration pipelines can propagate producer emission failure.

The early-success/SIGPIPE cases and the rsudo rightmost-status boundary above are
the material exceptions that prevent treating global pipefail as a mechanical
toggle.

### Proposed precise runtime contract

**Normal m bootstrap**

- Establish pipefail in root `m`, not `base.lib.sh`.
- Probe in a subshell before ordinary runtime library/command execution:
  `if (set -o pipefail) 2>/dev/null; then set -o pipefail; ...`.
- Keep only a private bootstrap-local degraded-mode flag long enough to defer
  diagnostics until `core -> base` has installed `log`; do not export or
  publish `m_PIPEFAIL`.
- On an unsupported shell, continue in compatibility mode and emit one warning
  through the normal logging surface after core/base becomes available.
  Proposed message identity: `system/pipefail-unavailable`.
- RumiAI-owned integrated commands and sourced libraries inherit the established
  option and must not globally disable it. A narrowly scoped subshell may
  deliberately disable it when another current contract requires different
  pipeline-status authority.

**Generated `loadlib_inject_stream` programs**

- Emit an unconditional generated preamble before library wrappers/loading.
- The preamble performs the same safe subshell capability probe and enables
  pipefail in the containing generated shell when supported.
- If unsupported, emit one minimal generator-owned stderr warning and continue;
  the warning cannot depend on `base` or `log` because zero-library
  generation is valid.
- The established option remains active for selected library loading, later
  continuation source and the containing generated program. Named and one-shot
  command subshells inherit it; their command-local shell-option changes remain
  isolated by the existing subshell contract.
- If a generated stream is dot-sourced, establishing pipefail in that containing
  shell is an intentional runtime effect, not state that is restored afterward.

**Standalone `#!/bin/sh` utilities**

- They are not implicitly covered by the m-bootstrap invariant.
- They must not assume pipefail merely because they are m-owned.
- Review them independently. If a standalone utility requires all-stage
  pipeline status for correctness, it must establish the capability safely in
  its own process or use an equivalent explicit structure.
- Current standalone pipeline users `read-key` and internal `#_readc` do
  not justify scattering a global policy into every standalone utility as part
  of this work unit.

**Other explicit new-shell boundaries**

A direct `sh -c`, remote shell, or other newly invoked shell does not inherit
the m shell option contract automatically. The owner of that boundary must
establish pipefail explicitly when its semantics require it. The existing
`rsudo-mod-fs` remote preflight already does this for its
`du -sk | awk` check and must retain that local policy unless that whole child
shell boundary is later generalized.

### Implementation order implied by the audit

Before enabling pipefail globally:

1. harden the identified successful early-exit pipelines;
2. preserve ordinary rightmost-status semantics around the non-interactive
   rsudo stdin-to-SSH transport boundary;
3. add bootstrap capability establishment and degraded warning;
4. add the generated-stream preamble/warning;
5. keep sequencing/atomicity/staging/sentinel mechanisms;
6. add permanent coverage for supported bootstrap semantics, degraded probe,
   generated streams, the rsudo early-close status case and the hardened
   early-success consumers;
7. only then consider optional low-value cleanup such as collapsing digest's
   two-stage status parsing.

This audit does not promote the working design into canonical specifications and
does not authorize a product modification by itself. The next step is to present
the audit/conclusions and, after acceptance, promote the settled runtime policy
to the applicable canonical specifications before product implementation.



## rsudo-admin Browse host PTY regression checkpoint — 2026-09-29

A physical user run of `rsudo-admin -> Browse host` exposed a regression that
the original permanent test did not exercise: after selecting a host the local
terminal showed only the rsudo startup log and then appeared to hang.

The cause was the local redirection around the complete browse action:

```sh
( rsudo ... ) >/dev/null
```

The remote `menu` correctly writes its terminal UI to its remote `/dev/tty`,
but OpenSSH transports that PTY output back through the local SSH stdout
channel. Redirecting the complete local rsudo action therefore discarded the
interactive screen itself while leaving the remote menu waiting for terminal
input.

The product fix at
`rumiai-os@ecfe8197085be8f2af4c72813ea18e00a9ba778f` removes the local
session redirect. The menu source is injected as named command
`_rsudo_admin_remote_menu`; continuation source invokes that command remotely
as:

```sh
_rsudo_admin_remote_menu -d / >/dev/null
```

This discards only the serialized menu command result on the remote side.
Writes to remote `/dev/tty` remain on the SSH PTY channel and are visible to
the operator. The operational manual was realigned to this routing.

Permanent regression coverage was extended at
`rumiai-tests@d588378dee5c3fa492460016b2d3ed606e41b6ac`. Its allowed external
SSH-boundary fixture emits a marker on the SSH output channel; the interactive
test now actually selects the Browse host entry and requires that marker to be
visible before control returns to the main menu. The pre-fix local redirect
would suppress this observation.

Focused workflow run `36573594068` first validated the fix revision
and was then rerun after a concurrent product merge advanced `rumiai-os`.
Attempt 2 froze the reconciled current product exactly at
`rumiai-os@45c1cf174c0b51540ce6903ca37a7eb4f58f5260` with
`rumiai-tests@d588378dee5c3fa492460016b2d3ed606e41b6ac`. The concurrent
product delta touched only `rsudo.lib.sh`; the browser fix and manual remained
unchanged.

```text
Ubuntu 26.04 ARM   PASS contract.test
                   PASS interactive.test
                   PASS 2 / FAIL 0 / SKIP 0 / ERROR 0

macOS              PASS contract.test
                   PASS interactive.test
                   PASS 2 / FAIL 0 / SKIP 0 / ERROR 0
```

This validates the local rsudo-admin/SSH-channel regression through the real
product path with the permitted external SSH fixture. The user subsequently
physically confirmed the corrected `rsudo-admin -> Browse host` path on a real
remote host after the PTY-routing fix at
`rumiai-os@45c1cf174c0b51540ce6903ca37a7eb4f58f5260`: the remote filesystem
menu was visible and interactive. That physical observation applies to that
revision and is not relabelled as evidence for later revisions.
