# RumiAI package manager — Execution architecture stress tests

Data: 2026-08-30

Stato: **design validation — no PoC**

Obiettivo: verificare che Package Interface, dependency resolution, Environment Specification, State Instance e Launch Specification rappresentino casi differenti senza reintrodurre global host mutation o resolution dinamica al launch.

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
```

Regola platform usata da tutti i casi:

> Package `platform`/`architecture` descrivono soltanto i vincoli propri del contenuto. Java/JDK/JRE/Python e altri runtime esterni sono requirements/capability.

---

# 1. Criteri di successo

```text
no host package manager dependency
no random PATH runtime discovery
no absolute path persisted
no shell eval/source requirement
no provider re-resolution at launch
private dependency does not become public automatically
multiple runtime versions can coexist locally
resolved binding remains exact until explicit new resolution
portable content can remain any-any while using native runtime providers
```

---

# 2. Caso A — Java pubblico più Java 8 alias logico

Local Package Instances native:

```text
temurin Java 8
temurin Java 21
```

Entrambe offrono `java-runtime contract 1`.

Desired Integration Profile:

```text
public java
    requirement = java-runtime
    selection = newest compatible

public java8
    requirement = java-runtime = 8
```

Resolution:

```text
java  -> exact Java 21 / command:java
java8 -> exact Java 8 / command:java
```

Expected public view su un host native:

```text
bin/@platforms/<current>/java
bin/@platforms/<current>/java8
```

Success:

```text
java e java8 indipendenti
nuova Java 8 non cambia binding finché non si re-resolve
Java 8 e Java 21 convivono localmente
```

`java8` resta selector/binding logico, non virtual Package Instance.

---

# 3. Caso B — NetBeans `any-any` con JDK privata

Esempio architetturale; il range non pretende di descrivere ogni release vendor reale.

Package Instance consumer:

```text
netbeans@26@r1@any-any
```

Descriptor:

```text
slot jdk:
    requires java-development-kit contract 1 >=17 <22

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

Resolver su Linux ARM64:

```text
jdk -> exact Temurin linux-arm64 / Java 21
```

Resolver su macOS ARM64 può scegliere:

```text
jdk -> exact Temurin macos-arm64 / Java 21
```

Materialized environment:

```text
JAVA_HOME = private JDK/root
PATH:
    private JDK/root/bin
    RUMIAI_ROOT/bin/@platforms/<current>
    RUMIAI_ROOT/bin
    inherited allowed PATH tail
```

Expected:

```text
shell java      -> public Java 17
NetBeans process -> private Java 21
```

Success:

```text
NetBeans identity resta any-any
runtime native provider varia per host
NetBeans non muta public JAVA_HOME
private JDK non diventa public automaticamente
host JAVA_HOME non sostituisce il binding privato
```

---

# 4. Caso C — nuova release JDK disponibile

Initial:

```text
NetBeans.jdk -> Temurin release-order 100
```

Arriva release-order 101.

Expected launch:

```text
continua a usare 100
```

Solo explicit update/re-resolve può produrre e attivare una generation con 101.

PASS: no silent update; old generation resta rollback-identifiable secondo retention.

---

# 5. Caso D — provider preference + fallback

Policy:

```text
Temurin
Microsoft OpenJDK
any-compatible
```

Resolution iniziale:

```text
jdk -> exact Temurin
```

Se Temurin scompare/corrompe:

```text
BROKEN_RESOLUTION
```

non automatic Microsoft fallback al launch.

Explicit repair/re-resolve può produrre Microsoft exact.

PASS.

---

# 6. Caso E — exact pin

```text
pin jdk -> temurin@21.0.8+9@r1@linux-arm64
```

Se assente/corrotto:

```text
PIN_UNAVAILABLE
```

anche se esiste un'altra Java compatibile.

PASS.

---

# 7. Caso F — Python pubblico 3.13 + app `any-any` privata 3.12

Public profile:

```text
python -> Python 3.13 native provider
```

Python app content, se privo di native extension proprie:

```text
example-app@...@any-any
```

Requirement:

```text
slot python:
    requires python-runtime contract 1 =3.12
```

Command:

```text
executable = dependency:python.command:python
arg = self:file:main-script
```

Resolved:

```text
python slot -> exact Python 3.12 native provider for current host
```

Expected:

```text
shell python -> 3.13
app command  -> 3.12
```

Se l'app contiene native extension obbligatorie, la Package Instance deve invece esporre il relativo platform/architecture nativo.

PASS.

---

# 8. Caso G — JAR-only `any-any` application

Package:

```text
java-app@...@any-any
root/app.jar
```

Descriptor:

```text
slot jvm:
    requires java-runtime contract 1 =21

file:app-jar -> root/app.jar

command:app
    executable = dependency:jvm.command:java
    fixed-args = [ self:file:app-jar ]

JAVA_HOME
    set dependency:jvm.directory:home
```

Expected:

```text
executable -> exact native Java provider command
arg        -> exact self app.jar
JAVA_HOME  -> exact Java home
```

Absolute path solo a materialization.

PASS: Java requirement non trasforma `platform` in `jvm`.

---

# 9. Caso H — Java + native content

Package contiene:

```text
root/app.jar
root/native/libfoo.so
```

Se `libfoo.so` è obbligatoria Linux ARM64:

```text
Package Instance = linux-arm64
Requirement      = java-runtime
```

PASS: native content constraint e runtime requirement restano ortogonali.

---

# 10. Caso I — Pulsar Electron/self-contained

Pulsar non è modellato come Java software.

```text
requirements: none per Java
command:pulsar -> self executable
```

La Package Instance platform/architecture deriva esclusivamente dall'artifact Electron concreto.

PASS.

---

# 11. Caso J — environment host in conflitto

Host:

```text
JAVA_HOME=/host/java
PATH starts /host/java/bin
```

NetBeans:

```text
JAVA_HOME = private jdk home
PATH prepend private jdk bin
```

Expected: exact RumiAI JDK vince; host Java non è candidate.

PASS.

---

# 12. Caso K — ambiguous provider

Requirement:

```text
java-runtime contract 1 =21
```

Due provider equivalenti senza policy.

Expected:

```text
RESOLUTION_AMBIGUOUS
```

Nessun filesystem/install-order tie breaker.

PASS.

---

# 13. Caso L — dependency conflict

```text
root
├── A requires D >=7 <8
└── B requires D >=8 <9
```

No isolation model:

```text
RESOLUTION_CONFLICT
```

PASS.

---

# 14. Caso M — dependency cycle

```text
A -> B -> C -> A
```

Expected:

```text
RESOLUTION_CYCLE
```

PASS.

---

# 15. Caso N — State Instance + filesystem routing + env

```text
root/etc  -> ../run/etc
root/logs -> ../run/logs
```

Mappings:

```text
etc -> conf
logs -> log
```

State:

```text
foo@s2
```

Environment può anche referenziare `state:conf`.

PASS: hardcoded filesystem access ed env-configurable access convergono sulla stessa State Instance.

---

# 16. Caso O — broken public binding

Active exact Package Instance X mancante/corrotta:

```text
BROKEN_RESOLUTION / INTEGRITY FAILURE
```

Execution View non diventa resolver.

PASS.

---

# 17. Caso P — rollback

G1:

```text
NetBeans any-any -> JDK A exact
```

G2:

```text
NetBeans any-any -> JDK B exact
```

Rollback riattiva G1 solo se exact Package Instance e State Instance richieste sono ancora disponibili.

Altrimenti:

```text
ROLLBACK_UNAVAILABLE
```

PASS.

---

# 18. Validation result

Il modello passa tutti i casi senza nuova primitiva fondamentale.

Primitive:

```text
Package Interface resources
Execution Capability contract/version
Requirement + dependency slot
Selection Policy
Resolved Binding / Graph
Environment Specification
State Instance / state area reference
Launch Template / Launch Specification
Desired/Resolved Integration Profile
Resolution Snapshot generation
Package platform/architecture orthogonal to runtime requirements
```

Non serve:

```text
jvm/python execution-domain platform
env/ autorevole fisica
runtime discovery dal PATH
shell code nel descriptor
automatic provider fallback al launch
package-specific global environment mutation
```

---

# 19. Boundary

Questi sono stress test architetturali, non Physical Platform Validation.

Restano separati:

```text
comportamento reale di specifiche release vendor
Windows link/process semantics
macOS app bundle peculiarities
concrete Java/NetBeans/Python vendor packaging
launcher implementation
performance del resolver/parser
```
