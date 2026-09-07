# Decisione — Pipeline repository, download/extract e integrazione di `pkg`

Date: 2026-09-07  
Status: **Accepted**

## Contesto

Il package manager corrente ha già fissato il layout delle versioni concrete, il selector `current`, il modello `cmd/` / `link/` / `env`, lo state package-local, facility/dependency/provider index e il principio che `pkg install` renda il package il più autosufficiente possibile.

La precedente decisione `2026-09-07-package-install-local-candidate-baseline.md` aveva però trasformato il primo incremento prodotto in una CLI locale:

```text
pkg install <pkg> <version> <candidate-directory>
```

con acquisizione e integrazione concentrate nel comando `pkg`.

La correzione esplicita del 2026-09-07 sostituisce tale modello. Il package manager deve mantenere distinti:

```text
repository-specific discovery/resolution
artifact download
artifact extraction
RumiAI package materialization/integration
```

La CLI pubblica opera su identità package, non su directory candidate.

---

## 1. CLI pubblica

Le forme canoniche sono:

```text
pkg install <pkg> [<pkg> ...]
pkg uninstall <pkg> [<pkg> ...]
```

Entrambi i sottocomandi richiedono almeno un package operand.

Ogni `<pkg>` è l'identità canonica RumiAI del package richiesta dall'utente. Nella baseline corrente l'operand non contiene versioni, repository coordinates o pathname locali.

La selezione della release concreta avviene attraverso la package definition e il relativo repository adapter prima della materializzazione della concrete identity già fissata:

```text
<pkg>@<version>!<osarch>
```

Una release dinamica come "latest" può essere una richiesta/discovery policy della package definition, ma prima del download deve essere risolta a una versione upstream concreta. `latest` non diventa una pseudo-versione installata per sostituire l'identità upstream reale.

La sintassi futura per pin/version override, se necessaria, richiederà una decisione separata.

---

## 2. Package definition come ingresso dell'orchestrazione

Per poter trasformare un nome come:

```text
pkg install foo
```

in un'installazione concreta, `pkg` deve disporre di una package definition che descriva almeno le informazioni necessarie a:

```text
selezionare il tipo di repository
identificare il progetto/artifact upstream nel repository
selezionare o risolvere la versione
identificare il formato/materializzazione dell'artifact
normalizzare e integrare il software in RumiAI
```

La package definition resta distinta dall'artifact upstream.

La serializzazione, la collocazione fisica e il lookup/catalogo delle package definition non sono fissati da questa decisione e devono essere chiusi prima della prima installazione remota completa. Non devono essere sostituiti nel frattempo da composite string ad hoc nella CLI o da manifest shell arbitrariamente sourced.

---

## 3. Repository adapter

GitHub, SourceForge, Maven, repository custom e altri ecosistemi upstream sono **repository type**, non `provider` nel significato del modello facility/dependency.

Il termine `provider` resta riservato nel package manager alla versione concreta che offre una `facility` secondo `2026-09-07-package-facility-dependency-and-provider-index.md`.

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
conosce soltanto le API/convenzioni dello specifico ecosistema upstream
esegue discovery e resolution repository-specific
non scarica l'artifact
non estrae l'artifact
non modifica $m_ROOT/pkg
non crea current
non crea binding pubblici
non modifica provider index o binding dependency
```

---

## 4. API comune dei repository adapter

Tutte le repository library espongono la stessa API semantica.

La baseline riprende e normalizza le tre responsabilità già emerse nella genealogia del package manager:

```text
pkg_repository_versions
pkg_repository_latest_version
pkg_repository_download_url
```

Semantica:

```text
pkg_repository_versions
    enumera le versioni upstream disponibili per la package definition/target corrente

pkg_repository_latest_version
    risolve la release upstream corrente scelta dalla semantica "latest" del repository

pkg_repository_download_url
    risolve l'URL dell'artifact concreto per una versione upstream e target già determinati
```

Le tre API fanno discovery/resolution; nessuna effettua il trasferimento dei byte.

La firma shell completa con cui ricevono repository coordinates/package-definition data viene fissata insieme al formato della package definition. Non deve essere anticipata comprimendo coordinate eterogenee in una singola stringa generica.

Gli output normativi devono essere dati repository-neutral consumabili dal layer successivo; il contratto di serializzazione esatto viene fissato insieme alle firme.

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

Questo permette a GitHub, SourceForge, Maven, custom e futuri repository type di implementare letteralmente la stessa API senza collisioni globali fra funzioni.

Il subshell isola lo stato shell dell'adapter; gli effetti filesystem deliberatamente committati dalla pipeline restano naturalmente visibili alla root RumiAI.

---

## 6. Layer download

Il download è repository-neutral.

La libreria canonica è:

```text
lib/sh/pkg-download.lib.sh
```

ed espone la responsabilità generica:

```text
pkg_download
```

Il repository adapter produce l'URL/artifact identity; `pkg_download` trasferisce i byte verso uno staging file locale.

`pkg_download` non conosce:

```text
GitHub
SourceForge
Maven
custom repository semantics
current
facility/dependency
package integration
```

Il transport backend concreto (`curl`, altra utility o futura primitive) e le regole complete di digest/signature verification devono essere fissati e fisicamente validati separatamente prima della prima implementazione network completa. Questa decisione non introduce implicitamente una dipendenza host non approvata.

---

## 7. Layer extract

L'estrazione è distinta sia dal repository sia dal download.

La libreria canonica è:

```text
lib/sh/pkg-extract.lib.sh
```

ed espone la responsabilità generica:

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

Il formato non deve essere dedotto implicitamente dal repository type. GitHub, Maven o custom possono distribuire formati differenti; il repository identifica l'artifact, mentre il formato appartiene ai dati dell'artifact/package definition.

Le utility concrete per `zip`, `tar.*`, `jar` o altri formati vengono aggiunte solo quando richieste e validate secondo le regole di portability/testing RumiAI.

---

## 8. Layer integrazione RumiAI

La materializzazione e integrazione RumiAI sono repository-neutral e appartengono a:

```text
lib/sh/pkg-integration.lib.sh
```

La libreria possiede le operazioni generiche di install/deinstall sul modello package corrente. Le API pubbliche interne iniziali sono semanticamente:

```text
pkg_integrate
pkg_deintegrate
```

Le firme concrete vengono chiuse insieme alla package-definition/materialization contract, perché devono trasportare in modo esplicito il package risolto e il tree estratto/normalizzato senza ricreare la vecchia CLI candidate.

Questo layer è l'unico dei layer descritti qui autorizzato a conoscere e modificare, quando applicabile:

```text
$m_ROOT/pkg/<pkg>@<version>!<osarch>
$m_ROOT/pkg/<pkg>!<osarch>
cmd/
link/
env
default/
var/
root/ state normalization
bin/ext-<osarch>/ public bindings
facility/dependency materialization
$m_ROOT/data/sys/pkg/providers/
binding/<facility>
```

Le regole correnti e i punti ancora aperti dei rispettivi sottosistemi restano vincolanti. In particolare `pkg-integration.lib.sh` non autorizza a inventare la serializzazione di facility/dependency o la policy di scelta fra provider equivalenti ancora aperte.

---

## 9. Pipeline `pkg install`

Il front command `bin/sys/pkg` è orchestratore CLI, non repository client, downloader, extractor o integrator monolitico.

Per ogni package richiesto la pipeline concettuale è:

```text
package operand
    -> load package definition
    -> select repository type
    -> isolated repository adapter
        -> resolve concrete upstream version
        -> resolve concrete artifact URL/identity
    -> generic download
    -> generic extract
    -> RumiAI materialization/integration
        -> dependency/facility resolution quando applicabile e completamente definita
        -> concrete package publication
        -> current/public bindings/provider index/resolved bindings secondo i contratti correnti
```

Repository discovery deve terminare prima che il layer generic download inizi a trasferire l'artifact concreto scelto.

Download ed extract non devono incorporare logica di integrazione.

Integration non deve interrogare GitHub/SourceForge/Maven o altri repository.

---

## 10. Pipeline `pkg uninstall`

La forma pubblica è:

```text
pkg uninstall <pkg> [<pkg> ...]
```

Uninstall opera esclusivamente sullo stato package locale già materializzato/registrato.

Non deve:

```text
interrogare repository upstream
risolvere latest
scaricare artifact
estrarre artifact
```

Il flusso concettuale è:

```text
package operand
    -> inspect local installed package state
    -> pkg_deintegrate
    -> remove materialized package objects secondo il lifecycle fissato
```

La semantica esatta di rimozione quando coesistono più versioni, la gestione del selector `current`, dependency reverse references e la policy sullo state utente restano da fissare prima della prima implementazione completa di uninstall. La presente decisione fissa la CLI e il confine dei layer, non anticipa tali policy.

---

## 11. Multi-package invocation

`install` e `uninstall` accettano uno o più package operand nella stessa invocazione.

Ogni package mantiene un proprio contesto repository/acquisition/integration. Package differenti nella stessa command line possono provenire da repository type differenti.

La policy finale su:

```text
stop al primo errore vs continuazione
aggregazione status
atomicità fra package distinti
ordine derivato da dependency
```

resta da fissare con il transaction/execution model. Non deve essere inferita dall'ordine testuale della CLI oltre al fatto che tutti gli operand rappresentano package richiesti dall'utente.

---

## 12. Supersession della baseline locale candidate

`2026-09-07-package-install-local-candidate-baseline.md` è superseded per:

```text
CLI pkg install <pkg> <version> <candidate-directory>
candidate-directory come input pubblico
acquisition locale come unico ingresso install
monolite bin/sys/pkg che incorpora validation/materialization/integration
```

Non vengono invece annullati gli invarianti provenienti da decisioni precedenti e riaffermati nel modello corrente, fra cui concrete pathname, selector relativo, command/state/env/facility/dependency semantics.

L'implementazione `rumiai-os@b0d1e1244709e1766c679898ac46785711aca1ca` di `bin/sys/pkg` implementa la baseline superseded e deve essere rimossa o riallineata prima di essere considerata implementazione corrente di `pkg install`.

Non esistono test permanenti pubblicati per quella implementazione, quindi nessuna evidenza permanente la promuove a contratto prodotto.

---

## 13. Sequenza di sviluppo

La sequenza minima coerente dopo questa decisione è:

```text
1 package-definition/catalog contract
2 repository adapter common API signatures + first adapter
3 generic download contract/backend
4 generic extract contract + first formats
5 generic integration API, riusando gli invarianti package già fissati
6 pkg install orchestration multi-package
7 pkg uninstall local lifecycle semantics
8 permanent tests per layer + orchestration
9 physical validation dei backend host/network/archive effettivamente usati
```

Ogni step deve poter essere testato separatamente; i repository adapter devono essere verificabili con fixture senza richiedere download reale quando la proprietà testata è soltanto parsing/discovery.

---

## 14. Invarianti fissati

```text
PKG-PIPE-01  CLI install = pkg install <pkg> [<pkg> ...]
PKG-PIPE-02  CLI uninstall = pkg uninstall <pkg> [<pkg> ...]
PKG-PIPE-03  gli operand pubblici sono package identity, non candidate directory o repository coordinates
PKG-PIPE-04  package definition != upstream artifact
PKG-PIPE-05  repository type e facility provider sono concetti distinti; provider mantiene il significato facility già fissato
PKG-PIPE-06  ogni repository type usa una propria lib/sh/pkg-repository-<type>.lib.sh
PKG-PIPE-07  tutte le repository library espongono la stessa API semantica
PKG-PIPE-08  API repository baseline = pkg_repository_versions, pkg_repository_latest_version, pkg_repository_download_url
PKG-PIPE-09  repository adapter fa discovery/resolution e non download/extract/integration
PKG-PIPE-10  adapter omonimi vengono caricati uno alla volta in contesto shell isolato per package
PKG-PIPE-11  download repository-neutral appartiene a lib/sh/pkg-download.lib.sh / pkg_download
PKG-PIPE-12  extract repository-neutral appartiene a lib/sh/pkg-extract.lib.sh / pkg_extract
PKG-PIPE-13  extract format non deriva semanticamente dal repository type
PKG-PIPE-14  materializzazione/integrazione RumiAI appartiene a lib/sh/pkg-integration.lib.sh
PKG-PIPE-15  solo il layer integration conosce store/current/public binding/provider index/resolved binding e routing package RumiAI
PKG-PIPE-16  uninstall non usa repository/download/extract
PKG-PIPE-17  latest/discovery viene risolto a una upstream version concreta prima della concrete package identity
PKG-PIPE-18  package-definition serialization/catalog, backend download, formati extract e policy uninstall/multi-package restano contratti separati da chiudere, non dettagli da inventare nel front controller
PKG-PIPE-19  la precedente CLI local-candidate e la relativa implementazione monolitica sono superseded
```