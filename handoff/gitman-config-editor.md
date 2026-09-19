# gitman configuration editor

Status: Complete
Updated: 2026-09-19

## Goal

Add a portable repository-configuration editing workflow to `gitman` without introducing a hard dependency on a non-standard editor.

## Current repository revisions

```text
rumiai-dev   bfa60820161af2bf243be034b823fc2cde4e9544
rumiai-os    9fcbc905e070799caf2ac72552d340621d7e03d8
rumiai-tests 50495b29e0c37d75830f39b1f265cbd42917b636
```

Formal validation suite revision:

```text
rumiai-tests 19fad2bb8adebf5703378416cbe530415266951f
```

## Applicable canonical sources

- `specifications/rumiai-os/GITMAN.md`
- `TESTING.md`
- `RUNNER.md`
- `TEST-PATTERNS.md`

## Completed

- Repository menu exposes `e` for configuration editing.
- Editor selection is `VISUAL` → `EDITOR` → `vi`; `nano` remains opt-in through the standard environment variables and is not a dependency.
- Editor variables are treated as executable identities/pathnames and are not shell-evaluated.
- Editor launches only after `menu` restores normal terminal state.
- Successful editor exit asks whether to reset/reload; No is default and No/cancel keeps the current in-memory repository set.
- Yes clears and reloads only configuration entries using existing decoding, Git validation, normalization, deduplication and aggregated error semantics.
- Explicit post-edit reload does not apply startup `.` fallback; zero valid repositories returns to filesystem acquisition.
- Non-zero editor exit preserves the current repository set and reports a bottom-footer error.
- Canonical specification and owner-local manual were updated.
- Permanent contract and interactive tests cover editor selection precedence, terminal restoration, No/Yes behavior, empty-config reload and non-zero editor exit.
- Development run on exact `rumiai-os 9fcbc905e070799caf2ac72552d340621d7e03d8`: PASS 2, FAIL 0, SKIP 0, ERROR 0.
- Formal validation on Linux/x86_64 using exact disposable `rumiai-os 9fcbc905e070799caf2ac72552d340621d7e03d8` and suite `19fad2bb8adebf5703378416cbe530415266951f`: PASS 2, FAIL 0, SKIP 0, ERROR 0; validation environment CLEAN; scope VALIDATED.
- Temporary development/validation workflows removed.
- Final consistency gate completed: diff reread, canonical specification/manual rechecked, validation scope pinned to the validated product revision, and no superseded save-only/menu-action wording remains in current searched surfaces.

## Current state

Durable contract is promoted to `specifications/rumiai-os/GITMAN.md`; product/manual/tests and validation scope are aligned.

## Next action

None.

## Blockers / open questions

None.
