# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate source streaming that can inject an existing `m` command plus an explicitly selected set of required system shell libraries through `rsudo --interactive`, execute it on a remote host, and avoid creating or copying a RumiAI/m runtime tree there.

## Current repository revisions

- rumiai-dev: f4fac7e88d70a7b4238e8e7f509ab459ef3d8916
- rumiai-os: ef93f108bbaf10333a7b550c1eabdcb72f0e973e
- rumiai-tests: a7027d8f97ea4a60613c6a9c6e703a8362ac086c
- rumiai-dev-PoCs: 04b17182392c323f13a53b9fffa6917ff9823cec

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- specifications/README.md
- specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/MENU.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md

## Fixed task-local choices

- The remote execution model remains source injection through the existing interactive `rsudo` stdin path; no temporary remote RumiAI/m helper tree is required.
- `loadlib` and `loadsyslib` are pure one-reference loading primitives. They do not forward library positional parameters.
- The local loader is owned by the technical `m` bootstrap and exists before `core.lib.sh` is loaded.
- Owned `lib/sys/sh` dependencies use `loadsyslib`; arbitrary runtime/external pathname sourcing remains ordinary POSIX dot-sourcing.
- Injection dependency selection is entirely explicit. The injector does not parse source, discover dependencies or compute transitive closure.
- The caller constructing an injected stream is responsible for every embedded library, including transitive dependencies and all runtime-selected candidates.
- The injected backend replaces `loadlib`; the `loadsyslib` caller surface remains unchanged.

## Implemented state

### Local loader

Current `m` defines:

```sh
loadsyslib()
{
  [ "$#" -eq 1 ] || return 1
  loadlib "sys/sh/$1"
}

loadlib()
{
  [ "$#" -eq 1 ] || return 1

  set -- "$m_LIB_DIR/${1}.lib.sh"
  [ -f "$1" ] && [ -r "$1" ] || return 2

  . "$1"
}
```

The loader is defined before core and is used by the bootstrap itself for `core` and `pkg/pkg-provider`.

### Streaming backend

`lib/sys/sh/loadlib-inject.lib.sh` exists with its mandatory manual. It replaces `loadlib` with an in-memory dispatcher boundary:

```sh
_loadlib_inject_dispatch()
{
  return 2
}

loadlib()
{
  [ "$#" -eq 1 ] || return 1
  _loadlib_inject_dispatch "$1"
}
```

The generated stream is expected to redefine the internal dispatcher for exactly the embedded preload set. A non-embedded library fails deterministically rather than falling back to a remote m library tree.

## Global loadsyslib migration

The complete current `rumiai-os` shell source surface was migrated from direct owned system-library dot imports to `loadsyslib`.

A complete tree scan verified that no direct `$m_LIB_DIR/sys/sh/...lib.sh` caller import remains. Remaining dot-sourcing is intentional runtime/external sourcing or the loader implementation itself, including examples such as package adapters and `m_COMMAND_BIN`.

The permanent test:

```text
tests/rumiai-os/bootstrap/library-loading.test
```

covers exact-one-operand loader behavior, representative direct/grouped library loading and recursively rejects reintroduction of direct owned-system-library dot imports.

Operational manuals that still showed old direct loading were migrated to `loadsyslib`, and the `m` manual now documents `loadlib`/`loadsyslib`.

The durable loader contract has been promoted into current `LIBRARY-INTERFACES.md` and `BOOTSTRAP-ENVIRONMENT.md`.

## Defects discovered by global validation and corrected

The first post-migration full health run exposed real migration/test-consistency defects rather than being treated as acceptable noise.

- Several library tests directly sourced dependency-bearing libraries and therefore bypassed the newly required loader runtime. Those tests were changed to execute inside the real target `m` shell through a temporary integrated-command wrapper; no fake `loadsyslib` is introduced.
- Three rsudo tests had lost executable mode and produced infrastructure ERROR; their `100755` mode was restored.
- The product contained only `#_osarch-set` / `#_osarch-update` even though current specifications still require compatibility commands `osarch-set` / `osarch-update`. The public compatibility names and executable modes were restored without changing wrapper behavior.
- The rsudo dynamic-module migration initially loaded `rsudo/rsudo-mod-${1}` only after an `eval` had replaced positional parameter 1 with the delegated function name. Module loading was moved before that argv transformation, preserving the runtime module identity.

## Validation state

The complete current product migration is structurally protected by `tests/rumiai-os/bootstrap/library-loading.test`, including a recursive scan that rejects any owned `lib/sys/sh` direct dot import. On the current migrated product this test passes.

The migration milestone is now closed for this work unit. The later full-product health run at `rumiai-tests@287577204412cef46cae83157547dbe9ac28d2f8` froze the migrated `rumiai-os@51d0cba5696a94caaf5ae39e2e476a31598a0ae1`. Ubuntu 26.04 ARM64 completed successfully. On macOS all `rumiai-os/*` tests passed; the remaining five FAILs were external live-package tests (DBeaver, Electron macOS launch, GraalVM, jq and Keycloak) and produced no loader/injection regression evidence. The current product HEAD `c33b39ded5020d85943ca826cedbe3ff6d2a4492` differs from that migration revision only in `rsudo.lib.sh` for the separately developed `--ssh-command` behavior.

A full-product validation froze:

```text
rumiai-os:    51d0cba5696a94caaf5ae39e2e476a31598a0ae1
rumiai-tests: 1341e7790bb0e33f70fab915322ee75020ec9ec3
```

On GitHub Ubuntu 24.04 x64 its baseline session produced 153 PASS, 1 FAIL, 13 SKIP, 0 ERROR; the only failure was the pre-existing `rumiai-os/rsudo/fs.test`. Published test evidence showed the first regular-file put failed because the runner's `/bin/sh` rejected POSIX.1-2024 `set -o pipefail`:

```text
set: Illegal option -o pipefail
```

The same rsudo/fs test already failed on 2026-09-25 before this loadsyslib migration, so it is not a migration regression.

External verification established that Ubuntu 24.04 ships dash 0.5.12-6ubuntu5, while pipefail support entered dash in 0.5.12-7. The current RumiAI stable Linux reference is Ubuntu 26.04 ARM64; GitHub now provides the production `ubuntu-26.04-arm` runner. The health workflow was therefore realigned from `ubuntu-latest` (still resolving to Ubuntu 24.04 during GitHub's staged migration) to `ubuntu-26.04-arm`.

The workflow realignment is committed in rumiai-tests as:

```text
c5dbf627300d095215da21bc07362de03e09337f
Validate health on Ubuntu 26.04 ARM64
```

The global migration validation no longer blocks stream-generation/injection work.

## Stream-format PoC

PoC 051 under `rumiai-dev-PoCs/pocs/051-loadlib-injection-stream` validates the first concrete explicit stream representation against `rumiai-os@c33b39ded5020d85943ca826cedbe3ff6d2a4492`.

The stream contains:

1. the ordinary `loadsyslib` specialization;
2. `loadlib-inject.lib.sh`;
3. one numbered function wrapper per caller-selected embedded library;
4. a generated `_loadlib_inject_dispatch` case table mapping exact `sys/sh/<reference>` values to those wrappers;
5. an explicit bootstrap `loadsyslib "core"`;
6. the real selected command body.

For the menu proof the caller-selected set is exactly `core array map term menu`. No dependency parser or closure logic participates. The generated stream passes `sh -n` and the real menu executes successfully in a Linux PTY, returning the expected serialized `enter one` result. The final passing PoC revision is `2dcdb127f4c0d049626257981809a987fad86cd7`.

The first hand-written Expect harness failed only because its PTY exposed no usable terminal geometry. Replacing it with the same Linux `script(1)` PTY mechanism used by the permanent menu test made the unchanged stream succeed, confirming the failure was harness-only.


## rsudo source-injection transport

The rsudo transport defect identified after PoC 051 has been corrected and promoted into the current RSUDO contract.

`rsudo_core` now consumes non-TTY stdin in interactive mode before deciding the ordinary no-command/default path. A non-empty source stream becomes a privileged remote shell program. When command operands are also present, their invocation is appended after the injected source in the same shell environment; normal quote-preserving mode preserves argv meaning and `--no-preserve-quotes` keeps its alternate command-passing behavior.

Source capture preserves trailing newlines by appending/removing a sentinel around command substitution. A non-empty source with no command operands executes as the complete remote shell program.

The canonical `RSUDO.md` contract now includes this behavior as RSUDO-22. Command and library manuals are aligned.

Permanent `tests/rumiai-os/rsudo/interactive.test` now covers both:

- injected source defining a function that is then invoked by command operands with an argument containing whitespace, including stdout/stderr and nonzero-status propagation;
- source-only interactive execution with no command operands.

The current full-product health run for this test revision froze runtime commit `3bc5ff3d06b457eb63b599f28b363f1876e930b0`; its Ubuntu/macOS jobs are still running at this checkpoint.

## End-to-end remote-menu PoC

PoC 052 under `rumiai-dev-PoCs/pocs/052-rsudo-menu-source-injection` validates the complete path against `rumiai-os@3bc5ff3d06b457eb63b599f28b363f1876e930b0`:

```text
explicit caller-selected libraries
→ generated loadlib-inject stream
→ rsudo --interactive stdin
→ real OpenSSH client
→ real Ubuntu 26.04 sshd
→ real sudo
→ privileged remote shell
→ existing menu command body
→ remote interactive PTY
```

The remote host contains no m runtime tree.

For this form, command argv is emitted explicitly as `set -- ...` immediately before the raw integrated-command body. This reproduces the normal m bootstrap boundary (command name removed, remaining argv visible while the command file is sourced) without wrapping the command body in an extra function.

The first PoC 052 runs reached the remote menu but inherited a 0x0 PTY geometry from CI. Setting the local controlling PTY to 24x80 before invoking rsudo allowed OpenSSH to propagate usable geometry. The final PoC run `36307771282` passed: the remote menu rendered, Enter selected the first item, the serialized result contained `enter one`, and rsudo returned status 0.

## Explicit stream generator

The user-facing generator surface is now implemented as the public function:

```text
loadlib_inject_stream <command-source> <library-reference>... -- [<command-arg>...]
```

in `lib/sys/sh/loadlib-inject-stream.lib.sh`, with its mandatory operational manual.

The generator validates the command source, the injection backend and every explicitly selected library before emitting source. The caller must explicitly include `core` and every other transitive/runtime candidate. No source parsing, dependency discovery or closure logic exists.

The generated stream reproduces the proven PoC representation: ordinary `loadsyslib`, `loadlib-inject`, numbered embedded-library wrappers, exact dispatcher, explicit core bootstrap, shell-safe command argv reconstruction and the raw command body.

The durable contract is promoted in `LIBRARY-INTERFACES.md` as LIB-15.

Permanent `tests/rumiai-os/bootstrap/library-loading.test` now verifies successful generation/execution with preserved whitespace+empty argv, generation of an intentionally incomplete preload set, deterministic runtime status 2 for the omitted dependency, explicit-core enforcement and missing-library rejection.

A full-product health run started from `rumiai-tests@a7027d8f97ea4a60613c6a9c6e703a8362ac086c` and froze `rumiai-os@ef93f108bbaf10333a7b550c1eabdcb72f0e973e`. It is in progress at this checkpoint.

## Next action

Inspect the current full-product Ubuntu 26.04 ARM64/macOS validation. Correct any generator/runtime regression it exposes. If the new generator test passes and only already-classified external live-package failures remain on macOS, close this task by performing the final consistency gate and propagating/removing the active handoff according to the normal lifecycle.

## Open questions

None in the loader/stream format itself. Validation outcome is the only remaining closure condition.
