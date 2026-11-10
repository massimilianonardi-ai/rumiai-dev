# AI-Workflow — MDM, fase unica e audit v02

**Stato:** riepilogo cumulativo aggiornato dopo l'approvazione della proposta v01. Distinguere le decisioni approvate dalle nuove proposte.  
**Documento precedente:** `mdm-routing-v01.md` (conservato senza modifiche).  
**Fonte operativa di riferimento:** `ai-workflow` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`.  
**Ambito:** progettazione, non implementazione.

## 1. Decisioni approvate

### 1.1 MDM (multi-dimensional matrix) snella e aperta

Sono approvate le quattro dimensioni concettuali e le sei famiglie operative presentate nella v01:

```yaml
version: 2
status: approved_design_not_activated
dimensions:
  operation: [research, design, develop, diagnose, validate, operate, other]
  input: [text, structured, image, audio, video, other]
  output: [text, document, code, structured, image, audio, video, other]
  effects: [read, artifact_write, environment_change]

candidate_workflows:
  research: technical-research
  design: system-design
  develop: software-development
  diagnose: technical-diagnosis
  validate: validation
  operate: operations
```

Questo YAML descrive un **catalogo progettuale**, non una configurazione operativa già attivata. I nomi di `candidate_workflows` sono riferimenti concettuali da risolvere soltanto quando esisteranno definizioni verificate.

Le dimensioni sono multi-etichetta quando pertinente; `other` lascia aperto il catalogo. L'attuale `interaction` si sovrappone al contesto linguistico; `continuity` e `resume` sono affidati al continuity controller e al recupero del task; `uncertainty` appartiene all'analisi di decisioni/evidenze. `irreversible` è una caratteristica del rischio e non una categoria di effetto esclusiva. Le dimensioni MDM **non attribuiscono autorizzazioni**.

Focus iniziale sulle richieste tecnologiche/scientifiche, progettazione e sviluppo; estensibilità per altri domini.

### 1.2 Una fase di controllo attiva per il workflow principale del task

Una nuova conversazione non ha una fase prescelta. Dopo selezione del task/workflow (oppure ripresa dello stato di un task esistente), l'istanza principale di workflow del task ha **una sola fase di controllo attiva** alla volta.

La fase può coordinare **microattività concorrenti**. Sovrapposizioni con una semantica specifica, come progettazione iterativa di specifiche e architettura, possono essere espresse mediante una fase composita esplicita (`iterative-design`) senza dover costruire ogni combinazione a priori. La regola non è globale per la chat: task diversi possono avere workflow/fasi diversi.

### 1.3 Contratto e supervisione

La fase governa internamente l'esecuzione, dichiara criteri di completamento **espliciti e verificabili**, e propone il completamento/transizione. Il continuity controller verifica coerenza, anomalie e persistenza dell'obiettivo senza sostituire la logica interna della fase o modificare autonomamente la baseline.

Per l'audit esterno, lo stato logico del task espone:
- una descrizione sintetica della **microattività corrente**;
- una **stima** della quantità di turni necessari con l'utente e relativi turni osservati;
- ove pertinente, una **stima** dei turni/passi con agenti e relativi passi osservati;
- l'**ultimo progresso significativo** o impedimento.

Le stime servono come segnali di controllo, non come scadenze automatiche o autorizzazioni a interrompere. Una deviazione può attivare una rivalutazione senza prova di stallo.

**Rimangono da dettagliare:** granularità e semantica dei turni con agenti, formato del contratto di fase, condizioni e soglie dell'audit, schema persistente e gestione del completamento nel caso di composizioni.

## 2. Nuova esigenza: log per audit del continuity controller — DA APPROFONDIRE

L'utente ha sottolineato la necessità di un **log sintetico dell'avanzamento** di workflow/fasi/microattività. Il log dovrebbe consentire un audit fondato su eventi osservabili oltre che sui risultati finali. Una fase più lunga del previsto può essere regolare se ha prodotto progressi ed evidenze significative.

**Distinzione:** l'esistenza del `task-log` come ambito logico è già approvata nella progettazione generale. È ancora **proposta da approfondire**, non decisione conclusa, la semantica particolare degli eventi di fase e il modo in cui alimentarli e utilizzarli per l'audit.

Indicazioni candidate:
- registrare eventi significativi (ingresso/uscita fase, avvio/conclusione microattività, avanzamento verificabile, impedimenti, revisioni delle stime, audit e relativo esito, transizioni);
- conservare una storia non distruttiva e sintetica; evitare una traccia verbosa di ogni passaggio;
- associare agli eventi riferimenti alle evidenze disponibili; il semplice log auto-dichiarato dalla fase non è una prova indipendente;
- attivare l'audit per scostamenti, ripetizioni senza nuovo risultato o incoerenze, **non** interrompere automaticamente sulla base di una soglia;
- verificare anzitutto se sia sufficiente l'ambito `task-log` già previsto, senza introdurre nuovi file per duplicazione.

Il formato dei record, il soggetto responsabile della registrazione, le condizioni di audit e le interazioni con lo stato corrente restano aperti.

## 3. Comando diagnostico esistente: `!aw route`

Nella revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`, `routing/commands.md` definisce:

```text
!aw route [--context ID] -- REQUEST
```

Il comando **non esegue** REQUEST: mostra il routing proposto (intenti, modalità, workflow/stato candidati, decisioni non risolte). Non garantisce oggi una pianificazione completa e dettagliata dell'esecuzione.

**Proposta ulteriore, non approvata:** mantenerlo ed estenderlo a una modalità dry-run con task individuato, MDM, workflow/fase iniziale, attività e dipendenze, autorizzazioni, possibili anomalie, senza effetti operativi.

## 4. Perimetro delle modifiche

Nessuna modifica operativa è autorizzata da questo documento nei repository `ai-workflow` o `ai-work-state`. La prossima attività progettuale è integrare un audit leggero e verificabile nel contratto delle fasi, prima della progettazione finale della persistenza.
