# rsudo fs transfer

Status: Active
Updated: 2026-09-25

## Goal

Rework the rsudo filesystem transfer module so get/put support safe streamed transfer of large administrative filesystem objects, staged replacement of existing destinations, explicit insufficient-space diagnostics, and preserved file/directory/symlink semantics.

## Current repository revisions

- rumiai-dev: 4f055017f950d2c2cc4331be0ca46e3b56df8add
- rumiai-os: 29d1c316d92ee2f68fd5d3bcf2bc59ceb5032785
- rumiai-tests: 318500723ee2674d951b9ab5a8df584adcd2db08

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/RSUDO.md
- specifications/rumiai-os/FILESYSTEM-NAMING.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- specifications/rumiai-os/LIBRARY-INTERFACES.md
- specifications/rumiai-os/DOCUMENTATION-MODEL.md
- TESTING.md
- TEST-PATTERNS.md
- RUNNER.md

## Fixed task-local choices

- put never performs an implicit destructive fallback when staged replacement lacks space; the user must explicitly delete the existing remote destination first.
- transfers remain streamed directly between source and final filesystem; no intermediate scp/sftp staging area is introduced.
- existing destinations are replaced through a sibling staging pathname in the same parent filesystem, with rollback if promotion fails.
- file, directory and symbolic-link transfer semantics are protected explicitly; tar is used without dereference options and source operands are passed without trailing slash.
- awk remains acceptable where it improves robustness for large numeric filesystem-space comparisons.

## Completed

- Mandatory preflight and current implementation inspection completed.
- GNU tar and bsdtar documentation were checked: both archive symbolic links as symbolic links by default; dereference requires explicit options such as -h/-L.
- Auxiliary GNU tar execution confirmed regular file, directory, symlink-to-file, symlink-to-directory and dangling symlink retain their object type when archived/restored without dereference options.

## Current state

The current rsudo-mod-fs.lib.sh contains multiple successive definitions of get and put from the ongoing redesign. The module requires consolidation into one implementation per public function, with comments and contract/manual/test alignment.

## Next action

Consolidate the runtime implementation, update the rsudo filesystem contract and library manual, add proportional permanent coverage, then run the applicable consistency and validation checks.

## Blockers / open questions

- None.
