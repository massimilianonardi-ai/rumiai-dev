# Decisione — Physical validation ARM64 di `pkg uninstall` e package command regression

Date: 2026-09-10  
Status: **Validated**

## Scope

Questa evidence chiude il gate J2 del lifecycle package dopo la correzione locale-independent dei validator condivisi documentata in:

```text
decisions/rumiai-os/2026-09-10-package-uninstall-macos-locale-validation-correction.md
```

La validation è revision-specific e riguarda il gruppo permanente:

```text
rumiai-os/pkg
```

che comprende:

```text
rumiai-os/pkg/catalog-snapshot.test
rumiai-os/pkg/install.test
rumiai-os/pkg/uninstall.test
```

Coppia validata:

```text
rumiai-os@164fe1b058710a6871266aab7ca9dc4495cbe4bc
rumiai-tests@71963b08476ff5c4d5557ed593cd6c4c8414b63c
selection: rumiai-os/pkg
```

La configuration versionata in `rumiai-tests@71963b0...` pinna esattamente `rumiai-os@164fe1b...`. Il launcher canonico verifica inoltre working tree clean e HEAD del target uguale al commit configurato prima di invocare la validation.

---

## Ubuntu ARM64

Host osservato:

```text
OS: Ubuntu 26.04.1 LTS
architecture: aarch64
kernel: Linux 7.0.0-31-generic
```

Sessione:

```text
20260910T220254+0200-111026
validation ref: validation/20260910T220254+0200-111026
validation evidence commit: 6e51e091d4287c6f2f15a772e19ba8eb69aaf1b7
```

Il commit di evidence ha come parent esatto:

```text
71963b08476ff5c4d5557ed593cd6c4c8414b63c
```

Risultato:

```text
PASS   rumiai-os/pkg/catalog-snapshot.test
PASS   rumiai-os/pkg/install.test
PASS   rumiai-os/pkg/uninstall.test
PASS   3
FAIL   0
SKIP   0
ERROR  0
TOTAL  3
runner exit status: 0
```

---

## macOS ARM64

Host osservato:

```text
OS: Darwin 26.6.2
architecture: arm64
kernel: Darwin 25.6.0
```

Sessione:

```text
20260910T220311+0200-16234
validation ref: validation/20260910T220311+0200-16234
validation evidence commit: d12fd743b8c7254028bed8cbd6dcf1887f2ffcef
```

Il commit di evidence ha come parent esatto:

```text
71963b08476ff5c4d5557ed593cd6c4c8414b63c
```

Risultato:

```text
PASS   rumiai-os/pkg/catalog-snapshot.test
PASS   rumiai-os/pkg/install.test
PASS   rumiai-os/pkg/uninstall.test
PASS   3
FAIL   0
SKIP   0
ERROR  0
TOTAL  3
runner exit status: 0
```

---

## Conclusione

Il gate J2 è chiuso.

La revisione:

```text
rumiai-os@164fe1b058710a6871266aab7ca9dc4495cbe4bc
```

è fisicamente validata sui reference host Ubuntu ARM64 e macOS ARM64 per il gruppo `rumiai-os/pkg` con la suite:

```text
rumiai-tests@71963b08476ff5c4d5557ed593cd6c4c8414b63c
```

La validation conferma in particolare il comportamento osservabile protetto dai permanent test dopo la correzione di portabilità:

```text
package name ASCII lowercase indipendente dalla locale
Bad rifiutato come operand lessicalmente invalido con status 2
pkg install pre-valida prima del catalog snapshot
pkg uninstall resta local-only
pkg install e pkg uninstall riusano i validator condivisi di pkg-integration
regressione catalog-snapshot/install/uninstall PASS su entrambi i reference host
```

Le precedenti evidence della revisione `rumiai-os@4aa3dbe...` restano immutabili: Ubuntu PASS e macOS FAIL. Non vengono reinterpretate come evidence della revisione corretta.

Questa evidence non definisce né valida nuovi nomi pubblici per il successivo confine di piano `version/current`.

---

## Stato lifecycle

```text
J1  contratto + test + implementazione pkg uninstall                    [completato]
J2  physical validation pkg uninstall + pkg command regression         [completato]
J3  lifecycle version/current: naming + public contract                [successivo]
```

`version/current` resta un label di pianificazione. Nessun sottocomando pubblico relativo a tale label è stabilito da questa validation.

---

## Invarianti di evidence

```text
PKG-UNINSTALL-VAL-01  coppia validata: rumiai-os@164fe1b + rumiai-tests@71963b0
PKG-UNINSTALL-VAL-02  Ubuntu ARM64: PASS 3/3, FAIL 0, SKIP 0, ERROR 0
PKG-UNINSTALL-VAL-03  macOS ARM64: PASS 3/3, FAIL 0, SKIP 0, ERROR 0
PKG-UNINSTALL-VAL-04  entrambi i commit evidence hanno parent esatto rumiai-tests@71963b0
PKG-UNINSTALL-VAL-05  le evidence della revisione 4aa3dbe restano storiche e immutabili
PKG-UNINSTALL-VAL-06  il gate J2 è chiuso
PKG-UNINSTALL-VAL-07  version/current resta un confine di design con naming pubblico non ancora fissato
```
