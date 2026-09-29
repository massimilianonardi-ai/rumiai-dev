# rsudo admin console

Status: Complete
Updated: 2026-09-29

## Goal

Create the m-owned interactive `rsudo-admin` command for host connection,
remote filesystem browsing, rsudo job execution, and encrypted-file
load/edit/new workflows.

## Current repository revisions

- rumiai-dev: d39aa5896910b16383f62e7acae66d215ee93edf before this final handoff snapshot
- rumiai-os: 584e49172e7adf613992f59d67fc3705cea96540
- rumiai-tests: 9df329a363696de6f7fba83f7c103381539699a5

Fresh remote HEAD retrieval remains mandatory before any later work.

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/rumiai-os/CURRENT-MODEL.md
- specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- specifications/rumiai-os/MENU.md
- specifications/rumiai-os/VSED.md
- specifications/rumiai-os/EDITOR.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/SSH.md
- TESTING.md
- TEST-PATTERNS.md

## Fixed task-local choices

None remain. Durable rsudo-admin behavior is promoted into
`specifications/rumiai-os/RSUDO.md`; revision-coupled operational detail lives
in `res/sys/manual/rsudo-admin`.

## Completed

- Added executable `bin/sys/rsudo-admin` as a bootstrap-integrated m command.
- Added the requested top-level actions: Connect to host, Browse host,
  rsudo jobs, and Encrypted file load/edit/new.
- Host selectors discover non-empty
  `RSUDO_CREDENTIALS_GROUP_<group>_HOST` state and use the corresponding
  credential group without displaying passwords.
- Connect starts an action-local interactive rsudo session.
- Browse composes the accepted `base array map term menu` injection and opens
  the privileged remote filesystem browser at `/`.
- Jobs select an explicit local library and template, source the library inside
  job-local execution state, create a private temporary template copy, edit it
  through `editor`, validate it with POSIX `sh -n`, execute it in an
  additional subshell, and clean up the temporary copy.
- Encrypted-file load/edit/new reuses `encoded_file_eval`,
  `encoded_file_edit`, and memory-only `vsed`; new-file creation publishes
  ciphertext without creating a plaintext temporary file.
- The separately discussed future data-only restriction for rsudo `--load`
  was deliberately not folded into this work unit.
- Removed the superseded
  `lib/sys/sh/rsudo/rsudo-jobs-template`.
- Added `res/sys/manual/rsudo-admin`.
- Promoted the public command contract into
  `specifications/rumiai-os/RSUDO.md`.
- Added permanent tests:
  `tests/rumiai-os/rsudo-admin/contract.test` and
  `tests/rumiai-os/rsudo-admin/interactive.test`.
- Added task validation scope `validation/rsudo-admin.conf` and formal
  multi-host workflow `.github/workflows/rsudo-admin.yml`.
- Formal validation run 36560721878 froze
  `rumiai-os@584e49172e7adf613992f59d67fc3705cea96540` and
  `rumiai-tests@9df329a363696de6f7fba83f7c103381539699a5`.
  Ubuntu 26.04 ARM and macOS both executed the two rsudo-admin tests with:
  PASS 2, FAIL 0, SKIP 0, ERROR 0.
- Final diff/manual/specification scan found no current product references to
  the superseded `rsudoenv`, `waituser`, or `rsudo-jobs-template`
  mechanisms.
- An auxiliary container checkout could not be run because that environment
  could not resolve github.com; formal hosted validation supplied the real
  revision-pinned execution evidence instead.

## Current state

The requested command, operational manual, canonical rsudo contract, permanent
tests and task-validation path are aligned at the revisions above.

An automatically triggered full-product health run from the earlier test commit
was still in progress when task validation completed; it is additional evidence
and is not required by the rsudo-admin task scope.

## Next action

None.

## Blockers / open questions

None.
