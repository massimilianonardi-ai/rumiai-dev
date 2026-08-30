# RumiAI package manager — serialization v0

Data: 2026-08-30

Stato: **design decision — JSON + TSV v0 fissati**

Questa specifica sostituisce la precedente scelta TOML.

---

# 1. Formato strutturato standard: JSON

RumiAI usa **JSON UTF-8** come formato strutturato di riferimento per lo sviluppo e, nel package manager v0, per:

```text
@package
Desired Integration Profile
Resolution Snapshot / resolved state
Selection Policy persistita
altri metadata strutturati del package manager
```

Motivazioni principali:

```text
standard estremamente diffuso e stabile
ecosistema parser maturo su praticamente ogni piattaforma
leggibile e trasformabile con jq
nativamente supportato da Node.js
nessuna dipendenza da Python
buona interoperabilità con shell/tooling multipiattaforma
parsing normalmente molto veloce
```

La scelta JSON è una decisione architetturale di riferimento RumiAI, non soltanto un dettaglio del package manager.

---

# 2. Restricted JSON profile RumiAI v0

Encoding:

```text
UTF-8
no BOM
```

Tipi ammessi quando previsti dallo schema:

```text
object
array
string
integer
boolean
null soltanto dove esplicitamente previsto
```

Non vengono usati come valori normativi:

```text
floating point
NaN / Infinity
commenti
estensioni JSON non standard
```

Regole parser:

```text
duplicate object member name -> errore
schema non supportato -> errore
unknown structural field nello stesso schema -> errore salvo esplicita estensione
integer overflow/range error -> errore
```

L'ordine delle proprietà di un object non ha significato semantico.

L'ordine degli elementi di un array ha significato quando il modello lo dichiara, per esempio:

```text
provider preference
fixed argv
environment operation sequence
```

Non è richiesta una canonical byte serialization JSON generale.

---

# 3. `@package`

Il pathname fisico resta:

```text
pkg/<package-instance-id>/@package
```

`@package` è un documento JSON anche se non usa estensione `.json`.

Struttura logica v0:

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

Esempio:

```json
{
  "schema": 1,
  "identity": {
    "name": "netbeans",
    "version": "26",
    "revision": 1,
    "platform": "any",
    "architecture": "any",
    "display-name": "NetBeans 26"
  },
  "release": {
    "release-order": 26
  }
}
```

---

# 4. Reference strutturate

Notazioni descrittive come:

```text
dependency:jdk.directory:home
self:file:launcher
state:home
```

non sono una mini-language persistita.

Le reference sono object JSON espliciti, per esempio:

```json
{
  "source": "dependency",
  "slot": "jdk",
  "resource-type": "directory",
  "resource": "home"
}
```

Questo mantiene parsing e validazione deterministici.

---

# 5. Integrity inventory separati

Il bulk inventory NON vive dentro `@package`.

La wrapper contiene due file di testo canonici TSV:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

La Package Instance fisica diventa:

```text
pkg/<id>/
├── root/
├── run-default/
├── @package
├── @integrity-root.tsv
├── @integrity-run-default.tsv
└── run/
```

`@package` contiene per ciascun tree:

```text
inventory file name
files count
directories count
links count
manifest digest
```

Esempio:

```json
{
  "integrity": {
    "method": 1,
    "algorithm": "sha256",
    "root": {
      "inventory": "@integrity-root.tsv",
      "files": 120,
      "directories": 24,
      "links": 3,
      "manifest-digest": "..."
    },
    "run-default": {
      "inventory": "@integrity-run-default.tsv",
      "files": 8,
      "directories": 4,
      "links": 0,
      "manifest-digest": "..."
    }
  }
}
```

---

# 6. TSV inventory record v0

Ogni record usa esattamente **cinque campi** separati da un singolo TAB:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path
```

`path` è sempre l'ultimo campo.

Questo permette parsing shell semplice senza rompere pathname contenenti spazi.

Semantica:

```text
type
    D = directory
    F = regular file
    L = symbolic link

mode
    4-digit canonical POSIX mode per D/F
    - per L

digest
    - per D
    digest dei file bytes per F
    digest del symlink target text per L

target
    - per D/F
    relative symlink target text per L

path
    canonical relative pathname dell'entry
```

Esempio:

```text
D	0500	-	-	.
D	0500	-	-	./bin
F	0500	<digest>	-	./bin/foo
F	0400	<digest>	-	./lib/foo.jar
L	-	<digest-target>	../run/log	./log
```

Il file:

```text
UTF-8
LF line ending
no BOM
no header
one record per line
final LF required
canonical order
```

I conteggi e l'algoritmo non vengono duplicati nel TSV: sono nel `@package` JSON.

La specifica Integrity Method 1 definisce in modo normativo canonical pathname, caratteri ammessi/escaping, sort order e digest input.

---

# 7. Manifest digest

`manifest-digest` è il digest dei **byte canonici completi del TSV inventory**.

Quindi dipende da:

```text
record order
TAB separators
LF separators
mode
digest/target/path fields
final LF
```

Non dipende dalla formattazione JSON di `@package`.

---

# 8. Immutabilità

Sono parte del core immutabile della Package Instance:

```text
root/
run-default/
@package
@integrity-root.tsv
@integrity-run-default.tsv
```

`run/` resta derivata e mutabile nel contenuto.

Unix-like default:

```text
@package                    0400
@integrity-root.tsv         0400
@integrity-run-default.tsv  0400
```

---

# 9. Desired / resolved state

Desired state e Resolution Snapshot sono JSON conformi allo stesso restricted JSON profile.

I pathname possono restare semanticamente:

```text
var/pkg/profiles/<profile>/generations/gN/desired
var/pkg/profiles/<profile>/generations/gN/resolved
```

L'estensione `.json` non è obbligatoria perché il ruolo del file ne determina già il content type.

Esempio resolved:

```json
{
  "schema": 1,
  "generation": 17,
  "profile": "default",
  "dependencies": [
    {
      "consumer": "netbeans@26@r1@any-any",
      "slot": "jdk",
      "provider": "temurin@21.0.8+9@r1@linux-arm64",
      "capability": "java-development-kit",
      "contract": 1,
      "satisfied-version": "21"
    }
  ]
}
```

---

# 10. Active pointer

`active` NON è JSON.

Resta volutamente il formato bootstrap/recovery minimale:

```text
g17\n
```

Non ogni file RumiAI deve essere JSON quando una rappresentazione più semplice ha semantica migliore.

---

# 11. Tooling principle

JSON è scelto anche per permettere operazioni portabili come:

```text
jq
Node.js JSON.parse / JSON.stringify
browser/runtime JavaScript
parser JSON di Go/Rust/C/C++/Java/etc.
```

Nessuna funzione fondamentale del package manager deve dipendere dall'esistenza di Python sull'host.

Python può essere una Package Instance/runtime gestita come qualunque altro requirement, non una baseline implicita RumiAI.

---

# 12. Invarianti

```text
SER-01 JSON UTF-8 è il formato strutturato di riferimento RumiAI v0
SER-02 @package, desired e resolved usano restricted JSON
SER-03 duplicate object member name è errore
SER-04 metadata JSON non è codice
SER-05 reference sono object strutturati, non mini-language
SER-06 bulk integrity inventory è esterno a JSON
SER-07 inventory v0 = canonical five-field TSV con path ultimo
SER-08 root e run-default hanno inventory distinti
SER-09 manifest-digest = digest dei byte canonici del relativo TSV
SER-10 JSON formatting/order non partecipa all'integrity tree digest
SER-11 active pointer resta formato minimale non-JSON
SER-12 nessuna dipendenza architetturale da Python
```
