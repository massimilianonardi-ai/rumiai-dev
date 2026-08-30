# RumiAI package manager — Package Instance internal layout

Data: 2026-08-30

Stato: **design draft — struttura fisica Package Instance fissata**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
drafts/rumiai-os/package-manager-state-model/README.md
```

Questo documento resta sul lato locale del confine già fissato: il software è già stato prodotto, normalizzato e validato come compatibile con il contratto RumiAI prima della materializzazione locale.

---

# 1. Wrapper fisica e Package Instance logica

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

`run/` è una view derivata e ricostruibile e non partecipa all'identità/integrità della Package Instance.

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
root/log   -> ../run/log
root/conf  -> ../run/conf
root/cache -> ../run/cache
```

Questa scelta evita il problema dei software che aggiornano singoli file tramite `unlink`, `rename` o atomic replace e potrebbero quindi rimuovere un symlink file-level.

Il criterio di admission privilegia directory mutabili complete (“writable islands”).

File-level redirection può esistere soltanto se il comportamento reale del software è stato validato come sicuro.

I link presenti in `root/` verso `run/` fanno parte dell'integrità di `root/`: ne vengono verificati pathname e target testuale, senza dereferenziare lo stato mutabile raggiunto.

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
    └── log -> ../../../log/foo@s1/log
```

Flusso visto dal software:

```text
root/log
    ↓ relative link
run/log
    ↓ relative link
RUMIAI_ROOT/log/<state-id>/log
```

`run/` è derivato, non autorevole.

La directory `run/` viene creata durante la materializzazione della wrapper, **prima del sealing della directory package**. Dopo il commit non si elimina e ricrea normalmente `run/`: si ricostruisce il suo contenuto.

Questo è necessario perché la wrapper package viene resa non-writable per proteggere i nomi `root/`, `run-default/`, `@package` e `run/` dalle normali operazioni di rename/unlink.

---

# 6. `run-default/`: factory defaults immutabili

`run-default/` contiene gli analoghi fisici iniziali delle writable islands così come distribuiti dal vendor o risultanti dalla normalizzazione pre-admission.

Serve almeno per:

```text
inizializzazione del primo state
factory reset esplicito
recovery controllato dei default
```

`run-default/` è immutabile e fa parte dell'integrità della Package Instance.

Un factory reset NON rende `run-default/` writable e non fa puntare direttamente `run/` ai default.

Concettualmente:

```text
run-default/<area>
        ↓ materialize/copy
RumiAI mutable state target
        ↓
run/<area> -> target
```

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

`@package` descrive inoltre almeno:

```text
integrity
runtime mappings
state compatibility/scope
Package Interface
Execution Requirements
schema/version del descriptor
```

Il formato concreto resta da decidere.

---

# 8. Integrità di `root/` e `run-default/`

Entrambi gli alberi immutabili sono verificabili tramite inventory canonici.

Il modello contiene almeno:

```text
integrity format/version
digest algorithm
numero totale regular files
numero totale directories
numero totale links
record canonico per ogni entry
mode POSIX canonico per regular file e directory
```

Forma concettuale:

```text
format 1
algorithm sha256
files 2
directories 2
links 1

D\t0500\t.
D\t0500\t./bin
<digest>\tF\t0500\t./bin/foo
<digest>\tF\t0400\t./app.jar
<digest-of-link-target>\tL\t./log\t../run/log
```

Principi fissati:

- regular file: digest dei bytes + mode canonico;
- directory: enumerata senza content digest + mode canonico;
- symlink: digest del target testuale, senza dereferenziare; mode/UID/GID del symlink non partecipano all'integrity;
- ordinamento canonico;
- pathname e target rappresentati senza ambiguità;
- `run/` e i dati mutabili raggiunti tramite `run/` sono esclusi dall'integrità;
- UID/GID concreti NON partecipano all'integrity;
- ACL aggiuntive NON partecipano al modello: nel core Package Instance v0 non sono ammesse;
- setuid, setgid e sticky bit non sono ammessi nel core Package Instance v0.

Lo stesso metodo di inventory viene applicato a `run-default/`.

La sintassi canonica definitiva di pathname/escaping e il digest method/version esatto restano specifiche tecniche successive, ma il contenuto semantico dell'inventory è fissato.

---

# 9. Normalizzazione dei mode immutabili

Il core Package Instance non conserva arbitrariamente tutte le permission vendor.

Nel v0 i mode ordinari vengono normalizzati a:

```text
regular non-executable    0400
regular executable        0500
directory immutable       0500
@package                  0400
```

Quindi l'executable bit è parte dell'integrity e della semantica della Package Instance.

Qualunque write bit sotto `root/` o `run-default/` è incompatibile con il core immutabile v0.

Quando un file/default viene materializzato in una State Instance mutabile, la copia operativa riceve permission writable appropriate all'Environment Owner; i write bit non vengono conservati nel core immutabile.

---

# 10. Manifest digest

Il modello calcola un digest dell'intero inventory canonico:

```text
root-digest
    = digest(canonical root inventory)

run-default-digest
    = digest(canonical run-default inventory)
```

Il digest cambia se cambia qualunque elemento rappresentato nel manifest, incluso il mode canonico di regular file/directory.

L'algoritmo e la versione del metodo sono espliciti e versionati.

---

# 11. Environment Owner

RumiAI v0 non richiede `root:root`, un utente di sistema `rumiai` o un gruppo speciale.

Ogni environment RumiAI ha un unico **Environment Owner**:

> l'utente OS che possiede, gestisce ed esegue quell'environment RumiAI.

Su Unix-like:

```text
owner = Environment Owner
group = gruppo ordinario assegnato dal sistema/filesystem
```

Il gruppo concreto non ha significato architetturale nel v0 e non viene usato per condivisione multi-user.

UID/GID numerici:

```text
NON fanno parte della Package Instance identity
NON fanno parte dell'integrity manifest
NON vengono persistiti come identità RumiAI
```

Questo evita di legare una Package Instance a UID/GID host-specific.

---

# 12. Permission della RumiAI root e delle aree mutabili

Il modello Unix-like v0 è single-user a livello filesystem.

Default:

```text
RUMIAI_ROOT/   0700
pkg/           0700
bin/           0700
conf/          0700
data/          0700
home/          0700
cache/         0700
log/           0700
run/           0700
tmp/           0700
```

Le directory delle singole State Instance sono normalmente `0700` e appartengono all'Environment Owner.

Il default `umask` per processi lanciati da RumiAI è `0077`, salvo futura estensione esplicita del modello di execution per software fisicamente validato che richieda semantiche differenti.

---

# 13. Sealing della Package Instance

Su Unix-like il write bit del file non impedisce da solo rename/unlink: tali operazioni dipendono anche dalla directory parent.

Per questo la wrapper package viene sigillata:

```text
pkg/<package-instance-id>/    0500
├── root/                     0500
├── run-default/              0500
├── @package                  0400
└── run/                      0700
```

`run/` viene precreata prima del sealing.

Dopo il sealing:

```text
root/          namespace + contenuto immutabile
run-default/   namespace + contenuto immutabile
@package       immutabile
run/           nome stabile; contenuto derivato e writable
```

Il package manager ricostruisce `run/*`, non sostituisce normalmente la directory `run/` stessa.

---

# 14. Immutabilità: protezione accidentale + verifica

Poiché l'Environment Owner possiede gli inode, può deliberatamente cambiare permission e modificare il package.

Il v0 NON pretende quindi di creare una security boundary contro l'Environment Owner.

Il contratto è:

```text
immutability by contract
+
filesystem protection contro modifiche accidentali
+
integrity verification
```

Non richiede:

```text
root ownership
privileged helper
read-only mount
filesystem immutable flag
```

Se il contenuto immutabile viene alterato deliberatamente o accidentalmente, il package manager deve rilevare un integrity failure.

---

# 15. ACL, special bits e symlink metadata

Nel core Package Instance v0:

```text
POSIX ACL aggiuntive    vietate
setuid                  vietato
setgid                  vietato
sticky bit              vietato
```

Le ACL ereditate o semantiche equivalenti del filesystem devono essere normalizzate/validate fisicamente.

Per i symlink l'identità portabile comprende il pathname e il target testuale; ownership e mode concreti del link non fanno parte dell'integrity RumiAI.

---

# 16. Relocatability e filesystem portability

Tutti i riferimenti persistiti sono relativi.

Esempi:

```text
root/log -> ../run/log
run/log  -> ../../../log/<state-id>/log
```

Non vengono persistiti pathname assoluti della RumiAI root.

Il contratto logico usa `Environment Owner`, non UID/GID numerici.

La praticabilità fisica deve essere validata per la combinazione:

```text
OS
+
filesystem
+
mount semantics
```

Un filesystem che non supporta adeguatamente permission, ownership o link richiesti dal contratto può rendere non supportata quella Reference Installation, anche se l'OS nominale è compatibile.

---

# 17. Materializzazione transazionale

Una Package Instance non appare sotto `pkg/` finché la struttura non è completa e verificata:

```text
candidate software
        ↓
normalizzazione/adattamento pre-admission
        ↓
build root/ + run-default/ + @package + empty run/ in staging
        ↓
normalize mode / ownership semantics
        ↓
verify identity + integrity + safe writable mappings
        ↓
atomic commit pkg/<package-instance-id>
        ↓
seal wrapper
```

Lo staging non usa una child directory ordinaria di `pkg/`.

---

# 18. Recovery e uninstall

Se `@package` manca o è corrotto, il pathname permette comunque di ricostruire l'identità minima.

Se `root/` o `run-default/` non corrispondono ai rispettivi inventory, il package è corrotto.

Se il contenuto di `run/` manca o è corrotto, la Package Instance può restare integra e la runtime view viene rigenerata.

L'uninstall fisico, dopo dependency/integration checks, è un'operazione amministrativa dell'environment, non dell'OS:

```text
verify references
↓
unseal con permission dell'Environment Owner
↓
remove pkg/<package-instance-id>/
```

Non richiede privilegi root e non implica il purge dello stato persistente esterno.

---

# 19. Invarianti fissate

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
PI-14 root/ e run-default/ possiedono inventory canonici verificabili con mode
PI-15 run/ e i dati mutabili target non partecipano all'integrità della Package Instance
PI-16 stato mutabile reale non vive nel core della Package Instance
PI-17 una Package Instance appare sotto pkg/ soltanto dopo commit del core verificato
PI-18 staging/transazioni non usano child directory ordinarie di pkg/
PI-19 uninstall della wrapper non implica purge dello stato persistente esterno

PERM-01 nessuna Package Instance richiede root:root
PERM-02 ogni environment appartiene logicamente a un solo Environment Owner
PERM-03 UID/GID concreti non fanno parte di identity o integrity
PERM-04 group sharing non è supportato nel v0
PERM-05 root/ e run-default/ non contengono write bit
PERM-06 regular file immutabili sono normalizzati a 0400 o 0500
PERM-07 directory immutabili sono normalizzate a 0500
PERM-08 @package è 0400
PERM-09 run/ e state areas sono owner-writable, normalmente 0700
PERM-10 la wrapper package è non-writable; run/ viene precreata e se ne ricostruisce il contenuto
PERM-11 symlink mode/UID/GID non partecipano all'integrity
PERM-12 setuid/setgid/sticky e ACL aggiuntive non sono ammesse nel core Package Instance v0
PERM-13 permissions proteggono da modifiche accidentali; integrity verifica il contenuto effettivo
PERM-14 filesystem/mount ownership semantics fanno parte della Physical Platform Validation
```

---

# 20. Struttura fisica considerata chiusa

Con queste decisioni sono fissati per il v0:

```text
Package Instance wrapper
root immutabile
run-default immutabile
run derivato
writable-island routing
State Instance identity e state areas
integrity inventory semantico
ownership/permission model
filesystem portability boundary
```

Restano da specificare alcuni dettagli tecnici di serializzazione/encoding, ma non cambiano il modello fisico.

Il prossimo nodo architetturale è la **Package Interface**.