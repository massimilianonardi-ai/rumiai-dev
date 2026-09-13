# Analisi esplorativa — consolidamento del futuro modello `m` / RumiAI e dello state

Date: 2026-09-13  
Status: **EXPLORATORY / NON-NORMATIVE — CONSOLIDATED SNAPSHOT**

## 1. Scopo e limite di autorità

Questa nota consolida, senza attivarle, le direzioni progettuali emerse nella riflessione sul futuro modello interno di `rumiai-os` e, in particolare, sul redesign dello state.

Il documento è deliberatamente **non normativo**. Non modifica né reinterpreta il modello operativo corrente. Restano pienamente applicabili:

```text
RULES.md
CONSISTENCY-GATE.md
specifiche normative correnti
decisioni Accepted correnti
permanent test correnti
physical evidence revision-specific
```

La relazione con il modello futuro continua a essere regolata da:

```text
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
decisions/rumiai-os/2026-09-12-stabilize-current-rumiai-os-before-model-migration.md
```

In particolare, questa nota non autorizza modifiche a:

```text
rumiai-os
rumiai-tests
pkg-catalog
bootstrap/runtime corrente
shebang correnti
namespace correnti
filesystem layout corrente
package model corrente
state layout corrente
```

## 2. Preflight della fotografia consolidata

La presente consolidazione è stata verificata contro gli HEAD remoti:

```text
rumiai-dev    fc8379dcb2ce4991353788e2657073684a946033
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests  bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
```

Sono stati riesaminati almeno:

```text
RULES.md
CONSISTENCY-GATE.md
TESTING.md
specifications/rumiai-os/BOOTSTRAP-ENVIRONMENT.md
specifications/rumiai-os/COMMAND-ENTRYPOINTS.md
decisions/rumiai-os/2026-09-05-package-state-var-default.md
decisions/rumiai-os/2026-09-06-system-base-state-namespace.md
decisions/rumiai-os/2026-09-07-package-state-instance-runtime-eligibility.md
decisions/rumiai-os/2026-09-08-runtime-state-git-ignore.md
decisions/rumiai-os/2026-09-12-substrate-contract-stratification.md
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
decisions/rumiai-os/2026-09-12-stabilize-current-rumiai-os-before-model-migration.md
analysis/rumiai-os/2026-09-12-m-substrate-and-rumiai-os-specialization.md
analysis/rumiai-os/2026-09-12-substrate-two-level-contract-model.md
```

Sono stati inoltre riesaminati i permanent test correnti che proteggono almeno:

```text
bootstrap PATH precedence
semantic roots correnti
runtime-state Git ignore policy
package state routing e var/
```

Questa fotografia usa le fonti correnti come autorità del presente e registra separatamente il futuro modello senza promuoverlo a contratto operativo.

## 3. Correzione della precedente formulazione del nome `m`

Le prime analisi esplorative descrivevano `m` come possibile working name non ancora scelto.

La direzione progettuale successiva è più precisa:

```text
m
= identità tecnica del futuro layer runtime general purpose interno a rumiai-os
```

Questa identità tecnica non implica:

```text
rinomina del repository rumiai-os
rinomina del prodotto finale RumiAI in m
riuso del vecchio repository/progetto massimilianonardi/m
separazione obbligatoria in un repository autonomo
```

La direzione consolidata è invece:

```text
repository: rumiai-os

layer tecnico basso: m
layer/prodotto superiore: RumiAI
```

L'attuale contenuto di `rumiai-os`, non contenendo ancora una vera responsabilità AI-specifica, è concettualmente quasi interamente candidato al layer tecnico `m`. Il futuro layer RumiAI aggiungerebbe sopra di esso shell/presentazione RumiAI, servizi e capability AI, core AI e GUI/desktop.

Questa classificazione resta futura e non cambia oggi ownership o naming del codice corrente.

## 4. Stratificazione dei contratti

Resta consolidata, ma non attiva, la distinzione:

```text
stable
    contratto minimo, fortemente compatibile e fortemente testato

development
    superficie intenzionalmente consumabile ma revision-coupled

private
    implementation detail non destinato al consumo
```

RumiAI runtime dovrebbe normalmente dipendere soltanto da `m/stable`.

Tooling di sviluppo, PoC, diagnostica e strumenti revision-coupled possono usare `m/development` quando necessario.

`m/private` non costituisce API.

Il principio guida resta:

> stabilizzare poco, ma stabilizzarlo molto bene.

Ownership e livello di stabilità restano assi indipendenti. Una primitive appartenente a `m` non è automaticamente stabile; un pathname nel `PATH` o una primitive coperta da test non è automaticamente API stabile.

## 5. Boundary di dipendenza fra `m` e RumiAI

La direzione consolidata prevede:

```text
m non dipende semanticamente da RumiAI

RumiAI può dipendere dal piccolo contratto stabile di m
```

Le principali superfici candidate del contratto stabile restano:

```text
shell infrastructure
service/daemon infrastructure futura
pochi command general purpose
```

`log`, `lang` e `pkg` restano forti candidati, senza essere qui promossi a contratto stabile attivo.

Primitive più operative o amministrative quali, in linea esplorativa:

```text
digest
extract
http-fetch
osarch-update
pkg-analyze
read-key
```

sono più naturalmente candidate alla superficie `development`, salvo requisiti futuri diversi.

Helper interni come `_pkg_*` o equivalenti implementation detail restano candidati `private`.

`pkg-launch.lib.sh` richiede attenzione specifica perché command materializzati da `pkg-catalog` lo consumano già; non può essere classificato semplicemente private senza riesaminare il contratto di quei consumer.

## 6. Runtime/bootstrap futuro e shebang

La direzione progettuale consolidata è che l'attuale ruolo tecnico:

```text
root bootstrap/runtime: rumiai-os
integrated shebang:      #!/usr/bin/env rumiai-os
runtime exposure:        bin/sys/rumiai-os -> ../../rumiai-os
```

migri in modo coordinato verso l'identità tecnica `m`:

```text
root bootstrap/runtime: m
integrated m-layer shebang: #!/usr/bin/env m
runtime exposure: bin/sys/m -> ../../m
```

La singola lettera `m` è compatibile con le correnti regole di naming dei pathname controllati da RumiAI.

Il rischio principale da verificare nella migrazione non è sintattico, ma la possibile collisione con un comando `m` presente nel `PATH` host prima che il runtime canonico sia attivo.

Non è prevista, come direzione preferita, una lunga fase di alias `rumiai-os` -> `m`: la migrazione futura è pensata come trasformazione coordinata e forward-only, con compatibilità esplicita solo se un requisito concreto la rende necessaria.

## 7. PATH: `m` non conosce `ai`

Una correzione importante rispetto a una formulazione intermedia è che il bootstrap `m` non deve costruire direttamente il `PATH` del layer AI.

Il `PATH` base del layer `m` resta concettualmente:

```text
sys-osarch
sys
ext-osarch
ext
host PATH
```

Il layer RumiAI aggiunge sopra di esso i propri executable root, in ordine di precedenza:

```text
ai-osarch
ai
```

ottenendo, quando il layer RumiAI è attivato:

```text
ai-osarch
ai
sys-osarch
sys
ext-osarch
ext
host PATH
```

La responsabilità di aggiungere `ai*` appartiene al layer RumiAI, non al bootstrap general purpose `m`.

RumiAI shell e GUI devono condividere lo stesso comportamento di attivazione del layer RumiAI; questa nota non inventa né fissa ancora il nome della primitive comune che lo implementerà.

Una futura policy dovrebbe inoltre evitare shadow accidentale dei command stabili `m` da parte di command RumiAI; l'esatta regola di collisione resta da formalizzare prima dell'attivazione.

## 8. Namespace environment futuro

La direzione progettuale è:

```text
m_*       famiglia environment del layer tecnico m
m_ai_*    sottospazio riservato al layer RumiAI/AI
```

Il prefisso non determina il livello di stabilità dell'interfaccia.

La forma `m_ai_*` è preferita a un generico `ai_*` perché riduce collisioni nel comune ambiente POSIX e mantiene evidente l'appartenenza alla runtime family composta.

La futura migrazione dovrà riesaminare ogni variabile `m_*` corrente per ownership effettiva; non è corretto rinominare meccanicamente tutte le variabili né assumere che tutte debbano essere stabili.

## 9. Branding e identità di prodotto

Il futuro design distingue:

```text
display brand
branded product entrypoints
technical runtime identity
```

La technical runtime identity è `m`.

Il display brand corrente resta `RumiAI` e deve essere disaccoppiato dal codice tecnico `m` quando avverrà la migrazione. L'attuale bootstrap contiene ancora `m_OS_NAME="RumiAI"`; questo è quindi un punto concreto da riallineare nel futuro blocco non-state.

Una configurazione di branding dovrebbe controllare presentazione e display identity senza provocare rename dinamici dei file tecnici.

Gli eventuali branded root entrypoint del prodotto RumiAI restano da definire esattamente; non vengono introdotti qui nuovi nomi canonici.

## 10. Versioning

La direzione progettuale consolidata è usare un unico versionamento SemVer per l'intera distribuzione `rumiai-os`, non versioni indipendenti dei singoli command.

Concettualmente:

```text
MAJOR  breaking change del contratto stable
MINOR  estensione compatible del contratto stable / nuova funzionalità
PATCH  fix o refactoring senza modifica del contratto stable
```

In fase pre-1.0 è ragionevole usare `0.y.z` con disciplina esplicita sui cambi breaking del contratto candidato/stabile.

Il Git SHA continua a identificare esattamente la revisione di sviluppo.

Non viene qui introdotta una nuova primitive di versioning: la forma concreta di manifest, file o comando deve essere decisa soltanto quando la migrazione viene attivata.

## 11. Principio del nuovo state model

Il redesign dello state nasce dall'osservazione che il layout corrente:

```text
$m_ROOT/<area>/...
```

espone come primo asse la natura dello state (`conf`, `data`, ecc.) e mescola poi ownership e identity.

La direzione futura preferita introduce una semantic root unica:

```text
$m_ROOT/state/
```

ma non per riprodurre semplicemente il modello corrente un livello più in basso.

Il nuovo state model separa esplicitamente almeno:

```text
security/execution scope
owner
state identity
optional identity-local instance
area
```

Il layout corrente, che dichiara esplicitamente l'assenza di una common state root, resta normativo fino alla futura migrazione. `state/` sarebbe quindi una supersession deliberata, non una reinterpretazione compatibile del contratto attuale.

## 12. Security/execution scope: soltanto `system` e `user`

La direzione consolidata prevede due soli scope di sicurezza/esecuzione:

```text
system
user/<POSIX-principal>
```

`user` significa esplicitamente:

```text
host/POSIX user
= security principal
= execution principal
```

Non rappresenta una identità logica RumiAI separata dal principal host.

Lo user state deve quindi rispettare realmente il security boundary del POSIX user. La separazione non può essere soltanto nominale o di pathname: ownership e mode del filesystem dovranno essere coerenti con il principal effettivo.

Nessuna condivisione implicita dello user state fra principal diversi è ammessa dalla direzione progettuale.

## 13. System profile: specializzazione amministrativa completa dello state system

`profile` non è un terzo security scope e non ha una relazione diretta con gli user.

Un system profile è una variante completa dello state system-wide selezionata da un amministratore.

Il modello preferito è:

```text
state/system/
├── current -> profile/<profile>
└── profile/
    ├── <profile-a>/
    ├── <profile-b>/
    └── ...
```

`current` è al momento il candidato preferito come nome del selector perché il progetto usa già lo stesso pattern concettuale per selezioni persistenti, ma questa nota non lo rende ancora contratto operativo.

Il selector deve essere un symlink relativo per preservare relocatability, per esempio:

```text
current -> profile/workstation
```

La semantica fondamentale è:

```text
system/profile/<name>
= state system-wide completo di quel profilo
```

Non esiste un base system state a cui applicare un overlay del profile.

Non esiste quindi una ricerca:

```text
profile -> fallback base
```

né una regola uniforme di merge fra directory.

Questo evita ambiguità diverse per `conf`, `data`, `run`, `tmp`, ecc. e mantiene una sola root concreta per lo state system attivo.

## 14. Selezione del system profile

La selezione del system profile è una responsabilità amministrativa system-wide.

Un POSIX user:

```text
non seleziona direttamente il system profile
non possiede il system profile
non è associato al system profile come identity
non condivide il proprio state tramite il system profile
```

Tutti i processi che operano sull'installazione vedono lo stesso profile system attivo, salvo processi già avviati prima di un cambio coordinato.

Il bootstrap futuro dovrebbe:

```text
1. risolvere $m_ROOT
2. risolvere state/system/current
3. canonicalizzare/fissare la root concreta del system profile per il processo
4. usare da quel momento la root concreta selezionata
```

Non dovrebbe continuare a seguire `current` per ogni singolo accesso allo state: ciò eviterebbe che un cambio del selector durante l'esecuzione produca un processo che osserva due profile differenti.

Il cambio di system profile deve quindi essere trattato come operazione amministrativa coordinata, normalmente con il sistema RumiAI fermo/quiescente o con arresto e riavvio controllato delle componenti dipendenti.

L'esatto comando/protocollo di selezione non è definito qui.

## 15. Nessuno state `boot` separato per ora

La necessità di bootstrap non richiede, allo stato attuale della riflessione, una root `boot/` distinta.

Prima della risoluzione del profile il bootstrap deve conoscere soltanto la struttura minima necessaria a trovare:

```text
state/system/current
```

Tutto lo state system applicativo si trova nel profile selezionato.

Una root `boot` separata dovrebbe essere introdotta soltanto se emergerà un lifecycle, ownership o security contract concretamente distinto che non possa essere rappresentato dal selector strutturale.

## 16. Owner dentro lo scope

Dentro uno scope concreto, la direzione preferita distingue ownership:

```text
sys
ai
pkg
```

con significato:

```text
sys  state di componenti integrati del layer tecnico/sistema
ai   state di componenti integrati del layer RumiAI
pkg  state di package gestiti
```

L'owner non determina lo security scope.

Sono quindi concettualmente possibili state:

```text
system / sys
system / ai
system / pkg

user / sys
user / ai
user / pkg
```

quando esiste un requisito concreto.

La vecchia idea di riservare package names `sys` e `ai` tramite configurazione non è necessaria nel modello owner-first, perché package state e integrated component state occupano namespace strutturalmente diversi.

## 17. Identity prima dell'area

La direzione preferita è raggruppare tutto lo state di una identity sotto una root comune:

```text
<scope>/<owner>/<identity>/<area>
```

anziché:

```text
<scope>/<owner>/<area>/<identity>
```

Motivazione:

```text
identity = naturale unità di lifecycle
```

Operazioni come ispezione, export, reset, migrazione o rimozione dello state di una identity diventano più naturali quando le relative area sono contenute sotto la stessa root.

Per i componenti integrati si usa component identity, non genericamente command name: un componente può esporre più command e una rinomina CLI non deve implicare migrazione automatica dello state.

Per `pkg`, l'identity è il package.

## 18. Layout esplorativo risultante

La forma fisica attualmente più promettente è:

```text
$m_ROOT/state/
├── system/
│   ├── current -> profile/<profile>
│   └── profile/
│       └── <profile>/
│           ├── sys/
│           │   └── <component>/
│           │       └── <area>/
│           ├── ai/
│           │   └── <component>/
│           │       └── <area>/
│           └── pkg/
│               └── <package>/
│                   └── <area>/
│
└── user/
    └── <POSIX-principal>/
        ├── sys/
        │   └── <component>/
        │       └── <area>/
        ├── ai/
        │   └── <component>/
        │       └── <area>/
        └── pkg/
            └── <package>/
                └── <area>/
```

Questa è una rappresentazione esplorativa consolidata, non un layout attivo.

## 19. State area

Le area correnti restano semanticamente utili:

```text
conf
    configurazione persistente

data
    dati persistenti autorevoli

home
    compatibility bucket conservativo quando lo state non è classificabile meglio

cache
    persistente ma rigenerabile

log
    diagnostica/storia operativa persistente non autorevole

run
    PID, socket, lock, coordinamento runtime

tmp
    scratch/intermedi temporanei
```

La classificazione corrente:

```text
persistent authoritative:      conf data home
persistent non-authoritative:  cache log
transient:                     run tmp
```

resta una buona base semantica.

Non tutte le combinazioni scope × owner × identity × area devono essere materializzate. Esistono soltanto quelle realmente necessarie.

`home` non equivale a `user`: un daemon o package system-wide può avere bisogno di una HOME compatibility area senza appartenere a un user interattivo.

## 20. Regola di sicurezza per state derivato

State derivato da informazioni user-private non deve allargare accidentalmente il security scope.

In particolare, una cache, un log, un runtime file o un tmp derivato da state appartenente a un POSIX user non deve diventare implicitamente system-wide soltanto perché l'area è non-authoritative o transient.

Il processo o servizio che prende ownership di quello state deve farlo esplicitamente secondo il proprio security contract.

## 21. System profile e transient state

Poiché un profile rappresenta lo state system completo, anche `cache`, `log`, `run` e `tmp` possono appartenere alla root del profile quando semanticamente necessari.

Questo evita contaminazione fra profile diversi.

La presenza fisica di vecchi contenuti `run`/`tmp` non implica riutilizzabilità: al riavvio o riattivazione di un profile deve continuare a valere la semantica transient dell'area. Lifecycle e cleanup restano responsabilità separate dal layout.

Non viene introdotta una root shared per cache/log/model artifact soltanto per deduplicazione. Se emergerà un grande store realmente condivisibile e immutabile, andrà prima valutato se sia davvero state o piuttosto uno store distinto.

## 22. Package store e package state restano concetti distinti

Il futuro layout mantiene distinta l'installazione del software dal relativo state:

```text
$m_ROOT/pkg
    package store / version materialization

$m_ROOT/state/.../pkg/<package>
    mutable runtime state del package
```

Un package può essere installato una sola volta nel package store e possedere state differente a seconda del security scope in cui viene eseguito.

La futura logica `pkg`/launcher dovrà quindi risolvere la root state corretta per il launch invece di assumere una sola root globale per package.

## 23. State Instance

Le State Instance correnti appartengono al package model e usano oggi:

```text
<pkg>@!<state-instance>
```

nelle root area-first correnti.

Il nuovo modello non deve importare automaticamente questa rappresentazione fisica.

Resta però utile la distinzione semantica:

```text
system profile
    variante completa dello state system-wide

State Instance
    molteplicità locale dello state di una singola identity
```

A livello user non serve introdurre un secondo concetto di user profile: la molteplicità di state di una singola identity è già il dominio naturale delle State Instance.

Non viene qui generalizzato il meccanismo State Instance da `pkg` a `sys`/`ai`: tale estensione richiede un requisito concreto.

La futura rappresentazione fisica delle State Instance nel layout identity-first resta un punto da decidere prima della migrazione state.

## 24. Static product resources contro mutable state

Il modello corrente contiene almeno un caso in cui configurazione distribuita/versionata e mutable state condividono concettualmente il nome `conf`: gli adapter shell distribuiti vivono oggi sotto `conf/sys/shell/`.

Il nuovo modello dovrebbe riesaminare questa sovrapposizione e distinguere chiaramente:

```text
static/versioned product resource
!=
mutable runtime state/conf
```

La collocazione concreta futura dei file statici non viene ancora fissata.

Analogamente, i cataloghi lingua sono static product resources, mentre eventuali preferenze/selector modificabili appartengono semanticamente allo state appropriato. La migrazione non deve però spostare meccanicamente `lang/` senza aver prima definito il contratto finale.

## 25. Environment roots dello state: punto non ancora fissato

L'introduzione di:

```text
m_STATE_DIR=$m_ROOT/state
```

è una conseguenza naturale da valutare, ma non è ancora una decisione operativa.

Analogamente, non è ancora fissato se le attuali variabili:

```text
m_CONF_DIR
m_DATA_DIR
m_HOME_DIR
m_CACHE_DIR
m_LOG_DIR
m_RUN_DIR
m_TMP_DIR
```

debbano essere reinterpretate come root dello `system/current` di `m`, sostituite da un resolver più esplicito o esposte diversamente fra `m` e RumiAI.

Non devono essere introdotte automaticamente sette variabili `m_ai_*` corrispondenti senza consumer reali.

Questo punto deve essere chiuso prima del blocco di migrazione state.

## 26. Git-ignore policy futura

Il prodotto corrente rende fisicamente presenti `pkg`, `data`, `home`, `cache`, `log`, `run`, `tmp` tramite `.gitignore` locali e mantiene `conf` versionabile.

Il nuovo layout `state/` richiederà una nuova policy coerente con:

```text
mutable runtime state non versionabile
static product resources versionabili
system profile selector strutturale
user state non versionabile
```

La policy esatta deve essere progettata insieme al nuovo layout, non ottenuta con un semplice rename dei `.gitignore` correnti.

## 27. Sequenza di migrazione preferita

La futura migrazione complessiva del modello dovrebbe essere una singola fase architetturale approvata, ma eseguita in due blocchi distinti e checkpointabili.

```text
BLOCCO A — tutto il modello non-state

runtime/bootstrap identity m
integrated shebang
runtime exposure
PATH m e attivazione PATH RumiAI
ownership/namespace environment non-state
branding boundary
entrypoint product/RumiAI
contract stratification iniziale
versioning
command classification necessaria
catalog consumer alignment
specifiche/documentazione/test correlati

        ↓ checkpoint coerente

BLOCCO B — state model

state/ root
system profiles e selector
POSIX-user scope
owner sys/ai/pkg
identity-first layout
state-area roots
pkg routing e launcher
State Instance representation
static config vs mutable conf
Git-ignore policy
state data migration
permanent tests
physical validation
```

Il BLOCCO A non deve anticipare a metà il nuovo state layout. Fino al checkpoint A, i pathname state e le relative environment variables devono restare coerenti con il vecchio contratto oppure essere cambiati soltanto come parte del BLOCCO B.

## 28. Git forward-only e recuperabilità

La futura migrazione resta forward-only.

Non è previsto riscrivere la storia né force-pushare per simulare un rollback.

Git conserva il checkpoint pre-migrazione e ogni checkpoint intermedio. Se una migrazione risultasse sbagliata, il recupero preferito è:

```text
analizzare il failure
produrre uno o più commit correttivi/revert forward-only
riprendere eventualmente il design dal checkpoint noto
```

Le physical evidence storiche restano associate alle revisioni effettivamente validate e non vengono rietichettate come validation del nuovo modello.

## 29. Questioni intenzionalmente ancora aperte

Prima dell'attivazione devono essere chiusi almeno:

```text
esatto contratto stable iniziale di m
superficie development iniziale
service/daemon boundary
branded product entrypoint finali
source-of-truth concreta del branding
primitive concreta di product versioning
collision policy fra command ai e command stable m
resolver/environment contract del nuovo state
rappresentazione fisica delle State Instance nel layout identity-first
amministrazione/atomicità del cambio system profile
ownership/mode/ACL contract dello user state
migrazione di state già materializzato
lifecycle/cleanup di run e tmp nei profile
collocazione finale delle static product resources oggi sotto conf
impatti del nuovo state sui package già materializzati
```

Questi open item non invalidano la direzione progettuale, ma impediscono di considerare il modello già pronto per l'attivazione senza un assessment dedicato.

## 30. Risultato del consolidamento

La fotografia progettuale risultante può essere riassunta così:

```text
rumiai-os repository
│
├── m
│   technical low-level general-purpose layer
│   m-only bootstrap/runtime/PATH
│   stable + development + private
│
└── RumiAI
    branded AI/product layer
    ai PATH activation
    AI-specific components and UX

state
├── system
│   ├── current -> profile/<profile>
│   └── profile/<profile>/<owner>/<identity>/<area>
└── user/<POSIX-principal>/<owner>/<identity>/<area>
```

Questa fotografia è sufficientemente consolidata per essere usata come input di un assessment/piano di migrazione, ma resta non normativa finché non viene superato esplicitamente il substrate activation gate.
