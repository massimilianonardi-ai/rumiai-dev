# m-boot standalone Linux build and bootable-media development

Status: Active
Updated: 2026-10-29

## Goal

Evolve the historically field-used `m-boot` into a standalone, reusable multiboot medium focused primarily on recovery, backup and OS installation: prepare a suitable disk/USB drive once, then add/remove bootable ISO images and other supported payloads by ordinary file copy from compatible hosts, without repeatedly flashing devices, recreating media or requiring host-side privileged imaging tools for each payload. The product builds on Linux x86_64/ARM64 and targets applicable x86_64 BIOS, x86_64 UEFI and ARM64 UEFI machines. Integration into `m` is not a current dependency.

## Current repository revisions

- `massimilianonardi-ai/m-boot` main: `94bb7d69c43f1cc7e1c482ccb2e583756def7c72`
- `massimilianonardi-ai/rumiai-dev` main (before this handoff checkpoint): `c87571939dee8143a5a17240ddb0bb5eb3ff4805`

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `specifications/README.md`
- `TESTING.md`
- `handoff/README.md`

There is no current `m-boot` subsystem specification routed from `specifications/README.md`; retain task-local design here until promoted after implementation decisions settle.

## Fixed task-local choices

- Preserve and understand the historically successful GRUB runtime and its important features instead of replacing the model wholesale; historical production use is user-confirmed, though bugs remain.
- Keep `loader/bootstrap-memdisk.sh` as the minimal embedded GRUB `-c` configuration (`normal (memdisk)/init`); keep the GRUB `init` script as a separate file inside the embedded `-m` memdisk. This is a user-agreed design choice, not evidence of ARM64 or new-host validation.
- Build-time policy selection for the embedded `(memdisk)/init`: use a flexible init for test, variable or recovery-oriented environments (try the firmware boot device then discover an external m-loader across devices), or a constrained init for production/fixed-device installations (select by the build-chosen identifier such as filesystem UUID or label, and fail that selection without falling back to unrestricted loader search). These are distinct built init implementations, not runtime policy branches embedded together in every bootloader. The fixed selector is a location constraint, not in itself cryptographic authentication.
- The embedded init is only responsible for locating and transferring control to an external m-loader or entering its explicitly intended failure/recovery path. The external m-loader is responsible for discovering available bootable devices/operating systems and selecting or delegating to other m-loader installations or versions; an older supported loader must remain able to delegate to another version. Multiple m-loader installations are normal for this design, not a functional ambiguity for the initial flexible bootstrap.
- Minimal embedded GRUB recovery is required when no external m-loader is available or it returns a handled error: retain the native GRUB command line via `c`, a no-timeout text menu for retry and basic inspection, plus reboot/shutdown. It must run independently of the external data filesystem, and does not itself modify storage. A Linux repair/rescue environment is outside this minimal GRUB recovery responsibility.
- Eliminate the Cygwin/Windows-oriented build assumption: the supported build hosts are Linux x86_64 and Linux ARM64.
- The product must currently build, install and run standalone, with no `m`, `mk` or RumiAI environment dependency. Integration into `m` is future work, not a blocker or prerequisite.
- Target boot platforms are x86_64 with legacy BIOS, x86_64 with UEFI and ARM64 with UEFI. Legacy PC BIOS is not an ARM64 platform.
- Target storage includes internal and external devices (e.g. USB, Thunderbolt), subject to firmware preboot-device enumeration and platform-specific firmware limitations.
- Build-host architecture, GRUB boot target and installation-media/device selection are separate concerns.
- The priority end-user workflow is a persistent bootable external/internal medium with a FAT32 EFI System Partition and a separate exFAT data partition holding the loader, ISO files, recovery/backup tools and optional OS-container files. Once provisioned, ordinary addition/removal of supported ISO files must not require reformatting, image flashing, privileged `dd`, or reinstalling the bootloader. Provisioning the medium initially remains an explicitly selected, safety-gated operation. UEFI firmware reads its FAT32 ESP; GRUB must itself provide exFAT filesystem support for data access. BIOS support on GPT may additionally require a BIOS Boot Partition; do not falsely promise a universal BIOS+UEFI two-partition layout.
- Prioritize recovery, backup and OS installation over advanced cryptographic/security features in the present phase. Security, signatures, disk encryption, trust chains and similar enhancements are future work, not current prerequisites; preserve basic data/device safety, no accidental disk overwrite and accurate warning/selection of destructive targets.
- `NaVi` is expressly deferred beyond this phase because it requires substantial Linux initramfs work; the separate, currently inactive `todo/m-boot-navi.md` records that future work. Do not develop or validate NaVi as part of current GRUB recovery, multiboot, device inspection, ISO boot or chainloading work.
- ISO copy-and-boot must be validated per OS/image family rather than promised for every arbitrary ISO: GRUB loopback can open accessible images, but the target OS/initramfs must be able to locate its remaining files; preserve and modernize existing ISO boot recipes. Installation/recovery tools and the files copied from an external host are distinct from one-time device preparation.
- Do not automatically partition/format disks or overwrite existing bootloaders as a side effect of routine build or install workflows. Follow forward-only Git and preserve concurrent changes.

## Acceptance scenarios

1. On a supported Linux x86_64 or ARM64 development host, an operator uses standalone project tools to build the supported BIOS/UEFI images with the requisite target GRUB modules; missing toolchains or modules are diagnosed explicitly rather than silently skipped.
2. An operator prepares an explicitly selected existing target storage device and installs a bootable x86_64 UEFI or ARM64 UEFI fallback image without requiring `m` or firmware NVRAM registration. Existing unrelated files and bootloaders are preserved unless deliberate replacement was selected.
3. An operator installs the x86_64 BIOS boot path on an explicitly selected compatible disk without silently changing partitions or formatting the disk.
4. Firmware boots the installed media and reaches the project's working GRUB runtime and usable menu, which supports its preserved essential navigation and multiboot behaviors.
5. Relevant x86 BIOS, x86 UEFI and ARM64 UEFI boot paths are actually exercised via QEMU firmware before claiming working interoperability. A virtual-machine result does not automatically establish hardware-specific USB/Thunderbolt, Secure Boot or Apple Silicon compatibility.
6. An operator copies an explicitly supported Linux installer ISO and recovery/backup ISO onto an already prepared exFAT data partition from a compatible host using normal file operations, with no device flashing or loader reinstall; after firmware boot, m-loader discovers and actually boots each image into its intended installer/recovery environment. Validate representative OS/image recipes and clearly identify those not yet supported.
7. A media-creation operator can positively identify and choose the intended device, preview the exact partition/boot changes, and avoid unintended writes to any other attached storage. Distinguish the one-time preparation of a disk from routine ISO-copy updates.
8. If no external m-loader is found (or a handled loader source failure occurs), the embedded GRUB recovery becomes usable without any external filesystem, permits native command-line access using `c`, retrying loader discovery, inspecting detected devices and boot variables, and reboot/shutdown without automatic writes.

## Working design

- Current `m-boot` uses `loader/.mk/target-build.sh`, currently empty `loader/.mk/target-install.sh`, `loader/bootstrap-memdisk.sh` and GRUB scripts in `loader/script/`. The current build emits `i386-pc`, `i386-efi` and `x86_64-efi` targets, assumes a Cygwin-specific GRUB module layout, and has no `arm64-efi` build target.
- Current `loader/grub-modules-efi.cfg` includes `exfat`, while `loader/grub-modules-bios.cfg` does not: data-partition support is inconsistent for the desired removable media layout. `loader/script/iso-boot/` contains historic ISO boot recipes, including Clonezilla, GParted and Ubuntu, but they are not validated against current images/firmware. Legacy NaVi examples remain in `loader/script/menu-default`, but NaVi is tracked only as deferred future work.
- The user committed a flexible two-stage embedded `loader/script/init` in m-boot `82f6a28`, but that commit accidentally contained unresolved Git merge-conflict delimiters. Forward-only commit `94bb7d6` resolves these by retaining the user's external-loader discovery flow, adds `loader/script/recovery`, and deletes the obsolete `loader/script/menu-recovery`. The existing tar wildcard includes the new recovery. The external `/m/boot/loader/init` is not yet distributed or implemented and fixed-selector build variants are not implemented. Keep device names parenthesis-free, GRUB absolute-device path syntax `($device)$path`, and do not add unrestricted fallback to constrained builds.
- Potential standalone design: an explicit host-side build interface using `grub-mkimage` and target-specific module directories, plus a separate installation interface. For UEFI, use the firmware fallback paths `EFI/BOOT/BOOTX64.EFI` and `EFI/BOOT/BOOTAA64.EFI` on a compatible EFI System Partition. For BIOS, use an explicit whole-disk GRUB installation with suitable MBR/GPT embedding prerequisites. Preserve existing runtime/ISO recipes where possible.
- Multiple architecture GRUB module sets may need to be provisioned explicitly, including cross-host inputs. Test the complete composition and ensure module-version compatibility before choosing a concrete mechanism.
- The current on-disk `/m/boot/loader` is a GRUB pathname layout, not necessarily a dependency on the `m` program; decide layout migration only after auditing existing references and compatibility.
- Secure Boot signing/enrollment and non-UEFI ARM64 boot chains (including native Apple Silicon's non-UEFI firmware) are platform-dependent and are not proven by a generic `arm64-efi` image. Do not imply universal coverage.
- Treat firmware/device installation as potentially destructive: require concrete target identification, a safe preflight, explicit operator acceptance and no automatic partitioning.

## Completed

- Verified live repository HEADs and mandatory source routing.
- At `m-boot` `94bb7d69c43f1cc7e1c482ccb2e583756def7c72`, repaired the committed `init` merge conflict while preserving the user's flexible two-stage selection logic; introduced an embedded read-only GRUB recovery menu with native `c` command-line access, retry/discovery, device and variable inspection, reboot/shutdown; removed obsolete `menu-recovery`. `bootstrap-memdisk.sh` remains unchanged. Static checks confirmed file/entrypoint paths, tar wildcard inclusion, required modules in both BIOS and EFI lists, absence of merge markers, basic conditional/brace balance and memdisk reset on both fallback branches. No `grub-script-check` or firmware boot tests were possible: tools are unavailable and auxiliary apt installation failed.
- Committed a focused GRUB runtime correction to `m-boot` main at `af0b323c426d54f4692a3728bf98f0dc8a0422b7`: `loader/script/init` now validates a boot source and falls back between firmware path, embedded `root.conf` and environment file search, holds `prefix=(memdisk)` until a device is verified, restricts imported environment variables and selects embedded recovery on failure. `loader/script/gui` preserves theme/resolution preferences and falls back to the console if gfxterm fails. New `loader/script/menu-recovery` is included by existing memdisk TAR wildcard. `loader/bootstrap-memdisk.sh` is unchanged.
- Reviewed actual Git diff: only the three intended files were changed, with a forward-only commit. Static structural checks passed for embedded boot module availability in the existing x86 BIOS/EFI lists, memdisk inclusion, fallback branches, approved environment whitelist and basic conditional balance. These are NOT GRUB parser or boot tests.
- Inspected current repository composition and build/boot scripts from current imported source.
- Verified platform distinctions and UEFI fallback filenames against GRUB and UEFI documentation.

## Current state

The minimal GRUB recovery is now committed and intended as the fallback for the user-authored flexible two-stage embedded init, but it has not been GRUB-parser- or firmware-boot-validated. The existing Cygwin-era build still does not stage an external m-loader init; a fully operating standalone system is therefore not yet delivered. `grub-script-check`, `grub-mkimage`, GRUB modules and QEMU were not available in the auxiliary container, and a limited attempt to install `grub-common` could not complete. Validation is restricted to reviewed diffs and static composition checks. The current phase is GRUB recovery, multiboot, device inspection, boot-from-ISO and chainloading; NaVi and advanced cryptography are deferred. Historical field use is user-confirmed, not revalidated on this revision.

## Next action

Next implement the external `/m/boot/loader/init` and standalone media/build split, after running authentic `grub-script-check` and boot tests of the embedded recovery/`init` path. Then implement and validate device discovery, chainloading and selected copy-and-boot ISO scenarios on safely provisioned FAT32 ESP + exFAT data media (BIOS embedding where applicable). Validate GRUB/QEMU BIOS/UEFI paths and real boot behavior before claiming interoperability. NaVi is not a current next action.

## Blockers / open questions

- Need actual GRUB target-module sets and QEMU firmware/test tools; they are not available in the current ChatGPT container.
- On-device firmware/boot behavior and Secure Boot cannot be claimed until appropriate tests have run.
- In a flexible build, multiple m-loader installations are expected and selection of one suitable first loader is permitted; security of executing untrusted external GRUB scripts is a separate issue. In a constrained build, fixed UUID/label/file selectors prevent unrestricted selection but can be duplicated/spoofed and do not prove authenticity. Both paths require real firmware validation; the exact behavior of recovery for constrained policy must not silently relax the restriction.
- The changes made to GRUB code need an authentic GRUB script parser and firmware boot smoke test before they can be considered validated, especially for BIOS recovery with no external root.
