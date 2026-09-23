# macOS http-fetch TTY progress

## Intent

Realign `http-fetch -o` progress behavior on macOS with the documented stderr-TTY contract while preserving the current backend abstraction.

## Why pending

The permanent PTY test passes on Linux but on macOS the current command does not expose the fake backend's native progress when stderr is attached to a terminal. The operational manual requires progress to remain visible in that case.

## Scope

```text
rumiai-os/bin/sys/http-fetch
rumiai-tests/tests/rumiai-os/http-fetch/progress.test
```

## Evidence

- `rumiai-os/res/sys/manual/http-fetch`
- current `rumiai-os/bin/sys/http-fetch`
- permanent `http-fetch/progress.test`
