# RumiAI package manager — lifecycle / bootstrap / recovery v0

Data: 2026-08-30

Stato: **architectural contract — v0**

Questa specifica chiude il lifecycle locale del package manager nel confine già fissato:

```text
software già prodotto/normalizzato
        ↓
local Package Instance materialization
        ↓
resolution/integration
        ↓
execution
        ↓
deintegration/removal/recovery
```

Acquisition, store remoto, download, build e toolchain restano fuori scope.

---

# 1. Initialized package-manager environment

Un environment `pkg` inizializzato deve avere un active default profile valido.

V0 crea una generation iniziale vuota:

```text
var/pkg/profiles/default/
├── active
└── generations/
    └── g1/
        ├── desired
        └── resolved
```

`g1` non rappresenta software installato; rappresenta un valid empty integration state.

---

# 2. Empty desired g1

```text
kind	profile_desired
schema	1
profile	default
selectors.count	0
command_bindings.count	0
environment.count	0
```

---

# 3. Empty resolved g1

```text
kind	profile_resolved
schema	1
generation	1
profile	default
reason	bootstrap
selectors.count	0
graphs.count	0
dependencies.count	0
command_bindings.count	0
environment.count	0
```

`created` può essere incluso secondo lo schema resolved corrente se richiesto dal writer v0.

---

# 4. Active g1

```text
kind	active
schema	1
generation	1
```

Dopo inizializzazione completa:

> un environment `pkg` valido non usa `active missing` come normale stato vuoto.

Active missing/corrupt indica errore/recovery condition.

---

# 5. Bootstrap directory creation

Prima inizializzazione crea con Environment Owner e policy private:

```text
var/pkg/
var/pkg/profiles/
var/pkg/profiles/default/
var/pkg/profiles/default/generations/
run/@rumiai/pkg/
```

Default Unix-like:

```text
0700 directories
umask 0077
```

Generation g1 viene costruita/staged e committata usando le stesse transaction primitives delle generation successive.

---

# 6. Package materialization does not integrate

Materializzare una Package Instance sotto `pkg/` NON modifica automaticamente:

```text
desired
resolved
active
bin/
```

Install/local materialization e integration restano operazioni distinte.

Una Package Instance può quindi essere localmente presente ma non referenziata da alcuna generation.

---

# 7. Package staging requirement

Per pubblicare atomicamente:

```text
staging package tree
    -> pkg/<package-instance-id>/
```

lo staging deve trovarsi nello stesso filesystem/domain atomicamente rinominabile del target `pkg/`.

Lo staging NON è una normale immediate child autorevole di `pkg/`.

Il bootstrap/platform adapter deve poter fornire una staging location compatibile con il target oppure una primitive equivalente.

Questo preserva:

```text
pkg/ immediate children = physical truth delle Package Instance visibili
```

---

# 8. Materialization algorithm

Sotto `manager.lock`:

```text
1 receive/locate prepared local candidate
2 parse/validate target Package Instance identity
3 validate canonical version-token round-trip
4 verify target pkg/<id> absent
5 create same-filesystem staging wrapper outside authoritative pkg children
6 materialize root/ + run-default/ + @package + integrity TSV
7 create empty run/
8 validate @package SCF/schema/pathname identity
9 validate Integrity Method 1 inventories + physical trees
10 validate modes/ownership/symlink/state mapping/interface/capability metadata
11 normalize immutable modes and wrapper permissions
12 ensure candidate wrapper is complete/durable according to platform contract
13 atomic publish staging -> pkg/<id>
14 sync pkg parent as required
15 classify resulting child HEALTHY
```

Failure prima del publish non crea una Package Instance visibile sotto `pkg/`.

---

# 9. Dependency availability is not materialization precondition

Materialization valida la Requirement syntax/contracts del package.

Non richiede necessariamente che ogni dependency candidate sia già presente localmente.

Quindi è possibile:

```text
Package Instance HEALTHY
+
future resolution => DEPENDENCY_UNAVAILABLE
```

La full local closure è requisito di resolution/integration, non di physical presence.

---

# 10. Materialization durability

Dopo successo pubblico di materialization:

```text
pkg/<id>
```

deve essere una wrapper completa, non partial copy.

Il transaction/platform contract decide le primitive concrete necessarie per rendere durable il tree prima/dopo atomic publish.

Non si usa `pkg/<id>` come live copy destination durante una copia lunga.

---

# 11. Removal reference check

Prima di rimuovere una Package Instance, `pkg` verifica almeno:

```text
active generation references
retained generation references
explicit pins/references persistite rilevanti
```

Se referenziata:

```text
PACKAGE_IN_USE
```

No silent re-resolution/fallback viene eseguita per rendere rimovibile il package.

---

# 12. Atomic detach before delete

La rimozione fisica non esegue direttamente recursive delete dentro authoritative `pkg/<id>`.

Pattern preferito:

```text
1 unseal wrapper con Environment Owner permissions
2 atomic detach/rename pkg/<id> -> same-filesystem removal staging outside authoritative pkg children
3 sync pkg parent as required
4 recursive delete detached tree
```

Dopo il punto 2 la Package Instance non è più fisicamente presente in `pkg/`.

Crash durante recursive delete lascia garbage fuori dall'authoritative `pkg/`, non una Package Instance partial/ghost.

---

# 13. Removal staging garbage

Detached removal tree è recovery garbage.

Può essere eliminato in recovery dopo verifica che:

```text
non è sotto authoritative pkg/
non è target di active/retained reference
è riconosciuto come lifecycle staging artifact
```

Il nome/layout fisico dello staging non è identity.

---

# 14. `pkg/` recovery scan

Recovery scansiona ogni immediate child di:

```text
RUMIAI_ROOT/pkg/
```

e classifica:

```text
HEALTHY
RECOVERABLE
IDENTITY_MISMATCH
UNKNOWN
```

Nessun indice/cache può nascondere un child fisicamente presente.

Recovery non sceglie automaticamente di usare un package RECOVERABLE/UNKNOWN per resolution.

---

# 15. Generation recovery

Per ogni profile:

```text
1 validate active SCF
2 validate referenced gN structural completeness
3 active valid wins
4 committed inactive generation resta inactive
5 @staging-* resta staging/recovery artifact
6 temporary active file resta artifact
7 highest generation/mtime non viene auto-selected
```

Active missing/corrupt:

```text
ACTIVE_GENERATION_ERROR
```

Non si inventa un fallback generation implicitamente.

---

# 16. Execution View recovery

`bin/` è derived.

Recovery:

```text
1 read active resolved generation
2 compute expected public stub paths
3 validate existing expected stubs
4 create/repair missing canonical stubs
5 identify stale canonical package stubs
6 remove stale canonical stubs per cleanup policy
```

---

# 17. System command vs package stub

`RUMIAI_ROOT/bin/` contiene anche veri system command RumiAI, per esempio:

```text
rumi
pkg
log
...
```

Questi NON sono package Command Stub.

V0 distingue un package stub perché è un file regolare che corrisponde esattamente al canonical Command Stub schema/body previsto.

Un existing path che non è canonical package stub è trattato come protected/non-stub entry.

---

# 18. Public binding conflict with system command

Se una candidate integration vuole materializzare:

```text
bin/pkg
```

ma il path contiene un system command/non-stub:

```text
SYSTEM_COMMAND_CONFLICT
```

`pkg` non sovrascrive il file.

Lo stesso vale per qualunque non-stub existing entry nel target public pathname.

Questo evita una whitelist hard-coded separata: la physical non-stub entry è protetta.

---

# 19. Corrupt expected stub

Se active generation richiede `bin/foo` ma il pathname esiste con contenuto noncanonical/non-stub:

```text
COMMAND_STUB_CONFLICT
```

Recovery non lo sovrascrive automaticamente, perché potrebbe essere un system/user-managed entry.

Una missing stub può invece essere rigenerata automaticamente.

---

# 20. Stale canonical stub

Se un pathname contiene esattamente un canonical package Command Stub ma active generation non ha binding corrispondente:

```text
stale derived stub
```

Può essere rimosso in sicurezza perché il body non contiene state/provider autorevole.

---

# 21. Package-local `run/` recovery

`pkg/<id>/run/` è derived runtime routing view.

Per Package Instance utilizzate dalla active generation:

```text
validate expected writable-island links
rebuild missing/incorrect derived links from @package state mapping + exact State Instance
```

Non si modifica `root/`, `run-default/` o `@package`.

---

# 22. State is not purged by uninstall

```text
deintegrate
    remove integration binding

uninstall/remove Package Instance
    remove immutable Package Instance

purge-state
    explicit separate destructive operation
```

Uninstall non elimina automaticamente:

```text
conf
data
home
```

---

# 23. Cache/index recovery

Qualunque futuro index/cache del package manager deve essere rebuildable da:

```text
pkg/ physical truth
var/pkg persisted generations
state areas
```

Un index non diventa source of truth.

---

# 24. Recovery order v0

Ordine concettuale:

```text
1 bootstrap Rumi environment
2 acquire pkg manager lock per mutation recovery
3 validate/init var/pkg structural roots
4 validate active profiles/generations
5 scan/classify pkg/ children
6 cleanup safe lifecycle staging artifacts
7 reconcile package-local run/ views necessarie
8 reconcile public Command Stub Execution View
9 report remaining broken/conflict states
10 release lock
```

Recovery non esegue acquisition/download/re-resolution implicita.

---

# 25. Error classes

```text
PACKAGE_ALREADY_PRESENT
PACKAGE_IN_USE
PACKAGE_MATERIALIZATION_ERROR
PACKAGE_PUBLISH_ERROR
PACKAGE_REMOVE_ERROR
PACKAGE_STAGING_ERROR
ACTIVE_GENERATION_ERROR
SYSTEM_COMMAND_CONFLICT
COMMAND_STUB_CONFLICT
EXECUTION_VIEW_INCOMPLETE
```

---

# 26. Invarianti

```text
LC-01 initialized pkg environment ha active empty g1 valido
LC-02 materialization != integration
LC-03 dependency availability non è physical materialization precondition
LC-04 package publish è atomic visibility event
LC-05 staging package tree non è authoritative pkg child
LC-06 successful install non lascia partial pkg/<id>
LC-07 referenced Package Instance non viene rimossa
LC-08 removal usa atomic detach prima del recursive delete
LC-09 removal crash garbage resta fuori authoritative pkg/
LC-10 pkg/ immediate children restano physical truth
LC-11 active valid generation resta authoritative in recovery
LC-12 recovery non seleziona highest/newest generation implicitamente
LC-13 bin/ è derived e contiene anche protected system commands
LC-14 pkg rimuove automaticamente soltanto canonical stale package stubs
LC-15 non-stub public path conflict non viene sovrascritto
LC-16 package-local run/ è derived/rebuildable
LC-17 uninstall non implica purge-state
LC-18 recovery non esegue acquisition o re-resolution implicita
```
