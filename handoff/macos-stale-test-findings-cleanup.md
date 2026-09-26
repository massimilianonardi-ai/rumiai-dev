# macOS stale test findings cleanup

Status: Active
Updated: 2026-09-26

## Goal

Remove two stale macOS product-defect TODO classifications and realign the permanent tests with the current contracts and observed platform behavior.

## Current repository revisions

```text
rumiai-dev   9d35c916aeae27fe1e18e9c18e7c1a5abede8f02
rumiai-os    51d0cba5696a94caaf5ae39e2e476a31598a0ae1
rumiai-tests a91eed38a7cdfe3dac5012586f120680a21ea884
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `rumiai-os/res/sys/manual/http-fetch`

## Fixed task-local choices

- The current command-entrypoint contract does not require a readable but non-executable `#!/usr/bin/env m` pathname to be accepted as a command. The former permanent `explicit-source-readable.test` asserted a non-contractual property and has been removed rather than driving product behavior.
- The current `http-fetch` implementation and manual retain the stderr-TTY progress contract. The user confirms the real command works on macOS; the historical Darwin failure is classified as a PTY-test-driver defect, not a product defect.
- Darwin PTY coverage for `http-fetch` now uses the suite's established `expect` approach instead of the Python `pty.openpty()` path that produced the false product FAIL. Linux retains the existing Python PTY probe.

## Completed

- Fresh preflight and current source/test inspection completed.
- Historical health evidence identified: hosted macOS run `35969903834` on 2026-09-24 recorded FAIL for both `command/explicit-source-readable.test` and `http-fetch/progress.test`, while the surrounding command and http-fetch tests passed.
- Removed `todo/macos-readable-integrated-command.md`.
- Removed `todo/macos-http-fetch-progress.md`.
- Removed `tests/rumiai-os/command/explicit-source-readable.test`.
- Realigned `tests/rumiai-os/http-fetch/progress.test`: Linux keeps the Python PTY probe; Darwin uses `expect` with stderr attached to the spawned terminal and verifies curl/wget progress/suppression plus backend flags.
- Product code was not changed.
- Final diff review confirms the current command-entrypoint specification contains no readable/non-executable command requirement and the http-fetch product/manual contract is unchanged.
- The current TODO inventory no longer contains either stale macOS product defect.

## Current state

Repository cleanup is committed. Full health validations triggered by the permanent-test changes are still executing; no PASS is claimed from those runs yet.

## Next action

Inspect the current health result once available and, if the realigned test passes on Darwin and no task-local regression appears, complete this handoff.

## Blockers / open questions

- Runtime validation of the new Darwin test driver is pending in the currently executing health workflow.
