# RumiAI package manager — Integration model draft

Data: 2026-08-29

Stato: **design draft — ragionamento successivo a Package Admission v0**

Prerequisito:

```text
drafts/rumiai-os/package-manager-v0/README.md
```

Questo documento evolve il primo modello `Integration Context → Binding → Materialized View` dopo averlo stressato contro i casi storici di `m`, in particolare Java multi-versione, dipendenze private, alias espliciti e shell con ambiente differente.

La conclusione principale è che un solo oggetto `Integration Context` mescolava tre responsabilità differenti.

Il modello viene quindi separato in:

```text
Package Interface
        ↓
Integration Profile (desired + resolved)
        ↓
Execution Environment
        ↓
Execution View / launcher materialization
```

---

# 1. Proprietà storica da preservare

Il package manager storico aveva già la proprietà corretta:

```text
package presente in pkg
    !=
package integrato/attivo
```

`integrate` gestiva almeno:

```text
PATH
environment
command alias
application
library
profile/state defaults
```

Il problema non era l'esistenza di queste capacità, ma il fatto che venissero materializzate principalmente come mutazioni incrementali di stato globale, che `deintegrate` doveva successivamente cercare di sottrarre.

La nuova architettura deve preservare le capacità evitando di usare il filesystem e l'environment globale come unica fonte di verità.

---

# 2. Package Interface

## 2.1 Definizione

La **Package Interface** descrive le risorse che una Package Instance rende disponibili al resto di RumiAI.

La Package Interface appartiene alla Package Instance ed è immutabile con essa.

Non significa che tali risorse siano automaticamente visibili in una shell o in un altro package.

La distinzione fondamentale è:

```text
PACKAGE RESOURCE
    ciò che il package possiede e può offrire

BINDING
    come una risorsa viene resa visibile in uno specifico ambiente
```

## 2.2 Risorse tipizzate

Il v0 di integrazione dovrebbe partire da poche risorse tipizzate.

Candidate iniziali:

```text
command
    entrypoint eseguibile interno alla Package Instance

directory
    directory semanticamente rilevante che altri binding possono referenziare
```

Esempio Java:

```text
Package Interface: java-runtime 21

command:java
    -> bin/java

command:javac
    -> bin/javac

directory:home
    -> .
```

Il package NON deve necessariamente esportare direttamente:

```text
JAVA_HOME=<qualcosa>
```

perché `JAVA_HOME` è un nome dell'environment esterno, non una proprietà intrinseca del package.

Un Integration Profile o un Execution Environment può invece decidere:

```text
JAVA_HOME = java-runtime.directory:home
```

Questa separazione evita che una dipendenza imponga mutazioni globali solo perché possiede una risorsa utile.

## 2.3 Export non implica integrazione

Più Package Instance possono esportare contemporaneamente:

```text
command:java
```

senza conflitto nello store.

Il conflitto può esistere solo quando due risorse vengono candidate allo stesso binding visibile nello stesso namespace di uno specifico profile/environment.

---

# 3. Execution Dependency con slot locale

Una Package Instance può dichiarare Execution Dependency tramite un **dependency slot locale**.

Esempio concettuale:

```text
dependency slot: jvm
requires: java-runtime >=8 <9
```

Il nome `jvm` è locale al package richiedente.

Dopo la resolution:

```text
jvm
    -> java-runtime 8.0.x / <platform concreta>
```

Questo permette ai metadata di integrazione/esecuzione del package di referenziare:

```text
dependency:jvm.command:java
dependency:jvm.directory:home
```

senza hardcodare pathname né una Package Instance specifica prima della resolution.

La sintassi concreta non è ancora definita.

---

# 4. Dipendenze private per default

Una Execution Dependency necessaria a un package NON deve diventare automaticamente visibile nel profilo generale.

Esempio:

```text
legacy-app
└── jvm -> Java 8
```

L'installazione/integration di `legacy-app` non deve automaticamente produrre:

```text
shell globale: java -> Java 8
```

Java 8 è una dipendenza dell'Execution Environment di `legacy-app`.

Per renderla visibile anche all'utente serve una decisione di integrazione esplicita, per esempio:

```text
java8 -> Java 8.command:java
```

Regola candidata:

> **Le dipendenze transitive/private soddisfano l'esecuzione del package che le richiede; non acquisiscono automaticamente visibilità pubblica.**

---

# 5. Integration Profile

## 5.1 Definizione

Un **Integration Profile** descrive ciò che utente o sistema vuole rendere normalmente disponibile in un determinato scope persistente.

Esempi:

```text
default profile
legacy-java8 profile
sviluppo-java17 profile
```

Un Integration Profile non è l'environment concreto di un singolo processo.

È il desired state persistente da cui possono derivare ambienti di esecuzione.

## 5.2 Desired profile e resolved profile

Occorre distinguere due rappresentazioni.

### Desired Integration Profile

Può contenere selector/constraint dinamici:

```text
integrate java-runtime latest
integrate python >=3.12 <3.14
alias java8 -> java-runtime 8 / command:java
```

Descrive l'intenzione persistente.

### Resolved Integration Profile

Contiene esclusivamente Package Instance concrete e binding deterministici:

```text
java
    -> java-runtime 21.0.8 revision 1 / macos-arm64 / command:java

java8
    -> java-runtime 8.0.462 revision 1 / macos-arm64 / command:java
```

Quindi:

```text
Desired Profile
      ↓ resolve
Resolved Profile
```

Questa distinzione è importante per update e rollback.

`latest` può vivere nel desired state, ma non nell'environment realmente eseguito.

---

# 6. Public bindings

Il Resolved Integration Profile contiene i **public bindings** dello scope.

Categorie iniziali candidate:

```text
command binding
environment binding
```

Esempio:

```text
command java
    -> Java 21.command:java

command java8
    -> Java 8.command:java

environment JAVA_HOME
    -> Java 21.directory:home
```

L'ordine di installazione non determina precedence.

Due binding pubblici incompatibili sullo stesso nome sono un errore salvo override/alias esplicito.

---

# 7. Profile derivation

Un profile può opzionalmente derivare da un altro profile.

Esempio:

```text
default
    java -> Java 21
    JAVA_HOME -> Java 21.home
    python -> Python 3.13

legacy-java8 extends default
    override java -> Java 8
    override JAVA_HOME -> Java 8.home
```

Il risultato è deterministico:

```text
legacy-java8:
    java -> Java 8
    JAVA_HOME -> Java 8.home
    python -> Python 3.13
```

Nel v0 non viene ancora richiesta inheritance multipla.

---

# 8. Execution Environment

## 8.1 Definizione

Un **Execution Environment** è l'ambiente completamente risolto con cui viene avviato uno specifico processo/process tree.

Contiene solo riferimenti a Package Instance concrete.

Può derivare da:

```text
Resolved Integration Profile
        +
Package Instance da eseguire
        +
Execution Dependency risolte di quel package
        +
override espliciti dell'invocazione
```

È normalmente effimero.

## 8.2 Package-specific overlay

Esempio:

```text
default profile:
    java -> Java 21
    JAVA_HOME -> Java 21.home

legacy-app:
    dependency:jvm -> Java 8
```

Execution Environment di `legacy-app`:

```text
public/default resources ereditate dove non in conflitto

private runtime binding:
    java -> dependency:jvm.command:java
    JAVA_HOME -> dependency:jvm.directory:home
```

Il processo legacy vede Java 8 senza cambiare il default profile.

## 8.3 Stesso package, processi differenti

Il sistema può quindi avere simultaneamente:

```text
normal shell       -> Java 21
legacy shell       -> Java 8
legacy-app process -> Java 8
modern-app process -> Java 17
```

senza mutare le Package Instance e senza sostituire globalmente una Java con un'altra.

---

# 9. Regola stretta sulle versioni dentro un Execution Environment

La coesistenza nello store non implica che versioni incompatibili della stessa dipendenza possano essere caricate nello stesso processo.

Regola v0 proposta:

> **Per una stessa dependency identity/slot risolta dentro un singolo Execution Environment deve esistere una soluzione coerente unica, salvo che un futuro execution backend dichiari esplicitamente isolamento interno.**

Esempio:

```text
root C
├── A -> requires D >=7 <8
└── B -> requires D >=8 <9
```

Se A e B devono vivere nello stesso Execution Environment/process tree e non esiste una versione D che soddisfa entrambi:

```text
RESOLUTION CONFLICT
```

Il fatto che `D7` e `D8` possano convivere fisicamente nello store non risolve automaticamente un conflitto runtime interno allo stesso ambiente.

Processi/environment distinti possono invece usare versioni differenti senza conflitto.

---

# 10. Environment binding dichiarativo

Il vecchio `m` usava shell code come:

```text
export JAVA_HOME=...
export JAVA_TOOL_OPTIONS=...
```

Il nuovo modello non dovrebbe richiedere shell code arbitrario.

Gli environment binding devono poter essere descritti come dati.

Operazioni candidate minime:

```text
set
set-if-unset
unset
prepend
append
```

Ma queste operazioni non vengono ancora fissate come API definitiva.

Il requisito già fissabile è:

> **Un environment binding deve poter referenziare risorse Package Interface e dependency slot senza `eval`, senza pathname hardcoded e senza eseguire codice arbitrario per ottenere il valore.**

Esempio concettuale:

```text
set JAVA_HOME = dependency:jvm.directory:home
set-if-unset CLASSPATH = "."
```

`PATH` può essere trattato separatamente dal namespace dei command binding; non è necessario modellare ogni comando come semplice concatenazione di directory PATH.

---

# 11. Command binding come Launch Specification

Un command binding non deve essere ridotto semanticamente a:

```text
nome -> pathname eseguibile
```

Per un package con dipendenze private, lanciare il comando può richiedere la costruzione dell'Execution Environment corretto.

Il binding logico è quindi più vicino a una **Launch Specification**:

```text
command name
    -> Package Instance
    -> entrypoint esportato
    -> Execution Environment da costruire
```

Esempio:

```text
pulsar
    -> Pulsar Package Instance
    -> command:pulsar
    -> execution env con Java 17 risolta
```

La materializzazione fisica può poi essere:

```text
symlink diretto       se semanticamente sufficiente
launcher minimale     se serve costruire environment
resolver dinamico     in implementazioni future
```

Il modello logico non dipende da una di queste tecniche.

---

# 12. Execution View / materialization

Il Resolved Integration Profile e l'Execution Environment sono oggetti logici.

Una **Execution View** è una loro possibile materializzazione fisica.

Può includere:

```text
bin namespace
environment representation
application namespace
```

La view NON è la fonte di verità.

Deve poter essere eliminata e rigenerata completamente dal resolved state.

Per un profile persistente può essere utile mantenere una view persistente/cache.

Per un Execution Environment package-specific può essere creata on-demand o non essere materializzata affatto se il launcher può costruire direttamente processo ed environment.

---

# 13. `integrate`

Nel nuovo modello:

```text
integrate
```

significa concettualmente:

```text
modifica Desired Integration Profile
        ↓
resolve package selectors + dependencies
        ↓
produce Resolved Integration Profile
        ↓
validate public binding conflicts
        ↓
rebuild/refresh eventuale Execution View
```

Non modifica la Package Instance.

Non dipende da side effect incrementali non registrati.

---

# 14. `deintegrate`

`deintegrate` significa:

```text
rimuovi selector/binding dal Desired Integration Profile
        ↓
risolvi nuovamente
        ↓
produce nuovo Resolved Integration Profile
        ↓
rigenera eventuale Execution View
```

Non tenta di ricostruire a ritroso le mutazioni precedenti leggendo metadata correnti del package.

La rimozione della Package Instance dallo store è un problema separato.

---

# 15. Installazione, integrazione e garbage collection restano distinti

Il modello separa tre operazioni:

```text
STORE / INSTALL
    Package Instance presente nel rumiai-store

INTEGRATE
    Package Instance selezionata come root/public binding di un profile

EXECUTE
    costruzione di un Execution Environment concreto
```

La rimozione di un root dal profile non implica necessariamente la rimozione fisica delle Package Instance non più utilizzate.

Quelle Package Instance diventano candidate a una futura garbage collection basata sulle reference reali del sistema.

---

# 16. Stato applicativo resta separato

Package Instance, Integration Profile ed Execution Environment NON sono application state.

Lo stato persistente deve rimanere un concetto distinto.

Un Execution Environment potrà in futuro bindare risorse come:

```text
config directory
data directory
home directory
cache directory
```

verso una State Instance/profile specifica.

Ma lo state non deve essere incorporato nella Package Instance né confuso con il desired integration state.

---

# 17. Casi di stress

## 17.1 Java default + Java 8 esplicita

Store:

```text
Java 8
Java 21
```

Desired default profile:

```text
integrate Java latest as default Java
alias java8 -> Java 8.command:java
```

Resolved profile:

```text
java  -> Java 21.command:java
java8 -> Java 8.command:java
JAVA_HOME -> Java 21.directory:home
```

## 17.2 Shell Java 8

```text
legacy-java8 extends default
    override java -> Java 8.command:java
    override JAVA_HOME -> Java 8.directory:home
```

Una shell lanciata con questo profile vede Java 8.

## 17.3 Package legacy con Java 8 privata

```text
legacy-app
    dependency slot jvm -> java-runtime >=8 <9
```

Resolved dependency:

```text
jvm -> Java 8
```

Execution Environment:

```text
java -> dependency:jvm.command:java
JAVA_HOME -> dependency:jvm.directory:home
```

Java 8 NON diventa pubblica nel default profile.

## 17.4 Package modern con Java 17

Parallelamente:

```text
modern-app
    dependency slot jvm -> Java 17
```

Il suo processo vede Java 17 mentre shell normale usa Java 21 e legacy-app Java 8.

## 17.5 Due package esportano `tool`

Store:

```text
A exports command:tool
B exports command:tool
```

Non esiste conflitto finché restano nello store.

Desired profile che integra entrambi implicitamente come `tool`:

```text
CONFLICT
```

Soluzioni esplicite:

```text
tool  -> A.command:tool
btool -> B.command:tool
```

oppure derived profile con override esplicito.

## 17.6 Dipendenza incompatibile nello stesso processo

```text
C
├── A -> D 7.x
└── B -> D 8.x
```

Se C/A/B devono condividere lo stesso Execution Environment e il modello runtime non offre isolamento:

```text
RESOLUTION CONFLICT
```

La presenza di D7 e D8 nello store non basta a rendere il grafo eseguibile.

---

# 18. Invarianti candidate aggiornate

```text
IM-01 Package Instance nello store != package integrato

IM-02 Package Interface descrive risorse, non side effect globali

IM-03 export != binding

IM-04 Execution Dependency è privata per default

IM-05 Desired Integration Profile può contenere selector/constraint

IM-06 Resolved Integration Profile contiene solo Package Instance concrete

IM-07 Execution Environment contiene solo dipendenze concrete e binding risolti

IM-08 version range/latest non esistono nell'Execution Environment

IM-09 install order non determina precedence

IM-10 namespace conflict richiede decisione esplicita

IM-11 package-specific dependency può override il default solo dentro il proprio Execution Environment

IM-12 integrate modifica desired state, non la Package Instance

IM-13 deintegrate ricalcola desired/resolved state, non esegue undo euristico

IM-14 Execution View è derivata e rigenerabile, non fonte di verità

IM-15 command binding può richiedere una Launch Specification, non solo un symlink

IM-16 state applicativo resta separato da store e integration profile

IM-17 versioni differenti possono convivere nello store; la compatibilità nello stesso Execution Environment richiede invece una resolution coerente
```

---

# 19. Conseguenze architetturali

Il modello risultante è:

```text
                 RUMIAI STORE
                     │
             Package Instance
                     │
              Package Interface
                     │
          ┌──────────┴───────────┐
          │                      │
Desired Integration      Execution Dependencies
     Profile                    │
          │                      │
          └────── resolve ───────┘
                     │
          Resolved Integration Profile
                     │
          + package da eseguire
          + private dependencies
                     │
              Execution Environment
                     │
              Launch Specification
                     │
           optional Execution View
                     │
                   process
```

Questa separazione preserva le capacità storiche di `integrate/deintegrate` ma evita che il modello dipenda da una singola mutazione globale di PATH/environment/filesystem.

---

# 20. Questioni da affrontare prima di un PoC

Il modello non decide ancora:

- identità e layout fisico del `rumiai-store`;
- struttura concreta della Package Interface;
- grammatica delle Execution Dependency e dependency slot;
- regole esatte di version comparison/range;
- formato Desired/Resolved Integration Profile;
- semantica completa degli environment binding;
- modello di State Instance;
- atomicità e persistenza dei resolved profile;
- risoluzione di provider alternativi per la stessa capability;
- applicazioni GUI e servizi;
- shared library integration fra Package Instance;
- execution backend isolati/container/VM;
- garbage collection e reference accounting.

Prima di progettare il PoC conviene ancora ragionare su due problemi centrali:

```text
A. dependency model / version resolution
B. package state / execution state
```

perché entrambi influenzano direttamente l'Integration Profile e l'Execution Environment.
