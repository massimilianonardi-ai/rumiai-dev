# Decisione — Entrypoint e root fisici/canonicalizzati

Date: 2026-08-27  
Status: **Accepted**

## Contesto

Il bootstrap iniziale di `rumiai-os` deve determinare una root fisica/canonicalizzata indipendentemente da invocazione diretta, `PATH` o symbolic link.

Baseline:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

## Decisione

### 1. Nomi canonici dello stato fondamentale

Le variabili esportate dal bootstrap sono esattamente:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

La capitalizzazione è normativa.

`RumiAI_BOOTSTRAP_BIN` identifica il pathname assoluto fisico/canonicalizzato del file eseguibile `rumiai-os` realmente raggiunto dopo la risoluzione di tutti i symbolic link.

`RumiAI_ROOT` identifica la directory assoluta fisica/canonicalizzata che contiene `RumiAI_BOOTSTRAP_BIN`.

I precedenti nomi `RUMIAI_ENTRY` e `RUMIAI_ROOT` sono superati come nomi di contratto e restano eventualmente presenti solo in evidenza storica precedente a questa decisione.

### 2. Risoluzione tramite facility POSIX standard

Il bootstrap usa `command -v` e `realpath` invece di implementare un resolver ricorsivo di symbolic link in shell.

Se `$0` contiene `/`, viene trattato come pathname di invocazione. Se `$0` non contiene `/`, viene risolto attraverso `PATH` con:

```sh
command -v -- "$0"
```

Un fallimento causa il fallimento del bootstrap.

### 3. Canonicalizzazione

Il pathname di invocazione viene canonicalizzato con:

```sh
realpath -- "$RumiAI_BOOTSTRAP_BIN"
```

Il bootstrap non usa parsing di `ls -l`, resolver ricorsivi custom, GNU `readlink -f` o opzioni GNU-specifiche di `realpath`.

### 4. Verifica dell'eseguibile finale

Il risultato canonicalizzato deve essere un regular file esistente:

```sh
[ -f "$RumiAI_BOOTSTRAP_BIN" ]
```

Un dangling link, loop o target non valido causa fallimento.

### 5. Derivazione di `RumiAI_ROOT`

Dato `RumiAI_BOOTSTRAP_BIN` già assoluto e canonicalizzato, la root viene derivata tramite parameter expansion:

```sh
RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
[ -n "$RumiAI_ROOT" ] || RumiAI_ROOT=/
```

Per questo specifico bootstrap viene preferita questa soluzione a `dirname`.

Se nello stesso dominio servisse il basename, si preferisce:

```sh
${RumiAI_BOOTSTRAP_BIN##*/}
```

Questa scelta non vieta globalmente `dirname` o `basename`.

### 6. Invariante runtime della root

Prima di esportare la root deve riuscire:

```sh
(cd -- "$RumiAI_ROOT")
```

### 7. Failure semantics

Le condizioni di errore del top-level bootstrap terminano il processo con stato non-zero, normalmente:

```sh
exit 1
```

Il termine `fail` usato in precedenti pseudocodici non indica una utility POSIX e non fa parte dell'architettura o dell'API di RumiAI.

Funzioni/librerie riutilizzabili seguono invece la regola generale di ritornare uno status al chiamante quando non è loro responsabilità terminare il processo.

### 8. Pathname con newline finali

Poiché la command substitution rimuove newline terminali, la cattura degli output pathname usa nel PoC un piccolo protocollo sentinel in modo da non perdere automaticamente newline che fanno parte del pathname.

## Evidenza

PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

La sessione:

```text
sessions/2026-08-27-linux-local-002/
```

è evidenza storica valida ma precede la decisione finale sui nomi delle variabili; non viene riscritta retroattivamente.

## Stato host di riferimento

L'algoritmo è consolidato come design rispetto alla baseline Issue 8 e all'evidenza cross-shell locale.

La certificazione runtime sugli host di riferimento correnti, in particolare macOS e Ubuntu LTS, resta una validazione distinta da eseguire.

## Authorization

Questa decisione **non autorizza** la scrittura dell'implementazione nel repository `rumiai-os` durante la fase iniziale.
