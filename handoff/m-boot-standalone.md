# m-boot standalone Linux build and bootable-media development

Status: Active
Updated: 2026-10-28

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
- Current `loader/script/init` changes `prefix` to `/m/boot/loader` before finding the external root; it branches on existence of embedded `root.conf`, but does not attempt `cmdpath` or an environment-file fallback when the search inside `root.conf` fails. Build currently usually generates that file, so this can bypass fallbacks. Proposed focused repair: retain memdisk bootstrap/prefix until external root is confirmed, make resolution status explicit with checked fallbacks and actionable recovery, validate loaded content before selecting it, and distinguish cloned media sharing the same marker. Specific fallback precedence remains design/test-dependent.
- Current `init` loads the writable external environment with `load_env --file ... --skip-sig` and no variable whitelist; GRUB's manual recommends a whitelist for `--skip-sig`. Proposed whitelist only for approved user settings, never GRUB critical variables such as `prefix`, `root` and signature controls. Audit `gui` and `main`: `gui` overwrites `theme_name` and `gfxmode` after loading the environment. Propose graceful console/menu fallback when graphical assets or external root are missing, and explicit diagnostics without forcing a graphics failure to abort core navigation.
- User submitted an alternative two-stage `init` design (2026-10-29), **under discussion, not yet accepted as implemented**: a minimal `(memdisk)/init` discovers and sources `/m/boot/loader/init` from a selected external filesystem; recovery remains embedded. Keep the agreed `bootstrap-memdisk.sh` unchanged. Before changing runtime, reconcile the distribution layout: the current build embeds `loader/script/init` and does not stage an external `/m/boot/loader/init`, and the current recovery script is named `menu-recovery` rather than `recovery`. The proposed script has inconsistent GRUB device/path representation: `cmdpath` regexp currently captures `(hdN,partM)`, while `search --set` typically yields `hdN,partM`, so using `$m_loader_disk/$m_loader_init` is not a valid unified explicit-device reference; `m_loader_init` already starts with `/`. Candidate correction: capture the parenthesis-free device ID with GRUB regexp, probe `($boot_disk)$m_loader_init`, use `search --set=m_loader_disk`, then set `root=$m_loader_disk` and source `$m_loader_init` with no extra slash; preserve `(memdisk)` as `prefix` until external loader takes responsibility. Validate external loader identity/boot-origin affinity and security of executing a script found by an unrestricted filename search, especially with cloned or untrusted disks. Do not claim GRUB runtime validation.
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

First run `grub-script-check` and real GRUB boot tests against the committed changed `init`, `gui` and `menu-recovery` scripts, then fix any discovered parser/runtime defects. Continue standalone Linux host build toolchain discovery/generation, safe installation/staging and QEMU BIOS/UEFI firmware validation of each supported target, without changing the proven GRUB model unnecessarily.

## Blockers / open questions

- Need actual GRUB target-module sets and QEMU firmware/test tools; they are not available in the current ChatGPT container.
- On-device firmware/boot behavior and Secure Boot cannot be claimed until appropriate tests have run.
- Media cloning ambiguity remains unresolved when firmware `cmdpath` cannot identify an installed environment: the embedded marker search or generic environment search can select the first matching cloned filesystem. The current implementation prioritizes a verified `cmdpath` source to avoid that case when possible; it is not a uniqueness guarantee. Investigate the known boot device and marker uniqueness in real firmware tests.
- The changes made to GRUB code need an authentic GRUB script parser and firmware boot smoke test before they can be considered validated, especially for BIOS recovery with no external root.
