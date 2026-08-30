# RumiAI package manager — persistence / transaction layout v0

Data: 2026-08-30

Stato: **design decision — persistence boundary v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-integration-schema-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
```

Questo documento fissa dove vive lo stato autorevole del package manager e come una nuova resolution diventa attiva senza confondere:

```text
Package Instance
State Instance
package-manager control state
transient locking
Execution View derivata
```

---

# 1. Nuova area root: `var/`

RUMIAI_ROOT introduce:

```text
var/
```

Semantica:

> stato mutabile autorevole interno a RumiAI che non appartiene a una State Instance applicativa.

Nel v0 il package manager usa:

```text
RUMIAI_ROOT/var/pkg/
```

`var/` non è una Package Instance state area e non viene esposta automaticamente ai package.

Default Unix-like:

```text
var/       0700 Environment Owner
var/pkg/   0700 Environment Owner
```

---

# 2. Profile persistence layout

```text
RUMIAI_ROOT/var/pkg/
└── profiles/
    └── <profile-id>/
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

`<profile-id>` segue logical-id v0.

Esempio:

```text
var/pkg/profiles/default/
```

---

# 3. Desired + Resolved sono committati insieme

Non esiste nel v0 un file autorevole mutable:

```text
profiles/default/desired
```

separato dalla generation attiva.

Ogni generation contiene la coppia:

```text
desired
resolved
```

che rappresenta:

```text
intenzione usata per la resolution
+
exact result prodotto da quella intenzione
```

Quindi:

```text
g17/desired
    ↕ semantic provenance
 g17/resolved
```

sono immutabili insieme.

Questo elimina il problema di crash fra:

```text
commit new desired
commit matching resolved
```

perché l'unico switch autorevole è `active`.

---

# 4. Generation directory

Generation ID v0:

```text
g<positive-monotonic-integer>
```

Esempi:

```text
g1
g2
g17
```

Una generation completa contiene:

```text
desired     restricted TOML Desired Integration Profile
resolved    restricted TOML Resolution Snapshot
```

Il `resolved` interno deve dichiarare la stessa generation numerica rappresentata dal pathname `gN`.

Mismatch:

```text
GENERATION_MISMATCH
```

---

# 5. Permission generation

Unix-like default:

```text
profiles/                    0700
<profile-id>/                0700
generations/                 0700
gN/                          0500
gN/desired                   0400
gN/resolved                  0400
active                       0400
```

Le permission proteggono da mutazioni accidentali; l'Environment Owner resta semanticamente amministratore del proprio environment come già fissato.

UID/GID non entrano nell'identità del control state.

---

# 6. `active`

`active` è un pointer fisico minimale.

Formato v0:

```text
g17\n
```

cioè:

```text
ASCII `g`
positive decimal generation integer
LF finale
```

Non è TOML perché non rappresenta un documento semantico complesso e deve essere leggibile/validabile con una primitive minima anche durante recovery/bootstrap.

`active` non è obbligatoriamente un symlink.

Questo evita dipendenza da semantiche symlink su Windows.

---

# 7. Locking v0: un solo global mutation lock

Per il v0 tutte le operazioni che mutano package-manager control/store state vengono serializzate da un solo lock logico:

```text
RUMIAI_ROOT/run/@rumiai/pkg/manager.lock
```

`@rumiai` è namespace interno riservato sotto la transient `run/` area e non può essere State Instance ID perché gli state ID package iniziano dal canonical package name.

Operazioni che richiedono exclusive manager lock includono almeno:

```text
package materialization/remove
integrate/deintegrate
resolve/re-resolve/update
active generation switch
explicit generation prune
package garbage collection
state migration transaction quando coordina package switch
```

Il v0 preferisce serializzazione semplice a fine-grained locks prematuri.

---

# 8. Lock file existence != lock ownership

Il file:

```text
manager.lock
```

può restare fisicamente presente.

La lock ownership deriva dalla OS locking primitive, non dall'esistenza del pathname.

Quindi:

```text
stale lock file != stale held lock
```

La primitive concreta viene adattata/validata per reference platform:

```text
Unix-like advisory exclusive file lock
Windows equivalent exclusive file locking
```

Il contratto richiede almeno:

```text
mutual exclusion
release on process termination secondo platform semantics
Physical Platform Validation
```

---

# 9. Launch è lock-free rispetto alle mutazioni

Il normale launch NON acquisisce `manager.lock`.

Legge:

```text
active
→ immutable gN/resolved
```

Generation immutabili permettono lettura concorrente senza osservare file resolved parzialmente riscritti.

Il launch non modifica Desired/Resolved state.

---

# 10. Retention v0

Nel v0 una generation committata NON viene cancellata automaticamente.

Default:

```text
retain all committed generations
until explicit prune policy/action
```

Motivazioni:

```text
rollback semplice
no race launch vs immediate old-generation deletion
no automatic loss of provenance
reference accounting conservativo
```

Conseguenza intenzionale:

> una Package Instance referenziata da una generation retained non è garbage.

Una futura retention/GC policy può essere più aggressiva, ma non è implicita nel v0.

---

# 11. Generation allocation

Sotto `manager.lock`:

```text
next generation = max committed generation + 1
```

Non si riusa un numero di generation cancellata/pruned.

Se esistono:

```text
g1
g2
g5
```

next è:

```text
g6
```

Il monotonic counter logico può essere ricostruito dal massimo pathname generation valido.

---

# 12. Staging generation

La candidate generation viene costruita sotto lo stesso `generations/` filesystem namespace per permettere commit tramite rename/replace validato.

Esempio:

```text
generations/@staging-g18-<nonce>/
├── desired
└── resolved
```

`@staging-*` è internal transaction namespace e non è una generation committata.

Recovery può classificare/rimuovere staging orphan dopo aver verificato che non è referenced da `active`.

---

# 13. Commit sequence

Sotto exclusive `manager.lock`:

```text
1. read/validate current active generation
2. derive candidate Desired Profile in memory
3. allocate next generation N
4. resolve full candidate closure
5. validate package health/integrity
6. validate State Instance compatibility
7. validate public bindings/environment/launch
8. write staging gN/desired + gN/resolved
9. flush/sync files as required by reference platform contract
10. seal desired/resolved read-only
11. atomically rename staging directory -> gN
12. materialize/validate candidate Execution View as required
13. write temporary active pointer in same profile directory
14. flush/sync pointer as required
15. atomically replace `active` -> gN
16. release manager lock
```

Se fallisce prima del punto 15:

```text
old active generation remains authoritative
```

Una committed ma non-active `gN` può essere retained come inactive generation oppure classified/pruned esplicitamente; non viene usata automaticamente.

---

# 14. Atomic active replace

Temporary active pointer deve vivere nello stesso profile directory/filesystem:

```text
<profile>/@active-<nonce>
```

poi viene sostituito atomicamente in:

```text
<profile>/active
```

La primitive concreta può differire per OS/filesystem, ma deve essere fisicamente validata.

Non assumiamo genericamente che POSIX `rename()` semantics siano identiche su ogni reference platform/filesystem.

---

# 15. Crash recovery states

Dopo crash possono esistere:

```text
@staging-*              incomplete candidate
committed gN inactive   complete generation mai attivata
@active-*               temporary pointer
active -> valid gM      authoritative state
```

Recovery rule:

```text
active valid generation wins
```

Non viene dedotta una generation attiva da:

```text
highest generation number
latest mtime
presence of staging directory
```

Se `active` manca/corrotto:

```text
ACTIVE_GENERATION_ERROR
```

Recovery assistita può proporre generation complete disponibili, ma non ne attiva una silenziosamente.

---

# 16. Generation validity

Una generation è structurally complete soltanto se:

```text
pathname gN valido
desired presente e schema-valid
resolved presente e schema-valid
resolved.generation == N
profile IDs concordano
exact references internally consistent
```

Per essere execution-valid richiede inoltre:

```text
all exact Package Instance present/HEALTHY
State Instance compatible/present
resource bindings valid
```

Una retained generation può quindi essere:

```text
COMPLETE + EXECUTABLE
COMPLETE + BROKEN_RESOLUTION
```

senza perdere provenance.

---

# 17. Reference accounting

Reference autorevoli derivano da tutte le generation retained che la policy considera rollback/retention roots.

Nel v0 default retain-all:

```text
all committed gN create package references
```

Quindi package GC deve leggere le retained generation, non solo `active`.

Explicit generation prune rimuove prima la generation root; soltanto una successiva reference analysis può rendere Package Instance garbage.

---

# 18. `var/pkg` != State Instance data

Non usare:

```text
conf/<state-id>
data/<state-id>
home/<state-id>
```

per Desired/Resolved package-manager state.

Queste aree appartengono alle applicazioni/package State Instance.

`var/pkg` è control-plane state di RumiAI.

Analogamente:

```text
run/@rumiai/pkg/
```

è transient package-manager coordination state, non application `run/<state-id>`.

---

# 19. Execution View boundary

Execution View resta derivata.

Non diventa fonte di verità soltanto perché viene materializzata durante il commit.

La generation autorevole è sempre:

```text
gN/desired + gN/resolved
```

Un'Execution View corrotta può essere ricostruita dalla generation attiva.

La tecnica concreta per rendere atomicamente coerenti tutti i public `bin/` binding con il cambio generation è un problema separato del **launcher/materialization model** e non viene nascosto dentro il persistence state.

---

# 20. Permission model integration

Aggiunta v0 al root permission model Unix-like:

```text
RUMIAI_ROOT/var/           0700
RUMIAI_ROOT/var/pkg/       0700
RUMIAI_ROOT/run/@rumiai/   0700
```

Package process normali non ricevono automaticamente path/reference a queste directory.

---

# 21. Error classes

```text
MANAGER_LOCK_ERROR
GENERATION_MISMATCH
GENERATION_SCHEMA_ERROR
ACTIVE_GENERATION_ERROR
TRANSACTION_COMMIT_ERROR
TRANSACTION_RECOVERY_REQUIRED
```

Restano valide:

```text
BROKEN_RESOLUTION
ROLLBACK_UNAVAILABLE
```

---

# 22. Invarianti

```text
PL-01 package-manager authoritative mutable state vive sotto var/pkg
PL-02 desired+resolved sono immutabili e co-versionati nella stessa generation
PL-03 non esiste desired autorevole separato dall'active generation nel v0
PL-04 generation ID = gN monotonic local
PL-05 active è pointer minimale separato dalle generation
PL-06 active generation switch avviene tramite atomic pointer replace
PL-07 staging non è generation committata
PL-08 v0 usa un solo global package-manager mutation lock
PL-09 lock ownership deriva dall'OS lock, non dall'esistenza del file
PL-10 launch non acquisisce mutation lock
PL-11 committed generations retained by default finché non pruned esplicitamente
PL-12 retained generation crea package references
PL-13 active pointer, non highest generation, definisce lo stato autorevole
PL-14 crash non attiva automaticamente incomplete/newest generation
PL-15 var/pkg control state != application State Instance
PL-16 run/@rumiai/pkg coordination state != application run state
PL-17 Execution View resta derivata e ricostruibile
```

---

# 23. Prossimo nodo

Resta un problema architetturale reale prima di dichiarare completamente chiuso il public execution path:

> **launcher/materialization model:** come i pathname stabili sotto `bin/` e `bin/@platforms/...` raggiungono sempre l'exact command binding della active generation, incluse package-specific dependency/environment, senza re-resolution e senza finestre incoerenti durante generation switch.

Questo è il prossimo punto da formalizzare.