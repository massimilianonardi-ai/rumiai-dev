# RumiAI system layer — transaction primitives v0

Data: 2026-08-30

Stato: **architectural contract — v0**

Questa specifica definisce le primitive transazionali che il bootstrap/platform adapter RumiAI deve esporre ai tool system-layer, in particolare a `pkg`.

Obiettivo:

> separare la semantica transazionale RumiAI dalle API specifiche di Linux/macOS/Windows/filesystem.

---

# 1. Perché sono bootstrap primitives

POSIX `sh` non standardizza in modo sufficiente:

```text
advisory/exclusive process lock
fsync file
fsync directory
atomic replace con semantics uniformi
crash durability
```

`pkg` non deve scegliere direttamente fra:

```text
flock
fcntl
lockf
MoveFileEx
ReplaceFile
sync utility variants
platform-specific helper
```

Queste differenze appartengono al bootstrap/platform adapter RumiAI.

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
release automatico alla terminazione/crash del holder
blocking o explicit busy result secondo API
lock file contents non autorevoli
```

La mera esistenza del pathname non indica ownership.

---

# 3. Lock API semantica

Forma astratta ammessa:

```text
RumiAI_lock_acquire <path>
RumiAI_lock_release <handle>
```

oppure una forma scoped:

```text
RumiAI_lock_with <path> <callback> [args...]
```

La physical API finale può scegliere la forma più affidabile per POSIX sh, purché conservi le stesse invarianti.

Per `pkg` v0 esiste un solo mutation lock, quindi non serve progettare lock ordering multiplo.

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
staging e final parent nello stesso filesystem
final diventa visibile come unità
non esiste partial generation tree visibile come gN
final target preesistente = errore
```

È usata per:

```text
@staging... -> gN
```

Single manager lock rende sufficiente una precondition check contro collisioni non malevole; Environment Owner non è security boundary.

---

# 6. File durability

Primitive:

```text
RumiAI_file_sync <file>
```

Dopo successo, il bootstrap/platform adapter RumiAI garantisce il livello di durability definito e fisicamente validato per la reference platform/filesystem.

La write API non confonde `close` con durable flush.

---

# 7. Directory durability

Primitive:

```text
RumiAI_directory_sync <directory>
```

Serve dove filesystem/OS richiede sync del parent directory per rendere durable:

```text
new entry
rename
replace
unlink
```

Se una reference platform implementa durability con primitive diversa, l'adapter mantiene la stessa semantica esterna.

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

Durability complete quando anche la necessaria parent durability primitive ha avuto successo.

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

---

# 13. Crash recovery implications

Dopo crash possono esistere:

```text
staging tree
committed inactive gN
temporary active file
old active
new active
```

Regole:

```text
valid active è authoritative
committed inactive generation non diventa active automaticamente
staging/temp sono recovery artifacts
highest gN/mtime non viene scelto automaticamente
```

---

# 14. Physical Platform Validation

Ogni Reference Installation/filesystem valida almeno:

```text
exclusive lock correctness
automatic lock release after process termination
atomic replace visibility
atomic generation publish visibility
file durability primitive
directory durability primitive
behavior after forced process termination in defined test points
same-filesystem preconditions
```

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
TX-02 manager lock è exclusive e process-scoped
TX-03 lock ownership non deriva dalla mera esistenza del file
TX-04 lock viene rilasciato alla terminazione/crash del holder
TX-05 active viene sostituito atomicamente, non modificato inplace
TX-06 generation staging viene pubblicata atomicamente come gN
TX-07 committed gN e active switch sono due eventi distinti
TX-08 file/directory durability sono esplicite
TX-09 reader vede old oppure new complete active state
TX-10 valid active resta authoritative dopo recovery
TX-11 Physical Platform Validation copre OS+filesystem+mount semantics
TX-12 namespaced RumiAI shell APIs use exact RumiAI_* namespace
```
