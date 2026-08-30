# RumiAI package manager — serialization v0

Data: 2026-08-30

Stato: **design decision — serializzazione v0 fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-descriptor/README.md
drafts/rumiai-os/package-manager-resolved-state/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-platform-vocabulary-v0/README.md
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
    valido tecnicamente e generalmente più veloce da parsare in molte implementazioni,
    ma meno leggibile per descriptor complessi e strutture ripetute

formato RumiAI generale proprietario
    evitato per non creare un parser/config language senza necessità
```

La performance non viene affidata alla scelta del formato: i grandi inventory integrity usano un singolo blocco line-oriented, e il launch non deve parsare l'intero `@package` di tutte le dependency.

---

# 2. Restricted TOML profile RumiAI v0

Tipi ammessi:

```text
UTF-8 string
base-10 integer
boolean
array
table
array of tables
```

Non usati:

```text
float
NaN / infinity
date
time
datetime
```

Un serializer RumiAI emette interi in base 10.

Duplicate key sono errore.

Uno `schema` unsupported viene rifiutato; non viene reinterpretato euristicamente.

Nel medesimo schema v0, chiavi strutturali sconosciute sono errore per default.

I commenti TOML non hanno significato semantico.

L'ordine delle table/key non ha significato salvo dove il modello definisce una sequenza ordinata.

---

# 3. `@package`

File fisico:

```text
pkg/<package-instance-id>/@package
```

Nessuna estensione obbligatoria.

Sezioni logiche:

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

Esempio minimo:

```toml
schema = 1

[identity]
name = "netbeans"
version = "26"
revision = 1
platform = "any"
architecture = "any"
display-name = "NetBeans 26"

[release]
release-order = 26
```

`platform`/`architecture` descrivono il contenuto della Package Instance. Java/Python/JDK/JRE necessari vengono rappresentati tramite requirements/capability, non come platform token.

---

# 4. Value reference: struttura, non mini-language

Notazioni architetturali come:

```text
dependency:jdk.directory:home
self:file:launcher
state:home
```

sono abbreviazioni concettuali.

Nel TOML le reference sono strutturate, per esempio:

```toml
value = { source = "dependency", slot = "jdk", resource-type = "directory", resource = "home" }
```

Questo evita parsing di stringhe composite.

---

# 5. Requirements

Esempio:

```toml
[[requirements]]
slot = "jdk"
target = "capability"
capability = "java-development-kit"
contract = 1
constraint = ">=17 <22"
```

La capability compatibility version è interpretata esclusivamente secondo il relativo `(capability, contract)`.

Provider preference, fallback e pin non vengono inseriti qui.

---

# 6. Package Interface

Le risorse sono strutture TOML tipizzate secondo lo schema `@package` v0.

Il modello non usa shell code né pathname host assoluti.

---

# 7. Integrity inventory line-oriented dentro TOML

L'inventory può contenere molte migliaia di entry e **non** viene rappresentato come table o array TOML per ogni record.

Ogni tree immutabile mantiene:

```text
files count
directories count
links count
manifest digest
canonical inventory records
```

I record sono serializzati in un'unica **multiline literal string TOML**, in ordine canonico, una riga per entry.

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
records = '''
D\t0500\t.
D\t0500\t./bin
<digest>\tF\t0500\t./bin/foo
<digest>\tF\t0400\t./app.jar
<digest-target>\tL\t./log\t../run/log
'''
```

Nel file reale i separatori fra campi sono TAB reali e le righe terminano con LF canonico; `\t` sopra serve soltanto a renderli visibili nel documento.

Stessa struttura per:

```toml
[integrity.run-default]
```

Dopo il parsing TOML, `records` è una singola stringa UTF-8.

Il manifest canonico usato per il digest è **esattamente il contenuto canonico della stringa `records`**, con:

```text
una riga per record
LF come line separator
LF finale obbligatorio
nessuna riga vuota aggiuntiva
```

Il digest non dipende da:

```text
indentazione TOML
commenti
ordine delle key TOML
serializer TOML
```

ma soltanto dal blocco canonico decodificato.

Questa forma è preferita all'array di stringhe perché:

```text
corrisponde direttamente al modello find-like fissato
riduce overhead sintattico
riduce numero di oggetti allocati dal parser
migliora sensibilmente il parse di inventory grandi
consente processing line-oriented successivo
```

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

Restano valide:

```text
directory senza content digest
file digest dei bytes
symlink digest del target testuale senza dereference
mode solo per regular file/directory
ordinamento canonico
```

Escaping/canonicalizzazione dei pathname appartengono all'Integrity Method 1.

---

# 9. Nessun nuovo metadata file

La wrapper resta:

```text
pkg/<id>/
├── root/
├── run-default/
├── @package
└── run/
```

Non vengono introdotti:

```text
env/
@meta/
@integrity separato
```

Environment Specification, requirements, interface e inventory restano nel singolo `@package`.

---

# 10. Resolved state usa lo stesso restricted TOML

Desired state e Resolution Snapshot sono TOML.

Esempio:

```toml
schema = 1
generation = 17

[[roots]]
package = "netbeans@26@r1@any-any"
command = "netbeans"
state = "netbeans@s2"

[[dependencies]]
consumer = "netbeans@26@r1@any-any"
slot = "jdk"
provider = "temurin@21.0.8+9@r1@linux-arm64"
capability = "java-development-kit"
contract = 1
satisfied-version = "21"
```

Tutti i binding resolved puntano a exact Package Instance identity.

Non vengono persistiti pathname assoluti RUMIAI_ROOT.

---

# 11. Generation ID v0

Generation identity = intero positivo monotono locale all'environment RumiAI:

```text
1 2 3 ...
```

Rappresentazione human-readable:

```text
g1 g2 g3 ...
```

---

# 12. Atomic active-generation pointer

Si distinguono:

```text
immutable generation snapshot
active generation pointer
```

Il pointer contiene soltanto la generation attiva ed è sostituito atomicamente con la primitive filesystem validata per la reference platform.

Non è obbligatoriamente un symlink.

---

# 13. Canonicality

Non serve una canonical byte serialization generale di TOML.

Quando serve un digest, il dominio definisce la propria rappresentazione canonica.

Per l'integrity v0 questa è il blocco line-oriented `records` definito dall'Integrity Method 1.

---

# 14. Security / parser rules

Il parser deve:

```text
leggere UTF-8
rifiutare schema unsupported
rifiutare duplicate key
rifiutare type mismatch
rifiutare structural unknown field nel medesimo schema
rifiutare reference incomplete/non valide
non eseguire codice
non espandere environment variable durante parsing
non risolvere symlink/path durante parsing puro
```

Parsing, semantic validation, filesystem validation e resolution restano fasi distinte.

---

# 15. Performance boundary

Regole v0:

```text
launch path non rilegge/verifica tutti gli inventory @package
integrity inventory viene parsato quando serve validation/integrity/admission/recovery
generation resolved attiva deve restare relativamente piccola e direttamente parsabile
implementazioni possono mantenere cache in-memory derivata; cache != fonte di verità
```

La scelta TOML privilegia leggibilità e schema; i grandi payload line-oriented vengono rappresentati come blocchi stringa per limitarne l'overhead.

---

# 16. Invarianti di serializzazione

```text
SER-01 TOML 1.0 è il formato metadata v0
SER-02 @package e resolved/desired state usano lo stesso restricted TOML profile
SER-03 il formato è dati, mai codice
SER-04 software version è stringa opaca
SER-05 reference sono strutture, non mini-language string
SER-06 inventory usa un canonical multiline line-record block
SER-07 manifest digest dipende dal blocco records decodificato, non dai byte TOML
SER-08 nessuna env/ o @integrity separata nel v0
SER-09 unknown structural fields nello schema v0 sono errore
SER-10 generation ID v0 è monotono locale
SER-11 active generation pointer è separato dallo snapshot ed atomicamente sostituibile
SER-12 canonical byte TOML non è requisito generale
SER-13 platform any-any è distinta dai runtime requirements
SER-14 inventory grandi non appartengono al critical launch parsing path
```
