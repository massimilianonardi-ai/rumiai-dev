# vsed visual stream editor

Status: Complete
Updated: 2026-09-21

## Goal

Deliver a minimal terminal visual stream editor `vsed` for sensitive text with in-memory editing, stream mode, existing/new file mode, operational documentation and permanent multi-host validation.

## Current repository revisions

```text
rumiai-dev   af9bb977ff6abb14e6968d099fb0dc1ec14d8a64  (before final handoff snapshot)
rumiai-os    587ccc948c2f9d082c99038f53d61dd36bf3f9d9
rumiai-tests 7b997adbecbc63b6fad4ae0e1f09468b8f186aa7
```

Fresh remote HEAD retrieval remains mandatory before future work.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
TESTING.md
TEST-PATTERNS.md
specifications/README.md
specifications/rumiai-os/VSED.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
```

## Completed

- Promoted and implemented the `vsed` contract in `specifications/rumiai-os/VSED.md`, `bin/sys/vsed` and `res/sys/manual/vsed`.
- Stream mode preserves redirected stdin behavior; a zero-operand invocation whose stdin is a terminal starts from an empty document and saves to stdout.
- File mode edits an existing readable/writable regular file or starts empty for a non-existing pathname.
- Saving a new pathname creates it directly under `umask 077`; cancelling leaves the pathname absent; saving an untouched new file creates a zero-byte file.
- File saves remain direct/non-atomic and create no plaintext temporary/swap/backup/undo/journal file.
- Permanent tests cover contract, stream editing, terminal-stdin empty sessions, existing-file editing, new-file creation, empty new-file creation, cancellation, file mode permissions, TTY restoration and unsupported input.
- Darwin interactive coverage uses `expect`; Linux coverage uses a real PTY. Darwin PENDIN is normalized only as a kernel-managed transient state bit in the TTY restoration assertion.
- Dedicated `vsed` formal-validation workflow/scope is present in `rumiai-tests`.
- Final formal validation for `rumiai-os@587ccc948c2f9d082c99038f53d61dd36bf3f9d9` and `rumiai-tests@7b997adbecbc63b6fad4ae0e1f09468b8f186aa7`:
  - Linux/x86_64: 2 PASS, 0 FAIL/SKIP/ERROR, environment CLEAN, scope VALIDATED.
  - Darwin/arm64: 2 PASS, 0 FAIL/SKIP/ERROR, environment CLEAN, scope VALIDATED.
- For isolated auxiliary hosts without outbound Internet, current testing guidance is `TEST-PATTERNS.md` section “outbound-network bridge for an isolated auxiliary host”; `vsed` itself requires no external network data.

## Current state

The first-delivery `vsed` task is complete. Canonical specification, implementation, manual, permanent tests and revision-specific validation evidence are aligned.

## Next action

None for this completed task. Future `vsed` enhancements should start from the current canonical specification and current repository HEADs.

## Blockers / open questions

None.
