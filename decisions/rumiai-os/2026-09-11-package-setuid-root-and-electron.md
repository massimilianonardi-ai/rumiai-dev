# Decisione — Materializzazione package `setuid_root` e primo caso Electron

Date: 2026-09-11  
Status: **Accepted**

## 1. Contesto

Il package manager corrente separa:

```text
repository resolution
pkg_download
pkg_extract
pkg_integrate
pkg_default
pkg_deintegrate
```

`pkg_extract` consegna a `pkg_integrate` una useful root già normalizzata. `pkg_integrate` materializza la disponibilità della concrete version e pubblica eventuali provider soltanto dopo che le trasformazioni di integrazione applicabili sono riuscite.

Il primo package reale successivo a DBeaver è Electron, distribuito tramite GitHub Releases. Per Linux, la release verificata `v44.3.0` pubblica gli artifact:

```text
electron-v44.3.0-linux-arm64.zip
electron-v44.3.0-linux-x64.zip
```

Il manifest upstream della distribuzione Linux contiene direttamente nella root almeno:

```text
electron
chrome-sandbox
```

Il sandbox helper Chromium/Electron richiede il file `chrome-sandbox` con ownership root e setuid abilitato; il caso concreto fissato per RumiAI richiede semanticamente:

```text
uid  = 0
gid  = 0
mode = 4755
```

Questa necessità non è state routing, environment, dependency, command mapping o extraction. È una trasformazione filesystem della useful root necessaria affinché il payload Linux installato sia utilizzabile secondo il proprio modello sandbox.

L'utente ha approvato esplicitamente il 2026-09-11 la prosecuzione di questa unità e la relativa implementazione, mantenendo separata la futura scelta di un eventuale meccanismo di privilege escalation.

---

## 2. Confine di responsabilità

La trasformazione appartiene a:

```text
pkg_integrate
```

Non appartiene a:

```text
pkg_extract
launcher
repository adapter
package command wrapper
```

`pkg_extract` continua a estrarre/materializzare e normalizzare strutturalmente la useful root senza conoscenza package-specific.

Il launcher non modifica ownership o mode e non richiede privilegi per il normale avvio del package.

Il repository adapter GitHub resta invariato: Electron usa il repository type `github`, `archive_regex`, `digest_type=sha256` e gli artifact GitHub Releases già rappresentabili dal contratto corrente.

---

## 3. Nessun `postinstall` arbitrario

Il caso Electron non introduce uno script generico `postinstall`, hook shell o altra esecuzione arbitraria proveniente dal catalogo.

La package definition resta dichiarativa.

Il requisito concreto viene rappresentato con una sola nuova top-level entry machine-oriented della range definition:

```text
setuid_root
```

Il nome identifica la semantica fissa descritta da questa decisione e non costituisce un framework generale di ownership/mode.

Non vengono introdotti in questa unità:

```text
owner arbitrario
group arbitrario
mode arbitrario
ACL
capability Linux
xattr
postinstall/preinstall
script eseguiti come root
```

---

## 4. Scope di piattaforma

`setuid_root` è ammesso nel baseline corrente esclusivamente per concrete package provenienti da stream target-specific:

```text
catalog-linux-arm64
catalog-linux-x86_64
```

Una range generic o non-Linux che dichiara `setuid_root` è invalida.

Questo vincolo riflette il primo requisito reale e non generalizza preventivamente la primitive ad altri target.

---

## 5. Serializzazione di `setuid_root`

`range/setuid_root` è opzionale.

Quando presente è:

```text
regular file
non symbolic link
readable
non executable
non vuoto
```

La serializzazione è line-oriented:

```text
<root-relative-path><LF>
[<root-relative-path><LF> ...]
```

Regole:

```text
una pathname per riga
LF finale obbligatorio
nessuna riga vuota
nessun commento
nessun quoting
nessun escaping
nessuna semantica speciale per TAB, spazi o leading '-'
```

LF non è rappresentabile dentro una pathname perché è il separatore record.

La grammatica lessicale della pathname è la stessa già fissata per i mapping package state:

```text
relativa a root/
non vuota
nessuno slash iniziale
nessuno slash finale
nessun componente vuoto
nessun componente . o ..
```

I componenti della pathname restano upstream/external data e non vengono normalizzati secondo il naming RumiAI.

Pathname duplicate nello stesso `setuid_root` sono invalide.

---

## 6. Oggetto target

Prima di qualsiasi mutazione, ogni pathname dichiarata deve esistere nella useful root e il final object deve essere:

```text
regular file
non symbolic link
```

Ogni ancestor fra la root e il final object deve essere una physical directory e non un symbolic link.

La stessa pathname non può essere contemporaneamente posseduta da un mapping `var/`, né può essere ancestor/descendant di un pathname state-bearing tale da spostare o sostituire il file durante la normalizzazione state.

La validazione avviene prima che la concrete version venga pubblicata.

---

## 7. Semantica materiale fissa

Per ogni file dichiarato, il risultato richiesto nella concrete version è esattamente:

```text
uid 0
gid 0
mode 4755
```

L'ordine operativo è:

```text
chown 0:0
chmod 4755
```

Il `chmod` segue il `chown` perché un cambio ownership può rimuovere bit setuid/setgid.

Il package manager non interpreta nomi host come `root:root`: usa l'identità numerica `0:0`, evitando dipendenza dal nome del gruppo amministrativo dell'host.

Il contenuto del file resta byte-per-byte quello proveniente dalla useful root.

---

## 8. Materializzazione e rollback sincrono

La trasformazione deve preservare il failure model corrente di `pkg_integrate`.

Per ogni target, l'originale viene preservato temporaneamente e la trasformazione viene applicata a una copia temporanea. Soltanto dopo che entrambe le operazioni:

```text
chown 0:0
chmod 4755
```

sono riuscite, la copia trasformata sostituisce il pathname finale.

Gli originali necessari al rollback restano disponibili fino a quando le operazioni successive della stessa integrazione che possono ancora fallire sono concluse.

Se la materializzazione `setuid_root` fallisce sincronicamente:

```text
ogni target già trasformato viene ritirato
ogni originale viene ripristinato
lo state creato dalla stessa integrazione viene rollbackato secondo il contratto state corrente
la useful root viene restituita al caller secondo il normale failure path di pkg_integrate
nessun provider marker resta pubblicato
```

Se una failure successiva richiede il rollback della concrete version, anche la trasformazione `setuid_root` appartiene alle mutazioni possedute dall'integrazione e viene annullata prima di restituire la useful root.

Non viene introdotto un transaction engine generale, journal o crash/power-loss recovery.

---

## 9. Posizione nel lifecycle

L'ordine semantico rilevante è:

```text
prevalidazione range/root/state/setuid_root/dependency
-> concrete root
-> command/env/facility/dependency materialization
-> state/default/var materialization
-> setuid_root materialization
-> provider publication
-> completamento/cleanup transiente
```

Un provider non deve essere considerato disponibile prima che i file `setuid_root` richiesti dalla concrete version siano stati materializzati con successo.

Il cleanup di backup esclusivamente transiente non introduce un nuovo oggetto persistente della concrete package.

---

## 10. Privilege boundary

Questa unità **non introduce privilege escalation**.

In particolare non vengono introdotti implicitamente:

```text
sudo
su
pkexec
setuid helper RumiAI
daemon privilegiato
```

`pkg_integrate` invoca direttamente le utility POSIX necessarie nel contesto di credenziali del processo corrente.

Se il processo non possiede i privilegi necessari per assegnare `uid=0,gid=0`, l'operazione fallisce come errore operativo:

```text
status 1
```

senza degradare automaticamente a `--no-sandbox` e senza ignorare il requisito.

L'eventuale UX/meccanismo con cui un normale utente autorizza in futuro la porzione privilegiata dell'installazione è una responsabilità separata e richiede una decisione esplicita. Questa decisione non sceglie automaticamente `sudo`.

---

## 11. Limite filesystem

Il successo di `chown` e `chmod` materializza i metadata richiesti sul filesystem.

Il baseline non introduce una detection generale delle mount option o delle policy kernel che possano neutralizzare setuid, per esempio `nosuid`.

Se il filesystem/host non supporta semanticamente il requisito, l'esecuzione del software può comunque rifiutarsi di partire. Un eventuale host-capability preflight più ampio richiede evidence concreta separata.

---

## 12. Primo package Electron

Il primo catalogo Electron usa package name:

```text
electron
```

Repository descriptor:

```text
repository/type       github
repository/owner      electron
repository/repository electron
```

Il primo scope implementato è:

```text
catalog-linux-arm64
catalog-linux-x86_64
```

Primo anchor:

```text
n0001=v44.3.0
```

Range Linux ARM64:

```text
archive_regex = ^electron-v[0-9][A-Za-z0-9._+~-]*-linux-arm64\.zip$
format        = zip
digest_type   = sha256
link/electron = electron
setuid_root   = chrome-sandbox
```

Range Linux x86_64:

```text
archive_regex = ^electron-v[0-9][A-Za-z0-9._+~-]*-linux-x64\.zip$
format        = zip
digest_type   = sha256
link/electron = electron
setuid_root   = chrome-sandbox
```

`cmd/electron` è un normale command body RumiAI che delega al launcher canonico:

```sh
launcher "electron" "$@"
```

Le release precedenti a `v44.3.0` non vengono dichiarate supportate dal primo catalogo. Release successive ricadono nell'ultimo range finché artifact layout e requisiti di integrazione restano compatibili.

Altri target Electron, inclusi macOS e Windows, restano fuori da questa unità finché la relativa package definition non viene verificata e aggiunta esplicitamente.

---

## 13. Testing

La copertura permanente deve proteggere almeno:

```text
setuid_root assente -> regressione invariata
setuid_root riconosciuto come feature supportata
range generic/non-Linux con setuid_root rifiutata
metadata file regular/readable/non-executable/non-symlink
file non vuoto e LF finale obbligatorio
pathname relative e componenti vuote/. /.. rifiutate
pathname external-data preservate
pathname duplicate rifiutate
target finale regular file e ancestor physical directory
target symlink/directory/special rifiutato
overlap con var/state rifiutato
ordine semantico chown 0:0 prima di chmod 4755
failure privilegiata -> status 1 e useful root ripristinata
success path simulabile nei test non privilegiati senza indebolire il helper reale
failure successiva -> rollback dei target setuid_root
nessun provider marker prima del successo setuid_root
nessun backup/transient object persistente dopo successo
Electron fixture Linux con electron + chrome-sandbox
assenza di sudo/su/pkexec nel nuovo path di integrazione
```

La verifica reale di ownership `0:0` e mode `4755` richiede un contesto host che autorizzi `chown` e deve essere registrata come physical evidence revision-specific quando eseguita.

Le normali validation non privilegiate devono comunque verificare deterministicamente parsing, confinement, rollback e il boundary di failure per privilegi insufficienti.

---

## 14. Invarianti fissati

```text
PKG-SETUID-01  setuid_root è metadata dichiarativo range-level, non codice eseguibile
PKG-SETUID-02  setuid_root è ammesso nel baseline solo per stream target-specific linux-arm64/linux-x86_64
PKG-SETUID-03  ogni record è una root-relative pathname con la stessa grammatica lessicale dei mapping state
PKG-SETUID-04  ogni target deve essere un regular file non-symlink con ancestor physical directory
PKG-SETUID-05  un target setuid_root non può sovrapporsi a pathname state-bearing var
PKG-SETUID-06  semantica finale fissa = uid 0, gid 0, mode 4755
PKG-SETUID-07  ordine operativo = chown 0:0 poi chmod 4755
PKG-SETUID-08  nessun owner/group/mode arbitrario viene introdotto dal primo contratto
PKG-SETUID-09  nessun postinstall/hook shell arbitrario viene introdotto
PKG-SETUID-10  nessuna privilege escalation viene introdotta; privilegi insufficienti -> status 1
PKG-SETUID-11  nessun fallback --no-sandbox viene introdotto
PKG-SETUID-12  la trasformazione appartiene a pkg_integrate, non a pkg_extract o launcher
PKG-SETUID-13  la trasformazione è rollbackabile per failure sincrone della stessa integrazione
PKG-SETUID-14  provider publication avviene solo dopo materializzazione setuid_root riuscita
PKG-SETUID-15  nessun backup/transient setuid_root appartiene alla shape persistente di una concrete version riuscita
PKG-ELECTRON-01  primo package name = electron
PKG-ELECTRON-02  repository type github owner=electron repository=electron
PKG-ELECTRON-03  primo scope = linux-arm64 e linux-x86_64
PKG-ELECTRON-04  primo anchor = v44.3.0
PKG-ELECTRON-05  artifact Linux sono ZIP target-specific con digest SHA-256 GitHub
PKG-ELECTRON-06  command pubblico electron usa il launcher canonico verso root/electron
PKG-ELECTRON-07  chrome-sandbox è dichiarato in setuid_root
PKG-ELECTRON-08  target macOS/Windows restano fuori da questa unità
PKG-ELECTRON-09  release precedenti a v44.3.0 non sono dichiarate supportate dal primo catalogo
```
