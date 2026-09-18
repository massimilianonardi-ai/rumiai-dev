# RumiAI OS — `mk` source materialization specification

Status: **Normative specification — Active**  
Updated: 2026-09-17

## 1. Scope

This specification defines the exact contract of the currently implemented `mk` source-materialization capability.

The broader responsibility of the `mk` subsystem is defined by `MK.md`. This specification is subordinate to that lifecycle contract and MUST NOT be read as the complete definition of `mk`.

The capability defined here is deliberately limited to:

```text
source tree
+
materialization definition
    ↓
mk materialize
    ↓
useful root
```

It does not define the complete development lifecycle, project build graph, build-environment resolver, test lifecycle, local package installation or package integration.

The purpose of this capability is to establish a reusable source-to-useful-root boundary without making materialization the architectural center of `mk`.

## 2. Ownership and layer

`mk` belongs to the general-purpose technical substrate `m`.

It MUST NOT semantically depend on the branded RumiAI layer.

The current command implementing this capability is:

```text
bin/sys/mk
```

and, while this capability is implemented in shell and integrated with `m`, uses:

```sh
#!/usr/bin/env m
```

Direct shell libraries of this capability are grouped under:

```text
lib/sys/sh/mk/
```

and follow the normal `.lib.sh` library contract.

This shell implementation constrains only this current capability and does not establish an implementation-runtime contract for the broader `mk` subsystem.

No new environment variable is introduced by this specification.

## 3. Public CLI baseline

The public operation defined by this capability is:

```text
mk materialize <source-root> <definition-root> <useful-root>
```

The operands mean:

```text
<source-root>
    existing source tree to transform

<definition-root>
    existing declarative materialization definition

<useful-root>
    destination pathname that does not yet exist
```

No implicit current-directory discovery is part of this capability.

No option syntax is introduced.

This specification defines no other lifecycle subcommands.

## 4. Public exit status

The command uses:

```text
0  success
1  operational, filesystem, definition, or materialization failure
2  invalid CLI invocation
```

A syntactically valid invocation whose declared materialization type is not supported by the current installation fails with status `1`.

An invalid definition also fails with status `1`; it is data supplied to a valid operation, not invalid command syntax.

## 5. Definition model

`<definition-root>` is a directory of declarative data.

It MUST NOT be shell-sourced, evaled, or interpreted as executable configuration.

The capability requires exactly one common entry:

```text
<definition-root>/type
```

`type` is a regular, readable, non-executable, non-symlink scalar file containing exactly one LF-terminated non-empty line.

The materialization type grammar is:

```text
[a-z][a-z0-9-]*
```

The current supported value is:

```text
copy
```

The selected type owns validation of all remaining entries in the definition root. Unknown entries MUST NOT be silently ignored.

## 6. Adapter contract

A materialization type is implemented by a direct `mk` library named:

```text
lib/sys/sh/mk/mk-materialize-<type>.lib.sh
```

The type grammar makes direct pathname construction safe and deterministic.

A type library is sourced only in an isolated subshell used for one materialization operation.

Every type library exposes exactly:

```text
mk_materialize_type <source-root> <definition-root> <staging-root>
```

The inputs passed to the adapter are already canonical existing directories except for `<staging-root>`, which is an already-created private destination directory owned by the current `mk` invocation.

The adapter MUST:

```text
validate every type-specific definition entry
write only inside <staging-root>
not modify <source-root>
not modify <definition-root>
not publish package state
not write bin bindings
not write outside <staging-root>
```

The adapter returns:

```text
0  materialization success
1  invalid definition or materialization failure
2  invalid internal API invocation
```

Adapter status `2` is an internal contract error and is exposed by the public command as operational failure status `1`.

## 7. Generic path contract

`<source-root>` MUST:

```text
exist
be a directory
not be a symbolic link after the operand itself is resolved
be canonicalizable through the current `m` path primitive
```

`<definition-root>` follows the same requirements.

`<useful-root>` MUST NOT exist as any filesystem object, including a symlink.

Its parent directory MUST already exist as a real directory and MUST be canonicalizable.

The final useful root MUST NOT be equal to or nested under the source root.

The final useful root MUST NOT be equal to or nested under the definition root.

`mk` MUST NOT create arbitrary missing parent directories for the caller.

## 8. Staging and publication

`mk` does not materialize directly into the final pathname.

For each invocation it creates a private sibling staging directory in the parent of `<useful-root>`.

The staging pathname is implementation-private and MUST NOT be part of the public contract.

The final publication sequence is:

```text
validate all generic inputs
validate/select type adapter
create private staging directory
adapter materializes into staging
move staging to the requested useful-root pathname
```

Before final publication, `<useful-root>` MUST still be absent.

On ordinary failure after staging creation, `mk` performs best-effort cleanup of the staging directory.

The capability does not claim crash atomicity, journaled recovery, or concurrency locking beyond refusing pre-existing final/staging path collisions.

## 9. `copy` materialization type

The current concrete type is:

```text
copy
```

Its purpose is to materialize source trees that do not require compilation or another transformation engine.

The `copy` definition accepts exactly:

```text
type
```

Any additional entry in the definition root makes the definition invalid.

### 9.1 Source contents

The adapter copies all normal and hidden top-level entries from the source root recursively into the staging root.

Two cases exist for the definition root.

If the definition root is external to the source root, the entire source tree is copied.

If the definition root is inside the source root, the only supported embedded form is exactly:

```text
<source-root>/mk
```

and that top-level `mk` directory is excluded from the copied useful root.

Any other definition-root nesting inside the source tree is invalid.

### 9.2 Symlink baseline

The current `copy` type rejects a source tree containing symbolic links.

This guarantees that the copied useful root does not preserve an accidental persistent dependency on the development/source tree through symlink targets.

### 9.3 Source immutability

The adapter does not delete, rename, chmod, rewrite, or otherwise mutate source entries.

## 10. Useful-root contract

A successful materialization produces a directory that is independent of the source pathname for its ordinary file contents.

`mk materialize` itself does not perform package integration.

In particular, successful `mk materialize` MUST NOT:

```text
write under $m_PKG_DIR
create or modify package current/default selectors
create bin/ext* bindings
materialize package facility/dependency binding
modify pkg-catalog
```

The useful root is handed to a later consumer.

## 11. Relationship with `src/`

Local development source may reside under:

```text
$m_SRC_DIR
```

but `mk materialize` accepts an explicit source root and is not restricted to `$m_SRC_DIR`.

No successful materialized package/runtime may rely on a persistent link back into `$m_SRC_DIR` merely because its source originated there.

## 12. Relationship with `pkg`

The current package pipeline remains unchanged by this specification.

Today it is effectively:

```text
resolve
→ download
→ extract
→ pkg_integrate
```

and `pkg_integrate` receives an already prepared useful root.

This specification does not authorize a `pkg` modification or define package orchestration involving source materialization.

Any such integration requires its own promoted current contract in the appropriate `mk` and package specifications.

## 13. Local package installation is out of scope

This capability does not define local package installation and does not establish local-path install syntax, catalog emulation or a public `pkg_integrate` API.

Those concerns are outside this specification.

## 14. Build/dependency modeling is out of scope

This capability does not serialize or resolve build-environment requirements, build-scoped material or project dependency models.

It does not change the current `pkg` runtime dependency contract.

## 15. State

The `materialize` operation takes an explicit caller-owned output pathname and therefore introduces no persistent `mk` state contract.

## 16. Logging

Public diagnostics use the existing `log` facility and existing generic domains/message IDs where they fit.

This capability does not create a new language domain or new localized message IDs merely for `mk`.

## 17. POSIX contract

The current shell implementation and materialization adapters are POSIX.1-2024 / Issue 8 compliant under the current RumiAI development rules.

No Bash-specific feature, GNU-only option, or host-specific pathname is part of this capability contract.

POSIX shell is a contract of this current capability implementation and does not define an implementation runtime for the broader `mk` subsystem.

## 18. Current implementation files

The current materialization capability consists of these product files:

```text
bin/sys/mk
lib/sys/sh/mk/mk-materialize.lib.sh
lib/sys/sh/mk/mk-materialize-copy.lib.sh
```

Additional `mk` implementation files require a concrete responsibility covered by a promoted current contract.

## 19. Invariants

```text
MK-MAT-01  mk belongs to the m technical layer
MK-MAT-02  this specification governs `mk materialize <source-root> <definition-root> <useful-root>`, not the complete mk subsystem
MK-MAT-03  materialization definitions are declarative data and are never sourced/evaled
MK-MAT-04  `type` is the mandatory common scalar and selects an isolated type adapter
MK-MAT-05  adapters write only to a caller-independent staging useful root and never mutate source/definition
MK-MAT-06  final useful-root must not pre-exist and is published only after adapter success
MK-MAT-07  useful-root cannot be located inside source-root or definition-root
MK-MAT-08  current type `copy` accepts no fields other than `type`
MK-MAT-09  embedded copy definition is allowed only as `<source-root>/mk` and is excluded from output
MK-MAT-10  current copy materialization rejects symbolic links in the source tree
MK-MAT-11  mk materialization never writes package availability/default/public bindings
MK-MAT-12  package integration and local package installation are outside this capability contract
MK-MAT-13  no persistent mk state contract is introduced by the materialize operation
MK-MAT-14  this specification does not establish an implementation runtime for the broader mk subsystem
```
