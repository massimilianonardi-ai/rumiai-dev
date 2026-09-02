# Decisione — Phase 0 bootstrap di RumiAI OS

Date: 2026-08-28  
Status: **Partially superseded 2026-09-02**

## Decisione ancora valida

Resta accettata la separazione concettuale **Phase 0**: il percorso minimo che deve stabilire in modo affidabile il bootstrap fisico e la root prima dei sottosistemi runtime successivi.

Lo stato fondamentale corrente è:

```text
m_BOOTSTRAP_BIN
m_ROOT
```

Sul percorso di successo Phase 0 resta silenziosa.

La root continua a essere derivata dal bootstrap fisico/canonicalizzato e il codice resta POSIX shell con:

```sh
#!/bin/sh
```

## Parti superseded

Sono superseded:

- il namespace `RumiAI_*`;
- il mapping numerico/simbolico `RumiAI_BOOTSTRAP_FATAL_*` descritto dalla versione storica;
- l'uso di `realpath -e` come canonicalizzatore;
- la decisione di eliminare il sentinel per la cattura esatta dei pathname;
- la descrizione della Phase 1 come bootstrap configuration + `i18n`.

La regola corrente di pathname è:

```text
VALIDATE EXISTENCE
→ CANONICALIZE EXISTING PATH
→ VALIDATE REQUIRED TYPE
```

La cattura corrente può usare sentinel per preservare trailing newline shell-rappresentabili.

Il sottosistema linguistico corrente è `lang`.

## Autorità corrente

```text
architecture/rumiai-os/PHASE-0.md
specifications/rumiai-os/ENTRYPOINT-ROOT-RESOLUTION.md
decisions/rumiai-os/2026-09-02-bootstrap-runtime-standards.md
```

La versione storica completa resta disponibile in Git history ed è evidenza soltanto del contratto che descriveva a quella revisione.
