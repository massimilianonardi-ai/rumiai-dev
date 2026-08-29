# Handoff — rumiai-test persistence and filesystem snapshot contract

## Stato

Il contratto generale dei test resta definito in:

```text
TESTING.md
```

Il contratto specifico e normativo di `rumiai-test`, inclusi CLI, exit status, persistenza delle run e filesystem snapshot, è definito in:

```text
RUNNER.md
```

Il README di `massimilianonardi-ai/rumiai-tests` è stato allineato e il repository ora contiene `.gitignore` con `.runs/` esclusa da Git.

## Runner minimale

Principio confermato:

> `rumiai-test` osserva l'esecuzione; non la prepara e non determina se il comportamento del target è corretto.

Il contratto runner -> test resta vuoto.

Il runner non passa argomenti o variabili RumiAI-specifiche, non individua target o fixture, non crea workspace temporanei, non cambia CWD, non modifica `HOME` o `TMPDIR`, non prepara setup/cleanup e non implementa una sandbox implicita.

Il contratto test -> runner resta:

```text
stream combinato stdout/stderr
exit status 0..3
```

## CLI canonica

La CLI iniziale è ora:

```text
rumiai-test [options] [--] [selection]
```

Opzioni definite:

```text
--validation
--snapshot=metadata|hash
--snapshot-scope=selection|test|both
--snapshot-root <pathname>
```

`--snapshot-root` è ripetibile.

`selection` assente seleziona l'intera suite. Una directory relativa a `tests/` seleziona un gruppo ricorsivo. Un file `*.test` relativo a `tests/` seleziona un singolo test.

`rumiai-test .` resta vietato. `--snapshot-root .` è invece valido e significa osservare esplicitamente la current working directory ereditata dal runner.

Quando lo snapshot è richiesto, modalità, scope e almeno una root devono essere espliciti: non esistono default impliciti per questa capability.

## Exit status

Test:

```text
0 PASS
1 FAIL
2 SKIP
3 ERROR
```

Runner:

```text
0 SUCCESS
1 FAIL
2 TEST ERROR
3 RUNNER ERROR
```

Precedenza:

```text
RUNNER ERROR > TEST ERROR > FAIL > SUCCESS
```

Uno snapshot richiesto che non può essere completato produce `RUNNER ERROR`. Una differenza filesystem osservata (`CHANGED`) non modifica automaticamente l'esito del test o del runner.

## Persistenza development/validation

Development e validation usano lo stesso formato persistente.

Development run:

```text
.runs/<run-id>/
```

Validation run completata:

```text
sessions/<run-id>/
```

`.runs/` è locale, ignorata da Git e non soggetta inizialmente ad alcuna retention automatica.

`sessions/` contiene evidenza permanente versionabile.

Il runner non esegue automaticamente:

```text
git add
git commit
git push
```

La versionatura delle validation session resta un'operazione Git separata dalla responsabilità del runner.

## Run ID

Forma canonica iniziale:

```text
YYYYMMDDThhmmss+zzzz-PID
```

Esempio:

```text
20260829T075523+0200-18432
```

Il formato evita `:` ed è utilizzabile anche su filesystem Windows.

## Struttura di una run

```text
<run-id>/
├── session
├── results
├── logs/
└── snapshots/        presente solo quando richiesto
```

### `session`

Record a riga singola:

```text
key<TAB>value
```

Contiene soltanto contesto globale osservato dal runner, inclusi almeno quando disponibili/applicabili:

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

Quando lo snapshot è attivo registra anche modalità, scope e root richieste/canonicalizzate.

Il runner non effettua target discovery e non inventa metadata globali del target.

### `results`

Un record elementare per test:

```text
result<TAB>test-id<TAB>observed-termination
```

Non contiene totali aggregati: i totali sono dati derivati.

### `logs/`

Replica la gerarchia degli identificatori dei test.

Ogni log contiene esclusivamente lo stream combinato stdout/stderr prodotto dal relativo `.test`.

## Validation session incompleta/completa

Durante l'esecuzione:

```text
sessions/.<run-id>/
```

Quando il runner completa correttamente la produzione dell'evidenza:

```text
sessions/<run-id>/
```

La presenza di test `FAIL`, `SKIP` o `ERROR` non rende di per sé incompleta la sessione. Il completamento riguarda il runner e la completezza dell'evidenza.

Una validation session completata non viene sovrascritta o modificata dal runner.

## Filesystem snapshot

La capability fa parte della prima versione del runner, ma viene attivata esplicitamente.

Non è una sandbox, non impedisce modifiche e non prova da sola quale processo abbia causato una differenza.

Esiti dell'audit:

```text
CLEAN
CHANGED
ERROR
```

`CLEAN` = nessuna differenza secondo la modalità richiesta.

`CHANGED` = differenza osservata; resta evidenza separata dall'esito del test.

`ERROR` = audit richiesto non completato; produce `RUNNER ERROR`.

## Modalità snapshot

```text
metadata
hash
```

### metadata

Registra almeno, quando applicabile/rappresentabile:

- pathname relativo alla root;
- tipo;
- size dei file regolari;
- mtime dei file regolari con precisione ragionevolmente disponibile;
- mode/permessi;
- target dei symlink.

`atime` non viene usato.

L'`mtime` delle directory non viene usato come indicatore canonico di differenza; per le directory interessano almeno esistenza, tipo e mode/permessi quando rappresentabili.

### hash

Comprende tutto `metadata` e aggiunge per ogni file regolare:

```text
SHA-256
```

Directory e symlink non ricevono hash del contenuto; per i symlink viene confrontato il target.

## Scope snapshot

```text
selection
test
both
```

`selection`:

```text
snapshot before
intera selezione
snapshot after
confronto
```

`test`:

```text
per ogni test:
    snapshot before
    test
    snapshot after
    confronto
```

`both` esegue entrambe le forme di audit.

Lo scope `both` permette anche di distinguere modifiche temporanee osservate durante singoli test e successivamente ripristinate da differenze persistenti al termine dell'intera selezione.

## Root multiple

Ogni `--snapshot-root <pathname>` definisce una root di audit.

L'opzione può essere ripetuta, per esempio per osservare contemporaneamente:

```text
/path/to/rumiai-os
/home
.
```

Ogni root viene risolta/canonicalizzata per quanto consentito dalla piattaforma. Gli entry pathname dello snapshot sono relativi alla rispettiva root.

Root sovrapposte non vengono deduplicate implicitamente: se l'utente richiede `/home` e `/home/user`, entrambe restano osservazioni distinte.

## Esclusione autoreferenziale

Se la directory della run corrente ricade sotto una root osservata, il runner esclude esclusivamente quella directory dalla scansione:

```text
.../.runs/<run-id>/
.../sessions/.<run-id>/
```

Non vengono escluse implicitamente intere directory come:

```text
.dev/
.git/
rumiai-tests/
sessions/
```

perché una modifica imprevista in tali aree può essere proprio parte dell'evidenza ricercata.

## Persistenza snapshot

Quando lo snapshot è attivo:

```text
snapshots/
├── roots
├── selection/        se scope selection o both
└── tests/            se scope test o both
```

`snapshots/roots` associa identificatori interni (`root-001`, `root-002`, ...) alle root richieste/canonicalizzate.

Per `selection` ogni root conserva:

```text
root-NNN.before
root-NNN.after
root-NNN.diff
```

Per `test` viene replicata la gerarchia dell'identificatore del test e ogni test conserva i tre file per ciascuna root.

Snapshot e diff sono evidenza del runner e restano separati sia dai log dei test sia da `results`.

## Commit coinvolti

`massimilianonardi-ai/rumiai-dev`:

- `789728cffdbf0547d06644e8a9ef029a3cbf551b` — `RUNNER.md`: persistenza e filesystem snapshot contract.

`massimilianonardi-ai/rumiai-tests`:

- `e2f455190b34b6e44b7c3820952d1ce5e8d86f71` — README allineato a persistenza/snapshot;
- `6b1b7de97eb791921b19abeaaec8adbbe4ebcaef` — `.gitignore` con `.runs/`.

## Prossimo passo

Il contratto è ora sufficiente per iniziare l'implementazione reale di `rumiai-test`.

L'implementazione iniziale deve includere fin dall'inizio:

- discovery/selezione gerarchica;
- execution/logging/status contract;
- development e validation persistence;
- validation incomplete/completed publication;
- snapshot `metadata` e `hash`;
- scope `selection`, `test`, `both`;
- root multiple;
- audit `CLEAN/CHANGED/ERROR`;
- nessuna API runner -> test;
- nessun workspace/sandbox implicito;
- nessun commit Git automatico.
