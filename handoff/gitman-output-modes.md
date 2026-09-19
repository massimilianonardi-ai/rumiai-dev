# gitman output presentation modes

Status: Active
Updated: 2026-09-19

## Goal

Add explicit Git action output presentation modes to `gitman` so the default isolates every Git action in a real pager, including short output, while an alternate terminal mode intentionally leaves output accumulated in the normal terminal.

## Current repository revisions

```text
rumiai-dev   7f95ec1523a86712babcd5ca34afedd1caf76035
rumiai-os    cf2e2e02ac9da54a993c7f5f118f72fe6dbdbe06
rumiai-tests 4af4183219ff42f07c9e6f116afc01ee0d3d2113
```

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`
- `specifications/README.md`
- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/PAGER.md`
- `specifications/rumiai-os/MENU.md`

## Fixed task-local choices

- Git action presentation has two explicit modes: `pager` and `terminal`.
- The initial/default mode for every `gitman` invocation is `pager`.
- Pager mode forces every supported Git action through a pager rather than relying on per-command Git pager defaults.
- Pager mode must not auto-exit merely because output fits on one screen.
- Pager mode should use normal terminal-screen lifecycle so paged output does not accumulate in the underlying terminal after the pager exits.
- Terminal mode disables Git paging and intentionally leaves command output in the normal terminal.
- Arbitrary `clear` calls or batches of blank lines are not used as a substitute for these explicit presentation modes.
- The Git action menu exposes a direct mode-toggle action and shows the current mode.
- Pager-mode exit itself is the user acknowledgement; the existing `Press any key to continue...` pause remains for terminal mode only.

## Working design

- Use Git's documented global `--paginate` switch in pager mode and `--no-pager` in terminal mode.
- In pager mode, select the RumiAI `pager` command explicitly through `GIT_PAGER=pager`.
- Compose `LESS` so existing caller options are preserved while `-R` is enabled and `F`/ `X` are explicitly disabled (`-+F -+X`), preventing one-screen auto-exit and allowing normal screen restoration when the selected backend is `less`.
- Generalize the RumiAI pager backend policy to prefer `less` whenever it is available on a current host, with `more` as degraded fallback; this gives the explicit pager mode consistent behavior without exposing a new pager-specific option surface.
- Proposed Git-action-menu key: `p` toggles `pager ↔ terminal`.

## Completed

- Mandatory preflight completed against current remote HEADs.
- Current gitman/pager/menu specifications, implementation and permanent tests inspected.
- Git upstream behavior verified: `--paginate` forces paging when stdout is a terminal; Git's default `LESS=FRX` includes `F` (quit if one screen), and `less -+F` disables that behavior.

## Current state

No product/spec/test modification for this work unit has been made yet.

## Next action

Promote the agreed presentation-mode contract into `GITMAN.md` and the cross-host pager backend refinement into `PAGER.md`, then implement command/manual changes and permanent tests.

## Blockers / open questions

None.
