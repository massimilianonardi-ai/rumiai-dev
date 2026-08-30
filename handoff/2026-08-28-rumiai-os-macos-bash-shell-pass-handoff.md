# Handoff — RumiAI OS — macOS Bash shell PASS

Data: 2026-08-28
Stato: **Bash branch physically validated on macOS**

## Esito

Il ramo Bash della RumiAI shell è stato validato fisicamente su macOS.

Risultato osservato:

```text
RumiAI_ROOT=/Volumes/RumiAI/rumiai-os
RumiAI_LANGUAGE=it_IT
RumiAI_TEXT_ENCODING=UTF-8
RUMIAI_SHELL_PROBE=macos-bash-pass
[RumiAI:BASH] user@host:/Volumes/RumiAI/rumiai-os $
```

Comportamento validato:

```text
RumiAI shell
    ↓
conf/shell/default = bash
    ↓
exec bash --noprofile --rcfile "$RumiAI_CONF_DIR/shell/bashrc" -i
    ↓
RumiAI-specific bashrc caricato
    ↓
custom prompt applicato
```

## Target

Repository prodotto:

```text
massimilianonardi-ai/rumiai-os
```

La validazione storica resta associata alla revisione effettivamente esercitata e ai relativi test/sessioni registrati nel repository.

## Decisione consolidata

Il default shell selector può scegliere Bash quando disponibile.

La RumiAI shell Bash non carica automaticamente i normali startup file host perché usa:

```text
--noprofile
--rcfile <RumiAI-specific bashrc>
```

Questo mantiene l'ambiente RumiAI deterministico e separato dalla configurazione interattiva ordinaria dell'host.

## Nota terminologica

`RumiAI shell` è il termine canonico. Abbreviazioni conversazionali non costituiscono nomi di prodotto o componenti.
