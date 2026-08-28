# Decisione — Command entrypoint tramite `#!/usr/bin/env rumiai-os`

Date: 2026-08-28
Status: **Accepted design decision**

## Decisione

I command entrypoint RumiAI direttamente eseguibili usano come prima riga:

```text
#!/usr/bin/env rumiai-os
```

`rumiai-os` deve essere risolvibile tramite il `PATH` dell'ambiente RumiAI attivo.

Il file contiene direttamente il proprio corpo di implementazione: non esiste una seconda implementazione shadow obbligatoria sotto `cmd/` e non è richiesto un symlink multicall verso `rumiai-os`.

Il modello precedente basato su:

```text
bin/<command> -> ../rumiai-os
cmd/<command>
```

è superseded da questa decisione.

## Distinzione fondamentale: eseguibile vs sorgente esplicito

Lo shebang appartiene al meccanismo di **esecuzione diretta da parte dell'host**.

Quindi:

```text
./foo
```

richiede che `foo` sia un file eseguibile e, per usare RumiAI come interprete, che inizi con:

```text
#!/usr/bin/env rumiai-os
```

Invece:

```text
rumiai-os foo
```

nomina già esplicitamente l'interprete.

In questo secondo caso `foo`:

- non deve obbligatoriamente contenere uno shebang;
- non deve obbligatoriamente avere il bit executable;
- deve essere un file regolare leggibile e risolvibile.

`rumiai-os` non deve quindi verificare lo shebang di un file ricevuto esplicitamente come operando.

## Modello di esecuzione diretta

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

Da quel punto il percorso è lo stesso di:

```text
rumiai-os /path/to/foo arg1 arg2
```

Il runtime:

1. risolve la propria root fisica con la phase 0;
2. inizializza bootstrap environment, i18n e logger;
3. canonicalizza il file ricevuto;
4. verifica che sia un file regolare leggibile;
5. rende disponibili le variabili RumiAI;
6. rimuove il pathname del file dagli argomenti;
7. esegue il corpo nello stesso processo shell tramite source;
8. propaga lo status finale.

Esempio direttamente eseguibile:

```sh
#!/usr/bin/env rumiai-os
log "$@"
```

Esempio valido solo come sorgente esplicito, ma ugualmente interpretabile:

```sh
log "$@"
```

tramite:

```text
rumiai-os file
```

## Nessun command shadow

La directory:

```text
$RumiAI_ROOT/cmd
```

non è più una root semantica accettata e `RumiAI_COMMAND_DIR` non fa più parte del bootstrap environment corrente.

I command file possono esistere nei pathname appropriati del sistema, anche in directory annidate e con basename uguali in directory differenti.

L'identità operativa è il pathname del file ricevuto dal runtime, non il solo basename.

## Alias e symlink

Un symlink esterno può rinominare liberamente un command file direttamente eseguibile:

```text
/usr/local/bin/my-log -> /opt/rumiai/bin/log
```

Il runtime canonicalizza il pathname ricevuto prima di eseguire il corpo reale.

Il nome esterno dell'alias non è quindi usato per determinare quale implementazione eseguire.

## Runtime selezionato dal PATH

Per l'esecuzione diretta tramite shebang, il `rumiai-os` che interpreta il command file è quello risolto da `env` nel `PATH` corrente.

Questa è una proprietà intenzionale del modello.

La compatibilità tra command file e runtime/versione dovrà essere gestita separatamente quando emergerà il requisito di versioning/capability; non viene introdotto ora un meccanismo di pinning del runtime.

## Portabilità e eccezione deliberata

POSIX.1-2024 non specifica la semantica generale della convenzione `#!` e non garantisce che `env` sia installato esattamente in `/usr/bin/env`.

Pertanto l'esecuzione diretta tramite:

```text
#!/usr/bin/env rumiai-os
```

è una **eccezione deliberata al solo contratto POSIX astratto** ed estende il profilo host richiesto da RumiAI.

Questi requisiti devono essere verificati con PoC sui reference host prima della promozione a product implementation.

L'invocazione esplicita:

```text
rumiai-os file
```

non dipende invece dalla presenza dello shebang nel file.

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

È stata scartata in favore del modello in cui `rumiai-os` è direttamente l'interprete dei command file eseguibili.

## Error status

Resta valida la regola già accettata:

```text
0       success
1..125  errori specifici
```

I codici assegnati sono sequenziali al momento dell'introduzione, append-only, non vengono rinumerati né riutilizzati dopo pubblicazione.

La mappatura definitiva fra errori condivisi del bootstrap e return status dei singoli source/command file resta un tema separato.

## Product boundary

Questa decisione modifica design, specifiche e bozze in `rumiai-dev`.

Non autorizza ancora modifiche di phase 1 o del nuovo command model nel repository prodotto `rumiai-os`.
