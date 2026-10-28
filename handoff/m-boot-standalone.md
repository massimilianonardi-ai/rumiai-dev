# m-boot standalone Linux build and bootable-media development

Status: Active
Updated: 2026-10-28

## Goal

Evolve the existing, extensively field-used `m-boot` multiboot system into a working standalone product, built on Linux x86_64 or Linux ARM64 and capable of booting from internal or external storage on applicable x86_64 BIOS, x86_64 UEFI, and ARM64 UEFI systems. Future integration into `m` is not a current runtime or build dependency.

## Current repository revisions

- `massimilianonardi-ai/m-boot` main: `47b9832dad08f24f3bb77d6f73a48602948b3334`
- `massimilianonardi-ai/rumiai-dev` main (preflight): `f96bd4610e970897b9490db2045394cc38e6ff52`

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
- Potential standalone design: an explicit host-side build interface using `grub-mkimage` and target-specific module directories, plus a separate installation interface. For UEFI, use the firmware fallback paths `EFI/BOOT/BOOTX64.EFI` and `EFI/BOOT/BOOTAA64.EFI` on a compatible EFI System Partition. For BIOS, use an explicit whole-disk GRUB installation with suitable MBR/GPT embedding prerequisites. Preserve existing runtime/ISO recipes where possible.
- Multiple architecture GRUB module sets may need to be provisioned explicitly, including cross-host inputs. Test the complete composition and ensure module-version compatibility before choosing a concrete mechanism.
- The current on-disk `/m/boot/loader` is a GRUB pathname layout, not necessarily a dependency on the `m` program; decide layout migration only after auditing existing references and compatibility.
- Secure Boot signing/enrollment and non-UEFI ARM64 boot chains (including native Apple Silicon's non-UEFI firmware) are platform-dependent and are not proven by a generic `arm64-efi` image. Do not imply universal coverage.
- Treat firmware/device installation as potentially destructive: require concrete target identification, a safe preflight, explicit operator acceptance and no automatic partitioning.

## Completed

- Verified live repository HEADs and mandatory source routing.
- Inspected current repository composition and build/boot scripts from current imported source.
- Verified platform distinctions and UEFI fallback filenames against GRUB and UEFI documentation.

## Current state

Requirements established; no product code, installation behavior or real boot validation has been changed or completed in this work unit. Historical use established by the user, not revalidated against the current imported repository. `m-boot` contains 326 Git blobs under `loader/` and `theme/`; the original archive's root `.mk/mk.conf` was not imported and is unrelated to the intended standalone path.

## Next action

Build and validate the first standalone Linux host entrypoints, beginning with target-module/toolchain discovery and boot-image generation; implement safe installation/staging and run real firmware boot validation for each target, preserving and iterating from the existing GRUB scripts.

## Blockers / open questions

- Need actual GRUB target-module sets and QEMU firmware/test tools; they are not available in the current ChatGPT container.
- On-device firmware/boot behavior and Secure Boot cannot be claimed until appropriate tests have run.
