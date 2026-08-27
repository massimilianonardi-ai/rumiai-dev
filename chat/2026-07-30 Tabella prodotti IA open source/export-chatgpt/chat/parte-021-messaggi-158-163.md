# Tabella prodotti IA open source — Trascrizione canonica

Parte 021 — messaggi **158–163** di **178**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 158 — ASSISTENTE

- Timestamp: `2026-07-30T22:22:11+02:00`
- Node ID: `f6d11606-0c40-4abe-bdfa-bed0f4a66884`
- Message ID: `f6d11606-0c40-4abe-bdfa-bed0f4a66884`

:::writing{variant="document" id="48172"}
# The RumiAI Notebook

## Notebook 001 — Dall'ecosistema AI al paradigma **Senso ↔ Espressione**

---

# Contesto

Durante la progettazione di RumiAI è emersa una constatazione fondamentale:

> La maggior parte delle architetture per l'intelligenza artificiale nasce dalle tecnologie disponibili oggi.

Si parte da concetti come:

- REST
- WebSocket
- OpenAI API
- MQTT
- Computer Use
- Speech-to-Text
- Vision

e si costruisce un sistema che li orchestra.

---

Parallelamente è stata svolta un'analisi dell'ecosistema open source dell'AI.

L'analisi ha mostrato che l'intero panorama può essere classificato secondo la funzione svolta dai vari prodotti:

- Runtime LLM
- Orchestrazione
- Workflow
- RAG
- Vector Database
- Memoria
- Messaging
- Voice
- Vision
- UI
- Computer Use
- Agent Framework
- Home Automation
- Robotica

Ogni categoria espone modalità differenti di comunicazione:

- Request / Response
- Streaming
- Full-Duplex
- Eventi asincroni
- Batch
- File
- MQTT
- HTTP
- WebSocket
- gRPC
- API proprietarie

L'eterogeneità delle implementazioni rende evidente un limite.

Le tecnologie vengono normalmente considerate parte del modello architetturale.

---

# Il problema

Le AI moderne sono estremamente potenti, ma sono ancora fortemente vincolate dalle modalità con cui comunicano.

Un LLM riceve testo.

Un modello di Vision riceve immagini.

Un sistema Speech-to-Text riceve audio.

Computer Use riceve screenshot e produce movimenti del mouse.

Un robot riceve dati da sensori.

Una smart home riceve eventi MQTT.

Dal punto di vista architetturale questi vengono normalmente trattati come sistemi completamente differenti.

In realtà rappresentano tutti la stessa cosa.

> Sono modalità diverse attraverso cui un'entità entra in relazione con il mondo.

---

Da questa osservazione nasce una domanda.

La classificazione basata sulle tecnologie è davvero quella corretta?

Oppure stiamo classificando le implementazioni invece delle funzioni fondamentali?

---

# Il cambio di paradigma

RumiAI vuole seguire il percorso opposto.

L'architettura non deve essere modellata sulle tecnologie disponibili oggi, ma sulle funzioni fondamentali che un'entità intelligente deve possedere per poter interagire con il mondo.

> Le tecnologie cambieranno.

> L'astrazione dovrà rimanere valida.

---

Invece di classificare i sistemi in base alla tecnologia utilizzata, RumiAI propone di classificarli in base alla funzione che svolgono.

L'interazione con il mondo può essere ricondotta a due soli concetti fondamentali.

- Senso
- Espressione

Questi due concetti costituiscono il livello di astrazione sul quale costruire tutta l'architettura.

---

# Perché non Input / Output

I termini Input e Output appartengono all'informatica.

Descrivono il punto di vista del software.

RumiAI vuole descrivere il punto di vista dell'entità intelligente.

Un'entità non possiede Input e Output.

Possiede Sensi.

Ed esprime qualcosa verso il mondo.

> Questo sposta completamente il modello mentale.

Non si sta più progettando un insieme di API.

Si sta progettando una capacità di relazione con il mondo.

---

# Perché non Percezione

Durante la discussione è emersa anche la possibilità di utilizzare il termine "Percezione".

Il termine è stato scartato.

Nelle neuroscienze e nella psicologia cognitiva esiste una distinzione precisa.

Sensazione (Sensation):

acquisizione del segnale.

Percezione (Perception):

interpretazione del segnale.

La percezione implica già un'elaborazione cognitiva.

RumiAI vuole mantenere separati questi livelli.

Il Senso trasporta fenomeni.

L'interpretazione appartiene ai processi cognitivi interni.

---

# Perché Senso

"Senso" rappresenta una capacità.

Non implica che il sistema stia effettivamente osservando qualcosa.

Non implica comprensione.

Non implica memoria.

Non implica ragionamento.

Esprime solamente la possibilità di entrare in contatto con una determinata categoria di fenomeni.

Per questo motivo risulta sufficientemente astratto da poter descrivere sia i sensi biologici sia futuri sensori completamente diversi.

---

# Perché Espressione

Anche il termine "Azione" è stato preso in considerazione.

È stato però ritenuto troppo legato al concetto di volontà o decisione.

L'Espressione è qualcosa di più generale.

Un essere umano si esprime.

Un animale si esprime.

Una pianta si esprime.

Un robot può esprimersi.

Una AI può esprimersi.

L'espressione può assumere qualunque forma.

Può essere verbale, grafica, meccanica, digitale o ancora sconosciuta.

Non descrive il mezzo.

Descrive il rapporto con il mondo.

---

# Prima conclusione

Il modello architetturale di RumiAI non nasce dall'analisi delle tecnologie.

Nasce dall'identificazione delle due capacità fondamentali che consentono ad una Persona Artificiale di entrare in relazione con il mondo.

Tutte le implementazioni esistenti e future dovranno poter essere ricondotte esclusivamente ai concetti di:

- Senso
- Espressione

La tecnologia diventa un dettaglio.

L'astrazione rimane.
:::

---

---
## 159 — UTENTE

- Timestamp: `2026-07-30T22:23:00+02:00`
- Node ID: `6385ef7e-b58a-4d62-98c4-87259068600d`
- Message ID: `6385ef7e-b58a-4d62-98c4-87259068600d`

avanti

---

---
## 160 — ASSISTENTE

- Timestamp: `2026-07-30T22:23:01+02:00`
- Node ID: `ba2e6c10-6c71-4101-a2bb-601f374fe564`
- Message ID: `ba2e6c10-6c71-4101-a2bb-601f374fe564`

:::writing{variant="document" id="59281"}
# The RumiAI Notebook

## Notebook 001 — Dall'ecosistema AI al paradigma **Senso ↔ Espressione**

*(continua)*

---

# Senso

Un Senso rappresenta una capacità di acquisire informazioni dal mondo.

Non identifica un dispositivo.

Non identifica un protocollo.

Non identifica un formato dati.

Identifica esclusivamente una modalità con cui il sistema può ricevere fenomeni provenienti dall'ambiente esterno o interno.

---

Un Senso può essere implementato attraverso:

- una telecamera;
- un microfono;
- una pelle sintetica;
- un radar;
- un sensore di temperatura;
- un filesystem;
- una mailbox;
- un feed di eventi;
- MQTT;
- HTTP;
- OpenAI Vision;
- un LLM che descrive un'immagine;
- qualunque futura tecnologia oggi ancora inesistente.

Tutte queste implementazioni rappresentano lo stesso concetto architetturale.

> La tecnologia diventa un dettaglio.

---

# Espressione

Una Espressione rappresenta la capacità del sistema di modificare il mondo.

Non descrive la decisione.

Non descrive l'intenzione.

Non descrive il dispositivo utilizzato.

Descrive esclusivamente il fatto che il sistema produce un effetto osservabile.

---

Un'Espressione può assumere forme molto diverse:

- pronunciare una frase;
- generare un'immagine;
- cliccare un pulsante;
- muovere il mouse;
- inviare una richiesta HTTP;
- pubblicare un messaggio MQTT;
- controllare un robot;
- accendere una lampadina;
- modificare un file;
- inviare un'email.

Dal punto di vista dell'architettura sono tutte manifestazioni dello stesso concetto.

---

# Fenomeno e significato

Questa distinzione introduce una separazione fondamentale.

Un Senso non dovrebbe trasportare significato.

Dovrebbe trasportare fenomeni.

Ad esempio:

OpenAI Vision restituisce già una descrizione interpretata.

Una pelle sintetica potrebbe invece trasmettere una matrice continua di valori di pressione.

Entrambi sono Sensi.

La differenza è solamente il livello di elaborazione.

L'architettura deve poter supportare indifferentemente dati grezzi e dati già interpretati.

> L'interpretazione non appartiene al Senso.

> Appartiene all'intelligenza.

---

# Conseguenze architetturali

Questa astrazione rende l'architettura indipendente dalle tecnologie.

Quando nascerà un nuovo sensore non sarà necessario modificare il modello concettuale.

Sarà sufficiente implementare un nuovo Senso.

Quando nascerà un nuovo attuatore non cambierà il modello.

Sarà semplicemente una nuova forma di Espressione.

Questo rende RumiAI naturalmente estendibile nel tempo.

---

# Relazione con l'AI-Channel

L'AI-Channel non rappresenta il concetto fondamentale.

Rappresenta il mezzo attraverso cui Sensi ed Espressioni vengono trasportati.

Request/Response, Streaming, Full-Duplex, Eventi asincroni e Batch diventano modalità di trasporto.

Non definiscono più la natura dell'informazione.

---

# Visione a lungo termine

La scelta dei termini "Senso" ed "Espressione" non nasce da una preferenza linguistica.

Nasce dalla volontà di costruire un'architettura che rimanga valida anche quando cambieranno completamente le tecnologie.

Oggi un Senso può essere una webcam.

Domani potrà essere una pelle sintetica, un naso elettronico, un sensore chimico, un radar o un dispositivo che ancora non esiste.

Oggi un'Espressione può essere un click del mouse.

Domani potrà essere un robot umanoide, un sistema domotico, un dispositivo medico o qualunque altro attuatore.

L'architettura non dovrà cambiare.

Cambieranno solamente gli adapter.

> Questo è il principio che guida RumiAI:

> **Le implementazioni evolvono; le astrazioni corrette devono sopravvivere.**

---

# Evoluzione del modello

Successivamente il paradigma viene ulteriormente raffinato.

RumiAI distingue due domini completamente diversi:

- il mondo fisico, continuo nel tempo e nello spazio;
- il mondo cognitivo, nel quale avvengono rappresentazione, ragionamento, memoria e decisione.

Questi due domini non comunicano direttamente.

La loro comunicazione avviene esclusivamente attraverso due astrazioni fondamentali:

- Senso
- Espressione

Esse costituiscono le uniche porte tra il mondo fisico e il mondo astratto dell'intelligenza.

---

# Il mondo fisico

Il mondo fisico evolve continuamente.

Non esistono realmente eventi, messaggi o richieste.

Esistono fenomeni che cambiano nel tempo.

Gli "eventi" sono una costruzione dei sistemi informatici, ottenuta campionando e discretizzando un universo che, nella sua natura, è continuo.

Una richiesta HTTP, un messaggio MQTT, un click del mouse o un interrupt hardware non sono altro che differenti modalità con cui scegliamo di rappresentare e trasportare porzioni di uno stream continuo.
:::

---

---
## 161 — UTENTE

- Timestamp: `2026-07-30T22:23:28+02:00`
- Node ID: `318f9ff8-ba67-47f4-af78-cbb33afec44d`
- Message ID: `318f9ff8-ba67-47f4-af78-cbb33afec44d`

avanti

---

---
## 162 — ASSISTENTE

- Timestamp: `2026-07-30T22:23:28+02:00`
- Node ID: `22b23ee6-e961-4667-a07a-82eaed171e44`
- Message ID: `22b23ee6-e961-4667-a07a-82eaed171e44`

:::writing{variant="document" id="61437"}
# The RumiAI Notebook

## Notebook 001 — Dall'ecosistema AI al paradigma **Senso ↔ Espressione**

*(continua)*

---

# Il Senso

Un Senso è una porta attraverso cui il Sistema Cognitivo osserva il mondo.

La sua responsabilità è trasformare fenomeni continui del mondo fisico in una rappresentazione trasportabile verso il dominio cognitivo.

Internamente un Senso può essere descritto come una catena composta da:

```text
Fenomeno
    ↓
Recettore
    ↓
Trasduzione
    ↓
Elaborazione
    ↓
Trasmissione
```

Ogni implementazione concreta può utilizzare tecnologie completamente differenti, ma il modello concettuale rimane invariato.

Una webcam, un microfono, un sensore di temperatura, una pelle sintetica, un naso elettronico, un feed MQTT o un sistema di Computer Use sono tutti esempi di Sensi.

Ciò che cambia è soltanto il modo in cui il fenomeno viene campionato, trasformato ed elaborato.

---

# L'Espressione

L'Espressione rappresenta il percorso inverso.

È la porta attraverso cui il Sistema Cognitivo modifica il mondo fisico.

Riceve una rappresentazione prodotta dal dominio cognitivo e la trasforma in un fenomeno osservabile nel mondo esterno.

Anche l'Espressione è indipendente dalla tecnologia utilizzata.

Può concretizzarsi come:

- una frase pronunciata;
- un movimento del mouse;
- un comando inviato a un robot;
- un messaggio MQTT;
- una richiesta HTTP;
- l'accensione di una lampada;
- qualunque futura tecnologia ancora inesistente.

---

# Stream, non eventi

Senso ed Espressione non sono basati sul concetto di evento.

Il loro modello naturale è lo stream.

L'universo evolve continuamente.

Un Senso osserva continuamente.

Un'Espressione agisce continuamente.

Gli eventi, i messaggi, i pacchetti, le richieste e le risposte sono soltanto modalità con cui uno stream viene campionato, quantizzato e organizzato per essere trasportato attraverso specifici protocolli.

Non appartengono al modello concettuale di RumiAI.

Appartengono alle implementazioni.

---

# Il ruolo dell'AI-Channel

L'AI-Channel non definisce il significato delle informazioni.

Definisce esclusivamente il loro trasporto.

Streaming continuo, request/response, eventi asincroni, frame, pacchetti e messaggi rappresentano differenti modalità di trasmissione dello stesso flusso informativo.

L'AI-Channel è quindi indipendente sia dal Senso sia dall'Espressione.

---

# Conseguenza architetturale

L'intero Sistema Cognitivo di RumiAI deve conoscere esclusivamente Sensi ed Espressioni.

Non deve conoscere:

- telecamere;
- microfoni;
- protocolli di rete;
- robot;
- mouse;
- tastiere;
- sensori specifici.

Questi appartengono al mondo fisico e vengono completamente astratti dalle due porte di comunicazione.

Questo rende l'architettura indipendente dalle tecnologie disponibili oggi e naturalmente estendibile a dispositivi e modalità di interazione future.

---

# Principio fondante

Senso ed Espressione costituiscono i due confini architetturali tra il mondo fisico e il mondo cognitivo.

Tutto ciò che appartiene al mondo fisico viene osservato attraverso un Senso.

Tutto ciò che il Sistema Cognitivo comunica al mondo fisico passa attraverso un'Espressione.

L'intera evoluzione tecnologica futura potrà modificare le implementazioni di queste due porte, senza alterare il modello concettuale dell'architettura.

---

# Prima validazione del modello (PoC)

L'obiettivo non è descrivere come funziona l'occhio umano, ma trovare una decomposizione che possa essere implementata in software.

| Livello | Responsabilità |
|---------|----------------|
| Fenomeno | Evento fisico o logico |
| Recettore | Acquisisce il fenomeno |
| Trasduzione | Converte il fenomeno in una rappresentazione |
| Elaborazione | Trasforma la rappresentazione senza comprenderla |
| Trasmissione | Porta la rappresentazione al Sistema Cognitivo |
| Sistema Cognitivo | Comprende, ragiona, decide |

Questa tabella evidenzia che ogni livello possiede una responsabilità precisa.

---

# La prima domanda

Se dovessi implementare un nuovo Senso, quali parti dovrei realmente scrivere?

Poiché:

- il Fenomeno esiste già nel mondo;
- il Sistema Cognitivo esiste già;

il Senso dovrebbe implementare esclusivamente:

```text
Recettore
    ↓
Trasduzione
    ↓
Elaborazione
    ↓
Trasmissione
```

Questo costituisce un buon candidato a diventare l'interfaccia di un **Sense Adapter**.
:::

---

---
## 163 — UTENTE

- Timestamp: `2026-07-30T22:24:02+02:00`
- Node ID: `1a38814b-1016-40f2-b5f6-df3fffa21cbe`
- Message ID: `1a38814b-1016-40f2-b5f6-df3fffa21cbe`

avanti

---
