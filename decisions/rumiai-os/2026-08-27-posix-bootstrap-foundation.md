# Decisione — POSIX bootstrap foundation

Date: 2026-08-27  
Status: **Accepted**

## Contesto

L'audit di `massimilianonardi/m` ha mostrato sia il valore di un portability layer POSIX sia diversi problemi nelle implementazioni storiche: dipendenze da estensioni non POSIX, uso di dati come format string e uso di `eval` con confusione fra dati e codice.

PoC 001 ha riprodotto tali difetti.

PoC 002 ha quindi validato una foundation minima sostitutiva per le operazioni necessarie all'avvio iniziale di `rumiai-os`.

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

### 2. Root discovery

L'entrypoint deve determinare dinamicamente la propria root e non deve dipendere dalla current working directory.

Il contratto iniziale supporta:

- invocazione relativa con pathname;
- invocazione assoluta;
- invocazione da una directory differente;
- invocazione tramite `PATH`.

### 3. Symlink dell'entrypoint

L'invocazione di `rumiai-os` tramite symbolic link **non fa parte del contratto iniziale**.

Se rilevata, deve essere rifiutata esplicitamente anziché tentare una risoluzione fragile basata su assunzioni GNU o parsing di `ls -l`.

Il supporto symlink potrà essere aggiunto in seguito soltanto dopo una specifica semantica e un PoC dedicato.

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

- shebang diversi da `#!/bin/sh` nel portable core;
- `$RANDOM`;
- `BASH_SOURCE`;
- `[[`;
- `readlink -f`;
- path host-specific noti;
- format operand di `printf` variabili, almeno come elemento da sottoporre a review.

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

su `dash`, Bash `--posix` e BusyBox `sh`.

## Conseguenze

Questa decisione autorizza la progettazione del primo entrypoint stabile di `rumiai-os` usando il modello validato dal PoC 002.

Non autorizza ancora:

- supporto symlink;
- dipendenze GNU;
- array/map generici;
- package manager;
- deployment Podman/image/device;
- certificazione macOS/Cygwin.
