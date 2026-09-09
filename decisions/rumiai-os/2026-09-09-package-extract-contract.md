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

> `pkg_extract` deve consegnare direttamente la useful root normalizzata, eliminando automaticamente i wrapper/prefix upstream variabili fra release e piattaforme prima che il payload venga passato a `pkg_integrate`.

Una successiva correzione dello stesso giorno chiarisce che questa normalizzazione **non** deve dipendere da pathname/version-specific metadata della package definition. Molti artifact includono la versione nel pathname interno; registrare quel pathname nel catalogo imporrebbe un nuovo range a ogni release e renderebbe incompatibile la normale semantica di `latest`.

La useful-root normalization è quindi una responsabilità strutturale e generica di `pkg_extract`.

`extract` resta invece una utility generale di estrazione e non acquisisce conoscenza dei package, dei range o della useful root.

---

## 1. File canonico e API

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

L'API resta:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Input:

```text
artifact      regular file locale già scaricato e verificato
format        token esplicito determinato dal packaging/resolution
staging-dir   destination reale già esistente e vuota scelta dal caller
```

Il terzo argomento è sempre il pathname di output scelto dal caller. `pkg_extract` non decide autonomamente dove collocare il payload e, in particolare, non sceglie né deriva `$m_ROOT/pkg`.

Non viene aggiunto un argomento o context di useful-root pathname proveniente dalla package definition.

---

## 2. Output: useful root normalizzata

Su successo, la directory staging consegnata al caller rappresenta **direttamente la useful root normalizzata del payload**.

Semanticamente:

```text
artifact upstream
    -> raw materialization
    -> structural useful-root discovery
    -> eliminazione dei wrapper/prefix strutturali
    -> staging root normalizzata
    -> caller
```

Il caller può usare tale destination come staging diagnostico/temporaneo oppure passarla successivamente a `pkg_integrate`. `pkg_extract` non effettua da solo la pubblicazione nel package store.

Di conseguenza `pkg_integrate` non deve conoscere né ricostruire pathname come:

```text
<release-name>/
<product>/<version>/
prefix specifici della piattaforma
altri wrapper upstream variabili fra release
```

Quando il payload upstream è già materializzato direttamente nella root utile, la normalizzazione è identità e non introduce un wrapper artificiale.

La normalizzazione riguarda la **radice del payload software**. È distinta dalla successiva normalizzazione dello state/path mutabile sotto il package installato (`root/<path> -> var/<area>/<path>`), che appartiene al layer di integrazione RumiAI.

---

## 3. Structural useful-root discovery

Il baseline usa una regola strutturale deterministica analoga alla responsabilità storicamente coperta da `find_deepest_dir`, senza importarne automaticamente il codice storico.

Dopo la raw materialization, partendo dalla root del tree estratto:

```text
finché il livello corrente contiene esattamente una entry
AND tale entry è una real directory, non symlink
    -> scendi nella directory

altrimenti
    -> il livello corrente è la useful root
```

La directory più profonda raggiunta da questa catena è la useful root strutturale.

Contano tutte le entry effettivamente presenti, incluse quelle con nome che inizia per `.`. Un symbolic link non viene seguito come wrapper directory.

Esempi:

```text
archive/
└── dbeaver-ce-26.1.5/
    ├── dbeaver
    ├── plugins/
    └── ...

-> useful root = contenuto di dbeaver-ce-26.1.5/
```

```text
archive/
└── product/
    └── 26.1.5/
        ├── bin/
        └── lib/

-> useful root = contenuto di product/26.1.5/
```

```text
archive/
├── bin/
└── lib/

-> useful root = archive/
```

Il pathname testuale dei wrapper non è parte del contratto e non viene persistito nella package definition.

Se emergerà un package reale la cui root semantica non è rappresentabile correttamente da questa regola strutturale, il caso dovrà essere valutato esplicitamente. Il baseline non introduce preventivamente override di pathname/depth nel catalogo.

---

## 4. Rapporto con range e `latest`

Una modifica che cambia soltanto il pathname dei wrapper strutturali dell'artifact non cambia la package definition e **non costituisce un nuovo range**.

In particolare forme come:

```text
foo-1.0/
foo-1.1/
foo-1.2/
```

oppure:

```text
foo/1.0/
foo/1.1/
foo/1.2/
```

non richiedono range separati se, dopo la normalizzazione strutturale, il payload utile mantiene lo stesso contratto di materialization/integration.

Questo preserva la regola già fissata secondo cui una nuova release successiva all'ultimo anchor appartiene automaticamente all'ultimo range finché non emerge una differenza **semantica reale** della package definition.

La useful-root wrapper path non viene quindi usata come discriminante di range e non può rendere `latest` dipendente dal nome interno della release.

---

## 5. Nessuna autodetection del format

`pkg_extract` non determina il formato dal repository type e non usa il filename come autorità per scegliere il backend.

Il `format` resta esplicito e deriva dalla package definition/resolution.

Il filename viene usato soltanto dalla materializzazione AppImage opaca e, dentro la utility `extract`, per derivare il nome di output dei formati single-stream.

Format selection e useful-root normalization restano responsabilità distinte: il primo è dichiarativo, la seconda è structural discovery generica.

---

## 6. Staging

Lo staging directory deve essere:

```text
scelto dal caller
esistente
reale, non symlink
vuoto all'ingresso
```

`pkg_extract` può usare internamente una raw materialization temporanea per applicare la normalizzazione prima di consegnare l'output. Il pathname/layout di tale area interna non è parte del contratto pubblico.

`pkg_extract` non pubblica direttamente dentro `$m_ROOT/pkg` e non modifica selector, binding o state RumiAI.

Se materializzazione o normalizzazione falliscono dopo aver prodotto contenuto parziale, l'intero staging di output è da considerare invalido e il caller deve scartarlo.

`pkg_extract` e `extract` non sono sandbox. L'hardening universale contro archive traversal, symlink/hardlink escape e pathology dei backend è un contratto separato se emergerà il requisito concreto.

---

## 7. Formati delegati a `extract`

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

Dopo il ritorno di `extract`, `pkg_extract` applica la structural useful-root discovery e consegna il payload normalizzato.

`extract` non viene esteso con parametri package-specific per assorbire questa responsabilità.

---

## 8. AppImage

`appimage` resta una materialization mode package-specific opaca e **non** viene delegata a `extract`.

Il layer:

```text
non esegue l'AppImage
non usa --appimage-extract
non monta il payload
materializza il regular file preservandone basename e mode
```

Per un payload opaco costituito dal solo AppImage, il livello contiene un file e non una singola real directory; la normalizzazione strutturale è quindi identità.

Un AppImage può tecnicamente autoestrarsi tramite `--appimage-extract`, ma ciò richiede l'esecuzione dell'artifact upstream. Installazione ed esecuzione sono trust boundary distinti: il fatto che il software possa essere eseguito dopo l'installazione non autorizza esecuzione implicita durante la materializzazione.

L'integrazione successiva decide come esporre/eseguire l'AppImage installato.

---

## 9. Utility mancanti e failure

Per i format delegati, diagnostica e capability detection dei backend host appartengono a `extract`.

Un exit non-zero della raw extraction oppure una failure della useful-root normalization è una extraction/materialization failure package-level:

```text
status 1
staging invalido da scartare dal caller
```

Non viene effettuato fallback verso un format differente.

---

## 10. Formati esclusi dal baseline

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

## 11. Exit status

```text
0  materializzazione e useful-root normalization riuscite
1  artifact/staging invalido o backend/materialization/normalization failure
2  numero di argomenti o format token non supportato
```

---

## 12. Testing e stato corrente

I test permanenti proteggono:

```text
API a tre argomenti e requisito staging vuoto
output nella destination scelta dal caller e nessuna pubblicazione implicita in $m_ROOT/pkg
assenza di autodetection implicita del format
delega dei format archive/compression a extract
propagazione backend failure come extraction failure package-level
AppImage non eseguito e materializzato opacamente preservando il mode
format non supportato -> status 2
normalizzazione identità quando la raw root ha più entry o non ha una singola real-directory entry
discesa attraverso uno o più wrapper single-directory
conteggio delle hidden entry nella regola strutturale
nessun follow di symlink come wrapper
staging finale coincidente con il contenuto della useful root strutturale
nessun pathname/version wrapper richiesto dalla package definition
assenza di useful-root discovery demandata a pkg_integrate
```

Mapping format→backend, alias, single-stream naming, missing utility e casi reali dei backend restano nei test della utility `extract` e non vengono duplicati nel package layer.

L'implementazione corrente di `rumiai-os/lib/sh/pkg-extract.lib.sh` e il test permanente `rumiai-tests/tests/rumiai-os/pkg-extract/contract.test` sono riallineati a questo contratto. La firma a tre argomenti è rimasta invariata.

I development checks sul fixture isolato sono distinti dalla physical validation revision-specific sui reference host.

---

## 13. Invarianti fissati

```text
PKG-EXTRACT-01  file canonico lib/sh/pkg-extract.lib.sh; libreria non eseguibile e senza shebang
PKG-EXTRACT-02  API = pkg_extract <artifact> <format> <staging-dir>
PKG-EXTRACT-03  pkg_extract è il layer repository-neutral di package materialization fra download e integration
PKG-EXTRACT-04  format è esplicito e non viene dedotto dal repository type
PKG-EXTRACT-05  staging di output è scelto dal caller e deve esistere, essere reale e vuoto all'ingresso
PKG-EXTRACT-06  archive/compression/deb/dmg usano extract soltanto per raw extraction/materialization
PKG-EXTRACT-07  pkg_extract non seleziona direttamente tar/gzip/bzip2/xz/zstd/unzip/7zip/dpkg-deb
PKG-EXTRACT-08  AppImage non viene eseguito, non usa --appimage-extract e viene materializzato opacamente preservando basename e mode
PKG-EXTRACT-09  AppImage resta fuori dalla utility generale extract
PKG-EXTRACT-10  backend o normalization failure invalida lo staging; il caller lo scarta prima di integration
PKG-EXTRACT-11  pkg_extract resta repository-neutral e non modifica package state RumiAI
PKG-EXTRACT-12  pkg_extract/extract non sono definiti come sandbox; archive hardening è contratto separato
PKG-EXTRACT-13  su successo lo staging consegnato al caller rappresenta direttamente la useful root normalizzata
PKG-EXTRACT-14  la useful root viene scoperta strutturalmente da pkg_extract, non dichiarata tramite pathname/version-specific metadata del catalogo
PKG-EXTRACT-15  la discovery scende finché il livello contiene esattamente una real-directory entry non symlink
PKG-EXTRACT-16  wrapper/prefix strutturali vengono eliminati prima di pkg_integrate
PKG-EXTRACT-17  pkg_integrate non effettua discovery o correzione dei wrapper upstream
PKG-EXTRACT-18  il cambio del solo wrapper pathname non crea un nuovo range e non altera la semantica di latest
PKG-EXTRACT-19  extract resta generic raw extraction e non conosce useful root o package definition
PKG-EXTRACT-20  non viene introdotto nel baseline un override di pathname/depth nella package definition
PKG-EXTRACT-21  pkg_extract non sceglie né deriva $m_ROOT/pkg: materializza esclusivamente nella destination ricevuta come terzo argomento
```
