# Decisione — Validazione fisica Electron cross-platform ARM64

Date: 2026-09-12  
Status: **Accepted**

## 1. Scopo

Questa decisione registra la chiusura revision-specific della qualificazione del package RumiAI `electron` sui reference host ARM64 disponibili.

La qualificazione riguarda Electron come **runtime/framework cross-platform** esposto dal package RumiAI, non una futura applicazione GUI RumiAI finale confezionata come `.app` o altro bundle distributivo.

Revisioni qualificate:

```text
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
```

Le evidence restano valide esclusivamente per le revisioni e gli host effettivamente esercitati.

---

## 2. Linux ARM64

Evidence:

```text
validation/20260912T220010+0200-319720
host              Ubuntu 26.04.1 LTS
architecture      aarch64
rumiai-tests      d28b580b0745e7ae60a5226446767038fc40c21c
rumiai-os         96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
selection         external/electron
runner             0
```

Risultati:

```text
external/electron/install-live.test       PASS
external/electron/linux-launch-live.test  PASS
```

Proprietà osservate e validate:

```text
installazione reale da pkg-catalog
Electron v44.3.0 linux-arm64
artifact/digest tramite normale pipeline pkg
chrome-sandbox uid=0 gid=0 mode=4755
sudo limitato ai due comandi setuid_root autorizzati
public command RumiAI
launcher direct-link
runtime Electron package-local
Chromium sandbox non disabilitato
BrowserWindow/workload reale fino al marker ready
HOME package RumiAI
argv preservato
exit/cleanup
```

Il gate Linux ha usato il catalogo:

```text
6443f265a922f7cff070f02e75d057727a6e5eb9
```

Non è stato usato `--no-sandbox`.

---

## 3. macOS ARM64 — archive/extraction

Evidence:

```text
validation/20260912T222918+0200-77771
selection external/electron/macos-archive-extraction-live.test
runner     0
PASS
```

Il gate ha validato l'archive ufficiale Electron `v44.3.0` Darwin ARM64 e ha verificato almeno:

```text
Electron.app preservato come application bundle
Info.plist e main executable nella shape upstream
symlink/framework/helper preservati
confronto strutturale estrazione RumiAI vs /usr/bin/ditto
stato del materiale code-signature osservato sull'archive upstream
```

La decisione specifica sulla firma upstream resta:

```text
decisions/rumiai-os/2026-09-12-electron-macos-prebuilt-signature-and-archive-validation.md
```

L'assenza dell'outer `Contents/_CodeSignature/CodeResources` è proprietà osservata già nell'archive upstream corrente; `pkg install` non risigna e non ripara il prebuilt Electron.

---

## 4. macOS ARM64 — normal runtime launch

Evidence:

```text
validation/20260912T224200+0200-78239
host              Darwin 26.6.2
architecture      arm64
rumiai-tests      bb335ca567bf465ba08f203caa2e5258db670869
rumiai-os         96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
selection         external/electron/macos-launch-live.test
runner             0
PASS
```

Output significativo registrato:

```text
installed=electron@v44.3.0!macos-arm64
catalog-head=6443f265a922f7cff070f02e75d057727a6e5eb9
bundle=Electron.app
signature-state=upstream-material-absent
launch=direct-runtime
workload=BrowserWindow-ready
```

Il gate ha verificato:

```text
installazione reale Electron macOS ARM64
Electron.app preservato
Info.plist valido
main executable = Electron.app/Contents/MacOS/Electron
link/electron relativo al main executable interno
cmd/electron tramite launcher direct-link
assenza di /usr/bin/open nel normal runtime command
public command RumiAI
process.execPath package-local
HOME package RumiAI
argv preservato direttamente
BrowserWindow nascosta
loadFile di HTML locale
marker deterministico di ready/page-load
exit/cleanup
```

La code-signature è stata trattata secondo il contratto corrente:

```text
CodeResources presente -> codesign --verify --deep --strict deve PASS
CodeResources assente  -> signature-state=upstream-material-absent e prosecuzione del runtime gate
```

Non sono stati usati `/usr/bin/open`, `-n`, `-W`, `--args` o `--no-sandbox`.

---

## 5. Confrontabilità delle evidence Linux e macOS

La suite Linux era basata su:

```text
rumiai-tests d28b580b0745e7ae60a5226446767038fc40c21c
```

La suite macOS finale è:

```text
rumiai-tests bb335ca567bf465ba08f203caa2e5258db670869
```

Tra queste revisioni sono cambiati soltanto:

```text
rumiai-validate.conf
tests/external/electron/macos-archive-extraction-live.test
tests/external/electron/macos-launch-live.test
```

I test Linux:

```text
external/electron/install-live.test
external/electron/linux-launch-live.test
```

non sono stati modificati.

La revisione prodotto è la stessa (`96d399d0...`) e il catalogo osservato dai gate Linux e macOS è lo stesso (`6443f265...`).

Non è quindi necessario ripetere il gate Linux per la sola correzione/estensione dei test macOS.

---

## 6. Stato qualificazione Electron

Sui reference host ARM64 attualmente disponibili, Electron è qualificato per il ruolo corrente di runtime RumiAI:

```text
Linux ARM64   install + setuid_root + normal runtime launch   VALIDATED
macOS ARM64   archive/bundle + install + normal runtime launch VALIDATED
```

Questo significa che il modello package corrente rappresenta correttamente le due shape upstream differenti:

```text
Linux   executable/resources top-level + chrome-sandbox setuid_root
macOS   Electron.app preservato + executable interno direct-link
```

La differenza di layout non richiede una diversa identità pubblica del command `electron`.

---

## 7. Limiti espliciti

Non risultano fisicamente qualificati da questa decisione:

```text
Linux x86_64
macOS x86_64
Windows
altre versioni Electron oltre la baseline osservata
signing/notarization di una futura app RumiAI finale
native LaunchServices semantics di una futura app finale .app
```

La decisione non afferma che ogni applicazione macOS `.app` debba essere lanciata dal Mach-O interno.

Per il package runtime `electron`, il direct executable interno è il contratto corretto perché deve conservare semantica CLI/processuale cross-platform.

Una futura applicazione RumiAI finale confezionata come `.app` deve valutare separatamente LaunchServices, signing e notarization.

---

## 8. Invarianti consolidati

```text
ELECTRON-ARM64-VALIDATION-01  Electron runtime è fisicamente validato sui reference host Linux ARM64 e macOS ARM64 disponibili
ELECTRON-ARM64-VALIDATION-02  la revisione prodotto qualificata è rumiai-os 96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
ELECTRON-ARM64-VALIDATION-03  il catalogo osservato dai gate è 6443f265a922f7cff070f02e75d057727a6e5eb9
ELECTRON-ARM64-VALIDATION-04  Linux conserva setuid_root e Chromium sandbox; nessun --no-sandbox
ELECTRON-ARM64-VALIDATION-05  macOS conserva Electron.app e usa il runtime executable interno tramite direct-link
ELECTRON-ARM64-VALIDATION-06  il normal runtime macOS non usa LaunchServices /usr/bin/open
ELECTRON-ARM64-VALIDATION-07  la firma macOS viene valutata rispetto al materiale realmente presente upstream
ELECTRON-ARM64-VALIDATION-08  future app finali .app valutano separatamente native launch, signing e notarization
ELECTRON-ARM64-VALIDATION-09  evidence e qualificazione restano revision-specific e platform-specific
ELECTRON-ARM64-VALIDATION-10  Git resta forward-only
```
