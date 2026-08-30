# RumiAI package manager — Dependency and resolution model v0

Data: 2026-08-30

Stato: **design decision — resolver v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
drafts/rumiai-os/package-manager-capability-contracts-v0/README.md
```

Il resolver è locale: vede soltanto Package Instance sane già presenti sotto `RUMIAI_ROOT/pkg/`.

Non acquisisce software, non consulta host package manager e non usa runtime casuali trovati nel PATH.

---

# 1. Oggetti fondamentali

```text
Requirement
    cosa serve

Selection Policy
    come scegliere fra candidate valide

Resolved Binding
    exact provider scelto per uno slot

Resolved Dependency Graph
    closure esatta persistibile
```

Regola:

```text
Requirement != Resolved Binding
```

Selection dinamica soltanto durante resolution; execution usa exact binding.

---

# 2. Package platform non è runtime requirement

Package Instance platform/architecture descrive esclusivamente il contenuto della Package Instance.

Esempio:

```text
netbeans@26@r1@any-any
```

può richiedere:

```text
java-development-kit contract 1 >=17 <22
```

Su Linux ARM64 il provider può essere `temurin@...@linux-arm64`; su macOS ARM64 `temurin@...@macos-arm64`.

`jvm`, `jdk`, `jre`, `python` non sono platform token.

---

# 3. Execution Capability

Una Execution Capability è un contratto nominato del package manager, distinto dalle capability Core-AI.

Identity:

```text
capability name + contract version
```

Esempi v0:

```text
java-runtime contract 1
java-development-kit contract 1
python-runtime contract 1
```

Il contract definisce:

```text
compatibility version scheme
required/optional resource keys
resource type per key
semantica
```

---

# 4. Software version vs capability version vs contract

Separati:

```text
software version
    upstream release identity opaca

capability contract version
    versione della semantica RumiAI del contratto

capability compatibility version
    livello di compatibilità fornito/richiesto
```

Esempio:

```text
Temurin software version = 21.0.8+9
provides java-runtime contract 1 version 21
```

Non esiste comparatore universale delle software version upstream.

---

# 5. `release-order`

Metadata immutabile family-local:

```text
release-order = positive integer
```

Ordina release della stessa logical package/provider family senza interpretare stringhe upstream.

Esempio:

```text
Temurin 8u452 -> 381
Temurin 8u462 -> 382
```

Non viene confrontato semanticamente fra provider family differenti.

A parità di release-order può prevalere la RumiAI revision più alta quando la policy richiede newest packaging revision.

---

# 6. Dependency slot

Ogni Requirement ha un nome locale al consumer:

```text
slot jdk
slot python
slot engine
```

Dopo resolution:

```text
netbeans@26@r1@any-any
└── jdk -> temurin@21.0.8+9@r1@linux-arm64
```

Environment/Launch Template possono referenziare risorse tramite lo slot senza conoscere il provider prima della resolution.

---

# 7. Requirement v0

Due target.

Capability Requirement:

```text
slot jdk:
    target = capability
    capability = java-development-kit
    contract = 1
    constraint = >=17 <22
```

Package Requirement, solo se l'identità family/provider è realmente significativa:

```text
slot engine:
    target = package
    package = specific-engine
```

Tutti i Requirement v0 sono mandatory.

Un Requirement non risolvibile produce:

```text
DEPENDENCY_UNAVAILABLE
```

---

# 8. Constraint grammar v0

Solo intersezione di comparator sul version scheme della capability:

```text
=
>
>=
<
<=
```

Esempi:

```text
=8
>=17 <22
>=3.11 <3.14
```

Non v0:

```text
OR
!=
wildcard
caret
tilde
constraint generico sulla software version upstream
```

---

# 9. Candidate set

Per un Requirement il resolver considera solo Package Instance locali che:

```text
sono HEALTHY
sono utilizzabili sul current native host secondo la propria platform/architecture identity
soddisfano target package/capability
soddisfano exact capability contract
soddisfano capability compatibility constraint
```

Una Package Instance consumer `any-any` non obbliga il provider a essere `any-any`; il provider può essere native.

Non sono candidate:

```text
software solo remoto
host runtime in PATH
apt/dnf/brew/Chocolatey/MSI package
package corrotti
platform-incompatible Package Instance
```

---

# 10. Selection Policy

Separata dal consumer Requirement.

Precedence v0:

```text
1 exact pin esplicito
2 Desired Integration Profile override/preference
3 RumiAI environment policy
4 nessuna preference
```

Il consumer generic capability requirement non impone vendor preference.

Se richiede davvero una family specifica usa Package Requirement.

---

# 11. Exact pin

```text
pin jdk -> temurin@21.0.8+9@r1@linux-arm64
```

Deve esistere, essere HEALTHY e soddisfare il Requirement.

Altrimenti:

```text
PIN_UNAVAILABLE
```

Pin non fa fallback.

---

# 12. Provider preference / fallback

Esempio:

```text
provider-order:
    temurin
    microsoft-openjdk
    any-compatible
```

Fallback viene applicato soltanto durante una nuova explicit resolution.

Dopo il commit il launch usa exact provider.

---

# 13. `newest`

`newest/latest` è Selection Policy, non version/identity.

Ranking v0:

```text
1 requirement-compatible candidates
2 exact pin se presente
3 provider preference
4 highest compatible capability version secondo contract
5 highest release-order nella chosen provider family
6 highest RumiAI revision a parità di release-order
```

Se restano provider equivalenti senza criterio semantico:

```text
RESOLUTION_AMBIGUOUS
```

Nessun install-order/filesystem-order tie breaker.

---

# 14. Resolved Binding

Associa:

```text
consumer exact Package Instance
+ slot
+ Requirement
→ exact provider Package Instance
```

Esempio:

```text
consumer  netbeans@26@r1@any-any
slot      jdk
requires  java-development-kit contract 1 >=17 <22
resolved  temurin@21.0.8+9@r1@linux-arm64
satisfies java-development-kit contract 1 version 21
```

Da quel momento `jdk` significa quella exact Package Instance.

---

# 15. Dynamic during resolution, static during execution

```text
dynamic selection  only resolution
exact binding       execution
```

Se il provider exact scompare/corrompe dopo il commit:

```text
BROKEN_RESOLUTION
```

Non automatic fallback a provider alternativo, host JAVA_HOME, PATH runtime o newest.

Repair/re-resolve è un'altra explicit transaction/generation.

---

# 16. Eventi di nuova resolution

Solo operazioni esplicite:

```text
first integration
explicit update
explicit re-resolve
Desired Profile / Selection Policy change
new root Package Instance selection
repair
```

Non:

```text
every launch
reboot
new candidate merely appearing in pkg/
```

---

# 17. Resolved Dependency Graph

Contiene exact Package Instance identity per tutti gli edge.

Serve per:

```text
launch
rollback
upgrade preview
why-installed
reference accounting
garbage collection
```

Non contiene `latest`, fallback o selector dinamici.

---

# 18. Dependency privacy

Transitive/private dependencies soddisfano il consumer ma non diventano public binding automaticamente.

Esempio:

```text
public shell java -> Java 21 A
NetBeans private jdk -> Java 21 B
legacy app private jvm -> Java 8
```

Possono convivere se usati in Execution Environment distinti.

---

# 19. Resolution scope e conflicts

Store coexistence != same-environment coexistence.

Se una singola Execution Environment richiede incompatibilmente la stessa capability e non esiste isolation model esplicito:

```text
RESOLUTION_CONFLICT
```

Più versioni possono invece convivere in environment/processi distinti.

---

# 20. Cycles

Dependency cycle nel v0:

```text
RESOLUTION_CYCLE
```

Nessuna lazy/implicit cycle semantics.

---

# 21. Optional dependencies

Non supportate nel v0.

Il package non cambia feature automaticamente in base a ciò che capita localmente nello store.

---

# 22. Physical platform interaction

Resolver selection usa l'identity Package Instance già ammessa e il current native host target.

La reale validità delle facility host resta coperta dalla Physical Platform Validation.

`any-any` consumer + native runtime provider è un caso normale, non una special case.

---

# 23. Invarianti

```text
DM-01 Requirement != Resolved Binding
DM-02 package platform/architecture != runtime requirement
DM-03 Java/JDK/JRE/Python sono capability requirements, non platform token
DM-04 software version != capability contract != compatibility version
DM-05 no universal upstream version comparator
DM-06 release-order is family-local
DM-07 dependency slot local to consumer
DM-08 resolved dependency always exact Package Instance
DM-09 provider preference separate from Requirement
DM-10 pin strict, no fallback
DM-11 newest is selection policy
DM-12 ambiguous provider selection fails explicitly
DM-13 dependencies private by default
DM-14 new package arrival does not mutate active generation
DM-15 execution does not re-resolve
DM-16 broken exact provider => BROKEN_RESOLUTION
DM-17 store coexistence != same-environment compatibility
DM-18 cycles rejected v0
DM-19 optional dependencies absent v0
DM-20 Resolved Dependency Graph persistible and authoritative for exact closure
```
