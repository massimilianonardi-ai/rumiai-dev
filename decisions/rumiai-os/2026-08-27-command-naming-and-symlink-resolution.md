# Decisione — Command naming e symbolic-link resolution

Date: 2026-08-27  
Status: **Accepted**

## Contesto

Il PoC 002 ha usato file `.sh` per gli harness e ha scelto di rifiutare l'invocazione dell'entrypoint tramite symbolic link. Queste scelte erano utili per un esperimento circoscritto, ma non rappresentano il contratto desiderato di `rumiai-os`.

Il repository storico `massimilianonardi/m` contiene inoltre implementazioni che tentano di ricavare il path reale del comando e la directory effettiva partendo da `$0`, incluse varianti che gestiscono symbolic link.

## Decisione

### 1. Il nome pubblico di un comando è indipendente dal linguaggio

Un comando eseguibile di RumiAI OS usa un nome semantico senza estensione che identifichi l'interprete.

Esempi:

```text
rumiai-os
pkg
path
install
```

L'implementazione può cambiare nel tempo senza cambiare il nome pubblico del comando.

Un comando inizialmente implementato come POSIX shell può quindi essere reimplementato in futuro tramite un altro runtime approvato senza essere rinominato.

### 2. Estensioni semantiche per file non eseguibili

Le estensioni hanno significato quando descrivono il ruolo del file o quando il file è realmente un sorgente legato al linguaggio.

Convenzioni iniziali:

```text
.lib   libreria sourced
.conf  configurazione
.c     sorgente C
.cpp   sorgente C++
.java  sorgente Java
.js    puro sorgente JavaScript
```

Un eseguibile Node.js con shebang non usa `.js` come parte del nome pubblico del comando.

### 3. Shell

Quando un comando è implementato in shell, il codice deve essere POSIX-compliant e l'eseguibile usa:

```sh
#!/bin/sh
```

L'assenza dell'estensione `.sh` non modifica né indebolisce il contratto POSIX.

### 4. Symbolic link

L'invocazione tramite symbolic link è un caso d'uso da supportare, non da rifiutare per principio.

Quando la root dipende dalla posizione reale dell'eseguibile, il bootstrap deve risolvere il path effettivo del comando.

Prima dell'implementazione stabile deve essere definita e provata una semantica che copra almeno:

- symlink assoluti;
- symlink relativi;
- catene di symlink;
- cycle detection;
- invocazione diretta;
- invocazione tramite `PATH`;
- current working directory arbitraria;
- path contenenti spazi e caratteri shell rilevanti.

### 5. Codice storico come riferimento

Il pattern storico presente in `m`, ad esempio:

```sh
if [ -L "$0" ]
then
  THIS_PATH="$(ls -ld -- "$0")"
  THIS_PATH="${THIS_PATH#*" $0 -> "}"
else
  THIS_PATH="$0"
fi
```

è materiale di riferimento utile e dimostra l'intento di risolvere il comando reale senza dipendere da `readlink -f` GNU.

Non viene però canonizzato automaticamente: il PoC dedicato deve verificare la conformità della baseline POSIX adottata, la semantica dell'output usato per ricavare il target del link e gli edge case indicati sopra.

## Supersession

Questa decisione sostituisce la sezione 3 della decisione:

```text
decisions/rumiai-os/2026-08-27-posix-bootstrap-foundation.md
```

che rifiutava l'invocazione tramite symlink.

## Authorization

Questa decisione non autorizza alcuna scrittura nel repository `rumiai-os` durante la fase iniziale. La relativa implementazione richiede consenso esplicito dell'utente.
