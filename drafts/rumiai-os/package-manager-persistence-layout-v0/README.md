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

`desired` e `resolved` sono documenti JSON UTF-8 secondo RumiAI JSON standard v0 anche senza estensione `.json`.

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

Entrambi sono immutabili.

L'unico switch autorevole è `active`.

---

# 4. Generation identity

```text
g<positive-monotonic-integer>
```

Il `resolved` JSON dichiara la stessa generation numerica del pathname.

Mismatch:

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

Formato minimale:

```text
g17\n
```

Non è JSON e non è obbligatoriamente un symlink.

Deve essere sostituibile atomicamente con una primitive fisicamente validata sulla reference platform/filesystem.

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

Lock ownership deriva dalla OS locking primitive, non dalla presenza del file.

Launch normale non acquisisce il mutation lock.

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

I numeri non vengono riutilizzati dopo prune.

---

# 10. Staging

Candidate generation:

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
2 read/validate current active
3 derive candidate desired in memory
4 allocate N
5 resolve entire closure
6 validate package integrity/state/bindings/environment/launch
7 write staging desired JSON + resolved JSON
8 flush/sync according to platform contract
9 seal files read-only
10 atomic rename staging -> gN
11 ensure candidate command stubs exist
12 write temporary active pointer in same profile directory
13 flush/sync pointer
14 atomic replace active -> gN
15 cleanup obsolete derived stubs opportunistically
16 release manager lock
```

Failure prima del punto 14 lascia la previous active generation autorevole.

---

# 12. Crash recovery

Possibili residui:

```text
@staging-*
committed inactive gN
@active-*
valid active -> gM
```

Regola:

```text
valid active pointer wins
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
desired valid JSON/schema
resolved valid JSON/schema
resolved.generation == N
profile IDs match
exact references internally consistent
```

Execution-valid richiede inoltre exact Package Instance/State Instance/resource availability.

Una retained generation può essere:

```text
COMPLETE + EXECUTABLE
COMPLETE + BROKEN_RESOLUTION
```

---

# 14. Execution View

`bin/` non è authoritative state.

Stable Command Stub legge `active` una sola volta e usa la generation exact.

Stale/missing stub è un problema della derived Execution View, non un motivo per modificare il resolved graph.

---

# 15. Invarianti

```text
PL-01 control state vive sotto var/pkg
PL-02 desired+resolved JSON sono immutabili e co-versionati
PL-03 active è pointer minimale separato
PL-04 generation ID = gN monotonic
PL-05 active switch atomic
PL-06 staging non è committed generation
PL-07 one global mutation lock v0
PL-08 launch lock-free rispetto alle mutation
PL-09 generations retained by default
PL-10 active, non highest generation, è authoritative
PL-11 crash non attiva automaticamente candidate/newest generation
PL-12 Execution View è derivata
```
