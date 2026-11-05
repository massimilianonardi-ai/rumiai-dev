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

## Working design — independent tasks, gates and exit criteria

**K0 — Early feasibility classification (can begin immediately).**
- Inputs: primary m-boot bare-metal goal, guest execution boundary, QEMU official model. Draw a two-column requirement comparison: guest VM tests vs direct host hardware installation/recovery. Output a written non-equivalence and keep the VM path only if useful as a product candidate *or* diagnostic baseline.
- Acceptance: a statement that a virtual optical device persists because the **whole OS is a VM guest**, an explicit host OS/hypervisor prerequisite and unresolved operator-facing use-case questions. Do not promise a 'CD-only KVM' driver.
- Stop/redirect: if a guest OS does not meet the intended bare-metal product use case, finish a **bounded diagnostic-control PoC** and avoid advancing it to product integration without explicit architectural selection.

**K1 — Host/guest and storage capability preflight (independent of K0 design conclusion).**
- Inputs: two environments: inexpensive GitHub-hosted x86_64 QEMU/TCG synthetic test, and optional Ubuntu ARM64 vmdev x86_64/TCG genuine-media test. Potential future native x86_64/KVM host is separate.
- Check actual QEMU version, supported controller and CD-ROM backend, OVMF code/vars pair, serial and display mode, /dev/kvm and CPU architecture only when relevant, host-side available RAM/disk.
- Use an existing real ISO pathname, read-only file access and deterministic firmware settings. Log exact command, QEMU version, host/guest architecture, accelerator, source path fingerprint and exit status. No full ISO hashing on USB unless useful and explicitly bounded (verified vendor hash may be reused when available).
- Exit: a support matrix with missing prerequisites and a command *candidate*, not a successful-boot claim.

**K2 — Independent minimal synthetic optical-boot test (first executable PoC).**
- Reuse existing synthetic UEFI bootable ISO fixtures from current PoCs when possible, keeping its real content and markers. Boot it as QEMU optical medium attached read-only; do not use Ventoy, GRUB loopback or the physical USB as a raw second disk.
- Within the guest, distinguish firmware optical detection, actual EFI loader, original Linux kernel handoff and Linux recognition of the same optical device (e.g. expected ISO9660 and marker). Prove absence of source mutations (unchanged source hash), no guest write target and that guest-only temporary state is discarded. A host-side 'file exists' assertion is not enough.
- FAIL fast on a missing optical device, missing original marker, changed source hash, unobserved guest read or silently writable media.
- Deliverable: a new single-purpose PoC under rumiai-dev-PoCs, one small workflow and log/manifest; do not reuse or alter the firmware-middleware PoC acceptance markers.

**K3 — Original Proxmox on persistent QEMU CD-ROM (independent vendor gate).**
- With a preexisting real ISO file (prefer operator USB without copying; no CI full ISO download), boot the original Proxmox VE 9.2-1 media. Capture the installer ISO ID check and progress past the retry loop observed in direct-USB EFI tests; record stable diagnostics and readable display/serial state.
- Provide a *disposable guest-only* installation target only if needed for media recognition; do not perform installation and never pass a host physical disk writable. If a host ISO is unavailable due to USB passthrough, mark the operator validation as blocked, not failed in the engine.
- FAIL if only the EFI bootloader or vendor kernel launches without the media check PASS.

**K4 — Original TrueNAS on persistent QEMU CD-ROM (parallel to K3 once K2 passes).**
- Same original-image, source hash, backend protections and exit criteria as K3; separate evidence and fixture, without sharing simultaneous writes to the same host disk or output path.
- Ensure a controllable video/serial diagnosis for the previously observed shifted-text problem and avoid treating it as the same failure as missing ISO.
- Stop at stable installer identification, not disk installation.

**K5 — Genuine KVM acceleration on a compatible host (independent of vendor media outcomes).**
- Only on proven x86_64 host/guest compatible with KVM: verify actual accelerator usage rather than assuming /dev/kvm exists. Exercise K2 as a correctness gate first, then a vendor boot if authorized and sufficiently resourced. Record whether nested virtualization is enabled if that host itself is a VM.
- Compare KVM vs TCG speed only under comparable hardware/media/guest conditions; no cross-architecture speed conclusion. TCG can be the independent portability line even when KVM unavailable.

**K6 — Isolation, operations and alternative viability (after K2 and vendor gates).**
- Audit read-only backend, no host block attachment, absence of destructive actions, guest target-disk safeguards, memory/CPU footprint, firmware versions, graceful termination, correct logs and qemu-guest failure status, filesystem read concurrency while ISO file is on ext4, source unplug handling, and limited operator interaction.
- Evaluate whether the product can itself boot/provide the required Linux hypervisor runtime before a guest OS, or whether QEMU/KVM should remain a **test/control alternative**. Do not imply m-boot standalone direct boot and hypervisor VM have equivalent hardware access.
- Deliver a short proposed user journey, unsupported capabilities and boundary/fallback, not an unvalidated integration.

**K7 — Hand off evidence to the shared architecture decision.**
- Report source revision/ISO digest, test host, accelerator, true guest optical/media marker, vendor media-check outcome, resource footprint and limitations. Submit a bounded comparison to handoff/m-boot-standalone.md without duplicating the entire child's active task state.
- This track is independently completable as a validated QEMU optical-media diagnostic/control PoC even if firmware middleware fails. Any product pivot requires a separate explicit selection.

## Completed

- 2026-11-05: independent workstream split from the global m-boot execution plan to allow concurrent development. No QEMU/KVM implementation, workflow or new test has yet been run as part of this new workstream. The PoC 081/087 baseline from the other track is reference only, not a KVM PASS.

## Current state

Planning and ownership are ready. Start with K0/K1 and then the bounded K2 synthetic guest-media test. The K3/K4 real vendor tests are operator-source gated, and K5 requires an actual compatible KVM host. The firmware/middleware work continues independently in the parent handoff.

## Next action

Inspect the existing synthetic ISO fixture and current QEMU runner usage, document the guest-mode/accelerator/support boundary (K0/K1), then implement and test the **smallest** real QEMU read-only optical-media boot PoC (K2) in rumiai-dev-PoCs. Stop and report the first failed gate; do not start product integration.

## Blockers / open questions

- An operator USB-backed genuine ISO file may not be currently visible on vmdev because its passthrough previously fell to 0B; a synthetic CI K2 test is not blocked by that.
- No verified native x86_64 KVM host is identified for K5; a future host is a dependency for that acceptance, not for K0–K4 TCG.
- Whether an OS running *inside a VM* satisfies the eventual physical recovery/installation goal remains an architectural selection to be made using evidence, not a settled contract.
