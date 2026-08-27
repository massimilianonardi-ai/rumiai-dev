# Decisione — Phase 0 bootstrap di RumiAI OS

Date: 2026-08-28  
Status: **Accepted and implemented**

## Decisione

La prima fase dell'entrypoint `rumiai-os` è definita come **phase 0**.

Il suo unico scopo è stabilire in modo affidabile:

```text
RumiAI_BOOTSTRAP_BIN
RumiAI_ROOT
```

prima che siano disponibili logger, i18n, configurazione o altri sottosistemi.

## Output della phase 0

Sul percorso di successo phase 0 non produce alcun output.

In caso di errore controllabile dopo l'avvio dello script:

- le diagnostiche delle utility sottostanti vengono soppresse;
- viene scritto su stderr un solo identificatore simbolico stabile e language-neutral;
- il processo termina con il corrispondente status numerico.

Mapping iniziale:

```text
RumiAI_BOOTSTRAP_FATAL_PATH_RESOLUTION_ERROR = 10
RumiAI_BOOTSTRAP_FATAL_REALPATH_ERROR        = 11
RumiAI_BOOTSTRAP_FATAL_BIN_ERROR             = 12
RumiAI_BOOTSTRAP_FATAL_ROOT_ERROR            = 13
```

Gli errori che impediscono l'avvio stesso dello script sono esterni alla phase 0 e possono produrre diagnostica dell'host.

## Risoluzione del comando

Se `$0` contiene `/`, viene usato direttamente come pathname di invocazione.

Se `$0` non contiene `/`, viene risolto usando il `PATH` corrente:

```sh
command -v -- "$0"
```

Il risultato deve essere un pathname assoluto per il caso supportato dell'entrypoint esterno.

## Canonicalizzazione

La canonicalizzazione usa la utility standard Issue 8 attraverso il default POSIX utility path:

```sh
command -p -- realpath -e -- "$RumiAI_BOOTSTRAP_BIN"
```

`command -p` evita che una utility omonima precedente nel `PATH` del chiamante diventi accidentalmente la dipendenza del bootstrap.

`realpath -e` è scelto esplicitamente perché POSIX.1-2024 segnala differenze implementative quando non viene specificato né `-e` né `-E`, e il contratto RumiAI richiede che ogni componente del pathname esista.

La precedente decisione di non dipendere da `realpath -e` è quindi **superata**.

## Root

Dopo la canonicalizzazione:

```sh
[ -f "$RumiAI_BOOTSTRAP_BIN" ]
RumiAI_ROOT=${RumiAI_BOOTSTRAP_BIN%/*}
[ -n "$RumiAI_ROOT" ] || RumiAI_ROOT=/
(cd -- "$RumiAI_ROOT")
```

devono stabilire gli invarianti del bootstrap.

`dirname` non viene usato in questo dominio ristretto.

## Stato esportato

Solo dopo il successo di tutti i controlli:

```sh
export -- RumiAI_BOOTSTRAP_BIN RumiAI_ROOT
readonly -- RumiAI_BOOTSTRAP_BIN RumiAI_ROOT
```

Lo stato interno esclusivo della phase 0 viene quindi rimosso prima dell'inizio della phase 1.

## Boundary successivo

La phase 1 inizia immediatamente dopo la phase 0 e deve inizializzare, nell'ordine minimo necessario:

1. supporto i18n necessario al logging;
2. logger RumiAI.

Dopo l'attivazione del logger, la normale diagnostica RumiAI deve passare attraverso il logger.

## Implementazione

Prima implementazione prodotto:

```text
massimilianonardi-ai/rumiai-os/rumiai-os
```

Il file è un executable Git mode `100755` con shebang:

```sh
#!/bin/sh
```

## Supersession

Questa decisione supersede le parti incompatibili delle decisioni precedenti relative a:

- uso di `realpath` senza scelta esplicita `-e`/`-E`;
- diagnostica generica `exit 1` come unico contratto di fallimento della root-resolution;
- possibilità di messaggi esplicativi pre-logger.

Le altre decisioni su naming, symlink support, POSIX baseline e `--` restano valide.
