# RumiAI — JSON structured data standard v0

Data: 2026-08-30

Stato: **design decision — standard di riferimento fissato per development/application layer**

RumiAI usa **JSON UTF-8** come formato strutturato di riferimento per sviluppo, applicazioni e tool RumiAI che **non appartengono al system layer**.

Il system layer costituisce un dominio separato: i suoi tool sono POSIX `sh` con bootstrap/shebang Rumi e usano formati system-layer progettati per essere letti direttamente tramite primitive bootstrap, senza imporre parser JSON.

---

# 1. Scope

JSON è lo standard strutturato di riferimento per:

```text
application layer
strumenti di sviluppo
servizi/tool RumiAI non appartenenti al system layer
API e interfacce strutturate dove JSON è appropriato
metadata/configurazioni del non-system layer
```

JSON NON è una dipendenza del bootstrap/system layer.

Il system layer usa:

```text
System Configuration Field Format
    configurazioni/metadata/control-state gerarchici

System Tabular Data
    dataset omogenei record-oriented
```

---

# 2. Motivazione

JSON combina:

```text
standardizzazione ampia
parser maturi e robusti
supporto multipiattaforma
integrazione nativa con Node.js/browser runtime
strumenti portabili come jq
disponibilità in Go/Rust/C/C++/Java/.NET/etc.
assenza di dipendenza architetturale da Python
buone performance di parsing
```

Python, Node.js e altri runtime possono essere gestiti da RumiAI come package/runtime requirement, ma non sono baseline implicite del system layer.

---

# 3. Restricted profile v0

```text
encoding = UTF-8
BOM = forbidden
comments = forbidden
duplicate object member = error
unknown structural member = error per schema v0 salvo estensione esplicita
```

Tipi:

```text
object
array
string
integer
boolean
null se previsto dallo schema
```

Floating point non viene usato per valori che richiedono esattezza intera/stringa.

---

# 4. Semantica

Object member order non è semantico.

Array order può essere semantico quando dichiarato dal relativo schema.

Non viene richiesta canonical byte serialization JSON generale.

Se un dominio richiede digest/firma deterministica, definisce canonical representation separata.

---

# 5. Formattazione JSON generata da RumiAI

Regole v0:

```text
indentation               2 spazi per livello
tab di indentazione       vietati
newline                   LF
final newline             obbligatoria
opening `{` / `[`         su nuova riga
closing `}` / `]`         su propria riga
object/array delimiter    non appeso alla riga che introduce il valore
trailing comma            vietata
Unicode                   emesso normalmente come UTF-8
```

Esempio:

```json
{
  "schema": 1,
  "identity":
  {
    "name": "example",
    "platform": "any"
  },
  "requirements":
  [
    {
      "name": "example-runtime",
      "version": ">=1"
    }
  ]
}
```

Il parser accetta qualunque JSON valido che soddisfi schema/restricted profile, indipendentemente dal whitespace.

Quando uno schema definisce ordine raccomandato dei member, i generatori lo seguono per diff stabili; l'ordine non diventa semantica JSON.

---

# 6. System layer

JSON non viene imposto al RumiAI system layer.

Esempi:

```text
pkg.conf / @package / desired / resolved / active
    System Configuration Field Format

integrity inventories
    System Tabular Data con header TSV
```

Principio:

> JSON è lo standard strutturato del development/application layer, non una dipendenza universale del system layer.

---

# 7. Tooling baseline

Un file JSON RumiAI del non-system layer deve essere ispezionabile tramite tool standard come:

```text
jq
Node.js JSON.parse
standard library JSON parser del linguaggio di implementazione
```

Il system layer non assume la presenza di questi tool.

---

# 8. Invarianti

```text
JS-01 JSON UTF-8 è structured data format di riferimento del development/application layer
JS-02 system layer è escluso dall'obbligo JSON
JS-03 system config gerarchico usa SCF
JS-04 system tabular data usa TSV con header
JS-05 duplicate keys JSON sono errore
JS-06 schema versioning è esplicito dove necessario
JS-07 object order non è semanticamente significativo
JS-08 array order è significativo solo dove dichiarato
JS-09 JSON non è codice e non viene eval/source
JS-10 canonical JSON byte serialization non è requisito generale
JS-11 nessuna dipendenza Python/Node/jq è richiesta al system layer
JS-12 JSON generato usa indentation di 2 spazi, LF e newline finale
JS-13 opening/closing object/array delimiter sono su righe proprie
JS-14 Unicode viene mantenuto come UTF-8
```
