# Architettura RumiAI

Data di inizio chat: 2026-07-29

Questo documento conserva il riassunto più fedele possibile delle decisioni, dei prototipi e dei concetti emersi nella conversazione.

## Obiettivo del progetto

RumiAI è concepito come una architettura software IA sovrana, locale e open source, un sistema operativo cognitivo personale.

Principi definiti:

- zero costi obbligatori: nessun abbonamento o servizio cloud necessario;
- local-first: elaborazione e dati sul dispositivo dell'utente, funzionamento anche offline, senza account esterni e senza API proprietarie obbligatorie;
- open source: componenti verificabili e modificabili;
- modulare e componibile: ogni componente può essere sostituito, migliorato e ricombinato;
- distribuibile: possibile evoluzione futura verso una rete di nodi IA cooperanti;
- data ownership: l'utente possiede modelli, dati, memoria e configurazioni;
- governance ownership: gli sviluppatori definiscono modello cognitivo, moduli, regole di estensione ed evoluzione del progetto;
- preferenza per standard già esistenti quando rispettano i requisiti del progetto, evitando di reinventare protocolli o tecnologie mature.

## Architettura iniziale

Livello 0:

```text
Utente
  |
Interfaccia IA
  |
Core IA
```

Livello 1 iniziale:

- Utente: persona, operatore o nodo;
- Interfaccia IA: chat, voce, immagini, video, documenti, conversazione multimodale;
- Core IA: interpretazione, ragionamento, pianificazione, esecuzione, apprendimento.

È stato stabilito un metodo di progettazione top-down e "divide et impera": ogni livello definisce moduli e contratti astratti; il livello successivo dettaglia l'interno dei moduli senza modificare i contratti già validati.

## Interfaccia IA e UI-Gateway

L'Interfaccia IA è stata definita come insieme di UI-Gateway indipendenti. I gateway non comunicano tra loro e parlano solo con il Core IA.

Implementazioni validate:

- Open WebUI come primo UI-Gateway;
- Terminal Gateway come secondo UI-Gateway.

Questa scelta ha permesso di considerare l'Interfaccia IA architetturalmente fissata nella fase corrente, consentendo lo sviluppo parallelo di ulteriori gateway senza interferire con il lavoro sul Core IA.

## Protocollo tra Interfaccia IA e Core IA

È stato scelto come contratto iniziale il protocollo OpenAI-compatible, non il servizio OpenAI.

Motivi:

- supportato da numerosi runtime e client;
- utilizzabile interamente in locale;
- non richiede cloud o API proprietarie;
- consente la sostituibilità delle implementazioni;
- evita di inventare un protocollo dove esiste già uno standard de facto.

Il PoC ha validato la seguente catena:

```text
Terminal Gateway / Open WebUI
        |
OpenAI-compatible API
        |
      Core IA
        |
OpenAI-compatible API
        |
      Ollama
        |
      Gemma4
```

Il Core IA è stato inserito tra i gateway e Ollama come proxy trasparente. I test con curl, Terminal Gateway e Open WebUI hanno funzionato correttamente.

Milestone: il Core IA diventa il punto di ingresso unico; Ollama diventa una dipendenza/runtime interno e non coincide più con il Core.

## PoC Core IA

È stato implementato un server FastAPI sulla porta 2000. In una prima versione inoltrava solo `/v1/chat/completions`; successivamente è stato reso proxy generico di `/v1/*` verso Ollama, preservando il protocollo OpenAI-compatible.

Il PoC ha dimostrato che il contratto esterno può rimanere stabile mentre l'implementazione interna del Core cambia.

## Filosofia del Core IA

Il Core IA deve adottare una architettura microkernel.

Il Kernel deve rimanere minimo e non implementare direttamente capacità cognitive. Le responsabilità emerse sono:

- lifecycle;
- gestione del Context;
- dispatch;
- caricamento configurazione;
- logging / tracing / osservabilità del flusso;
- caricamento/risoluzione dei kernel-mod.

Il Kernel non deve contenere memoria, ragionamento, planner, RAG, tool, runtime o orchestrazione come logiche fisse.

## Kernel-Mod

Tutte le funzionalità interne vengono viste come kernel-mod.

Principi:

- tutti rispettano la stessa interfaccia generale;
- nessun kernel-mod comunica direttamente con un altro kernel-mod;
- l'Orchestrator non è privilegiato: è anch'esso un kernel-mod;
- un kernel-mod riceve il Context e restituisce una Decision al Kernel;
- la comunicazione tra moduli passa sempre dal Kernel, così il Kernel può tracciare e loggare il flusso.

È stato scartato il modello di pipeline fissa perché troppo rigido. L'orchestrazione deve essere sostituibile: sequenziale, grafo, planner, reattiva o distribuita possono essere implementazioni diverse di un kernel-mod orchestratore.

## Capability-Based Architecture

È stato introdotto il concetto di Capability come astrazione principale.

Un kernel-mod non richiede un altro modulo per nome, ma richiede una capacità. Il Kernel, tramite configurazione/registry/plugin manager, risolve la capability verso l'implementazione configurata.

Esempi:

```text
llm.generate
memory.retrieve
memory.store
knowledge.retrieve
terminal.execute
browser.navigate
vision.ocr
speech.transcribe
speech.synthesize
```

Le capability descrivono cosa deve essere fatto, non come. Le implementazioni possono cambiare senza modificare i moduli che richiedono la capability.

Se serve distinguere una implementazione o semantica più specifica, il vocabolario delle capability può essere raffinato con capability più specifiche, mantenendo comunque la possibilità di rimapparle in futuro.

## Provider e riuso del software esistente

RumiAI non deve reinventare software già esistente. Quando un progetto open source maturo soddisfa i requisiti, RumiAI deve integrarlo mediante semplici provider/adapter.

Esempi discussi:

- Ollama, vLLM, llama.cpp per runtime LLM;
- Qdrant, Chroma, FAISS, Milvus per knowledge/memory;
- Playwright / Browser Use per browser/computer use;
- Whisper per STT;
- Piper / altri TTS;
- Tesseract per OCR;
- MCP come possibile provider per tool execution;
- LangChain, LlamaIndex, Haystack, CrewAI, AutoGen come software integrabile per capability specifiche.

È stata fatta la distinzione:

```text
Capability -> Provider -> Tecnologia
```

RumiAI vuole diventare una lingua comune / standard de facto, non un framework monolitico. La speranza è che progetti indipendenti possano in futuro implementare direttamente le interfacce RumiAI.

## Paragone con LEGO e componibilità

È stata adottata la metafora dei LEGO: elementi semplici, con interfacce standard, possono essere composti per ottenere sistemi complessi e molto diversi.

Il concetto più preciso non è solo modularità, ma componibilità. RumiAI dovrebbe definire un insieme minimo di contratti stabili e componibili dai quali possano emergere funzionalità complesse.

## Specifiche fondamentali emerse

Sono state individuate quattro specifiche iniziali, più una quinta proposta:

### Context

Unico oggetto condiviso tra Kernel e kernel-mod per una richiesta/elaborazione. Trasporta lo stato, non contiene logica. I kernel-mod non comunicano direttamente tra loro: condividono informazioni tramite Context.

È stato confrontato con lo State di LangGraph. L'idea dello stato condiviso è considerata valida, ma per RumiAI si valuta una struttura più controllata, eventualmente con namespace e ownership, per evitare crescita incontrollata e conflitti.

### Capability

Vocabolario funzionale pubblico di RumiAI. Descrive cosa fare, non come. Una implementazione può fornire più capability e più implementazioni possono fornire la stessa capability.

### Kernel-Mod

Unità funzionale/plugin del Core. Riceve Context, elabora, restituisce una Decision. Non conosce direttamente altri kernel-mod.

### Dispatch

Responsabilità del Kernel. Riceve la Decision, risolve le capability richieste, individua l'implementazione configurata, esegue il kernel-mod corrispondente e registra il flusso. Non contiene logica cognitiva.

### Decision

Proposta come ulteriore contratto fondamentale tra kernel-mod e Kernel. Deve esprimere il risultato dell'elaborazione e il passo successivo senza introdurre dipendenze dirette tra moduli.

## Plugin Manager / Registry

Il Plugin Manager deve essere passivo: caricare, elencare e risolvere moduli/capability. Non deve orchestrare né decidere quando un modulo deve essere eseguito.

Il Kernel è il dispatcher e punto centrale di osservabilità.

## Confronto con LangGraph

Sono state considerate utili alcune idee di LangGraph:

- State condiviso tra nodi;
- nodi indipendenti;
- concetto simile a Command/Decision;
- grafi come possibile strategia di orchestrazione.

Differenze volute:

- il grafo non deve essere hard-coded nel Kernel;
- l'Orchestrator è un kernel-mod sostituibile;
- i moduli richiedono capability, non tool/implementazioni concrete;
- il Context potrebbe essere più strutturato e con regole di ownership rispetto a uno state libero.

## Limiti rilevati nell'interfaccia OpenAI

È stato individuato un limite architetturale importante dell'API OpenAI-compatible:

- non offre un vero streaming bidirezionale full-duplex;
- lega request e response allo stesso client/gateway;
- non permette naturalmente scenari in cui l'input arriva da un canale e l'output deve uscire da un altro, ad esempio voce -> chat o chat -> voce, senza un gateway monolitico.

Conclusione: OpenAI rimane molto utile come protocollo/adapter di compatibilità, ma non dovrebbe necessariamente diventare il protocollo nativo universale interno di RumiAI.

## Comunicazione e AI-Channel

È emersa la necessità di standardizzare anche la comunicazione interna dei kernel-mod.

Sono stati distinti i principali modelli di interazione:

- request/response bloccante;
- streaming;
- eventi asincroni;
- full-duplex bidirezionale continuo.

La discussione ha poi portato al concetto di AI-Channel / Channel come astrazione logica del canale tra Kernel e kernel-mod.

Un Channel dovrebbe descrivere come avviene lo scambio, indipendentemente da HTTP, WebSocket, MQTT, OpenAI, REST o altri protocolli concreti.

Proprietà discusse:

- mode;
- session;
- streaming;
- direction / duplex;
- apertura/chiusura;
- send/receive/status.

È stato anche osservato che un kernel-mod nativo RumiAI non deve per forza implementare adapter: può esporre direttamente le proprie capability e capacità di comunicazione. Gli adapter servono soprattutto per software esterno già esistente.

## I/O multimodali e Message Contract

È stata riconosciuta la necessità di standardizzare gli I/O multimodali sia verso l'utente sia verso device fisici o software:

- testo;
- audio;
- immagini;
- video;
- documenti;
- eventi;
- misure da sensori;
- comandi;
- stato.

Esempi: computer use su mouse/tastiera, sensori di temperatura per smart home, speech-to-text, TTS, vision, OCR.

È stato proposto un Message Contract tipizzato, indipendente dalla capability e dal canale di comunicazione, con campi concettuali come id, conversation/session, timestamp, type, payload, metadata.

Le tre dimensioni da mantenere separate sono:

- Capability: cosa sa fare il modulo;
- Channel / Communication Contract: come comunica;
- Message Contract: cosa viene trasportato.

## Metodo di sviluppo / Proof of Concept

Il progetto dovrà essere pubblicato seriamente su GitHub come proof of concept installabile facilmente da un utente avanzato.

Il PoC non deve cercare di essere spettacolare: deve dimostrare la validità dell'architettura, la sostituibilità delle implementazioni e la semplicità di integrazione.

Roadmap concettuale emersa:

1. definire e implementare microkernel, Context, Capability Registry/Plugin Manager, Dispatch;
2. integrare pochi provider fondamentali, ad esempio Ollama, filesystem e terminale;
3. aggiungere seconde implementazioni delle stesse capability per dimostrare la sostituibilità;
4. integrare software esistente per RAG/knowledge, browser/computer use, speech, vision, ecc.;
5. mantenere la specifica semplice e stabile, lasciando libere le implementazioni.

## Principi architetturali consolidati

- astrazione prima dell'implementazione;
- top-down e divide et impera;
- contratti stabili, implementazioni libere;
- componenti allo stesso livello non comunicano direttamente;
- semantica prima della tecnologia;
- capability al posto delle dipendenze concrete;
- microkernel minimo;
- orchestrazione come kernel-mod sostituibile;
- logging/tracing centralizzato nel Kernel;
- riuso preferenziale di standard e prodotti open source esistenti;
- componibilità come obiettivo primario;
- RumiAI come possibile standard de facto / "POSIX per l'IA".

## Stato al termine della chat

Sono già stati validati:

- UI-Gateway multipli indipendenti;
- Open WebUI e Terminal Gateway;
- comunicazione OpenAI-compatible verso Core IA;
- Core IA come proxy intermedio stabile;
- comunicazione OpenAI-compatible Core IA -> Ollama;
- compatibilità con curl, Terminal Gateway e Open WebUI;
- separazione tra interfaccia e Core IA.

Da approfondire/progettare nei passaggi successivi:

- specifica definitiva di Context;
- specifica definitiva di Capability;
- specifica Kernel-Mod;
- specifica Dispatch;
- specifica Decision;
- AI-Channel / Channel;
- Message Contract;
- regole precise di Context namespace/ownership;
- primo microkernel PoC e primi provider/adapter reali.
