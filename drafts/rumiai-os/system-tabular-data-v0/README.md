# RumiAI system layer — System Tabular Data v0

Data: 2026-08-30

Stato: **design decision — formato dati tabellari system-layer fissato**

Il System Tabular Data format è usato per dataset omogenei e record-oriented del RumiAI system layer.

È distinto dal System Configuration Field Format:

```text
configuration / metadata gerarchici
    field-name<TAB>field-value

dataset tabellari
    TSV con header + una riga per record
```

---

# 1. Framing

Un file tabellare contiene:

```text
header row
zero o più data row
```

Ogni riga usa TAB come delimitatore.

La prima riga contiene i field-name/column-name dello schema.

Esempio:

```text
type	mode	digest	target	path
D	0500	-	-	.
F	0500	abc...	-	./bin/foo
```

---

# 2. Header

L'header è obbligatorio anche per dataset vuoto.

Ogni column-name è ASCII e usa una forma POSIX-safe:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Uno schema specifico fissa:

```text
numero colonne
nomi colonne
ordine colonne
```

Header diverso da quello previsto è errore di schema.

---

# 3. Record

Ogni data row contiene esattamente lo stesso numero di campi dell'header.

Un record logico corrisponde a una riga fisica.

Non si rappresenta un singolo record mediante più righe/field gerarchici.

Questo rende il formato adatto a:

```text
inventory
manifest
index/tabella grande
streaming verification
```

---

# 4. Encoding

```text
encoding       UTF-8
BOM            forbidden
line ending    LF
final LF       required
separator      TAB
header         required
blank row      forbidden nei file machine-generated
comments       forbidden nei dataset canonici
```

---

# 5. Valori

Ogni campo è UTF-8 opaco allo strato tabellare.

Sono vietati nei field-value:

```text
NUL
TAB
CR
LF
```

Non esiste quoting o escaping nel v0.

Se un dataset richiede valori non rappresentabili con queste regole, deve usare un altro schema/formato esplicitamente progettato; non si estende implicitamente TSV con una grammatica CSV-like.

---

# 6. Query / streaming

Il bootstrap Rumi espone primitive tabellari concettuali:

```text
rumi_table_validate <file> <schema>
rumi_table_rows <file>
rumi_table_filter <file> <column> <value>
```

Per grandi dataset il modello normale è single-pass streaming.

I tool possono usare `awk`/primitive POSIX equivalenti dietro l'API bootstrap, ma non devono inventare parser diversi per ogni tabella.

---

# 7. Header e digest

Quando uno schema definisce un digest canonico dell'intero dataset, il digest include:

```text
header
TAB separators
LF separators
all data rows
final LF
```

Quindi la semantica delle colonne è protetta anche dal digest.

---

# 8. Ordine

Il significato dell'ordine delle righe è definito dallo schema specifico.

Uno schema canonico può richiedere un ordine deterministico, per esempio pathname byte-order per gli inventory integrity.

Il formato base non effettua sort implicito.

---

# 9. Configurazione vs dati

Usare System Tabular Data quando:

```text
esiste una collezione omogenea di record
ogni record ha gli stessi campi
il dataset può essere grande
streaming per riga è naturale
```

Usare System Configuration Field Format quando:

```text
la struttura è gerarchica
campi opzionali/namespace sono frequenti
ci sono object/array/map annidati
lookup per path logico è naturale
```

---

# 10. Invarianti

```text
STD-01 first row = required header
STD-02 header column names sono POSIX-safe ASCII
STD-03 schema fissa column count/name/order
STD-04 one logical record = one physical row
STD-05 ogni row ha lo stesso numero di campi dell'header
STD-06 separator = TAB, record separator = LF
STD-07 UTF-8, no BOM, final LF required
STD-08 NUL/TAB/CR/LF vietati nei values
STD-09 nessun quoting/escaping v0
STD-10 canonical dataset può definire row ordering
STD-11 whole-file digest include header quando previsto
STD-12 dataset tabellare non viene flattenato nel config format
```
