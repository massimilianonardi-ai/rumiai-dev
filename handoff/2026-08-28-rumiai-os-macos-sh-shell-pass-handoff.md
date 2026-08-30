# Handoff — RumiAI OS — macOS POSIX sh shell PASS

Data: 2026-08-28
Stato: **POSIX sh branch physically validated on macOS**

## Esito

Il ramo POSIX `sh` della RumiAI shell è stato validato fisicamente su macOS.

La validazione ha confermato il comportamento previsto del fallback/selection `sh`, incluso il caricamento della configurazione RumiAI-specific tramite `ENV` quando disponibile e il prompt RumiAI.

## Contratto validato

```text
RumiAI shell
    ↓
conf/shell/default = sh
    ↓
ENV = "$RumiAI_CONF_DIR/shell/shrc" quando il file è presente/leggibile
    ↓
exec POSIX sh -i
```

Il ramo `sh` resta separato dal ramo Bash e non assume startup semantics specifiche di Bash.

## Target

Repository prodotto:

```text
massimilianonardi-ai/rumiai-os
```

La validazione storica resta associata alla revisione e alla sessione effettivamente esercitate.

## Decisione consolidata

Entrambi i rami interattivi supportati mantengono il naming canonico `RumiAI shell` e non introducono un nome alternativo per il prodotto o per il componente.
