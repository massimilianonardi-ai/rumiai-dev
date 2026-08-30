# RumiAI package manager — Integrity Method 1

Data: 2026-08-30

Stato: **design decision — canonical integrity format v0 fissato**

Prerequisiti:

```text
drafts/rumiai-os/system-field-format-v0/README.md
drafts/rumiai-os/package-manager-package-instance-layout/README.md
drafts/rumiai-os/package-manager-serialization-v0/README.md
```

Integrity Method 1 definisce la rappresentazione canonica degli inventory di:

```text
root/
run-default/
```

Ogni tree usa un file separato:

```text
@integrity-root.tsv
@integrity-run-default.tsv
```

Entrambi usano RumiAI System Field Format v0 a due campi.

---

# 1. Obiettivo

Il formato deve essere:

```text
deterministico
streamabile
semplice da verificare
leggibile da POSIX sh/awk tramite bootstrap Rumi
indipendente da JSON/Python/Node/jq
compatibile con Unicode
senza quoting/escaping del pathname
```

I caratteri che interferirebbero con record/field framing vengono vietati nei pathname e nei symlink target invece di introdurre una mini-sintassi di escaping.

---

# 2. Encoding e framing

Ogni inventory segue System Field Format:

```text
field-name<TAB>field-value<LF>
```

Regole machine-generated:

```text
UTF-8
no BOM
LF line ending
LF finale obbligatorio
nessun commento
nessuna blank row
field-name unico
```

Header:

```text
kind	integrity
schema	1
```

---

# 3. Collection directory

```text
directory_count	N
```

Ogni entry usa:

```text
directory_<i>_path	<canonical-path>
directory_<i>_mode	0500
```

Esempio:

```text
directory_count	2
directory_1_path	.
directory_1_mode	0500
directory_2_path	./bin
directory_2_mode	0500
```

Il record `.` rappresenta la root del tree inventariato e partecipa a `directory_count`.

---

# 4. Collection regular file

```text
file_count	N
```

Ogni entry usa:

```text
file_<i>_path	<canonical-path>
file_<i>_mode	0400|0500
file_<i>_digest	<digest>
```

Esempio:

```text
file_count	2
file_1_path	./bin/foo
file_1_mode	0500
file_1_digest	<sha256>
file_2_path	./lib/foo.jar
file_2_mode	0400
file_2_digest	<sha256>
```

Digest regular file:

> digest dei byte esatti del contenuto del file secondo `integrity_algorithm` dichiarato da `@package`.

Mode v0 normalizzati:

```text
0400    regular non-executable
0500    regular executable
```

---

# 5. Collection symlink

```text
link_count	N
```

Ogni entry usa:

```text
link_<i>_path	<canonical-path>
link_<i>_target	<canonical-relative-target>
link_<i>_digest	<digest-target>
```

Esempio:

```text
link_count	1
link_1_path	./log
link_1_target	../run/log
link_1_digest	<sha256-target>
```

Il symlink non viene dereferenziato per calcolare il proprio digest.

`link_<i>_digest` è il digest dei byte UTF-8 della canonical target string definita da Method 1.

Mode/UID/GID del symlink non partecipano all'integrity.

---

# 6. Oggetti filesystem ammessi

Method 1 rappresenta soltanto:

```text
directory
regular file
symbolic link
```

Altri filesystem object type non fanno parte di Integrity Method 1.

Package producer/admission deve normalizzare o rifiutare oggetti non rappresentabili dal metodo.

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
TAB         delimitatore System Field Format
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

La forma persistita è UTF-8 della stringa NFC.

Per regular file, la normalizzazione del pathname non modifica i byte del contenuto file.

Per symlink, `link_<i>_digest` viene calcolato sulla target string canonica NFC.

### Bootstrap requirement

POSIX `sh`, POSIX `awk` e `sed` non forniscono una primitive completa e portabile per:

```text
Unicode NFC normalization
Unicode default case-fold
```

Quindi il bootstrap Rumi DEVE esporre primitive normative per queste operazioni, oppure la validazione deve essere delegata a un producer/validator fidato prima dell'ammissione locale.

La scelta raccomandata è esporre le primitive nel bootstrap Rumi e mantenere invariata la semantica Method 1.

---

# 9. Canonical pathname syntax

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
caratteri vietati secondo §7
```

Il pathname `.` è l'unica eccezione alla regola sui componenti `.` ed è ammesso esclusivamente per la root del tree.

---

# 10. Portable collision rule

All'interno dello stesso tree non possono esistere due pathname fisicamente distinti che collidono dopo canonicalizzazione portabile.

Collision key:

```text
NFC
→ Unicode default case fold
→ NFC
```

Se due path distinti producono la stessa collision key:

```text
INTEGRITY_PATH_COLLISION
```

La regola vale per tutte le Package Instance v0, non soltanto `any-any`.

Il pathname canonico originale conserva il case.

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

I componenti `..` sono ammessi perché necessari a link relativi legittimi, per esempio:

```text
../run/log
```

La risoluzione lessicale rispetto alla directory parent del link non può uscire dalla wrapper:

```text
pkg/<package-instance-id>/
```

Le regole più specifiche restano al livello Package Instance/State Mapping.

---

# 12. Canonical collection ordering

Il precedente ordinamento globale dei record per path viene sostituito da un ordine canonico compatibile con System Field Format indicizzato.

Ordine delle sezioni:

```text
1 kind
2 schema
3 directory_count
4 directory entries 1..N
5 file_count
6 file entries 1..N
7 link_count
8 link entries 1..N
```

Dentro ciascuna collection, gli indici vengono assegnati dopo ordinamento:

```text
ascending lexicographic order dei byte UTF-8 del canonical NFC pathname
```

Dentro ogni entry l'ordine field è fisso:

```text
directory: path, mode
file:      path, mode, digest
link:      path, target, digest
```

Non si usa un semplice lexical sort dei field-name, perché `file_10_*` verrebbe prima di `file_2_*`.

---

# 13. Counts

Ogni inventory contiene obbligatoriamente:

```text
directory_count
file_count
link_count
```

`@package` mantiene gli stessi count come summary/cross-check.

I due insiemi devono concordare esattamente.

Gli indici di ogni collection sono contigui `1..N`.

---

# 14. Manifest digest

`manifest_digest` dichiarato da `@package` è:

> digest dei byte esatti dell'intero inventory System Field Format canonico, inclusi field-name, TAB, field-value, LF, ordine canonico e LF finale.

Quindi cambia se cambia:

```text
entry type/collection
mode file/directory
file content digest
symlink canonical target/digest
canonical pathname
numero/ordine entry
```

---

# 15. `@package` reference

Esempio:

```text
integrity_method	1
integrity_algorithm	sha256
integrity_root_inventory	@integrity-root.tsv
integrity_root_files	120
integrity_root_directories	24
integrity_root_links	3
integrity_root_manifest_digest	...
integrity_run_default_inventory	@integrity-run-default.tsv
integrity_run_default_files	8
integrity_run_default_directories	5
integrity_run_default_links	0
integrity_run_default_manifest_digest	...
```

I nomi inventory sono package-wrapper relative e non pathname host assoluti.

---

# 16. Streaming verifier property

Un verifier non deve usare `rumi_file_get` ripetutamente per ogni entry.

Può processare una collection in singola passata tramite bootstrap/per-prefix streaming:

```text
rumi_file_fields <inventory> directory_
rumi_file_fields <inventory> file_
rumi_file_fields <inventory> link_
```

oppure una primitive equivalente che attraversa il documento una volta.

Durante la scansione può:

```text
validare field-name/schema/index
validare canonical Unicode/path syntax
controllare monotonic pathname ordering dentro la collection
aggiornare count
aggiornare manifest digest incrementale sull'intero file
verificare il physical entry corrispondente
```

Per il collision check portabile può essere necessario mantenere un set/index delle collision key o usare una strategia bootstrap dedicata.

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
IM1-01 inventory usa System Field Format v0 a due campi
IM1-02 kind=integrity + schema=1
IM1-03 collection v0 = directory | file | link
IM1-04 collection usa count + indici contigui 1..N
IM1-05 TAB/CR/LF/NUL/backslash sono vietati in pathname e symlink target
IM1-06 Unicode è ammesso e canonicalizzato NFC
IM1-07 pathname usa solo `/` e forma `.` oppure `./...`
IM1-08 pathname non contiene empty/. /.. components
IM1-09 portable collision check = NFC + casefold + NFC
IM1-10 symlink target è relativo; `..` è ammesso quando semanticamente valido
IM1-11 symlink target inventariato non può risolvere fuori dalla Package Instance wrapper
IM1-12 file digest = byte content digest
IM1-13 symlink digest = digest della canonical UTF-8 target string
IM1-14 mode partecipa a directory/regular file; symlink mode no
IM1-15 entry index order = ascending canonical UTF-8 pathname bytes dentro ciascuna collection
IM1-16 manifest digest = digest dei byte esatti dell'inventory canonico con LF finale
IM1-17 inventory grandi usano streaming bootstrap, non repeated lookup
IM1-18 bootstrap/validator deve fornire Unicode NFC + case-fold semantics normative
```
