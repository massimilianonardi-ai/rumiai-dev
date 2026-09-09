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

L'utente ha richiesto il supporto iniziale per tar, tar.gz/tgz, gzip, bzip, tar.xz/xz, zip, 7z/7zip, jar, war, AppImage e deb, con fallimento esplicito quando l'utility host necessaria non è disponibile.

Il catalogo DBeaver corrente contiene inoltre artifact macOS `.dmg`, quindi `dmg` è un formato aggiuntivo concreto e utile da coprire nella stessa astrazione. Vengono inclusi anche alias/compressioni strettamente adiacenti ai formati richiesti, senza introdurre un framework universale degli archivi.

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

Il filename viene usato soltanto per derivare il nome di output dei formati single-stream e per preservare il basename di un AppImage opaco.

---

## 3. Staging

Lo staging directory deve essere:

```text
esistente
reale, non symlink
vuoto all'ingresso
```

`pkg_extract` non pubblica direttamente dentro `$m_ROOT/pkg` e non modifica selector, binding o state RumiAI.

Se un extractor esterno fallisce dopo aver prodotto contenuto parziale, l'intero staging è da considerare invalido e il caller deve scartarlo. Il layer non tenta una transaction/rollback ricorsiva generica dentro una directory che non possiede.

Questa unità non definisce `pkg_extract` come sandbox. Gli archivi provengono da artifact già risolti e verificati secondo la policy package, ma l'hardening universale contro ogni comportamento di extractor/pathology archive resta una responsabilità separata se emergerà un requisito concreto non coperto dai backend correnti.

---

## 4. Formati archive/tar

Formati:

```text
tar

tar.gz
tgz

tar.bz2
tar.bzip2
tbz
tbz2

tar.xz
txz

tar.zst
tzst
```

Backend:

```text
tar                         -> tar

tar.gz, tgz                 -> gzip + tar

tar.bz2, tar.bzip2,
tbz, tbz2                   -> bzip2 + tar

tar.xz, txz                 -> xz + tar

tar.zst, tzst               -> zstd + tar
```

Le compressioni vengono rimosse esplicitamente dal relativo utility e il tar risultante viene passato a `tar` tramite stdin. Non si dipende quindi dalle option GNU/BSD specifiche `tar -z`, `-j`, `-J` o equivalenti.

Per i tar compressi il layer verifica separatamente l'esito del decompressor prima di iniziare l'estrazione del tar.

---

## 5. Compressioni single-stream

Formati:

```text
gzip
gz

bzip
bzip2
bz2

xz

zstd
zst
```

Backend:

```text
gzip/gz             -> gzip
bzip/bzip2/bz2      -> bzip2
xz                   -> xz
zstd/zst             -> zstd
```

`bzip` è un alias del formato bzip2 corrente e non introduce supporto al formato storico bzip1.

L'output è un singolo file nello staging. Il basename viene derivato rimuovendo un suffisso coerente:

```text
gzip/gz        .gz oppure .gzip
bzip*          .bz2, .bz oppure .bzip2
xz             .xz
zstd/zst       .zst oppure .zstd
```

Se il basename non possiede un suffisso rappresentabile per il formato dichiarato, la materializzazione fallisce invece di inventare un filename di output.

Un output parziale single-stream viene rimosso in caso di decompression failure.

---

## 6. ZIP family

Formati:

```text
zip
jar
war
```

sono trattati come container ZIP ed estratti tramite:

```text
unzip
```

Non viene introdotta una dipendenza da Java soltanto per estrarre JAR/WAR.

Il baseline usa la sintassi compatibile con Info-ZIP UnZip corrente e non inserisce un delimitatore `--` non supportato universalmente dalle versioni correnti di `unzip`.

---

## 7. 7-Zip family e DMG

Formati:

```text
7z
7zip
dmg
```

usano il primo comando disponibile fra:

```text
7zz
7z
7za
```

con estrazione full-path nello staging.

`7z`/`7zip` sono alias dello stesso formato.

`dmg` viene inizialmente supportato attraverso 7-Zip perché il catalogo DBeaver corrente contiene artifact DMG e questo permette di mantenere l'extract capability-based senza introdurre subito una procedura host-specific di mount/unmount tramite `hdiutil`.

Se nessuna implementazione 7-Zip è disponibile, `dmg`, `7z` e `7zip` falliscono con diagnostica esplicita. Un eventuale backend nativo DMG futuro richiede un contratto separato proporzionato ai suoi side effect.

7-Zip supporta `--` come stop-switch delimiter e il layer lo usa prima del pathname artifact.

---

## 8. AppImage

`appimage` è una materialization mode opaca.

Il layer:

```text
non esegue l'AppImage
non usa --appimage-extract
non monta il payload
copia il regular file nello staging preservandone il basename e il mode
```

Questa scelta evita di eseguire codice upstream durante il layer extract. L'integrazione successiva deciderà come esporre/eseguire l'AppImage installato.

---

## 9. Debian package

Formato:

```text
deb
```

usa:

```text
dpkg-deb -x <artifact> <staging-dir>
```

Viene estratto il filesystem payload; i metadata di package Debian non diventano metadata RumiAI per implicazione.

`dpkg-deb` non espone nel contratto usato qui un generico `--` end-of-options fra `-x` e i due operandi, quindi il delimitatore non viene inventato.

---

## 10. Utility mancanti

Prima di usare un backend opzionale, `pkg_extract` ne verifica la presenza tramite command lookup.

Utility necessaria assente:

```text
status 1
nessuna fallback semantica verso un formato diverso
diagnostica execution.command-not-found
campi almeno operation=pkg-extract, command=<utility>, format=<format>
```

Per la famiglia 7-Zip vengono provati `7zz`, `7z`, `7za`; l'errore viene emesso solo se nessuno dei tre è disponibile.

La disponibilità di una utility non implica che ogni archive concreto sia valido; un exit non-zero del backend è extraction failure.

---

## 11. Formati esclusi dal baseline

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

## 12. Exit status

```text
0  materializzazione riuscita
1  artifact/staging invalido, utility mancante o backend failure
2  numero di argomenti o format token non supportato
```

---

## 13. Testing

I test permanenti devono proteggere almeno:

```text
API e requisito staging vuoto
mapping format -> backend
alias dei formati
assenza di autodetection implicita
missing-utility con diagnostica esplicita
uso di gzip/bzip2/xz/zstd separato da tar
single-stream naming e cleanup
ZIP/JAR/WAR via unzip
7z/7zip/dmg via 7zz|7z|7za
AppImage non eseguito e copiato come file opaco
DEB via dpkg-deb
un caso reale tar.gz sui backend host disponibili
```

I test di dispatch possono usare utility fake deterministiche. I test che verificano una capability host reale possono usare SKIP soltanto quando l'utility opzionale richiesta dal formato non è disponibile; ciò non sostituisce la physical validation revision-specific sui reference host.

---

## 14. Invarianti fissati

```text
PKG-EXTRACT-01  file canonico lib/sh/pkg-extract.lib.sh; libreria non eseguibile e senza shebang
PKG-EXTRACT-02  API = pkg_extract <artifact> <format> <staging-dir>
PKG-EXTRACT-03  format è esplicito e non viene dedotto dal repository type
PKG-EXTRACT-04  staging deve esistere, essere reale e vuoto
PKG-EXTRACT-05  tar compressi usano decompressor dedicato + tar e non option compression implementation-specific di tar
PKG-EXTRACT-06  formati tar iniziali = tar, tar.gz/tgz, tar.bz2/tar.bzip2/tbz/tbz2, tar.xz/txz, tar.zst/tzst
PKG-EXTRACT-07  single-stream = gzip/gz, bzip/bzip2/bz2, xz, zstd/zst con output name derivato dal suffisso
PKG-EXTRACT-08  zip/jar/war usano unzip
PKG-EXTRACT-09  7z/7zip/dmg usano 7zz, 7z o 7za in quest'ordine di capability
PKG-EXTRACT-10  AppImage non viene eseguito: è copiato opacamente preservando basename e mode
PKG-EXTRACT-11  deb usa dpkg-deb per estrarre il filesystem payload
PKG-EXTRACT-12  utility mancante produce failure esplicito e non silent fallback
PKG-EXTRACT-13  extraction failure invalida lo staging; il caller lo scarta prima di integration
PKG-EXTRACT-14  pkg_extract resta repository-neutral e non modifica package state RumiAI
```