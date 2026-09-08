# Decisione — Launcher operativo per le validation run

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Le validation run permanenti sono eseguite da `rumiai-test --validation`, ma l'operatore non deve ripetere manualmente operazioni di aggiornamento dei checkout, cambio directory, verifica della revisione da testare e costruzione della selezione da eseguire su ciascun host di riferimento.

Il runner `rumiai-test` deve restare agnostico rispetto al target e non deve acquisire responsabilità di aggiornamento Git, target discovery, configurazione operativa o orchestrazione host-specifica.

Per ridurre il lavoro manuale senza modificare il contratto del runner viene introdotto un launcher operativo separato.

Correzione esplicita del 2026-09-08: il comando normale dell'operatore deve essere soltanto `rumiai-validate`. Non deve essere necessario eseguire preventivamente `git pull`, `cd` o ricostruire manualmente la CLI. Di conseguenza l'auto-update della suite deve appartenere al bootstrap minimale del launcher e deve avvenire prima del caricamento della logica evolutiva e della configurazione.

## 1. Nome e collocazione

L'eseguibile canonico è:

```text
rumiai-tests/rumiai-validate
```

Il file di configurazione associato è:

```text
rumiai-tests/rumiai-validate.conf
```

L'eseguibile non porta estensione e, quando implementato in shell, usa `#!/bin/sh`.

`rumiai-validate` non è un alias di `rumiai-test`: svolge la preparazione operativa dell'host e poi delega l'esecuzione della validation al runner canonico.

Per evitare che un errore nella logica evolutiva impedisca persino l'auto-update, `rumiai-validate` deve restare un bootstrap minimale e stabile. La logica successiva al self-update è collocata nella libreria shell:

```text
lib/sh/rumiai-validate.lib.sh
```

La libreria viene caricata soltanto dopo che il checkout `rumiai-tests` è stato aggiornato ed è stato eventualmente riavviato il bootstrap aggiornato.

## 2. Responsabilità del bootstrap `rumiai-validate`

Il bootstrap deve:

1. risolvere la propria posizione e individuare la root del checkout `rumiai-tests`;
2. portarsi nella root di `rumiai-tests` senza dipendere dalla current working directory dell'operatore;
3. verificare che non esistano modifiche **tracked** locali nel checkout `rumiai-tests` che potrebbero essere alterate o confuse con l'auto-update;
4. eseguire `git pull --ff-only` sul checkout `rumiai-tests`;
5. se il pull aggiorna la suite, riavviare `rumiai-validate` dalla revisione appena aggiornata;
6. soltanto dopo il self-update caricare `lib/sh/rumiai-validate.lib.sh`;
7. delegare alla libreria il resto della preparazione e della validation.

La presenza di file **untracked** non impedisce il self-update della suite. Questo non costituisce un'eccezione alla cleanliness richiesta per la validation: dopo il self-update e prima di avviare il runner viene comunque applicato il controllo completo della working tree.

## 3. Responsabilità della logica di validation

Dopo il self-update, la logica caricata da `lib/sh/rumiai-validate.lib.sh` deve:

1. verificare che la working tree `rumiai-tests` sia completamente pulita, inclusi gli untracked;
2. leggere `rumiai-validate.conf` dalla root della suite;
3. individuare il checkout `rumiai-os` riusando la primitive di target discovery già presente in `lib/rumiai-os-target.lib`;
4. verificare che non esistano modifiche tracked locali in `rumiai-os` prima dell'aggiornamento automatico;
5. eseguire `git pull --ff-only` su `rumiai-os`;
6. verificare dopo il pull che la working tree `rumiai-os` sia completamente pulita, inclusi gli untracked;
7. verificare che l'HEAD risultante di `rumiai-os` corrisponda al commit atteso configurato;
8. rilevare e mostrare almeno sistema operativo e architettura dell'host;
9. invocare `rumiai-test --validation -- <selection>` con la selezione configurata;
10. propagare l'exit status del runner e mostrare, quando disponibile, l'identificatore della nuova validation session completata.

Il launcher non modifica il comportamento interno dei test e non introduce un nuovo contratto runner -> test.

## 4. Git

Gli aggiornamenti automatici dei checkout sono esclusivamente:

```text
git pull --ff-only
```

Il launcher non deve eseguire automaticamente:

```text
git add
git commit
git push
git merge
git rebase
```

La versionatura delle sessioni resta una fase distinta, in modo particolare quando più host producono evidenza contemporaneamente.

Prima di un pull automatico, modifiche tracked locali interrompono il launcher. File untracked possono invece coesistere con il self-update o con il pull del target, purché Git possa effettuare il fast-forward senza conflitti.

Prima dell'effettiva validation, sia `rumiai-tests` sia il target devono essere completamente clean secondo il contratto di `TESTING.md`. L'auto-update anticipato non indebolisce questo requisito.

Git resta forward-only; il launcher non riscrive la storia.

## 5. Configurazione

`rumiai-validate.conf` è un file di dati versionato insieme alla suite.

Il formato iniziale usa record:

```text
key<TAB>value
```

Le chiavi iniziali sono esattamente:

```text
rumiai-os-commit
selection
```

Esempio:

```text
rumiai-os-commit<TAB>262316902997319b56f1d5097d636b38de9dd2c4
selection<TAB>rumiai-os/bootstrap
```

`selection` identifica un singolo test oppure un gruppo relativo a `tests/`, coerentemente con la CLI già fissata di `rumiai-test`.

Il launcher non introduce una lista arbitraria di selettori: quando più test devono essere validati insieme si usa il gruppo gerarchico minimo appropriato. Un'estensione futura a più selettori richiede una necessità concreta e una decisione distinta.

Le righe vuote e le righe che iniziano con `#` possono essere usate come commenti. Chiavi sconosciute, duplicate o prive di valore sono errori di configurazione.

## 6. Aggiornamento della configurazione

Quando vengono aggiunti o modificati test permanenti e la modifica richiede physical validation sugli host di riferimento, lo stesso work unit deve valutare e, quando necessario, aggiornare `rumiai-validate.conf` con:

- il commit `rumiai-os` esatto da validare;
- la selezione minima proporzionata che copre il contratto modificato.

In questo modo l'operatore su ciascun host esegue sempre lo stesso comando:

```text
./rumiai-validate
```

senza eseguire prima `git pull` e senza ricostruire manualmente la CLI della validation.

La configurazione corrente vale per tutti gli host di riferimento. Non vengono introdotte configurazioni differenti per macOS e Linux soltanto per trasformare divergenze reali in esiti differenti.

## 7. Piattaforma

Il launcher rileva piattaforma e architettura per rendere immediatamente leggibile l'output operativo.

La piattaforma non viene usata, nel contratto iniziale, per scegliere test differenti. La regola di universalità dei test resta invariata: la stessa proprietà viene eseguita sui diversi host applicabili e la sessione registra dove è stata osservata.

## 8. Relazione con `rumiai-test`

`rumiai-test` resta il solo runner canonico della suite e conserva integralmente il contratto definito in `TESTING.md` e `RUNNER.md`.

`rumiai-validate` è un entrypoint dell'operatore posto prima del runner:

```text
operator
  -> rumiai-validate
       -> autodiscovery + cd nella root rumiai-tests
       -> git pull --ff-only di rumiai-tests
       -> eventuale restart del bootstrap aggiornato
       -> lib/sh/rumiai-validate.lib.sh
            -> gate completo di cleanliness della suite
            -> config + target discovery
            -> git pull --ff-only del target
            -> gate completo di cleanliness del target
            -> rumiai-test --validation -- <selection>
                 -> test permanenti
                 -> sessions/<run-id>/
```

Il launcher non aggiunge opzioni alla CLI di `rumiai-test` e non modifica la semantica della validation run.

## 9. Test permanenti

Il launcher deve essere protetto da almeno un test permanente che verifichi in sandbox il flusso operativo essenziale senza dipendere dalla rete pubblica:

- invocazione da una current working directory estranea;
- autodiscovery e ingresso nella root corretta di `rumiai-tests`;
- aggiornamento fast-forward del checkout `rumiai-tests` senza `git pull` esterno;
- self-update prima del caricamento della logica evolutiva e della configurazione;
- capacità di effettuare il self-update anche quando sono presenti file untracked, fermandosi comunque al successivo gate completo prima della validation;
- uso della configurazione aggiornata dopo il pull;
- aggiornamento fast-forward del target `rumiai-os`;
- verifica del commit target configurato;
- invocazione del runner con `--validation -- <selection>`.

Il test deve usare repository Git temporanei locali e non modificare i checkout reali.

## 10. Configurazione della validation corrente

Per la physical validation della semantic-root extension implementata in:

```text
massimilianonardi-ai/rumiai-os@262316902997319b56f1d5097d636b38de9dd2c4
```

la configurazione iniziale è:

```text
rumiai-os-commit<TAB>262316902997319b56f1d5097d636b38de9dd2c4
selection<TAB>rumiai-os/bootstrap
```

La stessa configurazione deve essere eseguita almeno sugli host stabili di riferimento correnti:

```text
macOS
Ubuntu 26.04 ARM64
```

## 11. Invarianti

```text
VALIDATE-01  rumiai-test resta il runner canonico e non acquisisce responsabilità di aggiornamento Git/configurazione target
VALIDATE-02  rumiai-validate è l'unico entrypoint operativo richiesto all'operatore per una validation configurata
VALIDATE-03  rumiai-validate.conf è versionato nella stessa root e definisce commit target e singola selection
VALIDATE-04  gli aggiornamenti Git eseguiti dal launcher sono esclusivamente pull --ff-only
VALIDATE-05  il launcher non esegue add/commit/push/merge/rebase
VALIDATE-06  l'auto-update della suite avviene prima del caricamento della logica evolutiva e non richiede un git pull manuale
VALIDATE-07  modifiche tracked locali bloccano il pull automatico; file untracked non bloccano il self-update ma la validation richiede poi working tree completamente clean
VALIDATE-08  il launcher riusa la target discovery esistente invece di introdurre una seconda primitive equivalente
VALIDATE-09  la configurazione è comune agli host; piattaforma/architettura sono osservate, non usate per mascherare incompatibilità
VALIDATE-10  il launcher propaga l'exit status del runner
VALIDATE-11  quando test nuovi o modificati richiedono physical validation, rumiai-validate.conf viene riallineato nello stesso work unit
VALIDATE-12  la logica evolutiva del launcher è caricata da lib/sh/rumiai-validate.lib.sh soltanto dopo il self-update
```