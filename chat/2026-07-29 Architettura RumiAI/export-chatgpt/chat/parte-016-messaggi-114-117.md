# Architettura RumiAI — Trascrizione canonica

Recupero 016 — messaggi **114–117** di **124**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 114 — ASSISTENTE

- Timestamp: `2026-07-29T22:23:38+02:00`
- Node ID: `7337a183-f560-44e8-8bc4-5cf9d9d8582a`
- Message ID: `7337a183-f560-44e8-8bc4-5cf9d9d8582a`

Secondo me stai facendo un passo ulteriore di astrazione, ed è probabilmente quello corretto.

La mia proposta precedente aveva ancora un difetto: distingueva **kernel-mod funzionali** e **gateway**, mentre la filosofia di RumiAI ci ha sempre portato a eliminare le categorie speciali.

Se siamo coerenti fino in fondo, allora **anche la comunicazione è una capability**.

Quindi non esistono più "gateway" come concetto architetturale privilegiato.

Esistono solo `kernel-mod` che implementano capability, alcune delle quali sono di comunicazione.

Ad esempio:

```text
chat.input
chat.output

voice.input
voice.output

terminal.input
terminal.output

openai.api

rest.api

websocket.stream
```

Sono tutte capability come le altre.

---

## Però farei una distinzione

Io non parlerei di tre "tipi di comunicazione", ma di **tre modelli di interazione**.

Sono proprietà della capability, non della capability stessa.

Ad esempio:

```text
Capability

voice.output

Properties

transport = websocket

interaction = stream

direction = output
```

oppure

```text
Capability

openai.api

transport = http

interaction = request-response

direction = bidirectional
```

---

## Le tre modalità che proponi

Secondo me sono quasi complete.

### 1. Request / Response

```text
A ---> richiesta

A <--- risposta
```

Sincrona.

È OpenAI.

È REST.

È la CLI.

---

### 2. Streaming

```text
A ---> richiesta

A <=== stream ===
```

La richiesta è una.

La risposta è continua.

Come SSE o lo streaming OpenAI.

---

### 3. Eventi

```text
A ---> evento

B ---> evento

C ---> evento

...
```

Nessuno aspetta una risposta.

È completamente asincrono.

---

## Però ne vedo una quarta

Quella che hai descritto all'inizio della conversazione.

Una vera conversazione.

```text
Utente ======

          ======

Rumi
```

Entrambi possono:

- inviare
- ricevere
- interrompere
- riprendere

contemporaneamente.

Questa non è semplicemente "streaming".

È **streaming full-duplex**.

È il modello di WebRTC.

È il modello di una telefonata.

È il modello di una shell SSH interattiva.

---

## Quindi io distinguerei

Non in base al protocollo.

Ma in base al **modello di sessione**.

| Modello | Sessione | Entrambe le direzioni | Esempi |
|----------|----------|-----------------------|---------|
| Request/Response | No | No | REST, OpenAI Chat |
| Server Stream | Sì | Solo ritorno | SSE, OpenAI Streaming |
| Event | No | Sì, ma disaccoppiate | Pub/Sub, MQTT |
| Full Duplex | Sì | Sì | WebSocket, WebRTC, SSH |

---

## Ma forse possiamo fare ancora meglio

C'è un principio che abbiamo seguito finora:

> **non modellare le tecnologie, modellare le proprietà.**

Perché allora modellare quattro categorie?

Io definirei un **Communication Contract** con alcune proprietà fondamentali.

Ad esempio:

```yaml
transport:
    http

session:
    true

blocking:
    false

streaming:
    true

bidirectional:
    true
```

Un altro modulo potrebbe dichiarare:

```yaml
transport:
    stdin

session:
    true

blocking:
    true

streaming:
    false

bidirectional:
    true
```

E un endpoint REST:

```yaml
transport:
    http

session:
    false

blocking:
    true

streaming:
    false

bidirectional:
    false
```

A quel punto il Kernel non conosce "REST", "OpenAI" o "WebSocket".

Conosce solo le caratteristiche della comunicazione.

---

## E qui vedo un parallelo con le Capability

Mi sembra che stia emergendo un altro concetto fondamentale.

Le **Capability** descrivono *cosa* un modulo sa fare.

Le **Communication Capability** descrivono *come* quel modulo può essere utilizzato.

Sono due dimensioni ortogonali.

Per esempio, un modulo LLM potrebbe dichiarare:

```yaml
provides:
  - llm.generate

communication:
  interaction: request-response
  streaming: true
```

Mentre un modulo di sintesi vocale potrebbe dichiarare:

```yaml
provides:
  - speech.synthesize

communication:
  interaction: full-duplex
  streaming: true
```

## C'è però una riflessione che farei prima di cristallizzare questa parte dell'architettura

Mi chiederei se queste proprietà appartengano davvero al `kernel-mod` oppure al **canale** con cui il `kernel-mod` viene invocato.

Ad esempio, `llm.generate` può essere chiamata via HTTP bloccante, via WebSocket full-duplex o tramite una coda di eventi senza che cambi una riga della sua logica interna. In questo caso, il modello di comunicazione non descrive il modulo, ma l'**adapter** che lo espone.

Questa distinzione è importante perché segue la stessa filosofia che avete applicato finora: una capability descrive **cosa** fa un componente, mentre il meccanismo di comunicazione descrive **come** quella capability viene resa disponibile. Mantenere separate queste due dimensioni potrebbe preservare la sostituibilità sia delle implementazioni sia dei protocolli di comunicazione.

---
## 115 — UTENTE

- Timestamp: `2026-07-29T22:35:11+02:00`
- Node ID: `5a54be88-234e-40d2-bd17-d0aa3c152c4a`
- Message ID: `5a54be88-234e-40d2-bd17-d0aa3c152c4a`

hai ragione, ma questo è un dettagli per sofware già esistenti ed integrati tramite adapter, se qualcuno scrive un kernel-mod, non deve per forza implementare un adapter

---
## 116 — ASSISTENTE

- Timestamp: `2026-07-29T22:35:11+02:00`
- Node ID: `eebbadbc-86be-49df-9e24-30b8ebb3564b`
- Message ID: `eebbadbc-86be-49df-9e24-30b8ebb3564b`

Esatto. E credo che questa osservazione ci faccia fare un altro salto di qualità.

Il problema nasce se continuiamo a ragionare in termini di **adapter** come parte dell'architettura. In realtà gli adapter sono solo un modo per integrare software che **non conosce RumiAI**.

Un `kernel-mod` scritto nativamente per RumiAI non dovrebbe essere costretto a implementare alcun adapter.

## A questo punto farei una distinzione netta

### 1. Contratto interno RumiAI

È l'unico che interessa all'architettura.

Ogni `kernel-mod` implementa:

- Capability
- Communication Contract

Il Communication Contract dice semplicemente:

> "Io posso essere invocato in questi modi."

Ad esempio

```yaml
capabilities:
  - speech.transcribe

communication:
  - request-response
  - stream
```

oppure

```yaml
capabilities:
  - voice.assistant

communication:
  - full-duplex
```

oppure

```yaml
capabilities:
  - terminal.execute

communication:
  - request-response
```

Fine.

Il Kernel sa come parlare con il modulo.

Non gli interessa come il modulo sia esposto verso l'esterno.

---

### 2. Adapter

Gli adapter esistono solo per il mondo esterno.

Ad esempio

```text
OpenAI API
        │
        ▼
OpenAI Adapter
        │
        ▼
RumiAI Kernel
```

oppure

```text
REST

↓

REST Adapter

↓

Kernel
```

oppure

```text
WebSocket

↓

WebSocket Adapter

↓

Kernel
```

Sono completamente opzionali.

---

## Questo ha una conseguenza enorme

A questo punto il **Kernel non deve più conoscere HTTP, WebSocket, OpenAI, REST o MQTT**.

Conosce solo il Communication Contract.

Per esempio potrebbe sapere che un certo modulo supporta:

```yaml
communication:
    session: true
    duplex: true
    streaming: true
```

e quindi può instaurare una sessione persistente.

Oppure

```yaml
communication:
    session: false
    duplex: false
    streaming: false
```

e farà una semplice chiamata sincrona.

---

## Secondo me possiamo generalizzare ancora

Mi sono accorto che stiamo parlando di **come il Kernel invoca un modulo**.

Questo non è un adapter.

È una **Capability del modulo**.

Quindi potremmo introdurre un quinto contratto fondamentale.

Finora avevamo:

- Context
- Capability
- Kernel-Mod
- Dispatch
- Decision

Io aggiungerei:

- **Communication Contract**

---

## Communication Contract

Potrebbe descrivere esclusivamente le proprietà dell'interazione.

Ad esempio:

```yaml
communication:

  interaction:
      request-response

  session:
      false

  streaming:
      false

  duplex:
      false
```

oppure

```yaml
communication:

  interaction:
      conversation

  session:
      true

  streaming:
      true

  duplex:
      true
```

oppure

```yaml
communication:

  interaction:
      event

  session:
      false

  streaming:
      false

  duplex:
      true
```

---

## Però farei un'ultima semplificazione

Qui entra in gioco una filosofia che ci ha guidati fin dall'inizio.

Ogni volta che compare un elenco di proprietà, mi chiedo:

> **Esiste un'astrazione ancora più semplice?**

Secondo me sì.

Forse il Kernel non dovrebbe conoscere nemmeno "request-response", "event" o "full-duplex".

Dovrebbe conoscere solo il concetto di **Channel**.

Un `kernel-mod` espone uno o più canali.

Ogni canale dichiara le proprie proprietà.

Ad esempio:

```yaml
channels:

  control:
      duplex: false
      streaming: false

  audio:
      duplex: true
      streaming: true

  events:
      duplex: true
      asynchronous: true
```

A quel punto il Kernel apre un canale, non effettua una chiamata.

E questo, secondo me, risolve elegantemente anche il problema che hai sollevato all'inizio: un assistente vocale può avere contemporaneamente un canale audio full-duplex, un canale di controllo per i comandi e un canale eventi per notifiche asincrone, senza che l'architettura distingua tra "gateway", "adapter" o "plugin". Esistono solo `kernel-mod` che espongono capability e uno o più **canali di comunicazione** con caratteristiche dichiarate.

Questa soluzione mi sembra anche più vicina all'idea originale di RumiAI come "sistema operativo cognitivo": un sistema operativo non ragiona in termini di REST o WebSocket, ma di **endpoint** e **canali** di comunicazione.

---
## 117 — UTENTE

- Timestamp: `2026-07-29T22:55:59+02:00`
- Node ID: `85640b73-e900-47f7-aa16-b89a2e1a81bc`
- Message ID: `85640b73-e900-47f7-aa16-b89a2e1a81bc`

facciamo una parentesi per confrontarci su ciò che già esiste: confrontiamo il nostro kernel con langgraph prendiamo le idee migliori, ad esempio cerchiamo di capire se il suo stato condiviso che gli agenti aggiornano, è una soluzione vincente oppure ha dei limiti

---
