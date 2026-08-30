# RumiAI package manager — Resolved state / lock model

Data: 2026-08-30

Stato: **design decision — resolved state + JSON v0 fissati**

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

Una Resolution Snapshot è immutabile e serializzata in JSON UTF-8.

Contiene almeno:

```text
schema
generation
profile
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

Human-readable pathname:

```text
g1
g2
g17
```

Una nuova resolution crea una nuova generation; non riscrive la precedente.

---

# 4. Resolved graph example

```json
{
  "schema": 1,
  "generation": 17,
  "profile": "default",
  "graphs": [
    {
      "id": "netbeans-graph",
      "root-package": "netbeans@26@r1@any-any"
    }
  ],
  "dependencies": [
    {
      "graph": "netbeans-graph",
      "consumer": "netbeans@26@r1@any-any",
      "slot": "jdk",
      "provider": "temurin@21.0.8+9@r1@linux-arm64",
      "capability": "java-development-kit",
      "contract": 1,
      "constraint": ">=17 <22",
      "satisfied-version": "21"
    }
  ]
}
```

Un `any-any` consumer può quindi avere una native provider dependency senza diventare platform-specific.

---

# 5. Resolved environment

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

Il launcher materializza l'absolute pathname usando la current RUMIAI_ROOT.

---

# 6. Active generation

Snapshots immutabili e active pointer sono separati.

`active` contiene il formato minimale:

```text
g17\n
```

Non è JSON perché non è un documento strutturato e deve restare minimale durante bootstrap/recovery.

---

# 7. Transaction boundary

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
write immutable candidate generation JSON
        ↓
validate candidate Execution View
        ↓
atomic replace active pointer
```

Errore prima dello switch: la previous generation resta autorevole.

---

# 8. New package arrival

Una nuova Package Instance compatibile disponibile localmente NON modifica la active generation.

Solo una nuova resolution esplicita può produrre binding diversi.

---

# 9. Missing provider

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

# 10. Rollback

Rollback riattiva una previous exact generation se tutte le Package Instance/State Instance necessarie sono ancora disponibili.

Altrimenti:

```text
ROLLBACK_UNAVAILABLE
```

Scegliere un provider equivalente sarebbe una nuova resolution, non rollback.

---

# 11. Reference accounting / GC

Ogni retained generation crea reference alle exact Package Instance che usa.

Con retention v0 conservativa, una Package Instance referenziata non è garbage.

`why-installed` deriva dalle reference chain del resolved graph.

---

# 12. Execution View

`bin/` e namespace materializzati sono derivati.

```text
active Resolution Snapshot JSON
        ↓
rebuild Execution View
```

La view non può correggere un resolved graph broken tramite re-resolution implicita.

---

# 13. State migration

Dependency re-resolution e State Instance migration sono operazioni distinte.

Cambio da `sN` a `sN+1` richiede migration esplicita prima dell'attivazione della candidate generation che la usa.

---

# 14. JSON boundary

JSON formatting/object member order non fa parte dell'identità della generation.

Generation identity è il numero monotono locale, non un digest del JSON.

Se serviranno firme/checksum dello snapshot sarà definita una canonical representation specifica.

---

# 15. Invarianti

```text
RS-01 desired != resolved
RS-02 resolved contiene solo binding exact
RS-03 Resolution Snapshot è immutable JSON
RS-04 new resolution => new generation
RS-05 active switch atomico
RS-06 no absolute RUMIAI_ROOT path persistiti
RS-07 launch non re-resolve
RS-08 new package arrival non muta active
RS-09 missing provider => BROKEN_RESOLUTION
RS-10 rollback exact o fallisce
RS-11 retained generations creano package references
RS-12 State migration separata dalla re-resolution
RS-13 active pointer è minimale e non-JSON
RS-14 Package Instance platform e runtime requirement restano ortogonali
```
