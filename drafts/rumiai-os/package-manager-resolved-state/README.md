# RumiAI package manager — Resolved state / lock model

Data: 2026-08-30

Stato: **design draft — resolved state v0 formalizzato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-dependency-model/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-package-descriptor/README.md
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

La Materialized Process Environment e i pathname assoluti non sono persisted lock state.

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
exact Package Instance identities
exact dependency slot bindings
exact Package Interface resource bindings
exact State Instance identity
validated environment expressions riferite a provider exact
```

Regola:

```text
DESIRED may be dynamic
RESOLVED must be exact
```

---

# 3. Resolution Snapshot

Una **Resolution Snapshot** è una rappresentazione immutabile di un risultato di resolution validato.

Contiene logicamente almeno:

```text
schema/version del resolved state
root/selectors risolti
Resolved Integration Profile
Resolved Dependency Graph per root command/package
Resolved Command Bindings
State Instance binding dove applicabile
provenance minima della Selection Policy
```

Non contiene absolute pathname.

---

# 4. Provenance

La provenance non serve a rivalutare la resolution durante il launch.

Serve per audit e spiegazione.

Può preservare almeno:

```text
Requirement originale
Selection Policy effettiva
provider preference usata
pin usato, se presente
reason/timestamp/generation della resolution
```

Il provider concreto rimane comunque l'unica sorgente del launch.

---

# 5. Resolved Dependency Graph

Per ogni edge:

```text
consumer exact Package Instance
slot
Requirement snapshot
provider exact Package Instance
capability/version con cui il Requirement è stato soddisfatto
```

Esempio:

```text
netbeans@26@r1@jvm-any
└── jdk
    requirement = java-development-kit >=17 <22
    provider    = temurin@21.0.8+9@r1@linux-arm64
    satisfied   = java-development-kit 21
```

Il grafo non contiene:

```text
provider = latest
provider = preferred-java
provider = qualsiasi Java 21
```

---

# 6. Resolved Command Binding

Un binding pubblico persistito collega:

```text
public command name
→ exact root Package Instance
→ exact command resource
→ Resolution Snapshot / exact dependency graph necessario
```

Esempio:

```text
netbeans
→ netbeans@26@r1@jvm-any
→ command:netbeans
→ resolution generation X
```

La materializzazione in `bin/` può essere ricostruita da questo binding.

---

# 7. State binding

Quando il command/package richiede State Instance, il resolved execution state associa l'identity compatibile concreta:

```text
<pkg-name>[@<platform>-<architecture>]@sN
```

Esempio:

```text
netbeans@s2
```

oppure:

```text
foo@linux-arm64@s4
```

Il binding non contiene i contenuti dello stato; li referenzia.

`run/` package-local viene materializzata coerentemente con questa State Instance attiva.

---

# 8. Environment nel resolved state

Non viene persistita una mappa di absolute string tipo:

```text
JAVA_HOME=/Volumes/RumiAI/pkg/...
```

Si persistono o si ricostruiscono deterministicamente reference exact relocatable:

```text
JAVA_HOME
→ provider temurin@21.0.8+9@r1@linux-arm64
→ directory:home
```

Al launch:

```text
exact logical reference
        ↓ current RUMIAI_ROOT
absolute process value
```

---

# 9. Resolution generation

Ogni commit di un nuovo resolved state produce una nuova **resolution generation**.

La forma concreta dell'identifier non è ancora fissata; può essere sequenziale, digest-based o entrambe.

Semantica richiesta:

```text
una generation è immutabile
una nuova resolution non modifica retroattivamente la precedente
```

Questo permette confronto e rollback del resolved state.

---

# 10. Transaction boundary

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
atomic commit active generation
```

In caso di errore, la generation corrente resta attiva.

---

# 11. New package arrival does not mutate resolved state

Esempio:

```text
active:
    jdk -> Java 21 release-order 100

arriva localmente:
    Java 21 release-order 101
```

Nessuna modifica automatica:

```text
active remains release-order 100
```

Solo una nuova resolution esplicita può creare una generation che usa 101.

---

# 12. Missing provider

Se una generation attiva referenzia:

```text
provider X
```

ma X viene rimosso o corrotto:

```text
BROKEN_RESOLUTION
```

Il sistema non rivaluta:

```text
fallback provider
latest
PATH host
JAVA_HOME host
```

Una repair/re-resolve esplicita può generare una nuova generation.

---

# 13. Reference accounting

Una active/in-retention Resolution Snapshot crea reference alle Package Instance esatte che contiene.

Una Package Instance referenziata non è garbage.

Reference source candidate:

```text
active Resolved Integration Profile
retained Resolution Snapshot necessarie a rollback
explicit pin/keep state
```

La futura garbage collection deve considerare queste reference, non soltanto i public binding attivi.

---

# 14. Rollback del resolved state

Se una precedente generation è ancora materializzabile:

```text
all exact Package Instance presenti e sane
State Instance compatibile/presente
```

il rollback può riattivarla senza nuova provider selection.

Se una dependency esatta della vecchia generation non esiste più:

```text
ROLLBACK_UNAVAILABLE
```

Non si sostituisce silenziosamente con un provider simile: quello sarebbe una nuova resolution, non un rollback.

---

# 15. Upgrade preview

Poiché desired e resolved state sono separati, un update può produrre una candidate generation senza attivarla immediatamente.

Confronto concettuale:

```text
current generation
vs
candidate generation
```

può mostrare:

```text
root Package Instance changed
provider changed
release changed
RumiAI revision changed
new/removed dependency edge
State compatibility change
public binding change
```

Questa è una conseguenza naturale del modello, non richiede reinterpretare il filesystem.

---

# 16. `why-installed`

Una Package Instance può spiegare la propria presenza tramite reference chain:

```text
public root binding
    ↓
root Package Instance
    ↓ dependency slot
provider Package Instance
```

oppure:

```text
retained rollback generation
    ↓
exact Package Instance
```

Il resolved graph è quindi la base autorevole per questa spiegazione.

---

# 17. Integration View rebuild

`bin/` e altri namespace materializzati non sono lock state autorevole.

Se vengono rimossi/corrotti:

```text
active Resolution Snapshot
        ↓
rebuild Execution View
```

Se invece il resolved state stesso è incoerente o referenzia Package Instance mancanti:

```text
BROKEN_RESOLUTION
```

La view non può correggere il grafo.

---

# 18. Multi-command package

Più command della stessa Package Instance possono condividere lo stesso Resolved Dependency Graph quando i Requirement sono comuni.

Se command-specific requirement/environment differiscono in futuro, il resolved state può associare graph/launch state differenti ai singoli command.

Il v0 non obbliga a duplicare fisicamente il grafo quando può essere condiviso semanticamente.

---

# 19. State migration e generation

Se una nuova Package Instance richiede:

```text
s4
```

mentre l'active generation usa:

```text
s3
```

la nuova generation non può essere attivata come semplice re-resolution.

Serve la state migration esplicita definita nel State model.

Dopo migration/validation la candidate generation può bindare:

```text
package@s4
```

La vecchia generation resta rollback-valid soltanto se il relativo `s3`/snapshot necessario è ancora disponibile.

---

# 20. Invarianti fissate

```text
RS-01 desired state != resolved state
RS-02 resolved state contiene soltanto binding exact
RS-03 Resolution Snapshot è immutabile
RS-04 nuova resolution produce una nuova generation
RS-05 active generation cambia atomicamente dopo validazione completa
RS-06 resolved state non persiste absolute RUMIAI_ROOT pathname
RS-07 Materialized Process Environment è effimera
RS-08 new Package Instance arrival non muta la generation attiva
RS-09 missing/corrupt provider => BROKEN_RESOLUTION
RS-10 broken resolution non fa provider/host fallback automatico
RS-11 resolved state crea reference per package retention/GC
RS-12 rollback riattiva exact old binding o fallisce; non re-resolve silenziosamente
RS-13 Execution View è derivata dalla generation attiva
RS-14 state migration è separata dalla dependency re-resolution
RS-15 provenance serve ad audit, non a dynamic launch selection
```

---

# 21. Dettagli fisici ancora aperti

Restano decisioni di implementazione/serializzazione:

```text
pathname concreto dei resolved state
formato file/database
resolution generation ID concreto
retention policy delle generation precedenti
atomic commit primitive cross-platform
locking/concorrenza durante resolve/integrate
```

Questi dettagli non cambiano la semantica del lock v0.