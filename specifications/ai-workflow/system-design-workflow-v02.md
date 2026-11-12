# AI-Workflow — Workflow `system-design` v02

**Data:** 10 novembre 2026  
**Stato:** specifica di progettazione, **non implementata**. Le regole P-1…P-5, identificate nella simulazione end-to-end, sono **APPROVATE** dall'utente; la struttura concreta di `system-design` resta un primo workflow pilota da verificare in esecuzione reale.  
**Evoluzione:** sostituisce come riferimento progettuale `system-design-workflow-v01.md` senza modificarlo; consolida `system-design-end-to-end-simulation-v01.md`.  
**Documenti collegati:** `mdm-routing-v02.md`, `continuity-audit-v02.md`, `conversation-identity.md`, `ai-workflow-v03.md`.  
**Bootstrap attuale di riferimento:** `ai-workflow/bootstrap.md` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221`, che non contiene ancora il nuovo workflow.  
**Destinazione:** `rumiai-dev/specifications/ai-workflow/`, documentazione italiana; non pubblicare come regola operativa in `ai-workflow` senza accordo.

## 1. Obiettivo e attivazione

Il workflow `system-design` guida la progettazione di un sistema dalle specifiche a un'architettura coerente, valutabile e tracciabile. Non autorizza implicitamente implementazione, modifiche di ambienti, deployment o approvazione di decisioni sostanziali.

L'istanza principale appartiene al **task**, non alla conversazione. In una nuova conversazione **non esiste una fase predefinita**. L'interpretazione e, quando utile, la **MDM** selezionano `system-design`; quando il task è già identificato e il suo workflow è pertinente, recuperare la fase corrente senza re-routing. È prevista **una sola fase di controllo attiva per istanza principale**, anche quando coordina microattività concorrenti.

La baseline del task conserva scopo e vincoli fondamentali; soltanto revisioni esplicitamente autorizzate possono modificarla, senza cancellare la versione originaria.

## 2. Contratto esterno di ogni fase

Ogni definizione di fase dichiara:

- **Obiettivo e risultati attesi**.
- **Prerequisiti** e condizioni di ingresso.
- **Comportamento e autonomia**: attività consentite, decisioni riservate all'utente e azioni vietate o fuori ambito.
- **Evidenze verificabili**: risultati richiesti per valutare la fase.
- **Criteri di completamento** e possibili impedimenti.
- **Transizioni consentite** e relativi gate di approvazione.
- **Condizioni di interruzione e rivalutazione**.

L'istanza in esecuzione espone sul piano logico: fase corrente; microattività corrente con risultato immediato atteso; stima iniziale e corrente dei **turni pertinenti con l'utente** e loro conteggi; quando applicabile stima e conteggio dei **passi agentici effettivamente osservati**; ultimo progresso verificabile o impedimento; criteri ancora aperti e prossimo passo autorizzato.

Le stime sono contestuali, non soglie universali di sospensione. Non attribuire passi ad agenti inesistenti. Le conversazioni laterali non aumentano automaticamente i contatori del lavoro di fase.

## 3. Fase `specification`

**Obiettivo:** rendere sufficientemente chiari obiettivo, requisiti, contesto operativo, vincoli, criteri di accettazione e decisioni sostanziali, senza inventare risposte non fornite.

**Prerequisiti:** task e obiettivo identificabili; l'eventuale ambiguità sostanziale va chiarita prima di decisioni che la presuppongono.

**Comportamento:** porre solo domande pertinenti, riutilizzare risposte e decisioni già disponibili, verificare autonomamente fatti accessibili, distinguere conferme da ipotesi, identificare scelte che richiedono l'utente. Ricerche tecniche necessarie sono sotto-operazioni, non un nuovo workflow.

**Risultati/evidenze:** requisiti funzionali e non funzionali; vincoli; decisioni con fonte e contesto; dubbi bloccanti vs rinviabili; criteri di accettazione; fonti dei fatti tecnici decisivi.

**Criteri di completamento (tutti quelli applicabili):**
1. Scopo e vincoli sono coerenti con la baseline vigente.
2. I requisiti bastano a elaborare alternative architetturali senza assumere decisioni sostanziali inesistenti.
3. Le decisioni necessarie sono esplicitamente autorizzate; le questioni non bloccanti sono segnate come aperte.
4. Evidenze importanti sono disponibili e verificabili, oppure si dichiarano limiti e ipotesi senza attribuire loro certezza.
5. Il gate di ingresso in `architecture` è effettivamente verificabile.

**Transizione:** `specification → architecture` quando il completamento e le autorizzazioni richieste sono soddisfatti. Non chiedere «procedi» se il passaggio era già previsto e autorizzato. Non considerare un'accettazione generica come approvazione di una nuova scelta sostanziale.

## 4. Fase `architecture`

**Obiettivo:** produrre una proposta architetturale coerente con le specifiche correnti, con decisioni e limiti tracciati.

**Prerequisiti:** gate di `specification` soddisfatto oppure equivalenti specifiche già verificate.

**Comportamento:** analizzare alternative, progettare componenti/interfacce/dipendenze, confrontare requisiti e soluzioni, verificare vincoli e compromessi; eseguire ricerche subordinate senza re-routing; coinvolgere l'utente per decisioni non autorizzate. Non implementare o distribuire soltanto perché la progettazione è progredita.

**Risultati/evidenze:** proposta completa e comprensibile; motivazioni delle scelte; tracciamento requisiti → componenti; rischi e verifiche; decisioni approvate vs aperte; indicazione di quanto è stato **progettato**, **analizzato** e **effettivamente verificato**.

**Criteri di completamento (tutti quelli applicabili):**
1. È disponibile una proposta esaminabile, non soltanto un elenco di idee.
2. Requisiti critici coperti o impedimenti espliciti; assenza di contraddizioni sostanziali note non risolte.
3. Sono documentate le verifiche davvero svolte e le verifiche ancora previste.
4. Decisioni sostanziali bloccanti fuori autonomia risolte mediante approvazione pertinente e verificabile.
5. È chiaro se l'elaborato è «pronto per revisione» oppure «approvato» dall'utente, e se il task richiede un gate finale di approvazione.

**Uscita:** chiusura del workflow `system-design` o attesa di revisione finale, secondo il contratto del task. Non attivare automaticamente `develop` o `operate`.

## 5. Regole P-1…P-5 approvate dopo la simulazione

### P-1. Validità dei risultati rispetto alle revisioni — APPROVATA

Ogni risultato rilevante è valido **rispetto ai requisiti, alle decisioni e alle evidenze** sui quali si fonda. Se uno di essi cambia, identificare i risultati dipendenti e marcarli da rivalutare, senza cancellare il risultato storico o riscrivere retroattivamente un precedente completamento. Un'elaborazione convalidata in passato non è automaticamente valida nel contesto nuovo.

Non occorre introdurre ora un formato di versionamento fisico: serve conservare il rapporto logico fra revisione, dipendenze, risultati e validità corrente.

### P-2. Correzione interna vs ritorno di fase — APPROVATA

**Non ogni modifica di requisito comporta il ritorno a `specification`.**

- Se il requisito modificato è già chiaro, approvato e verificabile, e serve solo modificare l'architettura, **restare in `architecture`**, correggendo i risultati interessati.
- Se la modifica riapre prerequisiti, decisioni, ambiguità o criteri di completamento di `specification`, **tornare a `specification`**, verificare nuovamente il gate e poi riprendere `architecture`.
- Se si modifica lo scopo fondamentale, non trattarlo come un ordinario cambio di fase: serve revisione esplicita della baseline o riconoscimento di un altro task/percorso, con MDM se necessario.

Il ritorno è una **transizione interna al workflow**, non un re-routing automatico.

### P-3. Conteggi per episodio e storia complessiva — APPROVATA

Un ritorno crea un **nuovo episodio** della stessa fase. Distinguere logicamente:
- stime, turni, passi agentici, microattività e risultati del singolo episodio;
- storia complessiva della fase e del task, inclusi episodi precedenti, ritorni, revisioni di stima e audit.

Il nuovo episodio non cancella né azzera la storia del lavoro, e non deve nascondere cicli improduttivi. Non è ancora stabilito uno specifico nome di campo, file o contatore YAML.

### P-4. Approvazioni contestuali — APPROVATA

Le approvazioni si riferiscono **alla decisione, al contenuto e alla versione concretamente presentati**, non indiscriminatamente a tutto il task. Approvare un requisito non equivale ad approvare un'architettura; approvare l'architettura non equivale ad autorizzare il deployment. Un «procedi» autorizza soltanto attività già comprese nel contesto e nell'autonomia consentita.

Quando il contenuto approvato cambia materialmente, riesaminare le approvazioni dipendenti. Non inventare consenso implicito.

### P-5. Evidenze decisive prima della chiusura — APPROVATA

Prima di dichiarare la fase o il workflow completati, distinguere:
- verifiche **effettivamente eseguite** con evidenze accessibili;
- analisi documentali, calcoli o argomentazioni;
- verifiche **pianificate ma non eseguite**;
- impedimenti, ipotesi e limiti irrisolti.

Una soluzione plausibile **non prova** prestazioni o funzionamento reali. Se manca una verifica che il contratto rende decisiva, non presentare la chiusura come verificata: dichiarare il blocco o la limitazione e chiedere l'eventuale decisione necessaria.

## 6. Continuità, audit e log

A ogni prompt pertinente, il continuity controller svolge il **controllo leggero** previsto in `continuity-audit-v02.md`: pertinenza, autorizzazioni, anomalie evidenti (incluse domande già risolte) e stime. Un cambiamento esplicito dei requisiti viene valutato subito, anche se la fase è ancora entro le stime.

Se i segnali lo giustificano, audit progressivo:
1. scostamento significativo dalle stime;
2. verifica della produttività nel log;
3. verifica dei risultati, delle ripetizioni e delle evidenze;
4. riesame di baseline, autorizzazioni, pertinenza e workflow se necessario.

L'utente può chiedere l'audit esplicitamente, senza attendere gli scostamenti; `!aw audit [--context ID]` è **sintassi candidata non ancora implementata**.

**Esiti:** continuare, correggere internamente, sospendere oppure rivalutare la MDM se il percorso non è più appropriato. La fase segnala il completamento; il workflow controller governa le transizioni previste. Un errore locale non implica automaticamente re-routing.

Il log sintetico, non distruttivo, conserva almeno gli **eventi significativi** (avvio/uscita fase, progressi, impedimenti, decisioni, modifiche, revisione stime, audit ed esiti, ritorni e invalidazioni) e riferimenti ad evidenze effettivamente accessibili. Distinguere eventi dichiarati dalla fase dalle valutazioni del controller: non dichiarare indipendenza inesistente quando lo stesso modello svolge entrambi i ruoli.

## 7. Variante `iterative-design` — NON ANCORA VALIDATA COME DEFAULT

Quando il workflow lo prevede esplicitamente, una sola **fase composita di controllo** può coordinare attività di specifiche e architettura concorrenti. Una modifica a un requisito riapre le microattività dipendenti, non obbligatoriamente l'intera fase. Il completamento richiede congiuntamente sufficienza/approvazione delle specifiche e coerenza/verifica dell'architettura.

La variante non impone più fasi di controllo simultanee. Non generare tutte le possibili fasi composite a priori. Resta un'opzione progettuale da collaudare, non il comportamento predefinito.

## 8. Scenari minimi di accettazione per il workflow

| Scenario | Risultato atteso |
| --- | --- |
| Nuovo task di progettazione | MDM seleziona `system-design`, fase `specification` |
| Requisiti sufficienti e approvati | Passaggio interno a `architecture` senza nuovo routing |
| Ricerca tecnica durante la fase | Sotto-operazione senza sostituire il workflow |
| Requisito modificato ma già chiaro/approvato | Correzione in `architecture` se il gate di `specification` rimane valido |
| Requisito modificato con decisioni o prerequisiti da riaprire | Ritorno a `specification`, nuovo episodio, poi ripresa dell'architettura |
| Revisione invalida una parte del progetto | Conservare lo storico e segnare i risultati da verificare, senza cancellarli |
| Lunga fase produttiva | Audit con evidenze: possibile prosecuzione, non arresto automatico |
| Domanda già risolta ripetuta | Correzione precoce senza attendere scostamento quantitativo |
| Discussione tecnica laterale | Nessuna modifica automatica di task, baseline o fase |
| Richiesta `!aw audit` | Audit su task pertinente senza autorizzare nuove azioni |
| Approvazione del requisito, ma non dell'architettura | Non certificare un'approvazione architetturale |
| Architettura plausibile, test prestazionali mancanti | Non dichiarare verificati i test; completare solo se il contratto non li richiede o la limitazione è accettata esplicitamente |
| Richiesta di implementazione | Non dedurre permesso dal workflow di progettazione; rivalutare percorso e autorizzazioni |

I casi sono criteri per test futuri: **non sono test operativi già eseguiti**.

## 9. Perimetro ancora aperto

La progettazione concettuale di `system-design` è sufficientemente definita per un **pilota controllato**, non per dichiarare un sistema robusto. Prima di attivarlo sono ancora da verificare: conversione in regole eseguibili da Chat/Work/Codex secondo capacità reali; contratto minimo di persistenza e gestione errori; integrazione del bootstrap universale; test di routing, comandi, audit, recupero task, revisioni, autorizzazioni e finalizzazione.

Non sono approvati in questo documento: schema YAML fisico, organizzazione definitiva di `ai-work-state` al di fuori di `conversations/`, meccanismi di atomicità, soglie universali, attivazione di workflow concorrenti multi-task, né modifiche ai repository operativi.

**Nessuna modifica operativa a `ai-workflow` o `ai-work-state` viene autorizzata da questa pubblicazione.**
