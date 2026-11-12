# AI-Workflow — Riflessioni e stato dell'architettura v0.4

**Data:** 12 novembre 2026  
**Natura:** documento cumulativo di riflessione e ricognizione; successore di `ai-workflow-v03.md`.  
**Stato:** fotografia verificata dei repository e delle decisioni, distinta da proposte e problemi aperti. **Non costituisce una nuova approvazione di architettura o una modifica della baseline.**

## 1. Continuità con v01–v03

Restano centrali le motivazioni storiche: evitare di confondere task diversi, preservare gli obiettivi approvati, porre tempestivamente le domande architetturali determinanti, distinguere un risultato effettivo da un test formalmente riuscito, mantenere cronologia e handoff affidabili, e limitare le richieste ripetitive di «procedi». Le versioni v01, v02 e v03 rimangono disponibili e non sono sovrascritte.

La v03 è una **fonte storica**: alcune sue affermazioni sullo stato del bootstrap e della persistenza erano vere il 10 novembre ma non descrivono più la situazione del 12 novembre.

## 2. Stato verificato al 12 novembre 2026

- **`ai-workflow/main`**: release/tag `v0.2.3`, commit `ffc405541702169de60c11e8823a1186e6461d93`; `bootstrap.md` adotta tre sezioni obbligatorie **A → B → C**.
- **`ai-work-state/main`**: repository persistente attivo. I checkpoint della conversazione di verifica sono stati effettivamente committati e riletti; non sono più soltanto una proposta.
- **`rumiai-dev/specifications/ai-workflow/`**: archivio storico dei documenti `ai-workflow-v01.md`, `ai-workflow-v02.md`, `ai-workflow-v03.md` e `ai-work-state-v01.md`. È distinto dai repository di regole e di stato.
- I test del runtime di checkpoint risultavano superati (23/23 nelle verifiche già eseguite), ma **test verdi non provano l'invocazione automatica del workflow nell'host**.

Questi fatti descrivono quanto osservato: non implicano che tutte le capacità progettate siano operative.

## 3. Tre repository, tre responsabilità

| Repository | Ruolo |
| --- | --- |
| `ai-workflow` | Bootstrap, regole, routing, metodi, runtime sperimentale e test. |
| `ai-work-state` | Checkpoint effettivi di conversazione e, quando autorizzati, documenti persistenti dei task. |
| `rumiai-dev` | Memoria progettuale storica e versioni cumulative delle riflessioni. |

**Riflessione:** questa distinzione deve essere esplicita nella navigazione del progetto. La recente ricerca dei file `ai-workflow-v01.md`–`v03.md` ha mostrato che la loro collocazione in `rumiai-dev` non era immediatamente riconoscibile partendo da `ai-workflow`. È un problema di reperibilità, non evidenza di perdita o cancellazione.

**Proposta, non approvata:** aggiungere in futuro un indice navigabile ai documenti storici, senza duplicarli né trasferirli implicitamente.

## 4. Bootstrap e continuità: progressi reali

Il bootstrap operativo ora separa:

1. **A — premesse universali e identità:** recuperare il checkpoint autentico, non dedurre un task dalla sola prossimità della chat.
2. **B — continuità e lavoro:** verificare prima se la richiesta prosegue il task; ricorrere al routing multidimensionale solo quando necessario; rispettare autorizzazioni e confini.
3. **C — finalizzazione universale:** tentare il checkpoint GitHub **a ogni risposta**, anche se nessun task è cambiato, e dichiarare gli esiti reali.

La distinzione tra **conversazione, branch, risposta, richiesta, intento e task** resta fondamentale. Il `chat-id` non è un ID nativo garantito dalla piattaforma. Il messaggio finale funge da riferimento ridondante per il recupero.

**Riflessione:** l'ordine A → B → C è utile solo se C viene realmente eseguita. Una promessa testuale di salvataggio, un piano di scrittura o un test sintetico non sono un checkpoint.

## 5. Persistenza: dal progetto alla prova end-to-end

Il protocollo attuale usa un commit Git atomico per aggiornare insieme:

- `conversations/<chat-id>/branch-N.yaml`: stato corrente del ramo;
- `requests/<chat-id>/<branch-id>-<message-id>.yaml`: record immutabile del checkpoint;
- eventuali documenti di task, **solo** quando esiste una modifica realmente autorizzata.

La scrittura deve partire da una revisione attesa di `main`, rifiutare aggiornamenti concorrenti incompatibili e concludersi con la rilettura del ref e dei file. Il solo esito `update_ref: success` non basta.

**Evidenza concreta:** la conversazione di verifica `2026-11-12_14-26_0d93fd1c-4113-4960-92e6-e05c2833a94e`, branch 0, ha prodotto quattro checkpoint consecutivi, con avanzamento verificato fino al messaggio 4. I file sono su `ai-work-state/main`. Non contengono la trascrizione privata della chat.

**Limite:** questa prova dimostra che il connettore GitHub può eseguire il protocollo in questa sessione, **non** che l'host lo invochi automaticamente in ogni ambiente o dopo ogni tipo di interruzione.

## 6. Incongruenze e lacune da non occultare

1. **Documentazione divergente:** `ai-workflow/state/protocol.md` conserva riferimenti operativi al branch `dev` in alcuni passi, mentre `main` è il ramo persistente corrente. Il testo va allineato mediante modifica esplicitamente autorizzata e verificata; questa v04 non lo corregge.
2. **Runtime sperimentale:** `state/checkpoint-runtime.mjs` è un pianificatore deterministico con adapter, non un hook nativo di ChatGPT. La copertura dei test non equivale all'integrazione con l'host.
3. **Diramazioni e riconciliazione:** alcune mutazioni di task e forme di divergenza non sono gestite end-to-end dal runtime attuale; non dichiararle implementate solo perché descritte nelle specifiche.
4. **Esito parziale:** `sync = pending` resta necessario quando una scrittura non è confermata o esistono lacune non riconciliate. Un checkpoint successivo non deve cancellare retroattivamente un errore non risolto.
5. **Privacy e tracciabilità:** `ai-work-state` è pubblico. Salvare metadati minimi, non conversazioni private, segreti o dati personali. Il requisito storico di conservare le chat originali non autorizza a pubblicarle automaticamente.

## 7. Riflessioni sul metodo di lavoro

### 7.1 Verità della fonte e pertinenza della fonte sono diverse

Un documento autentico può riguardare un altro task. Prima di importare server, infrastrutture, requisiti o decisioni pregresse bisogna verificare che la richiesta attuale abbia la stessa identità e non contenga contraddizioni. La lezione è documentata anche in `ai-workflow/evaluations/lessons/task-identity-contradictions.md`.

### 7.2 Le domande cruciali precedono il lavoro costoso

Per attività architetturali o difficili da invertire, l'assistente deve chiarire presto le scelte che cambiano il risultato, indagando autonomamente ciò che può verificare. Non deve né interrogare inutilmente l'utente né riempire silenziosamente lacune decisive. Si veda `evaluations/lessons/conversational-elicitation.md`.

### 7.3 La persistenza deve essere osservabile

Per ogni checkpoint vanno distinti: **intenzione di scrivere**, **commit creato**, **ref aggiornato**, **file riletti**, **esito comunicato**. La stessa disciplina vale per il risultato funzionale di un task: documenti e test sono prove, non surrogati dell'obiettivo.

### 7.4 La memoria progettuale va distinta dalla norma vigente

I documenti cumulativi `v01`–`v04` preservano il ragionamento e la sua evoluzione; non devono prevalere sul bootstrap e sulle specifiche operative approvate. In particolare, la presenza di una proposta nella storia non equivale alla sua approvazione.

## 8. Decisioni confermate, proposte, questioni aperte

**Decisioni confermate:** separazione dei repository; bootstrap universale A → B → C; identità distinte; baseline modificabile solo con revisione autorizzata; routing multidimensionale non esclusivo; checkpoint a ogni risposta; scrittura atomica con verifica; segnalazione esplicita dei fallimenti.

**Proposte da valutare:** indice dei documenti storici; controllo automatico di coerenza tra riferimenti a `main` e `dev`; test end-to-end nell'ambiente host, separati dai test del planner; criteri misurabili per l'accettazione del recupero di branch e task.

**Aperto:** garanzia effettiva di esecuzione universale nel client; copertura dei casi di diramazione, concorrenza e recupero; gestione autorizzata delle fonti originali delle chat senza violare la riservatezza; percorso di attivazione e validazione operativa oltre il repository.

## 9. Prossimo passo ragionevole

Prima di ampliare l'architettura, confrontare **specifica, runtime e comportamento effettivo** in una matrice di copertura: implementato e verificato, implementato ma non validato nell'host, solo documentato, contraddittorio. Correggere prima le discrepanze dimostrate, con approvazione esplicita per le modifiche normative.

---

**Tracciabilità:** documento nuovo, non sostituisce `ai-workflow-v03.md`, non modifica `ai-workflow` né `ai-work-state` e non dichiara approvate le proposte.