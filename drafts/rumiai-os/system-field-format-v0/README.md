# RumiAI system layer — System Field Format v0

Data: 2026-08-30

Stato: **design decision — formato system-layer fissato**

Il RumiAI system layer è composto da tool POSIX `sh` eseguiti tramite shebang/bootstrap Rumi.

I file dati/configurazione letti direttamente dal system layer usano un formato dichiarativo minimale, progettato per poter essere letto e scritto dal bootstrap con primitive POSIX `sh` e utility POSIX senza dipendere da JSON, Python, Node.js, `jq` o parser proprietari.

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
\\
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

Per i file del package manager questa limitazione diventa anche una regola di ammissibilità dei valori persistiti: un literal argv, label, constraint o altro valore che richieda TAB/CR/LF non è rappresentabile nel v0 e viene rifiutato invece di introdurre escaping.

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

L'ordine fisico dei field non ha significato semantico salvo esplicita eccezione definita da uno schema.

I file generati automaticamente da RumiAI DEVONO però usare l'ordine canonico definito dal relativo schema. Questo rende diff, digest, streaming e debugging deterministici senza trasformare l'ordine in significato logico.

Quando serve rappresentare una sequenza o una struttura ripetibile, l'indice viene incorporato nel `field-name` usando soltanto caratteri validi per un POSIX variable name.

Esempio:

```text
requirement_count	2

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

# 7. Collezioni indicizzate

Ogni collezione indicizzata del system layer DEVE avere un count esplicito:

```text
<prefix>_count	N
```

Gli indici validi sono obbligatoriamente:

```text
1
2
3
...
N
```

quindi sono:

```text
positivi
base 10
senza zero iniziali
contigui
senza gap
```

Esempi canonici:

```text
resource_count	3
resource_1_id	launcher
resource_2_id	home
resource_3_id	config
```

Non canonici:

```text
resource_01_id
resource_1_id
resource_3_id      # gap con count=3
```

Una collezione vuota viene rappresentata esplicitamente:

```text
requirement_count	0
```

Questo evita discovery costosa degli indici e permette loop POSIX `sh` deterministici.

Le collezioni annidate applicano la stessa regola:

```text
provide_count	1
provide_1_resource_count	3
provide_1_resource_1_key	command
provide_1_resource_2_key	home
provide_1_resource_3_key	bin
```

---

# 8. Mappe con chiavi arbitrarie

Una chiave arbitraria NON viene incorporata nel field-name se potrebbe non rispettare la grammar POSIX.

Si usa invece una collezione indicizzata key/value:

```text
entry_count	2
entry_1_key	foo-bar
entry_1_value	one
entry_2_key	café
entry_2_value	two
```

Regola:

> struttura nel field-name; identità/dato arbitrario nel field-value.

---

# 9. Valori opzionali, null e tipi canonici

Il formato base non ha `null`.

Uno schema rappresenta normalmente un valore opzionale tramite assenza del relativo field.

Un empty string resta distinto da field assente.

Quando uno schema usa tipi primitivi, le forme canoniche raccomandate sono:

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

Gli enum usano stringhe ASCII canoniche definite dallo schema.

---

# 10. Commenti e righe vuote

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

I file generati automaticamente da RumiAI DEVONO usare la forma canonica senza commenti e senza righe vuote, salvo che lo schema richieda diversamente.

---

# 11. Nessun `source` / `eval`

Il System Field Format è **dati**, non shell code.

Un file in questo formato non viene eseguito con:

```text
.
source
eval
```

Il fatto che `field-name` sia compatibile con un POSIX variable name serve a rendere semplice e sicuro il mapping e la costruzione dei nomi nel bootstrap, non a trasformare il file in codice eseguibile.

Le librerie POSIX `sh` del system layer possono invece essere sourced normalmente perché sono codice dichiarato come tale.

---

# 12. Bootstrap Rumi

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

Per evitare rescansioni quadratiche di file con collezioni grandi, il bootstrap DEVE inoltre fornire una primitive streaming/per-prefix equivalente a:

```text
rumi_file_fields <file> <prefix>
```

che legge il file una sola volta e restituisce soltanto record System Field Format corrispondenti al prefix richiesto.

L'implementazione può usare POSIX `awk`/`sed`/`grep` o primitive equivalenti del bootstrap, ma non richiede parser JSON o runtime esterni gestiti da `pkg`.

Il bootstrap deve almeno garantire:

```text
validazione field-name POSIX
split su un solo TAB
rifiuto record con zero o più di un TAB
rifiuto duplicate field-name
preservazione esatta del field-value
nessun eval/source del contenuto
validazione count/indici quando richiesta dallo schema
```

---

# 13. Performance rule

`rumi_file_get` è appropriato per pochi lookup puntuali.

Non è ammesso implementare loop su collezioni grandi come:

```text
for ogni entry
    per ogni field
        rumi_file_get che riscansiona l'intero file
```

perché produce comportamento O(n²) e process spawning eccessivo.

Per collezioni grandi si usa:

```text
count + indici contigui
streaming per prefix / singolo pass
```

Questa regola è particolarmente importante per:

```text
resolved dependency graph
integrity inventory
resource lists grandi
```

---

# 14. Esempio `pkg` configuration

```text
# RumiAI package manager configuration

schema	1
pkg_profile	default
pkg_verify_integrity	true
pkg_retain_generations	true
pkg_automatic_prune	false

selection_count	2

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

# 15. Relazione con JSON

```text
RumiAI development/application layer
    JSON standard v0

RumiAI system layer
    POSIX sh + Rumi bootstrap
    System Field Format v0
```

JSON non è una dipendenza del bootstrap/system layer.

I file dati del package manager appartengono al system layer e quindi usano System Field Format v0.

Formati fisici che non sono file dati parsati, per esempio script POSIX `sh`, directory, symlink o il file-handle usato esclusivamente per un OS lock, non sono System Field Format perché non rappresentano dati strutturati da leggere.

---

# 16. Invarianti

```text
SFF-01 record = field-name<TAB>field-value
SFF-02 esattamente due campi per record
SFF-03 field-name segue [A-Za-z_][A-Za-z0-9_]*
SFF-04 field-name è case-sensitive
SFF-05 field-name è unico nel file
SFF-06 field-value è UTF-8 opaco al formato base
SFF-07 NUL/TAB/CR/LF sono vietati nel field-value
SFF-08 nessun quoting/escaping v0
SFF-09 strutture ripetibili usano count + indici numerici contigui nel field-name; identity reale resta nel value
SFF-10 map key arbitrarie restano nei value, non nei field-name
SFF-11 ordine fisico non è semantico; output Rumi usa ordine canonico di schema
SFF-12 commento valido solo con # come primo byte della riga
SFF-13 il formato è dati e non viene source/eval
SFF-14 il bootstrap Rumi fornisce primitive standard di accesso e streaming
SFF-15 nessun parser JSON/Python/Node/jq è richiesto per leggere il formato
SFF-16 i file dati del package manager usano System Field Format v0
```
