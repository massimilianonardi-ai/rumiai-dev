# Assessment esplorativo — readiness e piano di azione per il cambio di modello

Date: 2026-09-13  
Status: **EXPLORATORY / NON-NORMATIVE — MIGRATION ASSESSMENT CHECKPOINT**

## 1. Scopo

Questo documento usa come input la fotografia progettuale consolidata in:

```text
analysis/rumiai-os/2026-09-13-future-model-and-state-consolidation.md
```

per rispondere a quattro domande:

```text
1. il cambio di modello appare tecnicamente attuabile?
2. quali decisioni devono essere chiuse prima di attivarlo?
3. in quale sequenza conviene eseguirlo?
4. quali meccanismi servono per ridurre il rischio e rendere recuperabile ogni fase?
```

Il documento è deliberatamente **non normativo**.

Non costituisce:

```text
attivazione del futuro modello
autorizzazione a modificare rumiai-os
autorizzazione a modificare rumiai-tests
autorizzazione a modificare pkg-catalog
dichiarazione del checkpoint stabile richiesto dal modello corrente
supersession delle specifiche o decisioni Accepted correnti
```

L'eventuale esecuzione resta subordinata sia al checkpoint/assessment richiesto da:

```text
decisions/rumiai-os/2026-09-12-stabilize-current-rumiai-os-before-model-migration.md
```

sia all'approvazione esplicita prevista da:

```text
decisions/rumiai-os/2026-09-12-substrate-exploration-activation-gate.md
```

## 2. Revisioni del checkpoint di assessment

Il piano è stato costruito contro queste revisioni remote:

```text
rumiai-dev    31b3dbeb242ab5d81b5e77e5272b7659ee7d5717
rumiai-os     96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests  bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog   6443f265a922f7cff070f02e75d057727a6e5eb9
```

Il commit `rumiai-dev@31b3dbeb...` è il primo checkpoint documentale della presente riflessione e contiene soltanto documentazione esplorativa non normativa.

Le revisioni `rumiai-os`, `rumiai-tests` e `pkg-catalog` non sono state modificate per produrre questo assessment.

## 3. Invarianti correnti che il piano non può aggirare

Fino a una futura attivazione esplicita restano veri almeno:

```text
il runtime tecnico corrente è rumiai-os
lo shebang integrato corrente è #!/usr/bin/env rumiai-os
il PATH corrente è sys-osarch -> sys -> ext-osarch -> ext -> host PATH
le semantic root correnti sono top-level
lo state corrente è area-first
non esiste una root globale state/
conf/sys/<component> è il namespace state/config corrente dei componenti base
package state vive in <area>/<pkg> o <area>/<pkg>@!<state-instance>
package-local var/ è routing statico verso lo state selezionato
State Instance runtime e var/ non possono convivere
Git resta forward-only
physical evidence resta revision-specific
```

Il futuro modello deve quindi sostituire questi contratti tramite una migrazione esplicita; non può essere ottenuto reinterpretando silenziosamente i pathname o i test correnti.

## 4. Giudizio sintetico di readiness

L'assessment porta a una conclusione differenziata.

### 4.1 Blocco A — modello non-state

Il blocco non-state appare **tecnicamente realizzabile con rischio controllabile**, purché prima dell'esecuzione vengano chiusi alcuni dettagli ancora aperti:

```text
initial stable contract di m
initial development surface
branded product entrypoint necessari al momento della migrazione
source of truth del product versioning
policy di collisione command fra m e layer RumiAI
trattamento dei consumer/materializzazioni package che incorporano il vecchio shebang
```

Le trasformazioni principali del blocco A sono meccanicamente inventariabili e fortemente testabili:

```text
bootstrap/runtime rename
runtime exposure
shebang
PATH
branding boundary
environment ownership non-state
catalog consumer alignment
permanent test
```

### 4.2 Blocco B — state model

Il blocco state appare **plausibile ma non ancora sicuro da attivare**.

Esiste almeno un problema strutturale da risolvere prima dell'implementazione:

> il routing package-local `var/` corrente è statico, mentre il futuro state per POSIX user richiede che lo stesso package installato possa risolvere state diversi in funzione del security principal che lo esegue.

Questo non è un dettaglio di pathname. È un conflitto fra:

```text
shared immutable package installation
+
static package-local routing links
+
per-user mutable state
```

Finché questo punto non viene progettato e validato, il blocco B deve essere considerato **NO-GO**.

## 5. Correzione importante sul significato di rollback Git

Git rende molto sicura la trasformazione di:

```text
codice tracked
documentazione tracked
specifiche tracked
permanent test tracked
catalog tracked
```

perché conserva la storia e permette di identificare esattamente ogni checkpoint.

Git **non** conserva però automaticamente il contenuto operativo ignorato o materializzato fuori dalla storia tracked.

Nel modello corrente rientrano almeno:

```text
pkg/ materializzato localmente
state operativo sotto data/
home/
cache/
log/
run/
tmp/
contenuti runtime ignorati da .gitignore
package command/body e routing materializzati localmente
```

Quindi il principio di recuperabilità deve essere:

```text
tracked repository state
    -> Git history / forward-only revert or corrective commit

mutable operational state
    -> snapshot/backup esplicito indipendente da Git

reconstructible package store
    -> preferibilmente rebuild/reinstall da source/catalog verificati
```

Il secondo blocco non deve iniziare senza uno snapshot verificato dello state operativo che si intende migrare.

## 6. Strategia complessiva a checkpoint

La sequenza proposta è:

```text
GATE 0
formalizzare la baseline corrente e chiudere le decisioni mancanti

        ↓

BLOCCO A
migrazione completa del modello non-state

        ↓

CHECKPOINT A
nuovo runtime m + layer RumiAI, ancora con vecchio state model

        ↓

STATE READINESS GATE
chiudere e validare tutti i problemi del nuovo state

        ↓

BLOCCO B
migrazione completa dello state

        ↓

CHECKPOINT B
nuovo modello completo
```

Il valore di questa separazione è che `CHECKPOINT A` deve essere un sistema coerente: nessun pathname state viene lasciato in una forma metà vecchia e metà nuova soltanto per preparare il blocco successivo.

## 7. GATE 0 — baseline corrente e activation readiness

Prima di modificare il prodotto, il piano richiede una fase senza refactoring che produca una fotografia esatta del punto di partenza.

### 7.1 Dichiarare formalmente la baseline corrente

La decisione `2026-09-12-stabilize-current-rumiai-os-before-model-migration.md` richiede un checkpoint stabile esplicito prima dell'assessment operativo della migrazione.

Alla revisione usata per questo documento non risulta già fissata, nelle fonti esaminate, una distinta dichiarazione finale di quella baseline.

Prima dell'attivazione va quindi verificato e, se ancora necessario, formalizzato:

```text
rumiai-os revision del checkpoint
rumiai-tests revision del checkpoint
pkg-catalog revision applicabile
scope funzionale incluso
permanent test applicabili
physical validation applicabile
limitazioni accettate
```

Non serve completare future feature: serve rendere esatto e affidabile ciò che stiamo per migrare.

### 7.2 Inventario completo pre-migrazione

L'inventario deve distinguere semantica e occorrenza testuale.

Cercare almeno:

```text
rumiai-os
RumiAI
rumiai
rumi
#!/usr/bin/env rumiai-os
bin/sys/rumiai-os
m_OS_NAME
RUMIAI_*
m_*
conf/sys
semantic roots correnti
package var/ routing
State Instance grammar
repository URLs
validation config keys
test IDs
symlink names e targets
materialized package command bodies
```

Ogni occorrenza va classificata prima di essere cambiata. Non è ammesso un replace indiscriminato di `rumiai-os`, `RumiAI` o `m_*`.

### 7.3 Chiudere i contratti necessari al solo Blocco A

Prima del primo write operativo vanno definiti almeno:

```text
quali interfacce costituiscono il minimal stable contract iniziale di m
quali costituiscono la development surface iniziale
quali restano private
come viene rappresentata la versione di prodotto
quali branded product entrypoint devono esistere subito
come viene inizializzato il layer RumiAI senza contaminare m
come vengono gestite collisioni intenzionali/accidentali fra ai PATH e stable m commands
```

Il service/daemon boundary può restare esplicitamente privo di un contratto stable iniziale se nessun consumer concreto lo richiede ancora. È preferibile dichiarare un'assenza intenzionale che inventare in anticipo una API.

### 7.4 Piano di esecuzione Git

Per ridurre il rischio di lasciare `main` in stato intermedio, è preferibile eseguire ciascun blocco operativo su una branch di migrazione derivata dall'esatto checkpoint approvato.

La branch:

```text
non riscrive la storia
non usa force push
procede con commit piccoli e coerenti
viene validata prima dell'integrazione
```

Se un esperimento di migrazione viene abbandonato, il checkpoint di partenza resta intatto. L'eventuale integrazione finale resta forward-only.

Il nome concreto delle branch non viene fissato in questo documento.

## 8. BLOCCO A — piano non-state

Il blocco A deve essere trattato come una trasformazione coordinata. L'ordine seguente mira a non produrre consumer permanentemente incoerenti.

### A0. Freeze delle revisioni target

Prima del primo write:

```text
riverificare tutti gli HEAD remoti
congelare gli SHA target del blocco
verificare working tree e origine dei repository locali
registrare selezione/test baseline
```

Qualsiasi nuovo commit upstream nel perimetro richiede riesame prima di proseguire.

### A1. Decisione normativa di activation/migration

Solo quando l'utente autorizza esplicitamente l'adozione, creare la decisione che supera il substrate activation gate e specifica almeno:

```text
identity m
boundary con RumiAI
repository ownership
minimal stable contract
development surface
private surface
runtime/bootstrap
namespace
PATH responsibilities
versioning
compatibility stance
migration checkpoints
```

Il documento esplorativo presente non sostituisce questa decisione.

### A2. Preparare le specifiche superseding

Prima o insieme al codice, definire la versione futura dei contratti osservabili:

```text
command entrypoint
bootstrap environment
PATH
runtime exposure
branding boundary
product version
shell activation boundary
package/catalog consumer contract rilevante
```

Le specifiche correnti non devono semplicemente sparire: la nuova autorità deve dichiarare esplicitamente cosa supersede.

### A3. Migrare il runtime tecnico a `m`

Trasformazione coordinata candidata:

```text
root technical bootstrap/runtime: m
integrated technical shebang:     #!/usr/bin/env m
runtime exposure:                 bin/sys/m -> ../../m
```

Nello stesso work unit devono essere aggiornati tutti i consumer tecnici tracked che dipendono dal vecchio interpreter identity.

Verificare in particolare:

```text
root discovery
m_COMMAND_BIN
in-process command source semantics
argument forwarding
error/failure behavior
PATH resolution host profile
possible host command collision with m
```

Il rename non deve cambiare incidentalmente la semantica del dispatcher.

### A4. Separare branding da runtime tecnico

Rimuovere dal layer tecnico la dipendenza hardcoded dal display brand oggi espressa, per esempio, da:

```text
m_OS_NAME="RumiAI"
```

La sorgente concreta del display brand deve essere quella definita durante il Gate 0.

Non creare rename dinamici dei technical file in funzione del brand.

### A5. Mantenere `m` owner del solo PATH general purpose

Il bootstrap `m` deve continuare a costruire esclusivamente:

```text
sys-osarch
sys
ext-osarch
ext
host PATH
```

Il layer RumiAI deve aggiungere:

```text
ai-osarch
ai
```

soltanto quando attivato.

Shell e GUI RumiAI devono convergere sul medesimo contratto di attivazione, ma il meccanismo concreto deve essere introdotto soltanto dopo averne fissato il contratto reale.

### A6. Audit dell'environment namespace non-state

Classificare ogni `m_*` corrente secondo ownership e stabilità.

Non rinominare automaticamente le variabili state-related che appartengono ancora al vecchio state model: tali variabili devono restare coerenti fino al Blocco B, salvo che il contratto del Block A possa conservarne esattamente la semantica corrente.

Riservare `m_ai_*` soltanto quando esiste un vero valore environment RumiAI/AI da esporre.

### A7. Materializzare product versioning

Implementare una sola source of truth della versione `rumiai-os`, secondo il contratto deciso in Gate 0.

Verificare che:

```text
non esistano versioni indipendenti dei singoli command
Git SHA continui a identificare la revisione esatta di sviluppo
SemVer descriva il prodotto/distribuzione
```

### A8. Allineare `pkg-catalog` e package materializzati

I package/catalog command correnti possono incorporare:

```text
#!/usr/bin/env rumiai-os
```

Aggiornare il catalogo non modifica automaticamente package già materializzati localmente.

Il blocco A deve quindi decidere esplicitamente una delle strategie supportate, preferendo quando possibile:

```text
ricostruire/reinstallare package materializzati da catalog/source verificati
```

anziché mutare silenziosamente in-place artefatti generated.

Prima di scegliere questa strategia va verificato che ogni package materializzato necessario sia effettivamente riproducibile/reinstallabile con le source ancora disponibili.

Lo state mutabile del package non deve essere cancellato insieme al package store.

### A9. Migrare permanent test e tooling

Aggiornare soltanto i test che proteggono contratti realmente cambiati.

Proteggere almeno:

```text
m direct bootstrap
integrated #!/usr/bin/env m command
runtime exposure
m-only PATH precedence
RumiAI ai PATH activation
brand/runtime separation
repository/product discovery che deve restare rumiai-os
catalog materialization col nuovo interpreter
```

Repository identity `rumiai-os` e technical runtime identity `m` non devono essere confuse nel test tooling.

### A10. Stale-pattern scan del Blocco A

Prima della validation cercare e classificare nuovamente almeno:

```text
#!/usr/bin/env rumiai-os
bin/sys/rumiai-os
technical bootstrap references a rumiai-os
hardcoded RumiAI branding nel layer m
accidental ai knowledge in m bootstrap
obsolete catalog-generated command bodies
```

Le occorrenze storiche o descrittive corrette non vanno rimosse solo perché contengono il nome vecchio.

### A11. Development run e physical validation

Eseguire i test proporzionati ai contratti modificati secondo `TESTING.md`.

Il cambio di bootstrap/shebang/PATH è comportamento runtime fondamentale e richiede validation revision-specific sui reference host applicabili, non soltanto una development run locale.

La validation deve usare revisioni committed esatte di prodotto e test.

### A12. CHECKPOINT A

Il checkpoint A è raggiunto soltanto se:

```text
m è il technical runtime attivo
RumiAI resta il product layer
PATH ownership è separata
branding non contamina m
versioning è coerente
catalog consumer/materialized packages sono allineati
permanent test sono verdi
validation applicabile è registrata
vecchio state model resta ancora internamente coerente
```

Non si inizia il Blocco B per correggere una regressione irrisolta del Blocco A.

## 9. STATE READINESS GATE — decisioni da chiudere prima del Blocco B

Il blocco state deve iniziare solo dopo aver risolto tutti i punti seguenti.

### S1. Identity fisica del POSIX principal

`user` è già concettualmente fissato come host/POSIX security principal, ma il pathname concreto non è ancora deciso.

Va valutato esplicitamente almeno:

```text
username
numeric UID
```

Il numeric UID è concettualmente più vicino alla security identity del kernel e non cambia con un rename del nome account, ma introduce questioni di portabilità/mapping fra host.

La decisione deve coprire almeno:

```text
rename user
UID reuse
root/euid 0
multi-host relocatability
ownership verification
```

Non scegliere la rappresentazione soltanto perché è più leggibile.

### S2. Ownership/mode/ACL contract

Definire esattamente:

```text
owner di state/system
chi può modificare system/current
mode della directory state/user
chi crea user/<principal>
owner e mode delle user subtree
comportamento con umask ostile
symlink attack prevention
canonicalization boundary
```

Un pathname user-separated senza enforcement del filesystem non costituisce un security boundary.

### S3. System profile selector contract

Chiudere il contratto di `system/current` o del nome finale scelto:

```text
admin-only mutation
relative symlink
target confinato sotto system/profile
validazione del target
missing selector behavior
broken selector behavior
atomic replacement
quiescence requirement
restart semantics
```

La direzione preferita è fail-closed in caso di selector invalido anziché fallback silenzioso, ma questo comportamento va fissato esplicitamente prima dell'implementazione.

### S4. Initial system profile

La migrazione deve sapere in quale profile collocare lo state system corrente e a cosa puntare il selector iniziale.

Il nome concreto dell'initial profile non è ancora fissato e non deve essere inventato durante la copia dei dati.

### S5. State resolver / environment contract

Un processo user-scoped può avere bisogno contemporaneamente di:

```text
system state/policy del profile corrente
user-private state del proprio principal
```

Questo non deve essere implementato come overlay filesystem implicito.

Prima del Blocco B va definito come un consumer richiede o deriva:

```text
system state root
user state root
owner-specific identity root
area root
```

In particolare va deciso il futuro delle attuali:

```text
m_CONF_DIR
m_DATA_DIR
m_HOME_DIR
m_CACHE_DIR
m_LOG_DIR
m_RUN_DIR
m_TMP_DIR
```

Non è sufficiente puntarle tutte a system oppure tutte a user: entrambe le classi di state possono essere necessarie nello stesso processo.

### S6. Package execution scope

Il package store può essere condiviso, ma il mutable state può essere:

```text
system-scoped
user-scoped
```

Va stabilito chi decide lo scope del launch e su quale informazione affidabile:

```text
package contract
service execution context
interactive/user launch context
explicit administrative configuration
```

Non deve essere il package stesso a scegliere liberamente un security scope più ampio.

### S7. Package `var/` contro per-user state — BLOCKER

Questo è il principale blocker strutturale identificato dall'assessment.

Oggi una versione concreta condivisa contiene routing statico:

```text
<package-version>/root/<path>
    -> <package-version>/var/<area>/<path>
        -> one selected physical state
```

Con due POSIX user A e B, la stessa versione dovrebbe invece poter raggiungere:

```text
state/user/A/pkg/<pkg>/...
```

e:

```text
state/user/B/pkg/<pkg>/...
```

senza modificare un link condiviso ad ogni launch.

La soluzione non può essere semplicemente "aggiornare var/" perché introdurrebbe race, cross-user routing e possibile violazione di sicurezza.

Prima del Blocco B serve un design dedicato e una PoC.

Le famiglie di soluzione da valutare, senza sceglierne qui una, includono:

```text
per-scope/per-launch execution view che condivide immutable payload ma materializza routing proprio
altro meccanismo di dynamic state routing coerente con gli upstream pathname
restrizione documentata dei package pathname-routed a uno scope compatibile
```

Non va introdotta una nuova primitive finché la PoC non dimostra quale responsabilità sia realmente necessaria.

### S8. Per-user default state initialization

Oggi `pkg install` può inizializzare uno state noto durante installazione.

Con user futuri non ancora esistenti, il default state user-scoped richiede un contratto nuovo per:

```text
lazy o explicit initialization
source da <package-version>/default
ownership corretta
atomicity
concurrent first launch
failure recovery
factory reset semantics
```

Questo punto deve essere risolto insieme a S7, non successivamente.

### S9. State Instance nel nuovo layout

Decidere se e come l'identity-first layout rappresenta una State Instance.

Devono restare vere almeno le proprietà semantiche utili:

```text
instance locale a una singola identity
nessuna confusione con system profile
nessuna cross-user sharing implicita
coerenza fra environment routing e pathname routing
```

La vecchia forma `<pkg>@!<state-instance>` non va copiata automaticamente nel nuovo layout solo per compatibilità visiva.

### S10. Static product resources vs mutable `conf`

Prima di rendere `state/.../conf` interamente mutable, riallocare o ridefinire in modo esplicito i contenuti versionati che oggi vivono sotto `conf`, per esempio gli adapter shell correnti.

La nuova destinazione deve derivare dal loro ruolo reale, non da un rename meccanico.

### S11. Git-ignore policy del nuovo state

Definire una policy che protegga:

```text
state runtime non tracked
selector/profile metadata che deve essere tracked o materializzato secondo il contratto scelto
static resources tracked altrove
nessuna contaminazione della root .gitignore
```

La policy deve essere protetta da permanent test isolati dagli exclude host, come avviene oggi.

### S12. Classificazione dello state corrente da migrare

Il layout corrente non codifica il futuro security scope.

Un pathname come:

```text
conf/<pkg>/env
```

è oggi descritto come user override, ma fisicamente è globale.

La migrazione deve quindi classificare ogni famiglia di state in:

```text
future system profile state
future user state del principal corrente
reconstructible/non-authoritative state eliminabile o rigenerabile
unsupported/needs-manual-decision
```

La classificazione deve essere basata sulla semantica del componente/package, non sul solo pathname corrente.

## 10. PoC obbligatoria consigliata per il package state multi-user

Prima del Blocco B è opportuno usare `rumiai-dev-PoCs` per validare fisicamente il problema S7/S8.

La PoC dovrebbe esercitare almeno:

```text
package env-only con user A e B
package pathname-routed/var-like con user A e B
una sola immutable package installation condivisa
system-scoped package state
user-scoped package state
State Instance o equivalente selezione locale se ancora applicabile
first initialization concorrente
relative routing
package uninstall/reinstall senza perdita user state
malicious/broken symlink nei confini user
UID/ownership mismatch
```

La stessa idea va verificata almeno sui reference host rilevanti quando dipende realmente dalla semantica filesystem/ownership host.

La PoC non diventa automaticamente architettura: serve a scegliere il contratto corretto prima di consolidarlo.

## 11. Snapshot operativo prima del Blocco B

Prima di modificare state fisico:

```text
fermare/quiescere il runtime necessario
inventariare tutte le root mutable
registrare owner/group/mode e symlink
calcolare hash dove appropriato
creare snapshot/backup fuori dal tree che si sta trasformando
verificare che il backup sia leggibile e completo
```

Per `run` e `tmp` la semantica transient può rendere inutile una restore bit-identica; la policy deve distinguerli da `conf`, `data` e `home` autorevoli.

Il backup deve comunque permettere di recuperare ogni state autorevole non tracked da Git.

## 12. BLOCCO B — piano state

Solo dopo il superamento dello State Readiness Gate.

### B0. Freeze del checkpoint A

Riverificare:

```text
HEAD di tutti i repository
validation del checkpoint A
assenza di regressioni pendenti
snapshot operativo pronto
```

### B1. Consolidare la specifica finale dello state

Prima della prima copia dati, fissare normativamente almeno:

```text
state root
system profile layout
selector contract
POSIX-principal identity
owner namespaces
identity-first layout
area semantics
state resolver/environment contract
package execution scope
package routing model
State Instance representation
permissions
Git-ignore policy
migration mapping
```

Non scoprire la grammatica del filesystem durante il data move.

### B2. Implementare il resolver state fondamentale

Il runtime deve poter determinare in modo verificabile:

```text
physical current system profile
current effective POSIX principal quando necessario
system owner/identity/area root
user owner/identity/area root
```

La risoluzione di `system/current` deve canonicalizzare un target confinato alla root prevista e congelare il risultato per il processo secondo il contratto finale.

### B3. Materializzare il nuovo dominio `state/`

Creare soltanto le directory strutturali necessarie secondo il contratto finale.

Non creare il prodotto cartesiano:

```text
scope × owner × identity × area
```

Le area esistono solo quando richieste.

### B4. Separare static resources da mutable state

Applicare il mapping definito in B1 ai contenuti versionati che oggi condividono namespace con `conf` runtime.

Aggiornare nello stesso work unit consumer, specifiche e permanent test relativi.

### B5. Implementare system profile selection

Implementare il selector amministrativo con:

```text
relative target
validation
authorization/permission contract
atomic switch
quiescence enforcement o procedura documentata
failure handling
```

Il bootstrap non deve inventare un fallback profile in assenza di un selector valido salvo contratto esplicitamente approvato.

### B6. Implementare user security boundaries

Materializzare user state soltanto con ownership/mode coerenti con il principal.

Testare esplicitamente:

```text
user A non legge/modifica state privato B secondo il security contract
user A non può ridirigere resolver verso system o B tramite symlink
admin/system operations restano separate
invalid ownership/mode viene rifiutata o gestita secondo contratto
```

### B7. Migrare `pkg`/launcher al nuovo routing

Applicare il design validato dalla PoC S7/S8.

Il launcher deve mantenere coerenti:

```text
execution scope
HOME/environment mapping
package env
user/system env override secondo il nuovo contratto
pathname-routed state
State Instance selection quando supportata
immutable package payload
```

Non devono esistere due identità state concorrenti nello stesso launch.

### B8. Allineare package default/initialization

Applicare il contratto deciso per il first-use user state, inclusa concorrenza e ownership.

Verificare che `pkg install`, normale launch e factory/default state non acquisiscano responsabilità contraddittorie.

### B9. Migrare lo state esistente offline

La migrazione dei dati autorevoli deve essere deterministica e auditabile.

Per ogni oggetto migrato registrare almeno, quando applicabile:

```text
source
destination
classification
owner/group/mode
symlink behavior
hash prima/dopo per regular data
result
```

La migrazione non deve cancellare la source autorevole prima che la destination sia verificata e che esista comunque il backup esterno.

### B10. Trattare cache/log/run/tmp secondo lifecycle

Non copiare automaticamente tutto soltanto perché esiste.

Applicare la policy di area:

```text
cache  può essere rigenerata quando sicuro
log    migrare o archiviare se serve continuità diagnostica
run    non riattivare stale PID/socket/lock
tmp    non trattare come autorevole
```

### B11. Ricostruire package store se previsto

Se il piano finale sceglie di ricostruire il package store per eliminare materializzazioni del vecchio modello:

```text
preservare separatamente mutable state
verificare catalog/source
reinstallare package
verificare command bodies, env, routing e symlink
```

Il package store ricostruibile non deve diventare il backup dello state.

### B12. Migrare permanent test

Proteggere almeno:

```text
state/system/current selector contract
profile confinement
profile switch semantics
user principal mapping
ownership/mode security boundary
owner sys/ai/pkg separation
identity-first layout
area materialization only when needed
system and user state resolution
package env-only user isolation
package pathname-routed user isolation
first-use/default initialization
State Instance semantics
static resource separation
new Git-ignore policy
migration behavior dove deterministicamente testabile
```

Le vecchie aspettative area-first devono essere superseded esplicitamente, non semplicemente cancellate.

### B13. Development run e security regression testing

Eseguire selection mirate durante lo sviluppo e una suite proporzionata al termine.

Il nuovo state model tocca security, filesystem, package launch, persistence e bootstrap; merita test negativi oltre ai soli happy path.

### B14. Physical validation

Validare revisioni committed esatte sui reference host applicabili.

La physical validation deve includere almeno le parti host-sensitive:

```text
principal identity
ownership/mode
symlink semantics
atomic selector behavior
package execution/routing
bootstrap state resolution
```

### B15. Stale-pattern scan finale

Cercare almeno:

```text
$m_ROOT/conf/<old form>
$m_ROOT/data/<old form>
$m_ROOT/home/<old form>
$m_ROOT/cache/<old form>
$m_ROOT/log/<old form>
$m_ROOT/run/<old form>
$m_ROOT/tmp/<old form>
<area>/sys/<component>
old package state link targets
old State Instance assumptions
old conf/sys static resource assumptions
old Git-ignore root set
```

Le occorrenze storiche/documentali corrette devono restare chiaramente storiche e non essere promosse a modello corrente.

### B16. CHECKPOINT B

Il modello completo è candidato al checkpoint soltanto quando:

```text
state resolver è unico e coerente
system profile selector è sicuro e amministrativo
user state rispetta il POSIX security principal
package state routing funziona con shared package installation
State Instance non confligge con profile/user scope
state migration è verificata
backup resta disponibile fino alla chiusura della validation
permanent tests sono allineati
physical validation applicabile è registrata
stale-pattern scan è pulito
```

## 13. Strategia di failure e recupero

### 13.1 Failure nel Blocco A

Poiché il blocco A riguarda principalmente contenuto tracked e artefatti ricostruibili:

```text
non force-pushare
non riscrivere la storia
correggere forward oppure produrre revert commit forward-only
confrontare sempre con il checkpoint pre-A
```

Se la migration branch non viene integrata, il checkpoint precedente resta naturalmente disponibile.

### 13.2 Failure nel Blocco B

Per lo state operativo Git non è sufficiente.

La procedura deve poter:

```text
fermare il nuovo runtime
ripristinare code/config tracked tramite checkpoint/revert forward-only
ripristinare lo snapshot dello state autorevole
ricostruire package store se necessario
rieseguire validation sul punto ripristinato
```

Non assumere che checkout di un vecchio commit ripristini automaticamente i dati mutable.

## 14. Matrice preliminare del rischio

La seguente valutazione è qualitativa e serve a guidare l'ordine del lavoro, non è una garanzia.

| Area | Readiness attuale | Motivo principale |
| --- | --- | --- |
| technical runtime rename `rumiai-os` -> `m` | alta | trasformazione inventariabile e testabile |
| integrated shebang/runtime exposure | alta | contratto corrente preciso, consumer identificabili |
| m-only PATH + RumiAI prepend | alta | boundary concettuale chiaro, testabile |
| docs/spec/test supersession | alta | interamente tracked e meccanicamente verificabile |
| branding separation | media | source of truth concreta ancora da fissare |
| product SemVer implementation | media | policy scelta, primitive concreta ancora aperta |
| stable/development/private initial cut | media | direzione chiara, elenco iniziale va formalizzato |
| catalog/materialized package transition | media | reinstallability dei package va verificata |
| system profile selector | medio-alta | modello semplice, restano atomicità/permission/failure contract |
| POSIX user state security | media | UID/path/ownership/ACL/symlink contract ancora aperti |
| env-only package per-user state | medio-alta | compatibile concettualmente con runtime routing via env |
| pathname-routed package per-user state | **bassa / blocker** | static shared `var/` non può scegliere user state per launch |
| per-user default state initialization | medio-bassa | lifecycle e concurrency da progettare |
| State Instance physical representation | media | semantica chiara, layout nuovo ancora da scegliere |
| existing state data migration | medio-bassa | richiede classificazione semantica + backup indipendente da Git |

## 15. Go / no-go criteria per l'attivazione

### GO per il Blocco A soltanto quando

```text
formal current-stability checkpoint disponibile
activation/migration esplicitamente approvata dall'utente
initial stable/development/private boundaries sufficientemente definite
branded entrypoint scope deciso
versioning source of truth deciso
collision policy PATH decisa
catalog/materialized package strategy verificata
baseline test/evidence identificata
```

### GO per il Blocco B soltanto quando

```text
Checkpoint A stabile e validato
S1-S12 chiusi
package var/per-user blocker risolto con design + PoC
security principal path e permission contract testabili
state resolver contract fissato
State Instance representation fissata
initial system profile fissato
migration classification completa
operational state snapshot verificato
```

Se uno di questi punti manca, la conclusione corretta è **NO-GO temporaneo**, non una implementazione parziale.

## 16. Copertura rispetto al substrate activation gate

Il piano copre o rende esplicito un work item per:

```text
identity/scope                    coperto
ownership/repos                   coperto, repository resta rumiai-os
boundary with RumiAI              coperto
stable initial contracts          Gate 0 work item
development surface               Gate 0 work item
services/daemon boundary          può essere esplicitamente deferred se nessun contract iniziale
shell boundary                    Block A
command boundary                  Block A
package/catalog ownership         Block A + Block B
runtime/bootstrap identity        Block A
namespace/filesystem              Block A + Block B
versioning/compatibility          Gate 0 + Block A
distributed docs                  Block A/B secondo contract
migration of specs/decisions      Block A/B
migration of permanent tests      Block A/B
physical validation               Checkpoint A/B
Git forward-only plan             coperto
```

Non risultano quindi categorie obbligatorie del gate completamente ignorate; alcune sono intenzionalmente ancora open work item da chiudere prima dell'attivazione.

## 17. Punti scoperti dall'assessment che non erano ancora emersi chiaramente

L'assessment ha fatto emergere in particolare:

```text
Git non protegge runtime state ignorato
static package var/ è incompatibile con per-user dynamic state senza nuovo routing design
future user path identity deve scegliere username vs UID con security semantics
user state richiede un vero permission/ownership contract
same process può necessitare system state e user state senza overlay
per-user package default state non può essere tutto materializzato a install time
current state migration richiede semantic classification, non pathname rewrite
materialized package command bodies possono conservare il vecchio interpreter
```

Questi punti devono essere considerati parte integrante della decisione di migrazione, non edge case successivi.

## 18. Conclusione dell'assessment

Il cambio di modello appare **attuabile**, ma conviene distinguere nettamente due livelli di confidenza:

```text
Blocco A
    sufficientemente definito da poter diventare operativo
    dopo un numero limitato di decisioni finali e l'activation approval

Blocco B
    architettura generale promettente
    ma NON ancora pronto all'esecuzione
    finché non viene risolto il package state routing multi-user
    e non vengono fissati security/resolver/migration contracts
```

Questa è una conclusione positiva ma non una autorizzazione a procedere immediatamente.

Il vantaggio del piano a checkpoint è che ogni fase può essere valutata contro una revisione esatta. Git conserva integralmente la storia tracked; snapshot indipendenti proteggono lo state mutable non tracked. Insieme, questi due meccanismi rendono la migrazione sostanzialmente recuperabile senza ricorrere a history rewrite.

Il prossimo lavoro progettuale più utile prima di una activation decision è quindi:

```text
1. chiudere il formal current-stability checkpoint se non già dichiarato separatamente;
2. chiudere i pochi contratti ancora aperti del Blocco A;
3. progettare e PoC-testare il routing package multi-user del Blocco B;
4. fissare principal identity, permissions e state resolver;
5. rieseguire il readiness assessment;
6. soltanto allora chiedere/registrare l'approvazione esplicita della migration phase.
```
