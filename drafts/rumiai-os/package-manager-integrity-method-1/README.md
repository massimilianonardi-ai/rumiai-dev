# RumiAI package manager — Integrity Method 1

Data: 2026-08-30

Stato: **design decision — canonical integrity format v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
drafts/rumiai-os/json-standard-v0/README.md
```

Integrity Method 1 definisce la rappresentazione canonica degli inventory di:

```text
root/
run-default/
```

Ogni tree usa un file TSV separato:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

Il descriptor `@package` JSON contiene metodo, algoritmo, conteggi, pathname dell'inventory e digest dell'intero manifest TSV.

---

# 1. Obiettivo

Il formato deve essere:

```text
deterministico
streamabile
semplice da verificare
facilmente leggibile da shell/awk
indipendente da Python
compatibile con Unicode
senza quoting/escaping del pathname
```

Per ottenere questo risultato, i caratteri che interferirebbero con record/field framing vengono vietati nei pathname e nei symlink target invece di introdurre una mini-sintassi di escaping.

---

# 2. Encoding e framing

Ogni inventory è:

```text
UTF-8
no BOM
LF line ending
LF finale obbligatorio
nessuna header row
nessuna blank row
```

Ogni record contiene esattamente:

```text
5 campi
4 TAB ASCII U+0009
```

Schema:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path<LF>
```

`path` è sempre l'ultimo campo.

Poiché TAB, CR e LF non sono ammessi nei campi pathname/target, il parser non necessita quoting o escaping.

---

# 3. Type

Token v0:

```text
D    directory
F    regular file
L    symbolic link
```

Altri filesystem object type non fanno parte di Integrity Method 1.

Package producer/admission deve normalizzare o rifiutare oggetti non rappresentabili dal metodo.

---

# 4. Record directory

Forma:

```text
D<TAB><mode><TAB>-<TAB>-<TAB><path>
```

Esempio:

```text
D	0500	-	-	.
D	0500	-	-	./bin
```

Il record:

```text
.
```

rappresenta la root del tree inventariato.

Directory immutable v0 usa normalmente:

```text
0500
```

---

# 5. Record regular file

Forma:

```text
F<TAB><mode><TAB><digest><TAB>-<TAB><path>
```

Esempi:

```text
F	0500	<sha256>	-	./bin/foo
F	0400	<sha256>	-	./lib/foo.jar
```

Digest regular file:

> digest dei byte esatti del contenuto del file secondo `integrity.algorithm`.

Mode v0 normalizzati:

```text
0400    regular non-executable
0500    regular executable
```

L'executable semantic è quindi protetta dall'integrity.

---

# 6. Record symlink

Forma:

```text
L<TAB>-<TAB><digest-target><TAB><target><TAB><path>
```

Esempio:

```text
L	-	<sha256-target>	../run/log	./log
```

Il symlink non viene dereferenziato per calcolare il proprio digest.

`digest-target` è il digest dei byte UTF-8 della **canonical target string** definita da Method 1.

Mode/UID/GID del symlink non partecipano all'integrity.

Per un record `L`, il valore `-` nel campo `target` è un target letterale valido se un symlink reale punta precisamente al nome `-`; l'interpretazione dei campi è determinata da `type`, quindi non esiste ambiguità.

---

# 7. Caratteri vietati in pathname e symlink target

Sono vietati:

```text
NUL        U+0000
TAB        U+0009
LF         U+000A
CR         U+000D
backslash  U+005C  \
```

Motivi:

```text
NUL         incompatibilità fondamentale con filesystem/API comuni
TAB         delimitatore TSV
CR/LF       delimitatori record / ambiguità line-oriented
backslash   separator/escape con semantiche incompatibili fra Unix e Windows
```

Non viene imposto ASCII-only.

Unicode è ammesso.

---

# 8. Unicode canonical form

Pathname e symlink target sono rappresentati semanticamente come Unicode e canonicalizzati in:

```text
Unicode NFC
```

La forma registrata nel TSV è UTF-8 della stringa NFC.

Questa regola permette di non vietare Unicode e riduce differenze fra filesystem che possono rappresentare sequenze Unicode equivalenti in forme differenti.

Per regular file, la normalizzazione del pathname non modifica i byte del contenuto file: il file digest resta sempre digest dei byte esatti del file.

Per symlink, `digest-target` viene calcolato sulla target string canonica NFC, non su una eventuale rappresentazione filesystem Unicode non canonica equivalente.

---

# 9. Canonical pathname syntax

Path record:

```text
root entry      .
other entry     ./<component>[/<component>...]
```

Regole:

```text
separator = /
nessun pathname assoluto
nessun componente vuoto
nessun componente .
nessun componente ..
nessun // ripetuto
nessun trailing /, salvo che / non compare come root syntax
Unicode NFC
caratteri vietati secondo §7
```

Il pathname `.` è l'unica eccezione alla regola sui componenti `.` ed è ammesso esclusivamente per il root record del tree.

La rappresentazione fisica letta dal filesystem viene convertita alla canonical RumiAI pathname prima di produrre/confrontare l'inventory.

---

# 10. Portable collision rule

All'interno dello stesso tree non possono esistere due pathname fisicamente distinti che collidono dopo canonicalizzazione portabile.

Per ogni canonical path viene derivata una collision key:

```text
NFC
→ Unicode default case fold
→ NFC
```

Se due path distinti producono la stessa collision key:

```text
INTEGRITY_PATH_COLLISION
```

Esempi incompatibili nello stesso tree:

```text
./Foo.txt
./foo.txt
```

oppure due rappresentazioni Unicode canonically equivalent dello stesso nome.

La regola vale per tutte le Package Instance v0, non soltanto `any-any`, così l'inventory mantiene una grammatica/filesystem safety unica e prevedibile.

Il pathname canonico originale conserva comunque il case; non viene convertito in lowercase.

---

# 11. Canonical symlink target syntax

Il target deve essere:

```text
relativo
Unicode NFC
separator = /
non vuoto
```

Sono vietati i caratteri di §7.

Sono vietati:

```text
leading /
repeated //
component .
trailing /
```

I componenti:

```text
..
```

sono ammessi perché necessari a link relativi legittimi, per esempio:

```text
../run/log
```

Un target con drive-prefix/forma assoluta riconoscibile da una reference platform è rifiutato come absolute target.

La semantica del link viene inoltre validata lessicalmente rispetto alla directory parent del link: la risoluzione non può uscire dalla wrapper:

```text
pkg/<package-instance-id>/
```

Method 1 garantisce quindi che un symlink inventariato non possa essere usato come escape verso pathname host arbitrari.

Le regole più specifiche restano al livello Package Instance/State Mapping. Per esempio una writable island sotto `root/` deve continuare ad avere il target relativo atteso verso `../run/<path>` secondo il relativo contratto.

---

# 12. Canonical ordering

I record vengono ordinati per il valore `path` canonico.

Ordine Method 1:

```text
ascending lexicographic order dei byte UTF-8 del canonical NFC pathname
```

Conseguenze:

```text
ordine indipendente da locale
ordine indipendente da filesystem enumeration
root `.` naturalmente precede i descendant `./...`
```

Il type non è un tie-breaker: due record con lo stesso canonical path sono invalidi.

---

# 13. Counts

`@package` mantiene per ciascun inventory:

```text
files
directories
links
```

I count devono concordare esattamente con i record TSV.

Il root record `D ... .` partecipa al directory count.

---

# 14. Manifest digest

`manifest-digest` è:

> digest dei byte esatti dell'intero file TSV canonico, inclusi TAB, LF, ordine dei record e LF finale.

Quindi cambia se cambia:

```text
entry type
mode file/directory
file content digest
symlink canonical target/digest
canonical pathname
numero/ordine record
```

Il digest non dipende da JSON pretty-printing o object member order del descriptor `@package`.

---

# 15. `@package` reference

Esempio concettuale JSON:

```json
{
    "integrity":
    {
        "method": 1,
        "algorithm": "sha256",
        "root":
        {
            "inventory": "@integrity-root.tsv",
            "files": 120,
            "directories": 24,
            "links": 3,
            "manifest-digest": "..."
        },
        "run-default":
        {
            "inventory": "@integrity-run-default.tsv",
            "files": 8,
            "directories": 5,
            "links": 0,
            "manifest-digest": "..."
        }
    }
}
```

I nomi inventory sono package-wrapper relative e non pathname host assoluti.

---

# 16. Streaming parser property

Un verifier può processare il TSV una riga alla volta.

Per ogni record può:

```text
split su esattamente quattro TAB
validare 5 field
validare type-specific field grammar
validare canonical Unicode/path syntax
controllare monotonic path ordering
aggiornare count
aggiornare manifest digest incrementale
verificare il physical entry corrispondente
```

Non è necessario caricare l'intero inventory in memoria.

Per il collision check portabile può essere necessario mantenere un set/index delle collision key oppure usare una seconda strategia di validation deterministica; questo non cambia il formato persistito.

---

# 17. Error classes

```text
INTEGRITY_MANIFEST_FORMAT_ERROR
INTEGRITY_PATH_ERROR
INTEGRITY_PATH_COLLISION
INTEGRITY_SYMLINK_TARGET_ERROR
INTEGRITY_ORDER_ERROR
INTEGRITY_COUNT_MISMATCH
INTEGRITY_DIGEST_MISMATCH
INTEGRITY_CONTENT_MISMATCH
```

---

# 18. Invarianti

```text
IM1-01 inventory = UTF-8 canonical TSV senza header
IM1-02 ogni record ha esattamente 5 campi / 4 TAB
IM1-03 path è sempre l'ultimo campo
IM1-04 record type v0 = D | F | L
IM1-05 TAB/CR/LF/NUL/backslash sono vietati in pathname e symlink target
IM1-06 Unicode è ammesso e canonicalizzato NFC
IM1-07 pathname usa solo `/` e forma `.` oppure `./...`
IM1-08 pathname non contiene empty/. /.. components
IM1-09 portable collision check = NFC + casefold + NFC
IM1-10 symlink target è relativo; `..` è ammesso quando semanticamente valido
IM1-11 symlink target inventariato non può risolvere fuori dalla Package Instance wrapper
IM1-12 file digest = byte content digest
IM1-13 symlink digest = digest della canonical UTF-8 target string
IM1-14 mode partecipa a directory/regular file record; symlink mode no
IM1-15 record order = ascending canonical UTF-8 pathname bytes
IM1-16 manifest digest = digest dei byte esatti del TSV canonico con LF finale
IM1-17 inventory è streamabile e non richiede parser JSON/Python
```
