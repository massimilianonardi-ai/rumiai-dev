# Decisione — Selettore interattivo degli scope di validation

Date: 2026-09-15  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione corregge il comportamento operativo di `rumiai-validate` quando viene avviato senza argomenti, in particolare da Finder/Files o da un'altra interfaccia grafica.

La terminologia canonica resta **validation scope**. L'espressione conversazionale "resource model disponibili" non introduce un nuovo concetto di prodotto: il launcher elenca gli scope versionati disponibili sotto `rumiai-tests/validation/`.

Il selettore offre inoltre una scelta UI riservata `0` per eseguire in una sola validation session l'intera suite permanente. Questa scelta non introduce un nuovo scope: usa il health scope canonico `rumiai-os-health` e la semantica già esistente del runner secondo cui l'assenza di `selection` seleziona la root `tests/`.

Questa decisione supersede soltanto il precedente comportamento no-arg che selezionava implicitamente la configurazione health/default e, con la revisione corrente, riserva l'indice UI `0` al full-suite health gate. Restano invariati il modello task-scoped, il runner `rumiai-test`, gli exit status e il modello di evidence revision-specific.

## 2. Self-location e current working directory

`rumiai-validate` deve essere indipendente dalla directory corrente dell'operatore.

Ad ogni invocazione il bootstrap deve, prima di caricare la logica evolutiva:

1. risolvere il pathname del proprio eseguibile;
2. derivare da esso la root canonica del checkout `rumiai-tests`;
3. verificare che tale directory sia effettivamente la root Git del repository;
4. eseguire `cd` nella root della suite.

Un avvio da Finder/Files, da una directory diversa o mediante pathname assoluto deve quindi esercitare lo stesso launcher e la stessa suite.

## 3. Self-update obbligatorio ad ogni lancio

Ogni invocazione di `rumiai-validate` deve tentare l'aggiornamento della suite tramite:

```text
git pull --ff-only
```

Il self-update avviene **prima** della discovery degli scope e prima della visualizzazione del menu.

Se l'HEAD di `rumiai-tests` cambia, il bootstrap aggiornato viene riavviato preservando l'eventuale scope passato esplicitamente. Nel caso interattivo senza argomenti, il menu viene quindi costruito soltanto dalla revisione aggiornata.

Restano validi i gate di sicurezza già fissati: nessun pull automatico in presenza di modifiche tracked locali e nessuna riscrittura della storia Git.

## 4. Discovery degli scope

Gli scope versionati sono i file regolari:

```text
validation/<scope-name>.conf
```

presenti nella revisione corrente di `rumiai-tests` dopo il self-update.

Il launcher:

- non mantiene una lista hardcoded degli scope task;
- valida ogni nome con il contratto corrente degli scope;
- ordina deterministicamente i nomi con ordinamento bytewise/C;
- richiede la presenza del health scope canonico `validation/rumiai-os-health.conf` per offrire l'opzione `0`;
- mostra come opzioni `1..N` gli altri scope versionati, escludendo `rumiai-os-health` per evitare una voce duplicata.

Il file storico/compatibile `rumiai-validate.conf` non viene selezionato implicitamente dal percorso no-arg. Può restare nel repository finché una work unit concorrente o materiale storico ne richiede la presenza; questa decisione non ne autorizza la cancellazione o modifica opportunistica.

## 5. Interazione senza argomenti

La forma:

```text
./rumiai-validate
```

mostra dopo il self-update un elenco numerato, con `0` riservato alla full suite e gli scope task correnti numerati da `1`, per esempio:

```text
Available validation scopes:
  0) all tests
  1) resource-model
  2) srv
Select validation scope:
```

L'esempio non è una lista hardcoded degli scope task: il contenuto effettivo di `1..N` dipende dai file `validation/*.conf` presenti nella revisione aggiornata, escluso il health scope canonico che è rappresentato dalla voce `0`.

L'utente inserisce il numero corrispondente.

Input vuoto, non numerico o fuori intervallo non seleziona alcuno scope e deve causare una nuova richiesta. EOF/interruzione dell'input prima di una scelta valida è un errore del launcher.

Il numero è soltanto una scelta UI effimera: non diventa identità persistente dello scope e non viene serializzato nelle evidence.

### 5.1 Opzione `0`: una sessione di tutti i test

La scelta:

```text
0) all tests
```

seleziona internamente il health scope canonico:

```text
rumiai-os-health
```

Lo scope `rumiai-os-health` rappresenta la **root completa `tests/`**, non soltanto il gruppo `rumiai-os/`.

Per preservare il contratto esistente del runner e produrre una sola sessione, la rappresentazione canonica del full-suite health scope è:

- `kind health`;
- `rumiai-os-commit <commit-esatto>`;
- **nessun record `selection`**.

L'assenza di record `selection` è ammessa soltanto per uno scope `health` e significa una singola invocazione:

```text
rumiai-test --validation
```

Il contratto corrente di `rumiai-test` stabilisce già che l'assenza di `selection` seleziona la root `tests/`; non viene quindi introdotto alcun sentinel, alias o pathname artificiale per rappresentare la full suite.

Uno scope `task` senza almeno un record `selection` resta invalido.

La scelta `0` è un health gate e non costituisce task validation di work unit indipendenti.

## 6. Esecuzione diretta nominata

Resta supportata la forma:

```text
./rumiai-validate <scope-name>
```

per automazione, test, CI e invocazioni non interattive.

Questa forma salta il menu ma **non** salta self-location, `cd`, self-update, cleanliness gate, preparazione della revisione target o pubblicazione delle evidence.

In particolare:

```text
./rumiai-validate rumiai-os-health
```

esegue la stessa full-suite health session della scelta interattiva `0`.

## 7. Relazione con scope concorrenti e futuri

Il launcher non crea implicitamente scope a partire da un vecchio `rumiai-validate.conf`, da una selection storica o dal nome di un sottosistema.

Uno scope task compare nel menu soltanto quando una work unit lo ha materializzato correttamente come:

```text
validation/<scope-name>.conf
```

con revisioni e selection coerenti con l'autorità corrente del sottosistema.

Il health scope `rumiai-os-health` è invece il backing scope canonico dell'opzione `0` e non viene duplicato tra le voci `1..N`.

In particolare, eventuali gate Node.js devono seguire la più recente decisione Node.js applicabile. La decisione corrente `2026-09-15-http-fetch-content-length-and-nodejs-size-remediation.md` richiede uno scope task più ampio del solo `external/nodejs`; il selettore non deve quindi reintrodurre come scope corrente il precedente gate live isolato.

Le evidence e le coppie precedenti restano storiche e non vengono reinterpretate.

## 8. Invarianti

```text
VAL-UI-01  rumiai-validate determina la propria root dal proprio pathname e non dalla cwd iniziale
VAL-UI-02  il launcher esegue cd nella root canonica di rumiai-tests prima dell'operatività
VAL-UI-03  ogni lancio tenta git pull --ff-only prima della discovery/menu
VAL-UI-04  il menu no-arg deriva dalla revisione aggiornata; 0 è riservato al backing scope rumiai-os-health e 1..N derivano dagli altri validation/*.conf
VAL-UI-05  l'ordine delle voci 1..N è deterministico
VAL-UI-06  la scelta numerica è soltanto UI e non cambia l'identità dello scope
VAL-UI-07  ./rumiai-validate <scope-name> resta disponibile per uso non interattivo
VAL-UI-08  rumiai-test resta invariato e a singola selection; l'assenza di selection conserva il significato già fissato di root tests/
VAL-UI-09  rumiai-validate.conf non viene implicitamente usato dal percorso no-arg e non viene modificato/cancellato da questa work unit
VAL-UI-10  evidence e sessioni restano revision-specific e immutabili
VAL-UI-11  nessuna modifica a rumiai-os è richiesta dalla modifica del selettore
VAL-UI-12  Git resta forward-only
VAL-UI-13  il menu non sintetizza scope task da decisioni o configurazioni superseded
VAL-UI-14  l'opzione 0 produce una sola validation session dell'intera root tests/
VAL-UI-15  uno scope health senza selection significa full-suite root; uno scope task senza selection è invalido
```

## 9. Testing richiesto

La suite permanente deve verificare almeno:

```text
avvio da cwd estranea
self-update prima della costruzione del menu
menu derivato dalla revisione aggiornata
presenza della voce 0 = all tests
assenza di una seconda voce numerata per rumiai-os-health
ordinamento deterministico delle voci 1..N
scelta 0 -> scope rumiai-os-health
scelta 0 -> una sola invocazione rumiai-test --validation senza selection
scelta numerica task valida -> scope corretto
input non valido -> nuova richiesta
invocazione nominata ancora funzionante
rumiai-os-health nominato -> stessa full-suite health session
scope task senza selection -> errore di configurazione
runner eseguito dalla root della suite
```

La modifica è infrastrutturale lato `rumiai-tests`; non autorizza né richiede modifiche al prodotto `rumiai-os`.
