# Decisione — Multicall commands, `cmd/` e bootstrap status

Date: 2026-08-28
Status: **Accepted design decision**

## Directory dei comandi privati

La directory privata per le implementazioni dei comandi fuori `PATH` è:

```text
$RumiAI_ROOT/cmd
```

Variabile canonica:

```text
RumiAI_COMMAND_DIR=$RumiAI_ROOT/cmd
```

Ruoli distinti:

```text
bin/  namespace pubblico dei comandi; partecipa a PATH
cmd/  implementazioni private; non partecipa a PATH
```

## Multicall

I comandi pubblici possono essere symlink verso il front controller:

```text
bin/log -> ../rumiai-os
bin/foo -> ../rumiai-os
```

Le forme:

```text
log ...
rumiai-os log ...
```

convergono sullo stesso bootstrap e sullo stesso `RumiAI_COMMAND=log`.

`log`, essendo già disponibile come funzione dopo il source di `lib/log.lib`, può essere dispatchato in-process. Gli altri comandi possono essere eseguiti esplicitamente da:

```text
$RumiAI_COMMAND_DIR/$RumiAI_COMMAND
```

## Alias esterni

Un symlink esterno può essere relativo o assoluto e può trovarsi fuori da `RumiAI_ROOT`.

Phase 0 canonicalizza il pathname invocato tramite `realpath -e`; `RumiAI_ROOT` viene quindi derivata dal target fisico `rumiai-os`, non dalla directory che contiene l'alias.

Un alias multicall con basename `<name>` viene accettato solo se esiste il comando pubblico ufficiale:

```text
$RumiAI_BIN_DIR/<name>
```

ed esso canonicalizza allo stesso:

```text
RumiAI_BOOTSTRAP_BIN
```

La directory fisica dell'alias esterno non deve coincidere con `RumiAI_BIN_DIR`.

Questo consente, per esempio:

```text
/usr/local/bin/log -> /opt/rumiai/rumiai-os
```

purché `/opt/rumiai/bin/log` sia un comando pubblico ufficiale registrato sullo stesso front controller.

Un basename arbitrario privo della corrispondente registrazione `bin/<name>` viene rifiutato.

Un alias esterno chiamato `rumiai-os` è invece un alias del front controller stesso e usa la forma:

```text
rumiai-os <command> ...
```

## Invocation identity

Prima della canonicalizzazione vengono preservati:

```text
RumiAI_INVOKED_AS
RumiAI_INVOKED_BIN
```

Dopo phase 0:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

`RumiAI_INVOKED_AS` identifica il basename usato dal caller. `RumiAI_INVOKED_BIN` conserva il pathname pre-realpath che ha condotto al target fisico.

## Bootstrap preferences

La code proposal non usa più valori hardcoded come shortcut.

Il flusso è:

```text
conf/bootstrap/language
    -> LC_ALL
    -> LC_MESSAGES
    -> LANG
    -> en_US

conf/bootstrap/text-encoding
    -> UTF-8 fallback
```

I valori richiesti vengono passati a `i18n.lib` per normalizzazione/selezione. Eventuali fallback non fatali vengono diagnosticati tramite logger solo dopo la sua attivazione.

## Error status condivisi

Prima della stabilizzazione pubblica, la sequenza del front controller viene rinumerata a partire da 1:

```text
1  PATH resolution failure
2  realpath/canonicalization failure
3  invalid bootstrap binary
4  invalid/inaccessible RumiAI root
5  i18n library load failure
6  log library load failure
7  invalid multicall invocation
8  invalid command name
9  private command unavailable
```

La regola è append-only: un numero assegnato non cambia significato e non viene riutilizzato.

Resta da definire separatamente come i return code locali delle librerie/comandi vengono mappati sugli exit status CLI senza collidere con questi status condivisi.

## Product boundary

Questa decisione aggiorna design, specifiche e bozze in `rumiai-dev`. Non costituisce ancora implementazione autorizzata della phase 1 nel repository `rumiai-os`.
