# Decisione — Contratto di `pkg_extract` e formati iniziali

Date: 2026-09-09  
Updated: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente ha fissato:

```text
lib/sh/pkg-extract.lib.sh
pkg_extract
```

come layer repository-neutral fra download e integrazione.

La decisione `2026-09-09-digest-and-extract-system-utilities.md` ha promosso la decompressione/estrazione generica alla utility di sistema:

```text
extract
```

La correzione esplicita dell'utente del 2026-09-09 fissa inoltre un confine semantico più forte rispetto alla prima versione di questa decisione:

> `pkg_extract` deve consegnare direttamente la useful root normalizzata, eliminando i wrapper/prefix upstream variabili fra release e piattaforme prima che il payload venga passato a `pkg_integrate`.

La prima versione di questa decisione, che considerava sufficiente lasciare nello staging il tree grezzo prodotto dall'estrazione, è superseded in quel punto.

`extract` resta invece una utility generale di estrazione e non acquisisce conoscenza delle package definition o della useful root di un package.

---

## 1. File canonico e confine API

La libreria canonica è:

```text
lib/sh/pkg-extract.lib.sh
```

È una libreria shell sourced:

```text
regular file
non executable
nessuno shebang
POSIX sh
```

La firma fisica implementata alla data della prima versione era:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Questa firma non viene promossa a contratto finale quando la useful-root normalization richiede informazioni package-specific aggiuntive.

Il contratto semantico corrente richiede che `pkg_extract` riceva, direttamente o attraverso il context di chiamata che verrà fissato con la package definition concreta, almeno:

```text
artifact locale già scaricato e verificato
format/materialization mode esplicito
informazione di normalizzazione della useful root applicabile al range/target selezionato
directory staging reale e vuota
```

La serializzazione esatta della useful-root normalization nella package definition e la firma fisica con cui tale informazione verrà consegnata a `pkg_extract` restano da fissare usando l'evidence prodotta da `pkg_analyze` sui package reali.

Non viene introdotto qui un nome di campo, una nuova primitive o una sintassi provvisoria.

---

## 2. Output: useful root normalizzata

Su successo, la directory staging consegnata al caller rappresenta **direttamente la useful root normalizzata del payload**.

Semanticamente:

```text
artifact upstream
    -> raw materialization
    -> eliminazione dei wrapper/prefix non appartenenti alla root utile
    -> staging root normalizzata
    -> pkg_integrate
```

Di conseguenza `pkg_integrate` non deve conoscere né ricostruire pathname come:

```text
<release-name>/
<product>/<version>/
prefix specifici della piattaforma
altri wrapper upstream variabili fra release
```

Il contenuto osservabile nello staging al termine di `pkg_extract` deve essere indipendente da tali wrapper quando la package definition li dichiara come non appartenenti alla useful root.

Quando il payload upstream è già materializzato direttamente nella root utile, la normalizzazione è identità e non deve introdurre un wrapper artificiale.

La normalizzazione riguarda la **radice del payload software**. È distinta dalla successiva normalizzazione dello state/path mutabile sotto il package installato (`root/ -> var/<area>/...`), che appartiene al layer di integrazione RumiAI.

---

## 3. Origine della normalizzazione

La useful-root normalization è informazione di package materialization e può cambiare fra:

```text
stream differenti
range di release differenti
target/osarch differenti
```

Non viene dedotta dal repository type.

`pkg_analyze` serve a osservare package reali e produrre evidence per stabilire quale root sia utile e quale informazione debba essere registrata nella package definition.

Il package manager non deve affidarsi a una scansione implicita di `root/` durante l'integrazione per correggere a posteriori wrapper upstream sconosciuti.

Questa decisione non fissa ancora se la rappresentazione finale debba esprimere un pathname relativo, una profondità o un'altra forma dichiarativa: tale scelta deve emergere dai casi reali senza introdurre una generalizzazione prematura.

---

## 4. Nessuna autodetection del format

`pkg_extract` non determina il formato dal repository type e non usa il filename come autorità per scegliere il backend.

Il `format` resta esplicito e deriva dalla package definition/resolution.

Il filename viene usato soltanto dalla materializzazione AppImage opaca e, dentro la utility `extract`, per derivare il nome di output dei formati single-stream.

La useful-root normalization non modifica questa separazione: format selection e payload-root normalization sono informazioni semanticamente distinte.

---

## 5. Staging

Lo staging directory deve essere:

```text
esistente
reale, non symlink
vuoto all'ingresso
```

`pkg_extract` può usare internamente materializzazione temporanea/raw staging per poter normalizzare il risultato, ma tale dettaglio non è parte dell'output contrattuale verso `pkg_integrate`.

`pkg_extract` non pubblica direttamente dentro `$m_ROOT/pkg` e non modifica selector, binding o state RumiAI.

Se materializzazione o normalizzazione falliscono dopo aver prodotto contenuto parziale, l'intero staging di output è da considerare invalido e il caller deve scartarlo.

`pkg_extract` e `extract` non sono sandbox. L'hardening universale contro archive traversal, symlink/hardlink escape e pathology dei backend è un contratto separato se emergerà il requisito concreto.

---

## 6. Formati delegati a `extract`

I seguenti format package restano delegati senza autodetection alla utility generale `extract` per la **raw extraction/materialization**:

```text
tar
tar.gz tgz
tar.bz2 tar.bzip2 tbz tbz2
tar.xz txz
tar.zst tzst
gzip gz
bzip bzip2 bz2
xz
zstd zst
zip jar war
7z 7zip dmg
deb
```

La scelta fra `tar`, `gzip`, `bzip2`, `xz`, `zstd`, `unzip`, `7zz|7z|7za` e `dpkg-deb` appartiene esclusivamente alla utility di sistema `extract`.

`pkg_extract` non contiene capability detection per tali utility e non ne replica le specifiche CLI.

Dopo il ritorno di `extract`, la responsabilità package-specific di scegliere/materializzare la useful root normalizzata resta in `pkg_extract`.

`extract` non viene esteso con parametri package-specific per assorbire questa responsabilità.

---

## 7. AppImage

`appimage` resta una materialization mode package-specific opaca e **non** viene delegata a `extract`.

Il layer:

```text
non esegue l'AppImage
non usa --appimage-extract
non monta il payload
materializza il regular file preservandone basename e mode
```

Per un payload opaco costituito dal solo AppImage, la staging root stessa è normalmente già la useful root e la normalizzazione è quindi identità.

Un AppImage può tecnicamente autoestrarsi tramite `--appimage-extract`, ma ciò richiede l'esecuzione dell'artifact upstream. Installazione ed esecuzione sono trust boundary distinti: il fatto che il software possa essere eseguito dopo l'installazione non autorizza esecuzione implicita durante la materializzazione.

L'integrazione successiva decide come esporre/eseguire l'AppImage installato.

---

## 8. Utility mancanti e failure

Per i format delegati, diagnostica e capability detection dei backend host appartengono a `extract`.

Un exit non-zero della raw extraction oppure una failure della useful-root normalization è una extraction/materialization failure package-level:

```text
status 1
staging invalido da scartare dal caller
```

Non viene effettuato fallback verso un format differente o verso una root differente non dichiarata.

---

## 9. Formati esclusi dal baseline

Non vengono aggiunti soltanto per completezza teorica:

```text
rar
rpm
iso
cab
msi
pkg macOS
installer exe
```

Potranno essere introdotti quando un package concreto li richiederà e sarà chiaro se debbano essere estratti, trattati come payload opaco o gestiti da una materialization mode dedicata.

---

## 10. Exit status

Il modello di status resta:

```text
0  materializzazione e useful-root normalization riuscite
1  artifact/staging invalido o backend/materialization/normalization failure
2  uso/API non valido o format token non supportato
```

La firma fisica finale può richiedere un aggiornamento quando verrà fissato il trasporto dell'informazione di normalizzazione; la classificazione semantica degli status resta quella sopra.

---

## 11. Testing e stato di riallineamento

I test permanenti dovranno proteggere almeno:

```text
staging reale e vuoto
assenza di autodetection implicita del format
delega dei format archive/compression a extract
propagazione backend failure come extraction failure package-level
AppImage non eseguito e materializzato opacamente preservando il mode
format non supportato -> status 2
normalizzazione identità quando la root upstream è già utile
eliminazione dei wrapper/prefix dichiarati dalla package definition
staging finale coincidente semanticamente con la useful root
failure se la normalizzazione dichiarata non può essere applicata in modo valido
assenza di useful-root discovery demandata a pkg_integrate
```

Mapping format→backend, alias, single-stream naming, missing utility e casi reali dei backend restano nei test della utility `extract` e non vengono duplicati nel package layer.

Alla data di questa correzione:

```text
rumiai-os/lib/sh/pkg-extract.lib.sh
rumiai-tests/tests/rumiai-os/pkg-extract/contract.test
```

implementano/proteggono ancora il precedente contratto di staging grezzo e la firma a tre argomenti.

Sono quindi **pending realignment** e non costituiscono autorità contro il contratto semantico corretto qui fissato.

La modifica dell'implementazione `rumiai-os` richiede una fase esplicitamente autorizzata dall'utente secondo `RULES.md`.

---

## 12. Invarianti fissati

```text
PKG-EXTRACT-01  file canonico lib/sh/pkg-extract.lib.sh; libreria non eseguibile e senza shebang
PKG-EXTRACT-02  pkg_extract è il layer repository-neutral di package materialization fra download e integration
PKG-EXTRACT-03  format è esplicito e non viene dedotto dal repository type
PKG-EXTRACT-04  staging di output deve esistere, essere reale e vuoto all'ingresso
PKG-EXTRACT-05  archive/compression/deb/dmg usano extract soltanto per raw extraction/materialization
PKG-EXTRACT-06  pkg_extract non seleziona direttamente tar/gzip/bzip2/xz/zstd/unzip/7zip/dpkg-deb
PKG-EXTRACT-07  AppImage non viene eseguito, non usa --appimage-extract e viene materializzato opacamente preservando basename e mode
PKG-EXTRACT-08  AppImage resta fuori dalla utility generale extract
PKG-EXTRACT-09  backend o normalization failure invalida lo staging; il caller lo scarta prima di integration
PKG-EXTRACT-10  pkg_extract resta repository-neutral e non modifica package state RumiAI
PKG-EXTRACT-11  pkg_extract/extract non sono definiti come sandbox; archive hardening è contratto separato
PKG-EXTRACT-12  su successo lo staging consegnato al caller rappresenta direttamente la useful root normalizzata
PKG-EXTRACT-13  wrapper/prefix upstream non appartenenti alla useful root vengono eliminati prima di pkg_integrate
PKG-EXTRACT-14  pkg_integrate non effettua discovery o correzione dei wrapper upstream
PKG-EXTRACT-15  useful-root normalization è package-definition materialization information e può variare per stream/range/target
PKG-EXTRACT-16  extract resta generic raw extraction e non conosce useful root o package definition
PKG-EXTRACT-17  la firma fisica precedente a tre argomenti è pending realignment e non viene trattata come API finale quando serve normalization context
PKG-EXTRACT-18  la serializzazione/trasporto concreto della normalization resta da fissare dai casi reali senza inventare una primitive provvisoria
```
