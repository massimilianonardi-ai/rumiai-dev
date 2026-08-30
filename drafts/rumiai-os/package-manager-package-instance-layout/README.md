# RumiAI package manager — Package Instance internal layout

Data: 2026-08-30

Stato: **design draft — passo successivo al local package/command layout**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
```

Questo documento resta sul lato locale del confine già fissato: il software è già stato prodotto, normalizzato e validato come compatibile con il contratto RumiAI prima della materializzazione locale.

---

# 1. Wrapper fisico e Package Instance logica

La wrapper fisica di una Package Instance ha la forma:

```text
pkg/<package-instance-id>/
├── root/
│   └── <execution tree immutabile>
├── run-default/
│   └── <default mutabili distribuiti/normalizzati>
├── @package
│   <descriptor dichiarativo RumiAI>
└── run/
    <runtime routing view attiva, derivata>
```

La parte immutabile che definisce la Package Instance è:

```text
root/
run-default/
@package
```

`run/` è invece una view derivata e ricostruibile e non partecipa all'identità della Package Instance.

Il pathname `<package-instance-id>` segue la convenzione fissata:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

---

# 2. `root/`: execution tree immutabile

`root/` è il tree con cui il software viene eseguito.

Non deve necessariamente coincidere byte-per-byte con il tree originario del vendor. Prima dell'admission, il lato produzione/adattamento può normalizzare il software per separare in modo sicuro le aree mutabili.

Dopo l'admission:

> `root/` è fisso e immutabile durante installazione, integrazione ed esecuzione.

Da questa parte del confine RumiAI assume quindi che esista già una configurazione di link sicura e fisicamente validata.

---

# 3. Requisito di admission: root fissa

Molto software distribuito come “portable” modifica direttamente file e directory sotto il proprio installation tree, per esempio:

```text
config
data
cache
log
pid
tmp
home applicativa
plugin/runtime-generated files
```

Per RumiAI questo comportamento deve essere normalizzato prima dell'admission.

Regola vincolante per il lato produzione/store:

> se non è possibile produrre una `root/` che resti immutabile durante la normale esecuzione, il package non può essere promosso nel RumiAI store per quella execution platform.

Il package manager locale non tenta workaround dinamici per software che continuano a modificare `root/`.

---

# 4. Writable islands e link relativi

Le aree mutabili devono essere separate, per quanto possibile, a livello di **directory**.

Esempio:

```text
root/log -> ../run/log
root/conf -> ../run/conf
root/cache -> ../run/cache
```

Questa scelta evita il problema dei software che aggiornano singoli file tramite `unlink`, `rename` o atomic replace e potrebbero quindi rimuovere un symlink file-level.

Il criterio di admission deve privilegiare directory mutabili complete (“writable islands”).

File-level redirection può esistere soltanto se il comportamento reale del software è stato validato come sicuro.

---

# 5. `run/`: unica runtime view attiva

Ogni Package Instance possiede **una sola runtime view attiva**.

`run/` contiene esclusivamente il routing corrente delle writable islands verso le directory RumiAI appropriate.

Esempio:

```text
pkg/foo@1.0@r1@linux-arm64/
├── root/
│   └── log -> ../run/log
├── run-default/
│   └── log/
├── @package
└── run/
    └── log -> ../../../log/foo
```

Flusso visto dal software:

```text
root/log
    ↓ relative link
run/log
    ↓ relative link
RUMIAI_ROOT/log/foo
```

Quindi esistono due view intenzionali:

```text
view package/software
    root/<writable-path>

view RumiAI
    home/, data/, log/, pid/, ...
```

`run/` è derivato, non autorevole.

Può essere ricreato, riparato o rimosso senza cambiare la Package Instance.

Poiché esiste una sola view attiva, un eventuale cambio di state/profile per la stessa Package Instance implica la rimaterializzazione di `run/`; il v0 non supporta più runtime view simultanee per la stessa Package Instance.

---

# 6. `run-default/`: factory defaults immutabili

`run-default/` contiene gli analoghi fisici iniziali delle writable islands così come distribuiti dal vendor o risultanti dalla normalizzazione pre-admission.

Serve almeno per:

```text
inizializzazione del primo state
factory reset esplicito
recovery controllato dei default
```

Esempio:

```text
run-default/
├── conf/
│   └── settings.ini
├── data/
│   └── initial.db
└── home/
    └── ...
```

`run-default/` è immutabile e fa parte dell'integrità della Package Instance.

Un “factory reset” NON significa puntare `run/` direttamente a `run-default/`, perché il software lo renderebbe mutabile.

Significa invece, concettualmente:

```text
run-default/<area>
        ↓ copy/materialize
RumiAI mutable state target
        ↓
run/<area> -> target
```

La semantica precisa di reset verrà definita nel modello dello stato, ma il principio è fissato: `run-default/` conserva sempre i default originali e non viene modificato dall'esecuzione.

---

# 7. `@package`: identity e metadata operativi

`@package` è il descriptor dichiarativo della Package Instance e non viene eseguito tramite `source`, `eval` o equivalenti.

Identity minima:

```text
name
version
revision
platform
architecture
display-name
```

`display-name` è human-readable, per esempio:

```text
Pulsar
NetBeans 26
OpenJDK 21
```

Non partecipa al pathname canonico.

I campi canonici:

```text
name
version
revision
platform
architecture
```

devono coincidere con l'identità ricostruita dal pathname.

`@package` dovrà inoltre descrivere almeno:

```text
integrity
runtime mappings per costruire run/
Package Interface
Execution Requirements
state requirements
schema/version del descriptor
```

Il formato concreto resta da decidere.

---

# 8. Integrità di `root/` e `run-default/`

Entrambi gli alberi immutabili devono essere verificabili tramite inventory canonici.

Il modello contiene almeno:

```text
integrity format/version
digest algorithm
numero totale regular files
numero totale directories
numero totale links
record canonico per ogni entry
```

Forma concettuale:

```text
format 1
algorithm sha256
files 3
directories 2
links 1

D\t.
D\t./bin
<digest>\tF\t./bin/foo
<digest>\tF\t./app.jar
<digest-of-link-target>\tL\t./log\t../run/log
```

Principi:

- regular file: digest dei bytes;
- directory: enumerata senza content digest;
- symlink: digest del target testuale, senza dereferenziare;
- ordinamento canonico;
- pathname e target rappresentati senza ambiguità;
- `run/` e i dati mutabili raggiunti tramite `run/` sono esclusi dall'integrità.

Lo stesso metodo di inventory viene applicato a `run-default/`.

È ancora da decidere quali metadata filesystem execution-relevant, per esempio mode/executable bit, entrino nel record canonico.

---

# 9. Manifest digest

Il modello può calcolare un digest dell'intero inventory canonico:

```text
root-digest
    = digest(canonical root inventory)

run-default-digest
    = digest(canonical run-default inventory)
```

L'algoritmo e la versione del metodo devono essere espliciti e versionati.

---

# 10. Immutabilità

Dopo il commit locale:

```text
root/          immutable + integrity-checked
run-default/   immutable + integrity-checked
@package       immutable
run/           derived + rebuildable
```

Una modifica a `root/`, `run-default/` o al significato operativo di `@package` produce una nuova Package Instance/revision.

Una modifica a `run/` cambia soltanto la runtime view attiva.

---

# 11. Stato reale separato

I dati mutabili autorevoli non vivono in `root/`, `run-default/` o `run/`.

Appartengono alle aree RumiAI appropriate, per esempio:

```text
home
data
conf
cache
log
pid
tmp
```

`run/` fornisce soltanto i link attraverso cui il software li raggiunge.

La rimozione di una Package Instance non implica automaticamente la cancellazione dello stato mutabile esterno.

---

# 12. Relocatability

Tutti i riferimenti persistiti sono relativi.

Esempi:

```text
root/log -> ../run/log
run/log  -> ../../../log/foo
```

Non vengono persistiti pathname assoluti della RumiAI root.

---

# 13. Materializzazione transazionale

Una Package Instance non appare sotto `pkg/` finché la parte immutabile non è completa e verificata:

```text
candidate software
        ↓
normalizzazione/adattamento pre-admission
        ↓
build root/ + run-default/ + @package in staging
        ↓
verify identity + integrity + safe writable mappings
        ↓
atomic commit pkg/<package-instance-id>
```

`run/` viene materializzato successivamente in base allo stato attivo.

Lo staging non usa una child directory ordinaria di `pkg/`.

---

# 14. Recovery e uninstall

Se `@package` manca o è corrotto, il pathname permette comunque di ricostruire l'identità minima.

Se `root/` o `run-default/` non corrispondono ai rispettivi inventory, il package è corrotto.

Se manca soltanto `run/`, la Package Instance può restare integra e la runtime view può essere rigenerata.

L'uninstall fisico, dopo dependency/integration checks, rimuove:

```text
pkg/<package-instance-id>/
```

senza implicare il purge dello stato persistente esterno.

---

# 15. Invarianti fissate/candidate

```text
PI-01 core immutabile Package Instance = root/ + run-default/ + @package
PI-02 run/ è runtime routing view derivata e non parte dell'identità/integrità
PI-03 ogni Package Instance ha una sola runtime view attiva
PI-04 root/ deve restare immutabile durante la normale esecuzione
PI-05 se non è possibile produrre una root fissa e sicura, il package non è ammissibile allo store per quella piattaforma
PI-06 la normalizzazione dei writable path avviene prima dell'admission
PI-07 le writable islands devono essere preferibilmente directory redirette tramite link relativi verso ../run/
PI-08 run/ instrada a stato RumiAI tramite ulteriori link relativi
PI-09 run-default/ conserva i default mutabili originari/normalizzati ed è immutabile
PI-10 factory reset materializza una nuova copia mutabile da run-default/, non rende run-default/ direttamente writable
PI-11 @package è descriptor dichiarativo e non codice eseguibile
PI-12 identity canonica del pathname e @package devono concordare
PI-13 display-name è human-readable e non partecipa al pathname canonico
PI-14 root/ e run-default/ possiedono inventory canonici verificabili
PI-15 run/ e i dati mutabili target non partecipano all'integrità della Package Instance
PI-16 stato mutabile reale non vive nel core della Package Instance
PI-17 una Package Instance appare sotto pkg/ soltanto dopo commit del core verificato
PI-18 staging/transazioni non usano child directory ordinarie di pkg/
PI-19 uninstall della wrapper non implica purge dello stato persistente esterno
```

---

# 16. Questioni successive

Prima di Package Interface restano da fissare:

- modello logico dei runtime mappings che costruiscono `run/`;
- tassonomia minima delle aree target (`home`, `conf`, `data`, `cache`, `log`, `pid`, `tmp`, ...);
- semantica di inizializzazione e factory reset a partire da `run-default/`;
- sintassi canonica degli integrity inventory;
- escaping canonico dei pathname nel manifest;
- metadata filesystem execution-relevant inclusi negli integrity record;
- algoritmo iniziale di digest e versioning del metodo;
- supporto fisico dei link relativi sulle reference platform/filesystem.

Solo dopo queste decisioni conviene passare alla **Package Interface**.
