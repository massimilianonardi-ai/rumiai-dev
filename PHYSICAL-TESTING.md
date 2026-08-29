# RumiAI Physical Testing Rules

Questo documento definisce la procedura operativa per i test fisici che richiedono esecuzione manuale su host reali.

Le regole generali dei test restano in `TESTING.md`; il contratto del runner resta in `RUNNER.md`.

## Sessione fisica

Ogni sessione di comandi si considera iniziata da un terminale appena aperto.

Non si assume quindi che siano già disponibili:

- una current working directory appropriata;
- `RumiAI_ROOT` o altre variabili di ambiente;
- `rumiai-os` o `rumiai-test` nel `PATH`;
- symlink locali verso i repository.

Finché `rumiai-os` non è discoverable autonomamente tramite `PATH`, symlink o altro meccanismo canonico, ogni sessione deve iniziare con un `cd` esplicito verso il repository `rumiai-os` usando il pathname reale dell'host sottoposto a test.

Subito dopo deve essere eseguito:

```sh
git pull --ff-only
```

Questo sincronizza prima di tutto il target che verrà sottoposto a test.

Successivamente la sessione deve entrare nel clone locale di `rumiai-tests`, normalmente sotto `.dev/rumiai-tests/`, ed eseguire nuovamente:

```sh
git pull --ff-only
```

Questo sincronizza la suite di test dopo avere sincronizzato il prodotto.

L'ordine è normativo:

```text
1. cd nel repository rumiai-os dell'host
2. git pull --ff-only di rumiai-os
3. cd nel repository rumiai-tests dell'host
4. git pull --ff-only di rumiai-tests
5. comando del runner
```

In questo modo una sessione non può produrre evidenza contro un checkout stale di `rumiai-os` o contro una suite stale di `rumiai-tests`.

La forma normale di un test fisico deve restare intenzionalmente minima:

```text
cd <rumiai-os-path-for-host>
git pull --ff-only
cd <rumiai-tests-path-for-host>
git pull --ff-only
./rumiai-test <selection>
```

Setup specifico, fixture, directory temporanee, isolamento di `HOME`, pseudo-terminali, input simulato, assert e cleanup appartengono ai file `.test` e non devono essere trasferiti all'operatore come sequenze manuali di shell. Se una proprietà può essere automatizzata in modo affidabile dentro la suite, deve essere automatizzata lì.

I comandi manuali aggiuntivi sono ammessi soltanto quando la proprietà stessa non è ancora rappresentabile dalla suite o quando si sta diagnosticando un fallimento concreto. Non costituiscono la forma normale di validazione fisica.

### Comandi interattivi

Quando un'attività manuale eccezionale richiede realmente un comando che legge direttamente dal terminale, per esempio tramite `/dev/tty`, tale comando costituisce un confine obbligatorio del blocco da incollare.

Non devono essere presenti comandi successivi nello stesso blocco di paste quando il comando interattivo può attendere input. Le righe già incollate possono infatti trovarsi nel buffer del terminale ed essere consumate dal prompt come risposta, anziché essere eseguite successivamente dalla shell.

La regola operativa è quindi:

```text
- i comandi preparatori possono stare nello stesso blocco;
- il comando interattivo deve essere l'ultima riga del blocco;
- eventuali verifiche successive devono stare in un nuovo blocco, eseguito solo dopo che il comando interattivo è terminato;
- se il comando interattivo può fallire o essere annullato, le verifiche successive devono prima controllarne l'exit status e non assumere che lo stato atteso sia stato creato.
```

Questa è un'eccezione per attività manuali diagnostiche, non il modello desiderato per i test permanenti.

## Path correnti degli host di riferimento

macOS:

```text
RumiAI_ROOT=/Volumes/RumiAI/rumiai-os
rumiai-tests=/Volumes/RumiAI/rumiai-os/.dev/rumiai-tests
```

Ubuntu 26.04 ARM64:

```text
RumiAI_ROOT=/m/src/git/rumiai-os
rumiai-tests=/m/src/git/rumiai-os/.dev/rumiai-tests
```

Questi pathname descrivono gli host correnti di test e non fanno parte del contratto dei test permanenti.

## Prima validazione fisica di `rumiai-test`

Il commit di `rumiai-tests`:

```text
551477f8a7e6a209c70318ded3eed4c14aa0eb4a
```

è stato esercitato fisicamente il 2026-08-29 con:

```text
./rumiai-test runner
```

su entrambi gli host stabili di riferimento.

Risultato macOS:

```text
PASS   4
FAIL   0
SKIP   0
ERROR  0
TOTAL  4
```

Risultato Ubuntu 26.04 ARM64:

```text
PASS   4
FAIL   0
SKIP   0
ERROR  0
TOTAL  4
```

Questa evidenza valida fisicamente discovery, execution/persistence, snapshot self-tests e validation-publication self-test del runner sui due host per il commit indicato.

## Seconda validazione fisica di `rumiai-test`

Il 2026-08-29 lo stesso commit è stato esercitato fisicamente su macOS e Ubuntu 26.04 ARM64 con snapshot reali e validation persistita.

Per entrambi gli host:

```text
snapshot metadata / scope selection: PASS 4, CLEAN
snapshot hash / scope both:          PASS 4, tutti gli audit CLEAN
validation runner:                   PASS 4
```

La validation ha pubblicato correttamente una sessione non ancora versionata sotto `sessions/`.

macOS:

```text
sessions/20260829T110426+0200-2339/
```

Ubuntu 26.04 ARM64:

```text
sessions/20260829T110518+0200-16081/
```

`git status --short` ha mostrato in entrambi i casi esclusivamente la nuova directory di validation come untracked, coerentemente con il contratto secondo cui il runner non esegue automaticamente `git add`, `git commit` o `git push`.

Questa seconda sessione ha esercitato realmente i rami host-specifici di metadata/hash snapshot, l'esclusione autoreferenziale della run corrente e la pubblicazione di validation session.

Nota: durante questa seconda sessione `rumiai-os` non era stato sincronizzato esplicitamente all'inizio. Ciò non invalida questi risultati specifici perché i quattro test eseguiti appartengono al gruppo `runner` e non esercitano `rumiai-os`. La procedura è stata successivamente irrigidita imponendo il pull di `rumiai-os` prima del pull di `rumiai-tests` per tutte le sessioni future.

## Bootstrap Git identity: lezione operativa

Nel test isolato del bootstrap con `$HOME` temporanea, una prima esecuzione Ubuntu ha ricevuto accidentalmente una riga del blocco di test al prompt `Git user.email`. Il problema ha mostrato tre aspetti distinti:

- il bootstrap necessitava di validazione e conferma dell'identità prima di scriverla;
- la procedura fisica non deve accodare comandi dopo un programma che legge interattivamente da `/dev/tty`;
- una volta disponibile una suite permanente, isolamento, PTY, input simulato e cleanup devono essere spostati dentro un `.test`, lasciando all'operatore soltanto sincronizzazione dei repository e invocazione del runner.

Il bootstrap è stato quindi irrigidito e il relativo scenario viene trasferito nella suite permanente `rumiai-tests`.
