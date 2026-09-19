# gitman command

Status: Complete
Updated: 2026-09-19

## Goal

Implement the technical `gitman` command as an interactive manager for local non-bare Git working trees, including repository acquisition/management, persisted initial-directory configuration and read-only Git actions.

## Canonical outcome

Durable behavior is now defined by:

- `specifications/rumiai-os/GITMAN.md`
- `specifications/rumiai-os/PAGER.md`
- `specifications/rumiai-os/MENU.md`

The completed implementation preserves Git's normal pager-selection behavior. The RumiAI `pager` command now implements the conventional zero-or-more-file pager role, including stdin mode and caller pager environment preservation.

## Completed

- `gitman` command and owner-local manual implemented.
- Initial candidates support explicit operands, user configuration fallback and `.` fallback.
- Git working-tree normalization/deduplication implemented.
- Repository add/remove/clear/save workflows implemented.
- Configuration newline/backslash round-trip encoding implemented.
- Overwrite confirmation for non-empty saved configuration implemented.
- Read-only Git actions implemented with normal Git pager selection.
- RumiAI `pager` expanded to stdin and multiple-file operation and caller `LESS*` environment preservation.
- Permanent pager and gitman contract/interactive tests added or realigned.
- Development run on exact `rumiai-os 97abcece0dbb9a4ae15fadf452c198e3c57a6037`: pager PASS 2/2; gitman PASS 2/2.
- Formal validation on Linux/x86_64 using `rumiai-tests f6590b2f8da99c897fa15d254acdbbe89a7a87fa` and exact disposable `rumiai-os 97abcece0dbb9a4ae15fadf452c198e3c57a6037`:
  - pager: PASS 2, FAIL 0, SKIP 0, ERROR 0; environment CLEAN; scope VALIDATED.
  - gitman: PASS 2, FAIL 0, SKIP 0, ERROR 0; environment CLEAN; scope VALIDATED.
- Final consistency gate completed after validation.
- Temporary development/validation workflows removed after evidence publication.

## Current repository revisions

```text
rumiai-dev   39b699308d9ad7aa3361d1c75375ccf47a982777
rumiai-os    97abcece0dbb9a4ae15fadf452c198e3c57a6037
rumiai-tests 5f5c0a14d313634bc00d52d1d05f32a0c3b1e85d
```

Formal validation suite revision:

```text
rumiai-tests f6590b2f8da99c897fa15d254acdbbe89a7a87fa
```

## Next action

None. Durable task state has been promoted to canonical specifications and permanent tests.

## Blockers / open questions

None.
