# Decisione — Phase 1 bootstrap environment

Date: 2026-08-28  
Status: **Superseded 2026-09-02**

Il modello Phase-1 descritto originariamente in questo documento è stato sostituito dopo l'ottimizzazione del bootstrap.

In particolare sono superseded:

```text
RumiAI_* environment variables
bin/ direttamente nel PATH
conf/bootstrap/language
conf/bootstrap/text-encoding
selezione lingua da LC_ALL / LC_MESSAGES / LANG
encoding bootstrap configurabile
nome/API i18n
```

Il contratto corrente usa:

```text
m_* environment variables
bin/sys-osarch
bin/sys
bin/ext-osarch
bin/ext
lang/current
fallback lang/en_US
UTF-8 fisso
API lang
```

La Phase 1 corrente, inclusi command entry e shell selection, è definita da:

```text
architecture/rumiai-os/PHASE-1.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/LANG-BOOTSTRAP.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

Il contenuto storico completo resta disponibile in Git history.
