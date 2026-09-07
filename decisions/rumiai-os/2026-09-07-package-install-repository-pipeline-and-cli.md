# Decisione — Pipeline repository, download/extract e integrazione di `pkg`

Date: 2026-09-07  
Updated: 2026-09-07  
Status: **Accepted**

## Contesto

Il package manager corrente ha già fissato il modello `cmd/` / `link/` / `env`, lo state package-local, facility/dependency/provider index e il principio che `pkg install` renda il package il più autosufficiente possibile.

La precedente decisione `2026-09-07-package-install-local-candidate-baseline.md` aveva trasformato il primo incremento prodotto in una CLI locale:

```text
pkg install <pkg> <version> <candidate-directory>
```

con acquisizione e integrazione concentrate nel comando `pkg`.

La correzione esplicita del 2026-09-07 sostituisce tale modello. Il package manager deve mantenere distinti:

```text
package-definition catalog lookup
repository-specific discovery/resolution
artifact download
artifact extraction
RumiAI package materialization/integration
```

La CLI pubblica opera su package RumiAI e non espone repository coordinates o directory candidate.

Il catalogo e i range delle package definition sono fissati da `2026-09-07-package-definition-catalog-and-version-ranges.md`.

---

## 1. CLI pubblica

Le forme canoniche dei sottocomandi restano:

```text
pkg install <package> [<package> ...]
pkg uninstall <package> [<package> ...]
```

Entrambi richiedono almeno un package operand.

Ogni operand ammette esattamente una delle forme strutturali:

```text
<pkg>
<pkg>@<version>
<pkg>!<osarch>
<pkg>@<version>!<osarch>
```

Dove:

```text
<pkg>      identità canonica RumiAI del package
<version>  versione upstream esatta richiesta
<osarch>   target RumiAI esplicito
```

Per `pkg install` la semantica è:

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

L'assenza di `@<version>` durante install significa quindi sempre `latest available` e deve essere risolta a una versione upstream concreta prima del download.

`latest` non è una pseudo-versione installata.

L'assenza di `!<osarch>` usa il target corrente esclusivamente per selezionare lo stream di catalogo appropriato. Se viene selezionato lo stream platform-independent `catalog`, la concrete identity risultante resta non qualificata anche quando il target era esplicito o derivato dall'host.

`pkg uninstall` usa la stessa grammatica lessicale degli operand ma resta un'operazione esclusivamente locale. L'assenza di versione in `uninstall` non autorizza una query upstream per `latest`; la policy locale esatta di rimozione senza versione e/o target espliciti resta da fissare con il lifecycle uninstall.

---

## 2. Package definition come ingresso dell'orchestrazione

Per trasformare un operand come:

```text
foo
foo@2.7
foo!linux-arm64
foo@2.7!linux-arm64
```

in una installazione concreta, `pkg` deve selezionare una package definition dal catalogo autorevole.

La package definition descrive almeno, quando applicabile:

```text
repository type
repository-specific project/artifact coordinates
version resolution context
artifact selection/materialization information
artifact format
integrity/provenance information
facility/dependency
cmd/link/env/default
state/path normalization
altre informazioni di integrazione previste dal modello package corrente
```

La package definition resta distinta dall'artifact upstream.

La struttura esterna del catalogo è fissata dalla decisione catalogo; la serializzazione interna completa della singola package definition resta il prossimo contratto da chiudere.

Non devono essere usate come scorciatoie:

```text
composite repository strings nella CLI
candidate-directory come input pubblico
manifest package generici arbitrariamente sourced come shell code
```

---

## 3. Repository adapter

GitHub, SourceForge, Maven, repository custom e altri ecosistemi upstream sono **repository type**, non `provider` nel significato del modello facility/dependency.

Il termine `provider` resta riservato alla versione concreta di package che offre una `facility`.

Ogni repository type è implementato da una libreria shell distinta sotto il layout runtime canonico:

```text
lib/sh/pkg-repository-github.lib.sh
lib/sh/pkg-repository-sourceforge.lib.sh
lib/sh/pkg-repository-maven.lib.sh
lib/sh/pkg-repository-custom.lib.sh
```

Nuovi repository type possono essere aggiunti senza modificare le responsabilità degli altri layer.

Ogni repository library:

```text
conosce soltanto API/convenzioni dello specifico ecosistema upstream
esegue discovery/resolution repository-specific
non trasferisce i byte dell'artifact
non estrae artifact
non modifica $m_ROOT/pkg
non crea selector current
non crea binding pubblici
non modifica provider index o resolved binding dependency
```

---

## 4. API comune dei repository adapter

Tutte le repository library espongono la stessa API semantica:

```text
pkg_repository_list_versions
pkg_repository_resolve_version
pkg_repository_resolve_artifact
```

### `pkg_repository_list_versions`

Enumera le versioni upstream disponibili nel repository/context corrente.

Serve anche, quando necessario, a fornire al resolver catalogo le informazioni repository-specific utili a collocare una versione rispetto agli anchor dei range senza introdurre nel core un comparatore universale delle versioni upstream.

L'ordine e la serializzazione esatta dell'output vengono fissati con la firma del primo adapter concreto e devono essere sufficienti al modello di lineage lineare accettato dal catalogo.

### `pkg_repository_resolve_version`

Risolve una richiesta di versione in una versione upstream concreta.

Per install:

```text
versione omessa
    -> latest upstream disponibile

versione esplicita
    -> la stessa versione upstream concreta, se disponibile/valida nel contesto richiesto
```

Una versione esplicita non deve essere sostituita silenziosamente con una release differente.

### `pkg_repository_resolve_artifact`

Risolve l'artifact concreto per una versione già determinata e per il target/context pertinente.

Il risultato semantico è un descriptor/identity repository-neutral consumabile dal layer download, non soltanto un URL testuale. Può comprendere, quando disponibili o richiesti:

```text
artifact locator/URL
artifact identity/name
size
digest
signature/checksum identity
repository provenance
altri dati necessari al trasferimento/verifica senza incorporare logica di download
```

La serializzazione esatta del descriptor viene fissata insieme alle firme concrete.

Nessuna delle tre API trasferisce i byte dell'artifact.

Queste API supersedono i precedenti nomi:

```text
pkg_repository_versions
pkg_repository_latest_version
pkg_repository_download_url
```

che non appartengono più all'interfaccia corrente.

---

## 5. Isolamento degli adapter con API omonime

Poiché repository library differenti espongono volutamente gli stessi nomi di funzione, non devono essere sourced simultaneamente nello stesso contesto shell persistente.

L'orchestrazione di un singolo package usa un contesto shell isolato, normalmente un subshell POSIX, nel quale viene caricata esclusivamente la repository library selezionata per quel package.

Concettualmente:

```text
pkg install a b c
    -> package a subshell -> source repository adapter A -> pipeline a
    -> package b subshell -> source repository adapter B -> pipeline b
    -> package c subshell -> source repository adapter C -> pipeline c
```

Il subshell isola definizioni e stato shell dell'adapter; gli effetti filesystem deliberatamente pubblicati dalla pipeline restano visibili alla root RumiAI.

---

## 6. Layer download

Il download è repository-neutral.

La libreria canonica è:

```text
lib/sh/pkg-download.lib.sh
```

ed espone:

```text
pkg_download
```

Il repository adapter produce il descriptor dell'artifact; `pkg_download` trasferisce i byte verso uno staging file locale.

`pkg_download` non conosce le convenzioni specifiche di GitHub, SourceForge, Maven o altri repository e non conosce current/facility/dependency/package integration.

Il transport backend concreto (`curl`, altra utility o futura primitive) e le regole complete di digest/signature verification devono essere fissati e fisicamente validati separatamente prima della prima implementazione network completa. Questa decisione non introduce implicitamente una dipendenza host non approvata.

---

## 7. Layer extract

L'estrazione è distinta sia dal repository sia dal download.

La libreria canonica è:

```text
lib/sh/pkg-extract.lib.sh
```

ed espone:

```text
pkg_extract
```

Input semantici:

```text
artifact locale già acquisito
formato/materialization mode determinato dalla package definition/resolution
directory staging di destinazione
```

`pkg_extract` non interroga repository e non crea integrazione RumiAI.

Il formato non deriva semanticamente dal repository type. Repository dello stesso tipo possono distribuire formati differenti.

Le utility concrete per `zip`, `tar.*`, `jar` o altri formati vengono aggiunte solo quando richieste e validate secondo portability/testing RumiAI.

---

## 8. Layer integrazione RumiAI

La materializzazione e integrazione RumiAI sono repository-neutral e appartengono a:

```text
lib/sh/pkg-integration.lib.sh
```

Le operazioni semantiche iniziali sono:

```text
pkg_integrate
pkg_deintegrate
```

Le firme concrete vengono chiuse insieme alla serializzazione/materialization contract della package definition.

Questo layer è l'unico della pipeline qui descritta autorizzato a conoscere e modificare, quando applicabile:

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

La scelta fra forme qualificate e non qualificate deriva dallo stream di catalogo selezionato secondo `2026-09-07-package-definition-catalog-and-version-ranges.md` e dal modello concrete identity corrente.

Le regole e i punti ancora aperti dei rispettivi sottosistemi restano vincolanti; in particolare questa decisione non inventa la serializzazione ancora aperta di `facility`/`dependency` né la policy di scelta fra provider equivalenti.

---

## 9. Pipeline `pkg install`

Il front command `bin/sys/pkg` è orchestratore CLI, non repository client, downloader, extractor o integrator monolitico.

Per ogni package richiesto la pipeline concettuale è:

```text
parse package operand
    -> determine requested/current target
    -> select <pkg>/catalog-<osarch> oppure fallback <pkg>/catalog
    -> select package-definition range
    -> source in isolation the repository adapter declared by that definition
        -> resolve concrete upstream version
        -> resolve concrete artifact descriptor
    -> generic download
    -> generic extract
    -> RumiAI materialization/integration
        -> dependency/facility resolution quando applicabile e completamente definita
        -> concrete package publication
        -> current/public bindings/provider index/resolved bindings secondo i contratti correnti
```

Per versione omessa, il catalogo usa l'ultimo range dello stream selezionato e `pkg_repository_resolve_version` risolve `latest` a una release concreta.

Per versione esplicita, il catalogo seleziona il range applicabile senza confrontare lessicograficamente la stringa upstream.

Repository discovery termina prima del trasferimento dell'artifact.

Download ed extract non incorporano logica di integrazione.

Integration non interroga GitHub/SourceForge/Maven o altri repository.

---

## 10. Pipeline `pkg uninstall`

La forma pubblica resta:

```text
pkg uninstall <package> [<package> ...]
```

con gli operand nelle quattro forme strutturali fissate nella sezione 1.

Uninstall opera esclusivamente sullo stato package locale già materializzato/registrato.

Non deve:

```text
interrogare package-definition catalog remoto per scegliere latest
interrogare repository upstream
risolvere upstream latest
scaricare artifact
estrarre artifact
```

Il flusso concettuale resta:

```text
package operand
    -> inspect local installed package state
    -> pkg_deintegrate
    -> remove materialized package objects secondo il lifecycle fissato
```

Restano da fissare:

```text
semantica di rimozione senza versione esplicita
semantica quando coesistono più versioni
selector current dopo la rimozione
dependency reverse references
policy sullo state utente
```

---

## 11. Multi-package invocation

`install` e `uninstall` accettano uno o più package operand nella stessa invocazione.

Package differenti possono usare repository type, target e stream catalogo differenti.

La policy finale su:

```text
stop al primo errore vs continuazione
aggregazione status
atomicità fra package distinti
ordine derivato da dependency
```

resta da fissare con il transaction/execution model.

Quando una singola operazione usa più package definition, esse dovrebbero essere risolte rispetto allo stesso snapshot Git del catalogo; il meccanismo operativo viene definito con il backend catalogo.

---

## 12. Relazione con concrete identity e target independence

Le identità installate sono:

```text
platform-independent:
    <pkg>@<version>

osarch-specific:
    <pkg>@<version>!<osarch>
```

I selector corrispondenti sono:

```text
platform-independent:
    <pkg>

osarch-specific:
    <pkg>!<osarch>
```

Non viene usato `any` come osarch artificiale.

La concrete identity descrive il package materializzato, non semplicemente il formato dell'artifact upstream. Un package che incorpora un resolved binding target-specific non può essere pubblicato come concrete identity non qualificata.

---

## 13. Supersession della baseline locale candidate

`2026-09-07-package-install-local-candidate-baseline.md` resta superseded per:

```text
CLI pkg install <pkg> <version> <candidate-directory>
candidate-directory come input pubblico
acquisition locale come unico ingresso install
monolite bin/sys/pkg che incorpora validation/materialization/integration
```

L'implementazione storica `rumiai-os@b0d1e1244709e1766c679898ac46785711aca1ca` appartiene alla baseline superseded ed è già stata rimossa forward-only dal prodotto corrente.

Non esistono test permanenti pubblicati per quella implementazione.

---

## 14. Sequenza di sviluppo

La sequenza minima corrente è:

```text
1 catalog layout/range contract                         [fissato]
2 package-definition internal serialization contract   [prossimo]
3 repository adapter signatures + primo adapter
4 generic download contract/backend
5 generic extract contract + primi formati
6 generic integration API riusando gli invarianti package
7 pkg install orchestration multi-package
8 pkg uninstall local lifecycle semantics
9 permanent tests per layer + orchestration
10 physical validation dei backend host/network/archive effettivamente usati
```

Ogni step deve poter essere testato separatamente; i repository adapter devono essere verificabili con fixture senza download reale quando la proprietà testata è soltanto parsing/discovery.

---

## 15. Implementazione e test

Alla data di questa decisione la pipeline riallineata non è implementata in `rumiai-os` e non esistono test permanenti `pkg` in `rumiai-tests`.

Le modifiche qui consolidate sono documentali e non dichiarano physical validation di backend network/archive.

---

## 16. Invarianti fissati

```text
PKG-PIPE-01  CLI install = pkg install <package> [<package> ...]
PKG-PIPE-02  CLI uninstall = pkg uninstall <package> [<package> ...]
PKG-PIPE-03  gli operand ammessi sono <pkg>, <pkg>@<version>, <pkg>!<osarch>, <pkg>@<version>!<osarch>
PKG-PIPE-04  per install, versione omessa significa latest upstream; versione esplicita significa quella release esatta
PKG-PIPE-05  target omesso usa il target corrente per scegliere lo stream; target esplicito permette cross-target install
PKG-PIPE-06  package definition != upstream artifact
PKG-PIPE-07  repository type e facility provider sono concetti distinti
PKG-PIPE-08  ogni repository type usa una propria lib/sh/pkg-repository-<type>.lib.sh
PKG-PIPE-09  tutte le repository library espongono la stessa API semantica
PKG-PIPE-10  API repository = pkg_repository_list_versions, pkg_repository_resolve_version, pkg_repository_resolve_artifact
PKG-PIPE-11  pkg_repository_resolve_artifact produce un descriptor repository-neutral e non trasferisce byte
PKG-PIPE-12  repository adapter fa discovery/resolution e non download/extract/integration
PKG-PIPE-13  adapter omonimi vengono caricati uno alla volta in contesto shell isolato per package
PKG-PIPE-14  download repository-neutral appartiene a lib/sh/pkg-download.lib.sh / pkg_download
PKG-PIPE-15  extract repository-neutral appartiene a lib/sh/pkg-extract.lib.sh / pkg_extract
PKG-PIPE-16  extract format non deriva semanticamente dal repository type
PKG-PIPE-17  materializzazione/integrazione RumiAI appartiene a lib/sh/pkg-integration.lib.sh
PKG-PIPE-18  solo integration conosce store/current/public binding/provider index/resolved binding e routing package RumiAI
PKG-PIPE-19  catalog produce identità non qualificate; catalog-<osarch> produce identità qualificate; non esiste any
PKG-PIPE-20  uninstall usa la stessa grammatica degli operand ma non usa repository/download/extract e non interpreta versione omessa come upstream latest
PKG-PIPE-21  latest/discovery viene sempre risolto a una upstream version concreta prima della concrete package identity
PKG-PIPE-22  backend catalog sync/cache, firme concrete adapter, backend download, formati extract e policy uninstall/multi-package restano contratti separati
PKG-PIPE-23  la precedente CLI local-candidate e la relativa implementazione monolitica restano superseded
```
