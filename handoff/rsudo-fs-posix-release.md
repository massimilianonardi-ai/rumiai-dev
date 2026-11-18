# m-rsudo v0.1.3 POSIX filesystem-transfer release and physical acceptance

Status: Active — release published; operator-host 22-case regression pending
Updated: 2026-11-18

## Goal

Repair the authentic `m-rsudo` filesystem module so `rsudo fs get/put` function on the operator's POSIX `/bin/sh` without `pipefail`. Publish a new immutable version, retain transfer failure detection, and accept the unmodified installed release only after real localhost SSH/sudo verification.

## Current repository revisions

- `m-rsudo/v0.1.3@f67d037fa5dc00b1e4e6748e5468da6ecaac98b8` (immutable release tag and source). Source module Git blob `41a8ff5f34a7707aefbc1d0e1e70a51b3952b4f5`.
- `m-rsudo/main@355294bc406a3392b029283972cd9fdd59e9a1a1` (follow-up hosted installed-package test workflow and README; does not alter release source).
- `pkg-catalog/main@eacaa2ac25f1b7a983269e1af2b96bf3c921b4cf` (adds `n0004=v0.1.3`, leaves earlier versions untouched).
- `m-os/master@3c0f5b8783fb8d319d5f4db23e902f77b7ddc924` (hosted installer test pin).
- `rumiai-dev/main@eb88f5534e64a7e3ca447bd7983e69df126edd90` before this checkpoint.

## Applicable canonical sources

`README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `specifications/rumiai-os/RSUDO.md`, `TESTING.md`, `PHYSICAL-TESTING.md`, `TEST-PATTERNS.md`, and the current package-source implementation/manual.

## Fixed task-local choices

- All operator-managed servers are expected to run a `sh` without `pipefail`. Do not change system shells or mutate the installed module during validation.
- A check may use a dedicated local fixture, but must execute the original installed `rsudo` and `rsudo fs` over real SSH/sudo, not an altered product.
- A producer failure must not be masked by a successful consumer. The v0.1.3 implementation uses portable local sidecar status files to check both tar endpoints and command-substitution status checks for `du`/`df` before `awk` parsing.
- Keep the immutable v0.1.2 release untouched. Do not claim its earlier 22/22 pass as authentic: that run secretly modified the installed module first, then restored it.
- No software release, source syntax check, package-install check or simulated test substitutes for the operator-host real SSH/sudo evidence.

## Acceptance scenarios

1. On operator Ubuntu x86_64, install actual `m-rsudo@v0.1.3` using `m pkg install` from the updated catalog; select `m-core@v0.1.1 m-term@v0.1.1 m-rsudo@v0.1.3` in `m shell`.
2. Check installed `rsudo-mod-fs.lib.sh` Git blob identity before and after the run; verify real `rsudo --connect user@localhost` root execution.
3. Run the unmodified original via 22 filesystem cases: single/empty/binary file, directories, all symlink kinds, replacements, metadata, failure preservation, rm/delete, status streams, Unicode/names, parents and tar option behavior.
4. Preserve complete PASS/FAIL and logs; do not infer 22/22 PASS from hosted syntax/package checks.

## Completed

- Operator evidence on *original* v0.1.2: `PASS=2 FAIL=20`, repeated `set: Illegal option -o pipefail`; original module hash `70f6e86a21fb352d9a0e2baa1e65d1b7739b0055` unchanged.
- `m-rsudo` PR #1 merged: removed all four `set -o pipefail` directives; preserved both pipeline endpoint statuses through sidecar files; separated `du`/`df` exit statuses; updated manual/build/release workflow.
- Hosted source/package CI on PR #1: Ubuntu 24.04 and macOS PASS (run 44309627448); neither ran real SSH/sudo.
- Published GitHub release `v0.1.3` with `m-rsudo-v0.1.3-all.tar.gz` asset, SHA256 `e5e0a8893e4905b89ec4044ce3b553612c090cfe3ebee33d1dd680d5ccdfbf60`, and SHA256SUMS.
- `pkg-catalog` PR #12 merged; immutable version registered under `v2/pkg/m-rsudo/all/n0004=v0.1.3`.
- Hosted nonprivileged installation check on released package, actual `m pkg install`: Ubuntu PASS (run 44310966778). macOS was queued at this checkpoint and must be rechecked, not assumed PASS.
- A revised 22-case original-package physical test driver is available in the conversation as `rsudo-localhost-fs-v0.1.3.sh`; shell syntax checked, not executed on operator host.

## Current state

Release and catalog publication complete. No operator-host v0.1.3 22-case SSH/sudo evidence. The module has a new protected-local-temp-dir requirement for `put` status recording, and interruption/cleanup, race and archive integrity risks remain and must not be mistaken for resolved merely by removing `pipefail`.

## Next action

Operator runs the 22-case suite on the unchanged installed v0.1.3 on Ubuntu x86_64 and provides the full output. Analyze any failures; record exact revision-linked evidence and make forward-only fixes without altering the tested release in place. Verify pending hosted macOS install run result when available.

## Blockers / open questions

- Physical localhost get/put/symlink/rollback acceptance of v0.1.3 is **unverified**.
- No deliberate injected-producer-failure, low-disk/quotas or interrupted transfer physical injection was performed. These resilience outcomes remain open.
