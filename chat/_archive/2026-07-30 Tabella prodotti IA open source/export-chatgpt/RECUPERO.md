# Recupero informativo dall'export

## Origine

La conversazione nasce dalla richiesta di costruire una tabella sintetica ma relativamente completa dei prodotti open source più diffusi per funzioni IA, classificandoli per tipologia (LLM runtime, RAG, orchestrator/agent, workflow, UI, voice, device, messaging ecc.), canali I/O e modalità di comunicazione (request/response, SSE, full-duplex stream, eventi asincroni, batch).

La panoramica mette in evidenza la frammentazione dell'ecosistema e porta alla considerazione che RumiAI debba astrarre le modalità di comunicazione anziché vincolarsi a una specifica API.

## Metodo di progettazione consolidato

La conversazione formalizza una regola centrale: progettare rapidamente un'astrazione minima e sostenerla presto con un Proof of Concept reale. I prototipi già realizzati hanno permesso di riconoscere rapidamente sia la validità sia i limiti dell'architettura iniziale. Una specifica che rimane a lungo non prototipabile è sospetta di essere troppo astratta o poco aderente alla realtà.

Il ciclo recuperato è:

1. definizione del problema;
2. astrazione minima;
3. Proof of Concept;
4. validazione su casi reali;
5. individuazione dei limiti;
6. revisione delle specifiche;
7. consolidamento.

## Persona Artificiale

RumiAI viene pensata non soltanto come strumento, ma come nucleo cognitivo di una `Persona Artificiale` con cui parlare, decidere e fare cose. La Persona Artificiale è caratterizzata non solo dal proprio cervello/dominio cognitivo, ma anche dall'insieme dei propri modi di entrare in relazione con il mondo.

La discussione rifiuta l'idea che i canali contemporanei (testo, audio, video, mouse, tastiera) debbano determinare l'architettura. I futuri sensi artificiali possono includere pelle sintetica, sensori chimici, naso elettronico e altre rappresentazioni oggi non comuni.

## Senso ed Espressione

Dopo il confronto tra termini come esperienza, percezione e azione, vengono preferiti **Senso** ed **Espressione**.

`Senso` viene scelto perché descrive la capacità di entrare in relazione con fenomeni senza implicare necessariamente interpretazione cognitiva. `Percezione` viene considerato più vicino all'interpretazione del segnale. `Espressione` viene preferita ad `Azione` perché è più generale e meno legata a volontà/decisione.

Una formulazione chiave emersa è:

> Senso non trasporta il mondo, ma una rappresentazione del mondo.

E un principio condiviso:

> RumiAI non assume che esista una rappresentazione privilegiata della realtà.

Il flusso astratto discusso è:

`Mondo → Fenomeno → Recettore → Trasduzione → Elaborazione → Trasmissione → Sistema Cognitivo`

La trasduzione segna il confine tra fenomeno e rappresentazione. L'accuratezza o il livello di elaborazione della rappresentazione non definiscono la natura del Senso: un input può essere molto grezzo oppure già fortemente elaborato.

## Stream

Viene esplicitamente rifiutata l'idea di assumere gli eventi come elemento fondamentale. Senso ed Espressione sono concepiti come **stream**: l'universo varia continuamente; eventi, pacchetti, campionamento, quantizzazione e digitalizzazione sono modi implementativi di rappresentare porzioni di questo continuo.

## Livelli di astrazione e adapter

Nella mappatura del prototipo OpenWebUI/OpenAI/Ollama emerge la necessità di non confondere concetti astratti, protocolli, trasporti e software. TCP, HTTP e OpenAI sono livelli implementativi. Software esistente può richiedere adapter per aderire al modello RumiAI.

Un'implementazione concreta discussa prevede Sensi/Espressioni collegati a RumiAI attraverso un canale trasmissivo implementato, nel PoC, con socket TCP sulla porta 2000, sul quale viaggiano rappresentazioni codificate nel formato/protocollo OpenAI-compatible.

## `Porta` eliminata dal modello

La parola `porta` era stata usata come analogia suggestiva per Senso/Espressione. Quando è stata proposta come nuovo concetto architetturale, l'utente ha chiarito che non doveva esserlo. La correzione viene accettata: **Porta non è un'entità del modello**. Regola emersa: le analogie aiutano a comprendere i concetti, ma non diventano automaticamente concetti architetturali.

## Nervo

Verso la fine della conversazione viene proposto il termine **Nervo** per il canale trasmissivo di Senso ed Espressione. Il termine viene giudicato promettente perché introduce un concetto distinto: il collegamento trasmissivo, separato da Senso/Espressione e dalle tecnologie concrete che lo implementano. Questa parte deve essere considerata una direzione progettuale da revisionare insieme al resto del corpus, non una specifica definitiva.

## Nota sulle revisioni

La conversazione contiene anche tentativi successivi di ridefinire `Senso` che l'utente identifica esplicitamente come una deriva/confusione rispetto alla definizione precedentemente consolidata. Tali riformulazioni **non devono sovrascrivere automaticamente** il modello precedente; vanno conservate come storia della discussione e sottoposte a review.
