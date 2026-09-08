# Decisione — Launcher operativo per le validation run

Date: 2026-09-08  
Status: **Accepted**  
Updated: 2026-09-08

## Contesto

Le validation run permanenti sono eseguite da `rumiai-test --validation`, ma l'operatore non deve ripetere manualmente aggiornamenti dei checkout, cambio directory, verifica della revisione, costruzione della selezione o gestione delle sessioni completate.

Il runner `rumiai-test` resta agnostico rispetto al target e non acquisisce responsabilita di aggiornamento Git, target discovery, configurazione operativa o pubblicazione remota dell'evidenza.

Il comando operativo normale e soltanto:

```text
./rumiai-validate
```

La correzione approvata il 2026-09-08 aggiunge inoltre la pubblicazione automatica e durevole delle validation session completate. Questa correzione sostituisce il precedente divieto assoluto di `commit`/`push` nel launcher con un'eccezione stretta dedicata esclusivamente all'evidenza di validation.

## 1. Nome e collocazione

L'eseguibile canonico e:

```text
rumiai-tests/rumiai-validate
```

Il file di configurazione associato e:

```text
rumiai-tests/rumiai-validate.conf
```

L'eseguibile non porta estensione e, quando implementato in shell, usa `#!/bin/sh`.

`rumiai-validate` non e un alias di `rumiai-test`: prepara l'host, pubblica eventuale evidenza pendente e poi delega l'esecuzione della validation al runner canonico.

Per evitare che un errore nella logica evolutiva impedisca il self-update, `rumiai-validate` resta un bootstrap minimale. La logica successiva al self-update appartiene a:

```text
lib/sh/rumiai-validate.lib.sh
```

## 2. Self-update della suite

Il bootstrap `rumiai-validate` deve:

1. risolvere la propria posizione e individuare la root di `rumiai-tests`;
2. portarsi nella root senza dipendere dalla current working directory;
3. verificare che non esistano modifiche tracked locali;
4. eseguire `git pull --ff-only` sulla suite;
5. se l'HEAD cambia, riavviare il bootstrap aggiornato;
6. soltanto dopo il self-update caricare `lib/sh/rumiai-validate.lib.sh`.

File untracked non impediscono il self-update. Questo e necessario anche per poter ricevere una correzione quando esiste una sessione completata ma non ancora pubblicata.

## 3. Sessioni completate pendenti

Dopo il self-update e prima del gate completo di cleanliness, il launcher puo trovare directory visibili:

```text
sessions/<run-id>/
```

non ancora tracked.

Questa e l'unica eccezione documentata al requisito di working tree clean nella fase preparatoria del launcher. Non rende validi file untracked arbitrari.

Una directory e pubblicabile automaticamente soltanto se il launcher verifica almeno:

- `session` regolare e leggibile;
- `results` regolare e leggibile;
- assenza di `.work`;
- `type=validation` esattamente una volta;
- `rumiai-tests-commit` esattamente una volta e risolvibile come commit Git canonico;
- presenza univoca di `end`;
- `runner-exit-status` univoco e appartenente a `0`, `1`, `2`.

Le directory nascoste `sessions/.<run-id>/` sono incomplete per contratto runner e non sono pubblicate automaticamente.

Una directory visibile non tracked che non soddisfa il contratto di sessione completata e un errore: non viene cancellata, spostata o reinterpretata.

## 4. Pubblicazione durevole dell'evidenza

Ogni sessione completata viene conservata sul remote Git configurato del checkout `rumiai-tests` sotto il ref:

```text
validation/<run-id>
```

Il commit di evidenza deve essere costruito in modo che:

1. il parent sia **esattamente** il `rumiai-tests-commit` registrato nella sessione;
2. il tree sia quello di quel commit esatto piu `sessions/<run-id>/`;
3. il contenuto successivo eventualmente presente nell'HEAD corrente della suite non venga trascinato nel commit di evidenza;
4. HEAD e index reali del checkout dell'operatore non vengano modificati.

L'implementazione puo usare un index Git temporaneo e `commit-tree`. L'uso di `git add` e ammesso soltanto contro tale index temporaneo e soltanto per la directory della sessione da pubblicare.

Il launcher non crea automaticamente commit di codice, test, configurazione o altro contenuto della working tree.

## 5. Perche l'evidenza non avanza `main`

Una validation su piu host deve riferirsi allo stesso commit della suite.

Se la sessione prodotta dal primo host avanzasse automaticamente `main`, il secondo host riceverebbe una nuova revisione della suite e validerebbe un commit differente anche quando i test sono identici.

Per questo:

```text
publication ref != suite main
```

Il ref `validation/<run-id>` e un ref durevole di evidenza e non cambia la baseline operativa della suite.

L'eventuale consolidamento successivo delle evidenze in `main` e una fase distinta e non appartiene a `rumiai-validate`.

## 6. Idempotenza e collisioni

Prima di creare un nuovo ref, il launcher verifica se `validation/<run-id>` esiste gia.

Se esiste, il launcher puo considerare la sessione gia pubblicata soltanto quando:

- il commit remoto ha come unico parent l'esatto `rumiai-tests-commit` registrato;
- il tree remoto coincide con il tree di evidenza ricostruito dalla copia locale.

In questo caso il retry e idempotente.

Se parent o tree differiscono, esiste una collisione: il launcher termina con errore e non sovrascrive il ref remoto.

Il launcher non usa force push.

## 7. Rimozione della copia locale

La copia locale untracked di `sessions/<run-id>/` puo essere rimossa soltanto dopo che il launcher ha verificato che il ref remoto punti al commit di evidenza atteso, oppure dopo aver verificato un ref remoto gia esistente e identico.

Se creazione, push o verifica falliscono:

- la sessione locale resta intatta;
- il launcher termina con errore operativo;
- la successiva invocazione di `./rumiai-validate` ritenta la pubblicazione prima di avviare una nuova validation.

Questo evita che un risultato importante rimanga silenziosamente confinato a un singolo host e, allo stesso tempo, evita perdita di evidenza in caso di errore di rete o autenticazione.

## 8. Cleanliness prima del runner

Dopo aver gestito tutte le sessioni completate pendenti, `rumiai-tests` deve risultare completamente clean, inclusi gli untracked, prima di invocare il runner.

Il target `rumiai-os` segue il gate ordinario:

1. modifiche tracked locali bloccano il pull automatico;
2. `git pull --ff-only`;
3. working tree completamente clean, inclusi gli untracked;
4. HEAD uguale al commit configurato.

Quindi l'eccezione riguarda soltanto la fase preparatoria del launcher; `rumiai-test --validation` continua a partire da una suite clean e il suo contratto non cambia.

## 9. Nuova sessione prodotta dalla validation

Al termine del runner, quando esiste una nuova sessione completata visibile, il launcher:

1. mostra l'exit status del runner e il run-id;
2. pubblica immediatamente la sessione secondo il contratto precedente;
3. verifica il ref remoto;
4. rimuove la copia locale soltanto dopo la verifica.

Le sessioni completate con status runner `0`, `1` o `2` vengono conservate: un FAIL o un TEST ERROR e evidenza utile e non deve dipendere da un successivo intervento manuale.

Un runner error `3` che lascia una sessione nascosta/incompleta non viene promosso automaticamente a evidenza completata.

Se il runner termina ma la pubblicazione della nuova sessione fallisce, il launcher conserva e mostra il risultato runner ma termina con errore operativo di launcher, lasciando la sessione locale disponibile per il retry.

## 10. Git

Gli aggiornamenti automatici dei checkout di codice sono esclusivamente:

```text
git pull --ff-only
```

Per la sola evidenza completata sono ammessi:

```text
index Git temporaneo
commit di sola sessione basato sul commit registrato
push non-forzato verso validation/<run-id>
fetch/ls-remote necessari alla verifica
```

Restano vietati nel launcher:

```text
git merge
git rebase
force push
riscrittura della storia
commit automatici di codice/test/configurazione
```

Git resta forward-only.

## 11. Configurazione

`rumiai-validate.conf` e un file di dati versionato insieme alla suite.

Formato:

```text
key<TAB>value
```

Chiavi correnti esatte:

```text
rumiai-os-commit
selection
```

`selection` identifica un singolo test o un gruppo relativo a `tests/`. La configurazione e comune agli host di riferimento.

Quando test nuovi o modificati richiedono physical validation, lo stesso work unit deve aggiornare, quando necessario, il commit target e la selection.

## 12. Piattaforma

Il launcher mostra almeno sistema operativo e architettura dell'host.

La piattaforma non viene usata per scegliere test differenti e mascherare incompatibilita: la stessa configurazione vale sui diversi host applicabili.

## 13. Relazione con `rumiai-test`

`rumiai-test` resta il solo runner canonico e conserva il contratto di `TESTING.md` e `RUNNER.md`.

Flusso corrente:

```text
operator
  -> rumiai-validate
       -> git pull --ff-only rumiai-tests
       -> eventuale restart
       -> publish pending completed sessions
       -> clean gate rumiai-tests
       -> config + target discovery
       -> git pull --ff-only rumiai-os
       -> clean gate + exact target commit
       -> rumiai-test --validation -- <selection>
            -> sessions/.<run-id>/ durante il run
            -> sessions/<run-id>/ quando completata
       -> publish validation/<run-id>
       -> verified local cleanup
```

Il runner non conosce il ref remoto e non esegue add/commit/push.

## 14. Test permanenti

Il self-update e protetto da:

```text
tests/rumiai-tests/validate/pull-config-and-run.test
```

La pubblicazione durevole e protetta da:

```text
tests/rumiai-tests/validate/session-publication.test
```

Il test di pubblicazione deve verificare almeno:

- pubblicazione anche di una sessione completata con status FAIL;
- conservazione locale se il remote non e raggiungibile;
- parent del commit di evidenza uguale all'esatto commit registrato nella sessione;
- esclusione dal tree di contenuto suite piu recente;
- HEAD locale invariato;
- working tree nuovamente clean dopo pubblicazione riuscita;
- retry idempotente quando il ref remoto identico esiste gia.

Il runner resta inoltre protetto separatamente da `tests/runner/validation-publication.test`, che continua a verificare che `rumiai-test` da solo non modifichi Git.

## 15. Configurazione della validation corrente

La modifica della policy `.gitignore` per-root di `rumiai-os` e implementata in:

```text
massimilianonardi-ai/rumiai-os@c6b3027cfef278b69681ba414337e4b357aca537
```

La configurazione corrente e:

```text
rumiai-os-commit<TAB>c6b3027cfef278b69681ba414337e4b357aca537
selection<TAB>rumiai-os/bootstrap
```

Host stabili di riferimento:

```text
macOS
Ubuntu 26.04 ARM64
```

L'allineamento di codice, test e configurazione non costituisce da solo physical validation.

## 16. Invarianti

```text
VALIDATE-01  rumiai-test resta il runner canonico e non acquisisce responsabilita Git/config/target/publication
VALIDATE-02  rumiai-validate e l'unico entrypoint operativo richiesto all'operatore
VALIDATE-03  rumiai-validate.conf e versionato e definisce commit target e singola selection
VALIDATE-04  gli aggiornamenti automatici di codice sono esclusivamente pull --ff-only
VALIDATE-05  scritture Git automatiche sono ammesse solo per un commit di sola evidenza costruito con index temporaneo e pushato su validation/<run-id>
VALIDATE-06  main e HEAD/index reali della suite non vengono modificati dalla pubblicazione di una sessione
VALIDATE-07  sessioni completate untracked sono ammesse solo come stato preparatorio pendente; prima del runner la suite torna completamente clean
VALIDATE-08  file untracked arbitrari e sessioni incomplete/anomale continuano a bloccare la validation
VALIDATE-09  ogni commit di evidenza ha come parent l'esatto rumiai-tests-commit registrato nella sessione
VALIDATE-10  la copia locale viene rimossa solo dopo verifica durevole del ref remoto; un errore preserva l'evidenza
VALIDATE-11  le sessioni completate con status 0, 1 o 2 vengono pubblicate; runner error incompleti non vengono promossi
VALIDATE-12  il launcher non esegue merge, rebase, force push o commit automatici di codice/test/configurazione
VALIDATE-13  il launcher riusa la target discovery esistente
VALIDATE-14  configurazione e selection restano comuni agli host; piattaforma/architettura sono osservate
VALIDATE-15  il risultato runner viene riportato; un successivo errore di pubblicazione e un errore operativo del launcher e lascia la sessione locale intatta
VALIDATE-16  la logica evolutiva viene caricata da lib/sh/rumiai-validate.lib.sh soltanto dopo il self-update
```
