# Service model

Status: Active
Updated: 2026-09-22

## Goal

Complete and physically validate the service/facility/pkg model connecting portable
`srv` lifecycle, package-provided service facilities and explicit user/system host
supervision without introducing a duplicate service registry, provider graph or
dependency graph.

GeoServer 3.0.1 remains the real reference service provider and Temurin Java 21 its
real dependency provider.

This handoff is the active resume point for the task. Current canonical
specifications remain authoritative over this task-local state.

## Repository checkpoint

Repository revisions immediately before this handoff synchronization:

```text
rumiai-dev      b0855c0a03016daddbea5a854506b84b58b6c4e9
rumiai-os       c2dcde09c2582ff67733911816088952fa1eb5ee
rumiai-tests    12992b0b3d6198347a393f2735db725f49d0ba0e
pkg-catalog     64d67a73f4f9485749e1b47712e42f77afb4773e
rumiai-dev-PoCs 1bb5474f2c5f0e31dd1af85e458d84fd5e376395
```

Fresh remote HEAD retrieval is mandatory on resume. Parallel work is active in the
repositories; preserve all concurrent changes and reconcile forward if any HEAD has
advanced.

## Applicable canonical sources

Mandatory normal retrieval applies. The minimum task-specific source set is:

```text
specifications/rumiai-os/PACKAGE-MODEL.md
specifications/rumiai-os/SERVICE-LIFECYCLE.md
specifications/rumiai-os/STATE-MODEL.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
specifications/rumiai-os/LIBRARY-INTERFACES.md
specifications/rumiai-os/DOCUMENTATION-MODEL.md
TESTING.md
PHYSICAL-TESTING.md
handoff/service-model.md
```

Add `FILESYSTEM-NAMING.md` when changing package/library paths and
`COMMAND-ENTRYPOINTS.md` when modifying command entrypoints.

## Fixed service/facility/pkg model

The current canonical/implemented model already covers:

- provider-backed portable `srv start/stop` through the facility `service` typed
  part;
- service identity equal to facility identity;
- exact concrete provider launch through the normal package launcher;
- dependency/provider selection owned by pkg rather than duplicated by srv;
- GeoServer 3.0.1 as the real service provider;
- Temurin Java 21 as GeoServer's real Java facility provider;
- user host supervision through systemd user units and launchd LaunchAgents;
- system host supervision through systemd system units and launchd LaunchDaemons;
- explicit pre-existing non-root execution accounts for system services;
- system package State Instance equal to service identity;
- exact provider reconciliation and stale-registration failure;
- selector metadata private by default and exposed read-only/traversable only when
  system-service reconciliation requires it;
- no privilege escalation or host-account creation/removal inside `srv`;
- removal of the old PATH-based `<service>-start` fallback.

Permanent service coverage includes
`tests/rumiai-os/srv/host-system.test` and the real
`tests/external/geoserver/service-live.test`.

GeoServer's broader upstream mutable-root audit remains intentionally separate in:

```text
todo/geoserver-mutable-runtime-state.md
```

Do not block current service validation on that deferred audit and do not silently
route only one guessed mutable directory.

## Artifact-download resilience already completed

A real physical Ubuntu/x86_64 validation on host `PRTL-GS-01` originally failed
while installing GeoServer because SourceForge redirected the ZIP download to:

```text
netix.dl.sourceforge.net
```

and that mirror timed out after 30 seconds.

The failure was specifically:

```text
external/geoserver/service-live.test
curl: (28) Failed to connect to netix.dl.sourceforge.net port 443 after 30001 ms
pkg-download reason=transfer-failed
pkg-install geoserver@3.0.1 failed
```

That exposed a generic limitation: resolved artifact descriptors previously allowed
only one URL.

The current package contract now supports one or more **ordered URL candidates for
the same artifact**. Repository adapters own provider-specific mirror ordering;
generic `pkg-download` knows nothing about SourceForge. For every candidate,
`pkg-download` requires the configured expected size and digest to pass before
accepting the artifact, deletes failed candidate output, and advances to the next
candidate. Exhausting all candidates fails the download.

GeoServer's repository adapter emits the canonical SourceForge URL plus explicit
SourceForge mirror candidates. The generic fallback behavior has permanent coverage
under `tests/rumiai-os/pkg-download/contract.test`.

The operational manual `res/sys/manual/pkg-download.lib.sh` was also added because
the library/documentation contract requires every RumiAI-owned library to have one.

A later auxiliary physical rerun on the same Ubuntu/x86_64 host succeeded at the
then-current revisions:

```text
rumiai-tests@1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
rumiai-os@0a45bddce0318e111a72b052f7bc8366d2911b0b

geoserver-service
  validation/20260922T103106+0200-147249
  Scope result: VALIDATED

package-provider-facility-final
  validation/20260922T103534+0200-175877
  Scope result: VALIDATED
```

This evidence is useful but revision-specific and predates the `all` stream
correction below. Do not relabel it as validation of the current revisions.

## Latest user correction: platform-independent package stream is `all`

The user explicitly corrected the package-layout vocabulary:

```text
pkg/geoserver/catalog/...   INVALID
pkg/geoserver/all/...       CORRECT
```

This is not merely a GeoServer catalog rename. The generic resolver previously used
`catalog` as the platform-independent fallback stream. That generic concept has now
been corrected.

### Canonical contract

`PACKAGE-MODEL.md` now defines these package stream shapes:

```text
pkg/<package>/<osarch>/...
pkg/<package>/all/...
```

Resolution semantics are:

```text
exact <osarch> stream exists
    -> use it
    -> concrete identity carries !<osarch>

otherwise all stream exists
    -> use all
    -> concrete identity is platform-independent
    -> no !<osarch> suffix

catalog
    -> not a package stream name
    -> no fallback semantics
```

The relevant new invariants are PKG-72 and PKG-73.

### Product implementation

Current `rumiai-os` revision:

```text
c2dcde09c2582ff67733911816088952fa1eb5ee
```

changes `_pkg_install_stream_select` in:

```text
lib/sys/sh/pkg/pkg-install.lib.sh
```

from the historical fallback:

```text
pkg/<package>/catalog
```

to:

```text
pkg/<package>/all
```

Exact target stream precedence is unchanged.

`res/sys/manual/pkg-install.lib.sh` was updated in the same work unit to describe
exact-target selection followed by the platform-independent `all` stream.

### GeoServer catalog layout

Current `pkg-catalog` revision:

```text
64d67a73f4f9485749e1b47712e42f77afb4773e
```

consolidates GeoServer into one platform-independent stream:

```text
pkg/geoserver/all/
    repository/
    n0001=3.0.1/
```

The previous duplicate trees were removed:

```text
pkg/geoserver/linux-arm64/
pkg/geoserver/linux-x86_64/
pkg/geoserver/macos-arm64/
pkg/geoserver/macos-x86_64/
```

The `all` tree reuses the same GeoServer package definition content; this work did
not reopen the deferred GeoServer mutable-root question.

### Permanent regression

Current `rumiai-tests` revision:

```text
12992b0b3d6198347a393f2735db725f49d0ba0e
```

adds:

```text
tests/rumiai-os/pkg/install-stream.test
```

It protects all of these properties:

```text
all-only package -> all selected, empty identity osarch
both exact target + all -> exact target wins
legacy catalog-only -> selection fails
malformed exact target -> fail rather than silently falling back to all
```

The test was added to both task scopes:

```text
validation/geoserver-service.conf
validation/package-provider-facility-final.conf
```

Both scopes are pinned to:

```text
rumiai-os-commit c2dcde09c2582ff67733911816088952fa1eb5ee
```

The GeoServer workflow path filter also explicitly observes
`tests/rumiai-os/pkg/install-stream.test`.

## Formal validation state at handoff time

The `all` stream correction has **not yet been declared validated**.

The commit to `rumiai-tests` triggered both task workflows and they were still in
progress when this handoff was written:

```text
GeoServer real service path
  workflow: geoserver-service
  run:      35719207985
  status at checkpoint: in_progress

Broad provider/facility/srv regression
  workflow: package-provider-facility-bridge
  run:      35719207987
  status at checkpoint: in_progress
```

Do not rely on prior green runs for the current `all` stream revisions. On resume,
inspect these exact runs first. If they fail, retrieve the revision-specific
validation logs and correct forward. Do not narrow the declared validation scopes.

The immediately preceding hosted green evidence (before the `all` correction) was:

```text
geoserver-service
  run 35702983502
  rumiai-tests@1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
  rumiai-os@0a45bddce0318e111a72b052f7bc8366d2911b0b
  Linux/x86_64 VALIDATED
  Darwin/arm64 VALIDATED

package-provider-facility-final
  run 35702983369
  rumiai-tests@1062ffcd51d3c66e16a4a07a1aa9d84a46a56f83
  rumiai-os@0a45bddce0318e111a72b052f7bc8366d2911b0b
  Linux/x86_64 VALIDATED
  Darwin/arm64 VALIDATED
```

These runs establish the prior service/mirror-fallback state only; they are not
evidence for `c2dcde09...` / `12992b0b...` / `64d67a73...`.

## Next action — exact resume order

1. Perform the mandatory fresh remote-HEAD preflight for all involved repositories.
2. Read the current canonical sources and this handoff; do not substitute this
   checkpoint for current HEAD state if parallel work advanced.
3. Inspect GitHub Actions runs:
   - `35719207985` (`geoserver-service`)
   - `35719207987` (`package-provider-facility-bridge`)
4. Require both Linux/x86_64 and Darwin/arm64 matrix jobs to complete with the real
   `rumiai-validate` step successful. Artifact upload is intentionally
   non-blocking; the formal validation step remains blocking.
5. If either run fails:
   - retrieve the exact session/log evidence;
   - determine whether failure is product, catalog, test, upstream/network or
     orchestration;
   - correct forward without rewriting history;
   - keep the existing scopes unless current authoritative analysis shows a broader
     scope is required.
6. If both hosted runs are green, rerun the two fixed scopes on the current physical
   Ubuntu/x86_64 work host `PRTL-GS-01` because the `all` stream changed the real
   package-resolution path after its previous PASS:

```sh
sudo -v
./rumiai-validate geoserver-service
./rumiai-validate package-provider-facility-final
```

7. Record the new physical Ubuntu/x86_64 evidence exactly. It remains auxiliary
   because the stable Linux reference host is Ubuntu 26.04 ARM64.
8. Final physical gate still requires both fixed scopes on:
   - stable macOS reference host;
   - stable Ubuntu 26.04 ARM64 reference host.
9. A required `SKIP` is not a PASS.
10. After both stable reference hosts pass the current exact revisions:
    - synchronize this handoff with `Status: Complete` and exact physical evidence;
    - commit that final snapshot;
    - remove the completed handoff in a later forward commit.

## Important non-goals / deferred work

Do not reopen these while closing the current validation unless new evidence proves
they are causally involved:

- GeoServer mutable paths beneath its installation root;
- endpoint/readiness/health semantics;
- automatic host-account creation;
- automatic privilege escalation;
- a second service registry/provider graph;
- platform-specific duplication of GeoServer merely to avoid the `all` stream.

GeoServer mutable-root analysis remains deferred under
`todo/geoserver-mutable-runtime-state.md`.

## Current blockers / open questions

There is no known architectural design question.

At this checkpoint the only immediate blocker to declaring the latest software state
validated is completion/result analysis of the two hosted runs triggered by the
`all` stream correction, followed by revision-current physical reruns.

If those runs pass, remaining work is validation/evidence only.
