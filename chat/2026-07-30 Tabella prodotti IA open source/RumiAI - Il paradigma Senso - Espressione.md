# RumiAI – Il paradigma Senso ↔ Espressione

## Premessa

Durante la progettazione di RumiAI è emersa una constatazione fondamentale: la maggior parte delle architetture per l'intelligenza artificiale nasce dalle tecnologie disponibili oggi.

Si parte da concetti come REST, WebSocket, OpenAI API, MQTT, Computer Use, Speech-to-Text, Vision, ecc., e si costruisce un sistema che li orchestra.

RumiAI vuole seguire il percorso opposto.

L'architettura non deve essere modellata sulle tecnologie disponibili oggi, ma sulle funzioni fondamentali che un'entità intelligente deve possedere per poter interagire con il mondo.

Le tecnologie cambieranno. L'astrazione dovrà rimanere valida.

## Il problema

Le AI moderne sono estremamente potenti, ma sono ancora fortemente vincolate dalle modalità con cui comunicano.

Un LLM riceve testo. Un modello di Vision riceve immagini. Un sistema Speech-to-Text riceve audio. Computer Use riceve screenshot e produce movimenti del mouse. Un robot riceve dati da sensori. Una smart home riceve eventi MQTT.

Dal punto di vista architetturale questi vengono normalmente trattati come sistemi completamente differenti.

In realtà rappresentano tutti la stessa cosa: sono modalità diverse attraverso cui un'entità entra in relazione con il mondo.

## Il cambio di paradigma

Invece di classificare i sistemi in base alla tecnologia utilizzata, RumiAI propone di classificarli in base alla funzione che svolgono.

L'interazione con il mondo può essere ricondotta a due soli concetti fondamentali:

- Senso
- Espressione

Questi due concetti costituiscono il livello di astrazione sul quale costruire tutta l'architettura.

## Senso

Un Senso rappresenta una capacità di acquisire informazioni dal mondo.

Non identifica un dispositivo. Non identifica un protocollo. Non identifica un formato dati.

Identifica esclusivamente una modalità con cui il sistema può ricevere fenomeni provenienti dall'ambiente esterno o interno.

Un Senso può essere implementato attraverso una telecamera, un microfono, una pelle sintetica, un radar, un sensore di temperatura, un filesystem, una mailbox, un feed di eventi, MQTT, HTTP, OpenAI Vision, un LLM che descrive un'immagine o qualunque futura tecnologia oggi ancora inesistente.

Tutte queste implementazioni rappresentano lo stesso concetto architetturale. La tecnologia diventa un dettaglio.

## Espressione

Una Espressione rappresenta la capacità del sistema di modificare il mondo.

Non descrive la decisione. Non descrive l'intenzione. Non descrive il dispositivo utilizzato. Descrive esclusivamente il fatto che il sistema produce un effetto osservabile.

Un'Espressione può assumere forme molto diverse: pronunciare una frase, generare un'immagine, cliccare un pulsante, muovere il mouse, inviare una richiesta HTTP, pubblicare un messaggio MQTT, controllare un robot, accendere una lampadina, modificare un file o inviare un'email.

Dal punto di vista dell'architettura sono tutte manifestazioni dello stesso concetto.

## Perché non "Input" e "Output"

I termini Input e Output appartengono all'informatica. Descrivono il punto di vista del software.

RumiAI vuole descrivere il punto di vista dell'entità intelligente.

Un'entità non possiede Input e Output. Possiede Sensi. Ed esprime qualcosa verso il mondo.

Questo sposta completamente il modello mentale. Non si sta più progettando un insieme di API. Si sta progettando una capacità di relazione con il mondo.

## Perché non "Percezione"

Durante la discussione è emersa anche la possibilità di utilizzare il termine "Percezione".

Il termine è stato scartato per un motivo importante. Nelle neuroscienze e nella psicologia cognitiva esiste una distinzione precisa:

- Sensazione (Sensation): acquisizione del segnale.
- Percezione (Perception): interpretazione del segnale.

La percezione implica già un'elaborazione cognitiva. RumiAI vuole mantenere separati questi livelli.

Il Senso trasporta fenomeni. L'interpretazione appartiene ai processi cognitivi interni.

## Perché "Senso"

"Senso" rappresenta una capacità.

Non implica che il sistema stia effettivamente osservando qualcosa. Non implica comprensione. Non implica memoria. Non implica ragionamento.

Esprime solamente la possibilità di entrare in contatto con una determinata categoria di fenomeni.

Per questo motivo risulta sufficientemente astratto da poter descrivere sia i sensi biologici sia futuri sensori completamente diversi.

## Perché "Espressione"

Anche il termine "Azione" è stato preso in considerazione. È stato però ritenuto troppo legato al concetto di volontà o decisione.

L'Espressione è qualcosa di più generale.

Un essere umano si esprime. Un animale si esprime. Una pianta si esprime. Un robot può esprimersi. Una AI può esprimersi.

L'espressione può assumere qualunque forma. Può essere verbale, grafica, meccanica, digitale o ancora sconosciuta.

Non descrive il mezzo. Descrive il rapporto con il mondo.

## Fenomeno e significato

Questa distinzione introduce una separazione fondamentale.

Un Senso non dovrebbe trasportare significato. Dovrebbe trasportare fenomeni.

Ad esempio, OpenAI Vision restituisce già una descrizione interpretata. Una pelle sintetica potrebbe invece trasmettere una matrice continua di valori di pressione. Entrambi sono Sensi. La differenza è solamente il livello di elaborazione.

L'architettura deve poter supportare indifferentemente dati grezzi e dati già interpretati.

L'interpretazione non appartiene al Senso. Appartiene all'intelligenza.

## Conseguenze architetturali

Questa astrazione rende l'architettura indipendente dalle tecnologie.

Quando nascerà un nuovo sensore non sarà necessario modificare il modello concettuale. Sarà sufficiente implementare un nuovo Senso.

Quando nascerà un nuovo attuatore non cambierà il modello. Sarà semplicemente una nuova forma di Espressione.

Questo rende RumiAI naturalmente estendibile nel tempo.

## Relazione con l'AI-Channel

L'AI-Channel non rappresenta il concetto fondamentale. Rappresenta il mezzo attraverso cui Sensi ed Espressioni vengono trasportati.

Request/Response, Streaming, Full-Duplex, Eventi asincroni e Batch diventano modalità di trasporto. Non definiscono più la natura dell'informazione.

## Visione a lungo termine

La scelta dei termini "Senso" ed "Espressione" non nasce da una preferenza linguistica. Nasce dalla volontà di costruire un'architettura che rimanga valida anche quando cambieranno completamente le tecnologie.

Oggi un Senso può essere una webcam. Domani potrà essere una pelle sintetica, un naso elettronico, un sensore chimico, un radar o un dispositivo che ancora non esiste.

Oggi un'Espressione può essere un click del mouse. Domani potrà essere un robot umanoide, un sistema domotico, un dispositivo medico o qualunque altro attuatore.

L'architettura non dovrà cambiare. Cambieranno solamente gli adapter.

Questo è il principio che guida RumiAI:

> le implementazioni evolvono; le astrazioni corrette devono sopravvivere.
