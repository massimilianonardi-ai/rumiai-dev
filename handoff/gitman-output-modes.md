# gitman output presentation modes

Status: Complete
Updated: 2026-09-19

## Goal

Add explicit Git action output presentation modes to `gitman` so the default isolates every Git action in a real pager, including short output, while an alternate terminal mode intentionally leaves output accumulated in the normal terminal.

## Canonical outcome

Durable behavior is now defined by:

- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/PAGER.md`

The completed behavior is:

- `gitman` starts every invocation in `pager` output mode.
- The Git action menu exposes `p` to toggle `pager ↔ terminal`; the current mode is prefixed in the header so it remains visible even when long repository paths are truncated.
- The selected mode persists across repositories for the current gitman session.
- Pager mode forces every read-only action through Git `--paginate` with `GIT_PAGER=pager`.
- Pager mode preserves existing caller `LESS` content and appends `-R -+F -+X`, preventing one-screen auto-exit and permitting normal pager screen restoration.
- Pager exit is the acknowledgement; no second `Press any key` prompt is shown.
- Terminal mode uses Git `--no-pager`, prints repository/action attribution, leaves output accumulated in the normal terminal, and retains the explicit `Press any key to continue...` pause.
- `gitman` does not clear the normal terminal or inject arbitrary blank-line batches between actions.
- RumiAI `pager` prefers `less` whenever it is available on the host and falls back to POSIX `more`.

## Completed

- Mandatory preflight completed against current remote HEADs and current canonical sources.
- Active task handoff created before material changes.
- Canonical gitman and pager specifications updated.
- `bin/sys/gitman`, `bin/sys/pager` and both owner-local manuals updated.
- Permanent contract/PTY tests updated for both output modes and cross-host less preference.
- Development validation on exact `rumiai-os 124770453db50f1fac59496bee2d843aef9505fd`: pager PASS and gitman PASS.
- Formal validation on Linux/x86_64 using exact `rumiai-tests 2faa936aff8b98bea8cb8deb8a15de4259d8c99e` and disposable exact `rumiai-os 124770453db50f1fac59496bee2d843aef9505fd`:
  - pager: PASS 2, FAIL 0, SKIP 0, ERROR 0; validation environment CLEAN; scope VALIDATED.
  - gitman: PASS 2, FAIL 0, SKIP 0, ERROR 0; validation environment CLEAN; scope VALIDATED.
- Validation exposed two width-dependent presentation/test issues during the work unit:
  - repository-menu tests previously assumed an untruncated full path;
  - the output mode indicator was originally placed after the repository path and could itself be truncated.
  Both were corrected forward; the final mode prefix remains visible.
- Temporary development, validation and diagnostic workflows removed after evidence publication.
- Final consistency gate completed: canonical specifications, manuals, implementation, tests and validation scopes were re-read; superseded pager-selection and OS-specific pager-policy phrases were searched; no temporary workflow remains.
- Concurrent unrelated `handoff/service-model.md` changes in `rumiai-dev` were preserved.

## Current repository revisions

```text
rumiai-dev   17d6b4371aa7421b9bc4abb0fbdd6758872af95c
rumiai-os    124770453db50f1fac59496bee2d843aef9505fd
rumiai-tests c8ef4031192bd780ffacd152c3d4267083dc8f57
```

Formal validation suite revision:

```text
rumiai-tests 2faa936aff8b98bea8cb8deb8a15de4259d8c99e
```

## Next action

None. Durable state is promoted to canonical specifications and permanent tests.

## Blockers / open questions

None.
