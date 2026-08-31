# RumiAI system layer — transaction primitives v0

Data: 2026-08-30

Stato: **architectural contract — v0**

Questa specifica definisce le primitive transazionali che il bootstrap/platform adapter RumiAI deve esporre ai tool system-layer, in particolare a `pkg`.

Obiettivo:

> separare la semantica transazionale RumiAI dalle API specifiche di Linux/macOS/Windows/filesystem.

---

# 1. Perché sono bootstrap primitives

POSIX `sh` non espone direttamente tutte le system interface necessarie per:

```text
advisory/exclusive process lock
per-file fsync
per-directory fsync
atomic replace con semantics uniformi
crash durability
```

`pkg` non deve scegliere direttamente fra:

```text
flock
lockf
fcntl
sync utility variants
platform-specific helper
```

Queste differenze appartengono al bootstrap/platform adapter RumiAI.

La v0 privilegia facility già presenti sulle reference installation e meccanismi filesystem/kernel-backed, evitando di introdurre un nuovo runtime o helper compilato quando non necessario.

---

# 2. Global package-manager mutation lock

Lock logico:

```text
RUMIAI_ROOT/run/@rumiai/pkg/manager.lock
```

Semantica richiesta:

```text
exclusive
process-scoped ownership
no two successful holders contemporaneamente
release alla chiusura del descriptor e alla terminazione/crash del holder
explicit busy result quando il lock non è immediatamente disponibile
lock file contents non autorevoli
mera esistenza del pathname != ownership
```

Il lock file può quindi rimanere fisicamente presente dopo il rilascio. È il kernel lock associato al descriptor aperto, non l'esistenza del file, a rappresentare ownership.

---

# 3. Lock API e implementazione v0

API:

```text
RumiAI_lock_acquire <path>
RumiAI_lock_release <handle>
```

La v0 ha un solo mutation lock e riserva il file descriptor:

```text
9
```

per tutta la durata del lock.

Dopo `RumiAI_lock_acquire` riuscita:

```text
RumiAI_LOCK_HANDLE=9
RumiAI_LOCK_PATH=<canonical-lock-path>
```

Il caller usa quindi:

```sh
RumiAI_lock_acquire "$path"
handle=$RumiAI_LOCK_HANDLE
...
RumiAI_lock_release "$handle"
```

L'acquire deve essere invocata direttamente nella shell corrente, non tramite command substitution o un subshell che terminerebbe immediatamente dopo la chiamata.

Physical implementation corrente:

```text
Linux
    open lock file on fd 9
    flock non-blocking on fd 9

macOS
    open lock file on fd 9
    lockf non-blocking on fd 9
```

Entrambe le implementazioni usano un descriptor già aperto dalla shell. Il lock pathname resta non autorevole e non viene usato come stale-lock marker.

Busy viene normalizzato nello status RumiAI:

```text
1 = lock busy
```

Errori di uso/API restano `2`; errori host/I/O `3`.

`RumiAI_lock_release` chiude il descriptor riservato e rimuove lo stato shell `RumiAI_LOCK_HANDLE` / `RumiAI_LOCK_PATH`.

Poiché la v0 ha un solo mutation lock, non viene introdotto lock ordering multiplo.

---

# 4. Atomic file replace

Primitive semantica:

```text
RumiAI_atomic_replace <prepared-file> <target-file>
```

Precondizione:

```text
prepared-file e target parent sono sullo stesso filesystem/domain atomicamente sostituibile
```

Semantica:

```text
reader concorrente vede old target oppure new target
mai contenuto parziale/intermedio
target pathname finale resta invariato
operation failure non lascia target parzialmente scritto
```

È usata per `active`.

La primitive v0 corrente è implementata per source/destination nella stessa directory. La relativa evidenza di Physical Platform Validation resta associata alle revisioni effettivamente esercitate.

---

# 5. Atomic publish/rename directory

Primitive semantica:

```text
RumiAI_atomic_publish <staging-path> <final-path>
```

Semantica:

```text
mutation lock RumiAI già acquisito
staging e final hanno lo stesso parent canonicale
staging è una directory reale, non symlink
final diventa visibile come unità
non esiste partial generation tree visibile come gN
final target preesistente = errore
```

È usata per:

```text
@staging... -> gN
```

La v0 usa il rename filesystem eseguito tramite `mv` nello stesso parent. Il precheck `final absent` è sufficiente nel modello cooperativo RumiAI perché l'operazione avviene sotto il singolo manager lock; l'Environment Owner non è un security boundary.

La primitive è implementata ma resta da Physical Platform Validation sulle reference installation correnti.

---

# 6. File durability

Primitive:

```text
RumiAI_file_sync <file>
```

La v0 valida che l'argomento sia un regular file reale e usa la facility host:

```text
sync
```

senza pathname operands.

Questa scelta produce intenzionalmente una barriera globale più ampia del singolo file. Il maggiore scope è accettato nella v0 per evitare una nuova dipendenza runtime o un helper compilato soltanto per esporre `fsync()` alla shell.

L'API resta distinta semanticamente: un'implementazione futura potrà sostituire la barriera globale con una primitive per-path più efficiente, senza modificare `pkg`, purché preservi o rafforzi il contratto e venga fisicamente validata.

La primitive è implementata ma resta da Physical Platform Validation sulle reference installation/filesystem correnti.

---

# 7. Directory durability

Primitive:

```text
RumiAI_directory_sync <directory>
```

La v0 valida che l'argomento sia una directory reale e usa la stessa barriera host globale:

```text
sync
```

Quindi `RumiAI_file_sync` e `RumiAI_directory_sync` hanno responsabilità semantiche distinte per il caller ma condividono deliberatamente la stessa physical implementation v0.

La scelta evita di introdurre un helper nativo esclusivamente per ottenere un directory `fsync()` da POSIX shell. Se in futuro servirà una garanzia o efficienza più specifica, l'adapter potrà cambiare senza contaminare il package manager.

La primitive è implementata ma resta da Physical Platform Validation sulle reference installation/filesystem correnti.

---

# 8. Atomic write pattern

Per un piccolo control-state file:

```text
1 create temp in target parent
2 write complete canonical content
3 close
4 RumiAI_file_sync temp
5 RumiAI_atomic_replace temp -> target
6 RumiAI_directory_sync target parent
```

Il target non viene modificato inplace.

Nella physical implementation v0 i punti 4 e 6 usano entrambi una barriera globale `sync`; restano due step semantici distinti nel protocollo.

---

# 9. Generation publish pattern

Sotto manager lock:

```text
1 build staging generation under generations/
2 write desired/resolved completely
3 sync desired/resolved
4 apply final read-only modes
5 sync staging directory metadata as required
6 RumiAI_atomic_publish staging -> gN
7 RumiAI_directory_sync generations/
```

Dopo il punto 6 `gN` è committed/inactive anche se non è active.

---

# 10. Active switch pattern

Dopo generation publish e stub preparation:

```text
1 build temporary active SCF in profile directory
2 sync temporary active
3 RumiAI_atomic_replace temp -> active
4 RumiAI_directory_sync profile directory
```

Il semantic commit point è l'atomic replace di `active`.

Durability complete quando anche la necessaria parent durability primitive ha avuto successo secondo il livello garantito e fisicamente validato dalla physical implementation corrente.

---

# 11. Reader rule

Launcher:

```text
open active once
read complete file
validate SCF
close
use generation N for entire launch
```

Concurrent atomic replace produce old oppure new complete active state.

Launcher non mantiene pathname temp e non rilegge active nello stesso launch.

---

# 12. Failure classes

Distinzione minima:

```text
LOCK_ERROR
LOCK_BUSY
SYNC_ERROR
ATOMIC_REPLACE_ERROR
ATOMIC_PUBLISH_ERROR
TRANSACTION_PRECONDITION_ERROR
```

Il caller non deve inferire la causa leggendo output specifico del comando host sottostante.

Il platform API v0 normalizza inoltre gli status tecnici come segue:

```text
0 success
1 negative/not-found/busy
2 invalid/precondition/unsupported input
3 host/I/O failure
```

---

# 13. Crash recovery implications

Dopo crash possono esistere:

```text
staging tree
committed inactive gN
temporary active file
old active
new active
persistent non-authoritative manager.lock pathname
```

Regole:

```text
valid active è authoritative
committed inactive generation non diventa active automaticamente
staging/temp sono recovery artifacts
manager.lock pathname non prova ownership
highest gN/mtime non viene scelto automaticamente
```

---

# 14. Physical Platform Validation

Ogni Reference Installation/filesystem valida almeno:

```text
exclusive lock correctness
busy result while another holder owns the lock
reacquire after explicit release
automatic kernel lock release after holder termination
host sync facility callable independently dal RumiAI PATH
atomic replace visibility
atomic generation publish/rejection behavior
same-parent/same-filesystem preconditions
```

Per la v0, `file_sync` e `directory_sync` usano la barriera globale dell'host; la validation registra quindi esattamente quella physical implementation e non attribuisce retroattivamente semantiche per-file non esercitate.

Validation target è:

```text
OS + filesystem + mount semantics
```

non soltanto OS name.

---

# 15. No security-boundary claim

Le primitive proteggono consistency/concurrency/crash behavior del RumiAI Environment Owner.

Non costituiscono security boundary contro lo stesso Environment Owner che modifica direttamente filesystem/processi.

---

# 16. Naming invariant

Le funzioni shell namespaced RumiAI usano sempre:

```text
RumiAI_*
```

Abbreviazioni conversazionali non definiscono command, namespace o API.

---

# 17. Invarianti

```text
TX-01 pkg usa bootstrap transaction API, non OS-specific locking code
TX-02 manager lock è exclusive e kernel-backed
TX-03 lock ownership non deriva dalla mera esistenza del file
TX-04 lock viene rilasciato chiudendo fd 9 e alla terminazione/crash del holder
TX-05 active viene sostituito atomicamente, non modificato inplace
TX-06 generation staging viene pubblicata atomicamente come gN sotto manager lock
TX-07 committed gN e active switch sono due eventi distinti
TX-08 file/directory durability restano API semanticamente esplicite
TX-09 physical sync v0 usa una barriera host globale, senza nuovo runtime/helper
TX-10 reader vede old oppure new complete active state
TX-11 valid active resta authoritative dopo recovery
TX-12 Physical Platform Validation copre OS+filesystem+mount semantics
TX-13 namespaced RumiAI shell APIs use exact RumiAI_* namespace
TX-14 lock file contents/path existence are non-authoritative
TX-15 v0 reserves fd 9 only while the manager lock is held
```
