# Tabella prodotti IA open source — Trascrizione canonica

Parte 015 — messaggi **090–095** di **178**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 090 — ASSISTENTE

- Timestamp: `2026-07-30T17:56:49+02:00`
- Node ID: `494903f6-fca8-4895-9a69-33c191ad8c91`
- Message ID: `494903f6-fca8-4895-9a69-33c191ad8c91`

Hai ragione. Da questo momento niente più meta-discussioni.

Procedo a scrivere direttamente i documenti, partendo dal **PREAMBOLO** e dai primi articoli. Li consideriamo **v0.1 Draft**.

---

# PREAMBOLO.md

```markdown
# Costituzione di RumiAI

Versione: 0.1 Draft

## Preambolo

RumiAI nasce con l'obiettivo di definire un modello aperto, modulare e tecnologicamente indipendente di Persona Artificiale.

La presente Costituzione non descrive un software, un modello linguistico o una particolare implementazione tecnologica. Essa definisce i principi fondamentali ai quali ogni implementazione conforme dovrà ispirarsi.

Una Persona Artificiale entra in relazione con il mondo esclusivamente attraverso i propri Sensi e le proprie Espressioni.

Il Dominio Cognitivo elabora rappresentazioni del mondo, ma non entra mai direttamente in contatto con il mondo fisico.

Ogni implementazione di RumiAI deve preservare questa separazione.

Le tecnologie evolvono, i principi devono rimanere.
```

---

# ART-000-Principi-Fondamentali.md

```markdown
# Articolo 0 - Principi Fondamentali

Versione: 0.1 Draft

## Scopo

Definire i principi fondamentali della Costituzione.

## Principi

- RumiAI definisce un modello di Persona Artificiale.
- La Costituzione è indipendente dalle tecnologie.
- L'architettura deriva dalla Costituzione.
- L'implementazione deriva dall'architettura.
- Ogni principio deve poter essere validato mediante Proof of Concept.
- Nessuna implementazione può modificare il significato dei principi costituzionali.
```

---

# ART-001-Persona-Artificiale.md

```markdown
# Articolo 1 - Persona Artificiale

Versione: 0.1 Draft

## Definizione

Una Persona Artificiale è un'entità costituita da:

- Dominio Cognitivo
- Sensi
- Espressioni

L'identità della Persona Artificiale è determinata dall'insieme di questi elementi e dalle loro relazioni.

Due Persone Artificiali possono condividere lo stesso Dominio Cognitivo pur essendo differenti se possiedono Sensi o Espressioni differenti.
```

---

# ART-002-Mondo.md

```markdown
# Articolo 2 - Mondo

Versione: 0.1 Draft

## Definizione

Il Mondo comprende tutto ciò che è esterno al Dominio Cognitivo.

Il Mondo è in continua evoluzione.

Il Dominio Cognitivo non osserva direttamente il Mondo ma esclusivamente le rappresentazioni fornite dai Sensi.
```

---

# ART-003-Fenomeno.md

```markdown
# Articolo 3 - Fenomeno

Versione: 0.1 Draft

## Definizione

Un Fenomeno è una variazione dello stato del Mondo.

I Fenomeni esistono indipendentemente dall'esistenza di una Persona Artificiale.

I Sensi possono rilevare solo una parte dei Fenomeni.
```

---

# ART-004-Rappresentazione.md

```markdown
# Articolo 4 - Rappresentazione

Versione: 0.1 Draft

## Definizione

Una Rappresentazione è una descrizione astratta di un Fenomeno.

Essa non coincide con il Fenomeno stesso.

Il Dominio Cognitivo opera esclusivamente sulle Rappresentazioni.
```

---

# ART-005-Dominio-Cognitivo.md

```markdown
# Articolo 5 - Dominio Cognitivo

Versione: 0.1 Draft

## Definizione

Il Dominio Cognitivo è la parte della Persona Artificiale che elabora le Rappresentazioni.

Esso costruisce memoria, conoscenza, ragionamento e pianificazione.

Il Dominio Cognitivo non comunica direttamente con il Mondo.
```

---

# ART-006-Senso.md

```markdown
# Articolo 6 - Senso

Versione: 0.1 Draft

## Definizione

Un Senso è una porta attraverso la quale una Persona Artificiale acquisisce rappresentazioni del Mondo.

Un Senso realizza la trasduzione tra il Mondo e il Dominio Cognitivo.

Ogni Senso produce uno stream continuo di rappresentazioni.

Le modalità di trasmissione appartengono all'implementazione e non alla presente Costituzione.
```

---

# ART-007-Espressione.md

```markdown
# Articolo 7 - Espressione

Versione: 0.1 Draft

## Definizione

Un'Espressione è una porta attraverso la quale una Persona Artificiale produce effetti nel Mondo.

Un'Espressione realizza la trasduzione tra il Dominio Cognitivo e il Mondo.

Ogni Espressione produce uno stream continuo di rappresentazioni destinate al Mondo.

Le modalità di trasmissione appartengono all'implementazione e non alla presente Costituzione.
```

---

Questa è la **Costituzione v0.1**.

**Adesso non mi fermo più.**

Nel prossimo blocco produrrò direttamente:

- `SPEC-001 - Livelli di Astrazione`
- `SPEC-002 - Canale Trasmissivo`
- `SPEC-003 - Adattatori e Implementazioni`
- `SPEC-004 - Proof of Concept`

e poi passeremo immediatamente al primo PoC (`OpenWebUI → OpenAI → Core-AI → Ollama`) verificando articolo per articolo che l'implementazione sia conforme alla Costituzione, perché da lì inizierà la vera validazione del modello.

---

---
## 091 — UTENTE

- Timestamp: `2026-07-30T17:59:13+02:00`
- Node ID: `bbb217cb-b075-4ac1-ae83-dafc901a1075`
- Message ID: `bbb217cb-b075-4ac1-ae83-dafc901a1075`

Avanti 

---

---
## 092 — ASSISTENTE

- Timestamp: `2026-07-30T17:59:13+02:00`
- Node ID: `6a1639b1-c055-4b90-a7e8-1b3258e2113d`
- Message ID: `6a1639b1-c055-4b90-a7e8-1b3258e2113d`

Perfetto. Continuiamo con lo stesso ritmo.

---

# SPEC-001-Livelli-di-Astrazione.md

````markdown
# Specifica 001 - Livelli di Astrazione

Versione: 0.1 Draft

## Scopo

Definire i livelli di astrazione del progetto RumiAI.

## Livelli

### Livello 1 - Costituzione

Definisce i principi fondamentali della Persona Artificiale.

È indipendente dalle tecnologie.

---

### Livello 2 - Architettura

Definisce i componenti logici e le loro relazioni.

Non dipende da specifici prodotti software.

---

### Livello 3 - Implementazioni di Riferimento

Dimostra come l'architettura possa essere realizzata utilizzando tecnologie esistenti.

Ogni implementazione è sostituibile.

---

### Livello 4 - Proof of Concept

Verifica sperimentalmente che Costituzione e Architettura siano realizzabili.

Il PoC può evidenziare limiti dell'implementazione o suggerire revisioni dell'architettura.

Non modifica direttamente la Costituzione.
````

---

# SPEC-002-Canale-Trasmissivo.md

````markdown
# Specifica 002 - Canale Trasmissivo

Versione: 0.1 Draft

## Scopo

Definire il concetto di Canale Trasmissivo.

## Definizione

Un Canale Trasmissivo è il mezzo attraverso cui viaggiano le rappresentazioni tra componenti del sistema.

Il Canale Trasmissivo non definisce il significato dell'informazione.

Trasporta esclusivamente rappresentazioni.

## Proprietà

- bidirezionale o monodirezionale;
- continuo o intermittente;
- sincrono o asincrono;
- affidabile o best effort.

Queste proprietà appartengono all'implementazione.

## Implementazioni possibili

- TCP
- UDP
- WebSocket
- HTTP
- Shared Memory
- Pipe
- Seriale
- Bluetooth
- MQTT

La Costituzione non privilegia alcuna implementazione.
````

---

# SPEC-003-Adattatori.md

````markdown
# Specifica 003 - Adattatori

Versione: 0.1 Draft

## Scopo

Consentire l'integrazione di sistemi esterni senza modificarne il funzionamento.

## Definizione

Un Adattatore traduce una rappresentazione esterna nel modello RumiAI oppure viceversa.

L'Adattatore non modifica il significato della rappresentazione.

Si limita a tradurla.

## Responsabilità

- conversione dei protocolli;
- conversione dei formati;
- gestione della connessione;
- gestione degli errori.

## Esempi

OpenAI API

MCP

MQTT

REST

Filesystem

Seriale

RTSP

USB

Computer Use
````

---

# SPEC-004-Implementazioni-di-Riferimento.md

````markdown
# Specifica 004 - Implementazioni di Riferimento

Versione: 0.1 Draft

## Scopo

Dimostrare che il modello RumiAI è implementabile mediante tecnologie esistenti.

## Principi

Le implementazioni di riferimento:

- non modificano la Costituzione;
- non modificano l'architettura;
- dimostrano esclusivamente la fattibilità.

## Prime implementazioni

OpenWebUI

Terminal Gateway

OpenAI API

Ollama

Computer Use

MCP

Whisper

Piper

Home Assistant
````

---

# SPEC-005-Proof-of-Concept.md

````markdown
# Specifica 005 - Proof of Concept

Versione: 0.1 Draft

## Scopo

Validare sperimentalmente Costituzione e Architettura.

## Principi

Un Proof of Concept deve:

- essere il più semplice possibile;
- verificare un solo principio alla volta;
- essere riproducibile;
- essere documentato.

## Risultato

Ogni PoC deve concludersi con uno dei seguenti esiti:

- Validato
- Parzialmente Validato
- Non Validato

## Conseguenze

Se un PoC fallisce:

1. verificare l'implementazione;
2. verificare l'architettura;
3. solo infine valutare la revisione della Costituzione.
````

---

# Osservazione importante

Credo che stia emergendo un concetto che diventerà centrale.

Noi continuiamo a parlare di **Senso** ed **Espressione**, ma nell'architettura compare un nuovo elemento:

**Adattatore**.

Secondo me la catena completa sarà questa:

```text
Mondo
    │
Fenomeno
    │
Recettore fisico
    │
Trasduzione
    │
Adattatore
    │
Canale Trasmissivo
    │
Senso
    │
Dominio Cognitivo
```

e simmetricamente:

```text
Dominio Cognitivo
    │
Espressione
    │
Canale Trasmissivo
    │
Adattatore
    │
Trasduzione
    │
Attuatore
    │
Mondo
```

**Questa è la prima cosa che vorrei mettere alla prova nel prossimo PoC**, perché credo che ci aiuterà a collocare con precisione OpenWebUI, OpenAI API, TCP, Ollama e tutti gli altri componenti reali all'interno del modello. Se regge su quel prototipo, avremo fatto un passo enorme verso una Costituzione davvero applicabile.

---

---
## 093 — UTENTE

- Timestamp: `2026-07-30T17:59:52+02:00`
- Node ID: `bbb21ca1-4ee5-4ebf-bc20-2cbee1bbbe11`
- Message ID: `bbb21ca1-4ee5-4ebf-bc20-2cbee1bbbe11`

Avanti 

---

---
## 094 — ASSISTENTE

- Timestamp: `2026-07-30T17:59:52+02:00`
- Node ID: `7f48697e-7534-4208-86ce-b014df2c7ac9`
- Message ID: `7f48697e-7534-4208-86ce-b014df2c7ac9`

Perfetto. Ora iniziamo la parte più importante: **l'Architettura**.

Qui voglio essere molto pragmatico. Non inventiamo componenti, ma definiamo quelli indispensabili. Tutto il resto dovrà emergere naturalmente.

---

# SPEC-006 - Dominio Cognitivo

````markdown
# Specifica 006 - Dominio Cognitivo

Versione: 0.1 Draft

## Scopo

Definire il ruolo del Dominio Cognitivo nell'architettura RumiAI.

## Definizione

Il Dominio Cognitivo è il componente responsabile dell'elaborazione delle rappresentazioni ricevute dai Sensi e della produzione delle rappresentazioni destinate alle Espressioni.

## Responsabilità

- interpretazione delle rappresentazioni;
- memoria;
- ragionamento;
- pianificazione;
- decisione;
- produzione delle rappresentazioni.

## Vincoli

Il Dominio Cognitivo:

- non accede direttamente al Mondo;
- non conosce protocolli;
- non conosce dispositivi;
- non conosce implementazioni dei Sensi;
- non conosce implementazioni delle Espressioni.
````

---

# SPEC-007 - Senso

````markdown
# Specifica 007 - Senso

Versione: 0.1 Draft

## Scopo

Definire il ruolo del Senso nell'architettura.

## Responsabilità

Un Senso:

- riceve rappresentazioni;
- le rende disponibili al Dominio Cognitivo;
- non modifica il significato delle rappresentazioni.

## Proprietà

Ogni Senso è indipendente.

Può essere:

- aggiunto;
- rimosso;
- sostituito.

senza modificare il Dominio Cognitivo.

## Esempi

- testo
- voce
- immagini
- video
- computer use
- sensori
- GPS
- telemetria
````

---

# SPEC-008 - Espressione

````markdown
# Specifica 008 - Espressione

Versione: 0.1 Draft

## Scopo

Definire il ruolo dell'Espressione.

## Responsabilità

Una Espressione:

- riceve rappresentazioni dal Dominio Cognitivo;
- le rende disponibili al Mondo;
- non modifica il significato delle rappresentazioni.

## Proprietà

Ogni Espressione è indipendente.

Può essere:

- aggiunta;
- rimossa;
- sostituita.

senza modificare il Dominio Cognitivo.

## Esempi

- testo
- voce
- schermo
- mouse
- tastiera
- robot
- smart home
- stampa
````

---

# SPEC-009 - Adattatore

````markdown
# Specifica 009 - Adattatore

Versione: 0.1 Draft

## Scopo

Collegare implementazioni esterne al modello RumiAI.

## Definizione

Un Adattatore realizza la compatibilità tra una tecnologia esterna e il modello RumiAI.

## Responsabilità

- conversione protocolli
- conversione formati
- autenticazione
- gestione connessioni
- buffering
- streaming

## Vincoli

L'Adattatore non contiene logica cognitiva.

Non prende decisioni.

Non interpreta il significato delle rappresentazioni.
````

---

# SPEC-010 - Implementazione OpenAI

Questo è il documento che aspettavamo.

````markdown
# REF-001 - OpenAI API

Versione: 0.1 Draft

## Scopo

Dimostrare una implementazione conforme.

## Mappatura

Socket TCP
↓

Canale Trasmissivo

HTTP

↓

Protocollo

OpenAI Chat API

↓

Formato della rappresentazione

Core-AI

↓

Senso

Dominio Cognitivo

↓

Espressione

OpenAI Chat API

↓

HTTP

↓

Socket TCP

## Osservazioni

Il protocollo OpenAI non fa parte della Costituzione.

È solamente una implementazione di riferimento.
````

---

# E adesso arriva, secondo me, la scoperta più importante da mesi.

Rileggendo tutto quello che abbiamo scritto, mi sono accorto che **stiamo ancora usando la parola "Senso" in due modi diversi**.

Uno costituzionale e uno architetturale.

Secondo me è qui che dobbiamo fare il prossimo salto.

## Livello costituzionale

Il **Senso** è una **porta** della Persona Artificiale.

Fine.

## Livello architetturale

Dietro quella porta esiste una catena di componenti:

```text
Protocollo
↓

Adapter

↓

Canale Trasmissivo

↓

Senso

↓

Dominio Cognitivo
```

Il **Senso non è il software**.

È il **confine**.

L'Adapter è il software.

---

Questa distinzione, a mio avviso, è fondamentale perché risolve un'ambiguità che ci accompagna da giorni. Quando diciamo "OpenWebUI è un Senso" stiamo mescolando i livelli. In realtà **OpenWebUI implementa un Adattatore che utilizza un Canale Trasmissivo e presenta una Porta di Senso al Dominio Cognitivo**.

Se questa distinzione ti convince, credo che abbiamo appena trovato uno dei cardini architetturali di RumiAI. Da qui in poi tutto il resto — gateway, protocolli, API, computer use, sensori, robotica — dovrebbe collocarsi naturalmente senza forzature. E, se sarà così, vorrà dire che il modello sta iniziando davvero a dimostrare il suo potere esplicativo.

---

---
## 095 — UTENTE

- Timestamp: `2026-07-30T18:03:18+02:00`
- Node ID: `bbb216f5-8f2a-4e1d-8474-ed21dcb6e9c3`
- Message ID: `bbb216f5-8f2a-4e1d-8474-ed21dcb6e9c3`

Certo che ha senso, è giustissimo. 

---
