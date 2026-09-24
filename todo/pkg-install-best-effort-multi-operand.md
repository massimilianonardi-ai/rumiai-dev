# pkg install best-effort multi-operand behavior

## Intent

Realign the public `pkg install <package>...` implementation with the current best-effort per-operand contract so that a failed operand does not prevent later independently installable operands from being attempted.

## Why pending

Full-product health validation on Ubuntu showed that `pkg install bad@@version jq` returned the expected overall failure status but did not leave the valid `jq` operand installed. The permanent test protects a current package-model contract and is not stale. Product correction is outside the active test-suite realignment work unit.

## Scope

```text
rumiai-os package install orchestration
rumiai-tests/tests/rumiai-os/pkg/install-live.test
```

## Evidence

- `specifications/rumiai-os/PACKAGE-MODEL.md`, Installation: multi-operand invocation is best-effort per operand and later independent operands must still be attempted.
- `rumiai-tests/tests/rumiai-os/pkg/install-live.test`.
- Hosted health run `35969903834`, Ubuntu, `rumiai-tests@280c0af57c84e95c91630983e2fc738354ce4a84` against `rumiai-os@50cb1a6734f74bc8faa5296189e60c0e9cdc8bc0`.
