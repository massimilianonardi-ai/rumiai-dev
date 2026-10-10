# diagnostic-observability-realignment

## Intent

Audit current `m`- and RumiAI-owned runtime code against the diagnostic/observability contract and realign evidence-confirmed legacy branches whose status codes, diagnostic identities or logging coverage remain flattened or ambiguous.

## Why pending

The current codebase predates `DIAGNOSTICS.md`. Existing code includes both good branch-specific status examples and legacy patterns that reuse the same status or generic diagnostic identity across many distinct failures. Realignment can affect callers, permanent tests and operational manuals, so it must be performed as a dedicated implementation/test work unit rather than by mechanically renumbering established interfaces.

## Scope

```text
rumiai-os     affected commands, libraries and bootstrap/runtime diagnostics
rumiai-tests  status/diagnostic/observability coverage for realigned behavior
rumiai-dev    only specification/manual/handoff realignment required by findings
```

Audit must distinguish internal statuses from already-observable/public statuses and preserve compatibility deliberately rather than renumbering by source position.

## Evidence

```text
specifications/rumiai-os/DIAGNOSTICS.md
rumiai-os/m
rumiai-os/lib/sys/sh/base.lib.sh
rumiai-os/bin/sys/srv
rumiai-os/bin/sys/state-path
rumiai-tests/tests/rumiai-os/log/
```

Current examples include reusable `fatal 1 execution execution-failed ... reason ...` / `fatal 2 execution invalid-arguments ...` patterns in larger commands, while existing primitives such as `pathsearch` and `log` already demonstrate distinct local status allocation.
