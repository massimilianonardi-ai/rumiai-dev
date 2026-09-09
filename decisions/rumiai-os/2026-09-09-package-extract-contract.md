# Decisione — Contratto di `pkg_extract` e formati iniziali

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente ha già fissato:

```text
lib/sh/pkg-extract.lib.sh
pkg_extract
```

come layer repository-neutral fra download e integrazione.

La decisione `2026-09-09-digest-and-extract-system-utilities.md` ha promosso la decompressione/estrazione generica alla utility di sistema:

```text
extract
```

Questa revisione mantiene in `pkg_extract` soltanto le policy package-specific: validazione dell'artifact, staging reale e vuoto, elenco dei format package ammessi e trattamento AppImage opaco. La selezione delle utility host per gli archivi appartiene invece a `extract`.

---

## 1. File e API canonici

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

L'API pubblica è:

```text
pkg_extract <artifact> <format> <staging-dir>
```

Input:

```text
artifact      regular file locale già scaricato e verificato
format        token esplicito determinato dal packaging/resolution
staging-dir   directory reale già esistente e vuota
```

Su successo il contenuto materializzato esiste esclusivamente nello staging directory e la funzione ritorna `0`.

---

## 2. Nessuna autodetection semantica

`pkg_extract` non determina il formato dal repository type e non usa il filename come autorità per scegliere il backend.

Il secondo argomento `format` è sempre esplicito.

Il filename viene usato soltanto dalla materializzazione AppImage opaca e, dentro la utility `extract`, per derivare il nome di output dei formati single-stream.

---

## 3. Staging

Lo staging directory deve essere:

```text
esistente
reale, non symlink
vuoto all'ingresso
```

`pkg_extract` non pubblica direttamente dentro `$m_ROOT/pkg` e non modifica selector, binding o state RumiAI.

Se una materializzazione fallisce dopo aver prodotto contenuto parziale, l'intero staging è da considerare invalido e il caller deve scartarlo. Il layer non tenta una transaction/rollback ricorsiva generica dentro una directory che non possiede.

`pkg_extract` e `extract` non sono sandbox. L'hardening universale contro archive traversal, symlink/hardlink escape e pathology dei backend è un contratto separato se emergerà il requisito concreto.

---

## 4. Formati delegati a `extract`

I seguenti format package sono delegati senza autodetection a:

```text
extract <format> <artifact> <staging-dir>
```

Formati:

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

---

## 5. AppImage

`appimage` resta una materialization mode package-specific opaca e **non** viene delegata a `extract`.

Il layer:

```text
non esegue l'AppImage
non usa --appimage-extract
non monta il payload
copia il regular file nello staging preservandone il basename e il mode
```

Un AppImage può tecnicamente autoestrarsi tramite `--appimage-extract`, ma ciò richiede l'esecuzione dell'artifact upstream. Installazione ed esecuzione sono trust boundary distinti: il fatto che il software possa essere eseguito dopo l'installazione non autorizza esecuzione implicita durante la materializzazione.

L'integrazione successiva deciderà come esporre/eseguire l'AppImage installato.

---

## 6. Utility mancanti e backend failure

Per i format delegati, diagnostica e capability detection dei backend host appartengono a `extract`.

`pkg_extract` tratta un exit non-zero della utility come extraction failure package-level:

```text
status 1
staging invalido da scartare dal caller
```

Non viene effettuato fallback verso un format differente.

---

## 7. Formati esclusi dal baseline

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

## 8. Exit status

```text
0  materializzazione riuscita
1  artifact/staging invalido o backend/materialization failure
2  numero di argomenti o format token non supportato
```

---

## 9. Testing

I test permanenti di `pkg_extract` devono proteggere almeno:

```text
API e requisito staging vuoto
assenza di autodetection implicita
delega dei format archive/compression a extract
propagazione backend failure come extraction failure package-level
AppImage non eseguito e copiato come file opaco preservando il mode
format non supportato -> status 2
```

Mapping format→backend, alias, single-stream naming, missing utility e caso reale tar.gz appartengono invece ai test permanenti della utility `extract` e non vengono duplicati nel package layer.

La physical validation dei backend reali resta revision-specific e separata.

---

## 10. Invarianti fissati

```text
PKG-EXTRACT-01  file canonico lib/sh/pkg-extract.lib.sh; libreria non eseguibile e senza shebang
PKG-EXTRACT-02  API = pkg_extract <artifact> <format> <staging-dir>
PKG-EXTRACT-03  format è esplicito e non viene dedotto dal repository type
PKG-EXTRACT-04  staging deve esistere, essere reale e vuoto
PKG-EXTRACT-05  archive/compression/deb/dmg vengono delegati alla utility di sistema extract
PKG-EXTRACT-06  pkg_extract non seleziona direttamente tar/gzip/bzip2/xz/zstd/unzip/7zip/dpkg-deb
PKG-EXTRACT-07  AppImage non viene eseguito, non usa --appimage-extract e viene copiato opacamente preservando basename e mode
PKG-EXTRACT-08  AppImage resta fuori dalla utility generale extract
PKG-EXTRACT-09  backend failure invalida lo staging; il caller lo scarta prima di integration
PKG-EXTRACT-10  pkg_extract resta repository-neutral e non modifica package state RumiAI
PKG-EXTRACT-11  pkg_extract/extract non sono definiti come sandbox; archive hardening è contratto separato
```
