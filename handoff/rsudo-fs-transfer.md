# rsudo fs transfer

Status: Active
Updated: 2026-09-25

## Goal

Rework the rsudo filesystem transfer module so get/put support safe streamed transfer of large administrative filesystem objects, staged replacement of existing destinations, explicit insufficient-space diagnostics, and preserved file/directory/symlink semantics.

## Current repository revisions

- rumiai-dev: e31b993ba955430f91e04e4bbcd15a2e5a4e89dd
- rumiai-os: eaf015fe516713c73eccceb9339a5b624fe63c76
- rumiai-tests: de7a0ddfc59cffd9a14c199f7452fc00186f5692

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
- Auxiliary local smoke execution of the consolidated functions passed for put/get of regular files, directories, symlink-to-file, symlink-to-directory and dangling symlink, including successful replacement paths.
- Confirmed that tests/rumiai-os/rsudo/fs.test exists on the current rumiai-tests revision.
- Added validation/rsudo-fs.conf as a focused task scope selecting only rumiai-os/rsudo/fs.test, so this work unit can be formally validated without running the complete product suite.
- First macOS focused validation against rumiai-tests d96b3d5bbf69d25fe39d147b2d3f88195dae8bc6 and rumiai-os eaf015fe516713c73eccceb9339a5b624fe63c76 produced TEST ERROR before test execution; the published session recorded observed termination 126.
- Root cause was test file mode 100644: the runner executes .test programs directly through their shebang, so fs.test was not executable. Changed only tests/rumiai-os/rsudo/fs.test mode to 100755 in rumiai-tests de7a0ddfc59cffd9a14c199f7452fc00186f5692; blob/content is unchanged.

## Current state

Implementation, canonical rsudo contract, operational library manual and permanent test coverage are aligned.

The first focused stable-host invocation reached the test but ended as TEST ERROR because fs.test lacked its executable bit. That test-infrastructure defect is fixed in rumiai-tests de7a0ddfc59cffd9a14c199f7452fc00186f5692. No post-fix formal validation result exists yet.

## Next action

From the rumiai-tests repository on a stable host, run:

./rumiai-validate rsudo-fs

This self-updates rumiai-tests to the executable fs.test revision, resolves the current committed rumiai-os revision and executes the focused rsudo fs task test. Inspect the resulting evidence, then perform the completion gate and remove this handoff after successful closure.

## Blockers / open questions

- Post-fix formal stable-host rsudo-fs task validation is pending.
