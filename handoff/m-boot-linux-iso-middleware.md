# m-boot — reusable early-Linux ISO middleware (independent parallel workstream)

Status: Active
Updated: 2026-11-05

## Goal

Build a **reusable early-Linux middleware stage** that consumes the already-demonstrated EFI Runtime Services ISO map, reconstructs an unchanged ISO through a read-only Linux block device and **transfers control to the original OS init**. First validate with synthetic ISO/kernel/initramfs; only after the generic handoff passes assess Proxmox VE 9.2-1 and TrueNAS SCALE 25.10.7 with the fewest necessary existing Ventoy adapters. This stage runs **inside Linux early userspace**, *after* the kernel has booted, not as a magical firmware component that persists after ExitBootServices.

Operational progress and local implementation choices belong here. The parent handoff/m-boot-standalone.md owns firmware producer/handoff validation, the shared comparison and final architecture decision. The independent QEMU/KVM guest optical-media work is owned by handoff/m-boot-qemu-kvm-iso.md.

## Current repository revisions

- Ventoy/m-boot-secondary-uefi: ceff79ca92d246928f86362a569f86c6d2ac130f (consumer implementation and PoC 081 pinned interface; recheck live HEAD).
- rumiai-dev-PoCs/main: cbd5906b5af50c989764dabc9acba48dd5d43dc2 (PoCs 080/081/085/087, future middleware code lives under its own non-colliding path; recheck HEAD).
- m-boot/main: c06cd35a73b7e420c3a06dc51537c028ffa619d0 (no authorized product modification).
- rumiai-dev/main: recheck live HEAD; this handoff's relationship owner is parent.

## Applicable canonical sources

rumiai-dev/README.md, RULES.md, CONSISTENCY-GATE.md, specifications/README.md, TESTING.md, RUNNER.md, PHYSICAL-TESTING.md, TEST-PATTERNS.md, handoff/README.md and handoff/m-boot-standalone.md.

Implementation baseline: experimental Ventoy GRUB2/port/probe-linux-efi-consumer.c, build-linux-handoff-initrd.sh, probe-standalone-uefi.sh; original IMG/cpio/ventoy/init_chain, IMG/cpio/ventoy/hook/debian/pve-hook.sh and truenas-disk.sh. PoC evidence: rumiai-dev-PoCs/pocs/079-, 080-, 081-, 085- and 087- paths and associated CI.

## Fixed task-local choices

- **Run concurrently** with firmware F3 negative/fragmented tests and independent QEMU/KVM; do not wait for all firmware hardening before beginning. Consume the unchanged, revision-pinned **existing** VtDmMapProbe variable format as an experimental interface. Do not invent a public API/namespace/version or silently alter the firmware producer. Freeze that input shape for the initial middleware prototype; reconcile forward before integration if firmware changes.
- Work in isolated PoC paths and CI workflows distinct from firmware and QEMU/KVM. No concurrent writes to the same C producer/consumer or global test fixture. A later integration into Ventoy experimental branch requires explicit coordination with parent; preserve master, m-boot/main and GRUB core.
- Keep original kernel and ISO unchanged. The middleware is early-userspace code that can be provided in an **external** test initramfs layer/virtual EFI file-shadow, not a wholesale rebuilt ISO or bespoke distribution image. Existing append-only aligned CPIO evidence PoC 085 is a candidate, not a blanket proof for EFI boot with full vendor initrds.
- Read-only ISO mapping only; identify physical source by GPT GUID/actual size; verify partition bounds, extent coverage, duplicate/ambiguous disks and media identity. If any check fails, fail closed before mounting an arbitrary host device. Evidence of checksums is not a proof of trust/authenticity of hostile firmware variables.
- Separate generic filesystem exposure from product-specific installer discovery. Only after generic success may existing Ventoy hooks be adapted, and those adapters should map to **actual early-boot frameworks / media-lookup behavior**, not a guessed Linux distribution label.
- Operator physical-USB test blocked until new real-media candidate and safe passthrough; no further raw USB manipulation merely to test basic middleware. No full vendor ISO copy, GUI work, Docker, forced installation or physical writes.

## Acceptance scenarios

1. The original EFI ISO loader hands the unchanged kernel a valid map. The middleware recognizes the physical source, exposes the complete original ISO read-only and mounts it; its media marker, SHA256 and mounted files agree with the untouched source.
2. With an independently identifiable **original next-stage init** (not a fake marker inside middleware), the middleware passes control to it after preparing the device and does not lose required mounts, /dev nodes, environment or access to the original ISO.
3. A corrupt/ambiguous map or missing kernel support cannot cause a mounted wrong device or silent fallback. Distinct errors are observable in guest serial evidence, and no write is attempted.
4. On original Proxmox/TrueNAS media, the guest's **own real media-check logic** accepts the reconstructed support and progresses beyond the earlier failures. EFI-only boot or dmsetup alone is not vendor success.

## Working design — granular work units

**M0 — Baseline inventory (independent, start immediately).**
- Read existing consumer C and initramfs builder as the only source of mechanics. Enumerate phases: efivarfs mounting, map parsing, disk/partition lookup, modules, dmsetup read-only mapping, /dev node creation, ISO9660 mount/identity verification, init control transfer, cleanup, diagnostics.
- Classify each existing line as generic runtime, fixture-only marker/check, OS-specific adaptation, or test harness. Record assumptions, privileges, kernel modules, memory footprint and current failure paths without designing new abstractions.
- Output responsibility map and a minimal-change proposal; NO implementation claim before a real test.

**M1 — Reusable, isolated middleware core (depends only on pinned map reader, can run alongside F3).**
- Use the real existing consumer and shell machinery. Separate it from the PoC 081 fixture-specific .pve-cd-id.txt value and hardcoded poweroff. Do not create new public command names; if packaging needs an internal executable, verify ownership and naming contract first.
- Parameterize only what the guest needs at boot, avoiding assumptions about /dev/vdb, dm-0, USB GPT p3 or one specific ISO path. Support bounded error diagnostics for missing efivarfs/modules, partition mismatch, incomplete extents, read failure and impossible mount.
- Test in disposable guest with the existing synthetic ISO; verify original bytes/hash and read-only remount. Product-specific adaptation remains absent.
- Exit: a smoke result that explicitly distinguishes parser success, dm device creation, read-only ISO9660 mount and identity. Document test-only assertions separately.

**M2 — Original init handoff (depends on M1 only).**
- Construct a synthetic two-stage initramfs with an original next-stage init that independently checks that the ISO device and mount are present, then reports a unique marker. The middleware must invoke the actual original next stage, not print its marker itself.
- Handle mount namespace inheritance, devtmpfs/udev and device node lifetime, /sys and /proc availability, signal/error propagation, root transition/switch_root when necessary; verify that teardown does not remove the medium before it is consumed.
- Negative paths require no handoff to original init and no arbitrary disk access.
- Exit: actual QEMU kernel execution of middleware followed by original init with surviving read-only media, log markers separately for each stage. Source ISO unchanged.

**M3 — EFI delivery of the middleware into a stock original ISO boot (join with parent firmware on a pinned, successful interface).**
- Reuse PoC 080 native EFI file-shadow and PoC 085 append-only/aligned CPIO observations, but verify the *combined* original EFI GRUB → unchanged vendor/kernel → injected early-userspace stage → original init path.
- Test shadow/extents beyond PoC 080's small probe, including real 39–56 MiB initrd prefixes only when source retrieval can be bounded; explicitly validate checksum and exact original prefix identity. An appended CPIO alone is not proof that existing EFI loader reads the injected bytes.
- Exit: QEMU/OVMF actual guest execution with unique firmware map, Linux ISO mount and original-init markers; no full vendor ISO copies or physical media. If EFI packaging conflicts with Secure Boot/signatures, declare a conditional limit rather than bypassing silently.

**M4 — Proxmox and TrueNAS *independent sibling vendor gates* (both depend on M3; run concurrently where resources permit).**
- Proxmox: exact 9.2-1 original GRUB/kernel/initrd/media ID. Try generic middleware first, then inspect the real loader's media check and reuse the smallest available Ventoy pve-hook.sh behavior if required. PASS only when original installer recognizes its own ISO and progresses beyond the prior ID retry loop.
- TrueNAS: exact 25.10.7 original GRUB/kernel/initrd and live-boot source lookup. Try generic middleware first, then reuse existing truenas-disk.sh/FUSE adapter if necessary. PASS only when its original media-recognition path succeeds and readable stable boot evidence exists.
- Each keeps separate CI/logs/evidence and cannot block the other. A failure in one vendor does not cancel the other's independent test.

**M5 — Bounded adapter policy and regression decision.**
- For every adapter, record which actual initramfs framework/media-check behavior needs intervention, how many lines of existing Ventoy code are reused, signatures, kernel-module requirements and versions validated.
- Apply a strict *evaluation trigger* if compatibility starts requiring a distinct whole-initramfs replacement for each vendor/release: stop incremental patching and compare stock Ventoy/GRUB loopback and the QEMU guest optical path. The trigger is provisional evaluation policy, not a claim every Linux installer shares one framework.
- Include negative regression of original Linux /init, stock Ventoy boot, no EFI variable, media removal and too-many-fragment extent paths before any m-boot integration.
- Exit: an evidence-backed recommendation about generic middleware plus family-level adapters, **not** an automatic production rollout.

## Completed

- Prior factual baseline (not newly performed in this workstream): PoC 081 authentic QEMU/OVMF synthetic ISO → EFI variable → unchanged Ubuntu kernel → read-only dm-linear + ISO9660 + media ID PASS (run 41839593585). PoC 085 direct QEMU kernel/append-only vendor CPIO PASS (run 41855782625), but **not** EFI integrated vendor boot. PoC 087 malformed-variable original C consumer 13/13 early rejection PASS (run 42015054609), not GPT/physical bounds.
- 2026-11-05: separated this self-contained middleware task from broader m-boot handoff so implementation can proceed concurrently with firmware and QEMU/KVM, while retaining shared input ABI as the only hard join point. No middleware code or new validation run has been completed under this new workstream yet.

## Current state

M0 and M1 can start immediately from the pinned consumer; F3 physical extent hardening and QEMU/KVM work are independent. M3 is the **first** firmware/consumer join gate, while M4 vendor cases are independent of each other after M3. No new vendor installer result is claimed.

## Next action

Perform M0 current-source responsibility inventory, then create one minimal isolated M1 PoC in rumiai-dev-PoCs that reuses the actual consumer, reconstructs a synthetic ISO read-only and removes fixture-specific behavior from the reusable stage. Validate real QEMU guest execution; do not start vendor adapters.

## Blockers / open questions

- Experimental producer/consumer interface is not a stable public contract. Preserve exact pinned data shape until concurrent firmware work is reconciled.
- Method of preserving mounted ISO and device access across the original OS init/switch_root requires empirical M2 proof; do not assume that creating dm device alone is sufficient.
- Existing 64 KiB EFI-sidecar limitation vs genuine vendor initrd sizes is an explicit M3 gate, not a reason to preemptively construct per-product initramfs.
- Secure Boot, BIOS/ARM64 and generalized install frameworks are outside M1 baseline; they are conditional future gates in the broader parent decision.
