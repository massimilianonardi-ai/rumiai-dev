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

For a provider-backed service, the selected provider realization maps service start to one ordinary package command. The concrete command belonging to the selected provider instance is resolved before launch, so provider selection and the process actually started cannot diverge. The normal package launcher remains responsible for package HOME, environment and dependency preparation.

The historical `<service>-start` name may remain a provider command naming convention during migration, but its presence is not the semantic test for service capability.

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

Future host-service integration is a separate, opt-in, host-specific capability and must preserve the portable lifecycle rather than replacing it.

System-wide installation/supervision requires an explicit administrative boundary and separate host validation.

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
systemd installation
launchd installation
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
```
