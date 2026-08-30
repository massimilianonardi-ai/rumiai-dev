# RumiAI package manager — `@package` descriptor model

Data: 2026-08-30

Stato: **design decision — modello logico + serializzazione v0 fissati**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
```

Serializzazione:

```text
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

`@package` è il descriptor dichiarativo immutabile di una Package Instance.

Non è codice eseguibile, non richiede una directory `env/` separata e nel v0 è serializzato tramite il **restricted TOML 1.0 profile RumiAI**.

Il modello logico contiene:

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

---

# 1. `schema`

Versione esplicita dello schema descriptor:

```toml
schema = 1
```

Un parser non deve inferire lo schema dalla forma del documento.

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

Esempio:

```toml
[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "any"
architecture = "any"
display-name = "NetBeans 26"
```

I campi canonici:

```text
name
version
revision
platform
architecture
```

devono concordare con:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

`platform` e `architecture` descrivono esclusivamente i vincoli propri del contenuto della Package Instance. Runtime/interpreti/SDK necessari non entrano nell'identity e vengono espressi tramite `requirements`.

Quindi una Package Instance Java/Python realmente OS/CPU-independent usa:

```text
any-any
```

non `jvm-any` o `python-any`.

`version` è la software version upstream semanticamente opaca.

`display-name` è human-readable e non entra nel pathname canonico.

---

# 3. `release`

Metadata di ranking della release senza interpretare genericamente la software version upstream.

Campo v0:

```text
release-order
```

È un intero positivo monotono all'interno della stessa famiglia logica di provider/package.

Non fa parte dell'identity e non viene confrontato fra famiglie/provider differenti.

---

# 4. `integrity`

Descrive:

```text
root/
run-default/
```

Contiene almeno:

```text
integrity method/version
digest algorithm
file count
directory count
link count
ordered canonical inventory records
manifest digest
```

Nel TOML v0 l'inventory è un array ordinato di record line-oriented, non una table per ogni file.

Esempio:

```toml
[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 2
directories = 2
links = 1
manifest-digest = "..."
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "<digest>\tF\t0500\t./bin/foo",
  "<digest>\tF\t0400\t./app.jar",
  "<digest-target>\tL\t./log\t../run/log",
]
```

Il digest canonico viene calcolato sui record TOML già decodificati, concatenati con LF, non sui byte del serializer TOML.

Restano fissati:

```text
file: digest bytes + mode
directory: mode, nessun content digest
symlink: digest target testuale, nessun dereference
UID/GID/ACL/symlink mode esclusi dall'identità portabile
```

---

# 5. `state`

Contiene:

```text
state-compatibility-version
state scope
runtime mappings
```

State Instance ID:

```text
<pkg-name>[@<platform>-<architecture>]@s<state-compatibility-version>
```

Scope:

```text
shared
platform
architecture
platform-architecture
```

Ogni writable island appartiene esattamente a una fra:

```text
conf
data
home
cache
log
run
tmp
```

La mapping associa pathname relativo software e state area RumiAI; non contiene pathname host assoluti.

La qualificazione platform/architecture dello state è indipendente da quella della Package Instance e descrive esclusivamente i vincoli dello state.

---

# 6. `interface`

Descrive ciò che la Package Instance offre.

Resource v0:

```text
file
directory
command
```

`file` e `directory` referenziano path relativi sotto `root/`.

`command` descrive una Launch Template e può essere:

```text
direct
hosted da dependency
```

Le reference sono strutture TOML validate, non mini-language string.

---

# 7. `provides`

Dichiara Execution Capability offerte dalla Package Instance e collega il capability contract alle risorse della Package Interface.

Esempio logico:

```text
java-runtime
    contract = 1
    version = 21
    command -> command:java
    home    -> directory:home
    bin     -> directory:bin
```

Il capability contract definisce:

```text
contract version
version scheme
resource key richieste/opzionali
semantica del contratto
```

`contract` e capability compatibility `version` sono concetti distinti.

---

# 8. `requirements`

Descrive gli Execution Requirement mandatory usando dependency slot locali.

Esempio serializzato:

```toml
[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
contract = 1
constraint = ">=17 <22"
```

Java/JRE/JDK/Python sono quindi rappresentati qui tramite capability come:

```text
java-runtime
java-development-kit
python-runtime
```

non come Package Instance platform.

Non appartengono a `requirements`:

```text
provider preference
latest/newest
fallback
user/profile pin
resolved provider
```

---

# 9. `environment`

Environment Specification dichiarativa.

Primitive v0:

```text
set
set-if-unset
unset
prepend
append
```

Value type:

```text
scalar
path
path-list
```

Source:

```text
literal
self resource
dependency resource
state area/path
```

Esempio concettuale:

```text
JAVA_HOME
    set dependency jdk / directory home

PATH
    prepend dependency jdk / directory bin
```

Le operation concrete sono array TOML ordinati secondo lo schema v0.

La notazione architetturale:

```text
dependency:jdk.directory:home
```

resta solo abbreviazione descrittiva, non sintassi serializzata.

---

# 10. Command-specific environment

Una command resource può aggiungere un overlay specifico alla Environment Specification generale.

Precedence interna:

```text
package Environment Specification
        ↓
command-specific overlay
```

Gli altri layer appartengono al modello di integrazione/execution.

---

# 11. Cosa NON vive in `@package`

```text
resolved provider Package Instance
Selection Policy corrente
absolute RUMIAI_ROOT
absolute package path
Materialized Process Environment
current run/ target concreti
State Instance contents
logs/cache/PID/tmp
Integration Profile corrente
```

---

# 12. Semantic revision rule

Una modifica semantica a:

```text
identity
release metadata
integrity
state contract/mappings
Package Interface
provided capabilities
Execution Requirements
Environment Specification
Launch Template
```

produce una nuova RumiAI package `revision` e non modifica una Package Instance in-place.

---

# 13. Relocatability

Tutti i riferimenti descriptor sono logici/relativi.

Gli absolute pathname vengono materializzati soltanto al launch usando la RUMIAI_ROOT corrente.

---

# 14. Esempio logico — JDK provider

```text
identity
    temurin / 21.0.8+9 / r1 / native platform concreta

interface
    directory:home
    directory:bin
    file:java-exe
    file:javac-exe
    command:java
    command:javac

provides
    java-runtime contract 1 version 21
    java-development-kit contract 1 version 21
```

---

# 15. Esempio logico — NetBeans

Stress architetturale, non dichiarazione normativa sui requirement reali di una release specifica:

```text
identity
    netbeans / 26 / r1 / any-any

requirements
    slot jdk
        java-development-kit contract 1 >=17 <22

environment
    JAVA_HOME = dependency jdk / directory home
    PATH prepend dependency jdk / directory bin

interface
    command:netbeans
```

Il provider JDK concreto non compare nel descriptor. La necessità del JDK non modifica `platform = any` della Package Instance NetBeans.

---

# 16. Esempio logico — Python application

Un'applicazione Python priva di contenuto nativo proprio può essere:

```text
identity
    my-app / ... / any-any

requirements
    slot python
        python-runtime contract 1 =3.12
```

Se contiene una native extension obbligatoria, l'identity diventa invece native/platform-specific per il relativo contenuto, pur continuando a richiedere `python-runtime` separatamente.

---

# 17. Esempio logico — Pulsar

Pulsar è modellato come applicazione Electron/self-contained:

```text
requirements
    none

interface
    command:pulsar
```

La sua platform/architecture concreta dipende esclusivamente dal contenuto dell'artifact normalizzato distribuito; non vengono introdotte dependency Java artificiali.

---

# 18. Invarianti fissate

```text
PD-01 @package è dichiarativo e immutabile
PD-02 schema è esplicito
PD-03 pathname identity e descriptor identity devono concordare
PD-04 display-name è human-readable e non entra nel pathname
PD-05 platform/architecture descrivono il contenuto, non runtime/interprete/SDK richiesti
PD-06 any-any rappresenta contenuto realmente OS/CPU-independent
PD-07 release-order è metadata di selection, non identity
PD-08 integrity descrive root/ e run-default/
PD-09 state descrive contract/mappings, non contenuto mutabile
PD-10 interface resource = file, directory, command
PD-11 provides collega capability contract/version a Package Interface resource
PD-12 requirements descrive bisogno, non selection policy
PD-13 Java/JDK/JRE/Python necessari appartengono ai requirements, non alla platform
PD-14 environment è dichiarativo, non environment snapshot
PD-15 env/ fisica non è necessaria
PD-16 descriptor non contiene absolute pathname persistenti
PD-17 resolved/user policy state non vive in @package
PD-18 modifica semantica richiede nuova revision
PD-19 serializzazione v0 = restricted TOML 1.0
PD-20 reference serializzate strutturalmente, non come mini-language
PD-21 Pulsar non viene usato come esempio Java
```

---

# 19. Schema concreto

Lo schema campo-per-campo è definito in:

```text
drafts/rumiai-os/package-manager-schema-v0/README.md
```

I reference descriptor sono in:

```text
drafts/rumiai-os/package-manager-schema-v0/reference-descriptors.md
```
