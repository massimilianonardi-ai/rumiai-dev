# Analisi esplorativa — `mk`, source materialization e packaging di progetti locali

Date: 2026-09-13  
Status: **EXPLORATORY / NON-NORMATIVE**

## 1. Scopo

Questa nota fissa una riflessione volutamente limitata e non normativa nata dal riesame dello storico `mk` in relazione all'attuale `pkg`.

Il punto di partenza è esplicito:

- lo storico `mk` è stato un tool utile e soddisfacente nel proprio contesto;
- oggi non è adatto a essere ripreso direttamente, per ragioni architetturali, di trust, coupling, global state, configurazione eseguibile e sovrapposizione di responsabilità;
- diversi concetti storici possono comunque essere recuperati e ridisegnati per RumiAI;
- questa nota **non** tenta di progettare il futuro `mk` nel suo complesso;
- la riflessione è concentrata su due scenari concreti relativi alla trasformazione di sorgenti in package installabili.

I due scenari sono:

```text
A. package remoto distribuito soltanto come sorgenti

B. progetto completamente locale sotto src/
   senza repository pubblico,
   da installare come package
```

Il secondo scenario è il centro principale dell'analisi.

Il termine `mk` viene usato qui quando si parla dello strumento storico o, in forma chiaramente ipotetica, di un possibile futuro erede concettuale. **Non viene fissato alcun nuovo comando, componente o nome canonico `mk`.**

Analogamente, espressioni come "source materialization", "trasformazione da sorgente" o "build side" sono descrittive in questa nota e non introducono terminologia di prodotto.

---

## 2. Autorità, preflight e stato osservato

La nota è stata redatta dopo riesame degli HEAD remoti correnti:

```text
rumiai-dev    96ce850bbb8662e5c4b2ea4b2ef357b228a41b1c
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests  bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
historical m  fa3a90d59e1b0da2f553cceef5066974dad21944
```

Sono stati riesaminati almeno:

```text
RULES.md
CONSISTENCY-GATE.md
analysis/m-audit/2026-08-27-mk-target-profile-deep-dive.md
analysis/rumiai-os/2026-09-12-m-substrate-and-rumiai-os-specialization.md
analysis/rumiai-os/2026-09-12-substrate-two-level-contract-model.md
decisions/rumiai-os/2026-09-02-source-workspace-and-generic-lang-domains.md
decisions/rumiai-os/2026-09-07-package-install-local-candidate-baseline.md
decisions/rumiai-os/2026-09-07-package-install-repository-pipeline-and-cli.md
decisions/rumiai-os/2026-09-09-package-integration-and-default-contract.md
rumiai-tests/tests/rumiai-os/pkg/install.test
```

Il repository storico `massimilianonardi/m` resta materiale genealogico e di analisi. Non è fonte normativa e questa nota non autorizza la copia o migrazione automatica di codice storico.

---

## 3. Invarianti correnti che questa analisi non modifica

La riflessione deve restare compatibile con i contratti Accepted correnti.

In particolare:

```text
- src/ è workspace di sviluppo locale;
- il contenuto operativo di src/ resta fuori dal prodotto runtime;
- il runtime non deve dipendere da src/;

- la CLI pubblica corrente di pkg install opera su package RumiAI;
- pkg install non espone repository coordinates o candidate-directory;

- la precedente forma
      pkg install <pkg> <version> <candidate-directory>
  è esplicitamente superseded;

- la pipeline corrente separa:
      package-definition lookup
      repository discovery/resolution
      download
      extract
      package integration;

- pkg_extract e pkg_integrate sono responsabilità distinte;

- pkg_integrate riceve una useful root già normalizzata;

- pkg_integrate rende disponibile una concrete version;
- disponibilità e default/current sono livelli distinti;
- pkg install non seleziona automaticamente il default;

- una concrete identity esistente non viene sovrascritta implicitamente;

- le package definition restano dati dichiarativi e non shell sourced/eval;

- facility/dependency hanno già semantica propria e non devono essere
  reinterpretate incidentalmente come generiche build dependency;

- nessun nuovo comando, namespace, API, directory, formato o primitive
  viene fissato da questa nota.
```

La nota descrive quindi possibili boundary futuri. Ogni adozione richiederebbe una decisione esplicita separata e il normale riallineamento forward-only di specifiche, prodotto e test.

---

## 4. Cosa vale la pena recuperare dallo storico `mk`

Lo storico `mk` non era soltanto un wrapper di compilazione. Era un orchestratore di progetto con concetti quali:

```text
PROJECT
PROFILE
TYPE
lifecycle operations
configuration overlays
project composition
distinct dependency kinds
build/install/test lifecycle
```

Per questa nota interessano soprattutto due aspetti.

### 4.1 Dipendenze software prima della build

Lo storico `mk` distingueva, fra gli altri, requisiti package da altri tipi di dipendenza e poteva procurare software necessario alla build attraverso il package layer.

Il concetto importante non è l'API storica concreta, ma la separazione semantica:

```text
il mondo sorgente/build
può aver bisogno di software già materializzato
fornito dal package manager
```

Questa direzione resta interessante anche oggi.

### 4.2 Bridge build -> package integration

Nel lifecycle storico l'output prodotto dal build system veniva consegnato al package system, che si occupava dell'integrazione.

Il valore genealogico è il confine:

```text
build system
    produce risultato

package system
    materializza/integrate risultato
```

La forma storica concreta, nella quale `mk` scriveva direttamente nel package area e poi invocava `pkg integrate`, non deve essere ripresa come implementazione moderna.

Il principio utile è invece:

> il componente che comprende il progetto sorgente produce il risultato installabile; il package manager mantiene ownership della materializzazione package.

Questa separazione diventa ancora più importante con l'attuale `pkg`, che possiede contratti molto più precisi rispetto allo storico.

---

## 5. Cosa non deve assorbire un eventuale nuovo `mk`

L'attuale `pkg` possiede già responsabilità consolidate relative a:

```text
package identity
repository discovery/resolution
version resolution
download
extract
package integration
installed concrete versions
current/default
public bindings
facility/dependency
state package-local e semantic state roots
install/uninstall lifecycle
```

Un eventuale futuro tooling ispirato a `mk` non dovrebbe riprendersi tali responsabilità.

Il boundary concettuale preferibile resta:

```text
source / workspace
      ↓
development/build tooling
      ↓
build result / installable useful root
      ↓
package integration contract
      ↓
pkg
      ↓
materialized package state
```

Nella direzione opposta, `pkg` può essere usato dal mondo sviluppo per procurare software, toolchain o runtime richiesti dalla trasformazione dei sorgenti.

Il dependency direction ideale, in questa esplorazione, è quindi:

```text
development/build tooling
        -> contract di pkg quando serve software materializzato

pkg
        -/-> project-specific development tooling
```

Questo evita che il package manager diventi dipendente da un particolare framework di progetto.

---

# Parte I — Package remoto distribuito solo come sorgenti

## 6. Limite del caso corrente

I package concreti affrontati finora possono essere scaricati ed estratti in una forma già sostanzialmente eseguibile o interpretabile.

La pipeline può quindi essere letta approssimativamente come:

```text
artifact upstream
        ↓
download
        ↓
extract
        ↓
useful root
        ↓
pkg_integrate
```

Questa forma funziona perché, nei casi correnti, l'estrazione è sufficiente a produrre il materiale utile all'integrazione.

Non è però una proprietà universale del software distribuito.

Un upstream può pubblicare soltanto sorgenti che richiedono, per esempio:

```text
configure
compiler/linker
make
cmake
ninja
language-specific build tool
code generation
install-to-staging
```

In tal caso:

```text
extract output != useful root
```

Il package manager deve quindi poter affrontare una trasformazione ulteriore prima dell'integrazione.

---

## 7. Flusso concettuale per un package source-only

La parte iniziale può restare coerente con il modello corrente:

```text
pkg install foo
      ↓
pkg-catalog
      ↓
repository discovery/resolution
      ↓
versione concreta
      ↓
source artifact
      ↓
download
      ↓
extract
      ↓
source tree
```

Da quel punto serve una trasformazione che produca il risultato realmente installabile:

```text
source tree
      ↓
trasformazione guidata da regole dichiarate
      ↓
useful root
      ↓
pkg_integrate
```

La trasformazione potrebbe corrispondere, a seconda del progetto, a operazioni come:

```text
configure + make + install-to-staging
cmake + ninja + install-to-staging
compiler diretto
language-specific build process
nessuna compilazione ma preparazione/copia/normalizzazione
```

Questa nota **non assegna ancora un nome canonico** alla fase né decide una API concreta.

La proprietà rilevante è il contratto semantico:

```text
INPUT
    source tree stabile
    informazioni di materializzazione/build
    ambiente/tool disponibili

OUTPUT
    useful root pronta per package integration
```

---

## 8. Perché non deve diventare semplicemente parte di `pkg_extract`

`extract` e trasformazione da sorgente hanno semantiche differenti.

`extract` risponde a una domanda come:

```text
come ottengo il contenuto utile dall'artifact trasferito?
```

La trasformazione da sorgente risponde invece a:

```text
come produco il software installabile a partire dai sorgenti?
```

Nascondere compilation/build/materialization dentro `pkg_extract` confonderebbe due responsabilità oggi separate intenzionalmente.

Se il caso source-only venisse adottato, l'attuale boundary:

```text
pkg_extract -> useful root -> pkg_integrate
```

richiederebbe quindi un'estensione deliberata per ammettere, quando necessaria, una fase intermedia.

Questa sarebbe una modifica di design esplicita, non un dettaglio implementativo.

---

## 9. `pkg` orchestra l'installazione, ma non deve diventare un build system universale

Dal punto di vista dell'utente l'operazione resterebbe naturalmente:

```text
pkg install foo
```

`pkg` mantiene ownership dell'obiettivo:

> rendere disponibile una concrete version di `foo`.

Ma questo non implica che il core di `pkg` debba incorporare conoscenza specifica di:

```text
GCC
Clang
Make
CMake
Ninja
Maven
Gradle
Cargo
npm
...
```

La package definition può dichiarare ciò che serve per materializzare il package; il meccanismo concreto deve restare componibile e isolare la conoscenza specifica degli ambienti di sviluppo.

La distinzione concettuale è:

```text
pkg conosce il piano necessario per ottenere un package materializzabile

ma

pkg non deve diventare il framework che comprende internamente
ogni sistema di build esistente
```

---

## 10. Build requirements e runtime dependency non sono la stessa cosa

Un package source-only può aver bisogno, durante la produzione, di software che non serve al package installato.

Esempio:

```text
source C

build requires:
    compiler
    make

resulting package runtime requires:
    forse nessuno dei due
```

Questa distinzione è importante perché il current `dependency` model ha già una semantica specifica relativa alle facility richieste dal package materializzato.

Non bisogna reinterpretare automaticamente:

```text
package runtime dependency
```

come:

```text
build/toolchain requirement
```

Il package manager potrà probabilmente essere usato per **procurare** compiler, runtime e build tool, ma il motivo per cui tali package sono richiesti deve restare semanticamente distinto.

Un futuro modello dovrà quindi rappresentare almeno la differenza fra:

```text
software richiesto per produrre il package

software/facility richiesto dal package una volta materializzato
```

Questa nota non fissa il formato o il resolver di tali requisiti.

---

# Parte II — Progetto completamente locale sotto `src/`

## 11. Scenario

Il caso principale è un progetto locale, per esempio concettualmente:

```text
$m_SRC_DIR/my-project/
```

che non possiede un repository pubblico e che si vuole installare come package.

Il progetto può essere di due famiglie principali.

### 11.1 Direttamente eseguibile o interpretabile

Esempi:

```text
POSIX shell
JavaScript
Python
altri linguaggi interpretati
```

Non serve necessariamente una compilazione tradizionale.

### 11.2 Richiede una trasformazione/compilazione

Esempi:

```text
C
C++
Rust
Java o altri casi con build/package step
```

Il punto importante è che la distinzione fra queste due famiglie dovrebbe sparire **prima di entrare nel package integration layer**.

---

## 12. Primo principio: working source != installed package

Un progetto locale non deve diventare un package mediante un semplice riferimento persistente al working tree.

Da evitare, per esempio:

```text
$m_ROOT/pkg/foo@1.0/root -> $m_SRC_DIR/foo
```

oppure altre forme in cui il package installato continui a dipendere operativamente dai file sotto `src/`.

Questo violerebbe il contratto corrente del workspace:

```text
src/ = sviluppo locale
runtime non dipende da src/
```

Inoltre produrrebbe una proprietà indesiderata:

```text
edit del sorgente
    -> modifica silenziosa del package già installato
```

La separazione deve quindi essere reale anche per un progetto shell, JavaScript o Python che non richiede compilazione.

La proprietà desiderata è:

```text
working source
    !=
installed package
```

---

## 13. Flusso locale concettuale

Senza fissare command o nomi di API, il percorso più coerente emerso dalla riflessione è:

```text
1. progetto locale in src/

2. creazione di un input stabile/snapshot/staging del source tree

3. acquisizione delle informazioni necessarie a descrivere:
       package identity
       eventuale target qualification
       trasformazione dei sorgenti
       package integration metadata

4. produzione della useful root:
       - copia/preparazione/normalizzazione, se già interpretabile
       - build/compile/install-to-staging, se necessario

5. consegna della useful root al package integration layer

6. materializzazione della concrete version in $m_ROOT/pkg

7. concrete version disponibile ma non automaticamente default/current
```

La necessità di uno snapshot/staging deriva dal desiderio di non far lavorare l'operazione di package integration direttamente su un working tree che può cambiare durante l'operazione.

Questa nota non fissa ancora:

```text
formato dello snapshot
content hashing obbligatorio
Git come requisito
clean-tree requirement
provenance serialization
reproducibility guarantees
```

Registra soltanto la proprietà concettuale:

> la produzione del package deve operare su un input sorgente delimitato e non trasformare il working tree stesso nel package runtime.

---

## 14. Caso locale interpretato

Per un progetto già interpretabile il flusso può essere molto semplice:

```text
src/project
    ↓
source snapshot
    ↓
preparazione / copia / normalizzazione
    ↓
useful root
    ↓
pkg integration
```

Non bisogna introdurre una compilazione artificiale soltanto per uniformare la pipeline.

La fase intermedia può essere quasi identitaria, purché produca una useful root autonoma dal working tree.

---

## 15. Caso locale compilato

Per un progetto che richiede build:

```text
src/project
    ↓
source snapshot
    ↓
compile / link / build tool / install-to-staging
    ↓
useful root
    ↓
pkg integration
```

Dal punto di vista di `pkg_integrate`, il risultato dovrebbe essere indistinguibile dal caso interpretato.

Questo produce una proprietà architetturale forte:

> **dopo la useful root, il package layer non deve più interessarsi al fatto che il software fosse originariamente shell, Python, C, C++ o altro.**

---

## 16. Due ingressi, un solo punto di convergenza

I due scenari principali possono essere letti come due diversi modi di ottenere sorgenti, seguiti dallo stesso problema di materializzazione.

### 16.1 Package remoto source-only

```text
pkg-catalog
    ↓
repository resolution
    ↓
download
    ↓
extract
    ↓
source tree
    ↓
source transformation
    ↓
useful root
    ↓
pkg integration
```

### 16.2 Progetto locale

```text
src/project
    ↓
source snapshot
    ↓
source transformation
    ↓
useful root
    ↓
pkg integration
```

Il punto di convergenza è:

```text
SOURCE TREE
    +
materialization/build description
    +
available build environment
    ↓
USEFUL ROOT
```

Dopo questo boundary esiste un solo mondo package.

Questo evita di creare:

```text
un package manager per gli artifact remoti
un secondo package manager per i progetti locali
```

---

## 17. Perché non reintrodurre `pkg install <directory>`

RumiAI ha già sperimentato e poi superseded una CLI che accettava direttamente una candidate directory:

```text
pkg install <pkg> <version> <candidate-directory>
```

La correzione corrente ha deliberatamente riportato la CLI pubblica a package operand e separato repository/download/extract/integration.

Per questo la nuova esigenza locale non dovrebbe essere risolta semplicemente con forme come:

```text
pkg install ./src/foo
```

oppure con una reintroduzione mascherata della candidate directory.

La ragione non è che una directory locale sia tecnicamente ingestibile.

La ragione è che una tale CLI rischierebbe di ricreare la confusione fra:

```text
project development/build concern
```

e:

```text
package acquisition/install concern
```

Il normale `pkg install foo` possiede oggi una semantica precisa:

```text
package identity
-> catalog
-> upstream resolution
-> concrete version
-> artifact
-> integration
```

Un progetto locale non possiede necessariamente questo percorso.

È quindi più pulito avere **ingressi differenti prima della useful root**, preservando una sola integrazione package dopo di essa.

Questa nota non decide quale eventuale interfaccia pubblica o di sviluppo debba avviare il flusso locale.

---

## 18. `pkg_integrate` come boundary concettuale importante

L'attuale `pkg_integrate` è particolarmente interessante perché riceve già:

```text
pkg
version
package definition selezionata
useful root
optional osarch
```

E mantiene separata:

```text
availability
```

da:

```text
default/current
```

Questo rende naturale pensare che il problema locale non richieda un secondo modello di package installato.

Il progetto locale deve arrivare al boundary con:

```text
una concrete identity valida
una useful root valida
le informazioni di integrazione applicabili
```

Da quel punto la semantica dovrebbe restare quella del package model corrente.

La presente nota **non** afferma però che l'attuale API interna `pkg_integrate` debba essere esposta direttamente a tooling esterno. La classificazione del futuro contract resta aperta.

---

## 19. Possibile posizione di un futuro erede concettuale di `mk`

Il caso locale chiarisce bene una possibile ownership.

`pkg` comprende concetti quali:

```text
package
version
availability
integration
facility/dependency
state
default/current
```

Il mondo sviluppo comprende invece:

```text
source tree
project
build configuration
build tool
compiler
test
generated artifact
```

Il progetto locale nasce nel secondo mondo.

È quindi più naturale che il tratto:

```text
project source
    -> useful root
```

appartenga a tooling di sviluppo/build, mentre il tratto:

```text
useful root
    -> installed concrete package
```

resti nel package layer.

Un eventuale moderno erede concettuale di `mk` potrebbe quindi vivere soprattutto nella **superficie di sviluppo flessibile** ipotizzata nell'analisi del substrato, non nel contratto runtime stabile minimo.

La distinzione utile sarebbe:

```text
il sistema può eseguire package senza avere il project build tooling

il project build tooling usa il sistema/package infrastructure
per produrre e validare package
```

Questo documento non decide che tale tooling debba chiamarsi `mk` né che debba essere un singolo comando.

---

## 20. Un solo meccanismo di trasformazione da sorgente per due consumer

La convergenza fra package remoto source-only e progetto locale suggerisce un'altra possibilità importante.

Non sarebbe desiderabile avere:

```text
pkg
    -> proprio framework universale di build

future development tooling
    -> secondo framework universale di build
```

Entrambi hanno invece lo stesso bisogno concettuale:

```text
source snapshot/tree
      +
materialization description
      +
build environment
      ↓
useful root
```

Potrebbe quindi emergere, davanti a casi concreti, una responsabilità riutilizzabile da orchestratori differenti:

```text
pkg
  -> quando un package upstream è source-only

sviluppo locale
  -> quando un progetto in src/ deve diventare package
```

Questa responsabilità condivisa non viene qui promossa a nuova primitive, componente, libreria o API. Prima di farlo occorre verificare che i primi casi concreti abbiano davvero un contratto comune e non soltanto una somiglianza superficiale.

---

# Parte III — Identità del package locale

## 21. Il problema più delicato non è la compilazione

Compilare un progetto locale è tecnicamente complesso ma concettualmente abbastanza lineare.

La domanda più profonda è invece:

> **che cosa identifica la concrete version prodotta da un source tree locale?**

Il current package model usa:

```text
<pkg>@<version>
<pkg>@<version>!<osarch>
```

Nella pipeline remota, `<version>` è oggi una versione upstream concreta risolta attraverso l'upstream corrente.

Un progetto locale, però, può non avere alcun upstream.

Questa è una vera tensione concettuale che non deve essere nascosta da una convenzione improvvisata.

---

## 22. Pseudo-versioni da evitare come scorciatoia implicita

Questa analisi non propone di usare automaticamente valori come:

```text
local
dev
latest
workspace
path
```

come pseudo-versioni speciali.

Tali valori introdurrebbero nuova semantica arbitraria e renderebbero più debole l'identità concreta.

La direzione più coerente sembra invece richiedere che il progetto locale sappia fornire almeno:

```text
package name
versione concreta
optional target qualification
```

La provenienza del source tree è un'altra dimensione.

Potrebbe essere, per esempio:

```text
remote repository + version
Git commit locale
source snapshot digest
working tree snapshot
altro identificatore
```

ma la provenance non deve essere confusa automaticamente con il package name o con la package version.

---

## 23. Possibile generalizzazione futura della nozione di versione

Il caso locale suggerisce una possibile evoluzione concettuale:

```text
modello corrente remoto:
    version = upstream concrete version

possibile modello più generale futuro:
    version = concrete software/package version
    upstream = una possibile provenance/distribution source
```

Questa sarebbe però una modifica reale del design corrente.

Non viene adottata da questa nota.

Se in futuro si decidesse di supportare package locali senza upstream, occorrerebbe stabilire esplicitamente:

```text
semantica della version
relazione con upstream version
provenance
collisioni
rebuild della stessa version
identità target-specific
```

---

## 24. Collision policy iniziale desiderabile

L'attuale package integration rifiuta una concrete identity già presente.

Questo comportamento è utile anche nel ragionamento locale.

Una prima baseline semplice potrebbe mantenere:

```text
foo@1.0 già disponibile
+
nuova build locale dichiarata foo@1.0
=
collisione / failure
```

senza overwrite, repair o reinstall implicito.

Lo sviluppo iterativo potrebbe poi richiedere una soluzione specifica per rebuild frequenti della stessa versione, ma questo è un problema di development workflow distinto.

Non conviene anticiparlo complicando da subito l'identità package con:

```text
revisioni automatiche
hash nel nome
pseudo-versioni speciali
mutable installed package
```

---

# Parte IV — Package definition e progetto locale

## 25. Due domande diverse oggi raccolte nella pipeline package

Il caso locale rende evidente una separazione concettuale latente.

Per un package remoto occorre rispondere a due famiglie di domande:

```text
A. COME OTTENGO / PRODUCO IL SOFTWARE?

repository
version resolution
artifact selection
download
extract
eventuale source transformation

B. COME IL RISULTATO DIVENTA UN PACKAGE DEL SISTEMA?

concrete identity
root
cmd/link/env/default
facility/dependency
state/path normalization
integration semantics
```

Nel catalogo remoto entrambe le famiglie sono necessarie.

Per un progetto locale la prima parte è diversa:

```text
repository remoto    non necessario
remote download      non necessario
source tree          già locale
```

ma la seconda parte resta necessaria.

---

## 26. Il progetto locale non dovrebbe fingere di essere un repository remoto

Per installare un progetto locale non appare desiderabile costringerlo a simulare artificiosamente:

```text
repository/
remote coordinates
archive URL
archive regex
fake download
```

soltanto per attraversare una pipeline progettata per acquisition remota.

Questo non significa necessariamente che servano due schemi differenti.

Significa soltanto che bisogna mantenere distinguibili:

```text
source acquisition/materialization description
```

e:

```text
package integration description
```

La nota non fissa:

```text
due file separati
un nuovo manifest
un nuovo descriptor
una directory sotto src/
un'estensione di pkg-catalog
```

La forma concreta dovrà emergere da una successiva decisione.

---

## 27. Riutilizzare la stessa semantica di integrazione

Qualunque forma venga scelta, è desiderabile non inventare una seconda descrizione per concetti già posseduti dal package model.

Se un progetto locale dichiara, per esempio:

```text
command exposure
link target
environment
facility
dependency
state behavior
```

la semantica dovrebbe restare quella corrente di `pkg`, non una variante development-only equivalente ma incompatibile.

Il caso locale deve quindi riusare il package integration model, pur potendo avere un percorso differente per ottenere la useful root e selezionare i dati pertinenti.

---

# Parte V — Modello concettuale a tre domini

## 28. Acquisition

Prima domanda:

> dove ottengo il materiale di partenza?

### Remoto

```text
pkg-catalog
repository adapter
download
extract
```

### Locale

```text
src/project
source snapshot/staging
```

Il risultato di questo dominio può essere:

```text
artifact già installabile
oppure
source tree
```

---

## 29. Source transformation / materialization

Seconda domanda:

> come trasformo il materiale sorgente nel software realmente installabile?

Possibili casi:

```text
nessuna trasformazione sostanziale
copy/prepare/normalize
compiler
configure + make
cmake + ninja
language-specific tooling
install-to-staging
```

Il risultato deve essere:

```text
useful root
```

Questa è l'area che oggi manca nel package pipeline generale quando l'upstream non fornisce software già materializzato.

È anche l'area che il progetto locale deve attraversare prima di diventare package.

---

## 30. Package integration

Terza domanda:

> come il risultato appartiene al package environment?

Qui ricadono i concetti già posseduti da `pkg`:

```text
concrete identity
root
cmd/link/env
default/current
facility/dependency
state
availability
public bindings
```

La useful root è il boundary naturale fra il mondo sorgente e il mondo package.

---

## 31. Vista complessiva

```text
              REMOTE INPUT

pkg-catalog / repository
          ↓
      download
          ↓
       extract
          ↓
   artifact/source tree
          │
          │
          ├─────────────────────────┐
          │                         │
          ▼                         │
source transformation              │ already materialized
          │                         │
          └────────────┬────────────┘
                       ▼
                  useful root
                       │
                       ▼
                pkg integration
                       │
                       ▼
               concrete package
```

```text
               LOCAL INPUT

             src/project
                 ↓
          source snapshot
                 ↓
       source transformation
                 ↓
            useful root
                 ↓
          pkg integration
                 ↓
         concrete package
```

Questi diagrammi sono descrittivi e non definiscono una pipeline o API canonica.

---

# Parte VI — Cose da evitare

## 32. Package installato come link persistente a `src/`

Da evitare perché:

```text
runtime dipenderebbe dal workspace di sviluppo
edit del source modificherebbe il package installato
rimozione del checkout romperebbe il package
```

---

## 33. Reintroduzione della candidate-directory pubblica

Da evitare come soluzione immediata:

```text
pkg install <directory>
pkg install <pkg> <version> <directory>
```

perché riaprirebbe una strada già esplicitamente superseded e confonderebbe acquisition/build con package install.

---

## 34. `mk` o altro tooling che scrive direttamente in `$m_ROOT/pkg`

Il mondo sviluppo non dovrebbe manipolare direttamente il package store.

Il risultato deve attraversare un contract del package layer, così che invarianti di identità, collisione, availability, facility/dependency, state e default restino centralizzati.

---

## 35. Compilazione nascosta dentro `extract`

Extract e build/source transformation devono restare semanticamente distinguibili.

---

## 36. Build dependency trattate automaticamente come runtime dependency

Toolchain e software necessario alla produzione non devono diventare accidentalmente requisiti del package installato.

---

## 37. Duplicazione del package model per il development workflow

Non è desiderabile creare un secondo concetto di:

```text
local package
local current
local dependency
local command exposure
```

se la stessa semantica è già coperta da `pkg`.

---

## 38. Fake repository per il progetto locale

Un progetto locale non dovrebbe essere costretto a fingere una distribution remota se il repository non esiste.

---

# Parte VII — Relazione con il futuro substrato e la superficie di sviluppo

## 39. Posizionamento probabile

Nella riflessione più ampia sul possibile futuro substrato general purpose, il tooling che comprende source tree, build, test e project composition appare più naturale nella **superficie di sviluppo flessibile** rispetto al contratto stabile minimo consumato dal runtime RumiAI.

Il principio esplorativo è:

```text
runtime/package environment
    non dipende dal project tooling

project tooling
    può dipendere dai contratti del runtime/package environment
```

Questo permette al tooling di evolvere più rapidamente senza congelare tutte le sue primitive come API permanenti del sistema.

---

## 40. Relazione con i concetti storici di `mk`

I concetti storici potenzialmente rilevanti per questa area restano:

```text
project composition
profiles/configuration overlays
distinct dependency kinds
type/build specialization
lifecycle build/test/install
bridge build -> package integration
test root materialization
```

Non devono invece essere ripresi automaticamente:

```text
dynamic global function naming
shell-sourced configuration
global mutable environment
implicit filesystem ordering
timestamp-only state
historical TARGET terminology senza chiarimento
```

In particolare, lo storico `TARGET` indicava operazioni come build/install/test/run e non deve essere confuso con l'attuale uso di target/osarch/deployment context.

---

# Parte VIII — Test e root isolata

## 41. Valore dello storico `testenv`

Un'altra idea storica utile era la capacità di materializzare il risultato in una root alternativa e provarlo lì.

Nel nuovo contesto, il flusso concettualmente più forte per un progetto locale potrebbe essere:

```text
source project
    ↓
source snapshot
    ↓
produce useful root
    ↓
package integration in isolated/test root
    ↓
exercise installed package through production-like path
```

Questo sarebbe preferibile a testare soltanto il build artifact direttamente dal workspace, perché eserciterebbe anche il package integration contract.

La nota non fissa una API per root alternative né modifica il current test framework.

---

# Parte IX — Questioni ancora aperte

## 42. Boundary pubblico o di sviluppo per l'integrazione locale

Resta da decidere chi può invocare il package integration path per un package prodotto localmente.

Possibili classi, non ancora scelte:

```text
API interna di pkg
superficie di sviluppo esplicita
command dedicato
orchestrazione attraverso altro tooling
```

Non si assume che l'attuale `pkg_integrate` debba diventare API pubblica.

---

## 43. Descrizione del progetto locale

Resta da decidere come il progetto esprime:

```text
package name
version
target qualification
source transformation rules
integration metadata
build requirements
runtime dependency/facility
```

Non viene introdotto qui un manifest o un pathname canonico.

---

## 44. Versione e provenance

Resta aperta la relazione fra:

```text
package version
upstream version
local project version
source snapshot identity
Git commit
digest
build provenance
```

---

## 45. Build environment

Resta da decidere come rappresentare e materializzare:

```text
compiler
build tool
runtime di build
headers/libraries
code generator
host capabilities
configuration flags
environment
```

senza confonderli con le dependency runtime del package finale.

---

## 46. Riproducibilità e cache

Un futuro sistema potrebbe dover considerare:

```text
source digest
configuration digest
toolchain identity
resolved build requirements
output digest
cache/reuse policy
```

Questi temi erano già implicitamente presenti nello storico `mk`, ma la nota non decide ancora un modello content-addressed o un build cache.

---

## 47. Target-specific build

Un progetto locale compilato può produrre output legato a `osarch`.

Resta da definire come il build context si collega alla concrete identity target-specific già prevista dal package model.

Non va riusato alla cieca il vecchio termine `TARGET` di `mk`.

---

## 48. Stesso motore per remote source-only e local source?

L'ipotesi è promettente, ma deve essere verificata su casi reali.

Prima di introdurre una primitive condivisa bisogna osservare almeno i primi consumer concreti e verificare che condividano davvero:

```text
input contract
build environment model
failure semantics
output contract
trust boundary
```

---

# Parte X — Non-decisioni esplicite

## 49. Questa nota non decide

Non viene deciso:

```text
- che esisterà un nuovo comando `mk`;
- che il tooling futuro si chiamerà `mk`;
- una nuova CLI di pkg;
- `pkg install ./path`;
- un subcommand local/install-local/build;
- una nuova API pubblica di pkg;
- un nuovo file manifest;
- una directory project metadata;
- uno schema di build definition;
- un repository type locale;
- un fake catalog locale;
- un nuovo namespace;
- una nuova variabile environment;
- un package format intermedio;
- un content-addressed store;
- una semantica definitiva della package version locale;
- una pseudo-versione local/dev/latest;
- overwrite/reinstall della stessa concrete identity;
- che build dependency e runtime dependency usino lo stesso schema;
- che pkg_integrate diventi API stabile;
- che pkg_extract cambi oggi contratto;
- che pkg-catalog cambi oggi struttura;
- che componenti first-party RumiAI debbano essere package;
- che il futuro substrato si chiami `m`;
- modifiche a rumiai-os, rumiai-tests o pkg-catalog.
```

---

# Parte XI — Sintesi

## 50. Tesi centrale

La riflessione porta a una separazione semplice:

```text
ACQUISITION
    remoto o locale

SOURCE TRANSFORMATION
    quando necessaria

PACKAGE INTEGRATION
    unica e comune
```

Il primo dominio cambia fra package remoto e progetto locale.

Il secondo dominio è il nuovo problema comune che emerge quando il materiale di partenza non è già una useful root.

Il terzo dominio appartiene già in gran parte a `pkg`.

---

## 51. Package remoto source-only

La forma concettuale è:

```text
pkg install
    ↓
resolve/download/extract source
    ↓
produce useful root
    ↓
normal package integration
```

`pkg` orchestra l'obiettivo, ma non dovrebbe incorporare direttamente tutti i build system del mondo.

---

## 52. Progetto locale

La forma concettuale è:

```text
src/project
    ↓
stable source snapshot
    ↓
produce useful root
    ↓
normal package integration
```

Il package installato è indipendente dal working tree.

Il caso interpretato e il caso compilato differiscono soltanto prima della useful root.

---

## 53. Relazione `mk` / `pkg`

La formulazione esplorativa più utile resta:

```text
project/build side
    source graph -> useful root / build artifacts

pkg side
    package identity + useful root -> materialized package environment
```

Oppure, in forma sintetica:

> il tooling di sviluppo costruisce; `pkg` materializza.

Lo storico `mk` è importante perché aveva già intuito il valore del confine build -> package integration, ma la nuova architettura deve renderlo molto più pulito e verificabile.

---

## 54. Punto architetturale più forte

Il risultato più importante di questa riflessione è che i due scenari non richiedono due soluzioni separate.

Entrambi convergono sullo stesso problema:

```text
source tree
    + materialization description
    + build environment
    ↓
useful root
```

e da lì possono usare un solo package integration model.

Se i primi casi concreti confermeranno questa convergenza, potrà emergere una responsabilità riutilizzabile fra `pkg` e il futuro tooling di sviluppo.

Fino ad allora questa resta un'ipotesi esplorativa, non una primitive di prodotto.
