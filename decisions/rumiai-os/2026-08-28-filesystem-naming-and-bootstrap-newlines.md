# Decisione — Naming filesystem RumiAI e gestione newline nel bootstrap

Date: 2026-08-28  
Status: **Accepted**

## Contesto

La prima implementazione della phase 0 conservava un protocollo sentinel per proteggere eventuali newline terminali nei pathname catturati tramite command substitution.

Questa protezione è corretta in generale per pathname arbitrari provenienti dall'esterno, perché POSIX command substitution rimuove uno o più newline terminali dall'output catturato.

Per il bootstrap RumiAI, però, il componente finale reale è controllato dal progetto ed è fissato come:

```text
rumiai-os
```

La complessità del sentinel non è quindi giustificata nel percorso critico della phase 0.

## Decisione 1 — naming controllato da RumiAI

I nomi di file e directory scelti o generati automaticamente da RumiAI/RumiAI tools seguono la specifica:

```text
specifications/rumiai-os/FILESYSTEM-NAMING.md
```

Default:

```text
[a-z0-9][a-z0-9._-]*[a-z0-9]
```

con nomi di un solo carattere `[a-z0-9]` ammessi.

In particolare, i nomi controllati da RumiAI non contengono whitespace o control characters e non iniziano con `-`.

Nomi utente o provenienti da tool/dataset esterni sono invece dati esterni e non vengono modificati automaticamente per conformarsi alla convention.

## Decisione 2 — niente sentinel nella phase 0

La phase 0 non usa più un protocollo sentinel per catturare l'output di `command -v` o `realpath`.

Sono sufficienti normali command substitution POSIX:

```sh
RumiAI_BOOTSTRAP_BIN=$(command -v -- "$0")
RumiAI_BOOTSTRAP_BIN=$(command -p -- realpath -e -- "$RumiAI_BOOTSTRAP_BIN")
```

Motivazione:

- il command name controllato è `rumiai-os`, quindi l'output utile non termina con newline appartenenti al filename;
- il risultato canonicalizzato di `realpath` termina con il componente controllato `rumiai-os`;
- eventuali newline presenti in directory parent scelte dall'utente o in componenti esterni sono newline **interni** al pathname complessivo e non vengono rimossi dalla command substitution;
- un symlink esterno invocato direttamente viene prima conservato in `$0` senza command substitution e poi canonicalizzato al target RumiAI.

Il problema generale dei pathname esterni con newline terminali resta reale, ma deve essere affrontato nei sottosistemi che trattano pathname arbitrari, non nel bootstrap controllato.

## Decisione 3 — `command -v` non deve restituire necessariamente un path assoluto

La phase 0 non richiede più che l'output di `command -v` sia già assoluto.

Un `PATH` può contenere componenti relativi. Il risultato di `command -v` viene quindi passato direttamente a `realpath -e`, che è responsabile della canonicalizzazione fisica assoluta.

Questo elimina una restrizione artificiale e rende corretta anche l'invocazione attraverso un `PATH` relativo.

## Conseguenza

La phase 0 è più piccola:

- nessuna funzione di capture;
- nessun sentinel;
- nessuna variabile newline temporanea;
- nessun controllo intermedio di assolutezza dopo `command -v`;
- `realpath -e` rimane l'unico punto di canonicalizzazione.

La phase 1 continua a iniziare immediatamente dopo con i18n minimale e logger.
