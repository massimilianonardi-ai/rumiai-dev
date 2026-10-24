# BOSGAME P2 Pro / Proxmox complete-freeze diagnosis

Status: Active
Updated: 2026-10-24 (Europe/Rome; new workload/power observations)

## Goal

Identify whether repeated complete freezes of a newly purchased BOSGAME P2 Pro (Proxmox host `pmve`) are attributable to Intel I226-V network controllers / Linux `igc`, their offload functions, another Linux subsystem, BIOS settings or defective hardware; decide promptly whether the machine is reliable enough to retain **before the seller's return window expires**. This is an operator's physical-host diagnostic task, **not a RumiAI runtime implementation or architecture change**. Preserve a careful one-variable-at-a-time experimental record and avoid destructive firmware operations without validated OEM images.

## Current repository revisions

- `massimilianonardi-ai/rumiai-dev` main preflight HEAD: `0ddf3c8b2d12204e87e37f5d306e52ec83f36bf6` (2026-10-24; recheck remote HEAD before resuming or writing).
- No product/runtime repositories are being modified by this task. The machine itself is outside Git; all observations derive from operator-pasted commands, logs and a physical-console photo.

## Applicable canonical sources

- `README.md`
- `RULES.md`
- `CONSISTENCY-GATE.md`
- `specifications/README.md` (no RumiAI subsystem specification directly governs this external host diagnosis)
- `handoff/README.md`

## Fixed task-local choices

- Preserve the option to return the new mini-PC: prioritize short, informative tests over exhaustive troubleshooting; do not risk the return period trying to perfect firmware or BIOS tuning.
- **Leave BIOS at factory/default values for the current diagnosis**, including platform C-states and PCIe power management. BIOS optimization comes later if machine reliability is established.
- Use Proxmox kernel `7.0.14-25-pve` as current reference, **without** `intel_idle.max_cstate=1` or `pcie_aspm=off` in the present tests. No permanent change to default kernel/GRUB intended.
- Test one variable at a time where practicable; clearly flag comparisons confounded by simultaneously changed BIOS, VM state or offload settings.
- Keep exact physical-console access when network controllers are blacklisted; disabling `igc` kills both integrated Ethernet interfaces.
- Avoid speculative BIOS flashing, third-party I226-V NVM flashing or deliberately induced kernel panic. BIOS/NVM inventories and diagnostic reads are permitted.
- **B1 failed:** a new photographed Oops and operator-reported full-host freeze at approximately 2h43m with factory BIOS; VM 100/101 boot starts are now verified by the supplied journal. Pre-crash `ethtool -k` was not supplied; do not imply verified offload state.
- Preserve distinction: disabling TSO/GSO/GRO is **not** disabling all offloading; checksum, VLAN and virtual/tap/guest offload settings remain unchanged.

## Operator decision tree for final isolation and return (fixed 2026-10-24; fault branch selected)

The operator's explicit plan overrides earlier PVEMods-first isolation. **They now report standalone Memtest failure and have selected return of the mini-PC.** The clean Proxmox/Ubuntu reinstall branches below are historical contingencies **not currently requested**.

1. **2026-10-24 outcome:** the operator reports standalone Memtest **failed**, before the intended overnight observation ended. No numeric error count, pass number, test ID, BIOS screen photo, or Memtest version has been provided.
2. **Triggered:** memory test reported failure → operator states the hardware is defective and selects **return the BOSGAME P2 Pro**, foregoing subsequent OS reinstall experiments. A memory subsystem fault is strongly supported, but faulty DIMM vs slot/IMC/board is not resolved.
3. **If the memory test is clean:** first export/back up **both existing Proxmox VMs** (VM 100 OPNsense, VM 101 Home Assistant). Before erasing the installation, keep the exports on storage **not affected by disk formatting**, verify backup completion and that files are readable, and preserve any pertinent VM/host network and device assignment settings needed for eventual restoration. Do not start reinstallation before backups are safely off-host.
4. **Reformat and install Proxmox VE from scratch**, with a stock configuration: no additional packages, PVEMods, Glances, lm-sensors customization, custom kernel command line, BIOS tuning, VM creation, VM import, or discretionary NIC/offload tweaks. Necessary initial installer networking is not a customization. Leave this clean host running without VMs for a meaningful observation period; record start time, actual kernel/boot cmdline and any crash. No precise observation period was committed by the operator.
5. **If freshly installed clean Proxmox freezes:** install **Ubuntu** instead, with no Proxmox, and run it with some workload/tasks (exact workload not yet specified). Observe stability and preserve evidence.
6. **If Ubuntu also freezes:** return the computer.
7. **If Ubuntu does not freeze:** operator will assess the next course of action; do **not** automatically conclude hardware is good or prescribe a predetermined next installation.

Important: the return deadline is unknown; remind operator to keep enough time for the explicitly intended refund/replacement. A clean Memtest or a stable idle Linux test alone does not prove the machine reliable. Preserve the above sequence unless the operator explicitly changes it.

## Acceptance scenarios

1. Standalone Memtest result is **operator-reported failure**, without inventing measurements; its error branch triggers the previously selected return.
2. After a clean Memtest, **both** VM backups are verified and stored away from the disk to be reformatted before a destructive reinstall.
3. Fresh Proxmox is tested at BIOS defaults, without additional packages or VMs; report uptime and outcome without assuming a passing interval until actually observed.
4. Only if the clean Proxmox host freezes, Ubuntu is installed and exercised with a task workload; a second freeze triggers the operator's planned return, otherwise the operator decides.
5. Preserve evidence and enough time for retailer return, and distinguish a memory-test pass from proof of system-wide reliability.

## Hardware identity and topology (operator-confirmed)

- Product: BOSGAME P2 Pro, system DMI `Bosgame EffiZen Series`, family `DB19D`; motherboard `Bosgame DB19D V1.0`; Intel Core i9-12900H (14 cores, 20 logical processors), roughly 16 GiB RAM (DMI: one of two slots populated), approx. 512 GB HighRel NVMe as previously inspected.
- BIOS: AMI/AMI Aptio V UEFI, string `DB19D005`, release 2024-11-26, SMBIOS 3.7.0, SMBIOS `BIOS Revision: 5.27`, `Firmware Revision: 1.5`. These latter SMBIOS fields must **not** be treated as a newer BOSGAME BIOS version. Do not store/display machine serial number, UUID or personal email addresses in this handoff.
- Two Intel Ethernet Controller **I226-V** `8086:125c` revision `04`, both `Subsystem: Intel Corporation Device [8086:0000]`:
  - `nic0` at PCI `0000:2b:00.0`, behind root port `0000:00:1c.0`, IOMMU group 14; link previously at 1 Gb/s.
  - `nic1` at PCI `0000:2c:00.0`, behind root port `0000:00:1c.6`, IOMMU group 15; link previously at 2.5 Gb/s.
  - Both use kernel driver `igc`; `ethtool -i` on kernel `7.0.14-25-pve` returned `firmware-version: 2023:889d`; hardware NVM word read-only via `ethtool -e nicX offset 10 length 2` returned `0x000a: 23 20` for both, little-endian `0x2023`; `0x889d` is the PHY firmware part reported by driver. This is consistent with NVM family 2.23 but does not furnish full Intel NVM image identity or ETrackID.
  - Both show `supports-eeprom-access: yes`; **do not infer flash size from PCI BAR size**.
- Intel AX201 Wi-Fi device (around `00:14.3`), distinct from both wired I226-V devices. In SMBIOS `Onboard - Ethernet` points at `00:14.3` and is **not** direct evidence of an I226-V toggle.
- Missing bridge ports for USB NIC-style interfaces `vmbr2` / `vmbr3` have been logged on boot; during blacklisted boot `vmbr0` / `vmbr1` were missing `nic0` / `nic1` as expected.

## Failure characterization and earlier experiments

- Hard freeze of the **entire host**: local screen/cursor do not update, no keyboard response or SSH/ping/VM operation, recovery requires forced power cycle. Lit/blinking Ethernet LEDs do not prove CPU responsiveness. Various incidents around the minute :17/:18 of the hour, e.g. 2026-10-22 about 23:18 and 2026-10-23 about 19:18; uptime often ~2–3 hours. This is an observation, not a proven clock-driven trigger.
- Tested kernels reported: `7.0.2-6-pve`, `6.17.13-21-pve`, `7.0.14-25-pve`; freezes observed across versions. Several initial freeze runs produced abruptly terminated journal with no panic/Oops.
- Tested BIOS and boot settings at different times: BIOS C-states on/off, kernel `intel_idle.max_cstate=1`; PCIe ASPM on/off, `pcie_aspm=off`; CPU clock/TDP reduction; VMs running or off. RAM clock controls apparently unavailable in BIOS. BIOS did not visibly offer built-in wired NIC toggles in earlier exploration. Tests not always fully factorial; do not infer any one setting cleared/caused freeze.
- `/etc/crontab` had standard `17 * * * * root ... run-parts --report /etc/cron.hourly`; `/etc/cron.hourly` only contained a nonexecutable placeholder and `run-parts --test` empty. Cron activity around :17 completed normally on boots with no freezes; in the decisive 2026-10-23 boot cron finished at 23:17 and last journal reached 23:43. No causal evidence against cron; low priority.
- PCIe link previously displayed sticky `CESta: RxErr+` on both Intel endpoints, but **all** `/sys/bus/pci/devices/{2b:00.0,2c:00.0,00:1c.0,00:1c.6}/aer_*` correctable/nonfatal/fatal counters were zero, as were root port totals. Sticky PCIe status and kernel AER counters are different mechanisms; do not claim proven link faults.
- `ethtool --show-eee nic0 nic1` confirmed **EEE disabled** and TX LPI disabled on both, despite advertised support from partners. EEE is not demonstrated cause.
- Prior USB/ACPI/TPM/PCIe/perf messages had uncertain significance; no reliable root cause established. Perf adaptive sample-rate drops appeared on several boots. Do not equate `perf: interrupt took too long` with proven CPU hardware failure.

## Important 2026-10-23/24 overnight Oops: informative but confounded

- Boot journal started **2026-10-23 21:11:00 Europe/Rome** with exact kernel cmdline:
  `BOOT_IMAGE=/boot/vmlinuz-7.0.14-25-pve root=/dev/mapper/pve-root ro quiet intel_idle.max_cstate=1 pcie_aspm=off module_blacklist=igc`.
  BIOS had **multiple nondefault power-management changes** and **VM 100 and VM 101 were started**, so this incident cannot be compared one-variable-at-a-time against a later default-BIOS/no-VM run.
- Operator verified `lsmod | grep '^igc'` produced nothing and `lspci -nnk` displayed `Kernel modules: igc` but **no** `Kernel driver in use: igc`; blacklisting worked. Journal explicitly stated `Module igc is blacklisted`, and missing `nic0`/`nic1` links corroborate that no wired interfaces existed.
- In the morning 2026-10-24, the user photographed kernel output on a fully frozen local console. Important partially legible trace, transcribed from photo (some register/module lines not reliably legible):
  `BUG: kernel NULL pointer dereference`; `#PF: supervisor read access in kernel mode`; `#PF error_code(0x0000) - not-present page`; `Oops: 0000 [#1] SMP NOPTI`; `CPU: 16 ... PID: 0 Comm: swapper/16`; `RIP: refill_obj_stock+0x85/0x260`; reported `CR2: 0000000000000001`.
  Trace displayed `refill_obj_stock → __memcg_slab_free_hook → rcu_free_sheaf_prepare/__rcu_free_sheaf_prepare → kmem_cache_free → rcu_free_sheaf → rcu_do_batch → rcu_core → handle_softirqs → irq_exit_rcu → sysvec_apic_timer_interrupt`. Exact symbol spellings and full trace should be checked from original photo if available. Path concerns memcg/slab/RCU frees; identifies failure *site*, **not** the source of potential corruption (kernel bug, driver, RAM/IMC/board all remain candidates).
  Time printed near the trace ~`[9455.485221]` seconds uptime, thus approx. **23:48:35** if anchored to the 21:11 journal timestamp; approximate due to boot-timestamp/clock interpretation.
- Complete journal of that boot (pasted text named `Testo incollato(6).txt`, ~1,560 lines) ends at **23:43:26** with `i915 0000:00:02.0: [drm] *ERROR* CPU pipe A FIFO underrun`, around 5 min before inferred Oops. This is a **display pipeline** warning, not necessarily CPU arithmetic or established cause; may be unrelated. The Oops itself did NOT survive in the journal. Multiple `perf: interrupt took too long` messages increased across session, with sample-rate auto reduction; not causal proof. `cron.hourly` at 23:17 completed.
- The `Tainted: P` indication is accounted for by normal loading of Proxmox ZFS `spl` / `zfs` CDDL out-of-tree modules; does not establish culprit.
- Conclusion: a memory-management Oops can happen with **no `igc` bound**, but in this run BIOS was heavily changed and VMs were active. It does not isolate whether the *original* freeze was caused by I226-V or the BIOS modifications; also reminds us there may be more than one failure mode.

## pstore / logging findings

- Boot-time journal can stop minutes before console Oops: `journald` disk journal is not crash-proof. The physical kernel console can show `printk`/Oops **without anyone logging in**, so earlier missing messages were not due simply to absent console login.
- `/sys/fs/pstore` was mounted as `pstore` but empty after reboot; `/var/lib/systemd/pstore` empty; `systemd-pstore.service` inactive because `ConditionDirectoryNotEmpty=/sys/fs/pstore` unmet. Not evidence that service itself is broken.
- Kernel config: `CONFIG_PSTORE=y`, `CONFIG_EFI_VARS_PSTORE=m`, `CONFIG_PSTORE_RAM=m`; `CONFIG_PSTORE_CONSOLE` and `CONFIG_PSTORE_PMSG` disabled; `efi_pstore` module loaded. Kernel logged `Registered efi_pstore as persistent store backend`.
- Active sysfs: `/sys/module/pstore/parameters/backend=efi_pstore`, `/sys/module/efi_pstore/parameters/pstore_disable=N`, `record_size=1024`. `kernel.panic_on_oops=0`, `kernel.panic=0`. No pstore/EFI write errors observed in the **new** boot journal, but this does **not** prove the previous crash could be recorded. Firmware NVRAM write limitations / crash execution path / altered previous boot all remain possible.
- Future instrumentation options if needed: external serial logging or another truly external receiver. `netconsole` requires functional network (not suitable when `igc` blacklisted). Do not activate extra logging mid-comparison without separately documenting configuration.

## BIOS firmware offline investigation (completed in prior chat)

- Operator provided official-looking BOSGAME package `DB19D_BOSGAME_BIOS0.05_EC1.05_16M_20241126.zip` (published BIOS0.05/EC1.05 for P2 Pro), containing `DB19D005.bin` 16 MiB and flashing utilities. **Never execute** flashing tools during diagnosis.
- Earlier assistant extracted AMI Aptio V UEFI Setup/HII/IFR in an offline analysis; reported ~8,880 strings, ~31,425 IFR instructions, ~4,595 named items. Outputs produced as conversation attachments: `DB19D005_BIOS_analysis.md` and `DB19D005_BIOS_IFR_options.txt`; these files are **not guaranteed available in new chat or committed to Git**, so rely only on listed observations until revalidated.
- Strings include `Foxville I225 LAN Controller` (relevant family to I225/I226) but that string was **not** found as a usable IFR setting in decoded forms. `PCH LAN Controller` is represented by an IFR enable/disable setting, but no evidence that it controls either I226-V; per-port PCIe Root Port controls appear implemented (e.g. Root Port 1/7, ASPM/L1 substate); their actual on-screen visibility and hardware mapping remain unverified.
- Earlier IFR reading claimed factory defaults: CPU C-states Enabled, Package C State Limit Auto, Intel Speed Shift Enabled, Energy Efficient Turbo Enabled, Maximum Memory Frequency Auto, some PCIe root ports Enabled. Treat extracted values as *firmware declared*, not proof of actual NVRAM or UI access.
- BIOS package appeared same release date as installed `DB19D005`. Do not seek unrelated BIOS tuning until freeze root cause/return decision is resolved.

## NVM/firmware investigation (current, no flash)

- Latest operator read-only inventory confirms:
  - `ethtool -i nic0` and `nic1`: `igc`, version `7.0.14-25-pve`, `firmware-version: 2023:889d`;
  - `lspci -nnvv -s 2b:00.0` and `2c:00.0`: `8086:125c (rev 04)`, subsystem `8086:0000` both;
  - `ethtool -e nic0 offset 10 length 2` and equivalent `nic1`: `0x000a: 23 20` both.
- Community sources mention newer I226-V NVM families 2.25, 2.27, 2.32 with potential EEE/link/PHY corrections, **not OEM certification, not proven to fix full-host freezes**. No BIOS/NVM package from BOSGAME conclusively validated for this specific motherboard's I226-V. Generic Intel NVM images may not preserve OEM NVM fields; avoid unapproved writes that could damage Ethernet and complicate a return.
- Prior assistant suggested an official Intel utility `nvmupdate64e` for **read-only inventory** (`-i`), but user explicitly reports **`nvmupdate64e` is not installed**. Do not assume it exists or repeatedly instruct to run it. If strictly useful, research validated Intel download and read-only mode before asking to install.
- OEM support request for precise update compatible with `DB19D V1.0 / I226-V rev04 / 8086:125c subsystem 8086:0000` is an option; prioritize remaining return window.

## Controlled experimental sequence and exact current state

1. **Overnight A0 (confounded):** kernel 7.0.14-25, `igc` blacklisted, **BIOS modified / C-state capped / ASPM disabled / VMs running** → Oops at ~2h37m. This cannot independently clear Ethernet or incriminate BIOS.
2. **A1 baseline (interrupted):** after user restored **BIOS factory defaults**, booted kernel 7.0.14-25 with only `module_blacklist=igc` added transiently via GRUB, no kernel C-state or ASPM overrides; verified by `/proc/cmdline`, `lsmod`, `lspci`; **VMs/containers off**. User reported physical console still responding after previously expected 2–3-hour freeze window; intentionally ended run earlier than planned (~24–48h) because return period was approaching. Encouraging but **not a proven stable 24h control**.
3. **B0 (new normal driver, offloads initially default):** User rebooted with **no additional kernel command-line parameters**, BIOS remains default; `igc` active on both NICs. Intended to keep VMs off first, but the current conversation does not establish a long B0 test duration or a freeze. Be careful: no matched-duration B0 vs A1 comparison yet.
4. **B1 (most recent intervention):** assistant instructed from physical console:
   ```sh
   ethtool -k nic0 > /root/nic0-offload-before.txt
   ethtool -k nic1 > /root/nic1-offload-before.txt
   ethtool -K nic0 tso off gso off gro off
   ethtool -K nic1 tso off gso off gro off
   ```
   Expected verification:
   ```sh
   for nic in nic0 nic1; do
       echo "===== $nic ====="
       ethtool -k "$nic" | grep -E 'tcp-segmentation-offload:|generic-segmentation-offload:|generic-receive-offload:'
   done
   ```
   Expected values `off` for `tcp-segmentation-offload`, `generic-segmentation-offload`, `generic-receive-offload`. Changes ephemeral across reboot; checksum/VLAN/LRO/etc were **not** explicitly disabled.
5. **B1 follow-up and outcome:** operator reported both VMs active with BIOS defaults and 24 W at the wall under negligible traffic; the later full journal **verified successful starts of VM 100/101** at 14:25, while subsequent photographed Oops at ~2h43m established **failure**. Effective TSO/GSO/GRO switches were not verified before failure.



## B1 failed — photographed second kernel Oops (2026-10-24)

- Operator supplied a **physical-console photograph** named `20261024_170014.jpg` showing a kernel Oops after approximately **9766 seconds uptime (~2h42m46s)**. Earlier operator report of two hours without freeze was an interim observation; it did **not** develop into four-hour success. The operator explicitly reports the machine again froze. Photo is a conversation attachment, not committed to Git.
- Legible first line: `Oops: general protection fault, probably for non-canonical address ...: 0000 [#1] SMP NOPTI`; exact faulting non-canonical address **not transcribed reliably**. `CPU: 17 UID: 33 PID: 52457 Comm: sensors`; `7.0.14-25-pve #1 PREEMPT(lazy)`; taint `P O`. Upper RIP line appears to be `lookup+0x58/0xe0` (minor character uncertainty), and the clearly readable call trace includes `lookup_fast+0xa5/0x120`, `link_path_walk`, `path_openat`, `do_filp_open`, `do_sys_openat2`, `__x64_sys_openat` and syscall return path.
- This is a kernel fault during filesystem pathname resolution in the context of the `sensors` userspace command; **neither `sensors` nor the filesystem has been proved to cause the underlying corruption**. Compare with earlier A0 `refill_obj_stock` slab/RCU-path Oops at ~2h37m with `igc` blacklisted and nondefault BIOS. Distinct crash sites plus similar elapsed uptime elevate concerns over broad memory corruption, hardware (RAM/IMC/board), or another kernel/driver fault, but **do not establish a hardware diagnosis**. The similar uptime may merit checking a periodic workload but is not itself proof of a timer.
- Under B1 the BIOS was reported to be at defaults and both VMs on; host TSO/GSO/GRO disablement had been instructed but **the immediately pre-crash settings were not freshly verified**. Do not say all offloads were disabled or that `igc` alone was ruled out in every context. The B1 experiment has nevertheless **failed to achieve host stability**.
- **Priority changed:** preserve photo/evidence and previous boot journal (kernel + full) after unavoidable power-cycle; optional standalone memory test from UEFI USB (e.g. Memtest86+) if return window permits; prioritize seller return/replacement after multiple serious kernel faults across configurations/kernels. **Defer** GRUB cleanup, permanent `ethtool` hooks and power optimization until reliability is resolved; no host configuration changes have been executed by the assistant.
- Do not infer whether offloading was disabled in the crashed boot by reading `ethtool -k` *after* reboot: NIC settings reset when the driver initializes. Journal may lack photographed Oops, as previously seen.

## Full previous-boot journal analysis — 2026-10-24 shared log

- Operator submitted `Testo incollato(20261024-151453).txt` (3,842 lines) showing **two distinct boots**. This conversation attachment is not a repository file or exact-host access.
- **13:39:35 boot**: kernel 7.0.14-25-pve with `intel_idle.max_cstate=1 pcie_aspm=off`; this boot ended with an **orderly** software reboot by 14:16:21. Do not conflate its command line with the later failing boot.
- **14:16:49 boot**: kernel 7.0.14-25-pve with **only** `BOOT_IMAGE=/boot/vmlinuz-7.0.14-25-pve root=/dev/mapper/pve-root ro quiet`, i.e. no experimental `intel_idle.max_cstate=1`, `pcie_aspm=off`, or igc blacklist. BIOS defaults were operator-reported, not read from kernel log. `igc` bound to both I226-V ports; link nic0 at 1Gb/s, nic1 at 2.5Gb/s. The **running boot's** cmdline was clean, but this alone does not prove `/etc/default/grub` is clean persistently.
- VM 100 startup recorded successful at **14:25:24–25**, VM 101 at **14:25:41–42**; eliminates earlier uncertainty about whether they actually started. Their guest health beyond launch is not established.
- `lm-sensors.service` ran and **finished** during boot (~14:16:50), generating `sensors[923]` temperature logs, including invalid ACPI sensor reading `-273.3°C` (invalid/sentinel, **not** physical CPU temperature). `glances.service` **started** at 14:16:51. These indicate active optional monitoring services, not proven causes.
- Photographed Oops occurred at uptime ~9766s (approx **16:59:35** from boot time); context `UID: 33, PID: 52457 Comm: sensors` is **not** the boot one-shot `sensors[923]` process. This suggests a **separate later caller**. Official Proxmox `pveproxy` executes workers as `www-data` (usually UID 33), so a pveproxy or custom API/frontend integration is a testable possibility, **not established**. Merely disabling `lm-sensors.service` will not block direct invocations by web/monitor scripts.
- **16:54:43**: `i915 ... [drm] *ERROR* CPU pipe A FIFO underrun`. This is about 4m50s before photographed Oops (~16:59:35); earlier A0 Oops also had same `i915` FIFO warning ~5 minutes earlier. Repeated ordering is noteworthy and motivates a controlled i915/display check if retaining host, but `i915` is a graphics display underrun report, **not proven to cause kernel memory corruption**. Last persisted journal message **16:58:31**; no Oops text preserved, as previously observed.
- The **historical** full-journal upload did not include the requested monitoring inventory; later operator output now confirms `www-data` for UID 33, Glances and lm-sensors package/services, plus a `www-data` `collector-temperature-sensors` process. Identity of that collector's parent and precrash TSO/GSO/GRO state remain unverified. Prioritize narrow reversible isolation if Memtest is negative, without blind package removal; preserve return window.
- Secondary unrelated-but-documented signals: postfix SMTP port 25 retries/timeouts, missing bridge ports for vmbr2/vmbr3, and boot-time ACPI/EDAC and hardware sensor oddities; none is directly shown to precipitate this Oops.

## Optional monitoring hypothesis — operator disclosure (2026-10-24)

- Operator newly clarified that they personally installed **`lm-sensors`** and a program called **Glances** (the journal verifies `glances.service`). This is new evidence for optional monitor activity and user-initiated packages, **not evidence that packages caused the kernel Oops**.
- In the new photographed Oops, `Comm: sensors` and **UID 33** are readable; UID 33 typically resolves to `www-data` on Debian, potentially indicating a web service or script invoked the sensors executable. Resolve with `getent passwd 33`; actual initiating service/parent unknown.
- Linux lm-sensors is primarily a user-space reader of `/sys/class/hwmon`, backed by kernel hwmon/I2C/CPU drivers. Modern Glances typically obtains temperature readings through Python psutil and need not spawn `sensors`, so do **not** attribute UID 33 invocation to Glances without process/audit evidence. `sensors-detect` might have resulted in persisted extra module-loading config; check rather than assuming.
- Next optional **reversible** isolation: collect prior boot journal, installed-package origin and monitor services/unit/timer/cron invocation, list relevant hwmon kernel modules and `/etc/modules` / `/etc/modules-load.d`; stop/disable only actual optional monitor services or scheduled sensor invocations, **not every user-installed package**, not baseline Proxmox/ZFS/QEMU/network services. Keep BIOS, kernel, VMs, and NIC test settings documented and otherwise unchanged. If a clean monitoring-free run survives, this is suggestive but does not resolve severe earlier kernel faults; compare only after multiple hours, within return deadline.
- Never issue blind `apt purge` / `apt autoremove` on Proxmox: first simulate removal and examine dependency impact, particularly `proxmox-ve` metapackage and PVE stack. Stop services before uninstall; a disabled `lm-sensors.service` alone may not prevent other software from invoking `sensors`.
- **Return/replacement option remains the safe fallback** because serious kernel Oops occurred in distinct paths under multiple configurations. One negative trial of monitoring isolation does not absolve hardware, and a positive one must be repeated to be persuasive.

## Operator process inventory and planned standalone memory test (2026-10-24)

- User pasted live read-only inventory: `getent passwd 33` confirms **`www-data:x:33:33:...`**. `/usr/bin/sensors` and `/usr/bin/glances` exist; installed `lm-sensors 1:3.6.2-2`, `glances 4.3.1+dfsg-1`; there is no separate `glance` executable.
- `glances.service` is **active/running** as root: PID 1114, `/usr/bin/python3 /usr/bin/glances -s -B 127.0.0.1`; `lm-sensors.service` is **active/exited** (oneshot). Both are enabled via symlinks under `/etc/systemd/system/multi-user.target.wants/`.
- **PVEMods collector identified by later uploaded host source excerpts:** process `www-data PID 1439 PPID 1438` with command `collector-temperature-sensors` is named exactly by `PVE::PVEMods::Collector::LmSensors`, which launches `sensors -J`. Shares UID 33 with photographed crashing `sensors` task. Exact live parent/scheduling unit and causation remain unverified; do not attribute it to Glances.
- No `glances`/`sensors` references surfaced in the reported grep of `/etc/cron*`, `/etc/systemd/system`, `/etc/modules`, `/etc/modules-load.d` other than the two systemd service files; this **does not rule out package-owned scripts**, `/usr/local`, `/etc/pve`, or runtime API collectors.
- User highlighted recurring ~2h30-2h45 timing of freezes, sometimes shorter/longer. This can be consistent with recurrent jobs or elapsed-state corruption, but does not eliminate RAM/IMC faults; no exact periodic trigger established.
- **Subsequent result: operator reports standalone Memtest FAIL on 2026-10-24.** Hardware memory-subsystem instability is independently supported beyond Proxmox/drivers/VMs. The specific faulty component is unconfirmed; test version, error count, pass/test IDs, photographs and exact duration were not supplied. This supersedes the prior intended overnight test and triggers the operator's return branch.
- Previous PVEMods `collector-temperature-sensors` isolation was a possible software experiment; it is **not required for the chosen return** after standalone Memtest errors. Do not assert that PVEMods/`sensors`, `igc`, or `i915` caused the corruption; the fault site is not identified to a specific memory component.
- No configuration change, USB imaging, or physical test has been performed directly by assistant.

## PVEMods temperature collector source identified (operator output, 2026-10-24)

- Operator supplied `Testo incollato(20261024-152511).txt`, which contains read-only output from the **actual host filesystem**. This is definitive evidence of a **PVEMods software collector**, not just an unidentified `www-data` process; do not silently conflate the separate root-owned `glances.service` with it.
- `/usr/share/perl5/PVE/PVEMods/Collector/LmSensors.pm` defines `collector_for_temperature_sensors` and explicitly sets `$0 = "collector-temperature-sensors"` (line 23); inside its acquisition path it calls **`sensors -J 2>/dev/null | python3 -m json.tool`** (line 71). The executable command, associated `www-data` collector and photographed kernel fault with `UID: 33 Comm: sensors` form a **strong caller-path match**. Runtime process parent tree from actual crashed child is not available, and matching command/UID is **not** proof that PVEMods induced corruption or that the same trigger explains prior PID 0 Oops.
- `/usr/share/perl5/PVE/API2/PVEMods_SensorInfo.pm` checks `$config{lm_sensors}{enabled}` in `get_sensors_info`, but **this is an API-read guard; do not assume setting it to false stops the running collector without inspecting its separate startup/loop config**. `/usr/share/perl5/PVE/API2/Nodes.pm` has a PVEMods SensorInfo API integration at line 541, and `/usr/share/pve-manager/js/PveMods_PveNodeStatusView.js` contains PVEMods-specific sensor UI integration.
- **Deferred diagnostic alternative, superseded as immediate next test by the operator's clean-reinstall decision:** isolate the PVEMods temperature collector only if the user later chooses that experiment. PVEMods remains a concrete possible cause/exposure path, not a demonstrated root cause. Do not change its installed files as part of the clean-host trial.
- Full PVEMods collector module / configuration are **not uploaded**, only `grep` excerpts. Safe future host read-only inspection: `ps -ww -p 1438,1439 -o user,pid,ppid,comm,args`, `pstree -asp 1439`, `sed -n '1,115p' /usr/share/perl5/PVE/PVEMods/Collector/LmSensors.pm`, and inspect only PVEMods-owned config/launcher paths. Avoid inventing configuration locations or stop commands.
- **Superseded by later operator result:** Memtest failed on 2026-10-24, and the operator chose return rather than continuing the previously planned overnight run.

## Deferred GRUB and offload configuration request (after B1 failure)

- Before the crash, the operator requested cleaning experimental persistent boot parameters and setting up automatic TSO/GSO/GRO disablement on `nic0` and `nic1`. The assistant has **not edited host configuration**.
- The prior two-hour no-freeze report was superseded by the photographed ~2h43m Oops, so **do not treat a persistent offload hook as a validated cure**. Defer applying or testing these changes while assessing reliability/return. Read-only inspection of `/proc/cmdline`, `/etc/default/grub`, `/etc/kernel/cmdline`, `/etc/network/interfaces` and `interfaces.new` is still safe, but there is no need to reboot/reconfigure for cleanup alone.
- If host is eventually retained after reliability is established, the previously proposed `post-up ethtool` hook must first be checked against the actual network declarations and validated on a planned restart. It only controls TSO/GSO/GRO, not all offloading.

## Additional operator-confirmed workload and power observations (2026-10-24)

- OPNsense VM: 4 vCPUs pinned onto P-core CPUs according to the operator, 4 GiB assigned RAM; expected workload routing/NAT/stateful firewall and VLANs up to a **future** 2.5 Gbit/s WAN service, explicitly **no** PPPoE, IDS/IPS, VPN, or traffic inspection; optional light DNS ad blocking.
- Home Assistant VM: 4 vCPUs, 8 GiB assigned RAM. Possible future NAS VM, not active or provisioned as part of current trial. Existing host RAM inventory is about 16 GiB total; guest allocations total 12 GiB, leaving approximately 4 GiB nominal for host/overhead before considering allocation versus resident-use differences.
- Current WAN modem/link is 1 Gbit/s because the modem supports 1 Gbit/s, while main switches support 2.5 Gbit/s; this is **not evidence of NIC failure**.
- Wall meter currently reads approximately **24 W** with default BIOS, VMs reported active, and negligible traffic. This is total system AC power at that operating point, not CPU package wattage, nor a 2.5 Gbit/s throughput benchmark.
- Previously the operator tried BIOS PL1=20000 / PL2=30000 (interpreted as 20 W/30 W), observed noticeably less warm air by touch and core temperature about **49°C**. There is no matched, instrumented wall-power/throughput/stability comparison for that profile; do not treat it as proof of fault resolution.
- Current BIOS must remain **unchanged at defaults** until the active freeze/return decision is established.

## Working design — post-diagnosis energy/thermal profile (planning only)

- Intended long-term workload newly clarified on 2026-10-24: Proxmox hosting OPNsense and Home Assistant VMs; 2.5 Gbit/s fiber connection, multiple VLANs, an external Wi-Fi access point with three wireless networks, and three IP cameras recording locally to SD with email events. Optimize wall power and heat without impairing routing throughput, peak single-core responsiveness or reliability.
- The operator reattached offline manufacturer-firmware analysis files `DB19D005_BIOS_analysis.md` and `DB19D005_BIOS_IFR_options.txt`. These are conversation attachments, **not Git-controlled files or current NVRAM snapshots**. IFR candidates: Platform PL1 = 28000 and Platform PL2 = 45000 (apparently mW; actual active limits unverified), C-states enabled, Package C-State Limit Auto, Intel Speed Shift enabled, Turbo Mode enabled, Energy Efficient Turbo enabled, and thermal/fan policy controls. IFR declarations do not guarantee the machine exposes or applies each control.
- Candidate later approach, **not yet an experiment**: measure idle wall power, CPU package power, temperatures, effective power limits, WAN throughput/latency under real routing/NAT/stateful firewall; compare a carefully isolated PL1=20 W / PL2=30 W profile (already informally tried) against defaults only after host reliability is established. Preserve frequency scaling, Turbo and default C-states; distinguish CPU peak power reductions from whole-system idle savings. Intel PL3 is an optional duty-cycle-reactive peak limiter; Intel PL4 is a preemptive peak limiter. This BIOS IFR declares PL3 override Disabled and PL4 override Enabled with default numeric value 120000, actual effective BIOS/NVRAM state unverified. Do **not** adjust PL3/PL4, C-state, ASPM, Ethernet, fan or thermal protections speculatively.
- B1 has **failed** with an Oops despite the attempted default-BIOS/VM-on setup. No power benchmark or physical validation has been performed for this optimization objective. Defer all power tuning and permanent offload/boot adjustments pending the freeze/return decision.


## Next action

1. **Return/replacement is the operator-selected next action:** standalone Memtest reportedly failed, supporting instability of the memory subsystem independent of Proxmox. No clean-install Proxmox or Ubuntu testing is needed for this branch.
2. Photograph/preserve the Memtest error display (version, failing tests, error count, pass count) for seller/return evidence if still accessible. **No photograph or numerical test log has yet been supplied**.
3. If data must be retained, back up the existing OPNsense and Home Assistant VMs onto external storage before returning the device and verify they are readable. Handle personal information on the device appropriately within the seller's warranty/return terms; **backup is no longer a prerequisite to reinstallation**.
4. Keep the handoff **Active until the actual return/replacement is confirmed**, or the user explicitly closes the case. No hardware alteration or host change has been executed by the assistant.

## Blockers / open questions

- Exact remaining retailer return deadline not recorded; return has now been selected by operator. Do not overinvest in further testing or firmware flashing.
- **B1 failed**: a second photographed Oops and reported full-host freeze at ~2h43m, current offload state was not freshly verified before the crash; prioritize host reliability/return decision, not persistent offload tweaks.
- Lack of a controlled `igc`/offload baseline no longer blocks the chosen return because standalone Memtest failure independently demonstrates a memory-subsystem stability problem; original NIC-specific causal theories remain unproven.
- The photographed kernel Oops events are compatible with memory corruption; whether they were caused by the same failing memory-subsystem component detected by standalone Memtest remains unproven.
- No BOSGAME-approved I226-V NVM image or reliable ETrackID inventory yet; generic NVM versions alone insufficient.
- Full BIOS IFR inventory and prior large text log were conversation artifacts, not presently verified as long-term Git repository files.
