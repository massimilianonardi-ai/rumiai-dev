# RumiAI package manager — Package Instance internal layout v0

Data: 2026-08-30

Stato: **design decision — struttura fisica Package Instance fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

---

# 1. Wrapper fisica

```text
pkg/<package-instance-id>/
├── root/
│   └── execution tree immutabile
├── run-default/
│   └── factory writable view immutabile
├── @package
│   JSON descriptor immutabile
├── @integrity-root.tsv
│   canonical integrity inventory di root/
├── @integrity-run-default.tsv
│   canonical integrity inventory di run-default/
└── run/
    derived active runtime routing view
```

Il core immutabile che definisce la Package Instance è:

```text
root/
run-default/
@package
@integrity-root.tsv
@integrity-run-default.tsv
```

`run/` non partecipa a identity/integrity e viene ricostruita.

---

# 2. Package Instance identity

Pathname:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

Platform v0:

```text
any
linux
macos
windows
```

Architecture v0:

```text
any
arm64
x86_64
```

La platform/architecture descrive i vincoli propri del contenuto della Package Instance.

Runtime come:

```text
Java/JRE/JDK
Python
```

NON sono platform: sono Execution Requirements/capability.

---

# 3. `root/`

`root/` è l'execution tree normalizzato e immutabile.

Prima dell'admission il producer può trasformare il tree vendor per separare writable islands.

Regola forte:

> se non è possibile produrre una `root/` che resti immutabile durante l'esecuzione normale attraverso una configurazione di link sicura e fisicamente validata, il package non è ammissibile allo store RumiAI per quella platform.

Il package manager locale assume che questa normalizzazione sia già stata completata.

---

# 4. Writable islands

Si preferiscono link a livello directory:

```text
root/log   -> ../run/log
root/conf  -> ../run/conf
root/cache -> ../run/cache
```

Questo evita che software che salva tramite unlink/rename/atomic replace cancelli un symlink file-level.

File-level redirection è ammessa solo se fisicamente validata come sicura.

---

# 5. `run-default/`

Contiene gli analoghi fisici iniziali delle writable islands distribuiti dal vendor o prodotti dalla normalizzazione.

Serve per:

```text
first state initialization
factory reset
controlled recovery
```

È immutabile.

Un factory reset copia/materializza i default nello State Instance target; non rende writable `run-default/` e non fa puntare `run/` direttamente ad essa.

---

# 6. `run/`

Ogni Package Instance ha una sola runtime view attiva.

Esempio:

```text
root/log
    -> ../run/log

run/log
    -> ../../../log/<state-id>/log
```

`run/` è precreata prima del sealing della wrapper.

Dopo il commit si ricostruisce il contenuto di `run/`, non la directory `run/` stessa.

---

# 7. `@package`

`@package` è JSON UTF-8 secondo il restricted JSON profile RumiAI v0.

Contiene logicamente:

```text
schema
identity
release
integrity metadata
state mappings
Package Interface
Execution Requirements
Environment Specification
```

Identity minima:

```text
name
version
revision
platform
architecture
display-name
```

I campi canonici devono concordare con il pathname.

`display-name` è human-readable e non entra nel pathname.

---

# 8. Integrity inventories separati

`root/` e `run-default/` hanno inventory distinti:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

`@package` contiene per ogni inventory:

```text
file name
files count
directories count
links count
manifest digest
```

L'inventory usa record TSV canonici a cinque campi:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

con `path` sempre ultimo.

Semantica:

```text
D    directory; mode; digest=-; target=-
F    regular file; mode; digest=file bytes; target=-
L    symlink; mode=-; digest=target text; target=relative target
```

Il manifest digest è il digest dei byte canonici completi del TSV.

La sotto-specifica Integrity Method 1 fissa pathname grammar, escaping, sort order, digest input e line-ending requirements.

---

# 9. Mode immutabili

Unix-like v0:

```text
regular non-executable       0400
regular executable           0500
immutable directory          0500
@package                     0400
@integrity-root.tsv          0400
@integrity-run-default.tsv   0400
```

Qualunque write bit sotto `root/` o `run-default/` viola il core immutable v0.

UID/GID non entrano nell'identity/integrity.

ACL aggiuntive, setuid, setgid e sticky bit non sono ammessi nel core Package Instance v0.

---

# 10. Environment Owner e sealing

RumiAI non richiede `root:root`, un utente `rumiai` o un gruppo speciale.

Ogni environment ha un solo Environment Owner.

Wrapper Unix-like dopo sealing:

```text
pkg/<id>/                    0500
├── root/                    0500
├── run-default/             0500
├── @package                 0400
├── @integrity-root.tsv      0400
├── @integrity-run-default.tsv 0400
└── run/                     0700
```

Le permission proteggono da modifiche accidentali; l'integrity rileva alterazioni. Non costituiscono una security boundary contro l'Environment Owner.

---

# 11. Materializzazione transazionale

```text
candidate software
        ↓
normalization/adaptation pre-admission
        ↓
build root/ + run-default/
        ↓
write @package JSON
        ↓
write canonical integrity TSV files
        ↓
verify pathname identity + descriptor identity
        ↓
verify inventory counts/digests + physical trees
        ↓
create empty run/
        ↓
normalize modes/ownership
        ↓
atomic commit into pkg/<id>
        ↓
seal wrapper
```

Staging non è una normale child directory di `pkg/`.

---

# 12. Recovery / anti-ghost

Il pathname permette sempre di ricostruire l'identità minima anche se metadata interni sono mancanti/corrotti.

Classificazione minima:

```text
HEALTHY
RECOVERABLE
IDENTITY_MISMATCH
UNKNOWN
```

Mancanza/corruzione di `@package` o degli inventory non rende il contenuto invisibile: la directory resta classificabile e segnalabile.

`pkg/` resta la physical truth delle Package Instance presenti.

---

# 13. State separation

Mutable state vive fuori dalla Package Instance:

```text
conf
data
home
cache
log
run
tmp
```

`run/` package-local è soltanto routing verso la State Instance attiva.

Uninstall della Package Instance non implica purge dello stato.

---

# 14. Invarianti

```text
PI-01 immutable Package Instance core = root + run-default + @package + two integrity TSV inventories
PI-02 run/ è derived runtime routing view
PI-03 root/ è immutable normalized execution tree
PI-04 no safe fixed root => package rejected before store promotion
PI-05 writable islands prefer directory-level relative symlink
PI-06 run-default conserva immutable factory writable view
PI-07 @package è JSON dichiarativo e immutabile
PI-08 root e run-default inventory sono file TSV distinti
PI-09 TSV record = fixed five fields, path last
PI-10 manifest digest verifica i byte canonici del TSV
PI-11 wrapper viene sigillata, run/ precreata e writable nel contenuto
PI-12 UID/GID concreti non fanno parte di identity/integrity
PI-13 mutable application state resta fuori dalla Package Instance
PI-14 Package Instance platform descrive il contenuto; runtime/interpreter sono requirements
```
