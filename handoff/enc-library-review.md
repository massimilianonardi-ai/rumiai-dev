# enc.lib.sh review

Status: Complete
Updated: 2026-09-25

## Goal

Review and realign `lib/sys/sh/enc.lib.sh` function by function, preserving the intended public behavior while correcting concrete portability/security defects, aligning operational documentation and permanent tests, and obtaining real GnuPG integration evidence.

## Current repository revisions

Final task-state checkpoint:

```text
rumiai-dev    da58ede73cb5264a7add861a11e68107f463eb45  (pre-final-snapshot HEAD)
rumiai-os     b66891732a99addbacba574aaf53779284319e16  (current HEAD)
rumiai-tests  318500723ee2674d951b9ab5a8df584adcd2db08
pkg-catalog   da9b8989088c8b3f2d8201ad09e5f7180f334a16
```

The final MacGPG/enc formal validation is revision-specific to `rumiai-os@baee6bf1b356d4855ab3eaf390ca8ee64f86508c`. The later product delta to `b668917...` changes only rsudo files and is not relabelled as validation evidence for the later revision.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
PHYSICAL-TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
```

## Fixed task-local choices

- The six public functions are `encode`, `decode`, `encoded_file_eval`, `encoded_file_edit`, `a2o` and `o2a`.
- Real GnuPG behavior is part of the integration evidence; boundary fixtures prove only the boundary properties they exercise.
- The current user instruction closes this review once the remaining MacGPG-backed integration verification succeeds. The older optional manual interactive Pinentry/vsed diagnostic is not a separate closure requirement and no physical-Mac PASS is claimed for a run that was not executed.

## Completed

- Corrected the octal helpers, GnuPG passphrase handling, OCB option selection, shell-function shadow resistance, macOS here-document portability and `o2a` POSIX-whitespace handling.
- Established and implemented `encoded_file_eval` authenticated evaluation semantics and the simplified `encoded_file_edit` pipefail/metadata/concurrency behavior.
- Added and aligned the mandatory `res/sys/manual/enc.lib.sh` operational manual with the complete public interface.
- Added proportional permanent coverage for all six public functions, including real-GnuPG OCB round trips and authenticated-source behavior.
- Earlier physical Ubuntu 26.04.1 ARM64 validation passed all five `rumiai-os/enc` tests at the exact recorded historical task revisions.
- Earlier physical macOS validation passed the non-GnuPG-dependent portions but correctly left two required real-GnuPG tests as SKIP because `gpg` was then unavailable. That evidence remains historical and is not relabelled.
- MacGPG is now implemented as a real `pkg` package for `macos-arm64`.
- Added `tests/external/macgpg/enc-live.test`, which installs MacGPG through the real public package path and verifies the public package-provided `gpg` with real `enc.lib.sh` `encode`, `decode`, `encoded_file_eval` and wrong-passphrase behavior.
- Formal MacGPG validation `20260925T153805+0000-1309` ran on hosted Darwin 26.6.2 / arm64 with target `macos-arm64`, `rumiai-tests@318500723ee2674d951b9ab5a8df584adcd2db08` and `rumiai-os@baee6bf1b356d4855ab3eaf390ca8ee64f86508c`. All five selected tests passed, including `external/macgpg/enc-live.test`; aggregate status was 0. The filesystem audit was `CHANGED`, which is observational evidence rather than an automatic failure under `TESTING.md`.

## Current state

The library implementation, public API classification, operational manual and permanent tests are aligned. The remaining MacGPG compatibility question has been exercised through the real package and real public GnuPG path and passed.

No known implementation, documentation or permanent-test defect remains in this review.

A fresh full physical-macOS `enc-library` run was not performed after MacGPG became available, so this closure does not claim such evidence.

## Next action

None.

## Blockers / open questions

None.
