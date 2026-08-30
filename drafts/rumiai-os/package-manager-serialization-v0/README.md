# RumiAI package manager — serialization v0

Data: 2026-08-30

Stato: **design decision — configurazione gerarchica + dati tabellari fissati**

Prerequisiti:

```text
drafts/rumiai-os/system-field-format-v0/README.md
drafts/rumiai-os/system-tabular-data-v0/README.md
drafts/rumiai-os/package-manager-integrity-method-1/README.md
```

JSON resta lo standard del development/application layer RumiAI. `pkg` appartiene al system layer e non dipende da parser JSON.

---

# 1. Due famiglie di file

`pkg` distingue semanticamente:

```text
CONFIGURATION / METADATA / CONTROL STATE
    System Configuration Field Format (SCF)
    field-name<TAB>field-value
    dot notation

TABULAR DATA
    System Tabular Data (STD)
    header TSV
    una riga per record
```

Non si tenta di rappresentare dataset tabellari come migliaia di field di configurazione.

---

# 2. File SCF di pkg

Usano SCF almeno:

```text
pkg configuration
@package
Desired Integration Profile
Resolution Snapshot / resolved state
active generation state
selection policy persistita
altri metadata/control-state gerarchici letti da pkg
```

Esempio:

```text
kind	package
schema	1
identity.name	netbeans
identity.version	26
identity.revision	1
identity.platform	any
identity.architecture	any
release.order	26
```

---

# 3. Dot notation

Field gerarchico:

```text
identity.name
integrity.root.manifest_digest
requirements.1.constraint
interface.commands.2.executable.source
```

Named segment:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Array index segment:

```text
[1-9][0-9]*
```

Identificatori arbitrari restano nei value.

---

# 4. Collection SCF

Ogni array usa count esplicito + indici contigui:

```text
requirements.count	1
requirements.1.id	jdk
requirements.1.target	capability
requirements.1.capability	java-development-kit
requirements.1.contract	1
requirements.1.constraint	>=17 <22
```

Array annidato:

```text
interface.provides.count	1
interface.provides.1.resources.count	3
interface.provides.1.resources.1.key	command
```

---

# 5. Structured reference SCF

Nessuna mini-language nei value.

Dependency reference:

```text
environment.1.value.source	dependency
environment.1.value.slot	jdk
environment.1.value.resource_type	directory
environment.1.value.resource	home
```

Literal:

```text
interface.commands.1.args.1.source	literal
interface.commands.1.args.1.value	-jar
```

---

# 6. `@package`

Path:

```text
pkg/<package-instance-id>/@package
```

SCF parziale:

```text
kind	package
schema	1
identity.name	netbeans
identity.version	26
identity.revision	1
identity.platform	any
identity.architecture	any
identity.display_name	NetBeans 26
release.order	26
integrity.method	1
integrity.algorithm	sha256
integrity.root.inventory	@integrity-root.tsv
integrity.root.files	120
integrity.root.directories	24
integrity.root.links	3
integrity.root.manifest_digest	...
```

`@package` è dichiarativo, immutabile e non viene source/eval.

---

# 7. Integrity = tabular data

Gli inventory:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

sono System Tabular Data, NON SCF.

Header canonico Integrity Method 1:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

Esempio:

```text
type	mode	digest	target	path
D	0500	-	-	.
D	0500	-	-	./bin
F	0500	<digest>	-	./bin/foo
L	-	<digest-target>	../run/log	./log
```

Una filesystem entry corrisponde a una data row.

`path` resta l'ultima colonna.

---

# 8. Integrity Method 1

Restano normative:

```text
Unicode ammesso
NFC canonical form
portable case-fold collision detection
TAB/CR/LF/NUL/backslash vietati nei pathname e symlink target
/ unico separator
path `.` oppure `./...`
symlink target relativo
nessun escape fuori dalla Package Instance wrapper
canonical row ordering
```

NFC/full case-fold richiedono primitive bootstrap/validator dedicate perché non sono implementabili portabilmente in puro POSIX `sh`.

---

# 9. Integrity whole-file digest

`manifest_digest` è il digest dei byte canonici completi del TSV.

Partecipa anche la prima riga header:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path<LF>
```

Il digest include:

```text
header
TAB
LF
all data rows
canonical row order
final LF
```

---

# 10. Desired / resolved

Path:

```text
var/pkg/profiles/<profile>/generations/gN/desired
var/pkg/profiles/<profile>/generations/gN/resolved
```

Entrambi sono SCF.

Resolved parziale:

```text
kind	profile_resolved
schema	1
generation	17
profile	default
dependencies.count	1
dependencies.1.consumer	netbeans@26@r1@any-any
dependencies.1.slot	jdk
dependencies.1.provider	temurin@21.0.8+9@r1@linux-arm64
dependencies.1.capability	java-development-kit
dependencies.1.contract	1
dependencies.1.satisfied_version	21
```

---

# 11. Active

`active` è un piccolo control-state SCF:

```text
kind	active
schema	1
generation	17
```

L'atomic replace del file resta la sola operazione che attiva una generation completamente validata.

---

# 12. Query model

Per SCF:

```text
rumi_conf_get
rumi_conf_has
rumi_conf_namespace
rumi_conf_validate
```

Per STD:

```text
rumi_table_validate
rumi_table_rows
rumi_table_filter
```

Il package manager non implementa parser ad hoc per ogni file.

---

# 13. Performance rule

Configurazioni/metadata: lookup puntuali o per namespace.

Dataset tabellari grandi: single-pass row streaming.

Vietato trasformare un inventory da N entry in O(N) namespace con più righe per entry quando una riga tabellare rappresenta naturalmente il record.

---

# 14. Immutabilità

Core immutabile Package Instance:

```text
root/
run-default/
@package
@integrity-root.tsv
@integrity-run-default.tsv
```

`@package` = SCF.

Inventory = canonical STD.

---

# 15. Tooling principle

`pkg` non richiede:

```text
JSON parser
Python
Node.js
jq
```

Il bootstrap Rumi fornisce primitive SCF/STD comuni.

---

# 16. Invarianti

```text
SER-01 pkg distingue configuration/metadata da tabular data
SER-02 SCF = field-name<TAB>field-value + dot notation
SER-03 @package/desired/resolved/active usano SCF
SER-04 SCF collection = count + indici contigui 1..N
SER-05 arbitrary IDs restano nei value
SER-06 structured references usano namespace SCF, non mini-language
SER-07 integrity inventory usa STD con header
SER-08 integrity header = type,mode,digest,target,path nell'ordine fissato
SER-09 one filesystem entry = one inventory data row
SER-10 path è ultima colonna inventory
SER-11 manifest digest include header + tutte le row + final LF
SER-12 root e run-default hanno inventory distinti
SER-13 nessuna dipendenza JSON/Python/Node/jq nel package-manager system layer
```
