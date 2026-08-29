# Chat archive — Tabella prodotti IA open source

- **Data di inizio:** 2026-07-30
- **Titolo chat:** Tabella prodotti IA open source
- **Stato:** archivio della conversazione e degli artefatti ancora recuperabili

## Origine della conversazione

La chat è partita dalla richiesta di costruire una panoramica sintetica ma relativamente completa dei prodotti open source più diffusi per funzioni AI: runtime LLM, RAG, orchestrazione, agenti, vector database, voice, UI, robotica, messaging ecc. La tabella doveva evidenziare anche canali I/O e modalità di comunicazione: request/response, SSE, WebSocket, full-duplex stream, eventi asincroni, batch.

Da questa analisi è emersa una considerazione architetturale importante per RumiAI: l'ecosistema è frammentato non solo per funzione, ma anche perché ogni componente espone modalità di comunicazione differenti. Questo ha riaperto il tema dell'AI-Channel e, più in generale, della standardizzazione dell'interazione tra RumiAI e il mondo.

## Regola metodologica consolidata: PoC-first

L'utente ha evidenziato un problema importante delle precedenti sessioni di progettazione: erano stati prodotti molti documenti che diventavano rapidamente obsoleti quando l'assistente cambiava idea o introduceva nuovi concetti. Per l'assistente riscrivere è economico; per l'utente validare e seguire le modifiche richiede ore.

È stata quindi consolidata una regola di lavoro fondamentale:

> progettare rapidamente, ma portare presto ogni idea importante a un prototipo reale / Proof of Concept.

Un'idea che rimane troppo a lungo puramente astratta è sospetta. Il PoC non serve soltanto a verificare il codice: serve a cercare limiti e controesempi del modello. La progettazione deve procedere per cicli rapidi di formulazione → prototipo → validazione → revisione.

La velocità iniziale è preferita al perfezionismo prematuro: i documenti diventano solidi attraverso cicli successivi di validazione, non attraverso un singolo passaggio di scrittura.

## Visione di RumiAI

L'utente ha chiarito la visione originaria: RumiAI deve diventare una **Persona Artificiale** con cui parlare, decidere e fare cose.

Le AI contemporanee hanno già molte capacità parziali — voce, computer use, LLM, automazione, robotica — ma sono difficili da combinare. L'obiettivo non è costruire ogni tecnologia, ma creare un modello e un ecosistema capaci di integrarle senza vincolare RumiAI alle tecnologie disponibili oggi.

Il progetto deve rimanere local-first, open source, modulare e tecnologicamente sostituibile.

## Dai canali ai Sensi

È stata riconosciuta un'analogia fondamentale: i canali attraverso cui una AI interagisce con il mondo sono analoghi ai sensi e alle capacità espressive di una persona.

Gli esseri umani hanno sensi biologicamente limitati. Una Persona Artificiale può invece acquisire nel tempo sensi radicalmente diversi: testo, audio, video, mouse/tastiera, sensori ambientali, radar, pelle sintetica, sensori chimici, naso elettronico e tecnologie non ancora esistenti.

Per questo l'architettura non deve assumere testo, audio, immagini o OpenAI API come forme privilegiate di interazione.

## Scelta terminologica: Senso ↔ Espressione

Sono state considerate diverse coppie terminologiche, fra cui esperienza, percezione e azione.

`Esperienza` è stata scartata perché evoca un vissuto già elaborato cognitivamente e potenzialmente memorizzato.

`Percezione` è stata ritenuta meno adatta perché tende a implicare interpretazione del segnale.

`Azione` è stata ritenuta troppo legata a intenzione, volontà e decisione.

La coppia consolidata è:

> **Senso ↔ Espressione**

`Senso` descrive la capacità di entrare in contatto con una categoria di fenomeni senza implicare comprensione, memoria o ragionamento.

`Espressione` descrive la capacità di produrre un effetto verso il mondo senza implicare che la decisione o l'intenzione appartengano all'Espressione stessa.

## Modello del Senso

La discussione sui sensi biologici ha portato alla catena astratta:

```text
Mondo
  ↓
Fenomeno
  ↓
Recettore
  ↓
Trasduzione
  ↓
Elaborazione
  ↓
Trasmissione
  ↓
Sistema Cognitivo
```

La trasduzione è il passaggio tra fenomeno fisico e rappresentazione astratta.

È stata considerata particolarmente importante la frase:

> **Senso non trasporta il mondo, ma una rappresentazione del mondo.**

Da questa riflessione è stato consolidato anche il principio:

> **RumiAI non assume che esista una rappresentazione privilegiata della realtà.**

Un Senso può quindi produrre rappresentazioni molto diverse dello stesso mondo, con differenti livelli di campionamento, quantizzazione ed elaborazione.

## Stream, non eventi

Un punto fondamentale emerso dalla discussione è che Senso ed Espressione devono essere pensati come **stream**.

Il mondo evolve continuamente nel tempo e nello spazio. Gli eventi sono una concettualizzazione e discretizzazione umana/informatica di questa continuità.

Una request HTTP, un messaggio MQTT, un interrupt o un click possono essere visti come pacchetti/segmenti organizzati sopra un flusso. Request/response, eventi asincroni, frame e messaggi appartengono quindi ai livelli implementativi e non devono determinare il modello concettuale.

## Senso ed Espressione come confini

Senso ed Espressione sono stati descritti metaforicamente come le due **porte** tra mondo fisico e mondo cognitivo.

Successivamente è stato esplicitamente chiarito che `porta` è soltanto una metafora descrittiva e **non deve diventare un concetto architetturale autonomo**. La proposta di introdurre `Porta di Senso` e `Porta di Espressione` è stata quindi scartata.

Regola metodologica derivata:

> Le analogie servono a comprendendere i concetti, ma non diventano automaticamente elementi del modello.

## Persona Artificiale

È stata consolidata una distinzione importante:

> **RumiAI non coincide con l'intera Persona Artificiale.**

RumiAI rappresenta il dominio/cervello cognitivo. La Persona Artificiale è caratterizzata dall'insieme di:

- Dominio Cognitivo / RumiAI;
- Sensi;
- Espressioni.

Due Persone Artificiali con lo stesso dominio cognitivo ma Sensi o Espressioni differenti instaurano relazioni differenti con il mondo e possono quindi essere considerate entità differenti.

Il parallelo con le persone umane è intenzionale: ciò che una persona può percepire e il modo in cui può esprimersi verso il mondo contribuiscono a definire il patrimonio di percezioni da cui nascono memoria, conoscenza ed esperienza.

## Livelli di astrazione

Per evitare di confondere concetti e tecnologie è stata concordata una separazione esplicita dei livelli:

1. **Modello concettuale / Costituzione** — che cosa esiste e che cosa significa.
2. **Modello logico / Architettura** — come i concetti interagiscono.
3. **Implementazioni di riferimento** — come il modello può essere realizzato oggi.
4. **Deployment / PoC concreto** — software, processi, container, configurazioni e test.

Una tecnologia come TCP, HTTP, JSON, OpenAI API, Ollama o Docker non deve contaminare la definizione costituzionale di Senso o Espressione.

## Implementazione di riferimento discussa

Il prototipo già validato OpenWebUI / Terminal Gateway → interfaccia OpenAI-compatible → Core-AI → Ollama è stato reinterpretato come possibile implementazione concreta del modello.

L'idea pratica è che una implementazione di RumiAI possa esporre un collegamento trasmissivo, per esempio una socket TCP sulla porta 2000, sulla quale viaggia informazione codificata secondo OpenAI API.

Questo è un esempio di implementazione, non la definizione di RumiAI.

OpenWebUI può quindi essere adattato per realizzare Senso ed Espressione verso RumiAI; TCP e OpenAI API appartengono ai livelli implementativi.

Gli adapter sono strumenti implementativi per rendere software e protocolli esistenti compatibili con il modello, non concetti fondamentali della Costituzione.

## Costituzione di RumiAI

Dalla necessità di mantenere stabili i principi è nata l'idea di una **Costituzione di RumiAI**: un corpus minimo di definizioni e principi tecnologicamente indipendenti, separato dalle specifiche architetturali, dalle implementazioni di riferimento e dai PoC.

Sono state abbozzate definizioni per Persona Artificiale, Mondo, Fenomeno, Rappresentazione, Dominio Cognitivo, Senso ed Espressione e sono state formulate regole metodologiche di essenzialità, astrazione e validazione.

Importante: diverse bozze prodotte nella seconda parte della chat hanno iniziato a confondere nuovamente i livelli di astrazione. L'utente lo ha rilevato esplicitamente. **Quelle riformulazioni non devono essere considerate automaticamente consolidate.** Il riferimento più fedele resta il modello Senso/Espressione già elaborato e i documenti recuperati in questa cartella.

## Nervo

Nella parte finale della chat l'utente ha proposto di chiamare **Nervo** il canale/collegamento trasmissivo di Senso ed Espressione.

La proposta è stata accolta perché, a differenza della metafora `porta`, introduce un concetto realmente distinto: il collegamento che trasporta le rappresentazioni tra Senso/Espressione e RumiAI.

Il termine è coerente con il paradigma biologico ma non deve vincolare l'implementazione. Un Nervo può essere realizzato, per esempio, con TCP, memoria condivisa o altri mezzi.

Stato terminologico alla fine della chat:

- **Senso** — consolidato;
- **Espressione** — consolidato;
- **Porta** — solo metafora, scartata come concetto architetturale;
- **AI-Channel** — precedente nome del canale trasmissivo;
- **Nervo** — nome proposto/accettato per il canale trasmissivo.

## Principi da preservare

> **Senso non trasporta il mondo, ma una rappresentazione del mondo.**

> **RumiAI non assume che esista una rappresentazione privilegiata della realtà.**

> **Senso ed Espressione sono stream, non eventi.**

> **Le implementazioni evolvono; le astrazioni corrette devono sopravvivere.**

> **Un'idea importante deve essere portata presto a un Proof of Concept.**

> **Le analogie aiutano a comprendere il modello, ma non sono automaticamente concetti del modello.**

## Artefatti archiviati

In questa cartella sono stati salvati i file testuali ancora recuperabili:

- `ai-open-source-ecosystem.md`
- `RumiAI - Il paradigma Senso - Espressione.md`
- `RumiAI Notebook 001 - recupero testuale.md`

Nella File Library risultano inoltre ancora presenti copie PDF di `RumiAI - Il paradigma Senso - Espressione.pdf`, `RumiAI - Senso ed Espressione.pdf` e `RumiAI Notebook 001.pdf`. In questa sessione il connettore GitHub consente la creazione di file UTF-8 ma non il trasferimento diretto dei byte dei PDF dalla File Library; per questo ne è stato conservato nel repository il contenuto testuale recuperabile, senza fingere di aver copiato i file binari originali.
