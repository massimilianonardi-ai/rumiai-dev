# Direzione progettuale consolidata — stratificazione dei contratti del futuro substrato general purpose

Date: 2026-09-12  
Status: **CONSOLIDATED DESIGN DIRECTION / NOT ACTIVE**

## Correzione di stato

Questo documento registra una direzione progettuale sulla quale esiste accordo concettuale, ma **non costituisce il nuovo modello di sviluppo corrente di RumiAI**.

Il precedente stato `Accepted` era troppo forte: consolidare una riflessione non equivale ad attivarla come architettura, workflow, contratto operativo o vincolo per lo sviluppo corrente.

Finché non saranno definite in modo sufficientemente completo le questioni importanti della separazione fra futuro substrato general purpose e RumiAI, restano normativi e operativi esclusivamente il modello, i repository, le specifiche, le decisioni Accepted e i test correnti già in vigore.

Nessuna parte di questo documento autorizza oggi:

```text
rinomina di rumiai-os
creazione o adozione del futuro substrato
spostamento di codice o ownership
cambio di bootstrap/runtime/shebang
cambio di namespace o layout
riclassificazione automatica di command o librerie
nuovo workflow di sviluppo
nuove dipendenze di RumiAI
modifiche a rumiai-os, rumiai-tests o pkg-catalog
```

L'eventuale adozione del nuovo modello richiederà una decisione complessiva esplicita dopo che le questioni rilevanti saranno state definite e verificate.

## 1. Direzione concettuale registrata

Se e quando il futuro substrato verrà formalmente adottato, la direzione concordata è distinguere semanticamente:

```text
1. contratto stabile minimo
2. superficie di sviluppo
3. implementation detail privati
```

Solo le prime due classi sarebbero intenzionalmente consumabili.

La classificazione sarebbe semantica e non deriverebbe automaticamente da pathname, linguaggio, presenza nel `PATH`, esistenza di test o semplice raggiungibilità tecnica.

## 2. Contratto stabile minimo

La direzione concordata è che il contratto stabile del futuro substrato debba essere:

```text
piccolo
esplicito
documentato
fortemente testato
compatibile nel tempo per quanto ragionevolmente possibile
indipendente dagli implementation detail evitabili
```

RumiAI in produzione dovrebbe dipendere normalmente soltanto da questa superficie.

Le aree candidate restano, senza classificazione definitiva:

```text
shell contract
service/daemon contract
pochi command pubblici stabili
```

Command correnti come `lang`, `log` e `pkg` restano candidati da valutare e non vengono promossi automaticamente dal presente documento.

## 3. Superficie di sviluppo

La direzione concordata prevede una superficie intenzionalmente più ampia per:

```text
sviluppo del substrato
tooling avanzato
prototipazione
integrazioni sperimentali
diagnostica e amministrazione
consumer tecnici revision-coupled
```

Questa superficie avrebbe un contratto valido per la revisione corrente, ma garanzie di compatibilità inferiori rispetto al contratto stabile.

Le sue primitive dovrebbero essere corrette, documentabili, verificabili e testate in modo proporzionato, pur potendo evolvere più frequentemente.

Il termine colloquiale "SDK di m" continua a non essere un nome canonico di prodotto, componente, package, directory, namespace o comando.

## 4. Implementation detail privati

Una primitive destinata soltanto all'implementazione corrente resterebbe privata e non offrirebbe promesse di:

```text
nome
pathname
firma
formato
persistenza fra revisioni
compatibilità
```

L'osservabilità tecnica o la presenza di test interni non la trasformerebbero in API.

## 5. Disciplina prevista per RumiAI

Nel modello futuro ipotizzato, RumiAI non dovrebbe usare la superficie di sviluppo come scorciatoia per aggirare il contratto stabile.

L'uso revision-coupled della superficie di sviluppo resterebbe appropriato per attività quali:

```text
tooling di sviluppo RumiAI
PoC
test e diagnostica
strumenti non appartenenti al runtime/prodotto distribuito
```

## 6. Percorso di maturazione

La direzione registrata prevede una promozione deliberata:

```text
implementation detail
       |
       | emerge un uso reale e ripetibile
       v
superficie di sviluppo
       |
       | semantica matura
       | utilità general purpose dimostrata
       | necessità di compatibilità stabile
       v
contratto stabile minimo
```

La promozione non dovrebbe avvenire automaticamente per anzianità, numero di chiamanti o presenza di test.

## 7. Testing e documentazione

Nel modello futuro ipotizzato:

- i test del contratto stabile proteggerebbero semantica osservabile, invarianti pubblici, compatibilità, failure contract e portabilità richiesta;
- i test della superficie di sviluppo proteggerebbero la correttezza della revisione corrente senza creare automaticamente compatibilità permanente;
- la documentazione renderebbe esplicita la classe di stabilità;
- path e visibilità non determinerebbero la classe di stabilità.

Questi principi restano una direzione progettuale e **non riclassificano oggi** le primitive del prodotto corrente.

## 8. Relazione con `pkg`

La stessa distinzione potrebbe applicarsi in futuro al package subsystem: RumiAI potrebbe consumare un piccolo contratto stabile mentre resolver, adapter, primitive di materializzazione e diagnostica resterebbero nella superficie di sviluppo o private.

Questo documento non modifica lo schema di `pkg-catalog` né il contratto corrente secondo cui `pkg` non gestisce il sistema base RumiAI.

## 9. Obiettivo architetturale registrato

L'obiettivo concettuale resta:

> stabilizzare poco, ma stabilizzarlo molto bene.

Il futuro substrato dovrebbe poter essere conservativo verso i consumer stabili e molto più libero di evolvere internamente.

## 10. Gate di attivazione

Questa direzione diventerà modello operativo soltanto dopo una futura decisione esplicita che, almeno:

```text
definisca identità e scope del substrato
definisca ownership e repository
definisca il boundary effettivo con RumiAI
definisca i contratti pubblici iniziali
definisca la superficie di sviluppo iniziale
definisca il modello di documentazione e versionamento necessario
definisca gli impatti su bootstrap, runtime, namespace e layout
definisca la migrazione di specifiche, test ed evidence
definisca il percorso forward-only di adozione
```

L'elenco non pretende di essere esaustivo: ulteriori questioni importanti emerse durante l'esplorazione devono essere risolte prima dell'attivazione.

## 11. Invarianti della direzione, non ancora del runtime

Le seguenti sigle registrano il contenuto della direzione progettuale, ma **non sono invarianti operativi del prodotto corrente**:

```text
SUBSTRATE-DIRECTION-01  distinguere stable, development e private
SUBSTRATE-DIRECTION-02  RumiAI in produzione dovrebbe dipendere normalmente solo da stable
SUBSTRATE-DIRECTION-03  development può evolvere più rapidamente
SUBSTRATE-DIRECTION-04  private non costituisce API
SUBSTRATE-DIRECTION-05  path, PATH, linguaggio e test non determinano automaticamente stabilità
SUBSTRATE-DIRECTION-06  la promozione private -> development -> stable è deliberata
SUBSTRATE-DIRECTION-07  "SDK di m" non è terminologia canonica
SUBSTRATE-DIRECTION-08  nessuna di queste direzioni cambia il modello di sviluppo corrente prima dell'activation gate
```

## 12. Stato corrente

Nessuna modifica a implementazione, permanent test o package catalog deriva direttamente da questo documento.

Le analisi correlate restano materiale di progettazione del possibile futuro substrato e non devono essere usate per reinterpretare le specifiche o le decisioni correnti di RumiAI OS.