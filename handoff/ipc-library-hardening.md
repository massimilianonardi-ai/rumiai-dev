# IPC library hardening

Status: Complete
Updated: 2026-09-23

## Goal

Correct the current `m` IPC shell library defects, realign its operational manual, and add permanent regression coverage for the corrected public behavior.

## Current repository revisions

```text
rumiai-dev   cc65e2a219ab5feefb03911ac8caf40720de9b11  (pre-final-snapshot HEAD)
rumiai-os    6a9e2da2c3a91ab1ac29b64c8268dc92030b5599
rumiai-tests a8befac73543de44f6c451569189ab1a8cc2aa3c
```

Fresh remote HEAD retrieval remains mandatory before any later work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/FILESYSTEM-NAMING.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
```

## Fixed task-local choices

- The public IPC interface is `ipc_create`, `ipc_open`, `ipc_write`, `ipc_read`, `ipc_close`, `ipc_sync`, `ipc_cancel` and `ipc_destroy`; underscore-prefixed helpers are internal.
- The existing newline-delimited record model is preserved and `ipc_write` rejects embedded newlines.
- Asynchronous operation PIDs must be canonical positive decimal values before `wait` or `kill`; `ipc_cancel` additionally requires the caller to pass only a child PID captured from `$!`.
- Channel operands are restricted to the generated absolute identity shape before channel filesystem operations.
- Channel/FIFO symlinks are rejected where applicable.
- `ipc_destroy` is only valid before either endpoint begins `ipc_open` and rejects arbitrary, empty, symlinked or non-directory channel-like targets.
- `res/sys/manual/ipc.lib.sh` is the operational manual for the library.

## Completed

- Activated and removed the deferred `todo/review-ipc-lib.md` item.
- Hardened `lib/sys/sh/ipc.lib.sh` while preserving POSIX-sh library identity and the duplex FIFO rendezvous model.
- Added `res/sys/manual/ipc.lib.sh` with the complete eight-function public API and no internal helper exposure.
- Added `tests/rumiai-os/ipc/contract.test` plus dedicated `validation/ipc.conf` and cross-host GitHub Actions orchestration.
- Final structural consistency check confirmed:
  - library mode `100644`, no shebang;
  - permanent test mode `100755`;
  - all eight public functions documented;
  - no `_ipc_*` helper documented as callable API;
  - no stale `randh` or `. enc.lib.sh` mechanism remains.
- Formal task validation for `rumiai-os@6a9e2da2c3a91ab1ac29b64c8268dc92030b5599` with `rumiai-tests@a8befac73543de44f6c451569189ab1a8cc2aa3c` passed:
  - Linux x86_64 / Ubuntu 24.04.5: `rumiai-os/ipc/contract.test` PASS, aggregate status 0, filesystem audit CLEAN; validation record `validation/20260923T124105+0000-2352`;
  - Darwin arm64 / macOS 26.6.2: `rumiai-os/ipc/contract.test` PASS, aggregate status 0, filesystem audit CLEAN; validation record `validation/20260923T124112+0000-3611`.
- No physical/stable-reference-host validation is claimed; the exact committed revisions were validated on GitHub-hosted Linux and Darwin runners.

## Current state

The IPC library, its operational manual and its dedicated permanent regression/validation surface are aligned at the revisions above. The broader deferred library-visibility audit remains only for libraries that are still unclassified; `ipc.lib.sh` is no longer part of that pending scope.

## Next action

None.

## Blockers / open questions

None.
