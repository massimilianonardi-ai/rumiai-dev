# RumiAI package manager — Resolved state / lock model

Data: 2026-08-30

Stato: **design decision — resolved state + serializzazione v0 fissati**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

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

# 1. Oggetti persistibili

Il v0 distingue almeno:

```text
Desired Integration Profile
Resolved Integration Profile
Resolved Dependency Graph
Resolved Command Binding
Resolved State Binding
```

La Materialized Process Environment e gli absolute pathname non sono persisted lock state.

---

# 2. Desired vs resolved

Desired state può contenere:

```text
latest/newest
capability constraint
provider preference
fallback policy
alias/override intent
```

Resolved state contiene soltanto:

```text
exact Package Instance identity
exact dependency slot binding
exact Package Interface resource binding
exact State Instance identity
validated relocatable environment reference
```

Regola:

```text
DESIRED may be dynamic
RESOLVED must be exact
```

---

# 3. Resolution Snapshot

Una **Resolution Snapshot** è una rappresentazione immutabile di un risultato di resolution validato.

Contiene almeno:

```text
schema
resolution generation
resolved roots/selectors
Resolved Integration Profile
Resolved Dependency Graph
Resolved Command Bindings
State Instance bindings
provenance minima della Selection Policy
```

Non contiene absolute pathname.

Nel v0 è serializzata in restricted TOML 1.0.

---

# 4. Resolution generation

La generation identity v0 è un **intero positivo monotono locale all'environment RumiAI**:

```text
1
2
3
...
```

Rappresentazione human-readable possibile:

```text
g1
g2
g3
```

Una generation è immutabile.

Una nuova resolution crea una nuova generation e non modifica retroattivamente le precedenti.

Non è richiesto un digest-based generation ID nel v0.

---

# 5. Provenance

La provenance serve per audit/spiegazione, non per rivalutare la resolution durante il launch.

Può preservare:

```text
Requirement originale
Selection Policy effettiva
provider preference usata
pin usato, se presente
reason/timestamp/generation
```

Il provider exact resta l'unica sorgente del launch.

---

# 6. Resolved Dependency Graph

Per ogni edge:

```text
consumer exact Package Instance
slot
Requirement snapshot
provider exact Package Instance
capability/version soddisfatta
```

Esempio:

```text
netbeans@26@r1@jvm-any
└── jdk
    requirement = java-development-kit >=17 <22
    provider    = temurin@21.0.8+9@r1@linux-arm64
    satisfied   = java-development-kit 21
```

Non esistono edge resolved verso:

```text
latest
preferred-java
any compatible provider
```

---

# 7. Resolved Command Binding

Un binding pubblico persistito collega:

```text
public command name
→ exact root Package Instance
→ exact command resource
→ exact resolution generation/graph
```

La materializzazione in `bin/` è derivata da questo stato.

---

# 8. State binding

Quando un command/package usa stato, il resolved state associa l'identity concreta:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

Il binding non contiene i contenuti dello stato.

`run/` package-local viene materializzata coerentemente con la State Instance attiva.

---

# 9. Environment nel resolved state

Non viene persistito:

```text
JAVA_HOME=/absolute/path/...
```

Si persiste o si ricostruisce deterministicamente una reference exact relocatable:

```text
provider exact Package Instance
+
resource type/name
```

Al launch:

```text
exact logical reference
        ↓ current RUMIAI_ROOT
absolute process value
```

---

# 10. TOML v0

Desired state e Resolution Snapshot usano lo stesso restricted TOML profile di `@package`.

Esempio concettuale:

```toml
schema = 1
generation = 17

[[roots]]
package = "netbeans@26@r1@jvm-any"
command = "netbeans"
state = "netbeans@s2"

[[dependencies]]
consumer = "netbeans@26@r1@jvm-any"
slot = "jdk"
provider = "temurin@21.0.8+9@r1@linux-arm64"
capability = "java-development-kit"
satisfied-version = "21"
```

La struttura schema definitiva viene fissata separatamente; il formato di serializzazione è già deciso.

---

# 11. Active generation pointer

Lo stato persistente distingue:

```text
immutable generation snapshots
active generation pointer
```

Il pointer contiene soltanto l'ID della generation attiva.

Non è obbligatoriamente un symlink; deve poter essere sostituito atomicamente usando una primitive validata sulla reference platform/filesystem.

Questo evita di imporre semantiche Unix a Windows.

---

# 12. Transaction boundary

Una resolution non diventa attiva progressivamente.

Flusso:

```text
current active generation
        ↓
build candidate desired/resolved state
        ↓
resolve entire closure
        ↓
validate Package Instance health/integrity
        ↓
validate dependency graph
        ↓
validate State Instance compatibility
        ↓
validate public binding conflicts
        ↓
validate Environment/Launch Specification
        ↓
materialize candidate Execution View, se necessario
        ↓
write immutable candidate generation
        ↓
atomic replace active-generation pointer
```

In caso di errore, la generation corrente resta attiva.

---

# 13. New package arrival does not mutate resolved state

Se arriva localmente una Package Instance migliore secondo la Selection Policy:

```text
active binding resta invariato
```

Solo una nuova resolution esplicita può produrre una nuova generation.

---

# 14. Missing provider

Se una generation attiva referenzia un provider mancante/corrotto:

```text
BROKEN_RESOLUTION
```

Non viene rivalutato automaticamente:

```text
fallback
latest
PATH host
JAVA_HOME host
```

Repair/re-resolve crea eventualmente una nuova generation.

---

# 15. Reference accounting

Una active/in-retention Resolution Snapshot crea reference alle exact Package Instance che contiene.

Reference source v0 candidate:

```text
active Resolved Integration Profile
retained Resolution Snapshot per rollback
explicit pin/keep state
```

Una Package Instance referenziata non è garbage.

---

# 16. Rollback

Rollback riattiva una precedente exact generation se:

```text
tutte le Package Instance esistono e sono sane
State Instance necessaria è disponibile/compatibile
```

Altrimenti:

```text
ROLLBACK_UNAVAILABLE
```

Non si sostituisce un provider mancante con uno simile: sarebbe una nuova resolution.

---

# 17. Upgrade preview

Una candidate generation può essere confrontata con quella attiva prima del commit.

Il diff può mostrare:

```text
root Package Instance changed
provider changed
release changed
RumiAI revision changed
new/removed dependency edge
State compatibility change
public binding change
```

---

# 18. `why-installed`

Il resolved graph permette reference chain esplicite:

```text
public root binding
    ↓
root Package Instance
    ↓ dependency slot
provider Package Instance
```

oppure:

```text
retained generation
    ↓
exact Package Instance
```

---

# 19. Execution View rebuild

`bin/` e gli altri namespace materializzati non sono lock state autorevole.

```text
active Resolution Snapshot
        ↓
rebuild Execution View
```

Se il resolved state è broken, la view non re-resolve il grafo.

---

# 20. State migration

Se una nuova Package Instance richiede una diversa state-compatibility-version, la nuova generation richiede prima la migration esplicita definita nel State model.

Dependency re-resolution e state migration restano operazioni distinte.

---

# 21. Canonical serialization boundary

Il resolved state non richiede una canonical byte representation TOML generale.

La generation identity è sequenziale, non un digest del file TOML.

Se in futuro servono checksum/firme del snapshot, verrà definita una canonical representation specifica senza cambiare la semantica di generation.

---

# 22. Invarianti fissate

```text
RS-01 desired state != resolved state
RS-02 resolved state contiene soltanto binding exact
RS-03 Resolution Snapshot è immutabile
RS-04 nuova resolution produce una nuova monotonic generation
RS-05 active generation cambia atomicamente dopo validazione completa
RS-06 resolved state non persiste absolute RUMIAI_ROOT pathname
RS-07 Materialized Process Environment è effimera
RS-08 new Package Instance arrival non muta la generation attiva
RS-09 missing/corrupt provider => BROKEN_RESOLUTION
RS-10 broken resolution non fa provider/host fallback automatico
RS-11 resolved state crea reference per package retention/GC
RS-12 rollback riattiva exact old binding o fallisce
RS-13 Execution View è derivata dalla generation attiva
RS-14 state migration è separata dalla dependency re-resolution
RS-15 provenance serve ad audit, non a dynamic launch selection
RS-16 serializzazione v0 = restricted TOML 1.0
RS-17 active-generation pointer è separato dallo snapshot
RS-18 generation ID v0 = positive local monotonic integer
```

---

# 23. Dettagli fisici successivi

Restano da definire nello schema/persistence layer concreto:

```text
pathname dei generation snapshot
pathname active pointer
retention policy
atomic replace primitive per reference platform
locking/concorrenza
schema field-by-field
```

Questi dettagli non cambiano la semantica del lock v0.