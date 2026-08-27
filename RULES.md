# RumiAI Development Rules

Questo documento contiene regole canoniche per lo sviluppo di RumiAI.

## Autorità e ruolo dei repository

`rumiai-dev` è la fonte autorevole per regole, workflow, decisioni, specifiche, terminologia, architettura, chat e memoria dello sviluppo.

`rumiai-dev-PoCs` è il laboratorio dei test eseguibili: contiene codice sorgente dei PoC, sessioni di test, input, output, log significativi e risultati dettagliati.

`rumiai-os` è il repository del sistema/prodotto stabile. Il codice vi entra solo dopo che principi, specifiche e decisioni rilevanti sono stati consolidati e, quando necessario, validati tramite PoC.

I repository storici o di riferimento, incluso `massimilianonardi/m`, sono materiale da analizzare: non sono fonti normative e il loro codice non deve essere copiato o migrato automaticamente.

La memoria conversazionale di ChatGPT è solo un supporto operativo e non prevale mai sul contenuto canonico di `rumiai-dev`.

In caso di conflitto tra memoria/conversazione e repository, prevale il repository.

## Contratto di piattaforma

RumiAI OS sviluppa contro **POSIX**, non contro Linux, macOS, Windows o una specifica distribuzione.

POSIX è il contratto di piattaforma. Il fatto che una soluzione funzioni su GNU/Linux o su un particolare Unix-like non è sufficiente a considerarla portabile.

Di conseguenza:

- non si devono introdurre dipendenze accidentali da estensioni GNU, Bash o da peculiarità di uno specifico host;
- comportamento specifico dell'host è ammesso soltanto dietro un'astrazione o adapter esplicito quando POSIX non fornisce la funzionalità necessaria;
- gli adapter specifici non devono contaminare il modello generale del sistema;
- la portabilità deve essere verificata automaticamente su implementazioni POSIX o POSIX-compatible differenti e non affidata soltanto alla disciplina dello sviluppatore.

Windows non influenza l'architettura di RumiAI OS. RumiAI OS richiede un ambiente POSIX-compatible; su Windows la documentazione può raccomandare Cygwin o indicare altri ambienti compatibili. L'eventuale preparazione dell'ambiente host non cambia il contratto interno di RumiAI OS.

## Shell

Tutti gli script shell devono essere POSIX-compliant e devono usare esattamente lo shebang:

```sh
#!/bin/sh
```

Non devono essere usate accidentalmente funzionalità specifiche di Bash o di altre shell, né opzioni GNU non previste da POSIX. Esempi tipici da non assumere includono array Bash, `[[ ... ]]`, `BASH_SOURCE`, process substitution e `readlink -f` GNU.

L'uso di una shell diversa, di una funzionalità non POSIX o di una dipendenza GNU-specifica è un'eccezione e richiede:

1. una ragione tecnica concreta;
2. approvazione esplicita;
3. documentazione dell'eccezione e della sua motivazione.

In assenza di questi tre requisiti, l'eccezione non è ammessa.

Quando una funzionalità utile non è disponibile in POSIX, si preferisce una primitiva portabile e riutilizzabile, purché la sua correttezza, sicurezza e portabilità siano verificabili.

## Portabilità, root e path

RumiAI OS deve poter operare come ambiente relocatable e non deve dipendere da installazioni particolari, layout locali o path specifici della macchina.

Di conseguenza:

- path assoluti host-specific hardcoded in test, script o codice sorgente non sono ammessi;
- la root di RumiAI OS deve essere determinata dinamicamente dal punto di ingresso appropriato;
- i path delle risorse gestite dal sistema devono essere derivati dalla root o da root/path semantici definiti centralmente;
- i componenti devono ricevere o consumare path semantici e non duplicare la conoscenza del layout fisico;
- risorse esterne devono essere fornite tramite configurazione esplicita e non tramite autodetection basata su path locali convenzionali;
- il codice non deve dipendere dalla directory corrente da cui viene eseguito, salvo che ciò faccia parte esplicitamente del contratto del comando;
- installazioni locali particolari, directory utente, mount point, path Homebrew, path di interpreti o tool e simili non devono essere incorporati nel codice;
- ogni eccezione deve essere esplicitamente approvata, tecnicamente motivata e documentata.

La regola generale è: **default portabile, override esplicito**.

Spostare l'albero di RumiAI OS su un altro path non deve richiedere modifiche al codice o agli script.

## Root del repository `rumiai-os`

La radice del repository `rumiai-os` deve contenere soltanto due file, oltre alle directory necessarie:

- `rumiai-os`;
- `README.md`.

`rumiai-os` è l'entrypoint principale, usa `#!/bin/sh` ed è un front controller: inizializza il minimo indispensabile e delega la logica a componenti interni. Non deve diventare uno script monolitico.

L'avvio iniziale da un altro sistema operativo non limita la generalità del progetto: lo stesso ambiente avviato può in seguito esporre comandi per deployment hosted, container, immagini/device e, in futuro, installazioni complete o bare-metal.

## Scelta di software e mezzo di esecuzione

RumiAI distingue tra **obiettivo** e **mezzo richiesto dall'utente**.

Se l'utente specifica soltanto il risultato, RumiAI può scegliere autonomamente lo strumento e l'interfaccia più appropriati, privilegiando quando opportuno soluzioni deterministiche, efficienti, verificabili e a minor overhead, come API, CLI o scripting.

Se l'utente specifica un software, un'interfaccia o una modalità di esecuzione, tale scelta diventa parte dell'intento e deve essere rispettata.

Esempio: per una richiesta generica di conversione CAD → Shapefile RumiAI può scegliere GDAL; per una richiesta del tipo "apri QGIS e converti il file" deve utilizzare QGIS.

La GUI e il computer-use sono quindi modalità operative tra le altre, non il modello generale di interazione con il computer.

## Workflow di sviluppo

Il flusso di riferimento è:

1. regola, specifica o decisione in `rumiai-dev`;
2. quando serve evidenza sperimentale, PoC e sessione di test in `rumiai-dev-PoCs`;
3. consolidamento dei risultati in `rumiai-dev`;
4. implementazione stabile in `rumiai-os`.

Un repository storico o sperimentale può fornire idee e codice di riferimento, ma ogni elemento deve essere valutato rispetto alle regole correnti prima del riuso.
