# Decisione — Launcher operativo per le validation run

Date: 2026-09-08  
Status: **Accepted**

## Contesto

Le validation run permanenti sono eseguite da `rumiai-test --validation`, ma l'operatore deve oggi ripetere manualmente operazioni di aggiornamento dei checkout, verifica della revisione da testare e costruzione della selezione da eseguire su ciascun host di riferimento.

Il runner `rumiai-test` deve restare agnostico rispetto al target e non deve acquisire responsabilità di aggiornamento Git, target discovery, configurazione operativa o orchestrazione host-specifica.

Per ridurre il lavoro manuale senza modificare il contratto del runner viene introdotto un launcher operativo separato.

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

## 2. Responsabilità del launcher

`rumiai-validate` deve:

1. risolvere la propria posizione e individuare la root del checkout `rumiai-tests`;
2. portarsi nella root di `rumiai-tests` prima dell'esecuzione della validation;
3. verificare che la working tree di `rumiai-tests` sia pulita;
4. eseguire `git pull --ff-only` sul checkout `rumiai-tests`;
5. se il pull aggiorna il launcher o la configurazione, riavviare il launcher dalla revisione appena aggiornata prima di procedere;
6. leggere `rumiai-validate.conf` dalla stessa root;
7. individuare il checkout `rumiai-os` riusando la primitive di target discovery già presente in `lib/rumiai-os-target.lib`;
8. verificare che la working tree di `rumiai-os` sia pulita;
9. eseguire `git pull --ff-only` su `rumiai-os`;
10. verificare che l'HEAD risultante di `rumiai-os` corrisponda al commit atteso configurato;
11. rilevare e mostrare almeno sistema operativo e architettura dell'host;
12. invocare `rumiai-test --validation -- <selection>` con la selezione configurata;
13. propagare l'exit status del runner e mostrare, quando disponibile, l'identificatore della nuova validation session completata.

Il launcher non modifica il comportamento interno dei test e non introduce un nuovo contratto runner -> test.

## 3. Git

Il launcher può aggiornare i checkout esclusivamente tramite:

```text
git pull --ff-only
```

Non deve eseguire automaticamente:

```text
git add
git commit
git push
git merge
git rebase
```

La versionatura delle sessioni resta una fase distinta, in modo particolare quando più host producono evidenza contemporaneamente.

Una working tree dirty è una precondizione non soddisfatta e deve interrompere il launcher prima della validation.

Git resta forward-only; il launcher non riscrive la storia.

## 4. Configurazione

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

## 5. Aggiornamento della configurazione

Quando vengono aggiunti o modificati test permanenti e la modifica richiede physical validation sugli host di riferimento, lo stesso work unit deve valutare e, quando necessario, aggiornare `rumiai-validate.conf` con:

- il commit `rumiai-os` esatto da validare;
- la selezione minima proporzionata che copre il contratto modificato.

In questo modo l'operatore su ciascun host esegue sempre lo stesso comando:

```text
./rumiai-validate
```

senza ricostruire manualmente la CLI della validation.

La configurazione corrente vale per tutti gli host di riferimento. Non vengono introdotte configurazioni differenti per macOS e Linux soltanto per trasformare divergenze reali in esiti differenti.

## 6. Piattaforma

Il launcher rileva piattaforma e architettura per rendere immediatamente leggibile l'output operativo.

La piattaforma non viene usata, nel contratto iniziale, per scegliere test differenti. La regola di universalità dei test resta invariata: la stessa proprietà viene eseguita sui diversi host applicabili e la sessione registra dove è stata osservata.

## 7. Relazione con `rumiai-test`

`rumiai-test` resta il solo runner canonico della suite e conserva integralmente il contratto definito in `TESTING.md` e `RUNNER.md`.

`rumiai-validate` è un entrypoint dell'operatore posto prima del runner:

```text
operator
  -> rumiai-validate
       -> git pull --ff-only dei checkout necessari
       -> verifica config/revisioni/host
       -> rumiai-test --validation -- <selection>
            -> test permanenti
            -> sessions/<run-id>/
```

Il launcher non aggiunge opzioni alla CLI di `rumiai-test` e non modifica la semantica della validation run.

## 8. Test permanenti

Il launcher deve essere protetto da almeno un test permanente che verifichi in sandbox il flusso operativo essenziale senza dipendere dalla rete pubblica:

- invocazione da una current working directory estranea;
- aggiornamento fast-forward del checkout `rumiai-tests`;
- uso della configurazione aggiornata dopo il pull;
- aggiornamento fast-forward del target `rumiai-os`;
- verifica del commit target configurato;
- ingresso nella root corretta di `rumiai-tests`;
- invocazione del runner con `--validation -- <selection>`.

Il test deve usare repository Git temporanei locali e non modificare i checkout reali.

## 9. Configurazione della validation corrente

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

## 10. Invarianti

```text
VALIDATE-01  rumiai-test resta il runner canonico e non acquisisce responsabilità di aggiornamento Git/configurazione target
VALIDATE-02  rumiai-validate è un launcher operativo separato nella root di rumiai-tests
VALIDATE-03  rumiai-validate.conf è versionato nella stessa root e definisce commit target e singola selection
VALIDATE-04  gli aggiornamenti Git eseguiti dal launcher sono esclusivamente pull --ff-only
VALIDATE-05  il launcher non esegue add/commit/push/merge/rebase
VALIDATE-06  suite e target devono essere clean prima della validation
VALIDATE-07  il launcher riusa la target discovery esistente invece di introdurre una seconda primitive equivalente
VALIDATE-08  la configurazione è comune agli host; piattaforma/architettura sono osservate, non usate per mascherare incompatibilità
VALIDATE-09  il launcher propaga l'exit status del runner
VALIDATE-10  quando test nuovi o modificati richiedono physical validation, rumiai-validate.conf viene riallineato nello stesso work unit
```