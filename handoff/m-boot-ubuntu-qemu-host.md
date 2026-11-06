# m-boot — Ubuntu minimal ext4 RAW host for native-architecture QEMU ISO boot

Status: **Active — host-looproot PASS; inner guest boot/optical recognition FAIL / unvalidated**
Updated: **2026-11-06** (operator-requested detailed checkpoint)

## Goal and current operator correction

The operator explicitly corrected the previous K-track interpretation on 2026-11-05: **implement a RAW disk container with a minimal Ubuntu-based OS that receives the selected ISO file path from m-boot GRUB/EFI, boots a native-architecture QEMU guest with that unchanged ISO presented as a persistent virtual optical drive, and exposes the actual host physical disks to the guest**. Other performance, firmware, device and UI settings require bounded research and measurement. This is a **host-OS-assisted m-boot boot path**; no longer classify it out of the intended use merely because QEMU runs a whole guest.

The previous `handoff/m-boot-qemu-kvm-iso.md` owns the bounded existing K-01…K-08 optical-device PoC/evidence and unfinished genuine vendor/KVM tasks, not this independently resumable RAW Ubuntu OS + GRUB launch/product-integration implementation. The parent `handoff/m-boot-standalone.md` retains the overall m-boot journey and shared F/M/K decisions. Keep each state in its owner and do not relabel previous PoC PASS as product PASS.

## Current ownership, repositories and exact resumption state

- This file owns the independently resumable **Ubuntu RAW host + GRUB launch + native QEMU guest + m-boot product integration** work. Parent coordination: `handoff/m-boot-standalone.md`. Previous K-01…K-08 optical-device diagnostics, genuine-vendor ISO and native KVM tasks have their separate owner `handoff/m-boot-qemu-kvm-iso.md`. Do not double-count that work as validated here.
- Canonical retrieval on resumption: fresh remote HEADs → `rumiai-dev/README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md` → relevant active handoffs → live PoC, current m-boot code/tests, evidence. Never infer an updated PASS from a test run on another SHA.
- Current code owner: `massimilianonardi-ai/rumiai-dev-PoCs/pocs/qemu-ubuntu-raw-host/`. Relevant files: `build.sh`, `grub-example.cfg`, `launch.py`, `mboot-qemu-host.service`, `smoke.py`, `boot-loop-smoke.sh`, `make-bootable-guest-iso.sh`, `README.md`. Relevant workflows: `.github/workflows/m-boot-ubuntu-raw-host.yml` and `.github/workflows/m-boot-ubuntu-loop-boot.yml`.
- Actual m-boot product files to inspect **before eventual integration**: `m-boot/loader/menu/{boot-media,boot-media-iso,boot-media-install}` and `m-boot/manual/boot-media`. Current m-boot production menu and the Ventoy secondary UEFI branch **have not been modified** by this RAW-host work.
- HEADs observed at this checkpoint, **not future defaults**: `rumiai-dev/main` dc9527c4f45960a6a91a8cc220e6edd8dff04ad6 (before this handoff commit); `rumiai-dev-PoCs/main` 2d5cedfef744a1a0cb88ab2135eb42ee6c404ec4; `m-boot/main` c06cd35a73b7e420c3a06dc51537c028ffa619d0. Re-verify remotely before further modifications. Concurrent changes belong to their existing owners.
- **Next action, without another design discussion:** diagnose actual startup and serial/QMP observability of the **inner QEMU guest** in the currently failing nested-Linux ISO test, then fix/prove guest-side persistent optical + disk detection on both AMD64 and ARM64. Do not restart the builder or replace Ubuntu's working native `loop=` path.

## Required operator journey and acceptance

1. Operator copies unchanged ISO and the built minimal Ubuntu RAW host container to m-boot's filesystem. A GRUB/EFI menu entry selects the original ISO and passes its real filesystem location to the RAW Ubuntu host.
2. Existing GRUB (no core rebuild) loads the selected host kernel/initramfs from the container or a justified, revision-bound sidecar. The host kernel/initramfs finds the RAW root filesystem file again, rather than assuming GRUB's loopback persists after handoff.
3. Minimal Ubuntu host starts without interactive distro setup, identifies native CPU architecture (x86_64 or aarch64), chooses its matching QEMU system emulator, uses actual KVM only if supported and demonstrably enabled, otherwise compatible TCG where feasible. RAM/CPU/firmware/graphics are separately characterized.
4. Guest receives unchanged selected ISO via persistent read-only virtual CD; provide honest guest-side post-kernel and original-vendor recognition evidence rather than host-only flags or an EFI-only menu.
5. The **full physical-disk inventory** is visible to the VM, including boot/source media. Host source disk must stay safe while hosting RAW/ISO files, so guest can be exposed a read-only view; other physical disks begin read-only unless exclusive ownership and explicit write authorization are demonstrated. Enabling writes on a device mounted or otherwise active in host is prohibited. The operator still needs a controlled route to explicitly authorize writes for real installation/backup tasks. Do not quietly omit the boot/source disk or claim all-disks available if devices cannot be attached.
6. Full source and physical disk integrity checks, isolation/cleanup, bounded failure paths and an operator-usable GRUB menu entry require real tests. Firmware/serial/graphics and host-bare-metal device/permission limitations must be recorded.
7. No current acceptance of raw USB writes, unattended disk installation, physical disk overwrite, real host boot success, or production-ready menu entry without authenticated execution and tests. CI must use **disposable fixture disks only**.

## Operator-approved implementation decisions (already fixed)

- Produce a **partitionless ext4 filesystem RAW file**, not a GPT whole-disk image. Native Ubuntu 24.04 `debootstrap --variant=minbase` builds the root tree; `mkfs.ext4 -d` populates the RAW file. APT is allowed **during build only**, in the temporary chroot. The old Ubuntu Cloud Image, QCOW2, `virt-customize`, libguestfs, partition-offset and custom GPT-root-hook paths have been retired; do not reintroduce them to solve a boot-test issue.
- Use a **same-build external kernel and initramfs** per architecture. MBOOTDATA layout: `/m/boot/host/{amd64,arm64}/` each containing `mboot-ubuntu-host.raw`, `vmlinuz`, `initrd.img`, `kernel-release.txt`, `release-SHA256SUMS`. `.raw.zst` is a compressed **transport** file, not the root image mounted by the kernel; decompress and validate before deployment. Never mix sidecars between builds.
- GRUB loads kernel and initramfs from ext4 MBOOTDATA and passes `root=UUID=<MBOOTDATA UUID>`, `loop=<RAW filesystem path>`, `loopfstype=ext4`, `mboot.iso=<original selected ISO path>`; x86_64 uses `ttyS0`, ARM64 virt uses `ttyAMA0`. Ubuntu's own `initramfs-tools/scripts/local` handles `loop=`, preserves the backing source filesystem under `/host` and mounts the unpartitioned RAW ext4 as root. No custom loop-root hook is necessary. The selected ISO is resolved from `/host`.
- The Ubuntu host launches **same-architecture** QEMU with a persistent read-only virtual CD/DVD containing the unchanged selected ISO. The launcher discovers host physical disks with `lsblk` and currently models each QEMU block backend **read-only**. Native KVM is preferred if genuinely accessible, otherwise TCG must be characterized. The prototype currently uses `-display none` / serial output: this is **not a usable final local GUI**.
- Protect the MBOOTDATA/source disk and any mounted/active host disk. **No concurrent host/guest writes, no unattended physical disk writes, and no implicit write permission**. The later writable-target policy requires explicit operator authorization and verified exclusive ownership; initial test fixtures remain ordinary disposable files.
- The experimental `grub-example.cfg` is a helper **not yet wired to the real m-boot menu**. Synthetic `grub-mkrescue` boot media prove a real GRUB firmware path, not the production ESP loader, GRUB chainload and USB device layout.

## Evidence matrix — current revision-specific truth

| Gate | Actual state | Pinned execution and interpretation |
| --- | --- | --- |
| Ubuntu Minimal rootfs RAW build | **PASS AMD64 + ARM64** | [CI 42114121474](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42114121474), source `b872aeb93578080e9b636aa239e5c7020a030e96`; both native runners ran debootstrap, APT in chroot, `mkfs.ext4 -d`, `blkid`/read-only `e2fsck`, `sha256sum -c release-SHA256SUMS`, and published compressed images with same-build `vmlinuz`/`initrd.img`. Kernel at that revision `6.8.0-147-generic`, raw logical size AMD64 2.5 GiB, ARM64 3.25 GiB. |
| Isolated QEMU read-only backing-device configuration | **PASS only for paused QEMU synthetic fixtures** | [CI 42079576887](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42079576887); real QEMU/QMP with read-only synthetic ISO + two file-backed disks, not a booted guest or actual physical disks. |
| Actual UEFI GRUB → native `loop=` Ubuntu root → systemd → QEMU launcher reached | **PASS AMD64 + ARM64 in isolated hosted VMs** | [CI 42117175487](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42117175487), source `7556f11e0a71b95f6d4d2abb6c2faa26aa4a34b2`; repeated [CI 42118352541](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42118352541), source `9c754fd0b7df728bf5dcbbaeace5585f51ea1379`, both jobs success and `MBOOT_LOOP_OUTER_QEMU_EXIT=0 phase=service`. Real GRUB and host service serial markers observed. The menu was a test-generated UEFI ISO, not real m-boot ESP. |
| Bootable synthetic Linux ISO **inside** nested QEMU, guest optical + disk enumeration | **NOT PASS — latest test FAILED on both architectures** | [CI 42119587994](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42119587994), source `885518fe383828b8658d96f3b75d99eb29eba065`; AMD64 job `127568131252`, ARM64 job `127568130780` both failed with `MBOOT_LOOP_INNER_OPTICAL_NOT_OBSERVED` (exit 14) after `MBOOT_LOOP_OUTER_QEMU_EXIT=124` (480 s timeout). Earlier [CI 42119540676](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42119540676) also FAILED on both architectures. In all these failures the host printed `MBOOT_QEMU_GUEST_START` and `MBOOT_QEMU_DISKS_READONLY=1`, but no accepted guest optical/device marker was observed. |
| Actual running inner QEMU VM, firmware selection and guest kernel | **Unverified** | **Important:** the launcher prints both host service markers immediately **before** calling `subprocess.run(cmd)`. Those markers prove that the launcher was reached and disks were inventoried, **not** that the inner QEMU process executed successfully, the CD-ROM was attached inside a running guest, or guest Linux started. Missing optical marker cannot yet be classified as a specific firmware, ISO, kernel, console, nested TCG or device fault. |
| User-facing menu, real disk safety/write ownership, graphics, KVM, original vendor ISO, reference hardware | **PENDING** | No direct operator-reference-host or actual m-boot USB execution and no authorized physical-disk write test. Do not promote any CI fixture as physical/product PASS. |

**Evidence notes / reproduction.** The inner test is owned by `boot-loop-smoke.sh` and `make-bootable-guest-iso.sh`, via `.github/workflows/m-boot-ubuntu-loop-boot.yml` on native `ubuntu-24.04` and `ubuntu-24.04-arm` GitHub runners. It downloads the exact same-build bundle artifacts from run `42114121474`, builds a disposable ext4 MBOOTDATA regular-file drive and EFI GRUB test ISO, then a synthetic Linux guest ISO using the bundle kernel and a modified **copy** of its initramfs. The source host RAW and original bundle sidecars are not modified. The failing run uploaded `mboot-ubuntu-real-loopboot-evidence-{amd64,arm64}` with `outer-qemu-serial.log`, GRUB logs and bundle SHA checks; use those and exact job logs to debug. The synthetic ISO is **not Proxmox or TrueNAS**. Artifacts originally retained for 14 days from 2026-11-05 (typically through 2026-11-19); after expiry rebuild/re-pin a coherent bundle, never silently select an unrelated `latest`.

## Remaining work, ordered by dependency and acceptance criteria

### P0 — Diagnose and complete actual boot of the nested Linux ISO (first; active blocker)

1. **Reproduce the latest pinned failure without redefining its meaning.** Inspect both failed job logs/evidence of run `42119587994`, including host `systemd` service output, child-QEMU stderr, firmware/GRUB output and the full serial stream. Current CI exits 14 only because the inner `sr*` marker is absent; confirm whether inner QEMU starts at all. Record exit/signal and first failing layer rather than retrying the 480-second timeout blindly.
2. **Isolate the bootable guest ISO before nesting.** Test the exact `make-bootable-guest-iso.sh` output directly with native QEMU/UEFI and one disposable virtio disk. Confirm GRUB actually boots its `vmlinuz`, the repacked initramfs executes `/init`, and the Linux fixture emits `MBOOT_INNER_GUEST_KERNEL_BOOTED`, `MBOOT_INNER_GUEST_OPTICAL_PRESENT`, `MBOOT_INNER_GUEST_DISK_PRESENT` and `MBOOT_INNER_GUEST_INSPECTION_PASS`. Check kernel modules (`virtio*`, `sr_mod`, `sd_mod`, SCSI/AHCI), `/sys/class/block`, serial console and firmware architecture. This is diagnostic media, never counted as vendor compatibility.
3. **Instrument the real inner-QEMU launch**, keeping its production-like command and read-only block backends: log exact command, child process result, `stderr`, QMP `query-status` and `query-block` / `query-named-block-nodes`; verify optical `-blockdev` read-only attachment, actual firmware boot, and serial console visibility. The current `-display none` may hide EFI/GRUB failures. Double TCG can be slow; benchmark the layers independently and use real KVM only if the host supports it. Do not weaken the marker requirement or translate a timeout into PASS.
4. **Restore the complete nested path** `m-boot-style GRUB → Ubuntu looproot → systemd → inner QEMU → guest Linux kernel → CD + disk observed inside guest`, on **both** native AMD64 and ARM64. Require all four guest markers from the real guest plus provenance/hash verification and an unchanged source ISO. Track precise CI revision, runner, QEMU version, firmware and log; if one architecture cannot complete, report that as an open architecture-specific gate.

**Exit criterion:** original guest-side synthetic Linux boots and observes both devices, not merely firmware/host-service startup.

### P1 — Validate full synthetic disk inventory, read-only guarantees and source safety

1. Move beyond the current **single outer-VM MBOOTDATA disk**: construct at least two additional disposable file-backed outer disks, including different sizes and missing/unready cases. Verify the actual host `lsblk` disk inventory and QEMU guest inventory agree, including the source/boot disk and all other drives; validate naming and robust error paths.
2. Validate persistent optical device and block data from inside the guest, not only QMP/backend declarations. Verify source ISO byte identity and hash before/after, QEMU read-only backend flags and backing file hashes; include all failure/cleanup branches.
3. Prove host-vs-guest source-disk policy. The host holds MBOOTDATA mounted for the RAW and ISO: even read-only guest exposure of its live block device may have consistency/staleness risks. Define and test an isolation/snapshot/reopen strategy before claiming a useful guest view. Do not expose writable host-mounted block devices.
4. Plan a separate explicit **write-enable mode for selected destination disks** only after safely unmounting/releasing them from Ubuntu, acquiring exclusive ownership and confirming the operator's intended target. No destructive real-disk test or deployment until separately authorized; source/boot remains protected.

**Exit criterion:** synthetic multi-disk guest inventory and integrity/safety validated; destructive/writable operations remain isolated and gated.

### P2 — Make the minimal host's QEMU guest usable locally

1. Replace the current headless `-display none` diagnostic behavior with a verified **local video and input** path appropriate for minimal Ubuntu (framebuffer/DRM/SDL/GTK or another justified existing facility), without assuming an Ubuntu desktop install. Choose real screen, keyboard, USB and console ownership and preserve a serial fallback.
2. Verify firmware UEFI, QEMU machine type, CPU, RAM, disk/network/USB configuration and host/guest resource contention separately on AMD64 and ARM64. Use KVM when actually available, record TCG fallback performance and set realistic memory limits. Double-TCG timing is not evidence of physical usability.
3. Test graphical/interactive installer normal path: keyboard, video, menus, installer media probing and reboot/cleanup back to m-boot without surprising extra operator steps.

**Exit criterion:** user can see and operate an actual guest on the monitor, not merely collect UART logs.

### P3 — Test unchanged original ISO media, not generated Linux fixtures

1. Obtain **genuine checksum-verifiable original** Proxmox VE and TrueNAS SCALE ISO media from trustworthy provider sources. Record URL, version, checksum, license constraints, architecture eligibility and exact tested binary; do not substitute a look-alike or generated fixture. Reuse the independent K-track vendor tests only for what their real revisions demonstrate.
2. Boot each supported vendor ISO through this actual RAW-host QEMU CD path, documenting BIOS/UEFI requirements, guest detection of optical contents, installer progress, physical/virtual disk visibility and interactive usability. Handle unsupported architectures explicitly rather than faking vendor support.
3. Add regression coverage for already working live/recovery ISO routes. Do not claim m-boot ISO compatibility from the first UEFI splash/menu alone.

**Exit criterion:** original vendor installer proceeds through real optical recognition and usable installer steps on supported architectures.

### P4 — Package and integrate the entry into the existing m-boot product

1. Establish a reproducible architecture-specific **distribution bundle**: RAW (uncompressed on MBOOTDATA), external `vmlinuz`/`initrd.img`, SHA256, kernel release and provenance. Deal with GitHub Action artifacts' finite retention and a deterministic release/rebuild channel; avoid mixing sidecar/raw revisions. Implement safe/atomic installation and rollback/fallback when appropriate.
2. Integrate a bounded GRUB helper and the normal ISO-selection action with existing categorized `m-boot/loader/menu/boot-media*`, without replacing or regressing working direct-kernel/loopback and network/EFI entries. Verify architecture discovery, path/UUID derivation, missing bundle and ISO handling, spaces/special characters in ISO path, appropriate GRUB variable export and source selection. Reuse actual m-boot ESP/loader for the final test rather than only `grub-mkrescue`.
3. Update the operator-facing `m-boot/manual/boot-media` at the same time as any public menu behavior change; add permanent source-pinned product tests/acceptance scenarios for the real selection flow and clear failure/fallback UX.
4. Retest update/regression semantics, USB installation/deployment and both native-architecture boot paths. Product repository changes must stay within the explicitly authorized phase and preserve concurrent edits.

**Exit criterion:** from actual m-boot boot menu, selecting an unchanged supported ISO invokes the verified host/QEMU path without an operator-crafted command line.

### P5 — Host hardware acceptance, write policy and closing evidence

1. After earlier gates, validate actual host CPU virtualization, `/dev/kvm` access, RAM pressure, I/O throughput, UEFI firmware, serial/video, USB input, disk inventory and source visibility on operator-designated reference hosts. Separate GitHub CI from actual reference-host evidence; never label hosted QEMU physical validation.
2. Validate **non-destructive** read-only mode first on real disks with explicit recorded source/destination identities, no unintended writes, fail-safe teardown and source integrity. Only after separate explicit authorization, test destination-drive writes on expendable media with exclusive host release and restore/rollback.
3. Apply the final consistency gate: inspect current HEADs, diff, product/manual/test alignment, evidence provenance, safety and no regressions, then update this handoff. After the full task is actually complete, promote any durable contractual decisions to current canonical specifications and close/remove the handoff forward-only per `handoff/README.md`.

**Exit criterion:** functional operator-facing m-boot ISO boot with safe disk policy, genuine installer/media recognition and actual reference-host confirmation. Until then **Status remains Active**.

## Safe continuation command

On a clean chat, start with the normal `rumiai-dev/README.md` bootstrap and **this exact handoff**. The first substantive action is **P0**: open source-pinned failed nested guest CI `42119587994`, inspect its archived serial/QEMU evidence and current scripts, determine whether QEMU/UEFI, guest GRUB, guest kernel or serial output is the missing link; then implement and retest only the identified layer. Do not reopen solved Ubuntu RAW build, native looproot or unrelated K/F/M tracks by default.
