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

Starting a service requires a configured system facility default for that service/facility identity and a valid installed service realization for the selected concrete provider. Absence of a default, an unresolved provider or an invalid realization is a lifecycle failure. Command naming and PATH lookup do not define or discover service capability.

## Process model

The baseline facility service requires `process = foreground`; upstream processes must not self-daemonize or require their own PID-file contract. Portable `srv start` and `srv stop [-f]` use a **native, child-owning POSIX supervisor helper** for process ownership rather than signaling an arbitrary recorded PID. `srv` resolves a genuine installed facility-service provider through `pkg`; the supervisor creates and retains the direct child process while it runs, and stop requests arrive through an owner-only local control socket. Runtime PID metadata is inspection/recovery state, **never** permission to signal an unrelated PID.

The helper is scoped by the installation root and effective POSIX account. Only that account may access its private control socket; logical `m` user-state identity never grants access. Service launch receives the requesting process's bounded data-only environment, not a first-caller global environment or shell-evaluated text. The supervisor keeps a child unreaped through the `waitpid(WNOHANG)`/SIGTERM stop boundary so its PID cannot be reused for an unrelated process during a stop. Normal stop waits a bounded period, never silently escalates to SIGKILL, and remains idempotent if no service is managed. `-f` bypasses only ordinary caller-ownership metadata and does not authorize an unrelated process signal.

The helper exits after a bounded idle period with no children (currently one minute) and is **not a permanent system-wide daemon**. A crashed supervisor may leave orphaned processes; later operations must fail closed and require explicit operator inspection/cleanup, never reuse an unverified PID record. This baseline needs no systemd, launchd or `/proc`-specific process supervision API. Host-supervised services remain a separate opt-in path.

## Native supervisor distribution and build

The separately built C helper is `native/sys/srv-supervisor.c` and the supported build entrypoint is `./tools/build-srv-supervisor.sh`, producing `libexec/sys/srv-supervisor` for the current host. A checkout must build it before portable service lifecycle use; a distributed `m` installation includes the already compiled helper and does **not** require a compiler merely for bootstrap.

`./tools/package-m-distribution.sh` builds a relocatable host-specific archive under `dist/m-os-<osarch>.tar.gz` with a versioned `M-DISTRIBUTION` manifest recording its source commit and target. The native helper is included as an executable and tested after extract. The supported helper targets are Linux and macOS; the distribution contract may select the appropriate compiled artifact per architecture. A missing helper is a specific explicit `srv` error, not an invitation to fall back to unsafe PID killing. Ordinary C compilation during package **build** is a host-specific implementation capability behind the POSIX baseline, not a new universal runtime dependency.

## Provider and running-instance identity

Service identity remains facility identity, independently of package/provider selector. A start resolves the configured **system facility default** to one installed concrete with a valid foreground service realization; consumer bindings and mere command-name/PATH discovery do not replace it. Selection intent and running-instance ownership are distinct: changing a provider default does not retarget an already-running child.

For an existing portable service, the owning live supervisor and its direct-child relationship are the authority for inspection/stop. A recorded PID with no verifiable live ownership is not a managed service, regardless of `stop -f`. Old/dead metadata may be cleaned only when no unrelated live process can be signaled. A restart is a new provider selection after the prior instance is safely stopped. Generic start survival is not application-specific readiness or health.

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
a permanent system-wide m supervisor daemon
```

It **does** require the separately built, account-local native child-owning supervisor described above.

Host-service integration is a separate, opt-in, host-specific capability and preserves the portable service/facility model rather than replacing it.

The current **user host-supervision** surface is:

```text
srv host user install <service> [unit-name]
srv host user uninstall <service>
srv host user start <service>
srv host user stop <service>
srv host user restart <service>
```

Here `user` means the host supervisor associated with the calling POSIX account/login context. It is **not** the `state/user` scope from `STATE-MODEL.md`, is not an `m` user-scope identity and does not redefine that state model.

Host-user adapter discovery and persistent registration therefore follow the actual calling host account/supervisor context rather than caller-overridable process environment variables such as `HOME`, `XDG_CONFIG_HOME` or `XDG_RUNTIME_DIR`. Those variables may be redirected by an enclosing process without changing which POSIX account's supervisor `srv host user` addresses. Host-specific account/runtime discovery remains inside the systemd/launchd adapter boundary.

The normalized actions have host-neutral semantics:

- `install` persistently registers the service with the calling account's host supervisor but does not itself start the service in the current session;
- `start` starts an installed host integration;
- `stop` stops the current hosted process while leaving the integration installed;
- `restart` replaces/restarts the current hosted process through the host supervisor;
- `uninstall` stops/unloads the integration when necessary and removes its persistent host registration.

Native manager verbs and file formats are adapter details. Linux/systemd and macOS/launchd are not required to expose textually identical operations.

The host manager supervises the provider's foreground process directly. It must not invoke portable `srv start`, because that command owns its own background/PID lifecycle. Each host-managed launch enters an internal foreground execution path in `srv`, resolves the current system facility default and exact provider service realization at launch time, then replaces itself with the normal package-launch path. The persistent host definition therefore does not freeze a concrete provider. A provider-default change affects a later host start/restart, not an already-running host process.

Persistent host definitions must encode the exact `m` bootstrap invocation as argv/data rather than generated shell source.

For the current Linux/systemd user adapter:

- the unit `ExecStart` executable is the already-contracted `/bin/sh`, because systemd rejects arbitrary special-character executable pathnames even when unit escaping reconstructs them correctly;
- the exact `m` bootstrap, `srv` command, internal foreground-run operand and service identity are passed as separately serialized arguments;
- the serializer must preserve relocatable paths containing spaces and shell/systemd metacharacters without shell evaluation.

For the current macOS/launchd user adapter:

- the plist `ProgramArguments` array carries the exact `m` bootstrap, `srv` command, internal foreground-run operand and service identity as distinct argv elements;
- the plist is constructed through the host property-list utility rather than by interpolating arbitrary paths into XML source.

User host integration does not silently enable a host policy that extends account lifetime beyond the host's normal user-manager/session rules, and it does not invent an automatic restart policy. Such policies require separate explicit contracts.

The current **system host-supervision** surface is:

```text
srv host system install <service> <account> [unit-name]
srv host system uninstall <service>
srv host system start <service>
srv host system stop <service>
srv host system restart <service>
```

Host registrations use the unprefixed service identity by default: on systemd, `<service>.service`; on launchd, `<service>` as the label. Both user-host and system-host install accept an optional host registration name (`unit-name`) without the systemd `.service` suffix. The selected name is stored with the corresponding service registration, and subsequent host lifecycle actions resolve it from that registration using only the logical service identity. The name must be a valid single host-service identity and must not contain path separators. The optional name does not change the package facility identity.

System-host operations are administrative. The baseline requires the caller to
already execute with effective UID 0; `srv` does not invoke `sudo`, `doas` or
another privilege-escalation mechanism.

`install` requires one explicit pre-existing POSIX account. The account must
resolve through host account data, must not be UID 0/root, and is never created,
modified or removed by `srv`. A dedicated non-login service account is the
recommended deployment shape but is not an `m`-managed identity. Host primary and
supplementary group policy remains administrator-owned.

A system host registration resolves the current system facility default to one exact
installed concrete provider and reconciles that deployment administratively. The
registration records that concrete provider as the prepared deployment identity; it
does not create another provider selector. At each hosted launch the internal runner
re-resolves the current system facility default and requires it to equal the concrete
recorded by the registration. A provider-default change does not mutate a running
process, but a later system start/restart fails as stale registration until the
administrator reruns:

```text
srv host system install <service> <account>
```

System `install` is idempotent reconciliation. It prepares the service-specific
package HOME required by the selected provider, assigns only that mutable HOME to the
execution account, and atomically refreshes native registration without starting or
retargeting an already-running service. `uninstall` removes native registration;
it does not delete the POSIX account or authoritative package/service state.

System-hosted package launch reuses the normal package launcher under a dedicated
system-service state context. For provider package `<package>` and service
`<service>`, package HOME/configuration resolve through the existing package State
Instance mechanism:

```text
state-path system pkg <package> home <service>
state-path system pkg <package> conf <service>
```

The service account must not gain ownership or write access to executable `m`/package
roots merely because host registration required administrative
privilege. Package-declared static `var/` routing remains governed by the existing
system-state package contract. Provider-specific mutable-path behavior inside an
upstream installation is a separate package concern and is not inferred or rewritten
by the generic host-service lifecycle.

For the Linux/systemd system adapter:

- registration is a system unit under the host systemd system-manager boundary;
- `User=<account>` expresses the selected non-root execution account;
- the provider is supervised as `Type=simple`;
- the exact `m` bootstrap, `srv` internal system-run operand, service identity
  and reconciled concrete provider are serialized as argv/data;
- install enables persistent boot intent without starting the service in the current
  session.

For the macOS/launchd system adapter:

- registration is a LaunchDaemon under the host system domain;
- `UserName=<account>` expresses the selected non-root execution account;
- `ProgramArguments` carries the exact `m`/`srv` argv and reconciled concrete
  provider as data;
- install establishes persistent boot intent without starting the service in the
  current session.

Neither system adapter introduces automatic account creation, automatic restart
policy or dynamic/recycled service identities. Linux `DynamicUser=` is not the
portable `m` baseline.

## Generalized-context host-service profile binding

A host-supervised service is a separately trusted consumer: its **system profile is bound at authorized registration**, never inherited from an unrelated interactive shell. Registration and later launches validate the selected profile against the installation inventory. Changing a caller's context or account defaults does not retarget an existing registration or running provider.

User-host registration records the calling real POSIX account and validated selected system profile. Within that registered profile, each later start/restart resolves its current system facility-default intent; it does **not** freeze a provider concrete. System-host registration instead requires pre-existing effective UID 0, a specified pre-existing non-root execution account and a reconciled exact provider concrete. Later start/restart verifies that the registered profile's current facility default still resolves to that concrete and otherwise fails closed pending authorized reinstallation/reconciliation.

Ordinary context operands and inherited envelope fields are **never host-admin authority**. No service account is created/modified by `srv`; host managers remain independently authorized. Multiple simultaneous host registrations for one service/facility require a separate, explicit qualified-identity contract and are not invented by unqualified `srv` names. Privileged positive host-system tests remain deliberately deferred to `todo/m-os-operator-privileged-validation.md`.

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
automatic service-account creation/removal
dynamic/recycled service-account allocation
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
SRV-11  portable srv uses an account-local native child-owning helper that exits when idle, not a permanent global daemon
SRV-12  baseline provider-backed service identity equals facility identity and no second service/provider registry exists
SRV-13  baseline service contract requires package-command start, foreground process behavior and generic SIGTERM stop
SRV-14  provider-backed start is tied to the exact selected provider concrete and uses its ordinary package command
SRV-15  changing provider selection does not retarget an already-running service instance
SRV-16  stop uses verified supervisor direct-child ownership; runtime PID metadata never authorizes signaling
SRV-17  endpoint, readiness and health are outside the baseline service typed part
SRV-18  global provider-backed start uses the system facility default and never consumer package bindings
SRV-19  srv start requires a configured system facility default and valid provider service realization; command naming/PATH lookup never substitutes for provider-backed service discovery
SRV-20  user host supervision exposes normalized install, uninstall, start, stop and restart actions
SRV-21  host user scope denotes the calling POSIX account/login supervisor context and is distinct from m state/user
SRV-22  user host install persists supervisor registration without starting the current hosted process
SRV-23  user host stop leaves persistent host integration installed and uninstall removes it
SRV-24  host managers supervise the provider foreground process directly rather than portable srv start
SRV-25  each host-managed launch resolves facility-default intent within its registered system profile; other shell contexts do not retarget it
SRV-26  user host integration does not automatically enable linger or an automatic restart policy
SRV-27  system host supervision exposes normalized install, uninstall, start, stop and restart actions behind an explicit administrative boundary
SRV-28  host user definitions preserve exact relocatable m/srv argv as data and do not reinterpret `m` pathnames as generated shell source
SRV-29  the systemd user adapter enters m through /bin/sh and serialized argv so arbitrary special-character m paths are not used as the systemd executable pathname
SRV-30  the launchd user adapter uses a ProgramArguments argv array built through the host plist utility rather than manual XML interpolation
SRV-31  user-host definitions pin a profile but not a concrete; system-host registration pins profile, account and reconciled concrete
SRV-32  host-user registration and supervisor discovery follow the actual calling POSIX account context rather than caller-overridden HOME/XDG roots
SRV-33  system host mutations require pre-existing effective UID 0 authority and never invoke an internal privilege-escalation mechanism
SRV-34  system host install requires one explicit pre-existing non-root POSIX execution account and never creates, modifies or removes that account
SRV-35  system host registration records the exact concrete provider prepared at reconciliation time while the system facility default remains the provider-selection authority
SRV-36  a later system start/restart requires current facility-default resolution to equal the reconciled concrete provider and otherwise fails until install reconciliation is repeated
SRV-37  system-hosted package launch uses system package State Instance equal to service identity and never reinterprets state/user as POSIX account state
SRV-38  system host reconciliation grants the execution account write ownership only over required mutable service state, never over executable product/package roots
SRV-39  system host uninstall removes native registration without deleting the POSIX account or authoritative package/service state
SRV-40  Linux system supervision uses a systemd system unit with an explicit non-root User and direct foreground-provider supervision
SRV-41  macOS system supervision uses a LaunchDaemon with an explicit non-root UserName and direct foreground-provider supervision
SRV-42  only a live supervisor-owned direct child may be signaled; unverifiable or orphaned PID records never authorize signaling even with stop -f
```
