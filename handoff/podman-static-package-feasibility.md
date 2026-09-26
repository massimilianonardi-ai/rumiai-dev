# Podman package feasibility

Status: Active
Updated: 2026-09-26

## Goal

Determine the correct RumiAI integration path for Podman without substituting a behaviorally reduced build for the normal official installation.

The decision criterion is now stricter than simple relocatability: a RumiAI `pkg podman` is useful only when it preserves the materially relevant behavior of the official/native Podman distribution. Otherwise RumiAI should use the normal host installation path.

## Current repository revisions

- rumiai-dev: 284be9a8d895afaed2239e22c6be1eb5dfd8a525
- rumiai-dev-PoCs: 948fd749f303aeaff2f7eb4d1fa6ecf181ef103f
- pkg-catalog: da9b8989088c8b3f2d8201ad09e5f7180f334a16
- rumiai-os: 4f429c811f9c19889d0d8f6fa42b0423356beecd

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- handoff/README.md

## Fixed task-local choices

- Do not create a Linux `pkg podman` from a Podman build that is materially different from the normal official/native installation merely to obtain relocatability.
- On Linux, prefer the distribution/native Podman installation when the alternative bundle changes supported behavior.
- `mgoltzsche/podman-static` remains useful experimental evidence and may still be useful for narrowly constrained environments, but it is no longer the preferred basis for a general RumiAI `pkg podman`.
- Do not rebuild, fork or carry private Podman patches merely to force a package shape.
- On macOS, investigate the official Podman installer as the preferred no-Homebrew path. A RumiAI package is interesting only if it can reuse the official artifacts without losing materially relevant installer/runtime behavior.
- Do not change `pkg` or add a `pkg-catalog` Podman definition until that equivalence question is resolved empirically.

## Experimental evidence completed

PoC 036 in `rumiai-dev-PoCs/pocs/036-podman-static-relocatability` validated the current `mgoltzsche/podman-static` v6.1.2 Linux bundle.

Observed positive behavior after physical relocation and isolated state/configuration:

- shipped runtime/network helpers are static or static PIE;
- relocated Podman uses relocated `conmon` and `crun`;
- `podman info`, image pull and basic container execution pass on suitable hosts;
- rootless networking passes;
- multi-container pod communication passes;
- host port forwarding passes;
- `podman kube play/down --network=pasta` passes.

Observed integration constraints:

- strict Ubuntu 24.04 AppArmor unprivileged-user-namespace policy is pathname-sensitive and blocks rootless re-exec of an arbitrarily relocated Podman binary;
- default Kube networking on the hosted test environment reached Netavark/Aardvark but failed when a systemd host had no user systemd bus; the explicit `pasta` path passed;
- automatic Podman health-check scheduling remained in `starting`.

The last point is material to the revised decision: the static project explicitly builds Podman without the `systemd` build tag. It is therefore not a behaviorally identical substitute for a normal feature-complete Podman installation.

## macOS official installer findings

Current official Podman installation guidance recommends the Podman installer on macOS and explicitly does not recommend Homebrew as the primary installation path.

Podman v6.1.2 currently publishes the official asset:

`podman-installer-macos-arm64.pkg`

The upstream package build:

- installs its payload under `/opt/podman`;
- includes the official Podman client, `gvproxy`, `vfkit`, `krunkit`, `podman-mac-helper` and associated libraries/docs;
- compiles Podman with additional helper binaries rooted at `/opt/podman/bin`;
- runs pre/post-install scripts that manage `/opt/podman`, `/etc/paths.d`, the manpath and `podman-mac-helper install`;
- documents that `helper_binaries_dir` can alternatively be overridden in `containers.conf`;
- treats installation of `podman-mac-helper` as non-mandatory for basic Podman use, while that helper manages the default Docker socket integration.

Current RumiAI `pkg` extraction supports `dmg-pkg`, but not a direct macOS flat `.pkg` artifact. More importantly, simply extracting the official payload into the relocatable package store would skip the official install scripts and move the payload away from the build-time `/opt/podman/bin` helper path.

Therefore direct payload extraction cannot yet be called equivalent to the official installation.

## Current state

Linux package promotion is stopped: no `pkg-catalog` Podman definition should be created from `podman-static`.

The remaining useful question is macOS-specific: can the exact official Podman `.pkg` payload be used relocatably with only documented configuration overrides while preserving the Podman behavior RumiAI needs, or should RumiAI simply require/use the official system installer?

## Next action

Run a macOS PoC against the official Podman v6.1.2 installer to:

1. verify and expand the exact signed release asset;
2. inspect the installed payload and installer scripts as actually packaged;
3. relocate the official payload without rebuilding any binary;
4. override only documented helper lookup configuration;
5. determine which Podman machine/client operations still work and which specifically depend on the system installer side effects.

Only if that path remains materially equivalent should a RumiAI `pkg podman` for macOS be considered.

## Open questions

- Whether the official macOS Podman payload can operate fully enough from a relocated root with `helper_binaries_dir` redirected.
- Whether `podman-mac-helper` / default Docker socket integration is required by the RumiAI test/runtime use case.
- Whether macOS hosted CI permits enough virtualization to validate `podman machine` beyond payload/configuration inspection.
