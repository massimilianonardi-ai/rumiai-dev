# Decisione — Naming filesystem RumiAI e gestione newline nel bootstrap

Date: 2026-08-28  
Status: **Partially superseded 2026-09-02**

## Naming filesystem ancora valido

Resta accettato che i nomi di file e directory scelti o generati automaticamente da RumiAI seguano la specifica:

```text
specifications/rumiai-os/FILESYSTEM-NAMING.md
```

I nomi esterni o forniti dall'utente restano dati esterni e non vengono rinominati automaticamente per conformarsi alla convenzione RumiAI.

Il nome canonico dell'entrypoint prodotto resta:

```text
rumiai-os
```

## Decisione newline superseded

La precedente conclusione secondo cui Phase 0 non dovesse usare un sentinel nella cattura di pathname tramite command substitution è superseded.

Il bootstrap stabilizzato preserva il dominio di pathname shell-rappresentabile necessario usando una tecnica sentinel per neutralizzare la rimozione dei trailing newline effettuata dalla POSIX command substitution.

Questa tecnica è un dettaglio di exact capture e non introduce un secondo modello di path resolution.

## Canonicalizzazione superseded

La precedente dipendenza da:

```text
realpath -e
```

è superseded per il profilo host corrente.

La regola accettata è:

```text
VALIDATE EXISTENCE
→ CANONICALIZE EXISTING PATH
→ VALIDATE REQUIRED TYPE
```

con canonicalizzazione optionless `realpath` applicata solo a un pathname già verificato come esistente.

## Autorità corrente

```text
architecture/rumiai-os/PHASE-0.md
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Il contenuto storico completo resta disponibile in Git history.
