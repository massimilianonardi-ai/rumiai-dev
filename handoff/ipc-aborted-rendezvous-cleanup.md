# IPC aborted-rendezvous cleanup

Status: Complete
Updated: 2026-09-23

## Goal

Extend the current IPC lifecycle so an incomplete `ipc_open` rendezvous can be cancelled and safely cleaned up, while preserving the existing public API.

## Current repository revisions

```text
rumiai-dev   c54102488d78cb5c75f46758607302181cadb476
rumiai-os    4cf6fb85f234db8db23114351c9da1f437e9a344
rumiai-tests 78c4c770150ce6ef70677b8895c2ab0588395c0f
```

The IPC product revision validated by this task is:

```text
rumiai-os    e82f68ba7862e11d52c01aa2f421881f86c37dd4
```

The later `rumiai-os` advance to `4cf6fb85...` was reconciled and changes only current `rsudo` files; the IPC files from this task remain unchanged.

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

- Preserve the existing public IPC API; no separate abort primitive was added.
- `ipc_destroy` cleanup is permitted before rendezvous begins or after every process that may be executing `ipc_open` for the channel has terminated and been reaped.
- `ipc_destroy` remains forbidden while any process may still be executing `ipc_open` for the channel.
- The lifecycle is protected by a permanent regression that deterministically reaches a half-open rendezvous, terminates/reaps the opener, and then destroys the channel.

## Completed

- `ipc.lib.sh` lifecycle comment realigned without adding a new public function.
- `res/sys/manual/ipc.lib.sh` now documents cleanup after an interrupted rendezvous and the mandatory termination/reaping precondition.
- `tests/rumiai-os/ipc/contract.test` now exercises deterministic half-open cancellation followed by `ipc_destroy`.
- `validation/ipc.conf` binds task validation to `rumiai-os` revision `e82f68ba7862e11d52c01aa2f421881f86c37dd4`.
- Formal IPC validation passed on GitHub-hosted Ubuntu and macOS for `rumiai-tests` revision `78c4c770150ce6ef70677b8895c2ab0588395c0f`.
- Final consistency review confirmed the old “only before ipc_open” rule is absent from the current IPC product surface.
- Concurrent repository movement was reconciled forward and did not modify IPC files.

## Current state

The public API is unchanged. A caller may now start an asynchronous `ipc_open`, cancel/reap it if its peer never arrives, and then call `ipc_destroy` to clean the residual channel safely.

## Next action

None.

## Blockers / open questions

None.
