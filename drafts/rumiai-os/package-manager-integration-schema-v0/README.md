# RumiAI package manager — Desired / Resolved Integration State schema v0

Data: 2026-08-30

Stato: **design decision — persistence schema v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/package-manager-schema-v0/README.md
drafts/rumiai-os/package-manager-capability-contracts-v0/README.md
```

Questo schema non introduce virtual package. Selector e binding sono nomi locali del profilo desiderato/risolto e non oggetti sotto `pkg/`.

---

# 1. Desired vs Resolved

Persistiamo separatamente:

```text
Desired Integration Profile
Resolution Snapshot
```

Entrambi restricted TOML 1.0.

```text
Desired = intention + selection policy
Resolved = exact immutable generation
```

Il launch usa la generation resolved attiva e non riesegue selector dinamici.

---

# 2. Desired Profile top-level

```toml
schema = 1
profile = "default"
```

Sezioni:

```text
selectors
command-bindings
environment
```

`profile` usa logical-id.

---

# 3. Selector package

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

No generic upstream version range v0.

---

# 4. Selector capability

```toml
[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
contract = 1
constraint = ">=17"
selection = "newest"
provider-order = ["temurin"]
allow-other-providers = true
```

Required:

```text
id
target = capability
capability
contract
constraint
selection
```

Matching usa exact capability identity:

```text
capability name + contract version
```

La compatibility version viene selezionata secondo il version scheme del contract.

---

# 5. Selection Policy

`selection` v0:

```text
newest
```

Ranking:

```text
compatible capability version più alta
→ provider-order
→ release-order nella provider family
→ RumiAI revision
```

`allow-other-providers = true` consente candidate family non elencate dopo le preferite.

Se restano provider equivalenti non ordinati:

```text
RESOLUTION_AMBIGUOUS
```

Nessun tie-breaker nascosto.

---

# 6. Exact pin

```toml
pin = "temurin@21.0.8+9@r1@linux-arm64"
```

Pin deve:

```text
esistere
essere HEALTHY
soddisfare target/capability contract/constraint
```

Pin non fa fallback.

Schema v0 rifiuta:

```text
pin + provider-order
pin + allow-other-providers
```

Con pin, `selection` può essere omesso.

---

# 7. Public command binding da package

```toml
[[command-bindings]]
id = "netbeans-command"
name = "netbeans"
selector = "netbeans"
source = "package"
command = "netbeans"
```

Il command ID deve esistere nella Package Interface della Package Instance risolta.

---

# 8. Public command binding da capability

```toml
[[command-bindings]]
id = "java-command"
name = "java"
selector = "default-java"
source = "capability"
resource-key = "command"
```

Il `resource-key` appartiene al capability contract selezionato.

Il resolver dereferenzia:

```text
(capability, contract, resource-key)
→ exact provider Package Interface resource
```

---

# 9. Public command name

Grammatica v0:

```text
[a-z0-9][a-z0-9._+-]*
```

Non ammessi `/`, `\`, NUL/control.

`@platforms` è reserved sotto `bin/`.

---

# 10. Platform namespace

Cross-platform execution domain:

```text
RUMIAI_ROOT/bin/<name>
```

Native package:

```text
RUMIAI_ROOT/bin/@platforms/<native-platform>-<architecture>/<name>
```

Il current native platform namespace precede `bin/` nel PATH.

---

# 11. Native specialization

Same-name binding è consentito soltanto tramite relazione esplicita:

```toml
[[command-bindings]]
id = "tool-portable"
name = "tool"
selector = "portable-tool"
source = "package"
command = "tool"

[[command-bindings]]
id = "tool-native"
name = "tool"
selector = "native-tool"
source = "package"
command = "tool"
specializes = "tool-portable"
```

Regole:

```text
same public name
base cross-platform
specialization native
specializes punta a binding ID esistente
```

Collisione non dichiarata:

```text
PUBLIC_BINDING_CONFLICT
```

---

# 12. Desired public environment

Capability resource:

```toml
[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
selector = "default-java"
source = "capability"
resource-key = "home"
```

Package resource:

```text
selector
source = package
resource-type = file|directory
resource
```

PATH example:

```toml
[[environment]]
name = "PATH"
operation = "prepend"
type = "path-list"
selector = "default-java"
source = "capability"
resource-key = "bin"
```

No absolute RUMIAI_ROOT path.

---

# 13. Desired example — Java + NetBeans

```toml
schema = 1
profile = "default"

[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
contract = 1
constraint = ">=17"
selection = "newest"
provider-order = ["temurin"]
allow-other-providers = true

[[selectors]]
id = "java8"
target = "capability"
capability = "java-runtime"
contract = 1
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
```

NetBeans continua a usare la propria private dependency `jdk` dal suo `@package`; il Java pubblico non la sostituisce.

---

# 14. Resolution Snapshot top-level

```toml
schema = 1
generation = 17
profile = "default"
reason = "explicit-update"
created = "2026-08-30T13:00:00+02:00"
```

`created` è stringa ISO-8601, non TOML datetime type.

Array principali:

```text
selectors
graphs
dependencies
command-bindings
environment
```

---

# 15. Resolved selector package

```toml
[[selectors]]
id = "netbeans"
target = "package"
package = "netbeans@26@r1@jvm-any"
```

---

# 16. Resolved selector capability

```toml
[[selectors]]
id = "default-java"
target = "capability"
capability = "java-runtime"
contract = 1
satisfied-version = "21"
package = "temurin@21.0.8+9@r1@linux-arm64"
```

Resolved state mantiene exact contract version e exact Package Instance.

---

# 17. Resolved dependency graph

```toml
[[graphs]]
id = "netbeans-graph"
root-package = "netbeans@26@r1@jvm-any"

[[dependencies]]
graph = "netbeans-graph"
consumer = "netbeans@26@r1@jvm-any"
slot = "jdk"
target = "capability"
capability = "java-development-kit"
contract = 1
constraint = ">=17 <22"
provider = "temurin@21.0.8+9@r1@linux-arm64"
satisfied-version = "21"
```

Nessun edge contiene latest/fallback dinamico.

---

# 18. Resolved command binding

```toml
[[command-bindings]]
id = "netbeans-command"
name = "netbeans"
package = "netbeans@26@r1@jvm-any"
command = "netbeans"
graph = "netbeans-graph"
state = "netbeans@s1"
```

Campi `graph`/`state` assenti se non necessari.

Capability public binding è già dereferenziato:

```toml
[[command-bindings]]
id = "java-default-command"
name = "java"
package = "temurin@21.0.8+9@r1@linux-arm64"
command = "java"
```

---

# 19. Resolved environment

```toml
[[environment]]
name = "JAVA_HOME"
operation = "set"
type = "path"
package = "temurin@21.0.8+9@r1@linux-arm64"
resource-type = "directory"
resource = "home"
```

Il launch converte exact package/resource nella current absolute RUMIAI_ROOT path.

---

# 20. State binding

Per package con `[state]`, la State Instance exact viene derivata da:

```text
package name
state compatibility version
state scope
current native execution platform/architecture quando richiesto
```

Nel v0 non esistono state alias/profile paralleli.

---

# 21. Provenance

Resolved selector/graph può conservare:

```text
requested target
requested capability/package
contract
constraint/version
selection
provider-order effettivo
allow-other-providers
pin
```

La provenance spiega; non seleziona al launch.

---

# 22. Active generation

Fuori dallo snapshot immutabile esiste un active-generation pointer contenente semanticamente soltanto:

```text
17
```

Lo switch atomico del pointer attiva una generation già completamente validata.

---

# 23. Validation — Desired

```text
1 TOML/schema
2 profile/id grammar
3 selectors structure
4 capability registry contract/constraint validation
5 pin/policy mutual exclusion
6 binding→selector references
7 public command name
8 specialization relations
9 public environment references
10 effective Selection Policy
11 root selector resolution
12 private dependency closure resolution
13 State Instance derivation
14 public capability resource dereference
15 public binding conflicts
16 candidate Resolution Snapshot
```

---

# 24. Validation — Resolved

```text
1 TOML/schema/generation
2 exact Package Instance health
3 selector consistency
4 graph closure
5 capability name+contract+version satisfaction
6 State Instance compatibility
7 resource references
8 public conflicts/specialization
9 Environment/Launch materializability
10 candidate Execution View
11 immutable generation commit
12 atomic active pointer replace
```

---

# 25. Error classes

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

# 26. Invarianti

```text
IS-01 selector locale != virtual/physical package
IS-02 Desired dynamic, Resolved exact
IS-03 selector target = package|capability
IS-04 capability selector identity = name+contract
IS-05 preference separate dal consumer Requirement
IS-06 pin non fa fallback
IS-07 same-name collision richiede specialization
IS-08 capability public binding usa contract resource key
IS-09 resolved binding = exact package+resource
IS-10 private closure non diventa public
IS-11 resolved graph non contiene dynamic selection
IS-12 resolved env non contiene absolute paths
IS-13 State Instance exact derivata/persistita
IS-14 generation immutable monotonic
IS-15 active pointer è switch atomico
IS-16 provenance non influenza launch
```

---

# 27. Next

Resta da fissare il physical persistence/transaction layout di Desired Profile, immutable Resolution Snapshot, active pointer e lock.