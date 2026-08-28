# Decisione — Command entrypoint tramite `#!/usr/bin/env rumiai-os`

Date: 2026-08-28
Status: **Accepted design decision**

## Decisione

I command entrypoint RumiAI direttamente eseguibili usano come prima riga:

```text
#!/usr/bin/env rumiai-os
```

`rumiai-os` deve essere risolvibile tramite il `PATH` dell'ambiente RumiAI attivo.

Il command file è esso stesso il comando: non esiste una seconda implementazione shadow obbligatoria sotto `cmd/` e non è richiesto un symlink multicall verso `rumiai-os`.

Il modello precedente basato su:

```text
bin/<command> -> ../rumiai-os
cmd/<command>
```

è superseded da questa decisione.

## Modello di esecuzione

Quando l'host supporta la convenzione scelta, l'esecuzione di un command file come:

```text
/path/to/foo arg1 arg2
```

con:

```text
#!/usr/bin/env rumiai-os
```

porta concettualmente a:

```text
/usr/bin/env rumiai-os /path/to/foo arg1 arg2
```

`env` seleziona `rumiai-os` dal `PATH` e il runtime RumiAI riceve il pathname del command file come primo operando, seguito dagli argomenti originali.

`rumiai-os`:

1. risolve la propria root fisica con la phase 0 già definita;
2. inizializza il bootstrap environment, i18n e logger;
3. canonicalizza il command file ricevuto;
4. rende disponibili le variabili RumiAI;
5. esegue il corpo del command file nello stesso processo shell tramite source, così le librerie bootstrap già caricate restano disponibili;
6. propaga lo status finale del command file.

Esempio minimale:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

`log` in questo esempio è la funzione caricata da `lib/log.lib`, non un secondo processo.

## Nessun command shadow

La directory:

```text
$RumiAI_ROOT/cmd
```

non è più una root semantica accettata e `RumiAI_COMMAND_DIR` non fa più parte del bootstrap environment corrente.

I command file possono esistere nei pathname appropriati del sistema, anche in directory annidate e con basename uguali in directory differenti.

L'identità operativa del comando è il pathname del file ricevuto dal runtime, non il solo basename.

Questo evita collisioni artificiali fra, per esempio:

```text
package-a/bin/foo
package-b/bin/foo
```

## Alias e symlink

Un symlink esterno può rinominare liberamente un command file:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

L'host esegue comunque il command file RumiAI e il runtime canonicalizza il pathname ricevuto prima di eseguire il corpo reale.

Il nome esterno dell'alias non è quindi usato per determinare quale implementazione eseguire.

Un symlink che punta direttamente a `rumiai-os` non diventa per questo un alias di un command file: esegue il front controller stesso.

## Runtime selezionato dal PATH

Il `rumiai-os` che interpreta il command file è quello risolto da `env` nel `PATH` corrente.

Questa è una proprietà intenzionale del modello, analoga all'uso di `/usr/bin/env` per scegliere un interprete attivo in un ambiente.

Di conseguenza, in presenza di più installazioni RumiAI, il `PATH` determina quale runtime è attivo. Un command file può quindi essere interpretato da un runtime diverso da quello fisicamente vicino al file se il `PATH` seleziona tale runtime.

La compatibilità tra command file e runtime/versione dovrà essere gestita separatamente quando emergerà il requisito di versioning/capability; non viene introdotto ora un meccanismo di pinning del runtime.

## Portabilità e eccezione deliberata

POSIX.1-2024 non specifica la semantica generale della convenzione `#!`: la Shell Command Language dichiara unspecified i risultati quando un file di shell commands inizia con `#!`.

POSIX standardizza la utility `env` e il suo uso del `PATH`, ma non garantisce che la utility sia installata esattamente come `/usr/bin/env`.

Pertanto questa decisione è una **eccezione deliberata al solo contratto POSIX astratto** ed estende il profilo host richiesto da RumiAI con i seguenti requisiti:

```text
/usr/bin/env esiste ed è eseguibile
l'host supporta executable scripts con #!
#!/usr/bin/env rumiai-os passa il pathname del command file a rumiai-os
rumiai-os viene risolto tramite PATH
il command file può essere successivamente sourced dal /bin/sh di riferimento con la prima riga #! trattata in modo compatibile
```

Questi requisiti devono essere verificati con PoC sui reference host prima della promozione a product implementation.

La scelta è stata accettata perché elimina una quantità sostanziale di logica e casi limite dal bootstrap/multicall e rende esplicito un requisito host semplice e verificabile.

## Confronto con alternative scartate

### Multicall tramite symlink

Proposta precedente:

```text
bin/log -> ../rumiai-os
cmd/log
```

Ha richiesto progressivamente:

- conservazione di basename e pathname pre-realpath;
- validazione degli alias esterni;
- regole per alias rinominati;
- gestione di command basename duplicati;
- ipotesi di shadow tree sotto `cmd/`;
- distinzione fra public path e implementation path;
- ulteriore dispatch nel front controller.

La complessità risultante è stata giudicata non proporzionata al beneficio.

### Trampoline POSIX shell

Alternativa considerata:

```sh
#!/bin/sh
exec rumiai-os "$0" "$@"
```

Evita `/usr/bin/env`, ma mantiene un launcher shell aggiuntivo e non elimina il problema se si separano launcher e implementazione. È stata scartata in favore del modello in cui `rumiai-os` è direttamente l'interprete del command file.

## Error status

Resta valida la regola già accettata:

```text
0       success
1..125  errori specifici
```

I codici assegnati sono sequenziali al momento dell'introduzione, append-only, non vengono rinumerati né riutilizzati dopo pubblicazione.

La mappatura definitiva fra errori condivisi del bootstrap e return status dei singoli command file resta un tema separato.

## Product boundary

Questa decisione modifica design, specifiche e bozze in `rumiai-dev`.

Non autorizza ancora modifiche di phase 1 o del nuovo command model nel repository prodotto `rumiai-os`.
