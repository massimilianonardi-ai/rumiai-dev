# RumiAI OS — Library interfaces

Status: **Current / normative**  
Updated: 2026-09-28

This specification defines the current interface-visibility and operational-documentation contract for `m`- or RumiAI-owned libraries.

## 1. Scope and library identity

A `m`- or RumiAI-owned library uses the ownership- and runtime-qualified layout defined by `FILESYSTEM-NAMING.md`. A library may be physically grouped below its runtime directory when a current subsystem contract defines that grouping.

For this contract, one library identity is the semantic owner plus the runtime-qualified library leaf; physical grouping directories are not part of that identity:

```text
<library-name>.lib.<runtime>
```

For example:

```text
lib/sys/sh/array.lib.sh
lib/sys/sh/pkg/pkg-install.lib.sh
lib/sys/js/mk.lib.js
```

have owner `sys` and library identities:

```text
array.lib.sh
pkg-install.lib.sh
mk.lib.js
```

The `.lib.<runtime>` components are part of the library identity. They are not documentation-format suffixes.

Package-owned external libraries are outside this `m`- or RumiAI-owned library contract unless another current specification explicitly adopts them.

## 2. System shell library loading

`core.lib.sh` provides the lowest shell-library loading primitive:

```text
loadlib <library-reference>
```

The root bootstrap directly dot-sources `$m_LIB_DIR/sys/sh/core.lib.sh` because
no owned library loader exists before that point. `core.lib.sh` defines the
normal filesystem-backed `loadlib`, then immediately loads
`sys/sh/base` through that primitive.

`loadlib` accepts exactly one library reference, resolves it below `m_LIB_DIR`
by appending `.lib.sh`, requires the resulting pathname to be a readable
regular file, and dot-sources that file in the current shell environment.

`base.lib.sh` establishes the common runtime and provides:

```text
loadsyslib <system-shell-library-reference>
```

`loadsyslib` accepts exactly one reference relative to `lib/sys/sh/` and
delegates it to the already-installed `loadlib` with the `sys/sh/`
owner/runtime prefix. This lets the same base runtime operate over the normal
filesystem loader or another explicitly established loader such as the
in-memory injection loader.

After base has been loaded, every `m`- or RumiAI-owned shell source that loads
an `m` system shell library under `lib/sys/sh/` MUST use `loadsyslib`.
The two bootstrap-level exceptions are the root bootstrap's direct dot-source of
`core.lib.sh` and core's initial `loadlib "sys/sh/base"` call. Direct
dot-sourcing of other owned system shell libraries is not a caller mechanism.

This rule does not replace ordinary POSIX dot-sourcing for pathnames that are runtime data rather than owned system-library references, such as package adapters or other explicitly external/runtime-selected source files.

The library reference used by `loadsyslib` is the physical path below `lib/sys/sh/` without the final `.lib.sh`, for example:

```text
array
pkg/pkg-install
pkg/facility/pkg-dependency
rsudo/rsudo-mod-fs
```

The loading primitive intentionally carries no positional-parameter forwarding contract: one library reference is the complete call interface.

### Explicit injection stream generation

The system library:

```text
loadlib-inject-stream.lib.sh
```

provides:

```text
loadlib_inject_stream
    [<library-reference> | --command <command-name> <local-source>]...
    [-- <command-source> [<command-arg>...]]
```

for generating one POSIX-shell source program that embeds an explicitly selected
set of system shell libraries and local command sources for execution without a
remote `m` library tree.

The caller owns the complete selected library and command-source set. The
generator MUST NOT parse command or library sources to discover dependencies and
MUST NOT compute or add transitive closure. No library identity is intrinsically
mandatory or special.

Before the final `--`, library references and repeatable `--command`
registrations may be interleaved.

For each selected library, the generated program installs one private wrapper
and an in-memory `loadlib` dispatch for exactly the selected references. It
then loads every selected library through that loader in caller-supplied order.
Zero selected libraries are valid; in that case generated `loadlib` returns
status 2 for every library lookup.

`--command <command-name> <local-source>` registers one reusable injected
command. `command-name` MUST already be a valid POSIX shell identifier:
alphabetic or underscore first character, followed only by alphabetic
characters, digits or underscore. Duplicate command names are invalid.
`loadlib` and names beginning `_loadlib_inject_stream_` are reserved by the
generated runtime.

Each registered command is generated as a function with exactly the
caller-selected name and with a subshell compound command as its body. Each
invocation therefore receives its own positional parameters and isolates
command-local variable/function definitions, traps, current directory, umask,
additional file descriptors, shell-option changes and `exit`/`exec` effects
from the containing generated shell. Injected library functions and inherited
environment remain available inside that subshell.

The generator does not inspect injected library or command contents for
non-reserved namespace collisions. Compatibility between caller-selected
command names and library/source-defined names remains a caller responsibility.

The final literal `--` is optional and non-repeatable. When present it MUST be
followed by one readable `command-source`; remaining operands are its command
arguments. The public calling syntax remains the existing one-shot command mode,
but the generated program now places that source in one private subshell wrapper
and invokes it once with the supplied arguments. This gives the one-shot source
the same process-state isolation as named commands without changing the caller
syntax.

If the one-shot invocation is the final generated operation, its status is the
generated program status. If later stdin source exists, ordinary shell
sequencing applies and the first subsequent command may observe the one-shot
status through `$?`.

Independently of command mode, non-TTY standard input is appended verbatim after
library loading, named-command definitions and the optional one-shot invocation
as POSIX shell source. It is source to be included in the generated program, not
runtime stdin for an injected command. A source-separating newline MUST prevent
accidental lexical merging.

Named commands remain available in the containing generated shell and may be
called repeatedly by the one-shot command or by subsequent stdin source. Each
invocation remains isolated in its own subshell.

The generator contains no semantic dependency on `base.lib.sh`,
`core.lib.sh`, or another particular library identity. Callers that need the
common m runtime select `base` explicitly like any other library.

A library that was not explicitly selected remains unavailable in the generated
environment rather than falling back to a remote filesystem.

Stream generation and stream transport are separate responsibilities. In
particular, `rsudo --interactive` may transport a generated stream through its
interactive source-injection contract, but `loadlib_inject_stream` itself does
not perform remote execution.

## 3. Public and internal function visibility

Every function defined as part of a `m`- or RumiAI-owned library must be classified as either:

```text
public
internal
```

The naming contract is mandatory:

```text
public function
    name MUST NOT begin with _

internal function
    name MUST begin with _
```

The leading underscore is the library-interface visibility marker defined by this contract. It does not provide language-level access control; callers MUST nevertheless treat underscore-prefixed library functions as implementation-private and MUST NOT depend on them as callable API.

A runtime-specific specification may impose stricter valid-function-name syntax, but it must not silently invert this public/internal leading-underscore meaning.

A function changing from public to internal or internal to public is an interface change and therefore requires the corresponding rename plus caller, test and manual realignment in the same authorized work unit.

## 4. Library operational manual

Every `m`- or RumiAI-owned library identity MUST have exactly one owner-local operational manual topic under the `manual` resource class defined by `DOCUMENTATION-MODEL.md`.

The topic identity is exactly the runtime-qualified library leaf:

```text
res/<owner>/manual/<library-name>.lib.<runtime>
```

For example:

```text
lib/sys/sh/array.lib.sh
    ↓
res/sys/manual/array.lib.sh

lib/sys/sh/pkg/pkg-install.lib.sh
    ↓
res/sys/manual/pkg-install.lib.sh
```

This deterministic mapping keeps command and library topics distinct even when their semantic base names coincide.

The library manual documents the library as one unit. It MUST expose the complete public function interface and MUST NOT expose internal functions as callable API.

For each public function, document the operationally relevant contract, including as applicable:

```text
function name and invocation shape
arguments / operands
output and returned data
return status
side effects / state mutation
required environment or dependencies
important caller obligations
```

Internal function identifiers MUST NOT be listed or documented as part of the library API. Implementation rationale and private helper structure remain implementation concerns rather than operational reference.

A library with no public function interface still requires its library manual topic; the page states that it exposes no public callable functions rather than documenting internal helpers.

## 5. Development lifecycle coupling

Library implementation, public API naming and operational documentation are one consistency unit.

```text
create library
    classify its functions
    apply the visibility naming contract
    create its manual topic in the same work unit

rename/remove library
    realign/remove the corresponding manual topic in the same work unit

modify library
    verify function visibility naming
    perform a library/manual consistency check

add/change/remove public function
    update the library manual in the same work unit

internal-only implementation change
    no manual text change is required when the public manual remains fully accurate
```

A library work unit is incomplete while:

```text
the required manual topic is missing
public/internal function naming disagrees with the intended visibility classification
the manual omits a public function
the manual advertises an internal function as API
the implemented public interface and manual disagree
```

## 6. Mechanical coverage

Permanent structural coverage MUST recursively detect every `m`- or RumiAI-owned library below an owner/runtime library tree and detect every library identity that lacks its required owner-local manual topic. Physical subsystem grouping directories MUST NOT create nested manual-topic identities.

The current plain-text manual model does not by itself make prose a machine-readable API declaration. Mechanical page-presence coverage therefore does not prove that every public function is documented or that an internal helper is absent from prose; those semantic checks remain part of library development and the final consistency gate.

A future richer documentation source model may make stronger API/manual consistency checks possible without changing the visibility contract defined here.

## 7. Invariants

```text
LIB-01  every `m`- or RumiAI-owned library function is classified as public or internal
LIB-02  public library function names do not begin with _
LIB-03  internal library function names begin with _
LIB-04  underscore-prefixed library functions are implementation-private API even where the runtime cannot enforce privacy
LIB-05  every `m`- or RumiAI-owned library identity has exactly one owner-local manual topic
LIB-06  a library manual topic uses the exact <library-name>.lib.<runtime> library leaf as topic identity
LIB-07  a library manual exposes all public functions and does not expose internal functions as callable API
LIB-08  library/API/manual realignment occurs in the same work unit for interface-affecting changes
LIB-09  structural permanent coverage recursively detects missing mandatory library manual topics across grouped library directories
LIB-10  physical subsystem grouping directories are not part of library identity or manual topic identity
LIB-11  core.lib.sh provides filesystem loadlib and loads base.lib.sh; base.lib.sh provides loadsyslib and the common runtime
LIB-12  after base loading, every owned lib/sys/sh shell-library import uses loadsyslib; bootstrap direct-load of core and core's initial loadlib of base are the two bootstrap-level exceptions
LIB-13  loadsyslib/loadlib accept exactly one library reference and do not forward positional parameters
LIB-14  runtime/external pathname sourcing remains ordinary POSIX dot-sourcing
LIB-15  loadlib_inject_stream embeds only caller-selected libraries and performs no dependency discovery or automatic closure
LIB-16  loadlib_inject_stream permits zero or more selected libraries, repeatable explicitly named isolated --command sources, one optional isolated one-shot command after --, and subsequent non-TTY stdin shell source
LIB-17  injected named and one-shot command bodies execute in subshells that isolate command-local process state while retaining access to the explicitly injected library environment
LIB-18  --command names are caller-selected valid POSIX shell identifiers; duplicate names and generator-reserved identities are rejected without filename derivation, sanitization or aliasing
```