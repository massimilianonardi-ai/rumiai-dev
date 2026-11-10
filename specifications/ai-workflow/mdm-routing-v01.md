# AI-Workflow — MDM routing v01 (proposta)

**Stato:** PROPOSTA, non approvata e non operativa.  
**Ambito:** revisione snella della matrice multidimensionale di routing (MDM).  
**Fonte:** `massimilianonardi-ai/ai-workflow/routing/intents.yaml` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`.  
**Priorità iniziali:** ricerca tecnologica/scientifica, progettazione e sviluppo, senza impedire espansioni future.

## 1. Ruoli separati

- **MDM:** sceglie o ricompone un percorso di lavoro quando il routing è necessario.
- **Continuity controller:** verifica se una richiesta prosegue il task e il workflow esistenti, se è una sotto-operazione o se richiede re-routing. Non è una dimensione MDM.
- **Workflow e contratto della fase:** determinano andamento, attività, requisiti, completamento e transizioni.
- **Controlli di autorizzazione:** verificano se le azioni proposte sono consentite. I valori MDM non attribuiscono permessi.
- **Task e stato:** conservano contesto, decisioni, fase corrente e avanzamento; non sostituiscono la MDM.

Per richieste semplici e autosufficienti può non essere necessario avviare un workflow persistente. In una nuova conversazione non esiste una fase associata finché non è selezionato o ripreso un task con workflow; il recupero di un task preesistente può ripristinare la fase senza nuova classificazione MDM.

## 2. Catalogo candidato snello

Il seguente YAML è una **bozza di struttura**, non la sostituzione già pubblicata di `routing/intents.yaml`. Gli identificatori in `candidate_workflows` sono **famiglie concettuali**, non file o workflow di cui si dichiara l'esistenza.

```yaml
version: 2
status: proposal
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

routing_rules:
  - prefer_continuity_before_new_routing
  - allow_multiple_operations_per_request
  - allow_unknown_or_unclassified_requests
  - do_not_reroute_for_phase_suboperations
  - resolve_only_existing_workflow_definitions
  - treat_modalities_as_specialization_hints
  - treat_effects_as_risk_hints_not_permissions
```

### Criteri semantici

- **`operation`** classifica lo scopo del lavoro, non la forma linguistica del prompt. `research` include ricerca scientifica, tecnologica ed eventuali esperimenti; `design` comprende specifiche e architettura; `develop` comprende implementazione. `diagnose`, `validate` e `operate` costituiscono famiglie distinte solo quando una loro selezione cambia davvero il percorso.
- **`input` e `output`** servono a scegliere capacità e specializzazioni: non trasformano automaticamente il task in un workflow diverso. Sono multi-etichetta quando necessario.
- **`effects`** rileva il tipo di conseguenza operativa; non sostituisce verifica di autorizzazione, reversibilità e impatto. `artifact_write` ed `environment_change` possono coesistere.
- **`other`** lascia aperto il catalogo: non si deve forzare una richiesta sconosciuta in una famiglia sbagliata. Anche un'operazione composta può coinvolgere più famiglie; la decisione se separare i task spetta al controllo contestuale.
- I **workflow candidati** sono nomi indicativi. Non seguire riferimenti che non esistono o non sono verificati. Le associazioni definitive saranno stabilite nella fase di integrazione.

### Elementi rimossi rispetto a v1

- `interaction`: sovrapposizione con intenti e comportamento conversazionale.
- `continuity` e `operations.resume`: di competenza del controller e del recupero del task.
- `uncertainty`: gestione operativa di evidenze e decisioni, non una famiglia primaria di routing.
- `operations.ask`, `reflect`, `create`, `plan`, `review`: comportamenti o sotto-operazioni, non workflow obbligatori.
- `effects.irreversible`: proprietà di rischio dell'azione da verificare indipendentemente dalla MDM, non un'alternativa a `environment_change`.

## 3. Confine MDM/fase — proposta correlata

Per ogni task con un workflow principale, preferire **una sola fase di controllo attiva**, che può coordinare microattività concorrenti. Le sovrapposizioni con semantica specifica possono essere espresse come fasi composte dichiarate dal workflow, senza enumerare a priori tutte le combinazioni. Non applicare questo vincolo all'intera conversazione: task differenti possono trovarsi in fasi diverse.

Il contratto esterno minimo della fase espone **criteri di completamento verificabili**. Il continuity controller verifica coerenza, progressi e anomalie, ma non si sostituisce alla logica interna della fase e non cambia autonomamente la baseline.

## 4. Telemetria minima per audit — proposta correlata

La fase può pubblicare nel task, senza fissarne ora il formato persistente:
- **microattività corrente**, con risultato immediato atteso;
- **stima in intervallo dei turni utente** necessari, con conteggio osservato;
- **stima in intervallo dei passi/turni agente** quando esistono agenti effettivamente coinvolti, con conteggio osservato;
- **ultimo avanzamento significativo o impedimento**, verificabile rispetto ai criteri di fase.

Le stime sono orientative, non limiti temporali o permessi di interrompere automaticamente. Un eccesso rispetto alla stima, una ripetizione senza evidenza nuova, una richiesta ricorrente già risolta o una contraddizione con la baseline attivano **audit o rivalutazione**; non provano da soli uno stallo. I contatori non devono registrare agenti inesistenti o attività non verificate.

## 5. Decisioni ancora aperte

1. Conferma delle quattro dimensioni e delle sei famiglie di operazioni.
2. Conferma della singola fase di controllo attiva per workflow principale, con attività interne parallele.
3. Semantica esatta dei turni con agenti e soglie di audit (da derivare da casi reali).
4. Contratto della fase e integrazione con il continuity controller.
5. Associazioni definitive tra famiglie MDM e workflow effettivamente disponibili, prima di qualsiasi attivazione.

**Non sono state modificate configurazioni operative dei repository `ai-workflow` o `ai-work-state`.**
