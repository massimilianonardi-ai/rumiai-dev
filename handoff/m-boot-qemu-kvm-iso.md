# m-boot — QEMU/KVM optical-ISO alternative (independent parallel workstream)

Status: Active
Updated: 2026-11-05

## Goal

Independently validate whether existing QEMU system emulation and, on compatible hosts, KVM acceleration can expose an **unchanged existing ISO file** as a **persistent read-only virtual CD-ROM** to an unmodified guest OS, through the actual installer media-recognition stage. This is an **alternative VM execution model** and an important diagnostic reference, not a claim that KVM can virtualize *only* an optical drive while an unmodified OS owns bare-metal hardware.

This workstream is concurrently active with the firmware/early-Linux pathway owned by handoff/m-boot-standalone.md. No dependency on finishing that middleware or rebuilding its EFI boot image.

## Current repository revisions

- rumiai-dev/main: verify live HEAD at every resume; parent execution plan in handoff/m-boot-standalone.md is the relationship and cross-track decision owner.
- rumiai-dev-PoCs/main: observed 0eeb350995b9a46e97925c5c148d585f29d1aeb8 during K-08 verification; K-07 CI pinned ac8abca7249043f9849c566b7498297246ba5f38, K-03 CI pinned 15954883ec1c84e909ca366c5fac53fa5f0e9af6, K-02 CI pinned 843c564d3ac918b3858ec5e78439b7b245f569c1. Reverify live HEAD on resumption.
- m-boot/main: c06cd35a73b7e420c3a06dc51537c028ffa619d0 (no planned product changes).
- Ventoy/m-boot-secondary-uefi: ceff79ca92d246928f86362a569f86c6d2ac130f (background evidence only; no planned fork edits).

## Applicable canonical sources

- rumiai-dev/README.md; RULES.md; CONSISTENCY-GATE.md; specifications/README.md.
- rumiai-dev/handoff/README.md; TESTING.md; RUNNER.md; PHYSICAL-TESTING.md; TEST-PATTERNS.md.
- Existing relevant PoC context: rumiai-dev-PoCs/pocs/081-m-boot-native-efi-linux-media/README.md and pocs/086-m-boot-dual-physical-usb-uefi/README.md.
- QEMU authoritative background: https://www.qemu.org/docs/master/system/introduction.html ; https://www.qemu.org/docs/master/system/qemu-manpage.html ; https://www.qemu.org/docs/master/system/qemu-block-drivers.html . Reverify actual installed QEMU invocation options before using them.

## Fixed task-local choices

- QEMU work begins **now**, in parallel; no F/M prerequisite. Different owner, file paths and CI workflow from source-ABI work. Never modify another track's files or infer its PASS from this track.
- Guest boots the **entire OS in the virtual machine**. Persistently emulated optical media are visible to the guest after ExitBootServices; they do not magically provide persistent block hardware to an unvirtualized bare-metal OS.
- An ARM64 Ubuntu host running x86_64 guest uses QEMU TCG (not x86_64 KVM). A genuine x86_64 Linux host may independently use x86_64 QEMU/KVM when CPU/OS/nested-VM configuration supports it; verify /dev/kvm and actual accelerator evidence. Do not use a benchmark from ARM64 TCG to claim KVM speed.
- Original ISO file must be accessed directly with a read-only backend. No vendor ISO duplication, USB raw block-device detachment, full-size conversion or physical writes. Host USB may stay mounted while QEMU reads the ISO **as a file**. No installation to an operator/host disk; test-only target volumes must be explicitly disposable, if ever created.
- Keep firmware/guest boot observation, ISO visibility in the guest, actual installer source-media recognition, installer stable state, and installation completion as **distinct evidence levels**. Installation completion is out of scope without a new authorization.

## Acceptance scenarios

1. With a readable, unchanged bootable ISO file already on the host's USB filesystem, start a QEMU x86_64 guest using that ISO as read-only optical media, without copying ISO bytes or unmounting host USB. Confirm that EFI boot and guest Linux see the ISO optical drive after ExitBootServices, including the expected filesystem/media identity; no host disk writes.
2. Proxmox VE 9.2-1 guest uses its own original installer files and finds the expected original ISO ID. A stable state past the prior retry loop is required; EFI handoff alone is insufficient.
3. TrueNAS SCALE 25.10.7 guest similarly recognizes its source medium; capture readable serial and graphics diagnostic evidence rather than assuming an unreadable framebuffer means success.
4. On an x86_64 Linux host that actually supports KVM, repeat the same correctness gate with KVM and record active accelerator. On ARM64 Ubuntu vmdev, mark x86_64 KVM **unavailable** and keep a separate TCG evidence line.

## Working design — task registry (stable IDs K-01…K-08)

**Operator task identities:** `K-01` through `K-08` are fixed, unique **planning** IDs, not commands/APIs/software namespaces. Say `fai K-03` to select one. Never recycle or renumber an ID; extend the next available number when a new independent work unit is justified. Each task records its own source HEAD/CI or QEMU result, and status in *this* handoff. This track never owns F's firmware map or M's early-Linux code.

### K-01 — Guest-versus-bare-metal feasibility

- **Status / dependencies:** PASS (2026-11-05; source/architecture assessment, no execution test), none.
- **Objective:** determine precisely what a QEMU read-only virtual CD-ROM can deliver in the target m-boot user journey and where it is only a diagnostic control.
- **Steps:** compare original goal (USB boots host CPU/hardware/recovery tools) with full QEMU guest execution; identify requirements for host Linux/hypervisor, disk access, network, firmware, actual target installation, performance and required machine ownership. Clarify that KVM does **not** transparently virtualize a single drive for an otherwise unvirtualized bare-metal Linux kernel.
- **Output / acceptance:** two-scenario capability and exclusions matrix, minimum operator journey and explicit product-candidate vs diagnostic-only classification, with remaining open decisions identified.
- **Stop boundary:** if a guest fails the bare-metal user scenario, retain the bounded test-harness alternative; no hypervisor-as-product implementation without explicit architecture selection.
- **Out of scope:** QEMU boot test, new hypervisor, remote device virtualization, modification of m-boot boot process or physical USB.

#### K-01 result — two-scenario capability and exclusions matrix

**Scope of evidence:** source-backed feasibility/classification only. No QEMU guest boot, vendor media-recognition, KVM accelerator test, destructive installer or physical-host validation is implied.

| Dimension | A. Standalone m-boot USB / target bare metal | B. Linux-hosted QEMU/KVM guest / read-only ISO file |
|---|---|---|
| Start and ownership | Boot the target computer directly from a prepared USB; no previously running Linux host. Booted native OS/tools own the actual machine. | A working Linux host with QEMU and guest firmware (OVMF for UEFI) is required first. QEMU virtualizes the **whole guest** including CPU, memory and devices; host hardware remains owned by the host. |
| ISO lifecycle | Existing GRUB loopback reads an ISO at boot but does **not** make a persistent optical device visible to Linux, Windows PE or BSD. Native `findiso` recipes may work individually; actual Proxmox/TrueNAS media checks remain unproven. | A configured virtual optical controller with file-backed read-only CD is designed to remain visible after EFI bootloader exit to the guest operating system. K-03 must verify this property with guest-side post-kernel evidence; K-04/K-05 independently test real vendor recognition. |
| Target disks and backups | Native recovery/backup tools may discover and access actual disks via their own drivers and operator choices. This is the current core goal. | Guest sees virtual disks only unless devices/images are deliberately passed or mapped in. It cannot transparently repair/backup the host's physical disks; physical-disk passthrough and writes are **not authorized** in this workstream. |
| Hardware and firmware diagnostics | Native firmware, controllers and real system RAM are exercised, subject to actual tool support and physical testing. | Guest sees virtual firmware/controllers and assigned guest RAM. Guest diagnostics or memtest do **not** validate the host's physical RAM, native UEFI or attached peripherals. |
| Network and peripherals | Real NIC/USB/controller availability depends on the selected native OS and host drivers. | Network requires virtual NIC plus host/NAT/bridge configuration. Real NIC, USB and storage controllers are not automatically guest-owned; passthrough is a separate capability/safety decision. |
| Installation target | A native installer can address actual target disks when explicitly authorized; specific ISO installer completion is not yet established. | Installer normally addresses disposable **virtual** disks; direct host installation would require a separate unsafe assignment and is outside this task. Do not start installation in current QEMU tests. |
| Portability and performance | USB alone is the boot medium on supported target architecture/firmware; actual ISO recipes have individual compatibility limits. | Depends on a running host, QEMU/OVMF, free memory/CPU and permissions. x86_64 guest on ARM64 Ubuntu uses **TCG, not x86_64 KVM**; x86_64 KVM is possible only on an appropriate Linux host with working acceleration. No performance numbers or measured compatibility are claimed. |
| ISO preservation | Original payload copied to `MBOOTDATA/m/boot/iso/`; ISO remains unchanged but legacy GRUB menu entries are not CD emulation. | Original ISO may be used as a file-backed read-only virtual CD without a second ISO copy or unmounting the host USB. Actual source-hash preservation, guest read-only enforcement and cleanup are **future K-03/K-07 acceptance**, not a K-01 runtime PASS. |

**Minimum operator journeys:**

- **A — primary standalone user journey:** prepare USB once using the existing guarded m-boot media provisioner; copy the desired ISO under `MBOOTDATA/m/boot/iso/`; boot the computer needing recovery/installation; select the relevant firmware/GRUB recovery, diagnostic or installer entry; confirm that the *native OS/tool*, not just the menu, reaches usable physical hardware/media. Treat presently experimental ISO paths as unvalidated until independently proven.
- **B — independent diagnostic user journey:** on an already booted Linux host, keep an existing ISO file readable (including from a mounted USB); after K-02 confirms QEMU/OVMF/controller prerequisites, start an isolated guest with an explicitly read-only file-backed virtual CD and no physical host disk target; observe post-kernel guest media discovery; stop before installation; validate source identity and cleanup under K-03/K-07. No host USB unmount/raw disk passthrough is required.

**Product classification / stop boundary:** **Diagnostic-only test harness for the current standalone m-boot objective; not a product-equivalent bare-metal candidate.** A full QEMU guest is a useful control for *whether an unchanged vendor installer finds a normal optical device* and for separating vendor-media defects from GRUB-loopback defects. It cannot supply a virtual CD to a separate, directly hardware-owning bare-metal Linux kernel, and does not deliver standalone physical recovery on a machine without an already running host. An optional **host-assisted VM product** is only a *conditional future candidate* if the operator explicitly accepts a distinct host-OS-dependent journey and specifies acceptable physical disk access, networking, resources and installation safety. No product pivot or hypervisor implementation is authorized by K-01.

**Open choices for the eventual cross-track comparison (not K-01 blockers):** Is a host-assisted journey useful alongside standalone m-boot? Is recovery of the actual target's physical storage/firmware mandatory? What hardware passthrough and safety boundary, if any, could be allowed? Are TCG memory/runtime cost or real KVM host prerequisites acceptable? Which outcomes from real Proxmox/TrueNAS tests materially change product fit? Keep K-02/K-03 independent from these future product decisions.

**Source and evidence anchors:** `m-boot/main c06cd35a73b7e420c3a06dc51537c028ffa619d0` (`manual/boot-media`, `manual/usb-image`, `loader/menu/boot-media-iso`); `rumiai-dev-PoCs/main cbd5906b5af50c989764dabc9acba48dd5d43dc2` (PoC 081 and 086 READMEs: experimental **F/M** evidence, not K PASS); `rumiai-dev/main 8267b790b8864c12c821e9d57d658e45b36e4d90` (routing/plan). External reference: QEMU [system introduction](https://www.qemu.org/docs/master/system/introduction.html) and [invocation/block read-only options](https://www.qemu.org/docs/master/system/qemu-manpage.html). **K-01 PASS = documented classification and bounded operator feasibility only. No executable, vendor, KVM or physical validation performed.**

### K-02 — Host/guest QEMU capability and safety preflight

- **Status / dependencies:** PASS (2026-11-05, actual Ubuntu x86_64 runner QEMU/OVMF stopped-device preflight only); independent of K-01 and every F/M task.
- **Objective:** establish actual QEMU/OVMF availability and constraints for a read-only original ISO **file** as a virtual optical medium.
- **Steps:** inspect existing m-boot/PoC QEMU scripts; verify available QEMU version, host architecture, guest x86_64, OVMF firmware, CD-ROM controller/drive settings, serial/graphics, memory, scratch space and safe terminal exit. Distinguish Ubuntu ARM64 `vmdev` **TCG** for x86_64 from a future native x86_64 **KVM** host. Record hardware/permission requirements and /dev/kvm only when relevant.
- **Output / acceptance:** reproducible host capability manifest and command *candidate*, exact supported optical controller/flags and explicit unavailable prerequisites; no invented accelerator.
- **Out of scope:** guest media discovery PASS, a writable physical disk, full ISO downloads/copies, USB detachment and changes to F/M.

#### K-02 result — host/device preflight (revision-pinned)

**PASS on GitHub-hosted Ubuntu x86_64; not on operator vmdev.** [Actions run 42032540706](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42032540706), job `127262333677`, successful 2026-11-05; exact PoC workflow/source revision `843c564d3ac918b3858ec5e78439b7b245f569c1`. The independently owned PoC files are `pocs/qemu-optical-preflight/probe.sh` and `.github/workflows/m-boot-qemu-optical-preflight.yml`. The published `m-boot-k02-qemu-optical-preflight` artifact (ID `13417260600`) contains the machine-readable manifest, QEMU help/controller and live monitor output, plus before/after SHA256.

| Check | Actual result from the successful CI run |
|---|---|
| Host | Ubuntu 24.04.5 LTS x86_64; kernel `7.0.0-1017-azure` |
| QEMU | `qemu-system-x86_64` 8.2.2 (`1:8.2.2+ds-0ubuntu1.18`); `q35`, explicit TCG |
| Firmware | `/usr/share/OVMF/OVMF_CODE_4M.fd` and `/usr/share/OVMF/OVMF_VARS_4M.fd`; isolated writable copy of VARS |
| Optical device | `ich9-ahci` controller, `ide-cd` on `ahci.0`, `media=cdrom,format=raw,readonly=on` with a disposable **64 KiB regular file** |
| Actual setup exercise | Guest CPU held using `-S`; QEMU HMP `info block`/`info qtree` reported device/controller/source; `quit` returned success |
| Safety and host resources | Scratch source SHA256 unchanged; no host disk/USB/raw block device/real ISO, guest boot, network or installation. At run time MemAvailable **15,236,752 KiB** and scratch **89,449,680 KiB** |
| Acceleration | `/dev/kvm` present **but not accessible** to runner; only TCG executed, **no KVM PASS** |
| Display and serial | Headless `-display none` accepted; `-display help` captured; live graphical interface and guest serial markers **not tested** |

**Device command verified with the guest stopped** (the variables are concrete runtime file paths, not additional public APIs):

```sh
qemu-system-x86_64 -nodefaults -no-user-config -machine q35,accel=tcg \
  -m 256 -smp 1 -S -no-reboot -display none -monitor stdio \
  -drive "if=pflash,format=raw,readonly=on,file=$ovmf_code" \
  -drive "if=pflash,format=raw,file=$private_vars_copy" \
  -device ich9-ahci,id=ahci \
  -drive "if=none,id=cd,media=cdrom,format=raw,readonly=on,file=$disposable_probe_regular_file" \
  -device ide-cd,drive=cd,bus=ahci.0,bootindex=1
```

**K-03 candidate, not run here:** reuse the verified optical controller/backend and private OVMF, substitute an unchanged *bootable disposable ISO* for the 64 KiB probe, remove `-S`, allocate bounded RAM (2 GiB initial candidate) and use `-serial mon:stdio` (previously exercised in PoC 079). Independently verify a real guest post-kernel ISO9660 read, source SHA256 preservation and negative media failure. Do not expose writable physical disks or infer GUI/serial/vendor success from this setup preflight.

**Reproduction:** on any intended Linux host with the required QEMU/OVMF/coreutils packages, run `sh pocs/qemu-optical-preflight/probe.sh NEW_UNUSED_OUTPUT_DIRECTORY`; the script rejects existing paths and does not require root. This CI result does **not** inventory the operator Ubuntu ARM64 `vmdev` (x86_64 guest requires TCG there); native x86_64 KVM, actual ARM64 host QEMU/OVMF, real vendor ISO, on-screen GUI, guest optical persistence and reference-host validation remain **unverified**.

### K-03 — Synthetic persistent read-only CD-ROM in real QEMU

- **Status / dependencies:** PASS (2026-11-05, pinned real QEMU/OVMF TCG guest Linux optical evidence), after K-02 PASS; no M/F dependencies.
- **Objective:** prove a **guest OS running in QEMU** can read the same unchanged ISO9660 optical source after ExitBootServices via ordinary virtual CD-ROM semantics.
- **Steps:** reuse an existing small bootable synthetic ISO/marker where practical; launch stock QEMU/OVMF with `media=cdrom` and read-only host file, no Ventoy/EFI map or host USB raw disk. Add a guest-side post-kernel original-init/observer that reads its own optical medium and marker; identify controller and device path from guest evidence, not only QEMU flags.
- **Positive test:** real guest serial/console log shows original EFI boot, kernel handoff and an actual Linux read of optical ISO9660 marker after ExitBootServices; source ISO SHA256 remains identical, guest has no host writable disk. Test logs identify QEMU version, accelerator, guest controller and exact result.
- **Negative test:** missing optical source or read failure causes bounded FAIL, not false PASS; termination leaves host backing unchanged and guest scratch disposable.
- **Output / acceptance:** isolated PoC and CI/QEMU artifact with original guest observation. EFI menu or host-side file existence alone is insufficient.
- **Out of scope:** installer support, KVM performance, emulating bare-metal optical drive, copies of vendor ISOs.

#### K-03 result — source-pinned genuine QEMU/OVMF guest optical validation

**PASS, 2026-11-05:** [GitHub Actions run 42035789115](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42035789115) (`qemu-linux-post-kernel-optical`, job `127273490191`, SUCCESS). Exact tested PoC source/workflow revision: **`15954883ec1c84e909ca366c5fac53fa5f0e9af6`**. This is independent from the EFI-map F/M mechanism and does not validate vendor installers. The initial K-03 run `42035682288` failed **before fixture creation** because an unavailable apt metapackage was named; the follow-up corrected the workflow dependency and passed. No code/behavior PASS is attributed to the failed run.

- **Actual host/guest:** GitHub-hosted Ubuntu 24.04 x86_64; QEMU **8.2.2** (`1:8.2.2+ds-0ubuntu1.18`), **TCG**, Q35, private OVMF 4M variables, `ich9-ahci` + `ide-cd`, raw file-backed `media=cdrom,readonly=on`, guest **original Ubuntu 6.8.0-147-generic kernel**. No KVM or operator reference-host test.
- **Fixture provenance:** existing PoC 079 stock EFI GRUB/El Torito builder reused with a **K-only** early Linux init observer and exact kernel-matched `ahci` / `sr_mod` / `iso9660` module closure. No Ventoy map or early-Linux F/M middleware, original vendor ISO, USB, host disk or writable guest target. The synthetic ISO was **40,456,192 bytes**.
- **Positive result:** QEMU exited **0**. Its actual guest serial trace independently contains `VT079_UEFI_GRUB_STARTED`, `VT079_UEFI_ISO_FOUND`, `VT079_UEFI_KERNEL_STARTING`, `K03_GUEST_INIT_STARTED`, `K03_GUEST_CD_READONLY_PASS`, `K03_GUEST_DEVICE=/dev/sr0`, `K03_GUEST_ISO_MARKER_PASS`, `K03_GUEST_POST_KERNEL_CD_PASS` and `K03_GUEST_TEST_PASS`. The guest detected a block CD device through Linux, mounted ISO9660 and read the expected marker **after kernel handoff**. This is materially stronger than EFI-only boot evidence.
- **Identity:** source ISO SHA256 `0b4724d4d0a6ebf3514d9f101bf84c4eee3dac5594c760ff38c935a3bbef8a8d`. Guest-side `sha256sum /dev/sr0` matched the source digest; host-side SHA256 remained identical before, after and after the negative check.
- **Negative result:** attaching a deliberately nonexistent file-backed optical source caused QEMU exit **1**, with a missing-file diagnostic, rather than a successful boot or timeout. This proves QEMU startup fail-closed for **that absent-file case**, not all guest media-removal failures.
- **Evidence:** [artifact `m-boot-k03-qemu-optical-linux-evidence`](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42035789115/artifacts/13417623442), ID `13417623442`: generated ISO, guest positive serial log, missing-source log, module inventory, SHA256 and output manifest; published by the successful workflow.
- **Permanent footprint:** `rumiai-dev-PoCs/pocs/qemu-optical-guest/{guest-init.sh,build.sh,run.sh}` and `.github/workflows/m-boot-qemu-optical-guest.yml`; no modifications to `m-boot/main`, the experimental Ventoy branch, firmware consumers, original ISO sources, or physical USB. One earlier oversized script write was rejected before any repository mutation; smaller task-specific scripts were published forward-only.

**Limitations:** only synthetic Linux/ISO9660, AHCI/IDE-CD, QEMU TCG on an auxiliary CI runner. K-03 does **not** establish Proxmox 9.2-1 or TrueNAS 25.10.7 native ISO-ID recognition (K-04/K-05), arbitrary optical-controller compatibility, persistent attachment after guest media change, KVM acceleration (K-06), full operational isolation/fault injection (K-07), graphical installer readiness, or physical/reference-host compatibility. Guest `/dev/sr0` is a **virtual optical device inside a full QEMU guest**, not a physical drive exported to bare metal.

**Validation statement:** **K-03 PASS** for the exact positive and absent-file negative acceptance above, with real QEMU+original guest Linux post-kernel evidence at pinned revision `15954883`. No actual operator VM or hardware validation was run.

### K-04 — Proxmox VE 9.2-1 guest ISO recognition

- **Status / dependencies:** WAITING safe availability of the genuine original ISO file; K-03 PASS. **Independent sibling of K-05**, no vendor test executed.
- **Objective:** make the actual unmodified Proxmox installer pass its own media-ID search using a persistent QEMU optical drive.
- **Steps:** launch original 9.2-1 ISO from mounted filesystem file directly, preferably read-only on already-mounted operator USB; record source digest/provenance, QEMU controller, OVMF/TCG or KVM mode, console and serial. Stop before any real installation. Only add fresh guest disposable target storage if absolutely needed for installer media detection.
- **Positive test:** guest-owned installer observation confirms expected CD/ISO ID recognized and stable progress beyond the old retry countdown; distinguish graphics problems from media recognition.
- **Failure handling:** operator USB unavailable means BLOCKED (not code failure); bootloader-only PASS prohibited; no dependency on TrueNAS.
- **Output / acceptance:** exact vendor version, original-media evidence, QEMU log and media-check result.
- **Out of scope:** writing a host physical disk, full vendor ISO copy, F/M changes, product integration.

### K-05 — TrueNAS SCALE 25.10.7 guest ISO recognition

- **Status / dependencies:** WAITING safe availability of the genuine original ISO file; K-03 PASS. **Independent sibling of K-04**, no vendor test executed.
- **Objective:** make the actual unmodified TrueNAS live/installer environment recognize its optical source in Linux.
- **Steps:** same read-only QEMU backend and isolation; observe native TrueNAS source discovery, record true guest device and media identity; separate framebuffer/graphics tests from actual ISO discovery.
- **Positive test:** guest-owned original initramfs mounts/discovers original medium, reaches a stable observable installer stage, original ISO remains unchanged.
- **Failure handling:** unavailable ISO = BLOCKED; unreadable graphics alone != source media failure; Proxmox failure does not block this test.
- **Output / acceptance:** release-specific evidence and exact state; no claim of actual installation.
- **Out of scope:** vendor patch, new filesystem translation layer, raw USB backing or physical-OS hardware access.

### K-06 — Real KVM accelerator availability on a compatible host

- **Status / dependencies:** BLOCKED pending a confirmed **x86_64 CPU/host with accessible KVM**; K-02 and K-03 PASS on TCG. **Not dependent on K-04/K-05**; if no suitable host, mark BLOCKED rather than FAIL.
- **Objective:** distinguish real KVM-accelerated guest boot from portable TCG correctness; examine nested virtualization where applicable.
- **Steps:** check CPU/guest architecture, `/dev/kvm`, QEMU accelerator in actual execution; run existing K-03 synthetic correctness case in KVM, then a bounded comparison if comparable resources and media exist.
- **Positive test:** host and QEMU evidence explicitly confirms **KVM engaged**, same ISO recognition/guest markers and no host writes. Record resource consumption and comparable performance only on comparable hardware.
- **Output / acceptance:** KVM-specific evidence, explicit unavailable platforms (ARM64 `vmdev` x86_64 remains TCG).
- **Out of scope:** claiming ARM64 host→x86_64 KVM, substituting pure performance for correctness, provisioning a production virtualization cluster.

### K-07 — Operational isolation and feasibility check

- **Status / dependencies:** PASS (2026-11-05, actual isolated QEMU guest/read-only optical fault-injection and safe teardown on GitHub-hosted x86_64 TCG only); K-03 PASS; vendor evidence separately pending.
- **Objective:** decide whether the guest optical approach is robust as a bounded test facility or eligible for further product evaluation.
- **Steps:** verify ISO file open read-only, no raw USB write path, no direct host disk target, scratch cleanup, QEMU command failure propagation, source disconnect behavior, serial/video observability, memory/time budget, OVMF variables, guest storage/network/pass-through limitations and host bootstrapping feasibility.
- **Positive test:** fault-injection and safe teardown on disposable fixtures; operator journey describes actual host prerequisites and what physical hardware is inaccessible from guest.
- **Output / acceptance:** limitations and safety checklist, actual observed risks, capability matrix.
- **Out of scope:** declaring QEMU boot on USB-only bare metal possible without host OS, automatic product deployment or running installations.

#### K-07 result — real QEMU isolation, media-path fault injection and teardown

**PASS for the isolated synthetic guest test facility on the tested host**, 2026-11-05. [Actions run 42042675086](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42042675086), job `127297285210`, SUCCESS; exact exercised workflow/script revision **`ac8abca7249043f9849c566b7498297246ba5f38`**. New K-specific experimental files: `rumiai-dev-PoCs/pocs/qemu-optical-isolation/check.py` and `.github/workflows/m-boot-qemu-optical-isolation.yml`. [Run artifact `m-boot-k07-optical-isolation`](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42042675086/artifacts/13423036473) (ID `13423036473`) contains JSON manifest, original guest serial evidence, QEMU logs, missing-source error, synthetic ISO digest and module inventory.

| Safety or feasibility dimension | Exact observed result / boundary |
|---|---|
| Host and prerequisites | Real GitHub Actions Ubuntu **24.04 x86_64**, QEMU **8.2.2**, OVMF **4M**, TCG selected; standard Ubuntu GRUB, kernel with matched AHCI/SCSI-CD/ISO9660 modules, BusyBox, EFI/ISO-building utilities and available host RAM/storage are required. Operator ARM64 `vmdev` not exercised. |
| Existing source and ISO identity | Fresh disposable synthetic **40,456,192-byte** ISO from existing K-03 builder, SHA256 **`4a6d67e610ee46b2961b8dc0681791f5b1050f7789c85d0adeb1eedf8084b69f`**. QEMU `query-block` reported `cd` backend **`ro=true`**; guest reported optical medium read-only, mounted ISO9660 and produced the same full optical SHA256. No ISO source bytes rewritten. |
| Open-file pathname disappearance | Create an additional **hard link** to the *same synthetic file* (no second ISO byte copy), open as QEMU read-only CD, then unlink only that disposable alias **after QEMU opens the file**. QMP confirmed CD still inserted; `cont` booted the original guest Linux and the guest successfully read its contents and exited **0**. This proves **open file-descriptor survival after pathname unlink on this host filesystem only**, **not** physical USB disconnect, unplug, forced I/O errors or post-kernel device removal. |
| Optical removal | Separate real QEMU launched with CPU paused; `eject(force=true)` over QMP cleared the media from `query-block`, then `quit` returned QEMU **0**. **Pre-boot media eject** only; guest reaction to a mid-Linux optical removal was not measured. |
| Failure propagation | Deliberately nonexistent read-only backing path was rejected by actual QEMU with exit **1**; checker treats unexpected success/failed invariants as a nonzero CI error. Missing-file failure does not prove every possible backend/media fault. |
| Scratch and firmware protection | Separate OVMF private VARS image per case; original OVMF CODE/VARS template SHA256 unchanged. No residual QMP sockets, private VARS or hardlink after safe exit; QEMU processes terminated. Evidence logs and manifest intentionally retained. |
| Storage and network isolation | Explicit `-nodefaults`, `-nic none`, `-display none`, no real host disk, raw USB backend, guest writable disk, or hardware passthrough. QMP inspected attached CD and rejected unexpected non-firmware block backends; firmware VARS writable **only in disposable scratch**. No real installer or host-storage operations. |
| Serial/graphics observability | Actual booted guest serial log contains stock ISO GRUB, Linux init, read-only optical device, ISO marker and full hash PASS. Headless graphics intentionally disabled; no vendor installer framebuffer or GUI readability claim. |
| Resource and termination budget | Guest configured for **2 GiB RAM / 2 vCPU**, TCG; observed guest boot elapsed **6.744 s** on this GitHub-hosted runner. QMP eject/quit case **0.067 s**. These are **single-run task timings**, not x86_64 KVM benchmark, ARM64 TCG prediction or upper resource guarantees. QEMU boot wait is bounded; process cleanup has bounded TERM/KILL fallback. |

**Operator diagnostic journey (bounded, not a product installer):** boot an already running compatible Linux host with enough available resources; install QEMU system emulator + OVMF and the kernel/GRUB/ISO tooling required only for synthetic fixture generation; keep a readable existing ISO file on its mounted filesystem; pass it to QEMU using a **regular file-backed raw, read-only CD-ROM**, private writable OVMF VARS in scratch, explicitly no virtual writable guest disk/host USB/raw block device and no NIC; observe serial output or separately arrange graphics as needed; stop before installer write/target selection; confirm source hash, QEMU termination and cleanup. No USB unmount or device permission escalation is necessary to read the original **file**, but each actual filesystem/path and access permission must be verified on the target host.

**Classification:** **K-07 PASS as an isolated Linux-hosted QEMU diagnostic test facility**, supporting further *bounded vendor-media evaluation* only. **Not eligible as a replacement for standalone m-boot's USB-only bare-metal recovery/backup/install journey**: it requires a running host OS, host-installed QEMU/firmware, CPU/RAM, guest virtualization and host-owned real physical storage. A virtual guest cannot recover/diagnose host physical disks or firmware without separate, explicitly authorized passthrough; host-assisted product suitability remains undecided and no product pivot, installation or deployment is inferred.

**Remaining risks/limits:** no operator reference-host run, real USB detach/disconnect, hot-eject after Linux mount, actual hardware passthrough, genuine Proxmox/TrueNAS recognition, x86_64 KVM accelerator, on-screen graphics, arbitrary host paths (including commas in QEMU legacy `-drive` syntax), complete failure-mode/fuzz coverage or sustained resource/capacity testing. This narrower acceptance must not be promoted to a general safety guarantee.

### K-08 — QEMU/KVM evidence report to shared decision

- **Status / dependencies:** PASS (2026-11-05; revision-pinned evidence synthesis and decision input only, no new guest/physical run). K-01, K-03 and K-07 prior PASS; K-04/K-05 WAITING original ISO; K-06 BLOCKED accessible KVM.
- **Objective:** deliver a comparably structured and bounded decision input to the parent F/M/K architecture comparison.
- **Steps:** report version, ISO digest and media ID, host/guest CPU, real accelerator, firmware, controller, boot milestones, media-check outcome, source integrity, resource cost, applicability to hardware-recovery purpose and unresolved limitations.
- **Output / acceptance:** traceable report distinguishing synthetic guest optical proof, vendor media acceptance, optional KVM acceleration and actual product suitability; the track can finish as diagnostic PoC even if no product pivot is chosen.
- **Out of scope:** implicit change to m-boot product architecture or a claim of bare-metal CD device transparency.

#### K-08 result — bounded QEMU/KVM evidence report for the parent F/M/K decision (2026-11-05)

**K-08 PASS for its reporting/decision-input acceptance only.** Evidence independently rechecked against the successful GitHub Actions **run status, exact tested commits and current artifacts**. No new QEMU run, product modification, host benchmark, genuine vendor installer run or physical validation is claimed for this documentation work unit.

**Decision input:** retain the existing full-system QEMU/OVMF **virtual optical guest** as a **diagnostic-only comparator** for the native firmware/early-Linux F/M and current GRUB-loopback approaches. It is **not an equivalent implementation candidate for the original standalone m-boot USB recovery/backup/install goal**. The diagnostic result is strong within its actual scope: the guest's original EFI GRUB boots a genuine Linux kernel; after the firmware-to-kernel transition, Linux discovers the read-only virtual CD, mounts ISO9660, reads a known marker and hashes the entire CD with the same digest as the unchanged synthetic source. A working Linux host is a hard prerequisite, and guest hardware is virtual. **No decision to pivot product architecture, introduce virtualization, pass through disks or complete an installation is made by K-08**; the parent `handoff/m-boot-standalone.md` owns any later cross-track decision.

##### Evidence ledger — run, version, observable and limits

| Task | Evidence (version/revision) | Claim actually accepted | Not established |
|---|---|---|---|
| **K-01 PASS** | Current `m-boot/main c06cd35a73b7e420c3a06dc51537c028ffa619d0` `loader/menu/boot-media-iso`, `manual/boot-media`; K-01 matrix above | Architectural feasibility only: full guest optical drive is **not** a drive handed to an unvirtualized bare-metal OS; original GRUB loopback does not create an OS-visible CD | Runtime QEMU success, native vendor installer or new product choice |
| **K-02 PASS** | [CI 42032540706](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42032540706), exact PoC commit `843c564d3ac918b3858ec5e78439b7b245f569c1`, [artifact 13417260600](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42032540706/artifacts/13417260600) | Real Ubuntu 24.04 x86_64 runner: QEMU **8.2.2**, private OVMF **4M**, Q35, AHCI/IDE-CD, regular-file read-only optical source and actual stopped QEMU block/device tree; scratch SHA256 unchanged | Guest Linux boot; accessible KVM (runner `/dev/kvm` present but inaccessible) |
| **K-03 PASS** | [CI 42035789115](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42035789115), exact PoC commit `15954883ec1c84e909ca366c5fac53fa5f0e9af6`, [artifact 13417623442](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42035789115/artifacts/13417623442) | Genuine UEFI GRUB → original Ubuntu **6.8.0-147-generic x86_64 Linux** → guest `/dev/sr0` read-only ISO9660 marker/full hash after kernel start; synthetic source preserved; nonexistent ISO fails startup (exit **1**) | Original Proxmox/TrueNAS media ID or installation; physical USB and KVM |
| **K-07 PASS** | [CI 42042675086](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42042675086), exact PoC commit `ac8abca7249043f9849c566b7498297246ba5f38`, [artifact 13423036473](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42042675086/artifacts/13423036473) | QMP `ro=true`; disposable ISO hardlink removed *after host QEMU open* but guest still reads correct content; QMP **pre-guest** optical eject; missing source exits **1**; no transient process/socket/private VARS/alias left and original ISO/firmware templates unchanged | Unplug of a real USB, unexpected real backing I/O loss, eject during Linux use, real guest/host storage passthrough |
| **K-04 WAITING** | No qualified run; **genuine Proxmox VE 9.2-1 ISO file not available/verified** for this track | No real Proxmox media-ID recognition evidence | Whether unmodified Proxmox installer gets past its earlier media search |
| **K-05 WAITING** | No qualified run; **genuine TrueNAS SCALE 25.10.7 ISO file not available/verified** for this track | No real TrueNAS medium-recognition evidence | Whether unmodified TrueNAS installer reaches a stable observable stage |
| **K-06 BLOCKED** | No host with proven accessible x86_64 KVM for this track; tested runs used TCG | No KVM acceleration claim; x86_64 guest on operator Ubuntu ARM64 `vmdev` would require TCG | KVM correctness/performance/compatibility on an actual accelerated host |

**Machine/media identity (never conflate two separate synthetic ISO builds):**

| Property | K-03 actual guest proof | K-07 isolation run |
|---|---|---|
| Host/guest architecture | GitHub-hosted **x86_64 Linux** / **x86_64 Linux guest** | Same architecture, new runner and new disposable ISO |
| Emulator and actual mode | QEMU **8.2.2**, **TCG** (not KVM) | QEMU **8.2.2**, **TCG** (not KVM) |
| Firmware / controller | **OVMF_CODE_4M** + private writable VARS; `q35`, `ich9-ahci`, `ide-cd`; `media=cdrom,format=raw,readonly=on` | Same model, plus QMP inspected actual read-only backend |
| Source | Self-generated El Torito **ISO9660**, volume label `VT079_LINUX_TEST`, **40,456,192 bytes**; marker `/vt079-marker` = `vt079-uefi-isolated-source` | New disposable ISO with the same volume label, marker and size; **different source bytes/hash** |
| Host original SHA256 = guest optical SHA256 | `0b4724d4d0a6ebf3514d9f101bf84c4eee3dac5594c760ff38c935a3bbef8a8d` | `4a6d67e610ee46b2961b8dc0681791f5b1050f7789c85d0adeb1eedf8084b69f` |
| Observation | EFI GRUB markers, Linux `/init` markers, read-only `/dev/sr0`, ISO9660 marker/hash; guest shutdown status 0 | Same post-kernel observations after temporary pathname unlink; QMP eject and quit on a separate paused VM |
| Resource/cost statement | QEMU TCG run, no host/raw USB disk or NIC; no comparable benchmark | **2 GiB RAM / 2 vCPU assigned**, measured **6.744 s** synthetic boot, **0.067 s** paused eject/quit. One runner observation only; not actual RAM consumption, vendor timing, `vmdev` timing or KVM performance |

The ISO label/marker above is **synthetic**; **no original Proxmox/TrueNAS installation-media volume ID, digest, vendor CD check or installer stage was observed in K runs**. QEMU CD read-only and source integrity were established for regular synthetic **files**, not for an operator-mounted USB filesystem. Runtime logs and build inputs remain in their pinned workflow artifacts, not reinterpreted as validation of later concurrent PoC HEADs.

##### Capability versus standalone m-boot (decision boundary)

| Criterion | Native m-boot/F/M experimental direction | QEMU/OVMF K direction | Implication |
|---|---|---|---|
| Starts on target hardware using only prepared USB | **Design goal**; actual supported tools and installer paths have separate, incomplete validation | **No**: requires a running host Linux with QEMU, OVMF, adequate CPU/RAM/storage | K cannot replace the standalone recovery operator journey |
| Persistent CD after native kernel handoff | Legacy GRUB loopback **does not** provide this; F/M is an independent experimental EFI/kernel-map/middleware path owned by the parent/other child | **Yes within K-03 synthetic guest**, as real guest Linux `/dev/sr0` and ISO9660 read prove | K supplies a positive diagnostic/control for normal virtual optical media, not proof of F/M |
| Real attached physical disks, network, firmware, memory | Native tools potentially use the target's actual hardware, subject to capability/authorization | Guest sees virtual devices; **no physical pass-through was attached or authorized** | Host-disk recovery and physical RAM/firmware diagnostics remain outside K |
| Proprietary/vendor installers | Version-specific standalone status remains owned by the other tracks and physical evidence | **K-04/K-05 untested** | No vendor compatibility winner can be declared yet |
| Operational safety | USB preparation can be destructive only under distinct explicit operator consent, not covered by K | Isolated synthetic runs had source read-only, private OVMF state, bounded timeout, clean shutdown, no writable guest host disk | Evidence supports an isolated test facility, **not** a generic product safety/capacity guarantee |
| Host feasibility/acceleration | Dedicated host virtualization not required for standalone USB | Tested **x86_64 TCG** only; ARM64 `vmdev` x86_64 guest implies TCG; native x86_64 KVM **unverified** | No portable resource, latency or KVM-performance guarantee |

**Report stop rule and next evidence needs:** deliver K's bounded diagnostic reference to the parent comparative review without selecting a new product architecture. **K-04 and K-05** can proceed independently only after each genuine unmodified vendor ISO is safely readable and identified; classify genuine source unavailable as **WAITING/BLOCKED**, never code FAIL or PASS. **K-06** remains **BLOCKED** pending an actually accessible compatible native x86_64 KVM host; it is not required to accept this report. Operator VM `vmdev`, real USB detachment, GUI/graphics and physical-host installer/media recognition are explicitly **NOT TESTED** in this workstream. No new physical validation or workflow was run for K-08; its PASS is the source-anchored reporting deliverable.

### Sequence and concurrency

```text
K-01 ───────────────────────────────────┐
K-02 → K-03 ──────→ K-07 ───────────────┼→ K-08
          ├────────→ K-04  (vendor evidence, as available)
          └────────→ K-05  (vendor evidence, as available)
K-02 + K-03 + compatible host → K-06 (optional evidence; may stay BLOCKED)
```

K-01/K-02/K-03/K-07/K-08 have PASS at their explicitly bounded evidence levels; K-04 and K-05 independently WAITING safely accessible vendor ISO files; K-06 BLOCKED on accessible native x86_64 KVM. **No F or M dependency exists**. Each task uses track-owned PoC/workflow/output paths and records exact evidence here.

## Completed

- 2026-11-05: **K-08 PASS (evidence report only)**: source-pinned K-01/02/03/07 proof and limitations, K-04/K-05 WAITING unmodified vendor ISO, K-06 BLOCKED accessible native KVM; diagnostic-only recommendation for parent F/M/K comparison. No new QEMU, installer, product or physical run.
- 2026-11-05: **K-07 PASS (bounded CI isolation only)**: real QMP read-only source verification, hardlink alias disappearance followed by genuine Linux CD read, pre-boot QMP eject, missing-file nonzero, original ISO/OVMF hashes unchanged, no residual private VARS/socket/process; [run 42042675086](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42042675086), pinned revision ac8abca, artifact 13423036473. Not a real USB detach, vendor, KVM or reference-host test.
- 2026-11-05: **K-03 PASS** — real QEMU/OVMF TCG original Linux guest mounts the virtual read-only ISO after kernel start, reads marker and matches full optical device SHA256 to unchanged synthetic source; absent-file negative refuses with exit 1. CI run 42035789115, pinned PoC revision 15954883, artifact 13417623442. No vendor, KVM or reference-host PASS.
- 2026-11-05: **K-02 PASS (host preflight on GitHub CI only)**: QEMU 8.2.2/OVMF 4M TCG stopped AHCI/IDE-CD setup, matching backing-file SHA256 and saved manifest; run 42032540706. No actual guest boot or real reference-host run.
- 2026-11-05: **K-01 PASS (source/architecture classification only)**: two-scenario matrix, minimum operator journeys, diagnostic-only classification and open decisions documented above. No K-02, K-03, QEMU or physical test executed.
- 2026-11-05: independent workstream split from the global m-boot execution plan to allow concurrent development. No QEMU/KVM implementation, workflow or new test has yet been run as part of this new workstream. The PoC 081/087 baseline from the other track is reference only, not a KVM PASS.

## Current state

Stable operator-addressable task catalog K-01…K-08 established. **K-01 PASS (assessment), K-02 PASS (host preflight), K-03 PASS (real synthetic Linux optical guest)**, all independently verified on their stated levels and no F/M dependency. K-07 PASS (isolated diagnostic safety and failure checks); K-08 PASS (bounded decision-input report above). The QEMU branch is validated as **diagnostic-only**, not a replacement for the USB-only bare-metal product. K-04/K-05 still WAITING safely available genuine vendor media; K-06 BLOCKED accessible x86_64 KVM host. Parent cross-track architecture decision remains open. No vendor, actual USB disconnect, KVM or operator-reference-host PASS is claimed.

## Next action

**K-08 report is available above to the parent** `handoff/m-boot-standalone.md` for its eventual F/M/K comparison; no product path has been selected. Remaining independent K work is **K-04/K-05** when genuine Proxmox/TrueNAS ISO files become safely available, or **K-06** once an x86_64 host with usable KVM is verified. These successors are not started by K-08, and the K handoff stays Active for their distinct outcomes.

## Blockers / open questions

- An operator USB-backed genuine vendor ISO file may not be currently visible on vmdev because its passthrough previously fell to 0B; this is relevant to K-04/K-05 only and was not used by K-03.
- No verified accessible native x86_64 KVM host exists for K-06 in current evidence: CI has /dev/kvm but cannot access it; this does not block independent K-07 TCG tests.
- Operator `vmdev` Ubuntu ARM64 host was not directly inventoried by CI K-02 and requires a separate host preflight before any host-specific execution.
- K-01 establishes that VM execution is **not equivalent** to standalone physical recovery. Whether a separate optional host-assisted VM product journey is ever wanted remains an explicit architecture choice, not a settled product contract.
