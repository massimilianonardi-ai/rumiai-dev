# Proxmox replacement hardware selection

Status: Active
Updated: 2026-10-25 (Europe/Rome)

## Goal

Select practical, purchasable and energy-efficient desktop hardware for a 24/7 Proxmox VE host replacing the failed BOSGAME P2 Pro. Separate this independent acquisition/design workflow from the active hardware-return/freeze diagnostic handoff `handoff/proxmox-bosgame-p2-pro-freeze-diagnostics.md`. Avoid committing to an unverified motherboard or claiming board-level idle consumption without a matched measurement.

## Current repository revisions

- `massimilianonardi-ai/rumiai-dev`: verify current remote main HEAD on every resumption. Initial preflight 2026-10-25: `450a2555e187c3803d988a2e2cdc27822c112104`.
- No product or firmware repositories to change. Host hardware is externally purchased by operator, not controllable from GitHub.

## Applicable canonical sources

- `README.md`, `RULES.md`, `CONSISTENCY-GATE.md`, `specifications/README.md`, `handoff/README.md`
- `handoff/proxmox-bosgame-p2-pro-freeze-diagnostics.md` is an independent handoff for return of defective former host; read only to recover workload and hardware rationale when relevant.

## Fixed task-local choices

- Desktop, user-replaceable Intel CPU, **Core Ultra 7 265 or Core Ultra 9 285** (whichever has a better offer), socket LGA1851, integrated display; avoid high-priced scarce T/tray variants.
- **Non-negotiable:** BIOS genuinely allows independent manual numerical settings of **PL1 and PL2**, including sustained power appreciably **below 65 W**. Do not equate listed Intel processor base power, BIOS marketing, or menu presence with verified low-value acceptance. Seek model + BIOS revision evidence and ideally screenshot or direct manufacturer reply; verify limits actually enforced at runtime after assembling.
- **Non-negotiable:** low *whole-system idle electrical consumption*, with wall-meter results preferred. Motherboard-only idle numbers for exact board and matched CPU/config often unavailable; don't invent. PL1/PL2 primarily limit CPU under load, not necessarily idle wall watts. Consider chipset, power supply light-load efficiency, controller inventory and idle device C-states.
- **Non-negotiable expansion:** PCIe x16 with CPU-connected bandwidth/physical space for future NVIDIA GPU used for local AI, **plus a physically accessible, electrically >=x4 PCIe slot for a four-port Intel 2.5GbE NIC**. Verify slot spacing with a 2–4-slot GPU, electrical lane widths, sharing/mutual exclusion, IOMMU and chassis capacity. Four LAN ports are expected through PCIe expansion, not necessarily motherboard-integrated. Two previously owned UGREEN 2.5GbE adapters are **USB**, not PCIe; useful for secondary/test use, not planned as primary 24/7 firewall WAN/LAN.
- Highly preferred modern **Thunderbolt 4 / USB4 / USB-C**; high physical USB port count. SATA/NVMe counts and RAID features **not primary criteria**; sufficient OS storage is implicit. Baseline applications: Proxmox/KVM, OPNsense VM WAN/LAN VLANs (future 2.5 GbE), Home Assistant VM, possible ZFS-managed storage and future local AI NVIDIA. Initial old VM nominal RAM 4+8 GiB; final RAM hardware TBD.
- Budget-conscious and vendor-supported retail boards; no fixed total budget. Avoid unverified claims about returned BOSGAME specific fault component; standalone Memtest failure reported in separate handoff.

## Acceptance scenarios

1. Select CPU 265 or 285 based on offers without changing compatible LGA1851 motherboard.
2. Model-specific BIOS permits and **actually applies** low PL1/PL2 values, with defaults restorable.
3. Idle whole-host wattage is measured with integrated graphics, intended NIC installed and future NVIDIA absent; compare meaningful numbers under matched workloads.
4. Quad-port PCIe Intel NIC and future wide NVIDIA GPU can coexist physically and electrically; all critical firewall Ethernet ports independent from temporary USB adapters.
5. Required rear/front USB-C/TB4 and USB-A counts verified, price and supported BIOS version known before final purchase.

## Working design (candidates and evidence checked 2026-10-25)

- **ASUS PRIME Z890-P WIFI**, ASUS Intel 800-series BIOS guide linked from this board's support page: `Long Duration Package Power Limit` (PL1) numeric **1–4095 W**, independent `Short Duration Package Power Limit` (PL2) option, adjustable `Package Power Time Window`. The guide explicitly warns options vary by CPU and DIMM; **do not call 285/265 at PL1=25–35W / PL2=45–65W on retail BIOS proven without exact firmware confirmation**. Physical slots: CPU PCIe 5.0 x16, chipset 2x PCIe 4.0 x4 plus a x1. Rear 1x Thunderbolt 4 USB-C 40Gb/s, assorted A, rear Realtek 2.5GbE; 4 M.2. Product: https://www.asus.com/it/motherboards-components/motherboards/prime/prime-z890-p-wifi/ ; BIOS guide: https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/E25827_Intel_800_Series_BIOS_manual_EM_WEB.pdf?model=PRIME+Z890-P .
- **ASRock Z890 Pro-A, NON-WiFi**: retail Italian offer roughly €139–180 before verification of shipping/current availability; CPU-connected PCIe 5.0 x16 + 2 chipset PCIe 4.0 x4, **one** rear Thunderbolt 4/USB4 USB-C 40Gb/s **plus one** rear USB-C 20Gb/s (do not confuse with Z890 Pro RS, which has 2 TB4). Multiple USB-A, front C 20Gb/s, 4 M.2 and 2.5GbE Realtek. The power-limit numeric minimum **NOT verified**. Official: https://asrock.com/mb/Intel/Z890%20Pro-A/index.it.asp . This is a strong price/port contender only after PL1/PL2 BIOS validation.
- **ASRock Z890 Pro RS, NON-WiFi**: ~€180–220, same GPU/NIC PCIe slot topology, **2 rear Thunderbolt 4 USB-C**, numerous USB-A; unverified exact BIOS PL1/PL2 lower limits and whole-system idle. Official: https://www.asrock.com/mb/Intel/Z890%20Pro%20RS/ .
- **MSI PRO B860-P (non-WiFi)**: ~€167–210 indicative Italy; CPU 5.0 x16 + chipset 4.0 x4 + two x1, **1 TB4 USB-C rear**, USB 10Gbps Type-C front, many A, 2.5GbE? MSI official lists **Realtek 8126 5GbE**. B860 chipset may allow fewer expansions but should not be prejudged for idle vs Z890; BIOS PL1/PL2 custom low watt **unverified**. Official: https://it.msi.com/Motherboard/PRO-B860-P/Specification .
- **MSI PRO Z890-A WIFI**: CPU 5.0 x16 + 2 chipset 4.0 x4, 2 TB4 USB-C, more USB A and C; >~€300 retail offer, less attractive on budget without matched idle evidence. Official: https://it.msi.com/Motherboard/PRO-Z890-A-WIFI .
- Real idle comparative evidence can be misleading: third-party tests of *other* B860 and Z890 systems report ~45–52 W total idle with discrete Nvidia GPU, not motherboard stand-alone nor exact candidate measurements; do not extrapolate to BIOS/CPU-only Proxmox at 20–25W.
- Intel NIC quad-port requires PCIe electrical >=x4 and compatible Intel controller/Proxmox Linux driver, not merely four Ethernet connectors. Price and exact card TBD.
- ASRock site Z890 family microsite inconsistently lists 2 TB4 on Pro-A in a feature table but **explicit footnote and dedicated model spec confirm only 1 TB4 + 1 USB-C 20 Gb/s**. Prefer model-specific spec.
- Models' precise slot spacing with future thick NVIDIA cards and sharing need layout diagram confirmation before purchase.
- Research is not approval to purchase. No hardware ordered or tested by assistant.

## More compact readily purchasable boards (2026-10-25 research)

- Operator provided Amazon.it product URL `https://www.amazon.it/dp/B0DJDFX4M1/` and identified it as **ASUS PRIME Z890-P without Wi-Fi**, the only easily obtainable board in the *previous* ATX shortlist. Do not conflate with **PRIME Z890-P WIFI** already in the working design: the non-WiFi board has **rear USB-C 20 Gb/s DP Alt**, **NOT an integrated Thunderbolt 4 rear port** (the WIFI SKU has rear TB4 40 Gb/s). Both are **ATX 30.5×24.4 cm**, 1x CPU PCIe5 x16, 2x chipset PCIe4 electrically x4 in full-length sockets, allowing dedicated NIC plus future GPU subject to physical slot clearance. ASUS SKU-specific specifications: `https://www.asus.com/it/motherboards-components/motherboards/prime/prime-z890-p/techspec/`; direct comparison in ASUS Z890 product press release: `https://press.asus.com/news/press-releases/asus-unveils-z890-motherboards-intel-core-ultra-ai/`.
- **mATX 24.4×24.4cm options located for sale in Italy** (market offers fluctuate):
  - **ASUS PRIME B860M-A WIFI**, offered on Amazon.it approx **€190–194**, 1 CPU PCIe5 x16, 1 chipset PCIe4 physical x16 / electrical **x4**, x1 additional, rear **USB-C 20Gbps** and front USB-C 10Gbps, **no rear TB4** (internal TB/USB4 header only). Intel B860, rear 8 USB incl many USB2, 2.5G Realtek. Manufacturer spec `https://www.asus.com/it/motherboards-components/motherboards/all-series/prime-b860m-a-wifi/techspec/`.
  - **ASUS PRIME Z890M-PLUS WIFI**, Italian retail/marketplace **~€234–238** (Amazon.it market offer seen on Trovaprezzi), Z890, 1 CPU PCIe5 x16 + 1 electrically **x4** PCIe4 full-length + 2 electrically x1, rear **USB-C 20Gbps NOT Thunderbolt 4**; front USB-C only 5Gbps. Official `https://www.asus.com/it/motherboards-components/motherboards/prime/prime-z890m-plus-wifi/`, full spec `https://www.asus.com/us/motherboards-components/motherboards/prime/prime-z890m-plus-wifi/techspec/`.
  - **MSI PRO B860M-A WIFI**, Amazon.it listed **~€242**, rear **Thunderbolt 4 40Gbps USB-C** plus USB-C 5Gbps, LAN Realtek 5GbE, CPU PCIe5 x16 and chipset PCIe4 electrical x4 full-length (physical PCI_E4 fourth slot), with 2 other x1 full-length PCIe connectors, 24.4×24.4cm. Official `https://www.msi.com/Motherboard/PRO-B860M-A-WIFI/Specification`. Inspect exact PCIe x4 physical clearance for 3–4-slot Nvidia card before committing.
- **mini-ITX 17×17cm** generally provides just one PCIe x16 slot. Example official ASUS ROG STRIX Z890-I only 1 PCIe5 x16, `https://rog.asus.com/it/motherboards/rog-strix/rog-strix-z890-i-gaming-wifi/spec/`; it **cannot directly accommodate both future NVIDIA and separate four-port Intel PCIe NIC** without complex riser/bifurcation. Do not promote mini-ITX against the present mandatory PCIe expansion requirement.
- ATX physical extra slot spacing is advantageous for future **3–4 slot-thick NVIDIA** and permanent x4 quad NIC; mATX x4 socket can be obscured by the GPU even though the board electrically supports both. Must check specific layout/slot cover positions and case before buying. Physical miniaturization **does not itself demonstrate lower idle wattage**.
- **PL1/PL2 hard gate STILL UNVERIFIED for actual non-K Core Ultra 7 265 / 9 285 and specific BIOS revision** on all newly found mATX models, notwithstanding ASUS shared Intel 800 BIOS guide. Do not recommend any board as fully compliant until confirmed. Neither B860 nor Z890 idle wall consumption for identical configurations is established; don't infer B860 lower idle from chipset classification.
- New operator question was whether listed boards are ATX and smaller formats exist; no new chassis-size constraint has been fixed. Availability observation concerns the *previous* shortlist; the new micro-ATX candidates surfaced in market listings, not guaranteed stock at the user's preferred retailer.

## Completed

- Identified compatible LGA1851 CPU pair and initial motherboard shortlist from official model specifications and Italian market price indications.
- Verified a documented **PL1 numeric range** and distinct PL2 field on ASUS Intel 800 BIOS guide; other motherboards' **actual minimum** still unverified.
- Identified need for future GPU x16 plus NIC x4 coexistence and distinction between TDP limits and platform idle power.

## Current state

Research/shortlist only. Operator confirms easy availability for **ASUS PRIME Z890-P non-WiFi ATX**, now distinguished from earlier WIFI shortlist. Additional mATX retail candidates discovered. No motherboard has passed **all** hard gates (exact BIOS low-power settings *and* idle consumption measurement in a comparable setup *and* physical slot coexistence). ASUS shared Intel 800 guide has strongest public PL1/PL2 descriptions, not tested enforcement with exact CPUs.

## Next action

1. Compare model-specific exact BIOS revision manual/screenshots or support replies on independent PL1=25–35W and PL2=45–65W values for non-K Ultra 7 265 / 9 285.
2. Compare motherboard and full-system idle measurements under matched CPU/PSU/devices or qualify estimates as unknown, and prioritize light-load efficient PSU.
3. Compare available **ATX PRIME Z890-P (non-WiFi, USB-C20, no TB4)** with micro-ATX ASUS PRIME B860M-A WIFI, PRIME Z890M-PLUS WIFI, and MSI PRO B860M-A WIFI (rear TB4). Verify PCIe x4 remains physically accessible with a wide NVIDIA (slot spacing in 4-slot mATX case), chipset uplink/sharing and case/airflow; verify needed rear USB counts.
4. Price final board + four-port NIC + RAM + PSU + case/cooling and ensure actual vendor/return policy is reasonable.

## Blockers / open questions

- Minimum accepted PL2 and runtime enforcement on exact ASUS BIOS revision + non-K CPU unverified; equivalent on ASRock/MSI unverified.
- Measured idle energy use under the intended host/Proxmox profile unavailable for shortlisted boards.
- NVIDIA model/slot thickness/power unknown; select enclosure and slot layout with safety margin.
- No fixed total purchase budget, case dimensions or exact quad-port Intel NIC SKU yet.
