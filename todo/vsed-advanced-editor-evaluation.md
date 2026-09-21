# vsed advanced editor evaluation

## Intent

Evaluate a future evolution of `vsed` from the current minimal visual stream editor into a high-quality general terminal editor, adding advanced editing capabilities only where they can preserve its defining security, stream/file and portability properties.

## Why pending

The current `vsed` implementation has reached its intended first-delivery goal and is usable for the sensitive in-memory editing use case. Advanced editor capabilities are explicitly outside the current contract and should be designed as a separate future work unit rather than expanding the present implementation opportunistically.

## Scope

```text
rumiai-dev    evaluate and, if accepted, promote the future advanced-editor contract
rumiai-os     evolve vsed and any existing terminal abstractions that genuinely need extension
rumiai-tests  add proportional permanent cross-host coverage for promoted capabilities
```

The future evaluation should include the advanced capabilities currently listed as non-goals in the `vsed` specification, together with editor usability, rendering/performance and interaction quality, without assuming in advance that every candidate capability should be implemented.

Any accepted evolution must preserve or explicitly reconcile the current memory-only handling guarantee, sensitive-content boundary, stdin/stdout and file semantics, POSIX portability target, and interactive performance.

## Evidence

```text
specifications/rumiai-os/VSED.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
bin/sys/vsed
lib/sys/sh/term.lib.sh
tests/rumiai-os/vsed/
```
