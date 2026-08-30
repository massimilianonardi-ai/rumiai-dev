# RumiAI package manager — serialization v0

Data: 2026-08-30

Stato: **design decision — serializzazione v0 fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
```

Questo documento fissa la rappresentazione testuale v0 di:

```text
@package
resolved / desired state persistente
```

senza cambiare il modello logico già definito.

---

# 1. Formato scelto: TOML

RumiAI v0 usa **TOML 1.0** come formato di serializzazione per metadata dichiarativi del package manager.

Lo stesso formato viene usato per:

```text
@package
Desired Integration Profile
Resolution Snapshot / resolved state
Selection Policy persistita
```

Motivazioni:

```text
parser standard disponibili su Linux/macOS/Windows
formato dichiarativo, non eseguibile
strutture tipizzate
buona leggibilità umana
duplicate key non ammesse
supporto naturale a table, array e array-of-table
un solo parser/config model nel package manager
```

Non vengono usati nel v0:

```text
YAML
    alias/tag/implicit typing e superficie parser non necessaria

JSON
    valido tecnicamente, ma meno leggibile per descriptor complessi e strutture ripetute

formato RumiAI generale proprietario
    evitato per non creare un parser/config language senza necessità
```

L'inventory di integrità mantiene comunque una grammatica line-oriented propria **dentro valori TOML**, perché è un dominio specifico già definito e può contenere molte migliaia di entry.

---

# 2. Restricted TOML profile RumiAI v0

RumiAI non usa necessariamente tutta la superficie dati TOML.

Tipi ammessi nel modello v0:

```text
UTF-8 string
base-10 integer
boolean
array
table
array of tables
```

Non sono usati nei file v0:

```text
float
NaN / infinity
date
time
datetime
```

Un serializer RumiAI deve emettere interi in base 10.

Le chiavi duplicate sono errore.

Un parser che incontra uno `schema` non supportato deve rifiutare il documento; non deve tentare di reinterpretarlo euristicamente.

Nel medesimo schema v0, chiavi strutturali sconosciute sono errore per default: questo evita che un typo venga silenziosamente ignorato.

I commenti TOML possono esistere ma non hanno significato semantico.

L'ordine delle table/key non ha significato semantico salvo dove il modello dichiara esplicitamente una sequenza ordinata, per esempio:

```text
provider preference/fallback order
fixed command arguments
PATH prepend/append sequence
integrity inventory entry order canonico
```

---

# 3. `@package`

Il file fisico resta:

```text
pkg/<package-instance-id>/@package
```

Non viene aggiunta un'estensione obbligatoria.

Il contenuto è TOML e contiene le sezioni logiche già fissate:

```text
schema
identity
release
integrity
state
interface
requirements
environment
```

Esempio minimo concettuale:

```toml
schema = 1

[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "jvm"
architecture = "any"
display-name = "NetBeans 26"

[release]
release-order = 26
```

La `version` upstream resta stringa semanticamente opaca.

---

# 4. Value reference: struttura, non mini-language

Le notazioni usate nei documenti architetturali come:

```text
dependency:jdk.directory:home
self:file:launcher
state:home
```

sono abbreviazioni concettuali, **non** la sintassi serializzata v0.

Nel TOML le reference vengono rappresentate strutturalmente.

Esempio concettuale:

```toml
[environment.JAVA_HOME]
operation = "set"
type = "path"
source = "dependency"
slot = "jdk"
resource-type = "directory"
resource = "home"
```

Una reference `self` può essere rappresentata come:

```toml
source = "self"
resource-type = "file"
resource = "netbeans-launcher"
```

Una reference a state area:

```toml
source = "state"
area = "home"
```

Questo evita parsing di stringhe composite e rende errori/validazione deterministici.

---

# 5. Requirements

Ogni dependency slot viene serializzato come struttura propria.

Esempio concettuale:

```toml
[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
constraint = ">=17 <22"
```

La stringa `constraint` viene interpretata esclusivamente secondo il version scheme della capability relativa; non è un comparatore universale di software version.

Provider preference, fallback e pin non vengono inseriti qui.

---

# 6. Package Interface

Le risorse sono dichiarate tramite array-of-table.

Esempio:

```toml
[[interface.resources]]
name = "home"
type = "directory"
path = "."

[[interface.resources]]
name = "bin"
type = "directory"
path = "bin"

[[interface.resources]]
name = "java-exe"
type = "file"
path = "bin/java"

[[interface.commands]]
name = "java"
executable-source = "self"
executable-resource = "java-exe"
```

La forma concreta può essere resa più compatta durante la futura specifica schema, ma non deve trasformarsi in codice eseguibile o in pathname host assoluti.

---

# 7. Integrity inventory line-oriented dentro TOML

L'inventory non viene rappresentato come una table TOML per ogni file.

Ogni tree immutabile mantiene:

```text
files count
directories count
links count
manifest digest
ordered inventory records
```

I record sono serializzati come **array ordinato di stringhe**, una stringa per record canonico.

Esempio:

```toml
[integrity]
method = 1
algorithm = "sha256"

[integrity.root]
files = 2
directories = 2
links = 1
manifest-digest = "..."
records = [
  "D\t0500\t.",
  "D\t0500\t./bin",
  "<digest>\tF\t0500\t./bin/foo",
  "<digest>\tF\t0400\t./app.jar",
  "<digest-target>\tL\t./log\t../run/log",
]
```

Stessa struttura per:

```toml
[integrity.run-default]
```

Dopo parsing TOML, ciascuna stringa rappresenta esattamente una riga canonica dell'inventory.

Il manifest canonico usato per il digest è:

```text
record-1 + LF
record-2 + LF
...
record-N + LF
```

Il digest non dipende da:

```text
indentazione TOML
quote style
commenti
ordine delle key TOML
line wrapping del serializer
```

ma soltanto dalla sequenza canonica dei record decodificati.

I conteggi vengono validati contro i record e contro il tree fisico.

---

# 8. Grammatica semantica dei record inventory

Forma v0:

```text
DIRECTORY
D<TAB><mode><TAB><relative-path>

REGULAR FILE
<digest><TAB>F<TAB><mode><TAB><relative-path>

SYMLINK
<digest-of-target-text><TAB>L<TAB><relative-path><TAB><relative-target>
```

Esempi:

```text
D\t0500\t.
D\t0500\t./bin
abc...\tF\t0500\t./bin/foo
def...\tL\t./log\t../run/log
```

Restano valide le regole già fissate:

```text
directory senza content digest
file digest dei bytes
symlink digest del target testuale senza dereference
mode solo per regular file/directory
ordinamento canonico
```

La specifica esatta di escaping/canonicalizzazione dei pathname resta una sotto-specifica dell'integrity method/version; non viene affidata alle regole di quoting TOML.

---

# 9. Nessun nuovo file `env/` o metadata tree

La scelta TOML non cambia la wrapper fissata:

```text
pkg/<id>/
├── root/
├── run-default/
├── @package
└── run/
```

Environment Specification, requirements, interface e inventory restano nel singolo `@package`.

Non vengono introdotti nel v0:

```text
env/
@meta/
@integrity separato
```

Se in futuro la dimensione reale degli inventory rendesse necessario separare storage e descriptor, questo potrà essere un'evoluzione di schema esplicita e non una modifica implicita del v0.

---

# 10. Resolved state usa lo stesso formato

Desired state e Resolution Snapshot sono TOML conformi allo stesso restricted profile.

Il resolved state è machine-generated ma resta facilmente ispezionabile.

Esempio concettuale:

```toml
schema = 1
generation = 17

[[roots]]
package = "netbeans@26@r1@jvm-any"
command = "netbeans"
state = "netbeans@s2"

[[dependencies]]
consumer = "netbeans@26@r1@jvm-any"
slot = "jdk"
provider = "temurin@21.0.8+9@r1@linux-arm64"
capability = "java-development-kit"
satisfied-version = "21"
```

Tutti i binding resolved puntano a exact Package Instance identity.

Non vengono persistiti pathname assoluti RUMIAI_ROOT.

---

# 11. Generation ID v0

Per il v0 la generation identity è un **intero positivo monotono locale all'environment RumiAI**:

```text
1
2
3
...
```

La rappresentazione human-readable può essere:

```text
g1
g2
g3
```

Il numero identifica l'ordine dei commit di resolved state, non una software version.

Non viene richiesto un digest-based generation ID nel v0.

L'integrità fisica e la futura firma/checksum del resolved snapshot sono responsabilità separabili dalla sua identità logica.

---

# 12. Atomic active-generation pointer

Il resolved state persistente deve distinguere:

```text
immutable generation snapshot
active generation pointer
```

Il pointer contiene soltanto la generation attiva e deve poter essere sostituito atomicamente dalla primitive filesystem appropriata della reference platform.

Il pointer non è un symlink obbligatorio: questo evita di imporre semantiche Unix a Windows.

La primitive fisica concreta di atomic replace/locking resta parte della Physical Platform Validation.

---

# 13. Canonicality

RumiAI non richiede una canonical byte serialization generale di TOML.

La semantica è il parsed data model validato dallo `schema`.

Quando serve un digest canonico, il relativo dominio definisce la propria canonical representation esplicita.

Nel v0 questo è già vero per l'integrity inventory:

```text
ordered canonical record lines
```

Questo evita di fare dipendere integrity/reproducibility dalle differenze fra serializer TOML equivalenti.

---

# 14. Security / parser rules

Il parser deve:

```text
leggere UTF-8
rifiutare schema unsupported
rifiutare duplicate key
rifiutare type mismatch
rifiutare structural unknown field nel medesimo schema v0
rifiutare reference incomplete/non valide
non eseguire codice
non espandere environment variable durante parsing
non risolvere symlink/path durante parsing puro
```

Parsing, semantic validation, filesystem validation e resolution restano fasi distinte.

---

# 15. Invarianti di serializzazione

```text
SER-01 TOML 1.0 è il formato metadata v0
SER-02 @package e resolved/desired state usano lo stesso restricted TOML profile
SER-03 il formato è dati, mai codice
SER-04 software version è stringa opaca
SER-05 reference sono strutture, non mini-language string
SER-06 inventory usa ordered canonical line records dentro array TOML
SER-07 manifest digest dipende dai record decodificati, non dai byte TOML
SER-08 nessuna env/ o @integrity separata nel v0
SER-09 unknown structural fields nello schema v0 sono errore
SER-10 generation ID v0 è monotono locale
SER-11 active generation pointer è separato dallo snapshot ed atomicamente sostituibile
SER-12 canonical byte TOML non è requisito generale
```

---

# 16. Prossimo passo

Con modello logico e serializzazione fissati, il prossimo lavoro architetturale non è ancora un PoC completo.

Conviene ora definire lo **schema v0 concreto di `@package` campo per campo**:

```text
key names definitivi
required / optional
cardinalità
namespace dei resource/capability/slot
constraint grammar minima
Environment Specification operations
validation order
error classes
```

Dopo lo schema concreto possiamo costruire alcuni descriptor completi di riferimento (JDK, NetBeans, Python, Pulsar) e verificarne la sufficienza prima di qualunque implementazione.