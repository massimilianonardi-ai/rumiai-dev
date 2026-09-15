# Decisione — Selettore interattivo degli scope di validation

Date: 2026-09-15  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione corregge il comportamento operativo di `rumiai-validate` quando viene avviato senza argomenti, in particolare da Finder/Files o da un'altra interfaccia grafica.

La terminologia canonica resta **validation scope**. L'espressione conversazionale "resource model disponibili" non introduce un nuovo concetto di prodotto: il launcher elenca gli scope versionati disponibili sotto `rumiai-tests/validation/`.

Questa decisione supersede soltanto il precedente comportamento no-arg che selezionava implicitamente la configurazione health/default. Restano invariati il modello task-scoped, la semantica degli scope, il runner `rumiai-test`, gli exit status e il modello di evidence revision-specific.

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

Gli scope selezionabili sono i file regolari:

```text
validation/<scope-name>.conf
```

presenti nella revisione corrente di `rumiai-tests` dopo il self-update.

Il launcher:

- non mantiene una lista hardcoded;
- valida ogni nome con il contratto corrente degli scope;
- ordina deterministicamente i nomi con ordinamento bytewise/C;
- considera errore l'assenza di scope validi.

Il file storico/compatibile `rumiai-validate.conf` non viene selezionato implicitamente dal percorso no-arg. Può restare nel repository finché una work unit concorrente o materiale storico ne richiede la presenza; questa decisione non ne autorizza la cancellazione o modifica opportunistica.

## 5. Interazione senza argomenti

La forma:

```text
./rumiai-validate
```

mostra dopo il self-update un elenco numerato degli scope disponibili, per esempio:

```text
Available validation scopes:
  1) nodejs-live
  2) resource-model
  3) rumiai-os-health
  4) srv
Select validation scope: 
```

L'utente inserisce il numero corrispondente.

Input vuoto, non numerico o fuori intervallo non seleziona alcuno scope e deve causare una nuova richiesta. EOF/interruzione dell'input prima di una scelta valida è un errore del launcher.

Il numero è soltanto una scelta UI effimera: non diventa identità persistente dello scope e non viene serializzato nelle evidence.

## 6. Esecuzione diretta nominata

Resta supportata la forma:

```text
./rumiai-validate <scope-name>
```

per automazione, test, CI e invocazioni non interattive.

Questa forma salta il menu ma **non** salta self-location, `cd`, self-update, cleanliness gate, preparazione della revisione target o pubblicazione delle evidence.

## 7. Relazione con il gate Node.js

Il gate live Node.js già fissato usa:

```text
selection external/nodejs
```

La sua configurazione deve essere resa disponibile come scope nominato, senza cambiare la selection né il contratto del test. Le istruzioni operative che in precedenza indicavano genericamente `./rumiai-validate` devono essere lette, dopo questa decisione, come scelta dello scope Node.js dal menu oppure come invocazione diretta dello scope nominato.

L'eventuale avanzamento della revisione `rumiai-tests` necessaria a rendere eseguibile il gate resta revision-specific e deve essere registrato separatamente; le evidence vecchie non vengono reinterpretate.

## 8. Invarianti

```text
VAL-UI-01  rumiai-validate determina la propria root dal proprio pathname e non dalla cwd iniziale
VAL-UI-02  il launcher esegue cd nella root canonica di rumiai-tests prima dell'operatività
VAL-UI-03  ogni lancio tenta git pull --ff-only prima della discovery/menu
VAL-UI-04  il menu no-arg deriva dinamicamente da validation/*.conf della revisione aggiornata
VAL-UI-05  l'ordine del menu è deterministico
VAL-UI-06  la scelta numerica è soltanto UI e non cambia l'identità dello scope
VAL-UI-07  ./rumiai-validate <scope-name> resta disponibile per uso non interattivo
VAL-UI-08  rumiai-test resta invariato e a singola selection
VAL-UI-09  rumiai-validate.conf non viene implicitamente usato dal percorso no-arg e non viene modificato/cancellato da questa work unit
VAL-UI-10  evidence e sessioni restano revision-specific e immutabili
VAL-UI-11  nessuna modifica a rumiai-os è richiesta
VAL-UI-12  Git resta forward-only
```

## 9. Testing richiesto

La suite permanente deve verificare almeno:

```text
avvio da cwd estranea
self-update prima della costruzione del menu
menu derivato dalla revisione aggiornata
ordinamento deterministico
scelta numerica valida -> scope corretto
input non valido -> nuova richiesta
invocazione nominata ancora funzionante
runner eseguito dalla root della suite
```

La modifica è infrastrutturale lato `rumiai-tests`; non autorizza né richiede modifiche al prodotto `rumiai-os`.
