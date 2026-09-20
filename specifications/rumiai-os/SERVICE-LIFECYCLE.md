# RumiAI OS — Portable service lifecycle

Status: **Current / normative**  
Updated: 2026-09-19

This document defines the current portable local service lifecycle provided by `m`.

## Ownership

The public command is:

```text
srv
```

`srv` belongs to the technical `m` substrate.

A service is not a new state-owner class and does not create a second package model. Provider-backed service identity is the corresponding facility identity; `srv` does not own a parallel service registry or provider resolver. The current state owner classes remain:

```text
sys
ai
pkg
```

## Baseline public surface

The current portable lifecycle baseline includes:

```text
srv start <service>
srv stop [-f] <service>
```

Service-operability for package providers is declared by the facility `service` typed part defined in `PACKAGE-MODEL.md`; command-name convention alone does not define a service.

For a provider-backed service, `srv start <service>` reads the system facility default for that same facility identity. Consumer package bindings are not consulted. The selected provider realization maps service start to one ordinary package command. The concrete command belonging to the selected provider instance is resolved before launch, so provider selection and the process actually started cannot diverge. The normal package launcher remains responsible for package HOME, environment and dependency preparation.

During the current migration, the historical PATH-resolved `<service>-start` mechanism remains a compatibility path only when no system facility default exists for the requested service identity (or the requested legacy service name is outside facility-name grammar). Once a facility default is configured, failure to resolve that provider or its service realization is a lifecycle failure and must not silently fall back to PATH. The legacy command name is therefore not the semantic test for provider-backed service capability.

## Process model

The baseline service facility contract requires `process = foreground`. The service target remains in foreground from its own perspective and must not self-daemonize in a way that causes `srv` to lose ownership of the managed process. The portable baseline does not require double-fork or an upstream PID-file contract.

`srv start` is responsible for the generic lifecycle mechanics around the long-running process, including current implementation responsibilities such as serialization of same-service lifecycle operations, stale-runtime cleanup, background launch/logging and publication of runtime metadata.

`srv stop` is idempotent when no active managed service remains. The normal stop path uses SIGTERM and a finite clean-termination wait. The portable baseline does not automatically escalate to SIGKILL.

The `-f` option is an explicit lifecycle override for the caller-ownership check; it is not authentication or a security boundary.

## Provider and running-instance identity

A provider-backed service start selects one concrete provider through the package facility/provider model. Selection configuration and running-instance identity are distinct: once started, runtime state belongs to the concrete process/provider instance, not to the mutable selector that happened to choose it.

Runtime metadata for a provider-backed service must therefore preserve enough concrete identity to keep later stop/inspection tied to the already-running instance. Changing a facility default after start does not retarget that process. A later new start or restart may resolve current provider selection again.

`srv stop <service>` operates on recorded runtime state and must not resolve another provider merely to stop an already-running instance.

## State

`srv` resolves its state roots through `state-path` rather than reconstructing the physical state tree.

The local user-scoped lifecycle uses semantic roots equivalent to:

```text
state-path user sys srv run
state-path user sys srv log
```

Runtime metadata layout beneath those roots is private to `srv` unless separately specified.

The `user` scope follows `STATE-MODEL.md`: it is an `m` namespace and not the POSIX principal identity.

## Readiness

The generic lifecycle may determine that a process survived initial launch; it does not infer arbitrary application readiness or health.

Application-specific readiness/health is not part of the baseline service typed part. If provider-independent readiness, health or endpoint semantics are later required, they need their own explicit contract rather than being inferred from process survival.

## Host supervision boundary

The portable baseline does **not** depend on:

```text
systemd
launchd
/proc-specific supervision APIs
an internal permanent m supervisor daemon
```

Host-service integration is a separate, opt-in, host-specific capability and preserves the portable service/facility model rather than replacing it.

The current **user host-supervision** surface is:

```text
srv host user install <service>
srv host user uninstall <service>
srv host user start <service>
srv host user stop <service>
srv host user restart <service>
```

Here `user` means the host supervisor associated with the calling POSIX account/login context. It is **not** the `state/user` scope from `STATE-MODEL.md`, is not an RumiAI user identity and does not redefine that state model.

The normalized actions have host-neutral semantics:

- `install` persistently registers the service with the calling account's host supervisor but does not itself start the service in the current session;
- `start` starts an installed host integration;
- `stop` stops the current hosted process while leaving the integration installed;
- `restart` replaces/restarts the current hosted process through the host supervisor;
- `uninstall` stops/unloads the integration when necessary and removes its persistent host registration.

Native manager verbs and file formats are adapter details. Linux/systemd and macOS/launchd are not required to expose textually identical operations.

The host manager supervises the provider's foreground process directly. It must not invoke portable `srv start`, because that command owns its own background/PID lifecycle. Each host-managed launch resolves the current system facility default and then the exact provider service realization before entering the package launcher. A provider-default change therefore affects a later host start/restart, not an already-running host process.

User host integration does not silently enable a host policy that extends account lifetime beyond the host's normal user-manager/session rules, and it does not invent an automatic restart policy. Such policies require separate explicit contracts.

System-wide installation/supervision remains outside this user baseline. It requires an explicit administrative boundary, account/environment semantics and separate host validation before `srv host system ...` can be implemented.

## Deferred unless separately specified

The current portable baseline does not establish generic contracts for:

```text
automatic restart policy
socket activation
timer jobs
service dependency graphs
multi-instance service orchestration
generic health protocols
automatic SIGKILL escalation
automatic systemd user lingering
automatic systemd/launchd restart policy
system-wide systemd installation
system-wide launchd installation
```

## Invariants

```text
SRV-01  srv belongs to m
SRV-02  baseline public operations are start and stop
SRV-03  provider-backed service capability is declared by a facility service typed part; command naming alone does not define a service
SRV-04  package launch semantics remain owned by the package launcher
SRV-05  local lifecycle uses state-path for run/log roots
SRV-06  user state is not POSIX user identity
SRV-07  caller ownership metadata is lifecycle state, not authentication
SRV-08  normal stop uses SIGTERM without automatic SIGKILL escalation
SRV-09  generic readiness is not application health
SRV-10  systemd/launchd integration is outside the portable baseline
SRV-11  no permanent internal supervisor daemon is introduced by this contract
SRV-12  baseline provider-backed service identity equals facility identity and no second service/provider registry exists
SRV-13  baseline service contract requires package-command start, foreground process behavior and generic SIGTERM stop
SRV-14  provider-backed start is tied to the exact selected provider concrete and uses its ordinary package command
SRV-15  changing provider selection does not retarget an already-running service instance
SRV-16  stop uses recorded runtime instance state rather than resolving a new provider
SRV-17  endpoint, readiness and health are outside the baseline service typed part
SRV-18  global provider-backed start uses the system facility default and never consumer package bindings
SRV-19  during migration, legacy PATH <service>-start fallback is allowed only when no provider-backed facility default applies; a configured-but-invalid provider path must fail rather than fall back
SRV-20  user host supervision exposes normalized install, uninstall, start, stop and restart actions
SRV-21  host user scope denotes the calling POSIX account/login supervisor context and is distinct from m state/user
SRV-22  user host install persists supervisor registration without starting the current hosted process
SRV-23  user host stop leaves persistent host integration installed and uninstall removes it
SRV-24  host managers supervise the provider foreground process directly rather than portable srv start
SRV-25  each host-managed launch resolves current system facility-default intent; later selector changes do not mutate an already-running host process
SRV-26  user host integration does not automatically enable linger or an automatic restart policy
SRV-27  system-wide host supervision remains behind a separate administrative/account/environment contract
```
