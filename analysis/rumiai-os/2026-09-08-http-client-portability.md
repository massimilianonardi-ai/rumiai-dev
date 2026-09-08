# Analisi — Portabilità del client HTTP e possibile astrazione RumiAI

Date: 2026-09-08  
Status: **Analysis / recommendation — non normative**

## Scopo

L'implementazione del repository adapter GitHub richiede richieste HTTPS verso API remote. POSIX.1-2024 non fornisce una utility standard equivalente a `curl` o `wget`, quindi una chiamata diretta a una specifica CLI host introdurrebbe una dipendenza non POSIX e un comportamento variabile fra sistemi.

Questa analisi confronta i client comunemente disponibili su Linux e macOS e valuta se convenga introdurre una piccola astrazione RumiAI indipendente dal backend concreto.

Windows non viene analizzato in questa unità: il contratto RumiAI richiede un ambiente POSIX-compatible e, per il caso indicato, Cygwin rende disponibili sia curl sia wget.

Il nome e l'API del possibile tool RumiAI **non sono fissati** da questo documento.

---

## 1. Nessun client HTTP appartiene al contratto POSIX

RumiAI OS sviluppa contro POSIX. Le operazioni necessarie qui includono almeno:

```text
HTTPS
redirect HTTP
request headers
status HTTP affidabile
TLS certificate verification
network timeout
response body su stdout o file
```

Non esiste una utility POSIX che fornisca questo contratto.

Di conseguenza una dipendenza diretta da `curl`, GNU `wget`, BusyBox `wget` o altra CLI sarebbe una scelta host-specific e deve essere trattata attraverso un'astrazione esplicita secondo `RULES.md`.

---

## 2. Panorama pratico degli host

La presenza di un package nei repository di una distribuzione non equivale alla garanzia che sia installato in ogni immagine/server/container/minimal profile. Il dato utile è quindi quale client sia normalmente più vicino al baseline del sistema, non una pretesa di disponibilità universale.

### macOS

Apple distribuisce curl come componente del sistema/macOS open source. Nelle installazioni macOS correnti `curl` è quindi il backend naturale da aspettarsi.

`wget` non deve invece essere assunto come componente standard di macOS.

### Debian

Nel packaging Debian GNU `wget` è classificato con priorità `standard`, mentre `curl` è `optional`.

Questo rende `wget` una supposizione più naturale su un sistema Debian tradizionale, senza trasformarla in una garanzia per immagini minimal o container.

### Ubuntu

Ubuntu distribuisce sia `curl` sia `wget` nei repository ufficiali correnti.

La loro presenza effettiva dipende però dal profilo installato (desktop, server, cloud, container/minimal). Non è quindi opportuno usare la disponibilità di uno dei due come contratto RumiAI.

### Fedora

Fedora distribuisce la famiglia curl e ha usato anche `curl-minimal` per profili/installazioni ridotte. Il lato wget ha inoltre subito evoluzioni di packaging, inclusi package `wget1`/shim che forniscono il comando `wget`.

Il nome del comando può restare familiare mentre il package/provider sottostante cambia.

### RHEL

RHEL 9 include la distinzione curl/libcurl e varianti minimal; RHEL 10 ha modificato nuovamente il packaging eliminando `curl-minimal` in favore di `curl`.

La differenza fra major release conferma che l'adapter applicativo non dovrebbe dipendere dalla struttura dei package host.

### Alpine Linux

`alpine-base` dipende da BusyBox. BusyBox fornisce un applet `wget`, con un sottoinsieme delle funzionalità e opzioni del GNU Wget.

GNU `wget` e `curl` sono disponibili come package separati, ma non devono essere presunti su una installazione Alpine minimale.

Questo è il caso più evidente in cui il nome `wget` non implica necessariamente la semantica completa di GNU Wget.

### Arch Linux

Il meta-package `base` include `pacman`; il package corrente `pacman` dipende da `curl`. Di conseguenza curl è una presenza molto forte in una normale installazione Arch.

GNU `wget` è disponibile separatamente nel repository `extra`.

### openSUSE

Sia curl sia wget sono strumenti comuni e disponibili almeno nelle linee correnti rilevanti, ma profilo e release non rendono prudente assumerne uno come contratto universale RumiAI.

---

## 3. Differenze semanticamente rilevanti

Anche quando due host espongono un client HTTP, le CLI non sono intercambiabili flag-per-flag.

Esempi:

```text
curl
    HTTP 4xx/5xx non è necessariamente errore di processo senza opzione dedicata
    header ripetibili e output/status hanno una propria sintassi

GNU wget
    opzioni e gestione status/output differenti da curl
    possiede funzionalità non presenti nel BusyBox wget minimo

BusyBox wget
    superficie di opzioni più piccola
    comportamento e feature dipendono dalla build BusyBox
```

Il consumer RumiAI non dovrebbe quindi conoscere flag come:

```text
curl --fail --location ...
wget -O - ...
busybox wget ...
```

Questi sono dettagli del backend host.

---

## 4. Raccomandazione: una primitive/tool HTTP RumiAI

L'astrazione è raccomandata **indipendentemente da quale client risulti statisticamente più diffuso**.

Motivazioni:

```text
POSIX non offre il servizio richiesto
la disponibilità dei client cambia per OS/distribuzione/profilo
curl, GNU wget e BusyBox wget hanno CLI e semantiche differenti
repository adapter diversi avranno bisogno dello stesso servizio
anche il futuro layer di download potrà riusare il medesimo transport
la scelta del backend non deve contaminare le API repository
```

Il tool non dovrebbe essere definito come wrapper di curl. Il suo contratto dovrebbe essere:

> una piccola interfaccia RumiAI per operazioni HTTP/HTTPS, implementabile mediante backend host differenti.

Il repository adapter GitHub chiamerebbe soltanto questa interfaccia. Non chiamerebbe direttamente `curl` o `wget`.

Il layer package `pkg_download` resterebbe comunque distinto: rappresenta l'operazione package-level di download di un artifact già risolto; il tool HTTP sarebbe una primitive di transport più bassa e riutilizzabile.

---

## 5. Backend iniziali da validare

Candidati naturali:

```text
curl
GNU wget
BusyBox wget
```

Non è ancora fissato un ordine normativo di preferenza.

Una implementazione potrebbe preferire il backend con il contratto più completo disponibile e usare fallback soltanto quando il backend alternativo soddisfa integralmente la semantica richiesta.

La selezione dovrebbe dipendere da capability/comportamento verificato, non da pathname host hardcoded o da una tabella `if linux distro X`.

Prima della promozione nel prodotto occorre physical validation sui reference host pertinenti per verificare almeno:

```text
TLS verification
redirect
HTTP error handling
request headers
stdout/file output
timeout
exit status
preservazione dei dati
```

---

## 6. Superficie minima dell'API da valutare

Il caso GitHub richiede oggi soltanto una superficie ridotta:

```text
HTTP(S) GET
URL come dato opaco
zero o più request header
redirect seguiti
TLS verification abilitata
network timeout esplicito
HTTP 4xx/5xx normalizzati come fallimento
response body su stdout oppure su un file richiesto
diagnostica separata dal response body
```

Non è opportuno anticipare senza caso concreto:

```text
POST/form upload
cookie jar
resume
FTP
proxy policy RumiAI
authentication schemes dedicate
multipart
WebSocket
HTTP/2- o HTTP/3-specific API
```

Un eventuale token GitHub non appartiene al catalogo; sarebbe un input/runtime concern separato.

Il parsing JSON delle GitHub API è inoltre un problema distinto dal transport HTTP e non dovrebbe essere incorporato artificialmente in questa primitive.

---

## 7. Nome del tool: ricerca dei conflitti

Sono stati esclusi o de-prioritizzati diversi nomi brevi perché già usati da tool reali o eccessivamente generici:

```text
http        già comando HTTPie
fetch       nome generico e già usato in ambienti/tool Unix
urlget      esiste come comando in altri package
geturl      già usato da altri tool/progetti
webget      esistono CLI correnti con questo nome
netget      esistono CLI correnti con questo nome
hget        nome già utilizzato
rget        nome già utilizzato
xfer        nome già utilizzato da diversi tool
```

### Candidato preferito: `http-fetch`

Il candidato attualmente preferito è:

```text
http-fetch
```

Ragioni:

```text
corto e leggibile
esprime esattamente il dominio HTTP senza legarsi a curl/wget
non si sovrappone ai comandi host principali verificati
non codifica il solo metodo GET nel nome
segue il normale naming RumiAI hyphen-separated
```

La ricerca ha rilevato `git-http-fetch`, che è un nome diverso, ma non un comune comando standalone `http-fetch` nel set di host/tool verificato.

Non è possibile garantire l'assenza assoluta di collisioni con ogni software esistente; `http-fetch` è soltanto il candidato con il miglior equilibrio fra chiarezza e basso rischio di collisione emerso dall'indagine corrente.

**Questo nome non è canonico e non deve essere implementato finché non viene approvato esplicitamente.**

Un'alternativa a rischio di collisione apparentemente basso è `net-fetch`, ma è meno precisa perché suggerisce un'astrazione di networking più ampia del contratto HTTP/HTTPS realmente necessario.

---

## 8. Conseguenza per `pkg-repository-github.lib.sh`

La precedente implementazione dell'adapter GitHub è stata correttamente sospesa prima di introdurre direttamente `curl` come dipendenza non POSIX.

Se l'astrazione HTTP viene approvata, il percorso raccomandato diventa:

```text
stabilire nome e API della primitive HTTP
-> validare i backend necessari sugli host di riferimento
-> implementare la primitive
-> implementare pkg-repository-github.lib.sh contro la primitive RumiAI
```

In questo modo l'adapter GitHub conosce GitHub, ma non le differenze fra curl/GNU wget/BusyBox wget.

---

## 9. Fonti consultate

Fonti principali utilizzate per l'analisi:

```text
Apple Open Source / curl
https://github.com/apple-oss-distributions/curl

Debian package metadata
https://packages.debian.org/

Ubuntu package search
https://packages.ubuntu.com/

Fedora Packages
https://packages.fedoraproject.org/

Red Hat Enterprise Linux package/migration documentation
https://docs.redhat.com/

Alpine Linux package index
https://pkgs.alpinelinux.org/

BusyBox wget documentation/source help
https://busybox.net/

Arch Linux Packages
https://archlinux.org/packages/

openSUSE Software
https://software.opensuse.org/

curl manual
https://curl.se/docs/manpage.html

GNU Wget manual
https://www.gnu.org/software/wget/manual/
```

Le disponibilità package e i profili delle distribuzioni sono dati evolutivi; prima di fissare backend obbligatori o fallback operativi devono essere confermati con physical validation sui reference host correnti.
