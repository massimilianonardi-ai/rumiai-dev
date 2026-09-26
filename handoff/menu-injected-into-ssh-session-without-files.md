# Menu injected into SSH session without files

Status: Active
Updated: 2026-09-26

## Goal

Define and validate source streaming that can inject an existing `m` command plus an explicitly selected set of required system shell libraries through `rsudo --interactive`, execute it on a remote host, and avoid creating or copying a RumiAI/m runtime tree there.

## Current repository revisions at this checkpoint

- rumiai-dev: b065844c8a419067fa5a15023268e24c22140c3a
- rumiai-os: 51d0cba5696a94caaf5ae39e2e476a31598a0ae1
- rumiai-tests: c5dbf627300d095215da21bc07362de03e09337f

Always re-read remote HEADs before resuming; these values are checkpoint evidence, not authoritative future HEADs.

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

A new full-product validation run is active against the same frozen current `rumiai-os` revision using the canonical Ubuntu 26.04 ARM64 host plus macOS. This run, not the incompatible Ubuntu 24.04 run, is the completion evidence required before the task moves into stream-generation/injection work.

## Next action

Inspect the new full-product health run triggered by rumiai-tests `c5dbf627300d095215da21bc07362de03e09337f` completely on Ubuntu 26.04 ARM64 and macOS. Resolve any remaining current-contract failures before continuing.

Do not proceed to stream generation or rsudo injection integration until the global `loadsyslib` migration has passed this full-product validation milestone.

After that milestone, define the explicit preload declaration/stream format around `loadlib-inject.lib.sh` and connect it to the already-existing `rsudo --interactive` source-injection path.

## Open questions

- Exact user-facing preload declaration surface / generated stream format.
- Exact generated dispatcher/wrapper representation for the explicitly embedded libraries.

These questions belong to the post-migration injection phase and must not be used to weaken or bypass the current full-product validation requirement.
