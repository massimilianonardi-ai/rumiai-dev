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

In particolare:

```text
Linux setuid_root validation        completata per lo scope esercitato
Electron Linux ARM64 live install   completato
Electron macOS live install         non ancora eseguito
Electron macOS normal launch        non ancora eseguito
Electron cross-platform qualification ancora aperta
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

pubblica anche l'artifact upstream:

```text
electron-v44.3.0-darwin-arm64.zip
```

La sua presenza upstream è verificata, ma la struttura interna dell'archive e il command target macOS devono essere verificati prima di fissare la package definition concreta. Non vengono dedotti per analogia dalla variante Linux.

---

## 4. Prossimo scope Electron

Il prossimo lavoro Electron è la definizione e la validazione della variante:

```text
catalog-macos-arm64
```

riusando il contratto esistente:

```text
<pkg>/catalog-<osarch>/
```

Non serve alcuna nuova astrazione del catalogo.

La variante macOS non deve dichiarare `setuid_root`: quella primitive resta limitata agli stream Linux già fissati.

Prima di creare la package definition devono essere verificati almeno:

```text
artifact upstream corretto
archive layout reale
useful root risultante dopo pkg_extract
pathname reale dell'eseguibile Electron
command/link mapping necessario
assenza di trasformazioni Linux-specifiche non applicabili
```

Solo i dati osservati vengono poi consolidati nel catalogo.

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
command/link mapping corretto
normal launch tramite il launcher RumiAI
avvio reale di Electron su macOS ARM64
esecuzione di un workload Electron minimo controllato
cleanup del workload e del processo di test
assenza di regressioni nella selection permanente rumiai-os/pkg
```

Il workload minimo deve verificare proprietà su cui RumiAI può realisticamente fare affidamento, senza trasformare la suite in un test generico di Electron.

In particolare è appropriato verificare che un'applicazione Electron minima basata su HTML/JavaScript possa essere avviata tramite il package installato e raggiunga uno stato osservabile di ready/avvio corretto.

L'eventuale verifica visiva umana di una finestra può integrare la physical validation, ma non deve sostituire quando possibile un esito deterministico prodotto dal workload.

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

Non deve essere semplicemente eseguito su macOS o indebolito con branch che rendano ambigua la proprietà verificata.

La copertura macOS deve verificare le proprietà macOS realmente necessarie a RumiAI mantenendo distinta la semantica Linux `setuid_root`.

Il riuso di helper comuni è ammesso solo se emerge una responsabilità realmente comune e senza violare l'indipendenza dei test.

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

## 8. Piattaforme non ancora fisicamente disponibili

La copertura corrente non autorizza a dichiarare validato ciò che non è stato esercitato.

Restano quindi distinti:

```text
Electron linux-arm64   fisicamente validato per install/setuid_root
Electron linux-x86_64  definito e coperto deterministicamente, physical validation ancora mancante
Electron macos-arm64   prossimo target da definire e validare fisicamente
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
PKG-REAL-06  il prossimo target Electron concretamente verificabile è macos-arm64
PKG-REAL-07  la variante macOS usa il modello catalog-<osarch> esistente e non setuid_root
PKG-REAL-08  la package definition macOS viene fissata soltanto dopo verifica dell'archive layout reale
PKG-REAL-09  la physical validation Electron macOS deve includere installazione reale e normal launch con workload minimo controllato
PKG-REAL-10  Java e Node.js sono candidati di elevata rilevanza futura; DBeaver non richiede per questo solo motivo ulteriore lavoro immediato
PKG-REAL-11  le evidence restano revision-specific e non vengono estese a target non esercitati
PKG-REAL-12  Git resta forward-only
```

---

## 10. Sequenza immediata

Il prossimo lavoro concreto prima di dichiarare Electron validato su macOS ARM64 è:

```text
1. ispezionare realmente electron-v44.3.0-darwin-arm64.zip;
2. fissare la package definition catalog-macos-arm64 in base alla shape osservata;
3. aggiungere la definizione concreta a pkg-catalog;
4. aggiungere test permanenti proporzionati senza contaminare il test Linux setuid_root;
5. eseguire il live install su macOS ARM64;
6. eseguire il normal launch con workload Electron minimo;
7. registrare physical evidence revision-specific;
8. rieseguire la regressione permanente rumiai-os/pkg sui reference host applicabili.
```

Eventuali requisiti mancanti del package manager emersi dall'archive o dal launch vengono trattati come requisiti concreti separati e non anticipati per generalizzazione.