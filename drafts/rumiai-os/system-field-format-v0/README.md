# RumiAI system layer — System Configuration Field Format v0

Data: 2026-08-30

Stato: **design decision — formato configurazione/metadata system-layer fissato**

Il RumiAI system layer usa tool POSIX `sh` e bootstrap API RumiAI.

Per configurazioni, metadata e control-state gerarchici letti direttamente dal system layer viene usato un formato dichiarativo minimale a due campi.

Questo formato NON viene usato per dataset tabellari omogenei: tali file usano RumiAI System Tabular Data v0, con header TSV e una riga per record.

---

# 1. Record fondamentale

Ogni record contiene esattamente:

```text
field-name<TAB>field-value<LF>
```

Esempio:

```text
schema	1
identity.name	netbeans
identity.platform	any
```

Non esiste header tabellare.

---

# 2. Dot notation

`field-name` è gerarchico e usa `.` come separatore strutturale.

Esempi:

```text
identity.name
integrity.root.manifest_digest
requirements.1.constraint
interface.commands.2.executable.source
```

Il punto è sintassi del formato, non parte dei singoli segmenti.

---

# 3. Segmenti nominali

Ogni segmento nominale segue:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Validi:

```text
identity
manifest_digest
JAVA_HOME
_name
```

Non validi come segmenti nominali:

```text
foo-bar
foo bar
café
```

Identificatori arbitrari, package ID, capability name e altri dati che possono contenere `-`, `@`, Unicode o altri caratteri restano nei field-value.

---

# 4. Segmenti indice

Per array/list sono ammessi segmenti indice numerici:

```text
1
2
3
...
```

Un indice è un positive base-10 integer senza zero iniziali.

Esempio:

```text
requirements.count	2
requirements.1.id	jdk
requirements.1.target	capability
requirements.2.id	python
requirements.2.target	capability
```

`0`, `01`, `002` non sono indici canonici.

---

# 5. Grammar concettuale

```text
field-name = named-segment *( "." (named-segment | index-segment) )

named-segment = [A-Za-z_][A-Za-z0-9_]*
index-segment = [1-9][0-9]*
```

Il primo segmento deve essere nominale.

---

# 6. Array

Ogni array persistito contiene un count esplicito:

```text
<prefix>.count	N
```

e indici contigui `1..N`.

Array vuoto:

```text
requirements.count	0
```

Array scalare:

```text
args.count	3
args.1	-jar
args.2	app.jar
args.3	--quiet
```

Array di object:

```text
requirements.count	1
requirements.1.id	jdk
requirements.1.target	capability
requirements.1.capability	java-development-kit
requirements.1.contract	1
requirements.1.constraint	>=17 <22
```

---

# 7. Map

Una map con namespace/key fissati dallo schema può usare direttamente dot notation:

```text
identity.name	netbeans
state.scope	shared
integrity.method	1
```

Una map con chiavi arbitrarie NON incorpora la chiave arbitraria nel field-name.

Usa una collection indicizzata:

```text
providers.count	2
providers.1.key	temurin-21
providers.1.value	10
providers.2.key	microsoft-openjdk
providers.2.value	20
```

Regola:

> struttura nello schema e nel field-name; identificatori arbitrari nei field-value.

---

# 8. Namespace/scalar collision

Un pathname logico non può essere contemporaneamente scalar e namespace.

Vietato:

```text
foo	value
foo.bar	other
```

Vietato anche il contrario.

Sono invece validi:

```text
foo.count	2
foo.1.id	one
foo.2.id	two
```

`foo` è in questo caso soltanto namespace.

---

# 9. Unicità

Ogni `field-name` completo deve comparire al massimo una volta nello stesso file.

Duplicato:

```text
identity.name	foo
identity.name	bar
```

è errore; non esiste `last value wins`.

---

# 10. Field value

`field-value` è una stringa UTF-8 opaca per il formato base.

Può contenere fra l'altro:

```text
spazi
=
:
#
/
\\
Unicode
.
@
-
```

Sono vietati:

```text
NUL
TAB
CR
LF
```

Non esiste quoting o escaping nel v0.

Un empty string è distinto da field assente.

Se un dominio richiede un valore multilinea/binario, il contenuto vive in un file separato e la configurazione mantiene una reference.

---

# 11. Tipi

Il formato base non codifica un type tag.

Lo schema specifico interpreta il value.

Forme canoniche comuni:

```text
boolean
    true
    false

integer
    base 10
    nessun + iniziale
    zero = 0
    nessuno zero iniziale per valori non-zero
```

Enum e pathname sono definiti dal relativo schema.

---

# 12. Encoding / framing

```text
encoding       UTF-8
BOM            forbidden
line ending    LF
final LF       required per file generati da RumiAI
separator      esattamente un TAB
```

Ogni record dati contiene esattamente un TAB.

---

# 13. Commenti e righe vuote

Per configurazioni human-editable sono ammesse:

```text
blank line
comment line con `#` come primo byte
```

Esempio:

```text
# pkg configuration

schema	1
profile	default
```

`#` dentro field-value è testo normale.

File machine-generated/autorevoli usano forma canonica senza commenti e blank line salvo schema esplicito contrario.

---

# 14. Ordine

L'ordine fisico dei field non è semanticamente significativo.

La sequenza di un array è determinata dall'indice numerico.

I writer RumiAI usano comunque un ordine canonico definito dallo schema per diff e debugging stabili.

Non si usa lexical sort generico dei field-name per sequenze, perché `items.10` precederebbe `items.2` lessicograficamente.

---

# 15. Nessun source/eval

Il formato contiene dati, non codice.

Non viene eseguito tramite:

```text
.
source
eval
```

La compatibilità dei segmenti nominali con i nomi POSIX serve a semplificare query e schema, non a creare automaticamente variabili shell.

In particolare non si sostituiscono `.` con `_` per creare variabili: ciò introdurrebbe collisioni fra nomi differenti.

---

# 16. Query bootstrap

Il bootstrap RumiAI espone primitive di configurazione:

```text
RumiAI_conf_get <file> <field-name>
RumiAI_conf_has <file> <field-name>
RumiAI_conf_set <file> <field-name> <field-value>
RumiAI_conf_remove <file> <field-name>
RumiAI_conf_namespace <file> <prefix>
RumiAI_conf_validate <file> [schema]
```

Semantica `namespace`:

```text
field == prefix
OR
field begins with prefix + "."
```

La query per prefix non richiede una regex costruita dal chiamante.

Le funzioni RumiAI namespaced usano il namespace canonico `RumiAI_*`; abbreviazioni conversazionali non definiscono namespace API.

---

# 17. Performance

Lookup puntuali possono scandire il file.

Per leggere molte proprietà dello stesso namespace si usa una singola scansione `RumiAI_conf_namespace` o primitive equivalente.

È vietato costruire algoritmi O(n²) facendo migliaia di full-file lookup sulla stessa collection.

Dataset grandi/record-oriented non devono essere rappresentati come configurazione gerarchica: usano System Tabular Data.

---

# 18. Confine con dati tabellari

Usano questo formato:

```text
pkg.conf
@package
desired
resolved
active
selection/configuration metadata
altri control-state gerarchici
```

NON usano questo formato:

```text
integrity inventories
altri dataset omogenei a una riga per record
```

Questi ultimi usano System Tabular Data v0.

---

# 19. Relazione con JSON

```text
RumiAI development/application layer
    JSON standard v0

RumiAI system layer
    POSIX sh + RumiAI bootstrap
    System Configuration Field Format v0
    System Tabular Data v0
```

JSON non è una dipendenza del bootstrap/system layer.

---

# 20. Invarianti

```text
SCF-01 configuration record = field-name<TAB>field-value
SCF-02 esattamente due campi / un TAB per record
SCF-03 field-name usa dot notation gerarchica
SCF-04 named segment = [A-Za-z_][A-Za-z0-9_]*
SCF-05 array index segment = positive base-10 integer senza zero iniziale
SCF-06 first segment deve essere nominale
SCF-07 field-name completo è unico
SCF-08 scalar/namespace collision è vietata
SCF-09 field-value è UTF-8 opaco al formato base
SCF-10 NUL/TAB/CR/LF vietati nel field-value
SCF-11 nessun quoting/escaping v0
SCF-12 array usa count + indici contigui 1..N
SCF-13 arbitrary map key/ID restano nei value
SCF-14 il formato non viene source/eval
SCF-15 bootstrap RumiAI fornisce query puntuali e per namespace
SCF-16 dataset tabellari non vengono flattenati in SCF
SCF-17 namespaced RumiAI shell APIs use exact RumiAI_* namespace
```
