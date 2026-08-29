# Tabella prodotti IA open source — Trascrizione canonica

Parte 001 — messaggi **001–007** di **178**.

Testo dei messaggi estratto dall'export ChatGPT senza riscrittura.

---

## 001 — UTENTE

- Timestamp: `2026-07-30T11:45:04+02:00`
- Node ID: `c8a6c35c-03e7-4959-978b-52f95ccc7f79`
- Message ID: `c8a6c35c-03e7-4959-978b-52f95ccc7f79`

creami una tabella che elenchi i prodotti open source relativi a funzioni ia più diffusi, tipo ollama, langgraph, ecc. classificali per tipologia tipo llm, rag, orchestrator, ecc. evidenzia i canali di comunicazione es web, audio, ecc. il tipo di canale ed il tipo di comunicazione es. full-duplex stream, request response, eventi asincroni, ecc. aggiungi caratteristiche che ritieni utili per avere un panorama sintetico ma relativamente completo

---
## 002 — ASSISTENTE

- Timestamp: `2026-07-30T11:45:05+02:00`
- Node ID: `126bc6f1-30d1-4753-ad4b-9f324afd6774`
- Message ID: `126bc6f1-30d1-4753-ad4b-9f324afd6774`

Di seguito trovi una tabella pensata non come elenco di software, ma come **mappa funzionale dell'ecosistema AI open source**. Ho privilegiato i progetti che oggi sono diventati di fatto degli standard o sono molto diffusi nella community.

> **Legenda comunicazione**
>
> - **RR** = Request / Response
> - **SSE** = Server Sent Events (stream unidirezionale)
> - **WS** = WebSocket
> - **FD Stream** = Full Duplex Streaming
> - **Events** = Eventi asincroni (message bus, webhook, pub/sub)
> - **Batch** = elaborazione offline

| Categoria | Prodotto | Funzione principale | Interfacce | Canali I/O | Comunicazione | Stato | Modularità | Note architetturali |
|------------|----------|--------------------|------------|------------|---------------|--------|-------------|---------------------|
| **LLM Runtime** | Ollama | esecuzione LLM locale | REST | testo | RR, SSE | maturo | media | standard de facto desktop |
| | llama.cpp | inference engine | C API, REST, CLI | testo | RR | maturo | alta | base di moltissimi progetti |
| | vLLM | serving LLM ad alte prestazioni | OpenAI API | testo | RR, SSE | maturo | alta | ottimo per GPU server |
| | Text Generation Inference (TGI) | serving HuggingFace | REST | testo | RR, SSE | maturo | alta | molto usato enterprise |
| | LM Studio | runtime desktop | REST OpenAI | testo | RR | maturo | bassa | simile a Ollama |
| **Multimodal Runtime** | Whisper.cpp | Speech To Text | API, CLI | audio→testo | RR, Stream | maturo | alta | realtime possibile |
| | Piper | Text To Speech | API, CLI | testo→audio | RR, Stream | maturo | alta | molto leggero |
| | Coqui TTS | TTS | API | testo→audio | RR | maturo | alta | numerose voci |
| | Kokoro | TTS | API | testo→audio | RR, Stream | emergente | media | qualità elevata |
| **Embedding** | Sentence Transformers | embedding | Python | testo | RR | maturo | alta | standard open source |
| | BGE | embedding | Python | testo | RR | maturo | alta | molto diffuso |
| | Jina Embeddings | embedding | API | testo | RR | maturo | alta | ottime prestazioni |
| **Vector DB / RAG** | Qdrant | vector database | REST, gRPC | embedding | RR | maturo | alta | probabilmente il più usato |
| | Milvus | vector database | REST, gRPC | embedding | RR | maturo | alta | enterprise |
| | Chroma | vector database | Python | embedding | RR | maturo | media | semplice |
| | Weaviate | vector database | REST, GraphQL | embedding | RR | maturo | alta | schema semantico |
| | FAISS | indice vettoriale | libreria | embedding | locale | maturo | alta | no server |
| **RAG Framework** | LlamaIndex | RAG completo | Python | testo | RR | maturo | molto alta | enorme ecosistema |
| | Haystack | RAG pipeline | REST, Python | testo | RR | maturo | alta | enterprise |
| | DSPy | ottimizzazione pipeline | Python | testo | RR | maturo | alta | orientato alla ricerca |
| **Agent Framework** | LangGraph | orchestrazione agenti | Python | testo | RR, Events | maturo | molto alta | state machine/grafo |
| | CrewAI | multi-agent | Python | testo | RR | maturo | media | semplice |
| | AutoGen | multi-agent | Python | testo | RR | maturo | alta | Microsoft |
| | OpenHands | agent coding | Web | testo | RR, Stream | maturo | media | ex OpenDevin |
| **Workflow / Orchestrator** | n8n | workflow automation | REST, Webhook | qualsiasi | RR, Events | maturo | alta | no-code |
| | Temporal | workflow distribuiti | gRPC | qualsiasi | Events | maturo | molto alta | mission critical |
| | Airflow | batch workflow | REST | dati | Batch | maturo | alta | ETL |
| | Prefect | workflow | REST | dati | RR, Events | maturo | alta | cloud/local |
| **Model Gateway** | LiteLLM | gateway multi LLM | OpenAI API | testo | RR, SSE | maturo | alta | routing modelli |
| | OpenRouter compat layer | gateway | REST | testo | RR | maturo | media | API compatibili |
| **UI Chat** | Open WebUI | interfaccia utente | Web | testo, immagini | RR, SSE | maturo | alta | standard Ollama |
| | LibreChat | chat UI | Web | testo | RR, SSE | maturo | alta | multi provider |
| **Memory** | Mem0 OSS | memoria AI | REST | testo | RR | emergente | alta | memoria semantica |
| | Graphiti | graph memory | REST | testo | RR | emergente | alta | knowledge graph |
| **Knowledge Graph** | Neo4j | graph DB | Bolt, REST | dati | RR | maturo | alta | molto diffuso |
| | FalkorDB | graph DB | Redis protocol | dati | RR | maturo | alta | molto veloce |
| **Document Processing** | Apache Tika | parsing documenti | REST | documenti | RR | maturo | alta | standard |
| | Unstructured | parsing AI | REST | documenti | RR | maturo | alta | RAG |
| | Docling | parsing documenti | Python | documenti | RR | emergente | alta | IBM |
| **Vision** | YOLO | object detection | API | immagini/video | RR, Stream | maturo | alta | realtime |
| | SAM | segmentazione | API | immagini | RR | maturo | alta | Meta |
| **Speech Assistant** | LiveKit Agents | realtime voice | WebRTC | audio | FD Stream | maturo | alta | molto interessante |
| | Pipecat | realtime multimodale | WebRTC, WS | audio/video | FD Stream | maturo | molto alta | orientato agenti vocali |
| **Computer Use** | Open Operator | browser automation | Web | GUI | RR, Events | emergente | media | browser agent |
| | Browser Use | browser automation | Python | GUI | RR | maturo | alta | molto usato |
| **Robotics / Devices** | ROS2 | robot middleware | DDS | sensori, attuatori | Events | maturo | enorme | standard robotica |
| | Home Assistant | smart home | MQTT, REST | sensori | Events | maturo | enorme | ottimo esempio event-driven |
| **Messaging** | MQTT | pub/sub | TCP | eventi | Events | standard | alta | IoT |
| | NATS | message bus | TCP | eventi | Events | maturo | alta | cloud native |
| | Kafka | event streaming | TCP | eventi | Events | maturo | molto alta | enterprise |

---

# Visione sintetica per funzione

| Funzione | Standard più diffusi oggi |
|----------|---------------------------|
| LLM locale | Ollama, llama.cpp |
| LLM server | vLLM, TGI |
| Embedding | Sentence Transformers |
| Vector DB | Qdrant |
| RAG | LlamaIndex |
| Agent | LangGraph |
| Multi-agent | CrewAI, AutoGen |
| Workflow | n8n, Temporal |
| UI | Open WebUI |
| Voice | Pipecat, LiveKit |
| Device | ROS2, Home Assistant |
| Messaging | MQTT, NATS |

---

# Comunicazioni realmente supportate

| Tipo comunicazione | Tecnologie tipiche | Progetti |
|-------------------|--------------------|-----------|
| Request / Response | HTTP REST | quasi tutti |
| Streaming output | HTTP SSE | Ollama, OpenAI API, vLLM |
| Full Duplex | WebRTC, WebSocket | Pipecat, LiveKit |
| Event Driven | MQTT, Kafka, NATS, DDS | ROS2, Home Assistant |
| Batch | file, job | Airflow |
| CLI | stdin/stdout | llama.cpp, whisper.cpp |
| Native SDK | Python, C++, Rust | moltissimi |

---

# Osservazione importante per RumiAI

Questa panoramica conferma una cosa che avevamo già intuito durante la progettazione dell'**AI-Channel**.

L'ecosistema oggi è frammentato perché ogni progetto espone un sottoinsieme diverso di modalità di comunicazione:

| Comunicazione | Diffusione |
|--------------|------------|
| REST Request/Response | ⭐⭐⭐⭐⭐ |
| REST Streaming (SSE) | ⭐⭐⭐⭐ |
| WebSocket | ⭐⭐⭐ |
| gRPC | ⭐⭐ |
| MQTT/Event Bus | ⭐⭐ |
| WebRTC Full Duplex | ⭐ |
| Eventi asincroni | ⭐⭐⭐ |

Da qui emerge un'opportunità architetturale per **RumiAI**: definire un **AI-Channel** astratto che rappresenti un superset di tutte queste modalità (request/response, streaming, full-duplex, eventi, batch), lasciando agli adapter il compito di tradurre verso le API specifiche dei vari componenti. In questo modo, kernel-mod e orchestratore possono ragionare su un unico modello di comunicazione indipendente dalla tecnologia sottostante, semplificando l'integrazione di runtime LLM, sistemi vocali, robotica, smart home e futuri servizi multimodali.

---
## 003 — UTENTE

- Timestamp: `2026-07-30T11:53:39+02:00`
- Node ID: `94df6aac-5e99-4c25-ace6-1561586c17c6`
- Message ID: `94df6aac-5e99-4c25-ace6-1561586c17c6`

innanzitutto produci la risposta precedente come un file scaricabile. la tua considerazione finale è quello che voglio ottenere. siamo partiti da un buon modello, validato da alcuni prototipi reali che ci hanno consentito di consolidare le specifiche. questo ci ha consentito di procedere con la progettazione, ma l'esistenza di prototipi reali ci ha consentito subito e senza perdere tempo prezioso che quella architettura era buona per diverse casistiche, ma aveva importanti limiti che si sarebbero ripercossi sulle funzionalità implementabili. questo metodo deve diventare una regola: progettiamo qualcosa, ma l'idea deve presto essere supportata da un prototipo "proof of concept", altrimenti vuol dire che è troppo astratta e probabilmente irrealizzabile

---
## 004 — ASSISTENTE

- Timestamp: `2026-07-30T11:53:48+02:00`
- Node ID: `7aeaf492-4824-4c47-8bbe-7445e3f3396e`
- Message ID: `7aeaf492-4824-4c47-8bbe-7445e3f3396e`

Ho preparato il documento in formato Word, scaricabile qui:

**📄 [RumiAI_Ecosistema_OpenSource_e_Regola_PoC.docx](sandbox:/mnt/data/RumiAI_Ecosistema_OpenSource_e_Regola_PoC.docx)**

---

Riguardo alla metodologia, credo che abbiamo individuato uno dei principi fondanti del progetto. Non è semplicemente una buona pratica di sviluppo, ma una **regola di governance dell'architettura**.

La formulerei in modo simile a questa.

> **Principio di Validazione tramite Proof of Concept (PoC)**
>
> Ogni nuova astrazione architetturale deve essere validata il prima possibile mediante un Proof of Concept funzionante.
>
> La progettazione non procede per sola analisi teorica: ogni concetto deve dimostrare di poter essere implementato e di risolvere casi d'uso reali.
>
> Il processo iterativo è:
>
> 1. Definizione del problema.
> 2. Proposta dell'astrazione minima.
> 3. Implementazione di un Proof of Concept.
> 4. Validazione su casi d'uso differenti.
> 5. Identificazione dei limiti emersi.
> 6. Raffinamento delle specifiche.
> 7. Consolidamento dell'architettura.
>
> Una specifica che non può essere rapidamente prototipata è probabilmente troppo astratta, incompleta oppure non sufficientemente aderente ai vincoli del mondo reale.
>
> Le specifiche definitive devono quindi nascere dall'interazione continua tra progettazione e sperimentazione, non dalla sola progettazione teorica.

Secondo me questo principio è uno degli elementi che differenzia RumiAI da molti framework esistenti. Finora non abbiamo costruito l'architettura "a tavolino": siamo partiti da componenti reali (Ollama, Open WebUI, API OpenAI, gateway, ecc.), li abbiamo fatti funzionare, abbiamo osservato i loro limiti e solo allora abbiamo astratto il modello generale. È esattamente questo percorso che ci ha portato alla definizione dell'**AI-Channel**: l'astrazione non è nata da un'idea teorica, ma dall'osservazione che nessun protocollo esistente era sufficientemente generale per coprire tutte le modalità di comunicazione che RumiAI dovrà orchestrare.

Ritengo che questo principio dovrebbe entrare a far parte del documento di **Governance** o dei **Principi Fondanti** del progetto, perché influenzerà tutte le future decisioni architetturali.

---
## 005 — UTENTE

- Timestamp: `2026-07-30T11:57:03+02:00`
- Node ID: `82956adf-00f5-4112-9351-b8416c0b3975`
- Message ID: `82956adf-00f5-4112-9351-b8416c0b3975`

non mi piacciono i formati documento di microsoft, preferisco un fomato aperto e semplice, che ne dici se mi ricrei il documento in formato markdown?

---
## 006 — ASSISTENTE

- Timestamp: `2026-07-30T11:57:16+02:00`
- Node ID: `23076cf1-a5a1-4eb5-a499-eebcb888a618`
- Message ID: `23076cf1-a5a1-4eb5-a499-eebcb888a618`

Sono d'accordo con la tua preferenza.

Per un progetto come **RumiAI**, il **Markdown** è probabilmente il formato migliore perché è:

- **aperto** e indipendente da qualsiasi produttore;
- **leggibile** anche come semplice file di testo;
- **versionabile** perfettamente con Git (i diff sono puliti);
- **convertibile** facilmente in HTML, PDF, EPUB, ODT, DOCX, ecc.;
- supportato nativamente da GitHub, GitLab e dalla maggior parte degli editor (VS Code, Obsidian, Typora, Zed, ecc.).

Ho quindi ricreato il documento in formato Markdown.

**📄 [RumiAI_Ecosistema_OpenSource_e_Regola_PoC.md](sandbox:/mnt/data/RumiAI_Ecosistema_OpenSource_e_Regola_PoC.md)**

---

Ti farei anche una proposta per il progetto: **adottare il Markdown come formato ufficiale di tutta la documentazione**.

Una possibile struttura potrebbe essere:

```
rumiai/
├── README.md
├── docs/
│   ├── architecture/
│   ├── specifications/
│   ├── concepts/
│   ├── decisions/
│   ├── poc/
│   ├── interfaces/
│   ├── protocols/
│   └── roadmap/
```

Con alcune convenzioni semplici:

- un documento = un concetto;
- file piccoli (preferibilmente <300 righe);
- collegamenti tra documenti tramite link relativi;
- diagrammi in **Mermaid** direttamente nel Markdown;
- eventuali immagini solo quando strettamente necessarie.

Credo inoltre che dovremmo introdurre una distinzione molto chiara tra documenti:

- **RFC (Request for Comments)** → idee ancora in discussione.
- **PoC (Proof of Concept)** → risultati sperimentali e prototipi.
- **Specification** → specifiche consolidate e implementabili.
- **ADR (Architecture Decision Record)** → decisioni prese e loro motivazione.

Questa separazione renderà molto più semplice capire cosa è ancora sperimentale e cosa invece costituisce parte stabile dell'architettura. Per un progetto open source ambizioso come RumiAI, penso che sarà un elemento importante sia per la collaborazione sia per la manutenzione nel lungo periodo.

---
## 007 — UTENTE

- Timestamp: `2026-07-30T12:00:34+02:00`
- Node ID: `f09a8e9f-73ca-40ea-9eac-d279bec7d46e`
- Message ID: `f09a8e9f-73ca-40ea-9eac-d279bec7d46e`

il contenuto del markdown è di un'altra risposta ed è diverso dal docx

---
