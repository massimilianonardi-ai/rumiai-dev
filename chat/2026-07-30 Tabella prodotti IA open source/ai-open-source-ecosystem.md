# Panoramica dell'ecosistema Open Source AI

Di seguito una mappa funzionale dell'ecosistema AI open source. La classificazione è organizzata per funzione architetturale, privilegiando i progetti più diffusi e maturi.

## Legenda comunicazione

- **RR** = Request / Response
- **SSE** = Server Sent Events (stream unidirezionale)
- **WS** = WebSocket
- **FD Stream** = Full Duplex Streaming
- **Events** = Eventi asincroni (message bus, webhook, pub/sub)
- **Batch** = Elaborazione offline

| Categoria | Prodotto | Funzione principale | Interfacce | Canali I/O | Comunicazione | Stato | Modularità | Note architetturali |
|---|---|---|---|---|---|---|---|---|
| LLM Runtime | Ollama | Esecuzione LLM locale | REST | Testo | RR, SSE | Maturo | Media | Standard desktop |
| LLM Runtime | llama.cpp | Inference engine | C API, REST, CLI | Testo | RR | Maturo | Alta | Base di molti progetti |
| LLM Runtime | vLLM | Serving LLM | OpenAI API | Testo | RR, SSE | Maturo | Alta | Ottimo per GPU |
| LLM Runtime | TGI | Serving HuggingFace | REST | Testo | RR, SSE | Maturo | Alta | Enterprise |
| LLM Runtime | LM Studio | Runtime desktop | REST | Testo | RR | Maturo | Bassa | Simile a Ollama |
| Multimodal | Whisper.cpp | Speech to Text | API, CLI | Audio→Testo | RR, Stream | Maturo | Alta | Realtime |
| Multimodal | Piper | Text to Speech | API, CLI | Testo→Audio | RR, Stream | Maturo | Alta | Leggero |
| Embedding | Sentence Transformers | Embedding | Python | Testo | RR | Maturo | Alta | Standard OSS |
| Vector DB | Qdrant | Vector Database | REST, gRPC | Embedding | RR | Maturo | Alta | RAG |
| Vector DB | Milvus | Vector Database | REST, gRPC | Embedding | RR | Maturo | Alta | Enterprise |
| Vector DB | Chroma | Vector Database | Python | Embedding | RR | Maturo | Media | Semplice |
| RAG | LlamaIndex | Framework RAG | Python | Testo | RR | Maturo | Molto alta | Ecosistema esteso |
| RAG | Haystack | Framework RAG | REST, Python | Testo | RR | Maturo | Alta | Enterprise |
| Agent | LangGraph | Orchestrazione agenti | Python | Testo | RR, Events | Maturo | Molto alta | Grafo |
| Agent | CrewAI | Multi-agent | Python | Testo | RR | Maturo | Media | Semplice |
| Workflow | n8n | Workflow automation | REST | Qualsiasi | RR, Events | Maturo | Alta | No-code |
| Workflow | Temporal | Workflow distribuiti | gRPC | Qualsiasi | Events | Maturo | Molto alta | Mission critical |
| Gateway | LiteLLM | Gateway multi LLM | OpenAI API | Testo | RR, SSE | Maturo | Alta | Routing |
| UI | Open WebUI | Interfaccia chat | Web | Testo, immagini | RR, SSE | Maturo | Alta | Standard Ollama |
| Voice | Pipecat | Assistente realtime | WebRTC | Audio | FD Stream | Maturo | Molto alta | Voice agent |
| Voice | LiveKit Agents | Assistente realtime | WebRTC | Audio | FD Stream | Maturo | Alta | Voice agent |
| Devices | ROS2 | Middleware robotica | DDS | Sensori/Attuatori | Events | Maturo | Molto alta | Standard robotica |
| Devices | Home Assistant | Smart Home | MQTT, REST | Sensori | Events | Maturo | Alta | Event driven |
| Messaging | MQTT | Pub/Sub | TCP | Eventi | Events | Standard | Alta | IoT |
| Messaging | NATS | Message Bus | TCP | Eventi | Events | Maturo | Alta | Cloud native |
| Messaging | Kafka | Event Streaming | TCP | Eventi | Events | Maturo | Molto alta | Enterprise |

## Visione sintetica

| Funzione | Standard più diffusi |
|---|---|
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

## Modalità di comunicazione

| Tipo | Tecnologie |
|---|---|
| Request / Response | HTTP REST |
| Streaming | HTTP SSE |
| Full Duplex | WebRTC, WebSocket |
| Event Driven | MQTT, Kafka, NATS, DDS |
| Batch | Job, File |
| CLI | stdin/stdout |
| SDK | Python, C++, Rust |

## Considerazioni per RumiAI

Questa panoramica conferma una delle intuizioni maturate durante la progettazione di RumiAI.

L'ecosistema è oggi frammentato perché ogni componente espone un sottoinsieme diverso di modalità di comunicazione.

| Comunicazione | Diffusione |
|---|---|
| REST Request/Response | ⭐⭐⭐⭐⭐ |
| REST Streaming (SSE) | ⭐⭐⭐⭐ |
| WebSocket | ⭐⭐⭐ |
| gRPC | ⭐⭐ |
| MQTT / Event Bus | ⭐⭐ |
| WebRTC Full Duplex | ⭐ |
| Eventi asincroni | ⭐⭐⭐ |

Da questa osservazione emerge la necessità di definire un **AI-Channel** astratto, concepito come superset delle modalità di comunicazione esistenti (request/response, streaming, full-duplex, eventi e batch).

Gli adapter avranno il solo compito di tradurre l'AI-Channel verso le API specifiche dei componenti integrati. In questo modo kernel-mod, orchestratore e servizi di RumiAI potranno ragionare su un unico modello di comunicazione indipendente dalla tecnologia sottostante, rendendo possibile integrare in modo uniforme runtime LLM, sistemi vocali, robotica, smart home e futuri servizi multimodali.
