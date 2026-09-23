# Branded entrypoint bootstrap realignment

## Intent

Realign `rumiai-os` / `rumiai-os-sh` with the current branded bootstrap contract so activation delegates through `m`, prepends the AI executable layers once and enters the selected shell without recursive environment growth.

## Why pending

Permanent cross-host health validation reaches the real branded entrypoints and they recurse until PATH/environment growth causes execution failure. This is a current product/specification mismatch and is outside the completed permanent-test realignment work unit.

## Scope

```text
rumiai-os
rumiai-tests/tests/rumiai-os/bootstrap/branded-path-prepend.test
```

## Evidence

- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`
- current `rumiai-os` root entrypoints
- permanent `bootstrap/branded-path-prepend.test`
