# RumiAI package manager — Package Interface and execution model

Data: 2026-08-30

Stato: **design draft — Package Interface / Environment / Launch model v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-state-model/README.md
```

Questo documento separa formalmente:

```text
ciò che una Package Instance OFFRE
ciò che una Package Instance RICHIEDE
come costruire il suo ENVIRONMENT
come viene RISOLTO
come viene LANCIATO un comando
cosa viene reso PUBBLICO da un Integration Profile
```

Il modello evita environment globale come fonte di verità, shell code arbitrario e pathname assoluti persistiti.

---

# 1. Pipeline complessiva

```text
Package Instance
│
├── Package Interface
│      cosa offre
│
├── Execution Requirements
│      cosa richiede
│
└── Environment Specification
       come usare self/dependency/state
              │
              ↓
       dependency resolution
              │
              ↓
       Resolved Dependency Graph
              │
              ↓
Desired Integration Profile
              │
              ↓ resolve
Resolved Integration Profile
              │
              + State Instance attiva
              + command da eseguire
              ↓
       Resolved Environment
              ↓
       Launch Specification
              ↓
       materializzazione OS
              ↓
            process
```

La resolution dinamica termina prima del launch.

---

# 2. Package Interface

La **Package Interface** è la superficie immutabile che una Package Instance rende referenziabile dal resto del package manager.

Appartiene a `@package`.

Non rende automaticamente nulla pubblico nella shell o nel sistema.

Distinzione:

```text
Package Resource
    risorsa posseduta/offerta dalla Package Instance

Public Binding
    decisione di rendere una risorsa visibile in un Integration Profile
```

Più Package Instance possono offrire una risorsa chiamata `command:java` senza alcun conflitto finché non vengono candidate allo stesso public binding.

---

# 3. Package Resource v0

Il v0 usa tre tipi fondamentali:

```text
file
    file immutabile sotto root/

directory
    directory immutabile semanticamente rilevante sotto root/

command
    risorsa lanciabile descritta dichiarativamente
```

I nomi delle risorse sono locali alla Package Instance.

Esempio:

```text
file:runtime-config
directory:home
directory:bin
command:java
command:javac
```

Un resource name non è un pathname e non implica integrazione pubblica.

---

# 4. `file` e `directory`

Una risorsa `file` o `directory` referenzia un pathname relativo e canonico sotto `root/`.

Esempio concettuale:

```text
directory:home -> root/
directory:bin  -> root/bin
file:launcher  -> root/bin/tool
```

Non sono ammessi nella Package Interface:

```text
pathname assoluti
riferimenti fuori dalla Package Instance tramite ..
pathname host hardcoded
```

Le risorse Package Interface descrivono il core immutabile; lo stato mutabile viene referenziato separatamente tramite State Area references.

---

# 5. `command` non è necessariamente un pathname

Una risorsa `command` rappresenta una **Launch Template**.

Caso semplice:

```text
command:foo
    executable = self:file:foo-executable
```

ma il modello deve rappresentare anche software che viene ospitato da una runtime dependency.

Esempio generico JAR:

```text
command:app
    executable = dependency:jvm.command:java
    fixed-args = [ self:file:app-jar ]
```

Quindi:

> `command` significa “come avviare questa capacità eseguibile”, non semplicemente “path a un executable bit”.

La materializzazione fisica può essere un symlink solo quando questa semantica si riduce realmente a un executable diretto.

---

# 6. Launch Template v0

Una risorsa `command` deve poter dichiarare almeno:

```text
executable reference
fixed argument list
optional working-directory reference
optional command-specific environment overlay
```

I valori sono dichiarativi e tipizzati; non vengono interpretati da una shell.

L'executable reference può essere almeno:

```text
self:file:<resource>
dependency:<slot>.command:<resource>
```

Gli argomenti possono contenere:

```text
literal
self file/directory reference
dependency resource reference
state area/path reference
```

Il formato serializzato concreto resta da decidere.

---

# 7. Execution Capability e Package Interface

Una Execution Capability dichiara un contratto e collega quel contratto a risorse della Package Interface.

Esempio Java concettuale:

```text
provides java-runtime = 21

resources:
    command = command:java
    home    = directory:home
    bin     = directory:bin
```

Una stessa Package Instance JDK può inoltre dichiarare:

```text
provides java-development-kit = 21

resources:
    java  = command:java
    javac = command:javac
    home  = directory:home
    bin   = directory:bin
```

Il capability contract definisce quali resource key sono obbligatorie/opzionali per quel contratto.

Il consumer non deve conoscere i pathname del provider: referenzia le resource key esposte dal dependency slot risolto.

---

# 8. Execution Requirements

Gli Execution Requirements sono i dependency slot formalizzati nel dependency model.

Esempio:

```text
slot jdk:
    requires java-development-kit >=17 <22
```

La Package Instance non decide qui quale provider soddisferà `jdk`.

Dopo resolution:

```text
jdk
    -> exact Package Instance
```

Da questo momento le espressioni:

```text
dependency:jdk.command:java
dependency:jdk.directory:home
dependency:jdk.directory:bin
```

sono risolvibili deterministicamente.

---

# 9. Environment Specification

La **Environment Specification** appartiene a `@package` ed è immutabile con la Package Instance.

Non viene introdotta una directory fisica `env/` come fonte di verità.

Motivo:

```text
l'environment dipende da dependency binding concreti
state attivo
execution platform
Integration Profile
invocazione
```

quindi non può essere materializzato staticamente dentro la Package Instance senza perdere relocatability o dinamicità controllata.

---

# 10. Environment Specification è dati, non shell code

Sono vietati come meccanismo del descriptor:

```text
source
eval
shell snippet arbitrari
export VAR=$(comando)
command substitution
espansione shell non controllata
```

Il modello usa operazioni dichiarative.

Primitive v0:

```text
set
set-if-unset
unset
prepend
append
```

Il launcher interpreta queste primitive direttamente.

---

# 11. Tipi di environment value

Il v0 distingue almeno:

```text
scalar
    valore testuale singolo

path
    singolo pathname logico

path-list
    lista ordinata di pathname logici
```

Questo è necessario perché una variabile come `PATH` non è semanticamente una stringa opaca.

Il separatore fisico viene scelto dal materializzatore della piattaforma:

```text
Unix-like  :
Windows    ;
```

Il descriptor non concatena manualmente separator platform-specific.

---

# 12. Value expressions

Un value expression può referenziare almeno:

```text
literal:<value>
self:file:<resource>
self:directory:<resource>
dependency:<slot>.<resource-type>:<resource>
state:<area>
state:<area>/<relative-path>
```

Per scalar che richiedono composizione, il modello può usare una sequenza dichiarativa di frammenti literal/reference.

Esempio concettuale:

```text
JAVA_HOME
    set dependency:jdk.directory:home
```

oppure:

```text
SOME_OPTION
    set [literal:"prefix=", state:home]
```

Non viene eseguita interpolazione shell.

---

# 13. PATH

`PATH` è trattato come `path-list`.

Un package può dichiarare, per esempio:

```text
PATH
    prepend dependency:jdk.directory:bin
```

Per un processo package-specific, il path privato della dependency precede i binding pubblici.

Esempio Linux ARM64:

```text
1. private dependency paths del command/package
2. RUMIAI_ROOT/bin/@platforms/linux-arm64
3. RUMIAI_ROOT/bin
4. inherited host PATH entries ammessi dalla base environment policy
```

Questo permette a NetBeans di usare una Java privata senza cambiare il `java` pubblico della shell.

---

# 14. Environment base e indipendenza dall'host

RumiAI non assume che l'intero environment host debba essere cancellato: variabili come locale, display/sessione, terminale o altri dati OS possono essere necessarie.

Il v0 distingue quindi:

```text
Base Environment
    environment host ereditato/normalizzato dalla policy RumiAI

Managed Environment
    variabili/path su cui Package/Integration/Launch applicano binding dichiarativi
```

Regola:

> quando RumiAI gestisce esplicitamente una variabile per un command, il valore host omonimo non deve sostituire o alterare implicitamente il binding risolto.

Esempio:

```text
host JAVA_HOME=/usr/lib/random-java

NetBeans Environment Specification:
    JAVA_HOME = dependency:jdk.directory:home

→ il processo NetBeans usa il JDK RumiAI risolto
```

Nessun fallback automatico a `JAVA_HOME` o runtime host è permesso per soddisfare un Requirement.

---

# 15. Environment composition

Per una Launch Specification, la composizione logica avviene in layer espliciti:

```text
1. Base Environment RumiAI
2. Resolved Integration Profile environment bindings
3. environment richiesto dalla catena di Launch Template effettivamente invocata
4. Environment Specification del package root
5. command-specific environment overlay
6. explicit launch overrides
```

Un layer successivo può modificare un valore precedente soltanto tramite una primitiva esplicita (`set`, `unset`, `prepend`, ...).

Non esiste precedence derivata dall'ordine di installazione.

Le dependency che non partecipano alla Launch Template non iniettano automaticamente environment variable nel consumer.

---

# 16. Environment delle dependency

Una dependency privata non esporta automaticamente il proprio environment nel package consumer.

Il consumer usa esplicitamente le risorse necessarie:

```text
JAVA_HOME = dependency:jdk.directory:home
PATH prepend dependency:jdk.directory:bin
```

Se il consumer usa come executable un `dependency:<slot>.command:<name>`, viene composta la Launch Template di quel command provider, perché quel command può avere propri requisiti di launch.

Quindi la composizione segue la relazione di launch reale, non l'intera dependency closure in modo indiscriminato.

Questo evita collisioni fra environment di dependency che esistono nello stesso grafo ma non devono mutare lo stesso processo.

---

# 17. `set`, `set-if-unset`, `unset`, `prepend`, `append`

Semantica v0:

```text
set
    sostituisce il valore precedente con l'espressione risolta

set-if-unset
    assegna soltanto se la variabile non ha già un valore nel layer corrente derivato

unset
    rimuove la variabile dal Process Environment risultante

prepend
    valido per path-list; inserisce elementi prima della lista corrente

append
    valido per path-list; inserisce elementi dopo la lista corrente
```

`prepend/append` su scalar sono errore di schema.

Una stessa Environment Specification non deve contenere mutazioni contraddittorie non ordinabili della stessa variabile; l'ordine dichiarato delle operazioni all'interno della specifica è parte della semantica quando più operazioni sullo stesso path-list sono intenzionali.

---

# 18. Resolved Environment

La **Resolved Environment** è il risultato logico della composizione dopo che tutti i dependency slot sono stati risolti a Package Instance concrete.

Contiene:

```text
exact Package Instance/resource references
exact State Instance/area references
operazioni environment già validate e ordinate
```

Non persiste pathname assoluti della RumiAI root.

Esempio relocatable:

```text
JAVA_HOME
    = package temurin@21.0.8+9@r1@linux-arm64 / directory:home

PATH prepend
    = package temurin@21.0.8+9@r1@linux-arm64 / directory:bin
```

Solo il materializzatore OS traduce queste reference in stringhe assolute al launch.

---

# 19. Materialized Process Environment

Immediatamente prima della creazione del processo:

```text
Resolved Environment
        ↓ current RUMIAI_ROOT + platform adapter
Materialized Process Environment
```

Esempio:

```text
JAVA_HOME=/current/root/pkg/temurin@.../root
PATH=/current/root/pkg/temurin@.../root/bin:/current/root/bin/@platforms/linux-arm64:/current/root/bin:...
```

Questi absolute pathname sono effimeri.

Non vengono usati come identity né persistiti nel Package Instance descriptor/resolved lock.

---

# 20. Integration Profile

Un **Integration Profile** decide quali risorse diventano pubblicamente disponibili in uno scope persistente.

Resta separato dalle private dependency di ciascun command.

Esempi di public binding:

```text
command java
    -> exact Java Package Instance / command:java

command java8
    -> exact Java 8 Package Instance / command:java

environment JAVA_HOME
    -> exact Java Package Instance / directory:home
```

---

# 21. Desired vs Resolved Integration Profile

Il **Desired Integration Profile** può contenere selector/policy dinamici:

```text
public Java = newest compatible
java8 = java-runtime 8
```

Il **Resolved Integration Profile** contiene esclusivamente riferimenti concreti:

```text
java
    -> temurin@21.0.8+9@r1@linux-arm64 / command:java

java8
    -> temurin@8u462@r1@linux-arm64 / command:java
```

`latest`, preference e fallback non sopravvivono come selezione dinamica nel launch state.

Una nuova release locale non cambia automaticamente il Resolved Integration Profile.

---

# 22. Public binding conflict

Due package possono offrire la stessa risorsa senza conflitto.

Il conflitto nasce soltanto quando uno stesso Resolved Integration Profile tenta di creare due public binding incompatibili con lo stesso nome.

Esempio:

```text
java -> Java 21
java -> Java 17
```

è errore salvo override/alias esplicito nel Desired Integration Profile.

L'ordine di installazione non risolve conflitti.

---

# 23. Native specialization vs cross-platform binding

Resta valida la struttura già fissata:

```text
RUMIAI_ROOT/bin/
├── <cross-platform bindings>
└── @platforms/
    └── <platform>-<architecture>/
        └── <platform-specific bindings>
```

PATH:

```text
bin/@platforms/<current-platform>
bin
inherited PATH
```

Una variante native può specializzare lo stesso public command cross-platform soltanto quando il Resolved Integration Profile dichiara la relazione di specialization.

La precedence del PATH non è un resolver generico dei conflitti fra package non correlati.

---

# 24. Launch Specification

Una **Launch Specification** è la descrizione completamente risolta necessaria ad avviare un command.

Contiene almeno:

```text
root Package Instance exact identity
command resource
Resolved Dependency Graph da usare
State Instance attiva, se richiesta
Resolved Environment
resolved executable reference
fixed args
invocation args
working directory
```

Non contiene Requirement ancora da risolvere.

Non contiene `latest`.

Non fa provider selection durante il launch.

---

# 25. Command binding pubblico

Un public command binding non deve essere pensato necessariamente come:

```text
name -> executable pathname
```

La forma logica è:

```text
public command name
    -> exact root Package Instance
    -> command resource
    -> exact resolved graph/state required
    -> Launch Specification
```

La materializzazione fisica può scegliere:

```text
symlink diretto
    solo se nessun environment/launcher logic è necessario

launcher minimale
    quando deve costruire env/args/state
```

La tecnica fisica non cambia la semantica del binding.

---

# 26. Execution View

`bin/` e le altre future view materializzate sono derivate.

```text
Desired state
    ↓ resolve
Resolved state
    ↓ materialize
Execution View
```

La Execution View:

```text
non è fonte di verità
può essere ricostruita
non decide quale Package Instance è installata
non decide autonomamente dependency resolution
```

Un binding stale verso una Package Instance assente/corrotta è integration corruption / BROKEN_RESOLUTION, non motivo per selezionare automaticamente un'altra versione.

---

# 27. `integrate`

Concettualmente:

```text
modify Desired Integration Profile
        ↓
resolve selectors + dependency Requirements
        ↓
produce Resolved Integration Profile
        ↓
produce/persist exact Resolved Dependency Graph per root binding
        ↓
validate public binding conflicts
        ↓
rebuild Execution View
```

Non modifica `root/`, `run-default/` o `@package`.

---

# 28. `deintegrate`

Concettualmente:

```text
remove desired selector/binding
        ↓
new explicit resolution
        ↓
new Resolved Integration Profile
        ↓
rebuild Execution View
```

Non tenta di annullare heuristicamente side effect storici.

Non implica uninstall della Package Instance né purge della State Instance.

---

# 29. Re-resolution

Una re-resolution è una transazione esplicita.

Può cambiare:

```text
provider
release
RumiAI revision
resolved dependency closure
public binding target
```

ma il nuovo state viene validato prima di sostituire quello precedente.

Il launch non è una re-resolution.

---

# 30. Caso Java pubblico + NetBeans privato

Store locale:

```text
Temurin Java 17
Temurin Java 21
altri provider compatibili
NetBeans
```

Default Integration Profile:

```text
java -> Java 21 public
JAVA_HOME -> Java 21 home
```

NetBeans, esempio architetturale:

```text
slot jdk:
    requires java-development-kit >=17 <22

environment:
    JAVA_HOME set dependency:jdk.directory:home
    PATH prepend dependency:jdk.directory:bin
```

Resolved NetBeans:

```text
jdk -> exact Java 21 Package Instance
```

Il processo NetBeans vede il JDK risolto privatamente.

La shell continua a vedere il Java pubblico del profile.

Il range usato qui è un esempio di stress architetturale, non una dichiarazione normativa sui requisiti di una specifica release reale di NetBeans.

---

# 31. Java 8 alias

Un Desired Integration Profile può chiedere:

```text
java -> newest preferred Java
java8 -> java-runtime = 8 / command:java
```

Resolved:

```text
java
    -> exact Java 21 / command:java

java8
    -> exact Java 8 / command:java
```

Entrambe convivono senza cambiare i private dependency binding di altre applicazioni.

---

# 32. Python pubblico + Python privato

Default profile:

```text
python -> Python 3.13
```

Una `python-app` può dichiarare:

```text
slot python:
    requires python-runtime = 3.12
```

La sua Launch Template può usare direttamente:

```text
executable = dependency:python.command:python
fixed-args = [ self:file:main-script ]
```

senza modificare il `python` pubblico.

Il package non è obbligato a impostare `PYTHONHOME`: lo dichiara soltanto se il suo reale contratto di esecuzione lo richiede.

---

# 33. Pulsar come caso Electron/self-contained

Pulsar non viene usato come esempio di applicazione Java.

Nel modello di stress rappresenta un'applicazione Electron/self-contained che può non avere Execution Requirements di runtime esterne.

Forma concettuale:

```text
Pulsar Package Instance

command:pulsar
    executable = self:file:pulsar-executable

Execution Requirements:
    none
```

Questo verifica che il modello non introduca dependency artificiali solo perché supporta runtime selezionabili.

---

# 34. JAR-only app

Caso utile per verificare che `command != path`.

```text
slot jvm:
    requires java-runtime = 21

file:app-jar
    -> root/app.jar

command:app
    executable = dependency:jvm.command:java
    fixed-args = [ self:file:app-jar ]

JAVA_HOME
    set dependency:jvm.directory:home
```

Non serve creare uno script shell artificiale dentro `root/` soltanto per trasformare il JAR in comando.

---

# 35. Stato e environment

La State Instance resta separata dalla Package Instance.

L'Environment Specification può referenziare semanticamente:

```text
state:conf
state:data
state:home
state:cache
state:log
state:run
state:tmp
```

ma non decide dove queste aree vivono fisicamente.

La `run/` package-local continua a fornire la view filesystem delle writable islands.

Environment variable e runtime routing sono due meccanismi complementari:

```text
software hardcoded sul proprio tree
    -> root/ → run/ → State Areas

software configurabile via env
    -> Environment Specification → State Areas
```

Entrambi puntano alla stessa State Instance attiva quando rappresentano lo stesso stato.

---

# 36. Persistenza del resolved execution state

Per reproducibility devono essere persistibili almeno:

```text
Resolved Integration Profile
Resolved Dependency Graph per root package/command
exact command resource binding
State Instance identity selezionata
selection/policy provenance sufficiente per audit
```

La Resolved Environment può essere persistita come riferimenti logici/esatti o ricostruita deterministicamente da questi oggetti.

Non vengono persistiti absolute pathname materializzati.

---

# 37. Failure semantics

Al launch:

```text
exact package missing/corrupt
    -> BROKEN_RESOLUTION

resource prevista non presente/integra
    -> BROKEN_RESOLUTION / INTEGRITY FAILURE

State Instance non materializzabile
    -> STATE_UNAVAILABLE

environment expression invalida
    -> INVALID_EXECUTION_SPEC
```

Il launcher non tenta:

```text
provider fallback
host JAVA_HOME fallback
host Python fallback
PATH discovery di runtime casuali
newest selection
```

Queste appartengono alla resolution esplicita, non al launch.

---

# 38. Invarianti fissate

```text
IM-01 Package Interface descrive risorse; non le integra automaticamente
IM-02 Package Resource v0 = file, directory, command
IM-03 file/directory resource sono root-relative e relocatable
IM-04 command è Launch Template, non necessariamente executable pathname
IM-05 capability contract mappa resource key a Package Interface resource
IM-06 Execution Requirements = dependency slot dichiarativi immutabili
IM-07 Environment Specification appartiene a @package; non esiste env/ autorevole
IM-08 environment è dati dichiarativi, non shell code/eval
IM-09 primitive v0 = set, set-if-unset, unset, prepend, append
IM-10 environment value v0 distingue scalar, path, path-list
IM-11 PATH è path-list semanticamente tipizzata
IM-12 package/dependency/state resource vengono referenziate semanticamente, non tramite absolute path
IM-13 dependency non inietta automaticamente environment nel consumer
IM-14 provider command env viene composto quando la sua Launch Template è realmente invocata
IM-15 managed env binding prevale sul valore host omonimo secondo layer espliciti
IM-16 private dependency paths possono precedere public PATH nel processo specifico
IM-17 Resolved Environment usa exact relocatable references
IM-18 absolute pathname esistono solo nella Materialized Process Environment effimera
IM-19 Desired Integration Profile può essere dinamico; Resolved Integration Profile è concreto
IM-20 public binding conflict non è risolto dall'install order
IM-21 command binding logico produce una Launch Specification
IM-22 Launch Specification non contiene Requirement/latest ancora dinamici
IM-23 Execution View è derivata e rebuildable
IM-24 launch non esegue dependency re-resolution
IM-25 BROKEN_RESOLUTION non autorizza fallback implicito
IM-26 State routing filesystem ed Environment Specification sono complementari
IM-27 Pulsar è caso Electron/self-contained, non esempio Java
```

---

# 39. Questioni tecniche successive

Il modello architetturale è ora sufficientemente definito per separare le questioni di serializzazione/implementazione:

```text
sintassi concreta di @package
schema/version del descriptor
grammatica concreta delle value expressions
formato persistito di Resolved Dependency Graph / Resolved Integration Profile
identity/versioning del resolved state
materializzazione fisica dei launcher in bin/
platform adapter per Process Environment
```

Queste decisioni non devono reintrodurre resolution dinamica al launch, pathname assoluti persistenti o shell code arbitrario.