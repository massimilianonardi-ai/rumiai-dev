# AI-Workflow — Continuity Controller: audit progressivo v02

**Data:** 10 novembre 2026  
**Stato:** consolidamento progettuale successivo al mandato dell'utente «ok procedi»; **non implementato**. Conserva `continuity-audit-v01.md` e integra le due precisazioni emerse da `system-design-audit-simulation-v01.md`.  
**Contesto:** `mdm-routing-v02.md` (MDM e fase di controllo unica approvate), `conversation-identity.md` (identità e checkpoint approvati).  
**Bootstrap operativo di riferimento:** revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`, che **non** incorpora questa specifica.

## 1. Contratto fra fase, log e controller — invarianti già approvate

- Una istanza di workflow principale ha una sola **fase di controllo** attiva per task; la fase può coordinare microattività parallele.
- La fase governa l'esecuzione interna, espone criteri di completamento verificabili e segnala quando sono soddisfatti; il workflow controller applica le transizioni previste.
- La fase espone nel proprio stato logico: microattività corrente, stime e conteggi di turni utente pertinenti, stime e conteggi di passi agentici quando applicabili, ultimo progresso significativo o impedimento.
- Il continuity controller verifica pertinenza, anomalie e autorizzazioni senza sostituire la fase; le decisioni o la baseline non possono essere cambiate senza l'autorizzazione necessaria.
- Un log sintetico non distruttivo conserva eventi significativi e riferimenti a evidenze; il corrente stato della fase non sostituisce la cronologia.
- Il controller non richiama la MDM per una normale continuazione, una ricerca subordinata o una transizione prevista dal workflow.

## 2. Controllo rapido a ogni prompt — PRECISAZIONE INTEGRATA

Prima di scegliere se proseguire, il controller esegue un controllo **leggero**, utilizzando contesto e checkpoint immediatamente pertinenti; non deve ricaricare l'intero log o la MDM ogni volta.

Verifiche minime:
1. **Pertinenza:** il prompt riguarda la fase corrente, una sotto-operazione, una conversazione laterale oppure introduce potenzialmente un task distinto?
2. **Coerenza evidente:** l'assistente sta ripetendo una domanda già risolta o sta contraddicendo un vincolo/decisione che è immediatamente disponibile?
3. **Autorizzazioni e interventi espliciti:** ci sono revoche, sospensioni, comandi di audit, richieste di operazioni non permesse o cambiamenti sostanziali?
4. **Indicatore quantitativo:** l'avanzamento in turni/passi si discosta significativamente dalla stima pertinente?

Se non emergono segnali, procedere senza audit approfondito. La conversazione non operativa non aggiorna automaticamente baseline, obiettivo, fase né contatori di lavoro della fase. Una richiesta di audit o un'anomalia grave produce intervento immediato: **non** attende il superamento della stima.

**Proprietà importante:** un'anomalia evidente può essere rilevata prima della scadenza quantitativa. Non costituisce automaticamente prova di stallo né motivo per eseguire il routing.

## 3. Audit progressivo L1–L4 — metodo approvato

Salvo i trigger immediati del § 2, l'audit approfondisce progressivamente:

| Livello | Domanda | Possibile esito |
| --- | --- | --- |
| **L1 — Scostamento** | Turni utente e passi agentici pertinenti sono molto superiori alla previsione? | Se no, continuare; se sì, L2. |
| **L2 — Avanzamento** | Il log mostra risultati nuovi e pertinenti che spiegano la durata? | Se sì e sufficientemente attendibili, confermare la fase e rivedere eventualmente la stima; altrimenti L3. |
| **L3 — Evidenze e ripetizioni** | Le evidenze esistono e soddisfano i criteri? Si stanno ripetendo domande o attività già concluse? | Correggere la fase se l'anomalia è locale; approfondire a L4 solo se serve. |
| **L4 — Coerenza globale** | Il lavoro è ancora coerente con baseline, vincoli, autorizzazioni e workflow? | Continuare, correggere, sospendere oppure rivalutare la MDM. |

Per un audit richiesto esplicitamente dall'utente, non si limita la risposta al solo L1: il controller riassume i progressi e controlla almeno le evidenze disponibili, commisurando la profondità alle ragioni della richiesta. Se un trigger grave emerge durante qualsiasi livello, si gestisce subito.

Non adottare una soglia numerica valida per tutte le fasi; la stima iniziale è contestuale e non si retrodata quando viene rivista. L'assenza di stime o log è **informazione incompleta**, non conferma che vada tutto bene.

## 4. Evidenze e affidabilità dell'audit — PRECISAZIONE INTEGRATA

Il log è una **fonte di eventi e asserzioni**, non una prova indipendente. Per ogni progresso importante, ove possibile, associare un riferimento controllabile a:
- risultato prodotto (documento, codice, report, prova o output disponibile);
- decisione e fonte dell'autorizzazione;
- verifica svolta, con relativo esito e limiti;
- impedimento fattuale e tentativo di risoluzione.

Una frase come «risultati eccellenti» senza un risultato accessibile non certifica avanzamento. Se l'evidenza è assente o non verificabile, registrare esplicitamente il livello di incertezza; non inventare link, approvazioni, attività di agenti o test.

Distinguere logicamente l'**evento dichiarato dalla fase** dalla **valutazione del controller** (origine, momento, motivazione, evidenza riesaminata). Questo non implica che esistano due agenti indipendenti: lo stesso modello potrebbe produrre entrambi, quindi **non** deve dichiararsi supervisore indipendente.

## 5. Eventi di log e aggiornamento delle stime

**Eventi rilevanti:** ingresso/uscita fase, microattività rilevante avviata/completata, progresso verificabile, impedimento, modifica motivata della stima, richiesta/esito audit, transizione. La selezione è basata sulla significatività: evitare log verbosi del ragionamento e registrazioni prive di conseguenze.

**Informazioni logiche per evento, non schema fisico approvato:** task e checkpoint identificabili, fase, evento, breve fatto osservato, risultato/impedimento, riferimento all'evidenza, origine della dichiarazione.

Il log mantiene le stime iniziali e le successive revisioni motivate; lo stato corrente può riportare solo la previsione valida e i conteggi aggiornati. I conteggi distinguono turni umani pertinenti da passi realmente eseguiti da agenti, senza contare divagazioni come lavoro o supporre agenti inesistenti.

## 6. Esiti ammessi e poteri

- **Continuare:** nessuna anomalia sostanziale o durata giustificata dall'avanzamento.
- **Correggere internamente:** rettificare microattività, recuperare decisioni, riordinare attività o aggiornare stime nel perimetro autorizzato.
- **Sospendere:** preservare stato e punto di ripresa se servono dati, autorizzazioni o decisioni non disponibili.
- **Rivalutare il routing:** consultare MDM per un altro percorso/task soltanto se quello corrente non è più pertinente; non cambiare baseline automaticamente.

Il controller non certifica da sé il completamento della fase: verifica i criteri esposti dalla fase e lascia al workflow controller il passaggio previsto, subordinato agli eventuali gate di approvazione.

## 7. Richiesta esplicita dell'utente

Il requisito approvato prevede un comando di audit manuale; la sintassi seguente resta proposta di integrazione operativa:

```text
!aw audit [--context <logical-id>]
```

Il comando è diagnostico, non concede permessi operativi; se il task è ambiguo senza `--context`, richiedere il minimo chiarimento. Rispondere con fase, stime/contatori disponibili, progressi ed evidenze, anomalie, valutazione ed esito motivato, prossimo passo. Eseguire la finalizzazione universale anche per un audit. **Il verbo `audit` non risulta registrato nel file operativo della revisione bloccata**: non dichiararlo funzionante prima dell'integrazione.

## 8. Casi di verifica richiesti

| Scenario | Atteso |
| --- | --- |
| Fase normale, nei limiti, senza anomalie visibili | Solo controllo leggero |
| Domanda già risolta ripetuta prima del superamento della stima | Correzione precoce, senza aspettare L1 quantitativo |
| Durata superiore con evidenze verificabili | Confermare il percorso, aggiornare la stima motivatamente |
| Durata superiore senza progresso | Verificare ripetizioni ed evidenze; correggere/sospendere |
| Log dichiara risultati senza riferimenti accessibili | Non certificare l'avanzamento |
| Revoca o comando audit prima della stima | Controllo immediato |
| Divagazione tecnica non operativa | Non convertire in nuove autorizzazioni o cambi di workflow |
| Cambio reale di obiettivo | Verificare relazione col task e riattivare routing dove necessario |

## 9. Ancora aperto

Sono rinviati: il formato file del log/stato, il criterio quantitativo contestuale per «scostamento eccessivo», la semantica esatta dei passi agentici nelle implementazioni, l'algoritmo tecnico di aggiornamento atomico dello stato e i test reali. **Non** interpretare questo documento come implementazione o collaudo del controller.
