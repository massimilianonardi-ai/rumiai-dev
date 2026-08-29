# RumiAI Test Runner Contract

Questo documento definisce il contratto canonico del runner `rumiai-test`.

Le regole generali della suite, dei test, dei gruppi, della portabilità e dell'indipendenza restano definite in `TESTING.md`. Questo documento specifica il comportamento del runner, la persistenza delle run e la capability di filesystem snapshot.

## 1. Principio fondamentale

`rumiai-test` deve restare intenzionalmente semplice e agnostico rispetto alla semantica dei test.

> `rumiai-test` osserva l'esecuzione; non la prepara e non determina se il comportamento del target è corretto.

La conoscenza specifica della prova appartiene interamente al singolo file `.test`.

## 2. CLI iniziale

La CLI canonica iniziale è:

```text
rumiai-test [options] [--] [selection]
```

Le opzioni iniziali definite sono:

```text
--validation
--snapshot=metadata|hash
--snapshot-scope=selection|test|both
--snapshot-root <pathname>
```

`--snapshot-root` è ripetibile.

Dove:

- `selection` assente seleziona il gruppo radice `tests/` e quindi l'intera suite;
- `selection` uguale al pathname relativo a `tests/` di una directory seleziona quel gruppo e tutti i test contenuti ricorsivamente;
- `selection` uguale al pathname relativo a `tests/` di un file `*.test` seleziona quel singolo test.

Esempi:

```text
rumiai-test
rumiai-test rumiai-os/bootstrap
rumiai-test rumiai-os/bootstrap/path/absolute.test
rumiai-test --validation
rumiai-test --validation rumiai-os/bootstrap
rumiai-test --validation --snapshot=hash --snapshot-scope=test --snapshot-root /path/to/rumiai-os --snapshot-root /home -- rumiai-os/bootstrap
rumiai-test --snapshot=metadata --snapshot-scope=selection --snapshot-root . -- rumiai-os/log
```

La forma:

```text
rumiai-test .
```

non è ammessa. `.` identifica normalmente la current working directory e introdurrebbe una semantica ambigua rispetto alla root logica `tests/`. Il runner non usa la current working directory come alias della selezione.

La forma:

```text
--snapshot-root .
```

è invece valida e non ambigua: `.` è in quel caso il pathname della root da osservare e identifica la current working directory ereditata dal runner. Il runner non cambia la current working directory.

La CLI iniziale accetta un solo selettore. Se devono essere eseguiti più test correlati, la relazione deve normalmente essere espressa tramite la gerarchia dei gruppi.

`--` separa esplicitamente le opzioni dal selettore quando necessario o desiderato.

Non vengono introdotte preventivamente opzioni come `--target`, `--host`, `--tmp`, `--jobs`, `--filter`, `--tag`, `--include`, `--exclude`, `--config` o equivalenti finché non emerge una necessità concreta.

## 3. Development run e validation run

La development run è il comportamento predefinito:

```text
rumiai-test [options] [--] [selection]
```

La validation run viene richiesta esplicitamente:

```text
rumiai-test --validation [options] [--] [selection]
```

Development e validation devono eseguire lo stesso `.test` nello stesso modo. `--validation` modifica soltanto i controlli e la conservazione dell'evidenza attorno all'esecuzione; non modifica la logica interna del test né introduce un ambiente differente.

Durante una development run le working tree possono essere dirty e l'esecuzione non costituisce evidenza formale di validazione di un commit.

Durante una validation run si applicano i requisiti definiti in `TESTING.md`, inclusi i controlli sulle revisioni e sulla pulizia delle working tree quando applicabili.

Il runner non esegue automaticamente `git add`, `git commit`, `git push` o altre modifiche alla storia Git. La responsabilità del runner termina con la produzione dell'evidenza della validation run sotto `sessions/`. La successiva versionatura dell'evidenza è un'operazione Git distinta.

## 4. Selezione e discovery

Il runner individua la propria suite e applica le regole canoniche di discovery definite in `TESTING.md`:

1. `*.test` identifica un test;
2. ogni directory normale sotto `tests/` identifica un gruppo;
3. pathname il cui nome inizia con `.` sono esclusi dalla discovery;
4. ogni altro file viene ignorato.

Una selezione di gruppo viene attraversata ricorsivamente.

Quando l'esecuzione è seriale, test e sottogruppi vengono attraversati in ordine lessicografico deterministico dei rispettivi identificatori.

Un gruppo selezionato che non contiene alcun test valido è un errore del runner e non uno `SKIP`.

## 5. Contratto runner -> test

Il contratto runner -> test è vuoto.

Il runner non deve:

- passare argomenti RumiAI-specifici al test;
- definire variabili d'ambiente RumiAI-specifiche;
- comunicare target, test-id, directory temporanee o metadata;
- individuare il target per conto del test;
- individuare fixture o file di supporto;
- preparare setup o cleanup;
- creare workspace temporanei impliciti;
- cambiare la current working directory per preparare il test;
- modificare `HOME`, `TMPDIR` o altre variabili per costruire un ambiente artificiale;
- implementare una sandbox implicita;
- fornire assertion o altra logica di test specifica.

Il test eredita il normale contesto del processo nel quale viene avviato e contiene autonomamente tutta la logica necessaria alla verifica.

Le opzioni di filesystem snapshot appartengono esclusivamente all'osservazione svolta dal runner e non vengono comunicate al test.

## 6. Contratto test -> runner

Il contratto test -> runner è limitato ai normali meccanismi del processo:

```text
stream combinato stdout/stderr
exit status 0..3
```

Gli exit status validi del singolo test sono:

```text
0 = PASS
1 = FAIL
2 = SKIP
3 = ERROR
```

Qualunque altro exit status prodotto dal processo `.test` viola il contratto del test e viene registrato dal runner come `ERROR` del test.

Se il processo `.test` termina per un segnale prima di produrre un esito valido, il runner registra il modo reale di terminazione nella diagnostica della sessione e classifica il test come `ERROR`.

Questo è distinto dal caso in cui il test verifica intenzionalmente che il target sotto test termini per un segnale: in quel caso è il test a osservare il target e a restituire `PASS`, `FAIL`, `SKIP` o `ERROR` secondo il proprio contratto.

## 7. Logging del test

Il runner cattura `stdout` e `stderr` del processo `.test` in un unico stream ordinato secondo un modello equivalente a:

```sh
1>logfile 2>&1
```

I due stream non devono essere conservati separatamente per poi tentare di ricostruirne l'ordine tramite timestamp.

Il log di un test contiene esclusivamente ciò che il processo di test ha prodotto. Il runner non inserisce nel log del test metadata globali della sessione.

Contesto globale, risultato osservato dal runner, tempi e altre informazioni di sessione vengono conservati separatamente.

## 8. Responsabilità del runner

Le responsabilità iniziali del runner sono:

- individuare la propria suite;
- validare la CLI;
- selezionare il test o gruppo richiesto;
- applicare discovery e ordine canonici;
- raccogliere il contesto globale dell'host e della sessione;
- eseguire direttamente ciascun `.test` rispettandone il shebang;
- catturare il log combinato;
- raccogliere e classificare l'exit status del test;
- continuare con gli altri test quando un singolo test produce `FAIL` o `ERROR`, salvo che un errore del runner renda impossibile proseguire;
- produrre un riepilogo leggibile;
- salvare risultati, log e metadati della run;
- eseguire, quando richiesto, l'audit del filesystem tramite snapshot;
- nelle validation run, conservare l'evidenza permanente richiesta da `TESTING.md`.

Il runner non interpreta semanticamente l'output del test per stabilire se il target è corretto.

## 9. Exit status del runner

Gli exit status semantici del runner sono:

```text
0 = SUCCESS
1 = FAIL
2 = TEST ERROR
3 = RUNNER ERROR
```

### 0 — SUCCESS

La run è stata completata e nessun test ha prodotto `FAIL` o `ERROR`.

Possono essere presenti test `PASS` e `SKIP`.

Una run composta esclusivamente da `SKIP` è comunque completata con status `0`; il riepilogo e la sessione devono rendere evidente che nessuna delle proprietà selezionate è stata effettivamente validata.

### 1 — FAIL

La run è stata completata, almeno un test ha prodotto `FAIL` e nessun test ha prodotto `ERROR`.

### 2 — TEST ERROR

La run è stata completata o ha potuto proseguire fino alla normale conclusione, ma almeno un test è stato classificato `ERROR`.

La presenza contemporanea di `FAIL` ed `ERROR` produce status `2`.

### 3 — RUNNER ERROR

Il runner non è riuscito a completare correttamente la run per un errore dell'infrastruttura di esecuzione o dell'invocazione.

Esempi includono:

- CLI invalida;
- selezione inesistente o non valida;
- gruppo selezionato privo di test;
- impossibilità di accedere alla suite;
- impossibilità di creare o conservare i file necessari alla run;
- errore interno del runner;
- precondizione obbligatoria di una validation run non soddisfatta;
- impossibilità di completare uno snapshot esplicitamente richiesto;
- qualunque condizione del runner che renda impossibile proseguire o considerare completa la run.

La precedenza semantica è:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

Un risultato filesystem `CHANGED` non modifica automaticamente l'exit status del test o del runner. Un risultato filesystem `ERROR` indica invece che una capability di audit esplicitamente richiesta non è stata completata e produce `RUNNER ERROR`.

## 10. Interruzione esterna del runner

Se `rumiai-test` viene interrotto esternamente da un segnale, non deve mascherare artificialmente tale evento come `RUNNER ERROR=3`.

Il processo deve preservare, per quanto possibile e coerente con la piattaforma, la normale semantica di terminazione da segnale osservabile dalla shell, per esempio tipicamente:

```text
SIGINT  -> 130
SIGTERM -> 143
```

Questi valori non fanno parte degli exit status semantici `0..3` del runner: descrivono una interruzione esterna del processo.

## 11. Output terminale iniziale

Durante una esecuzione seriale il runner deve mostrare almeno l'identificatore e l'esito di ogni test, per esempio:

```text
PASS   rumiai-os/bootstrap/absolute.test
PASS   rumiai-os/bootstrap/relative.test
FAIL   rumiai-os/bootstrap/symlink-chain.test
```

Al termine deve mostrare un riepilogo almeno equivalente a:

```text
PASS   2
FAIL   1
SKIP   0
ERROR  0
TOTAL  3
```

Quando l'audit filesystem è attivo, il runner deve rendere visibili anche gli esiti `CLEAN`, `CHANGED` o `ERROR` delle osservazioni richieste senza confonderli con gli esiti dei test.

Per `FAIL` e `ERROR` il runner può mostrare a terminale anche il contenuto del relativo log per rendere utile il ciclo di sviluppo. La copia persistente del log resta comunque separata e invariata.

Il formato preciso dell'output terminale potrà essere raffinato durante l'implementazione senza alterare il contratto semantico qui definito.

## 12. Directory delle run

Development run e validation run usano lo stesso formato persistente.

Le development run vengono conservate localmente sotto:

```text
.runs/
```

`.runs/` deve essere ignorata da Git e non è evidenza permanente.

Le validation run completate vengono conservate sotto:

```text
sessions/
```

Una validation session completata costituisce evidenza permanente ed è destinata a poter essere versionata nel repository. Il runner non ne esegue automaticamente il commit.

Il runner non applica inizialmente alcuna retention automatica a `.runs/`: non elimina run vecchie in base al numero, all'età o ad altre policy implicite.

## 13. Identificatore della run

L'identificatore iniziale della run deriva da data/ora locale con offset e da un discriminante di processo, usando caratteri sicuri anche per filesystem Windows.

Forma canonica:

```text
YYYYMMDDThhmmss+zzzz-PID
```

Esempio:

```text
20260829T075523+0200-18432
```

L'identificatore deve essere univoco all'interno della directory di destinazione. Non vengono introdotti UUID finché non emerge una necessità concreta.

## 14. Struttura persistente di una run

La struttura base è:

```text
<run-id>/
├── session
├── results
├── logs/
└── snapshots/        presente solo quando richiesto
```

I file e le directory di una development run e di una validation run hanno la stessa semantica.

### `session`

`session` contiene esclusivamente informazioni globali osservate dal runner.

Il formato iniziale è una sequenza di record a riga singola:

```text
key<TAB>value
```

Il runner deve normalizzare a una singola riga i valori che potrebbero contenere newline; `session` non è destinato a contenere dump grezzi.

Deve registrare almeno, quando disponibili e materialmente applicabili:

```text
type
start
end
selection
os
os-version
architecture
kernel
hostname
rumiai-tests-commit
runner-exit-status
```

Quando lo snapshot è attivo deve registrare anche modalità, scope e root richieste/canonicalizzate sufficienti a interpretare l'audit.

Il runner non effettua target discovery e quindi non inventa campi generici `target`, `target-commit` o `target-version`. Informazioni specifiche del target appartengono alla logica del test e possono comparire nel log del test quando rilevanti.

### `results`

`results` contiene un record elementare per ogni test nello stesso ordine deterministico di esecuzione.

Formato iniziale:

```text
result<TAB>test-id<TAB>observed-termination
```

Esempi:

```text
PASS	rumiai-os/bootstrap/absolute.test	0
FAIL	rumiai-os/bootstrap/symlink-chain.test	1
SKIP	rumiai-os/shell/bash.test	2
ERROR	rumiai-os/log/foo.test	42
```

Per terminazioni anomale il terzo campo deve conservare, per quanto la piattaforma consente, l'informazione realmente osservata invece di fingere che il test abbia restituito `3`.

`results` non contiene totali aggregati. I conteggi `PASS/FAIL/SKIP/ERROR/TOTAL` sono dati derivati e vengono calcolati dal runner quando necessari.

### `logs/`

`logs/` replica la gerarchia degli identificatori dei test.

Esempio:

```text
test:
rumiai-os/bootstrap/path/symlink-chain.test

log:
logs/rumiai-os/bootstrap/path/symlink-chain.test.log
```

Ogni log contiene esclusivamente lo stream combinato `stdout/stderr` del relativo `.test`. Un log vuoto è valido.

## 15. Completamento e immutabilità delle validation session

Durante una validation run la directory di sessione viene inizialmente creata con nome nascosto:

```text
sessions/.<run-id>/
```

Soltanto quando il runner ha completato correttamente la propria attività e ha scritto l'evidenza necessaria la directory viene rinominata atomicamente, quando supportato dalla piattaforma e dal filesystem, in:

```text
sessions/<run-id>/
```

`FAIL`, `SKIP` o `ERROR` dei singoli test non rendono di per sé incompleta una sessione. Una sessione con test falliti può essere un'evidenza completa e valida.

Un errore del runner o un'interruzione che impedisce il completamento lascia invece la directory nascosta/incompleta, quando è possibile conservarla utilmente per diagnosi.

Una validation session completata non deve essere modificata o sovrascritta dal runner. Una nuova esecuzione produce una nuova sessione.

## 16. Filesystem snapshot: ruolo

La capability di filesystem snapshot fa parte della prima versione del runner.

È una funzione di audit esplicita e opzionale: non è una sandbox, non impedisce modifiche e non dimostra da sola quale processo abbia causato una differenza osservata.

La capability osserva una o più root prima e dopo intervalli di esecuzione e confronta gli snapshot risultanti.

Il risultato dell'audit filesystem è distinto dal risultato del test:

```text
CLEAN
CHANGED
ERROR
```

Semantica:

- `CLEAN`: gli snapshot confrontati non mostrano differenze secondo la modalità richiesta;
- `CHANGED`: il filesystem osservato differisce tra i due snapshot;
- `ERROR`: il runner non è riuscito a completare integralmente l'audit richiesto.

`CHANGED` è evidenza osservativa e non viene convertito automaticamente in `FAIL` o `ERROR` del test. `ERROR` della capability è un errore del runner perché un audit esplicitamente richiesto non è stato completato.

## 17. Filesystem snapshot: modalità

Sono definite due modalità:

```text
metadata
hash
```

### `metadata`

Per ogni entry osservata deve registrare almeno, quando applicabile e rappresentabile in modo affidabile sulla piattaforma:

- pathname relativo alla root;
- tipo di entry;
- dimensione dei file regolari;
- timestamp di ultima modifica dei file regolari con la massima precisione ragionevolmente disponibile;
- mode/permessi;
- target dei symlink.

Per le directory non si usa il loro `mtime` come indicatore di differenza, perché operazioni del runner o variazioni interne escluse dallo snapshot possono modificarlo senza rappresentare una differenza utile dell'albero osservato. Per le directory interessano almeno esistenza, tipo e mode/permessi quando rappresentabili.

`atime` non fa parte dello snapshot canonico perché la stessa scansione, soprattutto in modalità `hash`, può influenzarlo.

### `hash`

La modalità `hash` contiene tutte le informazioni della modalità `metadata` e aggiunge per ogni file regolare un hash del contenuto.

L'algoritmo canonico è:

```text
SHA-256
```

L'utility concreta utilizzata per calcolare SHA-256 può differire tra host purché il valore semantico risultante sia lo stesso.

Non viene calcolato un hash del contenuto per directory o symlink; per i symlink viene registrato il target.

## 18. Filesystem snapshot: scope

Sono definiti tre scope:

```text
selection
test
both
```

### `selection`

Per ogni root richiesta:

```text
snapshot before
esecuzione completa della selezione
snapshot after
confronto
```

### `test`

Per ogni test e per ogni root richiesta:

```text
snapshot before
esecuzione del singolo test
snapshot after
confronto
```

Questo restringe l'intervallo nel quale una differenza è stata osservata e permette di associarla temporalmente a un singolo test, senza affermare automaticamente che il test ne sia la causa.

### `both`

Esegue sia l'audit `selection` sia l'audit `test`.

`both` permette di distinguere, tra gli altri casi, modifiche temporanee osservate durante singoli test ma ripristinate entro il termine della selezione da modifiche ancora presenti al termine dell'intera run.

## 19. Filesystem snapshot: root

Una richiesta di snapshot deve specificare almeno una root tramite:

```text
--snapshot-root <pathname>
```

L'opzione è ripetibile e permette di osservare più root nella stessa run.

Esempi di root valide includono, quando accessibili:

```text
/path/to/rumiai-os
/home
.
```

Il runner non deduplica implicitamente root sovrapposte. Se vengono richieste sia `/home` sia `/home/user`, entrambe sono osservazioni esplicite e distinte.

All'avvio il runner deve risolvere e canonicalizzare ogni root per quanto consentito dalla piattaforma e registrare almeno il pathname richiesto e quello effettivamente osservato.

Gli entry pathname contenuti negli snapshot sono relativi alla rispettiva root canonicalizzata.

Quando lo snapshot è richiesto, `--snapshot`, `--snapshot-scope` e almeno un `--snapshot-root` devono essere specificati esplicitamente. Il runner non assume implicitamente una root, una modalità o uno scope.

## 20. Esclusioni dello snapshot

Il runner deve escludere dallo snapshot esclusivamente la directory della run corrente che esso stesso sta generando, se tale directory ricade sotto una delle root osservate.

Esempi:

```text
.../rumiai-tests/.runs/<run-id>/
.../rumiai-tests/sessions/.<run-id>/
```

L'esclusione serve a impedire che i file di evidenza creati dal runner producano differenze autoreferenziali.

Il runner non deve escludere implicitamente intere directory come `.dev/`, `rumiai-tests/`, `sessions/`, `.git/` o altre aree: una modifica imprevista in tali directory può essere parte dell'evidenza che l'audit deve rilevare.

## 21. Persistenza degli snapshot

Quando la capability è attiva la run contiene:

```text
snapshots/
```

La mappa delle root viene conservata in:

```text
snapshots/roots
```

con identificatori stabili all'interno della run, per esempio:

```text
root-001
root-002
root-003
```

Per scope `selection` la struttura è:

```text
snapshots/
├── roots
└── selection/
    ├── root-001.before
    ├── root-001.after
    ├── root-001.diff
    ├── root-002.before
    ├── root-002.after
    └── root-002.diff
```

Per scope `test` viene replicata la gerarchia dell'identificatore del test:

```text
snapshots/
├── roots
└── tests/
    └── rumiai-os/
        └── bootstrap/
            └── absolute.test/
                ├── root-001.before
                ├── root-001.after
                ├── root-001.diff
                ├── root-002.before
                ├── root-002.after
                └── root-002.diff
```

Con scope `both` sono presenti entrambe le strutture.

Gli snapshot e i diff sono evidenza del runner e restano separati sia dal log del test sia dal file `results`.

## 22. Semplicità e portabilità

La prima implementazione deve privilegiare primitive semplici e disponibili sulla piattaforma, mantenendo il contratto semantico uniforme tra gli host di riferimento.

È ammessa una piccola implementazione host-specifica all'interno del runner quando necessaria per normalizzare una capability del runner, per esempio per ottenere metadata filesystem o SHA-256 con utility differenti. Tale differenza non deve essere esposta ai test e non deve modificare il contratto test/runner.

Non devono essere introdotti parser o formati complessi quando una rappresentazione lineare deterministica e confrontabile è sufficiente.
