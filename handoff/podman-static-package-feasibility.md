# Podman package feasibility

Status: Complete
Updated: 2026-09-26

## Goal

Determine whether RumiAI should provide a managed `pkg podman` or use the normal official/native Podman installation.

## Final decision

Do not create a general RumiAI `pkg podman`.

The user-established criterion is behavioral/install equivalence with normal Podman, not relocatability alone.

- Linux: use the distribution/native Podman installation.
- macOS: use the official Podman `.pkg` installer, which already avoids a Homebrew dependency and is the installation path recommended by Podman.
- Do not rebuild, fork or privately patch Podman merely to force it into the RumiAI package-store model.
- Do not add a Podman definition to `pkg-catalog` from `mgoltzsche/podman-static`.

## Evidence

### Linux static-bundle experiment

PoC 036: `rumiai-dev-PoCs/pocs/036-podman-static-relocatability`.

The unmodified `mgoltzsche/podman-static` v6.1.2 bundle is substantially relocatable and passed basic container execution, rootless networking, multi-container pod interaction, host port forwarding and `podman kube play/down --network=pasta` on suitable Linux hosts.

It is nevertheless not behaviorally identical to a normal feature-complete Podman installation. The project explicitly builds Podman without the `systemd` build tag, and the experiment confirmed that automatic Podman health checks remained in `starting` instead of being scheduled.

Other observed host/integration constraints included Ubuntu 24.04 pathname-sensitive AppArmor user-namespace policy and the default Netavark/Aardvark path on a systemd host without a user systemd bus.

These findings make `podman-static` unsuitable as the general replacement required by this task, even though the bundle remains technically useful for narrower environments.

### macOS official-installer experiment

PoC 037: `rumiai-dev-PoCs/pocs/037-official-podman-macos-pkg`.

The exact Podman v6.1.2 `podman-installer-macos-arm64.pkg` release asset was verified on an ARM64 macOS runner:

- release SHA-256 matched;
- the package was signed by `Developer ID Installer: Red Hat, Inc. (HYSCB8KRL2)`;
- Apple notarization and Gatekeeper validation passed;
- the official payload contained Podman, `gvproxy`, `vfkit`, `krunkit`, `podman-mac-helper`, libraries and documentation;
- principal relocated binaries retained valid code signatures.

After relocating the exact official payload and using only Podman's documented `helper_binaries_dir` configuration override, the client reported Podman 6.1.2 and completed `podman machine init` successfully.

However, relocation is still not the same installation as running the official installer: it skips the package's system-side PATH/manpath setup and the `podman-mac-helper install` side effect used for default Docker socket integration.

GitHub-hosted macOS runners do not support nested virtualization, so `podman machine start` was deliberately not claimed as validated by that PoC.

## Repository state at completion

- rumiai-dev-PoCs evidence through: `94e2d6a385236a081815b0a700b7c2b2be0c92bd`
- pkg-catalog: unchanged; no Podman package definition was added.
- rumiai-os: unchanged by this task; no Podman-specific package mechanism was added.

## Follow-up boundary

If a future RumiAI workflow needs Podman automatically provisioned, treat that as host/development/bootstrap provisioning of the official installation, not as evidence that Podman belongs in the relocatable `pkg` store.

