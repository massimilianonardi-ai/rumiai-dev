# Decisione — Piano corrente dopo la correzione del runtime Electron macOS

Date: 2026-09-12  
Status: **Accepted**

Questo documento definisce lo stato operativo corrente della qualificazione Electron cross-platform e supersede, dove incompatibili, le precedenti sezioni di stato/testing.

## 1. Runtime macOS corrente

Il package RumiAI `electron` espone il runtime/framework Electron e non una app finale.

La variante macOS ARM64 usa:

```text
root/Electron.app
link/electron -> ../root/Electron.app/Contents/MacOS/Electron
cmd/electron -> launcher "electron" "$@"
```

Non usa LaunchServices `/usr/bin/open` per il normale runtime command.

La decisione autorevole specifica è:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

Le precedenti decisioni che avevano introdotto `/usr/bin/open` e la firma concreta `launcher -c` sono superseded/deferite.

## 2. Stato prodotto/catalogo/test

Stato corrente:

```text
pkg_extract application-bundle boundary       implementata
launcher direct-link                          baseline corrente
launcher explicit-command (-c)                non implementato; deferito
cmd senza link                                non implementato; deferito
Electron Linux definitions                    invariate
Electron macOS definition                     direct runtime link
Electron macOS archive diagnostic             presente
Electron macOS normal-launch live test         presente
Electron Linux install/setuid live test        presente
Electron Linux normal-launch live test         presente
```

Il prodotto non conserva una capacità senza consumer reale.

## 3. Evidence già acquisite sulla revisione prodotto corrente

Revisione prodotto:

```text
rumiai-os 96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
```

### `pkg_extract` permanent gate

Linux ARM64:

```text
validation/20260912T214609+0200-319239
selection rumiai-os/pkg-extract
runner 0
```

macOS ARM64:

```text
validation/20260912T214622+0200-76068
selection rumiai-os/pkg-extract
runner 0
```

### Electron Linux

```text
validation/20260912T220010+0200-319720
selection external/electron
install-live.test       PASS
linux-launch-live.test  PASS
runner                   0
```

Questa evidence copre sulla revisione corrente sia installazione/setuid_root sia normal runtime workload Linux ARM64.

### Electron macOS archive/extraction

```text
validation/20260912T222918+0200-77771
selection external/electron/macos-archive-extraction-live.test
runner 0
PASS
```

Il gate ha verificato l'archive ufficiale `v44.3.0`, digest osservato, equivalenza strutturale RumiAI-vs-ditto, symlink e runtime executable.

Ha inoltre stabilito che l'outer `Contents/_CodeSignature/CodeResources` è assente già upstream e che strict `codesign` fallisce allo stesso modo dopo entrambi gli extractor.

La decisione/evidence specifica è:

```text
decisions/rumiai-os/2026-09-12-electron-macos-prebuilt-signature-and-archive-validation.md
```

## 4. Criterio code-signature macOS corretto

Il normal launch gate non deve pretendere una firma strict che il prebuilt upstream corrente non contiene.

Regola:

```text
CodeResources presente nel bundle installato
    -> codesign --verify --deep --strict deve PASS

CodeResources assente
    -> registrare signature-state=upstream-material-absent
    -> proseguire con le proprietà runtime
```

`pkg install` non risigna e non ripara il prebuilt Electron.

Una futura app finale RumiAI `.app` valuterà separatamente signing/notarization.

## 5. Proprietà ancora da chiudere su macOS ARM64

Resta un solo gate funzionale Electron macOS sulla revisione corrente:

```text
external/electron/macos-launch-live.test
```

Deve verificare:

```text
risoluzione/versione/artifact reali
SHA-256 tramite normale pipeline pkg
Electron.app preservato
Info.plist valido
main executable presente/executable
stato code-signature secondo il criterio corrente
link/electron relativo al main executable interno
cmd/electron direct-link
public command RumiAI
process.execPath package-local
HOME package RumiAI
argv diretto del runtime
BrowserWindow nascosta
loadFile HTML locale
marker deterministico
exit/cleanup
```

Non deve usare `/usr/bin/open`, `-n`, `-W`, `--args` o `--no-sandbox`.

## 6. Sequenza immediata

La sequenza corrente diventa:

```text
1. riallineare macos-launch-live.test al criterio firma osservato;
2. eseguire external/electron/macos-launch-live.test su macOS ARM64 tramite rumiai-validate;
3. se PASS, registrare evidence revision-specific;
4. consistency check finale su rumiai-dev, rumiai-os, rumiai-tests e pkg-catalog;
5. dichiarare Electron qualificato sui reference host ARM64 disponibili soltanto se non emergono altri mismatch.
```

Non è necessario ripetere i gate Linux già PASS sulla stessa revisione prodotto salvo modifica successiva del prodotto o dei test che renda non confrontabili quelle evidence.

L'utente esegue operativamente soltanto `rumiai-validate`; la selection viene predisposta nel repository test.

## 7. Priorità dei package reali

Restano validi:

```text
Electron  rilevanza elevata per future GUI cross-platform e stack web
Node.js   rilevanza fondamentale prevista
Java      rilevanza fondamentale prevista
DBeaver   caso reale utile, priorità immediata inferiore
```

Questi criteri guidano la pianificazione ma non diventano metadata di `pkg`.

## 8. Invarianti correnti

```text
ELECTRON-PLAN-01  Electron deve essere qualificato realmente sia su macOS ARM64 sia su Linux ARM64
ELECTRON-PLAN-02  Electron macOS runtime usa il direct executable interno preservando il bundle
ELECTRON-PLAN-03  Electron Linux resta direct-link e mantiene il Chromium sandbox
ELECTRON-PLAN-04  install/setuid e runtime launch Linux sono proprietà distinte ed entrambe risultano PASS sulla revisione 96d399d0...
ELECTRON-PLAN-05  la firma per launch line composta resta deferita finché un package reale non la richiede
ELECTRON-PLAN-06  una futura app finale .app valuta separatamente native application launch e signing/notarization
ELECTRON-PLAN-07  il prebuilt runtime macOS viene validato rispetto allo stato di firma realmente presente upstream
ELECTRON-PLAN-08  evidence e dichiarazioni di validazione restano revision-specific
ELECTRON-PLAN-09  Git resta forward-only
```
