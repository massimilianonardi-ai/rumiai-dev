# Decisione — Physical validation ARM64 di `pkg versions` / `pkg default` e package command regression

Date: 2026-09-11  
Status: **Validated**

## Scope

Questa evidence chiude il gate J3c del lifecycle package relativo a:

```text
pkg versions
pkg default
```

e alla regressione del gruppo permanente:

```text
rumiai-os/pkg
```

La validation è revision-specific e riguarda la coppia:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
selection: rumiai-os/pkg
```

La configuration versionata nella suite pinna esattamente:

```text
rumiai-os-commit  59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
selection         rumiai-os/pkg
```

Il gruppo validato comprende:

```text
rumiai-os/pkg/catalog-snapshot.test
rumiai-os/pkg/default.test
rumiai-os/pkg/install.test
rumiai-os/pkg/uninstall.test
rumiai-os/pkg/versions.test
```

Le evidence J2 precedenti restano immutabili e non vengono reinterpretate come evidence della revisione J3.

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
20260911T063224+0200-114517
validation ref: validation/20260911T063224+0200-114517
```

Il validation ref contiene un solo commit di evidence sopra:

```text
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
```

con merge-base esattamente uguale alla revisione della suite validata.

Risultato:

```text
PASS   rumiai-os/pkg/catalog-snapshot.test
PASS   rumiai-os/pkg/default.test
PASS   rumiai-os/pkg/install.test
PASS   rumiai-os/pkg/uninstall.test
PASS   rumiai-os/pkg/versions.test
PASS   5/5
runner exit status: 0
```

Non risultano record FAIL, SKIP o ERROR nella sessione completata.

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
20260911T063242+0200-18138
validation ref: validation/20260911T063242+0200-18138
```

Il validation ref contiene un solo commit di evidence sopra:

```text
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
```

con merge-base esattamente uguale alla revisione della suite validata.

Risultato:

```text
PASS   rumiai-os/pkg/catalog-snapshot.test
PASS   rumiai-os/pkg/default.test
PASS   rumiai-os/pkg/install.test
PASS   rumiai-os/pkg/uninstall.test
PASS   rumiai-os/pkg/versions.test
PASS   5/5
runner exit status: 0
```

Non risultano record FAIL, SKIP o ERROR nella sessione completata.

---

## Proprietà confermate dal gate

Il gate revision-specific conferma sui due reference host ARM64 le proprietà protette dai permanent test correnti, incluse:

```text
pkg versions osserva soltanto availability locale
pkg versions produce concrete identity complete in ordine C deterministico
pkg default osserva e modifica il default persistente
pkg_default resta l'unica primitive che muta selector current e binding pubblici
current resta interno/concezionale e non è un sottocomando pubblico
selezione target esplicita senza fallback generic
precedenza current-$m_OSARCH -> generic quando il target è omesso
corruption della classe prioritaria senza fallback
nessun SemVer/latest/catalog/upstream nelle operazioni locali versions/default
pkg install continua a non selezionare implicitamente il default
pkg uninstall continua a riusare il boundary locale senza modifica del contratto pubblico
regressione catalog-snapshot/install/uninstall PASS
```

La validation non estende il contratto oltre quanto già fissato dalle decisioni autorevoli e dai test permanenti.

---

## Conclusione

Il gate J3c è chiuso.

La revisione:

```text
rumiai-os@59fc8d5945dd4ec8acc99e4c41628e5cfed37a13
```

è fisicamente validata sui reference host Ubuntu ARM64 e macOS ARM64 per il gruppo:

```text
rumiai-os/pkg
```

con la suite:

```text
rumiai-tests@e2dd1ac08b9e1167a7a20db12a01a4869b797376
```

Entrambi gli host hanno prodotto PASS 5/5 e runner exit status 0.

---

## Stato lifecycle

```text
J1  pkg uninstall: contratto/test/implementazione                    [completato]
J2  physical validation pkg uninstall                                [completato]
J3a pkg versions/default: naming e contratto pubblico                [completato]
J3b permanent test + implementazione                                 [completato]
J3c physical validation versions/default + regressione pkg           [completato]
K   dependency/facility/state avanzato soltanto quando richiesto     [successivo]
```

---

## Invarianti di evidence

```text
PKG-VERSIONS-DEFAULT-VAL-01  coppia validata: rumiai-os@59fc8d5 + rumiai-tests@e2dd1ac
PKG-VERSIONS-DEFAULT-VAL-02  selection validata: rumiai-os/pkg
PKG-VERSIONS-DEFAULT-VAL-03  Ubuntu ARM64: PASS 5/5, runner status 0
PKG-VERSIONS-DEFAULT-VAL-04  macOS ARM64: PASS 5/5, runner status 0
PKG-VERSIONS-DEFAULT-VAL-05  entrambi i validation ref sono un singolo commit di evidence direttamente sopra rumiai-tests@e2dd1ac
PKG-VERSIONS-DEFAULT-VAL-06  le evidence precedenti restano storiche, immutabili e revision-specific
PKG-VERSIONS-DEFAULT-VAL-07  il gate J3c è chiuso
PKG-VERSIONS-DEFAULT-VAL-08  Git resta forward-only
```
