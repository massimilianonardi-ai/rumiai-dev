# Decisione — Piano corrente dopo la correzione del runtime Electron macOS

Date: 2026-09-12  
Status: **Accepted**

## 1. Correzione applicata

La qualificazione Electron cross-platform resta aperta, ma il normal command macOS è stato corretto.

Il package RumiAI `electron` espone il runtime/framework Electron e non una app finale. La variante macOS ARM64 usa quindi:

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

La precedente decisione `2026-09-12-package-macos-application-launch.md` è superseded.

## 2. Stato prodotto/catalogo/test

Stato corrente:

```text
pkg_extract application-bundle boundary       implementata
launcher direct-link                          già esistente e usato da Electron macOS
launcher explicit-command (-c)                resta disponibile, ma Electron non ne è consumer
Electron Linux definitions                    invariate
Electron macOS definition                     riallineata al direct runtime
Electron macOS live test                      riallineato al direct runtime
Electron Linux install/setuid live test        esistente
Electron Linux normal-launch live test         esistente
physical validation revisione corrente         pending
```

La capability `launcher -c` non viene rimossa: resta la realizzazione del modello `cmd/` senza `link/` per launch line realmente composte, già previsto dalle decisioni precedenti.

## 3. Proprietà da validare su macOS ARM64

La physical validation Electron macOS deve esercitare:

```text
risoluzione/versione/artifact reali
SHA-256
preservazione Electron.app
Info.plist valido
bundle signature verificabile
main executable presente ed executable
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

Il test non deve usare né verificare `/usr/bin/open`, `-n`, `-W` o `--args`.

## 4. Proprietà da validare su Linux ARM64

Restano separate:

```text
install-live.test
  download/integrity/extraction/integration
  chrome-sandbox root:root 4755
  privilege boundary setuid_root

linux-launch-live.test
  public command direct-link
  sandbox Chromium non disabilitato
  BrowserWindow/workload
  process.execPath
  HOME
  argv
  exit/cleanup
```

Se necessario, Xvfb resta esclusivamente infrastruttura del test Linux headless.

## 5. Relazione con app finali macOS

La correzione non stabilisce che ogni `.app` debba essere eseguita dal Mach-O interno.

Regola corrente:

```text
Electron runtime package
  CLI/runtime semantics -> direct executable interno

applicazione finale distribuita come .app
  native application semantics -> da valutare per quel package concreto
```

Non si generalizza nessuno dei due comportamenti all'altro caso.

## 6. Priorità dei package reali

Restano validi i criteri fissati dall'utente:

```text
Electron  rilevanza elevata per future GUI cross-platform e stack web
Node.js   rilevanza fondamentale prevista
Java      rilevanza fondamentale prevista
DBeaver   caso reale utile, priorità immediata inferiore
```

Questi criteri guidano la scelta dei casi reali ma non diventano metadata di `pkg`.

## 7. Sequenza immediata

Prima di dichiarare Electron qualificato sui reference host ARM64 disponibili:

```text
1. permanent validation della revisione prodotto corrente su Linux ARM64 e macOS ARM64;
2. external/electron/macos-launch-live.test su macOS ARM64;
3. external/electron/install-live.test su Linux ARM64;
4. external/electron/linux-launch-live.test su Linux ARM64;
5. registrazione separata delle evidence revision-specific;
6. consistency check finale su documentazione, catalogo, test e prodotto.
```

L'utente esegue operativamente soltanto `rumiai-validate`; la selection viene predisposta nel repository test.

## 8. Invarianti correnti

```text
ELECTRON-PLAN-01  Electron resta da qualificare realmente sia su macOS ARM64 sia su Linux ARM64
ELECTRON-PLAN-02  Electron macOS runtime usa il direct executable interno preservando il bundle
ELECTRON-PLAN-03  Electron Linux resta direct-link e mantiene il Chromium sandbox
ELECTRON-PLAN-04  install/setuid e runtime launch Linux restano gate distinti
ELECTRON-PLAN-05  launcher -c resta capability generica ma non viene giustificata da Electron macOS
ELECTRON-PLAN-06  una futura app finale .app valuta separatamente il native application launch
ELECTRON-PLAN-07  evidence e dichiarazioni di validazione restano revision-specific
ELECTRON-PLAN-08  Git resta forward-only
```
