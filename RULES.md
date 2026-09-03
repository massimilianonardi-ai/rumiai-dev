# RumiAI Development Rules

Questo documento contiene regole canoniche per lo sviluppo di RumiAI.

## Autorità e ruolo dei repository

`rumiai-dev` è la fonte autorevole per regole, workflow, decisioni, specifiche, terminologia, architettura, chat e memoria dello sviluppo.

`rumiai-os` è il repository del sistema/prodotto stabile. Il codice vi entra solo dopo che principi, specifiche e decisioni rilevanti sono stati consolidati e, quando necessario, validati sperimentalmente.

`rumiai-dev-PoCs` è il laboratorio sperimentale: contiene proof-of-concept, prototipi, fixture, sessioni sperimentali, input, output, log significativi e risultati usati per rispondere a domande ancora aperte. Il suo contenuto può essere temporaneo, evolutivo o specifico di una particolare indagine.

`rumiai-tests` è il repository della suite permanente di test e validazione: contiene test ripetibili, runner, supporto ai test e sessioni di validazione associate a revisioni precise. Protegge nel tempo proprietà consolidate di RumiAI e delle dipendenze esterne effettivamente utilizzate.

PoC e test permanenti hanno ruoli distinti: un PoC può essere modificato, sostituito o eliminato quando ha esaurito il proprio scopo; un test permanente deve restare finché la proprietà che protegge rimane parte del contratto o del comportamento atteso.

I repository storici o di riferimento, incluso `massimilianonardi/m`, sono materiale da analizzare: non sono fonti normative e il loro codice non deve essere copiato o migrato automaticamente.

La memoria conversazionale di ChatGPT è solo un supporto operativo e non prevale mai sul contenuto canonico di `rumiai-dev`.

In caso di conflitto tra memoria/conversazione e repository, prevale il repository.

Le regole specifiche per test permanenti, runner, development run, validation run e workspace locale sono definite in `TESTING.md`.

## Autorizzazione alle modifiche di `rumiai-os`

Almeno nella fase iniziale del progetto, nessun file deve essere creato, copiato, modificato o eliminato nel repository `rumiai-os` senza consenso esplicito dell'utente per quella fase di implementazione.

Una decisione consolidata, un PoC riuscito, un test riuscito o una raccomandazione tecnica non costituiscono da soli autorizzazione a scrivere nel repository `rumiai-os`.

`rumiai-dev`, `rumiai-dev-PoCs` e `rumiai-tests` possono essere usati rispettivamente per consolidamento, sperimentazione e validazione secondo il workflow concordato; la promozione nel prodotto richiede invece il consenso esplicito.

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

### Quoting difensivo in `sh`

Nel codice `sh` di RumiAI devono essere usate le doppie virgolette `"..."` intorno a variabili, espansioni e valori ogni volta che la sintassi e la semantica lo consentono senza alterare intenzionalmente il comportamento.

La regola vale anche quando il valore è costante, il contenuto di una variabile è già noto o il contenuto è considerato sicuro. La protezione deve dipendere dalla forma del codice e non da assunzioni sul contenuto corrente dei dati.

La regola si applica in particolare a espansioni di parametri e variabili, command substitution usate come valori, assegnazioni, operandi passati a comandi, confronti e test, parole esaminate da `case` e concatenazioni di pathname/stringhe.

Esempi:

```sh
value="fixed"
path="$m_ROOT/lib"
result="$(command -p -- uname -s)"
[ "$value" = "fixed" ]
case "$value" in
  "fixed") : ;;
esac
```

Le virgolette non devono essere introdotte quando cambierebbero una semantica shell intenzionale o quando l'elemento è sintassi e non un valore. Rientrano tra le eccezioni i metacaratteri che devono restare attivi nei pattern di `case`, keyword, operatori, redirection e nomi sintattici di variabili passati a `export`, `readonly` o primitive equivalenti.

Quando una parte letterale di un pattern può essere quotata senza disattivare il wildcard necessario, si preferisce quotare la parte letterale, per esempio:

```sh
case "$value" in
  "MINGW"*) : ;;
esac
```

La regola si applica al nuovo codice e al codice modificato; non impone una riformattazione indiscriminata dei sottosistemi non coinvolti. Il bootstrap root `rumiai-os` è il riferimento stilistico principale per questa disciplina.

## Naming dei file eseguibili, librerie e sorgenti

Il nome di un comando eseguibile identifica la sua funzione, non il linguaggio o l'interprete con cui è implementato.

Di conseguenza gli eseguibili interpretati non devono avere estensioni come `.sh`, `.py`, `.js` o analoghe soltanto per indicare l'interprete. L'implementazione può cambiare senza cambiare il nome pubblico del comando.

Esempio concettuale:

```text
foo
```

può essere inizialmente uno script `#!/bin/sh` e in futuro essere reimplementato con un altro runtime senza diventare `foo.sh`, `foo.py` o `foo.js`.

Le librerie interne sourced/importate sono invece oggetti legati al runtime che le carica. Devono essere organizzate sotto:

```text
lib/<runtime>/
```

Il runtime di caricamento deve essere espresso sia dal sottalbero sia dall'estensione composta del file. Le forme canoniche iniziali sono:

```text
lib/sh/<nome-libreria>.lib.sh
lib/js/<nome-libreria>.lib.js
```

Esempi:

```text
lib/sh/osarch.lib.sh
lib/js/example.lib.js
```

La componente `.lib` identifica il ruolo di libreria; il suffisso finale (`.sh`, `.js`, ecc.) identifica il runtime/formato con cui il file può essere caricato. Questa qualificazione del runtime è intenzionale per le librerie interne e non modifica la regola dei comandi pubblici senza estensione.

Per le librerie RumiAI viene esportata soltanto la root generale:

```text
m_LIB_DIR=$m_ROOT/lib
```

Non devono essere introdotte environment variables derivate come `m_LIB_SH_DIR`, `m_LIB_JS_DIR` o equivalenti soltanto per abbreviare i sottopercorsi. I consumer derivano il proprio sottalbero dal runtime appropriato, ad esempio `$m_LIB_DIR/sh` o `$m_LIB_DIR/js`.

Le librerie shell sotto `lib/sh/` sono file da source, non eseguibili: non devono avere il bit executable e non devono contenere shebang. Un file che deve essere direttamente eseguibile appartiene al modello dei comandi/eseguibili, non a quello delle librerie.

I file sorgente che non sono librerie seguono il formato reale del linguaggio o dell'ecosistema, ad esempio `.c`, `.cpp`, `.java` e `.js` per puro sorgente JavaScript.

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

## Workspace locale di sviluppo

RumiAI OS può contenere la directory tracciata `src/` esclusivamente come punto di ancoraggio del workspace locale di sviluppo.

Il contenuto operativo di `src/` non fa parte del prodotto e deve essere ignorato da Git. La configurazione iniziale prevista è:

```text
rumiai-os/src/rumiai-tests/
```

come clone indipendente del repository `rumiai-tests`.

Quando necessario per attività sperimentali può essere presente anche:

```text
rumiai-os/src/rumiai-dev-PoCs/
```

Questi repository locali non devono essere submodule né dipendenze runtime del prodotto. Le regole dettagliate sono definite in `TESTING.md`.

## Scelta di software e mezzo di esecuzione

RumiAI distingue tra **obiettivo** e **mezzo richiesto dall'utente**.

Se l'utente specifica soltanto il risultato, RumiAI può scegliere autonomamente lo strumento e l'interfaccia più appropriati, privilegiando quando opportuno soluzioni deterministiche, efficienti, verificabili e a minor overhead, come API, CLI o scripting.

Se l'utente specifica un software, un'interfaccia o una modalità di esecuzione, tale scelta diventa parte dell'intento e deve essere rispettata.

Esempio: per una richiesta generica di conversione CAD → Shapefile RumiAI può scegliere GDAL; per una richiesta del tipo "apri QGIS e converti il file" deve utilizzare QGIS.

La GUI e il computer-use sono quindi modalità operative tra le altre, non il modello generale di interazione con il computer.

## Workflow di sviluppo

Il flusso di riferimento è:

1. regola, specifica o decisione in `rumiai-dev`;
2. quando serve esplorare una domanda aperta, PoC e relativa evidenza in `rumiai-dev-PoCs`;
3. consolidamento dei risultati rilevanti in `rumiai-dev`;
4. implementazione stabile in `rumiai-os` solo dopo consenso esplicito dell'utente nella fase iniziale del progetto;
5. trasformazione delle proprietà consolidate e dei bug riproducibili in test permanenti dentro `rumiai-tests` quando il costo è ragionevole;
6. development run durante l'iterazione e validation run su revisioni committed e pulite secondo `TESTING.md`;
7. consolidamento in `rumiai-dev` delle conclusioni di validazione rilevanti.

Un repository storico o sperimentale può fornire idee e codice di riferimento, ma ogni elemento deve essere valutato rispetto alle regole correnti prima del riuso.
