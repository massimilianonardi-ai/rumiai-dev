# rsudo fs transfer

Status: Active
Updated: 2026-09-25

## Goal

Rework the rsudo filesystem transfer module so get/put support safe streamed transfer of large administrative filesystem objects, staged replacement of existing destinations, explicit insufficient-space diagnostics, and preserved file/directory/symlink semantics.

## Current repository revisions

- rumiai-dev: 544fa4a0934f82cbb6192a6d30ea2b19c56bf726
- rumiai-os: 83aa1a18bf0fdbf24807119cad4dd9bb4b8ec8a0
- rumiai-tests: e1cbdd302ab3b5283a6529b4c748b774ba0f86e7

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
- caller TAR_OPTIONS is unset for transfer producer/consumer execution so environment configuration cannot silently enable dereferencing.
- awk remains in the implementation where it improves robustness for parsing/comparing multi-terabyte filesystem-space values instead of relying on the minimum integer width of POSIX shell arithmetic.

## Completed

- Mandatory preflight and current implementation inspection completed.
- GNU tar and current FreeBSD bsdtar documentation were checked: both archive symbolic links as symbolic links by default; dereference requires explicit options such as GNU -h/--dereference or bsdtar -L.
- Auxiliary GNU tar 1.35 execution on Debian 13 confirmed regular file, directory, symlink-to-file, symlink-to-directory and dangling symlink retain their object type when archived/restored without dereference options.
- Consolidated lib/sys/sh/rsudo/rsudo-mod-fs.lib.sh to one definition of each public function. Removed the older ls-based get implementation and successive duplicate get/put definitions.
- get now streams one filesystem object through tar, uses sibling local staging only when replacing an existing destination, and restores the previous destination if stage promotion fails.
- put now performs remote space preflight, never performs an implicit destructive fallback, streams directly into the privileged destination filesystem, applies requested metadata before promotion, and performs staged replacement with rollback.
- Space diagnostics distinguish staged-copy insufficiency where an explicit delete would make the estimate fit from the case where even reclaiming the existing destination would remain insufficient.
- Created res/sys/manual/rsudo-mod-fs.lib.sh documenting all four public functions and the streaming/staging/space behavior.
- Promoted observable fs behavior into specifications/rumiai-os/RSUDO.md as RSUDO-14 through RSUDO-19.
- Added tests/rumiai-os/rsudo/fs.test through the real rsudo entrypoint. Coverage includes regular files, directories, symlink-to-file, symlink-to-directory, dangling symlink, destination replacement, forced transfer failure before promotion, forced put/get promotion failure with rollback, insufficient staged space, preservation of the old destination, explicit-delete diagnostics, and successful retry after explicit fs delete.
- The published runtime file is byte-identical to the locally syntax-checked implementation (FNV-1a 32 e30b4456); the published fs.test is byte-identical to the locally syntax-checked test (FNV-1a 32 2dc5879c before failure-coverage strengthening; the strengthened local test was syntax-checked before publication).
- Auxiliary local smoke execution of the consolidated functions passed for put/get of regular files, directories, symlink-to-file, symlink-to-directory and dangling symlink, including successful replacement paths.

## Current state

Implementation, canonical rsudo contract, operational library manual and permanent test coverage are aligned.

Formal stable-host product validation has not been executed for the new repository revisions. The current environment cannot clone the repositories (no network resolution from the execution container), and the available GitHub connector does not expose workflow dispatch. Therefore auxiliary syntax/smoke evidence must not be represented as formal validation.

## Next action

Run the normal RumiAI validation path for the current rumiai-tests / rumiai-os revisions on an applicable stable host, inspect rsudo/fs.test together with full-suite regressions, then perform the completion gate and remove this handoff after successful closure.

## Blockers / open questions

- Formal stable-host validation is pending.
