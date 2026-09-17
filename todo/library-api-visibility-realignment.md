# library-api-visibility-realignment

## Intent

Audit existing RumiAI-owned libraries against the current public/internal function visibility convention and realign legacy function names plus dependent callers/tests where necessary.

## Why pending

The leading-underscore visibility contract was introduced after the current library set already existed. Current libraries therefore cannot be assumed compliant without inspection. Some newer libraries already use underscore-prefixed private helpers and unprefixed public functions, while older library code contains unprefixed helper-shaped functions whose intended API status must be established before renaming or documenting them.

This product/API migration is separate from the current workflow/documentation rule change and requires a dedicated implementation/test work unit.

## Scope

```text
rumiai-os     RumiAI-owned libraries and all product callers
rumiai-tests  affected permanent tests and API coverage
rumiai-dev    only contract/handoff realignment required by findings
```

Coordinate with the active `rumiai-os-man-documentation` task because stable library manuals require the intended public function set to be known and naming-aligned.

## Evidence

```text
specifications/rumiai-os/LIBRARY-INTERFACES.md
lib/sys/sh/core.lib.sh
lib/sys/sh/array.lib.sh
lib/sys/sh/mk-materialize.lib.sh
```

`array.lib.sh` and `mk-materialize.lib.sh` provide current examples of the desired public/internal spelling pattern. `core.lib.sh` demonstrates why legacy visibility intent must be audited rather than inferred from conversation memory or renamed mechanically.
