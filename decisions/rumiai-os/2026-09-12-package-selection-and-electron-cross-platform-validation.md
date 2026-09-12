# Decisione — Scelta dei package reali e prosecuzione della validazione Electron cross-platform

Date: 2026-09-12  
Status: **Accepted**

## 1. Contesto

I package reali introdotti durante lo sviluppo di `pkg` hanno due motivazioni che devono essere considerate insieme:

1. fornire casi concreti che facciano emergere requisiti reali del package manager;
2. rappresentare software che può avere utilità concreta per RumiAI oltre al ruolo di caso di sviluppo.

La prima motivazione non deve far terminare automaticamente la valutazione di un package quando il requisito del package manager che lo ha introdotto è stato chiuso.

Se il software è plausibilmente importante per RumiAI, la sua validazione deve proseguire sulle piattaforme e sui comportamenti sui quali RumiAI prevede concretamente di fare affidamento.

Questo è un criterio di pianificazione e validazione. Non introduce una nuova categoria di package, un nuovo metadata del catalogo, una nuova primitive o un nuovo namespace.

---

## 2. Relazione con la unità `setuid_root` / Electron

La decisione:

```text
decisions/rumiai-os/2026-09-11-package-setuid-root-and-electron.md
```

aveva fissato deliberatamente come primo scope Electron:

```text
linux-arm64
linux-x86_64
```

perché Electron era il primo caso reale che richiedeva la trasformazione Linux `setuid_root` di `chrome-sandbox`.

La successiva physical validation:

```text
decisions/rumiai-os/2026-09-12-package-setuid-root-and-electron-physical-validation.md
```

chiude correttamente quella unità e resta evidence autorevole per le revisioni esercitate.

La chiusura della unità `setuid_root` non equivale però alla qualificazione completa di Electron come dipendenza cross-platform di RumiAI.

Lo stato corrente è:

```text
Linux setuid_root validation             completata per lo scope/revisioni esercitate
Electron Linux ARM64 live install        completato sulle revisioni già registrate
Electron macOS archive/layout            verificato
Electron macOS package definition        pubblicata
Electron macOS native-launch contract    fissato e implementato
Electron macOS live install/launch       pending sulla nuova revisione
Electron Linux normal-launch regression  pending sulla nuova revisione
Electron cross-platform qualification    ancora aperta
```

Non viene reinterpretata né riscritta retroattivamente alcuna evidence precedente.

---

## 3. Electron come candidato rilevante per RumiAI

Electron è considerato un candidato di particolare interesse per future applicazioni GUI cross-platform di RumiAI, anche perché usa lo stack web e permette un forte riuso fra interfacce desktop e frontend web.

Di conseguenza Electron non deve essere trattato soltanto come fixture reale per `setuid_root`.

La sua package definition e il suo runtime devono essere verificati sulle piattaforme di riferimento per le quali RumiAI intende usarlo.

Il reference host macOS ARM64 corrente rende immediatamente verificabile:

```text
macos-arm64
```

La release Electron già usata come primo anchor:

```text
v44.3.0
```

pubblica l'artifact upstream:

```text
electron-v44.3.0-darwin-arm64.zip
```

La struttura dell'archive è stata verificata e ha mostrato il semantic boundary:

```text
Electron.app/Contents/...
```

Questo requisito ha portato prima al riallineamento di `pkg_extract` per preservare application bundle reali e poi, dopo una valutazione distinta del launch macOS, alla scelta di trattare `Electron.app` come unità applicativa nativa invece di usare il Mach-O interno come normale target pubblico.

Le decisioni correnti sono:

```text
decisions/rumiai-os/2026-09-12-package-extract-macos-application-bundle-boundary.md
decisions/rumiai-os/2026-09-12-package-launch-explicit-command-line.md
decisions/rumiai-os/2026-09-12-package-macos-application-launch.md
```

---

## 4. Scope Electron macOS corrente

La variante:

```text
catalog-macos-arm64
```

è ora definita nel modello target-specific esistente:

```text
<pkg>/catalog-<osarch>/
```

senza nuove astrazioni del catalogo e senza `setuid_root`.

La shape osservata e consolidata è:

```text
artifact            electron-v44.3.0-darwin-arm64.zip
useful payload      Electron.app
main executable     Electron.app/Contents/MacOS/Electron
normal command      cmd/electron
link/electron       assente
normal launch       /usr/bin/open -n -W <package-local>/Electron.app
user argv           inoltrato con --args quando presente
```

L'assenza di `link/electron` è intenzionale: il normale target è il bundle `.app`, mentre `link/` resta riservato al direct binding verso regular executable nel root dello stesso concrete package.

Il runtime comune continua a essere applicato tramite la modalità explicit-command del `launcher`; la specializzazione macOS resta nel command entry Electron.

---

## 5. Validazione richiesta per Electron macOS ARM64

La validazione non si limita al fatto che l'archive possa essere scaricato o estratto.

Deve coprire almeno:

```text
repository/version resolution corretta
download reale dell'artifact macOS ARM64
verifica SHA-256
extraction e useful-root normalization
pkg integration reale
concrete identity target-specific corretta
Electron.app preservato
Info.plist valido
main executable presente ed executable
bundle signature verificabile con strumenti macOS appropriati
cmd/electron materializzato e executable
assenza di link/electron artificiale
normal launch del bundle package-local tramite launcher RumiAI
uso del native launch macOS senza lookup globale per nome/bundle id
nuova istanza per invocazione tramite -n
attesa sincrona tramite -W
argv utente preservato tramite --args
HOME package RumiAI ereditato dall'applicazione
avvio reale di Electron su macOS ARM64
BrowserWindow/workload minimo controllato fino a ready/page-load osservabile
cleanup del workload e dell'istanza
assenza di regressioni nei permanent test del runtime package modificato
```

Il workload minimo verifica proprietà su cui RumiAI può realisticamente fare affidamento, senza trasformare la suite in un test generico di Electron.

L'eventuale verifica visiva umana di una finestra può integrare la physical validation, ma non sostituisce l'esito deterministico prodotto dal workload.

---

## 6. Separazione dal live test Linux corrente

Il test corrente:

```text
tests/external/electron/install-live.test
```

è specifico del caso Linux perché verifica anche:

```text
chrome-sandbox
uid 0
gid 0
mode 4755
sudo authorization path
setuid_root metadata
```

Non viene indebolito con branch macOS.

La copertura macOS è separata in:

```text
tests/external/electron/macos-launch-live.test
```

e verifica le proprietà specifiche del bundle/LaunchServices e il workload Electron macOS.

Il riuso di helper comuni resta ammesso solo se emerge una responsabilità realmente comune e senza violare l'indipendenza dei test.

---

## 7. Criterio per i prossimi package reali

Nella scelta dei prossimi package da usare durante lo sviluppo di `pkg`, a parità di capacità di esercitare un requisito concreto del package manager, è preferibile scegliere software che abbia anche una ragione realistica di utilizzo in RumiAI.

La profondità della validazione dipende quindi anche dall'uso previsto del software da parte di RumiAI.

Indicazioni già esplicitamente fissate dall'utente:

```text
Electron  rilevanza elevata per future GUI cross-platform e riuso dello stack web
Node.js   rilevanza fondamentale prevista
Java      rilevanza fondamentale prevista
DBeaver   utile come caso package reale e potenzialmente utile in futuro, ma con priorità immediata inferiore
```

Queste indicazioni orientano la pianificazione dei casi reali; non costituiscono metadata del package manager e non implicano da sole nuove dependency di runtime di RumiAI OS.

Ogni integrazione concreta continua a richiedere il normale ciclo:

```text
requisito reale
-> verifica upstream
-> decisione/package definition
-> permanent test proporzionati
-> implementazione solo se necessaria
-> physical validation sulle piattaforme rilevanti disponibili
```

---

## 8. Piattaforme e proprietà ancora aperte

La copertura corrente non autorizza a dichiarare validato ciò che non è stato esercitato.

Restano quindi distinti:

```text
Electron linux-arm64   install/setuid_root già validati; normal launch/workload della revisione corrente pending
Electron linux-x86_64  definito e coperto deterministicamente; physical validation ancora mancante
Electron macos-arm64   definition e test pronti; physical install/native launch/workload pending
altri target           da affrontare quando diventano concretamente rilevanti e verificabili
```

Windows continua a seguire il contratto RumiAI OS già fissato per un ambiente POSIX-compatible; l'eventuale package Electron Windows richiederà una propria analisi concreta e non viene dedotto dal supporto upstream.

---

## 9. Invarianti di pianificazione

```text
PKG-REAL-01  i package reali possono servire sia come casi concreti di sviluppo di pkg sia come software utile a RumiAI
PKG-REAL-02  la chiusura della feature pkg che ha motivato un package non chiude automaticamente la validazione del software se RumiAI prevede di dipenderne
PKG-REAL-03  la validazione di software rilevante copre le piattaforme e le proprietà concrete su cui RumiAI prevede di fare affidamento
PKG-REAL-04  questo criterio non introduce classi, metadata o primitive nel package manager
PKG-REAL-05  Electron resta chiuso come primo caso setuid_root Linux ma aperto come candidato cross-platform da qualificare
PKG-REAL-06  macos-arm64 è il target Electron immediatamente disponibile per la physical validation successiva
PKG-REAL-07  la variante macOS usa il modello catalog-<osarch> esistente e non setuid_root
PKG-REAL-08  la package definition macOS deriva dalla shape realmente osservata dell'archive e preserva Electron.app
PKG-REAL-09  la physical validation Electron macOS include installazione reale e native normal launch con workload minimo controllato
PKG-REAL-10  Java e Node.js sono candidati di elevata rilevanza futura; DBeaver non richiede per questo solo motivo ulteriore lavoro immediato
PKG-REAL-11  le evidence restano revision-specific e non vengono estese a target non esercitati
PKG-REAL-12  Git resta forward-only
```

---

## 10. Sequenza immediata corrente

La preparazione software/documentale è arrivata al gate fisico.

La sequenza immediata prima di dichiarare Electron qualificato sulla revisione corrente è:

```text
1. eseguire la validation permanente del subtree rumiai-os sulla revisione prodotto pin-nata, includendo i nuovi contratti pkg-launch/pkg-integration e la regressione pkg;
2. eseguire tests/external/electron/macos-launch-live.test su macOS ARM64;
3. registrare la physical evidence revision-specific macOS;
4. rieseguire il live install/normal launch Electron Linux ARM64 sulla stessa revisione per proteggere il direct-link e setuid_root dopo il cambiamento del launcher/integration;
5. registrare la physical evidence revision-specific Linux aggiornata;
6. soltanto dopo considerare chiusa la qualificazione Electron sui due reference host ARM64 correntemente disponibili.
```

Eventuali requisiti mancanti emersi soltanto durante la physical validation vengono trattati come requisiti concreti separati e non anticipati per generalizzazione.
