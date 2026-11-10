# AI-Workflow — Identità e continuità delle conversazioni

**Percorso previsto nel repository `ai-workflow`:** `doc/conversation-identity.md`  
**Stato:** bozza operativa da revisionare; non ancora pubblicata né attivata  
**Data:** 2026-11-09  
**Ambito:** Chat, Work, Codex, nei limiti di accesso ed esecuzione effettivamente disponibili

## 1. Scopo e confini

Definire come recuperare o generare l'identità AI-Workflow di una conversazione, mantenere checkpoint progressivi, rilevare diramazioni, sincronizzare lo stato e riconciliare identificativi creati erroneamente. La specifica descrive un protocollo applicativo: non presuppone che la piattaforma esponga un identificativo nativo o segnali di branching, né che un modello disponga sempre della cronologia completa.

Le regole risiedono nel repository `ai-workflow`; i dati mutabili risiedono in `ai-work-state`. Il documento è richiamato dalla seconda istruzione della sezione 1 del bootstrap. La finalizzazione universale (sezione 3) ne applica le operazioni di persistenza e l'emissione del marcatore. Le regole degli ambienti ospitanti e i permessi reali prevalgono sulle possibilità operative descritte qui.

## 2. Identificatori

| Identificatore | Regola |
| --- | --- |
| `chat-id` | Immutabile; formato `YYYY-MM-DD_HH-MM_UUID`, con UUID v4 e timestamp della **generazione dell'identità AI-Workflow**, non necessariamente dell'apertura della chat. |
| `branch-id` | Intero non negativo, 0 per il primo percorso; nuovi valori assegnati in modo progressivo e senza riuso nell'ambito del `chat-id`. |
| `message-id` | Intero, prima risposta = 1, incrementato per **ogni risposta dell'assistente** sul percorso; la diramazione prosegue la numerazione dal checkpoint di origine. |

Il timestamp leggibile del `chat-id` adotta il fuso `Europe/Rome`; il timestamp completo, con offset, viene conservato nel ramo iniziale. La coppia `(branch-id, message-id)` è significativa soltanto nell'ambito di un determinato `chat-id`. I valori degli identificatori non identificano automaticamente un messaggio nativo della piattaforma.

Il marcatore finale di ogni risposta usa il formato ordinario:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <n>; message-id = <n>
```

Se la persistenza del checkpoint non è confermata, viene aggiunto soltanto in tale caso:

```text
ai-work-state: chat-id = <chat-id>; branch-id = <n>; message-id = <n>; sync = pending
```

Il marcatore è l'**ultima riga della risposta**, separata dal contenuto da una riga vuota e visualizzata in monospaziato. La riga identifica la **risposta prodotta**, non necessariamente il checkpoint già presente nel repository. Eventuali errori sono dichiarati prima del marcatore. Non inventare identificatori o conferme di scrittura.

## 3. Persistenza e modello dei file

Struttura minima nel repository `ai-work-state`:

```text
conversations/
  2026-11-09_14-11_<uuid>/
    branch-0.yaml
    branch-1.yaml
    ...
```

Non sono previste sottodirectory per i rami. `chat-id` è ricavato dalla directory, `branch-id` dal nome del file: nessuno dei due viene ripetuto nel contenuto.

### 3.1 Ramo iniziale

```yaml
created_at: '2026-11-09T14:11:00+01:00'
message_id: 3
tasks:
  - task-A
  - task-B
```

`created_at` del ramo 0 è l'istante della generazione dell'identità. `message_id` rappresenta l'ultimo checkpoint di risposta **persistito** sul ramo. `tasks` comprende soltanto le associazioni attive al checkpoint registrato.

### 3.2 Ramo derivato

```yaml
created_at: '2026-11-09T15:20:00+01:00'
parent_branch: 0
fork_message: 3
message_id: 4
tasks:
  - task-A
  - task-C
```

`created_at` indica il momento in cui il ramo viene creato/rilevato nel sistema AI-Workflow; `parent_branch` e `fork_message` compaiono **solo se verificabili**. Se la provenienza è nota soltanto tramite una riconciliazione, si usa il riferimento di recupero previsto nella sezione 9, senza inventare un checkpoint genealogico.

`tasks: []` significa **nessun task associato**; `tasks: null` indica che le associazioni non sono ricostruibili con sufficiente affidabilità. Non sostituire silenziosamente l'incertezza con un elenco vuoto.

### 3.3 Indice delle richieste

La cronologia delle richieste mantiene il collegamento fra prompt, ramo, checkpoint e uno o più task, incluse le **variazioni delle associazioni**. Deve permettere di ricostruire i task validi a un checkpoint precedente. I formati e i percorsi concreti dell'indice saranno stabiliti nella specifica della persistenza; questo documento definisce il requisito d'interfaccia, non un nuovo schema di file già approvato. L'archivio completo delle chat rimane indipendente per ora.

## 4. Inizializzazione e recupero dell'identità

Prima dell'analisi della richiesta:

1. Cercare l'**ultimo marcatore completo** accessibile nella cronologia della stessa conversazione. Usare la tripla `chat-id`, `branch-id`, `message-id` e l'eventuale indicazione `sync = pending`. Evitare di riutilizzare marcatori citati nel testo, negli esempi o provenienti da altre chat come se fossero lo stato corrente.
2. Se il marcatore è presente, risolvere gli eventuali alias, recuperare il file del ramo e verificarne la coerenza. Se l'alias rimappa anche il ramo, aggiornare entrambe le componenti dell'identità corrente.
3. Se il marcatore non è recuperabile, provare soltanto i segnali di identità realmente disponibili e verificabili nel contesto o nell'ambiente. L'assenza del marcatore **non dimostra** che la conversazione sia nuova.
4. Se non esiste un'identità recuperabile **e** il mancato recupero non dipende semplicemente da un guasto temporaneo di accesso a un'identità nota, generare un nuovo `chat-id`, creare la directory e inizializzare `branch-0.yaml` con `message_id: 0` e associazioni ancora da determinare. Usare una creazione condizionata che non sovrascriva file esistenti.
5. Se la persistenza della nuova identità fallisce, conservarla nel marcatore locale con `sync = pending` e dichiarare esplicitamente che non è stata salvata.

Non è richiesta una valutazione preliminare infallibile di «chat nuova» contro «chat esistente»: l'identità viene prima cercata, poi eventualmente generata. Una nuova identità generata per mancanza di informazioni resta potenzialmente riconciliabile. Non fondere conversazioni sulla sola somiglianza del testo.

## 5. Checkpoint, continuazione e divergenza

Distinguere sempre tre valori: **checkpoint di origine** letto dal marcatore precedente (`m`), **testa persistente** del ramo (`h`) e **checkpoint della risposta corrente** (`m + 1`, sul ramo appropriato).

| Confronto | Interpretazione operativa | Azione |
| --- | --- | --- |
| `m = h`, nessun pending | Continuazione ordinaria | Elaborare e salvare `m + 1` sullo stesso ramo. |
| `m < h`, nessun pending | Percorso che riparte da un checkpoint precedente: divergenza rilevabile | Creare un nuovo ramo dal checkpoint `m`. |
| `m > h` | Persistenza arretrata, salvataggio perduto o informazioni incoerenti | Recuperare; **non** presumere una diramazione. |
| `sync = pending` | Checkpoint locale non confermato | Applicare la sezione 7 prima di classificare differenze come nuove diramazioni. |
| Stato o marcatore incongruente / file assente | Identità o persistenza da verificare | Non sovrascrivere; applicare la sezione 8. |

L'uguaglianza numerica è significativa soltanto a parità di identità **canonica** e di ramo. Le risposte rigenerate a partire da un checkpoint precedente possono essere trattate come evoluzioni alternative: non occorre distinguere il percorso «originale» da quello «derivato».

Il numero di messaggio di un ramo derivato continua quello del checkpoint comune: se la biforcazione è da `0/3`, la prima risposta su `branch-1` è `1/4`. I messaggi 1–3 restano riferiti alla storia del ramo genitore; non devono essere inventati come risposte materialmente emesse su `branch-1`.

## 6. Rilevamento e creazione dei branch

Se `m < h` ed è esclusa una sincronizzazione pendente che spieghi la differenza:

1. Recuperare le associazioni ai task **valide al checkpoint `m`** usando la cronologia delle variazioni. Non copiare automaticamente i task del ramo genitore al checkpoint `h`.
2. Assegnare un nuovo `branch-id` pari al primo valore libero successivo al massimo esistente; riservarlo tramite una creazione condizionata di `branch-N.yaml`, senza sovrascrivere file già presenti. In caso di collisione, rileggere e riprovare.
3. Registrare `created_at`, `parent_branch`, `fork_message`, `tasks` ricostruiti e il punto di partenza `message_id: m`. Questa prima scrittura **riserva il ramo**; la prima risposta confermata avanza il contatore a `m + 1`.
4. **Iniziare la prima risposta del nuovo branch notificando esplicitamente il rilevamento**, con identificativo del ramo e checkpoint di origine. Se la riserva non è confermata, non dichiarare creato il ramo; indicare l'assegnazione come provvisoria e segnalare `sync = pending`.
5. Alla finalizzazione salvare `m + 1`, le associazioni correnti e le variazioni pertinenti; emettere il marcatore con il branch effettivamente assegnato.

Notifica ordinaria suggerita: **«AI-Workflow: rilevata una diramazione; creato il branch 1 dal checkpoint 0/3.»**

La notifica deve evidenziare anche eventuali falsi positivi derivanti da errori di gestione dei messaggi. Non presentare come certa la causa della divergenza: viene rilevata una divergenza di checkpoint, non necessariamente un'operazione «Crea branch» della piattaforma.

## 7. Sincronizzazione e `sync = pending`

Il `message-id` identifica la risposta corrente anche quando il salvataggio non riesce. Un fallimento di scrittura non consente di retrocedere al checkpoint persistito precedente.

1. Al fallimento o all'esito incerto di una scrittura, **rileggere il repository quando possibile**: un errore di comunicazione può seguire una scrittura riuscita.
2. Se il checkpoint non è verificabile, segnalare il problema nel testo e aggiungere `sync = pending` al marcatore finale. Conservare l'identità locale e l'eventuale catena di checkpoint pendenti.
3. Al prompt successivo, tentare prima di recuperare e sincronizzare gli aggiornamenti pendenti disponibili, senza inventare delta, messaggi o decisioni non recuperabili. Il solo marcatore non contiene necessariamente dati sufficienti per riprodurre gli aggiornamenti di task e indici.
4. Un checkpoint esplicitamente pendente **non deve essere classificato automaticamente come diramazione** a causa della differenza numerica con lo stato persistente.
5. Se il recupero riesce e viene verificato, proseguire con il checkpoint successivo e rimuovere `sync = pending`. Se non riesce, continuare la numerazione locale quando possibile, mantenendo `sync = pending` e dichiarando le limitazioni.
6. Se lo stato persistente è stato modificato nel frattempo da un altro percorso, non sovrascriverlo: confrontare la provenienza verificabile dei checkpoint, riconciliare o trattare l'eventuale conflitto come evoluzione alternativa.

La disponibilità del contesto o di una fonte di log per ricostruire i delta non è garantita. Quando mancano le informazioni necessarie, dichiarare la lacuna; non certificare come sincronizzata una storia incompleta.

## 8. Concorrenza e anomalie

Per ogni modifica a un ramo esistente usare un controllo condizionato sulla revisione Git letta. In caso di modifica concorrente, rileggere il file e **rivalutare** la situazione partendo dal checkpoint originario della risposta, non ripetere ciecamente la stessa scrittura.

- Se un'altra risposta ha nel frattempo avanzato lo stesso ramo, quella corrente può diventare una divergenza e richiedere un nuovo branch. In tal caso la notifica deve apparire **all'inizio della risposta finale**.
- La creazione di un nuovo `branch-N.yaml` deve fallire se il file esiste già; non sovrascrivere, riprovare con un altro ID.
- Non attribuire automaticamente la mancata lettura a una conversazione nuova; non creare un nuovo `chat-id` per aggirare un guasto di un'identità già nota.
- Se `m > h` senza una spiegazione verificabile, oppure ci sono alias incoerenti, sospendere gli aggiornamenti potenzialmente distruttivi e segnalare l'incertezza.
- Un evento o modifica della cronologia registrato due volte durante un retry deve poter essere riconosciuto come duplicato; l'idempotenza esatta dei record viene definita dalla specifica dell'indice delle richieste.

Il controllo del singolo file non rende automaticamente atomiche tutte le modifiche a task, indici e handoff: la finalizzazione universale dovrà prevedere ordine delle scritture, possibilità di retry e verifica dei riferimenti.

## 9. Identità duplicate e riconciliazione

Se `C2` è stata generata erroneamente come nuova conversazione mentre appartiene alla conversazione logica `C1`:

1. Confermare la relazione con informazioni attendibili o approvazione esplicita; la somiglianza semantica da sola non basta.
2. Scegliere l'ID canonico, normalmente il primo identificativo verificato (`C1`).
3. Importare ciascun ramo di `C2` come un distinto `branch-N.yaml` sotto `C1`, preservando task, cronologia e relazioni interne quando ricostruibili. Non unire automaticamente le liste dei task, le baseline o gli stati dei rami.
4. Conservare in `C2/alias.yaml` il riferimento canonico e la corrispondenza completa tra i vecchi branch e quelli nuovi. I riferimenti storici continuano così a essere risolvibili.
5. Per ogni ramo importato, registrare la provenienza dalla conversazione recuperata; attribuire `parent_branch` e `fork_message` solo se conosciuti con sufficiente evidenza.
6. Le risposte future usano `C1` e il branch canonico; una riga finale precedente con `C2` continua a essere risolvibile tramite l'alias.

Esempio dell'alias (forma proposta da validare nell'implementazione):

```yaml
canonical_chat_id: C1
branches:
  0: 2
  1: 3
```

Il merge è una **riconciliazione di identità**, non una cancellazione né una fusione arbitraria delle storie. Un riferimento di provenienza nel ramo importato può essere utile per l'audit; il formato preciso è rinviato allo schema della persistenza, evitando duplicazioni inutili.

## 10. Finalizzazione universale e ordine delle operazioni

Per ogni risposta, anche senza task persistenti:

1. Identificare il checkpoint di partenza e le eventuali divergenze, riservando il branch quando necessario.
2. Eseguire il lavoro richiesto rispettando autorizzazioni e fonti; determinare le associazioni ai task pertinenti.
3. Registrare i riferimenti alla richiesta e le variazioni delle associazioni; aggiornare soltanto i documenti dei task effettivamente interessati; scrivere gli handoff pertinenti per ultimi fra i documenti dei task.
4. Aggiornare condizionatamente il checkpoint del ramo, verificando gli esiti. Se un aggiornamento fallisce, non attestare persistenza completa e mantenere `sync = pending`.
5. Se è stato individuato un nuovo branch, aprire la risposta finale con la notifica. Segnalare prima del marcatore ogni lacuna di persistenza.
6. Terminare con l'unica riga finale di stato, riferita alla risposta effettivamente emessa.

**Invariante:** l'esecuzione della sezione 3 del bootstrap è obbligatoria anche quando la sezione 2 termina con errore, blocco, rifiuto, lavoro parziale o assenza di task. La chiusura della risposta non equivale alla chiusura del task.

## 11. Invarianti

- Una conversazione logica conserva il proprio `chat-id`, incluse le diramazioni conosciute.
- `chat-id` e `branch-id` non sono ripetuti dentro `branch-N.yaml`.
- `message-id` aumenta di uno per risposta lungo il percorso, anche se il salvataggio è pendente.
- `tasks: []` e `tasks: null` hanno significati diversi: rispettivamente assenza confermata e informazione non recuperata.
- Nessun ramo sovrascrive lo stato di un altro ramo.
- Nessuna nuova diramazione eredita i task attuali del genitore se non coincidono con quelli del checkpoint di origine.
- Nessun merge inventa genealogie o fonde automaticamente obiettivi e baseline.
- Nessun esito incerto viene dichiarato verificato.
- Nessuna diramazione rilevata resta priva di notifica iniziale nella risposta corrispondente.
- Nessun documento operativo può omettere la finalizzazione universale prevista dal bootstrap.

## 12. Casi minimi di verifica

| Caso | Situazione iniziale | Risultato atteso |
| --- | --- | --- |
| Nuova conversazione | Nessun ID recuperabile | Nuovo `chat-id`, `branch-0.yaml` con checkpoint 0 iniziale; prima risposta = 1. |
| Continuazione | Marcatore `0/3`, ramo persistito a `0/3` | Risposta `0/4`, salvataggio verificato. |
| Diramazione | Marcatore `0/3`, ramo persistito a `0/6` | Nuovo `branch-1`, prima risposta `1/4`, notifica in apertura. |
| Diramazione con task cambiati | Al checkpoint 3: A,B; al 6: A,C | Il ramo nuovo eredita A,B, non A,C. |
| Concorrenza | Due risposte partono da `0/3` | Una può proseguire su 0, l'altra deve rileggere e creare un ramo, senza sovrascrivere. |
| Collisione ID ramo | Due riserve tentano `branch-1` | Una prevale; l'altra ricalcola un nuovo ID. |
| Salvataggio fallito | Risposta `0/4`, persistito `0/3` | Marcatore `0/4; sync = pending`; non retrocedere. |
| Recupero pendente | Risposta precedente `0/4; pending`, file a `0/3` | Tentare recupero; non classificare subito come branch. |
| Stato remoto avanti | Marcatore `0/6`, file a `0/4` senza pending | Diagnosticare incoerenza; non sovrascrivere e non creare branch automaticamente. |
| Recupero duplicato | C2 riconosciuta parte di C1 | Importazione dei branch, alias C2→C1 e nuova riga finale canonica. |
| Errore lettura | ID noto, repository indisponibile | Conservare l'ID; segnalare persistenza non verificata, senza generarne uno nuovo. |
| Associazioni non ricostruibili | Fork da checkpoint storico senza variazioni disponibili | `tasks: null`, esplicitare incertezza; non sostituire arbitrariamente con lista corrente. |

## 13. Interfacce ancora da definire altrove

Queste parti non cambiano le decisioni approvate, ma richiedono una specifica complementare prima dell'attivazione:

- Schema e ubicazione dell'indice delle richieste, inclusa la ricostruzione delle associazioni storiche.
- Protocollo di finalizzazione di più file e idempotenza delle scritture dopo retry o crash.
- Rappresentazione recuperabile degli aggiornamenti pendenti quando il contesto della chat non basta.
- Formato esatto dei riferimenti di provenienza nei rami importati e modalità di conferma dei merge incerti.
- Adattamento ai segnali di identità concretamente disponibili in Chat, Work e Codex.

Nessuna di queste interfacce deve essere sostituita da ipotesi non verificate sull'ambiente host.