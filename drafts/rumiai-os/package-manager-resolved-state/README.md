# RumiAI package manager — Resolved state / lock model

Data: 2026-08-30

Stato: **design decision — resolved state + SCF v0 fissati**

Il resolved state è la barriera fra:

```text
desired / dynamic selection
        ↓
resolution
        ↓
exact / reproducible execution state
```

Il launch non attraversa nuovamente questa barriera.

---

# 1. Desired vs resolved

Desired può contenere:

```text
newest
capability constraint
provider preference
fallback policy
pin/override intent
```

Resolved contiene soltanto:

```text
exact Package Instance identities
exact dependency slot bindings
exact Package Interface resources
exact State Instance identity
validated relocatable environment references
```

Regola:

```text
DESIRED may be dynamic
RESOLVED must be exact
```

---

# 2. Resolution Snapshot

Una Resolution Snapshot è immutabile e serializzata in System Configuration Field Format v0.

Base:

```text
kind	profile_resolved
schema	1
generation	17
profile	default
```

Contiene almeno:

```text
resolved selectors
Resolved Dependency Graph
Resolved Command Bindings
State Instance bindings
selection provenance
```

Non contiene absolute pathname.

---

# 3. Generation

Generation ID v0:

```text
positive monotonic integer
```

Pathname:

```text
g1
g2
g17
```

Nuova resolution => nuova generation; la precedente non viene riscritta.

---

# 4. Resolved graph example

```text
kind	profile_resolved
schema	1
generation	17
profile	default
graphs.count	1
graphs.1.id	netbeans-graph
graphs.1.root_package	netbeans@26@r1@any-any
dependencies.count	1
dependencies.1.graph	netbeans-graph
dependencies.1.consumer	netbeans@26@r1@any-any
dependencies.1.slot	jdk
dependencies.1.provider	temurin@21.0.8+9@r1@linux-arm64
dependencies.1.capability	java-development-kit
dependencies.1.contract	1
dependencies.1.constraint	>=17 <22
dependencies.1.satisfied_version	21
```

Un `any-any` consumer può quindi avere native provider dependency senza diventare platform-specific.

---

# 5. Query model

Resolved è struttura gerarchica, non tabella omogenea.

Lookup puntuale:

```text
rumi_conf_get resolved dependencies.1.provider
```

Lettura di un intero elemento/namespace:

```text
rumi_conf_namespace resolved dependencies.1
```

Questo evita repeated full-file scansions per leggere più proprietà dello stesso edge.

---

# 6. Resolved environment

Non viene persistito:

```text
JAVA_HOME=/absolute/path
```

Si persiste una reference exact e relocatable:

```text
exact Package Instance
resource type
resource id
```

Il launcher materializza l'absolute pathname usando current RUMIAI_ROOT.

---

# 7. Active generation

Snapshots immutabili e active state sono separati.

`active` è SCF:

```text
kind	active
schema	1
generation	17
```

Atomic replace del file è lo switch autorevole.

---

# 8. Transaction boundary

```text
current active generation
        ↓
build candidate desired/resolved in memory
        ↓
resolve entire closure
        ↓
validate Package Instance health/integrity
        ↓
validate dependency graph/state/environment/bindings
        ↓
write immutable candidate generation SCF
        ↓
validate candidate Execution View
        ↓
atomic replace active
```

Errore prima dello switch: previous generation resta autorevole.

---

# 9. New package arrival

Nuova Package Instance compatibile disponibile localmente NON modifica active generation.

Solo nuova resolution esplicita può produrre binding diversi.

---

# 10. Missing provider

Provider exact mancante/corrotto:

```text
BROKEN_RESOLUTION
```

Non vengono rivalutati automaticamente:

```text
fallback
newest
host PATH
host JAVA_HOME/PYTHONHOME
```

---

# 11. Rollback

Rollback riattiva una previous exact generation se tutte le Package Instance/State Instance necessarie sono ancora disponibili.

Altrimenti:

```text
ROLLBACK_UNAVAILABLE
```

Scegliere provider equivalente sarebbe nuova resolution, non rollback.

---

# 12. Reference accounting / GC

Ogni retained generation crea reference alle exact Package Instance che usa.

Una Package Instance referenziata non è garbage.

`why-installed` deriva dalle reference chain del resolved graph.

---

# 13. Execution View

`bin/` e namespace materializzati sono derivati:

```text
active Resolution Snapshot
        ↓
rebuild Execution View
```

La view non corregge un graph broken tramite re-resolution implicita.

---

# 14. State migration

Dependency re-resolution e State Instance migration sono operazioni distinte.

Cambio `sN -> sN+1` richiede migration esplicita prima dell'attivazione della candidate generation che la usa.

---

# 15. Serialization boundary

SCF field order non è semanticamente significativo; array order è espresso da indici numerici.

Generated file usa ordine canonico di schema.

Generation identity è il numero monotono locale, non digest della serializzazione.

Dataset tabellari come integrity inventory non vengono flattenati dentro Resolution Snapshot.

---

# 16. Invarianti

```text
RS-01 desired != resolved
RS-02 resolved contiene solo binding exact
RS-03 Resolution Snapshot = immutable SCF dot-notation
RS-04 new resolution => new generation
RS-05 active switch atomico
RS-06 no absolute RUMIAI_ROOT path persistiti
RS-07 launch non re-resolve
RS-08 new package arrival non muta active
RS-09 missing provider => BROKEN_RESOLUTION
RS-10 rollback exact o fallisce
RS-11 retained generations creano package references
RS-12 State migration separata dalla re-resolution
RS-13 active usa SCF ed è separato
RS-14 Package Instance platform e runtime requirement restano ortogonali
RS-15 array/graph usano count + numeric indices
RS-16 arbitrary IDs restano values
```
