# Decisione — State selector semantici e user binding globale

Date: 2026-09-14  
Status: **Accepted / Active — post-2.0.0 correction**

## 1. Scopo

Questa decisione corregge, forward-only dopo il freeze `2.0.0`, la risoluzione delle root di state esposte dal bootstrap `m` e l'associazione dello user state.

Il checkpoint `2.0.0` resta immutabile e continua a identificare esattamente la revisione fissata da:

```text
decisions/rumiai-os/2026-09-14-model-2.0-release-freeze.md
```

Questa decisione non riscrive la specifica o le evidence della release `2.0.0`; definisce il contratto corrente per lo sviluppo successivo su `main` e supersede soltanto le clausole incompatibili elencate qui.

## 2. Motivazione

Il bootstrap tecnico `m` viene eseguito per ogni comando.

La release `2.0.0` risolveva nel bootstrap:

```text
state/system/current -> profile/<profile>
host-id nativo
UID POSIX effettivo
state/user/<host-id>-<uid>
```

Queste operazioni rendono il bootstrap responsabile di selezione e discovery che non sono necessarie per inizializzare il runtime tecnico ad ogni invocazione.

Il nuovo contratto separa quindi:

```text
bootstrap             -> root semantiche stabili
state-path system     -> pathname sotto il selector system corrente
state-path user       -> pathname sotto il binding user corrente oppure default
host                  -> sicurezza e autorizzazione fisica correnti
```

RumiAI resta estraneo a UID, host-id, selector fisici e dettagli di sicurezza dell'host.

## 3. Root state esportate dal bootstrap

Il bootstrap assegna ed esporta esattamente:

```text
m_STATE_DIR="$m_ROOT/state"
m_STATE_SYS_DIR="$m_STATE_DIR/system/current"
m_STATE_USER_DIR="$m_STATE_DIR/user/current"
```

Il bootstrap non deve:

```text
leggere state/system/current
canonicalizzare il target di state/system/current
validare il profilo selezionato
leggere state/user/current
risolvere un user binding
rilevare host-id
rilevare UID
costruire una user identity dall'host
creare o modificare selector di state
```

Le tre variabili sono pathname semantici. Non implicano che il target fisico di un selector sia stato risolto o validato dal bootstrap.

## 4. System selector

Resta valida la struttura:

```text
state/system/current -> profile/<profile>
```

Il selector continua a essere sostituibile amministrativamente e resta esterno al bootstrap.

Il bootstrap non è più fail-closed sulla validità del selector. Un comando che non usa system state deve poter avviarsi anche se `state/system/current` è assente, broken o temporaneamente in sostituzione.

`state-path system ...` resta un resolver puro e restituisce il pathname assoluto semantico sotto:

```text
$m_STATE_DIR/system/current
```

senza canonicalizzare o validare il target del selector. Un'operazione che usa realmente il filesystem osserva quindi l'eventuale errore soltanto al confine in cui il pathname viene consumato.

## 5. User identity e binding globale

Lo scope `user` non identifica più il principal POSIX corrente.

L'identità user di `m` è selezionata globalmente per l'installazione e non è derivata da:

```text
host-id
UID
effective UID
account name
home directory POSIX
```

Il pathname riservato al binding esplicito è:

```text
state/user/current
```

Un binding esplicito esiste quando `state/user/current` è un symbolic link. Il target del link identifica la persistent user identity selezionata.

In assenza di un binding esplicito, la persistent user identity implicita è:

```text
default
```

Il relativo state vive sotto:

```text
state/user/default/
```

`default` non rappresenta un utente autenticato, un account POSIX o un confine di sicurezza. È lo user state condiviso usato quando non è stato pubblicato alcun binding globale.

Questa decisione non introduce un nuovo comando pubblico per creare, importare, cambiare o rimuovere il binding. Il selector è state operativo e una futura facility di gestione potrà essere definita separatamente quando esisterà un requisito di interfaccia concreto.

## 6. Risoluzione `state-path user`

`state-path` resta la primitive pubblica canonica per la risoluzione dello state e resta priva di side effect.

Per lo scope `user` applica esclusivamente questa selezione:

```text
state/user/current è un symlink  -> root semantica state/user/current
altrimenti                        -> root state/user/default
```

Il resolver non crea directory, non pubblica symlink, non modifica binding e non esegue discovery dell'host.

Quando esiste un binding esplicito, il pathname restituito conserva `current` e non viene canonicalizzato sul target. Di conseguenza il binding resta sostituibile senza trasferire ai consumer la conoscenza del layout fisico.

Il contratto pubblico di invocazione resta invariato:

```text
state-path <scope> <owner> <identity> <area> [state-instance]
```

Restano invariati owner, area e State Instance già fissati dal modello 2.0.

## 7. Sicurezza

Il binding user corrente è selezione di identità, non autenticazione e non credenziale bearer.

Nel modello corrente:

```text
m seleziona il namespace di state
l'host governa chi può accedere fisicamente ai file
```

Non esiste quindi più un requisito generale secondo cui la root user di `m` deve appartenere al corrispondente UID POSIX o avere mode `0700` come conseguenza dell'identità `m`.

Permessi restrittivi già usati da singole facility possono restare come comportamento locale o hygiene, ma non costituiscono il confine di identità definito da questa decisione.

Una futura sicurezza gestita da RumiAI/m dovrà attraversare un confine esplicito e potrà usare, ad esempio, archivi cifrati sbloccati tramite password, token o chiavi. Tale modello non viene introdotto qui.

## 8. Git-ignore e runtime state

Resta valida la policy globale:

```text
/state/user/
```

Lo user state, incluso un eventuale `state/user/current`, resta operativo e non appartiene al repository prodotto.

La identity `default` viene materializzata lazily dalle facility che consumano user state attraverso i normali pathname restituiti da `state-path`; non richiede placeholder versionati.

## 9. Package state e HOME

Restano invariati:

```text
state-path come unico resolver pubblico dello state package
HOME risolto al launch da state-path user pkg <pkg> home
state instance nel segmento identity tramite @!
var/ statico e system-scoped
var/ persistente instradato attraverso state/system/current
```

I package e il layer RumiAI non devono ricostruire il binding user né conoscere UID o host-id.

## 10. Relazione con `osarch`

`osarch-update` resta una facility separata e non viene invocata dal bootstrap.

La preparazione host-specific di `osarch` e l'eventuale user binding possono appartenere allo stesso momento operativo quando si cambia host, ma restano responsabilità distinte. Questa decisione non introduce una generica astrazione di "host binding".

## 11. Supersession esplicita

A partire dallo sviluppo successivo al checkpoint `2.0.0`, sono superseded, soltanto per gli aspetti qui corretti, le clausole di `specifications/rumiai-os/MODEL-2.0-MIGRATION.md` che richiedono:

```text
bootstrap -> concrete/canonical m_STATE_SYS_DIR
bootstrap fail-closed su state/system/current
user principal = host-id + UID
state/user/<host-id>-<uid>
host-id nativo come parte dell'identità user di m
ownership/mode della root user derivati dal corrispondente UID come confine di identità
first-use user state per POSIX principal
```

Sono quindi superseded, per la loro parte incompatibile, gli invarianti:

```text
MODEL2-16
MODEL2-17
MODEL2-18
MODEL2-26
```

e i requisiti di test Model 2.0 che impongono host-id/UID user isolation o fail-closed del system selector nel bootstrap.

È inoltre superseded la riga `user principal state: state/user/<host-id>-<uid>` di:

```text
decisions/rumiai-os/2026-09-14-model-2.0-active-document-supersession.md
```

Restano storicamente corretti per la release `2.0.0` i documenti, commit, tag ed evidence che descrivono il contratto precedente.

## 12. Invarianti preservati

Restano invariati e applicabili:

```text
m è il substrate tecnico general-purpose
m non dipende semanticamente da RumiAI
state/ è la root semantica unica
system e user restano gli scope baseline
sys ai pkg restano le owner class baseline
identity precede area
state-path resta il resolver canonico e puro
HOME package è risolto al launch
var/ resta system-scoped e attraversa state/system/current
Git resta forward-only
physical evidence resta revision-specific
```

## 13. Invarianti nuovi

```text
STATESEL-01  il bootstrap esporta m_STATE_DIR=$m_ROOT/state
STATESEL-02  il bootstrap esporta m_STATE_SYS_DIR=$m_STATE_DIR/system/current senza risolvere il selector
STATESEL-03  il bootstrap esporta m_STATE_USER_DIR=$m_STATE_DIR/user/current senza user discovery
STATESEL-04  il bootstrap non legge o valida system/current o user/current
STATESEL-05  l'identità user di m non deriva da host-id o UID
STATESEL-06  state/user/current è l'unico binding user globale esplicito
STATESEL-07  soltanto un symlink state/user/current costituisce binding esplicito
STATESEL-08  senza binding esplicito state-path user usa state/user/default
STATESEL-09  default non è autenticato, privato o associato a un principal POSIX per contratto m
STATESEL-10  state-path conserva side-effect freedom e non canonicalizza il binding selezionato
STATESEL-11  RumiAI e i package non conoscono host-id, UID o layout fisico del binding
STATESEL-12  la sicurezza fisica corrente appartiene all'host e non al binding
STATESEL-13  state/user resta runtime state integralmente ignorato da Git
STATESEL-14  osarch e user binding restano responsabilità distinte
STATESEL-15  il checkpoint e il tag 2.0.0 restano immutabili e descrivono il contratto storico congelato
```
