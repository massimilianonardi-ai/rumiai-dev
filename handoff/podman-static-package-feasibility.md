# Podman static package feasibility

Status: Active
Updated: 2026-09-26

## Goal

Determine whether the current upstream `mgoltzsche/podman-static` Linux bundle can be used directly as the basis for a relocatable RumiAI `pkg podman`, especially for disposable service/interactions testing, and identify only the concrete host dependencies or incompatibilities that would require RumiAI-side adaptation or upstream reporting.

## Current repository revisions

- rumiai-dev: 888eb8b6935360137288e72370e87b795e4f9256
- rumiai-dev-PoCs: 8bec42ffa657d22aac4641af2bb2c98217625554
- pkg-catalog: da9b8989088c8b3f2d8201ad09e5f7180f334a16
- rumiai-os: 3d1f687cc12bac0467d37def42169bd5dbfb9912

## Applicable canonical sources

- README.md
- RULES.md
- CONSISTENCY-GATE.md
- TESTING.md
- DEVELOPMENT.md
- specifications/README.md
- specifications/rumiai-os/PACKAGE-MODEL.md
- specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
- handoff/README.md

## Fixed task-local choices

- Treat `mgoltzsche/podman-static` as the preferred upstream implementation to reuse directly.
- Do not rebuild, fork or add RumiAI-specific patches unless an observed defect or contract mismatch requires it.
- When a genuine upstream defect is found, prefer a minimal reproducible report/fix suitable for upstream before carrying a private RumiAI divergence.
- Initial scope is Linux, with rootless service/test workloads as the primary use case.
- This investigation does not yet authorize or imply a promoted `pkg-catalog` package definition; first establish empirical compatibility.

## Working design

- Experimental work belongs in `rumiai-dev-PoCs`.
- The PoC should test the released binary bundle from an arbitrary relocated directory, isolate mutable Podman configuration/storage/runtime state, and distinguish bundled userland dependencies from unavoidable Linux host requirements.
- Relevant behaviors include at least basic container execution, networking/port forwarding, a multi-container or pod interaction, and `podman play kube` when the execution environment permits them.

## Completed

- Compared the historical `popsUlfr/podman-appimage`, current `mgoltzsche/podman-static`, and the upstream Podman container image.
- Confirmed that current `podman-static` publishes Podman 6.1.2 static Linux bundles for amd64 and arm64 with the main Podman runtime/network/storage helpers.
- Confirmed that the upstream static project already exercises rootless networking, UID mapping, image builds, port forwarding and `podman play kube` in its own tests.

## Current state

The next step is empirical validation of the current `podman-static` release artifact itself, not redesign.

## Next action

1. Create a focused PoC in `rumiai-dev-PoCs`.
2. Inspect the release archive contents and binary linkage.
3. Execute relocatability and isolated-state experiments in an available Linux environment.
4. Record exact remaining host dependencies and classify any failures as environment limitation, upstream defect, or RumiAI integration mismatch.

## Blockers / open questions

- Whether the available auxiliary Linux environment exposes the kernel/user-namespace/FUSE/network facilities required for full rootless execution.
- Whether current hard-coded helper/configuration paths in the upstream bundle require only launch-time configuration or an actual upstream/RumiAI change.
