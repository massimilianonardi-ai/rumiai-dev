# Audit di `massimilianonardi/m` — Package manager, deep dive iniziale

Data: 2026-08-27

Snapshot:

```text
e4faae1c1d9b27cc5503b987ba5e7bf2874c906c
```

## Scopo

Questo documento approfondisce il package manager storico contenuto principalmente in:

```text
var/#_os/m/bin/pkg
var/#_os/m/bin/include/pkg/*
var/#_os/m/def/data/pkg/*
```

L'obiettivo non è migrare il codice, ma ricostruire il modello, individuare problemi concreti e separare i concetti utili dall'implementazione storica.

---

# 1. Modello complessivo ricostruito

Il sistema distingue almeno quattro livelli:

```text
catalog/store
    ↓
package resolution
    ↓
package acquisition/materialization
    ↓
system integration + profile state
```

Il front controller `pkg` delega a moduli distinti:

```text
parse
search
query
install
integrate
profile
```

Questa separazione è un buon punto di partenza concettuale.

---

# 2. Identità di un package

Il formato storico è sostanzialmente:

```text
name/platform/version
```

Il parser gestisce:

- solo nome;
- nome + piattaforma;
- package esatto;
- range di versioni tramite `min:max`;
- wildcard;
- pseudo-versione `latest`.

L'identità installata viene poi normalizzata in un nome filesystem simile a:

```text
name-platform-version
```

con omissioni per `all` e `latest` in alcuni casi.

## Aspetto da preservare

Separare:

```text
package name
platform compatibility
version constraint
resolved version
```

è corretto.

## Problema

Nell'implementazione storica questi concetti vengono compressi troppo presto in stringhe e nomi directory, rendendo parsing e matching fragili.

### Direzione `rumiai-os`

Il resolver dovrebbe lavorare internamente su una struttura logica, non su concatenazioni di stringhe. La rappresentazione filesystem può essere derivata successivamente.

---

# 3. Versioning

`compare_versions()` implementa manualmente il confronto di major/minor/build numerici, con gestione speciale di `latest`.

## Limiti

Il modello non copre in modo generale versioni reali come:

```text
1.2.3-alpha
1.2.3+build
2026.08
17.0.12+7
1.0rc1
vendor-specific version strings
```

Il parser assume inoltre una semantica di range molto semplice.

## Decisione preliminare

**REIMPLEMENT.**

Non va introdotta una dipendenza esterna solo per comodità senza valutarla, ma la grammatica delle versioni deve essere specificata prima del codice.

Il package manager deve distinguere almeno:

```text
version expression
resolved version
vendor version
package revision
```

per evitare che una singola stringa debba rappresentare concetti differenti.

---

# 4. `latest`: discovery e riproducibilità sono confuse

Il catalogo contiene package con directory/versione `latest`.

Sono stati verificati due modelli reali.

## DBeaver

Il package punta direttamente a un URL vendor del tipo:

```text
dbeaver-ce-latest-linux...
```

Il payload può quindi cambiare nel tempo senza che cambi il manifest locale.

## Java

Il file `link` contiene codice shell che scarica/parsa la pagina del vendor e determina dinamicamente un URL di download.

## Problema architetturale

Sono confuse due operazioni diverse:

```text
DISCOVERY
"qual è la release più recente?"

RESOLUTION
"questa richiesta è stata risolta esattamente alla release X"

INSTALLATION
"installa esattamente l'artefatto X verificato"
```

Un'installazione ripetuta dello stesso package `latest` in momenti diversi può produrre ambienti diversi.

## Direzione `rumiai-os`

La discovery può essere dinamica, ma deve produrre una **resolved package identity** immutabile per quella transazione/profilo/lock.

Esempio concettuale:

```text
request: dbeaver@latest
        ↓ discovery
resolved: dbeaver@25.x.y
        ↓
artifact URL + digest + provenance
        ↓
install
```

**Discovery non deve equivalere a installation.**

---

# 5. Package store: skeleton separato dalla versione

Il template storico mostra una separazione importante:

```text
<package>/
├── pkg/
│   └── default/
│       ├── def/
│       └── sys/
└── ver/
    └── <platform>/
        └── <version>/
            ├── link
            └── package
```

Il file `package` seleziona uno skeleton, mentre `link` descrive o calcola il payload vendor per quella versione/piattaforma.

## Valore architetturale

Questo permette teoricamente di riutilizzare la stessa integrazione per più release dello stesso software.

È un'idea forte e compatibile con `rumiai-os`.

## Evoluzione proposta da studiare

Separare formalmente:

```text
package definition
artifact definition
platform selector
version resolution
integration definition
state/default definition
```

senza affidare tale separazione alla convenzione implicita delle directory.

---

# 6. Package metadata vs codice eseguibile

Nel modello storico diversi file di metadata sono in realtà shell code sourced dal package manager.

Esempi:

```text
ver/.../link
sys/postdownload
sys/postinstall
```

Il template `postinstall` contiene sia una definizione di funzione sia codice eseguito immediatamente al source.

## Problema

Il package manager non ha un confine netto fra:

```text
data
configuration
trusted code
lifecycle hook
remote-derived information
```

Qualunque file sourced ha il potere del processo package manager.

## Direzione `rumiai-os`

Il formato package dovrebbe essere **dichiarativo per default**.

Gli hook eseguibili possono esistere solo quando realmente necessari, ma devono essere una categoria distinta, esplicita e sottoposta a un trust model.

Da specificare:

- origine;
- firma/digest;
- privilegi;
- filesystem access;
- network access;
- environment esposto;
- rollback;
- audit log.

---

# 7. Dependency model

Il sistema storico possiede già:

```text
sys/depend
DEP_DIR
DEPREV_DIR
```

quindi distingue dipendenze e reverse dependencies.

`install()` legge le dipendenze e richiama ricorsivamente `pkg install`.

## Lacune già visibili

Non è stato ancora trovato un solver completo per:

- cicli;
- conflitti;
- provider alternativi;
- più versioni compatibili;
- optional dependencies;
- pinning;
- scelta globale della combinazione di versioni;
- motivazione per cui un package è installato manualmente vs come dipendenza.

Sono inoltre presenti TODO espliciti nel codice sull'uninstall delle dipendenze.

## Rischio concreto

La semplice ricorsione di installazione non contiene una cycle detection evidente. Un grafo ciclico non può essere gestito correttamente senza stato di risoluzione.

## Direzione `rumiai-os`

Separare:

```text
resolver
    produce un piano

executor
    esegue il piano
```

Il resolver non deve modificare il sistema mentre sta ancora scoprendo il grafo.

---

# 8. Resolver prima, side effects dopo

L'implementazione attuale tende a risolvere, scaricare, estrarre, installare dipendenze e integrare durante lo stesso flusso.

Per `rumiai-os` è preferibile:

```text
request
  ↓
resolve complete graph
  ↓
validate constraints
  ↓
produce immutable plan
  ↓
fetch/verify artifacts
  ↓
materialize transaction
  ↓
integrate
  ↓
commit state
```

Questo è necessario per ottenere:

- prevedibilità;
- dry-run;
- auditabilità;
- rollback;
- installazione atomica;
- riproducibilità.

---

# 9. Bug/incongruenze concrete individuate

## 9.1 `findver()` / naming delle funzioni

Nel modulo `query` è presente una funzione `findver()` che chiama:

```text
parse_pkg_ver_range
```

mentre nel modulo `parse` analizzato sono definite `parse_pkg`, `parse_pkg_exact` e `parse_pkg_range`.

Questo suggerisce un refactoring incompleto o una funzione mancante.

Inoltre lo stesso modulo `query` definisce una funzione shell chiamata `find()`. Questo shadowing del comando POSIX `find` rende particolarmente ambiguo qualsiasi uso di `find` all'interno dello stesso contesto.

`findver()` contiene proprio una chiamata `find ...`, che può quindi risolversi nella funzione package invece che nell'utility filesystem prevista.

**Classificazione: bug/refactoring incompleto da verificare con test.**

## 9.2 Codice uninstall sovrapposto

`include/pkg/install` contiene una prima sequenza di uninstall e, più avanti, un secondo blocco con logica di reverse dependencies e nuova deintegration/rimozione.

La presenza di TODO e due strategie nello stesso flusso indica chiaramente codice in transizione.

**Classificazione: REIMPLEMENT.**

## 9.3 Integration non POSIX

`include/pkg/integrate` usa:

```sh
IFS=$'\n'
```

che non appartiene alla shell POSIX richiesta dal progetto attuale.

Usa inoltre opzioni GNU-specifiche di `diff` nella deintegration.

**Classificazione: implementazione non riutilizzabile direttamente.**

---

# 10. Install vs integrate

La separazione storica è concettualmente valida:

```text
install
    materializza package + payload

integrate
    rende il package disponibile nel sistema
```

L'integration gestisce:

- PATH;
- environment;
- comandi;
- applicazioni;
- librerie;
- stato/profilo;
- hook.

## Evoluzione importante per `rumiai-os`

L'integration non deve essere una sola implementazione.

Potrebbe diventare:

```text
package
   ↓
integration intent
   ↓
target adapter
   ├── hosted POSIX
   ├── container
   ├── image
   └── full OS
```

Lo stesso package può quindi avere una descrizione logica stabile ma differenti materializzazioni.

---

# 11. Stato applicativo

Il package skeleton distingue default per:

```text
conf
data
home
```

Il runtime storico aggiunge:

```text
log
pid
tmp
```

Questa separazione è preziosa perché permette di non confondere package immutabile e stato mutabile.

## Problema aperto già riconosciuto nel codice storico

I TODO di `profile` osservano che configurazioni e dati potrebbero essere compatibili fra più versioni e non dovrebbero necessariamente essere rigidamente legati alla stringa completa del package.

## Direzione `rumiai-os`

Serve un modello esplicito di **state compatibility/migration**, distinto dal package versioning.

---

# 12. Supply chain e artifact integrity

Il percorso storico è approssimativamente:

```text
package metadata
   ↓
URL vendor
   ↓
download
   ↓
extract
   ↓
integrate
```

Nelle parti analizzate non è ancora emerso un controllo sistematico obbligatorio di digest/firma prima dell'installazione.

Questa assenza va verificata sull'intero sottosistema prima di essere dichiarata definitiva, ma per `rumiai-os` il requisito dovrà comunque essere esplicito.

## Modello candidato

Ogni artifact risolto dovrebbe poter registrare almeno:

```text
source/provenance
resolved URL
version
platform
size se nota
cryptographic digest
signature/trust information se disponibile
time of resolution
```

Un alias dinamico `latest` non può sostituire questa identità.

---

# 13. Transaction model mancante

L'installazione storica modifica direttamente directory finali e integration state.

Non è ancora emersa una transazione esplicita del tipo:

```text
prepare → verify → stage → commit → rollback
```

Questo rende da approfondire i casi:

- download interrotto;
- extract fallito;
- dependency fallita a metà;
- postinstall fallito;
- integration parziale;
- power loss/process kill;
- due installazioni concorrenti.

## Direzione `rumiai-os`

Il package manager dovrebbe essere progettato attorno a **state transitions verificabili**, non a una sequenza di side effect sperando che tutti riescano.

---

# 14. Classificazione aggiornata

| Concetto | Valutazione |
|---|---|
| `name/platform/version` | KEEP / REDESIGN |
| package skeleton separato dal payload vendor | KEEP |
| catalogo platform/version | KEEP / REDESIGN |
| `latest` come richiesta utente | KEEP |
| `latest` come identità installabile dinamica | DROP |
| discovery dinamica | KEEP dietro provider |
| resolved immutable artifact | DA INTRODURRE |
| version comparator attuale | REIMPLEMENT |
| recursive dependency install attuale | REIMPLEMENT |
| dependency/reverse-dependency concept | KEEP |
| resolver separato dall'executor | DA INTRODURRE |
| install/integrate separation | KEEP |
| integration implementation attuale | REIMPLEMENT |
| profile/state separation | KEEP / REDESIGN |
| sourced metadata | REDESIGN |
| arbitrary lifecycle hooks | REDESIGN + TRUST MODEL |
| repository/provider abstraction recente | KEEP / REDESIGN |
| transaction/rollback | DA INTRODURRE/VERIFICARE |
| artifact integrity | DA INTRODURRE/VERIFICARE |

---

# 15. Ipotesi architetturale da validare, non ancora decisione

L'audit suggerisce questo modello come candidato:

```text
Package Request
      ↓
Catalog + Provider Discovery
      ↓
Resolver
      ↓
Resolved Package Graph
      ↓
Artifact Fetch + Verification
      ↓
Staging
      ↓
Target Materializer
      ↓
Integration
      ↓
State Commit
```

Con componenti logicamente distinti:

```text
catalog
provider
resolver
fetcher
verifier
store
materializer
integrator
state manager
transaction manager
```

Questa struttura non va ancora trasferita in `rumiai-os`: deve prima essere confrontata con il resto di `m`, in particolare il sistema `mk`, le primitive POSIX e gli altri package definition reali.

---

# 16. Prossimo lavoro sul package manager

Il deep dive deve ora proseguire su:

1. campionamento di package reali Linux/macOS/Windows/all;
2. modello `depend` effettivamente usato nei package;
3. `m-include.lib` e caricamento dei moduli;
4. `net` e package store remoto;
5. `web`, download e verifica artifact;
6. `xtr`, `cm`, `lnk` come primitive di materializzazione;
7. ricerca di checksum/signature e meccanismi di trust;
8. simulazione dei casi dependency conflict/cycle;
9. audit dell'uninstall/deintegration;
10. confronto completo con la generazione recente `cmd/pkg`.
