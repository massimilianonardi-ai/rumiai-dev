# RumiAI package manager — Execution architecture stress tests

Data: 2026-08-30

Stato: **design validation — no PoC**

Obiettivo: verificare che il modello formalizzato di Package Interface, dependency resolution, Environment Specification, State Instance e Launch Specification rappresenti casi differenti senza reintrodurre global host mutation o resolution dinamica al launch.

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
```

---

# 1. Criteri di successo

Ogni caso deve rispettare:

```text
no host package manager dependency
no random PATH runtime discovery
no absolute path persisted
no shell eval/source requirement
no provider re-resolution at launch
private dependency does not become public automatically
multiple runtime versions can coexist locally
resolved binding remains exact until explicit new resolution
```

---

# 2. Caso A — Java pubblico più Java 8 alias

Local Package Instances:

```text
temurin Java 8
temurin Java 21
```

Entrambe offrono:

```text
java-runtime
```

Desired Integration Profile:

```text
public `java`
    requirement = java-runtime
    selection = newest compatible

public `java8`
    requirement = java-runtime = 8
```

Resolution:

```text
java
    -> exact Java 21 / command:java

java8
    -> exact Java 8 / command:java
```

Expected public view:

```text
bin/@platforms/<current>/java
bin/@platforms/<current>/java8
```

oppure altra materializzazione equivalente compatibile con il modello `bin/@platforms` già fissato.

Success criteria:

```text
`java` e `java8` sono indipendenti
installare una nuova Java 8 non cambia `java8` finché non si re-resolve
Java 8 e Java 21 convivono nello store locale
```

---

# 3. Caso B — NetBeans con JDK privata

Questo è un esempio architetturale; il range mostrato non pretende di descrivere il requirement vendor reale di ogni release di NetBeans.

NetBeans descriptor:

```text
slot jdk:
    requires java-development-kit >=17 <22

environment:
    JAVA_HOME set dependency:jdk.directory:home
    PATH prepend dependency:jdk.directory:bin

command:netbeans
    executable = self:file:netbeans-launcher
```

System/public profile:

```text
java -> Java 17
JAVA_HOME -> Java 17
```

Resolver NetBeans:

```text
jdk -> Java 21 exact Package Instance
```

Materialized NetBeans environment:

```text
JAVA_HOME = Java21/root
PATH:
    Java21/root/bin
    RUMIAI_ROOT/bin/@platforms/<current>
    RUMIAI_ROOT/bin
    inherited allowed PATH tail
```

Expected result:

```text
shell `java`      -> Java 17
NetBeans process  -> Java 21
```

Success criteria:

```text
NetBeans non muta public JAVA_HOME
private JDK non diventa comando pubblico automaticamente
host JAVA_HOME non sostituisce il binding privato
```

---

# 4. Caso C — nuova release JDK disponibile

Initial resolution:

```text
NetBeans.jdk -> temurin release-order 100
```

Successivamente arriva localmente:

```text
temurin same compatibility version
release-order 101
```

Expected:

```text
launch NetBeans
    continua a usare release-order 100
```

Explicit update/re-resolve:

```text
candidate generation
    jdk -> release-order 101
```

solo dopo validation/commit:

```text
active generation = new binding
```

Success criteria:

```text
no silent update
old generation rimane identificabile per rollback secondo retention
```

---

# 5. Caso D — provider preference + fallback

Policy:

```text
prefer:
    temurin
    microsoft-openjdk
    any-compatible
```

Local set iniziale:

```text
Temurin compatible
Microsoft compatible
```

Resolution:

```text
jdk -> Temurin exact
```

Temurin viene poi rimosso/corrotto in modo anomalo.

Expected launch:

```text
BROKEN_RESOLUTION
```

NON:

```text
automatic switch -> Microsoft
```

Explicit repair/re-resolve può produrre:

```text
jdk -> Microsoft exact
```

Success criteria:

```text
fallback only during explicit resolution
execution remains reproducible
```

---

# 6. Caso E — exact pin

Policy:

```text
pin jdk -> temurin@21.0.8+9@r1@linux-arm64
```

Se disponibile e compatibile:

```text
resolved = pinned instance
```

Se assente/corrotta:

```text
PIN_UNAVAILABLE
```

Anche se esiste un'altra Java 21 compatibile.

Success criteria:

```text
pin semantics are strict
no hidden fallback
```

---

# 7. Caso F — Python pubblico 3.13 + app privata 3.12

Public profile:

```text
python -> Python 3.13
```

Python app:

```text
slot python:
    requires python-runtime = 3.12

file:main-script -> root/app.py

command:app
    executable = dependency:python.command:python
    fixed-args = [ self:file:main-script ]
```

Resolved:

```text
python slot -> exact Python 3.12
```

Expected:

```text
shell `python` -> 3.13
app command    -> 3.12
```

No `PYTHONHOME` is added unless the package contract explicitly requires it.

Success criteria:

```text
runtime-host command can be dependency resource
public Python unaffected
```

---

# 8. Caso G — JAR-only application

Package contains:

```text
root/app.jar
```

No artificial shell wrapper is required.

Descriptor:

```text
slot jvm:
    requires java-runtime = 21

file:app-jar -> root/app.jar

command:app
    executable = dependency:jvm.command:java
    fixed-args = [ self:file:app-jar ]

JAVA_HOME
    set dependency:jvm.directory:home
```

Expected Launch Specification resolves:

```text
executable -> exact Java command resource
arg[0]     -> exact self app.jar resource
JAVA_HOME  -> exact Java home resource
```

Absolute paths are generated only at process materialization.

Success criteria:

```text
command resource is more general than executable pathname
no wrapper script required merely for dependency injection
```

---

# 9. Caso H — Pulsar Electron/self-contained

Pulsar is intentionally not modeled as Java software.

Descriptor concept:

```text
requirements:
    none

command:pulsar
    executable = self:file:pulsar-executable
```

Expected:

```text
no JVM slot
no JAVA_HOME
no Java PATH injection
```

Success criteria:

```text
model does not invent dependencies when none are required
self-contained command remains simple
```

---

# 10. Caso I — environment host in conflitto

Host environment:

```text
JAVA_HOME=/host/java
PATH begins with /host/java/bin
```

NetBeans resolved package environment:

```text
JAVA_HOME = dependency:jdk.directory:home
PATH prepend dependency:jdk.directory:bin
```

Expected:

```text
NetBeans JAVA_HOME = exact RumiAI JDK
NetBeans Java path precedes host path
```

Host Java is not a dependency candidate.

Success criteria:

```text
host environment may be inherited as base context
but cannot override managed runtime binding
```

---

# 11. Caso J — ambiguous provider

Requirement:

```text
java-runtime = 21
```

Local candidates:

```text
provider A, compatibility 21
provider B, compatibility 21
```

No provider preference, pin or semantic ranking between families.

Expected:

```text
RESOLUTION_AMBIGUOUS
```

NOT:

```text
first directory wins
latest install wins
lexical package-name tie breaker
```

Success criteria:

```text
ambiguity is explicit
```

---

# 12. Caso K — dependency conflict inside one environment

Graph:

```text
root
├── A requires D >=7 <8
└── B requires D >=8 <9
```

No declared isolation model.

Expected:

```text
RESOLUTION_CONFLICT
```

Even if both D7 and D8 exist locally.

Success criteria:

```text
store coexistence != same-environment coexistence
```

---

# 13. Caso L — dependency cycle

```text
A -> B
B -> C
C -> A
```

Expected v0:

```text
RESOLUTION_CYCLE
```

Success criteria:

```text
no implicit lazy cycle semantics
```

---

# 14. Caso M — State Instance + filesystem routing + env

Package writable islands:

```text
root/etc  -> ../run/etc
root/logs -> ../run/logs
```

Descriptor mappings:

```text
etc  -> conf
logs -> log
```

State Instance:

```text
foo@s2
```

`run/` routing:

```text
run/etc  -> RUMIAI_ROOT/conf/foo@s2/etc
run/logs -> RUMIAI_ROOT/log/foo@s2/logs
```

Environment Specification may additionally contain:

```text
FOO_CONFIG_HOME = state:conf
```

Expected:

```text
filesystem-hardcoded access and env-configurable access converge on the same State Instance
```

Success criteria:

```text
state routing and env references are complementary, not competing models
```

---

# 15. Caso N — broken public binding

Active binding:

```text
java -> exact Package Instance X / command:java
```

X is missing/corrupt.

Expected:

```text
BROKEN_RESOLUTION / INTEGRITY FAILURE
```

The `bin/` launcher does not choose another Java.

Success criteria:

```text
Execution View cannot become an implicit resolver
```

---

# 16. Caso O — rollback

Generation G1:

```text
NetBeans -> JDK A
```

Generation G2 after explicit update:

```text
NetBeans -> JDK B
```

If NetBeans/JDK A and required State Instance are still available:

```text
rollback -> reactivate G1 exact
```

If JDK A no longer exists:

```text
ROLLBACK_UNAVAILABLE
```

NOT:

```text
resolve an equivalent JDK and call it rollback
```

Success criteria:

```text
rollback restores exact prior resolved state
```

---

# 17. Validation result

Il modello passa concettualmente tutti i casi sopra senza richiedere nuove primitive architetturali fondamentali.

Le primitive usate sono soltanto:

```text
Package Interface resources
Execution Capability
Requirement + dependency slot
Selection Policy
Resolved Binding / Graph
Environment Specification
State Instance / state area reference
Launch Template / Launch Specification
Desired/Resolved Integration Profile
Resolution Snapshot generation
```

Non emerge la necessità di:

```text
env/ autorevole fisica
runtime discovery dal PATH
shell code nel descriptor
automatic provider fallback al launch
package-specific global environment mutation
```

---

# 18. Questioni non validate da questo documento

Questi stress test sono architetturali, non Physical Platform Validation.

Restano separati:

```text
comportamento reale di specifiche release vendor
Windows link/process semantics
macOS app bundle peculiarities
concrete Java/NetBeans/Python vendor packaging
serializzazione @package
launcher implementation
performance del resolver
```

Questi non riaprono automaticamente il modello: diventano input per specifica tecnica, Physical Platform Validation o future estensioni se emerge un requisito reale.