# macOS stale test findings cleanup

Status: Active
Updated: 2026-09-26

## Goal

Remove two stale macOS product-defect TODO classifications and realign the permanent tests with the current contracts and observed platform behavior.

## Current repository revisions

```text
rumiai-dev   ef4ad202e3c742593d6bf0075ccc1e813981a8b9
rumiai-os    51d0cba5696a94caaf5ae39e2e476a31598a0ae1
rumiai-tests 1341e7790bb0e33f70fab915322ee75020ec9ec3
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `rumiai-os/res/sys/manual/http-fetch`

## Fixed task-local choices

- The current command-entrypoint contract does not require a readable but non-executable `#!/usr/bin/env m` pathname to be accepted as a command. The permanent `explicit-source-readable.test` therefore asserts a non-contractual property and must be removed rather than driving product behavior.
- The current `http-fetch` implementation and manual retain the stderr-TTY progress contract. The user confirms the real command works on macOS; the historical Darwin failure is therefore treated as a PTY-test-driver defect, not a product defect.
- Darwin PTY coverage for `http-fetch` will use the suite's established `expect` approach rather than the Python `pty.openpty()` path that produced the false product FAIL. Linux may retain the existing Python PTY probe.

## Completed

- Fresh preflight and current source/test inspection completed.
- Historical health evidence identified: hosted macOS run 35969903834 on 2026-09-24 recorded FAIL for both `command/explicit-source-readable.test` and `http-fetch/progress.test`, while the surrounding command and http-fetch tests passed.

## Current state

No cleanup write has yet been applied.

## Next action

Remove the invalid readable-command test, realign the Darwin http-fetch progress driver, remove both stale product TODOs, then run the consistency gate.

## Blockers / open questions

None.
