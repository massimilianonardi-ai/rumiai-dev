# RumiAI OS — Portable service lifecycle

Status: **Current / normative**  
Updated: 2026-09-17

This document defines the current portable local service lifecycle provided by `m`.

## Ownership

The public command is:

```text
srv
```

`srv` belongs to the technical `m` substrate.

A service is not a new state-owner class and does not create a second package model. The current state owner classes remain:

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

The service launch target convention is:

```text
<service>-start
```

The target is resolved/canonicalized before launch so the running instance is tied to the concrete command selected for that start operation.

If the target is a package-integrated command, the normal package launcher remains responsible for package HOME/environment/dependency preparation.

## Process model

The service target remains in foreground from its own perspective. The portable baseline does not require application self-daemonization, double-fork or an upstream PID-file contract.

`srv start` is responsible for the generic lifecycle mechanics around the long-running process, including current implementation responsibilities such as serialization of same-service lifecycle operations, stale-runtime cleanup, background launch/logging and publication of runtime metadata.

`srv stop` is idempotent when no active managed service remains. The normal stop path uses SIGTERM and a finite clean-termination wait. The portable baseline does not automatically escalate to SIGKILL.

The `-f` option is an explicit lifecycle override for the caller-ownership check; it is not authentication or a security boundary.

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

Application-specific readiness/health belongs to the service/application contract.

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
SRV-03  <service>-start is the launch-target convention
SRV-04  package launch semantics remain owned by the package launcher
SRV-05  local lifecycle uses state-path for run/log roots
SRV-06  user state is not POSIX user identity
SRV-07  caller ownership metadata is lifecycle state, not authentication
SRV-08  normal stop uses SIGTERM without automatic SIGKILL escalation
SRV-09  generic readiness is not application health
SRV-10  systemd/launchd integration is outside the portable baseline
SRV-11  no permanent internal supervisor daemon is introduced by this contract
```
