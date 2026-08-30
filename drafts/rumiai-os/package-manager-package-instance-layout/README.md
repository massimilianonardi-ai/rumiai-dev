# RumiAI package manager — Package Instance internal layout v0

Data: 2026-08-30

Stato: **design decision — struttura fisica Package Instance fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/package-manager-integrity-method-1/README.md
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
│   System Configuration Field descriptor immutabile
├── @integrity-root.tsv
│   canonical System Tabular Data integrity inventory di root/
├── @integrity-run-default.tsv
│   canonical System Tabular Data integrity inventory di run-default/
└── run/
    derived active runtime routing view
```

Core immutabile:

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

Platform/architecture descrivono i vincoli propri del contenuto della Package Instance.

Java/JRE/JDK/Python sono Execution Requirements/capability, non platform.

---

# 3. `root/`

`root/` è execution tree normalizzato e immutabile.

Prima dell'admission il producer può trasformare il vendor tree per separare writable island.

Regola forte:

> se non è possibile produrre una `root/` fissa e immutabile durante l'esecuzione normale tramite una configurazione di link sicura e fisicamente validata, il package non è ammissibile per quella platform.

---

# 4. Writable islands

Preferenza directory-level:

```text
root/log   -> ../run/log
root/conf  -> ../run/conf
root/cache -> ../run/cache
```

File-level redirection soltanto se fisicamente validata.

---

# 5. `run-default/`

Contiene factory/default writable island contents immutabili.

Serve per:

```text
first state initialization
factory reset
controlled recovery
```

Non diventa mai writable.

---

# 6. `run/`

Una sola runtime routing view attiva per Package Instance.

Esempio:

```text
root/log
    -> ../run/log

run/log
    -> ../../../log/<state-id>/log
```

`run/` è precreata prima del sealing; si ricostruisce il contenuto, non normalmente la directory stessa.

---

# 7. `@package`

`@package` usa System Configuration Field Format v0.

Esempio:

```text
kind	package
schema	1
identity.name	netbeans
identity.version	26
identity.revision	1
identity.platform	any
identity.architecture	any
identity.display_name	NetBeans 26
```

Contiene logicamente:

```text
identity
release
integrity metadata
state mappings
Package Interface
Execution Requirements
Environment Specification
```

I campi identity canonici devono concordare col pathname.

---

# 8. Integrity inventories

`root/` e `run-default/` hanno inventory separati:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

Sono dataset System Tabular Data, una row per filesystem entry.

Header canonico:

```text
type	mode	digest	target	path
```

Esempio:

```text
type	mode	digest	target	path
D	0500	-	-	.
F	0500	<digest>	-	./bin/foo
L	-	<digest-target>	../run/log	./log
```

`@package` contiene inventory filename, count e manifest digest.

Il manifest digest verifica i byte canonici completi del TSV, **header incluso**.

---

# 9. Integrity Method 1

Normativo:

```text
UTF-8 + Unicode NFC
TAB/CR/LF/NUL/backslash vietati nei pathname e symlink target
nessun quoting/escaping
pathname `.` oppure `./...`
collision check NFC + Unicode case-fold + NFC
symlink target relativo; `..` ammesso quando semanticamente valido
nessun symlink inventariato può risolvere fuori dalla wrapper
row ordinate per canonical pathname UTF-8 bytes
LF finale obbligatorio
```

NFC/full case-fold richiedono primitive bootstrap/validator dedicate.

---

# 10. Mode immutabili

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

UID/GID non entrano identity/integrity.

ACL aggiuntive, setuid, setgid e sticky bit non sono ammessi nel core v0.

---

# 11. Environment Owner e sealing

Un solo Environment Owner.

Wrapper Unix-like dopo sealing:

```text
pkg/<id>/                       0500
├── root/                       0500
├── run-default/                0500
├── @package                    0400
├── @integrity-root.tsv         0400
├── @integrity-run-default.tsv  0400
└── run/                        0700
```

Permission = protezione accidentale, non security boundary contro Environment Owner.

---

# 12. Materializzazione transazionale

```text
candidate software
        ↓
normalization/adaptation pre-admission
        ↓
build root/ + run-default/
        ↓
canonicalize/validate pathname + symlink target
        ↓
write @package SCF
        ↓
write canonical integrity TSV with header
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

# 13. Recovery / anti-ghost

Classificazione minima di ogni child `pkg/`:

```text
HEALTHY
RECOVERABLE
IDENTITY_MISMATCH
UNKNOWN
```

Mancanza/corruzione di `@package` o inventory non rende la directory invisibile.

`pkg/` resta physical truth.

---

# 14. State separation

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

Uninstall Package Instance non implica purge state.

---

# 15. Invarianti

```text
PI-01 immutable core = root + run-default + @package + two integrity inventories
PI-02 run/ è derived runtime routing view
PI-03 root/ è immutable normalized execution tree
PI-04 no safe fixed root => package rejected
PI-05 writable islands prefer directory-level relative symlink
PI-06 run-default conserva immutable factory writable view
PI-07 @package usa System Configuration Field Format
PI-08 integrity inventory usa System Tabular Data con header
PI-09 one filesystem entry = one inventory data row
PI-10 inventory header = type,mode,digest,target,path
PI-11 path è ultima colonna
PI-12 manifest digest include header + rows + final LF
PI-13 Integrity Method 1 mantiene Unicode NFC/case-fold/path rules
PI-14 wrapper viene sigillata; run/ precreata e writable nel contenuto
PI-15 UID/GID concreti non fanno parte di identity/integrity
PI-16 mutable application state resta fuori dalla Package Instance
PI-17 Package Instance platform descrive il contenuto; runtime/interpreter sono requirements
```
