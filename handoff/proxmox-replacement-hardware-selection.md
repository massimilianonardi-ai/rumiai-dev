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
- **Form factor now fixed to ATX**, not micro-ATX/mini-ITX. For motherboard ranking: mandatory independent low manual PL1/PL2 and PCIe electrically >=x4 quad Intel LAN NIC alongside CPU PCIe x16 future NVIDIA; **priority order Thunderbolt onboard, then USB 5Gbps-or-better port inventory, then USB-C availability**. "USB5" is treated provisionally as USB 5Gbps (not a USB standard version name), pending an explicit correction if the user intended something else. SATA/NVMe counts and RAID features **not primary criteria**; sufficient OS storage is implicit. Baseline applications: Proxmox/KVM, OPNsense VM WAN/LAN VLANs (future 2.5 GbE), Home Assistant VM, possible ZFS-managed storage and future local AI NVIDIA. Initial old VM nominal RAM 4+8 GiB; final RAM hardware TBD.
- Budget-conscious and vendor-supported retail boards; no fixed total budget. Avoid unverified claims about returned BOSGAME specific fault component; standalone Memtest failure reported in separate handoff.

- **Operator-fixed easily available motherboard pair (2026-10-25):** **ASUS TUF GAMING Z890-PRO WIFI** and **ASUS PRIME Z890-P non-WiFi** only. Other earlier ranked motherboards remain prior comparison evidence, not active purchase alternatives. Both ATX; low BIOS PL2 acceptance and runtime enforcement remain unverified. PRIME non-WiFi has no rear Thunderbolt 4; TUF provides two rear TB4.
- **Operator-fixed quad 2.5GbE PCIe NIC pair (2026-10-25):** **ZimaBoard ZBA022-EU** (marketed 4x Intel I226) and **KALEA-INFORMATIQUE 11870587** (marketed 4x Intel I226 with PLX bridge). KALEA **11628082** has older Intel I225 controllers and is excluded by the I226-or-better requirement. Neither remaining card purchased or physically validated. Before purchase confirm seller product revision/SKU, controller IDs, PCIe bridge/switch, power draw, Proxmox/FreeBSD driver support, passthrough IOMMU topology, physical slot position and four-port aggregate performance.

## Acceptance scenarios

1. Select CPU 265 or 285 based on offers without changing compatible LGA1851 motherboard.
2. Model-specific BIOS permits and **actually applies** low PL1/PL2 values, with defaults restorable.
3. Idle whole-host wattage is measured with integrated graphics, intended NIC installed and future NVIDIA absent; compare meaningful numbers under matched workloads.
4. Quad-port PCIe Intel NIC and future wide NVIDIA GPU can coexist physically and electrically; all critical firewall Ethernet ports independent from temporary USB adapters.
5. Required rear/front USB-C/TB4 and USB-A counts verified, price and supported BIOS version known before final purchase.

## Earlier candidate comparison evidence (before final two-board shortlist; 2026-10-25)

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

## Earlier ATX-ranked comparison evidence (superseded by operator-fixed ASUS pair, 2026-10-25)

The operator **explicitly fixes ATX format** and ranks motherboards primarily by BIOS PL1/PL2 freedom, NIC PCIe x4 compatibility, then **onboard Thunderbolt**, next **USB5 (provisionally interpreted as USB 5Gbps, counting 10/20Gbps as faster)** and finally USB-C. Previous micro-ATX research remains comparison evidence but is **not the active selection scope**.

Ranked candidates, all LGA1851 ATX with CPU PCIe 5.0 x16 for future Nvidia plus chipset PCIe 4.0 electrical x4 for 4x2.5GbE Intel NIC. All actual PL1/PL2 minima **unverified with Ultra 7 265 / Ultra 9 285 non-K** and motherboard firmware, so this is an evidence-ranked *shortlist*, not list of finally certified boards. Prices are retailer-search indicative and stock/shipping need checking.

1. **ASUS TUF GAMING Z890-PRO WIFI**, market ~€318, **2 rear TB4 40Gbps**, **6 rear USB 10Gbps Type-A**, 1 CPU x16 + 1 chipset x16-shaped electrical x4 + 1 chipset physical x4, Intel 2.5GbE onboard. ASUS Intel 800 BIOS manual PL1 and PL2 distinct; PL1 documented 1–4095 W. Manufacturer: https://www.asus.com/it/motherboards-components/motherboards/tuf-gaming/tuf-gaming-z890-pro-wifi/techspec/ .
2. **MSI MAG Z890 TOMAHAWK WIFI**, market ~€338, **2 rear TB4**, rear 4 USB 5Gbps A, 3 USB 10Gbps A and 1 USB 10Gbps C; 1 CPU x16 + 2 chipset electrical x4 in full-length slots, **Intel Killer E5000B 5GbE**. MSI Intel 800 BIOS guide independently lists editable Long/Short Duration Power Limit (W). Manufacturer: https://www.msi.com/Motherboard/MAG-Z890-TOMAHAWK-WIFI/Specification .
3. **MSI PRO Z890-A WIFI**, market ~€337, **2 rear TB4**, same rear 4x5Gbps A + 3x10Gbps A + 1x10Gbps C; 1 CPU x16 + 2 chipset x4, Realtek 5GbE. Manufacturer: https://www.msi.com/Motherboard/PRO-Z890-A-WIFI/Specification .
4. **ASRock Z890 Pro RS (non-WiFi)**, market ~€191, **2 rear TB4**, rear 2 USB 5Gbps A + 1 USB 10Gbps A + 4 USB2, front USB-C 20Gbps header; 1 CPU x16 + 2 chipset x4, Realtek 2.5GbE. ASRock Intel 800 BIOS guide documents independent PL1/PL2 in watts but not firmware minimum. Manufacturer: https://www.asrock.com/mb/Intel/Z890%20Pro%20RS/index.it.asp .
5. **ASRock Z890 Pro-A (non-WiFi)**, market ~€185, **1 rear TB4**, **1 rear USB-C 20Gbps** in addition, 1 USB 10Gbps A + 2 USB 5Gbps A; CPU x16 + 2 x4. Manufacturer https://www.asrock.com/mb/Intel/Z890%20Pro-A/index.it.asp .
6. **MSI PRO B860-P (non-WiFi)**, market ~€199, **1 rear TB4**, 2 USB 5Gbps A + 2 USB 10Gbps A; CPU x16 + **one** chipset x4 (other full-length physical slots electrical x1). Manufacturer https://www.msi.com/Motherboard/PRO-B860-P/Specification .
7. **ASUS PRIME Z890-P WIFI**, market ~€261, **1 rear TB4**, 2 USB 5Gbps A + 1 USB 10Gbps A; CPU x16 + 2 x4. Manufacturer https://www.asus.com/it/motherboards-components/motherboards/prime/prime-z890-p-wifi/ .
8. **ASUS PRIME Z890-P non-WiFi**, the operator's easy-to-find Amazon.it listing `https://www.amazon.it/dp/B0DJDFX4M1/`, market ~€212 other sellers, **no integrated TB4 rear**, 1 rear USB-C 20Gbps + 2 USB 5Gbps A +1 USB 10Gbps A; CPU x16 + 2 x4. Manufacturer https://www.asus.com/it/motherboards-components/motherboards/prime/prime-z890-p/techspec/ .

Manufacturer official BIOS manuals *read and checked as PDFs with page screenshots* (not hands-on physical firmware validation):
- ASUS PRIME/TUF Intel 800 series BIOS PDF (Jan 2025), PDF indexed pages **37 and 38**: PL1 numeric in watt **1–4095**, separate PL2 and Tau; https://dlcdnets.asus.com/pub/ASUS/mb/13MANUAL/E25827_Intel_800_Series_BIOS_manual_EM_WEB.pdf?model=PRIME+Z890-P .
- MSI Intel 800 BIOS PDF, PDF indexed page **42**: `Long Duration Power Limit (W)`, `Short Duration Power Limit (W)` and Tau; https://download.msi.com/archive/mnu_exe/mb/Intel800BIOS_English.pdf .
- ASRock Intel 800 BIOS PDF, PDF indexed page **38**: `Long Duration Power Limit` (PL1 W) and `Short Duration Power Limit` (PL2 W); https://download.asrock.com/Manual/Software/Intel%20Z890/Software_BIOS%20Setup%20Guide_English.pdf .

Source documents describe family-level BIOS controls, **not proof the exact candidate board/BIOS and non-K CPU accept and enforce 25–35 W / 45–65 W**. Need specific revision/manual/BIOS evidence or vendor explicit confirmation, then physically measure after assembly. All eight have model-level PCIe lane counts but verify GPU slot thickness and physical x4 clearance; no motherboard whole-system idle watt comparison measured or claimed. Retail price-search was 2026-10-25 and availability may be different by purchase date.

## RAM working options (2026-10-25; no final choice yet)

- Both selected ASUS Z890 boards specify 4 desktop DDR5 slots, non-ECC unbuffered, dual-channel, and nominal support for UDIMM/CUDIMM. Intel Core Ultra 7 265 / 9 285 memory support up to 6400 MT/s under relevant configurations. DDR5 on-die ECC is not full CPU/memory-path ECC; boards do not advertise system ECC.
- User wants to minimize RAM expense while prioritizing stability: 16 GB acceptable at launch, more RAM attractive for future guests and NAS. Former VM allocations: OPNsense 4 GiB plus Home Assistant 8 GiB. The host needs headroom, particularly with future ZFS/NAS.
- **16 GB budget candidate:** Crucial desktop UDIMM **CT16G56C46U5**, **1×16 GB DDR5-5600 CL46 JEDEC 1.1 V**, non-ECC. Alone it runs single-channel and allows adding another 16 GB later; future separately sourced modules may require retraining/speed fallback. Alternative verified manufacturer specification: Kingston ValueRAM **KVR56U46BS8-16**, 1Rx8 non-ECC 5600 CL46 1.1 V. Specific ASUS QVL qualification remains open.
- **32 GB capacity candidate:** Crucial desktop UDIMM kit **CT2K16G56C46U5**, **2×16 GB DDR5-5600 CL46 JEDEC 1.1 V**, non-ECC, dual-channel, leaves two slots empty. Verify exact board QVL and BIOS revision; avoid XMP/OC.
- Indicative Italian October 2026 catalog ranges for 16 GB Crucial ~€230–315 depending seller/date; an older indexed €211 quotation may be stale. 2×16 GB Crucial kit ~€540–550. Search listings frequently mix physically incompatible notebook SO-DIMM and desktop UDIMM; verify exact product/SKU and current checkout. No purchase decision made.
- These remain two proposed RAM **configurations**, not fixed purchase choices. 1×16 minimizes outlay and offers upgrade path at the cost of single-channel bandwidth; matched 2×16 provides capacity and dual-channel; 2×8 is less future-proof.

## RAM comparison checkpoint (2026-10-25)

User compared six 32GB (2x16GB) DDR5 UDIMM kits:
- Corsair CMG32GX5M2B5600Z40: 5600 CL40 1.25V profiled, base SPD 4800 1.1V.
- Crucial CP2K16G60C36U5B: 6000 CL36 1.35V profiled; base JEDEC 5600 CL46 1.1V, best candidate for no-XMP operation.
- Patriot PVV532G600C36K: 6000 CL36 profiled, base 4800 CL40 1.1V. Patriot materials conflict on profile voltage (older matrix 1.25V, specific datasheet and newer overview 1.35V).
- Corsair CMG32GX5M2B5200Z40: 5200 CL40 1.25V profiled, base SPD 4800 1.1V.
- Patriot PVV532G600C30K: 6000 CL30 1.35V profiled, base SPD 4800 CL40 1.1V.
- Patriot PVV532G640C32K (new sixth user-sourced kit): Viper Venom 32 GB (2x16 GB) DDR5 UDIMM; official Patriot SKU sheet specifies **XMP 6400 MT/s CL32-40-40-84 1.4 V** versus **base JEDEC 4800 MT/s CL40-40-40-77 1.1 V**, non-system-ECC, 43 mm module height; official reference https://gzhls.at/blob/ldb/1/c/0/c/52741725d8732ee343a468ec9863a1b8e4e7.pdf . Italian listing indicative ~EUR 452+ (not checkout confirmed). This adds no JEDEC/no-OC benefit over the other Patriot kits; Crucial CP2K16G60C36U5B stays the provisional preferred 32 GB kit, conditional on ASUS QVL and real price.
Both ASUS Z890 boards support DDR5 UDIMM, but complete QVL certification for each exact module has not been confirmed: published lists are dynamically paginated. No purchase decision fixed; the Crucial is a preliminary preference only, dependent on real retailer price and final QVL check.
## 2026-10-25 selection checkpoint: RAM and PSU

User fixes **32 GB (2x16 GB)** RAM alternatives: **Crucial CP2K16G60C36U5B** first, **Patriot PVV532G600C36K** second, both quoted at slightly below EUR 500. First operates at JEDEC 5600, second at JEDEC 4800. Exact ASUS memory QVL remains unconfirmed. Do not treat older 16 GB option as current shortlist.

PSU research for 24/7 low-idle Proxmox: candidate A **be quiet! Pure Power 13 M 750W BP026EU**, ATX 3.1, modular, native 12V-2x6, 2 EPS 8-pin CPU cables; maker reports 230V conversion efficiency 71.9% at 2% and 90.6% at 10% output load; Italian observed EUR 123.90 excluding shipping, 10-year warranty. https://www.bequiet.com/en/powersupply/6019 . Candidate B **Seasonic CORE GX-650 V2 ATX 3.1**, modular, 12V-2x6, two EPS 8/4-pin CPU cables, 7-year warranty, Italian observed EUR 97.98; low-output-load 230V efficiency not established from directly comparable measurements. https://seasonic.com/core-gx-atx-3-2024/ . Both ASUS board candidates have 2 EPS 8-pin CPU sockets. Final PSU selection is not fixed until budget and future Nvidia power envelope are clearer. PSU output ratings do not imply fixed AC wall consumption; measure final 24/7 host idle at wall. Still to select: CPU cooler, ATX chassis, NVMe, chassis airflow/fans. The future Nvidia GPU and optional NAS disks are deferred expansion items.

## PSU comparison extension — be quiet! Power Zone 2 750W (2026-10-25)

User asked specifically about **be quiet! Power Zone 2 750W BP006EU**, in comparison with already short-listed **Pure Power 13 M 750W BP026EU**. Both are ATX 3.1 modular, native 12V-2x6 and 10y warranties; Power Zone 2 is 80 PLUS Platinum, 140 mm fan, Pure Power 13 M 80 PLUS Gold, 120 mm fan, both semi-passive. The Power Zone 2 supports two CPU power leads (P4+4 and P8), 3 PCIe 6+2 and 6 SATA; Pure Power provides P4+4 plus P8, 4 PCIe 6+2 and 6 SATA.

**Crucial verified evidence:** same-independent-laboratory Cybenetics 230V low-load tests show **Power Zone 2 / Pure Power 13 M efficiencies**, respectively:
- 20 W DC: **70.935% / 77.598%** (AC input 28.186 / 25.781 W).
- 40 W DC: **82.766% / 85.668%** (AC input 48.321 / 46.699 W).
- 60 W DC: **87.716% / 88.802%**.
- 80 W DC: **89.919% / 90.855%**.

Sources: https://www.cybenetics.com/evaluations/psus/2681/en/ (Power Zone 2 750W), https://www.cybenetics.com/evaluations/psus/2844/cert/ch/ (Pure Power 13 M 750W); manufacturer https://www.bequiet.com/en/powersupply/5821 and https://www.bequiet.com/en/powersupply/6019 . Therefore Power Zone 2 Platinum is NOT the more-efficient PSU at the intended ultra-low DC loads, despite its higher overall certification. At continuous 20 W output, the measured AC delta is about 2.4 W, i.e. ~21 kWh/year if sustained all year, not a proven difference in the as-yet-unbuilt Z890 host.

An indicative Italian comparison site lists Power Zone 2 BP006EU at ~EUR 118 excluding shipping, with some shipped offers ~EUR 123; no price guarantee (https://www.idealo.it/confronta-prezzi/205850625/be-quiet-power-zone-2-750w.html). The previous Pure Power candidate retains preference for **24/7 very low idle power**; Power Zone 2 is a technically sound alternate if acquisition price and priorities favor it, without a purchase lock. Neither 750 W option is confirmed appropriate for unknown future GPU wattage. Physical PSU dimensions 160x150x86 mm each; case compatibility TBD.

## 2026-10-25 Pure Power 13 M availability and revised PSU comparison

Operator says locally obtainable **be quiet! Pure Power 13 M** retail prices are **1200 W EUR 126**, **1000 W EUR 145**, and **850 W EUR 139**; smaller Pure Power 13 M capacities not available from their practical supplier. User did NOT finalize PSU. The **1200 W** is cheapest of the obtainable family, surprisingly lower than 850/1000. Verify seller, VAT, warranty, shipping and exact European article **BP029EU** before acquisition. Official https://www.bequiet.com/en/powersupply/6022 .

Matched absolute low-output-load independent Cybenetics 230V **40 W DC** tests:
- 850 W: 83.944% / AC 47.651 W — https://www.cybenetics.com/evaluations/psus/2841/cert/en/
- 1000 W: 81.068% / AC 49.346 W — https://www.cybenetics.com/evaluations/psus/2834/en/
- 1200 W: 81.577% / AC 49.047 W — https://www.cybenetics.com/evaluations/psus/3127/cert/en/
- Earlier 750 W reference (not currently easy for operator to obtain): ~85.67% / AC ~46.7 W at 40 W DC — https://www.cybenetics.com/evaluations/psus/2844/cert/ch/ .

Thus 850 W saves ~1.40 W at a sustained 40 W DC output versus 1200 W; at hypothetical EUR 0.30/kWh and 24/7, ~EUR 3.67/year. The EUR 13 purchase-price premium of 850 W would take ~3.5 years of that *same hypothetical constant-load difference* to repay; not a host consumption forecast. Do not compare efficiency at different *percentage* loads. Actual target desktop idle still unmeasured; PSU high-watt rating does not mean constant high draw. Cybenetics 1000 W 20 W load row appears internally inconsistent (reported efficiency vs DC/AC); avoid basing a decision on that point until independently checked.

**Architecture revision:** 1200 W Pure Power 13 M is built by **CWT** whereas smaller 850/1000 variants are **FSP** in Cybenetics's reviewed units; similar marketing name does not imply identical internals. 1200 W rated model still ATX 3.1, 12V-2x6 600 W, 2 EPS CPU cables, 10-year warranty, 160 mm depth, fully modular and semi-passive. The attractive low price and future NVIDIA room favor a provisional 1200 W recommendation *among the operator's three easy-to-obtain Pure Power 13 M models*, conditional on genuine item and return policy; 850 W could win total cost over long 24/7 ultra-low use, or a smaller/different PSU could save more. Do not lock wattage before future GPU requirement and retailer validation.

## Fixed PSU alternatives — 2026-10-25

Operator explicitly fixes **be quiet! Pure Power 13 M 1200W BP029EU** as first choice and **be quiet! Power Zone 2 1200W BP030EU** as second. These supersede the previous 750W/850W/1000W/Seasonic alternatives for the active shortlist. The known Pure Power 1200W offer is EUR 126; Power Zone 2 purchase price not stated. Neither PSU has been purchased or physically validated.

**Matched Cybenetics EU 230V light-load tests, actual 20W and 40W DC outputs:**
- Pure Power 13 M 1200W: at 20W DC, 27.542W AC (72.586%); at 40W DC, 49.047W AC (81.577%).
- Power Zone 2 1200W: at 20W DC, 32.607W AC (61.345%); at 40W DC, 55.763W AC (71.725%).
- At 30W DC, simple *linear interpolation of AC input*, not a direct measurement: Pure Power ~38.295W AC (~78.34%); Power Zone 2 ~44.185W AC (~67.90%). Differences in AC input ~5.89W at 30W DC and ~6.72W at 40W DC. Distinguish output watts from user wall-meter input watts.
- **Pure Power 13 M is clearly the more efficient of these two specific 1200W units at 20-40W DC**, despite being marketed Gold versus the Power Zone 2 Platinum. Higher-load certification cannot establish very-low-load efficiency.

Reports: https://www.cybenetics.com/evaluations/psus/3127/cert/en/ (Pure Power, issued Jan 20 2026) and https://www.cybenetics.com/evaluations/psus/3042/cert/ (Power Zone 2 EU, issued Nov 21 2025). Official EU models: https://www.bequiet.com/en/powersupply/6022 and https://www.bequiet.com/en/powersupply/6013 . No matched physical host idle measurement; the actual desktop system wattage is not established. Both have ATX 3.1, 10-year warranty, native GPU 12V-2x6 and two EPS CPU connectors. Future GPU actual load remains unknown.

## Completed

- Identified compatible LGA1851 CPU pair and initial motherboard shortlist from official model specifications and Italian market price indications.
- Verified a documented **PL1 numeric range** and distinct PL2 field on ASUS Intel 800 BIOS guide; other motherboards' **actual minimum** still unverified.
- Identified need for future GPU x16 plus NIC x4 coexistence and distinction between TDP limits and platform idle power.

## Current state

Fixed shortlist has two independent choices per completed component: CPUs Core Ultra 7 265 / Ultra 9 285; motherboards ASUS TUF GAMING Z890-PRO WIFI / ASUS PRIME Z890-P non-WiFi; quad-port Intel I226 NICs ZimaBoard ZBA022-EU / KALEA 11870587. Operator now fixes 32 GB RAM pair Crucial CP2K16G60C36U5B (first) and Patriot PVV532G600C36K (alternative), both below EUR 500; QVL confirmation remains pending. PSU pair now fixed: be quiet! Pure Power 13 M 1200W BP029EU first; be quiet! Power Zone 2 1200W BP030EU second. Exact measured Cybenetics 230V light-load data favor Pure Power; real Proxmox whole-system draw remains unknown. This workflow is independent of the defective BOSGAME return. No purchases, BIOS low-limit physical experiment, DIMM qualification or idle-power measurements performed by assistant.

## Next action

1. Next select CPU cooler, ATX case and NVMe, ensuring adequate NIC x4 slot clearance for future wide NVIDIA; confirm RAM exact QVL on both ASUS boards and final PSU seller identity before ordering.
2. Complete total build costing (CPU, motherboard, NIC, RAM, chassis, efficient low-idle PSU, cooler and storage), including future wide GPU plus x4 NIC clearance.
3. Before purchase, seek model/BIOS evidence of independent low PL1/PL2 with non-K CPU; after assembly plan measured idle energy and stability tests.

## Blockers / open questions

- Minimum accepted PL2 and runtime enforcement on exact ASUS BIOS revision + non-K CPU unverified; equivalent on ASRock/MSI unverified.
- Measured idle energy use under the intended host/Proxmox profile unavailable for shortlisted boards.
- NVIDIA model/slot thickness/power unknown; select enclosure and slot layout with safety margin.
- No fixed total purchase budget, case dimensions, Power Zone 2 price, or NIC final choice between two fixed candidates; 32GB RAM pair awaits exact ASUS QVL confirmation. PSU shortlist fixed to two 1200W SKUs but the future NVIDIA power envelope remains unconfirmed.
