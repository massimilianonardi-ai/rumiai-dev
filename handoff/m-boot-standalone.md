# m-boot standalone Linux build and bootable-media development

Status: Active
Updated: 2026-10-29

## Goal

Evolve the existing, extensively field-used `m-boot` multiboot system into a working standalone product, built on Linux x86_64 or Linux ARM64 and capable of booting from internal or external storage on applicable x86_64 BIOS, x86_64 UEFI, and ARM64 UEFI systems. Future integration into `m` is not a current runtime or build dependency.

## Current repository revisions

- `massimilianonardi-ai/m-boot` main: `af0b323c426d54f4692a3728bf98f0dc8a0422b7`
- `massimilianonardi-ai/rumiai-dev` main (before this handoff checkpoint): `953b4dce68012e109e4043fc0f1e1e102bc90c78`

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
- A full `recovery` component is the next implementation step and does not exist yet. The existing `loader/script/menu-recovery` is only an initial placeholder menu, not the user-intended recovery implementation.
- Eliminate the Cygwin/Windows-oriented build assumption: the supported build hosts are Linux x86_64 and Linux ARM64.
- The product must currently build, install and run standalone, with no `m`, `mk` or RumiAI environment dependency. Integration into `m` is future work, not a blocker or prerequisite.
- Target boot platforms are x86_64 with legacy BIOS, x86_64 with UEFI and ARM64 with UEFI. Legacy PC BIOS is not an ARM64 platform.
- Target storage includes internal and external devices (e.g. USB, Thunderbolt), subject to firmware preboot-device enumeration and platform-specific firmware limitations.
- Build-host architecture, GRUB boot target and installation-media/device selection are separate concerns.
- Do not automatically partition/format disks or overwrite existing bootloaders as a side effect of routine build or install workflows. Follow forward-only Git and preserve concurrent changes.

## Acceptance scenarios

1. On a supported Linux x86_64 or ARM64 development host, an operator uses standalone project tools to build the supported BIOS/UEFI images with the requisite target GRUB modules; missing toolchains or modules are diagnosed explicitly rather than silently skipped.
2. An operator prepares an explicitly selected existing target storage device and installs a bootable x86_64 UEFI or ARM64 UEFI fallback image without requiring `m` or firmware NVRAM registration. Existing unrelated files and bootloaders are preserved unless deliberate replacement was selected.
3. An operator installs the x86_64 BIOS boot path on an explicitly selected compatible disk without silently changing partitions or formatting the disk.
4. Firmware boots the installed media and reaches the project's working GRUB runtime and usable menu, which supports its preserved essential navigation and multiboot behaviors.
5. Relevant x86 BIOS, x86 UEFI and ARM64 UEFI boot paths are actually exercised via QEMU firmware before claiming working interoperability. A virtual-machine result does not automatically establish hardware-specific USB/Thunderbolt, Secure Boot or Apple Silicon compatibility.

## Working design

- Current `m-boot` uses `loader/.mk/target-build.sh`, currently empty `loader/.mk/target-install.sh`, `loader/bootstrap-memdisk.sh` and GRUB scripts in `loader/script/`. The current build emits `i386-pc`, `i386-efi` and `x86_64-efi` targets, assumes a Cygwin-specific GRUB module layout, and has no `arm64-efi` build target.
- The current committed `m-boot` implementation is still the earlier single-stage memdisk `loader/script/init` (`af0b323`); the two-stage design and build-time policy variants above are not implemented. Existing `loader/script/menu-recovery` is an interim embedded menu, and the existing build does not distribute `/m/boot/loader/init`. Implement the source/media split and selected embedded init per build target before considering the new flow executable. For flexible discovery, normalize GRUB device names without surrounding parentheses (`cmdpath` regexp capture versus `search --set`), use `($device)$absolute_path` for explicit-device lookups, and retain memdisk access until delegation/recovery. In constrained builds, no unrestricted fallback is permitted. Distinguish the selector's safety against accidental booting of the wrong device from authenticity/security against spoofed UUIDs, labels or modified scripts.
- Potential standalone design: an explicit host-side build interface using `grub-mkimage` and target-specific module directories, plus a separate installation interface. For UEFI, use the firmware fallback paths `EFI/BOOT/BOOTX64.EFI` and `EFI/BOOT/BOOTAA64.EFI` on a compatible EFI System Partition. For BIOS, use an explicit whole-disk GRUB installation with suitable MBR/GPT embedding prerequisites. Preserve existing runtime/ISO recipes where possible.
- Multiple architecture GRUB module sets may need to be provisioned explicitly, including cross-host inputs. Test the complete composition and ensure module-version compatibility before choosing a concrete mechanism.
- The current on-disk `/m/boot/loader` is a GRUB pathname layout, not necessarily a dependency on the `m` program; decide layout migration only after auditing existing references and compatibility.
- Secure Boot signing/enrollment and non-UEFI ARM64 boot chains (including native Apple Silicon's non-UEFI firmware) are platform-dependent and are not proven by a generic `arm64-efi` image. Do not imply universal coverage.
- Treat firmware/device installation as potentially destructive: require concrete target identification, a safe preflight, explicit operator acceptance and no automatic partitioning.

## Completed

- Verified live repository HEADs and mandatory source routing.
- Committed a focused GRUB runtime correction to `m-boot` main at `af0b323c426d54f4692a3728bf98f0dc8a0422b7`: `loader/script/init` now validates a boot source and falls back between firmware path, embedded `root.conf` and environment file search, holds `prefix=(memdisk)` until a device is verified, restricts imported environment variables and selects embedded recovery on failure. `loader/script/gui` preserves theme/resolution preferences and falls back to the console if gfxterm fails. New `loader/script/menu-recovery` is included by existing memdisk TAR wildcard. `loader/bootstrap-memdisk.sh` is unchanged.
- Reviewed actual Git diff: only the three intended files were changed, with a forward-only commit. Static structural checks passed for embedded boot module availability in the existing x86 BIOS/EFI lists, memdisk inclusion, fallback branches, approved environment whitelist and basic conditional balance. These are NOT GRUB parser or boot tests.
- Inspected current repository composition and build/boot scripts from current imported source.
- Verified platform distinctions and UEFI fallback filenames against GRUB and UEFI documentation.

## Current state

First focused runtime hardening code has been committed, but it is NOT yet considered boot-validated or an accepted finished release. No standalone Linux build/install workflow or actual GRUB firmware boot test has been delivered yet. `grub-script-check`, `grub-mkimage`, GRUB modules and QEMU were unavailable in the ChatGPT Linux auxiliary container, so validation is limited to diff review and static checks. The build still uses its Cygwin-era assumptions. Historical production use is user-confirmed, not revalidated for the new revision. The original archive's root `.mk/mk.conf` was not imported and does not affect the intended standalone build.

## Next action

Implement and test the embedded-init/external-m-loader source and media split with separate build-selected flexible versus constrained init behavior, then develop the real embedded recovery component. Validate genuine GRUB script execution and QEMU BIOS/UEFI boot paths, including flexible discovery with multiple loaders, strict constrained failure and compatibility/delegation behavior between loader versions. Continue standalone Linux host build and safe installation/staging. Do not claim finished support until real boot validation.

## Blockers / open questions

- Need actual GRUB target-module sets and QEMU firmware/test tools; they are not available in the current ChatGPT container.
- On-device firmware/boot behavior and Secure Boot cannot be claimed until appropriate tests have run.
- In a flexible build, multiple m-loader installations are expected and selection of one suitable first loader is permitted; security of executing untrusted external GRUB scripts is a separate issue. In a constrained build, fixed UUID/label/file selectors prevent unrestricted selection but can be duplicated/spoofed and do not prove authenticity. Both paths require real firmware validation; the exact behavior of recovery for constrained policy must not silently relax the restriction.
- The changes made to GRUB code need an authentic GRUB script parser and firmware boot smoke test before they can be considered validated, especially for BIOS recovery with no external root.
