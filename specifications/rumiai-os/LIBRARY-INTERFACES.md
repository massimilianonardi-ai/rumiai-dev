# RumiAI OS — Library interfaces

Status: **Current / normative**  
Updated: 2026-09-17

This specification defines the current interface-visibility and operational-documentation contract for RumiAI-owned libraries.

## 1. Scope and library identity

A RumiAI-owned library uses the ownership- and runtime-qualified layout defined by `FILESYSTEM-NAMING.md`. A library may be physically grouped below its runtime directory when a current subsystem contract defines that grouping.

For this contract, one library identity is the semantic owner plus the runtime-qualified library leaf; physical grouping directories are not part of that identity:

```text
<library-name>.lib.<runtime>
```

For example:

```text
lib/sys/sh/array.lib.sh
lib/sys/sh/pkg/pkg-install.lib.sh
lib/sys/sh/mk/mk-materialize.lib.sh
```

have owner `sys` and library identities:

```text
array.lib.sh
pkg-install.lib.sh
mk-materialize.lib.sh
```

The `.lib.<runtime>` components are part of the library identity. They are not documentation-format suffixes.

Package-owned external libraries are outside this RumiAI-owned library contract unless another current specification explicitly adopts them.

## 2. Public and internal function visibility

Every function defined as part of a RumiAI-owned library must be classified as either:

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

The leading underscore is the RumiAI library-interface visibility marker. It does not provide language-level access control; callers MUST nevertheless treat underscore-prefixed library functions as implementation-private and MUST NOT depend on them as callable API.

A runtime-specific specification may impose stricter valid-function-name syntax, but it must not silently invert this public/internal leading-underscore meaning.

A function changing from public to internal or internal to public is an interface change and therefore requires the corresponding rename plus caller, test and manual realignment in the same authorized work unit.

## 3. Library operational manual

Every RumiAI-owned library identity MUST have exactly one owner-local operational manual topic under the `manual` resource class defined by `DOCUMENTATION-MODEL.md`.

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

## 4. Development lifecycle coupling

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

## 5. Mechanical coverage

Permanent structural coverage MUST recursively detect every RumiAI-owned library below an owner/runtime library tree and detect every library identity that lacks its required owner-local manual topic. Physical subsystem grouping directories MUST NOT create nested manual-topic identities.

The current plain-text manual model does not by itself make prose a machine-readable API declaration. Mechanical page-presence coverage therefore does not prove that every public function is documented or that an internal helper is absent from prose; those semantic checks remain part of library development and the final consistency gate.

A future richer documentation source model may make stronger API/manual consistency checks possible without changing the visibility contract defined here.

## 6. Invariants

```text
LIB-01  every RumiAI-owned library function is classified as public or internal
LIB-02  public library function names do not begin with _
LIB-03  internal library function names begin with _
LIB-04  underscore-prefixed library functions are implementation-private API even where the runtime cannot enforce privacy
LIB-05  every RumiAI-owned library identity has exactly one owner-local manual topic
LIB-06  a library manual topic uses the exact <library-name>.lib.<runtime> library leaf as topic identity
LIB-07  a library manual exposes all public functions and does not expose internal functions as callable API
LIB-08  library/API/manual realignment occurs in the same work unit for interface-affecting changes
LIB-09  structural permanent coverage recursively detects missing mandatory library manual topics across grouped library directories
LIB-10  physical subsystem grouping directories are not part of library identity or manual topic identity
```