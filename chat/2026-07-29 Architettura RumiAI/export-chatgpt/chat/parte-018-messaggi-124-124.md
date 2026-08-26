# Architettura RumiAI — Trascrizione canonica

Recupero 018 — messaggi **124–124** di **124**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 124 — ASSISTENTE

- Timestamp: `2026-07-29T23:29:56+02:00`
- Node ID: `b765ffc2-123e-417a-8383-cae8470c6577`
- Message ID: `b765ffc2-123e-417a-8383-cae8470c6577`

Sono d'accordo. Anzi, credo che **AI-Channel** possa diventare uno dei concetti fondanti di RumiAI, al pari di Context e Capability.

Lo progetterei seguendo la stessa filosofia: **massima astrazione, minima complessità**.

---

# RumiAI Specification 0006 - AI-Channel

## Scopo

Un AI-Channel rappresenta un canale logico di comunicazione tra il Kernel e un Kernel-Mod.

Il canale definisce esclusivamente **come** vengono scambiati i messaggi.

Non definisce:

- il protocollo di rete;
- il trasporto;
- la tecnologia utilizzata;
- il contenuto dei messaggi.

---

# Principi

Un AI-Channel è:

- indipendente dal protocollo;
- indipendente dal trasporto;
- indipendente dalle Capability;
- indipendente dai Message.

Il Kernel comunica esclusivamente attraverso AI-Channel.

---

# Responsabilità

Un AI-Channel deve garantire:

- apertura del canale;
- chiusura del canale;
- invio messaggi;
- ricezione messaggi;
- gestione della sessione;
- gestione del ciclo di vita del canale.

---

# Proprietà

Ogni AI-Channel dichiara le proprie proprietà.

## Mode

Definisce il modello di comunicazione.

Valori previsti:

```text
request-response
stream
event
full-duplex
```

---

## Session

```text
true
false
```

Indica se il canale mantiene uno stato persistente.

Esempi:

REST

```text
false
```

Conversazione vocale

```text
true
```

---

## Streaming

```text
true
false
```

Indica se i messaggi possono essere inviati in modo incrementale.

---

## Direction

```text
input
output
bidirectional
```

---

# Operazioni

Ogni AI-Channel espone sempre le stesse operazioni logiche.

```text
open()

close()

send(message)

receive()

status()
```

Il modo in cui vengono implementate è irrilevante.

---

# Message

L'AI-Channel trasporta esclusivamente Message.

Non interpreta il contenuto.

Il contenuto appartiene al Message Contract.

---

# Capability

Un Kernel-Mod può esporre uno o più AI-Channel.

Ad esempio

```yaml
capabilities:

  - speech.transcribe

channels:

  realtime:
      mode: full-duplex

  batch:
      mode: request-response
```

Lo stesso modulo può quindi essere utilizzato in modi differenti.

---

# Adapter

Gli Adapter convertono protocolli esterni in AI-Channel.

Esempio

```text
REST

↓

REST Adapter

↓

AI-Channel

↓

Kernel
```

oppure

```text
OpenAI

↓

OpenAI Adapter

↓

AI-Channel

↓

Kernel
```

---

# Il Kernel

Il Kernel non conosce:

- HTTP
- WebSocket
- MQTT
- OpenAI
- REST

Conosce soltanto AI-Channel.

---

# Obiettivo

L'obiettivo dell'AI-Channel è separare completamente:

- il trasporto;
- il protocollo;
- la comunicazione;
- la logica cognitiva.

---

# Osservazione: possiamo fare ancora meglio

Mentre lo scrivevo, mi sono accorto che stiamo ancora pensando al canale come a una **connessione**. Ma un sistema operativo non ragiona in termini di connessioni: ragiona in termini di **risorse**.

Forse un AI-Channel dovrebbe essere definito come una **risorsa del Kernel**.

Questo porta a una conseguenza molto interessante:

```text
Kernel

├── Context
├── AI-Channel
├── Capability Registry
├── Plugin Registry
└── Dispatcher
```

In questa visione, un `kernel-mod` non "chiama" un altro modulo e non apre direttamente connessioni. Chiede semplicemente al Kernel un canale con determinate caratteristiche (`full-duplex`, `stream`, `event`, ecc.) e il Kernel gli restituisce una risorsa conforme al contratto. Questo mantiene il principio del microkernel ancora più puro: tutta la gestione della comunicazione rimane centralizzata nel Kernel, mentre i `kernel-mod` restano completamente ignari dei dettagli di trasporto e delle implementazioni concrete.

Infine, farei un'ultima modifica terminologica: chiamarlo semplicemente **Channel** invece di **AI-Channel**. All'interno della specifica RumiAI il prefisso "AI" è ridondante, mentre un nome breve come `Channel` rende l'API e la documentazione più pulite (`Context`, `Capability`, `Channel`, `Decision`, `Dispatch`, `Kernel-Mod`). È una piccola scelta lessicale, ma contribuisce a dare alla specifica un aspetto più essenziale e vicino a quello di un vero sistema operativo.

---
