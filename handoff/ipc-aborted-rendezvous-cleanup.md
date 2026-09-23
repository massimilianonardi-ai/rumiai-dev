# IPC aborted-rendezvous cleanup

Status: Active
Updated: 2026-09-23

## Goal

Extend the current IPC lifecycle so an incomplete `ipc_open` rendezvous can be cancelled and safely cleaned up, while preserving the existing public API.

## Current repository revisions

```text
rumiai-dev   00029f1c6e88bd0bb61d787e865132c72ec67ca2
rumiai-os    ec670644237079b6e809aa2efe95cba5ed853b92
rumiai-tests 11449dde82c20559ead0ee23760a087c5abc9ed3
```

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

- Preserve the existing public IPC API; do not add a separate abort primitive.
- Extend `ipc_destroy` so cleanup is permitted before rendezvous begins or after every process that may be executing `ipc_open` for that channel has terminated and been reaped.
- `ipc_destroy` remains forbidden while any process may still be executing `ipc_open` for the channel.
- Protect the new lifecycle with a permanent regression case that reaches a deterministic half-open rendezvous, terminates the opener, and then destroys the channel.

## Completed

- Fresh preflight completed.
- Current implementation, manual and permanent IPC test inspected.
- Confirmed the implementation already has the filesystem mechanics required for post-cancellation cleanup; the current public contract incorrectly forbids that lifecycle.

## Current state

No product or permanent-test modification has been made yet.

## Next action

Realign `ipc.lib.sh`, its operational manual and the IPC permanent test, then run proportional validation.

## Blockers / open questions

None.
