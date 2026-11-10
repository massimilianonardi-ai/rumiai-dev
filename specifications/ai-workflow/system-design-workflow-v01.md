# AI-Workflow — Workflow concreto `system-design` v01

**Data:** 10 novembre 2026  
**Stato:** **PROPOSTA OPERATIVA DA VALIDARE**; non è un workflow già installato o abilitato in `ai-workflow`.  
**Fondamenti approvati:** bootstrap universale in tre sezioni; MDM snella con `design` come famiglia; una sola fase di controllo per istanza di workflow principale; autonomia vincolata, criteri espliciti di completamento; controller di continuità e audit progressivo con log sintetico.  
**Specifiche di riferimento:** `ai-workflow-v03.md`, `mdm-routing-v02.md`, `continuity-audit-v02.md`, `conversation-identity.md`.  
**Bootstrap attualmente fissato:** `ai-workflow/bootstrap.md` alla revisione `c9d12ce28f9948fe48625777e4d691dd8b4d5221` (non attiva questo workflow).

## 1. Scopo, avvio e confini

**Obiettivo:** ottenere una progettazione di sistema coerente con obiettivi, vincoli e requisiti effettivamente confermati, mantenendo evidenze, decisioni e autorizzazioni distinguibili.

**Attivazione:**
1. In una nuova conversazione non esiste una fase predefinita. L'interpretazione contestuale e, quando necessario, la MDM individuano un task e selezionano un workflow, tra cui `system-design` per un obiettivo di progettazione.
2. Recuperare invece direttamente il task/workflow già esistente quando identificabile e pertinente; non usare la MDM solo perché cambia la conversazione.
3. Associata l'istanza al task, iniziare con `specification` salvo che esistano già prerequisiti e un avanzamento verificato che giustificano una diversa fase. Non considerare come nuove autorizzazioni i semplici suggerimenti del router.
4. La baseline del task conserva l'obiettivo e i vincoli fondamentali; le modifiche sostanziali richiedono revisioni autorizzate e non distruttive.

**Limite:** `system-design` non implementa, distribuisce o configura sistemi in produzione senza un nuovo percorso e le autorizzazioni necessarie. Può produrre documenti quando la scrittura del relativo artefatto è autorizzata.

## 2. Interfaccia universale delle fasi

Ogni fase di controllo dichiara in termini verificabili:
- **obiettivo** e prodotti attesi;
- **prerequisiti**;
- **comportamento operativo** e grado di autonomia consentito;
- **criteri di completamento** e relative evidenze;
- **transizioni previste** e loro gate;
- **interruzioni/rivalutazioni**.

A ogni checkpoint la fase espone inoltre, sul piano logico (senza imporre uno schema persistente):
- microattività corrente e risultato immediato atteso;
- stima iniziale di turni pertinenti con l'utente e conteggio osservato;
- stima iniziale di passi con agenti quando realmente pertinenti e conteggio osservato;
- ultimo progresso significativo oppure impedimento;
- eventuali revisione motivata delle stime, criteri soddisfatti, criteri ancora aperti e richieste di autorizzazione.

**Le stime sono contestuali:** non sono soglie universali o numeri prescritti dal workflow. L'assenza di agenti è diversa da un conteggio di passi non verificabile.

## 3. Fase `specification`

**Obiettivo.** Ricostruire ciò che il sistema deve fare, per chi, con quali vincoli, condizioni operative, criteri di accettazione e decisioni architetturalmente rilevanti.

**Prerequisiti.** Obiettivo iniziale identificabile e task pertinente; possono mancare dettagli, da acquisire progressivamente. Se l'obiettivo è ambiguo in modo sostanziale, chiarirlo prima di prendere decisioni irreversibili.

**Comportamento e autonomia:**
- porre domande mirate soltanto sui vuoti che incidono sulle scelte;
- cercare autonomamente documentazione e fatti verificabili entro strumenti e autorizzazioni disponibili;
- distinguere requisiti confermati, ipotesi, vincoli scoperti e proposte;
- predisporre alternative quando una scelta dell'utente è necessaria;
- registrare cambiamenti sostanziali e approvazioni esplicite;
- evitare cicli di chiarimenti, ripetizioni di domande già risolte e progettazione prematura su presupposti fragili.

**Evidenze/prodotti attesi:** requisiti funzionali e non funzionali pertinenti; vincoli e contesto operativo; decisioni con la loro origine; questioni aperte distinguendo quelle bloccanti da quelle rinviabili; criteri di accettazione verificabili.

**Completamento (tutti i criteri applicabili):**
1. Obiettivo e vincoli di perimetro risultano coerenti con la baseline del task.
2. Sono disponibili requisiti sufficienti a valutare alternative architetturali senza inventare decisioni sostanziali.
3. Le scelte che richiedono approvazione sono state esplicitamente autorizzate; quelle non bloccanti sono annotate come aperte, con la conseguenza sulla progettazione.
4. Le informazioni esterne decisive sono supportate da fonti accessibili o dichiarate come ipotesi/limiti; nessun presupposto non verificato viene fatto passare per certo.
5. Il risultato è abbastanza tracciabile da permettere al workflow controller una verifica del gate di passaggio.

**Transizione ordinaria:** `specification → architecture` quando i criteri sono soddisfatti. Non è necessario un ulteriore «procedi» se la transizione è già autorizzata e non introduce decisioni nuove. Se manca un'approvazione sostanziale, la fase resta in attesa o lavora sulle parti indipendenti.

**Interruzioni:** richiesta esplicita dell'utente, perdita di pertinenza, nuova baseline che cambia l'obiettivo, mancanza di fonti indispensabili, autorizzazione necessaria non disponibile.

## 4. Fase `architecture`

**Obiettivo.** Progettare e verificare una proposta architetturale conforme a specifiche e vincoli approvati.

**Prerequisiti.** Completamento verificato della fase `specification` o disponibilità equivalente di specifiche/decisioni già accertate; permessi per eventuali letture e verifiche.

**Comportamento e autonomia:**
- elaborare alternative rilevanti, selezionare e giustificare una proposta nel perimetro autorizzato;
- verificare requisiti, vincoli operativi, dipendenze e compromessi;
- svolgere ricerche o prove documentali come sotto-operazioni senza sostituire il workflow;
- non trasformare la facoltà di disegnare l'architettura in consenso per implementazione, modifiche esterne o deployment;
- sottoporre all'utente solo le decisioni sostanziali non già autorizzate.

**Evidenze/prodotti attesi:** descrizione dei componenti e delle interfacce, alternative e motivazioni di scelta, mappatura requisiti→soluzione, rischi/limiti e verifiche, decisioni approvate e decisioni ancora aperte; piano di verifica della progettazione quando pertinente.

**Completamento (tutti i criteri applicabili):**
1. Esiste una proposta sufficientemente completa da essere esaminata e non soltanto un elenco di idee.
2. Ogni requisito critico è coperto o una lacuna è dichiarata come impedimento; assenza di contraddizioni sostanziali note non risolte.
3. Le verifiche previste per il livello di progettazione sono documentate; ipotesi e risultati non verificati sono dichiarati.
4. Tutte le decisioni sostanziali che eccedono l'autonomia sono sottoposte all'utente; quelle bloccanti devono essere risolte prima di certificare il completamento.
5. Risultato e prossimo passo sono chiari. **«Architettura pronta per revisione» non equivale ad «architettura approvata dall'utente»**: registrare esplicitamente la distinzione.

**Transizione ordinaria:** completamento del workflow di progettazione con risultato verificabile, eventualmente in attesa di revisione/approvazione finale se richiesta dai criteri del task. Non passare automaticamente a `develop` o `operate`: servono nuovo percorso/contesto e autorizzazioni appropriate.

**Ritorno interno a `specification`:** se una modifica ai requisiti rende invalida una decisione architetturale, registrare quali elaborati sono impattati; rivalutare i requisiti e gli eventuali gate, quindi riprendere `architecture`. Se la modifica altera l'obiettivo fondamentale serve autorizzazione per revisione della baseline. Il ritorno interno non richiede di per sé MDM.

## 5. Variante composita `iterative-design` — PROPOSTA, NON DEFAULT

Quando la natura del task giustifica una progettazione agile, l'istanza di workflow può prevedere una **fase di controllo unica** denominata `iterative-design`, che coordina microattività di specifiche e architettura anche concorrenti.

**Ingresso:** scelta esplicita del percorso iterativo e obiettivo/task identificabile; il controller non attiva implicitamente due fasi indipendenti.  
**Comportamento:** le modifiche a un requisito invalidano o rendono da riesaminare solo gli elementi architetturali dipendenti; il log registra impatto, riapertura delle microattività e nuova evidenza.  
**Completamento:** soddisfare insieme i requisiti di sufficienza/approvazione delle specifiche e di coerenza/verifica architetturale, con i medesimi confini di autorizzazione.  
**Transizione:** chiusura della progettazione o ritorno interno alla fase composita se una revisione autorizzata riapre le verifiche.  
**Limite:** evitare di predefinire ogni combinazione di fasi; introdurre varianti solo quando le regole di coordinamento sono realmente differenti e giustificate.

La variante è da validare mediante casi concreti prima di essere considerata modalità operativa.

## 6. Continuità e audit dentro `system-design`

Ogni prompt pertinente esegue il **controllo leggero** previsto da `continuity-audit-v02.md`:
- riconoscere risposta, correzione, conversazione laterale, sotto-operazione e nuovo task;
- verificare ripetizioni evidenti, incompatibilità con decisioni note e richieste di azioni non autorizzate, **anche prima** dello scostamento temporale;
- confrontare stime e conteggi pertinenti alla fase, attivando L1–L4 quando necessario;
- per un audit richiesto esplicitamente, esaminare andamento ed evidenze indipendentemente dal superamento delle stime;
- verificare log e prodotti realmente accessibili: il log non certifica da sé la bontà del risultato.

**Esiti:** continuare, correggere internamente, sospendere con punto di ripresa oppure valutare MDM se il percorso non è più appropriato. Una durata maggiore del previsto, spiegata da risultati verificabili, non implica uno stallo.

## 7. Log e progressi — interfaccia logica

**Eventi significativi:** selezione del workflow, entrata/uscita di fase, microattività rilevante, progresso effettivo, impedimento, decisione/approvazione, modifica delle stime, audit e suo esito, transizione o ritorno di fase.

Il log e lo stato sono distinti: il primo conserva la sequenza degli eventi con riferimenti ai prodotti/decisioni; il secondo indica quale fase è attiva, quali controlli sono ancora aperti e quale microattività è in corso. Un messaggio laterale senza conseguenze non crea una transizione né una fittizia «prova di progresso».

**Informazioni necessarie, senza definire file:** task, fase, checkpoint temporale, microattività, stime iniziali/attuali e contatori osservati, evento, decisioni con evidenze, eventuali invalidazioni e motivo, prossimo passo consentito. Eventi o riferimenti inesistenti non devono essere inventati.

## 8. Mini-casi di verifica concettuale

| Caso | Esito corretto |
| --- | --- |
| `specification` completa e approvazioni necessarie disponibili | Passaggio a `architecture` senza MDM |
| Ricerca di una tecnologia durante `specification` | Sotto-operazione; mantenere fase e task |
| Domanda già chiarita ripetuta prima della soglia | Correzione precoce mediante controllo leggero |
| `architecture` più lunga del previsto con verifiche concrete | Continuare, registrare revisione motivata delle stime |
| Architettura contraddice un requisito approvato | Riallineare l'architettura, oppure riaprire `specification` se il requisito va rivalutato |
| Discussione tecnica piacevole ma non operativa | Rispondere senza revisioni implicite di baseline/fase |
| Utente modifica obiettivo fondamentale | Fermare modifiche sostanziali non autorizzate; valutare revisione di baseline o nuovo task; MDM se nuovo percorso |
| `!aw audit` per task identificabile | Audit con evidenze, senza avviare un nuovo workflow |
| Richiesta «implementa ora» mentre è attiva `architecture` | Non dedurre autorizzazione dalla fase; valutare nuovo percorso e permessi espliciti |

Questi test sono **esempi progettuali**, non test svolti su una implementazione.

## 9. Aperture residue e confini di questa versione

**Da validare:** requisiti minimi specifici dei diversi tipi di sistema, scelta del percorso sequenziale rispetto a quello iterativo, definizione operativa dei conteggi, trattamento dei task multipli e delle dipendenze inter-task, descrizione formale del workflow e reali scenari di test. La condizione dell'utente (attenzione, stanchezza, digressioni) è un requisito da approfondire senza inferenze arbitrarie o revoche paternalistiche.

**Non implementato:** nessun file operativo in `ai-workflow` e nessuna struttura di persistenza in `ai-work-state` è stata modificata. Il documento specifica i comportamenti per i test successivi e per la futura integrazione in inglese.
