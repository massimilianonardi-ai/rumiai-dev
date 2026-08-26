# Architettura RumiAI — Trascrizione canonica

Recupero 017 — messaggi **118–123** di **124**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 118 — ASSISTENTE

- Timestamp: `2026-07-29T22:56:00+02:00`
- Node ID: `31977f00-dbe8-4789-ad5f-ebb278205df2`
- Message ID: `31977f00-dbe8-4789-ad5f-ebb278205df2`

Credo che questo confronto sia fondamentale. Però farei una precisazione metodologica.

Non dobbiamo confrontare **RumiAI** con LangGraph come prodotti, perché hanno obiettivi diversi.

Dobbiamo confrontare **i singoli concetti architetturali**.

Ad esempio:

- Context ↔ State
- Dispatch ↔ Scheduler
- Kernel-Mod ↔ Node
- Capability ↔ Tool
- Decision ↔ Command

Questo permette di prendere le idee migliori senza copiarne l'architettura.

---

# 1. State di LangGraph

Il concetto più interessante di LangGraph è proprio lo **State**.

In pratica ogni nodo riceve lo stesso oggetto.

```text
Nodo A

↓

State

↓

Nodo B

↓

State

↓

Nodo C
```

Ogni nodo può leggerlo e modificarlo.

È molto simile al nostro Context.

## Punti di forza

### 1. Semplicità

Un nodo non deve sapere chi verrà dopo.

Riceve uno State.

Lo modifica.

Restituisce lo State.

Fine.

Questo è estremamente elegante.

---

### 2. Disaccoppiamento

I nodi non si chiamano tra loro.

Comunicano solo tramite lo State.

Questo coincide esattamente con ciò che abbiamo deciso.

---

### 3. Estendibilità

Puoi aggiungere campi allo State senza modificare i nodi esistenti.

Anche questo è molto positivo.

---

## Limiti

Qui iniziano le differenze.

### Lo State è completamente libero

Qualunque nodo può fare

```python
state["pippo"] = ...
```

oppure

```python
state["utente"] = ...
```

oppure

```python
state["history"] = ...
```

Non esiste alcuna struttura architetturale.

Questo è molto comodo.

Ma nel lungo periodo diventa un problema.

---

### Non esiste ownership

Chi è proprietario di

```python
state["messages"]
```

?

Nessuno.

Chi può modificarlo?

Chiunque.

---

### Crescita incontrollata

Dopo un po' lo State diventa enorme.

Dentro ci trovi

- messaggi
- risultati
- embedding
- configurazione
- cache
- errori
- tool
- metadata

Tutto nello stesso oggetto.

È un po' il problema che hanno avuto molti framework basati su un dizionario condiviso.

---

## Cosa prenderei

Io prenderei il principio.

Non l'implementazione.

Ovvero:

> **Esiste un solo Context condiviso.**

---

# 2. Il Context di RumiAI

Secondo me dovrebbe essere più strutturato.

Ad esempio

```yaml
context:

    conversation:

    memory:

    execution:

    capabilities:

    metadata:

    runtime:
```

Non un dizionario arbitrario.

Ma una struttura nota.

---

## Ancora meglio

Potremmo distinguere

```text
Context

↓

Namespace
```

Ad esempio

```text
conversation.*

memory.*

runtime.*

filesystem.*

browser.*

user.*
```

In questo modo un Kernel-Mod può dichiarare:

> scrivo solo dentro

```text
memory.*
```

oppure

```text
runtime.*
```

Secondo me è molto più robusto.

---

# 3. Scheduler

LangGraph ha uno scheduler.

In pratica decide quale nodo eseguire.

Qui invece io preferisco decisamente la nostra soluzione.

Perché?

Perché LangGraph conosce il grafo.

Il Kernel di RumiAI no.

Lo conosce solo l'Orchestrator.

Questa separazione mi convince molto di più.

---

# 4. Node

I Node di LangGraph sono molto vicini ai nostri Kernel-Mod.

Direi che il concetto è praticamente identico.

La differenza è enorme però.

Un Node vive dentro LangGraph.

Un Kernel-Mod vive dentro uno standard.

---

# 5. Command

Negli ultimi mesi LangGraph ha introdotto il concetto di Command.

È una cosa molto intelligente.

Un nodo può dire

```text
vai al nodo X
```

oppure

```text
termina
```

oppure

```text
aggiorna lo state
```

Questo è molto vicino alla Decision che abbiamo immaginato.

Anzi.

Credo che la nostra Decision dovrebbe ispirarsi parecchio a questo concetto.

---

# 6. Tool

Qui invece non seguirei LangGraph.

Per LangGraph tutto diventa un Tool.

Noi invece abbiamo introdotto le Capability.

Secondo me sono molto più astratte.

Un Tool è un'implementazione.

Una Capability è un'intenzione.

Questa differenza è enorme.

---

# Dove credo che possiamo migliorare LangGraph

Qui arriva la parte interessante.

Secondo me LangGraph ha un'ottima idea.

Ma è ancora troppo orientato ai workflow.

RumiAI invece può diventare più generale.

Ad esempio:

## Context con ownership

Ogni namespace potrebbe avere un proprietario.

```yaml
conversation:
    owner: kernel

memory:
    owner: memory-mod

browser:
    owner: browser-mod
```

Non significa che gli altri non possano leggere.

Significa che solo il proprietario può modificare direttamente quella parte del Context.

Questo eviterebbe molti conflitti e renderebbe il comportamento del sistema più prevedibile.

---

## Capability dichiarative

Invece di dire

```text
uso il Tool X
```

un modulo dice

```text
ho bisogno di

knowledge.retrieve
```

Il Dispatch risolve automaticamente il provider.

Questo rende l'architettura molto più flessibile rispetto a un sistema in cui i nodi conoscono direttamente gli strumenti.

---

## Context tipizzato

Un altro miglioramento possibile è rendere il Context più strutturato.

Invece di un dizionario libero:

```python
state["qualunque_cosa"] = ...
```

potremmo avere un modello con sezioni note e regole di accesso. Questo facilita la validazione, la documentazione e l'evoluzione della specifica.

---

# La mia conclusione

Se dovessi riassumere il confronto in una tabella:

| Concetto | LangGraph | RumiAI |
|----------|-----------|---------|
| Stato condiviso | ✅ Ottima idea | Mantenerla, ma con struttura e regole |
| Nodo indipendente | ✅ | ✅ |
| Grafo | Integrato nel framework | Demandato a un `kernel-mod` orchestratore |
| Tool | Conoscenza diretta | Capability risolte dal Dispatch |
| Scheduler | Integrato | Demandato al Kernel + Orchestrator |
| Standard | No | Sì (obiettivo del progetto) |

La caratteristica che, a mio avviso, può distinguere davvero RumiAI non è tanto avere uno stato condiviso o un orchestratore, quanto **trasformare questi concetti in contratti architetturali stabili e indipendenti dall'implementazione**. È la differenza tra un framework che offre un modo di costruire applicazioni e una specifica che permette a implementazioni diverse di interoperare. È qui che vedo il potenziale più originale del progetto.

---
## 119 — UTENTE

- Timestamp: `2026-07-29T23:11:55+02:00`
- Node ID: `c5be7810-f7d6-453e-85b2-6c4c1afce4ee`
- Message ID: `c5be7810-f7d6-453e-85b2-6c4c1afce4ee`

ritorniamo sugli input e gli output, ci sono I/O multimodali da e verso l'utente e I/O multimodali da e verso devices, ad esempio computer use agisce su mouse e tastierea, oppure input da sensori di temperatura o di altro tipo per orchestrare una smart home in modo non lineare. credo che dobbiamo standardizzare gli input e gli output

---
## 120 — ASSISTENTE

- Timestamp: `2026-07-29T23:11:56+02:00`
- Node ID: `af95f291-d54b-45a8-b125-1c09cef82cc3`
- Message ID: `af95f291-d54b-45a8-b125-1c09cef82cc3`

Sono d'accordo. Anzi, credo che questo sia il prossimo grande concetto architetturale da definire, e penso che dobbiamo fare attenzione a **non confondere la modalità di comunicazione con la natura dell'informazione**.

Secondo me finora abbiamo parlato di tre cose diverse senza distinguerle chiaramente:

1. **Capability** → cosa sa fare un modulo.
2. **Communication Contract** → come il Kernel comunica con il modulo.
3. **Data Contract** → che tipo di informazione entra ed esce dal modulo.

Credo che ci manchi proprio il terzo.

---

# L'errore da evitare

Non standardizzerei "voice", "chat", "computer use" o "smart home".

Sono implementazioni.

Standardizzerei invece i **tipi di dato** che possono attraversare il Kernel.

---

# Un esempio

Un microfono produce...

...audio.

Una webcam produce...

...video.

Una tastiera produce...

...eventi di input.

Un sensore produce...

...misure.

Un LLM produce...

...testo.

Un sintetizzatore vocale produce...

...audio.

Quindi il Kernel non dovrebbe conoscere "microfono".

Dovrebbe conoscere solo:

```text
Audio
```

---

# Potremmo definire un Data Contract

Ad esempio:

```text
Text

Audio

Image

Video

Document

Event

Measurement

Command

State
```

Questi sono i "mattoncini" che attraversano il sistema.

---

# Esempio

Speech-to-Text

Input

```text
Audio
```

Output

```text
Text
```

---

Vision

Input

```text
Image
```

Output

```text
Text
```

---

LLM

Input

```text
Text
```

Output

```text
Text
```

---

Computer Use

Input

```text
Command
```

Output

```text
Event
```

---

Smart Home

Input

```text
Measurement
```

Output

```text
Command
```

---

# Osserva una cosa interessante

Un Kernel-Mod non dovrebbe dichiarare solo le Capability.

Dovrebbe dichiarare anche

```yaml
provides:
  - speech.transcribe

accepts:
  - Audio

returns:
  - Text
```

oppure

```yaml
provides:
  - vision.detect

accepts:
  - Image

returns:
  - Text
```

Questo ricorda molto una funzione tipizzata.

---

# Qui però farei un passo ancora più astratto

Mi chiederei:

> **Esistono davvero "input" e "output"?**

Oppure esistono solo **messaggi**?

---

Per esempio

Voice

produce

```text
Audio Chunk
```

Il TTS

consuma

```text
Text Chunk
```

Il Browser

produce

```text
Screenshot
```

Il Vision

consuma

```text
Screenshot
```

Il Terminal

produce

```text
Terminal Output
```

L'LLM

consuma

```text
Text
```

In tutti i casi stiamo semplicemente facendo transitare messaggi.

---

# Mi viene in mente un'altra analogia

Linux non conosce:

- webcam
- tastiera
- mouse
- joystick

Conosce:

- file descriptor
- stream
- device

Il resto è un driver.

---

Secondo me RumiAI dovrebbe fare qualcosa di analogo.

Non conoscere:

- Chat
- Voice
- Vision
- Smart Home

Conoscere soltanto un insieme molto piccolo di **tipi di messaggio**.

---

# Proposta

Io introdurrei una nuova specifica.

## Message Contract

Ogni messaggio ha:

```yaml
id:
conversation:
timestamp:

type:

payload:

metadata:
```

Dove

```yaml
type:
```

può essere

```text
text

audio

image

video

document

measurement

event

command

state
```

Il Kernel non interpreta il payload.

Lo trasporta.

---

# Questo apre uno scenario molto interessante

Un modulo potrebbe dichiarare:

```yaml
provides:
    speech.transcribe

input:
    - audio

output:
    - text
```

Un altro

```yaml
provides:
    llm.generate

input:
    - text

output:
    - text
```

Un altro ancora

```yaml
provides:
    speech.synthesize

input:
    - text

output:
    - audio
```

L'Orchestrator potrebbe collegarli automaticamente semplicemente perché i tipi sono compatibili.

---

# E qui vedo un'opportunità ancora più grande

Finora abbiamo identificato cinque contratti fondamentali:

- Context
- Capability
- Kernel-Mod
- Dispatch
- Decision

Io credo che ne manchi uno destinato a diventare altrettanto centrale:

- **Message Contract**

Perché, in fondo, RumiAI non orchestra moduli: **orchestra lo scambio di messaggi tipizzati tra moduli indipendenti**. Se le capability descrivono **cosa** un modulo sa fare e il communication contract descrive **come** dialogarci, il message contract descrive **cosa attraversa il sistema**. Questa separazione delle tre dimensioni (funzione, comunicazione e dati) mi sembra coerente con tutta la filosofia di RumiAI e potrebbe renderlo estremamente flessibile per casi d'uso che oggi vanno dalla chat alla voce, fino alla robotica e alla domotica, senza introdurre concetti speciali per ciascun dominio.

---
## 121 — UTENTE

- Timestamp: `2026-07-29T23:18:45+02:00`
- Node ID: `f581ce13-618e-4eb4-b429-d49529077234`
- Message ID: `f581ce13-618e-4eb4-b429-d49529077234`

fammi una sintesi dei canali di comunicazione

---
## 122 — ASSISTENTE

- Timestamp: `2026-07-29T23:18:45+02:00`
- Node ID: `6f8da3c3-ee93-446a-9978-98393f40160d`
- Message ID: `6f8da3c3-ee93-446a-9978-98393f40160d`

Credo che dalla discussione siano emersi **tre livelli distinti**, che è importante non confondere.

---

# 1. Communication Contract (come comunica un Kernel-Mod)

Descrive **come il Kernel interagisce con un Kernel-Mod**.

Non riguarda HTTP, WebSocket o OpenAI, ma il modello di comunicazione richiesto dal modulo.

Le modalità fondamentali sono:

| Modello | Descrizione | Esempi |
|---------|-------------|---------|
| **Request/Response** | Chiamata sincrona con una risposta finale | LLM, terminal.execute |
| **Streaming** | Risposta progressiva a una singola richiesta | Generazione testo, TTS |
| **Event** | Scambio asincrono di eventi indipendenti | Sensori, notifiche, smart home |
| **Full-Duplex** | Comunicazione bidirezionale continua | Conversazione vocale, teleoperazione, robotica |

Queste rappresentano le **capacità comunicative** di un `kernel-mod`.

---

# 2. Adapter (come il mondo esterno comunica con RumiAI)

Gli adapter sono completamente separati dal Kernel.

Sono semplicemente traduttori.

Esempi:

- OpenAI API
- REST
- WebSocket
- CLI
- MQTT
- MCP
- gRPC

Il Kernel non conosce nessuno di questi protocolli.

---

# 3. Message Contract (che cosa viene trasportato)

Indipendentemente dal protocollo e dalla modalità di comunicazione, il Kernel trasporta messaggi tipizzati.

Ad esempio:

- Text
- Audio
- Image
- Video
- Document
- Event
- Measurement
- Command
- State

---

# Riassunto grafico

```text
                 Mondo esterno

        OpenAI    REST    MQTT   CLI
            │        │       │      │
            └────────┴───────┴──────┘
                     Adapter
                        │
──────────────────────────────────────────
                RumiAI Kernel
──────────────────────────────────────────
                        │
        Communication Contract
                        │
      ┌─────────────────┼─────────────────┐
      │                 │                 │
 Request/Response   Streaming        Full-Duplex
      │                 │                 │
      └─────────────────┼─────────────────┘
                        │
                 Kernel-Mod
                        │
                  Capability
                        │
                Message Contract
                        │
         Text Audio Image Event ...
```

---

# Una possibile evoluzione

C'è però una riflessione che farei.

Finora abbiamo parlato di **modalità di comunicazione**.

Ma se guardiamo un sistema operativo moderno, il Kernel non ragiona in termini di "request/response" o "streaming": ragiona in termini di **canali**.

Potremmo quindi definire un'astrazione ancora più semplice.

## Channel

Un canale è un endpoint logico tra il Kernel e un `kernel-mod`.

Ogni canale dichiara le proprie caratteristiche.

Ad esempio:

```yaml
channel:
  mode: full-duplex
  session: true
  streaming: true
```

oppure

```yaml
channel:
  mode: request-response
  session: false
```

oppure

```yaml
channel:
  mode: event
```

In questo modo il Kernel non deve conoscere i dettagli del protocollo o del trasporto: apre semplicemente un **canale** con determinate proprietà.

## La mia proposta

Io farei diventare il **Channel** un concetto architetturale di primo livello.

- Il **Message Contract** descrive *cosa* passa nel sistema.
- La **Capability** descrive *cosa* sa fare un modulo.
- Il **Channel** descrive *come* Kernel e modulo si scambiano quei messaggi.
- Gli **Adapter** traducono i protocolli esterni (OpenAI, REST, MQTT, ecc.) nei canali nativi di RumiAI.

Questo mantiene l'architettura pulita e indipendente dalle tecnologie, lasciando agli adapter il compito di integrare il software esistente.

---
## 123 — UTENTE

- Timestamp: `2026-07-29T23:29:55+02:00`
- Node ID: `f0950b51-da53-4724-8edb-2ae182278f1b`
- Message ID: `f0950b51-da53-4724-8edb-2ae182278f1b`

ok definiamo il ai-channel

---
