# Service model

Status: Active
Updated: 2026-09-17 14:04 +02:00

## Goal

Define the service model that connects the portable `srv` lifecycle, package-provided facilities and explicit host supervision integration without introducing a duplicate package/service registry or a second dependency graph.

The task must converge on the semantic model and public contract before implementation work is started.

## Current repository revisions

Revisions verified for this checkpoint:

```text
rumiai-dev@c4f96d4547edd2c1258292d500c89705f25ec0b4
rumiai-os@36c29d8412a523f722fd90004b78a07fdf0b06c8
rumiai-tests@298931c1dca03d44755893d64b9b3a7c0058b7ea
pkg-catalog@94f58995cbd487b17f3b82bc2724c70540927b88
```

`rumiai-dev` advanced during the preflight from `67fb6fa1d4aafc048e0c27752e66abe77bc4d832` to the revision above. The intervening changes added unrelated TODO files only; the applicable rules/specifications did not change. The handoff commit itself advances `rumiai-dev` beyond the recorded authority baseline.

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
rumiai-os/lib/sys/sh/pkg-facility.lib.sh
rumiai-tests/tests/rumiai-os/srv/lifecycle.test
rumiai-tests/tests/rumiai-os/pkg/facility.test
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

10. Before introducing any new package-local `service` declaration or registry, evaluate whether the existing combination:

    ```text
    facility declaration
    +
    conventional <facility>-start command
    ```

    can identify that a facility is also operable as a service while preserving unambiguous package/provider ownership.

11. The current `<service>-start` foreground target convention remains the portable launch convention during this design task. Package-integrated targets must continue to use the normal package launcher for package HOME/environment/dependency preparation.

12. Host-managed system services must preserve the canonical administrative/security boundary: system-wide integration is an explicit admin operation, and any dedicated OS service account must not gain ownership/write access over executable product roots merely because it runs the service. Detailed host adapter mechanics remain to be designed and validated separately.

## Completed

- Fresh preflight completed against current remote HEADs of `rumiai-dev`, `rumiai-os`, `rumiai-tests` and `pkg-catalog`.
- Current documentation router, rules, consistency gate, service lifecycle specification, package model and handoff lifecycle were read.
- Current `srv` implementation and permanent lifecycle test were inspected.
- Current package facility implementation and permanent facility test were inspected.
- No existing `handoff/service-model.md` or deferred `service-model` TODO existed before activation.
- The initial service-model choices agreed in the design discussion are captured above as resumable task-local state.

## Current state

The canonical service specification still defines only the portable `srv start/stop` lifecycle and explicitly leaves host integration outside that baseline.

The current implementation resolves `srv start <service>` through the conventional `<service>-start` command. The current facility implementation accepts multiple facility declarations for one package and maintains a derived provider index through the package integration lifecycle.

This makes reuse of the facility/provider mechanism structurally plausible, but no current canonical contract yet defines how a facility becomes a service, how `srv` selects the responsible provider when provider ambiguity exists, or how host integration consumes that identity.

No product, test or catalog implementation change is part of this checkpoint.

## Next action

Analyze the existing facility -> provider -> integrated-command path and determine whether `facility + <facility>-start` is sufficient to represent package-provided services without any new service declaration or registry.

That analysis must specifically resolve command/provider ownership and multi-provider ambiguity before proposing canonical specification changes. If the existing primitives are insufficient, introduce the smallest additional declaration/resolution responsibility only after proving the gap.

After the semantic model is settled, update the applicable canonical specification(s) before implementation.

## Blockers / open questions

- How is a service distinguished from a non-service facility without duplicating package metadata?
- If multiple concrete packages provide the same facility, what makes `srv <operation> <service>` resolve to one operational provider without inventing an independent resolver or violating package ambiguity rules?
- Can ownership of the integrated `<facility>-start` command provide the required unambiguous link to the facility provider?
- Should the final service identifier be exactly the facility identifier and therefore adopt the canonical facility-name grammar, or does the current broader `srv` name grammar remain justified?
- What is the exact normalized host action set and the semantic mapping of actions such as `activate/deactivate` across systemd and launchd?
- Does host `user` scope also need explicit install/uninstall operations, or are install/uninstall initially system-only?
- What metadata/configuration, if any, is required to generate systemd units and launchd plists while preserving package launch semantics and the system-account/useful-root ownership boundary?
- Host adapters remain subject to separate host-specific proof/validation before being treated as portable product behavior.
