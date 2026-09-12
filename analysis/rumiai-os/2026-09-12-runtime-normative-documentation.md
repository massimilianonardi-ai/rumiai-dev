# Analisi esplorativa — documentazione normativa locale e consultabile dal prodotto

Date: 2026-09-12  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Scopo

Questa nota esplora l'idea di distribuire nel futuro substrato general purpose una rappresentazione locale della documentazione normativa e di renderla consultabile tramite un tool da terminale concettualmente simile a `man`.

L'obiettivo non è introdurre oggi un comando concreto né scegliere il nome del tool.

L'obiettivo è valutare un modello nel quale la documentazione del contratto installato sia:

```text
inclusa nel prodotto
consultabile offline
allineata alla revisione installata
internazionalizzabile
facile da interrogare da terminale
chiara sul livello di stabilità del contratto descritto
```

Questa idea si collega direttamente alla decisione Accepted:

```text
decisions/rumiai-os/2026-09-12-substrate-contract-stratification.md
```

che distingue:

```text
contratto stabile minimo
superficie di sviluppo
implementation detail privati
```

## 2. Preflight e stato corrente

La riflessione è stata riesaminata contro gli HEAD remoti correnti prima della modifica:

```text
rumiai-dev    3a1d13a641d9ec93189acb7fc469a245b25caf14
rumiai-os     bd31613f6e2de2ef8096d730916634ee40c4b967
rumiai-tests  4d04b9d6b27f5d99887ea2b18818ab2e00c3267a
```

Sono stati riesaminati in particolare:

```text
RULES.md
CONSISTENCY-GATE.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
analysis/rumiai-os/2026-09-12-substrate-two-level-contract-model.md
decisions/rumiai-os/2026-09-12-substrate-contract-stratification.md
rumiai-os/rumiai-os
rumiai-os/lib/sh/core.lib.sh
rumiai-os/bin/sys/lang
rumiai-os/bin/sys/lang-set
rumiai-tests/tests/rumiai-os/lang/
```

La ricerca nel prodotto e nella documentazione corrente non ha individuato un tool canonico già esistente con ruolo equivalente a un manuale normativo locale.

## 3. Invarianti applicabili

Restano validi almeno questi vincoli:

```text
- rumiai-dev resta oggi la fonte autorevole di regole, decisioni e specifiche;
- il futuro substrato deve esporre pochi contratti stabili e una superficie di sviluppo più dinamica;
- la documentazione distribuita non deve creare una seconda fonte normativa indipendente mantenuta a mano;
- il prodotto corrente usa lang/<language_TERRITORY>/ per i cataloghi messaggi e lang/current per la selezione;
- en_US è il fallback lingua corrente;
- data/ è persistent state, non un generico contenitore di product resources;
- bin/sys precede il PATH host;
- nessun nuovo comando, namespace, directory o semantic root viene fissato da questa analisi.
```

## 4. Problema che l'idea risolve

La documentazione normativa oggi vive principalmente nel repository di sviluppo.

Questo è corretto per l'autorità progettuale, ma introduce alcuni costi pratici:

```text
per consultare il contratto serve accedere al repository giusto
bisogna distinguere documenti correnti da analisi e materiale storico
la documentazione consultata può appartenere a una revisione diversa dal prodotto installato
l'accesso offline non è automatico
l'utente del prodotto non ha necessariamente un percorso semplice per trovare il contratto corretto
```

Un manuale locale distribuito con il prodotto può rendere il contratto installato immediatamente visibile.

## 5. Principio fondamentale: una sola fonte normativa, più rappresentazioni

Il beneficio esiste soltanto se non vengono create due fonti di verità.

Il modello desiderabile è:

```text
fonte normativa di sviluppo
        |
        | pubblicazione controllata
        v
snapshot normativo della release
        |
        v
tool locale di consultazione
```

La copia distribuita nel prodotto non deve essere modificata indipendentemente dalla fonte normativa.

Deve essere una rappresentazione pubblicata e revision-specific del contratto che accompagna quella precisa revisione/release del substrato.

In questo modello:

```text
rumiai-dev
  -> resta l'autorità durante progettazione e sviluppo

snapshot incluso nel prodotto
  -> rappresenta il contratto pubblicato della revisione installata

runtime documentation tool
  -> rende quello snapshot facilmente consultabile
```

La pubblicazione deve essere deterministica o comunque verificabile abbastanza da impedire drift silenzioso.

## 6. Il manuale installato descrive la revisione installata

Un vantaggio importante rispetto alla sola documentazione online è la coerenza temporale.

Il manuale locale dovrebbe descrivere:

```text
questa revisione del substrato
questi command
questi contratti
questo livello di stabilità
questi failure contract
```

Non necessariamente la documentazione della versione più recente disponibile su GitHub.

Questo rende possibile una proprietà molto utile:

> se un sistema viene conservato offline o non viene aggiornato per anni, conserva anche la documentazione normativa corrispondente al proprio comportamento.

La provenance della documentazione pubblicata dovrebbe quindi poter essere associata alla release/revisione del prodotto e, quando utile, alla revisione sorgente da cui è stata generata o copiata.

## 7. Documentazione come projection, non copia del repository di sviluppo

Non appare desiderabile distribuire tutto `rumiai-dev` nel prodotto.

Il repository di sviluppo contiene infatti oggetti con ruoli differenti:

```text
regole di sviluppo
decisioni
specifiche
analisi esplorative
handoff
materiale storico
evidence
chat e memoria progettuale
```

Il prodotto dovrebbe invece distribuire una **projection normativa curata** utile al consumer.

Questa projection potrebbe contenere, concettualmente:

```text
contratto del runtime
contratti shell esposti
command pubblici
contratti di servizio quando esisteranno
package interface pubblica
superficie di sviluppo documentata
failure contract rilevanti
formati pubblici
compatibilità/versione
```

Non dovrebbe includere automaticamente discussioni, alternative scartate, handoff o documenti di processo che non costituiscono contratto del prodotto installato.

## 8. Collegamento con la stratificazione dei contratti

Il manuale può rendere esplicita la classe di stabilità di ogni pagina o primitive documentata.

Esempio concettuale:

```text
STABLE
  contratto su cui un consumer come RumiAI può fare affidamento

DEVELOPMENT
  superficie intenzionalmente utilizzabile ma revisionabile
```

Gli implementation detail privati non dovrebbero essere presentati come API consumabile soltanto perché una pagina tecnica potrebbe descriverli internamente.

La documentazione diventa così anche uno strumento per rendere visibile il boundary architetturale.

Un consumer non dovrebbe dover dedurre la stabilità di una interfaccia dal pathname o dalla familiarità del nome.

## 9. Internazionalizzazione: stesso contratto, più lingue

La documentazione runtime può essere internazionalizzata, ma la traduzione non deve creare semantiche normative differenti.

Il principio da preservare è:

```text
una semantica normativa
più rappresentazioni linguistiche equivalenti
```

Non deve esistere, per esempio:

```text
contratto italiano A
contratto inglese B
```

solo perché i documenti vengono mantenuti separatamente.

Occorrerà quindi distinguere fra:

```text
fonte semantica canonica della pagina
traduzioni della stessa pagina/versione
```

Questa analisi non decide quale lingua debba essere la lingua sorgente canonica.

La lingua sorgente potrebbe essere una scelta editoriale futura; ciò che conta è che una sola rappresentazione definisca la semantica di riferimento e che le traduzioni siano trattate come traduzioni, non come norme indipendenti.

## 10. Relazione con il sistema `lang` corrente

Il prodotto corrente ha già un contratto di selezione lingua:

```text
lang/current -> <language_TERRITORY>
fallback en_US
UTF-8
```

È naturale valutare che il futuro manuale locale segua la stessa lingua effettiva dell'ambiente e un fallback coerente.

Tuttavia non segue che le pagine normative debbano essere fisicamente memorizzate dentro l'attuale albero `lang/`.

Il tree corrente `lang/` è un catalogo di messaggi organizzato per dominio/id e viene consumato dalla primitive `lang`.

Inoltre `lang-set` conta i regular file dei cataloghi come messaggi canonici.

Mescolare documenti lunghi e pagine di manuale dentro lo stesso schema rischierebbe di confondere due responsabilità diverse:

```text
message localization

contro

normative documentation localization
```

La soluzione più pulita appare quindi riutilizzare, se opportuno, **la policy di selezione della lingua**, ma non necessariamente il formato o il filesystem layout dei cataloghi messaggi.

## 11. `data/` non è il contenitore naturale

La specifica corrente definisce:

```text
data/
```

come persistent state autorevole e afferma esplicitamente che non è un generico contenitore di product resources.

La documentazione normativa installata è invece una risorsa immutabile o versionata del prodotto, non persistent state dell'utente o del sistema.

Perciò questa analisi non propone di collocarla sotto `data/`.

Se l'idea verrà adottata dovrà essere deciso esplicitamente il resource/layout model appropriato senza riutilizzare semantic root con responsabilità incompatibili.

## 12. Possibile nuova area di risorse: questione aperta

Il layout corrente non possiede ancora una root esplicitamente destinata a documentazione normativa distribuita.

Possibili direzioni future potrebbero includere:

```text
una nuova semantic root dedicata
un'area generale di immutable product resources
un layout specifico della documentazione
```

ma nessuna viene scelta qui.

La decisione dovrà tenere conto del principio corrente secondo cui ogni canonical top-level semantic root riceve una propria environment variable, oltre alla futura migrazione dell'ownership delle environment variables dal corrente RumiAI OS al substrato.

Per questo motivo sarebbe prematuro introdurre ora un pathname concreto.

## 13. Un tool simile a `man`, ma non necessariamente chiamato `man`

Il modello UX proposto è molto valido:

```text
terminale
  -> comando semplice
  -> topic
  -> pagina normativa locale
```

Il nome concreto del comando resta aperto.

Esiste però un vincolo importante: nel runtime corrente `bin/sys` precede il `PATH` host.

Se venisse creato un command del substrato chiamato esattamente:

```text
man
```

esso shadowerebbe normalmente il `man` dell'host nell'ambiente attivo.

Questo sarebbe indesiderabile perché impedirebbe o complicherebbe l'accesso normale alle manual page del sistema.

Perciò "simile a man" deve essere interpretato come modello di fruizione, non come decisione sul nome.

Il futuro comando dovrebbe avere un'identità propria che non sottragga semanticamente il comando standard/host.

Questa analisi non sceglie tale nome.

## 14. Esperienza utente desiderabile

Senza fissare ancora una CLI concreta, il tool dovrebbe rendere semplici almeno i casi concettuali:

```text
aprire una pagina per topic
elencare i topic disponibili
cercare un topic o un termine
mostrare il livello di stabilità
mostrare la versione/revisione cui la pagina appartiene
usare la lingua selezionata con fallback
funzionare senza rete
```

Potrebbe essere utile distinguere chiaramente pagine relative a:

```text
contratto stabile
superficie di sviluppo
command
runtime
formati/protocolli
```

ma questa classificazione non deve diventare un namespace fisico prima di una decisione concreta.

## 15. Rendering e pager

L'esperienza dovrebbe essere adatta al terminale e poter funzionare in pipeline quando richiesto.

Un comportamento concettualmente simile a `man` può includere un pager in uso interattivo, ma il prodotto non dovrebbe introdurre una dipendenza non portabile o assumere implicitamente utility host non garantite dal profilo.

Il rendering dovrebbe quindi essere progettato separatamente dal formato sorgente.

Sono possibili, da valutare in seguito:

```text
plain text UTF-8 pre-rendered
markup leggero renderizzato localmente
uso condizionale di un pager disponibile
output diretto quando stdout non è un terminale
```

Nessuna soluzione viene scelta qui.

## 16. Formato sorgente e formato distribuito possono differire

Non è necessario che il formato usato dagli sviluppatori per mantenere il contratto sia identico alla rappresentazione distribuita.

Un modello possibile è:

```text
source normativa strutturata
        |
        | publish/build
        v
representation runtime ottimizzata per consultazione
```

Questo può facilitare:

```text
indicizzazione
traduzioni
cross-reference
metadata di stabilità
provenance
rendering terminale
```

ma aumenta anche la complessità della pipeline.

Perciò la trasformazione deve esistere soltanto se porta un beneficio reale e deve essere verificabile in modo deterministico.

Una prima implementazione potrebbe anche mantenere un formato molto semplice se sufficiente.

## 17. Metadata minimi utili

Senza fissarne la serializzazione, una pagina distribuita potrebbe avere bisogno concettualmente di conoscere:

```text
topic identity
contract class
product/substrate revision
language
source/provenance
```

Eventualmente:

```text
introduced revision
deprecation state
replacement topic
```

Questi campi sono soltanto requisiti informativi candidati; questa nota non introduce un manifest o uno schema concreto.

## 18. Aggiornamento atomico con il prodotto

La documentazione normativa non dovrebbe aggiornarsi autonomamente rispetto al codice che descrive.

Il comportamento desiderato è più vicino a:

```text
aggiorno il substrato
  -> aggiorno insieme la sua documentazione pubblicata
```

piuttosto che:

```text
runtime revisione X
manuale scaricato separatamente della revisione Y
```

L'accoppiamento fra runtime e documentazione è qui un vantaggio, perché impedisce mismatch della semantica osservabile.

Un eventuale meccanismo di aggiornamento separato dovrebbe preservare esplicitamente l'identità della revisione cui la documentazione appartiene.

## 19. Offline e local-first

La proposta è particolarmente coerente con il carattere local-first del progetto.

Il tool non dovrebbe richiedere:

```text
GitHub
rete
account
servizio esterno
API cloud
```

per consultare il contratto della release installata.

Link o fonti online possono essere complementari, ma non devono essere necessari per leggere il manuale normativo locale.

## 20. Uso da parte di sviluppatori e AI

Una documentazione locale strutturata può essere utile non soltanto all'utente umano.

Tooling di sviluppo o un sistema AI possono consultarla per comprendere il contratto del substrato installato.

Questo non deve però trasformare la documentazione in una dipendenza funzionale necessaria all'esecuzione del runtime.

Il runtime deve continuare a funzionare in base ai propri contratti implementati; il manuale descrive tali contratti, non li esegue.

La documentazione resta dati trusted del prodotto, non codice da source/eval/eseguire.

## 21. Relazione con `--help`

Un futuro command pubblico potrebbe continuare ad avere, se previsto dal proprio contratto, una forma breve di help locale.

Il manuale normativo potrebbe invece contenere la descrizione completa e stabile.

Concettualmente:

```text
--help
  -> uso immediato e sintetico

manuale runtime
  -> contratto completo, failure semantics, esempi, stabilità, riferimenti
```

Questa relazione è soltanto esplorativa e non introduce oggi un requisito generale `--help` per i command correnti.

## 22. Controlli automatici possibili

Se la documentazione distribuita diventa parte importante del contratto pubblico, alcuni errori potrebbero essere rilevati automaticamente.

Esempi candidati:

```text
ogni pagina stabile ha una contract class valida
ogni lingua pubblicata appartiene allo stesso topic/versione
nessuna pagina runtime deriva da analisi non normative
lo snapshot distribuito identifica la provenance
un command dichiarato stable possiede la relativa documentazione
```

Non tutti i controlli devono essere implementati subito e la documentazione non deve essere trasformata artificialmente in uno schema complesso soltanto per renderli possibili.

## 23. Sicurezza e integrità

La documentazione normativa installata dovrebbe essere trattata come parte del prodotto.

Questo suggerisce almeno, a livello concettuale:

```text
provenance verificabile
aggiornamento insieme al prodotto
nessun fetch implicito da sorgenti non trusted
nessun source/eval dei contenuti
nessuna possibilità per una traduzione di introdurre comportamento eseguibile
```

Le policy concrete di firma, digest o packaging dipenderanno dal futuro distribution model del substrato e non vengono fissate qui.

## 24. Benefici attesi

Il modello offre diversi vantaggi:

```text
contratto sempre disponibile offline
manuale coerente con la versione installata
riduzione dell'ambiguità su quale documento leggere
accesso rapido dal terminale
internazionalizzazione naturale
maggiore visibilità della distinzione stable/development
migliore supporto a sviluppatori e tooling
possibilità di mantenere il substrato auto-descrivente
```

In particolare, un substrato che porta con sé i propri contratti pubblicati è più facile da usare come base indipendente per sistemi superiori diversi da RumiAI.

## 25. Rischi

### 25.1 Doppia fonte di verità

È il rischio principale.

Se la documentazione nel prodotto viene editata indipendentemente da quella normativa di sviluppo, il modello deve essere considerato fallito.

### 25.2 Translation drift

Traduzioni mantenute come documenti autonomi possono divergere semanticamente.

Serve una relazione esplicita fra topic canonico e traduzioni.

### 25.3 Manuale non allineato alla release

Un aggiornamento separato può descrivere un comportamento diverso da quello installato.

La revisione della pagina deve essere osservabile o verificabile.

### 25.4 Confusione fra stable e development

Una pagina ben documentata può essere percepita come stabile anche quando appartiene alla superficie dinamica.

La contract class deve quindi essere evidente.

### 25.5 Overengineering del formato

Indicizzazione, metadata, generatori e traduzioni possono portare rapidamente a un sistema documentale troppo complesso.

La prima forma adottata dovrebbe restare il minimo sufficiente.

### 25.6 Shadowing del `man` host

Usare letteralmente il nome `man` nel `bin/sys` del substrato interferirebbe con il normale command host a causa della precedenza del PATH corrente.

Il problema deve essere evitato nella scelta del nome finale.

## 26. Sequenza esplorativa proposta

Prima di implementare appare utile procedere così:

```text
D0  decidere quali documenti pubblici devono essere distribuiti

D1  definire il rapporto esatto fra fonte normativa e snapshot prodotto

D2  definire il modello di topic e contract class

D3  definire la relazione fra lingua canonica e traduzioni

D4  decidere il resource/layout model senza usare impropriamente lang/ o data/

D5  scegliere il nome del command evitando collisione con man host

D6  fissare una CLI minima di consultazione/list/search

D7  scegliere il formato più semplice sufficiente

D8  definire controlli di coerenza e provenance

D9  soltanto dopo valutare implementazione e permanent test
```

## 27. Direzione che appare più coerente

La forma concettualmente più robusta appare:

```text
rumiai-dev
  fonte normativa di sviluppo
        |
        | publish controllato
        v
substrato release X
  codice release X
  + snapshot normativo release X
  + traduzioni allineate
        |
        v
tool locale di consultazione
  offline
  terminal-friendly
  contract-class aware
  language-aware
```

Questo modello combina bene:

```text
single source of truth
revision coupling
local-first
internazionalizzazione
semplicità di accesso
```

## 28. Non-decisioni registrate

Restano deliberatamente aperti:

```text
nome del tool
nome della documentazione runtime
pathname e semantic root
formato sorgente
formato runtime
uso o meno di un generator
lingua sorgente canonica
meccanismo concreto di traduzione
meccanismo di fallback lingua per le pagine
CLI esatta
search/index format
pager/rendering
metadata serialization
provenance representation
versioning delle pagine
integrazione con --help
quali topic appartengano al contratto stabile
quali topic appartengano alla superficie di sviluppo
processo concreto di pubblicazione nella release
```

Nessuno di questi punti deve essere inferito come approvato dalla presente analisi.
