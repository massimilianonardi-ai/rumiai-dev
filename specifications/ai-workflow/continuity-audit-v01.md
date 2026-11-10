# AI-Workflow — Continuity Controller: audit progressivo v01

**Stato:** specifica progettuale; principi di seguito marcati **APPROVATI** a seguito della discussione del 10 novembre 2026. I dettagli marcati **PROPOSTA** restano da validare. Non è una funzionalità già implementata.  
**Documenti precedenti:** `ai-workflow-v03.md`, `mdm-routing-v02.md`, `conversation-identity.md`. Nessuna versione storica viene sostituita.  
**Bootstrap di riferimento:** `ai-workflow/bootstrap.md` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221` (ancora precedente alla nuova architettura in tre sezioni).

## 1. Confini e responsabilità — APPROVATI

- Una **istanza di workflow principale per task** presenta **una sola fase di controllo attiva**; questa può gestire attività interne concorrenti o essere una fase composita esplicita.
- La **fase** governa il proprio lavoro e il completamento, dichiara criteri di completamento espliciti e verificabili, la microattività corrente, le stime dei turni con l'utente e dei turni/passi con agenti (quando pertinenti), e l'ultimo avanzamento significativo o impedimento.
- Il **continuity controller** verifica se il percorso resta pertinente, controlla le anomalie, richiede o esegue audit e valuta se continuare, correggere, sospendere o ricorrere al routing; non riscrive da solo la baseline né concede autorizzazioni.
- La **MDM** seleziona o ricompone il workflow quando serve: non va richiamata per ogni prompt, per una normale transizione interna né per una mera sotto-operazione.
- Il **log** conserva eventi sintetici di workflow/fase e riferimenti alle evidenze; non è una registrazione integrale del ragionamento. Lo stato corrente e la cronologia degli eventi hanno responsabilità diverse. La possibilità di usare il `task-log` esistente senza introdurre un archivio duplicato è la preferenza progettuale.

L'audit non deve trasformare una durata eccessiva in prova automatica di stallo. Un'attività più lunga del previsto può essere appropriata se continua a produrre risultati pertinenti e verificabili.

## 2. Procedura progressiva di rilevazione — APPROVATA COME METODO

Prima di svolgere un audit ordinario approfondito, il controller effettua un **controllo leggero a ogni prompt pertinente**, senza riclassificare necessariamente la richiesta con la MDM. L'esame approfondito cresce soltanto in presenza di un segnale significativo.

**Livello 1 — Scostamento.** Confrontare l'andamento effettivo con le stime della fase: numero di turni con l'utente e, quando applicabile, passi agentici. Valutare lo *scostamento eccessivo* sulla base delle stime dichiarate per quella fase; una lieve eccedenza non basta. Se lo scostamento è normale e non sono presenti trigger straordinari, continuare senza audit ulteriore.

**Livello 2 — Avanzamento.** Se lo scostamento è eccessivo, consultare il log per confrontare risultati significativi, impedimenti, microattività, attività già concluse e lavoro ancora necessario. Se la durata è spiegata da progressi reali, si può confermare il percorso e aggiornare motivatamente la previsione.

**Livello 3 — Evidenze e ripetizioni.** Se i progressi sono insufficienti o dubbi, verificare i riferimenti ai risultati, le ripetizioni improduttive, i problemi già risolti riproposti, le contraddizioni e l'effettiva soddisfazione dei criteri della fase. Il log scritto dalla fase **non costituisce da solo prova indipendente**.

**Livello 4 — Coerenza globale.** Se l'anomalia resta aperta, confrontare andamento e risultati con obiettivo, baseline, vincoli, autorizzazioni e pertinenza del workflow; decidere se è sufficiente una correzione interna, se occorre sospendere, oppure se è necessario ricorrere alla MDM.

Il procedimento è **progressivo**: non bisogna eseguire tutte le verifiche se il livello corrente chiarisce già il caso. La mancanza di stime affidabili non deve essere trattata come «nessuno scostamento» certo: il controller può dichiarare il monitoraggio incompleto e sfruttare altre evidenze disponibili.

### Eccezioni indispensabili — APPROVATE COME PRINCIPIO

Il superamento della stima **non è una precondizione universale** per qualsiasi controllo: una richiesta esplicita di audit, una revoca/interruzione dell'utente, una proposta che supera le autorizzazioni, o un'incoerenza grave immediatamente visibile devono essere affrontate senza attendere i turni previsti. Le verifiche di sicurezza/autorizzazione precedono l'eventuale esecuzione rischiosa.

Un prompt di divagazione, discussione tecnica o chiarimento non costituisce automaticamente un nuovo task, una modifica della baseline o una nuova autorizzazione. La condizione dell'utente è un requisito riconosciuto da approfondire, non un'inferenza psicologica da automatizzare nell'alpha.

## 3. Esiti dell'audit — APPROVATI A LIVELLO LOGICO

1. **Continuare:** la fase procede; se opportuno le stime vengono aggiornate con motivazione senza alterare retroattivamente quelle precedenti.
2. **Correggere internamente:** riallineare microattività, ordine di lavoro, stime o verifiche **nel perimetro già autorizzato**, senza cambiare obiettivo o baseline.
3. **Sospendere:** non proseguire attività che richiedono una decisione, dati mancanti o autorizzazioni non disponibili; mantenere il punto di ripresa.
4. **Rivalutare il routing:** richiamare la MDM soltanto se la fase/workflow non è più pertinente, oppure il prompt introduce un obiettivo o un task sostanzialmente diverso. Il controller **non può autorizzare autonomamente** la revisione della baseline.

Gli esiti dell'audit e le relative motivazioni vanno registrati come eventi significativi.

## 4. Log sintetico per audit — PRINCIPIO APPROVATO, MODELLO MINIMO PROPOSTO

**Eventi candidati:** ingresso/uscita di fase, inizio/conclusione di microattività rilevante, progresso significativo, impedimento, revisione della stima, richiesta di audit, esito dell'audit, transizione.

**Informazioni logiche minime per evento (PROPOSTA, non ancora schema file):**
- identificazione verificabile del task e del checkpoint/ordine temporale;
- workflow/fase interessati, quando esistono;
- tipo di evento e breve descrizione fattuale;
- risultato o variazione verificata;
- eventuale riferimento all'evidenza disponibile;
- origine: dichiarazione della fase, osservazione del controller oppure richiesta dell'utente.

I passi agentici e i turni devono riferirsi **al task/fase pertinente**; conversazioni laterali o lavoro su altri task non devono gonfiare automaticamente i contatori della fase in audit. La semantica esatta di turni/passi, la frequenza degli eventi e il formato fisico restano da definire.

La revisione di una stima deve lasciare traccia del valore precedente e della motivazione: non deve servire ad azzerare artificiosamente le anomalie. Registrare gli eventi significativi, non ogni chiamata di tool o ogni ragionamento privato.

## 5. Audit richiesto dall'utente — APPROVATO COME REQUISITO

È approvato un **comando esplicito per richiedere audit in qualsiasi momento**, indipendentemente dallo scostamento dalle stime.

**Sintassi candidata (PROPOSTA DI DETTAGLIO):**

```text
!aw audit [--context <logical-id>]
```

- Senza `--context`, identificare il task corrente soltanto se non ambiguo; con più task candidati chiedere il discriminante essenziale, senza audit arbitrario su un task diverso.
- Il comando avvia un audit del workflow/fase del task selezionato e restituisce almeno: fase corrente, andamento rispetto alle stime se disponibile, ultimi progressi/evidenze, eventuali anomalie, esito motivato e prossimo passo.
- È diagnostico: non autorizza da solo esecuzione, deployment, cambio di baseline, avanzamento arbitrario di fase o re-routing senza presupposti.
- Come ogni richiesta, segue la **finalizzazione universale**; l'evento di audit e il checkpoint vengono registrati se la persistenza è disponibile e confermata, altrimenti si segnala lo stato pendente secondo il protocollo approvato.
- **Non è ancora registrato nel file operativo `routing/commands.md`** alla revisione fissata: il vecchio parser accetta solo verbi esplicitamente registrati. La sintassi proposta sarà attivabile soltanto dopo integrazione e verifica.

## 6. Scenari di verifica prima dell'attivazione

| Scenario | Esito atteso |
| --- | --- |
| Fase entro la stima, progressi normali | Controllo leggero, nessun audit approfondito |
| Fase oltre la stima con molti risultati verificabili | Audit progressivo: conferma del percorso ed eventuale stima rivista |
| Fase oltre la stima, ripetizioni e nessun risultato nuovo | Verifica evidenze; correzione interna o sospensione motivata |
| Errore di autorizzazione prima del superamento della stima | Controllo immediato e blocco dell'azione non autorizzata |
| Utente scrive `!aw audit` | Audit esplicito anche se fase nei tempi |
| Più task, comando privo di riferimento univoco | Richiesta di chiarimento minimo, nessun task scelto arbitrariamente |
| Discussione laterale non operativa | Nessuna revisione implicita dell'obiettivo o del workflow |
| Audit individua incompatibilità di workflow | Valutare re-routing MDM preservando lo stato precedente |

## 7. Questioni circoscritte ancora aperte

- Definizione concreta e non arbitraria di *scostamento eccessivo* per differenti tipi di fase, evitando soglie universali rigide.
- Esatta semantica di turni utente, turni/step agente e impatto delle microattività concorrenti.
- Presentazione sintetica dell'audit all'utente e contenuto informativo minimo del risultato.
- Dettagli del contratto delle fasi, dei riferimenti alle evidenze e integrazione fisica nel futuro schema di `ai-work-state`.
- Test del comportamento del comando `!aw audit` e del router prima di qualsiasi attivazione; il comando `!aw route` già esistente resta distinto dall'audit.

**Nessuna modifica operativa ai repository `ai-workflow` o `ai-work-state` è compresa in questa specifica.**
