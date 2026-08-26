# Architettura RumiAI — Trascrizione canonica

Recupero 015 — messaggi **110–113** di **124**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 110 — ASSISTENTE

- Timestamp: `2026-07-29T20:08:05+02:00`
- Node ID: `a22fb597-d389-4b04-b927-713b05501180`
- Message ID: `a22fb597-d389-4b04-b927-713b05501180`

Volentieri. Anzi, credo che questo sia il momento giusto per "congelare" le decisioni prese finora. Quello che segue lo considero il **documento di architettura del Core IA - Livello 1**.

---

# RumiAI - Core IA (Livello 1)

## Visione

Il Core IA rappresenta il sistema operativo cognitivo di RumiAI.

Il suo obiettivo **non è implementare capacità cognitive**, ma fornire un'infrastruttura minima, stabile ed estensibile sulla quale possano essere costruite.

Il Core IA deve poter evolvere senza modificare le interfacce pubbliche.

---

# Filosofia progettuale

Il progetto segue alcuni principi fondamentali.

## 1. Architettura prima dell'implementazione

Si definiscono prima:

- i moduli
- le responsabilità
- i contratti

e solo successivamente le implementazioni.

---

## 2. Divide et Impera

Ogni volta che un'interfaccia viene definita e validata, viene considerata stabile.

Da quel momento i due moduli possono evolvere indipendentemente.

È il principio già applicato tra:

```text
UI Gateway

↓

Core IA
```

mediante le API OpenAI.

Lo stesso principio viene ora applicato internamente al Core IA.

---

## 3. Contratti stabili

RumiAI non standardizza le implementazioni.

Standardizza esclusivamente i contratti.

Le implementazioni possono essere sostituite.

---

## 4. Componibilità

Il sistema non viene costruito aggiungendo funzionalità.

Viene costruito componendo elementi semplici.

Come i LEGO.

La complessità deve emergere dalla composizione.

---

# Microkernel

Il Core IA adotta un'architettura Microkernel.

Il Kernel deve essere il più piccolo possibile.

Non contiene:

- memoria
- ragionamento
- planner
- RAG
- tool
- runtime
- orchestrazione

Queste sono implementazioni.

---

# Responsabilità del Kernel

Il Kernel implementa esclusivamente:

- lifecycle
- gestione del Context
- dispatch
- caricamento della configurazione
- logging
- osservabilità

Nient'altro.

---

# Kernel-Mod

Ogni funzionalità del Core IA viene implementata da un Kernel-Mod.

Non esistono moduli privilegiati.

Nemmeno l'Orchestrator è un componente speciale.

È semplicemente un Kernel-Mod.

---

## Proprietà dei Kernel-Mod

Ogni Kernel-Mod:

- implementa una o più Capability;
- riceve un Context;
- produce una Decision;
- non comunica direttamente con altri Kernel-Mod.

---

## I Kernel-Mod non conoscono

- altri Kernel-Mod;
- Provider;
- tecnologie;
- implementazioni.

---

# Context

Per ogni richiesta esiste un solo Context.

Il Context rappresenta l'intero stato dell'elaborazione.

Tutti i Kernel-Mod operano sullo stesso Context.

Il Context:

- non contiene logica;
- non esegue elaborazioni;
- rappresenta esclusivamente lo stato condiviso.

---

# Capability

Le Capability rappresentano il vocabolario pubblico del Core IA.

Descrivono **cosa** il sistema deve fare.

Mai **come**.

Esempi:

```text
llm.generate

memory.retrieve

terminal.execute

browser.navigate

vision.ocr
```

Le Capability sono indipendenti dalle implementazioni.

---

# Provider

I Provider sono implementazioni delle Capability.

Un Provider può implementare una o più Capability.

Esempio:

```text
Capability

↓

llm.generate

↓

Provider

↓

Ollama
```

oppure

```text
Capability

↓

llm.generate

↓

Provider

↓

vLLM
```

Il resto del sistema rimane identico.

---

# Dispatch

Il Dispatch appartiene esclusivamente al Kernel.

Il suo compito è:

- ricevere una Decision;
- risolvere le Capability richieste;
- individuare il Provider configurato;
- eseguire il relativo Kernel-Mod;
- registrare il flusso.

Il Dispatch non implementa alcuna logica cognitiva.

---

# Plugin Manager

Il Plugin Manager è un registro.

Sa esclusivamente:

- quali Kernel-Mod esistono;
- quali Capability implementano.

Non prende decisioni.

Non orchestra.

---

# Decision

Il Kernel e i Kernel-Mod comunicano attraverso una Decision.

La Decision rappresenta il risultato dell'elaborazione di un Kernel-Mod.

Essa indica al Kernel il passo successivo.

La Decision diventerà probabilmente una specifica dedicata.

---

# Orchestrator

L'Orchestrator non è una componente architetturale privilegiata.

È un normale Kernel-Mod.

Può implementare:

- esecuzione sequenziale;
- grafo;
- planner;
- orchestrazione distribuita;
- qualsiasi altra politica.

Il Kernel non conosce la strategia adottata.

---

# Comunicazione

La comunicazione segue una regola precisa.

Componenti appartenenti allo stesso livello architetturale non comunicano direttamente.

Ad esempio:

```text
Gateway

↓

Core IA
```

mai

```text
Gateway

↓

Gateway
```

Analogamente:

```text
Kernel-Mod

↓

Kernel
```

mai

```text
Kernel-Mod

↓

Kernel-Mod
```

Questo garantisce:

- logging centralizzato;
- auditing;
- sicurezza;
- osservabilità;
- sostituibilità.

---

# Architettura basata sulle Capability

Il Core IA non è organizzato per moduli.

È organizzato per Capability.

Le implementazioni possono cambiare.

Le Capability rimangono stabili.

Questo rende possibile sostituire completamente una tecnologia senza modificare il resto del sistema.

---

# Riutilizzo del software esistente

RumiAI non vuole reinventare software già esistente.

Quando esiste un progetto open source maturo:

- Ollama
- vLLM
- llama.cpp
- Qdrant
- Playwright
- Whisper
- Piper
- ecc.

RumiAI implementa esclusivamente un Provider.

Non duplica la funzionalità.

---

# Ruolo di RumiAI

RumiAI non vuole diventare un framework monolitico.

Vuole diventare uno standard architetturale.

Il Kernel rappresenta semplicemente la prima implementazione di tale standard.

---

# Obiettivo finale

L'obiettivo non è che tutti utilizzino il Kernel ufficiale.

L'obiettivo è che i progetti open source implementino direttamente le interfacce RumiAI.

Ad esempio:

```text
Whisper
```

potrebbe dichiarare:

```text
Provides:

speech.transcribe
```

oppure

```text
Qdrant
```

potrebbe dichiarare:

```text
Provides:

knowledge.retrieve
knowledge.store
```

oppure

```text
Playwright
```

potrebbe dichiarare:

```text
Provides:

browser.navigate
browser.click
browser.extract
```

In questo scenario, RumiAI non sarebbe più un semplice software, ma una **specifica architetturale** adottata da un ecosistema di progetti indipendenti.

---

# Le quattro specifiche fondamentali

Dalla discussione è emerso che il nucleo del Core IA può essere descritto da quattro contratti principali, ai quali probabilmente si aggiungerà un quinto:

1. **Context** — definisce lo stato condiviso dell'elaborazione.
2. **Capability** — definisce il vocabolario funzionale pubblico del sistema.
3. **Kernel-Mod** — definisce l'unica interfaccia che ogni modulo deve implementare.
4. **Dispatch** — definisce il meccanismo con cui il Kernel coordina l'esecuzione e risolve le capability.
5. *(Proposto)* **Decision** — definisce il contratto con cui un `Kernel-Mod` comunica al Kernel il risultato della propria elaborazione e il passo successivo.

## Osservazione finale

Ripercorrendo l'intera evoluzione del progetto, noto un principio ricorrente che, a mio avviso, caratterizza profondamente RumiAI:

> **Ogni livello architetturale definisce esclusivamente un insieme minimo di contratti stabili. Tutta la complessità viene demandata al livello successivo attraverso implementazioni liberamente sostituibili.**

Questo principio è stato applicato al Livello 0 (UI Gateway ↔ Core IA tramite API OpenAI) e ora viene applicato ricorsivamente all'interno del Core IA stesso. È questa coerenza metodologica, più ancora delle singole scelte tecniche, che potrebbe rendere RumiAI una base architetturale solida e duratura.

---
## 111 — UTENTE

- Timestamp: `2026-07-29T22:09:14+02:00`
- Node ID: `afb12963-6944-4ca2-b789-f95400f626de`
- Message ID: `afb12963-6944-4ca2-b789-f95400f626de`

l'architettura che si sta delineando, è molto buona per situazioni semplici, ma sto rilevando alcuni limiti architetturali che si traducono direttamente in limiti funzionali, ad esempio l'interfaccia openai non consente lo streaming bidirezionale full-duplex e soprattutto vincola il gateway di richiesta e risposta ad essere lo stesso e quindi se io volessi fare delle richieste a voce tramite il microfono, non posso chiedere di rispondermi sulla chat o viceversa a meno di non implementare un gateway monoltico che fa tutto, ma comunque credo che openai non vada bene lo stesso per questo tipo di richieste.

---
## 112 — ASSISTENTE

- Timestamp: `2026-07-29T22:09:15+02:00`
- Node ID: `0b04651f-9c49-427e-a670-d91a14b84eb8`
- Message ID: `0b04651f-9c49-427e-a670-d91a14b84eb8`

Secondo me hai individuato il **primo vero limite architetturale** del progetto. E, cosa ancora più importante, non è un limite di implementazione, ma di **modello di comunicazione**.

Credo che questo sia il momento di distinguere due concetti che finora abbiamo inconsapevolmente sovrapposto:

- **Protocollo di invocazione** (OpenAI API)
- **Protocollo di comunicazione** (quello che dovrebbe usare RumiAI)

Sono due cose molto diverse.

---

## Il problema di OpenAI API

Le API OpenAI sono pensate per un paradigma molto preciso:

```text
Client
   │
Request
   │
   ▼
Server
   │
Response
   ▼
Client
```

È un classico modello **Request/Response**.

Anche quando usi lo streaming, in realtà hai:

```text
Request

↓

Stream di risposta

↓

Fine
```

Non esiste una vera conversazione.

---

## Una conversazione umana è diversa

Immagina di parlare con Siri.

```text
Utente: "Ehi Rumi..."

Rumi:
    "Dimmi."

Utente:
    "Apri..."

Rumi:
    "Quale applicazione?"

Utente:
    "Firefox"

Rumi:
    "Lo apro."
```

Durante tutta questa interazione:

- entrambi parlano;
- entrambi ascoltano;
- entrambi possono interrompersi.

È **full-duplex**.

---

## Ancora peggio: i gateway

Oggi abbiamo implicitamente assunto

```text
Terminal Gateway

↓

Core

↓

Terminal Gateway
```

oppure

```text
OpenWebUI

↓

Core

↓

OpenWebUI
```

cioè il gateway di ingresso coincide con quello di uscita.

Ma questa è solo una particolare implementazione.

---

## Un esempio

Immagina:

```text
Voice Gateway

↓

Core

↓

Chat Gateway
```

Oppure

```text
REST Gateway

↓

Core

↓

Voice Gateway
```

Oppure

```text
Terminal

↓

Core

↓

Telegram
```

Non c'è nessun motivo architetturale per vietarlo.

---

## Quindi dov'è il problema?

Il problema è che OpenAI identifica implicitamente:

- il chiamante
- il destinatario

Sono lo stesso oggetto.

---

## Credo che manchi un livello

Secondo me l'architettura dovrebbe evolvere così.

Oggi

```text
Gateway

↓

Core

↓

Gateway
```

Domani

```text
Gateway Input

↓

Core

↓

Gateway Output
```

che sono completamente indipendenti.

---

## Ancora meglio

Io eliminerei proprio il concetto di "Gateway".

Parlerei di **Endpoint**.

Ogni endpoint implementa una capability.

Ad esempio

```text
voice.input
```

oppure

```text
chat.output
```

oppure

```text
terminal.output
```

---

## E il Core?

Il Core non risponde più.

Il Core pubblica eventi.

Ad esempio

```text
PromptReceived
```

oppure

```text
ResponseReady
```

oppure

```text
NeedMoreInformation
```

Gli endpoint decidono cosa farne.

---

## Qui torna utile l'Event Bus

Prima avevi espresso dubbi sull'Event Bus.

Credo che il motivo fosse che lo immaginavamo **interno al Kernel**.

Io invece lo vedo come un **bus di comunicazione**, non come un motore decisionale.

Ad esempio

```text
Voice Input

↓

UserPrompt Event

↓

Core
```

poi

```text
Core

↓

AssistantResponse Event
```

e infine

```text
Chat Output
```

oppure

```text
Voice Output
```

oppure

```text
Terminal Output
```

---

## Questo cambia completamente il ruolo dei gateway

Non sono più client.

Sono peer.

Possono:

- inviare eventi;
- ricevere eventi.

Entrambe le direzioni.

---

## E OpenAI?

Qui secondo me arriva la soluzione elegante.

**OpenAI API non deve più essere il protocollo interno.**

Deve diventare un **adapter**.

Esattamente come Ollama.

Quindi:

```text
OpenWebUI

↓

OpenAI Adapter

↓

RumiAI Event Bus

↓

Kernel
```

Dal punto di vista di OpenWebUI nulla cambia.

Continua a parlare OpenAI.

Dal punto di vista del Kernel, OpenAI non esiste.

Esistono solo eventi.

---

## Questa evoluzione è coerente con la filosofia di RumiAI

Osserva cosa è successo.

All'inizio abbiamo usato OpenAI API come **contratto architetturale**.

Ora ci rendiamo conto che è troppo specifico.

Non lo buttiamo via.

Lo spostiamo di livello.

Diventa un adapter.

È esattamente lo stesso percorso che abbiamo seguito con Ollama:

- prima era il Core IA;
- poi è diventato un Provider `llm.generate`.

Ora accade lo stesso con OpenAI:

- prima era l'interfaccia del Core;
- poi diventa un Provider `openai.gateway`.

---

# La proposta che farei

A questo punto inizierei a distinguere chiaramente due livelli di comunicazione:

### Livello esterno (compatibilità)

Serve a dialogare con software esistente.

Può includere:

- OpenAI API
- REST
- CLI
- WebSocket
- MCP
- gRPC
- altri protocolli

Questi sono tutti **adapter**.

---

### Livello interno (nativo RumiAI)

Serve a far comunicare Endpoint e Kernel.

Qui non userei più il paradigma Request/Response.

Definirei invece un protocollo **event-driven**, asincrono e full-duplex, basato su eventi e identificativi di conversazione.

In questo modo diventano naturali scenari come:

- parlare al microfono e ricevere la risposta sulla chat;
- inviare un prompt dalla chat e ascoltare la risposta tramite sintesi vocale;
- avere più endpoint attivi contemporaneamente;
- interrompere una risposta vocale mentre è ancora in corso;
- distribuire la conversazione su nodi diversi in futuro.

Questa evoluzione, a mio avviso, non contraddice quanto abbiamo costruito finora: è il passo successivo del principio "divide et impera". Le API OpenAI rimangono un eccellente **adapter di compatibilità** verso l'ecosistema esistente, ma il **contratto nativo di RumiAI** dovrebbe essere progettato in funzione della vostra visione di sistema operativo cognitivo, non dei vincoli di un'API nata per un modello client/server tradizionale.

---
## 113 — UTENTE

- Timestamp: `2026-07-29T22:23:38+02:00`
- Node ID: `fe7280a5-f899-4469-b878-21ca516b0d67`
- Message ID: `fe7280a5-f899-4469-b878-21ca516b0d67`

credo che anche così ci siano dei limiti architetturali, probabilmente una soluzione ptrebbe essere avere solo dei kernel-mod ed ognuno tra le sue capabilities espone anche delle capabilities di comunicazione, ovvero se comunica in streaming full-duplex, ad eventi asincroni, oppure in modalità api-call bloccante. credo che le tipologie di comunicazione possano essere solo queste tre, giusto?

---
