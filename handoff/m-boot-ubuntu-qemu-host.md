# m-boot — Ubuntu minimal RAW boot host for native-architecture QEMU ISO execution

Status: Active
Updated: 2026-11-05

## Goal and current operator correction

The operator explicitly corrected the previous K-track interpretation on 2026-11-05: **implement a RAW disk container with a minimal Ubuntu-based OS that receives the selected ISO file path from m-boot GRUB/EFI, boots a native-architecture QEMU guest with that unchanged ISO presented as a persistent virtual optical drive, and exposes the actual host physical disks to the guest**. Other performance, firmware, device and UI settings require bounded research and measurement. This is a **host-OS-assisted m-boot boot path**; no longer classify it out of the intended use merely because QEMU runs a whole guest.

The previous `handoff/m-boot-qemu-kvm-iso.md` owns the bounded existing K-01…K-08 optical-device PoC/evidence and unfinished genuine vendor/KVM tasks, not this independently resumable RAW Ubuntu OS + GRUB launch/product-integration implementation. The parent `handoff/m-boot-standalone.md` retains the overall m-boot journey and shared F/M/K decisions. Keep each state in its owner and do not relabel previous PoC PASS as product PASS.

## Current sources and provenance

- Required: live remote HEADs at every new task; `rumiai-dev/{README.md,RULES.md,CONSISTENCY-GATE.md,specifications/README.md}`, `handoff/README.md`, `TESTING.md`, `PHYSICAL-TESTING.md`.
- Parent: `handoff/m-boot-standalone.md`; bounded prior K device evidence: `handoff/m-boot-qemu-kvm-iso.md`.
- Product current GRUB menu paths: `m-boot/loader/menu/{boot-media,boot-media-iso,boot-media-install}`; current `m-boot/manual/boot-media`; do not silently replace existing working entries.
- Existing device PoCs: `rumiai-dev-PoCs/pocs/{qemu-optical-guest,qemu-optical-isolation}`; only their exact source-pinned earlier CI conclusions apply.
- Research: Canonical Ubuntu Minimal official release images: https://cloud-images.ubuntu.com/minimal/releases/noble/release/ (official published AMD64/ARM64 QCOW2 UEFI/GPT disk images, not pre-customized m-boot host images); Ubuntu Minimal overview https://ubuntu.com/cloud/public-cloud/docs/all-clouds-explanation/ubuntu-base-and-minimal-images/ ; GRUB loopback boot https://www.gnu.org/software/grub/manual/grub/html_node/Loopback-booting.html ; QEMU host disk warning https://www.qemu.org/docs/master/system/qemu-block-drivers.html ; libguestfs image customization https://libguestfs.org/virt-customize.1.html .
- Repository revisions at task preflight: `rumiai-dev/main 8eb17a33ac517e490eb2e86a550233606ac95509`, `rumiai-dev-PoCs/main 5579216cb0c90d0fbdf97bd70f5b61f8e0d68c82`, `m-boot/main c06cd35a73b7e420c3a06dc51537c028ffa619d0`, `Ventoy/m-boot-secondary-uefi 475db53dee122887fab3387db47fbb1f09ca71b7`. Verify at each subsequent write/resumption; source HEADs can move concurrently.

## Required operator journey and acceptance

1. Operator copies unchanged ISO and the built minimal Ubuntu RAW host container to m-boot's filesystem. A GRUB/EFI menu entry selects the original ISO and passes its real filesystem location to the RAW Ubuntu host.
2. Existing GRUB (no core rebuild) loads the selected host kernel/initramfs from the container or a justified, revision-bound sidecar. The host kernel/initramfs finds the RAW root filesystem file again, rather than assuming GRUB's loopback persists after handoff.
3. Minimal Ubuntu host starts without interactive distro setup, identifies native CPU architecture (x86_64 or aarch64), chooses its matching QEMU system emulator, uses actual KVM only if supported and demonstrably enabled, otherwise compatible TCG where feasible. RAM/CPU/firmware/graphics are separately characterized.
4. Guest receives unchanged selected ISO via persistent read-only virtual CD; provide honest guest-side post-kernel and original-vendor recognition evidence rather than host-only flags or an EFI-only menu.
5. The **full physical-disk inventory** is visible to the VM, including boot/source media. Host source disk must stay safe while hosting RAW/ISO files, so guest can be exposed a read-only view; other physical disks begin read-only unless exclusive ownership and explicit write authorization are demonstrated. Enabling writes on a device mounted or otherwise active in host is prohibited. The operator still needs a controlled route to explicitly authorize writes for real installation/backup tasks. Do not quietly omit the boot/source disk or claim all-disks available if devices cannot be attached.
6. Full source and physical disk integrity checks, isolation/cleanup, bounded failure paths and an operator-usable GRUB menu entry require real tests. Firmware/serial/graphics and host-bare-metal device/permission limitations must be recorded.
7. No current acceptance of raw USB writes, unattended disk installation, physical disk overwrite, real host boot success, or production-ready menu entry without authenticated execution and tests. CI must use **disposable fixture disks only**.

## Initial implementation strategy / current decisions

- Reuse official Ubuntu 24.04 LTS Minimal **released** cloud images, architecture-matched and checksum-verified against the matching published release manifest. Convert customized image to **RAW** using existing `qemu-img`; do not invent a Linux distribution.
- First executable slice: build an Ubuntu-host disk image on an isolated runner; ship an ISO-from-kernel-command-line QEMU launcher and a physical-disk inventory with **read-only** backends; exercise with synthetic files, not host `/dev/sd*` or NVMe. The source image may be QCOW2 before conversion, but produced artifact must be `raw`. This partial slice is **not** the finished GRUB/EFI+physical-disk m-boot operator journey.
- Integration phase: GRUB reads kernel/initramfs from RAW file (or vetted sidecar) and passes source filesystem identity, RAW pathname and ISO pathname; initramfs mounts the correct filesystem, loop-mounts the RAW root and preserves the ISO source across switch-root. Test original GRUB/UEFI using disposable nested QEMU; no claim based on a GRUB snippet alone.
- The QEMU guest must never be mislabeled as the bare-metal OS. Physical I/O is virtualized, with native devices exposed only through deliberate, exclusive raw block backends or later validated safe passthrough modes.

## Evidence/status

- **IN PROGRESS**: new corrected operator requirement acknowledged and researched using current source and official upstream references. No RAW OS, guest disk pass-through, menu integration, reference-host or physical-media PASS yet.
- Independent earlier K-02/K-03/K-07 positive evidence validates QEMU optical behavior on synthetic guest and test isolation only; K-04/K-05 original Proxmox/TrueNAS ISO and K-06 native KVM remain unverified/blocked in their owning handoff.

## Open engineering risks / next actions

- Select and verify host image release/checksum/GPT layout; use the existing Ubuntu image and libguestfs customization rather than assuming an image is already a usable m-boot RAW host.
- Implement/test boot-time ISO command-line parsing, physical disk inventory, QEMU native-arch selection and read-only attachment on synthetic devices; ensure fatal diagnostics and no unauthorized physical writes.
- Validate raw-format image actually boots through stock UEFI/QEMU as a whole disk, then develop external GRUB loopback root-discovery/initramfs and verify the **actual** original GRUB selection-to-guest path.
- Validate all-physical-disks visibility and differentiated source/system/target write policy on a disposable multi-disk topology. Source disk and host active filesystems must not be writable from guest concurrently.
- Measure host memory footprint, ISO boot, graphics/console, KVM availability and native ARM64; only then test genuine vendor media and operator reference host.
