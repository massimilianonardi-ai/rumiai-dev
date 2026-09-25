# rsudo fs transfer

Status: Complete
Updated: 2026-09-25

## Goal

Rework the rsudo filesystem transfer module so get/put support safe streamed transfer of large administrative filesystem objects, staged replacement of existing destinations, explicit insufficient-space diagnostics, and preserved file/directory/symlink semantics.

## Current repository revisions

- rumiai-dev: ecb0985fa5afd32f748c3e8d775903da8f198be5
- rumiai-os: 4781025f6639454cdc16905a894aa366ec0ce630
- rumiai-tests: e91b0413ce76b2ca2b288afdd8f6537afd56f183

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

- get and put never perform an implicit destructive fallback when staged replacement lacks space; the user must explicitly delete the existing destination first (local destination for get, remote destination via rsudo fs delete for put).
- transfers remain streamed directly between source and final filesystem; no intermediate scp/sftp staging area is introduced.
- existing destinations are replaced through a sibling staging pathname in the same parent filesystem, with rollback if promotion fails.
- file, directory and symbolic-link transfer semantics are protected explicitly; tar is used without dereference options and source operands are passed without trailing slash.
- caller TAR_OPTIONS is unset for transfer producer/consumer execution so environment configuration cannot silently enable dereferencing.
- awk remains in the implementation where it improves robustness for parsing/comparing multi-terabyte filesystem-space values instead of relying on the minimum integer width of POSIX shell arithmetic.
- User correction: the earlier asymmetry was caused by get/put confusion in a prompt. get must use the same destination-space preflight policy as put.

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
- Post-executable focused validation ran on macOS/arm64 and Linux/aarch64 and failed functionally at the same assertion: `put succeeded despite forced promotion failure`.
- Inspection showed the failure-injection `mv` fixture only matched two-argument `mv source destination`, while the product invokes `mv -- source destination`; the fixture therefore never injected the promotion failure. Updated the fixture to recognize both argv forms while delegating the original argv unchanged. Auxiliary shell execution confirmed the corrected fixture returns the injected status for stage -> canonical promotion and does not inject failure for .orig -> canonical rollback. No product/runtime change was required for this defect.
- rumiai-os advanced concurrently from eaf015fe516713c73eccceb9339a5b624fe63c76 to e3abb0c38438d5c93459f29d088f59bacf652ad7. The intervening commits modify only rsudo-mod-db-pg.lib.sh; rsudo-mod-fs.lib.sh is unchanged.
- Focused formal validation of rsudo-fs passed on Darwin/arm64 (target macos-arm64) with validation 20260925T230402+0200-89087 and session 20260925T230404+0200-90877: aggregate status 0, fs.test PASS, audit CLEAN.
- The same focused validation passed on Linux/aarch64 (target linux-arm64) with validation 20260925T230437+0200-579965 and session 20260925T230438+0200-581684: aggregate status 0, fs.test PASS, audit CLEAN.
- Both successful validations exercised rumiai-tests 61c032c88b69a287c5517a8d034b593f24b2563b against rumiai-os e3abb0c38438d5c93459f29d088f59bacf652ad7.
- After those validations, the get/put space-policy asymmetry was corrected by explicit user instruction. RSUDO.md now requires get to estimate remote source size, local destination free space and reclaimable size of an existing local destination, with the same ok/delete/full policy as put.
- rumiai-os get now performs that preflight before creating destination directories or staging, logs insufficient-space / explicit-delete-required consistently, and never deletes the local destination implicitly.
- res/sys/manual/rsudo-mod-fs.lib.sh documents the get preflight and local explicit-delete behavior.
- fs.test now applies the df fixture to both local and remote preflight and covers get's explicit-delete-required case, preservation of the old local destination, successful retry after explicit local deletion, and insufficient-space failure when no old local destination exists.
- The fs.test executable bit remains 100755 after the test update.
- Final focused validation of the corrected get-space behavior passed on Darwin/arm64 with validation 20260925T235108+0200-94547 and session 20260925T235110+0200-96281: aggregate status 0, fs.test PASS, audit CLEAN.
- The same final focused validation passed on Linux/aarch64 with validation 20260925T235152+0200-587073 and session 20260925T235153+0200-588782: aggregate status 0, fs.test PASS, audit CLEAN.
- Both final validations exercised rumiai-tests e91b0413ce76b2ca2b288afdd8f6537afd56f183 against rumiai-os 4781025f6639454cdc16905a894aa366ec0ce630.
- The only rumiai-os change between the rsudo-fs implementation commit 948df6b668afee5b548de5ec39f571b435fc8cff and validated HEAD 4781025f6639454cdc16905a894aa366ec0ce630 modifies rsudo-mod-db-pg.lib.sh; rsudo-mod-fs.lib.sh and its manual are unchanged.
- Final consistency review found canonical RSUDO contract, runtime implementation, operational manual, validation scope and permanent fs.test coverage aligned. No current deferred-work item is required for this work unit.

## Current state

Implementation, canonical rsudo contract, operational library manual, focused validation scope and permanent test coverage are aligned for the symmetric get/put space policy. The final corrected revisions are formally VALIDATED on Darwin/arm64 and Linux/aarch64.

## Next action

Task complete. Remove this completed handoff from the current tree in a later forward commit; Git history retains this final snapshot.

## Blockers / open questions

- None.
