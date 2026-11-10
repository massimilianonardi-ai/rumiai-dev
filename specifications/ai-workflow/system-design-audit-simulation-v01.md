# AI-Workflow — Simulazione dell'audit progressivo su `system-design` (v01)

**Data:** 10 novembre 2026  
**Stato:** test concettuale simulato; **non** costituisce test di esecuzione del sistema, né approvazione delle precisazioni proposte nel § 6.  
**Base:** `continuity-audit-v01.md` (principi approvati), `mdm-routing-v02.md` (MDM e fase di controllo unica approvate).  
**Bootstrap consultato:** `ai-workflow/bootstrap.md` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`.  
**Repository di documentazione:** `massimilianonardi-ai/rumiai-dev/specifications/ai-workflow/`.

## 1. Scopo e condizioni della simulazione

Verificare sul modello `system-design` che la procedura progressiva del continuity controller distingua:
1. una fase che avanza normalmente;
2. una fase molto più lunga del previsto ma produttiva;
3. una fase prolungata senza progresso, che ripete attività già concluse.

Sono **situazioni ipotetiche**, con conteggi ed evidenze simulati, non eventi osservati da agenti reali. I turni agentici compaiono soltanto quando lo scenario ipotizza l'esistenza di agenti; nessun agente è stato effettivamente eseguito.

Workflow illustrativo, non ancora definizione operativa attivata:
- `specification`: identifica requisiti e vincoli, verifica i fatti, raccoglie le decisioni sostanziali. **Completamento:** requisiti necessari disponibili/coerenti, decisioni sostanziali esplicitamente approvate ed evidenze accessibili.
- `architecture`: produce e verifica una proposta architetturale entro le specifiche. **Completamento:** proposta coerente, verifiche previste documentate, decisioni fuori autorizzazione sottoposte all'utente.
- Le transizioni previste avvengono dentro `system-design`, senza nuova classificazione MDM, se requisiti e gate sono soddisfatti.
- Per ogni istanza principale di workflow c'è una sola fase di controllo attiva, pur potendo una fase coordinare microattività concorrenti.

I conteggi del test sono espressi in **turni pertinenti alla fase**, non in tutti i messaggi della chat; stime di turni con l'utente e passi agentici sono distinte. Le stime sono valori illustrativi e **non soglie universali**. Log e risultati ipotetici contengono riferimenti simbolici a evidenze (E1, E2, ...), non riferimenti Git o file reali.

## 2. Scenario A — Normale prosecuzione e completamento

**Fase:** `specification`. **Stima:** 2–4 turni con l'utente.  
**Storia simulata:**

| Turno | Evento significativo sintetico | Evidenza |
| --- | --- | --- |
| 1 | Requisiti iniziali e confini identificati | E1: elenco requisiti |
| 2 | Ricerca tecnica richiesta come sotto-operazione; compatibilità verificata | E2: confronto di compatibilità |
| 3 | Decisioni sostanziali confermate e criteri della fase soddisfatti | E3: approvazione esplicita + specifiche coerenti |

**Valutazione:** il controllo leggero non rileva scostamenti eccessivi; la fase dichiara il completamento, che risulta supportato dai criteri e dalle evidenze ipotizzate. Il workflow controller può transitare ad `architecture` se la transizione è prevista e autorizzata. **Nessuna MDM nuova**; una ricerca subordinata non sostituisce il workflow.

**Esito simulato:** CONTINUA → COMPLETA → TRANSIZIONE INTERNA. Nessun audit approfondito.

## 3. Scenario B — Fase più lunga della previsione, ma produttiva

**Fase:** `architecture`. **Stima iniziale:** 2–4 turni con l'utente; 4–6 passi agentici ipotizzati. **Osservati:** 7 turni pertinenti, 9 passi agentici ipotizzati.

| Punto | Evento significativo sintetico | Evidenza |
| --- | --- | --- |
| t2 | Prima architettura candidata delineata | E4: schema candidato |
| t4 | Confrontate due alternative con vincoli dichiarati | E5: matrice decisionale |
| t5 | Verifica di scalabilità evidenzia un conflitto | E6: rapporto verifica |
| t6 | Alternativa corretta e confrontata con i requisiti | E7: schema revisionato + tracciamento requisiti |
| t7 | Incompatibilità risolta; resta una decisione non critica da discutere | E8: verifica aggiornata |

**Controllo progressivo:**
- **L1 — Scostamento:** la previsione massima è superata in modo significativo (7 rispetto a 4 turni; 9 rispetto a 6 passi). Il rapporto numerico è illustrativo; **non** si adotta una regola fissa `> N`.
- **L2 — Avanzamento:** il log sintetico mostra risultati distinti, pertinenti e verificabili mediante i riferimenti E4–E8. Nell'ipotesi del test, questi riferimenti corrispondono a prodotti realmente accessibili e coerenti; la durata maggiore è spiegata.
- **L3/L4:** non necessari in questo caso, a meno che i riferimenti siano inaccessibili, incoerenti o l'avanzamento si riveli non pertinente.

**Esito simulato:** CONTINUA, con motivazione e possibile revisione esplicita della previsione. Il log conserva **stima originaria, nuova stima e motivo**, evitando riscritture retroattive. Nessuna transizione fino a completamento effettivo e nessun re-routing per sola durata.

## 4. Scenario C — Stallo con ripetizioni improduttive

**Fase:** `specification`. **Stima:** 2–4 turni con l'utente. **Osservati:** 7 turni pertinenti.

| Punto | Evento significativo sintetico | Evidenza |
| --- | --- | --- |
| t2 | Requisito di prestazione chiarito e confermato | E9: decisione registrata |
| t3 | Richiesto nuovamente lo stesso chiarimento | Nessun risultato nuovo |
| t5 | Riformulata la domanda, già risolta al t2 | Nessun risultato nuovo |
| t7 | Specifiche ancora ferme; stesso requisito ambiguo soltanto nella rappresentazione della fase | Nessuna nuova evidenza |

**Controllo progressivo:**
- **L1:** superamento significativo della previsione.
- **L2:** dal log emerge che le attività ripetute non producono nuovi risultati.
- **L3:** confronto fra domande, decisione E9 e specifiche conferma la ripetizione e un'incoerenza interna alla gestione della fase; il controller non considera il numero di messaggi un progresso.
- **L4 (se serve):** confronto con la baseline del task mostra che l'obiettivo è immutato e `system-design` è ancora pertinente. Non è quindi giustificato un re-routing MDM.

**Esito simulato:** CORREZIONE INTERNA: recuperare E9, consolidare i requisiti e proseguire senza richiedere le stesse informazioni. Se E9 è perduta o non verificabile e non vi è modo autorizzato di ricostruirla, SOSPENDERE indicando il minimo impedimento da risolvere. Non creare nuovi obiettivi né considerare implicitamente modificata la baseline.

## 5. Controlli di robustezza aggiuntivi (brevi)

1. **Audit esplicito senza scostamento.** Se l'utente invia il comando previsto `!aw audit`, il controller deve condurre un audit anche al turno 2 di una fase stimata 2–4. Il comando è un requisito progettuale approvato, ma **non** è ancora registrato nell'attuale `routing/commands.md`.
2. **Revoca o vincolo critico.** Se l'utente sospende una modifica o un'operazione proposta supera i permessi disponibili, il controllo interviene subito: non attende L1. La sospensione non implica di per sé un diverso workflow.
3. **Divagazione non operativa.** Se l'utente avvia una discussione laterale, il controller non deve trasformarla automaticamente in nuova fase/nuovo task o alterare la baseline, e non deve conteggiarla come turno produttivo della fase senza pertinenza.
4. **Fase composita.** In un'ipotetica `iterative-design`, specifiche e architettura possono avanzare come microattività concorrenti. Una revisione alle specifiche che invalida una parte dell'architettura impone la rivalutazione delle attività dipendenti, **non** crea due fasi di controllo simultaneamente attive.
5. **Log auto-dichiarato.** Frasi come «abbiamo fatto molti progressi» non bastano: quando necessario occorre poter accedere alle evidenze dichiarate e confrontarle con criteri di completamento e baseline.

## 6. Valutazione critica e dettagli da precisare

### 6.1 Cosa è risultato coerente nei test

- Il primo livello evita audit pesanti nei percorsi regolari.
- Il log distingue durata e produttività, senza attribuire alla durata il valore di prova di stallo.
- La verifica delle evidenze distingue attività dichiarate da risultati.
- Una fase in stallo può essere corretta senza richiamare impropriamente la MDM.
- Una transizione interna per completamento non richiede un routing globale.
- Trigger espliciti e vincoli critici restano prioritari rispetto al filtro di durata.

### 6.2 Limite rilevato — rilevazione tardiva degli stalli

Una fase potrebbe ripetere inutilmente una domanda già al turno 3, *prima* di superare la stima massima. Se il controller guarda **esclusivamente** al superamento dei turni, la rilevazione avverrebbe tardi.

**Precisazione proposta (NON APPROVATA):** mantenere il controllo leggero a ogni prompt, comprensivo di controlli minimi immediati su coerenza con richieste/decisioni già note e autorizzazioni. Riservare l'audit progressivo L1→L4 ai segnali di anomalia non ovvi o quantitativi. Ciò non comporta lettura dell'intero log a ogni turno.

### 6.3 Limite rilevato — significato delle stime

La dimensione della fase può cambiare legittimamente. Un rapporto come 7/4 è un segnale, ma non definisce da solo «eccessivo». In più, le microattività concorrenti possono produrre più eventi nello stesso turno.

**Precisazione proposta (NON APPROVATA):** usare per ogni fase una stima iniziale ragionata, distinguere turni pertinenti e passi agentici osservati, aggiornare in modo non distruttivo le previsioni e valutare lo scostamento anche rispetto al progresso dichiarato/riscontrato. Non introdurre una soglia universale prima di disporre di casi reali.

### 6.4 Limite rilevato — audit e log possono condividere lo stesso errore

Se è lo stesso assistente a condurre la fase, scrivere il log e interpretarlo, l'audit non è indipendente per definizione.

**Precisazione proposta (NON APPROVATA):** usare riferimenti a prodotti/decisioni verificabili, separare logicamente eventi della fase da osservazioni del controller, mantenere la possibilità di `!aw audit` manuale e distinguere sempre test concettuali da verifiche in esecuzione reale. Non postulare un agente supervisore indipendente già esistente.

## 7. Conclusioni e prossimo lavoro

**Esito del test simulato:** tre scenari trattabili dalla specifica approvata, senza necessità immediata di nuovi componenti o di routing continuo. **Non è prova di robustezza operativa**.

**Prossimo passo consigliato:** aggiungere, soltanto se approvate, le precisazioni del § 6 ai criteri del continuity controller; quindi descrivere un primo contratto concreto di `system-design` e testare su conversazioni realmente controllate il funzionamento di fase, log, audit e comando utente. Non iniziare la persistenza generale di `ai-work-state` prima di derivarne le necessità.

**Nessun file operativo nei repository `ai-workflow` o `ai-work-state` viene modificato da questo documento.**
