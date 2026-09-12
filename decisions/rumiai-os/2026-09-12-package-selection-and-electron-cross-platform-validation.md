# Decisione — Scelta dei package reali e prosecuzione della validazione Electron cross-platform

Date: 2026-09-12  
Status: **Accepted**

## 1. Criterio per i package reali

I package reali introdotti durante lo sviluppo di `pkg` hanno due motivazioni da considerare insieme:

1. fornire casi concreti che facciano emergere requisiti reali del package manager;
2. rappresentare software che può avere utilità concreta per RumiAI oltre al ruolo di caso di sviluppo.

La prima motivazione non deve far terminare automaticamente la valutazione di un package quando il requisito del package manager che lo ha introdotto è stato chiuso.

Se il software è plausibilmente importante per RumiAI, la sua validazione deve proseguire sulle piattaforme e sui comportamenti sui quali RumiAI prevede concretamente di fare affidamento.

Questo è un criterio di pianificazione e validazione. Non introduce una nuova categoria di package, metadata del catalogo, primitive o namespace.

## 2. Electron resta un candidato strategico distinto da `setuid_root`

Electron è stato inizialmente introdotto come primo caso reale del requisito Linux `setuid_root` di `chrome-sandbox`.

La physical validation di quella unità resta valida per le revisioni e proprietà effettivamente esercitate, ma non equivale alla qualificazione completa di Electron come runtime cross-platform di RumiAI.

Electron resta di particolare interesse per future GUI cross-platform perché combina runtime desktop e stack web, consentendo un forte riuso del frontend.

Per questo deve essere qualificato almeno sui reference host ARM64 correntemente disponibili:

```text
linux-arm64
macos-arm64
```

senza estendere le evidence a target non esercitati.

## 3. Electron macOS ARM64

La release baseline corrente:

```text
v44.3.0
```

pubblica:

```text
electron-v44.3.0-darwin-arm64.zip
```

La shape verificata è un vero application bundle:

```text
Electron.app/Contents/...
```

Il boundary `.app` deve essere preservato integralmente durante extraction.

Il package RumiAI `electron` espone però il **runtime Electron**, non una app finale. La semantica corrente è quindi:

```text
root/Electron.app
link/electron -> ../root/Electron.app/Contents/MacOS/Electron
cmd/electron -> launcher "electron" "$@"
```

Il normale runtime command non usa `/usr/bin/open` o LaunchServices.

La decisione specifica autorevole è:

```text
decisions/rumiai-os/2026-09-12-electron-macos-runtime-command.md
```

Una futura applicazione GUI RumiAI confezionata come `.app` valuterà separatamente il proprio native application launch.

## 4. Electron Linux

Linux mantiene il direct-link upstream esistente e il requisito specifico:

```text
chrome-sandbox uid=0 gid=0 mode=4755
```

La validazione Linux distingue due proprietà indipendenti:

```text
install/setuid_root
normal runtime launch
```

Il normal runtime launch non usa `--no-sandbox`.

Quando il reference host è headless, Xvfb può essere usato esclusivamente come infrastruttura del test; non diventa una dependency di RumiAI OS o del package Electron.

## 5. Physical validation richiesta

La qualificazione Electron sui due reference host ARM64 richiede evidence revision-specific che coprano almeno:

### macOS ARM64

```text
repository/version/artifact resolution
download reale e SHA-256
Electron.app preservato
Info.plist valido
bundle signature verificabile
main executable presente/executable
link/electron al main executable interno
public command RumiAI
process.execPath package-local
HOME package RumiAI
argv diretto del runtime
BrowserWindow nascosta
loadFile HTML locale
marker deterministico
exit/cleanup
```

### Linux ARM64

```text
installazione reale
setuid_root/chrome-sandbox
public command direct-link
Chromium sandbox non disabilitato
BrowserWindow/workload
process.execPath
HOME
argv
exit/cleanup
```

I live test restano separati quando verificano proprietà indipendenti.

## 6. Launch line composta

La correzione del runtime Electron elimina il requisito concreto che aveva temporaneamente motivato una firma `launcher -c` e `cmd/` senza `link/`.

Resta valido il principio già fissato nel 2026-09-07 che una futura launch line composta può richiedere una forma senza direct-link artificiale, ma la firma e l'implementazione concrete sono nuovamente deferite fino al primo package reale che le richiederà.

Non viene mantenuta una capability prodotto soltanto per un possibile uso futuro.

## 7. Priorità dei prossimi package

Indicazioni già fissate dall'utente:

```text
Electron  rilevanza elevata per future GUI cross-platform e riuso dello stack web
Node.js   rilevanza fondamentale prevista
Java      rilevanza fondamentale prevista
DBeaver   utile come caso package reale e potenzialmente utile in futuro, ma con priorità immediata inferiore
```

Queste indicazioni orientano la pianificazione; non sono metadata di `pkg` e non implicano da sole nuove dependency del runtime RumiAI OS.

Ogni integrazione concreta continua a seguire:

```text
requisito reale
-> verifica upstream
-> decisione/package definition
-> permanent test proporzionati
-> implementazione solo se necessaria
-> physical validation sulle piattaforme rilevanti disponibili
```

## 8. Stato corrente e piano immediato

Lo stato operativo corrente è definito più precisamente da:

```text
decisions/rumiai-os/2026-09-12-package-current-plan-after-electron-macos-runtime-correction.md
```

La sequenza resta:

```text
1. validare revision-specific il boundary pkg_extract sui reference host ARM64;
2. validare Electron macOS ARM64 con installazione e runtime workload reale;
3. riconfermare Electron Linux ARM64 install/setuid_root sulla revisione corrente;
4. validare Electron Linux ARM64 normal runtime workload;
5. registrare evidence separate e revision-specific;
6. chiudere la qualificazione ARM64 solo dopo tutti i gate applicabili PASS.
```

L'utente esegue operativamente soltanto `rumiai-validate`; la selection viene predisposta nel repository test.

## 9. Invarianti

```text
PKG-REAL-01  i package reali possono servire sia come casi concreti di sviluppo di pkg sia come software utile a RumiAI
PKG-REAL-02  la chiusura della feature pkg che ha motivato un package non chiude automaticamente la validazione del software se RumiAI prevede di dipenderne
PKG-REAL-03  la validazione di software rilevante copre le piattaforme e le proprietà concrete su cui RumiAI prevede di fare affidamento
PKG-REAL-04  questo criterio non introduce classi, metadata o primitive nel package manager
PKG-REAL-05  Electron resta chiuso come primo caso setuid_root Linux ma aperto come runtime cross-platform da qualificare
PKG-REAL-06  macos-arm64 è un target Electron corrente di physical validation
PKG-REAL-07  Electron.app viene preservato, mentre il runtime command usa il main executable interno tramite direct-link
PKG-REAL-08  Electron Linux mantiene il Chromium sandbox e separa install/setuid dal normal launch
PKG-REAL-09  Java e Node.js sono candidati di elevata rilevanza futura; DBeaver ha priorità immediata inferiore
PKG-REAL-10  le evidence restano revision-specific e non vengono estese a target non esercitati
PKG-REAL-11  una launch line composta resta deferita finché un package reale non la richiede
PKG-REAL-12  Git resta forward-only
```
