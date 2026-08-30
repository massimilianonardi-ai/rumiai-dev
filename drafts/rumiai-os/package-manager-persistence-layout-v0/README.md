# RumiAI package manager — persistence / transaction layout v0

Data: 2026-08-30

Stato: **design decision — persistence boundary v0 fissato**

---

# 1. Package-manager control state

Authoritative mutable package-manager state vive sotto:

```text
RUMIAI_ROOT/var/pkg/
```

Non è application State Instance data.

Unix-like default:

```text
var/      0700
var/pkg/  0700
```

---

# 2. Profile layout

```text
var/pkg/profiles/<profile-id>/
├── active
└── generations/
    ├── g1/
    │   ├── desired
    │   └── resolved
    ├── g2/
    │   ├── desired
    │   └── resolved
    └── ...
```

`active`, `desired` e `resolved` sono System Configuration Field files con dot notation.

---

# 3. Desired + Resolved co-versionati

Non esiste un mutable authoritative `desired` separato dalla generation attiva.

Ogni generation contiene:

```text
gN/desired
    intention + selection policy snapshot

gN/resolved
    exact resolution result
```

Entrambi immutabili.

L'unico switch autorevole è `active`.

---

# 4. Generation identity

```text
g<positive-monotonic-integer>
```

Il resolved dichiara:

```text
generation	N
```

Mismatch col pathname `gN`:

```text
GENERATION_MISMATCH
```

---

# 5. Permissions

```text
profiles/             0700
<profile-id>/         0700
generations/          0700
gN/                   0500
gN/desired            0400
gN/resolved           0400
active                0400
```

---

# 6. `active`

SCF:

```text
kind	active
schema	1
generation	17
```

Non è obbligatoriamente un symlink.

Deve essere sostituibile atomicamente con primitive fisicamente validata sulla reference platform/filesystem.

---

# 7. Global mutation lock v0

Un solo lock logico serializza tutte le mutation:

```text
RUMIAI_ROOT/run/@rumiai/pkg/manager.lock
```

Include almeno:

```text
package materialization/remove
integrate/deintegrate
resolve/re-resolve/update
active generation switch
generation prune
package GC
state migration transaction coordinata
```

`manager.lock` è OS lock handle, non data/config file.

Lock ownership deriva dalla OS locking primitive, non dalla presenza del file.

Launch normale non acquisisce mutation lock.

---

# 8. Retention

V0 default:

```text
retain all committed generations until explicit prune
```

Motivi:

```text
rollback
no race con launch di old generation
provenance
conservative reference accounting
```

Ogni retained generation crea package references.

---

# 9. Allocation

Sotto manager lock:

```text
next generation = max committed generation + 1
```

Numeri non riutilizzati dopo prune.

---

# 10. Staging

```text
generations/@staging-gN-<nonce>/
├── desired
└── resolved
```

`@staging-*` non è committed generation.

---

# 11. Commit sequence

```text
1 acquire manager lock
2 read/validate current active SCF
3 derive candidate desired in memory
4 allocate N
5 resolve entire closure
6 validate package integrity/state/bindings/environment/launch
7 write staging desired + resolved SCF
8 flush/sync according to platform contract
9 seal files read-only
10 atomic rename staging -> gN
11 ensure candidate command stubs exist
12 write temporary active SCF in same profile directory
13 flush/sync active temp
14 atomic replace active
15 cleanup obsolete derived stubs opportunistically
16 release manager lock
```

Failure prima del punto 14 lascia previous active generation autorevole.

---

# 12. Crash recovery

Possibili residui:

```text
@staging-*
committed inactive gN
@active-*
valid active
```

Regola:

```text
valid active file wins
```

Non si seleziona automaticamente highest generation/mtime.

Active missing/corrupt:

```text
ACTIVE_GENERATION_ERROR
```

---

# 13. Generation validity

Structural complete:

```text
gN pathname valid
desired valid SCF kind=profile_desired/schema
resolved valid SCF kind=profile_resolved/schema
resolved generation == N
profile IDs match
count/indices valid
exact references internally consistent
```

Execution-valid richiede exact Package Instance/State Instance/resource availability.

Una retained generation può essere:

```text
COMPLETE + EXECUTABLE
COMPLETE + BROKEN_RESOLUTION
```

---

# 14. Execution View

`bin/` non è authoritative state.

Stable Command Stub legge `active` una sola volta e usa generation exact.

Stale/missing stub è problema derived Execution View, non motivo per modificare resolved graph.

---

# 15. Bootstrap/platform primitives da validare

Il persistence protocol richiede primitive uniformi Rumi per:

```text
exclusive lock
flush/durability
atomic rename
atomic replace
```

Queste non vengono implementate tramite comandi platform-specific sparsi dentro `pkg`.

---

# 16. Data-format boundary

Persistence control state è gerarchico e usa SCF.

Dataset tabellari come integrity inventory restano file separati STD; non vengono incorporati in `desired`, `resolved` o `active`.

---

# 17. Invarianti

```text
PL-01 control state vive sotto var/pkg
PL-02 desired+resolved SCF sono immutabili e co-versionati
PL-03 active usa SCF ed è separato
PL-04 generation ID = gN monotonic
PL-05 active switch atomic
PL-06 staging non è committed generation
PL-07 one global mutation lock v0
PL-08 manager.lock non è un data file
PL-09 launch lock-free rispetto alle mutation
PL-10 generations retained by default
PL-11 active, non highest generation, è authoritative
PL-12 crash non attiva automaticamente candidate/newest generation
PL-13 Execution View è derivata
PL-14 tabular datasets restano separati dal control-state SCF
```
