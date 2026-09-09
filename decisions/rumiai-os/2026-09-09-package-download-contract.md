# Decisione — Contratto di `pkg_download`

Date: 2026-09-09  
Status: **Accepted**

## Contesto

La pipeline package corrente ha già fissato:

```text
lib/sh/pkg-download.lib.sh
pkg_download
```

come layer repository-neutral fra artifact resolution ed extract.

Il repository adapter GitHub corrente produce un descriptor artifact dichiarativo con:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=sha256:<hex-digest>   # quando richiesto
```

`http-fetch` è già la primitive RumiAI per il trasferimento HTTP/HTTPS e non deve essere bypassata introducendo chiamate dirette a curl/wget dentro il package manager.

Questa decisione chiude la prima firma operativa e la semantica di verifica necessarie al layer download.

---

## 1. File e API canonici

La libreria canonica è:

```text
lib/sh/pkg-download.lib.sh
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
pkg_download <staging-dir>
```

Il descriptor artifact viene letto da stdin.

Su successo `pkg_download`:

1. scarica l'artifact come `<staging-dir>/<name>`;
2. verifica size e digest quando presente;
3. emette su stdout il pathname locale dell'artifact terminato da LF;
4. ritorna `0`.

Lo staging directory deve già esistere ed essere una directory reale. Il layer non decide il lifecycle dello staging complessivo.

---

## 2. Descriptor accettato

I campi obbligatori sono esattamente:

```text
name
url
size
```

Il campo opzionale corrente è:

```text
digest
```

Regole:

```text
ogni campo compare al massimo una volta
campi sconosciuti sono errore
ogni record è key=value terminato da LF
value non vuoto
TAB e CR nei value sono rifiutati
name è un singolo basename e non può essere . oppure ..
url usa inizialmente http:// oppure https://, coerentemente con http-fetch
size è un intero decimale canonico non negativo
```

`name` è dato, non viene source/eval/espanso, e non può contenere `/`; quindi non può uscire dallo staging directory.

L'ordine dei record non è significativo.

---

## 3. Target e overwrite

Il target è:

```text
<staging-dir>/<name>
```

Se quel pathname esiste già come qualsiasi oggetto filesystem, `pkg_download` fallisce.

Il layer non sovrascrive artifact preesistenti e non interpreta un file esistente come cache valida.

---

## 4. Trasferimento

Il trasferimento usa esclusivamente:

```text
http-fetch -o <target> -- <url>
```

`pkg_download` non conosce GitHub, SourceForge, Maven o altri repository type.

Se il trasferimento fallisce, l'eventuale file target parziale creato dalla stessa invocazione viene rimosso e la funzione fallisce.

---

## 5. Verifica size

Dopo il download la dimensione reale in byte deve coincidere esattamente con `size`.

Mismatch o impossibilità di determinare la size:

```text
rimozione del target prodotto
errore operativo
nessun pathname emesso su stdout
```

La size viene verificata prima del digest.

---

## 6. Verifica SHA-256

Il solo algoritmo digest ammesso dal contratto corrente è:

```text
sha256
```

Il valore è composto da esattamente 64 cifre esadecimali e viene confrontato case-insensitively dopo normalizzazione lowercase.

Poiché gli host correnti non espongono ancora una singola primitive SHA-256 RumiAI fissata, `pkg_download` usa capability detection locale senza promuovere un nuovo comando pubblico.

Ordine iniziale dei backend:

```text
1  cksum -a sha256, se la capability è realmente supportata
2  sha256sum
3  shasum -a 256
4  openssl dgst -sha256
```

I backend leggono l'artifact da stdin quando possibile, evitando dipendenze dalla grammatica pathname dei singoli tool.

Se il descriptor richiede SHA-256 ma nessun backend disponibile può calcolarlo, il download fallisce con diagnostica esplicita `command-not-found` per la capability SHA-256.

Digest mismatch o errore del backend:

```text
rimozione del target prodotto
errore operativo
nessun pathname emesso su stdout
```

Questa capability detection interna non introduce una API digest generale. Una primitive RumiAI dedicata verrà valutata solo se emergeranno consumer ulteriori con lo stesso contratto.

---

## 7. Exit status

```text
0  download e verifiche riusciti
1  descriptor invalido, staging invalido, transfer/size/digest failure, capability necessaria assente
2  numero di argomenti invalido
```

I failure prodotti dal descriptor sono considerati errori operativi del pipeline input, non errori di sintassi della CLI pubblica `pkg`.

---

## 8. Confini di responsabilità

`pkg_download` non:

```text
consulta pkg-catalog
seleziona stream/range
interroga repository upstream per discovery
estrae artifact
interpreta format
modifica $m_ROOT/pkg
crea selector current
crea binding pubblici
modifica state package
```

Il suo unico effetto persistente nella chiamata è il file di staging validato.

---

## 9. Testing

I test permanenti devono proteggere almeno:

```text
validazione del descriptor e campi obbligatori
rifiuto duplicate/unknown field
confinamento di name a un basename
uso di http-fetch e preservazione del name
nessun overwrite del target
verifica size
verifica SHA-256
cleanup del target dopo transfer/size/digest failure
fallback fra backend SHA-256 disponibili
failure esplicita quando una capability digest richiesta è assente
```

I test unitari possono usare backend fake deterministici; la physical validation del transport/digest reale resta revision-specific e separata.

---

## 10. Invarianti fissati

```text
PKG-DOWNLOAD-01  file canonico lib/sh/pkg-download.lib.sh; libreria non eseguibile e senza shebang
PKG-DOWNLOAD-02  API = pkg_download <staging-dir>, descriptor letto da stdin
PKG-DOWNLOAD-03  successo crea <staging-dir>/<name> e ne emette il pathname su stdout
PKG-DOWNLOAD-04  descriptor obbligatorio name/url/size, digest opzionale; unknown/duplicate field sono errore
PKG-DOWNLOAD-05  name è confinato a un basename e non può uscire dallo staging
PKG-DOWNLOAD-06  target preesistente non viene sovrascritto
PKG-DOWNLOAD-07  trasferimento esclusivamente tramite http-fetch
PKG-DOWNLOAD-08  size viene sempre verificata
PKG-DOWNLOAD-09  digest corrente supportato = sha256 e, quando richiesto, viene sempre verificato
PKG-DOWNLOAD-10  backend SHA-256 = capability detection cksum/sha256sum/shasum/openssl senza nuova API pubblica
PKG-DOWNLOAD-11  transfer/size/digest failure rimuove il target prodotto dalla stessa invocazione
PKG-DOWNLOAD-12  pkg_download resta repository-neutral e non modifica package state RumiAI
```