# Analisi esplorativa — `var/` system-scoped e reassessment della readiness di migrazione

Date: 2026-09-13  
Status: **EXPLORATORY / NON-NORMATIVE — FOLLOW-UP ASSESSMENT**

## 1. Scopo

Questo documento raffina il modello futuro dello state dopo una precisazione sull'intento originario di `var/` e riesamina il principale blocker identificato in:

```text
analysis/rumiai-os/2026-09-13-model-migration-readiness-and-action-plan.md
```

La conclusione del precedente assessment secondo cui sarebbe necessario progettare un routing `var/` dinamico o per-user viene qui superata **soltanto come conclusione esplorativa del futuro modello**.

Il modello operativo corrente resta invariato. Questo documento non modifica né supersede le decisioni Accepted correnti finché il futuro modello non viene attivato esplicitamente secondo il substrate activation gate.

## 2. Preflight

Il reassessment è stato eseguito contro:

```text
rumiai-dev       2fb8f70c923a8c980a8c493be6aac10249991f73
rumiai-os        96d399d0fe0454ed22adf22dc9739af0c8e1ec9a
rumiai-tests     bb335ca567bf465ba08f203caa2e5258db670869
pkg-catalog      6443f265a922f7cff070f02e75d057727a6e5eb9
rumiai-dev-PoCs  96848d0cf17f8473b75be3d2ddc6ab710623a997
```

Sono stati riesaminati almeno:

```text
RULES.md
CONSISTENCY-GATE.md
2026-09-05-package-state-var-default.md
2026-09-06-package-self-contained-launch-and-default-state.md
2026-09-06-package-env-shell-source.md
2026-09-07-package-state-instance-runtime-eligibility.md
2026-09-12-substrate-exploration-activation-gate.md
2026-09-12-stabilize-current-rumiai-os-before-model-migration.md
2026-09-13-future-model-and-state-consolidation.md
2026-09-13-model-migration-readiness-and-action-plan.md
rumiai-tests/tests/rumiai-os/pkg/state.test
rumiai-os/lib/sh/pkg-launch.lib.sh
pkg-catalog DBeaver macOS arm64 command entry
```

È stata inoltre costruita e dry-run la PoC:

```text
rumiai-dev-PoCs/pocs/008-var-system-scope-routing
```

## 3. Intenzione semantica di `var/`

La precisazione progettuale è coerente con il contratto package già consolidato nel modello corrente:

```text
var/
    non è la root generale dello state
    non è un sostituto dell'environment
    non è un router generico per qualunque scope
```

Il suo ruolo è più specifico:

> separare fisicamente dal package store lo state che il software upstream continua a raggiungere tramite pathname interni al proprio installation tree.

Il modello corrente lo esprime già come:

```text
root/<path>
    -> var/<area>/<path>
        -> physical state
```

mentre lo state che l'upstream permette di collocare altrove viene indirizzato tramite environment, argomenti o altra interfaccia supportata dal software.

## 4. DBeaver come controesempio utile a un `var/` universale

Il package DBeaver corrente non necessita di `var/` per configuration/workspace.

Il command materializzato usa direttamente:

```text
-configuration <external path>
-data          <external path>
```

Questa è precisamente la situazione in cui RumiAI deve sfruttare la capacità nativa del software anziché introdurre un routing filesystem artificiale.

Nel futuro state model tali destinazioni possono quindi essere risolte nello user state del POSIX principal corrente senza modificare la package installation condivisa.

## 5. Regola futura preferita per `var/`

La direzione esplorativa viene raffinata così:

```text
state raggiunto tramite var/
    -> system-scoped

state user-scoped
    -> mai raggiunto tramite var/
    -> deve essere nativamente indirizzabile dal software
       tramite environment, argv o altro meccanismo upstream supportato
```

Nel futuro layout il target semantico di `var/<area>` diventa quindi:

```text
state/system/current/pkg/<package>/<area>
```

oppure la corrispondente forma finale del system profile attivo.

`var/` non deve puntare a:

```text
state/user/<principal>/...
```

## 6. Package misti: `var/` non classifica l'intero package

La presenza di `var/` non deve significare automaticamente:

```text
"tutto lo state di questo package è system-wide"
```

La classificazione corretta avviene per porzione di state e per meccanismo di routing.

Un medesimo package può quindi avere contemporaneamente:

```text
state system-scoped
    raggiunto tramite root -> var -> state/system/current/...

state user-scoped
    raggiunto tramite environment/argv/native upstream routing
    -> state/user/<principal>/...
```

Questo è importante perché evita di trasformare una limitazione di un singolo pathname upstream in una limitazione artificiale di tutto il package.

## 7. Caso non multi-user

Se uno state logicamente modificabile dall'utente:

```text
non è indirizzabile nativamente fuori dall'installation tree
```

e richiede quindi `var/`, quel particolare state non può essere isolato per POSIX user mantenendo una singola package installation condivisa e routing statico.

La direzione preferita non tenta di nascondere questa limitazione introducendo un `var/` dinamico.

Il comportamento corretto è invece riconoscere che:

```text
quel state è system-scoped nel modello RumiAI
```

oppure, se l'isolamento multi-user è un requisito indispensabile per quel software, dichiarare che quel caso non è supportabile dal baseline con una singola installation condivisa.

Questo riflette la capacità reale dell'upstream anziché simulare una multiutenza che il software non possiede.

## 8. Eliminazione del precedente blocker strutturale

Il precedente readiness assessment formulava il problema così:

```text
shared package installation
+
static var routing
+
per-user state
= incompatibilità strutturale
```

Questa formulazione assumeva implicitamente che lo stesso `var/` dovesse poter indirizzare per-user state.

Con la separazione qui fissata esplorativamente la relazione diventa invece:

```text
shared package installation
+
static var routing -> system state
+
native runtime routing -> user state
```

Non è quindi necessario introdurre:

```text
dynamic var per launch
per-user rewrite dei symlink package-local
per-user package execution view
seconda package materialization soltanto per cambiare var
```

Il blocker S7 del precedente assessment è pertanto considerato **risolto a livello progettuale esplorativo**.

## 9. Risultato della PoC 008

La PoC ha verificato fisicamente, in una root isolata, la coesistenza di:

```text
una sola package installation
static root -> var routing
var -> active system profile
user state distinto per due principal simulati
nessun var -> user state
cambio quiescente di system profile
package completamente native-routed senza var sintetica
```

Output:

```text
var-system-routing=PASS
native-user-routing=PASS
var-never-user=PASS
profile-switch=PASS
native-no-var=PASS
var-system-scope-model=PASS
```

La PoC non costituisce permanent validation e non prova ownership/security fra veri POSIX principal.

## 10. System profile e `var/`

Un vantaggio importante del nuovo modello è che il routing statico può attraversare il selector system-wide:

```text
var/<area>
    -> state/system/current/pkg/<package>/<area>
```

Con il sistema quiescente, cambiare `system/current` cambia il backing state system-wide visto dallo stesso package store senza riscrivere i `var/` di ogni package/versione.

Questo mantiene separate:

```text
package materialization lifecycle
system profile lifecycle
```

La PoC ha però evidenziato che l'esatto meccanismo portabile di replacement del selector resta da progettare.

## 11. Atomicità del selector: open item separato

Durante l'authoring della PoC, una sostituzione diretta:

```text
mv current.new current
```

con `current` symlink a una directory non ha prodotto il replacement desiderato sull'host di authoring: il destination operand è stato interpretato attraverso la directory referenziata.

La PoC usa quindi un cambio quiescente non atomico:

```text
prepare replacement
remove old selector
move replacement into place
```

Questa osservazione non riapre il problema `var/`.

Resta invece un work item specifico del system profile selector:

```text
portable replacement semantics
crash recovery
missing selector behavior
broken selector behavior
fail-closed behavior
quiescence requirement
```

L'atomicità non deve essere dichiarata risolta finché non viene definita e verificata una primitive/meccanismo realmente portabile.

## 12. Impatto sull'env utente corrente

Nel modello corrente l'env persistente utente è:

```text
$m_CONF_DIR/<pkg>/env
```

ed è anche raggiungibile tramite:

```text
<package-version>/var/conf/env
```

Questa equivalenza **non deve essere importata automaticamente nel futuro modello**.

Se `var/conf` è system-scoped, un user env futuro deve vivere nello user state appropriato ed essere letto dal launcher tramite il resolver user-scoped, non tramite `var/conf`.

Quindi il futuro modello deve distinguere almeno:

```text
package version env
    static/version-specific

system package config/state
    eventualmente raggiungibile tramite var/conf quando l'upstream lo richiede

user package env/config
    state/user/<principal>/pkg/<package>/...
    raggiunto dal launcher/native routing
```

Questo è un riallineamento futuro da includere nel Blocco B, non una modifica del contratto corrente.

## 13. Default state e inizializzazione

La distinzione semplifica anche l'inizializzazione.

Per state `var/` system-scoped:

```text
pkg install
```

può continuare concettualmente a materializzare factory/default state nel system profile selezionato secondo il contratto finale.

Per user state nativamente indirizzato, gli utenti futuri potrebbero non esistere al momento dell'installazione.

La relativa inizializzazione deve quindi essere:

```text
upstream-managed
```

quando il software la gestisce già, oppure:

```text
first-use/lazy per principal
```

quando RumiAI deve materializzare default user state.

Il vecchio S8 non sparisce completamente, ma non è più accoppiato a `var/`: resta soltanto per package che richiedono factory/default user state gestito da RumiAI.

## 14. State Instance

La distinzione system/user evita di usare State Instance come surrogato della multiutenza.

Restano concetti diversi:

```text
POSIX principal
    security/execution scope

system profile
    variante completa dello system state

State Instance
    molteplicità locale dello state di una identity dentro lo scope appropriato
```

Per state raggiunto tramite `var/`, una State Instance resta necessariamente legata a una selezione system/package persistente e coerente con il routing statico.

Per state user-scoped interamente nativamente indirizzabile, una futura State Instance user-local può in linea di principio essere selezionata runtime senza modificare `var/`, perché `var/` non partecipa a quello user state.

La grammatica fisica finale resta da decidere nel State Readiness Gate.

## 15. Security e concurrency

Il fatto che `var/` sia system-scoped rende esplicita una proprietà importante:

```text
var-backed state non è user-private
```

Se più POSIX principal eseguono contemporaneamente lo stesso software contro il medesimo var-backed state, condividono semanticamente quello state.

RumiAI non deve promettere isolamento che l'upstream non supporta.

Prima di rendere operativo il multi-user state va ancora definito:

```text
chi può scrivere system package state
ownership/mode/ACL
quali package possono essere lanciati da user non privilegiati quando possiedono var-backed writable state
concurrency/quiescence requirements del particolare software
```

Questi sono problemi reali di permission e software capability, non motivi per rendere `var/` per-user.

## 16. Nuova classificazione della readiness del Blocco B

Dopo questa correzione, la precedente valutazione:

```text
pathname-routed package per-user state
    bassa / blocker
```

viene sostituita esplorativamente da:

```text
var-backed package state
    system-scoped per definizione futura
    readiness medio-alta sul piano del routing

native-routed user state
    readiness medio-alta sul piano del routing

user-private state non nativamente redirigibile
    non supportabile come user-isolated tramite shared var
    deve restare system-scoped oppure essere escluso dal multi-user baseline
```

Non risulta più necessario progettare una nuova dynamic-routing primitive per superare il blocker.

## 17. Open item del State Readiness Gate dopo il reassessment

Restano da chiudere prima del Blocco B:

```text
rappresentazione fisica del POSIX principal
ownership/mode/ACL contract
system profile selector e replacement/recovery
initial system profile
state resolver/environment contract
classificazione system-vs-user dei singoli state binding del packaging
policy di launch dei package con writable var-backed state
future user env location/layering
first-use initialization quando RumiAI gestisce user defaults
State Instance physical representation
static resources vs mutable conf
Git-ignore policy
semantic classification e backup dello state corrente da migrare
```

Questi punti sono rilevanti ma, dopo la correzione di `var/`, **non è emerso al momento un blocker strutturale equivalente al precedente S7**.

## 18. Impatto sul piano di migrazione

La sequenza a due blocchi resta invariata:

```text
Blocco A — non-state
Checkpoint A
State Readiness Gate
Blocco B — state
Checkpoint B
```

Nel Blocco B, il work item precedentemente dedicato a un dynamic package-state routing va sostituito con:

```text
classificare ogni package state binding:
    system var-backed
    system native-routed
    user native-routed

materializzare var soltanto per system state che richiede compatibility routing

risolvere user state per principal tramite launcher/native upstream mechanism

rifiutare implicitamente l'idea che var possa essere user-scoped
```

Non viene introdotta ora una nuova metadata primitive: la rappresentazione concreta di questa conoscenza deve riusare il packaging esistente dove sufficiente o essere definita soltanto quando emergerà la minima informazione realmente mancante.

## 19. Readiness aggiornata

Il giudizio complessivo diventa:

```text
Blocco A
    sostanzialmente invariato: alta plausibilità dopo poche decisioni finali

Blocco B
    ancora non pronto all'esecuzione
    ma senza il precedente blocker strutturale var/per-user
    restano contratti di security, resolver, selector, State Instance e migration da chiudere
```

Quindi il futuro modello appare più attuabile di quanto risultasse dal precedente assessment.

## 20. Limite di autorità

Questo documento è non normativo.

Non modifica:

```text
rumiai-os
rumiai-tests
pkg-catalog
layout state corrente
semantica corrente di var/
semantica corrente delle State Instance
env utente corrente
```

La trasformazione qui descritta appartiene soltanto alla futura migration phase, se e quando verrà approvata esplicitamente secondo il substrate activation gate.
