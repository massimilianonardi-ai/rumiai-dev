# RumiAI package manager — Dependency model draft

Data: 2026-08-29

Stato: **design draft — non ancora specifica normativa**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
```

Questo documento esplora il dependency model dopo aver separato:

```text
Package Instance
Package Interface
Integration Profile
Execution Environment
```

L'obiettivo non è ancora definire una grammatica dei range o un solver completo, ma capire **che cosa deve significare una dipendenza**.

---

# 1. Problema

Il modello più semplice sarebbe:

```text
package A depends on package B version >=X <Y
```

Funziona, ma lega il consumer al nome concreto del package/provider.

Esempio Java:

```text
legacy-app depends on temurin >=8 <9
```

Questo rende `legacy-app` inutilmente dipendente dal fatto che Java 8 provenga da Temurin, Oracle, Microsoft o altro.

Ciò che `legacy-app` richiede realmente è:

```text
un runtime Java compatibile con Java 8
```

La dipendenza logica è quindi verso **una capacità di esecuzione**, non necessariamente verso una specifica Package Instance nominata in anticipo.

---

# 2. Execution Capability

Una **Execution Capability** è un contratto nominato che una Package Instance può dichiarare di fornire.

Esempio:

```text
Package Instance:
    temurin 21.0.8+9 / macos-arm64

provides:
    java-runtime version 21
```

Un'altra Package Instance potrebbe fornire lo stesso contratto:

```text
oracle-jdk 21.x / macos-arm64
provides:
    java-runtime version 21
```

Il package consumer può quindi richiedere:

```text
requires:
    java-runtime >=17 <22
```

senza scegliere preventivamente il provider concreto.

La terminologia `Execution Capability` è provvisoria e deve essere distinta dalle capability del Core-AI; se necessario verrà rinominata in `Package Provide`, `Runtime Capability` o altro.

---

# 3. Software version != capability version

Questa separazione risolve anche una difficoltà storica importante: non esiste un unico schema universale affidabile per le versioni software.

Esempi reali possibili:

```text
21.0.8+9
8u462
1.2.3-beta
2026.08
release-42
```

Il package manager non dovrebbe fingere che tutte le upstream version seguano SemVer.

Proposta:

```text
Package Instance software version
    identifica la release concreta del software

Execution Capability version
    identifica il livello di compatibilità del contratto fornito
```

Esempio:

```text
Package Instance:
    temurin
    software version = 21.0.8+9

provides:
    java-runtime = 21
```

Oppure:

```text
Package Instance:
    temurin
    software version = 8u462

provides:
    java-runtime = 8
```

Il consumer normalmente ragiona sul capability version:

```text
java-runtime >=8 <9
```

non sulla sintassi vendor della release concreta.

---

# 4. Version scheme appartiene alla capability

Non viene proposto un comparatore universale di versioni upstream.

Ogni Execution Capability deve avere una semantica di versione sufficientemente definita da permettere al resolver di valutare i constraint di quella capability.

Esempi concettuali:

```text
java-runtime
    compatibility version = feature release intera
    8, 11, 17, 21, ...

python-runtime
    compatibility version = major.minor
    3.11, 3.12, 3.13, ...
```

La forma definitiva del version scheme non è ancora fissata.

Principio candidato:

> **La semantica di compatibilità deve appartenere al contratto richiesto/fornito, non essere inferita genericamente dalla stringa di versione upstream.**

---

# 5. Dependency slot locale

Il consumer assegna un nome locale alla dependency.

Esempio:

```text
legacy-app

requires slot jvm:
    capability = java-runtime
    constraint = >=8 <9
```

Dopo resolution:

```text
slot jvm
    -> temurin 8u462 revision 1 / macos-arm64
    -> provides java-runtime = 8
```

I metadata del package possono quindi referenziare:

```text
dependency:jvm.command:java
dependency:jvm.directory:home
```

senza conoscere il provider concreto prima della resolution.

---

# 6. Package Interface e capability

Una capability deve poter descrivere quali risorse della Package Interface soddisfano il contratto.

Esempio concettuale:

```text
java-runtime = 21

resources:
    command:java
    directory:home
```

Una Package Instance JDK potrebbe fornire anche:

```text
java-compiler = 21

resources:
    command:javac
```

Il dettaglio se `java-runtime` e `java-compiler` debbano essere due capability distinte viene lasciato alla definizione concreta del contratto.

---

# 7. Dependency verso package concreto

Le capability non devono impedire dipendenze verso un package specifico quando l'identità del provider è realmente significativa.

Quindi il modello può prevedere due target:

```text
CAPABILITY REQUIREMENT
    richiede una capacità e lascia scegliere il provider

PACKAGE REQUIREMENT
    richiede esplicitamente una determinata famiglia/package
```

La seconda forma deve essere usata solo quando il consumer ha realmente bisogno di quel provider/package concreto.

---

# 8. Resolution produce Package Instance concrete

Né capability requirement né package requirement restano dinamiche durante l'esecuzione.

Il resolver trasforma:

```text
requirement
    ↓
constraint
    ↓
provider selection
    ↓
Package Instance concreta
```

Il grafo eseguibile contiene solamente identità concrete.

Esempio:

```text
legacy-app / 4.2
└── slot jvm
    └── temurin / 8u462 / revision 1 / macos-arm64 / digest X
```

`latest`, range e preferenze appartengono al desired/resolution state, non all'Execution Environment.

---

# 9. Provider preference separata dal requirement

Se più Package Instance soddisfano lo stesso requirement, la scelta del provider non deve dipendere dall'ordine casuale nel filesystem o di installazione.

Possibili fonti di preferenza future:

```text
system policy
Integration Profile
user preference
package pin esplicito
trust/source policy
```

Esempio:

```text
requires java-runtime >=17 <22

candidates:
    temurin 21
    oracle-jdk 21

policy:
    prefer temurin
```

Il requirement resta indipendente dal provider; la policy determina la scelta concreta.

---

# 10. Resolution scope: per Execution Environment

Il rumiai-store può contenere contemporaneamente versioni/provider incompatibili.

La coerenza deve essere verificata nel **singolo Execution Environment** che deve realmente eseguire un processo.

Esempio:

```text
legacy-app
    -> java-runtime 8

modern-app
    -> java-runtime 17
```

Sono due Launch Specification differenti e possono coesistere senza richiedere una singola Java globale.

Il default Integration Profile può avere contemporaneamente:

```text
legacy-app command
modern-app command
java -> Java 21
```

perché ogni app può costruire il proprio Execution Environment privato quando viene lanciata.

---

# 11. Il profile pubblico non fonde automaticamente tutte le dependency closure

Questo è un punto importante.

Integrare nello stesso profile:

```text
legacy-app
modern-app
```

NON significa costruire un unico environment globale contenente tutte le loro dipendenze private.

Il profile rende pubblici i loro entrypoint/binding.

Al launch:

```text
legacy-app
    -> Execution Environment con Java 8

modern-app
    -> Execution Environment con Java 17
```

Le dipendenze private restano locali alla Launch Specification del package.

Questo riduce drasticamente i conflitti globali.

---

# 12. Coerenza dentro un singolo Execution Environment

Dentro uno stesso Execution Environment, invece, i constraint devono essere compatibili.

Esempio:

```text
root C
├── A requires capability D >=7 <8
└── B requires capability D >=8 <9
```

Se A e B devono essere soddisfatti nello stesso environment e la capability D non prevede isolamento multiplo:

```text
RESOLUTION CONFLICT
```

La disponibilità fisica di D7 e D8 nello store non risolve da sola il conflitto.

---

# 13. Isolation come proprietà futura esplicita

Alcune tecnologie permettono più versioni dello stesso componente nello stesso processo tramite meccanismi propri:

```text
classloader isolati
plugin sandbox
container/process separation
namespace dedicati
```

Il v0 non deve assumere genericamente questa capacità.

Regola conservativa:

```text
una capability identity
    → una soluzione coerente per Execution Environment
```

salvo che un futuro execution backend/contract dichiari esplicitamente un isolation model capace di rappresentarne più istanze.

---

# 14. Process dependency vs in-process dependency — problema aperto

Non tutte le dipendenze hanno la stessa relazione di esecuzione.

Esempi:

```text
A usa ffmpeg come comando esterno
    → ffmpeg può essere lanciato come processo con il proprio environment

app Java usa JVM
    → JVM è il runtime che ospita l'applicazione

binary usa shared library
    → libreria entra nello stesso processo
```

Questi casi possono avere regole differenti di isolamento e conflitto.

Il v0 non introduce ancora categorie normative, ma registra la necessità di non assumere che ogni dependency edge abbia identica semantica.

Il modello futuro potrebbe distinguere, per esempio:

```text
runtime-host
external-command
in-process-resource
```

solo se i casi reali lo rendono necessario.

---

# 15. `latest` non è una versione

`latest` deve essere trattato come una **selection policy** del desired state, non come una Package Instance o una versione concreta.

Esempio:

```text
Desired Profile:
    java-runtime latest

Resolution oggi:
    Temurin 21.0.8+9

Resolution futura:
    Temurin 21.0.9+...
```

Il Resolved Profile e le Launch Specification correnti continuano sempre a referenziare identità esatte.

Un update è una nuova resolution/commit del desired state, non una mutazione invisibile dell'istanza corrente.

---

# 16. Resolved graph come stato persistibile

Per reproducibility, audit, rollback e deintegration, il risultato della resolution deve poter essere registrato.

Concettualmente:

```text
Desired requirement graph
        ↓ resolve
Resolved dependency graph
        ↓
exact Package Instance identities + dependency slot bindings
```

Il resolved graph deve poter essere confrontato con una nuova resolution.

Questo permette in seguito:

```text
upgrade preview
rollback
why-is-this-installed
reference accounting
garbage collection
```

senza reinterpretare retroattivamente i constraint storici.

---

# 17. Dependency roots e garbage

Una Package Instance può essere nello store perché:

```text
è integrata direttamente come root di un profile
è referenziata da un resolved dependency graph
è mantenuta esplicitamente/pinned
è cache non ancora raccolta
```

La rimozione da un profile non equivale alla rimozione fisica immediata.

In futuro il garbage collector potrà rimuovere soltanto istanze non più referenziate da alcuno stato risolto/pin valido.

Il dependency model deve quindi produrre reference esplicite, non affidarsi alla presenza di file sparsi.

---

# 18. Casi Java

## Default Java

Desired profile:

```text
require java-runtime latest
bind command java from selected java-runtime.command:java
```

Resolved:

```text
java-runtime
    -> Temurin 21.0.8+9 / exact Package Instance
```

## Java 8 alias

Desired profile:

```text
require slot java8-runtime:
    java-runtime = 8

bind command java8
    -> java8-runtime.command:java
```

Resolved:

```text
java8-runtime
    -> Temurin 8u462 / exact Package Instance
```

## Legacy app

Package metadata:

```text
requires slot jvm:
    java-runtime = 8
```

Launch resolution:

```text
legacy-app
└── jvm -> exact Java 8 provider
```

Il provider Java non deve diventare pubblico nel default profile.

---

# 19. Invarianti candidate

```text
DM-01 dependency requirement != resolved dependency

DM-02 software version != capability compatibility version

DM-03 non esiste un comparatore universale implicito delle upstream version

DM-04 capability requirement non deve hardcodare il provider quando il provider non è semanticamente necessario

DM-05 provider selection è policy esplicita, non effetto dell'install order

DM-06 dependency slot è locale al package consumer

DM-07 resolved dependency punta sempre a una Package Instance concreta

DM-08 transitive dependency è privata per default

DM-09 Integration Profile pubblico non fonde automaticamente tutte le dependency closure dei comandi integrati

DM-10 la coerenza viene richiesta per ogni Execution Environment concreto

DM-11 versioni incompatibili possono convivere nello store e in execution environment distinti

DM-12 più versioni della stessa capability nello stesso environment richiedono un isolation model esplicito; altrimenti sono conflitto

DM-13 latest è selection policy, non identità/versione

DM-14 resolved graph deve poter essere persistito e confrontato
```

---

# 20. Questioni aperte

Prima di una specifica o PoC restano da decidere:

- nome definitivo di `Execution Capability`;
- come vengono definiti/versionati i capability contract;
- se capability e Package Interface resource siano nello stesso namespace o separati;
- grammatica minima dei constraint;
- provider preference/pinning;
- comportamento quando più provider soddisfano allo stesso modo un requirement;
- dependency cycle;
- optional dependency;
- process dependency vs in-process dependency;
- reference accounting per garbage collection;
- persistenza del resolved graph;
- interazione con State Instance e migrazioni di stato.

Il prossimo problema da ragionare in parallelo è il **modello dello stato persistente**, perché update/rollback di una Package Instance sono semplici solo finché lo stato applicativo rimane correttamente separato dalle versioni del software.
