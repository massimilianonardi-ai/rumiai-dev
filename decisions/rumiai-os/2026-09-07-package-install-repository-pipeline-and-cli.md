# Decisione — Pipeline repository, download/extract e integrazione di `pkg`

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

Il package manager corrente mantiene distinti:

```text
package-definition catalog lookup
repository-specific discovery/resolution
artifact download
artifact extraction
RumiAI package materialization/integration
```

La CLI pubblica opera su package RumiAI e non espone repository coordinates o directory candidate.

Il catalogo e i range sono fissati da `2026-09-07-package-definition-catalog-and-version-ranges.md`. Il repository upstream corrente e la resolution posizionale dei range sono fissati da `2026-09-07-package-current-upstream-and-positional-range-resolution.md`.

Questa unità modifica soltanto `rumiai-dev`. Non autorizza modifiche a `rumiai-os` o `rumiai-tests`.

---

## 1. CLI pubblica

Le forme canoniche sono:

```text
pkg install <package> [<package> ...]
pkg uninstall <package> [<package> ...]
```

Ogni operand ammette esattamente:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

Per `pkg install`:

```text
<pkg>
    latest upstream, target corrente

<pkg>@<version>
    versione upstream esatta, target corrente

<pkg>!<osarch>
    latest upstream, target esplicito

<pkg>@<version>!<osarch>
    versione upstream esatta, target esplicito
```

L'assenza di `@<version>` significa sempre `latest available` e deve diventare una versione upstream concreta prima del download.

`latest` non è una pseudo-versione installata.

`pkg uninstall` usa la stessa grammatica lessicale ma resta local-only: versione omessa non significa query upstream per latest.

---

## 2. Due livelli del catalogo

Dopo la selezione dello stream, il catalogo separa:

```text
<stream>/repository
    repository upstream corrente dello stream

<stream>/nNNNN=<version-minimum>/
    package definition specifica del range
```

Il descriptor `repository` contiene semanticamente il repository type e le coordinate/context necessarie alle API repository correnti.

La package definition di range contiene invece le informazioni che possono cambiare fra intervalli di release, incluse quando applicabili:

```text
artifact selection/materialization information
artifact format
integrity/provenance requirements
facility/dependency
cmd/link/env/default
state/path normalization
altre informazioni di integrazione previste dal modello package corrente
```

Repository type e coordinate upstream correnti non vengono duplicati nei range come sorgenti storiche alternative.

La serializzazione interna esatta di `repository` e delle package definition resta da fissare separatamente.

---

## 3. Repository adapter

GitHub, SourceForge, Maven, repository custom e altri ecosistemi upstream sono **repository type**, non facility `provider`.

Ogni repository type usa una libreria distinta:

```text
lib/sh/pkg-repository-github.lib.sh
lib/sh/pkg-repository-sourceforge.lib.sh
lib/sh/pkg-repository-maven.lib.sh
lib/sh/pkg-repository-custom.lib.sh
```

Ogni repository library:

```text
conosce API/convenzioni dello specifico ecosistema upstream
interroga il repository upstream corrente dichiarato dallo stream
esegue discovery/resolution repository-specific
non trasferisce i byte dell'artifact
non estrae artifact
non modifica $m_ROOT/pkg
non crea selector current
non crea binding pubblici
non modifica provider index o resolved binding
```

---

## 4. API comune dei repository adapter

Tutte le repository library espongono esattamente:

```text
pkg_repository_list_versions
pkg_repository_resolve_version
pkg_repository_resolve_artifact
```

### `pkg_repository_list_versions`

Interroga direttamente il repository upstream corrente dello stream e restituisce semanticamente tutte le versioni attualmente installabili nel context corrente.

La successione è ordinata:

```text
oldest -> latest
```

ed è la sorgente autorevole usata da `pkg` per collocare una versione esplicita rispetto agli anchor dei range.

Non usa una lista statica di versioni mantenuta nel catalogo e non consulta repository upstream storici per completare la successione.

La serializzazione esatta dell'output viene fissata con la firma concreta del primo adapter; l'ordine semantico è già fissato.

### `pkg_repository_resolve_version`

Risolve una richiesta in una versione upstream concreta contro il repository corrente.

Per install:

```text
versione omessa
    -> latest upstream disponibile

versione esplicita
    -> la stessa versione upstream concreta, se disponibile/valida
```

Una versione esplicita non viene sostituita silenziosamente con una release differente.

La `latest` risolta deve essere coerente con l'ultima versione della successione di `pkg_repository_list_versions` per lo stesso repository/context.

### `pkg_repository_resolve_artifact`

Risolve l'artifact concreto per una versione già determinata, usando:

```text
repository upstream corrente dello stream
package definition del range selezionato
versione concreta
target/context pertinente
```

Il risultato è un descriptor repository-neutral consumabile dal layer download e può includere, quando disponibili o richiesti:

```text
artifact locator/URL
artifact identity/name
size
digest
signature/checksum identity
repository provenance
altri dati necessari al trasferimento/verifica
```

Nessuna delle tre API trasferisce i byte dell'artifact.

Restano superseded i nomi storici:

```text
pkg_repository_versions
pkg_repository_latest_version
pkg_repository_download_url
```

---

## 5. Migrazione del repository upstream

Ogni stream possiede un solo repository upstream corrente.

Se il produttore cambia sistema di distribuzione, il descriptor:

```text
<stream>/repository
```

viene aggiornato al nuovo sistema.

Il sistema precedente non resta un fallback automatico.

Una release storica resta installabile soltanto se il repository corrente:

```text
la include in pkg_repository_list_versions
la accetta in pkg_repository_resolve_version
permette di risolverne l'artifact
```

Questo evita una catena permanente di repository superseded dentro il catalogo.

---

## 6. Isolamento degli adapter

Poiché repository library differenti espongono gli stessi nomi di funzione, non devono essere sourced simultaneamente nello stesso contesto shell persistente.

L'orchestrazione di un package usa un contesto shell isolato, normalmente un subshell POSIX, nel quale viene caricata soltanto la repository library indicata dal `repository` dello stream selezionato.

Package differenti nella stessa invocazione possono usare adapter differenti e quindi contesti isolati distinti.

---

## 7. Resolution del range per versione esplicita

Per una versione esplicita, dopo aver selezionato lo stream `pkg`:

```text
load <stream>/repository
-> source repository adapter in isolation
-> pkg_repository_list_versions
-> verify requested version exists
-> locate all nNNNN=<version-minimum> anchors in the same succession
-> select the range of the last anchor not after the requested version
```

Il core usa soltanto le posizioni nella successione.

Non usa:

```text
SemVer
confronto lessicografico
confronto numerico
data derivata dalla stringa
pattern package-specific
ordine filesystem
```

Ogni anchor deve comparire esattamente una volta nella successione e le sue posizioni devono essere strettamente crescenti nello stesso ordine degli `nNNNN`.

Versione richiesta assente o catalogo incoerente -> errore.

Non vengono consultati adapter candidate differenti per range.

---

## 8. Resolution di `latest`

Per versione omessa, `pkg` può:

```text
select last range of the chosen stream
-> load <stream>/repository
-> source adapter in isolation
-> pkg_repository_resolve_version latest
```

Non è obbligatorio enumerare tutte le versioni soltanto per installare latest.

Una nuova release pubblicata dopo l'ultimo anchor appartiene automaticamente all'ultimo range finché non viene introdotta una nuova package definition.

---

## 9. Nessuna lista statica e nessun `match`

Il catalogo non contiene una lista esaustiva delle versioni per ciascun range.

Non viene introdotta una funzione/API/file eseguibile package-specific `match` per la membership del range.

La successione fornita dall'upstream corrente e gli anchor `nNNNN=<version-minimum>` sono il meccanismo baseline completo per la range resolution.

Una futura primitive di matching richiede un caso concreto e una nuova decisione.

---

## 10. Layer download

Il download è repository-neutral.

La libreria canonica è:

```text
lib/sh/pkg-download.lib.sh
```

ed espone:

```text
pkg_download
```

Input: descriptor artifact già risolto. Output: staging file locale.

`pkg_download` non conosce GitHub/SourceForge/Maven, current, facility, dependency o package integration.

Il transport backend e le regole finali di digest/signature verification restano da fissare e validare separatamente.

---

## 11. Layer extract

L'estrazione appartiene a:

```text
lib/sh/pkg-extract.lib.sh
```

ed espone:

```text
pkg_extract
```

Input semantici:

```text
artifact locale
formato/materialization mode
directory staging
```

Il formato deriva dalla package definition/resolution, non dal repository type.

Le utility concrete per i diversi formati vengono introdotte soltanto quando richieste e validate.

---

## 12. Layer integrazione RumiAI

La materializzazione e integrazione appartengono a:

```text
lib/sh/pkg-integration.lib.sh
```

con operazioni semantiche iniziali:

```text
pkg_integrate
pkg_deintegrate
```

Solo questo layer conosce e modifica, quando applicabile:

```text
$m_ROOT/pkg/<pkg>@<version>
$m_ROOT/pkg/<pkg>
$m_ROOT/pkg/<pkg>@<version>!<osarch>
$m_ROOT/pkg/<pkg>!<osarch>
cmd/
link/
env
default/
var/
root/ state normalization
bin/ext/
bin/ext-<osarch>/
facility/dependency materialization
$m_ROOT/data/sys/pkg/providers/
binding/<facility>
```

Repository adapter, download ed extract non pubblicano stato package RumiAI.

---

## 13. Pipeline `pkg install`

Per versione esplicita:

```text
parse package operand
-> determine requested/current target
-> select catalog-<osarch> or fallback catalog
-> load stream repository
-> source repository adapter in isolation
-> pkg_repository_list_versions
-> locate requested version and range anchors by position
-> select package-definition range
-> pkg_repository_resolve_version exact
-> pkg_repository_resolve_artifact
-> pkg_download
-> pkg_extract
-> pkg_integrate
```

Per versione omessa:

```text
parse package operand
-> determine requested/current target
-> select catalog-<osarch> or fallback catalog
-> select last range
-> load stream repository
-> source repository adapter in isolation
-> pkg_repository_resolve_version latest
-> pkg_repository_resolve_artifact
-> pkg_download
-> pkg_extract
-> pkg_integrate
```

Repository discovery/resolution termina prima del trasferimento dell'artifact.

Download ed extract non incorporano integrazione.

Integration non interroga repository upstream.

---

## 14. Pipeline `pkg uninstall`

`uninstall` opera esclusivamente sullo stato locale già materializzato.

Non deve:

```text
interrogare catalogo remoto per latest
interrogare repository upstream
risolvere upstream latest
scaricare artifact
estrarre artifact
```

Flusso concettuale:

```text
package operand
-> inspect local installed package state
-> pkg_deintegrate
-> remove materialized package objects secondo il lifecycle fissato
```

Restano da fissare policy di rimozione senza versione, coesistenza di versioni, current dopo rimozione, reverse dependency e state utente.

---

## 15. Multi-package invocation

`install` e `uninstall` accettano uno o più package operand.

Package differenti possono usare target, stream e repository type differenti.

La policy finale su stop/continue, aggregazione status, atomicità fra package e ordine dependency resta da fissare.

Le package definition di una singola operazione dovrebbero essere risolte rispetto allo stesso snapshot Git del catalogo.

---

## 16. Concrete identity e target independence

Identità installate:

```text
platform-independent:
    <pkg>@<version>

osarch-specific:
    <pkg>@<version>!<osarch>
```

Selector:

```text
platform-independent:
    <pkg>

osarch-specific:
    <pkg>!<osarch>
```

Non viene usato `any`.

La concrete identity descrive l'intero package materializzato, non soltanto l'artifact upstream.

---

## 17. Supersession

Resta superseded la baseline local-candidate:

```text
pkg install <pkg> <version> <candidate-directory>
candidate-directory come input pubblico
monolite bin/sys/pkg
```

Sono inoltre superseded le assunzioni precedenti secondo cui:

```text
repository type/coordinates correnti appartengono alla package definition di range
range differenti dello stesso stream possono usare repository upstream differenti per la normale resolution
pkg consulta adapter candidate differenti per determinare il range
```

La decisione `2026-09-07-package-explicit-version-range-resolution.md` è superseded da `2026-09-07-package-current-upstream-and-positional-range-resolution.md`.

---

## 18. Sequenza di sviluppo

La sequenza minima corrente è:

```text
1 catalog layout/range/current-upstream contract        [fissato]
2 repository + range-definition serialization contract [prossimo]
3 repository adapter signatures + primo adapter
4 generic download contract/backend
5 generic extract contract + primi formati
6 generic integration API riusando gli invarianti package
7 pkg install orchestration multi-package
8 pkg uninstall local lifecycle semantics
9 permanent tests per layer + orchestration
10 physical validation dei backend host/network/archive effettivamente usati
```

Ogni step deve poter essere testato separatamente.

---

## 19. Implementazione e test

Alla data di questa decisione la pipeline non è implementata in `rumiai-os` e non esistono test permanenti `pkg` in `rumiai-tests`.

Quando implementati, i test dovranno coprire almeno:

```text
CLI a quattro forme
repository unico per stream
pkg_repository_list_versions contro upstream corrente
ordine oldest -> latest
range esplicito per posizione
anchor validation
latest coerente con lista versioni
nessun repository storico fallback
nessuna lista statica per range
nessuna primitive match
adapter isolation
download repository-neutral
extract repository-neutral
integration unica responsabile dello stato RumiAI
uninstall local-only
```

Questa decisione è documentale e non richiede physical validation separata.

---

## 20. Invarianti fissati

```text
PKG-PIPE-01  install = pkg install <package> [<package> ...]
PKG-PIPE-02  uninstall = pkg uninstall <package> [<package> ...]
PKG-PIPE-03  operand = <pkg>, <pkg>@<version>, <pkg>!<osarch>, <pkg>@<version>!<osarch>
PKG-PIPE-04  install senza versione = latest upstream; versione esplicita = release esatta
PKG-PIPE-05  target omesso usa target corrente per selezionare lo stream; target esplicito consente cross-target
PKG-PIPE-06  stream repository descriptor e range package definition sono responsabilità distinte
PKG-PIPE-07  repository type e facility provider sono concetti distinti
PKG-PIPE-08  repository adapter = lib/sh/pkg-repository-<type>.lib.sh
PKG-PIPE-09  API repository = pkg_repository_list_versions, pkg_repository_resolve_version, pkg_repository_resolve_artifact
PKG-PIPE-10  pkg_repository_list_versions interroga il repository corrente e produce successione oldest -> latest
PKG-PIPE-11  repository storico superseded non è fallback automatico
PKG-PIPE-12  range esplicito viene selezionato per posizione nella successione e non con comparatore universale
PKG-PIPE-13  catalog non contiene lista statica delle versioni per range e non introduce match
PKG-PIPE-14  pkg_repository_resolve_version non sostituisce una versione esplicita
PKG-PIPE-15  pkg_repository_resolve_artifact usa repository corrente + definition range-specific e non trasferisce byte
PKG-PIPE-16  adapter omonimi vengono caricati isolatamente
PKG-PIPE-17  download repository-neutral = lib/sh/pkg-download.lib.sh / pkg_download
PKG-PIPE-18  extract repository-neutral = lib/sh/pkg-extract.lib.sh / pkg_extract
PKG-PIPE-19  integration = lib/sh/pkg-integration.lib.sh ed è l'unico layer che modifica lo stato package RumiAI
PKG-PIPE-20  catalog produce identity non qualificate; catalog-<osarch> identity qualificate; nessun any
PKG-PIPE-21  uninstall è local-only e non interpreta versione omessa come upstream latest
PKG-PIPE-22  latest/discovery viene sempre risolta a una versione concreta prima dell'identità installata
PKG-PIPE-23  serializzazione repository/range, firme adapter, download backend, extract e lifecycle restano contratti separati
PKG-PIPE-24  la baseline local-candidate e la resolution multi-repository-per-range restano superseded
```
