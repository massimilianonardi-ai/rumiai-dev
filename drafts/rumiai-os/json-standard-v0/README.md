# RumiAI — JSON structured data standard v0

Data: 2026-08-30

Stato: **design decision — standard di riferimento fissato per development/application layer**

RumiAI usa **JSON UTF-8** come formato strutturato di riferimento per sviluppo, applicazioni e tool RumiAI che **non appartengono al system layer**.

Il system layer costituisce un dominio separato: i suoi tool sono POSIX `sh` con bootstrap/shebang Rumi e usano formati system-layer progettati per essere letti direttamente tramite le primitive fornite dal bootstrap, senza imporre un parser JSON al bootstrap stesso.

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

Il system layer definisce separatamente i propri formati dichiarativi POSIX-sh-friendly.

---

# 2. Motivazione

JSON viene scelto perché combina:

```text
standardizzazione ampia
parser maturi e robusti
supporto multipiattaforma
integrazione nativa con Node.js/browser runtime
strumenti portabili come jq
ottima disponibilità in Go/Rust/C/C++/Java/.NET/etc.
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

Tipi utilizzabili:

```text
object
array
string
integer
boolean
null se lo schema lo prevede esplicitamente
```

Floating point non viene usato per identity, version, count, generation, revision o altri valori che richiedono esattezza intera/stringa.

---

# 4. Semantica

Object member order non è semantico.

Array order può essere semantico quando dichiarato dal relativo schema.

Non viene richiesta una canonical byte serialization JSON generale.

Se un dominio richiede digest/firma deterministica, quel dominio definisce una propria canonical representation separata.

---

# 5. Formattazione dei JSON generati da RumiAI

I JSON **generati da RumiAI** devono essere pretty-printed secondo uno stile stabile e leggibile.

Regole v0:

```text
indentation               2 spazi per livello
tab di indentazione       vietati
newline                   LF
final newline             obbligatoria
opening `{` / `[`         su una nuova riga
closing `}` / `]`         su una propria riga
object/array delimiter    non appeso alla fine della riga che introduce il valore
trailing comma            vietata, come richiesto da JSON standard
Unicode                   emesso normalmente come UTF-8; nessun ASCII escaping generale richiesto
```

Esempio normativo di stile:

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

La formattazione riguarda l'output prodotto da RumiAI. Un parser RumiAI deve comunque accettare qualunque JSON valido che soddisfi schema e restricted profile, indipendentemente da whitespace/indentation.

Per rendere i diff stabili, quando uno schema definisce un ordine raccomandato dei member, i generatori RumiAI devono emettere i member in quell'ordine. Questo ordine resta una regola di presentazione, non entra nella semantica JSON.

---

# 6. Eccezioni e system layer

JSON non viene imposto quando una rappresentazione più semplice è migliore e soprattutto non viene imposto al **RumiAI system layer**.

Esempi:

```text
system-layer configuration
    Rumi System Field Format

integrity bulk inventory
    canonical TSV streaming format

minimal bootstrap pointer
    plain text minimale quando semanticamente sufficiente
```

Principio:

> JSON è lo standard strutturato del development/application layer, non una dipendenza universale del system layer.

---

# 7. Tooling baseline

Un file JSON RumiAI del non-system layer deve poter essere ispezionato almeno concettualmente tramite tool standard come:

```text
jq
Node.js JSON.parse
standard library JSON parser del linguaggio di implementazione
```

Il system layer non assume la presenza di questi tool.

---

# 8. Invarianti

```text
JS-01 JSON UTF-8 è lo structured data format di riferimento del development/application layer RumiAI v0
JS-02 il RumiAI system layer è escluso dall'obbligo JSON
JS-03 duplicate keys sono errore
JS-04 schema versioning è esplicito dove necessario
JS-05 object order non è semanticamente significativo
JS-06 array order è significativo solo dove dichiarato
JS-07 JSON non è codice e non viene eval/source
JS-08 canonical JSON byte serialization non è requisito generale
JS-09 domini bulk/streaming possono usare formati più appropriati
JS-10 nessuna dipendenza architetturale da Python/Node/jq è richiesta al system layer
JS-11 JSON generato da RumiAI usa indentation di 2 spazi, LF e newline finale
JS-12 opening/closing object/array delimiter sono su righe proprie; `{` e `[` non vengono appesi alla riga che introduce il valore
JS-13 Unicode viene mantenuto come UTF-8; non si impone ASCII escaping generale
JS-14 la formattazione generata è stabile ma non modifica la semantica del parser JSON
```
