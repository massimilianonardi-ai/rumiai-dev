# Facility default global projection

Status: Active
Updated: 2026-09-19

## Goal

Define and implement the global command/environment projection owned by a facility default, while preserving the existing package-default publication model, consumer-specific provider overrides and the technical m bootstrap boundary.

## Current repository revisions

```text
rumiai-dev       d034dcfca095a839200ce181908cf88381e3160e
rumiai-os        a1644b2238f17633d19cdf2e963c7cc8f09dfa6a
rumiai-tests     322cee67192e38c828145325131c9fe6d0574c40
pkg-catalog      bd06488d3c67160e820c04d13067f852c8861c32
rumiai-dev-PoCs  af61caccde43151ef83a96b8988536f9aa997a0b
```

## Applicable canonical sources

- `RULES.md`
- `CONSISTENCY-GATE.md`
- `TESTING.md`
- `TEST-PATTERNS.md`
- `specifications/rumiai-os/CURRENT-MODEL.md`
- `specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md`
- `specifications/rumiai-os/STATE-MODEL.md`
- `specifications/rumiai-os/PACKAGE-MODEL.md`
- `specifications/rumiai-os/COMMAND-ENTRYPOINTS.md`
- `specifications/rumiai-os/FILESYSTEM-NAMING.md`
- `specifications/rumiai-os/LIBRARY-INTERFACES.md`
- `specifications/rumiai-os/DOCUMENTATION-MODEL.md`

## Fixed task-local choices

None yet. The current package contract requires facility-default ownership of a future global projection but deliberately leaves its concrete publication mechanism undefined.

## Working design

Current evidence separates two responsibilities that must not be conflated:

- global facility commands can potentially use the existing m-owned external command roots `bin/ext/` and `bin/ext-<osarch>/`, which are already on the technical bootstrap PATH;
- global facility environment values such as `JAVA_HOME` have no equivalent generic application point today. The bootstrap sources only the core library, and shell extension hooks are shell-startup-specific rather than a general m-command environment contract.

The design must therefore establish global command collision/ownership semantics and decide where facility environment projection is applied without making the bootstrap depend accidentally on package implementation details or reducing global semantics to interactive shell startup.

## Completed

- Previous provider/facility realignment is complete and validated.
- Current provider metadata already materializes generic `facility-cmd` and `facility-env` data.
- Current consumer launch re-resolves provider selection and applies those projections generically.
- Current package defaults publish package-owned commands into `bin/ext[-osarch]`.
- Current bootstrap/PATH, osarch selection and shell startup behavior were inspected for reuse boundaries.

## Current state

No global facility projection is implemented. Facility defaults currently store selector intent only. The exact global publication/application mechanism remains an open design question and has not been promoted to `PACKAGE-MODEL.md`.

## Next action

Evaluate the smallest coherent global projection model against existing command publication, bootstrap and shell semantics. Use a focused PoC if needed before promoting a contract.

## Blockers / open questions

- command collision and ownership between package-default commands and facility-default commands;
- whether global facility environment belongs to every m invocation, only managed shells, or another existing generic environment surface;
- atomicity/rollback when a facility default changes and its global projection changes with it.
