# AI-Workflow — Simulazione end-to-end di `system-design` v01

**Data:** 10 novembre 2026  
**Stato:** **SIMULAZIONE CONCETTUALE**, non test del software in esecuzione. Le decisioni già approvate sono richiamate come tali; le precisazioni individuate qui sono **PROPOSTE DA VALIDARE**.  
**Scopo:** seguire il percorso completo dall'attivazione tramite MDM al completamento del workflow, con una revisione dei requisiti durante `architecture`, audit, log e recupero della fase corretta.  
**Fonti di progetto:** `mdm-routing-v02.md`, `system-design-workflow-v01.md`, `continuity-audit-v02.md`, `conversation-identity.md`.  
**Bootstrap consultato:** `massimilianonardi-ai/ai-workflow/bootstrap.md` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`; non implementa ancora il nuovo workflow.  
**Repository:** `rumiai-dev/specifications/ai-workflow/`. Nessuna modifica ai repository operativi `ai-workflow` o `ai-work-state`.

## 1. Ipotesi e confini del test

La richiesta iniziale simulata è: «Voglio progettare un sistema interno per cercare nella documentazione tecnica, mantenendo i dati in azienda e rispettando gli accessi degli utenti».

Nella simulazione:
- **Task fittizio T-A:** progettazione del motore di ricerca documentale.
- **Baseline iniziale fittizia:** ricerca interna di documentazione tecnica, dati on-premises e rispetto dei permessi utente. È volutamente distinta dai successivi dettagli funzionali e prestazionali.
- **MDM proposta e approvata come design:** `operation: design`, `input: text`, `output: document`; `effects: read` per le ricerche e `artifact_write` solo quando autorizzato. La MDM seleziona concettualmente `system-design`; la revisione fissata del repository non dispone di questa nuova attivazione.
- **Workflow sequenziale iniziale:** `specification` → `architecture`; non è attiva la variante `iterative-design`.
- **Evidenze fittizie E1–E10:** rappresentano documenti, conferme e verifiche immaginati nello scenario. **Nessuna E1–E10 esiste come artefatto reale o prova di tool eseguito.**
- Ogni turno pertinente comprende una richiesta dell'utente e l'eventuale risposta dell'assistente; i conteggi sono illustrativi. Nessun agente esterno viene eseguito: i passi agentici rimangono `not applicable`, non valori inventati.
- L'esempio presume che i documenti e le autorizzazioni descritte come presenti nello scenario siano effettivamente verificabili **nel mondo simulato**; una futura esecuzione reale dovrà verificare tali presupposti.

## 2. Traccia completa

| Passo | Prompt/evento simulato | Controllo e comportamento previsto | Fase di controllo dopo il passo | Log/evidenza fittizia |
| --- | --- | --- | --- | --- |
| **P1** | «Voglio progettare un motore di ricerca per documentazione interna; niente cloud, permessi utenti». | Nuovo task T-A identificato; MDM `design` → `system-design`. Nessuna fase precedente da continuare. | `specification` | L1: avvio, baseline fittizia E1 |
| **P2** | «100.000 documenti, aggiornamento giornaliero, risposta di ricerca entro due secondi». | Requisiti di capacità, aggiornamento e latenza registrati come proposte da consolidare. | `specification` | L2: requisiti candidati E2 |
| **P3** | «Confronta per questi requisiti ricerca full-text e semantica». | Ricerca **subordinata**; non nasce un altro workflow e non viene richiamata la MDM. | `specification` | L3: confronto ipotetico E3, ipotesi tecniche separate |
| **P4** | «Confermo i requisiti; la ricerca per testo è sufficiente nella prima versione». | Verifica di sufficienza, approvazioni e criteri di fase. Se soddisfatti, transizione interna senza nuovo comando «procedi». | `architecture` | L4: conferma E4; chiusura `specification` |
| **P5** | L'assistente propone un indice full-text aggiornato in batch giornaliero e controllo degli accessi in ricerca. | Proposta architetturale in perimetro; non è deployment e non è ancora architettura finale. | `architecture` | L5: bozza architetturale E5 |
| **P6** | «Come si distinguono ricerca semantica e ricerca lessicale, in generale?» | Discussione tecnica laterale: rispondere, senza assumere che l'utente abbia cambiato i requisiti o aperto un nuovo task. | `architecture` | Nessuna falsa transizione; turno non contato automaticamente come avanzamento della fase |
| **P7** | «Cambio requisito: ogni modifica documentale deve essere ricercabile entro cinque minuti, non più il giorno dopo». | **Trigger immediato**: riconoscere una modifica esplicita anche senza superamento delle stime. Valutare impatto: invalida aggiornamento batch della bozza E5. Poiché l'obiettivo della baseline rimane invariato, aggiornare le specifiche con autorizzazione espressa, non automaticamente la baseline. | `specification` | L6: revisione requisito E6; architettura batch marcata da riesaminare |
| **P8** | «Le sorgenti emettono eventi di modifica; ecco il contratto API». | Nello scenario il contratto ipotetico E7 è consultabile. Verificare il requisito, registrare dipendenze e possibili rischi; se il contratto non è disponibile realmente, mantenere l'ipotesi come non verificata. | `specification` | L7: contratto ipotetico E7, nuova valutazione di fattibilità |
| **P9** | «Approvo le specifiche aggiornate». | Verifica del gate riaperto; nuova transizione interna a `architecture`. Non cancellare l'approvazione originaria né la storia delle modifiche. | `architecture` | L8: conferma E8, prerequisiti ripristinati |
| **P10** | L'assistente propone indicizzazione a eventi con recupero degli eventi persi e presenta tracciamento requisiti → componenti. | Riutilizzare le parti non invalidate della precedente architettura (es. ricerca full-text e controllo accessi) e rifare le parti impattate. Distinguere analisi documentale da test prestazionali non svolti. | `architecture` | L9: architettura revisionata E9, verifiche e limiti dichiarati |
| **P11** | «Esegui un audit del task» (in futuro tramite `!aw audit`). | Audit **esplicito** anche senza stime superate. Verifica storia E4→E6→E8, invalidazione E5, coerenza di E9; identifica eventuali impedimenti reali. La sintassi `!aw audit` non è ancora attiva nel vecchio router. | `architecture` | L10: esito audit ipotetico; nessun re-routing |
| **P12** | «Approvo il progetto architetturale e concludiamo la progettazione». | Se tutti i criteri applicabili risultano soddisfatti, registrare approvazione, chiudere la fase e concludere **solo** il workflow di progettazione. Nessuna attivazione automatica di sviluppo o produzione. | nessuna fase attiva; workflow completato | L11: approvazione E10 e chiusura; checkpoint finale |

La traccia rende visibili i tre momenti distinti: **routing iniziale** in P1, **transizioni ordinarie** in P4/P9, **ritorno interno** in P7. Né una ricerca subordinata né un'interruzione interna richiedono da sole una nuova MDM.

## 3. Contatori, microattività e audit

**Stime puramente illustrative:**
- Episodio iniziale `specification`: 2–4 turni pertinenti; P1–P4 = 4.
- Primo episodio `architecture`: 2–4 turni previsti; P5 = 1, poi P7 determina il ritorno.
- Revisione `specification`: nuova previsione contestuale 1–3 turni pertinenti; P7–P9 = 3.
- Ripresa `architecture`: previsione aggiornata motivatamente in rapporto al lavoro restante, P10–P12; la richiesta di audit P11 non va automaticamente interpretata come turno di progresso produttivo.

Al momento di P7, la **microattività** non può restare «completare l'indice batch» senza rettifica: diventa «valutare il nuovo vincolo di aggiornamento e le dipendenze architetturali». L'**ultimo progresso** o impedimento deve essere riferito a questo lavoro, non alla semplice lunghezza della risposta.

Il controllo leggero a P7 rileva immediatamente il cambiamento esplicito, **anche se P5 era ben al di sotto della stima massima**. Questo conferma l'utilità della precisazione introdotta in `continuity-audit-v02.md`.

L'audit P11 deve distinguere:
1. **durata**: la storia attraversa più episodi di fase per una variazione legittima;
2. **produttività**: E6–E9 aggiungono informazioni o elaborati pertinenti, se accessibili;
3. **coerenza**: l'architettura batch E5 non è più utilizzabile senza modifica;
4. **autorizzazione**: E8 approva il nuovo requisito, E10 — solo a P12 — approva il progetto finale;
5. **completezza**: le verifiche prestazionali non eseguite vanno dichiarate tali, senza fingere un sistema funzionante.

**Esito dell'audit ipotetico P11:** continuare, con possibile correzione del documento architetturale se permangono riferimenti a un indice esclusivamente giornaliero. Non ci sono elementi sufficienti per sospendere o richiamare la MDM solo perché la sequenza è più lunga della stima originaria.

## 4. Rispetto dell'invariante «una fase di controllo»

| Intervallo | Unica fase attiva |
| --- | --- |
| Prima di P1 | Nessuna |
| P1–P4 (fino al gate) | `specification` |
| Dopo P4 fino al cambio in P7 | `architecture` |
| P7–P9 (fino al nuovo gate) | `specification` |
| Dopo P9 fino alla chiusura in P12 | `architecture` |
| Dopo P12 | Nessuna fase attiva: workflow concluso |

Un ritorno non crea **due fasi simultanee** e non annulla retroattivamente il completamento storico di `specification` a P4. Crea una nuova esigenza di verifica: il completamento precedente era valido sulla versione precedente dei requisiti. La nuova validità va accertata di nuovo.

## 5. Variante `iterative-design` — confronto senza attivazione

Se in origine fosse stata **selezionata esplicitamente** la variante agile, lo stesso cambiamento P7 avverrebbe **dentro un'unica fase di controllo `iterative-design`**, con almeno due microattività coordinate: requisiti e architettura. La modifica E6 renderebbe da riesaminare la microattività di indicizzazione, non necessariamente quella di autorizzazione o ricerca full-text.

**Pro:** meno transizioni; coordinamento delle dipendenze in una singola fase.  
**Contro:** richiede un contratto di completamento congiunto e una mappa chiara delle dipendenze; il rischio di dichiarare «fatto» un blocco invalido resta, se il log non traccia revisioni e validità.

Questo confronto è **progettuale** e non approva automaticamente la variante come comportamento predefinito.

## 6. Valutazione: ciò che il test sostiene e ciò che non dimostra

**Coerente nella simulazione:**
- MDM invocata una sola volta al nuovo avvio; nessuna riclassificazione durante ricerche subordinate o transizioni previste.
- Workflow associato al task e non globalmente alla conversazione.
- Fase unica mantenuta anche con ritorno a `specification`.
- Cambio di requisito individuato subito e distinto da un nuovo obiettivo fondamentale.
- Log utile per ricostruire quale requisito e quale elaborato sono stati invalidati.
- Chiusura della progettazione separata da esecuzione/deployment; approvazione finale diversa da «pronto per revisione».

**NON dimostrato:** capacità reale del modello di riconoscere sempre la pertinenza, trovare le dipendenze, misurare progressi e contatori, persistere gli eventi senza perdita, gestire correttamente più task o applicare l'audit automaticamente. I riferimenti E1–E10 e i log L1–L11 sono **simulati**, non prove di strumenti, documenti o API.

## 7. Punti critici e precisazioni da discutere — NON APPROVATE

**P-1 — Versione di validità dei risultati.** Una fase può essere stata completata correttamente rispetto ai requisiti allora vigenti, ma una revisione successiva può invalidare i risultati che dipendevano da quei requisiti. Occorre conservare l'evento di completamento originale e segnalare quali risultati necessitano di nuova verifica. Evitare sia la cancellazione storica sia la falsa validità corrente.

**P-2 — Ritorno alla fase vs correzione interna.** Non ogni nuovo requisito richiede una transizione indietro. Se il requisito è già approvato e la modifica incide solo su una scelta architetturale, può bastare correggere `architecture`. Il ritorno a `specification` è appropriato quando occorre riaprire il suo gate: precisare regola e soglia semantica, non quantitativa.

**P-3 — Conteggi per episodio e per fase.** Un ritorno produce più episodi della stessa fase. Il continuity controller deve vedere sia le stime di episodio sia la storia complessiva per evitare che un ritorno azzeri apparentemente progressi o nasconda stalli. **Non** è ancora un campo YAML approvato.

**P-4 — Approvazioni contestuali.** L'approvazione del nuovo requisito (P9) non è automaticamente approvazione dell'architettura (P12). Le approvazioni sono riferite a contenuto e versione realmente presentati; un generico «procedi» va interpretato entro il perimetro autorizzato.

**P-5 — Evidenze decisive.** Prima di chiudere il workflow, documentare chiaramente le verifiche realmente svolte e quelle soltanto previste. Una struttura plausibile non è prova della prestazione dichiarata. Se una verifica decisiva manca, occorre un impedimento esplicito, non un'approvazione fittizia.

Questi punti circoscritti **non** richiedono un nuovo componente o una modifica immediata della MDM. Possono diventare test di accettazione della prima specifica operativa.

## 8. Prossimo passo suggerito

Convalidare P-1…P-5 come regole del workflow o limitarne il perimetro; quindi derivare da questa traccia **solo i dati logici effettivamente necessari** per riprendere fase, versione dei requisiti, validità delle evidenze, stime e checkpoint. Rinviare ancora le decisioni sui percorsi fisici di `ai-work-state` finché i requisiti logici non sono chiariti.

Successivamente preparare una verifica controllata dell'implementazione alpha su una conversazione reale, includendo comando `!aw route`, comando `!aw audit` e finalizzazione universale `1 → 2 → 3`. Il nuovo bootstrap **non è attivo** soltanto perché questa simulazione è stata pubblicata.
