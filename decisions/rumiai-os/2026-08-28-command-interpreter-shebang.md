# Decisione — Command entrypoint tramite `#!/usr/bin/env rumiai-os`

Date: 2026-08-28  
Status: **Accepted; terminology/layout updated 2026-09-02**

## Decisione ancora valida

I command entrypoint RumiAI direttamente eseguibili usano:

```text
#!/usr/bin/env rumiai-os
```

Il command file contiene direttamente il proprio corpo di implementazione. Non esiste una seconda implementazione shadow obbligatoria sotto `cmd/` e il vecchio multicall resta superseded.

L'esecuzione diretta richiede il normale profilo host per `/usr/bin/env`, shebang executable e risoluzione dell'interprete tramite `PATH`.

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

## Command identity

Il runtime canonicalizza il pathname del command/source file e lo espone come environment variable:

```text
m_COMMAND_BIN
```

L'identità operativa resta il pathname canonico del file, non il solo basename. Alias/symlink esterni possono quindi rinominare un command file senza introdurre un registry globale dei basename.

Prima del source, il runtime rimuove il pathname del command file da `$@`; il body osserva soltanto i propri argomenti.

## Runtime/root semantics

La root RumiAI deriva dal runtime fisico attivo, non dalla posizione del command file.

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

## Autorità corrente

```text
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Il rationale storico completo delle alternative scartate resta disponibile in Git history.
