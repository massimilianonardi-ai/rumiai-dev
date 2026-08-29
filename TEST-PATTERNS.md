# RumiAI Test Authoring Patterns

Questo documento raccoglie pattern, primitive e reference implementation emersi durante la costruzione e la validazione della suite permanente `rumiai-tests`.

Deve essere consultato insieme a `TESTING.md` quando si scrivono nuovi test. `TESTING.md` definisce il contratto normativo della suite; questo documento conserva invece know-how implementativo già validato affinché non venga reinventato o degradato nei test successivi.

## 1. Principio di estrapolazione

Quando durante la progettazione, il debug o la validazione fisica di un test emerge una funzionalità riutilizzabile e materialmente importante, non deve rimanere nascosta dentro quel singolo test per semplice inerzia.

La funzionalità deve essere valutata per estrapolazione a uno dei tre livelli seguenti:

```text
1. pattern documentale
2. reference implementation / libreria di authoring dei test
3. tool generale di rumiai-os
```

I livelli non sono mutuamente esclusivi. Una stessa capability può essere documentata al livello 1, avere una reference implementation al livello 2 e successivamente essere promossa anche al livello 3.

L'obiettivo non è ridurre a ogni costo la duplicazione del codice. L'obiettivo è conservare conoscenza verificata, rendere esplicite le scelte host-specifiche e permettere di risalire con precisione alla versione di una primitive riutilizzata.

## 2. Livello 1 — pattern documentale

Una tecnica utile deve essere documentata quando:

- contiene una scelta non ovvia;
- ha richiesto debug o validazione fisica significativa;
- risolve una classe di problemi che può ricomparire;
- contiene snippet o sequenze di shell che è preferibile riusare anziché riscrivere da zero;
- documenta differenze di comportamento tra host, tool o implementazioni.

Il pattern documentale deve descrivere almeno:

- il problema risolto;
- le precondizioni;
- la strategia scelta;
- le varianti host-specifiche rilevanti;
- i failure mode già osservati;
- il pathname dell'eventuale reference implementation canonica.

Gli snippet documentali sono materiale di authoring. Non diventano automaticamente una dipendenza runtime dei test.

## 3. Livello 2 — reference implementation dei test

Quando una funzionalità è sufficientemente concreta e riutilizzabile, deve essere estratta in una reference implementation sotto `rumiai-tests/lib/` o in un'altra posizione esplicitamente dedicata all'authoring.

Una reference implementation può assumersi la responsabilità di:

- scegliere il tool più appropriato in base all'host;
- normalizzare differenze tra implementazioni di utility esterne;
- applicare fallback dichiarati;
- offrire funzioni e convenzioni già validate;
- centralizzare correzioni a bug scoperti durante lo sviluppo della primitive.

### 3.1 Reference implementation non significa dipendenza runtime

L'indipendenza dei test resta prioritaria.

Per primitive fondamentali o complesse, il modello preferito è:

1. mantenere una versione canonica in `rumiai-tests/lib/`;
2. copiare inline nel `.test` le sole funzioni necessarie;
3. rendere il test eseguibile senza `source` o dipendenze da altri file della suite;
4. registrare nel codice del test la provenienza esatta della copia.

Formato raccomandato:

```sh
# Reference implementation copied from:
# massimilianonardi-ai/rumiai-tests@<commit>:lib/<name>.lib
# Copied inline intentionally to preserve test independence.
```

Il commit deve essere un commit Git immutabile, non `main`, `HEAD` o un branch.

Questo crea una relazione di provenienza, non una dipendenza runtime.

### 3.2 Perché registrare il commit

Il riferimento al commit rende possibile un audit retrospettivo.

Se in futuro viene scoperto un bug grave in una primitive canonica, è possibile cercare tutti i test che dichiarano di avere copiato quella specifica versione e stabilire quali risultati storici potrebbero essere stati influenzati.

Un aggiornamento della reference implementation non modifica automaticamente i test che ne hanno incorporato una copia precedente. La modifica dei test storici deve essere deliberata e deve preservare la tracciabilità dell'evidenza già prodotta.

### 3.3 Uso diretto di librerie condivise

Fare `source` di una libreria comune da un test permanente introduce una dipendenza runtime dalla versione corrente di quella libreria.

Questo può essere accettabile per primitive molto piccole, stabili e deliberatamente parte del contratto della piattaforma di test, ma non deve essere il default per logica materialmente necessaria a stabilire l'esito del test.

Quando l'indipendenza e la riproducibilità storica sono più importanti della deduplicazione, la primitive deve essere copiata inline con riferimento al commit di origine.

## 4. Livello 3 — promozione a tool di RumiAI OS

Una capability emersa nei test deve essere valutata per promozione a `rumiai-os` quando smette di essere principalmente una tecnica di testing e diventa una funzionalità generale del sistema.

Segnali favorevoli alla promozione:

- utilità anche fuori dalla suite;
- più componenti del prodotto necessitano della stessa capability;
- gestione host-specifica significativa che è utile centralizzare nel sistema;
- semantica sufficientemente stabile da meritare un'interfaccia pubblica o interna del prodotto;
- beneficio concreto nel rendere la capability disponibile a script, moduli o utenti di RumiAI OS.

La promozione non deve essere automatica. Un helper nato nei test non deve entrare nel prodotto soltanto perché è tecnicamente riutilizzabile.

Prima della promozione devono essere valutati almeno:

- responsabilità architetturale;
- naming;
- interfaccia;
- dipendenze esterne;
- comportamento cross-platform;
- error model;
- sicurezza;
- compatibilità con i principi POSIX e RumiAI OS applicabili.

## 5. Pattern: pilotaggio non interattivo di programmi interattivi

### Problema

Un test può dover esercitare un programma che legge intenzionalmente da `/dev/tty`, non da standard input. Una semplice pipe o redirezione di `stdin` non è quindi sufficiente.

Il problema è particolarmente importante per bootstrap e installer che devono poter essere forniti tramite `curl | sh` mantenendo comunque prompt interattivi sicuri sul terminale reale.

### Strategia canonica corrente

La reference implementation corrente è:

```text
rumiai-tests/lib/interactive.lib
```

Essa presenta al test una primitive di authoring che pilota un eseguibile wrapper dentro uno pseudo-terminale e cattura l'output.

La strategia host-specifica corrente è:

```text
macOS / Darwin
    expect(1)
    attesa esplicita del prompt prima di inviare ogni risposta

Linux
    script(1) util-linux
    input preparato e fornito allo pseudo-terminale
```

Il driver deve mantenere tutta la complessità dentro il test. L'operatore fisico deve continuare a vedere soltanto la normale forma:

```text
cd <rumiai-os>
git pull --ff-only
cd <rumiai-tests>
git pull --ff-only
./rumiai-test <selection>
```

### Formato del dialogo

La reference implementation usa record testuali:

```text
<prompt esatto><TAB><risposta>
```

Ogni record rappresenta una coppia prompt/risposta. Il prompt deve essere una stringa esatta osservabile sul terminale. Prompt e risposta non devono contenere TAB o newline.

Il dialogo è parte della fixture interna del test e non è input dell'operatore umano.

### Failure mode già osservati

Durante la prima implementazione sono emersi almeno questi problemi:

1. La variante BSD/macOS di `script(1)` non è intercambiabile con la variante util-linux usata su Linux per questo scenario.
2. In Tcl/Expect, stringhe tra doppi apici contenenti `[y/N]` interpretano le parentesi quadre come command substitution. I prompt letterali devono essere trattati come dati e non come codice Tcl.
3. Una strategia di logging Expect che disabilita `log_user` può rendere la cattura dell'output meno trasparente e complicare la diagnosi. Il driver deve preservare un transcript osservabile quando fallisce.
4. Inserire manualmente molti comandi dopo un programma che legge da `/dev/tty` può far consumare al prompt righe già incollate nel terminale. Questo è uno dei motivi per cui l'interazione deve essere automatizzata dentro il `.test`.

### Stato di promozione

Questa capability è attualmente classificata come **livello 2**.

È abbastanza generale e importante da avere una reference implementation canonica per i test, ma non è ancora promossa a tool di `rumiai-os` perché l'uso dimostrato finora appartiene all'infrastruttura di test e non al runtime del prodotto.

La promozione a livello 3 deve essere rivalutata se RumiAI OS avrà un'esigenza generale di pilotare processi TTY interattivi in modo programmabile e cross-platform.

## 6. Regola per la creazione di nuovi test

Prima di implementare una nuova primitive tecnica dentro un `.test`, l'autore deve verificare se:

1. il problema è già descritto in questo documento;
2. esiste una reference implementation sotto `rumiai-tests/lib/`;
3. esiste già un tool di `rumiai-os` che fornisce la capability richiesta;
4. la nuova soluzione migliora realmente quella esistente o la sta semplicemente duplicando.

Se durante il nuovo test emerge una primitive migliore, la conoscenza deve ritornare verso i livelli superiori: aggiornamento del pattern documentale, aggiornamento della reference implementation e, quando giustificato, valutazione della promozione a tool del prodotto.
