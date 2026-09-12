# Decisione — Piano corrente dopo la qualificazione Electron ARM64

Date: 2026-09-12  
Status: **Accepted**

Questo documento definisce lo stato operativo corrente dopo la chiusura della qualificazione Electron sui reference host ARM64 disponibili e supersede le precedenti sezioni operative/pending incompatibili dello stesso piano.

## 1. Stato Electron corrente

Il package RumiAI `electron` espone il runtime/framework Electron, non una applicazione finale già confezionata.

Revisione prodotto qualificata:

```text
rumiai-os 96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
```

Catalogo osservato dai gate fisici:

```text
pkg-catalog 6443f265a922f7cff070f02e75d057727a6e5eb9
```

Stato:

```text
Linux ARM64   install + setuid_root + normal runtime launch    VALIDATED
macOS ARM64   archive/bundle + install + normal runtime launch VALIDATED
```

La decisione/evidence di chiusura è:

```text
decisions/rumiai-os/2026-09-12-electron-cross-platform-arm64-physical-validation.md
```

---

## 2. Runtime macOS corrente

La variante macOS ARM64 mantiene:

```text
root/Electron.app
link/electron -> ../root/Electron.app/Contents/MacOS/Electron
cmd/electron -> launcher "electron" "$@"
```

Il normal runtime command non usa LaunchServices `/usr/bin/open`.

La decisione autorevole specifica resta:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

Le precedenti proposte che usavano `/usr/bin/open` per il runtime Electron e la modalità concreta `launcher -c` restano superseded/deferite.

`launcher` implementa soltanto il direct-link richiesto dai package reali correnti.

---

## 3. Evidence fisiche consolidate

### `pkg_extract`

```text
Linux ARM64
validation/20260912T214609+0200-319239
selection rumiai-os/pkg-extract
runner 0

macOS ARM64
validation/20260912T214622+0200-76068
selection rumiai-os/pkg-extract
runner 0
```

### Electron Linux ARM64

```text
validation/20260912T220010+0200-319720
selection external/electron
install-live.test       PASS
linux-launch-live.test  PASS
runner                   0
```

La evidence copre installazione reale, `setuid_root`, Chromium sandbox e workload Electron reale via public command RumiAI.

### Electron macOS ARM64 — archive/extraction

```text
validation/20260912T222918+0200-77771
selection external/electron/macos-archive-extraction-live.test
PASS
runner 0
```

Copre shape dell'archive ufficiale `v44.3.0`, preservazione `Electron.app`, confronto estrazione RumiAI-vs-ditto, symlink/runtime executable e stato del materiale code-signature upstream.

La decisione specifica resta:

```text
decisions/rumiai-os/2026-09-12-electron-macos-prebuilt-signature-and-archive-validation.md
```

### Electron macOS ARM64 — normal runtime launch

```text
validation/20260912T224200+0200-78239
rumiai-tests bb335ca567bf465ba08f203caa2e5258db670869
selection external/electron/macos-launch-live.test
PASS
runner 0
```

Output osservato:

```text
installed=electron@v44.3.0!macos-arm64
catalog-head=6443f265a922f7cff070f02e75d057727a6e5eb9
bundle=Electron.app
signature-state=upstream-material-absent
launch=direct-runtime
workload=BrowserWindow-ready
```

Il gate verifica il public command RumiAI, `process.execPath` package-local, `HOME`, argv, `BrowserWindow`, `loadFile`, marker deterministico ed exit/cleanup.

Non usa `/usr/bin/open`, `-n`, `-W`, `--args` o `--no-sandbox`.

---

## 4. Code-signature macOS

Il prebuilt Electron macOS corrente non contiene l'outer:

```text
Electron.app/Contents/_CodeSignature/CodeResources
```

Regola corrente:

```text
CodeResources presente
    -> codesign --verify --deep --strict deve PASS

CodeResources assente
    -> signature-state=upstream-material-absent
    -> proseguire con le proprietà runtime
```

`pkg install` non risigna e non ripara il runtime upstream.

Signing e notarization di una futura applicazione RumiAI finale `.app` restano un problema distinto da affrontare quando esisterà quel consumer reale.

---

## 5. Confrontabilità Linux/macOS

La evidence Linux usa:

```text
rumiai-tests d28b580b0745e7ae60a5226446767038fc40c21c
```

La evidence macOS finale usa:

```text
rumiai-tests bb335ca567bf465ba08f203caa2e5258db670869
```

Tra le due revisioni della suite sono cambiati soltanto:

```text
rumiai-validate.conf
tests/external/electron/macos-archive-extraction-live.test
tests/external/electron/macos-launch-live.test
```

I test Linux non sono cambiati; `rumiai-os` è rimasto `96d399d0...` e il catalogo osservato è `6443f265...` in entrambi i gate.

Non è richiesto ripetere il gate Linux per le sole modifiche macOS della suite.

---

## 6. Limiti della qualificazione corrente

Non sono qualificati da questa unità:

```text
Linux x86_64
macOS x86_64
Windows
altre versioni Electron oltre la baseline osservata
native launch/signing/notarization di una futura app finale RumiAI
```

La validazione del runtime Electron non stabilisce una regola generale secondo cui tutte le app macOS `.app` debbano essere avviate dal Mach-O interno.

Per il runtime Electron il direct executable interno preserva la semantica CLI/processuale cross-platform; per una futura app finale verrà valutata separatamente la native application semantics macOS.

---

## 7. Piano package dopo Electron

La specifica unità Electron ARM64 è chiusa.

La pianificazione package torna quindi alla scelta del prossimo caso reale, applicando i criteri già fissati:

```text
1. il package deve esercitare requisiti reali del package manager;
2. tra candidati utili allo sviluppo di pkg si privilegiano quelli con utilità strategica reale per RumiAI;
3. la rilevanza strategica non diventa metadata o semantica del package manager.
```

Priorità qualitative già fissate:

```text
Electron  rilevanza elevata per future GUI cross-platform e stack web
Node.js   rilevanza fondamentale prevista
Java      rilevanza fondamentale prevista
DBeaver   caso reale utile, priorità immediata inferiore
```

Il prossimo package concreto non viene scelto implicitamente da questo documento: la scelta deve derivare dalla successiva unità di pianificazione e dai requisiti reali che si vogliono esercitare.

---

## 8. Invarianti correnti

```text
ELECTRON-PLAN-01  Electron runtime è qualificato sui reference host Linux ARM64 e macOS ARM64 disponibili
ELECTRON-PLAN-02  Electron macOS preserva Electron.app e usa il main executable interno tramite direct-link
ELECTRON-PLAN-03  Electron Linux resta direct-link e mantiene Chromium sandbox e setuid_root
ELECTRON-PLAN-04  install/setuid e runtime launch Linux restano proprietà distinte ed entrambe validate
ELECTRON-PLAN-05  la modalità launcher per launch line composta resta deferita finché un package reale non la richiede
ELECTRON-PLAN-06  una futura app finale .app valuta separatamente native application launch, signing e notarization
ELECTRON-PLAN-07  il prebuilt runtime macOS viene validato rispetto allo stato di firma realmente presente upstream
ELECTRON-PLAN-08  evidence e dichiarazioni di qualificazione restano revision-specific e platform-specific
ELECTRON-PLAN-09  i package reali vengono scelti sia per copertura del package manager sia, quando utile, per rilevanza strategica RumiAI
ELECTRON-PLAN-10  Git resta forward-only
```
