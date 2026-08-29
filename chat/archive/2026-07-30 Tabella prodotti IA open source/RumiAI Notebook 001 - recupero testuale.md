# RumiAI Notebook 001 — recupero testuale

> Nota archivistica: nella File Library è ancora accessibile il PDF `RumiAI Notebook 001.pdf`, ma il connettore GitHub disponibile in questa sessione non consente di trasferire direttamente i byte del PDF. Questo file conserva il contenuto testuale recuperabile rilevante dalla copia accessibile.

## Ecosistema open source AI

La panoramica iniziale classifica runtime LLM, multimodale, embedding, vector DB, RAG, agenti, workflow, gateway, UI, voice, devices e messaging, evidenziando le modalità RR, SSE, WebSocket, full-duplex stream, eventi asincroni e batch.

La conclusione iniziale è che l'ecosistema è frammentato perché ogni componente espone un sottoinsieme diverso delle modalità di comunicazione e che occorre astrarre il trasporto.

## Paradigma Senso ↔ Espressione

RumiAI vuole partire dalle funzioni fondamentali con cui un'entità intelligente entra in relazione con il mondo, non dalle tecnologie disponibili.

L'interazione viene ricondotta a due concetti fondamentali:

- **Senso**
- **Espressione**

Un Senso rappresenta la capacità di acquisire informazioni dal mondo e non identifica dispositivo, protocollo o formato. Un'Espressione rappresenta la capacità di modificare il mondo e non descrive decisione, intenzione o dispositivo.

### Principi linguistici

`Input/Output` sono termini informatici e descrivono il punto di vista del software. `Percezione` implica già interpretazione cognitiva. `Azione` è troppo legata a volontà e decisione. `Senso` ed `Espressione` descrivono invece il rapporto dell'entità con il mondo.

## Fenomeno, rappresentazione e significato

Il modello deve supportare dati grezzi e dati già elaborati senza assumere una rappresentazione privilegiata.

Principio emerso nella discussione:

> Senso non trasporta il mondo, ma una rappresentazione del mondo.

L'interpretazione appartiene all'intelligenza, non deve essere imposta dalla definizione del Senso.

## Catena astratta del Senso

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

La trasduzione segna il passaggio tra fenomeno e rappresentazione. La trasmissione porta la rappresentazione verso il Sistema Cognitivo.

Esempi discussi:

```text
Webcam:
luce → camera → CMOS/RGB → compressione/elaborazione → trasmissione

Microfono:
onde sonore → microfono → ADC → codec/elaborazione → trasmissione

Computer Use:
stato schermo → screenshot → bitmap → OCR/Vision → trasmissione

MQTT:
fenomeno remoto → client MQTT → payload → parsing → trasmissione
```

## Stream, non eventi

Senso ed Espressione sono modellati come stream. Il mondo evolve continuamente; eventi, messaggi, pacchetti, request/response e interrupt sono modi implementativi di campionare, quantizzare e organizzare porzioni del flusso.

## AI-Channel / Nervo

Nel materiale originario il canale trasmissivo era chiamato `AI-Channel`.

Il suo ruolo è il trasporto e non la definizione del significato delle informazioni. Una implementazione può utilizzare, per esempio, una socket TCP/IP e protocolli/formati sovrapposti.

Nella parte finale della chat il termine **Nervo** è stato proposto e accettato come nome del collegamento/canale trasmissivo di Senso ed Espressione.

## Persona Artificiale

La Persona Artificiale non coincide con il solo cervello/RumiAI. È caratterizzata dall'insieme del Dominio Cognitivo, dei Sensi e delle Espressioni. Il modo in cui una persona — biologica o artificiale — può percepire ed esprimersi verso il mondo contribuisce a definirne l'identità.

## Principio fondante

Senso ed Espressione costituiscono i due confini architetturali tra mondo fisico e mondo cognitivo.

Tutto ciò che appartiene al mondo viene osservato attraverso un Senso; tutto ciò che il Sistema Cognitivo comunica al mondo passa attraverso un'Espressione.
