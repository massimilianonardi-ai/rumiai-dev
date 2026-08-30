# RumiAI package manager — Dependency and resolution model

Data: 2026-08-30

Stato: **design draft — resolver v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
```

Questo documento formalizza il resolver locale. Resta interamente sul lato locale del confine già fissato:

> il resolver vede soltanto Package Instance già presenti sotto `pkg/`; non acquisisce software, non consulta package manager host e non usa runtime trovati casualmente nel `PATH`.

---

# 1. Separazione fondamentale

Il modello distingue quattro oggetti:

```text
Requirement
    cosa serve

Selection Policy
    come scegliere tra più soluzioni valide

Resolved Binding
    scelta concreta per un dependency slot

Resolved Dependency Graph
    insieme persistibile delle scelte concrete
```

Regola centrale:

```text
Requirement != Resolved Binding
```

La selezione può essere dinamica durante una nuova resolution; l'esecuzione usa sempre binding concreti già risolti.

---

# 2. Execution Capability

Nel namespace del package manager una **Execution Capability** è un contratto nominato che una Package Instance può fornire e un'altra può richiedere.

Non è una capability del Core-AI.

Esempi:

```text
java-runtime
python-runtime
java-development-kit
```

Una Package Instance può dichiarare:

```text
provides:
    java-runtime = 21
```

Il consumer può richiedere:

```text
requires:
    java-runtime >=17 <22
```

senza conoscere il provider concreto.

---

# 3. Software version, capability version e release-order

Tre concetti sono separati.

## 3.1 Software version

Identifica la release upstream concreta:

```text
21.0.8+9
8u462
3.13.7
release-42
```

RumiAI la tratta semanticamente come stringa upstream opaca.

Non esiste un comparatore universale implicito delle software version.

## 3.2 Capability compatibility version

Appartiene al contratto della Execution Capability.

Esempi concettuali:

```text
java-runtime
    compatibility version = feature release intera
    8, 11, 17, 21, ...

python-runtime
    compatibility version = major.minor
    3.11, 3.12, 3.13, ...
```

Il capability contract definisce la propria rappresentazione canonica e il proprio ordinamento.

Il resolver confronta capability version, non interpreta genericamente le software version upstream.

## 3.3 `release-order`

Ogni Package Instance può contenere metadata immutabile:

```text
release-order = <positive integer>
```

`release-order` ordina le release **all'interno della stessa famiglia logica di package/provider**.

Esempio:

```text
temurin 8u452
release-order = 381

temurin 8u462
release-order = 382
```

Il valore viene assegnato dal lato packaging/store, che conosce l'ordine reale delle release upstream.

Il package manager locale non deve dedurre che `8u462 > 8u452` dalla stringa.

`release-order`:

```text
non fa parte del pathname Package Instance
non sostituisce software version
non è confrontabile semanticamente tra famiglie provider differenti
```

La `revision` RumiAI resta separata e ordina differenti revisioni di packaging della stessa release.

---

# 4. Dependency slot

Ogni requirement di una Package Instance possiede un nome locale, il **dependency slot**.

Esempio:

```text
slot jvm:
    requires java-runtime = 21
```

`jvm` appartiene al namespace del consumer.

Dopo la resolution:

```text
jvm
    -> temurin@21.0.8+9@r1@linux-arm64
```

I metadata del consumer possono quindi referenziare risorse attraverso lo slot:

```text
dependency:jvm.command:java
dependency:jvm.directory:home
dependency:jvm.directory:bin
```

senza conoscere prima della resolution provider e pathname concreti.

---

# 5. Requirement

Un Requirement è immutabile e appartiene a `@package`.

Nel v0 esistono due target.

## 5.1 Capability Requirement

Forma concettuale:

```text
slot jvm:
    target = capability
    capability = java-runtime
    constraint = =21
```

oppure:

```text
slot python:
    target = capability
    capability = python-runtime
    constraint = >=3.11 <3.14
```

È la forma preferita quando il provider concreto non è semanticamente rilevante.

## 5.2 Package Requirement

Usata soltanto quando il consumer dipende realmente da una specifica famiglia/provider.

Forma concettuale:

```text
slot engine:
    target = package
    package = specific-engine
```

Una Package Requirement limita il candidate set a quella famiglia logica; la scelta della release concreta resta separata e usa Selection Policy / release-order, salvo pin esatto.

## 5.3 Constraint v0

Il v0 supporta constraint congiuntivi semplici sul version scheme della capability:

```text
=
>=
>
<=
<
```

Esempi:

```text
=8
>=17 <22
>=3.11 <3.14
```

Non vengono introdotti nel v0:

```text
OR
NOT
wildcard complesse
constraint sulle stringhe software version upstream
```

Se in futuro servono, evolvono il capability contract/schema, non vengono inferiti implicitamente.

---

# 6. Requirement mandatory nel v0

Tutte le Execution Dependency dichiarate nel v0 sono obbligatorie.

Se un Requirement non è risolvibile:

```text
DEPENDENCY_UNAVAILABLE
```

Il v0 non introduce `optional dependency` o auto-enable di feature in base a ciò che capita nello store.

Funzionalità opzionali possono essere modellate in futuro esplicitamente; non devono introdurre comportamento non deterministico ora.

---

# 7. Candidate set locale

Per ogni Requirement il resolver costruisce candidati esclusivamente da Package Instance locali sane sotto:

```text
RUMIAI_ROOT/pkg/
```

Una candidata deve almeno:

```text
essere HEALTHY secondo identity/integrity
essere compatibile con l'Execution Platform corrente richiesta
soddisfare il target package/capability
soddisfare il capability constraint
```

Non sono candidate:

```text
software disponibile solo nel rumiai-store remoto/catalogo
runtime host trovato nel PATH
apt/dnf/brew/Chocolatey/MSI installati globalmente
package corrotti/inconsistenti
Package Instance per piattaforma incompatibile
```

Acquisire una Package Instance mancante è un'altra operazione, fuori dal resolver locale.

---

# 8. Selection Policy

La Selection Policy è separata dal Requirement.

Il consumer deve dichiarare ciò che gli serve; non deve hardcodare preferenze di vendor quando il vendor non è parte del requisito semantico.

La policy può derivare, in ordine di precedenza, da:

```text
1. exact pin esplicito dello scope/operazione corrente
2. override esplicito dell'Integration Profile / desired state
3. policy dell'environment RumiAI
4. nessuna preferenza
```

Il package consumer non impone una provider preference per un Capability Requirement generico.

Se vuole davvero un provider specifico usa una Package Requirement.

---

# 9. Pin vs preference

## 9.1 Exact pin

Un pin identifica una Package Instance concreta.

Esempio:

```text
slot jvm
pin = temurin@21.0.8+9@r1@linux-arm64
```

Se l'istanza non esiste, è corrotta o non soddisfa il Requirement:

```text
PIN_UNAVAILABLE
```

Un pin **non fa fallback**.

## 9.2 Provider preference

Una preference ordina provider/famiglie preferite ma consente fallback.

Esempio concettuale:

```text
provider-order:
    temurin
    microsoft-openjdk
    any-compatible
```

Significa:

```text
prima prova un candidato Temurin valido
se assente prova Microsoft OpenJDK
se assente considera altri provider compatibili
```

Il fallback esiste soltanto durante una nuova resolution.

Non viene rivalutato durante il launch.

---

# 10. `latest` / `newest`

`latest` non è una software version e non è una Package Instance.

È una Selection Policy.

Nel v0 il comportamento equivalente a `newest compatible` è:

```text
1. usa soltanto candidati che soddisfano il Requirement
2. applica provider preference/pin
3. se il constraint ammette più capability compatibility version, preferisce la più alta secondo il capability contract
4. dentro la stessa famiglia/provider + capability compatibility version, preferisce il release-order più alto
5. a parità di release-order, preferisce la revision RumiAI più alta
```

`release-order` non viene confrontato fra provider differenti.

Se dopo l'applicazione delle policy restano più provider equivalenti e non esiste un criterio semantico che li ordini:

```text
RESOLUTION_AMBIGUOUS
```

Il resolver non usa ordine filesystem, data di installazione o ordine di enumerazione come tie-breaker nascosto.

---

# 11. Resolution algorithm v0

Per ogni dependency slot:

```text
Requirement
    ↓
build local candidate set
    ↓
filter platform + health
    ↓
filter requirement target/constraint
    ↓
apply exact pin, se presente
    ↓
apply provider preference
    ↓
select capability compatibility version secondo policy
    ↓
select release-order nella famiglia scelta
    ↓
select RumiAI revision
    ↓
Resolved Binding
```

Il resolver procede sull'intera dependency closure fino a ottenere un grafo concreto o un errore.

---

# 12. Resolved Binding

Un Resolved Binding associa in modo deterministico:

```text
consumer Package Instance
+ dependency slot
+ Requirement
→ exact provider Package Instance
```

Esempio:

```text
consumer:
    netbeans@26@r1@jvm-any

slot:
    jdk

requirement:
    java-development-kit >=17 <22

resolved:
    temurin@21.0.8+9@r1@linux-arm64
```

Dopo il commit della resolution, `jdk` significa **quella esatta Package Instance**, non “qualunque JDK compatibile”.

---

# 13. Dynamic during resolution, static during execution

Regola fissata:

```text
dynamic selection
    soltanto durante resolution

exact binding
    durante execution
```

Esempio:

```text
policy:
    prefer Temurin
    fallback Microsoft

resolution:
    jdk -> Temurin 21
```

Se successivamente Temurin viene rimosso/corrotto, il prossimo launch NON passa automaticamente a Microsoft.

Risultato:

```text
BROKEN_RESOLUTION
```

Serve una nuova resolution esplicita.

Questo preserva:

```text
reproducibility
audit
rollback
assenza di mutazioni invisibili
```

---

# 14. Eventi che possono produrre una nuova resolution

Nel v0 una nuova resolution avviene soltanto come effetto di un'operazione esplicita, per esempio:

```text
prima integrazione/attivazione
update esplicito
re-resolve esplicito
cambio Selection Policy
cambio Desired Integration Profile
switch a una nuova Package Instance con Requirement differenti
riparazione esplicita di una BROKEN_RESOLUTION
```

Non avviene automaticamente:

```text
a ogni launch
a ogni reboot
perché compare una Package Instance più nuova
perché cambia l'ordine del filesystem
```

Installare una nuova Java 21 non cambia da sola un binding già risolto verso una Java 21 precedente.

---

# 15. Resolved Dependency Graph

Il resolver produce una closure concreta:

```text
root Package Instance
├── slot A -> exact Package Instance
│   └── ... transitive bindings ...
└── slot B -> exact Package Instance
    └── ...
```

Il grafo contiene soltanto Package Instance concrete.

Per ogni edge devono essere preservabili almeno:

```text
consumer identity
slot name
Requirement snapshot
provider identity
capability/version usata per soddisfare il Requirement, se applicabile
```

Il resolved graph è stato derivato e persistibile; non appartiene alla Package Instance immutabile.

---

# 16. Persistenza e relocatability del resolved graph

Il persisted resolved state NON contiene pathname assoluti della RumiAI root.

Persistisce riferimenti logici/esatti alle Package Instance e alle loro risorse.

Esempio:

```text
jdk
    -> temurin@21.0.8+9@r1@linux-arm64
```

non:

```text
jdk
    -> /Volumes/.../RumiAI/pkg/temurin.../root
```

Il pathname fisico viene ricostruito dalla RumiAI root corrente al momento della materializzazione/launch.

Questo mantiene l'environment relocatable.

---

# 17. Private dependencies

Le dipendenze sono private per default.

Se NetBeans risolve:

```text
jdk -> Java 21
```

questo non crea automaticamente nel default Integration Profile:

```text
java
javac
JAVA_HOME
```

La dipendenza serve all'Execution Environment di NetBeans.

Una risorsa del provider diventa pubblica soltanto tramite un binding di integrazione esplicito.

---

# 18. Coesistenza e conflitti

Package Instance incompatibili possono convivere fisicamente nello store locale.

Esempio:

```text
Java 8
Java 17
Java 21
Python 3.12
Python 3.13
```

Possono essere usate in Execution Environment distinti.

Nel v0, dentro lo stesso Execution Environment, una stessa Execution Capability richiede una soluzione coerente unica, salvo futuro isolation model esplicito.

Esempio:

```text
A requires D >=7 <8
B requires D >=8 <9
```

se A e B devono condividere lo stesso environment e non esiste soluzione comune:

```text
RESOLUTION_CONFLICT
```

La semplice presenza contemporanea di D7 e D8 sotto `pkg/` non risolve il conflitto.

---

# 19. Dependency cycles

Nel v0 un ciclo nella dependency closure è un errore:

```text
RESOLUTION_CYCLE
```

Non vengono introdotte ora semantiche speciali di mutual bootstrap, component groups o lazy cyclic dependencies.

Se un prodotto reale richiederà un ciclo legittimo, dovrà emergere come requisito architetturale esplicito.

---

# 20. Reference accounting

Ogni Resolved Dependency Graph crea reference esplicite alle Package Instance che contiene.

Una Package Instance non può essere rimossa fisicamente se è ancora referenziata da uno stato risolto valido.

Questo è il fondamento futuro per:

```text
why-installed
reference accounting
garbage collection
upgrade preview
rollback
```

L'ordine o la semplice presenza di directory non sostituisce le reference.

---

# 21. Casi di stress v0

## 21.1 Java default

Desired integration:

```text
require java-runtime
selection = newest compatible
provider preference = temurin, any-compatible
```

Resolved:

```text
java-runtime
    -> exact Java Package Instance
```

Il binding pubblico `java` viene trattato dal modello di integrazione, non dal resolver stesso.

## 21.2 Java 8 esplicita

```text
slot java8-runtime:
    requires java-runtime = 8
```

Resolved:

```text
java8-runtime
    -> exact Java 8 Package Instance
```

## 21.3 NetBeans con JDK privata

Esempio architetturale:

```text
NetBeans Package Instance

slot jdk:
    requires java-development-kit >=17 <22
```

Resolved su host Linux ARM64:

```text
jdk
    -> temurin@21.0.8+9@r1@linux-arm64
```

Il JDK resta privato all'Execution Environment di NetBeans salvo integrazione pubblica esplicita.

## 21.4 Python app privata

```text
python-app

slot python:
    requires python-runtime = 3.12
```

può convivere con un default pubblico Python 3.13 perché i due binding appartengono a execution/integration scope differenti.

## 21.5 Pulsar

Pulsar viene usato come caso di applicazione Electron/self-contained nel modello di stress.

Non viene modellato come consumer Java e non dichiara un requirement JVM solo per convenienza d'esempio.

Questo caso verifica anche che una Package Instance senza Execution Dependency possa avere un Launch Specification diretto.

---

# 22. Errori normativi v0

```text
DEPENDENCY_UNAVAILABLE
    nessuna Package Instance locale soddisfa il Requirement

PIN_UNAVAILABLE
    il pin esatto non è disponibile/sano/compatibile

RESOLUTION_AMBIGUOUS
    più candidati restano semanticamente equivalenti senza policy sufficiente

RESOLUTION_CONFLICT
    constraint incompatibili nello stesso Execution Environment

RESOLUTION_CYCLE
    dependency closure ciclica

BROKEN_RESOLUTION
    un binding esatto persistito non è più materializzabile/sano
```

Nessuno di questi errori autorizza fallback impliciti al software host.

---

# 23. Invarianti fissate

```text
DM-01 Requirement != Resolved Binding
DM-02 Requirement appartiene alla Package Instance; Selection Policy è separata
DM-03 software version != capability compatibility version != release-order != RumiAI revision
DM-04 non esiste comparatore universale delle software version upstream
DM-05 il capability contract definisce il version scheme confrontabile
DM-06 release-order è assegnato dal packaging e vale soltanto dentro una famiglia provider
DM-07 dependency slot è locale al consumer
DM-08 Capability Requirement non hardcoda provider non semanticamente necessario
DM-09 Package Requirement si usa quando la famiglia/provider è semanticamente necessaria
DM-10 tutte le dependency v0 sono mandatory
DM-11 candidate set = sole Package Instance locali sane e platform-compatible
DM-12 exact pin non fa fallback
DM-13 provider preference può fare fallback soltanto durante resolution
DM-14 latest/newest è Selection Policy, non versione/identity
DM-15 install order/filesystem order non determinano selection
DM-16 ambiguità non risolta => RESOLUTION_AMBIGUOUS
DM-17 ogni Resolved Binding punta a una Package Instance concreta
DM-18 selection dinamica avviene soltanto durante resolution
DM-19 launch non rivaluta requirement/preference/latest
DM-20 provider mancante dopo resolution => BROKEN_RESOLUTION, non fallback implicito
DM-21 resolved graph è persistibile senza pathname assoluti
DM-22 dependency private non diventa automaticamente public binding
DM-23 incompatibilità possono convivere in environment distinti
DM-24 una capability ha una soluzione coerente per Execution Environment salvo isolation model esplicito
DM-25 dependency cycle è errore nel v0
DM-26 resolved graph crea reference esplicite per accounting/GC
DM-27 il resolver locale non acquisisce software e non usa runtime host casuali
```

---

# 24. Confine con Package Interface ed Environment Specification

Il resolver decide **chi soddisfa un dependency slot**.

Non decide da solo come usare il provider.

Dopo la resolution:

```text
slot jdk
    -> exact Java Package Instance
```

la Package Interface del provider rende disponibili risorse tipizzate, per esempio:

```text
command:java
directory:home
directory:bin
```

L'Environment Specification del consumer può quindi dichiarare:

```text
JAVA_HOME = dependency:jdk.directory:home
PATH prepend dependency:jdk.directory:bin
```

Il modello completo prosegue in:

```text
Package Interface
Execution Requirements
Environment Specification
Resolved Environment
Launch Specification
```

formalizzati nel draft di integrazione.