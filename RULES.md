# RumiAI Development Rules

Questo documento contiene regole canoniche per lo sviluppo di RumiAI.

## Autorità

`rumiai-dev` è la fonte autorevole per regole, workflow, decisioni, specifiche, terminologia, chat e memoria dello sviluppo.

`rumiai-dev-PoCs` è il laboratorio dei test eseguibili: contiene codice sorgente dei PoC, sessioni di test, input, output, log significativi e risultati dettagliati.

La memoria conversazionale di ChatGPT è solo un supporto operativo e non prevale mai sul contenuto canonico di `rumiai-dev`.

In caso di conflitto tra memoria/conversazione e repository, prevale il repository.

## Shell

Tutti gli script shell devono essere POSIX-compliant e devono usare esattamente lo shebang:

```sh
#!/bin/sh
```

L'uso di una shell diversa o di funzionalità non POSIX è un'eccezione e richiede:

1. una ragione tecnica concreta;
2. approvazione esplicita;
3. documentazione dell'eccezione e della sua motivazione.

In assenza di questi tre requisiti, l'eccezione non è ammessa.

## Portabilità e path

RumiAI dispone di un portable runtime il cui compito è isolare il progetto da installazioni particolari, layout locali e path specifici della macchina.

Di conseguenza:

- path assoluti o host-specific hardcoded in test, script o codice sorgente non sono ammessi;
- i path delle risorse gestite dal portable runtime devono essere derivati dinamicamente dalla root del runtime o da altre root semantiche definite dal runtime;
- risorse esterne al portable runtime devono essere fornite tramite configurazione esplicita e non tramite assunzioni sull'ambiente locale;
- il codice non deve dipendere dalla directory corrente da cui viene eseguito, salvo che ciò faccia parte esplicitamente del contratto del comando;
- installazioni locali particolari, directory utente, mount point, path Homebrew, path di interpreti o tool e simili non devono essere incorporati nel codice;
- ogni eccezione deve essere esplicitamente approvata, tecnicamente motivata e documentata.

Il portable runtime deve essere relocatable: spostare il suo albero su un altro path non deve richiedere modifiche al codice o agli script.
