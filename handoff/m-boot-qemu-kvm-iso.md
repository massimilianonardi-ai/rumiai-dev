# m-boot — QEMU/KVM optical-ISO alternative (independent parallel workstream)

Status: Active
Updated: 2026-11-05

## Goal

Independently validate whether existing QEMU system emulation and, on compatible hosts, KVM acceleration can expose an **unchanged existing ISO file** as a **persistent read-only virtual CD-ROM** to an unmodified guest OS, through the actual installer media-recognition stage. This is an **alternative VM execution model** and an important diagnostic reference, not a claim that KVM can virtualize *only* an optical drive while an unmodified OS owns bare-metal hardware.

This workstream is concurrently active with the firmware/early-Linux pathway owned by handoff/m-boot-standalone.md. No dependency on finishing that middleware or rebuilding its EFI boot image.

## Current repository revisions

- rumiai-dev/main: verify live HEAD at every resume; parent execution plan in handoff/m-boot-standalone.md is the relationship and cross-track decision owner.
- rumiai-dev-PoCs/main: cbd5906b5af50c989764dabc9acba48dd5d43dc2 (current known evidence; reverify live HEAD).
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

- **Status / dependencies:** READY immediately, none.
- **Objective:** determine precisely what a QEMU read-only virtual CD-ROM can deliver in the target m-boot user journey and where it is only a diagnostic control.
- **Steps:** compare original goal (USB boots host CPU/hardware/recovery tools) with full QEMU guest execution; identify requirements for host Linux/hypervisor, disk access, network, firmware, actual target installation, performance and required machine ownership. Clarify that KVM does **not** transparently virtualize a single drive for an otherwise unvirtualized bare-metal Linux kernel.
- **Output / acceptance:** two-scenario capability and exclusions matrix, minimum operator journey and explicit product-candidate vs diagnostic-only classification, with remaining open decisions identified.
- **Stop boundary:** if a guest fails the bare-metal user scenario, retain the bounded test-harness alternative; no hypervisor-as-product implementation without explicit architecture selection.
- **Out of scope:** QEMU boot test, new hypervisor, remote device virtualization, modification of m-boot boot process or physical USB.

### K-02 — Host/guest QEMU capability and safety preflight

- **Status / dependencies:** READY now; independent of K-01 and every F/M task.
- **Objective:** establish actual QEMU/OVMF availability and constraints for a read-only original ISO **file** as a virtual optical medium.
- **Steps:** inspect existing m-boot/PoC QEMU scripts; verify available QEMU version, host architecture, guest x86_64, OVMF firmware, CD-ROM controller/drive settings, serial/graphics, memory, scratch space and safe terminal exit. Distinguish Ubuntu ARM64 `vmdev` **TCG** for x86_64 from a future native x86_64 **KVM** host. Record hardware/permission requirements and /dev/kvm only when relevant.
- **Output / acceptance:** reproducible host capability manifest and command *candidate*, exact supported optical controller/flags and explicit unavailable prerequisites; no invented accelerator.
- **Out of scope:** guest media discovery PASS, a writable physical disk, full ISO downloads/copies, USB detachment and changes to F/M.

### K-03 — Synthetic persistent read-only CD-ROM in real QEMU

- **Status / dependencies:** WAITING K-02. May run while K-01 is being finalized; no M/F dependencies.
- **Objective:** prove a **guest OS running in QEMU** can read the same unchanged ISO9660 optical source after ExitBootServices via ordinary virtual CD-ROM semantics.
- **Steps:** reuse an existing small bootable synthetic ISO/marker where practical; launch stock QEMU/OVMF with `media=cdrom` and read-only host file, no Ventoy/EFI map or host USB raw disk. Add a guest-side post-kernel original-init/observer that reads its own optical medium and marker; identify controller and device path from guest evidence, not only QEMU flags.
- **Positive test:** real guest serial/console log shows original EFI boot, kernel handoff and an actual Linux read of optical ISO9660 marker after ExitBootServices; source ISO SHA256 remains identical, guest has no host writable disk. Test logs identify QEMU version, accelerator, guest controller and exact result.
- **Negative test:** missing optical source or read failure causes bounded FAIL, not false PASS; termination leaves host backing unchanged and guest scratch disposable.
- **Output / acceptance:** isolated PoC and CI/QEMU artifact with original guest observation. EFI menu or host-side file existence alone is insufficient.
- **Out of scope:** installer support, KVM performance, emulating bare-metal optical drive, copies of vendor ISOs.

### K-04 — Proxmox VE 9.2-1 guest ISO recognition

- **Status / dependencies:** WAITING K-03 **and safe availability of the genuine original ISO file**; **independent sibling of K-05**.
- **Objective:** make the actual unmodified Proxmox installer pass its own media-ID search using a persistent QEMU optical drive.
- **Steps:** launch original 9.2-1 ISO from mounted filesystem file directly, preferably read-only on already-mounted operator USB; record source digest/provenance, QEMU controller, OVMF/TCG or KVM mode, console and serial. Stop before any real installation. Only add fresh guest disposable target storage if absolutely needed for installer media detection.
- **Positive test:** guest-owned installer observation confirms expected CD/ISO ID recognized and stable progress beyond the old retry countdown; distinguish graphics problems from media recognition.
- **Failure handling:** operator USB unavailable means BLOCKED (not code failure); bootloader-only PASS prohibited; no dependency on TrueNAS.
- **Output / acceptance:** exact vendor version, original-media evidence, QEMU log and media-check result.
- **Out of scope:** writing a host physical disk, full vendor ISO copy, F/M changes, product integration.

### K-05 — TrueNAS SCALE 25.10.7 guest ISO recognition

- **Status / dependencies:** WAITING K-03 and genuine original ISO file; **independent sibling of K-04**.
- **Objective:** make the actual unmodified TrueNAS live/installer environment recognize its optical source in Linux.
- **Steps:** same read-only QEMU backend and isolation; observe native TrueNAS source discovery, record true guest device and media identity; separate framebuffer/graphics tests from actual ISO discovery.
- **Positive test:** guest-owned original initramfs mounts/discovers original medium, reaches a stable observable installer stage, original ISO remains unchanged.
- **Failure handling:** unavailable ISO = BLOCKED; unreadable graphics alone != source media failure; Proxmox failure does not block this test.
- **Output / acceptance:** release-specific evidence and exact state; no claim of actual installation.
- **Out of scope:** vendor patch, new filesystem translation layer, raw USB backing or physical-OS hardware access.

### K-06 — Real KVM accelerator availability on a compatible host

- **Status / dependencies:** WAITING K-02, a confirmed **x86_64 CPU/host with KVM exposed** and K-03 as correctness fixture. **Not dependent on K-04/K-05**; if no suitable host, mark BLOCKED rather than FAIL.
- **Objective:** distinguish real KVM-accelerated guest boot from portable TCG correctness; examine nested virtualization where applicable.
- **Steps:** check CPU/guest architecture, `/dev/kvm`, QEMU accelerator in actual execution; run existing K-03 synthetic correctness case in KVM, then a bounded comparison if comparable resources and media exist.
- **Positive test:** host and QEMU evidence explicitly confirms **KVM engaged**, same ISO recognition/guest markers and no host writes. Record resource consumption and comparable performance only on comparable hardware.
- **Output / acceptance:** KVM-specific evidence, explicit unavailable platforms (ARM64 `vmdev` x86_64 remains TCG).
- **Out of scope:** claiming ARM64 host→x86_64 KVM, substituting pure performance for correctness, provisioning a production virtualization cluster.

### K-07 — Operational isolation and feasibility check

- **Status / dependencies:** WAITING K-03; K-04/K-05 outcomes may be PASS/FAIL/BLOCKED and should be included as available.
- **Objective:** decide whether the guest optical approach is robust as a bounded test facility or eligible for further product evaluation.
- **Steps:** verify ISO file open read-only, no raw USB write path, no direct host disk target, scratch cleanup, QEMU command failure propagation, source disconnect behavior, serial/video observability, memory/time budget, OVMF variables, guest storage/network/pass-through limitations and host bootstrapping feasibility.
- **Positive test:** fault-injection and safe teardown on disposable fixtures; operator journey describes actual host prerequisites and what physical hardware is inaccessible from guest.
- **Output / acceptance:** limitations and safety checklist, actual observed risks, capability matrix.
- **Out of scope:** declaring QEMU boot on USB-only bare metal possible without host OS, automatic product deployment or running installations.

### K-08 — QEMU/KVM evidence report to shared decision

- **Status / dependencies:** K-01, K-03 and K-07; include K-04/K-05/K-06 observed results or explicitly BLOCKED/UNTESTED. Do not wait indefinitely for an unavailable KVM host to summarize valid TCG/guest evidence.
- **Objective:** deliver a comparably structured and bounded decision input to the parent F/M/K architecture comparison.
- **Steps:** report version, ISO digest and media ID, host/guest CPU, real accelerator, firmware, controller, boot milestones, media-check outcome, source integrity, resource cost, applicability to hardware-recovery purpose and unresolved limitations.
- **Output / acceptance:** traceable report distinguishing synthetic guest optical proof, vendor media acceptance, optional KVM acceleration and actual product suitability; the track can finish as diagnostic PoC even if no product pivot is chosen.
- **Out of scope:** implicit change to m-boot product architecture or a claim of bare-metal CD device transparency.

### Sequence and concurrency

```text
K-01 ───────────────────────────────────┐
K-02 → K-03 ──────→ K-07 ───────────────┼→ K-08
          ├────────→ K-04  (vendor evidence, as available)
          └────────→ K-05  (vendor evidence, as available)
K-02 + K-03 + compatible host → K-06 (optional evidence; may stay BLOCKED)
```

K-01/K-02 are independent ready starters; K-04 and K-05 are siblings after K-03, and K-06 is a separate host-capability gate. **No F or M dependency exists**. Each task uses track-owned PoC/workflow/output paths and records exact evidence here.

## Completed

- 2026-11-05: independent workstream split from the global m-boot execution plan to allow concurrent development. No QEMU/KVM implementation, workflow or new test has yet been run as part of this new workstream. The PoC 081/087 baseline from the other track is reference only, not a KVM PASS.

## Current state

Stable operator-addressable task catalog K-01…K-08 established. **K-01 and K-02 are READY immediately**, independent of F/M; K-03 awaits K-02; K-04/K-05 vendor tests are sibling tasks after K-03; K-06 waits for a compatible x86_64 KVM host; K-07/K-08 consolidate only evidence actually obtained. No new QEMU/KVM experiment or real ISO boot is claimed by this planning edit.

## Next action

**K-01** classify guest vs bare-metal use cases, while **K-02** inventories real QEMU/OVMF capabilities independently. Then execute **K-03** genuine synthetic read-only optical guest boot. Do not wait for F/M, real USB or KVM host, and do not start original vendor tests before the K-03 acceptance gate.

## Blockers / open questions

- An operator USB-backed genuine ISO file may not be currently visible on vmdev because its passthrough previously fell to 0B; a synthetic CI K2 test is not blocked by that.
- No verified native x86_64 KVM host is identified for K5; a future host is a dependency for that acceptance, not for K0–K4 TCG.
- Whether an OS running *inside a VM* satisfies the eventual physical recovery/installation goal remains an architectural selection to be made using evidence, not a settled contract.
