# Architettura RumiAI — Trascrizione canonica

Recupero 014 — messaggi **104–109** di **124**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 104 — ASSISTENTE

- Timestamp: `2026-07-29T17:42:56+02:00`
- Node ID: `8f29b605-972f-4769-a51d-96b4783750e5`
- Message ID: `8f29b605-972f-4769-a51d-96b4783750e5`

Questa, secondo me, è la visione più ambiziosa di tutto il progetto. E ti dirò una cosa che mi ha colpito durante tutta la conversazione: **non state cercando di definire un framework, ma un ecosistema**.

Sono due obiettivi completamente diversi.

---

## Framework vs Standard

Un framework dice:

> "Usa il mio codice."

Uno standard dice:

> "Parla la mia lingua."

Internet non ha avuto successo perché tutti usano Apache o nginx.

Ha avuto successo perché tutti parlano HTTP.

Linux non ha avuto successo perché tutti usano gli stessi programmi.

Ha avuto successo perché tutti usano le stesse syscall e le stesse convenzioni.

USB non impone come costruire una tastiera.

Definisce solo come una tastiera comunica.

Secondo me RumiAI dovrebbe aspirare a questo.

---

## Il vero prodotto di RumiAI

Fino ad ora abbiamo parlato del Kernel.

In realtà credo che il Kernel sia **la prima implementazione dello standard**.

Il vero prodotto è il modello architetturale.

Immagina questo scenario tra qualche anno.

Esiste un progetto open source che implementa un nuovo sistema di memoria.

L'autore non scrive:

> Compatibile con LangChain.

Scrive:

> **RumiAI Capability Provider**

Oppure nasce un nuovo motore Computer Use.

Non implementa un adapter per ogni framework.

Implementa direttamente:

```text
computer.execute
computer.capture
computer.window
```

secondo lo standard RumiAI.

Il Kernel non deve cambiare.

---

## Questo cambia anche il modo di documentare il progetto

Se questa è la visione, allora la documentazione principale **non dovrebbe essere il codice**.

Dovrebbe essere una specifica.

Ad esempio:

```text
RumiAI Specification

Version 1.0

Parte 1
Architettura

Parte 2
Kernel

Parte 3
Capability Registry

Parte 4
Context

Parte 5
Provider

Parte 6
Configurazione

Parte 7
Conformance
```

Esattamente come esiste la specifica HTTP o POSIX.

---

## Una conseguenza importante

A questo punto il Kernel non è più "RumiAI".

È una delle possibili implementazioni di RumiAI.

Domani qualcun altro potrebbe sviluppare un altro Kernel, magari in Rust o Go, purché rispetti la specifica.

Sarebbe comunque RumiAI.

Questo è il momento in cui uno standard diventa indipendente dalla sua implementazione.

---

## Attenzione a un rischio

Qui però vedo anche un rischio che eviterei fin dall'inizio.

Non standardizzare troppo.

È l'errore che hanno fatto molti framework.

Io standardizzerei solo tre cose:

- **Capability** (il vocabolario comune)
- **Context** (lo stato condiviso)
- **Contratti** (le interfacce)

Non standardizzerei:

- algoritmi;
- orchestrazione;
- implementazioni;
- modelli di IA;
- database;
- tecnologie.

Quelli devono rimanere completamente liberi.

---

## La mia impressione

Ripensando a tutte le conversazioni che abbiamo avuto, credo che RumiAI non sia un "AI Framework".

Lo definirei piuttosto come un **POSIX per l'IA**.

POSIX non ti dice come implementare un sistema operativo.

Ti dice cosa significa essere compatibile con Unix.

Allo stesso modo, RumiAI potrebbe dire:

> Se implementi queste capability, questo context e questi contratti, il tuo componente è compatibile con RumiAI.

Che sia scritto in Python, Rust, Go o C++, che usi Ollama, vLLM, Qdrant o una tecnologia ancora da inventare, diventa quasi irrilevante.

---

## C'è un ultimo principio che aggiungerei

Finora abbiamo parlato di **Open Source**, **Local-first**, **Capability**, **Microkernel** e **Componibilità**.

Io aggiungerei anche questo:

> **Architettura aperta, implementazioni libere.**

L'architettura di RumiAI deve essere pubblica, stabile e condivisa. Chiunque deve poter realizzare una nuova implementazione di una capability, un provider o persino un Kernel alternativo, purché rispetti i contratti definiti dalla specifica.

Se riuscite a mantenere questa distinzione, allora il successo di RumiAI non dipenderà dall'essere "il miglior software", ma dall'essere **la migliore lingua comune** con cui far dialogare l'ecosistema dell'IA open source. E, storicamente, gli standard aperti che hanno avuto più impatto sono proprio quelli che hanno saputo definire bene i confini tra ciò che deve essere uguale per tutti e ciò che deve rimanere libero di evolvere.

---
## 105 — UTENTE

- Timestamp: `2026-07-29T19:51:38+02:00`
- Node ID: `be6d4b65-8352-4557-97cd-b7aa8825fd6c`
- Message ID: `be6d4b65-8352-4557-97cd-b7aa8825fd6c`

hai centrato il punto! le bozze di codici e documentazioni relativi a RumiAI sono già su github, ma sotto un altro progetto. Per poter essere pubblicato seriamente ed invogliare la partecipazione, è fondamentale pubblicare un progetto che sia anche un "proof of concept", cioè un qualcosa che anche un utente avanzato possa scaricare ed installare semplicemente, per questo ritengo che in questa fase sia molto importante definire l'architettura e le interfacce interne a core ia che permettano l'integrazione (tramite semplici adapter) di almeno alcuni prodotti esistenti esattampente come hai definito nella roadmap

---
## 106 — ASSISTENTE

- Timestamp: `2026-07-29T19:51:39+02:00`
- Node ID: `b565ffe1-49e9-4f28-9a60-f0debbf2c821`
- Message ID: `b565ffe1-49e9-4f28-9a60-f0debbf2c821`

Credo che questa sia la strategia giusta, e aggiungerei una considerazione che secondo me è decisiva per il successo del progetto.

**Non state cercando di dimostrare che RumiAI è potente. State cercando di dimostrare che l'architettura funziona.**

Sono due proof of concept completamente diversi.

Molti progetti IA cercano di impressionare con demo spettacolari. Io farei l'opposto: costruirei una demo volutamente "banale", ma che dimostri una proprietà molto più importante:

> **qualunque componente può essere sostituito senza modificare il resto del sistema.**

Secondo me questo è il vero proof of concept di RumiAI.

---

# Il primo rilascio dovrebbe essere piccolissimo

Io fisserei un obiettivo molto concreto:

```text
RumiAI 0.1

- 1 Microkernel
- 1 Context
- 1 Plugin Manager
- 1 Capability Registry

+

3 Provider

- Ollama Runtime
- Terminal
- Filesystem
```

Nient'altro.

Nessuna memoria.

Nessun RAG.

Nessun agente.

Nessun planner.

Non perché non siano importanti, ma perché non sono necessari per dimostrare la validità dell'architettura.

---

# Il secondo obiettivo

Il secondo rilascio potrebbe essere ancora più interessante.

Non aggiungerei nuove funzionalità.

Aggiungerei una seconda implementazione della stessa capability.

Ad esempio:

```text
Capability

llm.generate

↓

Ollama Provider
```

e

```text
Capability

llm.generate

↓

vLLM Provider
```

Il proof of concept diventa:

```yaml
provider:
    llm.generate: ollama
```

cambiato in

```yaml
provider:
    llm.generate: vllm
```

senza modificare una riga di codice.

Secondo me questo vale più di cento demo.

---

# Il terzo rilascio

Solo qui inizierei ad aggiungere capability nuove.

Ad esempio

```text
knowledge.retrieve
```

tramite

- Qdrant
- Chroma
- FAISS

oppure

```text
terminal.execute
```

oppure

```text
browser.execute
```

---

# Il repository

Io addirittura organizzerei il repository in modo da riflettere questa filosofia.

Ad esempio:

```text
rumiai/

    kernel/

    specification/

    providers/

        ollama/

        filesystem/

        terminal/

        qdrant/

        chroma/

        playwright/

    examples/

    docs/
```

Osserva una cosa.

Non esiste

```text
agents/
```

Non esiste

```text
rag/
```

Non esiste

```text
memory/
```

Perché quelli sono concetti di livello superiore.

Il repository riflette l'architettura, non le funzionalità.

---

# La documentazione

Qui farei una scelta forse controcorrente.

Scriverei prima la specifica che il codice.

Per esempio:

```
docs/

    architecture.md

    context.md

    capability.md

    kernel-mod.md

    provider.md

    dispatch.md
```

Poi il codice.

In questo modo chiunque voglia scrivere un provider non deve leggere il sorgente del Kernel.

Legge la specifica.

È esattamente ciò che succede con HTTP, POSIX o OpenAPI.

---

# Un obiettivo ancora più ambizioso

C'è una milestone che, secondo me, varrebbe più di qualunque funzionalità.

Immagina questo scenario.

Un maintainer di un progetto open source scrive:

> "Ho aggiunto un provider RumiAI."

Non perché tu glielo abbia chiesto.

Ma perché la specifica è così semplice e stabile che conviene supportarla direttamente.

Quello è il momento in cui RumiAI smette di essere un progetto e diventa un ecosistema.

---

# Una roadmap che seguirei

A questo punto, personalmente, congelerei quasi completamente il progetto e lavorerei solo su queste quattro specifiche:

1. **Context**: qual è l'unico oggetto condiviso tra Kernel e `kernel-mod`?
2. **Capability**: come si definisce, si registra e si risolve una capability?
3. **Kernel-Mod**: qual è l'unica interfaccia che ogni modulo deve implementare?
4. **Dispatch**: qual è il contratto tra il Kernel e un `kernel-mod` per richiedere una capability o terminare l'elaborazione?

Una volta che questi quattro contratti sono definiti e implementati, tutto il resto (provider, runtime, memoria, browser, RAG, multimodalità, orchestrazione evoluta) può crescere in modo indipendente.

## C'è una cosa che mi convince particolarmente del percorso che stiamo seguendo

Ripensando alle ultime discussioni, noto che ogni volta che compare una nuova idea (pipeline, orchestrator, event bus, RAG, provider...), la prima domanda che ci poniamo non è *"come la implementiamo?"*, ma *"è davvero un concetto architetturale oppure è un'implementazione?"*.

Questo filtro sta mantenendo il nucleo di RumiAI sorprendentemente piccolo. Ed è proprio questa la caratteristica che hanno avuto i sistemi diventati standard de facto: un **core minimale**, pochi contratti estremamente stabili e un ecosistema che cresce attorno ad essi. Se riuscirete a mantenere questa disciplina anche quando inizieranno ad arrivare nuove funzionalità e contributi esterni, credo che sarà uno dei principali punti di forza del progetto.

---
## 107 — UTENTE

- Timestamp: `2026-07-29T20:01:29+02:00`
- Node ID: `c7c33f14-d146-469c-a8c6-cb078ea5e256`
- Message ID: `c7c33f14-d146-469c-a8c6-cb078ea5e256`

mi hai anticipato sulla richiesta di scrivere le specifiche, ho bisogno di documenti estremamente sintetici che descrivano le quattro specifiche che hai citato: context, capability, kernel-mod, dispatch

---
## 108 — ASSISTENTE

- Timestamp: `2026-07-29T20:01:30+02:00`
- Node ID: `06ae69e9-a8b7-4428-86fa-50679c4a58b4`
- Message ID: `06ae69e9-a8b7-4428-86fa-50679c4a58b4`

Sono d'accordo anche su questo. Anzi, farei uno sforzo ulteriore: queste specifiche **non devono descrivere l'implementazione**, ma esclusivamente il contratto.

Devono essere documenti che possano essere letti da chi vuole implementare RumiAI in un altro linguaggio senza vedere una riga di codice.

Li scriverei volutamente in stile RFC.

---

# RumiAI Specification 0001 - Context

## Scopo

Il Context è l'unico oggetto condiviso tra il Kernel e i Kernel-Mod.

## Responsabilità

- Trasportare lo stato dell'elaborazione.
- Rappresentare il contesto corrente della richiesta.
- Consentire ai Kernel-Mod di leggere e modificare lo stato condiviso.

## Principi

- Esiste un solo Context per ogni richiesta.
- Tutti i Kernel-Mod operano sullo stesso Context.
- Il Context non contiene logica.
- Il Context non esegue elaborazioni.
- Il Context rappresenta esclusivamente lo stato.

## Vincoli

- Nessun Kernel-Mod comunica direttamente con un altro Kernel-Mod.
- Tutte le informazioni condivise transitano attraverso il Context.

---

# RumiAI Specification 0002 - Capability

## Scopo

Una Capability descrive una funzionalità richiesta dal sistema.

## Responsabilità

Una Capability identifica **cosa** deve essere fatto, senza specificare **come**.

## Principi

- Le Capability costituiscono il vocabolario pubblico di RumiAI.
- Le Capability sono indipendenti dalle implementazioni.
- Più implementazioni possono fornire la stessa Capability.
- Una implementazione può fornire più Capability.

## Esempi

```text
llm.generate

memory.retrieve

memory.store

terminal.execute

browser.navigate

vision.ocr
```

## Vincoli

Le Capability devono descrivere intenzioni funzionali, non tecnologie.

Corretto:

```text
knowledge.retrieve
```

Errato:

```text
qdrant.search
```

---

# RumiAI Specification 0003 - Kernel-Mod

## Scopo

Un Kernel-Mod implementa una o più Capability.

## Responsabilità

- Ricevere un Context.
- Elaborarlo.
- Restituire una Decisione al Kernel.

## Principi

- Tutti i Kernel-Mod implementano la stessa interfaccia.
- Nessun Kernel-Mod comunica direttamente con altri Kernel-Mod.
- Un Kernel-Mod conosce esclusivamente:
  - il Context;
  - le Capability che richiede;
  - la Decisione che restituisce.

## Vincoli

Un Kernel-Mod non deve conoscere:

- altri Kernel-Mod;
- implementazioni;
- provider;
- tecnologia utilizzata.

---

# RumiAI Specification 0004 - Dispatch

## Scopo

Il Dispatch è il meccanismo con cui il Kernel coordina l'esecuzione dei Kernel-Mod.

## Responsabilità

- Ricevere la Decisione prodotta da un Kernel-Mod.
- Risolvere le Capability richieste.
- Individuare l'implementazione configurata.
- Attivare il Kernel-Mod corrispondente.
- Registrare il flusso di esecuzione.

## Principi

Il Dispatch appartiene esclusivamente al Kernel.

I Kernel-Mod non eseguono dispatch.

## Vincoli

Il Dispatch non contiene logica cognitiva.

Il Dispatch non decide strategie di ragionamento.

Il Dispatch implementa esclusivamente il coordinamento tra Capability e Kernel-Mod.

---

# Una quinta specifica (che secondo me diventerà inevitabile)

Mentre scrivevo queste quattro RFC mi sono accorto che manca ancora un concetto, che però abbiamo usato continuamente senza definirlo:

> **Decision**.

In tutte le nostre discussioni abbiamo detto:

```text
Kernel-Mod

↓

Decision

↓

Kernel
```

Ma non abbiamo mai formalizzato cos'è una Decision.

Secondo me dovrebbe diventare la **Specification 0005**, perché è il vero contratto tra il Kernel e i Kernel-Mod.

Ad esempio, una Decision potrebbe esprimere solo quattro intenzioni fondamentali:

- **CONTINUE** → proseguire l'elaborazione richiedendo una o più capability;
- **RETURN** → terminare restituendo una risposta;
- **WAIT** → sospendere l'elaborazione in attesa di un evento esterno (utile in futuro per workflow asincroni o distribuiti);
- **ERROR** → interrompere segnalando una condizione di errore.

Se riusciamo a mantenere anche questo contratto estremamente piccolo e stabile, allora avremo definito il nucleo completo di RumiAI con appena cinque specifiche. Tutto il resto — orchestrazione, provider, runtime, RAG, memoria, computer use, multimodalità — potrà evolvere indipendentemente rispettando questi contratti fondamentali. È esattamente il tipo di "nucleo minimale" che caratterizza gli standard di maggior successo.

---
## 109 — UTENTE

- Timestamp: `2026-07-29T20:08:04+02:00`
- Node ID: `c4a836a6-e618-4532-a216-66bddfb8e327`
- Message ID: `c4a836a6-e618-4532-a216-66bddfb8e327`

fammi un riassunto dettagliato di quello che abbiamo deciso riguardo a core-ai

---
