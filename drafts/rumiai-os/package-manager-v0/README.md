# RumiAI package manager — Package Admission v0

Data: 2026-08-30

Stato corrente: **Superseded as current design by `decisions/rumiai-os/2026-09-05-package-manager-current-and-run-model.md`**  
Stato storico al 2026-08-30: **design decision — admission model v0 fissato**

> **Nota di supersession:** il contenuto seguente è conservato come lineage/input storico. Non deve essere usato come autorità sul design corrente di `pkg` salvo per i principi esplicitamente riaffermati da una decisione Accepted successiva. In particolare root immutabile obbligatoria, State Instance universali, capability resolver, Desired/Resolved Integration State, pathname Package Instance e criterio `REJECTED` qui descritti non appartengono più automaticamente alla baseline corrente.

Questo documento formalizzava il confine del package manager RumiAI OS al 2026-08-30.

Acquisizione, download, toolchain e build erano fuori scope nel design qui conservato. Il package manager locale cominciava quando esisteva già un candidate software tree prodotto/normalizzato.

---

# 1. Confine

```text
software già prodotto
        ↓
normalizzazione pre-admission
        ↓
Physical Platform Validation
        ↓
Package Instance RumiAI
        ↓
local pkg/ + integration + execution + removal
```

Fuori da questo confine:

```text
remote catalog/store discovery
download
source acquisition
build/toolchain
vendor installer execution
host package manager installation
```

---

# 2. RumiAI Execution Closure

L'esecuzione di una Package Instance dipende da:

```text
1. contenuto proprio della Package Instance
2. altre Package Instance dichiarate come Execution Requirements e risolte esattamente
3. facility native già presenti nella Reference Installation host
```

I primi due domini sono modellati da RumiAI.

Le facility native host non sono enumerate come dependency graph nodes: vengono coperte dalla Physical Platform Validation.

---

# 3. Package platform/architecture

Package Instance identity contiene:

```text
platform
architecture
```

Vocabolario v0:

```text
platform:
    any
    linux
    macos
    windows

architecture:
    any
    arm64
    x86_64
```

Principio:

> `platform` e `architecture` descrivono esclusivamente i vincoli propri del contenuto della Package Instance.

Non sono platform:

```text
jvm
jre
jdk
java
python
```

Runtime/interprete/SDK necessari sono Execution Requirements.

---

# 4. `any-any`

Contenuto realmente indipendente da OS e CPU usa:

```text
platform = any
architecture = any
```

Esempio:

```text
netbeans@26@r1@any-any
```

se il tree normalizzato NetBeans non contiene vincoli nativi propri.

La necessità del JDK viene rappresentata separatamente:

```text
requires java-development-kit
```

Su Linux ARM64 il resolver può usare un provider `linux-arm64`; su macOS ARM64 un provider `macos-arm64`, mantenendo identica la Package Instance consumer `any-any`.

`any` è ammesso solo dopo Physical Platform Validation appropriata; non è dedotto automaticamente dal formato `.jar`, `.py`, ecc.

---

# 5. Native content + runtime requirement

Una Package Instance può essere native e contemporaneamente richiedere un runtime.

Esempio:

```text
root/app.jar
root/native/libfoo.so
```

con `libfoo.so` obbligatoria Linux ARM64:

```text
Package Instance:
    linux-arm64

Requirement:
    java-runtime contract 1 >=17 <22
```

Il vincolo native appartiene al contenuto; Java appartiene alle dependency.

Lo stesso vale per Python con native extension obbligatorie.

---

# 6. Package Instance

Una **Package Instance** è una rappresentazione concreta, immutabile, già eseguibile e fisicamente validata di una specifica software version + RumiAI revision per un exact package platform/architecture identity.

Non è:

```text
source tree
build procedure
download procedure
upstream archive non qualificato
runtime state
Integration Profile
version selector
```

Identity filesystem:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Identity descriptor minima:

```text
name
version
revision
platform
architecture
display-name
```

Path identity e descriptor identity devono concordare.

---

# 7. Immutability and relocatability

Dopo admission:

```text
root/
run-default/
@package
```

sono immutabili per contratto e verificabili.

Qualunque semantic packaging change produce una nuova RumiAI `revision`.

La Package Instance deve essere relocatable rispetto a `RUMIAI_ROOT`; non può richiedere un absolute install prefix vendor globale.

---

# 8. Root fissa e writable islands

Software che modifica il proprio installation tree deve essere normalizzato prima dell'admission.

Le aree mutabili vengono separate preferibilmente come directory e sostituite con safe relative symlink:

```text
root/log -> ../run/log
root/etc -> ../run/etc
```

Se non è possibile produrre una `root/` che resti immutabile durante la normale esecuzione:

```text
REJECTED
```

Il package manager locale non tenta workaround dinamici.

---

# 9. Mutable state separation

Stato reale vive fuori dal core immutabile nelle State Instance areas:

```text
conf
data
home
cache
log
run
tmp
```

`run-default/` contiene factory defaults immutabili delle writable islands.

`run/` package-local è una routing view derivata verso la State Instance attiva.

---

# 10. No mandatory host mutation

Materializzazione, integrazione, execution e removal ordinari non devono richiedere:

```text
root/sudo/Administrator
apt/dnf/brew/Chocolatey/MSI
mandatory global vendor installer
mandatory global PATH mutation
mandatory system-wide runtime installation
```

Le dipendenze versionate/gestite da RumiAI devono essere Package Instance RumiAI.

---

# 11. Offline-ready

Una Package Instance deve poter essere eseguita offline quando tutte le sue resolved RumiAI dependencies sono già locali.

Il first run non può essere usato per:

```text
scaricare runtime obbligatori
completare installation
recuperare librerie necessarie all'avvio
```

Network use come funzione normale dell'applicazione resta naturalmente possibile.

---

# 12. Execution Requirement

Un Execution Requirement descrive software RumiAI necessario all'esecuzione.

Forma preferita: capability requirement.

Esempi:

```text
java-runtime contract 1 =21
java-development-kit contract 1 >=17 <22
python-runtime contract 1 =3.12
```

Il consumer non hardcoda il provider quando il provider non è semanticamente necessario.

Requirement:

```text
!= resolved dependency
```

La resolution produce sempre exact Package Instance bindings prima del launch.

---

# 13. Execution Capability

Capability v0 iniziali:

```text
java-runtime contract 1
java-development-kit contract 1
python-runtime contract 1
```

Il contract definisce:

```text
compatibility version scheme
required/optional resource keys
resource types
contract semantics
```

Esempio provider native:

```text
temurin@21.0.8+9@r1@linux-arm64
    provides java-runtime contract 1 version 21
    provides java-development-kit contract 1 version 21
```

---

# 14. Dependency privacy

Execution dependencies sono private per default.

Esempio:

```text
netbeans@26@r1@any-any
└── private slot jdk -> exact Temurin linux-arm64
```

Integrare NetBeans non rende automaticamente quel JDK il `java` pubblico.

Public binding richiede una decisione esplicita del Desired Integration Profile.

---

# 15. Physical Platform Validation

Il v0 non definisce una Platform Baseline teorica universale.

Admission si basa su test fisici sulle Reference Installation previste.

La validazione copre almeno ciò che il package realmente usa:

```text
host facilities
filesystem semantics
permission/ownership
symlink/link behavior
process behavior
runtime dependency interaction
```

Un PASS su una Reference Installation non equivale a una promessa universale per ogni distro/versione dello stesso OS.

---

# 16. `any` Physical Validation

`any-any` significa che il packaging RumiAI ha validato che il contenuto non introduce un vincolo OS/CPU proprio per il set di Reference Installation dichiarato/supportato.

Non significa:

```text
teoricamente eseguibile ovunque per sempre
```

Se emerge un native requirement obbligatorio, la Package Instance deve essere classificata con platform/architecture appropriati.

---

# 17. Side-by-side coexistence

Più versioni/provider possono convivere in `pkg/`:

```text
Java 8
Java 17
Java 21
Python 3.12
Python 3.13
```

La coesistenza fisica non implica coesistenza nello stesso Execution Environment.

Il resolver costruisce closure exact per ogni root/command.

---

# 18. Integration external to Package Instance

Package presence != integration.

```text
pkg/
    physical truth delle Package Instance

Desired/Resolved Integration State
    cosa è attivo/pubblico e con quali dependency

bin/
    derived command view
```

Install order non determina precedence.

---

# 19. Removal

Uninstall fisico rimuove l'unica wrapper:

```text
pkg/<package-instance-id>/
```

dopo reference/integration constraints.

Non usa vendor uninstaller e non cerca file sparsi nel sistema.

Uninstall non implica `purge-state`.

---

# 20. Admission requirements v0

```text
PA-01 platform/architecture determinabili dal contenuto
PA-02 Physical Platform Validation completata
PA-03 nessuna dependency obbligatoria da host package manager
PA-04 Execution Requirements espliciti
PA-05 nessuna mandatory global host installation
PA-06 nessun ordinary admin privilege
PA-07 relocatable
PA-08 core Package Instance immutabile
PA-09 mutable state separabile
PA-10 nessun first-run installation
PA-11 offline-ready con dependency locali
PA-12 nessun self-update della Package Instance
PA-13 side-by-side coexistence
PA-14 integration esterna alla Package Instance
PA-15 local removal
PA-16 content inventory/verifiability
PA-17 platform/architecture non codificano runtime/interprete/SDK requirements
PA-18 `any` richiede physical evidence; non è inferito dal file format
```

---

# 21. Esempi corretti

Java/JDK provider:

```text
temurin@21.0.8+9@r1@linux-arm64
```

NetBeans portable-content consumer:

```text
netbeans@26@r1@any-any
    requires java-development-kit
```

Python app portable-content consumer:

```text
my-python-app@1.0@r1@any-any
    requires python-runtime
```

Pulsar:

```text
app Electron/self-contained
nessuna dependency Java artificiale
platform/architecture determinate dall'artifact concreto
```

---

# 22. Invarianti storici

```text
AD-01 acquisition/build restano fuori dal local package manager boundary
AD-02 Package Instance content + RumiAI dependencies + host facilities = execution closure
AD-03 platform/architecture descrivono content constraints
AD-04 Java/JDK/JRE/Python sono requirements/capability, non platform
AD-05 any-any è ammesso per content realmente OS/CPU-independent fisicamente validato
AD-06 native content obbligatorio rende la Package Instance platform-specific
AD-07 root deve essere immutable durante normale execution
AD-08 mutable state vive fuori dal core Package Instance
AD-09 requirements sono espliciti e resolved in exact Package Instance
AD-10 host package manager/global runtime non sono fallback
AD-11 dependency private by default
AD-12 no first-run mandatory acquisition
AD-13 Package Instance presence != integration
AD-14 uninstall != purge-state
```

Questi identificatori sono conservati esclusivamente come riferimento al design storico del 2026-08-30; non costituiscono l'elenco degli invarianti correnti di `pkg`.
