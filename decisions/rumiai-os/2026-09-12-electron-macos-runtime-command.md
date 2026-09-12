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

Di conseguenza il command RumiAI `electron` su macOS segue la stessa semantica processuale diretta.

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

Il command entry usa lo stesso modello direct-link di Linux:

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

## 5. Launch line composta nuovamente deferita

Prima della correzione Electron era stato considerato il primo consumer concreto di una modalità `launcher -c` e di `cmd/` senza `link/`.

Venuto meno quel requisito reale, la loro implementazione non deve restare nel prodotto soltanto per un possibile uso futuro.

Torna quindi corrente il contratto già fissato da:

```text
decisions/rumiai-os/2026-09-07-package-command-specific-launch.md
decisions/rumiai-os/2026-09-10-package-launch-library.md
```

ossia:

```text
- una launch line composta può essere necessaria in futuro;
- il command entry resta il luogo della logica command-specific;
- link/ non deve essere artificiosamente usato per rappresentare una launch line composta;
- la firma concreta del launcher per quel caso resta da fissare quando un package reale la richiederà;
- il prodotto corrente implementa soltanto il direct-link già richiesto dai package reali correnti.
```

I commit che avevano anticipato `launcher -c` e `cmd` senza `link` vengono corretti forward-only riportando il prodotto al baseline direct-link, senza riscrivere la storia Git.

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

I permanent test non devono più proteggere `launcher -c` o `cmd/` senza `link/` come comportamento implementato corrente.

## 7. Supersession

Questa decisione supersede integralmente, per Electron macOS, la decisione:

```text
decisions/rumiai-os/2026-09-12-package-macos-application-launch.md
```

La decisione:

```text
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
```

è superseded come contratto implementato corrente: non essendoci più un consumer reale, la firma concreta e la materializzazione `cmd` senza `link` tornano deferite al primo requisito concreto secondo le decisioni del 7 e 10 settembre.

## 8. Invarianti

```text
ELECTRON-MACOS-RUNTIME-01  il package electron espone il runtime CLI, non una app finale
ELECTRON-MACOS-RUNTIME-02  Electron.app viene preservato integralmente sotto root/
ELECTRON-MACOS-RUNTIME-03  link/electron punta al main executable Electron.app/Contents/MacOS/Electron
ELECTRON-MACOS-RUNTIME-04  cmd/electron usa il launcher direct-link e preserva argv
ELECTRON-MACOS-RUNTIME-05  il normal command electron macOS non usa /usr/bin/open o LaunchServices
ELECTRON-MACOS-RUNTIME-06  process/exit/signal semantics restano quelle dell'exec diretto dell'upstream
ELECTRON-MACOS-RUNTIME-07  firma/layout/Info.plist del bundle restano proprietà da validare
ELECTRON-MACOS-RUNTIME-08  la modalità composta del launcher resta concettualmente prevista ma la sua firma/implementazione è deferita finché un package reale non la richiede
ELECTRON-MACOS-RUNTIME-09  una futura app GUI RumiAI .app deve valutare separatamente il proprio native application launch
ELECTRON-MACOS-RUNTIME-10  physical validation macOS ARM64 deve esercitare il runtime tramite il public command RumiAI
```
