# Panoramica ecosistema Open Source AI e principio di progettazione RumiAI

## Tabella sintetica

| Categoria | Prodotto | Funzione | Interfacce | Canali | Comunicazione | Stato | Note |
|---|---|---|---|---|---|---|---|
| LLM Runtime | Ollama | LLM locale | REST | Testo | RR, SSE | Maturo | Desktop |
| LLM Runtime | llama.cpp | Inference | C API, CLI | Testo | RR | Maturo | Base OSS |
| LLM Runtime | vLLM | Serving | OpenAI API | Testo | RR, SSE | Maturo | GPU |
| Vector DB | Qdrant | Vector DB | REST, gRPC | Embedding | RR | Maturo | RAG |
| RAG | LlamaIndex | Framework RAG | Python | Testo | RR | Maturo | Ecosistema esteso |
| Agent | LangGraph | Orchestrazione | Python | Testo | RR, Events | Maturo | Grafo |
| Workflow | n8n | Workflow | REST | Qualsiasi | RR, Events | Maturo | No-code |
| UI | Open WebUI | Chat UI | Web | Testo | RR, SSE | Maturo | Frontend |
| Voice | Pipecat | Realtime | WebRTC | Audio | Full-Duplex Stream | Maturo | Voice agent |
| Messaging | NATS | Message Bus | TCP | Eventi | Events | Maturo | Pub/Sub |
| Devices | ROS2 | Middleware robotico | DDS | Sensori | Events | Maturo | Standard robotica |

## Obiettivo architetturale

RumiAI mira a definire un **AI-Channel** come superset dei modelli di comunicazione oggi esistenti:
- Request / Response
- Streaming
- Full-Duplex Streaming
- Eventi asincroni
- Batch

Gli adapter traducono l'AI-Channel verso i protocolli specifici dei componenti integrati.

## Principio di Validazione tramite Proof of Concept

Ogni decisione architetturale deve essere validata il prima possibile mediante un Proof of Concept funzionante.

Processo:

1. Definizione del problema.
2. Definizione dell'astrazione minima.
3. Realizzazione del Proof of Concept.
4. Validazione su casi d'uso reali.
5. Individuazione dei limiti.
6. Aggiornamento delle specifiche.
7. Consolidamento dell'architettura.

Una specifica che non può essere rapidamente prototipata è probabilmente troppo astratta oppure non sufficientemente aderente ai vincoli reali.

L'architettura definitiva deve emergere dall'alternanza continua tra progettazione e sperimentazione.
