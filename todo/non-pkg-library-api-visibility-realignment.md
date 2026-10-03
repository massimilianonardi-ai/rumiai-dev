# non-pkg library API visibility realignment

## Intent

Audit remaining m- or RumiAI-owned libraries outside the pkg subsystem against the current public/internal function visibility convention and realign legacy function names plus dependent callers/tests where necessary.

## Why pending

The pkg subset has been activated as its own task. Other owned libraries may still contain legacy visibility mismatches and remain intentionally deferred.

## Scope

```text
rumiai-os     non-pkg libraries owned by m or RumiAI and their callers
rumiai-tests  affected permanent tests and API coverage
rumiai-dev    contract/handoff realignment required by findings
```

Coordinate with the active rumiai-os manual-documentation task because stable library manuals require the intended public function set to be known and naming-aligned.

## Evidence

```text
specifications/rumiai-os/LIBRARY-INTERFACES.md
handoff/rumiai-os-man-documentation.md
lib/sys/sh/core.lib.sh
lib/sys/sh/array.lib.sh
lib/sys/sh/mk-materialize.lib.sh
```
