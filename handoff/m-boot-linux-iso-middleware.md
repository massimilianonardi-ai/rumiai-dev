# m-boot — reusable early-Linux ISO middleware (independent parallel workstream)

Status: Active
Updated: 2026-11-05

## Goal

Build a **reusable early-Linux middleware stage** that consumes the already-demonstrated EFI Runtime Services ISO map, reconstructs an unchanged ISO through a read-only Linux block device and **transfers control to the original OS init**. First validate with synthetic ISO/kernel/initramfs; only after the generic handoff passes assess Proxmox VE 9.2-1 and TrueNAS SCALE 25.10.7 with the fewest necessary existing Ventoy adapters. This stage runs **inside Linux early userspace**, *after* the kernel has booted, not as a magical firmware component that persists after ExitBootServices.

Operational progress and local implementation choices belong here. The parent handoff/m-boot-standalone.md owns firmware producer/handoff validation, the shared comparison and final architecture decision. The independent QEMU/KVM guest optical-media work is owned by handoff/m-boot-qemu-kvm-iso.md.

## Current repository revisions

- Ventoy/m-boot-secondary-uefi: current observed HEAD 475db53dee122887fab3387db47fbb1f09ca71b7 (includes F-owned C consumer safety change f213b86 and later EFI map-size/runner adjustments). The new M-02 QEMU workflow has explicitly tested the pinned F-owned consumer/probe revision f213b860982f540f43d51a296b05768d13587af2, in addition to prior ceff79c evidence; any further changes remain revision-specific and require reconciliation before F/M integration.
- rumiai-dev-PoCs/main: exact latest M-02 work-tree revision `1d8033f28cedde6df91c09269d4250ec14f39009`, **PASS** for the exact PoC 088 QEMU fixture in run `42037354331`; recheck live HEAD before any further write. Revisions/runs remain evidence-specific.
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

## Working design — task registry (stable IDs M-01…M-07)

**Task identity contract:** these are operator-addressable *planning* IDs, not software component/API names. Say `fai M-03` to select exactly one unit. IDs are permanent, never recycled or renumbered; changed scopes are recorded as revisions, and genuinely new work gets the next unused M-number. Any task must start with a fresh repository HEAD/canonical preflight, then synchronize this handoff and report the exact tested revision and evidence. No task in this track owns the firmware map producer or the KVM guest runtime.

**Existing baseline:** genuine QEMU synthetic ISO post-ExitBootServices reconstruction (PoC 081, run 41839593585) PASS; vendor-kernel direct-QEMU appended CPIO (PoC 085, run 41855782625) PASS *only for that separate scope*; early malformed-map refusal (PoC 087, run 42015054609) PASS *only for 13 parser cases*. None is a finished reusable middleware or vendor installer PASS.

### M-01 — Inventory of reusable early-Linux responsibilities

- **Status / dependencies:** **PASS — source/planning acceptance (2026-11-05)**; no new firmware work needed. Input ABI pinned to current `Ventoy@m-boot-secondary-uefi` source until coordinated change at the F/M integration gate.
- **Objective:** inspect `probe-linux-efi-consumer.c`, `build-linux-handoff-initrd.sh`, current `init_chain` and existing Ventoy media hooks; establish the smallest reusable responsibility boundary.
- **Steps:** itemize efivarfs access, map parsing, source GPT discovery, modules, `dmsetup`, device-node creation, ISO9660 mount, identity check, original `/init` transition, teardown and diagnostics. Classify each step as reusable, synthetic fixture, vendor adapter or test harness; mark privilege/module and lifetime assumptions.
- **Output / acceptance:** a concise source-anchored responsibility map and a concrete minimal-change M-02 implementation/test plan; explain precisely which existing code is reused. Source inspection does **not** count as QEMU boot.
- **Out of scope:** new public ABI/namespace, actual middleware refactoring, changes to F-owned C producer, any vendor initramfs rewrite or product integration.

### M-01 source-inventory result — PASS (2026-11-05)

**Evidence boundary:** completed source inspection and an actionable M-02 plan, *not* a new QEMU run, executable test, vendor boot, physical trial or middleware implementation. Inputs pinned to `Ventoy/m-boot-secondary-uefi` `ceff79ca92d246928f86362a569f86c6d2ac130f` and `rumiai-dev-PoCs/main` `cbd5906b5af50c989764dabc9acba48dd5d43dc2`. PoC 081 [run 41839593585](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/41839593585) remains prior synthetic EFI-to-Linux evidence only.

| Concern | Current source-anchored inventory | M-01 classification / reuse boundary |
|---|---|---|
| EFI variable and map ABI | `GRUB2/port/probe-linux-efi-consumer.c:21,122-147` reads fixed efivarfs `VtDmMapProbe`; checks runtime attributes, `VTDMAP01`, chunk bounds, original Ventoy parameter checksum, image size | **Generic consumer logic, reuse unchanged at pinned revision**. Not a new public API; firmware producer and format belong to F |
| Source identification and extents | Same C source `:60-100,149-195` enumerates disk devices; requires a unique matching primary GPT disk GUID and whole-disk byte size; checks partition sysfs start, chunk continuity and GPT partition bounds; emits a `dm-linear` table | **Generic consumer logic**. Requires privileged guest, real kernel block device and GPT. Does *not* currently prove GPT CRC, every arithmetic overflow, hostile-variable authenticity or source races; F-02 owns broader safety realignment |
| Kernel and binary dependencies | `GRUB2/port/build-linux-handoff-initrd.sh:9-109` selects actual Ubuntu kernel/matching modules, builds static C consumer, bundles BusyBox, dmsetup with its ELF closure, and module dependencies for virtio, device mapper, ISO9660 and efivarfs | **Synthetic fixture/build harness**. Reuse for controlled M-02 guest, not an arbitrary vendor module/runtime contract |
| Mounted early Linux and mapper | Same build script `:111-154` mounts proc, sys, devtmpfs, efivarfs; loads real modules; calls C consumer; creates `dmsetup --readonly`, resolves named mapper through `/sys/block/dm-*/dm/name` and major/minor rather than assuming `dm-0`; mounts ISO9660 with `-o ro` | **Reusable generic guest stage to isolate in M-02**. Root/CAP_SYS_ADMIN, available efivarfs/EFI Runtime Services, matching kernel modules and device-mapper support are prerequisites |
| Identity assertion | Same build script `:149-159` hashes mapped device and compares a fixed `.pve-cd-id.txt` marker string; PoC 081 separately asserts unchanged source ISO digest and marker | **Test fixture only**. Keep marker and expected source hash in test assertions, never in generic stage or vendor policy |
| Lifecycle and original init | Same build script `:160-161` forces poweroff on success and never hands over. `IMG/cpio/ventoy/init:40-65` dispatches to `init_chain`; `init_chain:23-238` unpacks original image and calls `ventoy_chain.sh`, whose `:476-511` executes detected real init or switch_root | **M-03 responsibility**, not achieved by M-02. Existing Ventoy init-chain is reference for lifecycle, not a ready-made portable handoff; preserve mounted /dev and ISO across any later transition |
| Proxmox and TrueNAS discovery | `hook/debian/pve-hook.sh:20-26` rewrites real init media-device scanning and `pve-disk.sh:21-44` activates Ventoy disk hook. `truenas-hook.sh:20-27` inserts mountroot/live-media hooks; `truenas-disk.sh:24-53` uses vtoydm/FUSE ISO and mount | **Vendor adapters**; only M-05/M-06 after generic success and observed release-specific need. Their FUSE/directive approach is not the M-02 generic device mapper |
| Teardown/diagnostics | Consumer emits specific `VT_LINUX_HANDOFF_ERROR` causes; build script has phase-specific `VT_LINUX_*_FAILED` markers. Fixture powers off and does not handle normal resource teardown. Consumer can leave a partial output table on an error; current caller checks nonzero return before `dmsetup` | **M-02 stage obligation**: require successful consumer exit before use; fail closed, clean any owned mount/mapping on error and report distinct guest phases. Do not edit F-owned C merely for convenience |

**Minimal M-02 design and test sequence (not executed under M-01):**

1. Create an **M-track-only** isolated PoC directory/workflow, separate from F/K. Pin the current C consumer, original PoC 081 EFI producer/virtual-ISO pathway and exact kernel/fixture provenance. Reuse existing compilation, module/dependency closure and QEMU runner inputs rather than cloning a competing EFI parser or modifying the fork, `m-boot/main` or GRUB core.
2. Extract *only* the proc/sys/dev/efivarfs → modules → C table → read-only dm → stable device discovery → read-only ISO9660 mount sequence from the existing guest `/init` into a private reusable stage. Report actual mapped device/mount and explicit failure to the caller. Move hard-coded identity marker, independently expected digest and `poweroff` to the **test harness**; do not invent a public API or implement original-init handoff early.
3. Validate with **real disposable QEMU/OVMF guest boot** using the pinned existing EFI map/unchanged Linux kernel and a synthetic source-backed GPT ISO. Require independent guest-phase logs for successful map, mapper/device, ISO mount and content read, plus source ISO hash unchanged before/after. Do not count host grep, EFI menu or the old PoC 081 run as an M-02 PASS.
4. Exercise bounded real negative cases for absent/malformed variable, unavailable/ambiguous GPT source, missing module/device-mapper, wrong mapping or ISO read/mount failure. Observe no unintended mapped source, no fallback and cleanup of stage-owned resources. Use **only disposable virtual disks**, not host /dev, real USB or vendor installation media. Comprehensive GPT/CRC hardening stays in F-02.
5. Stop at **generic read-only exposure**. M-03 separately proves an *independent* original init can still read the ISO after process handoff; M-04 separately joins the firmware F-05 gate. Neither successor is authorized by a request for M-01 alone.


### M-02 — Generic read-only ISO reconstruction stage

- **Status / dependencies:** **IN_PROGRESS (implementation committed; authentic QEMU validation still running, no M-02 PASS yet)**; M-01 PASS. May run concurrently with F-02/F-03. Consume pinned already-PASS EFI producer map; F hardening completion is **not** a precondition for this isolated implementation.
- **Objective:** extract the existing Linux-side behavior into a bounded generic early-userspace stage, separately from PoC 081's synthetic `.pve-cd-id.txt` and unconditional `poweroff`.
- **Steps:** require trustworthy variable/identity checks already present, load matching kernel modules, detect the unique physical GPT source, create only read-only `dm-linear`, resolve stable device identity, mount ISO9660 read-only and expose a clear success/failure result to the caller. Use current source, avoid rewriting existing parser wholesale.
- **Positive test:** in real disposable QEMU Linux guest, unchanged synthetic ISO bytes/hash and marker, matching dm device and mount; distinct serial assertions for variable parsing, source discovery, device creation, read and mount. No success solely from host-side grep.
- **Negative tests:** missing variable, corrupted/ambiguous map, wrong disk, unavailable modules/device-mapper, read failure; no wrong device mounted, no silent fallback and no host disk access.
- **Output / acceptance:** isolated reusable code + CI log and manifest in track-owned PoC paths. Only a demonstrated guest mount passes.
- **Out of scope:** calling vendor original `/init`, injecting into ISO EFI loader, vendor-specific hooks, physical USB testing, writable host disk passthrough.

### M-02 implementation checkpoint (2026-11-05; not yet accepted)

- **PoC source:** [PoC 088](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/tree/main/pocs/088-m-boot-linux-generic-iso) contains `iso-stage.sh`, `guest-init.sh`, and scope/evidence README. Standalone [workflow](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/blob/main/.github/workflows/poc-088-m-boot-linux-generic-iso.yml) reuses the unchanged PoC 079 ISO/kernel and actual Ventoy EFI→Linux pipeline only on disposable GPT/QEMU media; the most recent task-local PoC revision is `1d8033f28cedde6df91c09269d4250ec14f39009` (duplicate-source-GPT guest check + CI + README).
- **Code boundary:** private early-guest preparation and cleanup; preserve the original compiled consumer; load matching kernel modules, require complete successful map before DM creation, check read-only kernel mapper flag, resolve sysfs block ID, mount ISO9660 with `-o ro`, clean stage-owned mapping/mount on failure. Test-only init checks marker/hash and powers off. Original vendor init handoff remains exclusively M-03.
- **Revision-specific CI:** [run 42033219716](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42033219716) PASS at `1529c173` for genuine guest ISO mount/hash and missing consumer/module-manifest negatives. [Run 42034161509](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42034161509) PASS at `78d58818` using tightened F-owned C consumer `f213b86` and genuine guest absent/corrupted EFI-variable and dmsetup refusal paths. [Run 42034889201](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42034889201) PASS at `7f1ab91a` for temporarily hidden disposable source disk/partition nodes with no fallback mapper. All are **specific exercised subcases**, not full M-02 PASS. The run [42035884712](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42035884712) **FAILED at the new ISO-corruption fixture** (`M02_GUEST_FAILURE_INVALID_ISO9660_MOUNT_ACCEPTED`): writing only one PVD descriptor did not invalidate the ISO; all preceding genuine guest checks and other negatives passed. The fixture was corrected at `c26a0b03`, which verified the `CD001` offset and invalidated the full descriptor region **only inside disposable QEMU `-snapshot`**. [Run 42036476622](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42036476622) **PASS at exact revision `c26a0b03`**, including `M02_NEGATIVE_ISO9660_MOUNT_ERROR_PASS`, full original/reconstructed SHA256 equality and `M02_REAL_QEMU_GUEST_READONLY_MOUNT_PASS`. A distinct duplicate-GPT source identity negative was subsequently added in `d6c38221`, workflow requirement `ba2a04f4`, and README `1d8033f2`; [run 42037354331](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42037354331) **PASS** at exact PoCs revision `1d8033f28cedde6df91c09269d4250ec14f39009`, including the duplicate-primary-GPT-source-GUID refusal, negative ISO9660 mount case, real read-only mapper/ISO mount, original source digest equality and final `M02_REAL_QEMU_GUEST_READONLY_MOUNT_PASS`. This test deliberately changes only the second **virtual** disk's primary GPT header under QEMU `-snapshot` then restores it; do not claim complete backup-GPT consistency, real physical disk duplication or portable kernel-driver behavior.
- **Important unfinished negative matrix:** duplicate primary GPT GUID selection has now been tested in a genuine disposable QEMU guest (run `42037354331`); genuine kernel driver absence, QEMU hot-unplug after EFI/physical media loss and actual block I/O error (EIO) remain **NOT_TESTED**. The completed snapshot PVD-corruption case demonstrates guest ISO9660 mount refusal and cleanup, **not** EIO. PoC 087 parser-only results are not a substitute for guest/physical safety. Do not promote M-02 overall to PASS until its remaining required acceptance is reconciled or explicitly bounded by owning contract.
- **Parallel F-owned input change:** Ventoy advanced from `ceff79c` to `f213b86` with tightened GPT header/partition CRC/extent validation; this exact revised consumer has now passed the M-02 guest synthetic positive path at `78d58818`. Later F-owned commits change the producer's chunk-count limit and probe runner but not that consumer's blob; their exact revision is not silently credited. M-04 still requires F-05 conformance.

### M-03 — Control transfer to an independent original init

- **Status / dependencies:** WAITING M-02; independent from remaining F hardening and from all K tasks.
- **Objective:** show that early Linux middleware runs first and then a **distinct original next-stage** `/init` executes with the reconstructed ISO still available.
- **Steps:** create a small test early userspace where independently authored next-stage init verifies expected ISO marker, `/dev` node and mounted media. Implement required mount namespace, devtmpfs/udev, `/proc`/`/sys` and lifecycle handling without assuming `dm-0`. Test process handoff/exit/error propagation and explicit cleanup.
- **Positive test:** actual guest console shows unique middleware-before-handoff marker, next-stage-original-init marker emitted only by that original init, and an **independent** original-init read of the ISO contents/hash.
- **Negative test:** corrupt map or vanished medium prevents next-stage execution with a specific error; no false PASS from a middleware-authored marker.
- **Output / acceptance:** exact QEMU command/build revision/log, complete original-init lifecycle observation with unchanged ISO.
- **Out of scope:** vendor Proxmox/TrueNAS bootloaders, EFI file shadow or general adapter support.

### M-04 — Integration of middleware into original EFI ISO boot

- **Status / dependencies:** WAITING M-03 **AND F-05** (the sole hard F/M join); no prerequisite from K.
- **Objective:** traverse **original EFI ISO loader → original unchanged kernel → injected early Linux middleware → reconstructed ISO → original next-stage init**, rather than direct QEMU `-kernel` substitution.
- **Steps:** reuse PoC 080 EFI file-shadow and PoC 085 aligned append-only CPIO evidence where applicable; check actual loader file access; lift existing tiny-overlay size limits for larger real initrds only when required, with bounded memory/disk. Preserve original ISO and original initrd **prefix bytes**, reconcile EFI variable source and map limits, no Secure Boot bypass.
- **Positive test:** real QEMU/OVMF guest reports each stage through independent markers, full unchanged-source SHA-256/identity, original-init ISO read and no host storage writes. A successful EFI boot *without* Linux remount is FAIL.
- **Negative/regression test:** original init not replaced unexpectedly; source identity mismatch/memory/size bound rejects; standard Ventoy behavior remains separately validated where the code overlaps.
- **Output / acceptance:** version-pinned integrated PoC, real QEMU trace and evidence for entire chain.
- **Out of scope:** claiming unmodified vendor installer success, bare-metal product integration or cross-architecture support.

### M-05 — Proxmox VE 9.2-1 vendor media acceptance

- **Status / dependencies:** WAITING M-04. **Independent sibling of M-06**; no requirement to finish M-06.
- **Objective:** prove that Proxmox's original installer, reached through the original ISO's EFI path, recognizes the real ISO9660 support and its actual media ID.
- **Steps:** use original Proxmox 9.2-1 kernel/initrd and vendor-owned media lookup; first try the unmodified generic middleware; only on observed incompatibility inspect and reuse the minimal current Ventoy `pve-hook.sh` / `pve-disk.sh` behavior. Preserve original ISO/bootloader/kernel bytes.
- **Positive test:** original Proxmox log or observable guest behavior confirms ID acceptance and stable progression **past the previous retry/countdown**. Capture exact source ID/hash, path, actual device/mount, serial and graphics separately.
- **Failure handling:** missing original image = BLOCKED (not implementation FAIL); vendor rejecting `dm*` = scoped adapter evidence. One vendor failure never blocks independent M-06/K tests.
- **Output / acceptance:** isolated PoC/log plus result specific to this exact installer release, not generic Linux compatibility.
- **Out of scope:** running installer onto a real host disk, copying multi-GB original ISO, per-release wholesale initramfs rewrite, changing guest firmware design.

### M-06 — TrueNAS SCALE 25.10.7 vendor media acceptance

- **Status / dependencies:** WAITING M-04. **Independent sibling of M-05**, eligible to run in parallel.
- **Objective:** prove original TrueNAS installer discovers its source filesystem after the Linux transition, instead of treating EFI entry or framebuffer progress as success.
- **Steps:** use original TrueNAS kernel/initrd/live-boot scripts; first generic middleware; only if real `live-boot` media discovery fails, inspect/adapt existing Ventoy `truenas-disk.sh` / FUSE behavior where needed. Keep guest video diagnostics separate from medium identity.
- **Positive test:** actual original TrueNAS source-discovery path finds/mounts the expected media and reaches a stable, observable installer stage; retain original ISO checksum and readable serial/graphics logs where possible.
- **Failure handling:** graphical corruption does not prove failure unless guest state/log corroborates; missing ISO = BLOCKED. No dependency on Proxmox test.
- **Output / acceptance:** isolated release-specific PoC/log and media identity result.
- **Out of scope:** installation, arbitrary TrueNAS releases, physical hardware claims, large copy or custom OS kernel.

### M-07 — Adapter policy, regression and evidence handoff

- **Status / dependencies:** results of M-05 and M-06, each of which may be PASS, FAIL or BLOCKED; reports can explicitly record partial coverage. No automatic requirement that both pass.
- **Objective:** determine whether generic middleware plus a few existing framework-level hooks is maintainable compared with stock Ventoy, GRUB loopback and K guest optical solution.
- **Steps:** measure adapter footprint and coverage by **actual initramfs/media-lookup mechanism**, not distro name alone; run proportionate synthetic/source-error regression and standard Ventoy regression only on changed surfaces; record missing EFI runtime, oversized fragmentation, source detach and original-init preservation. Apply adapter-growth stop criterion.
- **Output / acceptance:** compact comparative table and supported/rejected/unknown release list with exact evidence, blockers, cost and regression status; send only cross-track decision evidence to parent.
- **Out of scope:** automatic product promotion, unbounded vendor-specific patches or claiming hardware support without physical tests.

### Internal sequence and parallel safety

```text
M-01 → M-02 → M-03 ─┐
                    ├→ M-04 → { M-05 || M-06 } → M-07
F-05 (parent) ──────┘
```

A blocked M-05 must not stop M-06, and K is completely independent. New child PoC code/workflow lives under a separate track-owned path from F and K. No shared writable outputs. IDs are frozen; updates happen in this handoff only, with parent retaining the short public index.

## Completed

- Prior factual baseline (not newly performed in this workstream): PoC 081 authentic QEMU/OVMF synthetic ISO → EFI variable → unchanged Ubuntu kernel → read-only dm-linear + ISO9660 + media ID PASS (run 41839593585). PoC 085 direct QEMU kernel/append-only vendor CPIO PASS (run 41855782625), but **not** EFI integrated vendor boot. PoC 087 malformed-variable original C consumer 13/13 early rejection PASS (run 42015054609), not GPT/physical bounds.
- 2026-11-05: separated this self-contained middleware task from broader m-boot handoff so implementation can proceed concurrently with firmware and QEMU/KVM, while retaining shared input ABI as the only hard join point.
- 2026-11-05: completed **M-01 PASS (source inventory/planning)** at the pinned Ventoy/PoCs revisions and recorded the minimal M-02 implementation and validation path.
- 2026-11-05: implemented private M-02 stage/fixture/workflow in PoC 088 with forward-only PoCs commits. Actual QEMU PASS at `42033219716`, `42034161509`, `42034889201`, `42036476622` and **final expanded current PoC 088 run `42037354331`** at `1d8033f2` proves unchanged original ISO digest, guest dm-linear/ISO9660 mount, stage cleanup and the tested missing prerequisites/map, ambiguous source-GPT, vanished disposable block node and invalid ISO9660 cases. The first one-descriptor PVD corruption fixture failure (`46642e40`) was diagnosed, fixed forward-only (`c26a0b03`) and independently validated before the expanded run. True block EIO, source detach and kernel-driver absence remain NOT_TESTED; task is not fully accepted.

## Current state

Task registry M-01…M-07 is now stable for operator addressing. M-01 is **PASS (source inventory)**; M-02 is **IN_PROGRESS** (PoC 088 positive/negative tests PASS for exact `1d8033f2` in real QEMU, including primary-GPT source ambiguity and ISO9660 mount refusal; genuine EIO/hot-unplug and kernel-driver unavailability remain untested); M-03 is **WAITING M-02**; both retain pinned PoC 081 input evidence; M-04 alone waits for F-05 firmware gate; M-05 and M-06 are sibling vendor work units; M-07 compares evidence. Real QEMU/OVMF positive media-mount and several fail-closed subcases are PASS at their listed exact PoCs revisions. No **full M-02 acceptance**, vendor, original-init handoff or designated reference-host physical PASS is claimed; true I/O/media-loss/kernel-absence negative matrix remains pending; the primary-GPT collision test has passed.

## Next action

**M-02 (IN_PROGRESS):** preserve the exact PASS on [QEMU run 42037354331](https://github.com/massimilianonardi-ai/rumiai-dev-PoCs/actions/runs/42037354331) (`1d8033f2`), and next exercise real missing-kernel-feature/device-mapper, source loss or block read EIO at the guest level when a safe disposable QEMU fault mechanism exists. Keep F-owned media-loss/EFI runtime hardening in F-04 and avoid duplicate unrelated F work. Do not mark full M-02 PASS or begin M-03 until required negative acceptance and evidence boundaries have been explicitly reconciled. Synchronize revision-specific evidence and do not start M-03 automatically. Sole hard firmware join remains M-04 ↔ F-05.

## Blockers / open questions

- The experimental producer/consumer format is not a promoted public API. M-02 has now separately tested both prior `ceff79c` and hardened `f213b86` source revisions; newer F producer/probe changes have not all been exercised by M-02. Keep tests revision-specific until F-05 conformance joins the tracks.
- Method of preserving mounted ISO and device access across the original OS init/switch_root requires empirical M-03 proof; do not assume that creating dm device alone is sufficient.
- Existing 64 KiB EFI-sidecar limitation vs genuine vendor initrd sizes is an explicit M-04 gate, not a reason to preemptively construct per-product initramfs.
- Secure Boot, BIOS/ARM64 and generalized install frameworks are outside M1 baseline; they are conditional future gates in the broader parent decision.
