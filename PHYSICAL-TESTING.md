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
5. comandi del test fisico
```

In questo modo una sessione non può produrre evidenza contro un checkout stale di `rumiai-os` o contro una suite stale di `rumiai-tests`.

I comandi che appartengono alla stessa sessione devono essere forniti all'operatore in un unico blocco di codice quando ragionevolmente possibile. Se una divisione è tecnicamente necessaria, il numero di blocchi deve essere ridotto al minimo.

Il prefisso operativo normale di una sessione è quindi:

```text
cd <rumiai-os-path-for-host>
git pull --ff-only
cd <rumiai-tests-path-for-host>
git pull --ff-only
<physical-test-commands>
```

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
