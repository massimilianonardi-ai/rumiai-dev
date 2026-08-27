# Decisione — Entrypoint e `RUMIAI_ROOT` fisici/canonicalizzati

Date: 2026-08-27  
Status: **Accepted**

## Contesto

Il bootstrap iniziale di `rumiai-os` deve determinare una root fisica/canonicalizzata indipendentemente da invocazione diretta, `PATH` o symbolic link.

Il contratto richiesto stabilisce che:

- tutti i symlink devono essere risolti;
- `RUMIAI_ROOT` deve essere una directory esistente e accessibile;
- `cd -- "$RUMIAI_ROOT"` deve riuscire;
- l'invocazione tramite `PATH` deve essere risolta correttamente;
- i link circolari devono causare fallimento;
- la soluzione deve restare semplice e robusta, delegando il lavoro a utility POSIX quando possibile.

Baseline:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

## Decisione

### 1. Risoluzione tramite facility POSIX standard

Il bootstrap usa:

```text
command -v
realpath
```

invece di implementare un resolver ricorsivo di symbolic link in shell.

`realpath` è parte della baseline Issue 8 e viene usato come primitive normativa per la canonicalizzazione fisica.

### 2. Risoluzione di `$0`

Se `$0` contiene `/`, viene trattato come pathname di invocazione.

Se `$0` non contiene `/`, il bootstrap risolve il command name attraverso `PATH` con:

```sh
command -v -- "$0"
```

Un fallimento causa il fallimento del bootstrap.

### 3. Canonicalizzazione

Il pathname di invocazione viene canonicalizzato con:

```sh
realpath -- "$RUMIAI_ENTRY"
```

Il bootstrap non usa:

```text
ls -l parsing
custom recursive symlink walker
GNU readlink -f
GNU-specific realpath options
```

Non viene richiesto `realpath -e`: il dominio del bootstrap richiede già un entrypoint esistente e il risultato viene verificato esplicitamente come regular file. Questo evita una dipendenza non necessaria da opzioni Issue 8 che gli host correnti possono non avere ancora esposto uniformemente.

### 4. Entry point finale

Il risultato canonicalizzato deve essere un regular file esistente:

```sh
[ -f "$RUMIAI_ENTRY" ]
```

Un dangling link o un target non valido causa fallimento.

### 5. Derivazione di `RUMIAI_ROOT`

Dato `RUMIAI_ENTRY` già assoluto e canonicalizzato, la root viene derivata tramite parameter expansion:

```sh
RUMIAI_ROOT=${RUMIAI_ENTRY%/*}
[ -n "$RUMIAI_ROOT" ] || RUMIAI_ROOT=/
```

Per questo specifico bootstrap viene preferita questa soluzione a `dirname`.

Motivazione:

- dominio di input già ristretto e noto;
- nessun processo aggiuntivo;
- nessun nuovo output testuale da ricatturare;
- nessuna semantica generale di `dirname` necessaria.

Se nello stesso dominio servisse il basename, si preferisce:

```sh
${RUMIAI_ENTRY##*/}
```

Questa scelta non vieta globalmente `dirname` o `basename`.

### 6. Invariante runtime della root

Prima di esportare la root deve riuscire:

```sh
(cd -- "$RUMIAI_ROOT")
```

La subshell evita di modificare la current working directory del processo principale.

### 7. Symbolic-link loops

I loop devono causare fallimento.

La rilevazione viene delegata alla pathname resolution / `realpath` standard; non viene duplicata con un algoritmo shell ad hoc.

### 8. Pathname con newline finali

Poiché la command substitution rimuove newline terminali, la cattura degli output pathname usa un piccolo protocollo sentinel in modo da non perdere automaticamente newline che fanno parte del pathname.

La soluzione resta locale al bootstrap e non diventa una generic serialization abstraction.

## Evidenza

PoC:

```text
rumiai-dev-PoCs/pocs/003-entrypoint-symlink-resolution/
```

Sessione di consolidamento:

```text
sessions/2026-08-27-linux-local-002/
```

Matrice locale:

```text
dash          14 pass / 0 fail
bash --posix  14 pass / 0 fail
busybox sh    14 pass / 0 fail
TOTAL         42 pass / 0 fail
```

Sono inclusi test per:

- invocazione relativa e assoluta;
- `PATH`;
- symlink relativi e assoluti;
- catena di symlink;
- symlink in componente intermedio;
- spazi e testo ` -> `;
- componente che inizia con `-`;
- link circolare con fallimento atteso;
- dangling link con fallimento atteso;
- root con newline finale;
- verifica reale di `cd -- "$RUMIAI_ROOT"`.

## Stato host di riferimento

L'algoritmo è consolidato come design rispetto alla baseline Issue 8 e all'evidenza cross-shell locale.

La certificazione runtime sugli host di riferimento correnti, in particolare macOS e Ubuntu LTS, resta una validazione distinta da eseguire. Eventuali divergenze reali verranno gestite secondo la decisione sulla baseline POSIX e la sua evoluzione.

## Supersession

Questa decisione completa e sostituisce le parti ancora aperte relative alla scelta dell'algoritmo in:

```text
decisions/rumiai-os/2026-08-27-command-naming-and-symlink-resolution.md
architecture/rumiai-os/INITIAL-BOOTSTRAP.md
```

Il principio di supportare i symbolic link e le regole di naming contenuti nella decisione precedente restano validi.

## Authorization

Questa decisione **non autorizza** la scrittura dell'implementazione nel repository `rumiai-os` durante la fase iniziale.

La promozione nel prodotto richiede ancora consenso esplicito dell'utente.
