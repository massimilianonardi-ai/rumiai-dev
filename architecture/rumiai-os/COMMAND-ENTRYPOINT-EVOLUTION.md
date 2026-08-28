# RumiAI OS — Evoluzione del command entrypoint

Status: **historical design rationale**  
Date: 2026-08-28

## Obiettivo iniziale

Il problema di partenza era garantire che qualunque comando RumiAI potesse usare immediatamente il bootstrap environment, i18n e logger senza duplicare bootstrap logic in ogni script.

Il caso guida era `log`:

```text
lib/log.lib
```

caricata dal bootstrap per l'uso in-process da POSIX shell, insieme a un comando pubblico `log` utilizzabile anche da tool scritti in altri linguaggi.

## Prima ipotesi: command wrapper in `bin/`

È stata considerata una coppia:

```text
lib/log.lib
bin/log
```

con `bin/log` come adapter CLI sottile verso la library.

È emerso immediatamente il problema di garantire che `bin/log`, quando invocato direttamente, entrasse sempre nell'environment RumiAI prima di usare la library.

## Ipotesi shebang parametrico

È stata valutata concettualmente una forma tipo:

```text
#!/path/to/rumiai-os log
```

ma è stata scartata perché:

- richiede pathname assoluto o altre assunzioni non relocatable;
- la semantica generale `#!` non appartiene al contratto POSIX;
- l'uso di argomenti nello shebang non è un contratto portabile sufficiente per il progetto.

## Multicall tramite symlink

È stata quindi esplorata la forma:

```text
bin/log -> ../rumiai-os
```

con `rumiai-os` come multicall front controller.

Per distinguere il comando dal runtime fisico sono state introdotte nelle bozze:

```text
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND
```

Il modello inizialmente sembrava elegante perché ogni comando pubblico passava automaticamente dal bootstrap.

## `cmd/` come directory privata

Per separare public entry e implementation è stata proposta e temporaneamente accettata:

```text
RumiAI_COMMAND_DIR=$RumiAI_ROOT/cmd
```

con:

```text
bin/foo -> ../rumiai-os
cmd/foo
```

`bin/` restava nel PATH e `cmd/` fuori PATH.

## Problemi emersi nel multicall

### Alias esterni

Un alias:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

poteva essere validato dal basename `log`, ma:

```text
/usr/local/bin/my-log -> /opt/rumiai/rumiai-os
```

non conteneva alcuna informazione che permettesse di dedurre che `my-log` significasse `log`.

La soluzione avrebbe richiesto ulteriori mapping o regole sugli hop di symlink.

### Duplicate basenames

La presenza di:

```text
package-a/bin/foo
package-b/bin/foo
```

ha mostrato che `${0##*/}` non è un'identità di comando sufficiente.

Il routing avrebbe dovuto conservare il pathname pubblico completo selezionato dal PATH.

### `cmd/` shadow

Per evitare collisioni sarebbe stato necessario trasformare `cmd/` in uno shadow sparse della root:

```text
package-a/bin/foo
    ↔ cmd/package-a/bin/foo

package-b/bin/foo
    ↔ cmd/package-b/bin/foo
```

Questo risolveva tecnicamente il problema, ma aumentava notevolmente bookkeeping e complessità concettuale.

### Alias rinominati verso canonical public entry

È stata considerata una variante:

```text
/usr/local/bin/my-log
    -> /opt/rumiai/bin/log
    -> /opt/rumiai/rumiai-os
```

che preservava l'identità `log`, ma richiedeva distinguere symlink semantici da symlink fisici e definire quanti hop semantici supportare.

### Blast radius

Il multicall rende il bootstrap comune a tutti i comandi, ma implica anche che un guasto nel bootstrap blocchi tutti i command entrypoint, inclusi eventuali comandi di recovery.

Questo problema resta rilevante anche nel modello interprete, ma il multicall aggiungeva ulteriore routing prima dell'esecuzione del comando.

## Trampoline shell

È stata considerata la forma:

```sh
#!/bin/sh
exec rumiai-os "$0" "$@"
```

Questa richiede `rumiai-os` nel PATH e passa il pathname del comando come operando, eliminando gran parte della logica multicall.

È stato chiarito che non crea ricorsione se `rumiai-os` non riesegue il launcher, ma usa il pathname solo per identificare l'implementazione.

Tuttavia, mantenendo una separazione launcher/implementation, il modello avrebbe continuato a richiedere uno shadow o un mapping verso una seconda implementazione.

## Scelta finale: `rumiai-os` come interprete

La soluzione accettata è:

```text
#!/usr/bin/env rumiai-os
```

Il command file è esso stesso l'implementazione.

Il runtime selezionato dal PATH:

1. esegue phase 0;
2. inizializza phase 1, i18n e logger;
3. riceve e canonicalizza il pathname del command file;
4. rimuove tale pathname da `$@`;
5. source-a il file nello stesso processo.

Esempio:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Non servono più:

```text
cmd/
RumiAI_COMMAND_DIR
multicall symlink interni
basename registry
alias mapping
public/private shadow tree
```

## Trade-off accettato

La semplicità viene ottenuta introducendo un requisito host esplicito:

```text
/usr/bin/env
#! executable scripts
rumiai-os nel PATH
convenzione argv compatibile
source compatibile del command file
```

POSIX.1-2024 non garantisce questi dettagli; il comportamento deve quindi essere parte del RumiAI host profile e verificato tramite PoC sui reference host.

Questa eccezione è stata preferita a una crescente quantità di logica interna necessaria per simulare lo stesso risultato restando nel solo contratto POSIX astratto.

## Materiale storico conservato

```text
decisions/rumiai-os/2026-08-28-multicall-command-layout.md
drafts/rumiai-os/phase-1-multicall/
```

## Modello corrente

```text
decisions/rumiai-os/2026-08-28-command-interpreter-shebang.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
architecture/rumiai-os/PHASE-1.md
drafts/rumiai-os/phase-1-command-interpreter/
```
