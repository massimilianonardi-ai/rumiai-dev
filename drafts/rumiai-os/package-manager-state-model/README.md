# RumiAI package manager — State model v0

Data: 2026-08-30

Stato: **design decision — State Instance e runtime mappings fissati**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
```

---

# 1. Principio

```text
Package Instance != State Instance
```

Package Instance = software/default immutabili.

State Instance = stato mutabile riusabile dalle Package Instance compatibili.

Software version change non crea/rinomina/cancella automaticamente lo state.

---

# 2. State Instance identity

```text
<pkg-name>[@<platform>-<architecture>]@s<state-compatibility-version>
```

Il qualifier platform/architecture compare soltanto quando lo state dipende da uno o entrambi.

Esempi:

```text
netbeans@s2
netbeans@linux-any@s2
foo@linux-arm64@s4
bar@any-arm64@s1
```

`state-compatibility-version` è un intero positivo RumiAI:

```text
s1 s2 s3 ...
```

ed è indipendente dalla software version.

---

# 3. Una sola State Instance per identity nel v0

Non esistono profile state paralleli nominati `default/work/test` nel v0.

Una sola State Instance per:

```text
pkg-name
+ eventuale state platform/architecture
+ state-compatibility-version
```

Una Package Instance possiede una sola `run/` attiva.

---

# 4. State scope

`@package` dichiara:

```text
shared
platform
architecture
platform-architecture
```

che producono:

```text
shared                 pkg@sN
platform               pkg@linux-any@sN
architecture           pkg@any-arm64@sN
platform-architecture  pkg@linux-arm64@sN
```

La qualificazione descrive **lo state**, non la Package Instance.

Quindi:

```text
Package Instance:
    netbeans@26@r1@any-any

State scope:
    platform

State su Linux:
    netbeans@linux-any@s2
```

Non esiste più il concetto di Package Instance `jvm-any`/`python-any`: runtime/interpreti sono requirements separati.

Regola conservativa: se una parte autorevole dello state richiede specializzazione e non è separabile, l'intera State Instance viene qualificata.

---

# 5. State areas

Set v0:

```text
conf
data
home
cache
log
run
tmp
```

Fisicamente:

```text
conf/<state-id>/
data/<state-id>/
home/<state-id>/
cache/<state-id>/
log/<state-id>/
run/<state-id>/
tmp/<state-id>/
```

Non tutte devono esistere per ogni package.

---

# 6. Classi semantiche

Persistent authoritative:

```text
conf
data
home
```

Persistent non-authoritative:

```text
cache
log
```

Transient:

```text
run
tmp
```

Semantica:

```text
conf   configurazione persistente

data   dati autorevoli non rigenerabili

home   compatibility bucket opaco/conservativo; usato quando non è possibile classificare meglio

cache  contenuto rigenerabile ma utile fra execution

log    diagnostica/storia operativa con retention propria

run    PID/socket/lock/runtime coordination

tmp    scratch/intermedi temporanei
```

`home` viene trattata come autorevole per default.

---

# 7. Package wrapper e writable islands

```text
pkg/<id>/
├── root/
├── run-default/
├── @package
└── run/
```

Per ogni writable island viene mantenuto lo stesso path relativo:

```text
root/<path>
run-default/<path>
run/<path>
```

Esempio:

```text
root/etc       -> ../run/etc
root/workspace -> ../run/workspace
root/logs      -> ../run/logs
root/temp      -> ../run/temp
```

Descriptor mappings:

```text
etc       -> conf
workspace -> data
logs      -> log
temp      -> tmp
```

`run/` materializza i link verso la State Instance attiva.

---

# 8. Runtime mapping rules

Ogni mapping contiene:

```text
writable-island-path
state-area
```

Path:

```text
relativo
canonico
no leading slash
no ..
unique
no ancestor/descendant overlap fra mappings
```

Per ogni mapping:

```text
root/<path> -> ../run/<path>
```

è già un symlink relativo sicuro validato, e:

```text
run-default/<path>
```

esiste come counterpart fisico anche se vuoto.

Admission valida:

```text
@package mapping
↕
root symlink
↕
run-default path
```

Ogni writable island appartiene esattamente a una state area.

Se upstream mescola lifecycle differenti e non è separabile, si assegna l'isola alla categoria più conservativa (`home`/`data`) oppure il package viene rifiutato se non può mantenere `root/` fissa.

---

# 9. `run-default/`

Contiene factory defaults immutabili nei path attesi dal software, non organizzati per state area.

Factory reset:

```text
conf  replace from defaults
data  replace from defaults / empty
home  replace from defaults / empty
cache clear
log   clear secondo policy
run   clear
tmp   clear
```

`run-default/` non diventa mai writable.

---

# 10. Upgrade/migration

Compatibile:

```text
A1 supports s3
A2 supports s3
→ stessa State Instance package@s3
```

Incompatibile:

```text
A2 requires s4
→ migration esplicita s3 -> s4
```

Migration e dependency re-resolution restano operazioni separate.

Rollback semplice è possibile finché la precedente Package Instance comprende ancora la State Instance disponibile.

---

# 11. Backup e cleanup

Default backup:

```text
include conf data home
exclude cache log run tmp
```

Log può essere incluso tramite policy.

Cleanup sicuro può eliminare:

```text
cache
run
tmp
```

`log` segue retention separata.

---

# 12. Deintegrate / uninstall / purge-state

```text
deintegrate
    rimuove integration/runtime binding
    non Package Instance
    non State Instance

uninstall
    rimuove Package Instance
    non State Instance automaticamente

purge-state
    distrugge esplicitamente la State Instance
```

---

# 13. Ownership/permission

Unico Environment Owner.

State area directories normalmente:

```text
0700
```

UID/GID concreti non fanno parte della State Instance identity.

Group sharing non supportato nel v0.

Default launch `umask`:

```text
0077
```

salvo futura estensione dichiarativa/fisicamente validata.

---

# 14. Physical validation

Portabilità logica dello state non implica compatibilità universale del filesystem.

Si validano sulle Reference Installation:

```text
permission
ownership
symlink/link semantics
mount/filesystem behavior
```

---

# 15. Invarianti

```text
SM-01 Package Instance != State Instance
SM-02 State Instance identity non contiene software version
SM-03 ID = <pkg-name>[@<platform>-<architecture>]@sN
SM-04 qualifier state compare solo quando necessario
SM-05 state platform/architecture è indipendente dalla Package Instance identity
SM-06 nel v0 una sola State Instance per identity
SM-07 state scope = shared | platform | architecture | platform-architecture
SM-08 state areas = conf,data,home,cache,log,run,tmp
SM-09 conf/data/home persistent authoritative
SM-10 cache/log persistent non-authoritative
SM-11 run/tmp transient
SM-12 home compatibility bucket conservativo
SM-13 ogni writable island appartiene a una sola area
SM-14 root/run-default/run condividono lo stesso path relativo per mapping
SM-15 mapping path non si sovrappongono
SM-16 run-default contiene factory defaults immutabili
SM-17 upgrade compatibile riusa state
SM-18 cambio sN richiede migration esplicita
SM-19 deintegrate != uninstall != purge-state
SM-20 UID/GID concreti non sono identity
SM-21 filesystem/mount semantics fanno parte della Physical Platform Validation
SM-22 Java/JDK/JRE/Python non determinano State Instance qualifier salvo effetti reali sullo state prodotti/validati separatamente
```
