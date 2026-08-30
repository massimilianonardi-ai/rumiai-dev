# RumiAI package manager — Package Instance internal layout

Data: 2026-08-30

Stato: **design draft — passo successivo al local package/command layout**

Prerequisiti:

```text
drafts/rumiai-os/package-manager-v0/README.md
drafts/rumiai-os/package-manager-local-layout/README.md
```

Questo documento resta sul lato locale del confine già fissato: il software eseguibile è già stato prodotto/acquisito ed è candidato alla materializzazione come Package Instance locale.

---

# 1. Wrapper fisico e Package Instance logica

Una **Package Instance** è il contenuto locale immutabile gestito da RumiAI:

```text
root/
@package
```

La sua directory fisica può contenere anche una runtime view derivata e ricostruibile:

```text
pkg/<package-instance-id>/
├── root/
│   └── <execution tree immutabile>
├── @package
│   <descriptor dichiarativo RumiAI>
└── run/
    <runtime routing view derivata>
```

Quindi:

```text
Package Instance identity/integrity
    = root/ + @package

run/
    = stato derivato di integrazione/runtime
    ≠ parte dell'identità della Package Instance
```

Il pathname `<package-instance-id>` segue la convenzione fissata:

```text
<name>@<version-token>@r<revision>@<platform>-<architecture>
```

---

# 2. `root/`: execution tree immutabile

`root/` contiene il tree con cui il software viene eseguito.

Non è necessario che coincida byte-per-byte con il tree originario del vendor: eventuali adattamenti necessari a renderlo compatibile con il contratto RumiAI avvengono **prima dell'admission**, sul lato produzione/adattamento.

Dopo l'admission:

> `root/` è immutabile e l'integrazione non lo modifica.

Il package manager non inserisce successivamente in `root/` metadata, receipt, dati utente o link dipendenti dal particolare stato di integrazione.

---

# 3. Problema dei software “portable” che scrivono nel proprio tree

Molto software distribuito come “portable” conserva dentro la propria directory anche contenuto mutabile, per esempio:

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

Spesso tali pathname sono hardcoded o comunque assunti dal software rispetto alla propria installation directory.

Lasciare questi dati fisicamente sotto `root/` romperebbe:

```text
immutabilità
integrity verification
upgrade/rollback puliti
separazione Package Instance / State Instance
```

Il modello v0 introduce quindi una runtime redirection view.

---

# 4. Runtime redirection tramite doppio livello di link

Quando un'area del tree deve essere mutabile, il tree normalizzato può contenere un **link relativo stabile** verso il pathname speculare sotto `../run/`.

Esempio:

```text
pkg/foo@1.0@r1@linux-arm64/
├── root/
│   ├── bin/
│   ├── lib/
│   └── log -> ../run/log
├── @package
└── run/
    └── log -> ../../../log/foo
```

Il software continua quindi a usare:

```text
<package>/root/log
```

ma l'accesso effettivo diventa:

```text
root/log
    ↓ relative link
run/log
    ↓ relative link
RUMIAI_ROOT/log/foo
```

Il primo livello offre la **view attesa dal software**.

Il secondo livello offre la **view di routing RumiAI** verso le aree di stato appropriate.

Tutti i link devono essere relocatable rispetto all'environment RumiAI; non si persistono pathname assoluti della RumiAI root.

---

# 5. `run/` è derivato, non autorevole

`run/` non contiene dati applicativi autorevoli.

Contiene soltanto la struttura necessaria a instradare le aree mutabili verso le directory RumiAI appropriate.

Può quindi essere:

```text
creato
ricostruito
riparato
rimosso
```

senza cambiare l'identità della Package Instance.

La fonte di verità per ricostruirlo deve essere lo stato di integrazione insieme ai runtime mappings dichiarati in `@package`.

Se `run/` viene perso, il package resta installato; può però essere non eseguibile finché la runtime view non viene ricostruita.

---

# 6. Writable islands: preferenza per directory

Il v0 preferisce redirigere **directory mutabili complete** anziché singoli file.

Motivazione: molti programmi aggiornano file tramite:

```text
unlink
rename
atomic replace
create/delete
```

Un link posto direttamente al posto di un file potrebbe essere rimosso o sostituito dal programma, mutando `root/`.

Se invece una directory è rediretta:

```text
root/log -> ../run/log
```

le normali operazioni create/delete/rename sui suoi figli avvengono fuori da `root/`.

Quindi una proprietà favorevole all'admission v0 è:

> le aree mutabili del software sono separabili in directory (“writable islands”) che possono essere redirette integralmente.

Se file mutabili e file immutabili sono inseparabilmente mescolati nella stessa directory, può essere necessario un adattamento pre-admission; se non è possibile, il package può risultare non ammissibile nel v0.

File-level redirection non è vietata in assoluto, ma richiede che il comportamento reale del software sia compatibile e venga validato fisicamente.

---

# 7. Limiti del meccanismo

Il doppio livello di link non rende automaticamente compatibile ogni software.

Casi problematici includono software che:

```text
rifiuta symlink/link
risolve realpath e richiede che il target resti fisicamente dentro l'installation tree
cancella o sostituisce la directory-link stessa
usa pathname assoluti host non redirigibili
richiede semantiche filesystem incompatibili con il supporto link della piattaforma/reference filesystem
```

Questi casi vengono trattati secondo il principio già fissato di **Physical Platform Validation**.

Il modello logico usa link relativi. La primitiva concreta disponibile su ogni piattaforma/filesystem deve essere verificata sui reference host; il v0 non assume che tutte le combinazioni OS/filesystem abbiano semantiche identiche.

---

# 8. `@package`: identity leggibile + metadata operativi

`@package` è il descriptor dichiarativo della Package Instance e non viene eseguito tramite `source`, `eval` o meccanismi equivalenti.

Il blocco identity deve contenere almeno:

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

Non partecipa al pathname canonico e non sostituisce `name`.

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

Il formato concreto non è ancora deciso.

---

# 9. Integrità di `root/`

L'integrità di `root/` deve essere verificabile tramite un inventory manifest canonico.

Il modello richiesto contiene almeno:

```text
integrity format/version
digest algorithm
numero totale regular files
numero totale directories
numero totale links
record canonico per ogni entry del tree
```

Forma concettuale lineare, simile a un output `find`, con path relativo a `root/`.

Esempio:

```text
format 1
algorithm sha256
files 3
directories 2
links 1

D	.
D	./bin
<digest>	F	./bin/foo
<digest>	F	./app.jar
<digest-of-link-target>	L	./log	../run/log
```

Principi:

- una regular file possiede il digest dei propri bytes;
- una directory compare nell'inventory ma non possiede content digest;
- un link compare come entry propria e la sua integrità deve includere almeno il target testuale del link, senza dereferenziare il contenuto mutabile puntato;
- l'ordinamento delle entry deve essere canonico;
- pathname e link target devono avere una rappresentazione non ambigua anche in presenza di caratteri speciali;
- `run/` e i dati raggiunti tramite `run/` NON partecipano all'integrità di `root/`.

La sintassi esatta dell'inventory e l'escaping dei pathname verranno fissati separatamente.

È ancora da decidere quali metadata filesystem execution-relevant, per esempio executable permission/mode, debbano entrare nel record canonico oltre al contenuto.

---

# 10. Manifest digest

Oltre ai digest dei singoli file/link, è utile che il modello possa calcolare un digest dell'intero inventory canonico.

Concettualmente:

```text
root-digest
    = digest(canonical integrity manifest)
```

In questo modo il root digest cambia se cambia almeno uno dei seguenti elementi rappresentati nel manifest:

```text
path presente/assente
tipo entry
contenuto file
target di un link
directory presente/assente
metadata canonici eventualmente inclusi
```

L'algoritmo/versione del metodo di digest deve essere esplicito e versionato; non deve essere implicito nel codice corrente del package manager.

---

# 11. Immutabilità e integrità

Dopo il commit locale:

```text
root/       immutable + integrity-checked
@package    immutable
run/        derived + rebuildable
```

Una modifica a `root/` o una modifica semantica a `@package` produce una nuova Package Instance/revision, non una mutazione in-place.

Una modifica a `run/` non cambia la Package Instance: cambia soltanto la runtime/integration view.

---

# 12. Stato mutabile escluso dal core della Package Instance

I dati mutabili reali non vivono in `root/` e non devono essere memorizzati autorevolmente in `run/`.

Sono esclusi dal core della Package Instance almeno:

```text
home applicativa/utente
configurazione mutabile
data persistenti
cache runtime
log
PID
socket
temporary files
receipt di integrazione
indici del package manager
```

`run/` può soltanto fornire i pathname/link attraverso i quali il software raggiunge tali aree.

---

# 13. Relocatability

I riferimenti interni sono relativi.

Esempi:

```text
command java -> root/bin/java
root/log     -> ../run/log
```

I link di `run/` verso le directory RumiAI devono anch'essi essere relativi alla posizione fisica dell'environment.

Non si persistono pathname assoluti della RumiAI root come parte della Package Instance o della runtime view.

---

# 14. Materializzazione transazionale

Una Package Instance non appare sotto `pkg/` finché il core immutabile non è completo e verificato:

```text
candidate software
        ↓
normalizzazione/adattamento pre-admission
        ↓
build root/ + @package in staging
        ↓
verify identity + integrity
        ↓
atomic commit pkg/<package-instance-id>
```

`run/` può essere materializzato dopo il commit quando esiste uno stato di integrazione/runtime da applicare.

Lo staging non usa una child directory ordinaria di `pkg/`.

---

# 15. Recovery e uninstall

Se `@package` manca o è corrotto, il pathname permette di ricostruire l'identità minima e classificare il package come recuperabile/inconsistente.

Se `root/` non corrisponde all'inventory di integrità, il package è corrotto.

Se manca soltanto `run/`, il core della Package Instance può restare sano e la runtime view può essere rigenerata.

L'uninstall fisico, dopo dependency/integration checks, rimuove la directory:

```text
pkg/<package-instance-id>/
```

I dati reali raggiunti tramite `run/` restano separati e non vengono cancellati implicitamente.

---

# 16. Invarianti fissate/candidate

```text
PI-01 Package Instance logica = root/ + @package
PI-02 run/ è runtime routing view derivata e non parte dell'identità/integrità
PI-03 ogni Package Instance locale ha una singola wrapper directory immediata sotto pkg/
PI-04 root/ è execution tree immutabile dopo l'admission
PI-05 eventuale normalizzazione dei writable path avviene prima dell'admission
PI-06 le writable islands sono preferibilmente directory redirette tramite link relativi verso ../run/
PI-07 run/ instrada a stato RumiAI tramite ulteriori link relativi
PI-08 @package è descriptor dichiarativo e non codice eseguibile
PI-09 identity canonica del pathname e @package devono concordare
PI-10 display-name è human-readable e non partecipa al pathname canonico
PI-11 root/ possiede un inventory canonico con digest per file e link, directory enumerate e conteggi iniziali
PI-12 run/ e i dati mutabili target non partecipano all'integrità di root/
PI-13 run/ deve essere ricostruibile dallo stato di integrazione + runtime mappings dichiarati
PI-14 stato mutabile reale non vive nel core della Package Instance
PI-15 dependency package-to-package non vengono cablate dentro root/ tramite install-time mutation
PI-16 una Package Instance appare sotto pkg/ soltanto dopo commit del core verificato
PI-17 staging/transazioni non usano child directory ordinarie di pkg/
PI-18 uninstall della wrapper non implica purge dello stato persistente esterno
```

---

# 17. Questioni successive

Prima di Package Interface restano da fissare:

- modello logico dei runtime mappings che costruiscono `run/`;
- semantica precisa delle State Instance target (`home`, `data`, `log`, `pid`, ecc.);
- se una singola `run/` package-local può rappresentare più state/profile contemporanei oppure se il runtime routing dovrà essere scoped;
- sintassi canonica dell'integrity inventory;
- escaping canonico dei pathname nel manifest;
- metadata filesystem execution-relevant inclusi nell'integrity record;
- algoritmo iniziale di digest e versioning del metodo;
- supporto fisico dei link relativi sulle reference platform/filesystem.

Solo dopo queste decisioni conviene passare alla **Package Interface**.
