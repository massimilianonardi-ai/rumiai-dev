# RumiAI package manager — Desired / Resolved Integration State schema v0

Data: 2026-08-30

Stato: **design draft — persistence schema v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/package-manager-schema-v0/README.md
```

Questo schema non introduce virtual package. I nomi locali usati da selector e binding appartengono esclusivamente al profilo desiderato/risolto e non sono filesystem object sotto `pkg/`.

---

# 1. Due documenti distinti

Il v0 persiste separatamente:

```text
Desired Integration Profile
Resolution Snapshot
```

Entrambi usano restricted TOML 1.0.

Regola:

```text
Desired = intention + dynamic selection policy
Resolved = exact immutable generation
```

Il launch legge/usa la generation resolved attiva; non riesegue selector dinamici.

---

# 2. Desired Integration Profile top-level

Forma v0:

```toml
schema = 1
profile = "default"
```

Top-level sections:

```text
schema               required
profile              required logical profile id
selectors            optional ordered array-of-table
command-bindings     optional ordered array-of-table
environment           optional ordered array-of-table
```

Il v0 non introduce profile inheritance multipla o merge impliciti fra file.

Policy RumiAI più generali possono essere applicate dal resolver come layer esterno; il Resolution Snapshot preserva la policy effettiva usata.

---

# 3. Selector

Un selector è un oggetto locale del Desired Profile che produce una Package Instance root/provider concreta durante resolution.

Non è una Package Instance e non è materializzato in `pkg/`.

ID:

```text
logical-id = [a-z][a-z0-9-]*
```

Due target v0:

```text
package
capability
```

---

# 4. Package selector

Esempio:

```toml
[[selectors]]
id = "netbeans"
target = "package"
package = "netbeans"
selection = "newest"
```

Optional exact upstream version:

```toml
version = "26"
```

Semantica:

```text
package + no version
    qualsiasi release locale sana della family, poi Selection Policy

package + version
    soltanto quella exact upstream version, poi newest release-order/revision compatibile di quella release family
```

Il v0 non supporta generic range sulla software version upstream.

---

# 5. Capability selector

Esempio:

```toml
[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
constraint = ">=8"
selection = "newest"
provider-order = ["temurin", "microsoft-openjdk"]
allow-other-providers = true
```

Required:

```text
id
 target = capability
capability
constraint
selection
```

`selection` v0:

```text
newest
```

La semantica `newest compatible` segue il resolver già fissato:

```text
highest compatible capability version
→ provider preference
→ highest release-order nella family
→ highest RumiAI revision
```

`release-order` non viene confrontato fra famiglie provider differenti.

---

# 6. Provider preference

Optional:

```toml
provider-order = ["temurin", "microsoft-openjdk"]
allow-other-providers = true
```

`provider-order` è ordinato.

`allow-other-providers = false` significa che soltanto le family elencate sono ammesse dalla policy locale del selector.

`allow-other-providers = true` consente fallback ad altre family compatibili dopo quelle preferite.

Se più family non ordinate restano semanticamente equivalenti:

```text
RESOLUTION_AMBIGUOUS
```

Non viene introdotto un tie-breaker alfabetico/filesystem nascosto.

Quando `provider-order` manca, si usa l'eventuale policy di livello RumiAI; se nessuna policy ordina candidati equivalenti, vale la stessa ambiguità esplicita.

---

# 7. Exact pin

Un selector può usare invece:

```toml
pin = "temurin@21.0.8+9@r1@linux-arm64"
```

Regole v0:

```text
pin deve soddisfare target + constraint del selector
pin deve esistere ed essere HEALTHY
pin non fa fallback
pin rende non operative provider-order/allow-other-providers per quella resolution
```

Per evitare dead configuration, schema v0 rifiuta nello stesso selector:

```text
pin + provider-order
pin + allow-other-providers
```

`selection` può essere omesso quando esiste `pin`.

---

# 8. Public command binding — package resource

Ogni binding possiede un ID locale distinto dal public command name.

Esempio:

```toml
[[command-bindings]]
id = "netbeans-command"
name = "netbeans"
selector = "netbeans"
source = "package"
command = "netbeans"
```

Questo richiede che la Package Instance risolta dal selector esponga:

```text
interface command id = netbeans
```

---

# 9. Public command binding — capability resource

Per provider intercambiabili non si può assumere che tutti usino lo stesso internal command ID.

Si usa la resource key del capability contract:

```toml
[[command-bindings]]
id = "java-command"
name = "java"
selector = "default-java"
source = "capability"
resource-key = "command"
```

Il resolver usa la mapping `interface.provides.resources` del provider exact per ottenere il command resource concreto.

Questo mantiene il Desired Profile indipendente dai nomi interni del provider.

---

# 10. Public command name

Grammatica v0 candidate:

```text
[a-z0-9][a-z0-9._+-]*
```

Non sono ammessi:

```text
/
\
NUL/control characters
```

Il nome riservato:

```text
@platforms
```

non può essere un cross-platform public command binding sotto `bin/`.

Materializzazione Windows-specific di extension/launcher non cambia il public logical name.

---

# 11. Platform namespace derivation

Il namespace fisico del command binding viene derivato dall'Execution Platform della Package Instance root risolta:

```text
cross-platform execution domain
    → RUMIAI_ROOT/bin/<name>

native platform-specific
    → RUMIAI_ROOT/bin/@platforms/<platform>-<architecture>/<name>
```

La directory platform viene creata on demand come già fissato.

---

# 12. Native specialization

Due binding possono avere lo stesso public command name soltanto quando la relazione è esplicita.

Esempio:

```toml
[[command-bindings]]
id = "tool-portable"
name = "tool"
selector = "tool-portable-selector"
source = "package"
command = "tool"

[[command-bindings]]
id = "tool-native"
name = "tool"
selector = "tool-native-selector"
source = "package"
command = "tool"
specializes = "tool-portable"
```

Regole:

```text
specializes punta a binding id dello stesso profile
base deve essere cross-platform
specialization deve essere native e valida per la platform corrente
name deve coincidere
```

Il native namespace precede il cross-platform namespace nel PATH già fissato.

Same-name collision senza relazione esplicita:

```text
PUBLIC_BINDING_CONFLICT
```

---

# 13. Desired public environment operations

Il Desired Integration Profile può pubblicare environment binding con la stessa semantica delle Environment Specification package-level.

Esempio per Java default:

```toml
[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
selector = "default-java"
source = "capability"
resource-key = "home"

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
selector = "default-java"
source = "capability"
resource-key = "bin"
```

Per package resource direct:

```text
source = package
resource-type = file|directory
resource = <interface id>
```

Il Desired Profile non persiste absolute pathname.

---

# 14. Desired Profile example — Java + NetBeans

```toml
schema = 1
profile = "default"

[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
constraint = ">=17"
selection = "newest"
provider-order = ["temurin"]
allow-other-providers = true

[[selectors]]
id = "java8"
target = "capability"
capability = "java-runtime"
constraint = "=8"
selection = "newest"
provider-order = ["temurin"]
allow-other-providers = true

[[selectors]]
id = "netbeans"
target = "package"
package = "netbeans"
selection = "newest"

[[command-bindings]]
id = "java-default-command"
name = "java"
selector = "default-java"
source = "capability"
resource-key = "command"

[[command-bindings]]
id = "java8-command"
name = "java8"
selector = "java8"
source = "capability"
resource-key = "command"

[[command-bindings]]
id = "netbeans-command"
name = "netbeans"
selector = "netbeans"
source = "package"
command = "netbeans"

[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
selector = "default-java"
source = "capability"
resource-key = "home"

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
selector = "default-java"
source = "capability"
resource-key = "bin"
```

NetBeans mantiene comunque la propria private dependency `jdk` definita nel suo `@package`; il selector `default-java` non la sostituisce.

---

# 15. Resolution Snapshot top-level

Resolved document:

```toml
schema = 1
generation = 17
profile = "default"
reason = "explicit-update"
created = "2026-08-30T13:00:00+02:00"
```

`created` è stringa ISO-8601 nel restricted TOML profile, non TOML datetime type.

Top-level arrays:

```text
selectors
command-bindings
environment
graphs
dependencies
```

Tutti i riferimenti che determinano execution sono exact.

---

# 16. Resolved selector

Package selector resolved:

```toml
[[selectors]]
id = "netbeans"
target = "package"
package = "netbeans@26@r1@jvm-any"
```

Capability selector resolved:

```toml
[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
satisfied-version = "21"
package = "temurin@21.0.8+9@r1@linux-arm64"
```

Provenance optional/required-by-schema can preserve:

```text
original constraint
provider-order effettivo
pin
selection reason
```

ma questi campi non vengono usati dal launch per rivalutare il provider.

---

# 17. Resolved dependency graph

Ogni root Package Instance che possiede Execution Requirement ha un graph ID locale alla generation:

```toml
[[graphs]]
id = "netbeans-graph"
root-package = "netbeans@26@r1@jvm-any"
```

Edge flat:

```toml
[[dependencies]]
graph = "netbeans-graph"
consumer = "netbeans@26@r1@jvm-any"
slot = "jdk"
target = "capability"
capability = "java-development-kit"
constraint = ">=17 <22"
provider = "temurin@21.0.8+9@r1@linux-arm64"
satisfied-version = "21"
```

Ogni transitive consumer/provider è exact.

Un dependency edge non contiene `latest` o unresolved fallback.

---

# 18. Resolved command binding

Esempio:

```toml
[[command-bindings]]
id = "netbeans-command"
name = "netbeans"
package = "netbeans@26@r1@jvm-any"
command = "netbeans"
graph = "netbeans-graph"
state = "netbeans@s1"
```

Per command senza dependency/state i relativi campi possono essere assenti.

Il binding resolved contiene il command resource ID concreto del package exact.

Per selector capability il capability resource key è già stata dereferenziata:

```toml
[[command-bindings]]
id = "java-default-command"
name = "java"
package = "temurin@21.0.8+9@r1@linux-arm64"
command = "java"
```

Nessun capability lookup dinamico è necessario al launch.

---

# 19. Resolved environment

Le environment operations persistite sono exact relocatable reference.

Esempio:

```toml
[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
package = "temurin@21.0.8+9@r1@linux-arm64"
resource-type = "directory"
resource = "home"

[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
package = "temurin@21.0.8+9@r1@linux-arm64"
resource-type = "directory"
resource = "bin"
```

Al launch soltanto:

```text
exact package + resource
        ↓ current RUMIAI_ROOT
absolute process pathname
```

---

# 20. State binding derivation

Per una root Package Instance con `[state]`, il resolver/execution-state builder deriva l'exact State Instance ID secondo:

```text
package name
state compatibility version
state scope
current execution platform/architecture se richiesti
```

Poiché nel v0 esiste una sola State Instance per identity, il Desired Profile non necessita di uno state alias/profile selector.

Il resolved command binding persiste l'exact State Instance ID usata.

---

# 21. Provenance

Per audit, un Resolution Snapshot preserva abbastanza desired information da spiegare una scelta.

Candidate fields per resolved selector:

```text
requested-target
requested-package/capability
requested-version/constraint
selection
provider-order effettivo
allow-other-providers
pin
```

La provenance è descrittiva.

Regola:

```text
launch uses exact resolved fields
provenance never triggers selection
```

---

# 22. Active pointer

Fuori dalla immutable generation snapshot esiste un active-generation pointer contenente semanticamente:

```text
17
```

Il pointer non è un selector e non contiene desired state.

La sua sostituzione atomica attiva la generation solo dopo la validazione/materializzazione completa.

---

# 23. Validation order — Desired Profile

```text
1. TOML/schema
2. profile/id grammar
3. selector structural validation
4. selector target/constraint syntax
5. pin/policy mutual exclusion
6. binding references to selector ids
7. public command name validation
8. specialization relation validation
9. environment operation/reference validation
10. build effective Selection Policy
11. resolve root selectors
12. resolve each root dependency closure
13. derive State Instance bindings
14. resolve public package/capability resource keys
15. validate public binding conflicts
16. build candidate Resolution Snapshot
```

---

# 24. Validation order — Resolution Snapshot

```text
1. TOML/schema
2. generation/profile metadata
3. all exact Package Instance presence + health
4. resolved selector consistency
5. dependency graph closure consistency
6. requirement/provider satisfaction consistency
7. state compatibility/presence
8. exact resource reference validity
9. command specialization/binding conflicts
10. Environment/Launch Specification materializability
11. Execution View candidate build
12. immutable generation commit
13. atomic active pointer replace
```

---

# 25. Error classes

Aggiunte al dominio già definito:

```text
PROFILE_SCHEMA_ERROR
SELECTOR_ERROR
PIN_UNAVAILABLE
DEPENDENCY_UNAVAILABLE
RESOLUTION_AMBIGUOUS
RESOLUTION_CONFLICT
RESOLUTION_CYCLE
PUBLIC_BINDING_CONFLICT
BROKEN_RESOLUTION
ROLLBACK_UNAVAILABLE
ACTIVE_GENERATION_ERROR
```

---

# 26. Invarianti Integration State v0

```text
IS-01 selector locale != Package Instance/virtual package
IS-02 Desired Profile può essere dinamico; Resolution Snapshot è exact
IS-03 selector target v0 = package | capability
IS-04 provider preference è ordinata e separata dal Requirement del consumer
IS-05 exact pin non fa fallback
IS-06 same-name public command collision richiede specialization esplicita o fallisce
IS-07 native specialization relation è persistita nel Desired/Resolved Profile
IS-08 public capability binding usa capability resource key, non provider internal id
IS-09 resolved capability binding dereferenzia a exact package + exact resource
IS-10 private package dependency closure non diventa public automaticamente
IS-11 resolved graph non contiene latest/fallback dinamici
IS-12 resolved environment non contiene absolute RUMIAI_ROOT paths
IS-13 State Instance exact viene derivata/persistita, non selezionata tramite virtual alias
IS-14 generation è immutable e monotonic
IS-15 active pointer è l'unico switch atomico della generation attiva
IS-16 provenance spiega ma non influenza il launch
```

---

# 27. Stress cases coperti

Lo schema rappresenta direttamente:

```text
Java 21/default selector
Java 8 public alias command `java8` senza virtual package
NetBeans con JDK private dependency distinta dal Java pubblico
provider preference + fallback during resolution
exact pin
native-over-cross-platform specialization
public JAVA_HOME/PATH
resolved exact dependency closure
State Instance binding
rollback tramite previous immutable generation
```

---

# 28. Prossimo passo

Il prossimo livello architetturale è più circoscritto:

```text
1. fissare platform / execution-domain vocabulary v0
2. fissare capability contract registry v0 almeno per i reference case
3. fissare physical persistence layout di Desired/Resolved state + locking/atomic commit
```

Dopo questi tre punti il package-manager model sarà abbastanza chiuso da poter valutare il primo PoC senza usare il PoC per decidere l'architettura.