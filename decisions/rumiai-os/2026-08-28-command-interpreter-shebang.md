# Decisione — Command entrypoint tramite `#!/usr/bin/env rumiai-os`

Date: 2026-08-28  
Status: **Accepted; scope refined 2026-09-09**

## Scope corrente

La decisione originaria resta valida per i **bootstrap-integrated command** definiti dalla decisione successiva:

```text
decisions/rumiai-os/2026-09-09-command-shebang-and-read-key.md
```

Questi command entrypoint RumiAI direttamente eseguibili usano:

```text
#!/usr/bin/env rumiai-os
```

quando dipendono attualmente dalle facility inizializzate dal bootstrap RumiAI oppure quando tale dipendenza è ragionevolmente prevedibile nel normale ruolo/evoluzione del comando.

La formulazione originaria che applicava universalmente questo shebang a ogni executable RumiAI è stata raffinata il 2026-09-09: una standalone shell utility può usare `#!/bin/sh` soltanto dietro preventiva autorizzazione esplicita e documentazione autorevole delle condizioni definite dalla decisione successiva e da `COMMAND-ENTRYPOINTS.md`.

Il primo caso approvato è:

```text
bin/sys/read-key
```

Non vengono introdotti alias né una scelta automatica dello shebang.

## Command file bootstrap-integrated

Il command file contiene direttamente il proprio corpo di implementazione. Non esiste una seconda implementazione shadow obbligatoria sotto `cmd/` e il vecchio multicall resta superseded.

L'esecuzione diretta tramite `#!/usr/bin/env rumiai-os` richiede il normale profilo host per `/usr/bin/env`, shebang executable e risoluzione dell'interprete tramite `PATH`.

L'invocazione esplicita:

```text
rumiai-os file [args...]
```

nomina già l'interprete; il file sorgente deve essere un regular file leggibile ma non richiede di per sé shebang o executable bit.

## Active runtime

Dentro l'ambiente portable/attivato il runtime canonico è esposto tramite:

```text
bin/sys/rumiai-os -> ../../rumiai-os
```

Poiché `bin/sys` partecipa al RumiAI `PATH`, `/usr/bin/env rumiai-os` può risolvere il runtime attivo senza integrazione host obbligatoria.

Questo symlink non è multicall e non implementa routing.

Le standalone shell utility approvate non dipendono da questo meccanismo per il proprio interprete.

## Command identity

Per i file interpretati dal runtime RumiAI, il runtime canonicalizza il pathname del command/source file e lo espone come environment variable:

```text
m_COMMAND_BIN
```

L'identità operativa resta il pathname canonico del file, non il solo basename. Alias/symlink esterni possono quindi rinominare un command file senza introdurre un registry globale dei basename.

Prima del source, il runtime rimuove il pathname del command file da `$@`; il body osserva soltanto i propri argomenti.

Una standalone shell utility non riceve né richiede `m_COMMAND_BIN` come parte del proprio contratto.

## Runtime/root semantics

Per i bootstrap-integrated command la root RumiAI deriva dal runtime fisico attivo, non dalla posizione del command file.

La precedente terminologia:

```text
RumiAI_ROOT
RumiAI_BOOTSTRAP_BIN
RumiAI_COMMAND_BIN
i18n
```

è superseded rispettivamente dal namespace `m_*` e dal resolver `lang`.

## Portabilità

La semantica `#!` resta un'estensione deliberata del profilo host rispetto al contratto POSIX astratto. L'esecuzione esplicita `rumiai-os file` non dipende dallo shebang del file.

I command body shell restano POSIX `sh` secondo le regole correnti; la scelta fra `#!/usr/bin/env rumiai-os` e l'eventuale `#!/bin/sh` standalone è regolata separatamente dal contratto runtime.

## Autorità corrente

```text
RULES.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/POSIX-PORTABILITY-LAYER.md
decisions/rumiai-os/2026-09-09-command-shebang-and-read-key.md
```

Il rationale storico completo della formulazione originaria e delle alternative scartate resta disponibile in Git history.
