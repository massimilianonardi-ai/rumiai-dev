# macOS readable integrated-command portability

## Intent

Make explicit readable/non-executable `#!/usr/bin/env m` command path handling conform consistently across the POSIX reference hosts.

## Why pending

The permanent command-entrypoint test passes on Linux but on macOS the current bootstrap falls through to direct execution and receives permission denied instead of loading the readable integrated command. This is a product portability issue, not a test-infrastructure failure.

## Scope

```text
rumiai-os/m
rumiai-tests/tests/rumiai-os/command/explicit-source-readable.test
```

## Evidence

- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- current `rumiai-os/m`
- permanent `command/explicit-source-readable.test`
