# RumiAI package manager — `@package` logical descriptor model

Data: 2026-08-30

Stato: **design draft — modello logico fissato, serializzazione non ancora scelta**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
```

`@package` è il descriptor dichiarativo immutabile di una Package Instance.

Non è codice eseguibile e non richiede una directory `env/` separata.

Il modello logico v0 contiene le seguenti sezioni:

```text
schema
identity
release
integrity
state
interface
requirements
environment
```

La sintassi concreta resta volutamente aperta.

---

# 1. `schema`

Identifica la versione dello schema del descriptor RumiAI.

Concettualmente:

```text
schema = 1
```

Serve a permettere evoluzione esplicita del descriptor.

Il parser non deve inferire uno schema dalla presenza/assenza casuale di campi.

---

# 2. `identity`

Contiene:

```text
name
version
revision
platform
architecture
display-name
```

Esempio concettuale:

```text
name         = netbeans
version      = 26
revision     = 1
platform     = jvm
architecture = any
display-name = NetBeans 26
```

I campi canonici:

```text
name
version
revision
platform
architecture
```

devono concordare con il pathname:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`display-name` è human-readable e non entra nel pathname canonico.

---

# 3. `release`

Contiene metadata necessari alla selezione di release senza interpretare genericamente la software version upstream.

Campo v0:

```text
release-order
```

`release-order` è un intero positivo monotono all'interno della stessa famiglia logica di package/provider.

Esempio:

```text
software version = 8u462
release-order    = 382
```

Non fa parte dell'identity/pathname.

Non è confrontato tra provider/famiglie differenti.

Serve al resolver quando una Selection Policy richiede la release compatibile più recente della famiglia scelta.

---

# 4. `integrity`

Descrive l'integrità dei tree immutabili:

```text
root/
run-default/
```

Contiene logicamente almeno:

```text
integrity method/version
digest algorithm
root inventory
root manifest digest
run-default inventory
run-default manifest digest
```

Ogni inventory contiene:

```text
file count
directory count
link count
entry type
relative pathname
regular-file digest
POSIX canonical mode per regular file/directory
symlink target + digest del target testuale
```

Non contiene come identità portabile:

```text
UID
GID
symlink ownership
symlink mode
ACL
```

Restano valide le permission/integrity invariants del Package Instance layout.

---

# 5. `state`

Descrive il contratto di stato della Package Instance.

Contiene almeno:

```text
state-compatibility-version
state scope
runtime mappings
```

State Instance ID:

```text
<pkg-name>[@<platform>-<architecture>]@s<state-compatibility-version>
```

State scope:

```text
shared
platform
architecture
platform-architecture
```

Le runtime mappings associano ogni writable island a esattamente una state area:

```text
conf
data
home
cache
log
run
tmp
```

Esempio concettuale:

```text
etc        -> conf
workspace  -> data
logs       -> log
temp       -> tmp
```

Il pathname relativo della writable island è condiviso semanticamente fra:

```text
root/<path>         symlink verso ../run/<path>
run-default/<path>  factory default immutabile
run/<path>          routing derivato verso la State Instance
```

`state` non contiene pathname assoluti RumiAI.

---

# 6. `interface`

Descrive ciò che la Package Instance offre.

Contiene:

```text
resources
provides
```

Resource type v0:

```text
file
directory
command
```

`file` e `directory` puntano a pathname relativi sotto `root/`.

`command` descrive una Launch Template e può essere diretto oppure ospitato da una dependency.

Esempio diretto:

```text
command:tool
    executable = self:file:tool-executable
```

Esempio hosted:

```text
command:app
    executable = dependency:jvm.command:java
    fixed-args = [ self:file:app-jar ]
```

---

# 7. `provides`

`provides` dichiara Execution Capability offerte dalla Package Instance e mappa il contratto alle resource della Package Interface.

Esempio concettuale:

```text
java-runtime = 21
    command -> command:java
    home    -> directory:home
    bin     -> directory:bin
```

Una Package Instance può fornire più capability.

Il capability contract, non il provider, definisce:

```text
version scheme
resource key obbligatorie/opzionali
semantica del contratto
```

---

# 8. `requirements`

Descrive gli Execution Requirement mandatory della Package Instance.

Ogni requirement usa un dependency slot locale.

Esempio:

```text
slot jdk:
    target = capability
    capability = java-development-kit
    constraint = >=17 <22
```

Oppure provider-specific quando realmente necessario:

```text
slot engine:
    target = package
    package = specific-engine
```

Non appartengono a `requirements`:

```text
provider preference
latest/newest policy
fallback order
exact pin scelto dall'utente/profile
resolved Package Instance
```

Questi appartengono alla Selection Policy / resolved state esterni alla Package Instance.

---

# 9. `environment`

Descrive la Environment Specification dichiarativa della Package Instance.

Non è una snapshot dell'environment concreto.

Non contiene absolute pathname.

Primitive v0:

```text
set
set-if-unset
unset
prepend
append
```

Value type v0:

```text
scalar
path
path-list
```

Value reference v0:

```text
literal
self resource
dependency slot resource
state area/path
```

Esempio concettuale:

```text
JAVA_HOME
    set dependency:jdk.directory:home

PATH
    prepend dependency:jdk.directory:bin
```

La sintassi serializzata non deve richiedere shell, `eval`, command substitution o path separator platform-specific.

---

# 10. Command-specific environment

Una `command` resource può aggiungere un environment overlay specifico alla Environment Specification generale del package.

Questo permette a due command dello stesso package di avere esigenze differenti senza introdurre script arbitrari.

Precedence logica interna:

```text
package Environment Specification
        ↓
command-specific environment overlay
```

Il modello di integrazione definisce gli altri layer esterni.

---

# 11. Cosa NON vive in `@package`

Non devono essere persistiti nel descriptor immutabile:

```text
resolved provider Package Instance
current Selection Policy dell'utente/profile
absolute RUMIAI_ROOT
absolute package pathname
Materialized Process Environment
current run/ symlink targets concreti
mutable State Instance contents
logs/cache/PID/tmp
Integration Profile corrente
```

Questi sono resolved/derived/mutable state esterni.

---

# 12. Semantic revision rule

Una modifica a uno dei seguenti elementi cambia il significato operativo della Package Instance:

```text
identity canonica
release metadata usato dal resolver
integrity declaration
state compatibility/mappings
Package Interface
provided capabilities
Execution Requirements
Environment Specification
Launch Template
```

Non viene riscritta in-place una Package Instance esistente.

La modifica produce una nuova `revision` RumiAI della Package Instance, anche se la software version upstream non cambia.

---

# 13. Relocatability

Tutti i riferimenti del descriptor sono logici/relativi:

```text
self resources
dependency slot resources
state areas
relative root path
```

Il mapping verso:

```text
/current/RUMIAI_ROOT/...
```

avviene soltanto durante materializzazione/launch.

---

# 14. Esempio logico — JDK provider

Senza fissare una sintassi concreta:

```text
schema
    1

identity
    name = temurin
    version = 21.0.8+9
    revision = 1
    platform = linux
    architecture = arm64
    display-name = Eclipse Temurin 21

release
    release-order = <packaging assigned order>

interface
    directory:home -> root/
    directory:bin  -> root/bin
    file:java-exe  -> root/bin/java
    file:javac-exe -> root/bin/javac

    command:java
        executable = self:file:java-exe

    command:javac
        executable = self:file:javac-exe

provides
    java-runtime = 21
        command = command:java
        home = directory:home
        bin = directory:bin

    java-development-kit = 21
        java = command:java
        javac = command:javac
        home = directory:home
        bin = directory:bin
```

---

# 15. Esempio logico — NetBeans consumer

Esempio di stress architetturale, non dichiarazione normativa sui requirement di una specifica release reale:

```text
identity
    name = netbeans
    version = 26
    display-name = NetBeans 26

requirements
    slot jdk
        requires java-development-kit >=17 <22

environment
    JAVA_HOME
        set dependency:jdk.directory:home

    PATH
        prepend dependency:jdk.directory:bin

interface
    command:netbeans
        executable = self:file:netbeans-launcher
```

Il provider JDK concreto non compare nel descriptor NetBeans.

---

# 16. Esempio logico — Pulsar

Pulsar viene modellato come applicazione Electron/self-contained, non come consumer JVM.

Esempio:

```text
requirements
    none

interface
    command:pulsar
        executable = self:file:pulsar-executable
```

Questo evita dependency artificiali introdotte soltanto come esempi.

---

# 17. Invarianti fissate

```text
PD-01 @package è dichiarativo e immutabile
PD-02 schema version è esplicita
PD-03 identity pathname e descriptor devono concordare
PD-04 display-name è human-readable e non entra nel pathname
PD-05 release-order è metadata di selezione, non identity/software version
PD-06 integrity descrive root/ e run-default/ immutabili
PD-07 state descrive compatibility/scope/runtime mappings, non contenuto mutabile
PD-08 interface descrive resource file/directory/command
PD-09 provides mappa capability contract a Package Interface resource
PD-10 requirements descrive bisogno, non provider preference/resolution
PD-11 environment è Environment Specification dichiarativa, non env snapshot
PD-12 env/ fisica non è necessaria come fonte di verità
PD-13 descriptor non contiene absolute pathname persistenti
PD-14 resolved state/user policy non vive in @package
PD-15 modifica semantica del descriptor richiede nuova RumiAI revision
PD-16 Pulsar non viene usato come esempio di dependency Java
```

---

# 18. Prossimo livello

Con il modello logico definito, la decisione successiva può essere la **serializzazione concreta di `@package`** e del resolved state.

Quella scelta deve preservare:

```text
parsing deterministico
schema/version esplicita
nessuna esecuzione di codice
round-trip non necessario per la semantica
rappresentazione non ambigua di path/value expressions
portabilità Linux/macOS/Windows
```
