# Handoff — rumiai-test CLI and status contract

## Stato

Il contratto generale della suite resta definito in `TESTING.md`.

Il contratto specifico e normativo del runner è ora definito in:

```text
RUNNER.md
```

`rumiai-tests/README.md` è stato allineato al nuovo contratto.

## CLI canonica iniziale

```text
rumiai-test [--validation] [selection]
```

Semantica:

```text
selection assente
    gruppo radice tests/ / intera suite

selection = directory relativa a tests/
    gruppo ricorsivo

selection = file *.test relativo a tests/
    singolo test
```

Esempi validi:

```text
rumiai-test
rumiai-test rumiai-os/bootstrap
rumiai-test rumiai-os/bootstrap/path/absolute.test
rumiai-test --validation
rumiai-test --validation rumiai-os/bootstrap
```

La forma `rumiai-test .` è esplicitamente vietata perché `.` identifica normalmente la current working directory e sarebbe ambiguo rispetto alla root logica `tests/`.

La CLI iniziale accetta un solo selettore.

## Contratto runner/test

Il contratto runner -> test è vuoto.

Il runner non passa argomenti o variabili RumiAI-specifiche, non individua target o fixture, non crea workspace temporanei, non cambia CWD, non modifica `HOME` o `TMPDIR`, non prepara setup/cleanup e non implementa sandbox implicite.

Il contratto test -> runner è:

```text
stream combinato stdout/stderr
exit status 0..3
```

Gli status validi del singolo test restano:

```text
0 PASS
1 FAIL
2 SKIP
3 ERROR
```

Status del `.test` fuori da `0..3` o terminazione del test per segnale prima di un esito valido vengono classificati come `ERROR` del test.

## Logging

Il runner cattura stdout e stderr in un unico stream secondo un modello equivalente a:

```sh
1>logfile 2>&1
```

Il log del test contiene solo ciò che il processo `.test` ha prodotto. Metadata globali e risultati osservati dal runner restano separati.

## Exit status del runner

Contratto approvato:

```text
0 = SUCCESS
1 = FAIL
2 = TEST ERROR
3 = RUNNER ERROR
```

Precedenza:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

Semantica:

- `0`: run completata senza `FAIL` o `ERROR`; possono esserci `SKIP`;
- `1`: almeno un `FAIL`, nessun `ERROR`;
- `2`: almeno un test `ERROR`, anche in presenza di `FAIL`;
- `3`: errore del runner o run non completabile correttamente.

Una selezione inesistente/invalida o un gruppo selezionato senza test produce `RUNNER ERROR=3`.

Se il runner stesso viene interrotto da un segnale, non deve mascherare l'evento come `3`; deve preservare per quanto possibile la normale semantica di terminazione da segnale della piattaforma.

## Development e validation

La development run è il default.

`--validation` non cambia il modo in cui il `.test` viene eseguito. Cambia solo i controlli e la persistenza dell'evidenza attorno all'esecuzione.

## Prossimo passo

Definire la struttura persistente esatta di development run e validation run:

- directory locale delle development run;
- naming della sessione;
- file metadata/session;
- file results;
- gerarchia logs;
- formato machine-readable minimo;
- cosa mostrare a terminale per `FAIL`/`ERROR`;
- eventuale retention delle development run.

Dopo questa decisione il contratto è sufficiente per implementare la prima versione reale di `rumiai-test` e iniziare la conversione della matrice Phase 1 in test permanenti.
