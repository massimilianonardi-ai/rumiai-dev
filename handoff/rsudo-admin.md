# rsudo admin console

Status: Active
Updated: 2026-09-29

## Goal

Create the m-owned interactive `rsudo-admin` command for host connection,
remote filesystem browsing, rsudo job execution, and encrypted-file
load/edit/new workflows.

## Current repository revisions

- rumiai-dev: 0aeff0ea730d52abcf3079086900f7e7adbcb23c
- rumiai-os: 0c56665c5be7b6aac4c097dad1b000ce97bb6ac7
- rumiai-tests: 238ab53839814579ed0ed49400ae59864028a405

Fresh remote HEAD retrieval remains mandatory before future writes.

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
- handoff/rsudo-injection-menu.md
- handoff/rsudo-ssh-auth.md

## Fixed task-local choices

- Public command identity is `rsudo-admin`; `console` is presentation rather
  than command-function identity.
- The command belongs to m and is bootstrap-integrated.
- The main menu entries are Connect to host, Browse host, rsudo jobs, and
  Encrypted file load/edit/new.
- Host discovery uses in-memory
  `RSUDO_CREDENTIALS_GROUP_<group>_HOST` variables and selects the
  corresponding group through current rsudo state.
- Remote browsing reuses the accepted explicit injection composition
  `base array map term menu` and the current `menu -d /` command source.
- Jobs modernize the tracked `lib/sys/sh/rsudo/rsudo-jobs-template` workflow:
  select and source one local job library, copy one selected template to a
  private temporary file, edit through the m `editor` command, execute the
  edited copy as local shell source, and always remove the temporary copy.
- Job execution occurs in a subshell so job-local shell state cannot pollute
  the admin console, while inherited rsudo credential state remains available.
- Encrypted-file editing reuses `encoded_file_edit`; loading reuses the
  current public `encoded_file_eval` semantics. This task does not silently
  implement the separately discussed future restriction of rsudo --load.
- New encrypted files are created without plaintext temporary files.

## Completed

- Mandatory preflight completed.
- Existing rsudo/menu/editor/vsed/encryption/injection surfaces inspected.
- Existing `rsudo-jobs-template` identified as the predecessor of the requested
  jobs workflow.

## Current state

Implementation, manual and permanent tests are not yet written.

## Next action

Implement `bin/sys/rsudo-admin` and its operational manual, then add
proportional permanent coverage and validate the resulting revisions.

## Blockers / open questions

None.
