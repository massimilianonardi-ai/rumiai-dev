# RumiAI package manager — serialization v0

Data: 2026-08-30

Stato: **design decision — System Field Format v0 fissato per tutti i file dati `pkg`**

Prerequisiti:

```text
drafts/rumiai-os/system-field-format-v0/README.md
drafts/rumiai-os/package-manager-integrity-method-1/README.md
```

Questa specifica sostituisce le precedenti rappresentazioni TOML/JSON del package manager.

JSON resta lo standard strutturato del development/application layer RumiAI, ma non è una dipendenza del system layer né di `pkg`.

---

# 1. Principio

`pkg` è un tool del RumiAI system layer, implementato in POSIX `sh` e avviato tramite shebang/bootstrap Rumi.

Tutti i **file dati/configurazione/control state parsati da `pkg`** usano System Field Format v0:

```text
field-name<TAB>field-value
```

Questo include:

```text
pkg configuration
@package
@integrity-root.tsv
@integrity-run-default.tsv
Desired Integration Profile
Resolution Snapshot / resolved state
active generation pointer
selection policy persistita
altri metadata persistiti letti da pkg
```

Non sono file dati e quindi non usano System Field Format:

```text
script POSIX sh
Command Stub
filesystem directory/symlink
manager.lock usato esclusivamente come OS lock handle
```

---

# 2. Header comune

Ogni file machine-readable di `pkg` dichiara almeno:

```text
kind	<canonical-kind>
schema	<positive-integer>
```

Esempi kind v0:

```text
pkg_config
package
integrity
profile_desired
profile_resolved
active
```

`kind` permette di rilevare un file valido nel formato base ma aperto con lo schema sbagliato.

---

# 3. Collezioni

Ogni struttura ripetibile usa:

```text
<prefix>_count	N
<prefix>_1_...
<prefix>_2_...
...
<prefix>_N_...
```

Gli indici sono contigui `1..N`, base 10, senza zero iniziali.

Empty collection:

```text
requirement_count	0
```

Nested collection:

```text
interface_provide_count	1
interface_provide_1_resource_count	3
interface_provide_1_resource_1_key	command
```

L'ordine semantico di una sequenza è dato dagli indici, non dalla posizione fisica delle righe.

---

# 4. Arbitrary identifiers

Package ID, logical ID, provider name, capability name e altri valori arbitrari restano sempre `field-value`.

Non vengono incorporati dinamicamente nei field-name.

Corretto:

```text
selector_1_id	default-java
selector_1_provider_1	microsoft-openjdk
```

Da non fare:

```text
selector_default-java_provider_...
```

Questo mantiene tutti i field-name conformi alla grammar POSIX:

```text
[A-Za-z_][A-Za-z0-9_]*
```

---

# 5. `@package`

Pathname fisico:

```text
pkg/<package-instance-id>/@package
```

Esempio parziale:

```text
kind	package
schema	1
identity_name	netbeans
identity_version	26
identity_revision	1
identity_platform	any
identity_architecture	any
identity_display_name	NetBeans 26
release_order	26
integrity_method	1
integrity_algorithm	sha256
integrity_root_inventory	@integrity-root.tsv
integrity_root_files	120
integrity_root_directories	24
integrity_root_links	3
integrity_root_manifest_digest	...
```

Il descriptor resta dichiarativo e immutabile.

---

# 6. Structured reference

Le reference non usano mini-language nel value.

Esempio dependency reference:

```text
environment_1_value_source	dependency
environment_1_value_slot	jdk
environment_1_value_resource_type	directory
environment_1_value_resource	home
```

Esempio literal:

```text
interface_command_1_arg_1_source	literal
interface_command_1_arg_1_literal	-jar
```

---

# 7. Integrity inventory

I due file:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

restano separati per i due tree ma usano anch'essi System Field Format v0 a due campi.

Non esiste più il precedente record a cinque colonne.

Esempio:

```text
kind	integrity
schema	1
directory_count	2
directory_1_path	.
directory_1_mode	0500
directory_2_path	./bin
directory_2_mode	0500
file_count	1
file_1_path	./bin/foo
file_1_mode	0500
file_1_digest	<digest>
link_count	1
link_1_path	./log
link_1_target	../run/log
link_1_digest	<digest-target>
```

Ogni collection è indicizzata secondo l'ordine canonico dei pathname definito da Integrity Method 1.

Il manifest digest è il digest dei byte canonici completi del relativo inventory System Field Format.

---

# 8. Integrity Method 1

Restano valide le regole pathname/target già fissate:

```text
Unicode ammesso
NFC canonical form
portable case-fold collision detection
TAB/CR/LF/NUL/backslash vietati nei pathname e symlink target
/ unico separator
path `.` oppure `./...`
symlink target relativo
nessun escape fuori dalla Package Instance wrapper
```

La normalizzazione Unicode/full case-fold non è implementabile portabilmente in puro POSIX `sh`; il bootstrap Rumi deve quindi esporre la primitive normativa necessaria oppure delegarla a un validator/producer fidato. La scelta bootstrap è separata dalla serializzazione.

---

# 9. Manifest digest

`manifest-digest` verifica i byte canonici dell'intero inventory file.

Dipende quindi da:

```text
canonical field order definito dallo schema integrity
field-name
TAB
field-value
LF
final LF
```

Per collection indicizzate il canonical writer usa ordine numerico `1..N`, non ordinamento lessicografico dei field-name.

---

# 10. Immutabilità

Core immutabile Package Instance:

```text
root/
run-default/
@package
@integrity-root.tsv
@integrity-run-default.tsv
```

`run/` resta derivata.

Unix-like default:

```text
@package                    0400
@integrity-root.tsv         0400
@integrity-run-default.tsv  0400
```

---

# 11. Desired / resolved state

Pathname:

```text
var/pkg/profiles/<profile>/generations/gN/desired
var/pkg/profiles/<profile>/generations/gN/resolved
```

Entrambi usano System Field Format v0.

Esempio resolved parziale:

```text
kind	profile_resolved
schema	1
generation	17
profile	default
dependency_count	1
dependency_1_consumer	netbeans@26@r1@any-any
dependency_1_slot	jdk
dependency_1_provider	temurin@21.0.8+9@r1@linux-arm64
dependency_1_capability	java-development-kit
dependency_1_contract	1
dependency_1_satisfied_version	21
```

---

# 12. Active pointer

Anche `active` usa lo stesso formato:

```text
kind	active
schema	1
generation	17
```

L'atomic replace del file resta la sola operazione che attiva una generation completamente validata.

Non esiste più una seconda grammatica `g17\n` specifica per questo file.

---

# 13. Performance rule

`rumi_file_get` può essere usato per pochi lookup puntuali.

Collection grandi NON vengono elaborate tramite repeated full-file lookup.

Si usa:

```text
<count>
+
rumi_file_fields <file> <prefix>
```

con singola passata streaming.

Questo vale in particolare per:

```text
resolved dependency graph
integrity inventories
resource collection grandi
```

Il bootstrap può usare POSIX `awk` o una primitive equivalente senza introdurre un parser diverso.

---

# 14. Tooling principle

Il package manager non richiede:

```text
JSON parser
Python
Node.js
jq
```

per leggere il proprio stato autorevole.

Tutti i tool system-layer usano le primitive file esposte dal bootstrap Rumi.

JSON continua ad essere disponibile nel development/application layer e per tool che non appartengono al bootstrap/system layer.

---

# 15. Invarianti

```text
SER-01 tutti i file dati parsati da pkg usano System Field Format v0
SER-02 record base = field-name<TAB>field-value
SER-03 ogni file machine-readable dichiara kind + schema
SER-04 field-name segue grammar POSIX variable name
SER-05 arbitrary IDs/keys restano nei value
SER-06 collection = count + indici contigui 1..N
SER-07 structured reference viene flattenata in field strutturali, non mini-language
SER-08 @package usa System Field Format
SER-09 desired/resolved usano System Field Format
SER-10 active usa System Field Format
SER-11 integrity inventory usa System Field Format a due campi
SER-12 root e run-default hanno inventory distinti
SER-13 manifest digest = digest dei byte canonici del relativo inventory
SER-14 large collection usa streaming/per-prefix, non repeated get
SER-15 nessuna dipendenza JSON/Python/Node/jq nel package-manager system layer
```
