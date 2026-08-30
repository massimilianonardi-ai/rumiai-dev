# RumiAI — JSON structured data standard v0

Data: 2026-08-30

Stato: **design decision — standard di riferimento fissato**

RumiAI usa **JSON UTF-8** come formato strutturato di riferimento per nuovi metadata, configurazioni dichiarative, snapshot e interfacce persistite, salvo casi in cui un formato più semplice sia semanticamente migliore.

---

# 1. Motivazione

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

Python può essere gestito da RumiAI come runtime/package requirement, ma non è una baseline implicita per leggere i metadata fondamentali del sistema.

---

# 2. Restricted profile v0

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

# 3. Semantica

Object member order non è semantico.

Array order può essere semantico quando dichiarato dal relativo schema.

Non viene richiesta una canonical byte serialization JSON generale.

Se un dominio richiede digest/firma deterministica, quel dominio definisce una propria canonical representation separata.

---

# 4. Formattazione dei JSON generati da RumiAI

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
    "name": "netbeans",
    "platform": "any",
    "architecture": "any"
  },
  "requirements":
  [
    {
      "slot": "jdk",
      "target": "capability",
      "capability": "java-development-kit",
      "contract": 1,
      "constraint": ">=17 <22"
    }
  ]
}
```

Quindi non viene generato lo stile compatto:

```json
{
  "identity": {
    "name": "netbeans"
  },
  "requirements": [
    {
      "slot": "jdk"
    }
  ]
}
```

anche se è JSON semanticamente equivalente.

La formattazione riguarda l'output prodotto da RumiAI. Un parser RumiAI deve comunque accettare qualunque JSON valido che soddisfi schema e restricted profile, indipendentemente da whitespace/indentation.

Per rendere i diff stabili, quando uno schema definisce un ordine raccomandato dei member, i generatori RumiAI devono emettere i member in quell'ordine. Questo ordine resta una regola di presentazione, non entra nella semantica JSON.

---

# 5. Eccezioni intenzionali

JSON non viene imposto quando una rappresentazione più semplice è migliore.

Esempi package-manager v0:

```text
active generation pointer
    minimal text: gN + LF

integrity inventory
    canonical TSV streaming format
```

Principio:

> JSON è lo standard strutturato di riferimento, non un obbligo a trasformare qualunque byte persistito in JSON.

---

# 6. Tooling baseline

Un file JSON RumiAI deve poter essere ispezionato almeno concettualmente tramite tool standard come:

```text
jq
Node.js JSON.parse
standard library JSON parser del linguaggio di implementazione
```

La logica RumiAI non deve richiedere parser proprietari per il formato base.

---

# 7. Invarianti

```text
JS-01 JSON UTF-8 è il structured data format di riferimento RumiAI v0
JS-02 duplicate keys sono errore
JS-03 schema versioning è esplicito dove necessario
JS-04 object order non è semanticamente significativo
JS-05 array order è significativo solo dove dichiarato
JS-06 JSON non è codice e non viene eval/source
JS-07 canonical JSON byte serialization non è requisito generale
JS-08 domini bulk/streaming possono usare formati più appropriati
JS-09 nessuna dipendenza architetturale da Python per leggere metadata RumiAI
JS-10 JSON generato da RumiAI usa indentation di 2 spazi, LF e newline finale
JS-11 opening/closing object/array delimiter sono su righe proprie; `{` e `[` non vengono appesi alla riga che introduce il valore
JS-12 Unicode viene mantenuto come UTF-8; non si impone ASCII escaping generale
JS-13 la formattazione generata è stabile ma non modifica la semantica del parser JSON
```
