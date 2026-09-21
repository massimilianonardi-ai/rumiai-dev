# Service model

Status: Active
Updated: 2026-09-21

## Goal

Complete the service model that connects portable `srv` lifecycle, package-provided
facilities and explicit host-supervision integration without introducing a duplicate
service registry, provider graph or dependency graph.

The portable/provider-backed bridge, the first real service provider, user-scope
host supervision and legacy PATH-start migration are now complete. The remaining
active work is limited to system-scope administrative policy and physical validation.

## Current repository revisions

Current synchronized checkpoint before this handoff update:

```text
rumiai-dev      c221eb8562f5939b2ae46472fd1fbc528f9a5231
rumiai-os       f27f08f80d1e7407c8d8bd686a2beb4eb443eeb3
rumiai-tests    d61616898215d88a762aed191e7bbf5f096842c0
pkg-catalog     3749496e16172db00556751955280e7f3c7cbf61
rumiai-dev-PoCs ab470307cb8a3e26d57b798fe021109209d66792
```

Fresh remote HEAD retrieval remains mandatory on resume.

The service-relevant product revision formally validated below is:

```text
rumiai-os@6fd3656a7f8abdbc169ca2b9de94e02ec5e8cfbf
```

The current `rumiai-os` HEAD is a forward descendant whose only delta from that
revision is the unrelated addition of `res/sys/manual/enc.lib.sh`; no service,
package or GeoServer implementation changed in that delta.

## Applicable canonical sources

Use the mandatory project read order. The direct service contract is owned by:

```text
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/PACKAGE-MODEL.md
```

Add the host/platform/state/security specifications before system-scope host work.

## Completed implementation state

### Generic facility/service bridge

The current product implements the provider-backed service contract through the
facility `service` typed part. Provider conformance remains install-time/inert;
runtime service lifecycle remains owned by `srv`.

`srv start <service>` now requires:

```text
system facility default
→ installed concrete provider
→ valid facility-service/<facility>/start realization
→ ordinary package command
→ foreground provider process
```

Command naming and PATH are no longer a service-discovery mechanism.

Existing runtime records created by older revisions without provider metadata remain
readable for stop/stale-state cleanup. New starts persist concrete provider identity.

### First real provider: GeoServer

`pkg-catalog` now contains the first real service provider:

```text
facility/geoserver/1/service/start     package-command
facility/geoserver/1/service/process   foreground
facility/geoserver/1/service/stop      sigterm

pkg/geoserver/.../facility             geoserver 1
pkg/geoserver/.../dependency           java >=17 <22
pkg/geoserver/.../facility-service/geoserver/start
                                       geoserver-start
```

Temurin now provides the Java 21 path required by GeoServer 3.0.x while existing
Java 25 semantics remain intact.

The GeoServer repository adapter uses:

```text
GitHub releases API
    stable release inventory/latest only

SourceForge release RSS
    exact-version binary existence
    artifact size
    MD5 digest
```

Exact installs therefore do not depend on anonymous GitHub API quota. The exact
GeoServer 3.0.1 SourceForge binary metadata validated by the live test is:

```text
size    126971831
md5     1b8b60c512dd983f7996074d69119566
```

### User host supervision

The implemented public surface remains:

```text
srv host user install <service>
srv host user uninstall <service>
srv host user start <service>
srv host user stop <service>
srv host user restart <service>
```

Linux uses the calling account's systemd user manager; macOS uses the calling
account's launchd GUI domain. Host managers supervise the provider foreground process
directly and re-resolve current facility-default intent on a later start/restart.

No systemd linger or automatic restart policy is introduced.

### Legacy PATH migration

The historical PATH-resolved `<service>-start` fallback has been removed.

The removal criterion was satisfied because:

- GeoServer completed the first real catalog-provider migration;
- the current catalog contains no package `*-start` command other than GeoServer's
  provider-internal `geoserver-start`;
- service capability is now explicitly represented by the facility `service` part;
- permanent tests prove that both a configured-invalid default and an absent default
  fail instead of executing a same-named PATH command.

The canonical invariant is now SRV-19 in `SERVICE-LIFECYCLE.md`.

## Current formal validation evidence

All evidence is revision-specific and GitHub-hosted; it is not physical stable-host
validation.

### GeoServer end-to-end service validation

GitHub Actions run:

```text
35629714037
```

Exact revisions:

```text
rumiai-tests@d61616898215d88a762aed191e7bbf5f096842c0
rumiai-os@6fd3656a7f8abdbc169ca2b9de94e02ec5e8cfbf
pkg-catalog@3749496e16172db00556751955280e7f3c7cbf61
```

Formal `geoserver-service` scope:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

The scope validates live Temurin Java 21 installation, both repository adapters,
live GeoServer metadata resolution, facility contract, real `pkg install geoserver`,
provider default, portable `srv start/stop`, and
`srv host user install/start/restart/stop/uninstall`.

### Broad provider/facility/srv validation

GitHub Actions run:

```text
35629713722
```

Exact revisions:

```text
rumiai-tests@d61616898215d88a762aed191e7bbf5f096842c0
rumiai-os@6fd3656a7f8abdbc169ca2b9de94e02ec5e8cfbf
```

Formal `package-provider-facility-final` scope:

```text
Linux/x86_64   VALIDATED
Darwin/arm64   VALIDATED
```

The `rumiai-os/srv` selection passed on both hosts with no required SKIP:

```text
rumiai-os/srv/host-user.test   PASS
rumiai-os/srv/lifecycle.test   PASS
rumiai-os/srv/provider.test    PASS
```

The lifecycle test now exercises its concurrency, ownership, stale-state,
idempotence and failure behavior through an integrated provider/facility rather than
the removed PATH compatibility path.

A pre-existing malformed permanent-test fixture
`service_facility=servicefacility$` was discovered by this broader validation and
corrected to a valid unique facility identity before the final successful run.

## Remaining active work

### 1. System host supervision

`srv host system ...` remains intentionally unimplemented.

This is now the only remaining service-model design gate. Before implementation,
the project must decide the administrative contract for at least:

```text
execution account
account creation/reuse policy
privilege transition
system service environment
package/state HOME mapping
ownership and writable-state boundaries
installation/registration privilege
service-account access to package/provider state
```

Do not silently implement system scope as root execution, create a service account,
enable sudo, reuse RumiAI `state/user`, or grant a service account ownership/write
access over executable product roots.

This is a genuine policy decision rather than missing generic plumbing.

### 2. Physical validation

GitHub-hosted Linux/x86_64 and Darwin/arm64 formal validation is complete for the
implemented portable and user-host service paths.

Physical validation on the stable reference hosts remains separate under
`PHYSICAL-TESTING.md` and must not be inferred from GitHub-hosted evidence.

## Working system-host proposal — not yet canonical

The following is the current proposal for resolving the remaining system-scope
administrative gate. It is working design state only until explicitly accepted and
promoted into the canonical service/state/package specifications.

### Administrative invocation

System-scope lifecycle operations remain explicit administrative actions:

```text
srv host system install <service> <account>
srv host system uninstall <service>
srv host system start <service>
srv host system stop <service>
srv host system restart <service>
```

The proposed baseline requires the caller of every `srv host system ...` mutation
to already possess host administrative/root authority. `srv` does not invoke
`sudo`, `doas` or another privilege-escalation mechanism itself.

### Execution account

`install` receives one explicit pre-existing POSIX account. The account:

- must already exist in the host account database;
- must not be UID 0/root in the baseline;
- is not created, removed or modified by `srv`;
- may be a dedicated non-login service account and that is the recommended
  deployment shape;
- uses its host primary/supplementary group membership as configured by the
  administrator; group-management policy remains outside `srv`.

Linux/systemd should express this through the native system-unit execution-account
field. macOS/launchd should express the same semantic choice through the native
LaunchDaemon account field. The provider process itself never starts as root merely
because registration required administrative privilege.

Linux `DynamicUser=` is deliberately not the baseline because it is host-specific
and its recycled UID lifetime is a poor match for persistent RumiAI-managed service
state. No equivalent generic dynamic-account mechanism is assumed on macOS.

### System package state

A system-hosted provider must not use RumiAI `state/user`; that namespace is not a
POSIX account identity.

The proposed launch context instead uses system package state and isolates it by the
service facility identity through the existing State Instance mechanism:

```text
state-path system pkg <provider-package> home <service>
state-path system pkg <provider-package> conf <service>
```

and analogously for other package areas when needed.

This gives a service-specific package-state identity such as:

```text
<package>@!<service>
```

without adding a new state scope, owner class or registry.

The package launcher therefore needs an explicit internal system-service launch
context so that HOME/config resolution can use `scope=system` plus
`state-instance=<service>` instead of the normal user package state. The exact
private transport/API for that context remains an implementation question and
should reuse the existing launcher rather than create a second launcher model.

### Ownership boundary

Administrative install/reconciliation creates only the exact mutable system-state
paths required by the selected provider/service and assigns those paths to the
configured execution account.

The account must not receive ownership or write access to:

```text
$m_ROOT
$m_ROOT/m
$m_ROOT/bin
$m_ROOT/lib
$m_ROOT/res
$m_ROOT/pkg/<concrete>
provider executable/useful roots
catalog/runtime code
```

Package-declared mutable `var/` state remains governed by the existing static
system-state routing model. Where a provider requires mutable data that otherwise
lives in its executable tree, the package definition must route/configure that data
into managed mutable state rather than making the executable package root writable.

For GeoServer specifically, production system-host support should move
`GEOSERVER_DATA_DIR` away from the immutable installation root and into its
package HOME/data state derived from the system-service launch context.

### Provider reconciliation

The system facility default remains the provider-selection authority; system-host
registration does not become a second provider registry.

Because system service state permissions are prepared administratively, the proposed
system registration records the exact concrete provider that was resolved when
`install` last reconciled the service. At each hosted launch the internal runner:

1. resolves the current system facility default;
2. requires it to match the concrete prepared by the installed system registration;
3. resolves that concrete's service realization;
4. launches it with the prepared system-service package-state context.

If the facility default changes, the currently running process is unaffected and a
later system start/restart fails as a stale registration until the administrator
reruns:

```text
srv host system install <service> <account>
```

That install is an idempotent reconciliation operation: it prepares the current
provider's state permissions and atomically refreshes native registration, but does
not itself start or retarget an already-running service.

Uninstall removes native registration only. It does not delete the POSIX account or
authoritative package/service state.

### Host adapters

Proposed Linux baseline:

```text
systemd system unit
Type=simple
User=<account>
exact serialized m/srv argv
persistent enablement without implicit start during install
```

Proposed macOS baseline:

```text
/Library/LaunchDaemons
UserName=<account>
ProgramArguments exact argv array
persistent registration without implicit start during install
```

Both managers supervise the provider foreground process directly, as already required
for user-host supervision. Automatic restart policy remains outside the baseline.

### Proposal rationale

This shape preserves current RumiAI boundaries:

- no new service/provider graph;
- no new state scope or owner class;
- no implicit mapping from RumiAI `state/user` to POSIX users;
- no automatic account-management subsystem;
- no hidden privilege escalation;
- no writable executable product/package tree for service accounts;
- host-specific account dropping stays inside the systemd/launchd adapters;
- provider/default changes remain explicit administrative deployment transitions.

The principal tradeoff is intentional: system-host provider changes require an
explicit privileged reconciliation step before the next hosted launch. This is
preferred over granting service accounts broad write access to system package state
or allowing a boot-time unprivileged process to materialize state for arbitrary new
providers.

## Next action

The next implementation work is blocked on the system-scope administrative policy.

A clean resume should therefore:

1. perform the normal mandatory retrieval/preflight;
2. confirm that current HEAD deltas do not alter the service/package contracts above;
3. review/accept or correct the working system-host proposal recorded above;
4. after acceptance, promote the policy into current specifications and implement
   `srv host system ...`;
5. perform physical validation separately when the stable hosts are available.

No first-provider, Java 21, GeoServer, repository-metadata or legacy-PATH migration
work remains pending.
