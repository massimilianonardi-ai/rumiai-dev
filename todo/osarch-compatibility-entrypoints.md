# osarch compatibility entrypoints

## Intent

Restore or explicitly realign the compatibility command surface for `osarch-update` and `osarch-set` so implementation and the current platform-selection contract agree.

## Why pending

The current specification still requires both compatibility commands, while the current product exposes only the consolidated `osarch` command. Permanent health validation therefore fails the compatibility-command check on both reference hosts.

## Scope

```text
rumiai-os
rumiai-tests/tests/rumiai-os/osarch/update.test
```

## Evidence

- `specifications/rumiai-os/CURRENT-MODEL.md`
- current `rumiai-os/bin/sys/osarch`
- permanent `osarch/update.test`
