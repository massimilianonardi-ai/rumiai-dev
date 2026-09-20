# Service model

Status: Active
Updated: 2026-09-20

## Goal

Complete the service model that connects portable `srv` lifecycle, package-provided facilities and later explicit host-supervision integration without introducing a duplicate service registry, provider graph or dependency graph.

The portable/provider-backed bridge and user-scope host supervision are implemented and formally validated. The active task now begins only where real-provider policy, legacy migration and system-scope administrative policy remain.

## Current repository revisions

Current synchronized checkpoint:

```text
rumiai-dev      035ec37e87dd50bdb7620a695723355dea049772  pre-sync HEAD
rumiai-os       708588615bec88f729d8619b45b4f59c24e6b959
rumiai-tests    8846e04b494ea8df15b74048cc52fc0e1a19983d
pkg-catalog     12ea704ee4e25e62ab3ed0125133660b4e0c42cb
rumiai-dev-PoCs ab470307cb8a3e26d57b798fe021109209d66792
```

The latest formal user-host/provider/facility validation exercised exactly:

```text
rumiai-os@708588615bec88f729d8619b45b4f59c24e6b959
rumiai-tests@8846e04b494ea8df15b74048cc52fc0e1a19983d
GitHub Actions run 35526602708
```

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
- Host-user supervisor discovery and registration follow the actual POSIX account context rather than caller-overridden `HOME`/XDG roots; this is canonical as SRV-32.
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

## Implemented user host supervision

Current product behavior also includes the canonical user-scope host adapter surface:

```text
srv host user install <service>
srv host user uninstall <service>
srv host user start <service>
srv host user stop <service>
srv host user restart <service>
```

Implementation properties:

- Linux uses the real calling account's systemd user manager and registration tree;
- Linux resolves the account UID/home from host account data and connects through `/run/user/<uid>`, explicitly supplying the real account `HOME`, `XDG_CONFIG_HOME`, `XDG_RUNTIME_DIR` and user-bus address to `systemctl --user`;
- systemd `ExecStart` uses fixed `/bin/sh` plus separately serialized exact arguments for the active `m` bootstrap, `srv`, the internal foreground runner and service identity;
- macOS resolves the real account UID/home, uses `launchd gui/<uid>`, constructs `ProgramArguments` through `plutil`, and stores the LaunchAgent below the actual account home;
- install persists/enables native intent without starting the service;
- start/restart re-resolve the current facility default and exact provider command;
- stop leaves native registration installed;
- uninstall removes adapter-owned registration;
- the native supervisor manages the provider foreground process directly and never calls portable `srv start`;
- no systemd linger or automatic restart policy is introduced;
- manifest writes use process-unique temporary files before atomic replacement.

The permanent `rumiai-os/srv/host-user.test` exercises real systemd user / launchd operations, two provider versions, start/stop/restart/uninstall, SIGTERM delivery and provider re-resolution across default changes.

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

### User host-supervision formal validation

GitHub Actions run:

```text
35526602708
```

Exact revisions:

```text
rumiai-tests@8846e04b494ea8df15b74048cc52fc0e1a19983d
rumiai-os@708588615bec88f729d8619b45b4f59c24e6b959
```

Formal `package-provider-facility-final` scope:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

The required `rumiai-os/srv` selection contained no SKIP:

```text
rumiai-os/srv/host-user.test   PASS
rumiai-os/srv/lifecycle.test   PASS
rumiai-os/srv/provider.test    PASS
```

This validation is especially relevant because `rumiai-validate` redirects mutable `HOME`/XDG roots. The host-user adapter still reached the actual account supervisor on both hosts, proving that native account/supervisor discovery is no longer accidentally coupled to RumiAI validation/application user-state roots.

As with the earlier GitHub-hosted formal runs, this is formal revision-specific RumiAI evidence but is not physical stable-host validation.

## Current state

The generic portable/provider-backed service bridge and user-scope native host supervision are no longer implementation blockers.

No current `pkg-catalog` package declares the `service` facility part. The next portable-service step requires a real package whose normal RumiAI package command can expose a deterministic no-argument foreground start operation satisfying the canonical `foreground` + SIGTERM contract.

Keycloak and Pulsar are plausible current catalog candidates, but both require an operating-mode/subcommand choice. For Keycloak, choosing production `start` versus insecure/development `start-dev` plus any required production configuration is provider policy. For Pulsar, choosing standalone versus broker/cluster semantics is likewise provider policy. None of those choices should be invented merely to obtain a demo.

The temporary legacy PATH path remains because there is not yet a real catalog provider/migration criterion.

User host supervision is implemented and formally validated on GitHub-hosted Linux/x86_64 and Darwin/arm64. System scope remains intentionally unimplemented because execution account, privilege transition, environment/state mapping and installation semantics are genuine administrative-policy decisions.

Physical stable-host validation remains pending.

## Remaining active work

### 1. First real service provider

Choose a current package whose actual launch semantics meet the service contract, define its provider-independent service facility contract/realization, and exercise:

```text
pkg install
→ explicit facility default
→ srv start
→ running provider identity
→ srv stop
→ srv host user install/start/restart/stop/uninstall
```

Do not add a wrapper whose operating policy is semantically arbitrary. Current plausible candidates require a real mode choice and therefore mark the first user decision gate.

### 2. Legacy-path removal

After at least one real provider migration and a clear compatibility criterion, decide when the historical PATH `<service>-start` fallback can be removed.

### 3. System host supervision

System scope remains blocked on a genuine administrative-policy question: execution account, environment/state mapping, privilege transition and installation ownership. Do not implement `srv host system` by silently assuming root execution, creating an account, enabling sudo or reusing RumiAI `state/user`.

### 4. Physical validation

GitHub-hosted systemd/launchd formal validation is complete for the implemented user scope. Required physical stable-host validation remains separate under `PHYSICAL-TESTING.md`.

## Next action

There is no further generic user-host infrastructure work to implement safely.

Resume implementation when one of these gates is explicitly resolved:

1. select the first real service provider and its operating mode;
2. define the compatibility criterion for removing the legacy PATH fallback after that migration;
3. define the system-scope execution-account/environment/privilege contract.

Until then, preserve the now-formally-validated portable/provider/user-host behavior and do not add speculative service policy.

## Blockers / open questions

No generic portable-service or user-host implementation blocker remains.

The remaining gates require policy rather than more generic plumbing:

- first real catalog service provider and its package-specific operating mode;
- removal criterion for the temporary legacy PATH compatibility path;
- system-wide account/environment/privilege/install mechanics behind the administrative boundary;
- physical validation on the stable reference hosts.

Do not treat GitHub-hosted validation as physical evidence.
