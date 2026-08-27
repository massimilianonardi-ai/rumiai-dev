# Decisione — POSIX bootstrap foundation

Date: 2026-08-27  
Status: **Accepted, partially superseded**

> **Supersession notice — 2026-08-27**  
> La sezione 3 relativa al rifiuto dell'invocazione tramite symbolic link e qualunque assunzione implicita sui suffissi `.sh` sono superate da `2026-08-27-command-naming-and-symlink-resolution.md`. Il PoC 002 resta evidenza storica del comportamento testato, non definisce più il contratto symlink del bootstrap.

## Contesto

L'audit di `massimilianonardi/m` ha mostrato sia il valore di un portability layer POSIX sia diversi problemi nelle implementazioni storiche: dipendenze da estensioni non POSIX, uso di dati come format string e uso di `eval` con confusione fra dati e codice.

PoC 001 ha riprodotto tali difetti.

PoC 002 ha quindi validato una foundation minima sostitutiva per alcune operazioni necessarie all'avvio iniziale di `rumiai-os`.

Riferimenti:

- `specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md`
- `rumiai-dev-PoCs/pocs/001-posix-foundations/`
- `rumiai-dev-PoCs/pocs/002-posix-bootstrap-foundation/`

## Decisione

### 1. Bootstrap minimo in POSIX shell

Il primo bootstrap stabile di `rumiai-os` può e deve rimanere implementato in POSIX shell con:

```sh
#!/bin/sh
```

Non è emersa alcuna necessità, per le operazioni validate, di Bash o di estensioni GNU.

Il nome pubblico dell'eseguibile non deve tuttavia includere l'estensione `.sh`: il linguaggio di implementazione non fa parte dell'identità del comando.

### 2. Root discovery

L'entrypoint deve determinare dinamicamente la propria root e non deve dipendere dalla current working directory.

Il contratto deve supportare:

- invocazione relativa con pathname;
- invocazione assoluta;
- invocazione da una directory differente;
- invocazione tramite `PATH`.

### 3. Symlink dell'entrypoint — SUPERATA

La precedente scelta del PoC 002 di rifiutare esplicitamente i symbolic link **non è più una decisione architetturale valida**.

Il contratto corrente richiede invece che l'invocazione tramite symbolic link venga supportata mediante una risoluzione POSIX-compatible, sicura e testata del path reale dell'eseguibile.

La semantica e l'algoritmo devono essere validati in un PoC dedicato prima dell'implementazione stabile.

### 4. Data output

Per dati arbitrari il formato di `printf` deve essere costante.

Pattern di riferimento:

```sh
printf '%s' "$value"
printf '%s\n' "$value"
```

`echo` non viene usato come serializer generico di dati.

### 5. Static enforcement

Le regole di portabilità devono iniziare a essere applicate anche tramite controlli automatici.

Un controllo statico iniziale deve poter intercettare almeno:

- shebang shell diversi da `#!/bin/sh` nel portable core;
- `$RANDOM`;
- `BASH_SOURCE`;
- `[[`;
- `readlink -f` GNU quando non esplicitamente consentito;
- path host-specific noti;
- format operand di `printf` variabili, almeno come elemento da sottoporre a review;
- nomi di comandi eseguibili che incorporano inutilmente l'estensione del linguaggio/interprete.

Il lint non sostituisce i test comportamentali.

### 6. Nessuna collection abstraction prematura

Array, map, environment serialization e altre astrazioni storiche non vengono introdotte nel bootstrap iniziale solo perché esistevano in `m`.

Verranno specificate e testate soltanto quando un requisito concreto di `rumiai-os` le renderà necessarie.

## Evidenza

La sessione di PoC 002:

```text
pocs/002-posix-bootstrap-foundation/sessions/2026-08-27-local-001/
```

ha completato la matrice con:

```text
shells=3
fail=0
```

su `dash`, Bash `--posix` e BusyBox `sh` per il contratto che il PoC stava verificando.

Il risultato relativo al rifiuto dei symlink documenta esclusivamente quella scelta sperimentale ed è stato successivamente superato.

## Conseguenze

Questa decisione autorizza ulteriore progettazione e PoC del bootstrap POSIX.

Non autorizza scritture nel repository `rumiai-os` durante la fase iniziale senza consenso esplicito dell'utente.

Non autorizza ancora:

- una specifica implementazione della risoluzione symlink;
- dipendenze GNU;
- array/map generici;
- package manager;
- deployment Podman/image/device;
- certificazione macOS/Cygwin.
