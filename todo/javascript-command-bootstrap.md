# JavaScript command entrypoints and m bootstrap

## Intent

Evaluate whether m-owned commands whose actual implementation is JavaScript (notably `jsc` and `mk`) can use direct JavaScript entrypoints while retaining the established m bootstrap environment, instead of mandatory thin POSIX-shell entrypoints. Determine whether a bootstrap/dispatch model change is genuinely necessary or whether an existing process-launch boundary suffices.

## Why pending

The current `#!/usr/bin/env m` dispatcher sources integrated POSIX shell commands and establishes `m_*`, `log`, `fatal` and `m_COMMAND_BIN`. A direct Node shebang launched without passing through m would not initialize that environment. After m runs, exported environment variables can be inherited by child Node processes, but shell functions and sourcing-specific identity cannot be assumed to carry over. This is an independent bootstrap/entrypoint architecture question, not a prerequisite for restoring legacy `jsc` semantics now.

## Scope

`rumiai-dev` command-entrypoint/bootstrap contracts and tests; `rumiai-os/m`, `bin/sys/jsc`, `bin/sys/mk` and their JavaScript engines. Compare direct interpreter shebangs, m-dispatched execution and existing shell wrappers against environment/identity propagation, POSIX portability, diagnostics, security and backward compatibility. Do not change the current bootstrap contract before validation and an explicit design decision.

## Evidence

- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`
- `specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md`
- `specifications/rumiai-os/MK.md`
- `specifications/rumiai-os/JSC.md`
- `rumiai-os/bin/sys/jsc`, `rumiai-os/bin/sys/mk`, `rumiai-os/m`
