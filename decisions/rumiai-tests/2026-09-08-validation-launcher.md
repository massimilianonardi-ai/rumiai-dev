# Decisione — Launcher operativo per le validation run

Date: 2026-09-08  
Status: **Accepted**  
Updated: 2026-09-09

## Contesto

Le validation run permanenti sono eseguite da `rumiai-test --validation`, ma l'operatore non deve ripetere manualmente aggiornamenti dei checkout, cambio directory, verifica della revisione, costruzione della selezione o gestione delle sessioni completate.

Il runner `rumiai-test` resta agnostico rispetto al target e non acquisisce responsabilita di aggiornamento Git, target discovery, configurazione operativa, pubblicazione remota dell'evidenza o gestione della finestra terminale dell'operatore.

Il comando operativo normale e soltanto:

```text
./rumiai-validate
```

La correzione approvata il 2026-09-08 aggiunge la pubblicazione automatica e durevole delle validation session completate. Questa correzione sostituisce il precedente divieto assoluto di `commit`/`push` nel launcher con un'eccezione stretta dedicata esclusivamente all'evidenza di validation.

La correzione approvata il 2026-09-09 aggiunge inoltre un hold finale per i terminali Linux effimeri aperti da un'interfaccia grafica, in modo che i risultati non scompaiano alla chiusura automatica della finestra. Il normale uso da shell e le esecuzioni non interattive non devono acquisire un prompt aggiuntivo.

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

`rumiai-validate` non e un alias di `rumiai-test`: prepara l'host, pubblica eventuale evidenza pendente, gestisce l'eventuale hold della finestra terminale e poi delega l'esecuzione della validation al runner canonico.

Per evitare che un errore nella logica evolutiva impedisca il self-update, `rumiai-validate` resta un bootstrap minimale. La logica successiva al self-update appartiene a:

```text
lib/sh/rumiai-validate.lib.sh
```

Il finalizer necessario a preservare una finestra terminale effimera appartiene invece al bootstrap root, perche deve poter intervenire anche dopo un errore precedente al caricamento della libreria evolutiva.

## 2. Self-update della suite

Il bootstrap `rumiai-validate` deve:

1. risolvere la propria posizione e individuare la root di `rumiai-tests`;
2. portarsi nella root senza dipendere dalla current working directory;
3. verificare che non esistano modifiche tracked locali;
4. eseguire `git pull --ff-only` sulla suite;
5. se l'HEAD cambia, riavviare il bootstrap aggiornato;
6. soltanto dopo il self-update caricare `lib/sh/rumiai-validate.lib.sh`.

File untracked non impediscono il self-update. Questo e necessario anche per poter ricevere una correzione quando esiste una sessione completata ma non ancora pubblicata.

Un `exec` riuscito durante il self-update sostituisce il processo corrente con il launcher aggiornato e non deve attivare un hold intermedio: il finalizer appartiene soltanto alla terminazione effettiva del launcher che resta in esecuzione.

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

Il ref `validation/<run-id>` e quindi un ref di conservazione dell'evidenza, non una nuova baseline della suite. Un'eventuale successiva consolidazione delle evidenze in `main` e una fase distinta e non appartiene al launcher.

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

L'eventuale hold della finestra avviene soltanto dopo che il flusso normale o di errore ha prodotto il proprio output e non modifica la semantica della sessione o della pubblicazione.

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

Il meccanismo di hold non introduce una nuova chiave di configurazione, un nuovo argomento CLI o una nuova environment variable RumiAI.

## 12. Piattaforma

Il launcher mostra almeno sistema operativo e architettura dell'host.

La piattaforma non viene usata per scegliere test differenti e mascherare incompatibilita: la stessa configurazione vale sui diversi host applicabili.

Il comportamento di hold e intenzionalmente specifico del problema osservato su Linux e non cambia il contratto dei test o del target sugli altri host.

## 13. Relazione con `rumiai-test`

`rumiai-test` resta il solo runner canonico e conserva il contratto di `TESTING.md` e `RUNNER.md`.

Flusso corrente:

```text
operator
  -> rumiai-validate
       -> detect eventuale terminale Linux effimero
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
       -> eventuale hold finale della finestra
```

Il runner non conosce il ref remoto, non esegue add/commit/push e non gestisce il terminale dell'operatore.

## 14. Test permanenti e verifiche meccaniche

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

Il comportamento di hold richiede un terminale reale o pseudo-terminale. Prima della pubblicazione sono richieste almeno verifiche meccaniche che dimostrino:

- assenza di hold con stdin/stdout non terminali;
- preservazione dell'exit status originale;
- hold con un comando one-shot in pseudo-terminale;
- assenza di hold quando lo stesso comando e invocato da una normale shell interattiva.

La prova specifica tramite file manager Linux resta una verifica fisica dell'integrazione desktop e non viene sostituita da una fixture che finga un particolare file manager.

## 15. Configurazione e physical validation corrente

L'ultima coppia completamente validata su entrambi i reference host ARM64 resta:

```text
rumiai-os<TAB>c6b3027cfef278b69681ba414337e4b357aca537
rumiai-tests<TAB>7a28fe32ed30f0ea1108b4eab5572216e5551167
selection<TAB>rumiai-os/bootstrap
```

Evidenza:

```text
macOS ARM64
validation/20260909T000836+0200-18820
PASS 13 / FAIL 0 / SKIP 0 / ERROR 0

Ubuntu 26.04 ARM64
validation/20260909T001235+0200-7713
PASS 13 / FAIL 0 / SKIP 0 / ERROR 0
```

Le revisioni successive non vengono retroattivamente coperte da tale evidenza.

La configurazione corrente viene ora fissata a:

```text
rumiai-os-commit<TAB>b02965a91efdeb8f9609b432d635430ac9dba209
selection<TAB>rumiai-os
```

La revisione esatta della suite che porta questa configurazione e:

```text
massimilianonardi-ai/rumiai-tests@17a02fe6638c6cd0407410f487094200456e3596
```

Dal precedente target configurato `5d8f6f252e4167c3f49870fb2392ffde1516742c` al target corrente `b02965a91efdeb8f9609b432d635430ac9dba209` il prodotto incorpora nuovi layer e modifiche che coinvolgono almeno:

```text
digest
extract
http-fetch
lang-set
pkg-analyze
read-key
pkg-download
pkg-extract
```

Per questo il gate corrente usa il gruppo:

```text
rumiai-os
```

anziche mantenere artificialmente la precedente selection `rumiai-os/bootstrap`.

La stessa coppia esatta deve essere eseguita sui due reference host disponibili nell'ordine operativo scelto dall'utente:

```text
1. Ubuntu 26.04 ARM64
2. macOS ARM64
```

Su entrambi il comando normale dell'operatore resta esclusivamente:

```text
./rumiai-validate
```

Non si modifica `rumiai-validate.conf` fra i due run e non si avanza `rumiai-tests/main` fino a quando entrambi i reference host non hanno prodotto l'evidenza desiderata, salvo una correzione realmente necessaria emersa dal primo run.

Se Ubuntu individua un problema reale che richiede una modifica di prodotto o test, la coppia viene aggiornata forward-only e il successivo run macOS deve usare la nuova coppia; l'evidenza Ubuntu precedente resta valida soltanto per la revisione che ha effettivamente esercitato.

Questa validation riguarda il prodotto `rumiai-os` corrente e i relativi test permanenti. Non costituisce ancora physical validation di DBeaver come package installato, perche `pkg_integrate` e il `launcher` necessari al percorso reale non sono ancora implementati.

La verifica fisica specifica del terminal hold tramite file manager Linux resta una verifica distinta dell'integrazione desktop del launcher. Un normale run da shell valida il percorso operativo corrente ma non deve essere reinterpretato come prova del caso terminale grafico effimero se quest'ultimo non viene eseguito.

## 16. Chiusura del terminale grafico Linux

Il launcher deve impedire la perdita immediata dell'output quando, su Linux, viene avviato in una finestra terminale destinata a chiudersi insieme al processo.

Il comportamento richiesto e:

1. nessun hold se stdin o stdout non sono terminali;
2. nessun hold nel normale caso in cui l'operatore esegue `./rumiai-validate` da una shell interattiva;
3. su Linux, quando il launcher rileva un'esecuzione terminale one-shot/effimera, prima della terminazione mostra:

```text
Press Enter to close...
```

4. attende una singola riga di input; EOF non viene trasformato in un nuovo errore;
5. dopo l'input termina con l'exit status che il launcher avrebbe restituito senza hold;
6. il comportamento vale sia per successo sia per errori del launcher o del runner;
7. un self-update riuscito tramite `exec` non genera un prompt intermedio.

Il rilevamento puo usare informazioni POSIX/Linux sul parent process e sul process group per distinguere una normale shell interattiva da un comando terminale one-shot. Se il contesto terminale e presente ma la distinzione non puo essere determinata in modo affidabile, il comportamento corrente privilegia la conservazione della visibilita dell'output e puo applicare l'hold.

Questa logica e interna al launcher e non introduce una nuova primitive di prodotto RumiAI OS.

## 17. Invarianti

```text
VALIDATE-01  rumiai-test resta il runner canonico e non acquisisce responsabilita Git/config/target/publication/terminal
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
VALIDATE-17  il terminal hold e responsabilita esclusiva di rumiai-validate e non di rumiai-test o rumiai-os
VALIDATE-18  esecuzioni non-TTY e normali invocazioni da shell interattiva non devono richiedere Enter
VALIDATE-19  il terminal hold Linux preserva l'exit status originale e vale anche per errori preliminari
VALIDATE-20  un exec riuscito durante il self-update non produce un hold intermedio
VALIDATE-21  il gate corrente usa rumiai-os@b02965a91efdeb8f9609b432d635430ac9dba209 con rumiai-tests@17a02fe6638c6cd0407410f487094200456e3596 e selection rumiai-os
VALIDATE-22  la stessa coppia/configurazione viene usata su Ubuntu 26.04 ARM64 e macOS ARM64 senza reinterpretare evidence di revisioni precedenti
```
