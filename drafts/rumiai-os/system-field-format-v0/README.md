# RumiAI system layer — System Field Format v0

Data: 2026-08-30

Stato: **design decision — formato system-layer fissato**

Il RumiAI system layer è composto da tool POSIX `sh` eseguiti tramite shebang/bootstrap Rumi.

Per i file di configurazione del system layer viene usato un formato dichiarativo minimale, progettato per poter essere letto e scritto dal bootstrap con primitive POSIX `sh` senza dipendere da JSON, Python, Node.js, `jq` o parser esterni.

---

# 1. Record fondamentale

Ogni record contiene esattamente due campi:

```text
field-name<TAB>field-value
```

Esempio:

```text
schema	1
pkg_profile	default
pkg_verify_integrity	true
```

Il separatore è esattamente un TAB.

---

# 2. `field-name`

`field-name` segue **le stesse regole POSIX shell dei nomi di variabile**.

Forma normativa:

```text
[A-Za-z_][A-Za-z0-9_]*
```

Quindi sono validi:

```text
schema
pkg_profile
requirement_1_id
RUMI_TEST
_name
```

Non sono validi:

```text
1name
pkg.profile
pkg-profile
pkg name
café
```

Il nome è case-sensitive e non viene normalizzato automaticamente.

La scelta della forma canonica dei singoli field-name appartiene allo schema del file/tool che li usa.

---

# 3. `field-value`

`field-value` è una stringa UTF-8 opaca per il formato base.

Può contenere, fra l'altro:

```text
spazi
=
:
#
/
\
Unicode
```

Sono vietati nei valori:

```text
NUL
TAB
CR
LF
```

Non esiste quoting o escaping nel formato v0.

Un valore vuoto è ammesso quando lo schema del file lo consente:

```text
field_name<TAB><LF>
```

Il formato base non interpreta boolean, integer, pathname o altri tipi: la semantica e la validazione del valore appartengono allo schema specifico.

---

# 4. Encoding e line ending

```text
encoding       UTF-8
BOM            forbidden
line ending    LF
final LF       required per file generati da RumiAI
```

Ogni record dati contiene esattamente:

```text
field-name
1 TAB
field-value
1 LF
```

---

# 5. Unicità

Ogni `field-name` deve comparire al massimo una volta nello stesso file.

Esempio vietato:

```text
pkg_profile	default
pkg_profile	test
```

Un duplicato è errore di formato/schema, non "last value wins".

Questo permette lookup deterministico senza dipendenza dall'ordine del file.

---

# 6. Ordine

L'ordine fisico dei field non ha significato semantico salvo esplicita eccezione definita da uno schema futuro.

Quando serve rappresentare una sequenza o una struttura ripetibile, l'indice viene incorporato nel `field-name` usando soltanto caratteri validi per un POSIX variable name.

Esempio:

```text
requirement_1_id	jdk
requirement_1_target	capability
requirement_1_capability	java-development-kit
requirement_1_contract	1
requirement_1_constraint	>=17 <22

requirement_2_id	python
requirement_2_target	capability
requirement_2_capability	python-runtime
requirement_2_contract	1
requirement_2_constraint	>=3.12 <3.14
```

L'indice serve a raggruppare i field appartenenti alla stessa entry.

L'identità reale della entry resta un valore (`requirement_1_id = jdk`), non viene codificata nel nome del campo.

Questo evita di dover trasformare ID arbitrari, Unicode o stringhe con `-` in pseudo-nomi POSIX.

---

# 7. Indici canonici

Quando uno schema usa liste indicizzate:

```text
1
2
3
...
```

sono interi positivi base 10 senza zero iniziali.

Esempi canonici:

```text
requirement_1_id
requirement_2_id
requirement_10_id
```

Non canonici:

```text
requirement_01_id
requirement_002_id
```

Lo schema specifico decide se gli indici devono essere contigui.

---

# 8. Commenti e righe vuote

Per file di configurazione human-editable sono ammesse:

```text
righe vuote
righe di commento con `#` come primo byte della riga
```

Esempio:

```text
# pkg configuration

schema	1
pkg_profile	default
```

`#` dentro `field-value` è testo normale:

```text
label	test #1
```

I file generati automaticamente da RumiAI DEVONO preferire la forma canonica senza commenti e senza righe vuote, salvo che lo schema richieda diversamente.

---

# 9. Nessun `source` / `eval`

Il System Field Format è **dati**, non shell code.

Un file in questo formato non viene eseguito con:

```text
.
source
eval
```

Il fatto che `field-name` sia compatibile con un POSIX variable name serve a rendere semplice e sicuro il mapping verso variabili/funzioni del bootstrap, non a trasformare il file in codice eseguibile.

Le librerie POSIX `sh` del system layer possono invece essere sourced normalmente perché sono codice dichiarato come tale.

---

# 10. Bootstrap Rumi

Il bootstrap Rumi fornisce funzioni standard per interagire con System Field Format, così i tool system-layer non devono reimplementare il parser.

API concettuale minima:

```text
rumi_file_get <file> <field-name>
rumi_file_has <file> <field-name>
rumi_file_set <file> <field-name> <field-value>
rumi_file_remove <file> <field-name>
rumi_file_fields <file> [prefix]
rumi_file_validate <file> [schema]
```

Le firme fisiche POSIX `sh` saranno definite nella specifica bootstrap.

Il bootstrap deve almeno garantire:

```text
validazione field-name POSIX
split su un solo TAB
rifiuto record con zero o più di un TAB
rifiuto duplicate field-name
preservazione esatta del field-value
nessun eval/source del contenuto
```

---

# 11. Esempio `pkg` configuration

```text
# RumiAI package manager configuration

schema	1
pkg_profile	default
pkg_verify_integrity	true
pkg_retain_generations	true
pkg_automatic_prune	false

selection_1_id	java-runtime
selection_1_capability	java-runtime
selection_1_contract	1
selection_1_provider	temurin
selection_1_order	10

selection_2_id	python-runtime
selection_2_capability	python-runtime
selection_2_contract	1
selection_2_provider	cpython
selection_2_order	20
```

Tutti i field-name sono direttamente compatibili con POSIX shell variable names.

---

# 12. Relazione con JSON

```text
RumiAI development/application layer
    JSON standard v0

RumiAI system layer
    POSIX sh + Rumi bootstrap
    System Field Format v0 per configurazione/metadata system-layer dove appropriato
```

Il System Field Format non sostituisce JSON fuori dal system layer.

Analogamente, JSON non è una dipendenza del bootstrap/system layer.

---

# 13. Invarianti

```text
SFF-01 record = field-name<TAB>field-value
SFF-02 esattamente due campi per record
SFF-03 field-name segue [A-Za-z_][A-Za-z0-9_]*
SFF-04 field-name è case-sensitive
SFF-05 field-name è unico nel file
SFF-06 field-value è UTF-8 opaco al formato base
SFF-07 NUL/TAB/CR/LF sono vietati nel field-value
SFF-08 nessun quoting/escaping v0
SFF-09 strutture ripetibili usano indici numerici nel field-name; identity reale resta nel value
SFF-10 ordine fisico non è semantico per default
SFF-11 commento valido solo con # come primo byte della riga
SFF-12 il formato è dati e non viene source/eval
SFF-13 il bootstrap Rumi fornisce le primitive standard di accesso
SFF-14 nessun parser JSON/Python/Node/jq è richiesto per leggere il formato
```
