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

Finché `rumiai-os` non è discoverable autonomamente tramite `PATH`, symlink o altro meccanismo canonico, ogni sessione deve iniziare con un `cd` esplicito verso il repository coinvolto usando il pathname reale dell'host sottoposto a test.

Subito dopo il `cd`, ogni sessione deve eseguire:

```sh
git pull --ff-only
```

Questo garantisce che la sessione eserciti l'HEAD remoto corrente senza introdurre merge impliciti.

I comandi che appartengono alla stessa sessione devono essere forniti all'operatore in un unico blocco di codice quando ragionevolmente possibile. Se una divisione è tecnicamente necessaria, il numero di blocchi deve essere ridotto al minimo.

Il prefisso operativo normale di una sessione è quindi:

```text
cd <repository-path-for-host>
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

Questa evidenza valida fisicamente discovery, execution/persistence, snapshot self-tests e validation-publication self-test del runner sui due host per il commit indicato. Non sostituisce una `--validation` persistita sotto `sessions/`, che costituisce un'attività distinta.
