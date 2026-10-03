# library API visibility realignment

## Intent

Audit remaining libraries owned by m or RumiAI against the current public/internal function visibility convention and realign legacy function names plus dependent callers/tests where necessary.

## Why pending

The eliminated pkg-validator caller cleanup is complete, but the broader visibility migration remains open. Current pkg code still contains known cross-library dependencies on underscore-prefixed helpers that continue to exist, and non-pkg libraries have not yet been exhaustively classified.

## Scope

```text
rumiai-os     owned libraries and all affected product callers
rumiai-tests  affected permanent tests and API coverage
rumiai-dev    contract/handoff realignment required by findings
```

Coordinate with the active rumiai-os manual-documentation task because stable library manuals require the intended public function set to be known and naming-aligned.

## Evidence

```text
specifications/rumiai-os/LIBRARY-INTERFACES.md
handoff/rumiai-os-man-documentation.md
lib/sys/sh/pkg/pkg-install.lib.sh
lib/sys/sh/pkg/pkg-uninstall.lib.sh
lib/sys/sh/pkg/pkg-state.lib.sh
lib/sys/sh/pkg/pkg-integration.lib.sh
lib/sys/sh/core.lib.sh
```

Known pkg examples include callers of `_pkg_integration_set_concrete` and `_pkg_integration_link_target_read`; these are a different issue from references to functions that were actually removed.
