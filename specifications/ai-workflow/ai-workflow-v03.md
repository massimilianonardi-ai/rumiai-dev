# AI-Workflow — Decisioni architetturali v0.3

**Data:** 10 novembre 2026  
**Stato:** riepilogo cumulativo delle decisioni approvate e delle proposte ancora da validare; architettura e attivazione ancora in progettazione  
**Evoluzione:** aggiorna `ai-workflow-v02.md`, conservando tutte le scelte precedenti; integra l’approvazione della specifica delle conversazioni, la regola `sync = pending`, la pubblicazione nel repository e la nuova proposta di routing orientato a workflow e fasi. Le proposte della sezione 22 NON sono ancora decisioni approvate.  
**Ambito:** bootstrap, continuità delle conversazioni, stato e orchestrazione dei workflow di AI-Workflow, progetto sperimentale indipendente.

> **Legenda:** **APPROVATO** = decisione espressamente concordata; **PRINCIPIO CONCORDATO / DA DETTAGLIARE** = direzione condivisa che richiede una specifica; **PROPOSTA** = ipotesi non ancora approvata; **APERTO** = decisione da prendere. Alcune sezioni storiche della v02 usano ancora espressioni come «da definire»: per lo stato più recente prevalgono le sezioni 18–24 e la sezione 15 aggiornata.

> **Nota importante:** il bootstrap pubblicato su `main` è ancora la precedente implementazione in otto punti, non il nuovo bootstrap in tre sezioni. Il documento `doc/conversation-identity.md` è stato pubblicato in inglese, ma il nuovo protocollo non è ancora attivo.

## 1. Finalità dell'architettura — APPROVATA

AI-Workflow deve consentire a un assistente di gestire richieste semplici e attività complesse **senza perdere l'identità dei task né alterarne gradualmente gli obiettivi**.

I problemi che il progetto intende risolvere sono:

- interpretazioni scorrette o incomplete delle richieste iniziali;
- decisioni di prodotto, infrastruttura e architettura affrontate quando è già stato sviluppato molto lavoro;
- importazione di informazioni vere, ma relative a un altro task, ambiente o progetto;
- deriva progressiva dall'obiettivo iniziale attraverso molti prompt e conversazioni;
- perdita della cronologia delle decisioni, delle correzioni e delle alternative scartate;
- continue richieste di «procedi», scarsa autonomia esecutiva e cicli improduttivi di correzione;
- confusione tra test o documenti prodotti e risultato operativo effettivamente richiesto;
- valutazioni che giudicano corretti lavori tecnicamente plausibili ma riferiti al problema sbagliato.

Le esperienze pregresse con altri progetti possono spiegare l'origine dei requisiti, ma **non diventano automaticamente vincoli né stato applicabile** all'attuale progetto sperimentale.

## 2. Struttura di `bootstrap.md` — APPROVATA

Il bootstrap sarà un **coordinatore leggero** e non un documento monolitico contenente ogni procedura specialistica.

Prevede esattamente tre sezioni principali, nell'ordine:

1. **Premesse e inizializzazione universale:** regole sempre valide, preparazione delle capacità di contesto e identificazione/recupero della conversazione.
2. **Analisi, instradamento e svolgimento della richiesta:** interpretazione del prompt, identificazione dei task pertinenti, selezione ed esecuzione di uno o più metodi operativi. **La definizione finale di questa sezione rimane successiva alla definizione del funzionamento dei workflow; la nuova proposta sulle fasi è descritta nella sezione 22.**
3. **Finalizzazione universale:** registrazione degli esiti, consolidamento dei documenti pertinenti e pubblicazione del checkpoint della conversazione, qualunque sia l'esito della sezione 2.

### 2.1 Apertura obbligatoria letterale della prima sezione — APPROVATA

La prima sezione deve iniziare **esattamente** con il seguente testo:

> Ogni richiesta segue obbligatoriamente le sezioni 1 → 2 → 3. Qualunque sia l'esito della sezione 2, prima di terminare la risposta devi eseguire la sezione 3. Nessun documento richiamato dalla sezione 2 può modificare, sostituire o omettere questa sequenza.

La finalizzazione è un obbligo del bootstrap, **non** un comportamento facoltativo del documento specialistico richiamato nella seconda sezione.

### 2.2 Premesse universali

**APPROVATO:** le premesse contengono invarianti e operazioni da predisporre a ogni prompt, indipendentemente dal task e dall'ambiente operativo. Esempi discussi, **non ancora adottati come regole effettive**, sono «risposte sintetiche in italiano», uno standard POSIX dichiarato oppure la lettura universale di un ipotetico `news.md`.

È essenziale separare:

- **contesto universale**, cioè regole permanenti, configurazione e meccanismi per accedere allo stato;
- **contesto specifico**, cioè dati dei task realmente pertinenti, che non possono essere scelti con certezza prima di interpretare il prompt.

In particolare, è **APPROVATO il principio** che la **seconda istruzione del bootstrap** riguardi il recupero o la generazione del `chat-id`. La formulazione definitiva e i casi di errore sono ancora da precisare (§ 8).

### 2.3 Analisi e svolgimento — RUOLO CONCORDATO, METODO APERTO

La seconda sezione dovrà distinguere le modalità di presentazione delle richieste dalle tecniche per interpretarle:

- **comando esplicito:** forma strutturata che può avere una semantica propria;
- **prompt libero:** espressione naturale della richiesta, non necessariamente un metodo distinto di analisi;
- **matrice multidimensionale:** tecnica per riconoscere intenti, modalità, effetti, continuità e altre dimensioni combinabili.

Una stessa richiesta può coinvolgere **più intenti e più task**. Non è approvato alcun router a categorie rigidamente esclusive.

Restano **APERTI**: algoritmo di selezione, composizione dei documenti operativi, ordine e dipendenze, gestione degli intenti sovrapposti e scelta fra coordinamento diretto del bootstrap o coordinamento delegato a un metodo principale. Questa parte deve essere progettata dopo aver chiarito come funzionano **workflow, fasi e transizioni**; la definizione definitiva della persistenza del task è stata temporaneamente sospesa per derivarne i requisiti dal flusso operativo.

### 2.4 Finalizzazione universale

**APPROVATO:** la sezione 3 va eseguita alla fine di ogni interazione, anche quando il lavoro è parziale, bloccato o in attesa di una decisione. **Conclusione del prompt** e **conclusione del task** sono concetti distinti.

La finalizzazione deve aggiornare **selettivamente** ciò che è cambiato e non deve usare l'obbligo universale come autorizzazione per modifiche non consentite. Durante lavori lunghi restano possibili checkpoint intermedi. Alla fine della risposta deve comparire la riga di identificazione della conversazione prevista dal § 9.

### 2.5 Responsabilità separate

| Componente | Responsabilità |
| --- | --- |
| Bootstrap | Garantire l'ordine universale `1 → 2 → 3` e i vincoli comuni. |
| Router / analisi | Interpretare richiesta, intenti, task e metodi pertinenti. |
| Metodi operativi | Svolgere le attività specializzate. |
| Stato | Conservare dati, decisioni, fonti e checkpoint senza trasformarsi in una fonte concorrente di regole universali. |

## 3. Repository separati — APPROVATI

| Repository | Responsabilità |
| --- | --- |
| **`ai-workflow`** | Regole, `bootstrap.md`, routing e metodi operativi. |
| **`ai-work-state`** | Stato persistente delle conversazioni e dei task; indici, baseline, specifiche, log e handoff. |

L'utente ha **già creato** `ai-work-state`; questo documento non afferma che sia stato popolato con la struttura descritta.

Le identità logiche (chat, branch, messaggio, task, richiesta) vanno distinte dai percorsi fisici e dalle revisioni Git. Il sistema di regole non deve essere confuso con il contenuto mutevole dei task.

## 4. Identità distinte: conversazione, branch, messaggio, richiesta, task — APPROVATO

| Entità | Significato |
| --- | --- |
| **Conversazione (`chat-id`)** | Unità logica persistente che può avere più percorsi evolutivi e trattare più task. Non coincide necessariamente con l'ID interno della piattaforma. |
| **Branch (`branch-id`)** | Un percorso evolutivo della conversazione, con uno stato corrente e associazioni ai task proprie. |
| **Messaggio di risposta (`message-id`)** | Contatore progressivo delle risposte dell'assistente **all'interno del branch**; serve anche da checkpoint. |
| **Richiesta / prompt** | Una singola richiesta dell'utente, collegabile a uno o più task e alla conversazione/branch. Il suo eventuale ID nel `request index` è concettualmente diverso dal `message-id` della risposta. |
| **Task** | Obiettivo persistente che può coinvolgere più prompt, più branch e più conversazioni. |
| **Intento** | Caratteristica del lavoro richiesta, individuata mediante l'analisi multidimensionale; non equivale a un task. |

**Principio fondamentale:** lo stato sostanziale appartiene al **task**; lo stato del **branch** indica invece *quali task sono attualmente associati a quel percorso conversazionale*.

Una conversazione può cambiare argomento e associazioni senza cambiare `chat-id`. Una diramazione conserva il `chat-id` comune, ma può divergere nei task attivi e nella propria progressione.

## 5. Informazioni da conservare in `ai-work-state` — APPROVATE

Restano confermati gli **otto elementi logici** già discussi. La nuova gestione dello stato conversazionale è un **ulteriore elemento distinto**, per un totale di **nove ambiti logici**; questo numero **non** significa nove file obbligatori per ogni task.

| N. | Elemento | Funzione | Ambito |
| --- | --- | --- | --- |
| 1 | **Chat originali** | Conservare integralmente richieste, risposte, correzioni e deviazioni. | Necessarie; exporter esistente ma integrazione rinviata. |
| 2 | **Task registry** | Identificare e localizzare i task, il loro ambito e le relazioni. | Universale. |
| 3 | **Request index** | Collegare ogni richiesta alla conversazione/branch e a uno o più task. | Ogni prompt. |
| 4 | **Task baseline** | Preservare l'obiettivo originario e le sue revisioni autorizzate. | Ogni task persistente. |
| 5 | **Task state** | Rappresentare stato e decisioni correnti valide. | Ogni task persistente. |
| 6 | **Task specification** | Requisiti, progettazione, casi d'uso e criteri di accettazione. | Quando pertinente. |
| 7 | **Task log** | Cronologia fattuale di azioni, decisioni, correzioni, scarti ed evidenze. | Ogni task persistente. |
| 8 | **Handoff** | Ultimo punto verificato, dipendenze e prossimo passo. | Ogni task persistente. |
| 9 | **Conversation / branch state** | Associazione corrente tra ciascun branch e i task, con contatori e origine della diramazione quando nota. | Ogni conversazione gestita dal workflow. |

### 5.1 Chat originali

**APPROVATO:** devono essere conservate integralmente perché lo stato sintetico non basta a ricostruire quando un'intenzione sia stata travisata o un obiettivo sia cambiato progressivamente. Il sistema di esportazione già disponibile all'utente **rimane fuori dal flusso documentale per ora**: non va assunto che l'exporter sia installato, sincronizzato o invocabile automaticamente.

Gli altri documenti potranno collegarsi alla fonte originale mediante riferimenti effettivamente disponibili, evitando di inventare ID o URL interni della piattaforma.

### 5.2 Task registry e request index

Il `task registry` deve rendere individuabili ID logici, ambito, posizione dei documenti e relazioni tra task (ad esempio dipendenza, composizione, sostituzione, risorsa comune). Le relazioni sono **indizi di pertinenza**, non autorizzazioni a ereditare decisioni.

Il `request index` deve consentire il percorso bidirezionale **richiesta → task coinvolti** e **task → richieste pertinenti**, includendo il legame con la conversazione e il branch quando noto. Un prompt può riferirsi contemporaneamente a task differenti.

### 5.3 Documenti principali di ciascun task

- **`task-baseline.md`** — obiettivo e vincoli originari, con revisioni autorizzate non distruttive (§ 6).
- **`task-state.md`** — verità corrente, obiettivo attuale, scelte approvate, stato effettivo e impedimenti.
- **`task-specification.md`** — requisiti e casi d'uso quando il task ne ha bisogno; non obbligatorio per ogni richiesta banale.
- **`task-log.md`** — cronologia append-only, comprese proposte scartate, errori e motivazioni; non sostituisce la fonte integrale della chat.
- **`handoff.md`** — checkpoint preciso e recente, che non riproponga operazioni già concluse.

## 6. Baseline immutabile e revisioni autorizzate — APPROVATA ESPLICITAMENTE

La decisione dell'utente è:

> «la baseline deve essere immutabile, ammettendo solo revisioni esplicitamente autorizzate».

Regole derivanti dalla decisione:

1. La **versione originale** è permanente e non viene sovrascritta.
2. Ogni variazione sostanziale autorizzata genera una **nuova revisione**, senza cancellare quelle precedenti.
3. L'assistente **non può autorizzare da solo** modifiche dell'obiettivo fondamentale.
4. Ogni revisione indica differenze, motivazione, fonte e approvazione esplicita dell'utente.
5. La baseline e le revisioni devono permettere il confronto con lo stato corrente, distinguendo evoluzione legittima da deriva involontaria.
6. Gli aggiornamenti di `task-state.md`, `task-specification.md`, handoff o dello stato conversazionale **non modificano implicitamente** la baseline.
7. Nessun merge di identità o branch può legittimare da solo una revisione della baseline.

Il meccanismo tecnico per archiviare e referenziare le revisioni **rimane da definire**.

## 7. Recupero dei contesti all'inizio del prompt — PRINCIPIO APPROVATO

Si distinguono due livelli:

**Livello 1 — preliminare universale.** Il bootstrap rende disponibile la propria configurazione, identifica **la conversazione e il ramo**, e recupera dal file `branch-N.yaml` la **lista corrente dei task associati**. Questa lista è il punto di partenza efficiente, non una prova conclusiva della pertinenza di tutti i task al nuovo prompt.

**Livello 2 — interpretazione mirata.** La futura sezione 2 analizza l'effettiva richiesta, verifica se i task associati sono pertinenti, ne aggiunge o rimuove eventualmente altri e recupera soltanto la baseline, lo stato, la specifica, i log, gli handoff e le fonti necessari.

La matrice multidimensionale determina aspetti del **modo di operare**; l'associazione chat/branch→task facilita l'individuazione dei **contesti candidati**. I due problemi non vanno confusi.

**Caso di associazione persa o non recuperabile:** il bootstrap deve poter rideterminare il contesto attraverso gli strumenti ordinari (registro, indici, stato disponibile e interpretazione del prompt). La cache conversazionale ottimizza efficienza e coerenza, ma **non deve diventare un requisito di correttezza assoluto**.

## 8. Identificativo della conversazione e seconda istruzione del bootstrap — APPROVATO / TESTO DA DEFINIRE

### 8.1 Formato e invarianti — APPROVATI

Ogni nuova conversazione, in **Chat, Work o Codex** quando il workflow è effettivamente applicato, deve ottenere un identificativo proprio e una directory nello stato persistente.

Formato approvato:

```text
YYYY-MM-DD_HH-MM_UUID
```

Esempio strutturale:

```text
2026-11-09_14-11_<uuid>
```

- `YYYY-MM-DD_HH-MM` rende immediatamente leggibile l'epoca di generazione dell'identità.
- L'UUID, preferibilmente UUID v4, assicura l'unicità pratica.
- Il `chat-id` completo è **immutabile**: un'eventuale denominazione descrittiva può essere modificata separatamente, senza rinominare l'identità logica.
- Il timestamp esprime il momento **di assegnazione dell'ID dal workflow**, che potrebbe essere diverso dalla creazione tecnica della conversazione nella piattaforma.
- Il fuso orario e la modalità esatta di generazione dell'ora restano dettagli da fissare; la discussione ha menzionato `Europe/Rome` come proposta, **non come ulteriore vincolo definitivamente approvato**.

### 8.2 Seconda istruzione della sezione 1 — INTENTO APPROVATO, FORMULAZIONE APERTA

La seconda istruzione, immediatamente dopo l'apertura obbligatoria (§ 2.1), deve **recuperare o generare** il `chat-id`.

La logica concordata è:

1. Cercare il `chat-id`, `branch-id` e `message-id` più recenti e attendibili disponibili nella conversazione.
2. Se disponibili, recuperare il branch pertinente in `ai-work-state`.
3. Se non disponibili, tentare il recupero dell'identità con le fonti realmente accessibili, senza scambiare automaticamente la mancanza di ID per la certezza che la conversazione sia nuova.
4. Se non è possibile recuperare l'identità, crearne una nuova e inizializzare il relativo `branch-0.yaml`, annotando il carattere eventualmente provvisorio della scelta e consentendo un merge successivo.
5. Non dichiarare riuscite creazioni, letture o scritture senza conferma dello strumento impiegato.

**Non è stata ancora approvata una formulazione letterale definitiva** della seconda istruzione; quella iniziale della prima sezione (§ 2.1) invece è stata fissata parola per parola.

### 8.3 «Conversazione nuova» e «ID non disponibile» sono condizioni diverse

L'assistente non dispone necessariamente di segnali nativi affidabili per stabilire se la chat corrente sia appena iniziata, se il contesto sia stato compattato o se stia operando su una diramazione. L'assenza di un identificativo nel contesto **non prova** che la conversazione sia nuova.

L'architettura **accetta una probabilità residua di assegnare un nuovo ID a una conversazione esistente**, purché sia previsto il recupero successivo (§ 12). Non si richiede una garanzia assoluta della cache. Non è invece accettabile fingere che una persistenza fallita sia riuscita.

## 9. Checkpoint pubblicato in ogni risposta — APPROVATO

Alla fine di **ogni risposta dell'assistente** deve comparire, in un'unica riga Markdown in stile monospaziato, la forma logica:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <branch-id>; message-id = <message-id>
```

Regole concordate:

- La riga è **l'ultima** della risposta, separata dal contenuto tramite una riga vuota.
- Usa **inline code Markdown** (backtick singoli), non un titolo, una tabella o un blocco di codice.
- Usa sintassi e ordine **costanti** in Chat, Work e Codex, nei limiti dell'ambiente che effettivamente esegue il bootstrap.
- Espone la chiave per il recupero del ramo, **non** l'elenco dei task: quello resta nei file di stato.
- Il `chat-id` resta stabile tra diramazioni; `branch-id` e `message-id` identificano il checkpoint specifico.
- La riga è anche una cache ridondante nel contesto conversazionale; se non disponibile, si applica il recupero definito nella sezione 1.

Esempio **illustrativo** (non un identificativo realmente assegnato a questa chat):

`ai-work-state: chat-id = 2026-11-09_14-11_<uuid>; branch-id = 1; message-id = 4`

### 9.1 Nuova regola di notifica — APPROVATA NELLA PRESENTE REVISIONE

**Quando il workflow rileva e assegna un nuovo branch, la risposta deve iniziare notificando esplicitamente la rilevazione**, prima del contenuto ordinario della risposta. Questo serve sia nelle diramazioni attese sia come segnale visibile di possibili errori nella gestione dei messaggi e dei checkpoint.

- La notifica riguarda la **rilevazione di una nuova diramazione**, non qualsiasi risposta del ramo.
- Deve riportare in modo chiaro che è stato rilevato un nuovo branch e, preferibilmente, il `branch-id` assegnato.
- La **frase esatta e la presentazione grafica** della notifica non sono state ancora fissate; non inventiamo uno stile come se fosse già approvato.
- Rimane comunque obbligatoria **la riga finale** del § 9.
- Se una divergenza è soltanto sospetta ma non dimostrata, la comunicazione non deve presentarla falsamente come accertata.

Esempio puramente illustrativo di contenuto: «AI-Workflow: rilevata una nuova diramazione; assegnato branch 2». Non è una formula definitiva approvata.

## 10. File di stato della conversazione — APPROVATI

È stata preferita la soluzione **un file YAML per ciascun ramo, senza sottodirectory di branch**, in luogo di un unico `state.yaml` per conversazione.

Percorso concordato:

```text
ai-work-state/
└── conversations/
    └── 2026-11-09_14-11_<uuid>/
        ├── branch-0.yaml
        ├── branch-1.yaml
        └── branch-2.yaml
```

L'estensione corretta è `.yaml`.

**Non si ripetono dentro il file né `chat-id` né `branch-id`**, perché sono già ricavabili dal percorso e dal nome. Si evitano anche altri campi ridondanti senza utilità concreta.

### 10.1 Ramo iniziale

Esempio minimo di `branch-0.yaml`:

```yaml
created_at: 2026-11-09T14:11:00+01:00
message_id: 7
tasks:
  - task:A
  - task:B
```

- `created_at` indica la creazione dell'identità conversazionale nel workflow.
- `message_id` è il checkpoint corrente **del ramo**, incrementato a ogni risposta dell'assistente.
- `tasks` contiene l'insieme **corrente** dei task associati a quel ramo, non l'elenco storico di tutti quelli mai trattati.
- L'inizio del contatore è stato fissato a **1 per la prima risposta**; il checkpoint non ancora pubblicato può essere rappresentato logicamente da `0`.

### 10.2 Ramo derivato

Esempio di `branch-1.yaml`:

```yaml
created_at: 2026-11-09T15:20:00+01:00
parent_branch: 0
fork_message: 3
message_id: 4
tasks:
  - task:A
  - task:C
```

- `created_at` indica il momento della **creazione o rilevazione** del nuovo ramo.
- `parent_branch` e `fork_message` sono informazioni di genealogia **solo quando conosciute con sufficiente evidenza**; in particolare, nei recuperi da un ID falso **non vanno inventate**.
- L'elenco dei task può divergere da quello del ramo genitore senza modificare gli altri rami.
- Una modifica a un ramo deve aggiornare soltanto il relativo `branch-N.yaml` e gli altri documenti effettivamente coinvolti.

### 10.3 Vantaggi del file per ramo

- In condizioni normali è sufficiente **una lettura** di `branch-N.yaml` per conoscere i task associati.
- L'aggiornamento di un ramo non richiede la riscrittura degli altri.
- La directory può contenere un numero variabile di rami senza annidamenti disomogenei.
- Per assegnare un nuovo `branch-id` occorre invece individuare i nomi già esistenti e scegliere un intero disponibile, evitando collisioni.
- Il controllo della revisione Git del file (o un meccanismo di scrittura condizionata equivalente) rimane necessario nelle scritture concorrenti.

## 11. Rilevazione delle diramazioni — APPROVATA COME METODO DI BASE

### 11.1 Contatori e identificazione

- `branch-id` è un intero progressivo, inizialmente **0**.
- `message-id` è un intero progressivo **per ramo**, con **prima risposta = 1**.
- Il checkpoint si individua tramite la terna **`(chat-id, branch-id, message-id)`**, non con il solo `message-id`: due rami possono avere lo stesso contatore senza rappresentare lo stesso checkpoint.
- Una diramazione **conserva il `chat-id`**; quando viene riconosciuta, riceve il successivo `branch-id` disponibile.

### 11.2 Regola di confronto

Prima di aggiornare lo stato, il bootstrap recupera dalla risposta precedente il checkpoint da cui **il percorso corrente** sta ripartendo; quindi legge il corrispondente `branch-N.yaml`.

- **Coincidenza:** se il checkpoint precedente corrisponde all'ultima risposta persistita del ramo, la nuova risposta prosegue **lo stesso branch** e incrementa `message-id`.
- **Divergenza:** se il percorso riparte da un checkpoint precedente rispetto a quello registrato, il sistema può riconoscere una diramazione, creare **un nuovo file `branch-M.yaml`** e proseguire dal contatore appropriato.
- **Incertezza:** una discrepanza può anche essere causata da una scrittura fallita, da un ID errato o da un contesto incompleto; **non ogni differenza deve essere classificata automaticamente come nuova diramazione**.
- **Concorrenza:** due operazioni che leggono la stessa revisione non devono poter sovrascrivere silenziosamente le modifiche reciproche. Se la revisione non coincide, leggere il nuovo stato e rivalutare prima di scrivere.

La nuova diramazione può essere riconosciuta **soltanto quando i due percorsi evolvono in modo osservabile**. Non è necessario, e potrebbe non essere possibile, sapere quale sia la conversazione «originale» nella piattaforma. Il primo percorso che aggiorna il ramo registrato può mantenere il vecchio ID; quello divergente ne ottiene uno nuovo.

### 11.3 Esempio schematico

Uno stato persistente registra:

```text
chat=C1; branch=0; message=6
```

Un altro percorso della stessa conversazione conosce ancora:

```text
chat=C1; branch=0; message=3
```

Il confronto mostra che il secondo percorso riparte da un checkpoint più vecchio. Se la divergenza è confermata, si crea il **branch 1** partendo dal messaggio 3; la sua prima risposta diviene **message 4**.

La risposta deve **iniziare** con la notifica del nuovo branch (§ 9.1) e **terminare** con il checkpoint aggiornato (§ 9).

### 11.4 Limiti riconosciuti

Il metodo non presuppone che ChatGPT esponga l'ID tecnico della diramazione o segnali in modo infallibile se una conversazione è nuova. Il confronto può non distinguere perfettamente rigenerazioni, checkpoint mancanti o condizioni di concorrenza. Per l'obiettivo attuale **non è richiesta infallibilità**, ma una strategia efficiente con recupero e senza perdita silenziosa di dati.

Rimane da progettare in dettaglio il protocollo di rilettura, retry e gestione dei casi ambigui (§ 15).

## 12. Recupero di una falsa nuova conversazione: merge come branch — APPROVATO

### 12.1 Scenario

Una conversazione con ID originale **C1** perde il proprio identificativo; il bootstrap genera erroneamente una nuova identità **C2** e registra alcuni messaggi e task. Più tardi viene ritrovata la corrispondenza.

**Decisione approvata:** incorporare C2 in C1 come **nuovo branch** anziché tentare un merge distruttivo degli stati. Il risultato può essere genealogicamente approssimativo, ma deve essere efficace, conservativo e non compromettere il funzionamento complessivo.

### 12.2 Comportamento concordato

1. Stabilire con evidenza sufficiente che C1 e C2 rappresentano la stessa conversazione logica.
2. Conservare **C1 come identificativo canonico**, normalmente quello originario verificato.
3. Inserire l'evoluzione registrata sotto C2 in uno o più file `branch-N.yaml` non collidenti della directory C1. **Non unire automaticamente** l'insieme dei task associati ai due rami.
4. Lasciare nella directory C2 un riferimento persistente verso C1, per esempio `alias.yaml`, così i precedenti riferimenti a C2 restano risolvibili.
5. Preservare cronologie, fonti, revisioni e datazioni disponibili. Se parentela e punto esatto della biforcazione non sono noti, non inventare `parent_branch` o `fork_message`.
6. Da quel momento utilizzare nei nuovi checkpoint della risposta il `chat-id` canonico, con il nuovo `branch-id` e il proprio `message-id`.
7. Una riconciliazione di identità **non** autorizza nuove decisioni di task né revisioni della baseline.

Schema illustrativo:

```text
conversations/
├── C1/
│   ├── branch-0.yaml
│   ├── branch-1.yaml
│   └── branch-2.yaml    # sviluppo prima conservato sotto C2
└── C2/
    └── alias.yaml      # rinvia all'identità canonica C1
```

Esempio di alias:

```yaml
canonical_chat_id: C1
```

Il trattamento degli eventuali **più rami già nati dentro C2**, delle collisioni di riferimenti e dei checkpoint intermedi sarà definito nella procedura tecnica. L'alias deve evitare la perdita di puntamenti già esistenti; non deve diventare un secondo stato attivo indipendente.

### 12.3 Distinzione fondamentale

Se C1 era associata ai task A e B e C2 ai task B e C, il merge **non implica** che il ramo corrente debba trattare A, B e C simultaneamente. Lo stato di ciascun ramo conserva le associazioni effettivamente pertinenti; il **request index** e le fonti integrali permetteranno eventualmente di ricostruire la storia.

## 13. Salvataggio al termine di ogni prompt — PRINCIPI APPROVATI

La sezione 3 è sempre percorsa; le operazioni concrete sono **selettive** e subordinate a strumenti realmente disponibili e alle autorizzazioni applicabili.

| Informazione / evento | Azione prevista |
| --- | --- |
| Prompt e relativa origine | Registrare il riferimento nel **request index**. |
| Task trattati | Aggiornare il collegamento richiesta↔task. |
| Decisioni, correzioni, lavoro, errori, evidenze | Appendere gli eventi significativi ai log interessati. |
| Nuovo stato corrente dei task | Aggiornare selettivamente `task-state.md`. |
| Requisiti o progetto cambiati | Aggiornare `task-specification.md` se pertinente. |
| Obiettivo o vincolo fondamentale cambiato | Non alterare la baseline senza approvazione esplicita; eventuale nuova revisione non distruttiva. |
| Punto effettivo da cui riprendere | Aggiornare `handoff.md` dei task coinvolti. |
| Associazione corrente conversazione/ramo→task | Aggiornare **solo il pertinente `branch-N.yaml`** se l'associazione o il checkpoint cambia. |
| Risposta dell'assistente | Pubblicare **sempre** l'ultima riga con `chat-id`, `branch-id`, `message-id`; **all'inizio** notificare l'eventuale nuova diramazione rilevata. |
| Archivio integrale della chat | Compito dell'exporter esterno, non integrato per ora. |

Il `message-id` cambia a ogni risposta, quindi in condizioni normali il checkpoint del branch richiede un aggiornamento per risposta, anche se l'elenco `tasks` resta invariato.

Se il repository non è scrivibile, il sistema **non deve dichiarare salvato** ciò che non è stato persistito. Resta da fissare la forma della segnalazione e l'eventuale continuazione in modalità degradata, senza inventare una garanzia di recupero.

## 14. Consistenza, revisioni e non ridondanza — PRINCIPI APPROVATI

- **Stato del ramo piccolo:** solo dati necessari al recupero rapido (`created_at`, `message_id`, task attivi, eventuale genealogia verificata).
- **Nessun chat-id nel file:** il percorso `conversations/<chat-id>/branch-N.yaml` contiene già l'identità.
- **Nessun branch-id nel file:** è già espresso dal nome.
- **Relazioni opzionali:** `parent_branch` e `fork_message` si scrivono solo se realmente conosciuti.
- **Nessuna fusione automatica dei task:** due rami o due identità erroneamente duplicate possono avere associazioni differenti.
- **Scritture condizionate:** per l'aggiornamento dello stesso ramo si usa la revisione Git del file o un equivalente confronto-and-swap; una collisione richiede rilettura.
- **Nuovo numero di branch:** occorre coordinare l'assegnazione di ID interi non già presenti, soprattutto con esecuzioni concorrenti.
- **Nessuna falsa certezza sulla piattaforma:** una procedura testuale del bootstrap non equivale a un'API garantita di identificazione della conversazione in Chat, Work o Codex.

## 15. Stato aggiornato delle questioni aperte — AL 10 NOVEMBRE 2026

### 15.1 Definito e approvato dopo la versione 02

- Specifica operativa della gestione delle conversazioni, con algoritmo di inizializzazione, checkpoint, diramazioni, recuperi e alias: approvata e **pubblicata** come `doc/conversation-identity.md` nel repository `ai-workflow`, in inglese.
- `sync = pending`: approvato come suffisso **solo quando** la persistenza della risposta non è stata confermata. La riga identifica comunque il messaggio emesso; un checkpoint pendente non prova una diramazione.
- Ricostruzione dei task al checkpoint di origine mediante storia delle variazioni di associazione: approvata.
- Documentazione finale di repository **in inglese**, discussione di progettazione **in italiano**: approvata.

### 15.2 Da definire operativamente

- Schema esatto dell'indice delle richieste, idempotenza e cronologia delle variazioni task↔checkpoint.
- Coordinamento di scritture fra più file (inclusi errori, recupero e rappresentazione dei delta pendenti).
- Schema definitivo di `ai-work-state` oltre la directory `conversations/`, già approvata.
- Sezione 1 e sezione 3 effettive del nuovo bootstrap in tre parti, con integrazione della specifica pubblicata.
- Sezione 2: algoritmo di interpretazione e composizione, criteri di uso della matrice e controllo della continuità di workflow/fasi.
- Comportamento dei workflow quando il prompt introduce più task o un'operazione subordinata alla fase corrente.
- Migrazione/attivazione nei contesti realmente supportati da Chat, Work e Codex; test del comportamento reale.

### 15.3 Priorità progettuale aggiornata

L'utente ha **sospeso la validazione dello schema generale di stato** per chiarire prima come deve funzionare il percorso operativo del task nel tempo. La proposta attuale è progettare il **contratto universale delle fasi**, la verifica leggera a ogni prompt e i trigger del re-routing. Solo dopo occorre validare i campi persistenti necessari per supportarli.

## 16. Registro sintetico delle decisioni

| ID | Decisione | Stato |
| --- | --- | --- |
| D-01 | Bootstrap in tre sezioni universali `1 → 2 → 3`. | **APPROVATA** |
| D-02 | Apertura letterale obbligatoria della sezione 1 (§ 2.1). | **APPROVATA** |
| D-03 | Sezione 2 progettata per ultima, mantenendo la matrice multidimensionale e i multi-task. | **APPROVATA** |
| D-04 | `ai-workflow` = regole; `ai-work-state` = dati persistenti. | **APPROVATA** |
| D-05 | Chat, task e richieste sono entità diverse; le chat originali vanno conservate integralmente tramite exporter separato per ora. | **APPROVATA** |
| D-06 | Otto elementi originari dello stato più stato conversazione/branch. | **APPROVATA** |
| D-07 | Baseline originale immutabile; revisioni solo su approvazione esplicita e senza cancellazione della storia. | **APPROVATA** |
| D-08 | Identità della conversazione `YYYY-MM-DD_HH-MM_UUID`, immutabile. | **APPROVATA** |
| D-09 | Seconda istruzione del bootstrap dedicata a recuperare o generare il chat-id; testo esatto ancora da definire. | **PRINCIPIO APPROVATO** |
| D-10 | Lo stesso chat-id è mantenuto dalle diramazioni. | **APPROVATA** |
| D-11 | Branch numerici da 0 e message-id per ramo con prima risposta 1. | **APPROVATA** |
| D-12 | Riga finale costante con chat-id, branch-id e message-id. | **APPROVATA** |
| D-13 | `conversations/<chat-id>/branch-N.yaml`, un file per ramo, senza sottodirectory e senza ID ridondanti al suo interno. | **APPROVATA** |
| D-14 | Conservare `created_at` in ogni ramo; genealogia soltanto quando conosciuta. | **APPROVATA** |
| D-15 | Rilevare diramazioni mediante confronto fra checkpoint conversazionale e checkpoint persistito; non ogni mismatch implica automaticamente un branch. | **APPROVATA COME METODO** |
| D-16 | **All'inizio della risposta notificare la rilevazione di un nuovo branch.** | **APPROVATA** |
| D-17 | Merge di una falsa nuova conversazione tramite nuovo branch dell'ID canonico, conservando alias e storia. | **APPROVATA COME METODO** |
| D-18 | Non unire automaticamente gli insiemi di task e non alterare baseline durante branch/merge. | **APPROVATA** |
| D-19 | Scritture condizionate alla revisione e recupero senza fingere operazioni riuscite. | **PRINCIPIO APPROVATO** |
| D-20 | Finalizzazione ad ogni prompt, salvataggio selettivo, eventuale checkpoint intermedio e distinzione prompt/task. | **APPROVATA** |

## 17. Perimetro e prossima attività di progettazione

Questa versione documenta **le decisioni effettivamente concordate** fino alla richiesta di notificare, all'inizio della risposta, ogni nuovo branch rilevato.

**Non** costituisce una specifica tecnica completa, **non** afferma che ChatGPT esponga l'ID interno o i rami, **non** integra l'exporter e **non** documenta modifiche effettuate nei repository GitHub.

Le decisioni successive a questa versione storica sono documentate nelle sezioni 18–24. Il passo successivo attualmente proposto è definire **il contratto universale delle fasi dei workflow**, non tornare immediatamente alla struttura definitiva di `ai-work-state`.

---

## 18. Specifica delle conversazioni: approvazione e pubblicazione — APPROVATO / ESEGUITO

Dopo la v02 sono stati approvati l'algoritmo operativo e i casi limite per l'identità conversazionale. La specifica inglese è stata pubblicata nel repository `massimilianonardi-ai/ai-workflow`:

- **Percorso:** `doc/conversation-identity.md`.
- **Commit di pubblicazione:** `8519db3e79a0dd55ee9ffe83945494fe970141a1`.
- **Contenuto:** identificativi, inizializzazione e alias, file `branch-N.yaml`, checkpoint e diramazioni, notifica obbligatoria all'inizio della prima risposta di un nuovo branch, concorrenza Git, riconciliazione delle identità duplicate, finalizzazione e scenari di verifica.
- **Condizione:** è una specifica approvata e pubblicata, **non** l'attivazione del nuovo workflow nel bootstrap.

### 18.1 Gestione dei checkpoint non sincronizzati — APPROVATA

Ogni risposta possiede un proprio `message-id`, anche se il relativo salvataggio fallisce. Il marcatore finale assume il formato normale quando il checkpoint è confermato:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <branch-id>; message-id = <message-id>
```

In caso di scrittura non confermata, viene aggiunto **soltanto** il suffisso:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <branch-id>; message-id = <message-id>; sync = pending
```

- Il contatore non torna indietro per riflettere il vecchio checkpoint persistente.
- Alla richiesta successiva si tenta di recuperare e sincronizzare i checkpoint pendenti prima di riconoscere nuove diramazioni.
- Un checkpoint marcato `pending` **non** costituisce da solo prova di un branch.
- Una risposta di errore GitHub non dimostra necessariamente che la scrittura non sia riuscita: quando possibile, occorre rileggere il repository prima di ritentare.
- Non si inventano dati, delta o modifiche di task che non possono più essere recuperati dal contesto o da fonti verificabili.
- Il marcatore identifica la risposta prodotta, non garantisce da solo la persistenza; gli errori sono segnalati prima della riga finale.

### 18.2 Altre precisazioni approvate

- Per una diramazione dal checkpoint `0/3`, il nuovo ramo può pubblicare il proprio primo messaggio con `branch-id = 1, message-id = 4`.
- Il ramo eredita le **associazioni ai task valide al checkpoint 0/3**, non le associazioni correnti del ramo di origine.
- Il registro richieste dovrà quindi conservare le **variazioni di associazione** utili alla ricostruzione storica.
- `tasks: []` e `tasks: null` sono distinti: assenza verificata di task versus impossibilità di ricostruire le associazioni.
- La riconciliazione di due `chat-id` non deve fondere automaticamente le baseline né inventare il punto storico di diramazione.

## 19. Documentazione, release e stato dei repository

**Convenzione approvata:** discussioni e lavoro di progettazione in italiano; documenti pubblicati nei repository in inglese, previa traduzione delle bozze.

Il documento `ai-workflow-v02.md` e questa v03 sono riepiloghi di progettazione in italiano, **non** documentazione operativa già pubblicata su GitHub. Una specifica locale in italiano deve essere tradotta prima dell'eventuale commit.

**Release storica:** è stato individuato il commit `9ca60a87ec00eedccda95b2575e877bee28ad238` come revisione di `ai-workflow` **immediatamente precedente** all'introduzione di `doc/conversation-identity.md`. La convenzione consigliata è versione `0.1.0`, tag Git `v0.1.0`; la conversazione non ha verificato la creazione del tag o di una GitHub Release. Non dichiarare la release pubblicata senza una verifica specifica.

**Persistenza dello stato:** il repository `ai-work-state` esisteva ma risultava vuoto all'ultima verifica. La proposta di nuova struttura è stata salvata anche nel documento locale `ai-work-state-v01.md`, senza che questo ne costituisca approvazione né implementazione.

## 20. Struttura persistente proposta: validazione rinviata — NON APPROVATA

La proposta contenuta in `ai-work-state-v01.md` prevedeva, oltre a `conversations/` già approvata:

```text
ai-work-state/
  conversations/<chat-id>/branch-N.yaml   # approvato
  registry/tasks.yaml                      # proposto
  requests/<chat-id>/<branch>-<message>.yaml  # proposto
  tasks/<task-id>/
    baseline-v001.md
    task-state.md
    task-specification.md
    task-log.md
    handoff.md
```

Principi già approvati e conservati: baseline iniziale immutabile, revisioni solo su autorizzazione esplicita; stato, specifica, cronologia append-only e handoff con responsabilità distinte; richiesta e task non sono entità equivalenti; archivio delle chat originale separato.

**Non sono invece approvati** i percorsi per `registry/`, `requests/` e `tasks/`, il formato definitivo dei record, gli ID dei task, la scelta fra singolo registro e molti record, né l'atomicità delle scritture. L'utente ha scelto di chiarire prima il flusso operativo, così che lo schema venga derivato dalle esigenze effettive dei workflow.

## 21. Valutazione dell'attuale matrice multidimensionale — ANALISI, NON NUOVA DECISIONE

La matrice alla revisione bloccata dal progetto (`routing/intents.yaml`, versione 1) prevede:

```yaml
dimensions:
  interaction: [ask, act, express, unknown]
  operations: [ask, research, reflect, design, plan, develop, diagnose, review, validate, operate, resume, create, unknown]
  input_modalities: [text, image, audio, video, structured, unknown]
  output_modalities: [text, code, document, image, audio, video, structured, system_change, unknown]
  continuity: [new, continue, resume, unknown]
  effects: [none, read, local_write, external_action, irreversible, unknown]
  uncertainty: [resolved, discoverable, consequential_decision, unknown]
```

### 21.1 Come viene attualmente invocata

Un riferimento testuale dal bootstrap **non apre automaticamente il file**. Il modello deve decidere quando è necessario consultarlo e, se effettivamente disponibile, usare uno strumento per recuperare `routing/intents.yaml`. Poi interpreta il YAML semanticamente. Non è implementato un interprete deterministico o un invocatore automatico.

La revisione bloccata indica una lettura **condizionale**: aprire la matrice soltanto se una classificazione più dettagliata può modificare il routing. Anche `main`, pur avendo una v2 della matrice, mantiene una logica di invocazione prevalentemente opzionale. Questo comportamento è troppo vago per essere un contratto operativo robusto.

### 21.2 Limiti osservati e domande aperte

- `interaction.ask` e `operations.ask` si sovrappongono senza definizioni disambiguanti.
- `operations.resume` descrive principalmente continuità, mentre altre operation descrivono lavori; `create` è troppo generico.
- `effects.irreversible` è una qualità dell'effetto, non una categoria alternativa a `external_action`.
- I valori `uncertainty.discoverable` e `uncertainty.consequential_decision` possono coesistere.
- La matrice elenca documenti da richiamare per operazione, ma non definisce in modo completo come dividere richieste composte, comporre percorsi, gestire l'ordine e riconsiderare il routing.

L'approccio **multidimensionale e multi-etichetta** rimane un principio del progetto; l'elenco specifico di dimensioni, valori e procedura di invocazione resta aperto a revisione.

## 22. Proposta emersa: routing selettivo con continuità vincolata — PROPOSTA DA VALIDARE

Questa sezione registra fedelmente la più recente proposta di architettura del flusso. **Non è ancora approvata dall'utente**. Il problema posto è evitare due estremi:

- **Rigidità:** una volta entrato in un percorso, l'assistente non ne esce più, neppure quando i requisiti sono cambiati o una fase è completa.
- **Flessibilità eccessiva:** il modello riclassifica continuamente il prompt, cambia metodo oppure assume iniziative non richieste e supera il confine delle autorizzazioni.

### 22.1 Tre livelli: router, workflow e fase

1. **Router multidimensionale:** interpreta la richiesta per selezionare uno o più workflow appropriati quando occorre scegliere/rivedere il percorso.
2. **Workflow persistente:** definisce un percorso con fasi, dipendenze, condizioni di avanzamento e confini di autorizzazione; prosegue fra più prompt.
3. **Fase corrente:** indica l'obiettivo immediato, il comportamento previsto dell'assistente e il grado di autonomia consentito.

**Principio proposto:** la matrice seleziona o modifica il percorso; il workflow governa le fasi; il prompt corrente può confermare, modificare, interrompere o sostituire il percorso. Il workflow appartiene al **task**, non globalmente alla conversazione; una conversazione può avere più task, ciascuno in una propria fase.

### 22.2 Esempio illustrativo `system-design`

**Ingresso:** «Voglio progettare un nuovo sistema» → possibile routing iniziale verso `system-design`.

| Fase | Comportamento | Uscita |
| --- | --- | --- |
| 1. Specifiche | Interazione con l'utente, domande focalizzate, ricerca autonoma dei fatti verificabili; identificazione di vincoli, casi d'uso, decisioni | Requisiti sufficientemente definiti e scelte sostanziali approvate |
| 2. Architettura | Progettazione autonoma all'interno dei limiti approvati, verifica tecnica, coinvolgimento dell'utente per nuove scelte sostanziali | Proposta architetturale coerente con le specifiche e pronta per revisione |

Il completamento della fase 1 può produrre il passaggio alla fase 2 **senza una nuova classificazione globale**. «Autonomia architetturale» non equivale ad autorizzazione a implementare, distribuire o modificare sistemi esterni.

### 22.3 Quando consultare nuovamente la matrice

**A ogni prompt** effettuare un controllo **leggero** della pertinenza al workflow/fase corrente. **Non** ricaricare necessariamente il catalogo multidimensionale ogni volta.

| Evento / prompt | Comportamento proposto |
| --- | --- |
| Risposta dell'utente a una domanda della fase | Proseguire la fase senza re-routing globale |
| Criteri di completamento soddisfatti | Effettuare una transizione di fase |
| Ricerca tecnica necessaria durante una fase | Eseguire una sotto-operazione, senza abbandonare il workflow |
| Richiesta marginale e autonoma | Soddisfarla e riprendere il contesto del workflow precedente |
| Nuovo obiettivo o task diverso | Rivalutare il routing |
| Richiesta di saltare una fase | Valutare transizione, prerequisiti e confini di autorizzazione |
| Revoca/modifica di un vincolo approvato | Rivalutare le decisioni dipendenti e, se necessario, la fase |
| Richiesta di azione oltre l'autonomia della fase | Verificare l'autorizzazione, senza dedurla dalla modalità attiva |
| Prompt incompatibile con il percorso corrente | Rieseguire il routing, preservando lo stato precedente |

**Esempio chiave:** durante la specifica, «Cerca quali database supportano queste caratteristiche» è un'operazione di ricerca **subordinata** alla fase corrente; non richiede di sostituire l'intero workflow di progettazione. Viceversa «Abbandoniamo questo progetto e avviamone uno nuovo» richiede rivalutazione del task e routing.

### 22.4 Transizione di fase vs re-routing

- **Transizione di fase:** evoluzione prevista **dentro lo stesso workflow**, quando i criteri stabiliti sono soddisfatti; non occorre necessariamente consultare la matrice.
- **Re-routing:** selezione o ricomposizione del percorso quando quello corrente non è più applicabile, oppure il prompt introduce una nuova richiesta o un nuovo task.

Le due operazioni non sono sinonimi. Il workflow attivo costituisce il percorso predefinito, ma **non deve impedire di riconoscere una richiesta che ne esce**.

### 22.5 Proprietà richieste a ogni fase — PROPOSTA

Ogni fase dovrebbe dichiarare in forma verificabile:

1. **Obiettivo:** risultato della fase.
2. **Autonomia:** operazioni eseguibili senza nuova autorizzazione, decisioni che richiedono intervento dell'utente e attività fuori ambito.
3. **Condizioni di completamento:** criterio di uscita per evitare domande o controlli indefiniti.
4. **Transizioni consentite:** passi successivi, ritorni, prerequisiti ed eventuali gate di approvazione.
5. **Interruzioni/rivalutazioni:** eventi che sospendono la fase o impongono di rivedere il workflow.

Esempio: `specification` non deve costringere l'assistente a fare domande dopo che tutti i requisiti sono stati chiariti; `architecture` non deve trasformare l'autonomia tecnica in permesso di implementazione o deployment.

### 22.6 Tre responsabilità logiche — PROPOSTA

| Responsabilità | Scopo |
| --- | --- |
| **Continuity controller** | Ogni prompt: controlla se proseguire, avanzare di fase, eseguire una sotto-operazione o rivalutare. |
| **Multidimensional router** | Quando necessario: seleziona/riesamina i workflow e compone i metodi. |
| **Workflow controller** | Durante l'esecuzione: applica la fase, le sue regole e le transizioni. |

Questi nomi identificano **responsabilità**, non obbligatoriamente tre servizi software, tool o documenti distinti. Non è stata approvata alcuna nuova directory né API dedicata.

### 22.7 Implicazione per `ai-work-state`

Lo stato futuro del task dovrà presumibilmente consentire di recuperare almeno il workflow attivo, la fase corrente, i prerequisiti/approvazioni e il punto di ripresa. **I campi definitivi non sono ancora approvati**: la forma del workflow deve essere progettata prima di dedurre lo schema persistente.

## 23. Conseguenze sul bootstrap — PROPOSTA

- **Sezione 1:** recupero dell'identità conversazionale e delle capacità minime di accesso allo stato; non importare automaticamente task non pertinenti.
- **Sezione 2:** controllo leggero iniziale della continuità; quando il percorso corrente resta valido, applicare il workflow/fase senza re-routing completo. Quando è richiesto un nuovo percorso, consultare la matrice e interpretarne i dati secondo una procedura esplicita.
- **Sezione 3:** salvare in modo verificabile le variazioni di task, workflow e fase, insieme ai checkpoint; conservare il marker finale e il comportamento `sync = pending` già approvati.

**Importante:** il collegamento testuale dal bootstrap a `routing/intents.yaml` **non apre automaticamente il file**. Va previsto il recupero esplicito quando il router lo richiede. Non è opportuno confondere la matrice descrittiva con un motore deterministico già esistente.

## 24. Prossimi lavori e approvazioni richieste

**Prossima proposta di lavoro:** definire il **contratto universale delle fasi dei workflow**, specificando le proprietà minime, i segnali di avanzamento, i trigger di re-routing e le richieste subordinate. Poi progettare un primo workflow concreto (`system-design`) e verificare che i principi siano generalizzabili a ricerca, sviluppo e diagnosi.

A seguire:

1. Rivedere la matrice multidimensionale (dimensioni, valori, regole di invocazione) alla luce del contratto delle fasi.
2. Formalizzare il controller di continuità, le transizioni e la composizione di più workflow/task.
3. Derivare e validare **solo a quel punto** i campi e i percorsi restanti in `ai-work-state`; `conversations/` resta già definita.
4. Completare e pubblicare in inglese la nuova architettura del bootstrap e le specifiche operative necessarie.
5. Integrare i repository, verificare il comportamento reale negli ambienti supportati e attivare la nuova versione soltanto dopo approvazione e verifiche.

**Non presumere approvati** il controller proposto, un'implementazione deterministica della matrice, uno schema YAML per le fasi o la struttura restante di `ai-work-state`. Questo documento registra la proposta da discutere; non implementa nulla.
