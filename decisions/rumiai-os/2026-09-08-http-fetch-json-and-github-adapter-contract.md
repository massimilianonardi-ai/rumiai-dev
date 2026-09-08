# Decisione — `http-fetch`, primitive JSON mirate e primo adapter GitHub

Date: 2026-09-08  
Status: **Accepted**

## Contesto

L'implementazione del primo repository adapter GitHub richiede due capability non fornite direttamente da POSIX:

```text
transport HTTP/HTTPS
interpretazione delle risposte JSON GitHub
```

L'analisi `analysis/rumiai-os/2026-09-08-http-client-portability.md` ha già mostrato che curl, GNU Wget e BusyBox Wget non costituiscono un contratto host uniforme. L'utente ha approvato il nome `http-fetch`, l'astrazione del transport e l'implementazione del primo adapter GitHub; ha inoltre richiesto di estrarre il parsing JSON in `lib/sh/json.lib.sh` affinché possa essere riusato senza trasformarlo prematuramente in un parser general-purpose.

Questa decisione autorizza l'implementazione in `rumiai-os` esclusivamente di:

```text
bin/sys/http-fetch
lib/sh/json.lib.sh
lib/sh/pkg-repository-github.lib.sh
```

Non modifica altri file prodotto, non implementa `pkg_download`, extract o integration e non modifica `pkg-catalog`.

---

## 1. `http-fetch`

Il comando canonico è:

```text
bin/sys/http-fetch
```

Essendo un command entrypoint RumiAI direttamente eseguibile usa:

```text
#!/usr/bin/env rumiai-os
```

La CLI iniziale è:

```text
http-fetch [-H <header>]... [-o <file>] [-t <seconds>] -- <url>
```

Semantica:

```text
metodo                         GET
scheme iniziali ammessi        http, https
redirect                       seguiti entro il backend supportato
TLS certificate verification   attiva per HTTPS
HTTP 4xx/5xx                   fallimento
header                         -H ripetibile
output                         stdout di default; -o scrive nel pathname richiesto
timeout                        -t in secondi interi positivi; default 30
stderr                         diagnostica/backend, separata dal body
```

Exit status:

```text
0   trasferimento riuscito
1   errore operativo/backend/transport
2   invocazione o argomento invalido
```

Non appartengono al contratto iniziale:

```text
POST
upload
cookie jar
resume
FTP
authentication RumiAI-specific
proxy policy RumiAI-specific
multipart
WebSocket
HTTP/2- o HTTP/3-specific public API
opzioni per disabilitare TLS certificate verification
```

`http-fetch` non è un wrapper semanticamente legato a curl. È una primitive RumiAI HTTP/HTTPS con backend host intercambiabili.

---

## 2. Backend iniziali di `http-fetch`

Ordine iniziale:

```text
1. curl, se disponibile
2. GNU Wget, se curl non è disponibile e il comando wget si identifica come GNU Wget
```

BusyBox Wget non viene usato in questa prima implementazione finché le capability richieste non vengono fisicamente validate.

La scelta avviene per capability/comando disponibile, non per distribuzione o pathname host hardcoded.

Un errore di trasferimento del backend selezionato NON provoca retry automatico con un backend differente. Il fallback riguarda soltanto la selezione iniziale del backend disponibile; non deve mascherare errori di rete, TLS, proxy, CA o server.

La configurazione host pertinente a trust store, proxy e rete resta visibile al backend. `http-fetch` disabilita invece i file di configurazione startup specifici del client quando il backend lo consente, così il contratto non viene alterato accidentalmente da opzioni CLI persistenti dell'utente.

---

## 3. TLS e ambienti con HTTPS inspection

Per HTTPS la certificate verification resta abilitata nel baseline.

Non vengono introdotte opzioni RumiAI equivalenti a:

```text
curl --insecure
wget --no-check-certificate
```

La presenza di firewall enterprise con HTTPS inspection e CA locali non modifica questo vincolo.

Per il debug/physical validation va però mantenuto il seguente contesto operativo corrente:

```text
Ubuntu x86_64
    ambiente enterprise
    possibile HTTPS inspection
    CA locale/enterprise
    eventuali anomalie TLS/proxy devono essere diagnosticate tenendo conto di questo contesto

macOS arm64
Ubuntu arm64
    ambiente domestico
    nessuna HTTPS inspection nota
```

Un fallimento TLS nell'ambiente enterprise non autorizza automaticamente a disabilitare la verifica; deve prima essere distinto da trust-store, proxy, interception e comportamento del backend.

---

## 4. `json.lib.sh`

La libreria canonica è:

```text
lib/sh/json.lib.sh
```

È una libreria shell sourced:

```text
regular file
non executable
nessuno shebang
POSIX sh + POSIX awk
```

Non viene definita come parser JSON general-purpose e non introduce JSONPath, query language, object model persistente o serializzazione RumiAI generale.

La superficie iniziale è deliberatamente strutturale e limitata alle forme necessarie alle API correnti:

```text
json_object_fields <field> [<field> ...]
json_array_object_fields <field> [<field> ...]
json_object_array_object_fields <array-field> <field> [<field> ...]
json_object_read <field> <variable> [<field> <variable> ...]
```

Tutte leggono un singolo documento JSON da stdin.

Le prime tre funzioni emettono record tabulari typed. Ogni scalar estratto è codificato come:

```text
s:<string>
n:<number>
b:true
b:false
z:
m:
```

I campi di uno stesso record sono separati da TAB; i record da LF.

Per preservare questa serializzazione, una stringa selezionata contenente TAB, CR o LF viene rifiutata. Le stringhe selezionate che richiedono escape Unicode `\uXXXX` vengono inoltre rifiutate in questa prima implementazione invece di essere decodificate parzialmente. Stringhe non selezionate possono essere saltate dal parser senza diventare output.

`json_object_read` esegue una singola estrazione del root object e assegna i token typed alle variabili shell richieste nel processo corrente. I nomi variabile vengono validati prima dell'assegnazione; la funzione non esegue dati JSON come shell code. Per conservare gli assegnamenti il caller deve invocare la funzione nel processo shell corrente, non nel lato subshell di una pipeline.

La libreria può essere estesa in futuro con altre primitive mirate soltanto quando un consumer concreto le richiede.

---

## 5. API concrete del repository adapter GitHub

L'adapter canonico è:

```text
lib/sh/pkg-repository-github.lib.sh
```

Espone esclusivamente:

```text
pkg_repository_list_versions <repository-dir>
pkg_repository_resolve_version <repository-dir> [<version>]
pkg_repository_resolve_artifact <repository-dir> <range-dir> <version>
```

`<repository-dir>` identifica la directory stream-level `repository/` già selezionata.

Per `pkg_repository_resolve_version`:

```text
un argomento repository-dir          -> latest full release
repository-dir + versione esplicita  -> exact tag release
```

L'assenza della versione rappresenta latest; non viene introdotta una pseudo-stringa riservata `latest` nel dominio delle versioni upstream.

---

## 6. GitHub REST contract usato

Il primo adapter usa GitHub Releases REST API con header:

```text
Accept: application/vnd.github+json
X-GitHub-Api-Version: 2026-03-10
```

Il catalogo non contiene token o credenziali.

Endpoint iniziali:

```text
GET /repos/{owner}/{repository}/releases?per_page=100&page=N
GET /repos/{owner}/{repository}/releases/latest
GET /repos/{owner}/{repository}/releases/tags/{tag}
```

Le versioni installabili baseline sono full releases:

```text
draft=false
prerelease=false
```

La successione viene ordinata oldest -> latest secondo `created_at`, coerentemente con la semantica GitHub della latest full release. Se due full release installabili hanno lo stesso `created_at` e non è disponibile un ordine semanticamente autorevole ulteriore, l'adapter fallisce invece di inventare un tie-breaker.

Le versioni/tag restano opache al core; l'adapter verifica soltanto che siano rappresentabili dalla grammatica version già fissata dal catalogo RumiAI.

---

## 7. Output di `pkg_repository_list_versions`

Output:

```text
<version>\n
<version>\n
...
```

Ogni versione appare al massimo una volta.

Ordine:

```text
oldest -> latest
```

L'adapter pagina l'endpoint releases finché la pagina restituita contiene meno di 100 release object.

---

## 8. Output di `pkg_repository_resolve_version`

Output in caso di successo:

```text
<concrete-version>\n
```

Per una versione esplicita il tag restituito dall'API deve coincidere esattamente con la versione richiesta e la release deve essere full (`draft=false`, `prerelease=false`).

---

## 9. `pkg_repository_resolve_artifact`

L'adapter usa:

```text
repository descriptor GitHub
range-dir/archive_regex
range-dir/digest_type, se presente
range-dir/digest_regex, se presente
versione concreta
```

Per il contratto corrente:

```text
archive_regex    obbligatorio per la resolution GitHub corrente
digest_type      opzionale; primo valore supportato sha256
digest_regex     se presente -> non ancora supportato, perché il parsing del checksum artifact non è stato fissato
```

L'asset deve avere:

```text
state=uploaded
name che matcha archive_regex
size intera non negativa
browser_download_url HTTPS
```

`archive_regex` deve selezionare esattamente un asset.

Se `digest_type=sha256`, il campo GitHub asset `digest` deve essere esattamente semanticamente:

```text
sha256:<64 hex>
```

ed è normalizzato a lowercase.

---

## 10. Artifact descriptor repository-neutral

Il risultato iniziale di `pkg_repository_resolve_artifact` è un descriptor testuale dichiarativo:

```text
name=<artifact-name>
url=<artifact-url>
size=<decimal-bytes>
digest=<algorithm>:<digest>
```

Regole:

```text
name, url, size sono sempre presenti
digest è presente soltanto quando il range richiede digest_type
un record per riga terminato da LF
il primo `=` separa key e value
nessuna interpretazione shell
nessun source/eval
```

Il descriptor è output dell'adapter verso il futuro layer download; non trasferisce l'artifact.

---

## 11. Descriptor GitHub e scalar validation

Per `type=github`, `repository/` deve contenere esattamente i tre campi già fissati:

```text
type
owner
repository
```

L'adapter rifiuta campi sconosciuti, symlink, sottodirectory o scalar file non conformi.

I valori correnti vengono limitati soltanto al sottoinsieme ASCII non ambiguo necessario a costruire gli endpoint senza URL encoding aggiuntivo:

```text
owner       uno o più caratteri ASCII alfanumerici o hyphen
repository  uno o più caratteri ASCII alfanumerici, dot, underscore o hyphen
```

Non viene replicata nel client una policy più restrittiva sui nomi GitHub. In particolare un repository come `.github` non deve essere rifiutato soltanto perché inizia con dot. La validità semantica finale delle coordinate resta responsabilità dell'API GitHub.

La scalar validation preserva il contratto già fissato: una sola riga non vuota con LF finale, nessun contenuto aggiuntivo, regular non executable file. Il confronto byte-count impedisce che dati non rappresentabili correttamente in una variabile shell vengano accettati silenziosamente.

---

## 12. Testing e physical validation

In questa unità non vengono aggiunti test permanenti perché l'utente ha autorizzato modifiche prodotto soltanto ai tre file indicati e la suite corrente non contiene ancora il gruppo `pkg`/HTTP/JSON.

Prima di considerare fisicamente validato il transport occorre una successiva validation proporzionata almeno su:

```text
Ubuntu x86_64 enterprise
macOS arm64 home
Ubuntu arm64 home
```

verificando quando disponibili i backend pertinenti e distinguendo esplicitamente eventuali problemi HTTPS inspection nell'host enterprise.

La commit di implementazione può essere prodotta dopo syntax/fixture checks locali, ma tali checks non vengono presentati come physical validation multi-host.

---

## 13. Invarianti fissati

```text
HTTP-FETCH-01  il comando canonico è bin/sys/http-fetch
HTTP-FETCH-02  http-fetch astrae il client host e non espone curl/wget ai consumer
HTTP-FETCH-03  la CLI iniziale è http-fetch [-H <header>]... [-o <file>] [-t <seconds>] -- <url>
HTTP-FETCH-04  GET, http/https, redirect, header, stdout/file e timeout appartengono al baseline
HTTP-FETCH-05  TLS certificate verification resta attiva per HTTPS; nessuna opzione insecure baseline
HTTP-FETCH-06  backend iniziali: curl, quindi GNU Wget; BusyBox Wget pending validation
HTTP-FETCH-07  errore del backend selezionato non provoca fallback verso altro backend
HTTP-FETCH-08  HTTPS inspection enterprise è contesto di debug/validation, non eccezione TLS
JSON-01        la libreria canonica è lib/sh/json.lib.sh
JSON-02        json.lib.sh non è un parser/query framework general-purpose
JSON-03        gli estrattori iniziali lavorano su root object/array e array di object e producono scalar typed
JSON-04        json_object_read può assegnare più campi in variabili del processo corrente con una sola estrazione
JSON-05        dati JSON non vengono source/eval come codice
PKG-GITHUB-API-01 le tre firme concrete sono quelle fissate in sezione 5
PKG-GITHUB-API-02 list_versions restituisce una versione per riga oldest -> latest
PKG-GITHUB-API-03 latest è rappresentato dall'assenza dell'argomento versione
PKG-GITHUB-API-04 full releases GitHub escludono draft/prerelease
PKG-GITHUB-API-05 la successione GitHub corrente usa created_at; tie non risolvibile -> errore
PKG-GITHUB-API-06 resolve_artifact produce name/url/size e digest quando richiesto, senza trasferire byte
PKG-GITHUB-API-07 digest_regex resta non implementato finché il checksum-resource contract non viene fissato
PKG-GITHUB-API-08 l'adapter usa soltanto http-fetch per HTTP e json.lib.sh per il parsing JSON
```
