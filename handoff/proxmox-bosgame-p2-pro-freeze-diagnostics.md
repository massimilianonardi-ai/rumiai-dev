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
- The **latest direction** is to stress the actual workload with VM 100 and VM 101 running while host `nic0` and `nic1` have TSO/GSO/GRO disabled; on 2026-10-24 the operator reports the VMs active, but **has not supplied `qm` output, verified current offload state, or a timed B1 stability outcome**.
- Preserve distinction: disabling TSO/GSO/GRO is **not** disabling all offloading; checksum, VLAN and virtual/tap/guest offload settings remain unchanged.

## Acceptance scenarios

1. On BIOS defaults, same kernel and comparable VM/network workload, repeated runs show whether `igc` active vs excluded materially changes host stability.
2. If `igc` is implicated, isolate whether toggling host TSO/GSO/GRO or one of the two I226-V ports changes the failure, without unverified NVM flashing.
3. Provide return/keep recommendation based on observed reliability within available return period; never call a single short stable run proof of a repair.
4. If a freeze occurs, collect photo of physical console, uptime/wall time, complete prior boot journal and pstore; distinguish recorded evidence from hypotheses.

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
5. **B1 follow-up:** after prior instructions to start VM 100 and 101, the operator now reports both VMs active with factory-default BIOS and 24 W at the wall under negligible traffic. Still **no `qm list` output, `ethtool -k` confirmation of offloads, or measured duration/stability/freeze outcome for B1**. Do not infer a successful B1 test from the idle power observation.



## B1 stability observation and configuration maintenance plan (2026-10-24)

- Operator reports **two hours without a freeze** during the ongoing default-BIOS test with both VMs reported running and host TSO/GSO/GRO disablement intended. This is an observed survival window, not a timed command log or proof that all six features are currently disabled; operator plans to observe for approximately two more hours. Do not claim four-hour success before confirmation. Repeated prior events often occurred at approximately 2–3 hours.
- Operator requests removal of past experimental kernel parameters from the persistent boot configuration, and automatic reapplication of `ethtool -K nic0/nic1 tso off gso off gro off` after reboot. At this checkpoint **neither change has been performed on the host** (assistant has no shell access).
- Safe next procedure: verify `cat /proc/cmdline`, `proxmox-boot-tool status`, saved `/etc/default/grub` / `/etc/kernel/cmdline`, `/etc/network/interfaces` and any `interfaces.new`; preserve necessary root/boot, virtualization or passthrough args; remove only unwanted historical experiment flags; with GRUB use `update-grub` without reboot. For permanent NIC offloads consider `post-up /usr/sbin/ethtool -K nicX tso off gso off gro off` within existing `iface nicX inet manual` definitions, if confirmed present. Do not `ifreload -a`, `ifdown`, reboot, or apply pending network GUI changes in B1. On later **deliberate** reboot, check that hooks executed and all six booleans remain off and that VMs/network return.
- Changing the persisted bootloader or network configuration but not activating it does not modify the running test's kernel command line or the active NIC offload state, but should be documented separately from next-boot test conditions.


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
- The active B1 comparison retains BIOS factory defaults and the existing NIC offload/VM configuration until its result is recorded. No BIOS change, power benchmark or physical validation has been performed for this optimization objective. Completing or handing off a separate optimization lifecycle will be decided **after** the freeze/return decision.


## Next action

1. Obtain **actual timed outcome of the ongoing B1 trial**: boot/VM uptime, `qm list` confirmation of reported active VMs, and `ethtool -k` verification of TSO/GSO/GRO disabled on both NICs; record whether host stayed responsive or froze. Do not repeat already reported 24 W idle reading or VM sizing questions.
2. If freeze: preserve console photo; obtain `journalctl -b -1 -k` and full prior journal, approximate clock time/uptime; compare with A1 and overnight A0, note VM/offload confounds. Consider a **controlled** test with `igc` enabled and VMs off and offloads on/off, or isolate one I226-V at a time; choose based on urgency of return window.
3. If stable: run long enough to be informative given typical 2–3h failure timing, then (while BIOS/kernel/VM workload constant) restore one offloading feature at a time for causal reproduction **only if user judges return window allows it**. A single stable period is not causal proof.
4. If host freezes again under multiple materially distinct configs, prioritize **return/replacement** over speculative firmware flashing. Memtest86+ 4 passes and minimal external-boot diagnostics are fallback to investigate RAM/IMC/mainboard, but not at expense of deadline.
5. Keep this handoff synchronized after material new results, and apply `CONSISTENCY-GATE.md` to any repository edits.

## Blockers / open questions

- Exact remaining retailer return deadline not recorded. Do not overinvest in extensive testing or firmware flashing.
- Operator reports **two hours without a freeze** on B1 with VM activity, but the current offload state is not freshly verified and the planned four-hour observation has not yet concluded.
- An independent, sustained baseline with BIOS defaults / `igc` enabled / VMs off / default offloads has not been recorded; causal assessment remains tentative.
- The earlier Oops may be from altered BIOS conditions or an unrelated memory corruption bug; not established to be the same freeze mechanism as earlier silent hangs.
- No BOSGAME-approved I226-V NVM image or reliable ETrackID inventory yet; generic NVM versions alone insufficient.
- Full BIOS IFR inventory and prior large text log were conversation artifacts, not presently verified as long-term Git repository files.
