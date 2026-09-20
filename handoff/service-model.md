# Service model

Status: Active
Updated: 2026-09-20

## Goal

Complete the service model that connects portable `srv` lifecycle, package-provided facilities and later explicit host-supervision integration without introducing a duplicate service registry, provider graph or dependency graph.

The portable/provider-backed bridge is implemented and formally validated. The active task now begins only where real-provider policy and host-supervision design remain.

## Current repository revisions

Checkpoint used for this synchronization:

```text
rumiai-dev      73d62079a053712f0f4a7f63ddeca6595542397e  pre-sync HEAD
rumiai-os       3a5691f46a2538dad00657d47334d1d1eb0329f0
rumiai-tests    e31641259396b6ce503df1283fed4a5b186e5596
pkg-catalog     12ea704ee4e25e62ab3ed0125133660b4e0c42cb
```

The exact service-bridge product revision exercised by the current formal validation is:

```text
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
```

Current `rumiai-os@3a5691...` is a descendant of that revision; intervening changes are outside the service/package-provider subsystem.

Fresh remote HEAD retrieval remains mandatory on resume.

## Applicable canonical sources

Use the mandatory project read order. The direct service contract is owned by:

```text
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

Add the host/platform/state/security specifications when host-supervision work becomes active.

## Fixed task-local choices

Durable service semantics are canonical in the specifications; this handoff records only current task state.

- Portable lifecycle remains:
  ```text
  srv start <service>
  srv stop [-f] <service>
  ```
- Provider-backed service identity is the facility identity. No second service inventory/provider registry exists.
- Portable service capability is declared through the trusted facility `service` part.
- Baseline service contract remains:
  ```text
  start   package-command
  process foreground
  stop    sigterm
  ```
- `pkg` owns facility identity, provider conformance and selection; `srv` owns process lifecycle.
- Global provider-backed `srv start <facility>` uses only the system facility default. Consumer bindings do not participate.
- A running provider-backed instance persists its selected concrete provider. Later default changes do not retarget it; stop does not re-resolve provider selection.
- A configured-but-invalid provider path fails. It must not silently fall back to PATH.
- The historical PATH `<service>-start` mechanism remains a temporary compatibility path only when no provider-backed default applies.
- Endpoint, readiness and application health remain outside the baseline service part.
- User host integration is now canonically normalized as:
  ```text
  srv host user install <service>
  srv host user uninstall <service>
  srv host user start <service>
  srv host user stop <service>
  srv host user restart <service>
  ```
- Host `user` is the calling POSIX account/login supervisor context and is distinct from RumiAI `state/user`.
- Host managers supervise the foreground provider directly; they do not invoke portable `srv start`.
- Each host-managed launch resolves current system facility-default intent; selector changes affect a later launch/restart, not the running instance.
- User integration does not enable systemd linger or an automatic restart policy.
- `srv host system ...` remains a design boundary only; system-wide account/environment/privilege semantics are not yet fixed.
- System-wide host integration remains an explicit administrative boundary; a service account must not gain ownership/write access over executable product roots merely because it runs a service.

## Implemented portable/provider-backed bridge

Current product behavior includes:

- trusted `service` facility-contract/provider validation;
- same-snapshot provider conformance during normal `pkg install` before package-store mutation;
- materialization of validated `facility-service/<facility>/start`;
- public system-facility-default resolution through the package provider model;
- exact installed-provider service-start command resolution;
- provider-backed `srv` launch through the exact active `m` bootstrap, preserving package-launch HOME/environment/dependency behavior on Linux and macOS;
- runtime persistence of selected concrete provider identity;
- SIGTERM stop through recorded running-instance state;
- no provider re-resolution during stop;
- no fallback from configured-but-invalid provider state to the legacy PATH path.

The macOS bootstrap fix is part of this bridge: directly executing a `#!/usr/bin/env m` package command under host `nohup` could lose discovery of `m`; provider-backed launch therefore enters through `$m_BOOTSTRAP_BIN` with the exact package command as the command operand.

Permanent service coverage exercises the real `srv` entrypoint and the real package integration/provider machinery. The current service provider used by that regression test is synthetic package input to `pkg_integrate`; no real `pkg-catalog` package has yet been promoted as a service provider.

## Formal validation evidence

All evidence is revision-specific.

### Baseline provider/facility/service formal validation

GitHub Actions run:

```text
35495425634
```

Exact revisions:

```text
rumiai-tests@aa7ff12a0ecb63ef2b83f26576df19eff424da27
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
```

Formal `package-provider-facility` task scope:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

All required provider/facility/integration/launcher/service selections passed with no required SKIP. `rumiai-validate` published the individual sessions and aggregate validation records.

### Expanded Java-consumer formal validation

GitHub Actions run:

```text
35495727155
```

Exact revisions:

```text
rumiai-tests@f4b46a079d81cc15bdc0eb9fa215ba1c1f652444
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
```

The same formal task scope, now including live Temurin/NetBeans/Keycloak/Maven consumers, again finished:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

The `rumiai-os/srv` selection passed on both hosts.

These GitHub-hosted validations are formal RumiAI validation evidence, but they are not physical validation of the stable reference hosts.

## Current state

The generic portable/provider-backed service bridge is no longer a blocker.

No current `pkg-catalog` package declares the `service` facility part. The next portable-service step therefore requires a real package whose normal RumiAI package command can expose a deterministic no-argument foreground start operation satisfying the canonical `foreground` + SIGTERM contract.

Keycloak is a plausible current catalog candidate, but the existing package command maps directly to upstream `kc.sh`; selecting a production-vs-development start mode and any required production configuration is a real provider-policy choice, not generic service plumbing. Do not encode `start-dev`, `start` arguments or networking/TLS policy merely to obtain a demonstration.

The temporary legacy PATH path remains because there is not yet a real catalog provider/migration criterion.

User host-supervision semantics are now promoted, but product adapters are not yet implemented. System scope remains unresolved.

## Remaining active work

### 1. First real service provider

Choose a current package whose actual launch semantics meet the service contract, define its provider-independent service facility contract/realization, and exercise:

```text
pkg install
→ explicit facility default
→ srv start
→ running provider identity
→ srv stop
```

Do not add a wrapper whose policy is semantically arbitrary. If the candidate requires a meaningful product choice about operating mode, surface that choice rather than guessing.

### 2. Legacy-path removal

After at least one real provider migration and a clear compatibility criterion, decide when the historical PATH `<service>-start` fallback can be removed.

### 3. User host supervision

PoC 012 in `rumiai-dev-PoCs` exercised real user supervisors on GitHub-hosted Ubuntu and macOS.

Evidence:

```text
run 35509150751
    Linux systemd user lifecycle   PASS
    macOS launchd user lifecycle   PASS

run 35509294369
    Linux systemd user lifecycle   PASS
    macOS awaited bootout/bootstrap lifecycle PASS
```

The tested native mapping establishes:

```text
Linux/systemd --user
    install   unit persistence + enable
    start     start
    stop      stop
    restart   restart
    uninstall stop + disable + remove + reload

macOS/launchd gui/<uid>
    install   persistent LaunchAgent definition
    start     bootstrap when unloaded
    stop      bootout while definition remains installed
    restart   kickstart -k for a loaded job
    uninstall bootout when needed + remove definition
```

Native verbs remain adapter detail. The serialization/relocatability boundary is resolved by PoC 012 follow-up run `35511575613` at `rumiai-dev-PoCs@a500e3073d89d00127e0a174958ad64a0d43dbef`: Ubuntu and macOS both passed with bootstrap/command paths containing spaces and multiple metacharacters. Linux must use `/bin/sh` as the systemd executable and serialize the exact `m` + command paths as arguments; macOS safely constructs distinct `ProgramArguments` entries through `plutil`.

### 4. System host supervision

System scope remains blocked on a genuine administrative-policy question: execution account, environment/state mapping and privilege transition. Do not implement `srv host system` by silently assuming root execution, creating an account, enabling sudo or reusing `state/user`.

## Next action

Implement and permanently test `srv host user` using the resolved serialization contract. The host definition must invoke an internal foreground `srv` execution path that re-resolves current facility-default intent at every host start/restart and then `exec`s the exact provider package command through `m`.

Do not implement `srv host system` until the execution-account/environment/privilege contract is fixed.

For the first real catalog service provider, stop only at the point where a package-specific operating-mode decision is genuinely required. Do not choose a development/insecure mode or production networking/security defaults on the user's behalf.

## Blockers / open questions

No generic portable-service implementation blocker remains.

Actual decision gates are now limited to:

- first real catalog service provider and any package-specific operating-mode policy it requires;
- removal criterion for the temporary legacy PATH compatibility path;
- product implementation/permanent validation of the now-proven user host adapters;
- system-wide account/environment/install mechanics behind the administrative boundary.

Physical stable-host validation has not been performed for this checkpoint.
