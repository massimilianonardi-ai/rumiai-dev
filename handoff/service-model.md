# Service model

Status: Active
Updated: 2026-09-20

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task owns the portable/provider-backed service model and the later explicit host-supervision integration. The portable/provider-backed bridge is now implemented; host supervision remains a later phase of this active task.

## Current repository revisions

Current checkpoint used for this handoff sync:

```text
rumiai-dev      524bb9b1da2680c07b911b286c7d09be76155553  pre-sync HEAD
rumiai-os       56bfd26e1c59d040fcf2bffe5a823c071e78bda9
rumiai-tests    c1e6707943eb570ef7d8700233630fff6019f291
pkg-catalog     5372c160441b0346b976db7f7a022196784c9425
```

The service-bridge product revision actually exercised by the latest targeted matrix is:

```text
rumiai-os@b18d0fc804814c7b99e841df6f5d1fc22d2e5a90
rumiai-tests@c1e6707943eb570ef7d8700233630fff6019f291
```

Current `rumiai-os@56bfd26...` is a descendant of the exercised product revision and differs from it only in unrelated `gitman` command/manual changes. Fresh remote HEAD retrieval remains mandatory on resume.

## Applicable canonical sources

```text
README.md
RULES.md
CONSISTENCY-GATE.md
handoff/README.md
specifications/README.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

Current implementation/test evidence inspected for this checkpoint:

```text
rumiai-os/bin/sys/srv
rumiai-os/lib/sys/sh/pkg/facility/pkg-facility.lib.sh
rumiai-os/lib/sys/sh/pkg/pkg-provider.lib.sh
rumiai-tests/tests/rumiai-os/srv/lifecycle.test
rumiai-tests/tests/rumiai-os/pkg/provider.test
```

## Fixed task-local choices

The following choices are fixed for this task unless the user explicitly corrects them or a current canonical contract makes one impossible:

1. The portable, host-independent lifecycle remains:

   ```text
   srv start <service>
   srv stop [-f] <service>
   ```

2. Explicit host integration uses the public shape:

   ```text
   srv host user <action> <service>
   srv host system <action> <service>
   ```

   `user` and `system` identify the host-supervision integration scope. They do not redefine the existing `m` state-scope semantics.

3. Host runtime/policy actions such as:

   ```text
   start
   stop
   restart
   status
   activate
   deactivate
   ```

   are normalized `m` operations translated by host adapters onto the corresponding systemd/launchd semantics. They are not required to be literal textual aliases because the host interfaces are not perfectly isomorphic.

4. `srv host system install <service>` and `srv host system uninstall <service>` are higher-level `m` integration operations, not simple supervisor dispatch. They may need to manage host-specific unit/plist generation, registration, paths, account/ownership boundaries and other installation/removal mechanics under the explicit administrative boundary required by the canonical service contract.

5. Service integration remains opt-in and separate from the portable lifecycle. The portable `srv start/stop` contract must remain usable without systemd/launchd and must not be replaced by host supervision.

6. A service is conceptually related to a package facility, but `service` and `facility` are not synonyms. A facility is an abstract function/interface supplied by a package; a service adds an operational lifecycle contract. Not every facility is a service.

7. A package may expose zero, one or multiple services. Do not impose a package-to-service 1:1 restriction merely for convenience. The existing facility implementation already supports one package declaring multiple facilities, so the service model should preserve the natural 0..N cardinality unless a concrete contradiction is found.

8. Reuse the package facility declaration/provider-index responsibility for service registration/identity as far as its contract permits. Do not introduce a second service inventory/registry or a parallel provider lifecycle unless a concrete requirement proves the existing responsibility insufficient.

9. Facility/dependency semantics must not be reinterpreted as a service dependency graph. `srv` owns service lifecycle; `pkg` continues to own package facility/provider/dependency semantics.

10. Service-operability must be expressed through the generalized `pkg` facility contract rather than inferred semantically only from the presence of a conventional command. Do not introduce a separate service declaration/registry unless the generalized facility contract proves insufficient.

11. Provider-backed runtime now uses `facility-service/<facility>/start`, resolves the exact selected provider concrete and launches that exact package command through the active `m` bootstrap so package-launch semantics remain intact across hosts. PATH-resolved `<service>-start` remains only the temporary compatibility path when no facility default applies.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.
13. The provider-independent facility contract belongs to `pkg`. `srv` must not own a parallel provider contract/registry; it interprets the service/lifecycle portion of the selected facility provider when the generalized package facility model defines such an aspect.

## Active implementation scope

The portable/provider-backed service bridge is implemented.

Current product behavior:

- `service` is a trusted facility typed part with exact `package-command / foreground / sigterm` contract semantics;
- normal `pkg install` validates provider conformance against the same immutable catalog snapshot after extraction and before package-store mutation;
- `pkg_integrate` accepts and materializes validated `facility-service/<facility>/start` metadata without acquiring catalog context;
- `pkg_provider_default_resolve <facility>` resolves only the system facility default for global service lifecycle;
- `pkg_facility_service_start_resolve <facility> <concrete>` resolves the exact installed package command from materialized realization data;
- `srv start <facility>` uses that exact provider concrete and does not consult consumer bindings;
- provider-backed package commands are entered through `$m_BOOTSTRAP_BIN`, preserving `m_COMMAND_BIN`, bootstrap PATH and the normal package launcher on Linux and macOS;
- provider-backed runtime state records the selected concrete provider; later default changes do not retarget the running process and stop performs no provider re-resolution;
- configured-but-invalid provider state fails instead of silently falling back to PATH;
- the historical PATH `<service>-start` path remains temporarily only when no provider-backed default applies.

Permanent coverage now includes service conformance, integration/materialization/runtime resolution, provider-backed end-to-end `srv` behavior, default changes while running, no-invalid-default fallback, legacy lifecycle compatibility and real Temurin installation through the new install-time conformance boundary.

No real service provider has yet been added to `pkg-catalog`. The current end-to-end service lifecycle proof uses a synthetic package definition passed through the real `pkg_integrate` path; real catalog installation/conformance is separately exercised by the existing Temurin provider.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- Concurrent changes to `CONSISTENCY-GATE.md` and `handoff/README.md` were detected during the write, re-read and reconciled before this checkpoint.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.


- Promoted the service typed-part model into PACKAGE-MODEL.md and SERVICE-LIFECYCLE.md.
- Implemented service contract/provider conformance and the public installed-realization resolver.
- Wired exact-snapshot provider conformance into normal pkg install before package-store mutation.
- Added facility-service validation/materialization to package integration.
- Added system facility-default concrete resolution without consumer-binding semantics.
- Implemented provider-backed srv exact-concrete launch and running-instance provider identity.
- Diagnosed a real macOS failure where direct nohup of a #!/usr/bin/env m package command could not find m; corrected provider-backed launch to enter through the exact active m bootstrap.
- Realigned stale package-env test paths/driver execution discovered by the widened regression scope.
- GitHub Actions run 35491988828 passed the complete targeted development matrix on ubuntu-latest and macos-latest at rumiai-os@b18d0fc... / rumiai-tests@c1e670..., including external/temurin/install-live.test and all required provider/facility/srv selections.
- The GitHub Actions run is clean multi-host development evidence; it is not relabelled as formal rumiai-validate evidence and is not physical validation of the stable reference hosts.
## Current state

The portable/provider-backed service model and composition bridge are implemented and pass the targeted Linux/macOS GitHub-hosted matrix.

The current `pkg-catalog` has no service-capable provider definition yet. Therefore the remaining portable-service work is no longer a generic bridge problem; it is choosing and modelling the first real package/provider whose real foreground/start semantics satisfy the canonical service contract.

The temporary legacy PATH compatibility path remains intentionally present until that migration has a concrete removal criterion.

Host supervision (`srv host user|system ...`) remains unimplemented and is a separate later phase of this active service task.

Formal `rumiai-validate` evidence and physical stable-host validation have not been executed for this checkpoint. The available evidence is exact-revision GitHub-hosted development execution on Linux and macOS.

## Next action

The next portable-service step is to select one real current catalog package whose actual process model can satisfy the canonical `service` contract, add its facility contract/provider realization and exercise `pkg install -> facility default -> srv start/stop` end to end.

Do not invent package-specific start policy merely to obtain a demo. In particular, Keycloak's existing generic package command requires explicit upstream start-mode arguments, so choosing production `start`, `start-dev` or another wrapper is a real provider-policy decision rather than a generic facility default.

After a real provider proof and an explicit migration criterion, remove the temporary PATH `<service>-start` compatibility path.

The separate later phase is host supervision through the already-fixed `srv host user|system ...` public shape.

## Blockers / open questions

No generic facility/provider/srv bridge blocker remains.

Open service-task decisions that require concrete provider/host semantics rather than more generic infrastructure:

- which current package is the first real service provider in `pkg-catalog`;
- that provider's exact no-argument package start command and proof of `foreground` + SIGTERM behavior;
- the criterion for removing the temporary legacy PATH compatibility path;
- systemd/launchd adapter schemas and action mapping for `srv host user|system`;
- system-wide installation/account/environment mechanics behind the explicit administrative boundary.

Endpoint/readiness/health remain outside the baseline service part.
