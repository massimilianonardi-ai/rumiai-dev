# RumiAI package manager — State model draft

Data: 2026-08-29

Stato: **design draft — non ancora specifica normativa**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-integration-context/README.md
drafts/rumiai-os/package-manager-dependency-model/README.md
```

Questo documento formalizza la separazione già presente concettualmente nell'antenato di `m` fra software installato e stato operativo (`conf`, `data`, `home`, `log`, `pid`, `tmp`).

---

# 1. Principio centrale

```text
Package Instance
    !=
State Instance
```

Una Package Instance rappresenta software immutabile.

Una **State Instance** rappresenta lo stato mutabile usato da una specifica istanza logica di utilizzo del software.

Cambiare versione del software non deve significare automaticamente creare, modificare o cancellare lo stato.

---

# 2. State Instance

Una State Instance è un insieme identificabile di aree mutabili che può essere associato a una Package Instance durante la costruzione di un Execution Environment.

Esempio concettuale:

```text
pulsar / state profile default

config
data
home
cache
log
tmp
runtime
```

La nomenclatura fisica e la distinzione definitiva delle aree non sono ancora fissate.

---

# 3. Identità indipendente dalla software version

La State Instance NON deve essere identificata dalla versione concreta della Package Instance.

Esempio:

```text
pulsar 1.0
pulsar 1.1
pulsar 2.0
```

possono, se compatibili, utilizzare la stessa:

```text
state:pulsar/default
```

Questo permette:

```text
upgrade software
    senza duplicare automaticamente i dati

downgrade/rollback
    senza dover ricostruire lo stato da zero
```

La compatibilità dello stato deve però essere verificata separatamente.

---

# 4. State profile multipli

Lo stesso software può avere più State Instance indipendenti.

Esempio:

```text
pulsar/default
pulsar/work
pulsar/test
```

Lo stesso Package Instance può quindi essere eseguito in context differenti con dati/configurazioni differenti.

Un Integration Profile e uno State Profile non sono la stessa cosa.

Esempio:

```text
Integration Profile: default-java21
State Instance: pulsar/work
```

sono dimensioni ortogonali che un Execution Environment può combinare.

---

# 5. State roles

Invece di assumere pathname applicativi specifici, RumiAI dovrebbe modellare poche **state role** semantiche.

Candidate:

```text
config
    configurazione persistente modificabile

data
    dati persistenti dell'applicazione

home
    home applicativa/utente virtualizzata quando necessaria

cache
    dati ricostruibili

log
    log prodotti durante l'esecuzione

tmp
    temporanei

runtime
    pid/socket/lock e altri dati validi solo durante l'esecuzione
```

Non tutte le Package Instance devono usare tutti i role.

Il mapping concreto fra role e environment/path richiesti dal software appartiene alla sua descrizione di esecuzione/integration.

---

# 6. Persistent vs disposable

Le state role non hanno tutte la stessa semantica di conservazione.

Proposta iniziale:

```text
persistent by default:
    config
    data
    home

reconstructible/disposable by default:
    cache
    tmp
    runtime

policy-dependent:
    log
```

La cancellazione di una Package Instance non deve automaticamente cancellare le aree persistenti.

---

# 7. Package defaults != mutable state

Una Package Instance può contenere template/default iniziali.

Esempio:

```text
package/defaults/config/...
package/defaults/home/...
```

Ma questi file restano parte del package immutabile.

Quando viene creata una nuova State Instance possono essere usati per inizializzarla.

Dopo l'inizializzazione:

```text
package defaults
    !=
state corrente
```

Un upgrade del package non deve sovrascrivere silenziosamente configurazione o dati già modificati.

---

# 8. State schema version separata dalla software version

La compatibilità dello stato non può essere dedotta automaticamente dalla versione software.

Una Package Instance dovrebbe poter dichiarare, in futuro, qualcosa di equivalente a:

```text
state schema understood: 3..5
state schema produced: 5
```

La sintassi non è definita.

Il principio è:

```text
software version
    !=
state schema version
```

Due versioni software diverse possono comprendere lo stesso schema.

Una singola nuova versione software può invece introdurre un'incompatibilità dello schema.

---

# 9. Upgrade conservativo

Nel modello stretto iniziale, un upgrade è consentito senza trasformazioni di stato solo se la nuova Package Instance dichiara compatibilità con lo schema della State Instance esistente.

Esempio:

```text
current package: A 1.0
state schema: 4
new package A 1.1 supports schema 4..5

→ switch Package Instance possibile
```

Caso incompatibile:

```text
state schema: 4
new package supports only schema 6

→ upgrade NON deve procedere silenziosamente
```

La migrazione automatica è un sottosistema futuro.

---

# 10. Migration come operazione separata

Una state migration non deve essere nascosta dentro il semplice cambio di symlink/versione.

Concettualmente:

```text
State Instance schema 4
        ↓ explicit migration
State Instance schema 6
        ↓
new Package Instance
```

La migration può richiedere:

```text
snapshot
backup
forward migration
rollback strategy
validation
```

Queste responsabilità verranno progettate separatamente.

---

# 11. Rollback

Se un upgrade cambia solo la Package Instance e NON cambia lo state schema:

```text
A1 + state S
    ↓ switch
A2 + state S
```

il rollback può essere quasi banale:

```text
A2 + state S
    ↓ switch
A1 + state S
```

purché A1 sia ancora nello store e supporti S.

Se lo stato è stato migrato a uno schema incompatibile, il rollback richiede invece una snapshot o una reverse migration.

Quindi il package manager non deve promettere rollback universale senza considerare lo state schema.

---

# 12. Execution Environment seleziona la State Instance

Il binding fra software e stato avviene nell'Execution Environment.

Esempio:

```text
Package Instance:
    pulsar 1.120

State Instance:
    pulsar/work

Execution Environment:
    package = pulsar 1.120
    state = pulsar/work
```

Il package può quindi ricevere pathname/variabili appropriati per:

```text
config
data
home
cache
...
```

senza modificare la Package Instance.

---

# 13. Environment mapping dichiarativo

Una Package Instance può dichiarare come usare le state role.

Esempio concettuale:

```text
HOME = state:home
XDG_CONFIG_HOME = state:config
XDG_CACHE_HOME = state:cache
```

oppure un parametro command-line potrebbe referenziare:

```text
--data-dir state:data
```

La sintassi concreta è fuori scope.

Il requisito è che il mapping sia dichiarativo e referenzi risorse semantiche, non pathname host hardcoded.

---

# 14. State ownership e dipendenze

Per default una dependency privata non deve condividere automaticamente la State Instance del package root.

Esempio:

```text
pulsar
└── Java 17
```

Java può essere sostanzialmente stateless oppure avere proprie cache/runtime areas.

Non deve scrivere arbitrariamente dentro `pulsar/data` soltanto perché è una dipendenza.

Regola candidata:

> **Ogni state ownership deve essere esplicita; la dependency relation non implica automaticamente condivisione dello stato.**

---

# 15. Deintegrate, uninstall, purge

Tre operazioni devono rimanere distinte.

```text
deintegrate
    rimuove il package/profile binding
    NON cancella Package Instance
    NON cancella State Instance

uninstall/store-remove
    rimuove una Package Instance non più referenziata
    NON cancella automaticamente State Instance persistenti

purge-state
    operazione esplicita che elimina una State Instance
```

Questo impedisce che la rimozione temporanea del software distrugga dati dell'utente.

---

# 16. Orphan state

È possibile che una State Instance rimanga senza Package Instance attualmente installata.

Questo non è necessariamente un errore.

Esempio:

```text
utente disinstalla temporaneamente Pulsar
ma conserva pulsar/work
```

Una futura reinstallazione compatibile può riutilizzare quello stato.

Il sistema deve quindi poter distinguere:

```text
orphan package instances
orphan state instances
```

con policy di garbage collection differenti.

---

# 17. Snapshot come primitive futura naturale

La separazione fra Package Instance e State Instance rende naturale una futura snapshot:

```text
Package Instance identity
Resolved dependency graph
Resolved Integration Profile
State Instance snapshot(s)
```

Questo può diventare il fondamento di:

```text
upgrade transaction
rollback
backup
reproducible execution profile
```

ma non viene implementato nel v0.

---

# 18. Casi di stress

## 18.1 Upgrade senza state change

```text
Pulsar 1.0 + state schema 3
→ Pulsar 1.1 supports schema 3
→ switch package, stesso state
```

## 18.2 Upgrade incompatibile

```text
Pulsar 1.0 + schema 3
→ Pulsar 2.0 requires schema 5
→ STOP / migration richiesta
```

## 18.3 Due profili di utilizzo

```text
Pulsar Package Instance unica

state:pulsar/default
state:pulsar/work
```

Due Execution Environment possono usare lo stesso software con stati completamente separati.

## 18.4 Rollback semplice

```text
A1 supports schema 4
A2 supports schema 4
state = schema 4

A1 → A2 → A1
```

nessuna conversione di dati necessaria.

## 18.5 Deintegration

```text
remove Pulsar from default Integration Profile
```

non cancella né il package store né `state:pulsar/default`.

---

# 19. Invarianti candidate

```text
SM-01 Package Instance != State Instance

SM-02 State Instance identity non dipende dalla software version concreta

SM-03 stesso package può avere più State Instance/profile

SM-04 Integration Profile != State Profile

SM-05 package defaults != mutable state

SM-06 software version != state schema version

SM-07 upgrade non modifica implicitamente state incompatibile

SM-08 migration è operazione esplicita separata

SM-09 rollback semplice è possibile solo quando le versioni coinvolte comprendono lo stesso state schema

SM-10 Execution Environment seleziona esplicitamente Package Instance e State Instance

SM-11 dependency relation non implica condivisione automatica dello stato

SM-12 deintegrate != uninstall != purge-state

SM-13 State Instance può sopravvivere alla rimozione del software
```

---

# 20. Modello complessivo dopo i tre draft

```text
                        RUMIAI STORE
                             │
                      Package Instance
                             │
                     Package Interface
                             │
                Execution Requirements
                             │
                           resolve
                             │
                  Resolved Dependency Graph
                             │
             ┌───────────────┴────────────────┐
             │                                │
Desired Integration Profile             State Instance
             │                                │
           resolve                            │
             │                                │
Resolved Integration Profile                  │
             └───────────────┬────────────────┘
                             │
                    Execution Environment
                             │
                    Launch Specification
                             │
                           process
```

Il package store contiene software immutabile.

Il dependency graph decide quali Package Instance servono.

L'Integration Profile decide cosa è pubblicamente disponibile.

La State Instance decide quali dati mutabili vengono usati.

L'Execution Environment compone questi elementi per un'esecuzione concreta.

---

# 21. Prossime questioni

Prima di un PoC restano almeno quattro decisioni architetturali fortemente collegate:

```text
1. rumiai-store identity + layout
2. formato minimo della Package Interface/metadata
3. resolved-state persistence / transaction boundary
4. command execution/launcher model
```

Solo dopo queste decisioni avrebbe senso costruire un PoC che non venga immediatamente buttato via per un cambio di modello.
