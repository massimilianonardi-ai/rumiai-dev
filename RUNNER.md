# RumiAI Test Runner Contract

Questo documento definisce il contratto canonico di `rumiai-test`.

Le regole generali della suite, dei validation scope e della task validation sono in `TESTING.md`.

## 1. Principio fondamentale

`rumiai-test` resta intenzionalmente semplice e agnostico rispetto alla semantica del target.

> `rumiai-test` osserva l'esecuzione; non prepara il target e non decide quali proprietà servano a chiudere un task.

La scelta dello scope di validation appartiene al launcher/configurazione di validation, non al runner.

## 2. CLI

La CLI canonica resta:

```text
rumiai-test [options] [--] [selection]
```

Opzioni correnti:

```text
--validation
--snapshot=metadata|hash
--snapshot-scope=selection|test|both
--snapshot-root <pathname>
```

`--snapshot-root` è ripetibile.

`selection` assente seleziona la root `tests/`; un pathname di directory seleziona ricorsivamente il gruppo; un pathname `*.test` seleziona il singolo test.

Il runner continua intenzionalmente ad accettare una sola selection per run. La necessità di validare più selection di uno stesso work unit è gestita da `rumiai-validate`, che può eseguire più validation run elementari e aggregarne l'esito di scope.

La forma `rumiai-test .` non è ammessa. `--snapshot-root .` resta valida.

## 3. Development e validation run

Development e validation eseguono lo stesso `.test` nello stesso modo.

`--validation` aggiunge controlli di riproducibilità e persistenza dell'evidenza; non cambia la logica interna del test.

Il runner non esegue `git add`, `commit`, `push`, checkout o aggiornamenti del target.

## 4. Discovery e ordine

Il runner applica le regole di `TESTING.md`:

1. `*.test` identifica un test;
2. directory normali sono gruppi;
3. pathname nascosti sono esclusi;
4. altri file sono ignorati.

Una selection di gruppo è ricorsiva. In esecuzione seriale l'ordine è lessicografico deterministico e semanticamente irrilevante.

Un gruppo selezionato senza test è `RUNNER ERROR`.

## 5. Contratto runner -> test

Il contratto resta vuoto.

Il runner non comunica target, test-id, temp directory o metadata RumiAI-specifici; non prepara setup/cleanup; non cambia CWD; non modifica `HOME`/`TMPDIR`; non fornisce assertion o sandbox implicite.

Un test può usare librerie condivise di `rumiai-tests` localizzandole autonomamente dalla propria posizione. Tali librerie non sono servizi del runner.

## 6. Contratto test -> runner

Il contratto è:

```text
stdout/stderr combinati
exit status 0..3
```

```text
0 PASS
1 FAIL
2 SKIP
3 ERROR
```

Qualunque altro exit status o terminazione anomala viene registrato come `ERROR` con la terminazione realmente osservata quando possibile.

## 7. Logging

Il runner cattura stdout e stderr in un unico stream equivalente a:

```sh
1>logfile 2>&1
```

Il log del test contiene soltanto output del test. Metadata globali, risultato e timing restano separati.

## 8. Responsabilità del runner

Il runner:

- individua la suite;
- valida la CLI;
- risolve la selection;
- esegue discovery;
- raccoglie contesto host/sessione;
- esegue ciascun `.test` rispettandone lo shebang;
- cattura il log combinato;
- classifica l'exit status;
- continua dopo FAIL/ERROR del singolo test salvo errore infrastrutturale;
- produce riepilogo;
- persiste run/sessione;
- esegue snapshot quando richiesto.

Non interpreta semanticamente output o fallimenti per decidere la correttezza del target.

## 9. Exit status del runner

```text
0 SUCCESS
1 FAIL
2 TEST ERROR
3 RUNNER ERROR
```

- `0`: nessun FAIL/ERROR; possono essere presenti PASS e SKIP;
- `1`: almeno un FAIL e nessun ERROR;
- `2`: almeno un ERROR;
- `3`: il runner non ha potuto completare correttamente la run.

Precedenza:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

Il runner status descrive **la sessione**, non la task validation. Un launcher di task scope può considerare non validato uno scope contenente SKIP richiesti pur quando il runner restituisce `0`.

Un'interruzione esterna preserva per quanto possibile la normale semantica di segnale (es. 130/143) e non viene mascherata come status semantico 0..3.

## 10. Output terminale

Durante una run seriale il runner mostra almeno test-id ed esito. Al termine mostra i conteggi PASS/FAIL/SKIP/ERROR/TOTAL.

Per FAIL/ERROR può mostrare anche il log pertinente.

## 11. Persistenza

Development run:

```text
.runs/<run-id>/
```

Validation run completata:

```text
sessions/<run-id>/
```

Formato run-id:

```text
YYYYMMDDThhmmss+zzzz-PID
```

Struttura base:

```text
<run-id>/
├── session
├── results
├── logs/
└── snapshots/   # solo se richiesto
```

Durante una validation la directory è inizialmente `sessions/.<run-id>/` e viene resa visibile soltanto al completamento della run.

FAIL/SKIP/ERROR dei test non rendono incompleta una sessione; un runner error può lasciarla nascosta/incompleta.

Una sessione completata è immutabile.

## 12. File `session`

Formato:

```text
key<TAB>value
```

Registra almeno quando applicabile:

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

Il runner non effettua target discovery e non inventa metadata generici del target.

## 13. File `results`

Un record per test:

```text
result<TAB>test-id<TAB>observed-termination
```

I totali sono derivati, non memorizzati come record duplicati.

`logs/` replica la gerarchia dei test-id; un log vuoto è valido.

## 14. Filesystem snapshot

La capability snapshot resta osservativa, esplicita e opzionale. Non è una sandbox.

Esiti snapshot:

```text
CLEAN
CHANGED
ERROR
```

`CHANGED` non cambia automaticamente l'esito del test. `ERROR` di un audit richiesto produce `RUNNER ERROR`.

Modalità:

```text
metadata
hash
```

`hash` include metadata più SHA-256 dei file regolari.

Scope:

```text
selection
test
both
```

Le root sono fornite con `--snapshot-root`, possono essere multiple e vengono canonicalizzate/registrate.

Il runner esclude soltanto la directory della run corrente quando ricade nella root osservata; non esclude implicitamente `.git`, `sessions`, `rumiai-tests` o altre aree.

Gli snapshot sono persistiti separatamente dai log e dai risultati.

## 15. Relazione con `rumiai-validate`

`rumiai-test` resta l'unico runner canonico.

`rumiai-validate` può:

- self-update della suite;
- usare una configurazione di validation scope;
- preparare l'esatta revisione target senza modificare il checkout principale;
- invocare il runner una o più volte, una selection per run;
- pubblicare le sessioni;
- aggregare gli esiti per stabilire se lo scope task è validato.

Queste responsabilità non vengono spostate nel runner.

## 16. Semplicità e portabilità

Il runner deve privilegiare rappresentazioni lineari, primitive semplici e comportamento uniforme tra host.

Una piccola normalizzazione host-specifica è ammessa soltanto per implementare capability del runner come metadata filesystem o SHA-256, senza contaminare il contratto dei test.
