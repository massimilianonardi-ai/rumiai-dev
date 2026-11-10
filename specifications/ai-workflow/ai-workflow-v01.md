# AI-Workflow — Decisioni architetturali v0.1

**Data:** 9 novembre 2026  
**Stato:** sintesi delle decisioni concordate; architettura in definizione  
**Oggetto:** struttura del bootstrap, separazione tra regole e stato, persistenza, recupero del contesto e prevenzione della deriva degli obiettivi.

> **Criterio di lettura:** il documento distingue **decisioni approvate**, **principi concordati ma non ancora dettagliati** e **questioni aperte**. Non è una specifica di implementazione completa e non dichiara modifiche ai repository.

## 1. Obiettivo del lavoro

Progettare **AI-Workflow** come sistema generale di regole e metodi per assistere richieste semplici e attività complesse, mantenendo la continuità del lavoro e la fedeltà agli obiettivi originari.

I problemi che l'architettura deve affrontare sono soprattutto:

- interpretazioni iniziali scorrette o incomplete che finiscono per cambiare il lavoro richiesto;
- decisioni architetturali importanti affrontate troppo tardi;
- importazione di informazioni corrette ma appartenenti a un altro task;
- progressiva deriva degli obiettivi attraverso molte richieste e conversazioni;
- perdita di decisioni, correzioni, alternative scartate e motivazioni;
- interruzioni ripetitive, scarsa autonomia esecutiva e lavori che non arrivano al risultato;
- confusione tra attività eseguite, risultati verificati e semplici affermazioni dell'agente.

L'architettura è **indipendente da RumiAI e da altri progetti particolari**. Le esperienze precedenti sono motivazioni e casi di studio, non una fonte automatica di vincoli operativi.

## 2. Struttura del bootstrap — APPROVATA

Il file `bootstrap.md` deve avere **tre sezioni principali**, con responsabilità distinte:

1. **Premesse universali:** regole sempre valide e preparazione del contesto universale minimo.
2. **Analisi e svolgimento della richiesta:** interpretazione, individuazione dei task, selezione e coordinamento dei metodi operativi; questa è la sezione più complessa e **sarà progettata per ultima**.
3. **Finalizzazione universale:** azioni da eseguire alla conclusione di ogni interazione, indipendentemente dall'esito del lavoro.

### 2.1 Apertura letterale obbligatoria della prima sezione

La **prima sezione deve iniziare esattamente** con il testo approvato dall'utente:

> Ogni richiesta segue obbligatoriamente le sezioni 1 → 2 → 3. Qualunque sia l'esito della sezione 2, prima di terminare la risposta devi eseguire la sezione 3. Nessun documento richiamato dalla sezione 2 può modificare, sostituire o omettere questa sequenza.

È una prescrizione universale: la finalizzazione non deve dipendere dal fatto che un documento specializzato si ricordi di restituire esplicitamente il controllo al bootstrap.

### 2.2 Sezione 1 — Premesse e inizializzazione universale

**Approvato:** la prima sezione contiene le regole invarianti e le operazioni preliminari valide per ogni richiesta. Non deve conoscere in anticipo tutti i dettagli del task specifico.

Esempi formulati durante la discussione per illustrare la *categoria* di queste regole: «risposte sintetiche in italiano», riferimento a uno standard POSIX di revisione determinata, «leggi sempre `news.md`». **Questi sono esempi, non regole già approvate o documenti di cui sia stata stabilita l'esistenza.** Le regole concrete verranno scelte successivamente.

Si distingue tra:

- **Contesto universale:** regole, configurazione e meccanismi di accesso allo stato applicabili a prescindere dal task.
- **Contesto specifico:** informazioni relative a uno o più task effettivamente pertinenti; la loro applicabilità può essere stabilita soltanto interpretando la richiesta.

La sezione 1 deve predisporre l'accesso alle informazioni necessarie, senza assumere erroneamente che un task storico sia quello corrente.

### 2.3 Sezione 2 — Analisi, instradamento ed esecuzione

**Concordato il ruolo generale; progettazione dettagliata rinviata.** La sezione dovrà interpretare la richiesta e individuare il lavoro e i metodi necessari. Il riferimento attuale comprende comandi espliciti, matrice multidimensionale e prompt libero, ma non sono necessariamente tre metodi equivalenti:

- il **comando** è una forma esplicita di richiesta;
- la **matrice multidimensionale** descrive più caratteristiche e intenti che possono coesistere;
- il **prompt libero** è una forma di espressione, che può comunque richiedere analisi multidimensionale.

Una richiesta può coinvolgere più intenti e **più task distinti**. Non va imposta artificialmente una sola categoria esclusiva. L'idea di selezionare «il documento da eseguire» va quindi esaminata criticamente: potrebbero servire diversi documenti o metodi, con dipendenze e coordinamento.

**Non è stato deciso** se il bootstrap debba orchestrare direttamente più documenti oppure affidare a un metodo principale il coordinamento degli altri. Non sono ancora stati definiti l'algoritmo di routing, il linguaggio dei contratti tra documenti e i criteri di scelta delle fonti.

### 2.4 Sezione 3 — Finalizzazione universale

**Approvato:** viene eseguita alla fine di ogni prompt/interazione, anche se la sezione 2 ha completato il lavoro solo parzialmente, si è bloccata o attende una decisione.

La **conclusione del prompt non coincide con la conclusione del task**: un task può proseguire attraverso molte richieste e chat.

La finalizzazione deve consolidare i risultati e lo stato applicabile, ma non eseguire indiscriminatamente operazioni vietate o prive delle necessarie autorizzazioni. Le azioni particolari e i formati saranno definiti successivamente, sulla base dei principi di persistenza di questo documento.

È possibile eseguire checkpoint intermedi durante lavori lunghi o con effetti esterni; la sezione 3 rimane il punto di consolidamento finale dell'interazione.

### 2.5 Separazione di responsabilità

Principio concordato:

- **Bootstrap:** governo della sequenza universale `1 → 2 → 3`.
- **Routing:** interpretazione e selezione/coordinamento dei metodi necessari.
- **Metodi operativi:** modo in cui eseguire le attività specializzate.
- **Stato:** dati e decisioni sui task, non un'ulteriore fonte concorrente di regole universali.

La distinzione è concettuale; non è ancora stabilita la distribuzione definitiva in file e interfacce.

## 3. Separazione dei repository — APPROVATA

Sono stati scelti due repository distinti:

| Repository | Responsabilità |
| --- | --- |
| **`ai-workflow`** | Bootstrap, regole universali, routing e metodi operativi. |
| **`ai-work-state`** | Stato persistente: task, decisioni, richieste, cronologie, baseline, specifiche e handoff. |

L'utente ha dichiarato di avere **creato `ai-work-state`**. La presente sintesi non implica che il suo contenuto sia stato inizializzato, verificato o modificato.

Il repository delle regole non deve diventare il contenitore predefinito dello stato mutevole dei task. È inoltre importante distinguere l'**identità logica** di un task dalla sua **posizione fisica** e dalla **revisione** dei documenti.

La convenzione iniziale può usare GitHub, ma la logica del bootstrap non deve dipendere dal percorso concreto dei file: il meccanismo di risoluzione deve poter identificare lo stato pertinente in modo esplicito.

## 4. Unità concettuali: richiesta, task e conversazione — APPROVATO

Le tre entità non coincidono:

| Entità | Definizione |
| --- | --- |
| **Richiesta / prompt** | Singola interazione dell'utente e attività che ne deriva; può coinvolgere più task. |
| **Task** | Obiettivo logico persistente, che può attraversare più prompt e conversazioni. |
| **Conversazione / chat** | Contenitore delle interazioni; può riguardare più task. |

**Lo stato corrente appartiene principalmente al task, non alla chat.**

Gli **intenti** identificati dalla matrice multidimensionale e i **task** sono due dimensioni differenti: una richiesta può combinare diversi intenti applicati a più task, mentre una somiglianza di intenti non dimostra che si tratti dello stesso task.

## 5. Informazioni da conservare in `ai-work-state` — APPROVATO

Sono stati concordati **otto elementi logici**. «Elemento logico» non equivale automaticamente a «file fisico obbligatorio per ogni richiesta».

| N. | Elemento | Scopo | Ambito concordato |
| --- | --- | --- | --- |
| 1 | **Chat** | Conservare le conversazioni originali integrali, per recuperare intenzioni, correzioni, errori e derive. | Necessarie come patrimonio informativo; exporter esterno per ora. |
| 2 | **Task registry** | Catalogo dei task: ID, posizione, ambito, relazioni e riferimenti. | Universale. |
| 3 | **Request index** | Collegare ogni prompt alla chat originale e a uno o più task interessati. | **Ogni prompt**. |
| 4 | **Task baseline** | Conservare l'obiettivo originale e i vincoli fondamentali con provenienza e storia delle revisioni autorizzate. | Ogni task persistente. |
| 5 | **Task state** | Descrivere obiettivo corrente, stato effettivo e decisioni attualmente valide. | Ogni task persistente. |
| 6 | **Task specification** | Formalizzare requisiti, progettazione, casi d'uso e criteri di accettazione quando necessari. | Condizionale, secondo il tipo di lavoro. |
| 7 | **Task log** | Registrare cronologicamente richieste, attività, decisioni, correzioni, alternative scartate ed evidenze. | Ogni task persistente. |
| 8 | **Handoff** | Identificare il punto esatto di ripresa, i riferimenti correnti e il prossimo passo. | Ogni task persistente. |

### 5.1 Chat originali: indispensabili, ma integrazione rinviata

Le chat devono essere conservate **integralmente**: riassunti, task state e handoff possono perdere sfumature e informazioni che diventano decisive quando si ricerca l'origine di una deviazione.

L'utente dispone già di un proprio sistema di esportazione delle chat. **Per ora quel sistema rimane separato dal nuovo flusso documentale**: non si introduce una dipendenza dall'exporter né si progetta qui la sua integrazione tecnica.

I documenti di stato devono poter conservare **riferimenti alle fonti originali** quando disponibili, senza inventare identificativi di messaggi, archivi esistenti o sincronizzazioni automatiche.

### 5.2 Task registry

Il registro rende individuabili i task mediante identificativi logici stabili, ubicazione dei documenti, ambito e relazioni tra task.

Le relazioni possono includere, a titolo di esempio: «dipende da», «è parte di», «sostituisce», «condivide una risorsa». Queste relazioni servono a trovare contesti candidati: **non autorizzano automaticamente a importare decisioni da un task all'altro**.

Il fatto che due task siano nello stesso repository, nella stessa chat o nello stesso progetto non dimostra la loro identità.

### 5.3 Request index

Per ogni prompt occorre preservare una relazione consultabile tra:

- identificativo della richiesta;
- riferimento alla conversazione originale, se disponibile;
- task coinvolto o **insieme** dei task coinvolti;
- eventuali legami rilevanti con nuove richieste e aggiornamenti.

Lo scopo è poter risalire **in entrambe le direzioni**: da una richiesta ai suoi task e da un task alle richieste che lo hanno interessato. Questa informazione non va perduta quando una stessa richiesta modifica più task.

### 5.4 Task state, specification, log e handoff

Si mantiene la separazione già approvata:

- **`task-state.md`** — situazione corrente e decisioni valide; le alternative respinte non diventano parte della verità corrente.
- **`task-specification.md`** — dettagli di requisiti, progetto, casi d'uso e verifiche quando il lavoro lo richiede.
- **`task-log.md`** — storia cronologica, incluse correzioni, proposte respinte, motivazioni e risultati.
- **`handoff.md`** — checkpoint di ripresa, con ciò che è realmente stato completato e il successivo passo pertinente.

Un handoff affidabile deve descrivere **l'ultimo stato effettivo**, non riproporre attività già concluse.

## 6. Task baseline: immutabilità e revisioni autorizzate — APPROVATO ESPLICITAMENTE

La baseline è stata individuata come elemento essenziale per prevenire la **deriva progressiva dell'obiettivo**: potrebbe accadere che stato corrente e handoff siano perfettamente coerenti tra loro, ma descrivano ormai un prodotto diverso da quello originariamente richiesto.

La decisione esplicita dell'utente è:

> «la baseline deve essere immutabile, ammettendo solo revisioni esplicitamente autorizzate».

Ne derivano le seguenti regole:

1. **Versione originale permanente.** La baseline iniziale conserva obiettivo, vincoli e fonte della richiesta originaria; non può essere riscritta retroattivamente.
2. **Revisioni non distruttive / append-only.** Una modifica autorizzata genera una nuova revisione e preserva tutte le precedenti.
3. **Autorizzazione esplicita.** Un cambiamento sostanziale della baseline richiede approvazione dell'utente; interpretazioni successive dell'agente non bastano.
4. **Provenienza verificabile.** Ogni revisione deve indicare cosa cambia, perché, quale autorizzazione la legittima e quale richiesta ne è la fonte.
5. **Rilevazione della deriva.** Il sistema deve poter confrontare obiettivo originale, revisioni approvate e stato corrente, distinguendo evoluzione autorizzata da spostamento involontario dell'obiettivo.
6. **Autorità distinta.** Un cambiamento in `task-state.md`, `task-specification.md` o `handoff.md` non modifica da solo la baseline.

Il meccanismo tecnico con cui conservare versioni e autorizzazioni (file singolo versionato, file distinti, riferimenti Git ecc.) **non è stato ancora deciso**.

## 7. Lettura iniziale dello stato — PRINCIPI APPROVATI; ALGORITMO APERTO

Questa è stata riconosciuta come una delle parti più difficili dell'intera architettura.

### 7.1 Due livelli di recupero

**Livello A — preparazione universale minima:** rendere disponibili le regole di accesso all'archivio, i meccanismi di risoluzione, il registro e i riferimenti esplicitamente forniti, evitando il caricamento indiscriminato dei documenti di tutti i task.

**Livello B — recupero selettivo dei contesti specifici:** dopo una prima interpretazione della richiesta, individuare uno o più task candidati e, per ciascuno:

1. verificare identità, ambito e pertinenza mediante registro e baseline;
2. esaminare incompatibilità tra prompt attuale e fatti precedenti;
3. caricare stato e handoff quando necessari;
4. consultare specifiche, log e conversazioni originali quando necessari per decisioni, correzioni o sospetta deriva.

Il fatto di *trovare* una fonte non prova che la fonte sia *applicabile* al task. L'identità deve essere risolta sulla base di elementi concreti, non soltanto di somiglianze lessicali o di numeri apparentemente coincidenti.

### 7.2 Sovrapposizione tra task

Una richiesta potrebbe riguardare, per esempio, «analizza A, confrontalo con B e modifica C»:

- task potenzialmente interessati: A, B, C;
- intenti potenzialmente combinati: ricerca, analisi, confronto, progettazione, sviluppo;
- relazioni e decisioni eventualmente diverse per ciascun task.

La matrice multidimensionale può aiutare a capire **come** svolgere il lavoro, ma **non identifica da sola** gli stati pertinenti. Occorre uno specifico meccanismo di riconoscimento e collegamento dei task.

### 7.3 Questioni ancora aperte

Non è stato deciso:

- con quale algoritmo identificare, classificare e disambiguare più task;
- quali parti del registro vadano consultate sempre e quali solo su richiesta;
- come indicizzare e ricercare fonti quando l'archivio diventa grande;
- quali condizioni giustifichino la lettura integrale delle chat;
- come coordinare il recupero dello stato con la selezione dei documenti operativi nella futura sezione 2.

## 8. Salvataggio alla fine di ogni prompt — PRINCIPI APPROVATI

La **sezione 3** viene sempre eseguita, ma gli aggiornamenti ai documenti sono **selettivi**. Non è necessario modificare tutte le informazioni a ogni interazione.

| Dato o evento | Azione conclusiva prevista |
| --- | --- |
| Prompt corrente e sua fonte | Registrare il riferimento nel `request index`. |
| Uno o più task interessati | Aggiornare i collegamenti della richiesta ai task pertinenti. |
| Nuove attività, decisioni, correzioni, errori o risultati | Aggiungere gli eventi significativi ai relativi `task-log.md`. |
| Stato o decisioni correnti cambiati | Aggiornare il `task-state.md` dei task pertinenti. |
| Requisiti o progettazione cambiati | Aggiornare `task-specification.md` quando applicabile. |
| Modifica sostanziale dell'obiettivo originale | **Non** cambiare implicitamente la baseline; registrare una nuova revisione soltanto dopo approvazione esplicita. |
| Punto di avanzamento o dipendenze cambiati | Aggiornare `handoff.md` dei task interessati affinché descriva il punto effettivo da cui riprendere. |
| Conversazione originale | Conservazione demandata al sistema exporter esistente, fuori dal flusso documentale per ora. |

È ammesso un salvataggio intermedio durante attività lunghe o rischiose. La finalizzazione resta obbligatoria anche con risultato parziale, blocco o attesa di una decisione.

Le scritture devono rispettare accesso, autorizzazioni ed effetti consentiti: l'obbligo di finalizzare non equivale al permesso di compiere azioni vietate. Non si devono dichiarare salvate informazioni per cui non esiste una scrittura riuscita; un'eventuale mancanza di persistenza va comunicata.

## 9. Struttura logica possibile dell'archivio — NON ANCORA VINCOLANTE

La rappresentazione discussa è:

```text
ai-work-state/
  registry/               # Identità, ubicazione, ambito e relazioni dei task
  requests/               # Indice prompt → chat → uno o più task
  tasks/
    <task-id>/
      task-baseline.md     # Originale e revisioni autorizzate, mai distruttive
      task-state.md        # Stato corrente
      task-specification.md  # Solo se pertinente
      task-log.md          # Cronologia
      handoff.md           # Ripresa

[Archivio chat esterno — exporter già esistente, integrazione rinviata]
```

**Attenzione:** questa è un'organizzazione concettuale, non una convenzione definitiva dei percorsi. Le relazioni tra stati non devono essere dedotte automaticamente dalla struttura delle directory.

## 10. Decisioni deliberate da prendere in seguito

### 10.1 Sezione 2 del bootstrap: ultimo tema da affrontare

Resta da progettare con particolare attenzione:

- riconoscimento e interpretazione di comandi espliciti, matrice multidimensionale e prompt libero;
- composizione di più intenti senza imporre una categoria esclusiva;
- identificazione e sovrapposizione di più task;
- selezione, ordine, dipendenze e cooperazione dei documenti operativi;
- scelta tra orchestrazione direttamente nel bootstrap e metodo principale che coordina gli altri;
- gestione di autorizzazioni, incertezze e cambi di perimetro durante l'esecuzione.

### 10.2 Stato e persistenza

Da definire concretamente:

- struttura del registro e del request index, identificativi e riferimenti alle chat;
- formato, risoluzione e versionamento delle baseline;
- politica per **richieste banali**: ogni prompt va indicizzato, ma non è ancora stabilito se debba generare sempre un nuovo task persistente;
- meccanismi di scrittura, aggiornamento, ripresa, coerenza e gestione degli errori;
- criteri e granularità dei checkpoint intermedi;
- criteri effettivi per riconoscere task sovrapposti o distinti;
- regole universali concrete della sezione 1 e azioni definitive della sezione 3;
- futura integrazione dell'exporter delle conversazioni (per ora esclusa).

## 11. Decisioni confermate in sintesi

1. `bootstrap.md` ha **tre sezioni**: premesse universali, analisi/svolgimento, finalizzazione universale.
2. La prima sezione inizia con la **frase obbligatoria esatta** riportata al § 2.1.
3. Le regole universali valgono sempre; il contesto dei task si recupera solo verificandone la pertinenza.
4. La finalizzazione è sempre obbligatoria, ma non implica la conclusione del task né autorizza effetti vietati.
5. La sezione 2 e il coordinamento dei metodi saranno progettati **per ultimi**.
6. `ai-workflow` contiene le regole; `ai-work-state` contiene lo stato persistente.
7. Prompt, task e chat sono entità distinte; un prompt può coinvolgere più task e più intenti.
8. Gli **otto elementi logici** da preservare sono: chat, task registry, request index, task baseline, task state, task specification, task log e handoff.
9. Le chat originali sono fondamentali, ma il loro exporter rimane temporaneamente **esterno** al workflow documentale.
10. Ogni prompt deve poter essere collegato ai task interessati attraverso il request index.
11. La baseline originale è **permanente e immutabile**; le sue revisioni sono non distruttive e richiedono **autorizzazione esplicita**.
12. Lo stato corrente non può legittimare da solo la modifica dell'obiettivo iniziale.
13. Le letture sono minime e selettive, senza importare automaticamente il contesto di task simili.
14. Alla conclusione di ogni prompt si consolidano selettivamente registro, indice, log, stato, specifiche e handoff, rispettando permessi e disponibilità reali.

---

**Perimetro di questa versione:** esclusivamente ricapitolazione delle decisioni approvate e delle questioni ancora aperte. Nessuna modifica ai repository `ai-workflow` o `ai-work-state` è implicata dalla creazione di questo documento.
