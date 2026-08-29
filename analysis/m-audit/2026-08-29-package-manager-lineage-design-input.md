# RumiAI package manager — genealogia da `m` e input di design

Data: 2026-08-29

Stato: **analisi / design input, non ancora specifica normativa**

Repository storico analizzato:

```text
massimilianonardi/m
```

Snapshot di riferimento:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

Questo documento non ripete l'inventario generale del 2026-08-27. Confronta deliberatamente due generazioni del package manager per ricostruire la visione che deve guidare il package manager di RumiAI OS.

---

## 1. Tesi centrale

Il package manager da costruire non deve essere una replica di `apt`, `brew`, `npm`, `pip` o di un altro package manager esistente.

La genealogia di `m` mostra un obiettivo differente:

> costruire e mantenere un ambiente software proprio, relocatable e componibile, consumando software proveniente da ecosistemi upstream eterogenei senza delegare a questi ecosistemi il modello del sistema RumiAI.

Il package manager è quindi candidato a diventare uno dei meccanismi fondamentali con cui RumiAI OS descrive, materializza e integra il proprio software.

Non deve essere confuso con:

- il package manager nativo dell'host;
- un downloader universale;
- un installer Linux globale;
- un build system;
- un deployment engine completo;
- un catalogo di applicazioni.

Può coordinarsi con tutti questi elementi, ma non deve assorbirne arbitrariamente le responsabilità.

---

## 2. Le due generazioni

### 2.1 Antenato: `var/#_os`

La linea storica più vicina alla vision corrente è:

```text
var/#_os/
└── m/
    ├── bin/pkg
    ├── bin/include/pkg/
    └── def/data/pkg/
```

Il sistema storico contiene una root logica propria, package installati separati dallo stato operativo, profili/work directory, build/composition tramite `mk` e capacità di materializzare una root alternativa per test.

Il package manager è diviso per responsabilità:

```text
parse
search
query
install
integrate
profile
```

Il modello package separa già:

```text
name
platform
version
package skeleton
vendor artifact
integration
mutable state
```

L'implementazione è incompleta e fragile, ma la separazione concettuale è la parte più preziosa della genealogia.

### 2.2 Generazione recente: `cmd/pkg`

La generazione recente introduce un front controller molto più piccolo:

```text
pkg install
pkg uninstall
pkg run
```

ed esplicita provider upstream distinti:

```text
custom
github
codeberg
maven
sourceforge
```

con operazioni comuni come:

```text
versions
latest_version
download_url
```

Questa evoluzione migliora fortemente l'acquisizione di software reale dagli ecosistemi upstream.

Contemporaneamente, però, concentra troppe responsabilità:

```text
provider discovery
artifact selection
download
unpack
postinstall
symlink
application launcher
systemd
users/groups
PostgreSQL
certificati
desktop integration
host package installation
```

Il manifest è inoltre shell code eseguibile e il front controller incorpora path `/m` e persino il pathname del checkout sorgente.

---

## 3. Che cosa l'antenato aveva capito meglio

### 3.1 Il package non è l'artifact vendor

Nel catalogo storico la struttura è sostanzialmente:

```text
<package>/
├── pkg/
│   └── <skeleton>/
└── ver/
    └── <platform>/
        └── <version>/
            ├── link
            └── package
```

La release del vendor seleziona un artifact, mentre il package skeleton descrive come quel software appartiene all'ambiente `m`.

Questa distinzione deve essere preservata.

Concettualmente:

```text
PACKAGE DEFINITION
    identità e integrazione RumiAI

ARTIFACT
    cosa viene realmente acquisito da upstream
```

Uno stesso package definition può essere riutilizzato per molte versioni e piattaforme dell'artifact.

### 3.2 Installazione e integrazione sono operazioni differenti

Il package manager storico separa:

```text
install
    materializza package + payload

integrate
    rende il package parte dell'ambiente
```

Questa separazione è essenziale per RumiAI OS.

Un artifact può esistere nello store senza essere attivo. Un package può essere materializzato in una root senza modificare il sistema host. Un'integrazione può dipendere dal tipo di ambiente in cui il package viene materializzato.

### 3.3 Package immutabile e stato mutabile sono differenti

Lo skeleton storico distingue default:

```text
def/conf
def/data
def/home
```

mentre il runtime dispone anche di aree semantiche per:

```text
conf
data
home
log
pid
tmp
```

Il codice storico contiene già TODO sulla compatibilità dello stato fra versioni differenti.

Il principio da preservare è:

```text
software/package
    !=
user/application state
```

Upgrade, downgrade e uninstall non devono implicitamente significare perdita dello stato.

### 3.4 Il sistema deve poter essere materializzato in una root arbitraria

`mk` e `sys_root` mostrano che la linea storica possedeva già il concetto:

```text
system/package definition
        ↓
materialize into another root
        ↓
validate/run
```

Questo è direttamente coerente con la vision moderna:

```text
hosted root
container
image
device
```

Il package manager non deve hardcodare uno di questi deployment environment, ma deve produrre materiale e intenti che possano essere applicati a una root/target esplicito.

---

## 4. Che cosa la generazione recente ha migliorato

### 4.1 Upstream-first

`cmd/pkg` non richiede che tutto il software venga ripubblicato in un repository proprietario.

Può interrogare direttamente ecosistemi come GitHub, Codeberg, Maven e SourceForge.

Questo è perfettamente coerente con RumiAI:

> usare prodotti esistenti tramite adapter invece di ricostruire artificialmente il loro ecosistema.

Il concetto di **provider** deve quindi restare.

### 4.2 Overlay platform/architecture

La configurazione recente applica varianti basate su:

```text
base
OS
architecture
OS + architecture
```

La forma concreta va ripensata, ma il concetto di overlay/specializzazione è valido ed è coerente anche con `mk`.

### 4.3 Normalizzazione di artifact eterogenei

La generazione recente riconosce una realtà utile:

```text
zip
tar
tar.gz
tar.xz
AppImage
deb
jar
war
...
```

RumiAI non controlla il formato in cui il vendor pubblica il software. Serve quindi un livello di artifact materialization capace di normalizzare formati differenti senza confondere questa responsabilità con la semantica del package.

---

## 5. Dove la generazione recente è regredita architetturalmente

### 5.1 Root portabile trasformata in pathname fisso

`cmd/pkg/pkg` definisce direttamente:

```text
/m/pkg
/m/bin
/m/app
/m/lib
/m/home
/m/conf
```

oltre al pathname del checkout sorgente.

La vision è ancora quella di una root propria, ma l'implementazione non è relocatable.

Nel nuovo sistema tutte le destinazioni devono derivare dal runtime/root/context corrente, mai da pathname host hardcoded.

### 5.2 Manifest == codice arbitrario

I `.conf` recenti vengono sourced e possono definire funzioni `postinstall`, `beforeuninstall`, effettuare discovery remota e modificare variabili globali.

Il provider GitHub usa anche `eval` per espandere URL custom.

Questo confonde:

```text
data
configuration
provider logic
trusted lifecycle code
```

Il nuovo package format deve essere **dichiarativo per default**.

Gli hook eseguibili, se necessari, sono una capability separata con trust e privilegi espliciti.

### 5.3 Il package manager muta direttamente l'host

La generazione recente può:

- eseguire `sudo apt install`;
- creare utenti e gruppi;
- creare unit systemd;
- copiare file in `/usr/share`;
- configurare PostgreSQL;
- generare certificati.

Queste non sono responsabilità universali del core package manager.

Devono diventare, quando realmente necessarie:

```text
integration intents
        ↓
host/materializer adapters
```

### 5.4 Uninstall ricostruito, non registrato

La generazione recente carica la configurazione corrente del package e da essa deduce symlink, launcher e integrazioni da rimuovere.

Questo è fragile: la definizione può essere cambiata dopo l'installazione.

Il nuovo sistema deve registrare ciò che **ha realmente fatto**.

Quindi:

```text
installation plan
        ↓ execution
installation receipt
        ↓
uninstall / rollback
```

L'uninstall deve usare la receipt/state installato, non reinterpretare il manifest corrente sperando che sia identico a quello originario.

---

## 6. Vision recuperata

La linea genealogica complessiva suggerisce che il package manager RumiAI debba essere pensato come:

> **software environment composition substrate**

più che come semplice gestore di archivi.

Il suo compito fondamentale è tradurre una richiesta logica in uno stato software materializzato e verificabile dentro una root RumiAI.

Flusso concettuale:

```text
Package Request
      ↓
Discovery Provider
      ↓
Resolved Package Identity
      ↓
Resolved Artifact(s)
      ↓
Plan
      ↓
Fetch / Verify
      ↓
Stage
      ↓
Materialize package
      ↓
Apply integration intents
      ↓
Commit state + receipt
```

Questa pipeline non implica ancora processi, directory o API definitivi. Rappresenta le responsabilità che non devono essere nuovamente fuse insieme.

---

## 7. Concetti primitivi da mantenere distinti

### Package request

Ciò che l'utente/sistema chiede, ad esempio:

```text
foo
foo@latest
foo@1.2
foo con determinati constraint
```

Non è ancora un'identità installabile.

### Package definition

Descrive il significato del software dentro RumiAI:

- nome;
- compatibility/constraints;
- artifact selectors;
- dependencies;
- integration intents;
- default state/schema;
- eventuali capability fornite.

### Provider

Sa interrogare un ecosistema upstream e trasformare discovery upstream in candidate artifacts/versioni.

Non installa.

### Resolved package

È il risultato immutabile di una risoluzione per una specifica operazione.

Deve distinguere almeno:

```text
package identity
resolved version
platform
provider/provenance
artifact identity
```

### Artifact

È il contenuto acquisibile/verificabile:

```text
URL/source
format
digest
size se nota
signature/trust metadata se disponibili
```

### Package materialization

Colloca il software/package in una root/store destinazione senza ancora assumere integrazione globale nell'host.

### Integration intent

Descrive cosa il package vuole rendere disponibile, per esempio:

```text
command
library
environment contribution
application launcher
service intent
configuration/default state
```

Non deve necessariamente contenere la procedura host-specific per realizzarlo.

### State

Dati mutabili appartenenti all'uso del package, separati dall'installazione immutabile.

### Receipt

Descrive lo stato effettivamente committato:

```text
resolved identities
artifacts/digest
materialized files/state
integration operations realmente applicate
ownership/provenance
```

È la base per audit, uninstall e rollback.

---

## 8. Invarianti candidate

Questi punti sono sufficientemente supportati dalla genealogia da essere trattati come invarianti candidate del PoC.

### I1 — Nessun pathname host globale nel core

Ogni operazione avviene rispetto a una root/context esplicita.

### I2 — Discovery non è resolution

`latest` può essere una richiesta, mai un'identità installata mutable.

### I3 — Resolution non produce side effect

Prima si costruisce il piano completo; poi lo si esegue.

### I4 — Package definition != artifact

RumiAI può descrivere un software una volta e selezionare artifact differenti per release/piattaforma.

### I5 — Materialization != integration

Avere il software nello store/root non significa averlo reso attivo.

### I6 — Package != mutable state

Configurazione, dati e home non devono essere cancellati implicitamente con la versione del package.

### I7 — Uninstall usa stato registrato

L'inverso di un'installazione deriva dalla receipt/transaction state, non dalla versione corrente del manifest.

### I8 — Metadata sono dati per default

Shell code non è il formato ordinario di configurazione.

### I9 — Upstream ecosystems restano esterni

GitHub/Maven/Codeberg/etc. sono provider, non il modello interno del package manager.

### I10 — Host-specific integration è delegata

Il core può esprimere intenti; adapter/materializer decidono come applicarli al target supportato.

---

## 9. Anti-goal iniziali

Il primo package manager RumiAI NON deve ancora tentare di risolvere:

- tutti i formati artifact esistenti;
- tutti i provider;
- semantic versioning universale;
- SAT solver completo;
- servizi systemd/launchd;
- installazione globale dell'host;
- database provisioning;
- desktop integration;
- container/image/device;
- migrazioni di stato complesse;
- firme PKI universali;
- multi-user policy.

Questi aspetti devono emergere da requisiti reali e inserirsi nelle boundary già separate.

---

## 10. Primo PoC proposto

Il primo PoC deve verificare **la differenza filosofica** rispetto a un package manager convenzionale, non il download da Internet.

### Scenario

```text
RumiAI root temporanea vuota
        ↓
package definition dichiarativa
        ↓
artifact locale/statico noto
        ↓
resolve
        ↓
plan immutabile
        ↓
materialize in package store della root
        ↓
integrate un solo command in bin/
        ↓
command eseguibile dalla RumiAI root
        ↓
uninstall tramite receipt
        ↓
root torna allo stato precedente
```

### Deliberatamente esclusi dal PoC 1

```text
network
latest
provider GitHub
dipendenze
upgrade
rollback da failure intermedio
servizi
sudo
host-global filesystem
```

### Cosa deve dimostrare

1. una root arbitraria è il target dell'operazione;
2. package definition e artifact sono separati;
3. resolution produce dati/piano prima dei side effect;
4. materialization e integration sono due step osservabili;
5. viene emessa una receipt;
6. uninstall usa esclusivamente quella receipt;
7. nessuna modifica viene effettuata fuori dalla root di prova.

Se questo PoC è semplice e pulito, la genealogia è stata tradotta correttamente in un nuovo nucleo. Solo dopo ha senso aggiungere provider discovery, versioning e dependency graph.

---

## 11. Evoluzione PoC suggerita

```text
P1  root + package definition + static artifact + receipt
P2  provider adapter: discovery → resolved immutable artifact
P3  cache/store + digest verification
P4  dependency graph resolved completely before execution
P5  staging + transactional commit + rollback
P6  integration adapter per hosted POSIX root
P7  profile/state compatibility e migration
P8  system composition verso ulteriori materializer
```

Questa sequenza non è una roadmap normativa: serve a mantenere ogni esperimento focalizzato su una singola nuova proprietà.

---

## 12. Decisione di direzione proposta

La combinazione da perseguire è:

```text
ANTENATO var/#_os
    modello package/integration/state/root

+

m corrente cmd/pkg
    pragmatismo provider/upstream/artifact heterogeneity

+

nuovo rumiai-os
    relocatability rigorosa
    metadata come dati
    plan prima dei side effect
    receipt
    transactionality
    trust esplicito
```

Non migrare il codice del package manager storico o recente.

Migrare **la visione**, dimostrarla con PoC piccoli e poi promuovere soltanto i contratti provati in `rumiai-os`.
