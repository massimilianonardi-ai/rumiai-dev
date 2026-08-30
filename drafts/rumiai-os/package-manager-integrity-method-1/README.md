# RumiAI package manager — Integrity Method 1

Data: 2026-08-30

Stato: **design decision — canonical integrity TSV v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/system-tabular-data-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

Integrity Method 1 definisce la rappresentazione canonica degli inventory di:

```text
root/
run-default/
```

Ogni tree usa un file System Tabular Data separato:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

---

# 1. Obiettivo

Il formato deve essere:

```text
deterministico
streamabile
una riga per filesystem entry
semplice da verificare
leggibile da POSIX sh/awk tramite bootstrap Rumi
indipendente da JSON/Python/Node/jq
compatibile con Unicode
senza quoting/escaping del pathname
```

---

# 2. Header canonico

Prima riga obbligatoria:

```text
type<TAB>mode<TAB>digest<TAB>target<TAB>path<LF>
```

I nomi e l'ordine delle colonne sono normativi:

```text
1 type
2 mode
3 digest
4 target
5 path
```

`path` è sempre l'ultima colonna.

Header assente/diverso:

```text
INTEGRITY_MANIFEST_FORMAT_ERROR
```

---

# 3. Encoding e framing

Ogni inventory usa:

```text
UTF-8
no BOM
LF line ending
LF finale obbligatorio
header obbligatorio
nessuna blank row
nessun commento
```

Ogni data row contiene esattamente:

```text
5 campi
4 TAB
```

Una filesystem entry corrisponde esattamente a una data row.

---

# 4. Type

Token v0:

```text
D    directory
F    regular file
L    symbolic link
```

Altri filesystem object type non fanno parte di Method 1.

Producer/admission deve normalizzare o rifiutare oggetti non rappresentabili.

---

# 5. Directory row

Forma:

```text
D<TAB><mode><TAB>-<TAB>-<TAB><path>
```

Esempio:

```text
D	0500	-	-	.
D	0500	-	-	./bin
```

`.` rappresenta la root del tree inventariato.

Directory immutable v0 usa normalmente `0500`.

---

# 6. Regular file row

Forma:

```text
F<TAB><mode><TAB><digest><TAB>-<TAB><path>
```

Esempio:

```text
F	0500	<sha256>	-	./bin/foo
F	0400	<sha256>	-	./lib/foo.jar
```

Digest = digest dei byte esatti del contenuto secondo `integrity.algorithm` dichiarato in `@package`.

Mode normalizzati v0:

```text
0400    regular non-executable
0500    regular executable
```

---

# 7. Symlink row

Forma:

```text
L<TAB>-<TAB><digest-target><TAB><target><TAB><path>
```

Esempio:

```text
L	-	<sha256-target>	../run/log	./log
```

Il symlink non viene dereferenziato per calcolare il proprio digest.

`digest-target` = digest dei byte UTF-8 della canonical target string.

Mode/UID/GID del symlink non partecipano all'integrity.

---

# 8. Caratteri vietati in pathname e symlink target

Vietati:

```text
NUL        U+0000
TAB        U+0009
LF         U+000A
CR         U+000D
backslash  U+005C  \
```

Non viene imposto ASCII-only.

Unicode è ammesso.

La proibizione di TAB/CR/LF rende il TSV non ambiguo senza quoting/escaping.

---

# 9. Unicode canonical form

Pathname e symlink target sono rappresentati semanticamente come Unicode e canonicalizzati in:

```text
Unicode NFC
```

La forma persistita è UTF-8 NFC.

Per regular file, il content digest resta digest dei byte esatti del file.

Per symlink, il digest target viene calcolato sulla target string NFC.

### Bootstrap requirement

POSIX `sh`/`awk`/`sed` non garantiscono una primitive completa e portabile per:

```text
Unicode NFC normalization
Unicode default case-fold
```

Il bootstrap/platform adapter Rumi deve quindi esporre primitive normative per queste operazioni, oppure la validazione deve essere eseguita da un validator fidato con semantica equivalente.

---

# 10. Canonical pathname syntax

Path persistito:

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
nessun trailing /
Unicode NFC
caratteri vietati secondo §8
```

`.` è l'unica eccezione ed è ammesso soltanto come root entry.

---

# 11. Portable collision rule

Per ogni canonical path viene derivata:

```text
NFC
→ Unicode default case-fold
→ NFC
```

Due pathname fisicamente distinti con stessa collision key sono vietati:

```text
INTEGRITY_PATH_COLLISION
```

Esempio:

```text
./Foo.txt
./foo.txt
```

La regola vale per tutte le Package Instance v0.

---

# 12. Canonical symlink target

Il target deve essere:

```text
relativo
non vuoto
Unicode NFC
separator = /
```

Vietati:

```text
leading /
repeated //
component .
trailing /
caratteri di §8
```

`..` è ammesso quando necessario, per esempio:

```text
../run/log
```

La risoluzione lessicale rispetto alla directory parent del link non può uscire dalla Package Instance wrapper:

```text
pkg/<package-instance-id>/
```

Le writable island continuano inoltre a rispettare il contratto specifico `root/... -> ../run/...`.

---

# 13. Canonical row ordering

Tutte le data row vengono ordinate per `path` canonico:

```text
ascending lexicographic order dei byte UTF-8 del canonical NFC pathname
```

L'header resta sempre la prima riga.

Conseguenze:

```text
ordine indipendente dal locale
ordine indipendente dalla filesystem enumeration
`.` precede naturalmente `./...`
```

Due row con stesso canonical path sono invalide.

Il `type` non è tie-breaker.

---

# 14. Counts

`@package` mantiene per ciascun inventory:

```text
files
directories
links
```

I count devono concordare con le data row.

L'header non partecipa ai count.

Il root row `D ... .` partecipa al directory count.

---

# 15. Manifest digest

`manifest_digest` è:

> digest dei byte esatti dell'intero TSV canonico, a partire dall'header e fino al final LF.

Include quindi:

```text
header
column order
TAB separators
LF separators
all rows
canonical row order
final LF
```

Cambia se cambia:

```text
entry type
mode
file content digest
symlink canonical target/digest
canonical pathname
numero/ordine row
header/schema columns
```

---

# 16. `@package` reference

Esempio SCF:

```text
integrity.method	1
integrity.algorithm	sha256
integrity.root.inventory	@integrity-root.tsv
integrity.root.files	120
integrity.root.directories	24
integrity.root.links	3
integrity.root.manifest_digest	...
integrity.run_default.inventory	@integrity-run-default.tsv
integrity.run_default.files	8
integrity.run_default.directories	5
integrity.run_default.links	0
integrity.run_default.manifest_digest	...
```

I nomi inventory sono wrapper-relative, non host absolute path.

---

# 17. Streaming verifier

Il verifier:

```text
1 valida header
2 legge una data row alla volta
3 valida esattamente 5 field
4 valida grammar type-specific
5 valida canonical path/target
6 controlla monotonic path ordering
7 aggiorna counts
8 aggiorna manifest digest incrementale includendo i byte letti
9 verifica la physical entry corrispondente
```

Non è necessario caricare l'intero inventory in memoria.

Per il collision check può servire un set/index delle collision key o una primitive bootstrap dedicata.

---

# 18. Error classes

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

# 19. Invarianti

```text
IM1-01 inventory = canonical System Tabular Data
IM1-02 header esatto = type,mode,digest,target,path
IM1-03 one filesystem entry = one data row
IM1-04 ogni data row = 5 campi / 4 TAB
IM1-05 path è sempre ultima colonna
IM1-06 type v0 = D | F | L
IM1-07 TAB/CR/LF/NUL/backslash vietati in pathname e target
IM1-08 Unicode ammesso e canonicalizzato NFC
IM1-09 pathname = `.` oppure `./...`
IM1-10 portable collision = NFC + casefold + NFC
IM1-11 symlink target relativo; `..` ammesso quando semanticamente valido
IM1-12 symlink target non può risolvere fuori dalla wrapper
IM1-13 file digest = byte content digest
IM1-14 symlink digest = digest canonical UTF-8 target
IM1-15 mode partecipa per directory/file, non per symlink
IM1-16 data row order = ascending canonical UTF-8 pathname bytes
IM1-17 manifest digest include header + all rows + final LF
IM1-18 inventory è streamabile
IM1-19 bootstrap/validator deve fornire NFC + case-fold semantics normative
```
