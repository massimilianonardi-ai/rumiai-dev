# RumiAI Development Rules

Questo documento contiene regole canoniche per lo sviluppo di RumiAI.

## Autorità e ruolo dei repository

`rumiai-dev` è la fonte autorevole per regole, workflow, decisioni, specifiche, terminologia, architettura, chat e memoria dello sviluppo.

`rumiai-dev-PoCs` è il laboratorio dei test eseguibili: contiene codice sorgente dei PoC, sessioni di test, input, output, log significativi e risultati dettagliati.

`rumiai-os` è il repository del sistema/prodotto stabile. Il codice vi entra solo dopo che principi, specifiche e decisioni rilevanti sono stati consolidati e, quando necessario, validati tramite PoC.

I repository storici o di riferimento, incluso `massimilianonardi/m`, sono materiale da analizzare: non sono fonti normative e il loro codice non deve essere copiato o migrato automaticamente.

La memoria conversazionale di ChatGPT è solo un supporto operativo e non prevale mai sul contenuto canonico di `rumiai-dev`.

In caso di conflitto tra memoria/conversazione e repository, prevale il repository.

## Autorizzazione alle modifiche di `rumiai-os`

Almeno nella fase iniziale del progetto, nessun file deve essere creato, copiato, modificato o eliminato nel repository `rumiai-os` senza consenso esplicito dell'utente per quella fase di implementazione.

Una decisione consolidata, un PoC riuscito o una raccomandazione tecnica non costituiscono da soli autorizzazione a scrivere nel repository `rumiai-os`.

`rumiai-dev` e `rumiai-dev-PoCs` possono essere usati per analisi, specifiche, decisioni e sperimentazione secondo il workflow concordato; la promozione nel prodotto richiede invece il consenso esplicito.

## Contratto di piattaforma

RumiAI OS sviluppa contro **POSIX**, non contro Linux, macOS, Windows o una specifica distribuzione.

POSIX è il contratto di piattaforma. Il fatto che una soluzione funzioni su GNU/Linux o su un particolare Unix-like non è sufficiente a considerarla portabile.

La baseline POSIX iniziale di RumiAI OS è fissata a:

**POSIX.1-2024 / The Open Group Base Specifications Issue 8**.

La scelta iniziale della baseline è una decisione esplicita di progetto e non deriva da una regola che imponga di adottare automaticamente la revisione POSIX più recente o quella maggiormente implementata dagli host correnti.

Dopo la scelta iniziale, la baseline viene modificata solo quando emerge una necessità concreta di RumiAI relativa a una feature, utility, interfaccia o garanzia semantica appartenente a una revisione POSIX successiva.

In quel caso il processo obbligatorio è:

1. identificare il requisito reale emerso in RumiAI;
2. verificare che la feature o il comportamento della revisione successiva sia effettivamente necessario;
3. verificare la specifica normativa pertinente;
4. verificare il comportamento reale sugli OS di riferimento quando tale comportamento è materialmente rilevante, usando PoC quando opportuno;
5. se il requisito è validato e la revisione successiva è il contratto corretto, adottare esplicitamente la nuova baseline;
6. se il comportamento osservato su uno o più OS di riferimento non corrisponde al contratto POSIX atteso, valutare soluzione, compatibilità, fallback, astrazione e/o modifica della baseline prima di consolidare l'implementazione.

Non è necessario verificare preventivamente tutte le feature introdotte dalle revisioni POSIX successive. Se RumiAI non dipende da una feature, la sua disponibilità o mancata disponibilità pratica sugli host di riferimento non richiede investigazione.

Di conseguenza:

- non si devono introdurre dipendenze accidentali da estensioni GNU, Bash o da peculiarità di uno specifico host;
- comportamento specifico dell'host è ammesso soltanto dietro un'astrazione o adapter esplicito quando POSIX non fornisce la funzionalità necessaria o quando una divergenza reale dagli host di riferimento è stata verificata e accettata;
- gli adapter specifici non devono contaminare il modello generale del sistema;
- la portabilità delle funzionalità realmente usate da RumiAI deve essere verificata automaticamente su implementazioni POSIX o POSIX-compatible differenti e non affidata soltanto alla disciplina dello sviluppatore.

Windows non influenza l'architettura di RumiAI OS. RumiAI OS richiede un ambiente POSIX-compatible; su Windows la documentazione può raccomandare Cygwin o indicare altri ambienti compatibili. L'eventuale preparazione dell'ambiente host non cambia il contratto interno di RumiAI OS.

## Shell e interpreti

Gli script implementati in shell devono essere POSIX-compliant e, quando direttamente eseguibili, devono usare esattamente lo shebang:

```sh
#!/bin/sh
```

Non devono essere usate accidentalmente funzionalità specifiche di Bash o di altre shell, né opzioni GNU non previste dal contratto POSIX/profilo adottato. Esempi tipici da non assumere includono array Bash, `[[ ... ]]`, `BASH_SOURCE`, process substitution e `$RANDOM`.

L'uso di una shell diversa, di una funzionalità non POSIX o di una dipendenza implementation-specific è un'eccezione e richiede:

1. una ragione tecnica concreta;
2. approvazione esplicita;
3. documentazione dell'eccezione e della sua motivazione.

In assenza di questi tre requisiti, l'eccezione non è ammessa.

Un comando di RumiAI OS può essere implementato in futuro con un interprete o runtime diverso da `sh`, purché tale dipendenza sia prevista dal relativo profilo/capability e rispetti le regole del progetto. Il nome pubblico del comando non deve dipendere dal linguaggio usato per implementarlo.

Quando una funzionalità utile non è disponibile direttamente nel profilo POSIX adottato, si preferisce una primitiva portabile e riutilizzabile, purché la sua correttezza, sicurezza e portabilità siano verificabili.

## Naming dei file eseguibili, librerie e sorgenti

Il nome di un comando eseguibile identifica la sua funzione, non il linguaggio o l'interprete con cui è implementato.

Di conseguenza gli eseguibili interpretati non devono avere estensioni come `.sh`, `.py`, `.js` o analoghe soltanto per indicare l'interprete. L'implementazione può cambiare senza cambiare il nome pubblico del comando.

Esempio concettuale:

```text
foo
```

può essere inizialmente uno script `#!/bin/sh` e in futuro essere reimplementato con un altro runtime senza diventare `foo.sh`, `foo.py` o `foo.js`.

I file sourced/importati devono usare estensioni con significato semantico, non con significato di interprete. Esempi canonici iniziali:

- `.lib` per librerie sourced;
- `.conf` per configurazioni.

Le estensioni di linguaggio restano appropriate quando il file è realmente un sorgente identificato dal linguaggio e non un comando direttamente eseguibile, ad esempio `.c`, `.cpp`, `.java` e `.js` per puro sorgente JavaScript.

Un file JavaScript eseguito direttamente tramite uno shebang Node.js, se previsto e autorizzato dall'architettura, segue invece la regola degli eseguibili e non porta `.js` nel nome pubblico.

## Sintassi dei comandi e delimitatore `--`

I comandi di RumiAI OS che accettano opzioni devono seguire, salvo eccezioni motivate, le POSIX Utility Syntax Guidelines.

Per ogni tool, POSIX o non-POSIX, che supporta `--` con la specifica funzione semantica di terminare il parsing delle opzioni e delimitare gli operandi/argomenti dati successivi, l'uso di `--` è **obbligatorio** quando vengono passati uno o più operandi/argomenti dati.

La regola è determinata dal contratto reale del singolo tool, non dal fatto che il tool sia POSIX.

Quindi:

- se il tool supporta `--` come delimitatore e riceve almeno un operando/argomento dato, `--` deve essere presente;
- se il numero di operandi/argomenti dati è zero, `--` non deve essere presente;
- se il tool non supporta `--` con questa funzione, il delimitatore non deve essere inventato né forzato;
- la stessa regola vale per tool POSIX e non-POSIX;
- non si deve assumere che tutti i tool POSIX supportino Guideline 10: le eccezioni definite dal relativo contratto devono essere rispettate.

Forma generale quando supportata:

```text
command [options] -- [operands]
```

Esempi concettuali:

```text
# tool con supporto a -- e almeno un operando
command [options] -- operand

# tool con supporto a -- e zero operandi
command [options]

# tool senza supporto a --
command [tool-specific syntax]
```

Il supporto di `--` deve essere stabilito dalla specifica/documentazione effettiva del tool e, quando necessario, verificato empiricamente.

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

L'invocazione di un comando tramite symbolic link non deve essere rifiutata per principio. Quando il path reale del comando è necessario per determinare la root o altre risorse, la risoluzione del symlink deve avere una semantica esplicita, essere compatibile con il profilo POSIX adottato e venire validata con test specifici, incluse catene di symlink, target relativi, symlink in componenti intermedi e invocazione tramite `PATH`.

## Root del repository `rumiai-os`

La radice del repository `rumiai-os` deve contenere soltanto due file, oltre alle directory necessarie:

- `rumiai-os`;
- `README.md`.

`rumiai-os` è l'entrypoint principale ed è un front controller: inizializza il minimo indispensabile e delega la logica a componenti interni. Non deve diventare uno script monolitico.

La sua implementazione iniziale prevista è POSIX shell con `#!/bin/sh`, ma il nome `rumiai-os` non incorpora il linguaggio utilizzato.

Tra le responsabilità minime dell'entrypoint rientra la risoluzione delle informazioni fondamentali necessarie per inizializzare il sistema, incluse almeno la root reale di RumiAI OS e le informazioni essenziali sull'host necessarie al dispatch iniziale. Il set esatto di variabili fondamentali deve essere definito e mantenuto piccolo; dopo questa inizializzazione l'entrypoint deve delegare a comandi interni o librerie sourced appropriate.

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
4. implementazione stabile in `rumiai-os` solo dopo consenso esplicito dell'utente nella fase iniziale del progetto.

Un repository storico o sperimentale può fornire idee e codice di riferimento, ma ogni elemento deve essere valutato rispetto alle regole correnti prima del riuso.
