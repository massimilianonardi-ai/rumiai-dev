# Decisione — Content-Length mirato in `http-fetch` e remediation size Node.js

Date: 2026-09-15  
Status: **Accepted / Active — physical validation pending**

## 1. Contesto

La live validation del package `nodejs` sulla coppia:

```text
rumiai-os    a5442e527f6bc7a70022f09330ba27770c0b5fb7
rumiai-tests a80de1c56b9073804e7b3ed994c208be5f40c43b
selection    external/nodejs
```

ha prodotto `FAIL` sia su Ubuntu 26.04 ARM64 sia su macOS ARM64:

```text
Ubuntu 26.04 ARM64
session 20260915T160755+0200-405802

macOS ARM64
session 20260915T160821+0200-75434
```

In entrambi i casi il test ha raggiunto il percorso live `pkg install nodejs` e l'installazione è fallita.

L'analisi del contratto e dell'upstream ha individuato il difetto nella sorgente usata dall'adapter Node.js per la size esatta dell'artifact. Il directory index corrente di:

```text
https://nodejs.org/dist/<version>/
```

espone size human-readable arrotondate, per esempio `33 MB`, `58 MB` e valori analoghi, non il numero esatto di byte richiesto dal descriptor `pkg_download`.

Il parsing HTML del directory index non può quindi essere l'autorità della size esatta.

La correzione non modifica:

```text
l'autorità delle release GitHub
SHASUMS256.txt come autorità di name + SHA-256
archive_regex
pkg_download
pkg_extract
pkg_integrate
il catalogo Node.js
```

## 2. Decisione

La size dell'artifact Node.js viene ottenuta interrogando l'URL finale dell'artifact attraverso la primitive già esistente:

```text
http-fetch
```

Non viene introdotto un nuovo comando HTTP, un parser HTML, un adapter di download separato o una nuova repository abstraction.

`http-fetch` viene esteso con una modalità mirata:

```text
http-fetch -l [-H <header>]... [-t <seconds>] -- <url>
```

La modalità `-l` significa:

```text
restituire il Content-Length esatto della risposta HTTP finale
senza trasferire il response body
```

Output di successo:

```text
<decimal-bytes>\n
```

La modalità non espone una API generale per gli header HTTP e non introduce una scelta pubblica del metodo HTTP.

## 3. Contratto di `http-fetch -l`

`-l` conserva le policy già fissate per `http-fetch`:

```text
scheme ammessi                 http, https
redirect                       seguiti
TLS certificate verification   attiva
HTTP 4xx/5xx                   fallimento
header -H                      supportati
-t                             timeout corrente
backend selection              curl, poi GNU Wget se curl non disponibile
backend failure                nessun retry su backend alternativo
```

La risposta finale deve contenere esattamente un `Content-Length` rappresentabile come intero decimale canonico non negativo:

```text
0
oppure
[1-9][0-9]*
```

Sono failure operative, exit status `1`:

```text
Content-Length finale assente
Content-Length finale malformato
Content-Length finale duplicato
fallimento del backend selezionato
HTTP failure
```

`-l` e `-o` sono semanticamente incompatibili. La loro combinazione è invocazione invalida e produce exit status `2` secondo il contratto CLI corrente.

La normale modalità GET di `http-fetch` resta invariata.

## 4. Backend

L'implementazione iniziale riusa esclusivamente i backend già autorizzati.

Con curl, la modalità `-l` usa una request senza body basata sulle capability del backend e segue i redirect correnti.

Con GNU Wget, la modalità `-l` usa il probe senza download del body e osserva gli header della risposta.

La normalizzazione dei backend è responsabilità di `http-fetch`; i consumer non devono invocare direttamente curl o wget.

BusyBox Wget resta escluso come nel contratto corrente.

## 5. Adapter Node.js

`pkg_repository_resolve_artifact` conserva l'ordine logico:

```text
verifica exact full release GitHub
-> selezione univoca name + SHA-256 da SHASUMS256.txt
-> costruzione URL finale artifact
-> http-fetch -l sull'URL finale
-> emissione descriptor repository-neutral
```

La size viene quindi risolta con:

```text
http-fetch -l -- https://nodejs.org/dist/<version>/<name>
```

Il directory index:

```text
https://nodejs.org/dist/<version>/
```

non viene più usato per ricavare la size.

`dist/index.tab` continua a non partecipare alla resolution o all'ordering.

L'adapter non scarica il body dell'artifact durante la resolution. Il download effettivo resta esclusivamente responsabilità di `pkg_download` tramite `http-fetch` normale.

## 6. Relazione con le decisioni precedenti

Questa decisione aggiorna esclusivamente i punti in conflitto delle decisioni:

```text
decisions/rumiai-os/2026-09-08-http-fetch-json-and-github-adapter-contract.md
decisions/rumiai-os/2026-09-14-nodejs-package-integration.md
```

Nella decisione `http-fetch`, la CLI corrente diventa:

```text
http-fetch [-l] [-H <header>]... [-o <file>] [-t <seconds>] -- <url>
```

con il vincolo `-l` incompatibile con `-o`.

Nella decisione Node.js, la frase:

```text
size in byte esatti -> https://nodejs.org/dist/<version>/
```

è superseded da:

```text
size in byte esatti -> Content-Length della risposta finale dell'URL artifact tramite http-fetch -l
```

Analogamente, `NODEJS-PKG-10` viene corretto soltanto nella parte relativa alla size.

Tutti gli altri invarianti delle due decisioni restano attivi.

## 7. Testing permanente

La modifica deve essere protetta riusando i test permanenti esistenti, senza creare frammentazione non necessaria.

`rumiai-os/http-fetch/cli.test` deve verificare almeno:

```text
-l restituisce il Content-Length della risposta finale dopo redirect
-l non materializza il body
Content-Length assente -> FAIL operativo
Content-Length malformato -> FAIL operativo
Content-Length duplicato -> FAIL operativo
-l + -o -> invalid invocation
normale GET resta invariato
```

`rumiai-os/http-fetch/backends.test` deve verificare almeno:

```text
errore curl in -l non provoca fallback verso wget
GNU Wget supporta -l tramite probe senza body
redirect intermedi non determinano la size finale
BusyBox Wget resta non supportato
```

`rumiai-os/pkg-repository-nodejs/artifact.test` deve verificare almeno:

```text
size ottenuta tramite http-fetch -l sull'URL artifact esatto
vecchio directory listing non consultato
mapping invariato per tutte le sei osarch
assenza size autorevole -> failure
SHASUMS256.txt resta sorgente del digest
```

`external/nodejs/install-live.test` resta la regressione end-to-end del failure osservato e non viene indebolito.

## 8. Validation scope

La physical validation successiva deve usare uno scope task nominato, fissato prima del run, contenente almeno:

```text
rumiai-os/http-fetch/cli.test
rumiai-os/http-fetch/backends.test
rumiai-os/pkg-repository-nodejs/artifact.test
external/nodejs/install-live.test
```

Host richiesti per chiudere il work unit corrente:

```text
Ubuntu 26.04 ARM64
macOS ARM64
```

Tutte le selection richieste devono produrre PASS. SKIP non costituisce validation positiva.

Le sessioni fallite precedenti restano evidence immutabile della coppia che hanno realmente esercitato.

## 9. Scope escluso

Questa unità non introduce:

```text
API HTTP header general-purpose
metodo HTTP configurabile pubblicamente
curl/wget nei repository adapter
fallback backend dopo transfer failure
SemVer Node.js
LTS selector
index.tab
URL template generico
catalog pin nuovo
secondo downloader
rilassamento della verifica size di pkg_download
```

## 10. Invarianti

```text
HTTP-FETCH-LEN-01  -l estende il comando esistente http-fetch; nessun nuovo comando HTTP viene introdotto
HTTP-FETCH-LEN-02  -l emette un solo Content-Length finale canonico in byte e non trasferisce il body
HTTP-FETCH-LEN-03  Content-Length finale assente, malformato o duplicato produce failure operativo
HTTP-FETCH-LEN-04  -l e -o sono incompatibili e producono invalid invocation
HTTP-FETCH-LEN-05  redirect, TLS, backend selection e no-retry restano quelli di http-fetch
HTTP-FETCH-LEN-06  curl e GNU Wget restano gli unici backend baseline; BusyBox Wget resta escluso
NODEJS-SIZE-01     name + SHA-256 continuano a provenire da SHASUMS256.txt
NODEJS-SIZE-02     size proviene dal Content-Length dell'URL artifact finale tramite http-fetch -l
NODEJS-SIZE-03     il directory index nodejs.org/dist/<version>/ non è più sorgente della size
NODEJS-SIZE-04     l'adapter non trasferisce il body dell'artifact durante resolve_artifact
NODEJS-SIZE-05     pkg_download resta l'unico responsabile del download finale e della verifica exact-size/digest
NODEJS-SIZE-06     catalogo, mapping osarch, archive_regex e digest_type restano invariati
NODEJS-SIZE-07     le failure evidence 20260915T160755+0200-405802 e 20260915T160821+0200-75434 restano immutabili
NODEJS-SIZE-08     validation successiva = task scope su Ubuntu ARM64 + macOS ARM64
NODEJS-SIZE-09     Git resta forward-only
```
