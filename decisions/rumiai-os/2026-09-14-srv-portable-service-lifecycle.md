# Decisione — lifecycle portabile dei servizi e confine con la supervisione host

Date: 2026-09-14  
Status: **Accepted / Active**

## 1. Scopo

Questa decisione introduce il primo modello service/daemon successivo a RumiAI OS 2.0 e chiude il rinvio esplicito presente in `MODEL-2.0-MIGRATION.md`.

Il requisito concreto è permettere a `m` di avviare e fermare processi long-running locali, per esempio un server Ollama usato on demand, senza richiedere privilegi amministrativi e senza dipendere da `systemd` o `launchd`.

Separatamente, RumiAI deve poter integrare in futuro gli stessi target con il service manager nativo dell'host. Tale integrazione è opt-in, host-specific e non fa parte del lifecycle portabile baseline definito qui.

## 2. Ownership architetturale

`srv` appartiene al substrate tecnico `m`.

Un service non introduce una nuova owner class dello state. Restano le sole owner class correnti:

```text
sys
ai
pkg
```

Il daemon non è un secondo tipo di oggetto prodotto: è il processo long-running risultante dall'avvio di un service target.

## 3. Comando pubblico baseline

Il comando pubblico è:

```text
srv
```

La prima tranche espone:

```text
srv start <service>
srv stop [-f] <service>
```

Il comportamento deriva dallo storico `srv-start` / `srv-stop` di `rumiai-portable-runtime`, che resta materiale di riferimento non normativo e non viene copiato o migrato automaticamente.

L'opzione `-f` forza lo stop esplicito di un processo vivo anche quando il caller corrente non coincide con il caller che lo ha avviato tramite `srv`.

## 4. Service target

Per il service `<service>`, `srv start` risolve il comando:

```text
<service>-start
```

Il pathname viene canonicalizzato prima del launch usando le primitive correnti di `m`.

Questa scelta ha due conseguenze intenzionali:

1. il target effettivamente avviato resta stabile per quella istanza anche se un binding pubblico package cambia successivamente;
2. `srv` non duplica il package launcher: se `<service>-start` è un comando package, il normale command body/package launcher continua a preparare HOME, env e dependency e poi esegue il target reale.

Il service target deve restare in foreground dal proprio punto di vista. Self-daemonization, double-fork e PID file applicativi non diventano il contratto baseline di `srv`.

## 5. Lifecycle portabile

`srv start`:

```text
valida il nome service
risolve lo state runtime/log tramite state-path
serializza start/stop concorrenti dello stesso service
riusa un processo già registrato e ancora vivo
rimuove runtime state stale
risolve e canonicalizza <service>-start
avvia il target con nohup in background
indirizza stdout/stderr al log del service
verifica che il processo non termini immediatamente
pubblica i metadata runtime come insieme completo
```

`srv stop`:

```text
è idempotente se il service non è attivo
rimuove metadata stale quando il PID non è più presente
senza -f ferma soltanto un processo registrato dallo stesso caller operativo
con -f permette lo stop esplicito da un caller differente
invia SIGTERM
attende una terminazione pulita entro un limite finito
non usa SIGKILL automaticamente
rimuove i metadata dopo la terminazione
```

Il caller ownership marker è una regola di lifecycle/cleanup, non autenticazione e non confine di sicurezza.

## 6. State

`srv` usa esclusivamente `state-path` per ottenere le proprie root semantiche.

Il lifecycle locale baseline usa:

```text
state-path user sys srv run
state-path user sys srv log
```

I metadata di ogni service vivono sotto la root `run` di `srv`; i log dei processi sotto la root `log` di `srv`.

Il layout fisico oltre queste root è dettaglio interno di `srv` e non deve essere ricostruito da altri consumer.

Lo scope `user` continua ad avere il significato corrente di namespace di state selezionato da `m`. Non identifica il POSIX principal corrente e non costituisce un confine di sicurezza.

## 7. Process identity e limite POSIX

La baseline usa il PID del processo long-running e metadata runtime gestiti da `srv`.

Il processo viene considerato presente attraverso primitive POSIX del sistema. POSIX non offre un identificatore di generazione del processo portabile che elimini in assoluto il rischio teorico di PID reuse dopo una perdita anomala dei metadata/runtime owner.

La baseline riduce il rischio tramite:

```text
runtime state transiente
cleanup stale
pubblicazione completa dei metadata
lock per service
stop owner-aware
force esplicito
```

Non viene introdotta una dipendenza da `/proc`, `launchctl`, `systemctl`, API Linux-specific o API macOS-specific per risolvere tale limite nel core portabile.

## 8. Readiness e health

`srv` verifica soltanto che il processo non termini immediatamente durante l'avvio.

Readiness applicativa e health sono responsabilità del service specifico e non vengono inferite genericamente dal lifecycle wrapper.

## 9. Supervisione host distinta

L'integrazione con `systemd` e `launchd` è una funzionalità distinta e opt-in che verrà esposta attraverso `srv`, ma non viene implementata dalla tranche portabile baseline.

Gli adapter host dovranno preservare almeno questi invarianti:

```text
il lifecycle portabile continua a funzionare senza installazione host
nessuna operazione normale on-demand richiede sudo/amministratore
user/session supervision e system supervision restano distinte
state scope user/system non viene dedotto dal POSIX account del supervisor
l'installazione system-wide richiede un confine amministrativo esplicito
un daemon system-wide usa un POSIX account dedicato quando l'isolamento lo richiede
la useful root/eseguibili non devono essere writable dal service account per default
lo state mutabile deve essere separato dalla useful root e posseduto secondo necessità operative
client non privilegiati possono usare un daemon già installato senza escalation amministrativa
```

Su Linux il primo adapter candidato è `systemd`; su macOS è `launchd`. Il loro comportamento concreto deve essere validato tramite PoC prima della promozione nel prodotto, perché POSIX non definisce un service manager comune.

## 10. Relazione con package e state

`srv` non introduce un secondo package model e non reinterpreta `dependency`/facility come service dependency graph.

Il normale package launcher resta responsabile del launch environment del package. Lo state package resta risolto tramite `state-path` secondo i contratti correnti.

La futura supervisione system-wide richiederà un launch context esplicito per state system-scoped; non deve fingere che un daemon amministrativo sia un normale launch user-scoped.

Quella generalizzazione non viene introdotta in questa tranche.

## 11. Deferred

Restano esplicitamente fuori dalla baseline corrente:

```text
systemd adapter
launchd adapter
install/uninstall host service
enable/disable host service
system-service launch context package
readiness protocol generico
health checks generici
service dependency graph
socket activation
timer/scheduled jobs
multi-instance service
restart policy automatica
SIGKILL automatico
security model gestito da m/RumiAI
```

## 12. Invarianti

```text
SRV-01  srv appartiene a m
SRV-02  il comando pubblico si chiama srv
SRV-03  la baseline espone start e stop
SRV-04  <service>-start è il target convenzionale del lifecycle locale
SRV-05  il target viene canonicalizzato prima del launch
SRV-06  srv non duplica il package launcher
SRV-07  il lifecycle locale non dipende da systemd o launchd
SRV-08  il lifecycle locale non richiede privilegi amministrativi per contratto
SRV-09  srv usa state-path per run e log
SRV-10  user state non viene reinterpretato come POSIX user identity
SRV-11  caller ownership è lifecycle metadata, non sicurezza
SRV-12  stop normale usa SIGTERM e non escalation automatica a SIGKILL
SRV-13  readiness applicativa non appartiene al wrapper generico
SRV-14  host supervision è opt-in e separata dalla baseline portabile
SRV-15  system-wide supervision richiede un confine amministrativo esplicito
SRV-16  un service account system-wide non possiede per default una useful root writable
SRV-17  nessun supervisor daemon interno a m viene introdotto dalla baseline
SRV-18  gli adapter host richiedono validazione separata prima della promozione
```
