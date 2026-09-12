# Decisione — Electron macOS come runtime CLI tramite executable interno

Date: 2026-09-12  
Status: **Accepted**

## 1. Correzione

Electron distribuito come `Electron.app` su macOS è un application bundle, ma il package RumiAI `electron` espone il **runtime Electron**, non una applicazione finale già confezionata per l'utente.

Il normale uso upstream del runtime è equivalente a:

```text
electron <app-or-project> [arguments...]
```

L'implementazione npm ufficiale di Electron su Darwin risolve come executable:

```text
Electron.app/Contents/MacOS/Electron
```

e la CLI ufficiale avvia direttamente tale executable preservando argv, exit status e segnali.

Di conseguenza il command RumiAI `electron` su macOS deve seguire la stessa semantica processuale diretta.

## 2. Package definition macOS

La variante `catalog-macos-arm64` mantiene integralmente il bundle:

```text
root/Electron.app/
```

ma materializza:

```text
link/electron -> ../root/Electron.app/Contents/MacOS/Electron
```

Il descriptor catalogo resta root-relative:

```text
Electron.app/Contents/MacOS/Electron
```

Il command entry è lo stesso modello direct-link usato su Linux:

```sh
#!/usr/bin/env rumiai-os

. "$m_LIB_DIR/sh/pkg-launch.lib.sh"

launcher "electron" "$@"
```

Non usa `/usr/bin/open`, `open -a`, `open -b`, `-n`, `-W` o `--args`.

## 3. Motivazione

`open` / LaunchServices è appropriato quando RumiAI deve aprire una **app macOS finale** come unità applicativa.

Non è il contratto corretto per il runtime Electron perché introduce un processo intermedio e una semantica diversa per:

```text
argv
exit status
segnali
process identity
lifecycle
```

Il package `electron` deve invece comportarsi come runtime CLI cross-platform e ricevere direttamente il progetto/app da eseguire.

La preservazione di `Electron.app` resta necessaria perché framework, helper, resources, `Info.plist`, firma e layout macOS fanno parte del runtime upstream. L'esecuzione diretta del main executable non autorizza a smontare o modificare il bundle.

## 4. Sicurezza e macOS

Questa decisione non elimina i controlli specifici macOS sul payload:

```text
Electron.app preservato
Info.plist valido
main executable presente/executable
bundle signature verificabile
artifact SHA-256 verificato dal normale pipeline pkg
```

Non viene assunto che `open` costituisca un controllo di integrità sostitutivo del package manager.

Se in futuro RumiAI distribuisce una propria applicazione GUI macOS confezionata come `.app`, la modalità nativa di apertura di **quella applicazione finale** dovrà essere valutata nel relativo package/command e non dedotta dal runtime Electron.

## 5. Relazione con `launcher -c`

La modalità:

```text
launcher -c <pkg> <absolute-command> [arguments...]
```

resta valida come capacità generica per launch line realmente composte, già prevista dal modello `cmd/` senza `link/`.

Electron macOS non è più il primo consumer concreto di tale modalità.

La correzione non riapre né rimuove:

```text
PKG-LAUNCH-15..22
PKG-CMD-LINK-01..05
```

ma supersede soltanto le affermazioni che identificavano Electron macOS come consumer di `/usr/bin/open` o come caso senza `link/electron`.

## 6. Testing corrente

Il live test macOS deve verificare almeno:

```text
installazione reale Electron macOS ARM64
Electron.app preservato
Info.plist valido
bundle signature verificabile
main executable = Electron.app/Contents/MacOS/Electron
link/electron materializzato e confinato nel package root
cmd/electron direct-link
normal launch tramite public command RumiAI
process.execPath uguale al main executable package-local
HOME package RumiAI ereditato
argv utente preservato direttamente
BrowserWindow/workload minimo fino a ready/page-load
exit/cleanup deterministico
```

Non deve verificare `/usr/bin/open`, `-n`, `-W` o `--args`.

## 7. Supersession

Questa decisione supersede integralmente, per Electron macOS, la decisione:

```text
decisions/rumiai-os/2026-09-12-package-macos-application-launch.md
```

Supersede inoltre in:

```text
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
```

solo le affermazioni che indicano Electron macOS come primo consumer concreto della modalità explicit-command e l'invariante `PKG-CMD-LINK-06` nella sua formulazione Electron-specifica.

Restano valide tutte le altre regole della modalità explicit-command.

## 8. Invarianti

```text
ELECTRON-MACOS-RUNTIME-01  il package electron espone il runtime CLI, non una app finale
ELECTRON-MACOS-RUNTIME-02  Electron.app viene preservato integralmente sotto root/
ELECTRON-MACOS-RUNTIME-03  link/electron punta al main executable Electron.app/Contents/MacOS/Electron
ELECTRON-MACOS-RUNTIME-04  cmd/electron usa il launcher direct-link e preserva argv
ELECTRON-MACOS-RUNTIME-05  il normal command electron macOS non usa /usr/bin/open o LaunchServices
ELECTRON-MACOS-RUNTIME-06  process/exit/signal semantics restano quelle dell'exec diretto dell'upstream
ELECTRON-MACOS-RUNTIME-07  firma/layout/Info.plist del bundle restano proprietà da validare
ELECTRON-MACOS-RUNTIME-08  launcher -c resta disponibile per launch line composte reali, ma Electron macOS non ne è consumer
ELECTRON-MACOS-RUNTIME-09  una futura app GUI RumiAI .app deve valutare separatamente il proprio native application launch
ELECTRON-MACOS-RUNTIME-10  physical validation macOS ARM64 deve esercitare il runtime tramite il public command RumiAI
```
