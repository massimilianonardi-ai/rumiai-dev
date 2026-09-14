# Consolidamento esplorativo — punto di partenza per sviluppo `mk` ed evoluzione di `pkg`

Date: 2026-09-14  
Status: **EXPLORATORY / NON-NORMATIVE — DEVELOPMENT INPUT ONLY**

## 1. Scopo

Questo documento consolida le analisi già svolte sul rapporto fra un futuro `mk`, la trasformazione dei sorgenti, il package manager `pkg`, l'installazione da sorgente locale e remoto e lo scenario sviluppo/build/test.

Serve come materiale di ingresso per una futura sessione dedicata a:

```text
sviluppo di mk
+
evoluzione coordinata di pkg
```

La sessione operativa **non parte con questo documento**.

L'utente ha stabilito esplicitamente che l'avvio dello sviluppo di `mk` e della relativa evoluzione di `pkg` avverrà soltanto su sua decisione.

Di conseguenza questa nota:

```text
consolida scenari
consolida boundary promettenti
registra alternative
registra tensioni ancora aperte
ordina le domande da risolvere quando inizierà lo sviluppo
```

ma non autorizza:

```text
implementazione di mk
modifiche a rumiai-os
modifiche a pkg-catalog
modifiche a rumiai-tests
nuove API pubbliche
nuovi formati
nuove primitive
```

Il nome `mk` viene qui usato perché l'utente ha indicato esplicitamente la futura sessione come sviluppo di `mk`. Questo non rende automaticamente normativi struttura interna, CLI, schema o comportamento non ancora decisi.

---

## 2. Relazione con l'analisi precedente

Questa nota consolida e aggiorna, senza riscriverla retroattivamente:

```text
analysis/rumiai-os/2026-09-13-mk-pkg-source-materialization-and-local-project-packaging.md
```

Quel documento resta utile per:

```text
origine delle riflessioni
analisi dei due ingressi remoto/locale
useful root come boundary
identità/versione locale
rapporto con lo storico mk
questioni aperte iniziali
```

La presente nota aggiunge soprattutto:

```text
- riallineamento al Model 2.0 attivo;
- ruolo futuro di mk come orchestratore del mondo progetto/build;
- quattro scenari distinti invece di due;
- distinzione fra build environment, build material e runtime dependency;
- possibilità che build tool e toolchain siano normali package gestiti da pkg;
- chiarimento del significato di "sistema pulito" nello sviluppo/test;
- alternative per riusare facility/provider senza confondere la dependency runtime;
- ordine di lavoro consigliato quando la sessione operativa partirà.
```

---

## 3. Preflight corrente

HEAD remoti osservati immediatamente prima di questo consolidamento:

```text
rumiai-dev    85b2662d2d001ce6dc3b1109dae2ab9f549cd3ee
rumiai-os     52c8618d73e85e0b411313ea5fedd3562283fac5
rumiai-tests  a113116a2df1eacc5e6d4424d6ec5662ac675aba
pkg-catalog   7a0c0e78710b771096c4dea20cdb7fa9bb5760b6
```

Fonti correnti riesaminate per questa unità:

```text
RULES.md
CONSISTENCY-GATE.md
specifications/rumiai-os/MODEL-2.0-MIGRATION.md
decisions/rumiai-os/2026-09-14-model-2.0-active-document-supersession.md
decisions/rumiai-os/2026-09-02-source-workspace-and-generic-lang-domains.md
decisions/rumiai-os/2026-09-07-package-install-repository-pipeline-and-cli.md
decisions/rumiai-os/2026-09-09-package-integration-and-default-contract.md
decisions/rumiai-os/2026-09-11-package-facility-dependency-serialization-and-resolution-policy.md
analysis/m-audit/2026-08-27-mk-target-profile-deep-dive.md
analysis/rumiai-os/2026-09-13-mk-pkg-source-materialization-and-local-project-packaging.md
rumiai-tests/tests/rumiai-os/pkg/install.test
```

Il Model 2.0 è attivo. Per il sottosistema migrato, eventuali clausole 1.x incompatibili nei documenti precedenti sono superseded.

---

# Parte I — Invarianti correnti da preservare

## 4. Ownership del layer tecnico

Nel Model 2.0:

```text
m
    = layer tecnico general purpose

pkg
    = responsabilità di m

pkg-catalog
    = responsabilità di m
```

Qualunque futuro `mk` general purpose dovrà essere progettato coerentemente con questa stratificazione e non deve introdurre una dipendenza semantica di `m` da RumiAI.

---

## 5. Workspace locale

Resta fissato:

```text
m_SRC_DIR=$m_ROOT/src
```

con proprietà:

```text
src/ = sviluppo locale
src/ non è runtime
src/ non deve diventare una dipendenza necessaria all'esecuzione
```

Quindi:

```text
working source != installed package
```

anche per progetti interpretati che non richiedono compilazione.

---

## 6. CLI corrente di `pkg`

La CLI corrente opera su package:

```text
pkg install <package> [<package> ...]
pkg uninstall <package> [<package> ...]
```

Non espone:

```text
candidate-directory
repository coordinates
local source pathname
```

La vecchia forma:

```text
pkg install <pkg> <version> <candidate-directory>
```

resta superseded e non deve essere reintrodotta implicitamente per risolvere il caso locale.

---

## 7. Pipeline package corrente

Resta distinta almeno la sequenza concettuale:

```text
package definition lookup
repository discovery/resolution
download
extract
package integration
```

In particolare:

```text
extract != package integration
```

e l'attuale integrazione riceve una useful root già normalizzata.

Il caso source-only richiede quindi una estensione deliberata fra extract e integration, non una compilazione nascosta dentro `pkg_extract`.

---

## 8. Availability e default

Resta fissato:

```text
default => available
available != default
```

`pkg_integrate` rende disponibile una concrete version ma non deve automaticamente selezionarla come default/current né creare binding pubblici.

Questo resta importante anche quando `mk` produrrà package locali.

---

## 9. Runtime dependency corrente

Il current `dependency` model ha già una semantica precisa:

```text
requisito runtime del package materializzato
verso una facility astratta
risolto verso un provider concreto
```

Non può essere reinterpretato silenziosamente come:

```text
build tool requirement
compiler requirement
input temporaneo della build
```

Ogni futura estensione deve preservare questa distinzione.

---

## 10. Facility/provider corrente

Il modello corrente possiede già:

```text
facility identity
compatibility
provider concreto
provider index
resolved binding
```

Questa infrastruttura è potenzialmente riutilizzabile per parte del futuro build environment, ma tale riuso deve essere progettato esplicitamente.

Non è ancora deciso che il requirement di build usi la stessa serializzazione del runtime `dependency`.

---

# Parte II — Quattro scenari da distinguere

## 11. Scenario A — package remoto già materializzato

È il caso più vicino alla pipeline attuale:

```text
pkg install foo
    ↓
repository resolution
    ↓
download
    ↓
extract
    ↓
useful root
    ↓
pkg integration
```

Orchestratore:

```text
pkg
```

`mk` non è necessario se l'artifact estratto è già una useful root consumabile.

---

## 12. Scenario B — package remoto distribuito come sorgente

L'intenzione dell'utente resta:

```text
installare un package
```

Quindi l'orchestratore principale resta naturalmente:

```text
pkg
```

La pipeline estesa diventa concettualmente:

```text
pkg install foo
    ↓
package definition
    ↓
repository resolution
    ↓
download
    ↓
extract
    ↓
source tree
    ↓
mk
    ↓
useful root
    ↓
pkg integration
```

In questo scenario `mk` svolge il sottoproblema:

```text
source tree
+
regole di trasformazione
+
build environment
+
materiali di build applicabili
    ↓
useful root
```

`pkg` mantiene ownership dell'obiettivo finale:

```text
rendere disponibile una concrete package version
```

---

## 13. Scenario C — progetto locale da installare

L'oggetto iniziale è un progetto/source workspace, non una package identity remota.

La direzione preferita emersa è:

```text
mk
    ↓
project/source orchestration
    ↓
useful root
    ↓
pkg integration internals
    ↓
concrete package available
```

La direzione alternativa:

```text
pkg
    ↓
mk
```

resta concettualmente possibile ma appare meno coerente perché spingerebbe `pkg` a comprendere un local project ingress che non appartiene alla sua attuale CLI package-oriented.

### 13.1 Direzione preferita, non ancora decisione normativa

La preferenza esplorativa è quindi:

```text
remote package install
    -> pkg orchestrator

local project install
    -> mk orchestrator
```

con convergenza successiva sulla stessa package integration.

Questa preferenza dovrà essere confermata nella sessione di design prima dell'implementazione.

---

## 14. Scenario D — sviluppo/build/test locale

Questo scenario deve partire da:

```text
mk
```

`mk` è l'orchestratore principale del lifecycle di sviluppo.

Obiettivi tipici:

```text
prepare
build
test
run
materialize candidate/useful root
```

senza installare automaticamente il progetto nel package environment.

Il principio consolidato è:

> una development operation non deve avere come side effect l'installazione del progetto o dei suoi output come package del sistema.

Quindi build output, test output, staging root, file generati e scratch non devono essere pubblicati automaticamente sotto:

```text
$m_ROOT/pkg
bin/ext
bin/ext-<osarch>
```

---

# Parte III — Un solo punto di convergenza

## 15. Useful root come boundary

I tre casi che producono software installabile dovrebbero convergere su:

```text
useful root
```

Vista complessiva:

```text
REMOTE BINARY
repository -> download -> extract ------------------------┐
                                                         │
REMOTE SOURCE                                             │
repository -> download -> extract -> mk -----------------┤
                                                         │
LOCAL PROJECT                                             │
src/project -> mk ---------------------------------------┤
                                                         ▼
                                                    useful root
                                                         │
                                                         ▼
                                                package integration
```

Il package integration layer non dovrebbe dover sapere se la useful root proviene da:

```text
archive prebuilt
shell project
Python project
C/C++ build
Java build
altro build system
```

---

## 16. Una package integration, non un package model parallelo

Non è desiderabile introdurre un secondo modello per:

```text
local package
local current
local dependency
local facility
local command binding
```

Il package prodotto localmente deve rispettare le stesse semantiche del package ottenuto da upstream una volta raggiunta la useful root.

---

# Parte IV — Distinzione dei requirement della build

## 17. La dicotomia build/runtime è insufficiente

La riflessione più recente ha mostrato che classificare tutto semplicemente come:

```text
build dependency
runtime dependency
```

è troppo grossolano.

Per il design futuro conviene distinguere almeno tre ruoli descrittivi:

```text
A. build environment
B. build material
C. runtime dependency
```

Questi nomi descrivono ruoli nell'analisi e non fissano ancora nomi di file, schema o termini di prodotto.

---

## 18. Build environment

Appartengono tipicamente al build environment software come:

```text
make
cmake
ninja
compiler C/C++
linker
JDK
language runtime usato per costruire
code-generation tool riusabile
generic build tool
```

Proprietà tipiche:

```text
software eseguibile autonomo
versione propria
lifecycle indipendente dal singolo progetto
riusabile da più progetti
potenzialmente target-specific
può essere mantenuto disponibile nel sistema
```

La direzione preferita è:

> il software che costituisce il build environment può e spesso dovrebbe essere un normale package gestito da `pkg`.

Quindi, per esempio:

```text
pkg
├── cmake@...
├── ninja@...
├── compiler@...
└── jdk@...
```

può costituire l'ambiente da cui `mk` seleziona gli strumenti necessari.

---

## 19. Analogia con plugin di `mk`

L'utente ha proposto una analogia utile:

```text
build tool installati tramite pkg
    ≈
capacità/plugin disponibili a mk
```

L'analogia è utile ma non deve ancora diventare un contratto tecnico.

Occorre distinguere:

```text
package CMake
    = software installato e versionato da pkg

supporto di mk per CMake
    = eventuale logica/adattatore che sa usarlo
```

Il package del build tool e l'eventuale estensione interna di `mk` non sono automaticamente lo stesso oggetto.

Il termine "plugin" resta quindi descrittivo finché non viene progettato un vero extension contract di `mk`.

---

## 20. Build material

Esistono poi input necessari alla produzione che non devono necessariamente diventare software installato nel package environment.

Esempi:

```text
JAR da incorporare nella distribuzione finale
libreria statica .a linkata nell'eseguibile
header/source bundle privato della build
generated source dependency
artifact intermedio scaricato per una sola build
vendored source tree
```

Proprietà tipiche:

```text
vengono consumati durante la materializzazione
possono essere incorporati nell'output
possono cessare di servire dopo la build
non hanno necessariamente lifecycle autonomo nel sistema
non devono essere esposti come package solo perché sono stati necessari alla build
```

Direzione preferita:

```text
resolve/acquire
    ↓
user build state/cache
    ↓
mk
    ↓
useful root
```

senza obbligo di passaggio attraverso:

```text
$m_ROOT/pkg
```

---

## 21. Runtime dependency

Il terzo ruolo resta quello già posseduto dal package model.

Esempi:

```text
JRE richiesto dal software installato
shared library necessaria al launch/runtime
database client runtime
altro provider richiesto dopo l'installazione
```

Questi requirement appartengono al current modello:

```text
facility
+
dependency
+
provider/binding
```

quando applicabile.

---

## 22. Tabella di riferimento esplorativa

| Ruolo descrittivo | Esempi | Persistenza tipica | Gestore candidato | Necessario dopo build |
| --- | --- | --- | --- | --- |
| build environment | CMake, Make, Ninja, compiler, JDK | persistente/condivisa | `pkg` | no per il package finale, sì per build future |
| build material | JAR incorporato, `.a`, source/header privato | build-scoped/cache | `mk` + acquisition/cache da definire | no come entità separata, salvo casi specifici |
| runtime dependency | JRE, shared library, provider runtime | persistente/condivisa | `pkg` | sì |

La tabella è un modello di ragionamento, non uno schema definitivo.

---

# Parte V — Il criterio non è il formato del file

## 23. Libreria statica non significa automaticamente "fuori da pkg"

Non è corretto fissare una regola universale:

```text
static library -> mai package
```

Una SDK o development library usata da molti progetti può avere proprietà da build environment condiviso:

```text
headers
static libs
cmake metadata
pkg-config metadata
tool ausiliari
versione propria
```

In tal caso può essere sensato installarla come package persistente.

---

## 24. Shared library non significa automaticamente una sola categoria

La stessa famiglia software può avere ruoli differenti.

Esempio concettuale OpenSSL:

### link statico

```text
headers + libcrypto.a
    ↓
link
    ↓
executable finale
```

Il materiale potrebbe essere build input e non runtime dependency.

### link dinamico

```text
headers durante build
+
libssl runtime
```

Può emergere contemporaneamente:

```text
build environment/material
+
runtime dependency
```

### development SDK condiviso

Se headers e librerie sono usati ripetutamente da molti progetti, possono diventare parte persistente dell'ambiente di sviluppo.

---

## 25. Criterio più forte

La domanda principale dovrebbe essere:

> vogliamo trattare questo oggetto come software/environment installato, persistente, condivisibile e versionabile indipendentemente dal singolo build?

Se sì, `pkg` è un candidato naturale.

Se invece l'oggetto è principalmente:

```text
input privato della materializzazione corrente
```

allora il suo lifecycle può appartenere al build state/cache gestito dall'orchestrazione `mk`.

---

# Parte VI — Possibile riuso di facility/provider

## 26. Opportunità

Un build tool installato tramite `pkg` può concettualmente offrire una capacità riusabile.

Il package model possiede già il concetto di:

```text
facility
compatibility
provider concreto
```

Questo suggerisce una possibile direzione:

```text
package build-tool
    offre una facility

project/materialization specification
    richiede una facility per costruire
```

---

## 27. Vincolo fondamentale

Non bisogna però usare automaticamente l'attuale file/semantica:

```text
dependency
```

per esprimere tale requisito.

Oggi `dependency` appartiene al package materializzato e descrive un requisito runtime.

Il futuro requisito di build potrebbe:

```text
riusare l'identità facility
riusare compatibility matching
riusare provider discovery
```

ma avere un edge/relation semanticamente differente.

---

## 28. Alternative da valutare quando inizierà il design

### Alternativa A — riuso forte

```text
stesse facility
stesso resolver/provider index
requirement di build separato dal runtime dependency
```

Vantaggi:

```text
un solo modello di capability/provider
niente resolver parallelo
riuso dell'infrastruttura pkg
```

Rischi:

```text
coupling eccessivo fra build e runtime package model
provider installato ma non adatto come development SDK
necessità di metadati ulteriori per toolchain/context
```

### Alternativa B — modello build distinto che usa package identity

```text
project richiede package/tool specifici
pkg li rende disponibili
mk li seleziona direttamente
```

Vantaggi:

```text
modello iniziale più semplice
minor estensione di facility
```

Rischi:

```text
coupling alla package identity concreta
minor astrazione
possibile duplicazione di compatibility logic
```

### Alternativa C — nuovo modello di capability del build environment

Da considerare soltanto se A e B falliscono su casi concreti.

Il consistency gate impone di non introdurre una nuova primitive finché la stessa responsabilità può essere coperta da qualcosa di già esistente.

Nessuna delle tre alternative è scelta da questo documento.

---

# Parte VII — Significato di "sistema pulito" nello sviluppo/test

## 29. Correzione della formulazione iniziale

La frase:

```text
build/test non deve modificare pkg/
```

è troppo forte se presa letteralmente.

Se durante lo sviluppo emerge che servono:

```text
CMake
compiler
JDK
Ninja
```

è coerente che tali strumenti siano package persistenti e condivisi.

Installarli tramite `pkg` modifica deliberatamente il package environment, ma non equivale a installare il progetto in sviluppo.

---

## 30. Regola più precisa

La proprietà desiderata è:

> una build/test non deve installare il progetto in sviluppo né pubblicare automaticamente i suoi output come package o command del sistema.

Può invece:

```text
usare build tool già installati
```

e, secondo una policy futura ancora aperta:

```text
procurare/installare build environment mancante tramite pkg
```

---

## 31. Cosa deve restare nello user state

Devono restare fuori dal package store almeno gli oggetti build-scoped come:

```text
object files
staging roots
generated sources
intermediate artifacts
test binaries
private downloaded build material
build cache
scratch
test runtime state
build/test logs
```

Il Model 2.0 possiede una semantic state root e il resolver `state-path`.

La futura specifica di `mk` dovrà usare il modello di state corrente invece di ricostruire path fisici o ripristinare le root 1.x superseded.

Il dettaglio di identity/area usato da `mk` resta da progettare.

---

## 32. Side effect ancora da decidere

Resta aperto se una normale operazione:

```text
mk build
mk test
```

possa installare automaticamente build tool mancanti oppure debba:

```text
fallire con requirement non soddisfatto
chiedere conferma
richiedere una operazione preparatoria esplicita
usare una policy configurabile
```

Questa è una decisione di UX/lifecycle distinta dalla decisione architetturale secondo cui il build environment può essere gestito da `pkg`.

---

# Parte VIII — Relazione fra orchestratori e servizi di basso livello

## 33. Evitare una dipendenza circolare ingenua

La forma:

```text
pkg -> mk
mk  -> pkg
```

può sembrare circolare se entrambi chiamano indiscriminatamente le rispettive CLI complete.

La soluzione concettuale è distinguere:

```text
orchestratori
```

da:

```text
primitive/internals riutilizzabili
```

---

## 34. Remote source install

```text
pkg orchestrator
    ↓
package acquisition internals
    ↓
extract
    ↓
mk materialization
    ↓
package integration internals
```

`pkg` non deve necessariamente invocare una CLI interattiva di `mk`; il contract preciso resta da progettare.

---

## 35. Local install

Direzione preferita:

```text
mk orchestrator
    ↓
project/source preparation
    ↓
materialization
    ↓
useful root
    ↓
package integration internals
```

`mk` non deve scrivere direttamente nel package store.

---

## 36. Development/test

```text
mk orchestrator
    ↓
resolve build environment
    ↓
resolve/acquire build material
    ↓
build/test/materialize
    ↓
user state only per gli output del progetto
```

I package persistenti di toolchain/build environment restano esterni al build output del progetto.

---

# Parte IX — Package specification e materialization specification

## 37. Due famiglie di informazioni

I casi discussi suggeriscono che bisogna mantenere semanticamente distinguibili due domande.

### Produrre il software

```text
source input
source acquisition se applicabile
build environment requirements
build material requirements
transformation/build rules
target/context
output useful root
```

### Integrare il software come package

```text
package identity
version
target qualification
cmd/link/env/default
facility
runtime dependency
state behavior
availability/integration semantics
```

---

## 38. Non forzare il progetto locale a fingere il catalogo remoto

Il progetto locale non dovrebbe dover inventare:

```text
repository/
URL
archive regex
fake artifact
fake download
```

per poter riusare la package integration.

Quindi il futuro design dovrà separare il fatto che:

```text
pkg-catalog è una sorgente di package definition
```

dal fatto che:

```text
le semantiche di package integration devono poter essere fornite anche da un progetto locale
```

senza duplicarle.

---

## 39. Tensione nell'attuale `pkg_integrate`

L'attuale API riceve una `range-dir` proveniente dal catalogo.

Per un progetto locale questo crea una tensione:

```text
integration semantics
    sono riusabili

ma

range-dir catalogo
    non esiste naturalmente
```

Quando inizierà lo sviluppo occorrerà decidere se:

```text
- generalizzare il boundary interno di package integration;
- introdurre un input normalizzato intermedio;
- mantenere un adapter interno fra sorgenti differenti di package definition;
- usare un'altra soluzione più piccola emersa dai casi reali.
```

Non va creato un fake range/catalog soltanto per soddisfare la firma corrente.

---

# Parte X — Responsabilità candidate di `mk`

## 40. Responsabilità coerenti con le analisi

Un futuro `mk` può plausibilmente possedere:

```text
project/source understanding
project composition
configuration/profile handling
build environment selection
build material acquisition orchestration
source transformation
build lifecycle
run/test lifecycle
generated artifacts
build cache/state
production of useful root
```

Questa lista è input di design, non un'API fissata.

---

## 41. Responsabilità che dovrebbero restare a `pkg`

`mk` non dovrebbe duplicare:

```text
package store ownership
concrete package availability
current/default
public command bindings
package facility provider index
runtime dependency binding
normal package integration/deintegration
repository adapter semantics già generiche di pkg
```

---

## 42. Concetti storici di `mk` da riesaminare

Da recuperare concettualmente:

```text
project composition
profiles/configuration overlays
distinct dependency kinds
build/test/install lifecycle
build -> package bridge
test environment isolation
```

Da non copiare automaticamente:

```text
shell-sourced configuration
dynamic global function names
global mutable environment
filesystem-order orchestration
timestamp-only build state
historical TARGET terminology
imperative side effects durante resolution
```

---

# Parte XI — Alternative e questioni aperte da portare alla sessione futura

## 43. Orchestratore dell'installazione locale

Direzione preferita:

```text
mk -> package integration internals
```

Alternativa da riesaminare solo se emerge un vantaggio concreto:

```text
pkg -> mk
```

Criteri di scelta:

```text
ownership dell'intento utente
CLI coherence
separation of concerns
riuso internals
failure semantics
possibilità di evitare local-path semantics in pkg
```

---

## 44. Build environment requirement

Da decidere:

```text
come viene dichiarato
come viene risolto
se riusa facility compatibility
come seleziona una concrete provider version
se usa current/default o binding concreto
se l'installazione può essere automatica
come viene reso disponibile al processo di build
```

---

## 45. Build material

Da decidere:

```text
come viene dichiarato
come viene acquisito
come viene verificato
come viene cached
come viene indirizzato dentro la build
come viene distinto da software installato
quando promuoverlo invece a package persistente
```

---

## 46. Toolchain identity e riproducibilità

Da esaminare:

```text
source digest
toolchain/package identities
build environment resolved graph
build material provenance
configuration digest
target/osarch
output digest
cache key
```

Non viene ancora adottato un content-addressed build store.

---

## 47. Target qualification

Da progettare la relazione fra:

```text
build target/context
m_OSARCH
package target-specific identity
cross compilation
host toolchain
output target
```

Non va recuperato automaticamente lo storico significato di `TARGET` di `mk`, che indicava lifecycle actions.

---

## 48. Test

Lo scenario development/test deve poter testare senza pubblicare il progetto nel sistema.

Resta da stabilire se e quando sia utile:

```text
produrre useful root
    ↓
integrare in una root isolata/test
    ↓
provare il package attraverso un path production-like
```

Questo concetto deriva dallo storico `testenv`, ma non deve essere implementato copiando il vecchio meccanismo.

---

# Parte XII — Direzioni preferite già abbastanza forti

## 49. Punti da portare come baseline di discussione

Pur restando non normativa, l'analisi converge con buona forza sui seguenti punti:

```text
1. mk orchestra il mondo progetto/build/test.

2. pkg orchestra l'installazione di package remoti.

3. remote source-only install inserisce mk fra extract e package integration.

4. local project install parte preferibilmente da mk e converge sulle internals di package integration.

5. development/test parte da mk e non installa il progetto o i suoi output nel sistema.

6. build tool/toolchain persistenti e condivisi sono buoni candidati a normali package gestiti da pkg.

7. input privati della build non devono essere trasformati automaticamente in package.

8. runtime dependency resta distinta dai requirement necessari a produrre il software.

9. useful root è il boundary naturale di convergenza prima della package integration.

10. il progetto locale non deve fingere di essere un repository remoto.

11. mk non deve scrivere direttamente nel package store.

12. pkg non deve diventare un framework universale che comprende ogni build system.
```

Questi punti sono materiale di partenza, non sostituiscono una futura decisione Accepted.

---

# Parte XIII — Ordine consigliato per la futura sessione di sviluppo

## 50. Gate iniziale obbligatorio

Quando l'utente deciderà di iniziare lo sviluppo di `mk` e l'evoluzione di `pkg`, la sessione dovrà ricominciare dal normale preflight repository-first.

Non si deve assumere che gli HEAD o i contratti riportati in questa nota siano ancora correnti.

Ordine minimo:

```text
1. verificare HEAD remoti correnti;
2. rileggere RULES.md e CONSISTENCY-GATE.md;
3. rileggere Model 2.0 e decisioni pkg correnti;
4. rileggere questo consolidamento e l'analisi 2026-09-13;
5. controllare implementazione e test pkg correnti;
6. estrarre nuovamente invarianti;
7. solo allora iniziare il design normativo/PoC.
```

---

## 51. Primo blocco di design consigliato

Prima di scrivere codice di `mk`, chiudere il modello minimo di:

```text
source tree -> useful root
```

con input espliciti per:

```text
build environment
build material
project/build rules
target/context
output location
```

senza ancora progettare tutto il lifecycle storico di `mk`.

---

## 52. Secondo blocco di design consigliato

Definire il boundary con `pkg` per:

```text
remote source-only
local install
```

risolvendo in particolare:

```text
package specification source
integration metadata normalization
current range-dir coupling
identity/version/provenance locale
failure/cleanup semantics
```

---

## 53. Terzo blocco di design consigliato

Definire il build environment:

```text
come vengono dichiarati i tool
come pkg li installa/rende disponibili
come mk li seleziona
come evitare conflitto fra versioni
se riusare facility/provider
```

Questo blocco deve essere guidato da almeno un caso reale, per esempio una toolchain concreta.

---

## 54. Quarto blocco di design consigliato

Definire il lifecycle development/test e lo user state:

```text
build output
cache
scratch
log
test state
staging/useful roots
cleanup/reuse
```

coerentemente con `state-path` e il Model 2.0.

---

## 55. Implementazione solo dopo chiusura dei boundary

Solo dopo i blocchi precedenti sarà proporzionato decidere:

```text
CLI esatta di mk
file/schema di progetto
adapter/plugin model
internal API di pkg da estendere
nuovi test permanenti
PoC richiesti
```

Questo evita di lasciare che la forma dell'implementazione decida accidentalmente l'architettura.

---

# Parte XIV — Non-decisioni esplicite

## 56. Questo documento non decide

Non viene ancora deciso:

```text
- la CLI completa di mk;
- la posizione fisica dell'eseguibile mk;
- il runtime/linguaggio con cui mk sarà implementato;
- un plugin API di mk;
- che Make/CMake/Ninja siano formalmente "plugin";
- il formato della project specification;
- il formato della materialization specification;
- il pathname dei metadata di progetto;
- una nuova serializzazione di build requirements;
- che il runtime dependency file venga riusato per build requirements;
- che facility/provider venga sicuramente riusato per il build environment;
- l'installazione automatica di build tool mancanti;
- il lifecycle/cache dei build material;
- un content-addressed store;
- un package format intermedio;
- un fake local repository/catalog;
- `pkg install ./path`;
- un local/install-local subcommand di pkg;
- una API pubblica di pkg_integrate;
- una nuova firma di pkg_integrate;
- una nuova primitive condivisa source->useful-root;
- la semantica definitiva della versione di un package locale;
- overwrite/reinstall della stessa concrete identity;
- cross-compilation semantics;
- test-root API;
- modifiche a rumiai-os, rumiai-tests o pkg-catalog;
- l'inizio della sessione di sviluppo.
```

---

# Parte XV — Sintesi operativa

## 57. Modello sintetico

```text
                     SOFTWARE PERSISTENTE

             pkg -----------------------------+
              |                               |
              | build environment             | runtime providers
              |                               |
              v                               v
             mk --------------------------> package runtime
              |
              | project source
              | build material
              | build/test state
              v
          useful root
              |
              +---- development/test -> user state only
              |
              +---- install ----------> pkg integration
```

---

## 58. Tre categorie da non confondere

```text
BUILD ENVIRONMENT
    software persistente e condivisibile
    normalmente buon candidato per pkg

BUILD MATERIAL
    input consumato dalla materializzazione
    normalmente build-scoped/cache, non automaticamente package

RUNTIME DEPENDENCY
    requirement del package installato
    appartiene al current dependency/facility model
```

---

## 59. Orchestrazione per scenario

```text
remote prebuilt package
    orchestrator = pkg

remote source-only package
    orchestrator = pkg
    materializer = mk

local project install
    preferred orchestrator = mk
    final integration = pkg internals

development/build/test
    orchestrator = mk
    project outputs = user state, non package publication
```

---

## 60. Punto di ripartenza futuro

Quando l'utente autorizzerà l'inizio dello sviluppo, questa nota deve essere usata come:

```text
mappa delle domande già esplorate
catalogo delle alternative
lista dei boundary promettenti
promemoria delle non-decisioni
ordine iniziale di lavoro
```

Non deve invece essere usata come sostituto delle fonti normative correnti.

La sessione futura dovrà trasformare, uno alla volta, i punti necessari da analisi esplorativa a decisioni/specification validate, mantenendo la disciplina:

```text
current repository authority
    ↓
concrete scenario
    ↓
minimal contract
    ↓
PoC quando necessario
    ↓
permanent tests
    ↓
product implementation autorizzata
```
