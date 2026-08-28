# RumiAI Test Runner Contract

Questo documento definisce il contratto canonico del runner `rumiai-test`.

Le regole generali della suite, dei test, dei gruppi, della portabilità, dell'indipendenza e delle sessioni restano definite in `TESTING.md`. Questo documento specifica esclusivamente il comportamento del runner.

## 1. Principio fondamentale

`rumiai-test` deve restare intenzionalmente semplice e agnostico rispetto alla semantica dei test.

> `rumiai-test` osserva l'esecuzione; non la prepara e non determina se il comportamento del target è corretto.

La conoscenza specifica della prova appartiene interamente al singolo file `.test`.

## 2. CLI iniziale

La CLI canonica iniziale è:

```text
rumiai-test [--validation] [selection]
```

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
```

La forma:

```text
rumiai-test .
```

non è ammessa. `.` identifica normalmente la current working directory e introdurrebbe una semantica ambigua rispetto alla root logica `tests/`. Il runner non usa la current working directory come alias della selezione.

La CLI iniziale accetta un solo selettore. Se devono essere eseguiti più test correlati, la relazione deve normalmente essere espressa tramite la gerarchia dei gruppi.

Non vengono introdotte preventivamente opzioni come `--target`, `--host`, `--tmp`, `--jobs`, `--filter`, `--tag`, `--include`, `--exclude`, `--config` o equivalenti finché non emerge una necessità concreta.

## 3. Development run e validation run

La development run è il comportamento predefinito:

```text
rumiai-test [selection]
```

La validation run viene richiesta esplicitamente:

```text
rumiai-test --validation [selection]
```

Development e validation devono eseguire lo stesso `.test` nello stesso modo. `--validation` modifica soltanto i controlli e la conservazione dell'evidenza attorno all'esecuzione; non modifica la logica interna del test né introduce un ambiente differente.

Durante una development run le working tree possono essere dirty e l'esecuzione non costituisce evidenza formale di validazione di un commit.

Durante una validation run si applicano i requisiti definiti in `TESTING.md`, inclusi i controlli sulle revisioni e sulla pulizia delle working tree quando applicabili.

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
- qualunque condizione del runner che renda impossibile proseguire o considerare completa la run.

La precedenza semantica è:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

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

Il formato preciso potrà essere raffinato durante l'implementazione senza alterare il contratto semantico qui definito.

## 12. Sessioni e persistenza

La struttura esatta dei file di development run e validation run viene definita separatamente prima dell'implementazione stabile.

Restano già fissati questi principi:

- i log dei test devono essere distinti dai metadata globali;
- ogni test deve avere un log combinato stdout/stderr;
- le validation run devono produrre evidenza permanente sotto `sessions/`;
- development e validation eseguono gli stessi test con la stessa semantica;
- la sessione deve registrare le caratteristiche dell'host necessarie a interpretare i risultati.
