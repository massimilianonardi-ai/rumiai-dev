# RumiAI package manager — System Field Format stress test

Data: 2026-08-30

Stato: **design analysis — verifica di rappresentabilità/praticità prima della conversione completa dei file `pkg`**

Obiettivo:

> verificare che tutti i file dati letti dal package manager `pkg`, implementato in POSIX `sh`, possano usare System Field Format v0 senza reintrodurre parser complessi, mini-language nascoste nei value o pattern inefficienti.

Sono esclusi perché non sono file dati parsati:

```text
script POSIX sh
Command Stub
filesystem directory/symlink
manager.lock usato soltanto come OS lock handle
```

---

# 1. Conclusione

Il formato a due campi è sufficiente per rappresentare tutti gli oggetti logici già fissati:

```text
pkg configuration
@package
integrity inventories
desired profile
resolved generation
active generation pointer
selection policy
Package Interface
capability provides
requirements
environment
Launch Template
resolved dependency graph
public bindings
```

Non è necessaria una seconda sintassi dati.

La rappresentazione resta pratica a condizione di fissare:

```text
1. collection count obbligatorio
2. indici contigui 1..N
3. map key arbitrarie come value, non come field-name
4. streaming/per-prefix per collezioni grandi
5. nessun repeated full-file lookup nei loop
6. schema/kind specifici per ciascun file
```

---

# 2. Header comune consigliato

Ogni file dati machine-generated di `pkg` dovrebbe iniziare logicamente con:

```text
kind	<canonical-kind>
schema	<positive-integer>
```

Esempi:

```text
kind	package
schema	1
```

```text
kind	resolved
schema	1
```

```text
kind	active
schema	1
```

`kind` evita che un file valido secondo System Field Format venga accidentalmente interpretato con lo schema sbagliato.

`schema` versiona il contenuto logico di quel kind.

---

# 3. `@package`

La struttura JSON precedente può essere flattenata senza perdita.

Esempio concettuale:

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

state_present	true
state_compatibility_version	1
state_scope	shared
state_mapping_count	1
state_mapping_1_path	etc
state_mapping_1_area	conf
```

Non emerge alcuna incompatibilità strutturale.

---

# 4. Package Interface resources

Le resource diventano collezioni indicizzate:

```text
interface_file_count	1
interface_file_1_id	launcher
interface_file_1_path	bin/netbeans

interface_directory_count	1
interface_directory_1_id	home
interface_directory_1_path	.
```

Gli ID reali possono contenere la grammar logica prevista dallo schema e restano nei value.

---

# 5. Structured reference

Una reference non richiede una mini-language nel value.

Self:

```text
interface_command_1_executable_source	self
interface_command_1_executable_resource_type	file
interface_command_1_executable_resource	launcher
```

Dependency:

```text
environment_1_value_source	dependency
environment_1_value_slot	jdk
environment_1_value_resource_type	directory
environment_1_value_resource	home
```

State:

```text
environment_1_value_source	state
environment_1_value_area	home
```

Literal:

```text
interface_command_1_arg_1_source	literal
interface_command_1_arg_1_literal	-jar
```

Questa forma è verbosa ma semplice da validare e non richiede parsing interno del field-value.

---

# 6. Command / argv

Ordered argv usa count + index:

```text
interface_command_count	1
interface_command_1_id	app
interface_command_1_executable_source	dependency
interface_command_1_executable_slot	jvm
interface_command_1_executable_resource_type	command
interface_command_1_executable_resource	java
interface_command_1_arg_count	2
interface_command_1_arg_1_source	literal
interface_command_1_arg_1_literal	-jar
interface_command_1_arg_2_source	self
interface_command_1_arg_2_resource_type	file
interface_command_1_arg_2_resource	app_jar
```

Limitazione v0 intenzionale:

```text
argv literal contenente TAB/CR/LF/NUL -> non rappresentabile -> descriptor rejected
```

Questo è più restrittivo di argv POSIX teorico, ma evita escaping e non confligge con i casi package già modellati.

---

# 7. Capability provide con nested collection

Il caso annidato più evidente resta rappresentabile:

```text
interface_provide_count	1
interface_provide_1_capability	java-runtime
interface_provide_1_contract	1
interface_provide_1_version	21
interface_provide_1_resource_count	3
interface_provide_1_resource_1_key	command
interface_provide_1_resource_1_resource_type	command
interface_provide_1_resource_1_resource	java
interface_provide_1_resource_2_key	home
interface_provide_1_resource_2_resource_type	directory
interface_provide_1_resource_2_resource	home
interface_provide_1_resource_3_key	bin
interface_provide_1_resource_3_resource_type	directory
interface_provide_1_resource_3_resource	bin
```

Profondità e lunghezza dei field-name restano moderate per il modello v0.

---

# 8. Requirements

```text
requirement_count	1
requirement_1_slot	jdk
requirement_1_target	capability
requirement_1_capability	java-development-kit
requirement_1_contract	1
requirement_1_constraint	>=17 <22
```

Il constraint resta un value opaco per System Field Format ed è interpretato soltanto dallo schema/resolver.

Nessun problema con spazi o operatori perché TAB è l'unico delimitatore strutturale.

---

# 9. Environment

L'ordine semantico è l'indice, non l'ordine fisico delle righe:

```text
environment_count	2

environment_1_name	JAVA_HOME
environment_1_operation	set
environment_1_type	path
environment_1_value_source	dependency
environment_1_value_slot	jdk
environment_1_value_resource_type	directory
environment_1_value_resource	home

environment_2_name	PATH
environment_2_operation	prepend
environment_2_type	path-list
environment_2_value_source	dependency
environment_2_value_slot	jdk
environment_2_value_resource_type	directory
environment_2_value_resource	bin
```

Questo conserva completamente la semantica già fissata.

---

# 10. Desired selector / provider order

```text
selector_count	1
selector_1_id	default-java
selector_1_target	capability
selector_1_capability	java-runtime
selector_1_contract	1
selector_1_constraint	>=17
selector_1_selection	newest
selector_1_provider_count	2
selector_1_provider_1	temurin
selector_1_provider_2	microsoft-openjdk
selector_1_allow_other_providers	true
```

Il provider name resta value e può quindi contenere `-` senza encoding.

---

# 11. Resolved dependency graph

Il graph può crescere molto ma la struttura resta lineare:

```text
graph_count	1
graph_1_id	netbeans-graph
graph_1_root_package	netbeans@26@r1@any-any

dependency_count	1
dependency_1_graph	netbeans-graph
dependency_1_consumer	netbeans@26@r1@any-any
dependency_1_slot	jdk
dependency_1_target	capability
dependency_1_capability	java-development-kit
dependency_1_contract	1
dependency_1_constraint	>=17 <22
dependency_1_provider	temurin@21.0.8+9@r1@linux-arm64
dependency_1_satisfied_version	21
```

Problema pratico possibile:

```text
repeated rumi_file_get per ogni field/edge
```

produrrebbe rescansioni O(n²).

Soluzione normativa:

```text
read dependency_count una volta
stream dependency_ prefix una volta
oppure usare una singola passata awk/bootstrap
```

---

# 12. Active generation

Anche `active` può usare lo stesso formato:

```text
kind	active
schema	1
generation	17
```

oppure semanticamente `g17` come value se si preferisce mantenere il token completo.

L'atomic replace del file non cambia.

Questo elimina l'ultima eccezione di parsing nel control state di `pkg`.

---

# 13. Integrity inventory nel formato a due campi

Il precedente record a cinque colonne può essere sostituito senza perdere dati.

Per evitare un field `type` ridondante si usano collezioni separate:

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

Ogni collection viene indicizzata in ordine crescente del pathname canonico UTF-8 previsto da Integrity Method 1.

Il manifest digest diventa digest dei byte canonici dell'intero file System Field Format inventory.

Non serve più un parser TSV a cinque colonne distinto.

## 13.1 Overhead

Micro-benchmark engineering locale, non performance guarantee:

```text
50.000 regular files
pathname medio simulato ~50 byte
SHA-256 hex digest
```

Confronto indicativo:

```text
vecchio 5-field inventory   ~6.25 MB / 50.000 righe
2-field SFF inventory       ~8.52 MB / 150.002 righe
```

Overhead byte ~36%, ritenuto accettabile in cambio di un solo formato parser.

Sul medesimo ambiente di test, scansione di ~8.5 MB / 150k record:

```text
POSIX-style awk filter      ~0.04 s
shell while/read loop       ~2.16 s
```

Questi numeri sono soltanto orientativi, ma mostrano il pattern architetturale corretto:

> inventory grandi devono essere processati da primitive streaming/bootstrap efficienti, non da centinaia di migliaia di lookup shell individuali.

Il costo di hashing dei payload resta comunque separato e spesso dominante.

---

# 14. Field-name compatibility

La grammar POSIX:

```text
[A-Za-z_][A-Za-z0-9_]*
```

non crea problemi perché:

```text
schema structure -> field-name ASCII controllato
arbitrary package/resource/provider IDs -> field-value
Unicode -> field-value
```

Non bisogna mai generare direttamente:

```text
selector_<arbitrary-id>_...
```

Si usa sempre:

```text
selector_<numeric-index>_id	<arbitrary-id>
```

---

# 15. Ambiguità underscore

Field-name come:

```text
interface_command_10_arg_2_resource_type
```

non devono essere interpretati tramite una grammar generica che tenta di dedurre autonomamente ogni livello da `_`.

Per System Field Format il field-name è una chiave opaca valida POSIX.

È lo schema specifico a conoscere pattern/prefix previsti.

Questo evita ambiguità se un token strutturale futuro contiene underscore.

---

# 16. Canonical ordering e indice 10

Un ordinamento lessicografico puro dei field-name produrrebbe:

```text
item_1
item_10
item_2
```

quindi NON è la regola canonica delle collection indicizzate.

I generatori usano:

```text
schema-defined section order
numeric index order 1..N
schema-defined field order dentro ogni entry
```

Il generic `rumi_file_set` non deve fingere di poter canonicalizzare automaticamente qualunque schema tramite semplice `sort` alfabetico.

Per file machine-generated complessi si preferisce rigenerare l'intero documento secondo schema.

---

# 17. Human-editable configuration

`pkg.conf` può contenere commenti/blank line.

Problema pratico:

```text
rumi_file_set
```

se riscrive canonicalmente tutto il file potrebbe perdere commenti o posizione scelta dall'utente.

Decisione consigliata:

```text
machine-generated authoritative files
    full canonical regeneration

human-edited config
    setter conserva righe non-target/commenti quando possibile
    oppure configurazione editata manualmente e validata
```

Questa è una questione di editor API, non del formato.

---

# 18. POSIX sh variable-name compatibility != automatic source

Il fatto che i field-name siano shell-variable-safe non elimina un limite POSIX:

```text
POSIX sh non ha associative array
POSIX sh non ha generic indirect expansion portabile
```

Caricare arbitrariamente tutti i field come variabili richiederebbe `eval` o una trasformazione intermedia.

Il modello v0 non ne ha bisogno.

`pkg` usa le API bootstrap per lookup/streaming e tratta il file come dati.

Questo evita code injection dai field-value.

---

# 19. Unicode: incompatibilità operativa da risolvere nel bootstrap

System Field Format trasporta Unicode UTF-8 senza problemi perché i value sono byte/stringhe opache.

Esiste però una incompatibilità separata con Integrity Method 1:

```text
Unicode NFC normalization
Unicode default case-fold collision detection
```

non sono implementabili in modo completo e portabile con sole primitive POSIX `sh`/`awk`/`sed`.

Quindi una delle seguenti deve essere vera:

```text
A. bootstrap `rumi` fornisce primitive Unicode normative
oppure
B. quella parte della canonicalizzazione viene spostata fuori dal local pkg verso un producer/validator fidato
```

Raccomandazione:

> mantenere il contratto Integrity Method 1 e fornire nel bootstrap Rumi primitive Unicode, invece di restringere i pathname ad ASCII o indebolire la portabilità.

---

# 20. Altre primitive non POSIX-sh pure

Il formato non risolve da solo altre differenze platform già note:

```text
SHA-256 command/API
filesystem stat/mode query
symlink target query
exclusive file locking
fsync/durability
atomic replace semantics
```

`pkg` resta POSIX `sh`, ma queste operazioni devono essere esposte da bootstrap/platform adapter Rumi con semantica uniforme.

Non devono essere implementate tramite branching casuale in ogni tool system-layer.

---

# 21. Errori di formato/schema da distinguere

Si raccomandano almeno:

```text
FIELD_FORMAT_ERROR
DUPLICATE_FIELD
INVALID_FIELD_NAME
INVALID_FIELD_VALUE
UNSUPPORTED_SCHEMA
WRONG_FILE_KIND
MISSING_FIELD
UNKNOWN_FIELD
INVALID_COLLECTION_COUNT
INVALID_COLLECTION_INDEX
INVALID_FIELD_TYPE
```

Gli errori semantici package-manager restano separati.

---

# 22. Esito finale

Il System Field Format v0 a due campi è adatto a tutti i file dati di `pkg`.

Non sono emerse strutture già fissate che richiedano JSON, nested parser o quoting.

Le difficoltà reali sono operative e hanno soluzioni chiare:

```text
nested/repeated data
    -> count + numeric indices

arbitrary keys/IDs
    -> values, mai field-name dinamici

large files
    -> one-pass streaming/prefix API

canonical output
    -> schema order, non lexical sort

multiline/TAB values
    -> intentionally unsupported v0

Unicode normalization/case-fold
    -> bootstrap Rumi primitive

platform filesystem/digest/lock differences
    -> bootstrap/platform adapter
```

Con queste regole non vedo una incompatibilità architetturale che impedisca di convertire `@package`, desired, resolved, active e integrity inventory allo stesso formato system-layer.
