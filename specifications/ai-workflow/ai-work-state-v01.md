# AI-Workflow — Proposta di struttura persistente di `ai-work-state` (v01)

> **Stato: proposta progettuale, non ancora approvata né implementata.**
> Trascrizione in Markdown della risposta presentata in chat. Il repository `ai-work-state` non è stato modificato.

Consideriamo **`conversations/` già definita e approvata** e concentriamoci sulle altre componenti di `ai-work-state`.

Ho verificato che il repository `massimilianonardi-ai/ai-work-state` esiste ma attualmente è vuoto. Possiamo quindi progettare la struttura senza vincoli di compatibilità con file preesistenti.

La mia proposta è distinguere tre responsabilità: **individuare i task, ricostruire le richieste e conservare lo stato autorevole di ciascun task**.

## 1. Struttura generale proposta

```text
ai-work-state/
│
├── conversations/                 # Già approvata
│   └── <chat-id>/
│       ├── branch-0.yaml
│       ├── branch-1.yaml
│       └── ...
│
├── registry/
│   └── tasks.yaml
│
├── requests/
│   └── <chat-id>/
│       ├── 0-000001.yaml
│       ├── 0-000002.yaml
│       ├── 1-000003.yaml
│       └── ...
│
└── tasks/
    └── <task-id>/
        ├── baseline-v001.md
        ├── task-state.md
        ├── task-specification.md
        ├── task-log.md
        └── handoff.md
```

In questa proposta non aggiungerei altri livelli di directory. Per esempio, `task-specification.md` sarà presente soltanto per i task che ne hanno bisogno.

## 2. `registry/` — Individuazione dei task

Il registro deve permettere di identificare un task quando non abbiamo già un'associazione attendibile nella conversazione.

Non deve contenere lo stato completo dei task.

Proporrei un unico file `registry/tasks.yaml`:

```yaml
tasks:
  - id: task-001
    title: AI-Workflow development
    summary: Universal AI workflow design and implementation

  - id: task-002
    title: SuperEnalotto analysis
    summary: Statistical analysis and predictive experiments
```

Gli identificativi sono illustrativi; non abbiamo ancora deciso il loro formato definitivo.

**Eviterei campi ridondanti**, come:

- `path`, perché è sempre ricavabile da `tasks/<task-id>/`.
- `status`, perché appartiene a `task-state.md`.
- `current_baseline`, perché deve essere definita nello stato autorevole del task.

Il registro serve quindi a cercare e riconoscere i task, non a decidere cosa sia stato approvato.

## 3. `requests/` — Cronologia delle richieste e delle associazioni

Questa è la parte più importante per il funzionamento dei branch.

Propongo **un file per checkpoint di risposta**, contenente il riferimento alla richiesta e le variazioni dello stato della conversazione prodotte da quel prompt.

Esempio:

`requests/<chat-id>/0-000004.yaml`

```yaml
request_ref: <source-reference>

tasks_added:
  - task-002

tasks_removed:
  - task-001
```

Il percorso identifica già:

- La conversazione.
- Il branch.
- Il `message-id` della risposta.

Non ripeterei quindi queste informazioni nel file.

### Perché registrare le variazioni e non l'elenco completo?

Supponiamo che l'evoluzione sia:

| Checkpoint | Modifica | Task attivi |
|---|---|---|
| 0/1 | Aggiunto A | A |
| 0/2 | Nessuna | A |
| 0/3 | Aggiunto B | A, B |
| 0/4 | Rimosso A | B |
| 0/5 | Aggiunto C | B, C |

Se una diramazione parte da `0/3`, ricostruiamo correttamente **A e B**, senza utilizzare lo stato corrente del ramo 0.

Questo soddisfa il requisito già approvato senza duplicare l'elenco dei task in ogni richiesta.

Il file per checkpoint potrebbe inoltre contenere un riferimento al risultato o all'evento registrato, se necessario.

Una precisazione: quando più messaggi dell'utente confluiscono in un'unica risposta, il record deve poter conservare **più riferimenti alle richieste**. Non dobbiamo assumere una corrispondenza sempre uno-a-uno.

## 4. `tasks/` — Documenti autorevoli

Qui manterrei i documenti già concordati, senza aggiungerne altri per il momento.

| File | Responsabilità | Aggiornamento |
|---|---|---|
| `baseline-vNNN.md` | Obiettivo originale e sue revisioni esplicitamente autorizzate | Nuova versione, mai sovrascrittura |
| `task-state.md` | Stato attuale effettivo, decisioni approvate, vincoli, avanzamento | Quando cambia |
| `task-specification.md` | Requisiti, progettazione, casi d'uso, verifiche | Quando necessario |
| `task-log.md` | Eventi cronologici, modifiche, errori, risultati | Append-only |
| `handoff.md` | Punto preciso di ripresa e prossima azione autorizzata | Ultimo aggiornamento del task |

### Baseline

Per le baseline approvate manterrei:

```text
tasks/<task-id>/
├── baseline-v001.md
├── baseline-v002.md
└── ...
```

La versione iniziale rimane sempre disponibile.

Una modifica dell'obiettivo non aggiorna la baseline esistente: ne crea una nuova soltanto dopo autorizzazione esplicita.

### Handoff

L'handoff non è una seconda copia dello stato.

Deve rispondere principalmente alla domanda:

**«Se un altro agente riprende il task adesso, cosa deve sapere e qual è la prossima azione autorizzata?»**

Può quindi riferirsi a baseline, stato, specifica e revisioni Git senza copiarne integralmente il contenuto.

## 5. Relazioni fra task

Abbiamo già deciso che i task possono avere relazioni molteplici: dipendenze, sostituzioni, appartenenza a un progetto, condivisione di risorse.

Le conserverei in `task-state.md` del task interessato.

Per esempio:

```yaml
relations:
  depends_on:
    - task-001
  related_to:
    - task-003
```

Non le inserirei inizialmente nel registro globale, perché rischieremmo di dover aggiornare due fonti per ogni modifica.

Un eventuale indice inverso delle dipendenze potrà essere generato in futuro se necessario.

## 6. Come funziona il recupero

```text
chat-id + branch-id
        ↓
conversations/<chat-id>/branch-N.yaml
        ↓
tasks/<task-id>/task-state.md
        ↓
Documenti aggiuntivi necessari
(baseline, specifica, log, handoff)
```

Normalmente sono sufficienti due letture iniziali: file del branch e stato del task.

`registry/` interviene quando occorre individuare un task non già associato.

`requests/` interviene quando occorre ricostruire un checkpoint precedente, verificare associazioni o recuperare una diramazione.

Questo è un punto importante per l'efficienza: **non dobbiamo consultare tutti gli archivi a ogni prompt**.

## 7. Persistenza e affidabilità

Non introdurrei immediatamente una directory permanente `pending/`.

Il problema principale non è dove mettere i file temporanei, ma come evitare che un aggiornamento parziale renda incoerente lo stato.

Per questo proporrei che la finalizzazione utilizzi, quando disponibile, **un unico commit Git per aggiornare insieme** il record della richiesta, i documenti dei task interessati e il checkpoint del branch.

Il commit dovrebbe essere pubblicato verificando che la revisione del repository non sia cambiata. In caso di conflitto, l'operazione viene rivalutata.

Se gli strumenti non consentono un aggiornamento atomico, il protocollo dovrà prevedere recupero e `sync = pending`.

L'architettura non deve presumere che Git renda atomiche più scritture effettuate separatamente.

## 8. Le decisioni che ti propongo

| Elemento | Proposta |
|---|---|
| `conversations/` | Nessuna modifica |
| `registry/tasks.yaml` | Indice sintetico dei task |
| `requests/` | Un file per checkpoint con riferimenti alle richieste e variazioni delle associazioni |
| `tasks/<task-id>/` | Directory individuale per task |
| Baseline | File versionati e immutabili |
| Stato | Un solo `task-state.md` corrente |
| Specifica | Facoltativa |
| Log | Append-only |
| Handoff | Unico documento corrente, aggiornato per ultimo |
| Relazioni fra task | Nello stato del task |
| Archiviazione completa delle chat | Esclusa per ora, come concordato |

### Tre dettagli da chiudere

La struttura complessiva mi sembra sufficientemente semplice. Prima di considerarla definitiva, affronterei tre scelte specifiche:

1. **Formato degli identificativi dei task**, che devono essere immutabili e non dipendere dal titolo.
2. **Granularità dell'indice delle richieste:** un file per checkpoint, come proposto, oppure un registro append-only per branch.
3. **Forma e dimensione di `registry/tasks.yaml`:** indice unico inizialmente, oppure suddivisione per task per ridurre i conflitti quando crescerà il numero di attività.

La mia preferenza iniziale è **un file per checkpoint e un registro globale leggero**. È una soluzione semplice, con costi di lettura contenuti e una buona possibilità di recupero.

Non aggiungerei ancora altri contenitori per contesti, cache, allegati o archivi: possiamo introdurli quando avremo identificato un requisito concreto.

**Questa è una proposta progettuale, non ancora approvata né implementata.** Il repository `ai-work-state` non è stato modificato.
